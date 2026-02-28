{
  description = "cs445 nix develop";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
  };
  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          pkgs.iverilog
        ];
      };
    };
}

