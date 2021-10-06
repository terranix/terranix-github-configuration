{ config, lib, pkgs, ... }:
with lib;
let cfg = config.github.milestones;
in {
  options.github.milestones = mkOption {
    default = [ ];
    type = with types;
      listOf (submodule {
        options = {
          owner = mkOption { type = str; };
          repository = mkOption { type = str; };
          milestones = mkOption {
            default = [ ];
            type = listOf (submodule {
              options = {
                title = mkOption { type = str; };
                state = mkOption {
                  type = nullOr str;
                  default = null;
                };
                description = mkOption {
                  type = nullOr str;
                  default = null;
                };
                due_date = mkOption {
                  type = nullOr str;
                  default = null;
                };
              };
            });
          };
        };
      });
  };

  config = {
    resource.github_repository_milestone = mkMerge (flatten (map
      ({ owner, repository, milestones, ... }:
        (map ({ title, state, description, due_date }:
          let
            name = replaceStrings [ "." "," "/" ] [ "_" "_" "_" ]
              "${owner}_${repository}_${title}";
          in {
            ${name} = {
              inherit title state description due_date owner repository;
            };
          }) milestones)

      ) cfg));

  };

}
