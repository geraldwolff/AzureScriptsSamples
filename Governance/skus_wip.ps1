<#
.NOTES

    THIS CODE-SAMPLE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED 

    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR 

    FITNESS FOR A PARTICULAR PURPOSE.

    This sample is not supported under any Microsoft standard support program or service. 

    The script is provided AS IS without warranty of any kind. Microsoft further disclaims all

    implied warranties including, without limitation, any implied warranties of merchantability

    or of fitness for a particular purpose. The entire risk arising out of the use or performance

    of the sample and documentation remains with you. In no event shall Microsoft, its authors,

    or anyone else involved in the creation, production, or delivery of the script be liable for 

    any damages whatsoever (including, without limitation, damages for loss of business profits, 

    business interruption, loss of business information, or other pecuniary loss) arising out of 

    the use of or inability to use the sample or documentation, even if Microsoft has been advised 

    of the possibility of such damages, rising out of the use of or inability to use the sample script, 

    even if Microsoft has been advised of the possibility of such damages.

#> 
 


 ######################33
 ##  Necessary Modules to be imported.

import-module Az.Compute -force 

 ############
 ## connect to Azure with authorized credentials 
 
 Connect-AzAccount




 
$Available_resourceskus  = Get-AzComputeResourceSku  | Select-Object -Property * | select -First 1


 

$Available_resourceskus | fl *





<#

ResourceType    : disks
Name            : Premium_LRS
Tier            : Premium
Size            : P20
Family          : 
Kind            : 
Capacity        : 
Locations       : {westeurope}
LocationInfo    : {Microsoft.Azure.Management.Compute.Models.ResourceSkuLocationInf
                  o}
ApiVersions     : {}
Costs           : {}
Capabilities    : {MaxSizeGiB, MinSizeGiB, MaxIOps, MinIOps...}
Restrictions    : {}
RestrictionInfo : {}

#>



