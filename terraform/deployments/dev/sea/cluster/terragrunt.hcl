locals {
  site_vars                          = read_terragrunt_config(find_in_parent_folders("site.hcl"))
  cluster_subnet_name                = "cluster-1-sn-${local.site_name}"
  cluster_subnet_security_group_name = "cluster-1-sg-${local.site_name}"
  site_name                          = local.site_vars.locals.site_name
  resource_group_name = local.site_vars.locals.resource_group_name
  name = "cluster-1"
  context = "${local.resource_group_name}-${local.name}"
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_parent_terragrunt_dir()}/modules//cluster"
  after_hook "after_hook" {
    commands     = ["apply"]
    execute      = [
      "/bin/bash",
      "-c",
      "echo > ~/.kube/config && az aks get-credentials --resource-group ${local.resource_group_name} --name ${local.name} --context ${local.context}"
    ]
    run_on_error = false
  }
}

dependency "registry" {
  config_path = "../../../global/registry"
}

inputs = {
  name = "cluster-1"
  context = local.context
  acr_id = dependency.registry.outputs.registry_id
  acr_name = dependency.registry.outputs.registry_name
}
