{ config, lib, pkgs, ... }:
with lib;

let cfg = config.github.repositories;
in {
  options.github.repositories = mkOption {
    default = { };
    type = with types;
      attrsOf (submodule ({ name, ... }: {
        options = {

          # inherited parameter
          # -------------------

          name = mkOption {
            type = str;
            default = name;
            description = "name of the repository";
          };

          description = mkOption {
            type = nullOr str;
            default = null;
            description = "description of the repository";
          };

          homepage_url = mkOption {
            type = nullOr str;
            default = null;
            description = "homepage url of the repository";
          };

          visibility = mkOption {
            type = nullOr (enum [ "private" "public" "internal" ]);
            default = null;
            description = "wether of the repository is private or not";
          };

          has_issues = mkOption {
            type = nullOr bool;
            default = null;
            description = "should the repository have issue tracking";
          };

          has_projects = mkOption {
            type = nullOr bool;
            default = null;
            description = "should the repository have projects";
          };

          has_wiki = mkOption {
            type = nullOr bool;
            default = null;
            description = "should the repository have a wiki";
          };

          is_template = mkOption {
            type = nullOr bool;
            default = null;
            description = "is this repository a template";
          };

          allow_merge_commit = mkOption {
            type = nullOr bool;
            default = null;
            description =
              "Set to false to disable merge commits on the repository.";
          };

          allow_squash_merge = mkOption {
            type = nullOr bool;
            default = null;
            description =
              "Set to false to disable squash merges on the repository.";
          };

          allow_rebase_merge = mkOption {
            type = nullOr bool;
            default = null;
            description =
              "Set to false to disable rebase merges on the repository.";
          };

          delete_branch_on_merge = mkOption {
            type = nullOr bool;
            default = null;
            description =
              "Automatically delete head branch after a pull request is merged. Defaults to false";
          };

          has_downloads = mkOption {
            type = nullOr bool;
            default = null;
            description =
              "Set to true to enable the (deprecated) downloads features on the repository.";
          };

          auto_init = mkOption {
            type = nullOr bool;
            default = null;
            description =
              "Set to true to produce an initial commit in the repository.";
          };

          gitignore_template = mkOption {
            type = nullOr str;
            default = null;
            description = ''
              Use the [name of the template](https://github.com/github/gitignore) without the extension.
            '';
            example = "Haskell";
          };

          license_template = mkOption {
            type = nullOr str;
            default = null;
            description = ''
              Use the [name of the template](https://github.com/github/choosealicense.com/tree/gh-pages/_licenses) without the extension.
            '';
            example = "mpl-2.0";
          };

          archived = mkOption {
            type = nullOr bool;
            default = null;
            description =
              "Specifies if the repository should be archived. Defaults to false";
          };

          archive_on_destroy = mkOption {
            type = nullOr bool;
            default = null;
            description =
              "Set to true to archive the repository instead of deleting on destroy.";
          };

          topics = mkOption {
            type = listOf str;
            default = [ ];
            description = "list of topics for the repository";
          };

          template = mkOption {
            type = nullOr (submodule {
              options = {
                owner = mkOption {
                  type = str;
                  description =
                    "The GitHub organization or user the template repository is owned by.";
                };
                repository = mkOption {
                  type = str;
                  description = "The name of the template repository.";
                };

              };
            });
            default = null;
            description = "Use a template repository to create this resource.";
          };

          vulnerability_alerts = mkOption {
            type = nullOr bool;
            default = null;
            description = ''
              Set to true to enable security alerts for vulnerable dependencies.
              Enabling requires alerts to be enabled on the owner level
            '';
          };

          pages = mkOption {
            type = nullOr (submodule {
              options = {
                source = mkOption {
                  type = (submodule {
                    options = {
                      branch = mkOption {
                        type = str;
                        description =
                          "The repository branch used to publish the site's source files.";
                      };
                      path = mkOption {
                        type = nullOr str;
                        description =
                          "The repository directory from which the site publishes";
                      };
                    };
                  });
                  description =
                    "The source branch and directory for the rendered Pages site.";
                };
                cname = mkOption {
                  type = nullOr str;
                  description =
                    "The custom domain for the repository. This can only be set after the repository has been created.";
                };
              };
            });
            default = null;
            description = "The repository's GitHub Pages configuration. ";
            example = { pages.source.branch = "gh-pages"; };
          };

          # special treated parameter
          # -------------------------

          # todo
          default_branch = mkOption {
            type = nullOr str;
            default = null;
            description = ''
              default branch of the repository
            '';
            example = "main";
          };

          # todo
          branches = mkOption {
            type = listOf str;
            default = null;
            description = ''
              branches of repository
            '';
            example = [ "main" "develop" ];
          };

          # todo
          colaborators = mkOption {
            type = attrsOf (submodule ({ name, ... }: {
              options = {
                name = mkOption {
                  type = str;
                  default = name;
                  description = "github name";
                };
                permission = mkOption {
                  type =
                    nullOr (enum [ "pull" "push" "maintain" "triage" "admin" ]);
                  default = null;
                  description = "permissions of this collaborator";
                };
              };
            }));
            default = { };
            description = ''
              collaborators of repository
            '';
            example = [ "main" "develop" ];
          };

          teams = mkOption {
            type = listOf str;
            default = [ ];
            description = ''
              list of teams this repository belongs to.
              convenience function, which appends this repository to github.teams;
            '';
            example = "main";
          };

          extraConfig = mkOption {
            type = attrs;
            default = { };
            description = ''
              To set additional parameters from
              https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository
              which are not covered yet.
              extraConfig will override every other parameter provider by this github terranix module.
            '';
          };
        };
      }));
  };

  config = mkMerge [{
    resource.github_repository = (mapAttrs (_: value:
      {
        inherit (value)
          name description homepage_url visibility has_issues has_projects
          has_wiki is_template allow_merge_commit allow_squash_merge
          allow_rebase_merge delete_branch_on_merge has_downloads auto_init
          gitignore_template license_template archived archive_on_destroy topics
          template vulnerability_alerts pages;
      } // value.extraConfig) cfg);

    github.teams = let
      team_for_repositories = zipAttrs (flatten (mapAttrsToList
        (_: value: (map (team: { ${team} = value.name; }) value.teams)) cfg));
    in mapAttrs (_: repositories: { inherit repositories; })
    team_for_repositories;
  }];
}
