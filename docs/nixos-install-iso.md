# NixOS 共通インストーラー ISO からの手動インストール

この手順は、x86_64 PC 用の **共通 live ISO** で起動し、対象 PC とホストを確認してから手動でインストールするためのものです。ISO は `minf` / `x360` / `tp` / `usb` のどれかを自動選択したり、ディスクを自動消去したりしません。以下の `/dev/...` は例なので、実際のデバイス名に置き換えてください。

## 1. ISO を作る（x86_64 Linux）

ビルドするマシンは、x86_64 Linux、Nix（flakes と `nix-command` が有効）、十分なディスク容量、インターネット接続が必要です。macOS/ARM でそのままビルドできるとは仮定しません。リポジトリの作業ツリーで:
Raspberry Pi はこの ISO の対象外です。既存の `make result-spi`（SD image）を使います。既存 OS に Nix + Home Manager だけを追加する用途にも、このディスク全消去手順は使いません。

```sh
make installer-iso
```

生成物は `result-installer/iso/*.iso` です。ISO のビルドは Cachix へ自動 upload しません。ISO を USB に書き込む前に、ファイル名と対象 USB の容量・モデル・シリアルを確認します。

```sh
ls -l result-installer/iso/
lsblk -o NAME,PATH,SIZE,MODEL,SERIAL,TYPE,MOUNTPOINTS
```

USB のデバイス（例 `/dev/sdX`）を**モデルとシリアルで二重確認**してから、USB 上の全データが消えることを了承できる場合だけ書き込みます。`/dev/sdX1` ではなくディスク本体を指定します。

```sh
sudo dd if=result-installer/iso/<生成されたファイル名>.iso of=/dev/sdX bs=4M status=progress conv=fsync
sync
```

上の `<生成されたファイル名>` と `/dev/sdX` はプレースホルダーです。ここでは実行しません。書き込み後、USB を安全に取り外し、対象 PC の起動メニューで USB から起動します。

## 2. ISO 起動後の準備

対象 PC の機種、起動方式、消去対象ディスクを確認します。live 環境でネットワークを使うため、Wi-Fi は次で接続します（有線 DHCP が使える場合はそれを優先）。

以降は `sudo -i` で root shell に入って作業します（コマンド例の `sudo` は root shell でも使用できます）。

```sh
nmtui
ping -c 3 github.com
```

インストール先を、モデル・シリアル・容量・現在のマウントポイントまで確認します。**USB（ISO 起動元）をインストール先に選ばないでください。**

```sh
lsblk -o NAME,PATH,SIZE,MODEL,SERIAL,TYPE,FSTYPE,MOUNTPOINTS
```


ホスト名とディレクトリの対応は次のとおりです。

| 対象 | flake 属性 | hardware ファイル |
| --- | --- | --- |
| minf | `minf` | `hosts/minf/hardware-configuration.nix` |
| x360 | `x360` | `hosts/x360/hardware-configuration.nix` |
| ThinkPad (`tp`) | `tp` | `hosts/t440p/hardware-configuration.nix` |
| portable USB (`usb`) | `usb` | `hosts/usb/hardware-configuration.nix` |

対象に合わせて変数を設定します。以下は `minf` の例です。`tp` は `HOST=tp`、`HOST_DIR=t440p`、他は表の対応を使います。

```sh
HOST=minf
HOST_DIR=minf
```

## 3. ディスクを手動で作成・マウント

次の作業は指定したディスクを全消去します。`lsblk` の結果と、筐体に表示されるディスクのモデル・シリアルを照合し、対象が一致しない場合は停止してください。既存 OS を残すディスクにはこの手順を使わず、バックアップも先に取得します。

### UEFI: `minf` / `x360` / `usb`

