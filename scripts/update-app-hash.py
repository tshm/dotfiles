#!/usr/bin/env python3
import base64
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
BEEPER_VERSION_RE = re.compile(r"Beeper-([0-9]+\.[0-9]+\.[0-9]+)-x86_64\.AppImage$")
VERSION_RE = re.compile(r'^\s*version\s*=\s*"([^"]+)"\s*;\s*$')
URL_RE = re.compile(r'^\s*url\s*=\s*"([^"]+)"\s*;\s*$')
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


def github_release_digest(owner, repo, asset_name, tag=None):
    if tag:
        api_url = f"https://api.github.com/repos/{owner}/{repo}/releases/tags/{tag}"
    else:
        api_url = f"https://api.github.com/repos/{owner}/{repo}/releases/latest"

    release = fetch_json(api_url)
    for asset in release.get("assets", []):
        if asset.get("name") == asset_name:
            digest = asset.get("digest")
            if not digest:
                raise RuntimeError(
                    f"GitHub release asset {owner}/{repo}:{asset_name} has no digest field"
                )
            return sha256_hex_to_sri(digest)

    raise RuntimeError(f"asset {asset_name!r} not found in {owner}/{repo} release")


def beeper_latest_version():
    req = urllib.request.Request(
        BEEPER_API_URL,
        method="HEAD",
        headers={"User-Agent": "dotfiles-apphash-updater"},
    )
    with urllib.request.urlopen(req, timeout=30) as response:
        match = BEEPER_VERSION_RE.search(response.url)
        if not match:
            raise RuntimeError(f"cannot parse Beeper version from {response.url}")
        return match.group(1)


def beeper_current_hash(url, version, current_hash):
    if url == BEEPER_API_URL or BEEPER_CDN_RE.match(url):
        latest_version = beeper_latest_version()
        package_version = version

        cdn_match = BEEPER_CDN_RE.match(url)
        if cdn_match and cdn_match.group(1) != "${version}":
            package_version = cdn_match.group(1)

        if package_version == latest_version:
            return current_hash

        raise RuntimeError(
            "Beeper does not publish a sha256 release digest; "
            f"latest is {latest_version}, package is {package_version}. "
            "Refusing to download the AppImage."
        )

    return None


def hash_from_url(url, version, current_hash):
    beeper_hash = beeper_current_hash(url, version, current_hash)
    if beeper_hash:
        return beeper_hash

    latest_match = GITHUB_LATEST_RE.match(url)
    if latest_match:
        owner, repo, asset = latest_match.groups()
        return github_release_digest(owner, repo, unquote(asset))

    tag_match = GITHUB_TAG_RE.match(url)
    if tag_match:
        owner, repo, tag, asset = tag_match.groups()
        return github_release_digest(owner, repo, unquote(asset), unquote(tag))

    host = urlparse(url).netloc
    raise RuntimeError(
        f"no published sha256 metadata known for {host}; refusing to download the binary"
    )


def read_package(path):
    lines = path.read_text().splitlines(keepends=True)
    url = None
    version = None
    hash_line = None
    current_hash = None

    for index, line in enumerate(lines):
        version_match = VERSION_RE.match(line)
        if version_match and version is None:
            version = version_match.group(1)

        url_match = URL_RE.match(line)
        if url_match and url is None:
            url = url_match.group(1)

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

    return lines, url, version, hash_line, current_hash


def update_file(path):
    lines, url, version, hash_line, current_hash = read_package(path)
    new_hash = hash_from_url(url, version, current_hash)
    match = HASH_RE.match(lines[hash_line])
    updated = f'{match.group(1)}{match.group(2)}{match.group(3)}"{new_hash}"{match.group(5)}\n'

    if lines[hash_line] != updated:
        lines[hash_line] = updated
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
