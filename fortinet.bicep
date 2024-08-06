@description('Prefix to be appended to all resource names')
param resourcePrefix string

@description('Location for all resources')
param location string = resourceGroup().location

@description('The address space of the virtual network must be /20 and include a slash 20 at the end.')
param virtualNetworksAddress string

@description('Firewall External Subnet name')
param FirewallExternalSubnetName string = 'FirewallExternalSubnet'

@description('Firewall Internal Subnet name')
param FirewallInternalSubnetName string = 'FirewallInternalSubnet'

@description('Firewall External Subnet Address')
param FirewallExternalSubnet string

@description('Firewall Internal Subnet Address')
param FirewallInternalSubnet string

@description('Firewall External Interface IP address')
param FirewallExternalInterfaceIP string

@description('Firewall Internal Interface IP address')
param FirewallInternalInterfaceIP string

@description('Username for the FortiGate VM')
param adminUsername string

@description('Password for the FortiGate VM')
@secure()
param adminPassword string

@description('Identifies whether to to use PAYG (on demand licensing) or BYOL license model (where license is purchased separately.')
@allowed([
  'fortinet_fg-vm'
  'fortinet_fg-vm_payg_2023'
])
param fortiGateImageSKU string = 'fortinet_fg-vm'

@description('Select the image version')
@allowed([
  '6.4.15'
  '7.0.15'
  '7.0.14'
  '7.2.8'
  '7.2.7'
  '7.4.4'
  '7.4.3'
  '7.6.0'
  'latest'
])
param fortiGateImageVersion string = 'latest'

@description('Virtual Machine size selection - must be F4 or other instance that supports 4 NICs')
@allowed([
  'Standard_F2s'
  'Standard_F4s'
  'Standard_F8s'
  'Standard_F16s'
  'Standard_F2'
  'Standard_F4'
  'Standard_F8'
  'Standard_F16'
  'Standard_F2s_v2'
  'Standard_F4s_v2'
  'Standard_F8s_v2'
  'Standard_F16s_v2'
  'Standard_F32s_v2'
  'Standard_DS1_v2'
  'Standard_DS2_v2'
  'Standard_DS3_v2'
  'Standard_DS4_v2'
  'Standard_DS5_v2'
  'Standard_D2s_v3'
  'Standard_D4s_v3'
  'Standard_D8s_v3'
  'Standard_D16s_v3'
  'Standard_D32s_v3'
  'Standard_D2_v4'
  'Standard_D4_v4'
  'Standard_D8_v4'
  'Standard_D16_v4'
  'Standard_D32_v4'
  'Standard_D2s_v4'
  'Standard_D4s_v4'
  'Standard_D8s_v4'
  'Standard_D16s_v4'
  'Standard_D32s_v4'
  'Standard_D2a_v4'
  'Standard_D4a_v4'
  'Standard_D8a_v4'
  'Standard_D16a_v4'
  'Standard_D32a_v4'
  'Standard_D2as_v4'
  'Standard_D4as_v4'
  'Standard_D8as_v4'
  'Standard_D16as_v4'
  'Standard_D32as_v4'
  'Standard_D2_v5'
  'Standard_D4_v5'
  'Standard_D8_v5'
  'Standard_D16_v5'
  'Standard_D32_v5'
  'Standard_D2s_v5'
  'Standard_D4s_v5'
  'Standard_D8s_v5'
  'Standard_D16s_v5'
  'Standard_D32s_v5'
  'Standard_D2as_v5'
  'Standard_D4as_v5'
  'Standard_D8as_v5'
  'Standard_D16as_v5'
  'Standard_D32as_v5'
  'Standard_D2ads_v5'
  'Standard_D4ads_v5'
  'Standard_D8ads_v5'
  'Standard_D16ads_v5'
  'Standard_D32ads_v5'
  'Standard_D2ps_v5'
  'Standard_D4ps_v5'
  'Standard_D8ps_v5'
  'Standard_D16ps_v5'
  'Standard_D32ps_v5'
  'Standard_D2pds_v5'
  'Standard_D4pds_v5'
  'Standard_D8pds_v5'
  'Standard_D16pds_v5'
  'Standard_D32pds_v5'
  'Standard_D2pls_v5'
  'Standard_D4pls_v5'
  'Standard_D8pls_v5'
  'Standard_D16pls_v5'
  'Standard_D32pls_v5'
  'Standard_D2plds_v5'
  'Standard_D4plds_v5'
  'Standard_D8plds_v5'
  'Standard_D16plds_v5'
  'Standard_D32plds_v5'
  'Standard_E2ps_v5'
  'Standard_E4ps_v5'
  'Standard_E8ps_v5'
  'Standard_E16ps_v5'
  'Standard_E32ps_v5'
  'Standard_E2pds_v5'
  'Standard_E4pds_v5'
  'Standard_E8pds_v5'
  'Standard_E16pds_v5'
  'Standard_E32pds_v5'
])
param instanceType string = 'Standard_F2s'

