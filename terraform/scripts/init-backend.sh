#!/usr/bin/env bash

# Variables
LOCATION=southeastasia
INFRA_RG=infra
STORAGE_ACCOUNT=swisspineinfrastorage
CONTAINER_NAME=terraform-state

# Login into Azure using a service principal
echo "Authenticating as the service principal..."
az login --service-principal --username $ARM_CLIENT_ID --password $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID

# Set default values for resource group and location so we don't have to repeat them
az configure --defaults location=$LOCATION
az configure --defaults group=$INFRA_RG

# Create a storage account for our remote state if it doesn't exist
if [ $(az storage account list --query "[?name == '$STORAGE_ACCOUNT'].name | [0] != null") = false ]; then
  echo "Creating storage account for remote state..."
  az storage account create -n $STORAGE_ACCOUNT --sku Standard_LRS
else
  echo "Storage account already exists."
fi

STORAGE_ACCOUNT_KEY=$(az storage account keys list -n $STORAGE_ACCOUNT --query "[0].value" -o tsv)

# Create a storage container if it doesn't exist
if [ $(az storage container list --account-key $STORAGE_ACCOUNT_KEY --account-name $STORAGE_ACCOUNT --query "[?name == '$CONTAINER_NAME'].name | [0] != null" -o tsv) = false ]; then
  echo "Creating storage container for remote state..."
  az storage container create -n $CONTAINER_NAME --account-name $STORAGE_ACCOUNT --account-key $STORAGE_ACCOUNT_KEY
else
  echo "Storage container already exists."
fi

cat <<EOF
Terraform backend has been configured.

Make sure you have a Personal Access Token from ADO.
Export it to your current shell along with your Organization URL:

export AZDO_ORG_SERVICE_URL=https://dev.azure.com/<myorg>/
export AZDO_PERSONAL_ACCESS_TOKEN=<PAT>

You can now deploy the ADO Project from terraform/deployments/global/project

$ terragrunt run-all apply

EOF