例として GPT、1 GiB ESP、残りを ext4 root にします。`/dev/nvme0n1` は実際の内蔵ディスクに変更し、NVMe のパーティション名は `p1` / `p2` になることに注意します。
`test -d /sys/firmware/efi` が成功する UEFI 起動であることも確認してください。以下の `p1` / `p2` は NVMe 専用の例なので、SATA/USB の場合はフォーマットを実行する前に `/dev/sda1` / `/dev/sda2` などへ置き換えます。

```sh
DISK=/dev/nvme0n1                 # モデル・シリアルを確認した実ディスク
sudo sgdisk --zap-all "$DISK"
sudo sgdisk -n 1:1MiB:+1GiB -t 1:EF00 "$DISK"
sudo sgdisk -n 2:0:0 -t 2:8300 "$DISK"
sudo partprobe "$DISK"

ESP=${DISK}p1
ROOT=${DISK}p2
sudo mkfs.fat -F 32 -n EFI "$ESP"
sudo mkfs.ext4 -L nixos-root "$ROOT"
sudo mount "$ROOT" /mnt
sudo mkdir -p /mnt/boot
sudo mount "$ESP" /mnt/boot
```

SATA の `/dev/sda` などでは `ESP=/dev/sda1`、`ROOT=/dev/sda2` としてください。既存の swap を残さない最小構成です。swap が必要なら、実 RAM と用途を確認して別途作成し、生成された `swapDevices` を採用します。

### BIOS/legacy: `tp`（ThinkPad T440p）

`tp` は `hosts/t440p/default.nix` で GRUB と `/dev/sda` を指定しており、他のホストの systemd-boot/ESP 構成とは異なります。legacy BIOS で起動した `tp` には、GPT の BIOS Boot パーティションと root だけを作ります（ESP を `/boot` に mount しません）。対象ディスクが本当に `/dev/sda` であることをモデル・シリアルで確認し、違う場合は構成の `boot.loader.grub.device` も実ディスクに合わせて変更します。

```sh
DISK=/dev/sda                    # 必ずモデル・シリアルを照合
sudo sgdisk --zap-all "$DISK"
sudo sgdisk -n 1:1MiB:+2MiB -t 1:EF02 "$DISK"   # BIOS Boot
sudo sgdisk -n 2:0:0 -t 2:8300 "$DISK"            # root
sudo partprobe "$DISK"
sudo mkfs.ext4 -L nixos-root /dev/sda2
sudo mount /dev/sda2 /mnt
```

UEFI で `tp` を使う場合はこの BIOS 手順を流用せず、GRUB の構成と boot パーティションを実機の起動方式に合わせて見直します。UEFI で systemd-boot の `minf` などを選ぶ場合も、ESP を `/mnt/boot` に mount する必要があります。

## 4. hardware 設定を flake に反映する

生成設定は、実際に import されるホストのファイルへ反映する必要があります。`/mnt/etc/nixos` に置くだけでは、このリポジトリの flake が参照する固定 UUID は変わりません。

**ディスクを `/mnt` にマウントした後で** checkout を作ります。マウント前に clone すると、live 環境側へ保存され、インストール先には残りません。

```sh
git clone https://github.com/tshm/dotfiles.git /mnt/home/tshm/.dotfiles
cd /mnt/home/tshm/.dotfiles
```

```sh
sudo nixos-generate-config --root /mnt
less /mnt/etc/nixos/hardware-configuration.nix
cd /mnt/home/tshm/.dotfiles
# 生成ファイルを確認し、既存のホスト固有設定を保ったうえで反映する
sudo cp /mnt/etc/nixos/hardware-configuration.nix hosts/$HOST_DIR/hardware-configuration.nix
nano hosts/$HOST_DIR/hardware-configuration.nix
```

`fileSystems` の UUID、swap、CPU/boot 関連を実機と照合してください。`tp` では前節の GRUB device も確認します。新しいホストディレクトリや新規ファイルを追加した場合、Nix flake は Git の未追跡ファイルを入力に含めないため、インストール前に必ず追加します。

```sh
git status --short
git add hosts/$HOST_DIR
```

