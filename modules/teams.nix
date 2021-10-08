{ config, lib, pkgs, ... }:
with lib;
let cfg = config.github.teams;
in {
  options.github.teams = mkOption {
    default = { };
    type = with types;
      attrsOf (submodule ({ name, ... }: {
        options = {

          # inherited parameter
          # -------------------

          name = mkOption {
            default = name;
            type = str;
          };
          description = mkOption {
            default = null;
            type = nullOr str;
          };
          privacy = mkOption {
            default = null;
            type = nullOr (enum [ "secret" "closed" ]);
          };

          # special parameter
          # -----------------

          extraConfig = mkOption {
            type = attrs;
            default = { };
            description = ''
              To set additional parameters from
              https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team
              which are not covered yet.
              extraConfig will override every other parameter provider by this github terranix module.
            '';
          };

          members = mkOption {
            default = [ ];
            type = listOf str;
          };
          maintainers = mkOption {
            default = [ ];
            type = listOf str;
          };
          repositories = mkOption {
            default = [ ];
            type = listOf str;
          };

        };
      }));
  };

  config =
    let mergeAll = function: mkMerge (flatten (mapAttrsToList function cfg));
    in mkIf (cfg != { }) {

      resource.github_team = mapAttrs (name: value:
        {
          inherit (value) name description privacy;
        } // value.extraConfig) cfg;

      resource.github_team_membership = mergeAll (team_name:
        { name, maintainers, members, ... }:
        (imap0 (index: maintainer: {
          "${team_name}_maintainer_${toString index}" = {
            team_id = "\${github_team.${team_name}.id}";
            username = maintainer;
            role = "maintainer";
          };
        }) (unique maintainers)) ++

        (imap0 (index: member: {
          "${team_name}_member_${toString index}" = {
            team_id = "\${github_team.${team_name}.id}";
            username = member;
            role = "member";
          };
        }) (unique members)));

      resource.github_team_repository = mergeAll (team_name:
        { repositories, ... }:
        imap0 (index: repository: {
          "${team_name}_repository_${toString index}" = {
            team_id = "\${github_team.${team_name}.id}";
            inherit repository;
          };
        }) (unique repositories));
    };

}
