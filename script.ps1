# vNet template URL
$templateUriVnet = "https://raw.githubusercontent.com/andriy-petrovuch/az-template-public/main/vNet/template.json"
$templateUriFortigate = "https://raw.githubusercontent.com/fortinet/azure-templates/main/FortiGate/A-Single-VM/azuredeploy.json"

# Fortigate base config 
$confUrl = "https://raw.githubusercontent.com/andriy-petrovuch/az-template-public/main/fortigate/firewalBaseConfig.txt"
$fortiGateAdditionalCustomData = (Invoke-WebRequest -Uri $confUrl).Content

# Function to check if resourcePrefix is not empty
function Validate-Resource {
    param (
        [string]$resource
    )
    if ([string]::IsNullOrWhiteSpace($resource)) {
        Write-Host "Resource cannot be empty."
        return $false
    } else {
        return $true
    }
}

# Function to validate virtual network address space
function Validate-VirtualNetworkAddress {
    param (
        [string]$address
    )
    if ($address -match "^([0-9]{1,3}\.){2}(0|16|32|48|64|80|96|112|128|144|160|176|192|208|224|240)\.0/20$") {
        $octets = $address -split '[./]'
        $firstOctet = [int]$octets[0]
        $secondOctet = [int]$octets[1]

        # Check if the address is within private IP ranges
        if (($firstOctet -eq 10) -or
            ($firstOctet -eq 172 -and $secondOctet -ge 16 -and $secondOctet -le 31) -or
            ($firstOctet -eq 192 -and $secondOctet -eq 168)) {
            return $true
        } else {
            Write-Host "The address is not within a private IP range."
            return $false
        }
    } else {
        Write-Host "Invalid address space. It must be in the format x.x.x.x/20 with the third octet being a multiple of 16 and the fourth octet being 0."
        return $false
    }
}

# Function to validate admin password
function Validate-AdminPassword {
    param (
        [string]$password
    )
    $disallowedPasswords = @("abc@123", "P@`$`$w0rd", "P@ssw0rd", "P@ssword123", "Pa`$`$word", "pass@word1", "Password!", "Password1", "Password22", "iloveyou!")
    if ($password.Length -ge 16 -and $password.Length -le 72 -and $password -notin $disallowedPasswords) {
        $conditionsMet = 0
        if ($password -match "[a-z]") { $conditionsMet++ }
        if ($password -match "[A-Z]") { $conditionsMet++ }
        if ($password -match "[0-9]") { $conditionsMet++ }
        if ($password -match "[\W_]") { $conditionsMet++ }
        if ($conditionsMet -ge 3) {
            return $true
        }
    }
    Write-Host "Invalid password. Please ensure it meets the complexity requirements."
    return $false
}

# Prompt for inputs with validation
do {
    $RGName = Read-Host "Enter the resource group name for deployment. All resources will be deployed in this group and region."
} until (Validate-Resource -resource $RGName)

# Check if the resource group exists
if (-not (Get-AzResourceGroup -Name $RGName -ErrorAction SilentlyContinue)) {
    Write-Warning "Resource group '$RGName' not found. Script execution will stop until the resource group is discovered in this PowerShell session.”
    Write-Warning "Before executing this script, ENSURE that your PowerShell session is logged into Azure AND the default context is set."
    # Display instructions for installing the Azure module
    Write-Output "1. If you haven't installed the Azure module, use this command:"
    Write-Output "   Install-Module -Name Az -Repository PSGallery -Force" 
    # Display instructions for connecting to Azure
    Write-Output "2. Connect to your Azure account using the following command:"
    Write-Output "   Connect-AzAccount"
    # Display instructions for checking all subscriptions
    Write-Output "3. Check all available subscriptions with this command:"
    Write-Output "   Get-AzSubscription"
    # Display instructions for setting the default context
    Write-Output "4. Set the default context for your Azure subscription (use the subscription ID from the previous step) with this command:"
    Write-Output "   Set-AzContext -Subscription 'SubscriptionID'"
    # Display instructions for verifying the current context
    Write-Output "5. Verify the current context using this command:"
    Write-Output "   Get-AzContext"
    # Display instructions for creating a resource group
    Write-Output "6. To create a resource group in PowerShell, use this command:"
    Write-Output "   New-AzResourceGroup -Name 'ResourceGroupName' -Location 'EastUS'"

    exit
}

do {
    $resourcePrefix = Read-Host "Enter the resource prefix (Prefix to be appended to all resource names.)"
} until (Validate-Resource -resource $resourcePrefix)

