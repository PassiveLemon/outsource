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
          # export ANTENNA_SSH_FLAGS=""
          shellHook = ''
            export ANTENNA_SSH_PATH="${lib.getExe pkgs.openssh}"
            export ANTENNA_SSH_HOST="lemon@silver"
            export ANTENNA_FFMPEG_PATH="/run/current-system/sw/bin/ssh"
            export ANTENNA_SOURCE_DIR="/source/replacement/works"
            export ANTENNA_DEST_DIR="/dest/replacement/works"
            alias editor="lite-xl $PWD &"
            alias nr="nix run"
            export ANTENNA_TEST='-i file:"/test/data/file-in.mp4" -hls_segment_filename "/test/config/file-out.mp4"'
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

