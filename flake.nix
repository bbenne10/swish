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
            patchPhase = ''
              substituteInPlace swi.sh \
                --replace "comrak" "${pkgs.comrak}/bin/comrak"
            '';
            installPhase = ''
              DESTDIR=$out make install
            '';
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
