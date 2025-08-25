Connect-AzAccount 

$subs = get-azsubscription  -SubscriptionName wpi-corp

set-azcontext -Subscription wpi-corp

$adminmggroup = Get-AzManagementGroup -GroupName Admingroup
$notscope = Get-AzManagementGroup -GroupName tenantmanagementgroup
$tenantrootgrp =  Get-AzManagementGroup -GroupName  d06bc698-c2f2-495a-ab7a-a078237ea9ad

set-azcontext -Tenant $($subs.TenantId)

$policy = @" 
{
  "properties": {
    "displayName": "Not allowed resource types",
    "policyType": "BuiltIn",
    "mode": "All",
    "description": "Restrict which resource types can be deployed in your environment. Limiting resource types can reduce the complexity and attack surface of your environment while also helping to manage costs. Compliance results are only shown for non-compliant resources.",
    "metadata": {
      "version": "2.0.0",
      "category": "General"
    },
    "parameters": {
      "listOfResourceTypesNotAllowed": {
        "type": "Array",
        "metadata": {
          "description": "The list of resource types that cannot be deployed.",
          "displayName": "Not allowed resource types",
          "strongType": "resourceTypes"
        }
      },
      "effect": {
        "type": "String",
        "metadata": {
          "displayName": "Effect",
          "description": "Enable or disable the execution of the policy"
        },
        "allowedValues": [
          "Audit",
          "Deny",
          "Disabled"
        ],
        "defaultValue": "Deny"
      }
    },
    "policyRule": {
      "if": {
        "allOf": [
          {
            "field": "type",
            "in": "[parameters('listOfResourceTypesNotAllowed')]"
          },
          {
            "value": "[field('type')]",
            "exists": true
          }
        ]
      },
     "then": {
        "effect": "[parameters('effect')]"
      }
   },
  "id": "/providers/Microsoft.Authorization/policyDefinitions/6c112d4e-5bc7-47ae-a041-ea2d9dccd749",
  "type": "Microsoft.Authorization/policyDefinitions",
  "name": "6c112d4e-5bc7-47ae-a041-ea2d9dccd749"
 }
}
"@



get-azpolicydefinition -Id '/providers/Microsoft.Authorization/policyDefinitions/6c112d4e-5bc7-47ae-a041-ea2d9dccd749'  

$notallowedresourcetypes = $PolicyParameters = @{
    listOfResourceTypesNotAllowed = @('microsoft.billing/billingaccounts/billingsubscriptions',
'microsoft.subscription/createsubscription')
}


$definition = New-AzPolicyDefinition -Name "Block-New-Subscription-Creation" `
                                    -DisplayName "Block the creation of new subscriptions" `
                                    -Description "This policy blocks the creation of new subscriptions in Azure" `
                                    -Mode All `
                                    -Policy  $policy -ManagementGroupName $($tenantrootgrp.Name)


$assignment = New-AzPolicyAssignment -Name "BlockNewSubsCreation" `
                                      -DisplayName "Block new subscription creation assignment" `
                                      -Scope "$($tenantrootgrp.id)" `
                                      -NotScope  "$($notscope.id)" `
                                      -PolicyDefinition $definition `
                                      -PolicyParameterObject  $notallowedresourcetypes  -EnforcementMode Default  
                                      
                                      
    
    
    
     
    
    
    
    
    
    
    
    
    
    
    
    
                                      
                                              
