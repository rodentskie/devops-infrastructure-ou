terraform {
  source = "git::https://github.com/rodentskiedev/terraform-modules.git//aws_sso/aws_ou?ref=v0.0.2"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  environment = get_env("TG_VAR_ENVIRONMENT")

  tags_vars = read_terragrunt_config(find_in_parent_folders("tags.hcl"))

  tags = local.tags_vars.locals[local.environment]
}

dependency "org" {
  config_path = find_in_parent_folders("data/organization")

  mock_outputs_allowed_terraform_commands = ["validate", "init", "plan"]
  mock_outputs = {
    root_id = "r-123456"
  }
}

inputs = {
  parent_id            = dependency.org.outputs.root_id
  organizational_units = ["system", "sandbox"]
  tags                 = local.tags
}