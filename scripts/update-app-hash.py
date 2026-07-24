#!/usr/bin/env python3
import base64
import hashlib
import json
import re
import sys
import urllib.error
import urllib.request
from pathlib import Path
from urllib.parse import urlparse, unquote

GITHUB_LATEST_RE = re.compile(
    r"^https://github\.com/([^/]+)/([^/]+)/releases/latest/download/([^/?#]+)$"
)
GITHUB_TAG_RE = re.compile(
    r"^https://github\.com/([^/]+)/([^/]+)/releases/download/([^/]+)/([^/?#]+)$"
)
BEEPER_API_URL = (
    "https://api.beeper.com/desktop/download/linux/x64/stable/"
    "com.automattic.beeper.desktop"
)
BEEPER_CDN_RE = re.compile(
    r"^https://beeper-desktop\.download\.beeper\.com/builds/"
    r"Beeper-(\$\{version\}|[0-9]+\.[0-9]+\.[0-9]+)-x86_64\.AppImage$"
)
VERSION_RE = re.compile(r'^(\s*version\s*=\s*)"([^"]+)"([ \t]*;[ \t]*)\n?$')
URL_RE = re.compile(r'^(\s*url\s*=\s*)"([^"]+)"([ \t]*;[ \t]*)\n?$')
HASH_RE = re.compile(r'^(\s*)(sha256|hash)(\s*=\s*)"([^"]+)"([ \t]*;[ \t]*)\n?$')


def fetch_json(url):
    req = urllib.request.Request(
        url,
        headers={
            "Accept": "application/vnd.github+json",
            "User-Agent": "dotfiles-apphash-updater",
        },
    )
    with urllib.request.urlopen(req, timeout=30) as response:
        return json.load(response)


def sha256_hex_to_sri(digest):
    if not digest.startswith("sha256:"):
        raise ValueError(f"unsupported digest format: {digest}")

    raw_hash = bytes.fromhex(digest.removeprefix("sha256:"))
    return "sha256-" + base64.b64encode(raw_hash).decode("ascii")


def github_asset_digest(owner, repo, release, asset_name):
    for asset in release.get("assets", []):
        if asset.get("name") == asset_name:
            digest = asset.get("digest")
            if not digest:
                raise RuntimeError(
                    f"GitHub release asset {owner}/{repo}:{asset_name} has no digest field"
                )
            return sha256_hex_to_sri(digest)

    raise RuntimeError(f"asset {asset_name!r} not found in {owner}/{repo} release")


def github_release_digest(owner, repo, asset_name, tag=None):
    if tag:
        api_url = f"https://api.github.com/repos/{owner}/{repo}/releases/tags/{tag}"
    else:
        api_url = f"https://api.github.com/repos/{owner}/{repo}/releases/latest"

    return github_asset_digest(owner, repo, fetch_json(api_url), asset_name)


def sri_from_sha256_bytes(raw_hash):
    return "sha256-" + base64.b64encode(raw_hash).decode("ascii")


def download_sha256_sri(url):
    req = urllib.request.Request(
        url,
        headers={"User-Agent": "dotfiles-apphash-updater"},
    )
    digest = hashlib.sha256()
    with urllib.request.urlopen(req, timeout=30) as response:
        while chunk := response.read(1024 * 1024):
            digest.update(chunk)

    return sri_from_sha256_bytes(digest.digest())


def beeper_latest_release():
    req = urllib.request.Request(
        BEEPER_API_URL,
        method="HEAD",
        headers={"User-Agent": "dotfiles-apphash-updater"},
    )
    with urllib.request.urlopen(req, timeout=30) as response:
        latest_url = response.url

    match = BEEPER_CDN_RE.match(latest_url)
    if not match or match.group(1) == "${version}":
        raise RuntimeError(f"cannot parse Beeper release from {latest_url}")

    return match.group(1), latest_url


