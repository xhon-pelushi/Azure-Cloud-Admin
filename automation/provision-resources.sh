#!/bin/bash
# Azure Resource Provisioning Script
# Uses Azure CLI to provision resources

set -e

RESOURCE_GROUP="rg-azure-lab"
LOCATION="eastus"
VM_NAME="vm-lab-01"
STORAGE_ACCOUNT="st$(date +%s)"

echo "Provisioning Azure resources..."
echo "Resource Group: $RESOURCE_GROUP"
echo "Location: $LOCATION"

# Login to Azure (uncomment if needed)
# az login

# Create resource group
echo "Creating resource group..."
az group create \
    --name $RESOURCE_GROUP \
    --location $LOCATION

# Create storage account
echo "Creating storage account..."
az storage account create \
    --resource-group $RESOURCE_GROUP \
    --name $STORAGE_ACCOUNT \
    --location $LOCATION \
    --sku Standard_LRS

# Create virtual network
echo "Creating virtual network..."
az network vnet create \
    --resource-group $RESOURCE_GROUP \
    --name "${RESOURCE_GROUP}-vnet" \
    --address-prefix 10.0.0.0/16 \
    --subnet-name default \
    --subnet-prefix 10.0.1.0/24

# Create network security group
echo "Creating network security group..."
az network nsg create \
    --resource-group $RESOURCE_GROUP \
    --name "${VM_NAME}-nsg"

# Add RDP rule
az network nsg rule create \
    --resource-group $RESOURCE_GROUP \
    --nsg-name "${VM_NAME}-nsg" \
    --name RDP \
    --priority 1000 \
    --protocol Tcp \
    --destination-port-ranges 3389 \
    --access Allow

# Create public IP
echo "Creating public IP..."
az network public-ip create \
    --resource-group $RESOURCE_GROUP \
    --name "${VM_NAME}-pip" \
    --allocation-method Static \
    --sku Standard

# Create network interface
echo "Creating network interface..."
az network nic create \
    --resource-group $RESOURCE_GROUP \
    --name "${VM_NAME}-nic" \
    --vnet-name "${RESOURCE_GROUP}-vnet" \
    --subnet default \
    --public-ip-address "${VM_NAME}-pip" \
    --network-security-group "${VM_NAME}-nsg"

# Create virtual machine
echo "Creating virtual machine..."
az vm create \
    --resource-group $RESOURCE_GROUP \
    --name $VM_NAME \
    --image Win2022Datacenter \
    --size Standard_B2s \
    --admin-username azureadmin \
    --admin-password "YourSecurePassword123!" \
    --nics "${VM_NAME}-nic"

echo "Resources provisioned successfully!"
echo "VM Public IP: $(az vm show -d -g $RESOURCE_GROUP -n $VM_NAME --query publicIps -o tsv)"


















