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

Other uris :
 #$uri = "https://management.azure.com/subscriptions/$($sub.id)/providers/Microsoft.Web/skus?api-version=2022-03-01"

#$uri = "https://management.azure.com/subscriptions/$($sub.id)/resourceGroups/wolffappserviceplanrg/providers/Microsoft.Web/serverfarms/wolffappserviceplan01?api-version=2022-09-01"
#$uri = "https://management.azure.com/subscriptions/$($sub.id)/resourceGroups/wolffappserviceplanrg/providers/Microsoft.Web/serverfarms/wolffappserviceplan01/capabilities?api-version=2022-03-01"



 
    Script Name: get_appserviceplan_hw_skus_html_report.ps1
    Description: Custom script collect Subscription HW skus available for Application Service plans 
    NOTE:   Scripts creates an HTML report 
           "c:\temp\appserviceplan_hwSkus.html"
           

#> 

####### Suppress powershell module changes warning during execution 

  Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings 'true'

   

 connect-azaccount 

 $subs = get-azsubscription  



 foreach($sub in $subs) 
 {
   set-azcontext -Subscription $sub.Name
 
 

          Write-Host "Authenticating to Azure..." -ForegroundColor Cyan
            try
            {
                $AzureLogin = Get-AzSubscription -SubscriptionId $($sub.id)
                $currentContext = Get-AzContext
                $token = Get-AzAccessToken -TenantId $($sub.TenantId)
                if($Token.ExpiresOn -lt $(get-date))
                {
                    "Logging you out due to cached token is expired for REST AUTH.  Re-run script"
                    #$null = Disconnect-AzAccount        
                } 
   
            }
            catch
            {

                $AzureLogin = Get-AzSubscription  -SubscriptionId $($sub.id)
                $currentContext = Get-AzContext
                $token = Get-AzAccessToken -TenantId $($sub.TenantId)
             }
                   
 

         function BuildBody
        (
            [parameter(mandatory=$True)]
            [string]$method
        )
        {
            $BuildBody = @{
            Headers = @{
                Authorization = "Bearer $($token.token)"
                'Content-Type' = 'application/json'
            }
            Method = $Method
            UseBasicParsing = $true
            }
            $BuildBody
        }  
 
          $body = BuildBody GET

         $sub = get-azsubscription -SubscriptionName "$($sub.name)"
          set-azcontext -Subscription $sub.Name

    
         $skulist = ''
         $rgs = get-azresourcegroup 

         $rg

         foreach($rg in $rgs) 
         {
         $apiversion = '2021-04-01'
            $appserviceplans = get-AzAppServicePlan -ResourceGroupName $($rg.ResourceGroupName)

            foreach($appserviceplan in $appserviceplans) 
            {
                $uri = "https://management.azure.com/subscriptions/$($sub.id)/resourceGroups/$($rg.name)/providers/Microsoft.Web/serverfarms/$($appserviceplan.name)/skus?api-version=$apiversion"

                $response = Invoke-RestMethod -Uri $uri -Headers $($body.Headers) -Method GET



           
                ($response.value).GetEnumerator() | foreach-object {

                            write-host "Name : $($_.sku.name)  : Tier $($_.sku.tier) " -ForegroundColor green 
                            write-host "Capacity:  Min $($_.capacity.Minimum) Max: $($_.capacity.Maximum) ScaleType : $($_.scaletype)  elasticMaximum :$($_.capacity.elasticMaximum) elasticScalingAllowed : $($_.capacity.elasticScalingAllowed) " -ForegroundColor Cyan 
                            write-host "" -ForegroundColor green 
 
                             $Skuobj = new-object PSObject 

                             $skuobj | Add-Member -MemberType NoteProperty -Name name -Value $($_.sku.name)
                             $skuobj | Add-Member -MemberType NoteProperty -Name tier -Value $($_.sku.tier)
                             $skuobj | Add-Member -MemberType NoteProperty -Name capacityMin -Value $($_.capacity.Minimum)
                             $skuobj | Add-Member -MemberType NoteProperty -Name capacityMax -Value $($_.capacity.Maximum)
                             $skuobj | Add-Member -MemberType NoteProperty -Name scaletype -Value $($_.capacity.scaletype)
                             $skuobj | Add-Member -MemberType NoteProperty -Name elasticMaximum -Value $($_.capacity.elasticMaximum)
                             $skuobj | Add-Member -MemberType NoteProperty -Name elasticScalingAllowed -Value $($_.capacity.elasticScalingAllowed)
                             $skuobj | Add-Member -MemberType NoteProperty -Name Subscriptionname -Value $($sub.name)
                             $skuobj | Add-Member -MemberType NoteProperty -Name SubscriptionID -Value $($sub.ID)
                             $skuobj | Add-Member -MemberType NoteProperty -Name Appserviceplan -Value $($appserviceplan.name)
                             $skuobj | Add-Member -MemberType NoteProperty -Name Location -Value $($appserviceplan.location)


                             [array]$skulist += $skuobj

                 }
            }
    }
}






$CSS = @"

<Title>Azure App Service Plan Skus : $(Get-Date -Format 'dd MMMM yyyy') </Title>

 <H2>Azure App Service Plan Skus:$(Get-Date -Format 'dd MMMM yyyy')  </H2>

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





($skulist | select name ,tier,capacityMin, capacityMax, scaletype, elasticMaximum, elasticScalingAllowed,Subscriptionname, SubscriptionID,Appserviceplan ,location  `
| ConvertTo-Html -Head $CSS ) `
|  Out-File "c:\temp\appserviceplan_hwSkus.html"


invoke-item "c:\temp\appserviceplan_hwSkus.html"