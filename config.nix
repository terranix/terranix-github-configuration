{
  imports = [ ./provider.nix ];

  # repositories
  resource.github_repository = let
    visibility = "public";
    homepage_url = "https://terranix.org";
    topics = [ "nix" "terraform" ];
    vulnerability_alerts = true;
    has_issues = true;
    has_downloads = true;
  in {
    terranix-github-configuration = {
      name = "terranix-github-configuration";
      description = "terranix project configuration on github";
      inherit visibility homepage_url topics vulnerability_alerts has_issues;
    };
    terranix-examples = {
      name = "terranix-examples";
      description = "examples/templates on how to use terranix";
      inherit visibility homepage_url topics vulnerability_alerts has_issues
        has_downloads;
    };
    terranix = {
      name = "terranix";
      description =
        "terranix is a terraform.json generator with a nix-like feeling";
      inherit visibility homepage_url topics vulnerability_alerts has_issues
        has_downloads;
    };
    terranix-website = {
      name = "terranix-website";
      description = "https://terranix.org website";
      inherit visibility homepage_url topics vulnerability_alerts has_issues;
    };
  };

  # teams
  resource.github_team.admins = {
    name = "admins";
    description = "sudo team";
  };
  resource.github_team_membership = {
    palo = {
      team_id = "\${github_team.admins.id}";
      username = "mrvandalo";
      role = "maintainer";
    };
  };
  resource.github_team_repository = {
    terranix-github-configuration = {
      team_id = "\${github_team.admins.id}";
      repository = "\${github_repository.terranix-github-configuration.name}";
    };
  };
}
