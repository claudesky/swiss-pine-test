# Swiss Pine Test App
A test application for Swiss Pine

# Requirements

## Deployment
- An Azure account with an active Subscription
- An [Azure DevOps Organization](https://dev.azure.com/)
- The [azure-cli](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) installed on your system
- Terraform
- Terragrunt
- bash
- git

## Running Locally
- Docker
- Node 22
- VS Code

## Setup for Deployment

### Azure DevOps Setup

Create an ADO Personal Access Token (PAT)
https://learn.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate

Setup SSH keys to be able to push code to repositories in ADO
https://learn.microsoft.com/en-us/azure/devops/repos/git/use-ssh-keys-to-authenticate

### Initialization Scripts

Run these scripts on your local machine with a bash shell (other shells may work, untested)

*the first script is sourced to export the required env variables into your shell*

---

`source terraform/scripts/init-service-principal.sh`

This sets up some resources as well as the service principal that terraform will use to create resources
You can also re-source this script to reload the required environment variables into your shell

---

`./terraform/scripts/init-backend.sh`

The init-backend script initializes the storage for terraform state. You only need to run this once.

### Deploying the Project and Azure Container Registry

Export your ADO Organization URL and PAT as environment variables to allow terraform to create resources in ADO.

Set `./terraform/deployments/global/project` as your current working directory and run terragrunt with the `run-all` command to include setup of the registry.

`cd terraform/deployments/global/project`
`terragrunt run-all apply`

### Push the code

# Regarding Scaling of Customers

Infrastructure (terragrunt/terraform files) should be moved to a separate repository. That repository will handle deployments for each customer.
It should be possible to use multiple subscription IDs for each deployment within a single repository while reusing most or almost all of the existing code.

Customers may want to opt for their own kubernetes cluster, OR with what may be a more cost-effective solution; just share a kubernetes cluster with other customers.
Databases should still be separate even in a shared k8s cluster. If they really wanted to have their own 'VMs' in a shared k8s cluster, that should also be possible to arrange.
