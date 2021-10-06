{
  imports = [ ./provider.nix ./modules/teams.nix ];

  # repositories
  resource.github_repository = let
    visibility = "public";
    homepage_url = "https://terranix.org";
    topics = [ "nix" "terraform" ];
    vulnerability_alerts = true;
    has_issues = true;
    has_downloads = true;
    license_template = "gpl-3.0";
  in {
    terranix-github-configuration = {
      name = "terranix-github-configuration";
      description = "terranix project configuration on github";
      inherit visibility homepage_url topics vulnerability_alerts has_issues
        license_template;
    };
    terranix-examples = {
      name = "terranix-examples";
      description = "examples/templates on how to use terranix";
      inherit visibility homepage_url topics vulnerability_alerts has_issues
        has_downloads license_template;
    };
    terranix = {
      name = "terranix";
      description =
        "terranix is a terraform.json generator with a nix-like feeling";
      inherit visibility homepage_url topics vulnerability_alerts has_issues
        has_downloads license_template;
    };
    terranix-website = {
      name = "terranix-website";
      description = "https://terranix.org website";
      inherit visibility homepage_url topics vulnerability_alerts has_issues
        license_template;
    };
  };

  github.team.admins = {
    maintainers = [ "mrvandalo" ];
    members = [ "mrvandalo-springer" ];
    repositories = [
      "terranix"
      "terranix-examples"
      "terranix-website"
      "terranix-github-configuration"
    ];
  };

  # Create a milestone for a repository
  resource.github_repository_milestone = let
    owner = "terranix";
    repository = "terranix";
  in {
    flakes = {
      inherit owner repository;
      description = "bring terranix in the world of flakes";
      state = "open";
      title = "2.4.0";
    };
    next_big_thing = {
      inherit owner repository;
      description = "next big thing";
      state = "open";
      title = "2.5.0";
    };
  };

}
