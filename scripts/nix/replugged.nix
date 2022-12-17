{
  pkgs,
  revision,
  mkPnpmPackage,
}: rec {
  replugged =
    mkPnpmPackage
    {
      name = "replugged";

      src = ../../.;

      packageJSON = ../../package.json;
      pnpmLock = ../../pnpm-lock.yaml;

      overrides = {
        electron = drv:
          drv.overrideAttrs (old: {
            ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
          });
      };

      allowImpure = true;

      linkDevDependencies = true;
      outputs = ["out"];

      nativeBuildInputs = with pkgs; [git];

      buildPhase = ''
        cp -r $PWD/node_modules/replugged/* $PWD
        ${pkgs.nodePackages.pnpm}/bin/pnpm build nix ${revision}
      '';

      installPhase = ''
        mkdir -p $out
        cp -r $PWD/dist/* $out
      '';
    };
}
