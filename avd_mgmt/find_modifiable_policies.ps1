Connect-AzAccount


$policyaliases = get-azpolicyalias | select-object -ExpandProperty 'Aliases' 

$policyaliases.aliases.defaultmetadata.attributes | gm
$policyaliases | fl *

$policyaliases | where-object { $_.defaultmetadata.attributes -eq 'Modifiable' } 


