resource "azuredevops_project" "project" {
  name               = var.app_name
  visibility         = "private"
  version_control    = "Git"
  work_item_template = "Agile"
}

data "azuredevops_agent_queue" "default" {
  project_id = azuredevops_project.project.id
  name       = "Default"
}

// A default repo is created after creating the project
data "azuredevops_git_repository" "default" {
  project_id = azuredevops_project.project.id
  name = var.app_name
}

resource "azuredevops_serviceendpoint_azurecr" "registry" {
  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "Registry Service"
  resource_group            = var.resource_group_name
  azurecr_spn_tenantid      = var.tenant_id
  azurecr_name              = var.azurecr_name
  azurecr_subscription_id   = var.subscription_id
  azurecr_subscription_name = var.subcription_name
}

resource "azuredevops_build_definition" "example" {
  project_id = azuredevops_project.project.id
  name       = "Deployment Pipeline"

  ci_trigger {
    use_yaml = true
  }

  variable {
    name  = "registry_service_id"
    value = azuredevops_serviceendpoint_azurecr.registry.id
  }

  variable {
    name  = "app_name"
    value = var.app_name
  }

  repository {
    repo_type   = "TfsGit"
    repo_id     = data.azuredevops_git_repository.default.id
    branch_name = "main"
    yml_path    = "azure-pipelines.yml"
  }
}

resource "azuredevops_pipeline_authorization" "example" {
  project_id  = azuredevops_project.project.id
  resource_id = data.azuredevops_agent_queue.default.id
  type        = "queue"
  pipeline_id = azuredevops_build_definition.example.id
}

resource "azuredevops_pipeline_authorization" "registry" {
  project_id  = azuredevops_project.project.id
  resource_id = azuredevops_serviceendpoint_azurecr.registry.id
  type        = "endpoint"
}
