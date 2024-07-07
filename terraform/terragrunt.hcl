locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  site_vars = read_terragrunt_config(find_in_parent_folders("site.hcl"))
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">=0.1.0"
    }
  }
  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

provider "azuredevops" {
}
EOF
}

remote_state {
  backend = "azurerm"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    subscription_id      = get_env("ARM_SUBSCRIPTION_ID")
    resource_group_name  = "infra"
    storage_account_name = "swisspineinfrastorage"
    container_name       = "terraform-state"
    key                  = "${path_relative_to_include("deployments")}/terraform.tfstate"
  }
}

inputs = merge(
  local.env_vars.locals,
  local.site_vars.locals,
)
