{
  pkgs,
  revision,
}: rec {
  replugged =
    pkgs.mkYarnPackage
    {
      name = "replugged";

      src = ../..;

      packageJSON = ../../package.json;
      yarnLock = ../../yarn.lock;

      linkDevDependencies = true;
      outputs = ["out"];

      nativeBuildInputs = with pkgs; [git];

      buildPhase = ''
        yarn build nix ${revision}
      '';

      installPhase = ''
        mkdir -p $out
        cp -r $PWD/deps/replugged/dist/* $out
        cp -r $PWD/deps/replugged/i18n $out
      '';

      distPhase = "#";
    };
}
