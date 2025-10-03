{
  description = "terranix github account configuration";

  inputs = {
    devshell.url = "github:numtide/devshell";
    flake-parts.url = "github:hercules-ci/flake-parts";
    module-github.url = "github:terranix/terranix-module-github";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    terranix.inputs.nixpkgs.follows = "nixpkgs";
    terranix.url = "github:terranix/terranix/develop";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./nix/formatter.nix
        ./nix/devshells.nix
      ];
      systems = [ "x86_64-linux" ];
      perSystem =
        {
          config,
          self',
          inputs',
          pkgs,
          system,
          ...
        }:
        let
          opentofu = "${pkgs.opentofu}/bin/tofu";
          terranixConfiguration = inputs.terranix.lib.terranixConfiguration {
            inherit system;
            modules = [
              inputs.module-github.terranixModule
              ./config.nix
            ];
          };
        in
        {

          apps.default = self'.apps.apply;

          # nix run ".#apply"
          apps.apply = {
            type = "app";
            program = toString (
              pkgs.writers.writeBash "apply" ''
                if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
                cp ${terranixConfiguration} config.tf.json \
                  && ${opentofu} init \
                  && ${opentofu} apply
              ''
            );
          };

          # nix run ".#destroy"
          apps.destroy = {
            type = "app";
            program = toString (
              pkgs.writers.writeBash "destroy" ''
                if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
                cp ${terranixConfiguration} config.tf.json \
                  && ${opentofu} init \
                  && ${opentofu} destroy
              ''
            );
          };

        };
    };
}
