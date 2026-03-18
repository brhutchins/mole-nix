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
              rev = "main";
              hash = "sha256-r7v/3BB4f+BH+1wwF2GPYiVKHKmIGFWP6JJB0n4ROV4=";
            };

            proxyVendor = true;
            deleteVendor = true;
            vendorHash = "sha256-8jpELwcEVdo2gV9KbJz5KttluSRN+hYQeo+ZZ4gFkTk=";

            subPackages = [ "cmd/analyze" "cmd/status" ]; 

            postInstall = ''
              mkdir -p $out/bin $out/lib
              cp $src/mole $out/bin/mole
              chmod +x $out/bin/mole
              cp -r $src/lib/* $out/lib/
              sed -i "s|SCRIPT_DIR=.*|SCRIPT_DIR=\"$out\"|" $out/bin/mole
              ln -s $out/bin/analyze $out/lib/analyze.sh
              ln -s $out/bin/status $out/lib/status.sh

              ln -s $out/bin/analyze $out/lib/analyze.sh
              ln -s $out/bin/status $out/lib/status.sh

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
          program = "${self.packages.${system}.default}/bin/mole";
        };
      });
    };
}
