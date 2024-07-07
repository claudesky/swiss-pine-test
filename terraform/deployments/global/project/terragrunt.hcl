include {
  path = find_in_parent_folders()
}

dependency "registry" {
  config_path = "../registry"
}

terraform {
  source = "${get_parent_terragrunt_dir()}/modules//project"
}

inputs = {
  azurecr_name = dependency.registry.outputs.registry_name
  app_name = "swiss-pine"
}
