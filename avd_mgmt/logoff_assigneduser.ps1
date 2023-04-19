 $account = connect-azaccount -id #-Environment AzureUSGovernment 

 $subs = get-azsubscription  -SubscriptionName $($account.Context.Subscription.Name)



                $workspace = Get-AzWvdWorkspace -ResourceGroupName $($vm.ResourceGroupName) -SubscriptionId  $subscriptionId 

                $hostpool = Get-AzWvdHostPool -ResourceGroupName $($vm.ResourceGroupName) -SubscriptionId  $subscriptionId 
                $appgroup = Get-AzWvdApplicationGroup -ResourceGroupName $($vm.ResourceGroupName) -SubscriptionId  $subscriptionId 
                $sessionhost = Get-AzWvdSessionHost -HostPoolName $($hostpool.name) -ResourceGroupName $($vm.ResourceGroupName) -SubscriptionId  $subscriptionId 



                $connectedusernames = Get-AzWvdSessionHost -ResourceGroupName $resourceGroupName -HostPoolName "$($hostpool.name)" `
                 -SubscriptionId $subscriptionId `
                     -Name $vmName `
                    | Select-Object -ExpandProperty assigneduser
 


$server   = "$Env:computername"
$username =  (($connectedusernames) -split('@'))[0]

 
 
 $quserResult = quser  /server:$server 2>&1
	If ( $quserResult.Count -gt 0 )
{
		$quserRegex = $quserResult | ForEach-Object -Process { $_ -replace '\s{2,}',',' }
		$quserObject = $quserRegex | ConvertFrom-Csv
		$userSession = $quserObject | Where-Object -FilterScript { $_.USERNAME -eq "$username" }
$userSession

		If ( $userSession )
		{


			 logoff $userSession.ID /server:$computer
		}
	}



