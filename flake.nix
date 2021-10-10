{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    terranix = {
      #url = "github:terranix/terranix/develop";
      url = "path:/home/palo/dev/terranix/terranix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, terranix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        terraform = pkgs.terraform_0_15;
        terranixConfiguration = terranix.lib.buildTerranix {
          inherit pkgs;
          terranix_config.imports = [ ./config.nix ];
        };
        terranixOptions = terranix.lib.buildOptions {
          inherit pkgs;
          moduleRootPath = toString ./.;
          urlPrefix =
            "https://github.com/terranix/module-github/tree/main/modules";
          terranix_modules = [{ imports = [ ./modules/default.nix ]; }];
        };
      in {
        defaultPackage = terranixConfiguration;
        #defaultPackage = terranixOptions;
        # nix develop
        devShell = pkgs.mkShell {
          buildInputs =
            [ pkgs.terraform_0_15 terranix.defaultPackage.${system} ];
        };
        # nix run ".#options"
        apps.options = {
          type = "app";
          program = toString (pkgs.writers.writeBash "options" ''
            cp ${terranixOptions}/options.json options.json
          '');
        };
        # nix run ".#apply"
        apps.apply = {
          type = "app";
          program = toString (pkgs.writers.writeBash "apply" ''
            if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
            cp ${terranixConfiguration}/config.tf.json config.tf.json \
              && ${terraform}/bin/terraform init \
              && ${terraform}/bin/terraform apply
          '');
        };
        # nix run ".#destroy"
        apps.destroy = {
          type = "app";
          program = toString (pkgs.writers.writeBash "destroy" ''
            if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
            cp ${terranixConfiguration}/config.tf.json config.tf.json \
              && ${terraform}/bin/terraform init \
              && ${terraform}/bin/terraform destroy
          '');
        };
        # nix run
        defaultApp = self.apps.${system}.apply;
      });
}
