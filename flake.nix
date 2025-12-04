libx52 = pkgs.stdenv.mkDerivation rec {
  pname = "libx52";
  version = "unstable-2025-12-05";

  src = pkgs.fetchFromGitHub {
    owner = "nirenjan";
    repo = "libx52";
    rev = "master";
    sha256 = "sha256-xVOwNinQZ3CLIRoeiIZ90gn/mVsUskCEam72UfMTkjQ=";
  };

  nativeBuildInputs = with pkgs; [ autoconf automake gettext libtool pkg-config ];
  buildInputs = with pkgs; [ hidapi libusb1 libevdev python3 ];

  preConfigure = "./autogen.sh";

  configureFlags = [
    "--localstatedir=${placeholder "out"}/var"
    "--sysconfdir=${placeholder "out"}/etc"
    "--with-input-group=input"
    "--disable-systemd"
  ];

  postInstall = ''
    sed -i '/install-udevrulesDATA/d' Makefile
    mkdir -p $out/etc/udev/rules.d
    cp libx52/*.rules $out/etc/udev/rules.d/ 2>/dev/null || true
  '';

  meta = with pkgs.lib; {
    description = "C library and daemon for X52/X52Pro/X55 HID devices";
    homepage = "https://github.com/nirenjan/libx52";
    license = licenses.mit;
    platforms = platforms.linux;
  };
};
