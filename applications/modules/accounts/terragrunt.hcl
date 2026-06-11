terraform {
  source = "git::https://github.com/rodentskiedev/terraform-modules.git//aws_sso/aws_account?ref=v0.0.2"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  environment = get_env("TG_VAR_ENVIRONMENT")

  tags_vars = read_terragrunt_config(find_in_parent_folders("tags.hcl"))

  tags = local.tags_vars.locals[local.environment]
}

dependency "ou" {
  config_path = find_in_parent_folders("applications/modules/ou")

  mock_outputs_allowed_terraform_commands = ["validate", "init", "plan"]
  mock_outputs = {
    system = {
      id  = "ou-01234-abcd",
      arn = "arn:aws:organizations::11111111:ou/o-abcd/ou-abcd-abcd"
    }
    sandbox = {
      id  = "ou-01234-abcd",
      arn = "arn:aws:organizations::11111111:ou/o-abcd/ou-abcd-abcd"
    }
  }
}

inputs = {
  accounts = {
    system = {
      name      = "system"
      email     = "aws+system@gmail.com"
      parent_id = dependency.ou.outputs.organizational_units["system"].id
      tags      = local.tags
    }
    klaro-dev = {
      name      = "klaro-dev"
      email     = "aws+klaro-dev@gmail.com"
      parent_id = dependency.ou.outputs.organizational_units["sandbox"].id
      tags      = local.tags
    }
  }
}