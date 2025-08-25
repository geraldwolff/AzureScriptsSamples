
# Connect to Azure
Connect-AzAccount #-Environment AzureUSGovernment

# Define the Azure subscription and resource group
 
 $subscriptions = get-azsubscription -verbose | where state -EQ 'Enabled'

$policyassignmentreports = ''

 foreach($subscription in $subscriptions) 
 {
        set-azcontext -Subscription $($subscription.name) -force


       $policyassignments = get-azpolicyassignment  |   select -ExcludeProperty properties
   

        foreach($PolicyAssignment in $policyassignments)
        {


               $assignmentparamsvalues =   $($PolicyAssignment.Properties.Parameters.listOfResourceTypesNotAllowed) 

            $assignmentprops = Get-AzPolicyAssignment -Id $($PolicyAssignment.PolicyAssignmentId) | Select-Object -ExpandProperty properties 
            
            foreach($assignedparamvalue in $assignmentparamsvalues)
            {

            
            $PolicyAssignmentobj = New-Object PSObject 

            $PolicyAssignmentobj | Add-Member -MemberType NoteProperty -Name  Scope   -value $($assignmentprops.Scope)  
            $PolicyAssignmentobj | Add-Member -MemberType NoteProperty -Name  NotScopes   -value $($assignmentprops.NotScopes)
            $PolicyAssignmentobj | Add-Member -MemberType NoteProperty -Name  DisplayName   -value $($assignmentprops.DisplayName)
            $PolicyAssignmentobj | Add-Member -MemberType NoteProperty -Name  Metadata   -value $($assignmentprops.Metadata)
            $PolicyAssignmentobj | Add-Member -MemberType NoteProperty -Name  EnforcementMode   -value $($assignmentprops.EnforcementMode)
            $PolicyAssignmentobj | Add-Member -MemberType NoteProperty -Name  PolicyDefinitionId   -value $($assignmentprops.PolicyDefinitionId)
            $PolicyAssignmentobj | Add-Member -MemberType NoteProperty -Name  Parameters   -value $($assignmentprops.Parameters)
            $PolicyAssignmentobj | Add-Member -MemberType NoteProperty -Name  NonComplianceMessages   -value $($assignmentprops.NonComplianceMessages)
            $PolicyAssignmentobj | Add-Member -MemberType NoteProperty -Name  assignmentparamsvalues   -value "$($assignedparamvalue.value)"

            

            [array]$policyassignmentreports +=    $PolicyAssignmentobj  
            
            }  
             
        }


      }

$policyassignmentreports | select Scope,`
NotScopes, `
DisplayName, `
Metadata, `
EnforcementMode, `
PolicyDefinitionId, `
Parameters, `
NonComplianceMessages, `
assignmentparamsvalues `
  | where scope -ne $null |export-csv c:\temp\assignedpolicies_information.csv -NoTypeInformation





  ####################
        
                $policy = Get-AzPolicyDefinition  
 
                $policy  | foreach-object {
  
                Get-AzPolicyDefinition -Name $_.name | ConvertTo-Json -Depth 10 | out-file "c:\temp\$($_.Properties.DisplayName)_general.json" -Encoding unicode


                }
















