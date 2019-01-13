# To select a default subscription for your current session
Get-AzureRmSubscription -SubscriptionId “84415d2c-ea78-4653-a57c-504d3966c730” | Select-AzureRmSubscription

# Variables    
## Global
$ResourceGroupName = "ResourceGroup"
$Location = "CentralEurope"

## Storage
$StorageName = "GeneralStorage"
$StorageType = "Standard_GRS"    # Standard_LRS, Standard_ZRS, Standard_GRS, Standard_RAGRS, Premium_LRS

## Network
$InterfaceName = "NetworkInterface"
$Subnet1Name = "FrontEnd"
$Subnet2Name = "BackEnd"
$VNetName = "VNet"
$VNetAddressPrefix = "10.0.0.0/16"
$VNetSubnet1AddressPrefix = "10.0.1.0/24"
$VNetSubnet2AddressPrefix = "10.0.2.0/24"

## Compute
$VMName = "HDC-SRV-1"
$ComputerName = "Server1"
$VMSize = "Standard_A2"
$OSDiskName = $VMName + "_OSDisk"

# Resource Group
New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location -ErrorAction SilentlyContinue

# Storage
$StorageAccount = New-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageName -Type $StorageType -Location $Location -ErrorAction SilentlyContinue 

# Network
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod Dynamic
$SubnetConfig | New-AzureRmVirtualNetworkSubnetConfig -Name $Subnet1Name -AddressPrefix $VNetSubnetAddressPrefix
$SubnetConfig | New-AzureRmVirtualNetworkSubnetConfig -Name $Subnet2Name -AddressPrefix $VNetSubnetAddressPrefix
$VNet = New-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $ResourceGroupName -Location $Location -AddressPrefix $VNetAddressPrefix -Subnet $SubnetConfig
$Interface = New-AzureRmNetworkInterface -Name $InterfaceName -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[0].Id -PublicIpAddressId $PIp.Id

# Compute

## Setup local VM object
$Credential = Get-Credential
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $ComputerName -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
$VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2012-R2-Datacenter -Version "latest"
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface.Id
$OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption FromImage

## Create the VM in Azure
New-AzureRmVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VirtualMachine