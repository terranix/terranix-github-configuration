{ config, lib, pkgs, ... }:
with lib;
let cfg = config.github.provider;
in {
  options.github.provider = {
    enable = mkEnableOption "github";
    owner = mkOption {
      default = null;
      type = with types; nullOr str;
    };
    version = mkOption {
      default = null;
      type = with types; nullOr str;
    };
    token = mkOption {
      default = null;
      type = with types; nullOr str;
    };
    base_url = mkOption {
      default = null;
      type = with types; nullOr str;
    };
  };

  config = mkIf cfg.enable {
    terraform.required_providers.github = {
      source = "integrations/github";
      inherit (cfg) version;
    };
    provider.github = { inherit (cfg) owner token base_url; };
  };
}
