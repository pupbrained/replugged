{
  pkgs,
  lib,
  symlinkJoin,
  discord-canary ? pkgs.discord-canary,
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
    paths = [discord-canary.out];

    postBuild = ''
      mkdir -p '$out/Applications/Discord Canary.app/Contents/Resources/app'
      echo -e 'require("../dist/main.js");' > '$out/Applications/Discord Canary.app/Contents/Resources/app/index.js'
      echo -e '{ "name": "discord-canary", "main": "index.js" }' > '$out/Applications/Discord Canary.app/Contents/Resources/app/package.json'
      mkdir -p '$out/Applications/Discord Canary.app/Contents/Resources/dist'
      cp -r ${replugged.replugged}/* '$out/Applications/Discord Canary.app/Contents/Resources/dist'
      cp -r '$out/Applications/Discord Canary.app/Contents/Resources/dist/i18n' '$out/Applications/Discord Canary.app/Contents/Resources'

      cp -a --remove-destination $(readlink "$out/Applications/Discord Canary.app/.DiscordCanary-wrapped") "$out/Applications/Discord Canary.app/.DiscordCanary-wrapped"
      cp -a --remove-destination $(readlink "$out/Applications/Discord Canary.app/DiscordCanary") "$out/Applications/Discord Canary.app/DiscordCanary"

      mv '$out/Applications/Discord Canary.app/Contents/Resources/app.asar' '$out/Applications/Discord Canary.app/Contents/Resources/app.orig.asar'

      if grep '\0' '$out/Applications/Discord Canary.app/DiscordCanary' && wrapperCmd=$(${extractCmd} '$out/Applications/Discord Canary.app/DiscordCanary') && [[ $wrapperCmd ]]; then
        parseMakeCWrapperCall() {
            shift
            oldExe=$1; shift
            oldWrapperArgs=("$@")
        }
        eval "parseMakeCWrapperCall ''${wrapperCmd//"${discord-canary.out}"/"$out"}"
        makeWrapper $oldExe '$out/Applications/Discord Canary.app/DiscordCanary' "''${oldWrapperArgs[@]}"
      else
        substituteInPlace '$out/Applications/Discord Canary.app/DiscordCanary' \
        --replace '${discord-canary.out}' "$out"
      fi

      substituteInPlace '$out/Applications/Discord Canary.app/DiscordCanary' --replace '${discord-canary.out}' "$out"
    '';

    meta.mainProgram =
      if (discord-canary.meta ? mainProgram)
      then discord-canary.meta.mainProgram
      else null;
  }
