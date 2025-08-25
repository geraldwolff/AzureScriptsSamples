import-module az.automation 

 
 connect-azaccount  #-Environment AzureUSGovernment

 import-module az.automation #-verbose


# Login to Azure - if already logged in, use existing credentials.
Write-Host "Authenticating to Azure..." -ForegroundColor Cyan
try
{
    $AzureLogin = Get-AzSubscription
    $currentContext = Get-AzContext
    $token = Get-AzAccessToken 
    if($Token.ExpiresOn -lt $(get-date))
    {
        "Logging you out due to cached token is expired for REST AUTH.  Re-run script"
        $null = Disconnect-AzAccount        
    } 
}
catch
{
    $null = Login-AzAccount
    $AzureLogin = Get-AzSubscription
    $currentContext = Get-AzContext
    $token = Get-AzAccessToken

}


$subscriptions = get-azsubscription 


$subscriptionsselected = $subscriptions | ogv -Title " select subscriptions to extract runbooks from:" -PassThru | Select *


    #$runbookpath = "c:\temp\runbookexports\"
    $runbookpath = "C:\git\AzureScriptsSamples\Runbooks\"
           if (-not (Test-path $runbookpath ))
               {
                    New-Item $runbookpath  -Type Directory
 
    
               }




foreach($subscription in $subscriptions)
{
    set-azcontext -Subscription $($subscription.name)

   $automationaccounts =   get-azresource | where resourcetype -eq 'Microsoft.Automation/automationAccounts'

   $automationaccountsselected = $automationaccounts | ogv -Title "Select the automation to exprt runbooks from :" -PassThru | select name, resourcegroupname 


   foreach($automationaccount IN $automationaccountsselected)
   {

    $runbooks = Get-AzAutomationRunbook   -AutomationAccountName "$($automationaccount.name)" -ResourceGroupName "$($automationaccount.resourcegroupname)"

    #$runbooks = Get-AzAutomationRunbook -AutomationAccountName "Contoso17" -ResourceGroupName "ResourceGroup01"

    $runbooks

        foreach($runbook in $runbooks)
        {
 


        Export-AzAutomationRunbook -ResourceGroupName  "$($automationaccount.resourcegroupname)" -AutomationAccountName "$($automationaccount.name)" -Name "$($runbook.NAME)" -Slot "Published" -OutputFolder "$runbookpa"

        }
         


      
     }
}


 












