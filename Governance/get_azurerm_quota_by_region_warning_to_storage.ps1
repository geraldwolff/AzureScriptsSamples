 
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

    Script Name: get_azurerm_quota_by_region_warning_to_storage.
    Description: Custom script collect Subscription quota counts and Flagge/report on percentage levels get to close to limit
    NOTE:   Scripts creates resourcegroup, storage account, containers and csv files loaded to storage account

#> 

####### Suppress powershell module changes warning during execution 

  Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings 'true'





 connect-azaccount  # -identity

  
 


## Cleanup



$usageSummary = $null 

$subs = get-Azsubscription 
foreach($sub in $subs)
{
    $subname = $sub.Name


        Set-Azcontext -Subscription $subname   

            $regionlist = (Get-AzLocation).Location

              foreach ($region in $regionlist)
               {

                 $regionquotausage =    Get-AzVmUsage –Location $region  -ErrorAction SilentlyContinue
 
                   foreach($usage in $regionquotausage)
                    {
                            $vmobj = new-object PSObject 

                                $usedCount= [int]($($usage.CurrentValue))   
                                $quota = [int]($($usage.Limit))

                                if ($quota -gt 0)
                                {
                                $Percentage = ($usedCount / $quota) * 100
                                }
                                else
                                {
                                    $Percentage = 0
                                }
 
                                $vmobj | add-member  -membertype NoteProperty -name   Subscription  -value "$subname" 
                                $vmobj | add-member  -membertype NoteProperty -name   Region  -value "$region"                                                                                    
                                $vmobj | add-member  -membertype NoteProperty -name   ResourceNameValue  -value "$($usage.Name.Value)"  
                                $vmobj | add-member  -membertype NoteProperty -name   ResourceNameLocalizedValue  -value "$($usage.Name.LocalizedValue)"                                                                         
                                $vmobj | add-member  -membertype NoteProperty -name   CurrentCount  -value "$($usage.CurrentValue)"         
                                $vmobj | add-member  -membertype NoteProperty -name   Limit  -value "$($usage.Limit)"         
                                $vmobj | add-member  -membertype NoteProperty -name   Percentage_used   -value    $Percentage         


                          [array]$usageSummary +=       $vmobj  
                         

                    }
                }

}


 

$CSS = @"

<Title>Azure Resource Usage  Warning  Report:$(Get-Date -Format 'dd MMMM yyyy') </Title>

 <H2>Azure Resource Usage Warning  Report:$(Get-Date -Format 'dd MMMM yyyy')  </H2>

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



########read in collected results and create the html report

$usagereport = $usageSummary
 
 
$usage_report_detail = (($usagereport   | Sort-Object -Property Subscription,Region,ResourceNameValue,ResourceNameLocalizedValue,CurrentCount,Limit -Unique |`
Select Subscription, Region,ResourceNameValue,ResourceNameLocalizedValue,@{Name='CurrentCount';E={IF ($_.CurrentCount -eq '0'){'unused'}Else{$_.CurrentCount}}},Limit,@{Name='Percentage_used';E={IF ($_.Percentage_used -ge 85){'Running_out'}Else{$_.Percentage_used}}}  |`
ConvertTo-Html -Head $CSS ).replace('unused','<font color=red>-0-</font>'))   
  
$usage_report_detail | Out-File "c:\temp\Region_usage_counts.html"

 $footer=("<B>Company Confidential</B> <br><I>Report generated from {3} on $env:computername {0} by {1}\{2} as a scheduled task</I><br><br>Please contact $contact with any questions" -f (Get-Date -displayhint date),$env:userdomain,$env:username,$MyInvocation.MyCommand.Definition )

  
$footer | Out-File "c:\temp\Region_usage_counts.html"  -append
 
 ###############
 

$usagereportSummary = $usage_report_detail

$usage_summary_warning_report = (($usageSummary  | Sort-Object -Property Subscription,Region,ResourceNameValue,ResourceNameLocalizedValue,CurrentCount,Limit,  percentage_Used |`
Select Subscription, Region,ResourceNameValue,ResourceNameLocalizedValue, CurrentCount,Limit,Percentage_used |  Where {$_.percentage_used -gt 75 } |`
ConvertTo-Html -Head $CSS ) )

 $usage_summary_warning_report | Out-File "c:\temp\Region_usage_Summary.html"

 $footer=("<B>Company Confidential</B> <br><I>Report generated from {3} on $env:computername {0} by {1}\{2} as a scheduled task</I><br><br>Please contact $contact with any questions" -f (Get-Date -displayhint date),$env:userdomain,$env:username,$MyInvocation.MyCommand.Definition )

  
