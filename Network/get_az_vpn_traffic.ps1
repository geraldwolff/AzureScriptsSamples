 
 


  connect-AzAccount #-Environmentname azureusgovernment    -Verbose

    $sublist = get-azsubscription | ogv -Title "Select subscriptions to check VPN traffic on:" -PassThru 


    foreach($sub in $sublist)

    {

 
 
         Set-AzContext -Tenant  ($sub.tenantid)
         #get-azsubscription 
 


        $traffic_summary = ''
 
          set-azcontext -Subscription $($sub.Name)
        $rgs = Get-AzResourceGroup 

        foreach($rg in $rgs) 
            {

        

                      $VPNs =   Get-AzVirtualNetworkGatewayConnection -ResourceGroupName $($rg.resourcegroupname) 

                      foreach ($vpn in $vpns) 
                            {

                                $trafficdata =   Get-AzVirtualNetworkGatewayConnection -Name $($vpn.name)  -ResourceGroupName $($rg.resourcegroupname)

                             $traffic_counts =    $trafficdata | select name, EgressBytesTransferred, IngressBytesTransferred, ConnectionStatus
                             $trafficobj = New-Object PSObject


                             $trafficobj | Add-Member -MemberType NoteProperty -Name Connection_name -value $($traffic_counts.name)
                             $trafficobj | Add-Member -MemberType NoteProperty -Name EgressBytesTransferred -value $($traffic_counts.EgressBytesTransferred)
                             $trafficobj | Add-Member -MemberType NoteProperty -Name IngressBytesTransferred -value $($traffic_counts.IngressBytesTransferred)
                             $trafficobj | Add-Member -MemberType NoteProperty -Name COnnectionStatus -value $($traffic_counts.ConnectionStatus)
                             [array]$traffic_summary += $trafficobj


                        }
              }
    


#$traffic_summary

#########################################  Style sheet 
     $CSS = @"
<Title>Azrue VPN Connection traffic Report:$(Get-Date -Format 'dd MMMM yyyy' )</Title>
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

 

$traffic_summary_report = (($traffic_summary |`
Select Connection_name,EgressBytesTransferred,IngressBytesTransferred,ConnectionStatus |`
ConvertTo-Html -Head $CSS ) )   | Out-File "c:\temp\traffic_summary_report_$($sub.name).html"

 Invoke-Item "c:\temp\traffic_summary_report_$($sub.name).html"


 
     }