param imagePublisher string = 'fortinet'

param imageOffer string = 'fortinet_fortigate-vm_v5'

@description('Connect to FortiManager')
@allowed([
  'yes'
  'no'
])
param fortiManager string = 'no'

@description('FortiManager IP or DNS name to connect to on port TCP/541')
param fortiManagerIP string = ''

@description('FortiManager serial number to add the deployed FortiGate into the FortiManager')
param fortiManagerSerial string = ''

@description('The ARM template provides a basic configuration. Additional configuration can be added here.')
param fortiGateAdditionalCustomData string = ''

@description('FortiGate BYOL FortiFlex license token')
param fortiGateLicenseFortiFlex string = ''

@description('FortiGate BYOL license content')
param fortiGateLicenseBYOL string = ''

@description('By default, the deployment will use Azure Marketplace images. In specific cases, using BYOL custom FortiGate images can be deployed. This requires a reference ')
param customImageReference string = ''

var imageReferenceCustomImage = {
  id: customImageReference
}
var imageReferenceMarketplace = {
  publisher: imagePublisher
  offer: imageOffer
  sku: fortiGateImageSKU
  version: fortiGateImageVersion
}
var virtualMachinePlan = {
  name: fortiGateImageSKU
  publisher: imagePublisher
  product: imageOffer
}
var sn1IPArray = split(FirewallExternalSubnet, '.')
var sn1IPArray2ndString = string(sn1IPArray[3])
var sn1IPArray2nd = split(sn1IPArray2ndString, '/')
var sn1IPArray3 = string((int(sn1IPArray2nd[0]) + 1))
var sn1IPArray2 = string(int(sn1IPArray[2]))
var sn1IPArray1 = string(int(sn1IPArray[1]))
var sn1IPArray0 = string(int(sn1IPArray[0]))
var sn1GatewayIP = '${sn1IPArray0}.${sn1IPArray1}.${sn1IPArray2}.${sn1IPArray3}'
var sn2IPArray = split(FirewallInternalSubnet, '.')
var sn2IPArray2ndString = string(sn2IPArray[3])
var sn2IPArray2nd = split(sn2IPArray2ndString, '/')
var sn2IPArray3 = string((int(sn2IPArray2nd[0]) + 1))
var sn2IPArray2 = string(int(sn2IPArray[2]))
var sn2IPArray1 = string(int(sn2IPArray[1]))
var sn2IPArray0 = string(int(sn2IPArray[0]))
var sn2GatewayIP = '${sn2IPArray0}.${sn2IPArray1}.${sn2IPArray2}.${sn2IPArray3}'

var fmgCustomData = ((fortiManager == 'yes')
  ? '\nconfig system central-management\nset type fortimanager\n set fmg ${fortiManagerIP}\nset serial-number ${fortiManagerSerial}\nend\n config system interface\n edit port1\n append allowaccess fgfm\n end\n config system interface\n edit port2\n append allowaccess fgfm\n end\n'
  : '')
