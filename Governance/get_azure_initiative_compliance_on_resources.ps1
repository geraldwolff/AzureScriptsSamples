# Connect to Azure
Connect-AzAccount #-Environment AzureUSGovernment

# Define the Azure subscription and resource group
 
 $subscriptions = get-azsubscription 


 foreach($subscription in $subscriptions) 
 {
        set-azcontext -Subscription $($subscription.name) -force

    $resourcegroups = get-azresourcegroup 

    foreach($resourcegroup in $resourcegroups)
    {

        # Get the Azure resources in the resource group
        $resources = Get-AzResource -ResourceGroupName $($resourceGroup.ResourceGroupName)

        # Loop through the resources and retrieve the policy initiative compliance
        foreach ($resource in $resources) {
            $compliance = Get-AzPolicyState -ResourceId $resource.ResourceId |
                Where-Object {$_.PolicyDefinitionReferenceId -like "/providers/Microsoft.Authorization/policySetDefinitions/*/initiatives/*"} |
                Select-Object PolicyDefinitionReferenceId, ComplianceState


            $compliancestates = Get-AzPolicyState -ResourceId $resource.ResourceId | Select-Object -Property Properties
 $compliancestates.Properties

            $policyreferenceid = Get-AzPolicyState -ResourceId $resource.ResourceId | select PolicyDefinitionReferenceId

            Write-Output "Resource: $($resource.Name)"
            Write-Output "Compliance: $compliance "
            write-output " PolicydefinitionReferenceid $policyreferenceid :" 
            write-output " compliance $($compliancestates.Properties)  :" 
            }
    }


}