def beeper_update(url, version, current_hash):
    cdn_match = BEEPER_CDN_RE.match(url)
    if url != BEEPER_API_URL and not cdn_match:
        return None

    latest_version, latest_url = beeper_latest_release()
    package_version = version
    new_url = None

    if cdn_match and cdn_match.group(1) != "${version}":
        package_version = cdn_match.group(1)
        new_url = latest_url

    if package_version == latest_version:
        return current_hash, None, None

    print(
        "Beeper does not publish a sha256 release digest; "
        f"downloading {latest_url} to compute it.",
        file=sys.stderr,
    )
    return download_sha256_sri(latest_url), latest_version, new_url


def hash_from_url(url, version, current_hash):
    beeper_result = beeper_update(url, version, current_hash)
    if beeper_result:
        return beeper_result

    tag_match = GITHUB_TAG_RE.match(url)
    if tag_match:
        owner, repo, tag, asset = tag_match.groups()
        tag = unquote(tag)
        asset = unquote(asset)
        if tag == "v${version}":
            release = fetch_json(
                f"https://api.github.com/repos/{owner}/{repo}/releases/latest"
            )
            latest_tag = release.get("tag_name", "")
            if not latest_tag.startswith("v"):
                raise RuntimeError(f"cannot parse GitHub release tag {latest_tag!r}")
            latest_version = latest_tag.removeprefix("v")
            latest_asset = asset.replace("${version}", latest_version)
            new_version = latest_version if latest_version != version else None
            return (
                github_asset_digest(owner, repo, release, latest_asset),
                new_version,
                None,
            )

        return (
            github_release_digest(
                owner,
                repo,
                asset.replace("${version}", version),
                tag.replace("${version}", version),
            ),
            None,
            None,
        )

    url = url.replace("${version}", version)
    latest_match = GITHUB_LATEST_RE.match(url)
    if latest_match:
        owner, repo, asset = latest_match.groups()
        return github_release_digest(owner, repo, unquote(asset)), None, None

    host = urlparse(url).netloc
    raise RuntimeError(
        f"no published sha256 metadata known for {host}; refusing to download the binary"
    )


def read_package(path):
    lines = path.read_text().splitlines(keepends=True)
    url = None
    url_line = None
    version = None
    version_line = None
    hash_line = None
    current_hash = None

    for index, line in enumerate(lines):
        version_match = VERSION_RE.match(line)
        if version_match and version is None:
            version_line = index
            version = version_match.group(2)

        url_match = URL_RE.match(line)
        if url_match and url is None:
            url_line = index
            url = url_match.group(2)

        hash_match = HASH_RE.match(line)
        if hash_match and hash_line is None:
            hash_line = index
            current_hash = hash_match.group(4)

    if not url:
        raise RuntimeError(f"{path}: no fetch url found")
    if not version:
        raise RuntimeError(f"{path}: no version assignment found")
    if hash_line is None:
        raise RuntimeError(f"{path}: no sha256/hash assignment found")

    return lines, url, url_line, version, version_line, hash_line, current_hash


def replace_string_assignment(line, pattern, value):
    match = pattern.match(line)
    return f'{match.group(1)}"{value}"{match.group(3)}\n'


def update_file(path):
    lines, url, url_line, version, version_line, hash_line, current_hash = read_package(path)
    new_hash, new_version, new_url = hash_from_url(url, version, current_hash)
    changed = False

    if new_version and new_version != version:
        lines[version_line] = replace_string_assignment(
            lines[version_line],
            VERSION_RE,
            new_version,
        )
        changed = True

    if new_url and new_url != url:
        lines[url_line] = replace_string_assignment(lines[url_line], URL_RE, new_url)
        changed = True

    hash_match = HASH_RE.match(lines[hash_line])
    updated_hash = (
        f'{hash_match.group(1)}{hash_match.group(2)}{hash_match.group(3)}'
        f'"{new_hash}"{hash_match.group(5)}\n'
    )
    if lines[hash_line] != updated_hash:
        lines[hash_line] = updated_hash
        changed = True

    if changed:
        path.write_text("".join(lines))

    print(f"Hash set in {path}: {new_hash}")


def main(argv):
    if len(argv) != 2:
        print(f"usage: {argv[0]} <homes/apps/*.nix>", file=sys.stderr)
        return 2

    try:
        update_file(Path(argv[1]))
    except (RuntimeError, ValueError, urllib.error.URLError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
