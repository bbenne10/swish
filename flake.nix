{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system:
    let pkgs = nixpkgs.legacyPackages.${system}; in
    rec {
      packages = {
        swish = pkgs.writeShellApplication {
          name = "swi.sh";
          runtimeInputs = with pkgs; [
            comrak
            minify
          ];
          text = builtins.readFile ./swi.sh;
        };
      };
      defaultPackage = packages.swish;
      devShell = pkgs.mkShell {
        packages = with pkgs; [
          shellcheck
        ];
        inputsFrom = [ packages.swish ];
      };
    }
  );
}
