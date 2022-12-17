{
  description = "A Discord client mod that does things differently";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    pnpm2nix = {
      url = "github:pupbrained/pnpm2nix";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    pnpm2nix,
    ...
  } @ inputs: let
    forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
  in {
    packages = forAllSystems (system: let
      pkgs =
        import nixpkgs
        {
          inherit system;
          config.allowUnfree = true;
        }
        // {runCommandNoCC = pkgs.runCommand;};

      pnpm2nix' = import pnpm2nix {
        inherit pkgs;
      };
    in rec {
      allowImpure = true;

      discord-plugged = pkgs.callPackage ./scripts/nix/discord-plugged.nix {inherit replugged;};
      replugged = pkgs.callPackage ./scripts/nix/replugged.nix {
        revision =
          if self ? rev
          then self.rev
          else "dev";
        inherit (pnpm2nix') mkPnpmPackage;
      };
    });
  };
}
