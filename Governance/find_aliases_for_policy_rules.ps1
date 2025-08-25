$hubaliases = Get-AzPolicyAlias -ListAvailable | where-object { $_.resourcetype -like '*hubVirtualNetworkConnections*' } | select resourcetype, aliases 

$($hubaliases.aliases) | fl *


