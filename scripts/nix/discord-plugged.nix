{
  pkgs,
  lib,
  symlinkJoin,
  discord ? pkgs.discord,
  makeBinaryWrapper,
  writeShellScript,
  replugged,
}: let
  extractCmd =
    makeBinaryWrapper.extractCmd
    or (writeShellScript "extract-binary-wrapper-cmd" ''
      strings -dw "$1" | sed -n '/^makeCWrapper/,/^$/ p'
    '');
in
  symlinkJoin {
    name = "replugged";
    paths = [discord.out];

    postBuild = ''
      mkdir -p $out/opt/Discord/resources/app
      echo -e 'require("../dist/main.js");' > $out/opt/Discord/resources/app/index.js
      echo -e '{ "name": "discord", "main": "index.js" }' > $out/opt/Discord/resources/app/package.json
      mkdir -p $out/opt/Discord/resources/dist
      cp ${replugged.replugged}/* $out/opt/Discord/resources/dist

      cp -a --remove-destination $(readlink "$out/opt/Discord/.Discord-wrapped") "$out/opt/Discord/.Discord-wrapped"
      cp -a --remove-destination $(readlink "$out/opt/Discord/Discord") "$out/opt/Discord/Discord"

      mv $out/opt/Discord/resources/app $out/opt/Discord/resources/app.orig.asar

      if grep '\0' $out/opt/Discord/Discord && wrapperCmd=$(${extractCmd} $out/opt/Discord/Discord) && [[ $wrapperCmd ]]; then
        parseMakeCWrapperCall() {
            shift
            oldExe=$1; shift
            oldWrapperArgs=("$@")
        }
        eval "parseMakeCWrapperCall ''${wrapperCmd//"${discord.out}"/"$out"}"
        makeWrapper $oldExe $out/opt/Discord/Discord "''${oldWrapperArgs[@]}"
      else
        substituteInPlace $out/opt/Discord/Discord \
        --replace '${discord.out}' "$out"
      fi

      substituteInPlace $out/opt/Discord/Discord --replace '${discord.out}' "$out"
    '';

    meta.mainProgram =
      if (discord.meta ? mainProgram)
      then discord.meta.mainProgram
      else null;
  }
