#!/usr/bin/env bash

# For the DevOps Pipeline

# Variables
LOCATION=southeastasia
INFRA_RG=infra
VAULT_NAME=swiss-pine-infra
SECRET_NAME=sp-credentials

# get account details
ARM_ACCOUNT_DATA=($(az account show --query "[id,tenantId]" --out tsv))
SIGNED_IN_USER_ID=$(az ad signed-in-user show --query "id" --out tsv)

export ARM_SUBSCRIPTION_ID=${ARM_ACCOUNT_DATA[0]}
export ARM_TENANT_ID=${ARM_ACCOUNT_DATA[1]}

echo "Fetching service principal credentials..."
IFS=',' read -r -a SP_CREDENTIALS <<< $(az keyvault secret show -n $SECRET_NAME --vault-name $VAULT_NAME --query "value" --out tsv)

export ARM_CLIENT_ID=${SP_CREDENTIALS[0]}
export ARM_CLIENT_SECRET=${SP_CREDENTIALS[1]}

echo "Environment loaded."

echo "Authenticating as the service principal..."
az login --service-principal --username $ARM_CLIENT_ID --password $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID

echo "CI init complete."
