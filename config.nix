{
  imports = [ ./provider.nix ];

  resource.github_repository = {
    terranix-github-configuration = {
      name = "terranix-github-configuration";
      description = "terranix project configuration on github";
      visibility = "public";
    };
    #terranix-examples = {
    #  name = "terranix-examples";
    #  description = "terranix examples/templates";
    #  visibility = "public";
    #};
    #terranix = {
    #  name = "terranix";
    #  description = "terranix";
    #  visibility = "public";
    #};
    #terranix-website = {
    #  name = "terranix-website";
    #  description = "terranix.org";
    #  visibility = "public";
    #};
  };
}
