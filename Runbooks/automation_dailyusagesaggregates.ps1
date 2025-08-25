<#
.SYNOPSIS  
 Wrapper script for Azure Usage for date range
.DESCRIPTION  
 Wrapper script for Azure Usage for date range
.EXAMPLE  
.\automation_dailyusagesaggregates.ps1  -reportedStartTime "yyyy-MM-dd" -reportedEndTime "yyyy-MM-dd" -Subscription "Subscriptionname"
Version History  
v1.0   - Initial Release  
 

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
 

param(

[String]$reportedStartTime = $(throw "yyyy-MM-dd"),
[String]$reportedEndTime = $(throw "yyyy-MM-dd"),
[String]$Subscription = $(throw "Value for Subscriptioname is missing"),
[String]$Storageaccount = $(throw "Value for StorageAccount is missing"),
[String]$Resourcegroup = $(throw "Value for Resourcegroup is missing"),
[String]$container  = $(throw "Value for container is missing"),
[string]$region = $(throw "Value for location is missing")
)

 $ErrorActionPreference = 'Continue'

 # install-module Az.Billing -AllowClobber 
  #install-module az.Profile -AllowClobber 
  #install-module az.Compute -AllowClobber 
 # install-module az.Storage  -AllowClobber 

  
                              
import-module Az.Billing -Force -verbose
#import-module az.Profile
import-module az.Compute
import-module az.Storage

connect-azaccount  -identity


#
 


#######################################################################################
  
  

 
#######################################################################################
 



<#
 
 


  $usageobj = new-object PSObject
                                 $usageobj | add-member -membertype NoteProperty -name "UsageStartTime" -value  "$UsageStartTime"
                                 $usageobj | add-member -membertype NoteProperty -name "UsageEndTime" -value  "$UsageEndTime"
                                 $usageobj | add-member -membertype NoteProperty -name "SubscriptionId" -value  "$SubscriptionId"
                                 $usageobj | add-member -membertype NoteProperty -name "MeterCategory" -value  "$MeterCategory"
                                 $usageobj | add-member -membertype NoteProperty -name "MeterId" -value  "$MeterId"
                                 $usageobj | add-member -membertype NoteProperty -name "MeterName" -value  "$MeterName"
                                 $usageobj | add-member -membertype NoteProperty -name "MeterSubCategory" -value  "$MeterSubCategory"
                                 $usageobj | add-member -membertype NoteProperty -name "MeterRegion" -value  "$MeterRegion"
                                 $usageobj | add-member -membertype NoteProperty -name "InstanceSize" -value  "$InstanceSize"
                                 $usageobj | add-member -membertype NoteProperty -name "Unit" -value  "$Unit"
                                 $usageobj | add-member -membertype NoteProperty -name "Quantity" -value  "$Quantity"
                                 $usageobj | add-member -membertype NoteProperty -name "Project" -value  "$Project"
                                 $usageobj | add-member -membertype NoteProperty -name "PublicIPAddress" -value  "$PublicIPAddress"
                                 $usageobj | add-member -membertype NoteProperty -name "InstanceData" -value  "$InstanceData"
 
                                  $usageobj | export-csv "c:\temp\azure_usage_summary.csv" -notypeinformation -Append




                    } # foreach usageinfo
                    
                    #>


############################################################################################

$usageaggragationcollection =''
 
$curr_date =  Get-Date
 
$daterecord = $curr_date.ToString("yyyy-MM-dd") 
# set min age of files
 
  
 
# determine how far back we go based on current date
 
$start_date_range =  "$daterecord"


# Set date range for exported usage data
 

$reportedStartTime = "$reportedStartTime"
$reportedEndTime = "$reportedEndTime"


$subs = get-azsubscription -SubscriptionName $Subscription



foreach($sub in $subs) 
{

    $subscriptionName = $sub.name
    $subscriptionid = $sub.id

        set-azcontext -subscription $subscriptionname 


  
    # Set usage parameters
    $granularity = "Daily" # Can be Hourly or Daily
    $showDetails = $true
  

    $continuationToken = $null


    Do { 
 
           $usageData = Get-UsageAggregates `
                -ReportedStartTime $reportedStartTime `
                -ReportedEndTime $reportedEndTime `
                -AggregationGranularity $granularity `
                -ShowDetails:$showDetails `
                -continuationToken $continuationToken 

                Get-UsageAggregates `
                -ReportedStartTime $reportedStartTime `
                -ReportedEndTime $reportedEndTime `
                -AggregationGranularity $granularity `
                -ShowDetails:$showDetails `
                -continuationToken $continuationToken 
 
         $usageaggrgationdata =   $usageData.UsageAggregations.Properties | 
                Select-Object `
                    UsageStartTime, `
                    UsageEndTime, `
                    @{n='SubscriptionId';e={$subscriptionId}}, `
                    MeterCategory, `
                    MeterId, `
                    MeterName, `
                    MeterSubCategory, `
                    MeterRegion, `
                    Unit, `
                    Quantity, `
                    @{n='Project';e={$_.InfoFields.Project}}, `
                    InstanceData  
                    foreach($Usageaggregationdataitem in  $usageaggrgationdata)
                    {
                         $usageobj = new-object PSObject
                                 $usageobj | add-member -membertype NoteProperty -name "UsageStartTime" -value  "$($Usageaggregationdataitem.UsageStartTime)"
                                 $usageobj | add-member -membertype NoteProperty -name "UsageEndTime" -value  "$($Usageaggregationdataitem.UsageEndTime)"
                                 $usageobj | add-member -membertype NoteProperty -name "SubscriptionId" -value  "$($Usageaggregationdataitem.SubscriptionId)"
                                 $usageobj | add-member -membertype NoteProperty -name "MeterCategory" -value  "$($Usageaggregationdataitem.MeterCategory)"
                                 $usageobj | add-member -membertype NoteProperty -name "MeterId" -value  "$($Usageaggregationdataitem.MeterId)"
                                 $usageobj | add-member -membertype NoteProperty -name "MeterName" -value  "$($Usageaggregationdataitem.MeterName)"
                                 $usageobj | add-member -membertype NoteProperty -name "MeterSubCategory" -value  "$($Usageaggregationdataitem.MeterSubCategory)"
                                 $usageobj | add-member -membertype NoteProperty -name "MeterRegion" -value  "$($Usageaggregationdataitem.MeterRegion)"
                                 $usageobj | add-member -membertype NoteProperty -name "InstanceSize" -value  "$($Usageaggregationdataitem.InstanceSize)"
                                 $usageobj | add-member -membertype NoteProperty -name "Unit" -value  "$($Usageaggregationdataitem.Unit)"
                                 $usageobj | add-member -membertype NoteProperty -name "Quantity" -value  "$($Usageaggregationdataitem.Quantity)"
                                 $usageobj | add-member -membertype NoteProperty -name "Project" -value  "$($Usageaggregationdataitem.Project)"
                                 $usageobj | add-member -membertype NoteProperty -name "PublicIPAddress" -value  "$($Usageaggregationdataitem.PublicIPAddress)"
                                 $usageobj | add-member -membertype NoteProperty -name "InstanceData" -value  "$($Usageaggregationdataitem.InstanceData)"
 
                              [array]$usageaggragationcollection +=  $usageobj  

                    }


            if ($usageData.NextLink) {
                $continuationToken = `
                    [System.Web.HttpUtility]::`
                    UrlDecode($usageData.NextLink.Split("=")[-1])
                } else {
                    $continuationToken = $null
                }


                        
 

  
          $appendFile = $true
    } until (!$continuationToken)


}



 $resultsfilename = "ResourceUsageaggrgation.csv"

