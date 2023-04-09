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

    Scriptname: get_azure_security_alerts.ps1
    Description:  Script to collect all Azure security alerts
                   Script will generate report in HTML and CSV
                  

    Purpose:  Collection of Azure security alerts 

    Note: in order for process counter to show it must be in the first tab of PowerShell ISE

#> 

 
   Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings 'true'

 $DirectoryToCreate = 'C:\temp'

 if (-not (Test-Path -LiteralPath $DirectoryToCreate)) {
    
    try {
        New-Item -Path $DirectoryToCreate -ItemType Directory -ErrorAction Stop | Out-Null #-Force
    }
    catch {
        Write-Error -Message "Unable to create directory '$DirectoryToCreate'. Error was: $_" -ErrorAction Stop
    }
    "Successfully created directory '$DirectoryToCreate'."

}
else {
    "Directory already existed"
}

 ######################33
 ##  Necessary Modules to be imported.

 

Install-Module -Name Az.ResourceGraph
# Get a list of commands for the imported Az.ResourceGraph module
#Get-Command -Module 'Az.ResourceGraph' -CommandType 'Cmdlet'



# Query Azure Defender Status and sort by tier
#Search-AZGraph -Query "securityresources | where type == `"microsoft.security/pricings`" | extend tier = properties.pricingTier | project name, tier, subscriptionId" | Sort-object tier

 ############
 ## connect to Azure with authorized credentials 
 
 Connect-AzAccount #-Environment AzureUSGovernment

 
#########################################

##  Get Date
$date = get-date -Format ddMMyyyy 
 



#########################################
##  uncomment this line if anomalies in queries display deprecation messages - This will allow script to continue discovery

##$ErrorActionPreference = 'silentlyContinue'

### get the list of subscriptions accessible by the credentials provided   

#########################################
### Clear Array collector 
## This is used to collect data using the custom schema in $resultobj
 $alertresults = ''

#########################################

##  Get ist of subscriptions that will be read for discovery 
 
 $Subs =  Get-azSubscription | select Name, ID,TenantId


 foreach($Subscription in  $subs)
    {

                             $SubscriptionName =  $Subscription.name

                             
                           $azcontext = (set-azcontext -SubscriptionName $SubscriptionName  -ErrorAction SilentlyContinue)

                       write-host "$SubscriptionName" -foregroundcolor yellow





# Show Microsoft Defender for Cloud plan
#Get-AzSecurityPricing | select Name, PricingTier, FreeTrialRemainingTime


$alerts = Get-AzSecurityAlert  
$j = 0

        Foreach($alert in $alerts)
        {
      
                 ################### counter for Alerts
 

                        $j = $j+1
                                # Determine the completion percentage
                                $JCompleted = ($j/$alerts.count) * 100
                                $Jactivity = "Processing Alerts" + ($j + 1);
         
                       Write-Progress -Activity " $Jactivity " -Status "Progress:" -PercentComplete $JCompleted  


                        #################### end progress counter for Alerts   





            $alertobj = new-object PSObject 

            $alertobj | Add-Member -MemberType NoteProperty -Name AlertDisplayName    -Value $($alert.AlertDisplayName)
            $alertobj | Add-Member -MemberType NoteProperty -Name CompromisedEntity   -Value  $($alert.CompromisedEntity)
            $alertobj | Add-Member -MemberType NoteProperty -Name Description   -Value  $($alert.Description)
            $alertobj | Add-Member -MemberType NoteProperty -Name RemediationSteps   -Value  $($alert.RemediationSteps)
            $alertobj | Add-Member -MemberType NoteProperty -Name  Severity -Value  $($alert.Severity)
            $alertobj | Add-Member -MemberType NoteProperty -Name  ProductName  -Value  $($alert.ProductName)
            $alertobj | Add-Member -MemberType NoteProperty -Name Intent  -Value  $($alert.Intent)
            $alertobj | Add-Member -MemberType NoteProperty -Name AlertType  -Value  $($alert.AlertType)
            $alertobj | Add-Member -MemberType NoteProperty -Name StartTimeUtc  -Value  $($alert.StartTimeUtc)
            $alertobj | Add-Member -MemberType NoteProperty -Name id  -Value  $($alert.id)
            $alertobj | Add-Member -MemberType NoteProperty -Name TimeGeneratedUtc  -Value  $($alert.TimeGeneratedUtc)


           
            $extendedValuesdata =($($alert.ExtendedProperties)) 

            $property =    $extendedValuesdata.Keys|foreach{ Write-Output "$($_ +":"+ $extendedValuesdata[$_])"}

       #   foreach ($i in $extendedValuesdata.GetEnumerator()) { write-host $i.key $i.value }
    
           
 

            $alertobj | Add-Member -MemberType NoteProperty -Name ExtendedProperties  -Value  "$property"
 
            [array]$alertresults += $alertobj
    }


}




$alertresults | select AlertDisplayName,StartTimeUtc,CompromisedEntity, Description, RemediationSteps, Severity, ProductName, Intent, AlertType,ExtendedProperties, id,TimeGeneratedUtc |`
export-csv c:\temp\AlertsCollections$date.csv -NoTypeInformation 





 $alertresultsfilename = "Alerts.csv"

$alertresults | select AlertDisplayName,StartTimeUtc,CompromisedEntity, Description, RemediationSteps, Severity, ProductName, Intent, AlertType,ExtendedProperties, id,TimeGeneratedUtc |`
  export-csv $alertresultsfilename  -NoTypeInformation   
  


##### storage subinfo

$Region = "<Location>"

 $subscriptionselected = '<subscription>'



$resourcegroupname = '<Resourcegroup>'
$subscriptioninfo = get-azsubscription -SubscriptionName $subscriptionselected 
$TenantID = $subscriptioninfo | Select-Object tenantid
$storageaccountname = '<StorageAccount>'
$storagecontainer = 'alerts'
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
       

         Set-azStorageBlobContent -Container $storagecontainer -Blob $alertresultsfilename  -File $alertresultsfilename -Context $destContext
        
 














