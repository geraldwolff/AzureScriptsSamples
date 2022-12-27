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
   Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings 'true'
   $SuppressAzurePowerShellBreakingChangeWarnings = 'true'

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

import-module Az.Compute -force 

 ############
 ## connect to Azure with authorized credentials 
 
 Connect-AzAccount

  
  $erroractionpreference = 'Continue'
  $OrhanedDisks_report =''
 
 $date = get-date 
 cls
 

            $subs  = get-AZsubscription

            foreach($sub in $subs) 
            {
                                $subscriptionName = $sub.name
                                $Subscriptionid =  $sub.ID

                                Set-AZContext  -Subscription $SubscriptionName -tenantid $sub.tenantid | out-null 



                       $disks =	Get-AZDisk  | where name -notlike '*ASRReplica*'     
                     #  $disks
                       $diskslist =   $disks   #| where-object managedby -eq $null
        
        

                    foreach($diskresource in   $diskslist)
                    {
             
                          $orphaneddisks =   get-AZdisk -ResourceGroupName $diskresource.resourcegroupname   -DiskName $diskresource.name  -erroraction silentlyContinue
 
                             $curr_date =  Get-Date 
 

                            # set min age of files
                            $max_days = "-88"

 
                            # determine how far back we go based on current date
                            $bak_date = $curr_date.AddDays($max_days).Date

                            $bk_date_range =  $bak_date.ToString("yyyyMMdd")

                                
                           
                            foreach($orphaneddisk in $orphaneddisks)
                            {

                               $diskproperties =   Get-azlog -StartTime $bak_date -EndTime $curr_date -ResourceId $($orphaneddisk.ID)  -MaxRecord 1    
                        #$diskproperties
                            $diskpropdetail = $diskproperties | select-object -expandproperty properties 

                            $keydata = $diskpropdetail | Select-Object -property Content  


                             #$keyvalue = $keydata | select -expandProperty content 

                             #$values = $keyvalue | select-object -expandProperty values

 
 
                             [array]$keys = $keydata.Content.responseBody    
 
                             $keylist =  $keys -split(',"')   
                                
                                $originalmanagedby =  $keylist | select-string -Pattern 'managedby'   
                              
                                 $originalmanagedby 
  

   
                                   <#
                                   ResourceGroupName  : UW2LSNREPRO
                                    ManagedBy          : 
                                    Sku                : Microsoft.Azure.Management.Compute.Models.DiskSku
                                    Zones              : 
                                    TimeCreated        : 7/13/2017 6:41:24 PM
                                    OsType             :  
                                    CreationData       : Microsoft.Azure.Management.Compute.Models.CreationData
                                    DiskSizeGB 
                                   #> 
      

                                        $Diskobj = New-Object PSOBject 
                                      
                                            $Diskobj | add-member -MemberType NoteProperty   ResourceGroupName -value "$($orphaneddisk.ResourceGroupName)"
                                            $Diskobj | add-member -MemberType NoteProperty -name  ManagedBy  -value "$($orphaneddisk.ManagedBy)"
                                            $Diskobj | add-member -MemberType NoteProperty -name  Sku  -value "$($orphaneddisk.Sku.Tier)"
                                            $Diskobj | add-member -MemberType NoteProperty -name  Zones  -value "$($orphaneddisk.Zones)"
                                            $Diskobj | add-member -MemberType NoteProperty -name  TimeCreated -Value "$($orphaneddisk.TimeCreated)"
                                            $Diskobj | add-member -MemberType NoteProperty -name  OsType  -value  "$($orphaneddisk.OsType)"
                                            $Diskobj | add-member -MemberType NoteProperty -name  CreationData  -value "$($orphaneddisk.CreationData.CreateOption)"
                                            $Diskobj | add-member -MemberType NoteProperty -name  DiskSizeGB  -value "$($orphaneddisk.DiskSizeGB)" 
                                            $Diskobj | add-member -MemberType NoteProperty -name  Name  -value "$($orphaneddisk.Name)" 
                                            $Diskobj | add-member -MemberType NoteProperty -name  Location  -value "$($orphaneddisk.Location)"   
                                            $Diskobj | add-member -MemberType NoteProperty -name  Tags  -value "$($orphaneddisk.Tags.Values)" 
                                            $Diskobj | add-member -MemberType NoteProperty -name  ResourceProviderName -Value "$($diskproperties.ResourceProviderName)" 
                                            $Diskobj | add-member -MemberType NoteProperty -name  Operation -Value "$($diskproperties.operationname)" 
                                            $Diskobj | add-member -MemberType NoteProperty -name  Originalmanagedby -value  "$originalmanagedby"                                                                                                                                        
                                            $Diskobj | add-member -MemberType NoteProperty -name  Record_Date "$date"    

                                            [array]$OrhanedDisks_report +=  $Diskobj  
                         
                           }
               
                           
                  
                    }
            }
 




     $CSS = @"
<Title>Ophaned DISKS to be deleted Report:$(Get-Date -Format 'dd MMMM yyyy' )</Title>
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




 

$deletionAuditReport = (($OrhanedDisks_report| Select  ResourceGroupName,Managedby,Sku , Zones,TimeCreated ,OsType , CreationData, DiskSizeGB,Name ,Location,Tags,ResourceProviderName,Operation,originalManagedby ,Record_date |`
  ConvertTo-Html -Head $CSS ).replace('Ophaned to be deleted','<font color=red>Ophaned to be deleted</font>'))   | out-file c:\temp\orphaned_disk_deletionAuditReport.ConvertTo.Html

  invoke-item c:\temp\orphaned_disk_deletionAuditReport.ConvertTo.Html
    
 