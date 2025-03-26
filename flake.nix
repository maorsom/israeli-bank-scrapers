{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = (import (inputs.nixpkgs) { inherit system; });
        chromiumRevision = "1250580";

        chromiumSnapshot = pkgs.stdenv.mkDerivation {
          pname = "chromium-snapshot";
          version = chromiumRevision;
          src = pkgs.fetchzip {
            url = "https://storage.googleapis.com/chromium-browser-snapshots/Linux_x64/${chromiumRevision}/chrome-linux.zip";
            sha256 = "0fd3sqnx7z7vpmrmlxwid7qhdrpxhajcxv32hiqxk4v2wx1sbnxj";
          };  

          dontBuild = true;

          installPhase = ''
            mkdir -p $out/bin
            cp -r $src/* $out/
            chmod +x $out/chrome
            ln -s $out/chrome $out/bin/chromium
          '';
        };

        fhsChromium = pkgs.buildFHSEnv {
          name = "chromium-fhs";
          targetPkgs = pkgs: [
            pkgs.alsa-lib
            pkgs.glibc
            pkgs.expat
            pkgs.udev
            pkgs.libxkbcommon
            pkgs.atk
            pkgs.gtk3
            pkgs.libgbm
            pkgs.nss
            pkgs.nspr
            pkgs.cups
            pkgs.glib
            pkgs.gobject-introspection
            pkgs.xorg.libX11
            pkgs.xorg.libxcb
            pkgs.xorg.libXcomposite
            pkgs.xorg.libXcursor
            pkgs.xorg.libXdamage
            pkgs.xorg.libXext
            pkgs.xorg.libXfixes
            pkgs.xorg.libXi
            pkgs.xorg.libXrandr
            pkgs.xorg.libXrender
            pkgs.xorg.libXtst
            pkgs.xorg.libXScrnSaver
            pkgs.pango
            pkgs.cairo
            pkgs.libdrm
            pkgs.xorg.libxshmfence
            pkgs.dbus
            pkgs.fontconfig
            pkgs.freetype
            pkgs.gdk-pixbuf
            pkgs.icu

            pkgs.libpulseaudio
            pkgs.zlib
            pkgs.libGL
          ];
          runScript = "${chromiumSnapshot}/chrome";

        };
      in {
      
        packages.default = chromiumSnapshot;
        
        devShell = pkgs.mkShell {

          buildInputs=[
            pkgs.nodePackages.nodejs
            pkgs.nodePackages.npm
            pkgs.nodePackages.typescript
            fhsChromium
          ];

          shellHook = ''
            export CHROMIUM_BIN="${fhsChromium}/bin/chromium-fhs"
          '';
        };
      }
    );
}
