{
  description = "A Discord client mod that does things differently";

  inputs = {
    # nixpkgs.url = "github:pupbrained/nixpkgs-replugged";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
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
    in rec {
      allowImpure = true;

      discord-plugged = pkgs.callPackage ./scripts/nix/discord-plugged.nix {inherit replugged;};
      replugged = pkgs.callPackage ./scripts/nix/replugged.nix {
        revision =
          if self ? rev
          then self.rev
          else "dev";
      };
    });
  };
}
