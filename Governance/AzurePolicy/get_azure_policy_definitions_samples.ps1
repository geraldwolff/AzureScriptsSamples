$policy = Get-AzPolicyDefinition | Where-Object { $_.Properties.DisplayName -like '*alert*' }  

foreach-object {
$policy.Properties.DisplayName

}





$metricpolicy = Get-AzPolicyDefinition | Where-Object { $_.Properties.DisplayName -eq 'Metric alert rules should be configured on Batch accounts'}


$metricpolicy.properties.Parameters  | ConvertTo-Json



$metricpolicy.properties.PolicyRule  | ConvertTo-Json



$metricpolicy.properties.Metadata  | ConvertTo-Json




Get-AzPolicyDefinition -Name $($metricpolicy.Name) | ConvertTo-Json -Depth 10 | out-file c:\temp\metricpolicy.json -Encoding unicode

#############################################################



$policy = Get-AzPolicyDefinition | Where-Object { $_.Properties.DisplayName -like '*storage*' } 

#$policy.properties.PolicyRule  | ConvertTo-Json
#$policy.Properties.DisplayName
 


$policy  | foreach-object {
  
Get-AzPolicyDefinition -Name $_.name | ConvertTo-Json -Depth 10 | out-file "c:\temp\$($_.Properties.DisplayName)_storagepolicy.json" -Encoding unicode


}





$policy = Get-AzPolicyDefinition #| Where-Object { $_.Properties.DisplayName -like '*allowed*' } 

#$policy.properties.PolicyRule  | ConvertTo-Json
#$policy.Properties.DisplayName
 


$policy  | foreach-object {
  
Get-AzPolicyDefinition -Name $_.name | ConvertTo-Json -Depth 10 | out-file "c:\temp\$($_.Properties.DisplayName)_general.json" -Encoding unicode


}

 















