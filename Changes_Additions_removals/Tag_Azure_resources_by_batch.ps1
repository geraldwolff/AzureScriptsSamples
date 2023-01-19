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

Description: interactive script to get azure resources in a subscription selected from list
              Select resources to group for tagging
              entering metadata asked in prompts 
 

#> 

#Set-AzureResourceGroup -Name GroupName -Tag @{Name='TagName';Value='TagValue'} #this will replace all the tags with this one
#    New-AzureResourceGroupDeployment -ResourceGroupName GroupName ...
## Suppres misc errors
 $ErrorActionPreference = 'SilentlyContinue'

Import-Module az.compute  -Force 
##########################################################################################
 

#$owner = 'Jerry Wolff'
#$purpose = "Poc"
#$Team = "MSUS MFG Core"



 $sub  = get-azsubscription  

 $selectedsubscription = get-azsubscription | Select name, TenantID | ogv -PassThru -title " Select Subscription to update" | select name
 $Subscription = $($selectedsubscription.name)

 Set-azContext -subscription  $Subscription
            

             
                    $global:EnvironmentSubscriptionName = $global:sub.name
                    $global:EnvironmentSubscriptionid =  $global:sub.Id




$Resources = get-azresource  | sort-object resourceType -Descending | Select -Property *
 # | Where-Object {$_.ResourceType -eq 'Microsoft.Compute/virtualMachines' -and $_.resourcegroupname -eq  'azureResourceManagement'}

$Resource_to_tag =  $($Resources) | select Name, Tags, resourcegroupname, ID , subscription |  ogv -passthru -title "resources to tag for ownership" | select ID, Name, Tags, ResourcegroupName
            $resource_selected = $Resource_to_tag
            

 $owner = Read-host " Enter owner : " 
$purpose = Read-Host "Purpose :"
$Team = Read-Host "  team name :"

 

foreach($resource in  $resource_selected) 
{
    
    $newtag = Get-azResource -ResourceName $resource.name -ResourceGroupName $resource.resourcegroupname 
Set-azResource -Tag @{ Owner ="$owner"; Purpose="$purpose" ;Team ="$Team" } -ResourceId $newtag.ResourceId -Force

 get-azresource -ResourceId $resource.Id | select Name, Tags, resourcegroupname

} 


 





