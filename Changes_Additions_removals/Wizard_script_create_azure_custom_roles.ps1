
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

    Script Name: check_sku_quota_by_selected_subscriptions.ps1
    Description: Custom script collect Subscription quota counts and Flagge/report when percentage levels get to close to limit
    NOTE:   Scripts creates 2 HTML reports 
            c:\temp\Region_usage_counts.html Full count of all Sku quotas used or unused
            "c:\temp\Region_used_skus.html" List of Only skus where the quota is used

#> 

####### Suppress powershell module changes warning during execution 

  Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings 'true'

   

 connect-azaccount  # -identity
  

## Cleanup

$percentagelimit = 80

$usageSummary = $null 





$subs = get-Azsubscription 


$Subscriptions  = $subs | `
select name, ID  | `
Out-GridView -PassThru -Title "Choose one or more Subscriptions: "


        $locname  = Get-azLocation | `
                    select displayname | `
                    Out-GridView -PassThru -Title "Choose a location"


            $regionlist = $locname



foreach($sub in $Subscriptions)
{
    $subname = $sub.Name


        Set-Azcontext -Subscription $subname   



              foreach ($region in $regionlist)
               {

                 $regionquotausage =    Get-AzVmUsage –Location $($region.DisplayName)  -ErrorAction SilentlyContinue
 
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


                          [array]$usageSummary +=  $vmobj  
                         

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
 
 
$usage_report_detail = ((($usagereport   | Sort-Object -Property Subscription,Region,ResourceNameValue,ResourceNameLocalizedValue,CurrentCount,Limit -Unique |`
Select Subscription, Region,ResourceNameValue,ResourceNameLocalizedValue,@{Name='CurrentCount';E={IF ($_.CurrentCount -eq '0'){'unused'}Else{$_.CurrentCount}}},Limit,@{Name='Percentage_used';E={IF ($_.Percentage_used -ge $percentagelimit){"Running_out $($_.Percentage_used)" }Else{$_.Percentage_used}}}  |`
ConvertTo-Html -Head $CSS ).replace('unused','<font color=red>-0-</font>')).replace('Running_out',"<font color=red>Running_out -  $($_.Percentage_used) %</font>"))  
  
$usage_report_detail | Out-File "c:\temp\Region_usage_counts.html"
 

invoke-item "c:\temp\Region_usage_counts.html"

$used_skus_only  = ((($usagereport | where currentcount -gt 0  | Sort-Object -Property Subscription,Region,ResourceNameValue,ResourceNameLocalizedValue,CurrentCount,Limit -Unique |`
Select Subscription, Region,ResourceNameValue,ResourceNameLocalizedValue,@{Name='CurrentCount';E={IF ($_.CurrentCount -eq '0'){'unused'}Else{$_.CurrentCount}}},Limit,@{Name='Percentage_used';E={IF ($_.Percentage_used -ge $percentagelimit){"Running_out $($_.Percentage_used) "}Else{$_.Percentage_used}}}  |`
ConvertTo-Html -Head $CSS ).replace('unused','<font color=red>-0-</font>')).replace('Running_out',"<font color=red>Running_out -  $($_.Percentage_used) %</font>"))
  
$used_skus_only | Out-File "c:\temp\Region_used_skus.html"
 
 ###############
 

 invoke-item "c:\temp\Region_used_skus.html"















