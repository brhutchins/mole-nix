{
  description = "Mole - High-performance system maintenance tool for macOS";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.buildGoModule {
            pname = "mole";
            version = "latest";

            src = pkgs.fetchFromGitHub {
              owner = "tw93";
              repo = "Mole";
              rev = "bcccefd525b4b9286b346ef6bdadb4a4f7c16ac0";
              hash = "sha256-C+mw9mV9vaa+7Dr+ujJtEBUEn/vNcxr6KbsQ+xcSlOI=";
            };

            proxyVendor = true;
            vendorHash = "sha256-8+1FDxumlBFzBz/b1KVbotQq+twm/MRlJSJ9AZCgASE=";

            subPackages = [ "cmd/analyze" "cmd/status" ];

            postInstall = ''
              mkdir -p $out/bin $out/lib

              # 1. Copy main script and libraries
              cp $src/mole $out/bin/mo
              chmod +x $out/bin/mo
              cp -r $src/lib/* $out/lib/

              # Copy shell scripts
              cp -r $src/bin/* $out/bin/
              chmod +x $out/bin/*

              # Patch the script path
              sed -i "s|SCRIPT_DIR=.*|SCRIPT_DIR=\"$out\"|" $out/bin/mo

              # Patch hardcoded `/bin/bash` to standard `/usr/bin/env bash`
              sed -i "s|#!/bin/bash|#!/bin/bash|#!/usr/bin/env bash" $out/bin/*.sh

              # Link the built go binaries to the locations the provided shell scripts expect
              ln -sf $out/bin/analyze $out/bin/analyze-go
              ln -sf $out/bin/status $out/bin/status-go
            '';

            meta = with nixpkgs.lib; {
              description = "High-performance system maintenance tool for macOS";
              homepage = "https://github.com/tw93/Mole";
              platforms = platforms.darwin;
            };
          };
        }
      );

      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/mo";
        };
      });
    };
}
