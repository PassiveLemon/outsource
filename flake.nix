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
          packages = let
            luaEnv = pkgs.luajit.withPackages (ps: with ps; ([
              luaposix
            ]));
          in [
            luaEnv
          ];
          packagesFrom = [
            self'.packages.default.nativeBuildInputs
            self'.packages.default.buildInputs
          ];
          # export ANTENNA_MAP_DIRS="/test/data//source/replacement/works;/test/config//dest/replacement/works"
          shellHook = ''
            export ANTENNA_SSH_PATH="${lib.getExe pkgs.openssh}"
            export ANTENNA_SSH_HOST="lemon@silver"
            export ANTENNA_FFMPEG_PATH="/run/current-system/sw/bin/ffmpeg"
            export ANTENNA_MAP_DIRS="/data/shows//mnt/titanium/Media/Shows;/config//mnt/titanium/docker/volumes/streaming/Jellyfin"
            export ANTENNA_TEST='-i file:"/test/data/file-in.mp4" -hls_segment_filename "/test/config/file-out.mp4"'
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

