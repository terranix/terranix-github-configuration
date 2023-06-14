{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    terranix = {
      url = "github:terranix/terranix/develop";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    module-github.url = "github:terranix/terranix-module-github";
  };

  outputs = { self, nixpkgs, flake-utils, terranix, module-github }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        terraform = pkgs.terraform_0_15;
        terranixConfiguration = terranix.lib.terranixConfiguration {
          inherit system;
          modules = [
            module-github.terranixModule
            ./config.nix
          ];
        };
      in {
        defaultPackage = terranixConfiguration;

        # nix develop
        devShell = pkgs.mkShell {
          buildInputs =
            [ pkgs.terraform_0_15 terranix.defaultPackage.${system} ];
        };

        # nix run ".#apply"
        apps.apply = {
          type = "app";
          program = toString (pkgs.writers.writeBash "apply" ''
            if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
            cp ${terranixConfiguration} config.tf.json \
              && ${terraform}/bin/terraform init \
              && ${terraform}/bin/terraform apply
          '');
        };

        # nix run ".#destroy"
        apps.destroy = {
          type = "app";
          program = toString (pkgs.writers.writeBash "destroy" ''
            if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
            cp ${terranixConfiguration} config.tf.json \
              && ${terraform}/bin/terraform init \
              && ${terraform}/bin/terraform destroy
          '');
        };

        # nix run
        apps.default = self.apps.${system}.apply;
      });
}
