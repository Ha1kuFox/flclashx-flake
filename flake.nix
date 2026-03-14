{
  description = "FlClashX AppImage Nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pname = "FlClashX";
        version = "0.3.2";
        arch = if pkgs.stdenv.hostPlatform.isAarch64 then "arm64" else "amd64";
      in
      {
        packages.${pname} = pkgs.appimageTools.wrapType2 rec {
          inherit pname version;
          src = pkgs.fetchurl {
            url = "https://github.com/pluralplay/FlClashX/releases/download/v0.3.2/FlClashX-linux-${arch}.AppImage";
            hash = "sha256-RbL1M6WKsUoxt83kDmkjoWs2voIBzp9P4hbSn5MDBow=";
          };

          extraPkgs =
            pkgs: with pkgs; [
              gtk3
              glib
              libGL
              libglvnd
              libepoxy
              libX11
              libXcursor
              libXi
              libXrandr
              libXrender
              alsa-lib
              udev
              nspr
              nss
              cups
              fuse2
              at-spi2-atk
              wayland
            ];

          desktopItem = pkgs.makeDesktopItem {
            name = pname;
            exec = "${pname}";
            comment = "Multi-platform ClashMeta proxy client";
            desktopName = "FlClashX";
            genericName = "Proxy Client";
            categories = [
              "Network"
              "Utility"
              "System"
            ];
            mimeTypes = [ ];
            extraEntries = ''
              StartupWMClass=FlClashX
              Keywords=clash,proxy,vpn,tun,flclash
            '';
          };

          meta = with pkgs.lib; {
            description = "FlClashX proxy client (AppImage)";
            homepage = "https://github.com/pluralplay/FlClashX";
            license = licenses.gpl3;
            platforms = platforms.linux;
            mainProgram = "${pname}";
          };
        };

        packages.default = self.packages.${system}.${pname};

        apps.default = flake-utils.lib.mkApp {
          drv = self.packages.${system}.default;
          desktopItem = self.packages.${system}.default.desktopItem;
        };
      }
    );
}
