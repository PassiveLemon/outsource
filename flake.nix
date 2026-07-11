{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs = { ... } @ inputs:
  inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" ];

    perSystem = { self', system, ... }:
    let
      pkgs = import inputs.nixpkgs { inherit system; };
      lib = pkgs.lib;
    in
    {
      devShells = {
        default = pkgs.mkShell {
          packages = with pkgs; [
            lua
          ];
          packagesFrom = [
            self'.packages.default.nativeBuildInputs
            self'.packages.default.buildInputs
          ];
          # export ANTENNA_FFMPEG_PATH="${lib.getExe pkgs.ffmpeg_7}"
          # export ANTENNA_SSH_PATH="${lib.getExe pkgs.openssh}"
          # export ANTENNA_SSH_FLAGS="-i /home/lemon/.ssh/id_ed25519 lemon@silver"
          # export ANTENNA_SOURCE_DIR="/test/source/replacement"
          # export ANTENNA_DEST_DIR="/test/dest/replacement"
          shellHook = ''
            alias editor="lite-xl $PWD &"
            alias nr="nix run"
          '';
        };
      };
      packages = {
        default = self'.packages.antenna;
        antenna = pkgs.callPackage ./package.nix { };
      };
    };
  };
}

