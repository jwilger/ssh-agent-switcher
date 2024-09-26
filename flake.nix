{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages.ssh-agent-switcher = pkgs.stdenv.mkDerivation {
          pname = "ssh-agent-switcher";
          version = "latest";

          src = pkgs.fetchFromGitHub {
            owner = "jmmv";
            repo = "ssh-agent-switcher";
            rev = "HEAD";
            sha256 = "sha256-Fe2sBTb+FCjiSAA+nbqUtwgLenO67oDmxF08DAtbef8=";
          };

          buildInputs = [ pkgs.go ];

          buildPhase = ''
            export GOCACHE=$(pwd)/.cache/go-build
            mkdir -p $GOCACHE
            go build
          '';

          installPhase = ''
            mkdir -p $out/bin
            cp ssh-agent-switcher $out/bin/
          '';

          meta = with pkgs.lib; {
            description = "A tool to manage SSH agent switching";
            homepage = "https://github.com/jmmv/ssh-agent-switcher/";
            license = licenses.mit;
            maintainers = [ ];
            platforms = platforms.linux ++ platforms.darwin;
          };
        };

        packages.default = self.packages.${system}.ssh-agent-switcher;

        devShells.default = pkgs.mkShell {
          buildInputs = [ self.packages.${system}.ssh-agent-switcher ];
        };
      });
}
