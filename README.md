# ARM Template for Virtual Network Deployment

This ARM template deploys a virtual network with multiple subnets and a route table. The virtual network address space must be /20 and include a slash 20 at the end. The resource group must be created prior to deployment, and the default context should be set.

## Parameters

- **location**: The location of the resources. Defaults to the resource group's location.
- **tags**: Tags to be applied to all resources.
- **resourcePrefix**: Prefix to be appended to all resource names.
- **virtualNetworksAddress**: The address space of the virtual network. Must be /20 and include a slash 20 at the end.

## Variables

- **virtualNetworksName**: Name of the virtual network.
- **DefaultRouteTableName**: Name of the default route table.
- **FirewallExternalSubnet**: Address prefix for the firewall external subnet.
- **FirewallExternalInterfaceIP**: IP address for the firewall external interface.
- **FirewallInternalSubnet**: Address prefix for the firewall internal subnet.
- **FirewallInternalInterfaceIP**: IP address for the firewall internal interface.
- **ServerSubnet1**: Address prefix for the first server subnet.
- **ServerSubnet2**: Address prefix for the second server subnet.
- **VirtualDesktopSubnet1**: Address prefix for the virtual desktop subnet.
- **TestAndDevSubnet1**: Address prefix for the test and development subnet.
- **BackupApplianceSubnet1**: Address prefix for the backup appliance subnet.

## Resources

- **Microsoft.Network/routeTables**: Creates a route table with routes for internet, internal networks, and firewall subnets.
- **Microsoft.Network/virtualNetworks**: Creates a virtual network with specified subnets and applies the route table.

## Outputs

- **virtualNetworksAddress**: The address space of the virtual network.
- **FirewallExternalSubnet**: The address prefix for the firewall external subnet.
- **FirewallExternalInterfaceIP**: The IP address for the firewall external interface.
- **FirewallInternalSubnet**: The address prefix for the firewall internal subnet.
- **FirewallInternalInterfaceIP**: The IP address for the firewall internal interface.
- **ServerSubnet1**: The address prefix for the first server subnet.
- **ServerSubnet2**: The address prefix for the second server subnet.
- **VirtualDesktopSubnet1**: The address prefix for the virtual desktop subnet.
- **TestAndDevSubnet1**: The address prefix for the test and development subnet.
- **BackupApplianceSubnet1**: The address prefix for the backup appliance subnet.

## Deployment

To deploy this template using PowerShell, use the following command:

```powershell
New-AzResourceGroupDeployment -ResourceGroupName <ResourceGroupName> -TemplateUri <LinkToTemplateFile> -resourcePrefix <ResourcePrefix> -virtualNetworksAddress <VirtualNetworksAddress>
```

Replace `<ResourceGroupName>`, `<LinkToTemplateFile>`, `<ResourcePrefix>`, and `<VirtualNetworksAddress>` with appropriate values.

**Note**: The region will match the resource group region by default. If the region must be different from the resource group, it can be overridden with the `location` parameter.
