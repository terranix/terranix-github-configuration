{
  terraform.required_providers.github = {
    source = "integrations/github";
    #version = "4.16.0";
  };
  provider.github = {
    owner = "terranix";
  };
}
