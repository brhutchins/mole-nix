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

        apps = forAllSystems (system: {
          default = {
              type = "app";
              progarm = "${self.packages.${system}.default}/bin/mole";
            };
        }); 

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

            # 1. Point to the actual Go code subdirectories
            subPackages = [ "cmd/analyze" "cmd/status" ]; 

            # 2. Fix directory issue and install the wrapper script
            postInstall = ''
              # 1. Create the necessary structure in the Nix output
              mkdir -p $out/bin $out/lib
                
              # 2. Copy the main script
              cp $src/mole $out/bin/mole
              chmod +x $out/bin/mole
                
              # 3. Copy the libraries
              cp -r $src/lib/* $out/lib/

              # 4. THE FIX: Patch the script to find its libs in the Nix Store
              # Most scripts use a variable like SCRIPT_DIR. We force it to $out.
              sed -i "s|SCRIPT_DIR=.*|SCRIPT_DIR=\"$out\"|" $out/bin/mole
                
              # Also ensure the sub-binaries are in the right spot for the script
              ln -s $out/bin/analyze $out/lib/analyze
              ln -s $out/bin/status $out/lib/status
            '';

            meta = with nixpkgs.lib; {
              description = "High-performance system maintenance tool for macOS";
              homepage = "https://github.com/tw93/Mole";
              platforms = platforms.darwin;
            };
          };
        });
    };
}
