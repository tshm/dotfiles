#!/bin/sh
sudo apt-get update && sudo apt-get dist-upgrade
sudo apt-get install build-essential

nix-env -i tig

# k8s
nix-env -i kubectl kustomize k9s docker

