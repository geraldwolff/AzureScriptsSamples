##########  Requires Window remote to tbe enabled

### Aaure az version

Connect-AzAccount 


 $uptime_collection = $null 

$Subs =  Get-azSubscription #-SubscriptionName 'corporate'  | select Name, ID,TenantId


 foreach($Subscription in  $subs)
    {

                             $SubscriptionName =  $Subscription.name

                             
                           $azcontext = (set-azcontext -SubscriptionName $SubscriptionName  -ErrorAction SilentlyContinue )




        $rgs = Get-azResourceGroup 
        foreach($rg in $rgs) 
        {
        $rgname = $rg.ResourceGroupName

            $vms =     get-azvm   -ResourceGroupName $rgname

            foreach ($vm in $vms)
            {
             $computer = "$($vm.Name)"

             $Provisioning_date = $vmdetail.Statuses | where code -eq 'ProvisioningState/succeeded' | select time
             
                        $VMDetail = Get-azVM -ResourceGroupName $rgname   -Name $($VM.Name) -Status  -erroraction silentlycontinue 
                             
                        foreach ($VMStatus in $VMDetail.Statuses)
                        { 
  
                                $VMStatusDetail = $VMStatus.DisplayStatus
                            }
                             
                             if($VMStatusDetail -like '*running*' )
                             {
                                 $results =   invoke-command -computername $computer -Credential $vmcred  -scriptblock { param($computer)
          
                                 $os = Get-CimInstance  -ClassName Win32_OperatingSystem
                                 $uptime = (Get-Date) - $os.LastBootUpTime
                                 $Uptime_breakout = "Uptime: "+ $uptime.Days + " days, " + $uptime.Hours + " hours, " + $uptime.Minutes + " minutes"
                               
                                 $lastboot = $os.LastBootUpTime
                                 $vmStatusDetail

                                 write-output "$Uptime_breakout - $uptime - $lastboot"

                        

                                               # Write-Output $Display  
                                      } -ArgumentList $computer


                                      $vmuptime = $results -split(' - ')
                                      $uptime_exp =  $vmuptime[0]
                                      $vmuptimeraw = $vmuptime[1].trim()
                                      $Vmdowntime = $vmuptime[2].trim()
                                      
                                      $current_date = (get-date)

                                      $Down_Time = $null
                                       

                                   $vmobj = new-object PSObject 

                                        $vmobj | add-member  -membertype NoteProperty -name   SubscriptionName  -value "$SubscriptionName"                                                                                    
                                        $vmobj | add-member  -membertype NoteProperty -name   resourcegroupname  -value "$($rgname)"         
                                        $vmobj | add-member  -membertype NoteProperty -name   VMName  -value "$computer"
                                        $vmobj | add-member  -membertype NoteProperty -name   vmloc -Value "$($vm.Location)"
                                        $vmobj | add-member  -membertype NoteProperty -name   VMStatusDetail -Value "$VMStatusDetail"
                                        $vmobj | add-member  -membertype NoteProperty -name   UpTime -value "$uptime_exp"
                                        $vmobj | add-member  -membertype NoteProperty -name  VMtimeraw  -value "$vmuptimeraw"
                                        $vmobj | add-member  -membertype NoteProperty -name  Provisioning_Date  -value "$($Provisioning_date.time)"

 
                                        

                             }
                            else 
                            {
                                $vmobj = new-object PSObject 

                                        $vmobj | add-member  -membertype NoteProperty -name   SubscriptionName  -value "$SubscriptionName"                                                                                    
                                        $vmobj | add-member  -membertype NoteProperty -name   resourcegroupname  -value "$($rgname)"         
                                        $vmobj | add-member  -membertype NoteProperty -name   VMName  -value "$computer"
                                        $vmobj | add-member  -membertype NoteProperty -name   vmloc -Value "$($vm.Location)"
                                        $vmobj | add-member  -membertype NoteProperty -name   VMStatusDetail -Value "$VMStatusDetail"
                                        $vmobj | add-member  -membertype NoteProperty -name   UpTime -value "Server is not running or not reachable"
                                        $vmobj | add-member  -membertype NoteProperty -name  VMtimeraw  -value "$vmuptimeraw"
                                         $vmobj | add-member  -membertype NoteProperty -name  Provisioning_Date  -value "$($Provisioning_date.time)"
 


                            }
                            
                            [array]$uptime_collection += $vmobj
            }
        }
          
      }

$uptime_collection


$CSS = @"
<Title>VM Uptime Report Report:$(Get-Date -Format 'dd MMMM yyyy' )</Title>
<Header>
 
"<B>Company Confidential</B> <br><I>Report generated from {3} on $env:computername {0} by {1}\{2} as a scheduled task</I><br><br>Please contact $contact with any questions "$(Get-Date -displayhint date)",$env:userdomain,$env:username
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






$uptime_collection  | export-csv c:\temp\uptime_results.csv
 

$uptime_report = (($uptime_collection   | Sort-Object -Property SubscriptionName,resourcegroupname,VMName,vmloc,VMStatusDetail,UpTime,VMtimeraw -unique |`
Select SubscriptionName,resourcegroupname, VMName,vmloc,`
VMStatusDetail,UpTime,VMtimeraw ,Provisioning_Date  |`
ConvertTo-Html -Head $CSS ).replace('Server is not running or not reachable','<font color=red>Server is not running or not reachable</font>'))     
 
 