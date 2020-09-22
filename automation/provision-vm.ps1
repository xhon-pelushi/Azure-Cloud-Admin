# Azure VM Provisioning Script
# Automates virtual machine deployment

param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory=$true)]
    [string]$VMName,
    
    [Parameter(Mandatory=$false)]
    [string]$Location = "East US",
    
    [Parameter(Mandatory=$false)]
    [string]$VMSize = "Standard_B2s",
    
    [Parameter(Mandatory=$false)]
    [string]$ImagePublisher = "MicrosoftWindowsServer",
    
    [Parameter(Mandatory=$false)]
    [string]$ImageOffer = "WindowsServer",
    
    [Parameter(Mandatory=$false)]
    [string]$ImageSKU = "2022-Datacenter",
    
    [Parameter(Mandatory=$false)]
    [string]$AdminUsername = "azureadmin",
    
    [Parameter(Mandatory=$false)]
    [securestring]$AdminPassword,
    
    [Parameter(Mandatory=$false)]
    [string]$VNetName,
    
    [Parameter(Mandatory=$false)]
    [string]$SubnetName = "default"
)

# Connect to Azure
Connect-AzAccount -ErrorAction Stop

Write-Host "Provisioning Azure VM..." -ForegroundColor Green
Write-Host "Resource Group: $ResourceGroupName" -ForegroundColor Cyan
Write-Host "VM Name: $VMName" -ForegroundColor Cyan
Write-Host "Location: $Location" -ForegroundColor Cyan

# Generate password if not provided
if (-not $AdminPassword) {
    $AdminPassword = Read-Host -AsSecureString "Enter admin password"
}

# Create resource group if it doesn't exist
$ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
if (-not $ResourceGroup) {
    Write-Host "Creating resource group: $ResourceGroupName" -ForegroundColor Yellow
    New-AzResourceGroup -Name $ResourceGroupName -Location $Location
}

# Create virtual network if not provided
if (-not $VNetName) {
    $VNetName = "${ResourceGroupName}-vnet"
    $SubnetName = "default"
    
    $VNet = Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VNetName -ErrorAction SilentlyContinue
    if (-not $VNet) {
        Write-Host "Creating virtual network: $VNetName" -ForegroundColor Yellow
        
        $Subnet = New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix "10.0.1.0/24"
        $VNet = New-AzVirtualNetwork `
            -ResourceGroupName $ResourceGroupName `
            -Location $Location `
            -Name $VNetName `
            -AddressPrefix "10.0.0.0/16" `
            -Subnet $Subnet
    }
}

# Get subnet
$VNet = Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VNetName
$Subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $VNet -Name $SubnetName

# Create public IP
$PublicIPName = "${VMName}-pip"
Write-Host "Creating public IP: $PublicIPName" -ForegroundColor Yellow
$PublicIP = New-AzPublicIpAddress `
    -ResourceGroupName $ResourceGroupName `
    -Location $Location `
    -Name $PublicIPName `
    -AllocationMethod Static `
    -Sku Standard

# Create network security group
$NSGName = "${VMName}-nsg"
Write-Host "Creating NSG: $NSGName" -ForegroundColor Yellow
$NSG = New-AzNetworkSecurityGroup `
    -ResourceGroupName $ResourceGroupName `
    -Location $Location `
    -Name $NSGName

# Add RDP rule
$RDPRule = New-AzNetworkSecurityRuleConfig `
    -Name "RDP" `
    -Protocol Tcp `
    -Direction Inbound `
    -Priority 1000 `
    -SourceAddressPrefix * `
    -SourcePortRange * `
    -DestinationAddressPrefix * `
    -DestinationPortRange 3389 `
    -Access Allow

$NSG.SecurityRules.Add($RDPRule)
$NSG | Set-AzNetworkSecurityGroup

# Create network interface
$NICName = "${VMName}-nic"
Write-Host "Creating NIC: $NICName" -ForegroundColor Yellow
$NIC = New-AzNetworkInterface `
    -ResourceGroupName $ResourceGroupName `
    -Location $Location `
    -Name $NICName `
    -SubnetId $Subnet.Id `
    -PublicIpAddressId $PublicIP.Id `
    -NetworkSecurityGroupId $NSG.Id

# Create VM configuration
Write-Host "Creating VM configuration..." -ForegroundColor Yellow
$VMConfig = New-AzVMConfig -VMName $VMName -VMSize $VMSize

# Set operating system
$Credential = New-Object System.Management.Automation.PSCredential ($AdminUsername, $AdminPassword)
$VMConfig = Set-AzVMOperatingSystem `
    -VM $VMConfig `
    -Windows `
    -ComputerName $VMName `
    -Credential $Credential `
    -ProvisionVMAgent `
    -EnableAutoUpdate

# Set image
$VMConfig = Set-AzVMSourceImage `
    -VM $VMConfig `
    -PublisherName $ImagePublisher `
    -Offer $ImageOffer `
    -Skus $ImageSKU `
    -Version "latest"

# Attach NIC
$VMConfig = Add-AzVMNetworkInterface -VM $VMConfig -Id $NIC.Id

# Create VM
Write-Host "Creating VM: $VMName" -ForegroundColor Yellow
New-AzVM `
    -ResourceGroupName $ResourceGroupName `
    -Location $Location `
    -VM $VMConfig

Write-Host "VM provisioned successfully!" -ForegroundColor Green
Write-Host "Public IP: $($PublicIP.IpAddress)" -ForegroundColor Cyan




























