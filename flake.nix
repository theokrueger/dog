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
      
      wave2saif = pkgs.rustPlatform.buildRustPackage (finalAttrs: {
        pname = "wave2saif";
        version = "14.1.1";

        src = pkgs.fetchFromGitLab{
          owner = "surfer-project";
          repo = "wave2saif";
          rev = "d89109c7074fb50bee8825858afb2ccdc6001f22";
          hash = "sha256-4SnixiFvfTYn9TN2lBq3F4BH41W+JiXbBTKW7wHyo9w=";
        };

        cargoHash = "sha256-RfyND/j25a6wlXMjPAZ4n9tWRo9KI4klr1pYvRr6O8s=";
      });

      
      
    in {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          pkgs.iverilog
          pkgs.sv-lang
          wave2saif
        ];
      };
    };
}

