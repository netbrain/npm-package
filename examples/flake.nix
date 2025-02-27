{
  description = "Example usage of npm-package";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Reference the GitHub repository
    #npm-package.url = "github:netbrain/npm-package";
    npm-package.url = "path:..";
  };

  outputs = { self, nixpkgs, npm-package, ... }: 
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      # Example NixOS configuration
      nixosConfigurations.example = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          # Direct module usage example
          ({ pkgs, ... }: {
            # Add Claude CLI to system packages using the npmPackage function
            environment.systemPackages = [
              (npm-package.lib.${pkgs.system}.npmPackage {
                name = "claude";
                packageName = "@anthropic-ai/claude-code";
              })
            ];
          })
        ];
      };
      
      # Standalone packages example
      packages = {
        # Create a package for the Claude CLI
        claude-cli = npm-package.lib.${system}.npmPackage {
          name = "claude";
          packageName = "@anthropic-ai/claude-code";
        };
        
        # Create a package for another npm tool as an example
        prettier = npm-package.lib.${system}.npmPackage {
          name = "prettier";
          version = "3.5.2";
        };
      };
      
      # Development shell with the packages
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          self.packages.claude-cli
          self.packages.prettier
        ];
      };
    };
}
