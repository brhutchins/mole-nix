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
            deleteVendor = true;

            subPackages = [ "cmd/analyze" "cmd/status" ]; 

            postInstall = ''
              mkdir -p $out/bin $out/lib
              
              # 1. Copy main script and libraries
              cp $src/mole $out/bin/mo
              chmod +x $out/bin/mo
              cp -r $src/lib/* $out/lib/

              # 2. Patch the script path
              
              # 3. FORCE symlinks to replace existing script files
              # Use -sf to overwrite any existing analyze.sh/status.sh
              ln -sf $out/bin/analyze $out/bin/analyze.sh
              ln -sf $out/bin/status $out/bin/status.sh
              
              ln -sf $out/bin/analyze $out/lib/analyze.sh
              ln -sf $out/bin/status $out/lib/status.sh        
              sed -i "s|SCRIPT_DIR=.*|SCRIPT_DIR=\"$out\"|" $out/bin/mo
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
