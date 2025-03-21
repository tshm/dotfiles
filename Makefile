# initial setup
ISNIXOS:=$(shell grep ID=nixos /etc/os-release)
NIX:=$(shell which nix)
ISWSL:=$(shell uname -a | grep WSL)

HAS_CASHIX:=$(shell which cachix)
ifdef HAS_CACHIX
CACHIX:=cachix watch-exec tshmcache --
else
CACHIX:=
endif

home-manager: nix
	which nh && ${CACHIX} nh home switch || \
	${CACHIX} nix run home-manager/master -- switch --flake .
	ya pack -u

APPSRC := $(shell find ./homes/apps/ -name '*.nix')
APPS := $(patsubst ./homes/apps/%.nix, update.%, $(APPSRC))

apphash_update: $(APPS)

update.%: ./homes/apps/%.nix
	$(eval URL := $(shell sed -ne '/url =/s/.*url = //p' "$<"))
	echo updating $% from ${URL}
	$(eval HASH := $(shell nix-prefetch-url --type sha256 ${URL}))
	$(eval SRI := $(shell nix hash convert --hash-algo sha256 --to sri ${HASH}))
	echo ${SRI}
	sed -i "s|sha256 = \".*\";|sha256 = \"${SRI}\";|" "$<"
	echo "Hash updated in $<: ${SRI}"

ifdef NIX
nix:; @echo nix exists
else
nix:
	@echo no nix
	curl --proto '=https' --tlsv1.2 -sSf \
		-L https://install.determinate.systems/nix | sh -s -- install
endif

ifdef ISNIXOS
all: sudo home-manager os
else
all: home-manager
endif

sudo:; sudo echo sudo

os: sudo
	which nh && ${CACHIX} nh os switch || \
	${CACHIX} sudo nixos-rebuild switch --flake .

update:
	nix flake update

yazi: ~/.config/yazi/plugins/hide-preview.yazi/ ~/.config/yazi/plugins/git.yazi
~/.config/yazi/plugins/hide-preview.yazi:
	ya pack -a yazi-rs/plugins:hide-preview

~/.config/yazi/plugins/git.yazi:
	ya pack -a yazi-rs/plugins:git

nvim: ~/.local/bin/nvim ~/.config/nvim
~/.local/bin/nvim:
	mkdir -p ~/.local/bin/
	curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
	chmod u+x nvim.appimage
	mv nvim.appimage ~/.local/bin/nvim

resh:
	curl -fsSL https://raw.githubusercontent.com/curusarn/resh/master/scripts/rawinstall.sh | bash

ifdef ISWSL
REPO:=jtroo/kanata
kanata: kanata/kanata_gui.exe
kanata/kanata_gui.exe:
	$(eval V:=$(shell curl 'https://api.github.com/repos/${REPO}/releases/latest' | jq -r .tag_name))
	echo $V
	mkdir -p tmp
	wget https://github.com/jtroo/kanata/releases/download/$V/kanata_gui.exe -O $@
	# shell:common startup
	# powershell.exe "[Environment]::GetFolderPath('Startup')"
endif

.git/hooks/pre-commit: flake.lock
	pre-commit autoupdate
	pre-commit install -f

PHONY: all yazi home-manager nix update katana sudo x
