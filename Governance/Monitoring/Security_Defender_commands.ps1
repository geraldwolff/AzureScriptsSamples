#get-command -verb get -Noun *threat, *threatd*
 Connect-AzAccount 
 import-module az.security -force

 $Subs =  Get-azSubscription | select Name, ID,TenantId



 $defCldAssresults = ''
 $defCldresults = ''



 foreach($Subscription in  $subs)
    {

                             $SubscriptionName =  $Subscription.name

                             
                           $azcontext = (set-azcontext -SubscriptionName $SubscriptionName  -ErrorAction SilentlyContinue)

                       write-host "$SubscriptionName" -foregroundcolor yellow
 
                         #Get-MpThreat  

                     #Get-MpThreatDetection | Select-Object -ExpandProperty resources
                    # Get-MpThreatDetection | Format-List threatID, *time
 


                    #Get-AzRegulatoryComplianceAssessment
 


                    $securityevents = Get-AzSecurityAlert | Select AlertDisplayName, Severity, ProductComponentName,RemediationSteps


                    Foreach($defCldevent in $securityevents)
                    {



                            $Defcldobj = new-object PSObject 

                            $Defcldobj | Add-Member -MemberType NoteProperty -Name AlertDisplayName   -value $($defCldevent.AlertDisplayName)
                            $Defcldobj | Add-Member -MemberType NoteProperty -Name Severity   -value $($defCldevent.Severity)
                            $Defcldobj | Add-Member -MemberType NoteProperty -Name ProductComponentName   -value $($defCldevent.ProductComponentName)
                            $Defcldobj | Add-Member -MemberType NoteProperty -Name RemediationSteps   -value $($defCldevent.RemediationSteps)
                            [Array]$defCldresults += $Defcldobj 



                    }



                    $securityassessment = Get-AzSecurityAssessment 

                    Foreach($defCldAssessment in $securityassessment)
                    {


                            $IDobjName = $($securityassessment).id.split('/')[-5]
                            $IDobjType = $($securityassessment).id.split('/')[-6]


                            $DefcldAssobj = new-object PSObject 

                           $DefcldAssobj | Add-Member -MemberType NoteProperty -Name ID   -value   $($defCldAssessment).id 
                           $DefcldAssobj | Add-Member -MemberType NoteProperty -Name Type   -value  $IDobjType 
                           $DefcldAssobj| Add-Member -MemberType NoteProperty -Name name   -value $IDobjName 
                           $DefcldAssobj | Add-Member -MemberType NoteProperty -Name Status   -value $($defCldAssessment).status.code  
                           $DefcldAssobj| Add-Member -MemberType NoteProperty -Name ResourceDetails   -value $($defCldAssessment).resourcedetails
                           [Array]$defCldAssresults += $DefcldAssobj 



                }

}

 $defCldresults| select AlertDisplayName, Severity, ProductComponentName, RemediationSteps | export-csv "C:\temp\Defender4cloudalerts.csv" -NoTypeInformation


 
 $defCldAssresults | select ID, Type, Name, Status, Resourcedetails | export-csv "c:\temp\Defender4cloudAssessments.csv" -NoTypeInformation




 $resultsfilename1 = "defenderforcloudAssessments.csv"

$defCldAssresults | export-csv $resultsfilename1  -NoTypeInformation   
  

  
 $resultsfilename2 = "defenderforcloudresults.csv"

$defCldresults | export-csv $resultsfilename2  -NoTypeInformation   


##### storage subinfo

$Region = "West US"

 $subscriptionselected = '<Subscription>'



$resourcegroupname = '<Resourcegroup>'
$subscriptioninfo = get-azsubscription -SubscriptionName $subscriptionselected 
$TenantID = $subscriptioninfo | Select-Object tenantid
$storageaccountname = '<Storageaccount>'
$storagecontainer = 'defenderforcloudalerts'
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
       

         Set-azStorageBlobContent -Container $storagecontainer -Blob $resultsfile  -File $resultsfilename1 -Context $destContext
        
          Set-azStorageBlobContent -Container $storagecontainer -Blob $resultsfilename2  -File $resultsfilename2 -Context $destContext





 






#$securityevents | gm

#Get-AzSecuritySolution

#Get-AzSecuritySetting

#Get-AzSecuritySecureScoreControl

#Get-AzSecuritySecureScoreControlDefinition
 





#$securityassessment | gm
#$($securityassessment).resourcedetails | fl *
#$($securityassessment).Status | fl *


