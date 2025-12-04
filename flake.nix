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
            sha256 = "REPLACE_ME";
          };

          nativeBuildInputs = with pkgs; [
            autoconf automake autopoint gettext libtool pkg-config
          ];

          buildInputs = with pkgs; [
            hidapi libusb1 libevdev python3
          ];

          preConfigure = "./autogen.sh";

          # соответствуют INSTALL.md, но адаптированы под Nix
          configureFlags = [
            "--localstatedir=${placeholder "out"}/var"
            "--sysconfdir=${placeholder "out"}/etc"
            "--with-input-group=input"
            # udev/systemd dirs устанавливаются автоматически в Nix
          ];

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
            autoconf automake autopoint gettext libtool pkg-config
            hidapi hidapi.dev libusb1 libusb1.dev libevdev libevdev.dev
            python3 git
          ];
        };
      });
}
