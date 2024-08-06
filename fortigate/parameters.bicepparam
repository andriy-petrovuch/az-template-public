using './template.bicep'

param resourcePrefix = ''
param location = resourceGroup().location
param virtualNetworksAddress = ''
param FirewallExternalSubnetName = 'FirewallExternalSubnet'
param FirewallInternalSubnetName = 'FirewallInternalSubnet'
param FirewallExternalSubnet = ''
param FirewallInternalSubnet = ''
param FirewallExternalInterfaceIP = ''
param FirewallInternalInterfaceIP = ''
param adminUsername = ''
param adminPassword = ''
param fortiGateImageSKU = 'fortinet_fg-vm'
param fortiGateImageVersion = 'latest'
param instanceType = 'Standard_F2s'
param imagePublisher = 'fortinet'
param imageOffer = 'fortinet_fortigate-vm_v5'
param fortiManager = 'no'
param fortiManagerIP = ''
param fortiManagerSerial = ''
param fortiGateAdditionalCustomData = ''
param fortiGateLicenseFortiFlex = ''
param fortiGateLicenseBYOL = ''
param customImageReference = ''
