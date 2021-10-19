{

  github.provider = {
    enable = true;
    owner = "terranix";
  };

  github.repositories = let
    visibility = "public";
    homepage_url = "https://terranix.org";
    topics = [ "nix" "terraform" ];
    vulnerability_alerts = true;
    has_issues = true;
    has_downloads = true;
    license_template = "gpl-3.0";
    delete_branch_on_merge = true;
  in {
    terranix = {
      teams = [ "admins" "core" ];
      description =
        "terranix is a terraform.json generator with a nix-like feeling";
      inherit visibility homepage_url topics vulnerability_alerts has_issues
        delete_branch_on_merge has_downloads license_template;
    };
    terranix-examples = {
      teams = [ "admins" "core" "modules" ];
      description = "examples/templates on how to use terranix";
      inherit visibility homepage_url topics vulnerability_alerts has_issues
        delete_branch_on_merge has_downloads license_template;
    };
    terranix-github-configuration = {
      teams = [ "admins" ];
      description = "terranix project configuration on github";
      inherit visibility homepage_url topics vulnerability_alerts has_issues
        delete_branch_on_merge license_template;
    };
    terranix-website = {
      teams = [ "admins" "website" ];
      description = "https://terranix.org website";
      inherit visibility homepage_url topics vulnerability_alerts has_issues
        delete_branch_on_merge license_template;
    };
    terranix-module-github = {
      teams = [ "admins" ];
      description = "An opinionated github terranix module.";
      inherit visibility homepage_url topics vulnerability_alerts has_issues
        delete_branch_on_merge license_template;
    };
  };

  github.teams = {
    admins = {
      maintainers = [ "mrvandalo" ];
      privacy = "closed";
    };
    core = {
      maintainers = [ "mrvandalo" ];
      privacy = "closed";
    };
    website = {
      maintainers = [ "mrvandalo" ];
      privacy = "closed";
    };
    modules = {
      maintainers = [ "mrvandalo" ];
      privacy = "closed";
    };
  };

  github.milestones = [
    {
      owner = "terranix";
      repository = "terranix";
      milestones = [
        {
          title = "2.4.0";
          description = "bring flakes to terranix";
        }
        {
          title = "2.5.0";
          description = "next level";
        }
      ];
    }
    {
      owner = "terranix";
      repository = "terranix-website";
      milestones = [{
        title = "1.0.0";
        description = ''
          Re-brand the whole terranix website
          and bring it back on the map
        '';
      }];
    }
  ];

}
