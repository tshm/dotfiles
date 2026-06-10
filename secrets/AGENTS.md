# Encrypted Secrets

## Purpose

Age-encrypted secrets consumed by NixOS and Home Manager configuration.

## Ownership

- Owns everything under `secrets/`.
- `secrets.nix` owns age recipient mappings and encrypted secret declarations.
- `*.age` files are encrypted payloads only.

## Local Contracts

- Never commit plaintext secrets, decrypted payloads, private keys, passwords, tokens, or temporary secret material.
- Do not decrypt, rotate, replace, or regenerate secret payloads unless the user explicitly asks for that secret operation.
- Keep encrypted filenames and `secrets.nix` declarations aligned with callsites in `hosts/` and `homes/`.
- Treat changes here as security-sensitive and verify every affected consumer path.

## Work Guidance

- Prefer changing references and declarations before touching encrypted payloads.
- If adding a secret, add only the encrypted `*.age` payload and matching `secrets.nix` entry; do not add plaintext examples with real values.

## Verification

- For `secrets.nix` changes, run the relevant Nix parse/evaluation check for the consumer configuration when available.

## Child DOX Index

No child DOX files.
