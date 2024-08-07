metadata author = 'Andriy Bodnar'
metadata about = '''This is a Bicep module template designed for nested deployments.
It references multiple other templates, allowing for a centralized management of 
parameters and logic.
The primary goal is to streamline the deployment process by maintaining parameters
in a single location and ensuring that dependencies between templates are
handled efficiently'''

@description('''Inherit the location from the resource group.
If needed, this can be overridden to specify a different location.''')
param location string = resourceGroup().location

@description('Define resource tags. Set to an empty object {} to apply no tags.')
param tags object = {
  // DeploymentMethod : 'IaC / ARM template'
}

@description('''A prefix for a naming convention.
Example:
- For Miles IT tenant, resource prefix might be something like 'mit'.
- For Sunny Days, resource prefix might be something like 'sd'
''')
param resourcePrefix string = 'mit'

@description('''The CIDR address space for the virtual network.
Must be a /20 subnet''')
param vNetAddressSpace string = '172.20.128.0/20'

@description('Controls the deployment of the Fortigate NVA Firewall.')
@allowed(['yes','no'])
param deployNvaFirewall string = 'no'

module virtualNetwork 'virtualNetwork/template.bicep' = {
  name: '${deployment().name}-virtualNetwork'
  params: {
    resourcePrefix: resourcePrefix
    location: location
    vNetAddressSpace: vNetAddressSpace
    deployNvaFirewallSubnets: deployNvaFirewall
    tags: tags
  }
}

output virtualNetwork string = virtualNetwork.outputs.networkSize
