 <#
.SYNOPSIS  
 Wrapper script for automation_get_azure_storage_accountusage_sizes_commercial.ps1
.DESCRIPTION  
 Wrapper script for automation_get_azure_storage_accountusage_sizes_commercial.ps1
.EXAMPLE  
.\automation_get_azure_storage_accountusage_sizes_commercial.ps1
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
  Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings 'true'
### uncomment when using for AAzure Automation
connect-azaccount     -Identity


$AZStorageACCOUNTlist = ''


$sub = Get-AzSubscription | select Name  


    $sub | foreach {   
        Set-AzContext -Subscription $_.Name  
        $subscriptioname = $_.Name  
        $RGs = Get-AzResourceGroup | select ResourceGroupName  
            $RGs | foreach {  
                $CurrentRG = $_.ResourceGroupName  
                $StorageAccounts = Get-AzStorageAccount -ResourceGroupName $CurrentRG | select StorageAccountName  
                        $StorageAccounts | foreach {  
                        $StorageAccount = $_.StorageAccountName  
                        $CurrentSAID = (Get-AzStorageAccount -ResourceGroupName $CurrentRG -AccountName $StorageAccount).Id  
                        [decimal]$usedCapacity = (Get-AzMetric -ResourceId $CurrentSAID -MetricName "UsedCapacity").Data  
                        [decimal]$usedCapacityInMB = $usedCapacity.average / 1024 / 1024  


                        
                                   $obj = new-object PSObject


                                     $Resource = Get-AzResource -Name $StorageAccount | select -Property *


                                           $Resource.Tags.GetEnumerator() | ForEach-Object {

                                               #Write-Output "$($_.key)   = $($_.Value)"
                                        
 
                                              $obj | add-member -membertype Noteproperty -name $($_.key) -value $($_.value)

                                              }

                              #Convert length to GB

                                    [decimal]$TotalSIZEGB = $usedCapacity.average /1024 /1024 /1024

                        wRITE-HOST "$StorageAccount = $TotalSIZEGB" -ForegroundColor CYAN

                                        $obj | add-member -membertype NoteProperty -name "subscriptioname" -value "$subscriptioname"
                                        $obj | add-member -membertype NoteProperty -name "Resourcegroup" -value "$CurrentRG"
                                        $obj | add-member -membertype NoteProperty -name "storageaccountname" -value "$StorageAccount"
                                        $obj | add-member -membertype NoteProperty -name "tOTALSIZEMB" -Value $($usedCapacityInMB) 
                                        $obj | add-member -membertype NoteProperty -name "TotalSIZEGB" -Value $($TotalSIZEGB) 

                                   [array]$AZStorageACCOUNTlist +=     $obj  

                      
                        }  
                }  
        }
 

  $date = $(Get-Date -Format 'dd MMMM yyyy' )
 
    $CSS = @"
<Title> Azure Storage container sizes Report: $date </Title>
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


 

 
$AZStoragelist_report = ($AZStorageACCOUNTlist | sort-object subscriptioname   | Select  * |`   
ConvertTo-Html -Head $CSS )  | out-file "c:\temp\Azure_storage_account_sizes.html" 

invoke-item "c:\temp\Azure_storage_account_sizes.html" 
 

 
 
 ######### Uncomment and configure to send results to storage account blob 


 
 $date = $(Get-Date -Format 'dd MMMM yyyy' )
 
########### Prepare for storage account export

$csvresults = $AZStorageACCOUNTlist | sort-object subscriptioname   |   Select  *

 $resultsfilename = "storageaccountusage.csv"

$csvresults  | export-csv $resultsfilename  -NoTypeInformation   

# end vmss data 


##### storage subinfo

$Region = "westus"
 $date = Get-Date -Format MMddyyyy
 $subscriptionselected = 'wolffentpsub'



$resourcegroupname = 'wolffautomationrg'
$subscriptioninfo = get-azsubscription -SubscriptionName $subscriptionselected 
$TenantID = $subscriptioninfo | select tenantid
$storageaccountname = 'wolffautosa'
$storagecontainer = 'storageaccountusage'
### end storagesub info

set-azcontext -Subscription $($subscriptioninfo.Name)  -Tenant $($TenantID.TenantId)

 

#BEGIN Create Storage Accounts
 
 
 
 try
 {
     if (!(Get-AzStorageAccount -ResourceGroupName $resourcegroupname -Name $storageaccountname ))
    {  
        Write-Host "Storage Account Does Not Exist, Creating Storage Account: $storageAccount Now"

        # b. Provision storage account
        New-AzStorageAccount -ResourceGroupName $resourcegroupname  -Name $storageaccountname -Location $region -AccessTier Hot -SkuName Standard_LRS -Kind BlobStorage -Tag @{"owner" = "Jerry wolff"; "purpose" = "Az Automation storage write" } -Verbose
 
     
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
                        }
             }
        catch
             {
                Write-Warning " $storagecontainer container already exists" 
             }
       

         Set-azStorageBlobContent -Container $storagecontainer -Blob $resultsfile  -File $resultsfilename -Context $destContext -FORCE
        
        
 
 
 





