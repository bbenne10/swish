{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system:
    let pkgs = nixpkgs.legacyPackages.${system}; in
    rec {
      packages = {
        swish = pkgs.stdenv.mkDerivation
          {
            pname = "swish";
            version = "1.0.0";
            src = ./.;
            doBuild = false;
            installPhase = ''
              DESTDIR=$out make install
            '';
            propagatedBuildInputs = with pkgs; [
              coreutils
              comrak
            ];
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
