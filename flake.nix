nixpkgs.overlays = [
  (final: prev: {
    libx52 = prev.stdenv.mkDerivation rec {
      pname = "libx52";
      version = "unstable-2025-12-05";

      src = prev.fetchFromGitHub {
        owner = "nirenjan";
        repo = "libx52";
        rev = "master";
        sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # замените после первого запуска
      };

      nativeBuildInputs = with prev; [
        autoconf automake autopoint gettext libtool pkg-config
      ];

      buildInputs = with prev; [
        hidapi libusb1 libevdev python3
      ];

      preConfigure = "./autogen.sh";

      configureFlags = [
        "--prefix=$(out)"
        "--localstatedir=/var"
        "--sysconfdir=/etc"
        "--with-input-group=input"
      ];

      meta = with prev.lib; {
        description = "C library and daemon for Saitek X52/X52Pro/X55";
        homepage = "https://github.com/nirenjan/libx52";
        license = licenses.mit;
        platforms = [ "x86_64-linux" ];
      };
    };

    edl = (import stable { system = final.system; config.allowUnfree = true; }).edl;
    bitchx = self.packages.${final.system}.bitchx;
  })
];
