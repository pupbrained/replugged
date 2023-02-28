{
  pkgs,
  lib,
  symlinkJoin,
  discord-canary ? pkgs.discord-canary,
  makeBinaryWrapper,
  writeShellScript,
  replugged,
}:
discord-canary.overrideAttrs (old: {
  postInstall = ''
    echo "out is $out"
    echo "src is $src"
    mkdir -p "$out/Applications/Discord Canary.app/Contents/Resources/app"
    echo -e 'require("../dist/main.js");' > "$out/Applications/Discord Canary.app/Contents/Resources/app/index.js"
    echo -e '{ "name": "discord-canary", "main": "index.js" }' > "$out/Applications/Discord Canary.app/Contents/Resources/app/package.json"
    mkdir -p "$out/Applications/Discord Canary.app/Contents/Resources/dist"
    cp -r ${replugged.replugged}/* "$out/Applications/Discord Canary.app/Contents/Resources/dist"
    cp -r "$out/Applications/Discord Canary.app/Contents/Resources/dist/i18n" "$out/Applications/Discord Canary.app/Contents/Resources"

    mv "$out/Applications/Discord Canary.app/Contents/Resources/app.asar" "$out/Applications/Discord Canary.app/Contents/Resources/app.orig.asar"

    substituteInPlace "$out/bin/Discord Canary" --replace '${discord-canary.out}' "$out"
  '';
})
