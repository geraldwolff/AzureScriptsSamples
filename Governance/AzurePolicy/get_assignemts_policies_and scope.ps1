
# Connect to Azure
Connect-AzAccount #-Environment AzureUSGovernment

# Define the Azure subscription and resource group
 
 $subscriptions = get-azsubscription 


 foreach($subscription in $subscriptions) 
 {
        set-azcontext -Subscription $($subscription.name) -force


       $policyassignments = get-azpolicyassignment |   select -ExcludeProperty properties
        $policyassignments

        foreach($PolicyAssignment in $policyassignments)
        {
                

            $assignmentprops = Get-AzPolicyAssignment -Name $PolicyAssignment.Name | Select-Object -ExpandProperty properties 
            
            $PolicyAssignmentobj = New-Object PSObject 

            $PolicyAssignmentobj | Add-Member -MemberType NoteProperty -Name  Scope   -value $($assignmentprops.Scope)  
            $PolicyAssignmentobj | Add-Member -MemberType NoteProperty -Name  NotScopes   -value $($assignmentprops.NotScopes)
            $PolicyAssignmentobj | Add-Member -MemberType NoteProperty -Name  DisplayName   -value $($assignmentprops.DisplayName)
            $PolicyAssignmentobj | Add-Member -MemberType NoteProperty -Name  Metadata   -value $($assignmentprops.Metadata)
            $PolicyAssignmentobj | Add-Member -MemberType NoteProperty -Name  EnforcementMode   -value $($assignmentprops.EnforcementMode)
            $PolicyAssignmentobj | Add-Member -MemberType NoteProperty -Name  PolicyDefinitionId   -value $($assignmentprops.PolicyDefinitionId)
            $PolicyAssignmentobj | Add-Member -MemberType NoteProperty -Name  Parameters   -value $($assignmentprops.Parameters)
            $PolicyAssignmentobj | Add-Member -MemberType NoteProperty -Name  NonComplianceMessages   -value $($assignmentprops.NonComplianceMessages)
 
            

            [array]$policyassignmentreports +=    $PolicyAssignmentobj  
            
                  
             
        }
      }

$policyassignmentreports | where scope -ne $null


