$footer | Out-File "c:\temp\Region_usage_Summary.html"  -append
 
 

################

  

 $resultsfile1 = "regionusagecounts.csv"
$resultsfile2 = "regionusagesummary.csv"
 
  $usagereport   | Sort-Object -Property Subscription,Region,ResourceNameValue,ResourceNameLocalizedValue,CurrentCount,Limit -Unique |`
Select Subscription, Region,ResourceNameValue,ResourceNameLocalizedValue,@{Name='CurrentCount';E={IF ($_.CurrentCount -eq '0'){'unused'}Else{$_.CurrentCount}}},Limit,@{Name='Percentage_used';E={IF ($_.Percentage_used -ge 85){'Running_out'}Else{$_.Percentage_used}}}  |`
export-csv "resultsfile1" -NoTypeInformation



$usageSummary  | Sort-Object -Property Subscription,Region,ResourceNameValue,ResourceNameLocalizedValue,CurrentCount,Limit,  percentage_Used |`
Select Subscription, Region,ResourceNameValue,ResourceNameLocalizedValue, CurrentCount,Limit,Percentage_used |  Where {$_.percentage_used -gt 75 } |`
export-csv "resultsfile2" -NoTypeInformation




########### Connect if using a diferent tenant or account to store data

connect-azaccount  

   ##### storage subinfo

$Region = "<Location>"

 $subscriptionselected = '<Subscriptionaname>'



$resourcegroupname = '<Resourcegroupname>'
$subscriptioninfo = get-azsubscription -SubscriptionName $subscriptionselected 
$TenantID = $subscriptioninfo | Select-Object tenantid
$storageaccountname = '<Storageacocuntname>'
 
### end storagesub info

set-azcontext -Subscription $($subscriptioninfo.Name)  -Tenant $($TenantID.TenantId)


#BEGIN Create Storage Accounts
 
  

 ####resourcegroup 
 try
 {
     if (!(Get-azresourcegroup -Location 'westus' -Name $resourcegroupname -erroraction "silentlycontinue" ) )
    {  
        Write-Host "resourcegroup Does Not Exist, Creating resourcegroup  : $resourcegroupname Now"

        # b. Provision resourcegroup
        New-azresourcegroup  -Name  $resourcegroupname -Location $region -Tag @{"owner" = "Jerry wolff"; "purpose" = "Az Automation" } -Verbose -Force
 
       start-sleep 30
        Get-azresourcegroup    -ResourceGroupName  $resourcegroupname  -verbose
     }
   }
   Catch
   {
         WRITE-DEBUG "Resourcegroup   Aleady Exists, SKipping Creation of resourcegroupname"
   
   }



 
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


####################


$storagecontainer = 'regionusagecounts'

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
       
        $StorageKey = (Get-AzStorageAccountKey -ResourceGroupName $resourcegroupname  –StorageAccountName $storageaccountname).value | select -first 1
        $destContext = New-azStorageContext  –StorageAccountName $storageaccountname `
                                        -StorageAccountKey $StorageKey

$usagereport   | Sort-Object -Property Subscription,Region,ResourceNameValue,ResourceNameLocalizedValue,CurrentCount,Limit -Unique |`
Select Subscription, Region,ResourceNameValue,ResourceNameLocalizedValue,@{Name='CurrentCount';E={IF ($_.CurrentCount -eq '0'){'unused'}Else{$_.CurrentCount}}},Limit,@{Name='Percentage_used';E={IF ($_.Percentage_used -ge 85){'Running_out'}Else{$_.Percentage_used}}}  | export-csv "regionusagecounts.csv" -NoTypeInformation
       

         Set-azStorageBlobContent -Container $storagecontainer -Blob $resultsfile1 -File $resultsfile1 -Context $destContext -force


########################

       $storagecontainer = 'regionusagesummary'

       
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
               
               
        $StorageKey = (Get-AzStorageAccountKey -ResourceGroupName $resourcegroupname  –StorageAccountName $storageaccountname).value | select -first 1
        $destContext = New-azStorageContext  –StorageAccountName $storageaccountname `
                                        -StorageAccountKey $StorageKey

$usageSummary  | Sort-Object -Property Subscription,Region,ResourceNameValue,ResourceNameLocalizedValue,CurrentCount,Limit,  percentage_Used |`
Select Subscription, Region,ResourceNameValue,ResourceNameLocalizedValue, CurrentCount,Limit,Percentage_used |  Where {$_.percentage_used -gt 75 } | export-csv 'regionusagesummary.csv' -NoTypeInformation

        Set-azStorageBlobContent -Container $storagecontainer -Blob $resultsfile2  -File $resultsfile2 -Context $destContext -force


 