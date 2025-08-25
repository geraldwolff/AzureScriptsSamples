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
 $ErrorActionPreference = 'Continue'

Import-Module az.compute  -Force 
##########################################################################################


#connect-azaccount -identity
connect-azaccount #-Environment AzureUSGovernment
  

$updatedtags  = ''

$FulltagsAudit = ''


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
            

$owner = Read-host "Enter owner : " 
$purpose = Read-Host "Purpose :"
$Team = Read-Host "Team name :"

$businessUnit = Read-host "Business unit:" 
$ASNNUMBER = Read-Host "app service number: "
$Sequencestop = read-host " Sequencestop number:"

$Sequencestart = read-host " Sequencestart number: "

if(!($ASNNUMBER -like 'ASN*') )
{
    do
      {
        $ASNNUMBER = Read-Host "app service number: "
     }until($ASNNUMBER -like 'ASN*')

}

 

foreach($resource in  $resource_selected) 
{
    
    $newtag = Get-azResource -ResourceName $resource.name -ResourceGroupName $resource.resourcegroupname 
 
                
                      
 
                 $settag = Set-azResource -Tag @{ 'Owner' ="$owner"`
                 ;'Purpose' ="$purpose" `
                 ;'Team' ="$Team" `
                 ;'app service number'="$ASNNUMBER" `
                 ;'businessUnit' ="$businessUnit"`
                 ;'Sequencestop' = "$Sequencestop" `
                 ;'Sequencestart' = "$sequencestart" ` 
                 } -ResourceId $newtag.ResourceId -Force -ErrorAction silentlyContinue -ErrorVariable ProcessError

               if($processError)
                 {
                     if($processError -like '*VM is not running*')
                     {
                         $Tagsvalue =  'resource is not running'

                     }
                      write-host "Not taggable - $ProcessError" -ForegroundColor Red
                      $Tagsvalue =  'not taggable'
                }
                else
                {

                    $updatedresource = get-azresource -ResourceId $resource.Id | select Name, Tags, resourcegroupname, ID

                   $Tagsvalue = $updatedresource.Tags.Values
                }
     

     $Resourceobj = New-Object Psobject

    $Resourceobj | Add-Member -MemberType NoteProperty -name Name  -Value $($updatedresource.Name) 
    $Resourceobj | Add-Member -MemberType NoteProperty -name TAGS  -Value "$($Tagsvalue)"
    $Resourceobj | Add-Member -MemberType NoteProperty -name Resourcegroupname  -Value $($updatedresource.ResourceGroupName) 
    $Resourceobj | Add-Member -MemberType NoteProperty -name Subscription -Value $Subscription 
    $Resourceobj | Add-Member -MemberType NoteProperty -name ID -Value  $($updatedresource.id)
    [array]$updatedtags += $Resourceobj 
} 


$updatedtags 

 
$CSS = @"
<Title>Azure Resource $scope tagging Report:$(Get-Date -Format 'dd MMMM yyyy' )</Title>
<Header>
 
"<B>Azure Governance</B> <br><I>Report generated from {3} on $env:computername {0} by {1}\{2} as a scheduled task</I><br><br>Please contact $contact with any questions "$(Get-Date -displayhint date)",$env:userdomain,$env:username
 </Header>

 <Style>
th {
	font: bold 11px "Trebuchet MS", Verdana, Arial, Helvetica,
	sans-serif;
	color: #FFFFFF;
	border-right: 1px solid #C1DAD7;
	border-bottom: 1px solid #C1DAD7;
	border-top: 1px solid #C1DAD7;
	letter-spacing: 2px;
	text-transform: uppercase;
	text-align: left;
	padding: 6px 6px 6px 12px;
	background: #5F9EA0;

}
td {
	font: 11px "Trebuchet MS", Verdana, Arial, Helvetica,
	sans-serif;
	border-right: 1px solid #C1DAD7;
	border-bottom: 1px solid #C1DAD7;
	background: #fff;
	padding: 6px 6px 6px 12px;
	color: #6D929B;
}
</Style>
"@



 $scope = 'Updated'
 

(($updatedtags | select Name, Tags, resourcegroupname, subscription, ID  | `
ConvertTo-Html -Head $CSS ).replace('not taggable','<font color=red>not taggable</font>'))      | Out-File c:\temp\Azureresource_tag_report.html
 Invoke-Item c:\temp\Azureresource_tag_report.html


 $scope = 'Full Subscription'



 $FullUpdated_resources = get-azresource  | sort-object resourceType -Descending | Select -Property *

 $Full_audit = $($FullUpdated_resources) | select Name, Tags, resourcegroupname, ID , subscription 

 foreach($Full_audit_resource in $Full_audit)
 {
 

  $FullListresource = get-azresource -ResourceId $Full_audit_resource.Id | select *
  

    $Tags = $FullListresource.Tags

     IF ($null -eq $Tags )
    {
         $Tagsvalue = 'Not taggable'
    
    } 
    Else
    {
          $Tagsvalue = $($Tags.Values)
    }

 $Resourceobj = New-Object Psobject

    $Resourceobj | Add-Member -MemberType NoteProperty -name Name  -Value $($Full_audit_resource.Name) 
    $Resourceobj | Add-Member -MemberType NoteProperty -name TAGS  -Value "$($Tagsvalue)"
    $Resourceobj | Add-Member -MemberType NoteProperty -name Resourcegroupname  -Value $($Full_audit_resource.ResourceGroupName) 
    $Resourceobj | Add-Member -MemberType NoteProperty -name Subscription -Value $subscription
    $Resourceobj | Add-Member -MemberType NoteProperty -name SubscriptionID -Value $($FullListresource.SubscriptionId)
    $Resourceobj | Add-Member -MemberType NoteProperty -name ID -Value $($Full_audit_resource.id)

    [array]$FulltagsAudit += $Resourceobj 
}



(( $FulltagsAudit | select Name, Tags, resourcegroupname, subscription,SubscriptionID,ID  | `
ConvertTo-Html -Head $CSS ).replace('Not taggable','<font color=red>not taggable</font>'))     | Out-File c:\temp\Azureresource_Full_tag_report.html
 Invoke-Item c:\temp\Azureresource_Full_tag_report.html


<#  no color report option

  ( $FulltagsAudit | select Name, Tags, resourcegroupname, subscription,SubscriptionID, ID  | `
ConvertTo-Html -Head $CSS )   | Out-File c:\temp\Azureresource_Full_tag_reporttest.html
 Invoke-Item c:\temp\Azureresource_Full_tag_reporttest.html

 #>



