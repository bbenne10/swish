{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system:
    let pkgs = nixpkgs.legacyPackages.${system}; in
    rec {
      packages = {
        sw = pkgs.stdenv.mkDerivation
          {
            pname = "sw";
            version = "1.0.0";
            src = ./.;
            installPhase = ''
              DESTDIR=$out make install
            '';
            buildInputs = with pkgs; [
              coreutils
            ];
          };
      };
      defaultPackage = packages.sw;
    }
  );
}
