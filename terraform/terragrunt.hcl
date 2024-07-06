locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  site_vars = read_terragrunt_config(find_in_parent_folders("site.hcl"))
  subscription_id                        = local.env_vars.locals.subscription_id
  client_id                              = local.env_vars.locals.client_id
  tenant_id                              = local.env_vars.locals.tenant_id
  deployment_storage_resource_group_name = local.site_vars.locals.deployment_storage_resource_group_name
  deployment_storage_account_name        = local.site_vars.locals.deployment_storage_account_name
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
    subscription_id      = local.subscription_id
    resource_group_name  = local.deployment_storage_resource_group_name
    storage_account_name = local.deployment_storage_account_name
    container_name       = "terraform-state"
    key                  = "${path_relative_to_include("deployments")}/terraform.tfstate"
  }
}

inputs = merge(
  local.env_vars.locals,
  local.site_vars.locals,
)
