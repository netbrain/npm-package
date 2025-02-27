{ pkgs }:

{
  # Function to create an npx wrapper for any npm package
  npmPackage = { 
    name,                   # Name of the package
    packageName ? name,     # NPM package name (defaults to name)
    version ? "latest",     # Package version (defaults to "latest")
    binName ? null          # Binary name (defaults to name)
  }: 
    let
      # Use the provided binary name or fallback to package name
      actualBinName = if binName != null then binName else name;
    in
      # Create a simple wrapper script that uses npx
      pkgs.writeShellScriptBin actualBinName ''
        # Set npm log level to error to suppress update notices
        export npm_config_loglevel=error
        
        # Make sure scripts can find 'node' by creating a PATH with both 'node' and 'nodejs'
        export PATH="${pkgs.lib.makeBinPath [ pkgs.nodejs ]}:$PATH"
        
        # Tell npx explicitly where to find node
        export NODE="${pkgs.nodejs}/bin/node"
        
        # Use npx to run the package without installing it globally
        exec ${pkgs.nodejs}/bin/npx --node "$NODE" --yes ${packageName}@${version} "$@"
      '';
}
