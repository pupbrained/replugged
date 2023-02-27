{
  pkgs,
  revision,
}: rec {
  replugged =
    pkgs.mkYarnPackage
    {
      name = "replugged";

      src = ../../.;

      packageJSON = ../../package.json;
      yarnLock = ../../yarn.lock;

      # overrides = {
      #   electron = drv:
      #     drv.overrideAttrs (old: {
      #       ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
      #     });
      # };

      allowImpure = true;

      linkDevDependencies = true;
      outputs = ["out"];

      nativeBuildInputs = with pkgs; [git];

      buildPhase = ''
        cp -r $PWD/node_modules/replugged/* $PWD
        ${pkgs.nodePackages.yarn}/bin/yarn build nix ${revision}
      '';

      installPhase = ''
        mkdir -p $out
        cp -r $PWD/dist/* $out
        cp -r $PWD/i18n $out
      '';
    };
}