必要なら安全な別ブランチで commit しておきます。作業中の hardware ファイルを commit したくない場合でも、`git add` 済みで `nixos-install` が入力として読める状態にしてください。

## 5. agenix の初期ファイルを配置する

現在の構成は、次の**絶対パス文字列**を実行時に使います（Nix path に変換しないでください）。初回 activation/起動前に、インストール先の root `/mnt` の中へ配置します。

- 暗号化済みパスワードハッシュ: `/mnt/home/tshm/.dotfiles/secrets/user-password-hash.age`
- 復号 identity: `/mnt/home/tshm/.ssh/id_ed25519`

秘密鍵、Wi-Fi パスワード、トークンを ISO や Nix store に埋め込んだり、公開リポジトリへ commit したりしません。暗号化ファイルと秘密鍵は、保護した別媒体・private checkout などから手動で供給します。

```sh
sudo install -d -m 700 /mnt/home/tshm/.ssh
sudo install -m 600 /安全な媒体/id_ed25519 /mnt/home/tshm/.ssh/id_ed25519
sudo install -m 600 /安全な媒体/user-password-hash.age \
  /mnt/home/tshm/.dotfiles/secrets/user-password-hash.age
```

インストール後、root shell で所有者・権限を確認し、必要なら直します。`tshm` がまだ live 環境で解決できない場合は、最初の起動後に実行します。

```sh
sudo chown -R tshm:users /home/tshm/.ssh /home/tshm/.dotfiles
sudo chmod 700 /home/tshm/.ssh
sudo chmod 600 /home/tshm/.ssh/id_ed25519 /home/tshm/.dotfiles/secrets/user-password-hash.age
```

### private flake を使う場合

組織・個人の private 設定は公開 dotfiles に混ぜません。private flake を `/mnt/home/tshm/.dotfiles-private` に clone し、Makefile と同じ「private flake を主 flake、公開 dotfiles を `dotfiles` input に override」する形で指定します。

```sh
git clone <private-flake-url> /mnt/home/tshm/.dotfiles-private
sudo nixos-install --flake /mnt/home/tshm/.dotfiles-private#$HOST \
  --override-input dotfiles path:/mnt/home/tshm/.dotfiles
```

private 設定が必要なホストで input/属性が一致しない場合は停止し、private flake の契約に合わせます。公開 flake へのフォールバックで private 設定を省略しません。private flake でインストールした場合、次節の公開 flake コマンドを重ねて実行しないでください。

## 6. NixOS をインストール

mount、hardware、秘密ファイル、Git 追跡状態を再確認してから、対象属性を明示します。`nixos-install` はディスクを選んで消去するツールではなく、消去と mount は前節で手動に行ったものだけです。

```sh
sudo nixos-install --flake /mnt/home/tshm/.dotfiles#$HOST
```

インストール完了後は checkout 内から `cd /` で移動してから `/mnt` を unmount し、再起動後の起動メニューで USB ではなくインストール先ディスクを選びます。インストール時に設定した root パスワードを初回の復旧・所有者調整用に確保します。

```sh
cd /
sudo umount -R /mnt
sudo reboot
```

## 7. 初回起動と Home Manager

実ディスクから起動します。まずテキストコンソール（GUI が起動した場合は Ctrl+Alt+F2 など）で、インストール時に設定したパスワードを使って root にログインし、`chown -R tshm:users /home/tshm` と前節の権限確認を行います。その後 `tshm` のログイン、ネットワーク、対象ホストの systemd-boot または GRUB、agenix によるパスワード利用を確認します。agenix は root で復号するため、初回起動前の秘密鍵が root 所有でも復号できます。

Home Manager は OS のホスト属性とは別に、対応する `homeConfigurations` の属性を指定します。対象ユーザー `tshm` の shell で、flake に固定された Home Manager input を使います。再起動すると前の `$HOST` は引き継がれないため、改めて指定します。

```sh
cd ~/.dotfiles
HOST=minf  # 実際のホスト名。tp の場合は tp
nix run --inputs-from . home-manager -- switch --flake ".#tshm@$HOST"
```