$usageaggragationcollection | select-object UsageStartTime,UsageEndTime,SubscriptionId, MeterCategory,MeterId,MeterName, MeterSubCategory,MeterRegion, InstanceSize, Unit, Quantity, Project,PublicIPAddress, InstanceData  | export-csv $resultsfilename  -NoTypeInformation   

#$usageaggragationcollection | select-object UsageStartTime,UsageEndTime,SubscriptionId, MeterCategory,MeterId,MeterName, MeterSubCategory,MeterRegion, InstanceSize, Unit, Quantity, Project,PublicIPAddress, InstanceData  |  export-csv c:\temp\usageaggragationresults.csv -NoTypeInformation



##############################################################
 

  ##### storage subinfo

$Region = $region

 $subscriptionselected = $Subscription



$resourcegroupname = $resourcegroup
$subscriptioninfo = get-azsubscription -SubscriptionName $subscriptionselected 
$TenantID = $subscriptioninfo | select tenantid
$storageaccountname = $Storageaccount
$storagecontainer = $container
### end storagesub info

set-azcontext -Subscription $($subscriptioninfo.Name)  -Tenant $($TenantID.TenantId)

 

#BEGIN Create Storage Accounts
 
 
 
 try
 {
	if (!(Get-azresourcegroup -ResourceGroupName $resourcegroupname ))
    {  
        Write-Host "Resourcegroup Does Not Exist, Creating Resourcegroup: $ressourcegroup Now"

        # b. Provision storage account
        New-azresourcegroup  -ResourceGroupName $resourcegroupname -Location $region   -Tag @{"owner" = "Jerry wolff"; "purpose" = "Az Automation resourcegroup" } -Verbose
         
            Start-Sleep -Seconds 30
     
        Get-azresourcegroup -Name   $resourcegroupname     -verbose
     }
   }
   Catch
   {
         WRITE-DEBUG "Resourcegroup Aleady Exists, SKipping Creation of $resourcegroupname"
   
   }  

 try
 {

     if (!(Get-AzStorageAccount -ResourceGroupName $resourcegroupname -Name $storageaccountname ))
    {  
        Write-Host "Storage Account Does Not Exist, Creating Storage Account: $storageAccount Now"

        # b. Provision storage account
        New-AzStorageAccount -ResourceGroupName $resourcegroupname  -Name $storageaccountname -Location $region -AccessTier Hot -SkuName Standard_LRS -Kind BlobStorage -Tag @{"owner" = "Jerry wolff"; "purpose" = "Az Automation storage write" } -Verbose
         Start-Sleep -Seconds 30
     
        Get-AzStorageAccount -Name   $storageaccountname  -ResourceGroupName  $resourcegroupname  -verbose
     }
   }
   Catch
   {
         WRITE-DEBUG "Storage Account Aleady Exists, SKipping Creation of $storageAccount"
   
   } 
        $StorageKey = (Get-AzStorageAccountKey -ResourceGroupName $resourcegroupname  –StorageAccountName $storageaccountname).value | select -first 1
        $destContext = New-azStorageContext  –StorageAccountName $storageaccountname `
                                        -StorageAccountKey $StorageKey


             #Upload user.csv to storage account

        try
            {
                  if (!(get-azstoragecontainer -Name $storagecontainer -Context $destContext))
                     { 
                         New-azStorageContainer $storagecontainer -Context $destContext

                          Start-Sleep -Seconds 30
                          get-azstoragecontainer -Name $storagecontainer -Context $destContext

                        }
             }
        catch
             {
                Write-Warning " $storagecontainer container already exists" 
             }
       

         Set-azStorageBlobContent -Container $storagecontainer -Blob $resultsfile  -File $resultsfilename -Context $destContext -force
        
 
 
 
     
 















