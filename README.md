# Mole-Nix 🐾
> [!NOTE]
> Yes I know there is a Mole Homebrew package that can be used with Nix-Darwin. I have moved completly away from Homebrew

A **Nix Flake** for [Mole](https://github.com/tw93/Mole), the high-performance system maintenance and "deep clean" tool for macOS.

This flake packages the hybrid Bash/Go architecture of Mole, ensuring all dependencies (like the `analyze` and `status` Go binaries) are compiled correctly and patched to work within the read-only Nix store.

## ✨ Features

* **Reproducible Build**: Compiles Go sub-packages (`cmd/analyze`, `cmd/status`) automatically.
* **Path Patching**: Uses `sed` to redirect internal script calls to the immutable Nix store.
* **Compatibility**: Works on both **Intel** (`x86_64-darwin`) and **Apple Silicon** (`aarch64-darwin`).
* **Instant Run**: No installation required via `nix run`.

## 🚀 Quick Start (Try without installing)

You can run the Mole TUI immediately without adding it to your system configuration:

```bash
nix run github:mikewebbtech/mole-nix --refresh --no-write-lock-file -- --help
```
Note: Use sudo if you plan to run system-level optimizations or TouchID configurations.

🛠️ Permanent Installation
1. Add to your Flake Inputs
In your system flake.nix (e.g., your nix-darwin or home-manager config):

```Nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  # Add Mole-Nix here
  mole-nix.url = "github:mikewebbtech/mole-nix";
};
```

2. Add to System Packages
Inject the package into your environment:

```Nix
outputs = { self, nixpkgs, mole-nix, ... }: {
  darwinConfigurations."Your-Hostname" = nixpkgs.lib.darwinSystem {
    modules = [
      {
        environment.systemPackages = [
          mole-nix.packages.\${system}.default
        ];
        
        # Recommended: Add an alias for the 'mo' command
        environment.shellAliases = {
          mo = "sudo mole";
        };
      }
    ];
  };
};
```

3. Apply Changes
```Bash
darwin-rebuild switch --flake .
```
### 🏗️ Technical Details
Mole is a unique "hybrid" application. This flake handles the following complexities:
* Go Vendoring: Uses proxyVendor = true to handle out-of-sync upstream dependencies.
* Naming Conventions: Creates forced symbolic links (e.g., analyze.sh -> analyze) so the main Bash wrapper can find the compiled Go binaries.
* Environment Isolation: Patches the SCRIPT_DIR variable within the mole script to point to the specific $out path in the Nix store.

## 🤝 Credits
Original Tool: tw93/Mole (give this project some stars. It is awesome 🤩)
Packaging: mikewebbtech (This is my first package flack, feedback welcome)