既存の `make home-manager` も利用できますが、`nh` や現在の環境の設定に依存するため、初回は上の明示的な属性指定を使います。この Makefile の Home Manager ターゲットは OS ターゲットと違って private flake を自動選択しません。private 側の Home Manager output を使う場合は、その flake と実在する属性を明示してください。

## 制約と確認範囲

このガイドは完全オフライン導入を想定しません。ISO 起動後の Git、flake input、NixOS closure、private input の取得にネットワークが必要です。

2026-10-28 の確認:

- `make installer-iso` が成功し、`result-installer/iso/` に ISO（1,519,271,936 bytes）を生成。
- QEMU に生成 ISO を接続し、対応する kernel/initrd を直接指定して live 環境を起動。ISO の squashfs からの起動、Git、`nixos-install`、`nmtui`、flakes / nix-command の有効化を確認。
- 手順に記載した `nix run --inputs-from . home-manager -- --version` は `26.11-pre` を出力。

kernel 直接起動のため ISO の UEFI/BIOS ブートローダー経由は未確認です。USB 書き込み、実ディスクへの導入、各 PC の hardware UUID、再起動後ログイン、Home Manager の switch も未実施です。対象 PC ごとに確認し、失敗した場合は disk を再消去せず原因を切り分けます。

## Btrfs 移行用 USB（手動開始）

通常の新規インストールとは別に、`make migration-iso` で `result-migration/iso/*.iso` を作れます。USB 起動だけではバックアップ・フォーマットを開始しません。設定なしの ISO は対象ディスクを持たず、安全に停止します。

専用 ISO は `nixosConfigurations.migration-installer.extendModules` に `services.btrfsMigration.config` を渡して作ります。実機の識別情報・共有名は公開リポジトリ外で管理し、SMB パスワードと restic パスワードは ISO・Nix store・設定 JSON に保存しません。private 構成を含むイメージや OS closure は公開キャッシュに upload しません。

設定に必要な値:

| フィールド | 内容 |
| --- | --- |
| `disk`, `serial`, `disk_size` | `/dev/disk/by-id/` のディスクパス、シリアル、バイト単位の容量 |
| `source_uuid`, `source_size` | 既存 ext4 root の UUID とパーティション容量 |
| `server`, `share`, `username`, `domain`, `repository` | SMB サーバ IP、UNC 共有名、アカウント、ドメイン、専用保存ディレクトリ名 |
| `system` | private 設定も含む、移行後の起動構成を事前ビルドした NixOS closure |
| `hardware_file`, `hardware_sha256`, `hardware_replacement` | root 相対の hardware ファイルパス、元ファイルの SHA-256、置換内容を持つ store ファイル |

`system` と `hardware_replacement` は ISO に同梱されます。JSON から読み込んだ store パスには Nix の参照 context がないため、専用ビルド式で `builtins.storePath` を使って復元します（`--impure` が必要）。移行後の root は `/dev/disk/by-label/nixos-root`、Btrfs、`compress=zstd:3` とし、GRUB の対象も実機の安定したディスクパスに合わせます。元の稼働 OS にこの設定を activation してはいけません。

### 後日、移行を開始する場合

**以下のコマンドは実データのバックアップを開始します。USB の起動確認だけが目的なら実行しません。**

1. 有線 LAN を接続し、USB を Legacy BIOS モードで起動します。
2. `sudo migrate-btrfs` を実行し、SMB パスワードとバックアップ用パスワードを入力します。新しいバックアップ用パスワードは再入力し、別媒体にも安全に記録します。
3. SSD のオフライン検査・読み取り専用マウント・暗号化バックアップ・全データ検査・hardware ファイルの試験復元を待ちます。バックアップは共有内の専用ディレクトリの `repo/`、再開情報は `state.json` に保存されます。
4. 表示された対象を照合し、消去してよい場合だけ `ERASE <シリアル>` を入力します。既存パーティションを Btrfs に作り直し、検証付き復元、hardware ファイル更新、事前ビルド済み OS と GRUB の導入を行います。
5. `COMPLETE` を確認後、USB を外して手動で再起動します。バックアップは起動・ログイン・サービス・データを確認するまで保持します。

