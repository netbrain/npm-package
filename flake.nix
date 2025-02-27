{
  description = "Simple utility for integrating NPM packages into NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      # Define supported systems
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      # Helper function to generate attributes for all supported systems
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Get the npm-utils for each system
      npmUtilsFor = forAllSystems (system: import ./lib/npm-utils.nix {
        pkgs = nixpkgs.legacyPackages.${system};
      });
    in
    {
      # Expose the library functions
      lib = forAllSystems (system: {
        npmPackage = npmUtilsFor.${system}.npmPackage;
      });

      
      devShells = forAllSystems (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            gh
          ];
        };
      });
  };
}