var customDataHeader = 'Content-Type: multipart/mixed; boundary="12345"\nMIME-Version: 1.0\n\n--12345\nContent-Type: text/plain; charset="us-ascii"\nMIME-Version: 1.0\nContent-Transfer-Encoding: 7bit\nContent-Disposition: attachment; filename="config"\n\n'
var customDataBody = 'config system global\nset hostname ${fgtVmName}\nend\nconfig system sdn-connector\nedit AzureSDN\nset type azure\nnext\nend\nconfig router static\nedit 1\nset gateway ${sn1GatewayIP}\nset device port1\nnext\nedit 2\nset dst ${virtualNetworksAddress}\nset gateway ${sn2GatewayIP}\nset device port2\nnext\nend\nconfig system interface\nedit port1\nset mode static\nset ip ${FirewallExternalInterfaceIP}/26\nset description external\nset allowaccess ping ssh https\nnext\nedit port2\nset mode static\nset ip ${FirewallInternalInterfaceIP}/26\nset description internal\nset allowaccess ping ssh https\nnext\nend\n${fmgCustomData}${fortiGateAdditionalCustomData}\n'
var customDataLicenseHeader = '--12345\nContent-Type: text/plain; charset="us-ascii"\nMIME-Version: 1.0\nContent-Transfer-Encoding: 7bit\nContent-Disposition: attachment; filename="license"\n\n'
var customDataFooter = '\n--12345--\n'
var customDataFortiFlex = ((fortiGateLicenseFortiFlex == '') ? '' : 'LICENSE-TOKEN:${fortiGateLicenseFortiFlex}\n')
var customDataCombined = '${customDataHeader}${customDataBody}${customDataLicenseHeader}${customDataFortiFlex}${fortiGateLicenseBYOL}${customDataFooter }'
var fgtCustomData = base64((((fortiGateLicenseBYOL == '') && (fortiGateLicenseFortiFlex == ''))
  ? customDataBody
  : customDataCombined))

@description('vNET name')
var virtualNetworksName = '${resourcePrefix}-${location}-vNET-01'

@description('NSG name applied to FirewallExternalInterface')
var nsgname = '${resourcePrefix}-${location}-FirewallExternalInterface-nsg1'

@description('Public IP name applied to FirewallExternalInterface')
var publiIPname = '${resourcePrefix}-${location}-FirewallExternalInterface-publicIP1'

@description('NIC name applied to FirewallExternalInterface')
var nic1Name = '${resourcePrefix}-${location}-FirewallExternalInterface-privateIP1'

@description('NIC name applied to FirewallInternalInterface')
var nic2Name = '${resourcePrefix}-${location}-FirewallInternalInterface-privateIP1'

@description('FortiGate Azure VM name')
var fgtVmName = '${resourcePrefix}-${location}-Firewall1'

@description('Net Security Group, that applies to External Firewall Interface')
resource nsg 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
  name: nsgname
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowAllInbound'
        properties: {
          description: 'Allow all in'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: FirewallExternalInterfaceIP
          access: 'Allow'
          priority: 1000
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowAllOutbound'
        properties: {
          description: 'Allow all out'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1000
          direction: 'Outbound'
        }
      }
    ]
  }
}

@description('Public IP, that assotiates to External Firewall Interface')
resource publicIP 'Microsoft.Network/publicIPAddresses@2024-01-01' = {
  name: publiIPname
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

@description('NIC1 as External interface on firewall')
resource nic1 'Microsoft.Network/networkInterfaces@2024-01-01' = {
  name: nic1Name
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: FirewallExternalInterfaceIP
          privateIPAllocationMethod: 'Static'
          publicIPAddress: {id:publicIP.id}
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets',virtualNetworksName,FirewallExternalSubnetName)
          }
        }
      }
    ]
    enableIPForwarding: true
    networkSecurityGroup: {
      id: nsg.id
    }
    enableAcceleratedNetworking: true
  }
}

@description('NIC2 as Internal interface on firewall')
resource nic2 'Microsoft.Network/networkInterfaces@2024-01-01' = {
  name: nic2Name
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: FirewallInternalInterfaceIP
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets',virtualNetworksName,FirewallInternalSubnetName)
          }
        }
      }
    ]
    enableIPForwarding: true
    enableAcceleratedNetworking: true
  }
}

@description('FortiGate VM')
resource fgtVM 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: fgtVmName
  location: location
  plan: virtualMachinePlan
  properties: {
    hardwareProfile: {
      vmSize: instanceType
    }
    osProfile: {
      computerName: fgtVmName
      adminUsername: adminUsername
      adminPassword: adminPassword
      customData: fgtCustomData
    }
    storageProfile: {
      imageReference: (((fortiGateImageSKU == 'fortinet_fg-vm') && (customImageReference != ''))
      ? imageReferenceCustomImage
      : imageReferenceMarketplace)
      osDisk: {
        createOption: 'FromImage'
      }
      dataDisks: [
        {
          diskSizeGB: 30
          lun: 0
          createOption: 'Empty'
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          properties: {
            primary: true
          }
          id: nic1.id
        }
        {
          properties: {
            primary: false
          }
          id: nic2.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}
