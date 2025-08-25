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


######################################


param(

[String]$source = $(throw "westus")
 
)

$ErrorActionPreference = "silentlycontinue"

Switch ("$source")
{
    "" {$source ="westus"}
    $null {$source = "westus"}
 
}


   Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings 'true'

#############


connect-azaccount  -identity


#install-module -name  azspeedtest -allowclobber
import-module azspeedtest
import-module az -force


$regions = Get-azlocation | select location


$speedresults = $null
$date = $(Get-Date -Format 'dd MMMM yyyy')

foreach($region in $regions)
{
    $sourceregion = "$source"
    $($region.location)
        $results = test-azregionlatency -Region "$sourceregion", "$($region.location)"  -Iterations 50  

        $results 


 

        foreach($result in $results)
        {
            if("$($result.region)" -notmatch "$sourceregion")
            {
                $speedobj = new-object PSObject 

                $speedobj | Add-Member -MemberType NoteProperty -Name SourceComputername -value "$($result.computername)"
                $speedobj | Add-Member -MemberType NoteProperty -Name SourceRegion -value "$sourceregion"
                $speedobj | Add-Member -MemberType NoteProperty -Name Minimum -value "$($result.Minimum)"
                $speedobj | Add-Member -MemberType NoteProperty -Name Average -value "$($result.Average)"
                $speedobj | Add-Member -MemberType NoteProperty -Name Maximum -value "$($result.Maximum)"
                $speedobj | Add-Member -MemberType NoteProperty -Name TotalTime -value "$($result.TotalTime)"
                $speedobj | Add-Member -MemberType NoteProperty -Name Region -value "$($result.Region)"
                $speedobj | Add-Member -MemberType NoteProperty -Name Record_date -value "$date"

                [array]$speedresults += $speedobj
            }
        }
}



 $resultsfilename = "networkspeedperformance.csv"

 $speedresults |  select SourceComputername, SourceRegion, Minimum, Average, Maximum,TotalTime ,Region , Record_date  | export-csv $resultsfilename  -NoTypeInformation  


  ##### storage subinfo

##### storage subinfo

$Region = "<location>"
#####  Subscription name if results storage accounts are in a separate subscription

### If results storage account is in a separate tenant 
#Connect-azaccount   # for storage account tenant and subscription context verification

 $subscriptionselected = '<results subscription>'



$resourcegroupname = '<resourcegroupname>'
$subscriptioninfo = get-azsubscription -SubscriptionName $subscriptionselected 
$TenantID = $subscriptioninfo | Select-Object tenantid
$storageaccountname = '<storaceaccountcontainer>'
 
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
       

         Set-azStorageBlobContent -Container $storagecontainer -Blob $resultsfilename  -File $resultsfilename -Context $destContext -force
        
 