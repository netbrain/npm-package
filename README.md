# npm-package

A minimal utility for using NPM packages in NixOS flakes without installation hassles.

## Problem

Installing and using NPM packages in NixOS can be challenging due to:
- The immutable nature of the Nix store
- Friction between NPM's imperative package management and Nix's declarative approach
- Complexity in making NPM packages available in your PATH

## Solution

This repository provides a simple, lightweight function (`npmPackage`) that:
- Creates a wrapper script that uses `npx` to run NPM packages on demand
- Requires no global installation or build-time package fetching
- Works perfectly in flake-based setups with Nix's sandbox restrictions

## Usage

### In a flake.nix

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    npm-package.url = "github:netbrain/npm-package";
  };

  outputs = { self, nixpkgs, npm-package, ... }: {
    nixosConfigurations.yourSystem = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ pkgs, ... }: {
          environment.systemPackages = [
            # Add the Claude CLI wrapper
            (npm-package.lib.${pkgs.system}.npmPackage {
              name = "claude";
              packageName = "@anthropic-ai/claude-code";
            })
          ];
        })
      ];
    };
  };
}
```

### Development Shell

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    npm-package.url = "github:netbrain/npm-package";
  };

  outputs = { self, nixpkgs, npm-package, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          # Add nodejs to the shell
          pkgs.nodejs
          
          # Add the Claude CLI wrapper
          (npm-package.lib.${system}.npmPackage {
            name = "claude";
            packageName = "@anthropic-ai/claude-code";
          })
        ];
      };
    };
}
```

## How It Works

This utility creates a simple wrapper script that leverages `npx` to run NPM packages on demand. This approach:

1. Requires no build-time package fetching
2. Works perfectly with Nix's sandbox restrictions 
3. Uses `npx`'s cache for better performance after first run
4. Always uses the specified version

## API Reference

### npmPackage

```nix
npmPackage {
  name,                   # The name of the command to create (required)
  packageName ? name,     # The npm package name (defaults to name)
  version ? "latest",     # Package version to use (defaults to "latest")
  binName ? null          # Binary name if different from name (optional)
}
```

#### Parameters

- `name`: The name of the command that will be available in your PATH
- `packageName`: The full NPM package name, useful for scoped packages (e.g., "@anthropic-ai/claude-code")
- `version`: The NPM package version to use (e.g., "1.0.0", "latest")
- `binName`: (Optional) Override the binary name if different from the package name

## Examples

See the [examples](./examples) directory for complete working examples:
- Basic usage in a flake
- Dedicated example for Claude CLI in a devshell

## Advantages

- **Zero Build-Time Dependencies**: No network access needed during build
- **Always Up-to-Date**: Gets the latest package version when specified
- **Sandbox Compatible**: Works with NixOS's strict sandbox settings
- **Minimal**: Simple implementation with no complex logic
- **Flexible**: Works with any NPM package with minimal configuration

## License

MIT
