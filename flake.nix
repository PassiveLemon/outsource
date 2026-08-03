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
    in
    {
      devShells = {
        default = pkgs.mkShell {
          packages = let
            luaEnv = pkgs.lua.withPackages (ps: with ps; ([
              luaposix
            ]));
          in [
            luaEnv
          ];
          packagesFrom = [
            self'.packages.outsource.nativeBuildInputs
            self'.packages.outsource.buildInputs
          ];
          shellHook = ''
            export OUTSOURCE_SSH_PATH="/run/current-system/sw/bin/ssh"
            export OUTSOURCE_SSH_HOST="lemon@silver"
            export OUTSOURCE_FFMPEG_PATH="/run/current-system/sw/bin/ffmpeg"
            export OUTSOURCE_FFPROBE_PATH="/run/current-system/sw/bin/ffprobe"
            export OUTSOURCE_MAP_DIRS="/data//mnt/titanium/Media/;/config//mnt/titanium/docker/volumes/streaming/Jellyfin/"
            export OUTSOURCE_LOG_LEVEL="debug"
            alias editor="lite-xl $PWD &"
            alias nr="nix run"
          '';
        };
      };
      packages = {
        default = self'.packages.outsource;
        outsource = pkgs.callPackage ./package.nix { };
      };
      apps = {
        ffmpeg = {
          type = "app";
          program = "${self'.packages.outsource}/bin/outsource-ffmpeg";
        };
        ffprobe = {
          type = "app";
          program = "${self'.packages.outsource}/bin/outsource-ffprobe";
        };
      };
    };
  };
}

