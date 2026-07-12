{ lib
, stdenv
, lua
}:
let
  luaEnv = lua.withPackages (ps: with ps; ([
    luaposix
  ]));
in
stdenv.mkDerivation (finalAttrs: {
  pname = "antenna";
  version = "0.1.0";

  src = ./.;

  strictDeps = true;

  buildInputs = [ luaEnv ];

  installPhase = ''
    runHook preInstall

    mkdir $out/bin
    cp $src/* $out/bin

    runHook postInstall
  '';

  meta = with lib; {
    description = "Run FFmpeg commands on another host";
    homepage = "https://github.com/PassiveLemon/antenna";
    changelog = "https://github.com/PassiveLemon/antenna/releases/tag/${finalAttrs.version}";
    license = licenses.gpl3;
    maintainers = with maintainers; [ passivelemon ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "antenna";
  };
})