do {
    $virtualNetworksAddress = Read-Host "Enter the virtual network address space (must be /20)"
} until (Validate-VirtualNetworkAddress -address $virtualNetworksAddress)

do {
    $FirewallApplianceInUse = Read-Host "Is the Fortigate appliance in use? (yes or no)"
} until ($FirewallApplianceInUse -eq "yes" -or $FirewallApplianceInUse -eq "no")

if ($FirewallApplianceInUse -eq "yes") {
    
    do {
        Write-Host "Select license model:"
        Write-Host "1. PAYG"
        Write-Host "2. BYOL"
        $selection = Read-Host "Enter 1 or 2"
    } while ($selection -notin 1, 2)
    switch ($selection) {
        1 { $fortiGateImageSKU = "fortinet_fg-vm_payg_2023" }
        2 { $fortiGateImageSKU = "fortinet_fg-vm" }
    }
    
    do {
        $adminPassword = Read-Host "Enter the admin password. (admin username is: miles)" -AsSecureString
        $plainText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($adminPassword))
    } until (Validate-AdminPassword -password $plainText)  
}
$plainText = ''


# Get the Azure context
$context = Get-AzContext

# Output the Resource Group name, Subscription Name, and Tenant ID
Write-Host "`nDeployment will take place in the following Resource Group: " -NoNewline
Write-Host $RGName -BackgroundColor Yellow -ForegroundColor Black
Write-Host "Subscription Name: " -NoNewline
Write-Host $($context.Subscription.Name) -BackgroundColor Yellow -ForegroundColor Black
Write-Host "Tenant ID: " -NoNewline
Write-Host $($context.Tenant.Id) -BackgroundColor Yellow -ForegroundColor Black

# Confirm the deployment
$confirmation = Read-Host -Prompt "`nDo you want to proceed with the deployment in the Resource Group `'$RGName`'? (yes/no)"
if ($confirmation -ne 'yes') {
    Write-Host "Deployment cancelled by the user." -ForegroundColor Red
    return
}

# Deploy the vNET template from URL
$deployment = New-AzResourceGroupDeployment -ResourceGroupName $RGName -TemplateUri $templateUriVnet -resourcePrefix $resourcePrefix -virtualNetworksAddress $virtualNetworksAddress -firewallApplianceInUse $FirewallApplianceInUse

# Convert outputs to PowerShell variables
$outputs = $deployment.Outputs
foreach ($key in $outputs.Keys) {
    Set-Variable -Name $key -Value $outputs[$key].Value
}


# Deploy the Fortigate template from URL
$fortigateParametrs = @{
    adminUsername = "miles"  # if username is modified, ensure to change that in the config system admin (see line 6)
    fortiGateNamePrefix = "$resourcePrefix-$((Get-AzResourceGroup -Name $RGName).Location)-Firewall1"
    fortiGateImageSKU = $fortiGateImageSKU
    fortiGateImageVersion = "latest"
    fortiGateAdditionalCustomData = $fortiGateAdditionalCustomData
    instanceType = "Standard_F2s"
    acceleratedNetworking = "true"
    publicIP1NewOrExisting = "new"
    publicIP1Name = "$resourcePrefix-$((Get-AzResourceGroup -Name $RGName).Location)-FirewallExternalInterface-publicIP1"
    publicIP1AddressType = "Static"
    publicIP1SKU = "Standard"
    vnetNewOrExisting = "existing"
    vnetName = "$resourcePrefix-$((Get-AzResourceGroup -Name $RGName).Location)-vNET-01"
    vnetResourceGroup = $RGName
    vnetAddressPrefix = $virtualNetworksAddress
    subnet1Name = "firewallExternalSubnet"
    subnet1Prefix = $firewallExternalSubnet
    subnet1StartAddress = $firewallExternalInterfaceIP
    subnet2Name = "firewallInternalSubnet"
    subnet2Prefix = $firewallInternalSubnet
    subnet2StartAddress = $firewallInternalInterfaceIP
    subnet3Name = "testAndDevSubnet1"
    subnet3Prefix = $testAndDevSubnet1
    serialConsole = "yes"
    fortiManager = "no"
    tagsByResource = @{
        DeploymentMethod = "IaC / ARM template"
    }
}

if ($FirewallApplianceInUse -eq "yes") {
    New-AzResourceGroupDeployment -ResourceGroupName $RGName -TemplateUri $templateUriFortigate -TemplateParameterObject $fortigateParametrs -adminPassword $adminPassword
}

