
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

    Script Name: check_sku_quota_use_percentage
    Description: Custom script to check on quota percentage based on requested use 
    NOTE:   Scripts creates an HTML report with the percentage against requested amount and recommended amount to increase limit


#> 

####### Suppress powershell module changes warning during execution 

 
        param(
            [Parameter(Mandatory = $true)]
            [string]$SubscriptionId,

            [Parameter(Mandatory = $true)]
            [string]$Location,

            [Parameter(Mandatory = $true)]
            [string]$SkuName,

            [Parameter(Mandatory = $true)]
            [int]$Threshold,

            [Parameter(Mandatory = $true)]
            [int]$Corecountrequests
        )
 
         sl 'C:\Users\jerrywolff\OneDrive - Microsoft\Documents\azure\PS1\Quota'


          Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings 'true'
        
        import-module az.capacity -Force -ErrorAction SilentlyContinue
        import-module  az.quota -Force -ErrorAction SilentlyContinue


         connect-azaccount  # -identity

        ## Cleanup

        $percentagelimit = $Threshold

        $usageSummary = $null 

        
        $subs = get-Azsubscription -SubscriptionId $SubscriptionId
 
       

        $subid = $subs.id
        $subname = $($subs.name) 
 
                Set-Azcontext -subscriptionname  $subname 
                  
         $region =   get-azlocation | where-object {$_.location -eq "$Location" }
 
    If( $($region.Location) -eq $null )
    {
            write-host "$Location was not found  Please check spelling and or use the location name ex: 'centralus' instead of 'Central US' " -ForegroundColor Red -BackgroundColor white

            $validregions = get-azlocation | select Location 

            Write-host " Valid region/location names are: $($validregions.location)   "   -ForegroundColor Red -BackgroundColor white
            exit

         }
         Else
         {
              write-host "$($region.Displayname)" -ForegroundColor red 


   ########################## SKU check 
         
        #$skuname = 'standardFFamily'
            $regionquotausage =    Get-AzVmUsage –Location $Location   -ErrorAction SilentlyContinue

        if(!($($regionquotausage.name.value) | where-object {$_ -eq "$skuname"}) )
        {
                Write-Warning " $skuname was not found or is not properly named Please try one of the following " 
                write-host "$($regionquotausage.name.value)" -ForegroundColor DarkRed -BackgroundColor white  
                exit
         }
          else{
   
 
                 $regionquotausage = $($regionquotausage.name.value)  | Where-Object {$_ -eq "$skuname"}
                write-host " $($regionquotausage.name.Value)" -ForegroundColor Green
          }
 
   }
          
          
                    #        Calculate the percentage used
                            #$percentageUsed = [math]::Round(($regionquotausage.CurrentValue / $regionquotausage.Limit) * 100)

                          

                                    $vmobj = new-object PSObject 

                                        $usedCount = [int]($($regionquotausage.CurrentValue))   
                                        $quota = [int]($($regionquotausage.Limit))

                                        if ($quota -gt 0)
                                        {
                                        $Percentage = ($usedCount / $quota) * 100
                                        }
                                        else
                                        {
                                            $Percentage = 0
                                        }

                                        If(($usedcount + $Corecountrequests) -gt $quota )
                                        {
 
                                         $Recommended_increase  = (($quota + $Corecountrequests) +  ($quota + $Corecountrequests) * (20/100) )

                                         }


                                        $vmobj | add-member  -membertype NoteProperty -name   Subscription  -value "$subname" 
                                        $vmobj | add-member  -membertype NoteProperty -name   Region  -value "$Location"                                                                                    
                                        $vmobj | add-member  -membertype NoteProperty -name   ResourceNameValue  -value "$($regionquotausage.Name.Value)"  
                                        $vmobj | add-member  -membertype NoteProperty -name   ResourceNameLocalizedValue  -value "$($regionquotausage.Name.LocalizedValue)"                                                                         
                                        $vmobj | add-member  -membertype NoteProperty -name   CurrentCount  -value "$($regionquotausage.CurrentValue)"         
                                        $vmobj | add-member  -membertype NoteProperty -name   Limit  -value "$($regionquotausage.Limit)"  
                                        $vmobj | add-member  -membertype NoteProperty -name   RequestedCoreAmount  -value    $Corecountrequests                                                  
                                        $vmobj | add-member  -membertype NoteProperty -name   Percentage_used   -value    $Percentage   
                                        $vmobj | add-member  -membertype NoteProperty -name   Recommended_increase   -value   $Recommended_increase                                         


                                  [array]$usageSummary +=  $vmobj  
                         

       
 

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
        Select Subscription, Region,ResourceNameValue,ResourceNameLocalizedValue,@{Name='CurrentCount';E={IF ($_.CurrentCount -eq '0'){'unused'}Else{$_.CurrentCount}}},Limit,@{Name='Percentage_used';E={IF ($_.Percentage_used -ge $percentagelimit){"Running_out $($_.Percentage_used)" }Else{$_.Percentage_used}}},RequestedCoreAmount, Recommended_increase |`
        ConvertTo-Html -Head $CSS ).replace('unused','<font color=red>-0-</font>')).replace('Running_out',"<font color=red>Running_out -  $($_.Percentage_used) %</font>"))  
        
        $usage_report_detail | Out-File "c:\temp\quota_check.html"
 
 invoke-item "c:\temp\quota_check.html"
