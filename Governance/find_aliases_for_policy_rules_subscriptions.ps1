$hubaliases = Get-AzPolicyAlias -ListAvailable | where-object { $_.resourcetype -like '*OPERATION*' } | select resourcetype, aliases 

$($hubaliases.aliases) | select name | fl *


