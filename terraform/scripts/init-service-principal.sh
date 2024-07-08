#!/usr/bin/env bash

# Initializes a service principal and stores credentials in KeyVault

# Variables
LOCATION=southeastasia
INFRA_RG=infra
VAULT_NAME=swiss-pine-infra
SECRET_NAME=sp-credentials

# login
az login

# get account details
ARM_ACCOUNT_DATA=($(az account show --query "[id,tenantId]" --out tsv))
SIGNED_IN_USER_ID=$(az ad signed-in-user show --query "id" --out tsv)

export ARM_SUBSCRIPTION_ID=${ARM_ACCOUNT_DATA[0]}
export ARM_TENANT_ID=${ARM_ACCOUNT_DATA[1]}

# check for infra resource group
if [ $(az group exists --name $INFRA_RG) = false ]; then
  echo "Creating resource group for remote state..."
  az group create -n $INFRA_RG -l $LOCATION
else
  echo "Resource group already exists."
fi

# check for keyvault
if [ ! $(az keyvault list --query "[?name == '$VAULT_NAME'].name | [0]" --out tsv) = $VAULT_NAME ]; then
  echo "Creating keyvault for infra..."
  az keyvault create -n $VAULT_NAME -g $INFRA_RG -l $LOCATION
else
  echo "Keyvault already exists."
fi

# check for keyvault admin role
KEYVAULT_SCOPE=$(az keyvault show --name $VAULT_NAME --query "id" --out tsv)
if [ $(az role assignment list --assignee $SIGNED_IN_USER_ID --role "Key Vault Administrator" --scope $KEYVAULT_SCOPE --query "[0] != null") = false ]; then
  echo "Assigning keyvault admin role to self..."
  az role assignment create --assignee $SIGNED_IN_USER_ID --role "Key Vault Administrator" --scope $KEYVAULT_SCOPE
else
  echo "Keyvault admin role is already assigned."
fi

# check for service principal credentials
if [ $(az keyvault secret list --vault-name $VAULT_NAME --query "[?name == '$SECRET_NAME'] | [0] != null") = false ]; then
  echo "Creating service principal..."
  SP_CREDENTIALS=($(az ad sp create-for-rbac --role="Owner" --scopes="/subscriptions/$ARM_SUBSCRIPTION_ID" --query "[appId,password]" --out tsv))
  echo "Saving to secret in vault..."
  az keyvault secret set -n $SECRET_NAME --vault-name $VAULT_NAME --value ${SP_CREDENTIALS[0]},${SP_CREDENTIALS[1]}
else
  echo "Service principal credentials found, checking..."
  IFS=',' read -r -a SP_CREDENTIALS <<< $(az keyvault secret show -n $SECRET_NAME --vault-name $VAULT_NAME --query "value" --out tsv)
  if [ $(az role assignment list --assignee ${SP_CREDENTIALS[0]} --role "Key Vault Administrator" --scope $KEYVAULT_SCOPE --query "[0] != null") = false ]; then
    echo "Adding keyvault admin role to service principal..."
    az role assignment create --assignee ${SP_CREDENTIALS[0]} --role "Key Vault Administrator" --scope $KEYVAULT_SCOPE
  fi
fi

export ARM_CLIENT_ID=${SP_CREDENTIALS[0]}
export ARM_CLIENT_SECRET=${SP_CREDENTIALS[1]}

echo "Service principal is ready. If you sourced this file, the environment variables should already be in your shell."
