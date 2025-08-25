

# Login to Azure
Connect-AzAccount

$subscriptions = get-azsubscription 

$subselected = $subscriptions | ogv -Title " select subscription to use:" -PassThru | select * 

$laws = Get-AzOperationalInsightsWorkspace 


$lawselected = $laws | ogv -Title "select the log anaytics workspace to send diagnostic logs to: " -PassThru | select * -first 1

foreach ($subscription in $subselected)
{
  
    # Select a subscription
    Set-AzContext -SubscriptionId $($subscription.id) 

    # Get all Azure Arc enabled servers
 $resources = get-azresource 


     foreach($resource in $resources)
     {
 
        $subscriptionId = (Get-AzContext).Subscription.Id
        $metric = @()
        $log = @()
        try
        {
            if (Get-AzDiagnosticSettingCategory -ResourceId $($resource.Resourceid) -erroraction ignore)
            {
                $categories = Get-AzDiagnosticSettingCategory -ResourceId $($resource.Resourceid)  -erroraction Ignore
            #$categories | ForEach-Object {if($_.CategoryType -eq "Metrics"){$metric+=New-AzDiagnosticSettingMetricSettingsObject -Enabled $true -Category $_.Name -RetentionPolicyDay 7 -RetentionPolicyEnabled $true} else{$log+=New-AzDiagnosticSettingLogSettingsObject -Enabled $true -Category $_.Name -RetentionPolicyDay 7 -RetentionPolicyEnabled $true}}
            $categories | ForEach-Object {if($_.CategoryType -eq "Metrics"){$metric+=New-AzDiagnosticSettingMetricSettingsObject -Enabled $true -Category $_.Name  -RetentionPolicyDay 7 -RetentionPolicyEnabled $true  } else{$log+=New-AzDiagnosticSettingLogSettingsObject -Enabled $true -Category $_.Name -RetentionPolicyDay 7 -RetentionPolicyEnabled $true}}  -ErrorAction Ignore

            }
        }
        catch
        {
            Write-warning "$($resource.resourcetype) is not supported for diags"
        }
 

         New-AzDiagnosticSetting -Name "$($resource.Name)_diags" -ResourceId $($resource.resourceid) -WorkspaceId "$($lawselected.ResourceId)" -Log $log -Metric $metric -erroraction Ignore

        get-AzDiagnosticSetting -ResourceId $($resource.resourceid)  -Name  "$($resource.Name)_diags"  -erroraction Ignore
     }




 }


















