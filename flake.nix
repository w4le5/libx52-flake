{
  description = "libx52 — Library and daemon for Saitek X52/X52Pro/X55 flight sticks";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        libx52 = pkgs.stdenv.mkDerivation rec {
          pname = "libx52";
          version = "unstable-2025-12-05";

          src = pkgs.fetchFromGitHub {
            owner = "nirenjan";
            repo = "libx52";
            rev = "master";
            sha256 = "sha256-xVOwNinQZ3CLIRoeiIZ90gn/mVsUskCEam72UfMTkjQ=";
          };

          nativeBuildInputs = with pkgs; [
            autoconf automake gettext libtool pkg-config
          ];

          buildInputs = with pkgs; [
            hidapi libusb1 libevdev python3
          ];

          preConfigure = "./autogen.sh";

          configureFlags = [
            "--localstatedir=${placeholder "out"}/var"
            "--sysconfdir=${placeholder "out"}/etc"
            "--with-input-group=input"
            "--disable-systemd"
          ];

          # Патчим Makefile до сборки, чтобы убрать установку udev-прав в системные каталоги
          preBuild = ''
            sed -i '/install-udevrulesDATA/d' Makefile
          '';

          installPhase = ''
            make install
            mkdir -p $out/var/run
            mkdir -p $out/var/log
          '';

          postInstall = ''
            mkdir -p $out/etc/udev/rules.d
            cp libx52/*.rules $out/etc/udev/rules.d/ 2>/dev/null || true
          '';

          postPatch = ''
            sed -i 's|/var/run|$TMPDIR/x52d/run|g' libx52d/x52d.c
            sed -i 's|/var/log|$TMPDIR/x52d/log|g' libx52d/x52d.c
          '';

          meta = with pkgs.lib; {
            description = "C library and daemon for X52/X52Pro/X55 HID devices";
            homepage = "https://github.com/nirenjan/libx52";
            license = licenses.mit;
            platforms = platforms.linux;
          };
        };
      in {
        packages.libx52 = libx52;
        packages.default = libx52;

        overlay = final: prev: {
          libx52 = libx52;
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            autoconf automake gettext libtool pkg-config
            hidapi hidapi.dev libusb1 libusb1.dev libevdev libevdev.dev
            python3 git
          ];
        };
      });
}