MBR と root 1 パーティションの構成だけが対象です。USB/リムーバブルディスク、マウント中の SSD、識別情報の不一致、他ディスクとの root ラベル重複は拒否します。パーティションテーブルは作り直しません。SMB は暗号化接続（`seal`）、バックアップは restic の暗号化形式なので、SMB 側で Linux の所有者・権限を直接表現できる必要はありません。サーバ空き容量は SSD 使用量の 110% 以上を要求し、書き込み・読み戻しも消去前に確認します。

フォーマット後に中断した場合は、原因を確認してから `sudo migrate-btrfs --resume` を使います。保存したバックアップと Btrfs UUID が一致する場合だけ、`RESTORE <シリアル>` の確認後に復元を再実行し、再フォーマットはしません。完了済みの移行は再開できません。ロック・検査エラーを無視したり、`state.json` を手動で書き換えたりしないでください。

### 仮想ディスクでの検証

ホストの実ディスクを渡さず、独立した Samba サーバと空の仮想ディスクで検証します。

```sh
nix build --impure --expr 'let f = builtins.getFlake ("path:" + toString ./.); in import ./scripts/test-migrate-btrfs.nix { pkgs = f.nixosConfigurations.installer.pkgs; }' --no-link -L
```

仮想ディスクでは、暗号化 SMB バックアップ・全データ検査・Btrfs 復元・OS/GRUB 導入・復元ディスクからの BIOS 起動まで確認しました。ファイル内容、所有者・権限、ハードリンク、シンボリックリンク、拡張属性、実際の zstd 圧縮も検証しています。中断後の状態を再現した `--resume` では、データの修復と、ファイルシステム UUID・追加ファイルの保持（再フォーマットしないこと）を確認しました。

専用 ISO を USB に書き込み、イメージ全体の読み戻し SHA-256 が一致することを確認しました。書き込み済み USB を読み取り専用で QEMU の BIOS から起動し、自動バックアップがなくログイン待機することと、対象 SSD 不在時の停止も確認しました。実機 BIOS での起動確認や本番バックアップとは別の検証です。

## 公式資料

- [NixOS Wiki — Creating a NixOS live CD](https://wiki.nixos.org/wiki/Creating_a_NixOS_live_CD)
- [NixOS Manual — Installation](https://nixos.org/manual/nixos/stable/#ch-installation)
- [nixpkgs — minimal installer](https://github.com/NixOS/nixpkgs/blob/3ec636362e1816bc2f0888fa0fa2c69f1bc9e504/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix)
- [nixpkgs — ISO builder](https://github.com/NixOS/nixpkgs/blob/3ec636362e1816bc2f0888fa0fa2c69f1bc9e504/nixos/modules/installer/cd-dvd/iso-image.nix)
- [nixpkgs — installation device profile](https://github.com/NixOS/nixpkgs/blob/3ec636362e1816bc2f0888fa0fa2c69f1bc9e504/nixos/modules/profiles/installation-device.nix)
- [Home Manager — Flakes](https://nix-community.github.io/home-manager/nix-flakes.html)
- [NixOS Download](https://nixos.org/download/)
- [disko upstream — disko-install](https://github.com/nix-community/disko/blob/master/docs/disko-install.md)（この手順では使用しない）
- [nixos-anywhere upstream — Quickstart](https://github.com/nix-community/nixos-anywhere/blob/main/docs/quickstart.md)（この手順では使用しない）
- [nixpkgs — aarch64 SD image](https://github.com/NixOS/nixpkgs/blob/3ec636362e1816bc2f0888fa0fa2c69f1bc9e504/nixos/modules/installer/sd-card/sd-image-aarch64.nix)
