metadata author = 'Andriy Bodnar'
metadata about = '''This template creates a virtual network in an Azure environment.
The address prefix must be 20 for the template to create the network.
The standard subnets include: ServerSubnet, VirtualDesktopSubnet, TestAndDevSubnet, and BackupApplianceSubnet.
Additionally, a NAT Gateway and 'GatewaySubnet' are included unless
the 'deployNvaFirewallSubnets' parameter is set to 'yes'. In that case,
the 'FirewallExternalSubnet' and 'FirewallInternalSubnet' are created instead, specifically for the Virtual Network Appliance firewall use.
Please note, this template does not include any firewalls, nsg or route tables.'''


@description('Defines key-value pairs for tagging resources deployed with this template')
param tags object = {
  DeploymentMethod : 'IaC / ARM template'
}

@description('Inherits the location from the resource group where the deployment is taking place.')
param location string = resourceGroup().location

@description('''Specifies whether to deploy subnets for an NVA firewall.
If set to "no", a GatewaySubnet and a NAT Gateway will be created and associated with all subnets except the GatewaySubnet.
If set to "yes", subnets for internal and external NVA firewall interfaces will be created.''')
@allowed(['yes','no'])
param deployNvaFirewallSubnets string = 'no'

@description('''The CIDR address space for the virtual network.
This parameter also determines if the network will be deployed based on a conditional check later.''')
param vNetAddressSpace string

@description('A prefix for resources created by this template')
param resourcePrefix string

@description('A suffix to be appended to the virtual network name')
param vNetNameSuffix string = 'vNet01'

@description('A suffix to be appended to the NAT gateway name ')
param natGwyNameSuffix string = 'natGwy01'

@description('A suffix to be appended to the NAT gateway public IP address name')
param natGwyIPNameSuffix string = 'natGwy01-ip'

@description('''Defines names for each subnet within the virtual network.
These names are referenced later to build subnet configurations.
To expand the subnet configuration,
append new subnets to this list AND modify the Arrays of Subnet Definitions variables to assign IP address blocks.
- FirewallExternalSubnetName: Subnet for external interface of NVA firewall.
- FirewallInternalSubnetName: Subnet for internal interface of NVA firewall.
- GatewaySubnetName: Subnet for the Azure virtual network gateway (if NAT gateway is not deployed). Name must be: GatewaySubnet
- ServerSubnetName: Subnet for deploying servers within the virtual network.
- VirtualDesktopSubnetName: Subnet for deploying virtual desktops within the virtual network.
- TestAndDevSubnetName: Subnet for deploying test and development environments within the virtual network.
- BackupApplianceSubnetName: Subnet for deploying backup appliances within the virtual network.
''')
param subnetNames object = {
  FirewallExternalSubnetName: 'FirewallExternalSubnet'
  FirewallInternalSubnetName: 'FirewallInternalSubnet'
  GatewaySubnetName: 'GatewaySubnet'
  ServerSubnetName: 'ServerSubnet01'
  VirtualDesktopSubnetName: 'VirtualDesktopSubnet01'
  TestAndDevSubneName: 'TestAndDevSubnet01'
  BackupApplianceSubnetName: 'BackupApplianceSubnet01'
}

@description('''A string representing the CIDR block size of the vNetAddressSpace parameter,
used to verify if the vNet is suitable for deployment
requires a 20-bit subnet
value is used for conditional checks later in the code.''')
var vNetSize = split(vNetAddressSpace, '/')[1]
var networkSizeCheck = vNetSize == '20' ? vNetAddressSpace : 'Network Address Space is not 20. No network to deploy with this template!'

@description('A string representing the full name of the virtual network, constructed from resourcePrefix, location, and vNetNameSuffix.')
var vNetName = '${resourcePrefix}-${location}-${vNetNameSuffix}'

@description('A string representing the full name of the NAT gateway, constructed from resourcePrefix, location, and natGwyNameSuffix.')
var natGwyName = '${resourcePrefix}-${location}-${natGwyNameSuffix}'

@description('A string representing the full name of the NAT gateway public IP, constructed from resourcePrefix, location, and natGwyIPNameSuffix.')
var natGwyIPName = '${resourcePrefix}-${location}-${natGwyIPNameSuffix}'

