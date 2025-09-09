# initial setup
ISNIXOS:=$(shell grep ID=nixos /etc/os-release)
NIX:=$(shell which nix)
ISWSL:=$(shell uname -a | grep WSL)

HAS_CACHIX:=$(shell which cachix)
ifdef HAS_CACHIX
CACHIX:=cachix watch-exec tshmcache --
else
CACHIX:=
endif

HAS_NH:=$(shell which nh)
home-manager: nix
ifdef HAS_NH
	${CACHIX} nh home switch
else
	${CACHIX} nix run home-manager/master -- switch --flake .
endif

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

.PHONY: zi up
up: update apphash_update
zi:; zsh -i -c 'zinit update'

ifdef NIX
nix:; @echo nix exists
else
nix:
	@echo no nix
	curl --proto '=https' --tlsv1.2 -sSf \
		-L https://install.determinate.systems/nix | sh -s -- install

nix-upgrade:
	sudo determinate-nixd upgrade
endif

ifdef ISNIXOS
all: sudo home-manager os
else
all: home-manager
endif

sudo:; sudo echo sudo

os: sudo
ifdef HAS_NH
	${CACHIX} nh os switch
else
	${CACHIX} sudo nixos-rebuild switch --flake .
endif

clean:
	which nh && nh clean all
	nix-collect-garbage -d
	nix-store --optimize

update:
	nix flake update
	# cd ./homes/modules/node2nix; make

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
	wget https://github.com/jtroo/kanata/releases/download/$V/kanata_winIOv2.exe -O $@
	# shell:common startup
	# powershell.exe "[Environment]::GetFolderPath('Startup')"
endif

.git/hooks/pre-commit: flake.lock
	pre-commit autoupdate
	pre-commit install -f

PHONY: all yazi home-manager nix update katana sudo x
