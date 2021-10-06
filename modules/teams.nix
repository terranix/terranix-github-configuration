{ config, lib, pkgs, ... }:
with lib;
let cfg = config.github.team;
in {
  options.github.team = mkOption {
    default = { };
    type = with types;
      attrsOf (submodule ({ name, ... }: {
        options = {
          name = mkOption {
            type = str;
            default = name;
          };
          description = mkOption {
            default = "";
            type = str;
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

      resource.github_team =
        mapAttrs (name: value: { inherit (value) name description; }) cfg;

      resource.github_team_membership = mergeAll (team_name:
        { name, maintainers, members, ... }:
        (imap0 (index: maintainer: {
          "${team_name}_maintainer_${toString index}" = {
            team_id = "\${github_team.${team_name}.id}";
            username = maintainer;
            role = "maintainer";
          };
        }) maintainers) ++

        (imap0 (index: member: {
          "${team_name}_member_${toString index}" = {
            team_id = "\${github_team.${team_name}.id}";
            username = member;
            role = "member";
          };
        }) members));

      resource.github_team_repository = mergeAll (team_name:
        { repositories, ... }:
        imap0 (index: repository: {
          "${team_name}_repository_${toString index}" = {
            team_id = "\${github_team.${team_name}.id}";
            inherit repository;
          };
        }) repositories);
    };

}
