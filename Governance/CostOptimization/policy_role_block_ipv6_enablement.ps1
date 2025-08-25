# Replace <custom-role-name> with your desired role name
# Replace <subscription-id> with your subscription ID
$roleName = "<custom-role-name>"
$subscriptionId = "<subscription-id>"

# Create the custom role JSON definition
$roleDefinition = '{
  "Name": "' + $roleName + '",
  "IsCustom": true,
  "Description": "Custom role to block enabling Private IPv6 addresses on virtual machines",
  "Actions": [
    "Microsoft.Compute/virtualMachines/write",
    "Microsoft.Network/networkInterfaces/write"
  ],
  "NotActions": [
    "Microsoft.Compute/virtualMachines/networkInterfaces/ipv6Addresses/write"
  ],
  "AssignableScopes": ["/subscriptions/' + $subscriptionId + '"]
}'

# Create the custom role
New-AzRoleDefinition -InputObject $roleDefinition
