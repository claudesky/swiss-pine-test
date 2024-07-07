include {
  path = find_in_parent_folders()
}

dependency "cluster" {
  config_path = "../cluster"
}

terraform {
  source = "${get_parent_terragrunt_dir()}/modules//app"
}

inputs = {
  name = "swiss-pine"
  acr_name = "swisspineorgregistry"
  kube_context = dependency.cluster.outputs.context
  cluster_subnet_id = dependency.cluster.outputs.cluster_subnet_id
  cluster_vnet_name = dependency.cluster.outputs.cluster_vnet_name
  cluster_vnet_id = dependency.cluster.outputs.cluster_vnet_id
  db_name = "swiss_pine"
}
