# Select a subscription
Select-AzureRmSubscription -SubscriptionName "Replace_with_your_subscription_name"

# Define the Azure region
$region = 'centralus'

# Create a new resource group for the vnet to belong to, otherwise select an existing resource group
$resourcegroup = 'group1'
New-AzureRmResourceGroup -Name $resourcegroup -Location $region

# Create the vnet
$vnetname = 'vnet1'
New-AzureRmVirtualNetwork -ResourceGroupName $resourcegroup -Name $vnetname -AddressPrefix 10.0.0.0/16 -Location $region

# Store vnet in a var
$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $resourcegroup -Name $vnetname

# Add Subnets
Add-AzureRmVirtualNetworkSubnetConfig -Name 'FrontEnd' -VirtualNetwork $vnet -AddressPrefix 10.0.1.0/24
Add-AzureRmVirtualNetworkSubnetConfig -Name 'BackEnd' -VirtualNetwork $vnet -AddressPrefix 10.0.2.0/24

# Add DNS Servers
$vnet.DhcpOptions.DnsServers = "10.0.0.10"
$vnet.DhcpOptions.DnsServers += "10.0.0.11" 

# Push changes to Azure
Set-AzureRmVirtualNetwork -VirtualNetwork $vnet