@description('An array of strings representing the first three octets of the vNetAddressSpace.')
var octets = take(split(vNetAddressSpace, '.'), 3)

@description('''Arrays of Subnet Definitions
- BaseSubnets: 
These subnets are always deployed.
An array of objects, each representing a subnet configuration. 
Includes name and subnetPrefix properties.

- NvaFirewallSubnets:
These subnets are deployed only if deployNvaFirewallSubnets is 'yes'.
An array of objects, each representing a subnet configuration for an NVA firewall.
Includes name and subnetPrefix properties.

- GatewaySubnets:
 This subnet is deployed only if deployNvaFirewallSubnets is 'no'.
An array of objects, each representing a subnet configuration for the gateway.
Includes name and subnetPrefix properties.

- subnets: 
An array of objects, combining BaseSubnets with either NvaFirewallSubnets or GatewaySubnets based on the deployNvaFirewallSubnets parameter.''')
var BaseSubnets = [
  {
    name: subnetNames.ServerSubnetName
    subnetPrefix: '${octets[0]}.${octets[1]}.${int(octets[2]) + 3}.0/24'
  }
  {
    name: subnetNames.VirtualDesktopSubnetName
    subnetPrefix: '${octets[0]}.${octets[1]}.${int(octets[2]) + 8}.0/24'
  }
  {
    name: subnetNames.TestAndDevSubneName
    subnetPrefix: '${octets[0]}.${octets[1]}.${int(octets[2]) + 12}.0/24'
  }
  {
    name: subnetNames.BackupApplianceSubnetName
    subnetPrefix: '${octets[0]}.${octets[1]}.${int(octets[2]) + 14}.0/24'
  }
]
var NvaFirewallSubnets = [
  {
    name: subnetNames.FirewallExternalSubnetName
    subnetPrefix: '${octets[0]}.${octets[1]}.${int(octets[2]) + 1}.64/26'
  }
  {
    name: subnetNames.FirewallInternalSubnetName
    subnetPrefix: '${octets[0]}.${octets[1]}.${int(octets[2]) + 1}.128/26'
  }
]
var GatewaySubnet = [
  {
    name: subnetNames.GatewaySubnetName
    subnetPrefix: '${octets[0]}.${octets[1]}.${int(octets[2]) + 1}.128/26'
  }
]
var subnets = (deployNvaFirewallSubnets == 'yes')
  ? concat(BaseSubnets, NvaFirewallSubnets)
  : concat(BaseSubnets, GatewaySubnet)

@description('''Creates a static public IP address resource for the NAT gateway.
This resource is deployed only when deployNvaFirewallSubnets is 'no' and the vNet size is 20.''')
  resource natGwyIP 'Microsoft.Network/publicIPAddresses@2024-01-01' = if ((deployNvaFirewallSubnets == 'no') && (vNetSize == '20')) {
  name: natGwyIPName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

@description('''Creates a NAT gateway to enable outbound internet connectivity in the virtual network.
This resource is deployed only when deployNvaFirewallSubnets is 'no' and the vNet size is 20.''')
resource natGwy 'Microsoft.Network/natGateways@2024-01-01' = if ((deployNvaFirewallSubnets == 'no') && (vNetSize == '20')) {
  name: natGwyName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIpAddresses: [ {id: natGwyIP.id} ]
  }
}

@description(''' Creates a virtual network with the specified address space, subnets, and optional NAT gateway configuration.
The subnets and NAT gateway configuration are determined by the deployNvaFirewallSubnets parameter.''')
resource vNet 'Microsoft.Network/virtualNetworks@2024-01-01' = if (vNetSize == '20') {
  name: vNetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vNetAddressSpace
      ]
    }
    subnets: [for subnet in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.subnetPrefix
        natGateway: (deployNvaFirewallSubnets == 'no') 
          ? (subnet.name != 'GatewaySubnet') 
            ? { id:natGwy.id }
            : null
          : null
        }
      }  
    ]
  }
}

@description('''Output either the original vNet address space or
a message indicating the network size is not supported for deployment.''')
output networkSize string = networkSizeCheck
