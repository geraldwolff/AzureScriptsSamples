  connect-AzAccount #-Environmentname azureusgovernment    -Verbose


  
 $date = get-date 
 
          $ConnectionTraffic = $null
      
      

         $subscriptions  = get-AZsubscription  | select name, ID
            
         foreach ($subscription in $subscriptions )
         {

             set-AZcontext    -SubscriptionName $subscription.name -verbose

             $virtualnetworks  = Get-AZVirtualNetwork  

             $rgs = get-AZresourcegroup 

             foreach ($Rg in $RGs)
             {
          

               $VNETGWConnections =  Get-AZVirtualNetworkGatewayConnection    -ResourceGroupName $($rg.resourcegroupname)
                   foreach($VNETGWConnection in $VNETGWConnections)
                   {
                        $VNETGW =  Get-AZLocalNetworkGateway -ResourceGroupName $($rg.resourcegroupname) 

                        $trafficdata =   Get-AzVirtualNetworkGatewayConnection -Name $($VNETGWConnection.name)  -ResourceGroupName $($rg.resourcegroupname)

                     $traffic_counts = $trafficdata | select name, EgressBytesTransferred, IngressBytesTransferred, ConnectionStatus

                        $Vnetconnobj = new-object PSObject 
 
                                    $Vnetconnobj | add-member  Subscription  $($subscription.name)
                                    $Vnetconnobj | add-member  Resourcegroupname    $($rg.resourcegroupname)
                                    $Vnetconnobj | add-member  Environment   $($VNETGWConnection.Environment)
                                    $Vnetconnobj | add-member  ConnectionName   $($traffic_counts.Name)
                                    $Vnetconnobj | add-member  ConnectionStatus   "$($traffic_counts.ConnectionStatus)"
                                    $Vnetconnobj  | add-member EgressBytesTransferred  "$($traffic_counts.EgressBytesTransferred)"
                                    $Vnetconnobj | add-member  IngressBytesTransferred  "$($traffic_counts.IngressBytesTransferred)"
                                    $Vnetconnobj | add-member  ConnectionType   "$($VNETGWConnection.ConnectionType)"
                                    $Vnetconnobj  | add-member Location  "$($VNETGWConnection.Location)"
                                    $Vnetconnobj | add-member  SharedKey  "$($VNETGWConnection.SharedKey)"
                                    $Vnetconnobj | add-member  AuthorizationKey $($VNETGWConnection.AuthorizationKey)
                                    $Vnetconnobj | add-member  ConnectionMode $($VNETGWConnection.ConnectionMode)
                                    $Vnetconnobj | add-member  ConnectionProtocol $($VNETGWConnection.ConnectionProtocol)
 
                                    $Vnetconnobj | add-member  DpdTimeoutSeconds $($VNETGWConnection.DpdTimeoutSeconds)
 
                                    $Vnetconnobj | add-member  EgressNatRules $($VNETGWConnection.EgressNatRules)
                                    $Vnetconnobj | add-member  EgressNatRulesText $($VNETGWConnection.EgressNatRulesText)
                                    $Vnetconnobj | add-member  EnableBgp $($VNETGWConnection.EnableBgp)
                                    $Vnetconnobj | add-member  EnablePrivateLinkFastPath $($VNETGWConnection.EnablePrivateLinkFastPath)
                                    $Vnetconnobj | add-member  Etag $($VNETGWConnection.Etag)
                                    $Vnetconnobj | add-member  ExpressRouteGatewayBypass $($VNETGWConnection.ExpressRouteGatewayBypass)
                                    $Vnetconnobj | add-member  GatewayCustomBgpIpAddresses $($VNETGWConnection.GatewayCustomBgpIpAddresses)
                                    $Vnetconnobj | add-member  GatewayCustomBgpIpAddressesText $($VNETGWConnection.GatewayCustomBgpIpAddressesText)
                                    $Vnetconnobj | add-member  Id $($VNETGWConnection.Id)
 
                                    $Vnetconnobj | add-member  IngressNatRules $($VNETGWConnection.IngressNatRules)
                                    $Vnetconnobj | add-member  IngressNatRulesText $($VNETGWConnection.IngressNatRulesText)
                                    $Vnetconnobj | add-member  IpsecPolicies $($VNETGWConnection.IpsecPolicies)
                                    $Vnetconnobj | add-member  LocalNetworkGateway2 $($VNETGWConnection.LocalNetworkGateway2)
                                    $Vnetconnobj | add-member  LocalNetworkGateway2Text $($VNETGWConnection.LocalNetworkGateway2Text)
 
                                    $Vnetconnobj | add-member  Name $($VNETGWConnection.Name)
                                    $Vnetconnobj | add-member  Peer $($VNETGWConnection.Peer)
                                    $Vnetconnobj | add-member  PeerText $($VNETGWConnection.PeerText)
                                    $Vnetconnobj | add-member  ProvisioningState $($VNETGWConnection.ProvisioningState)
 
                                    $Vnetconnobj | add-member  ResourceGuid $($VNETGWConnection.ResourceGuid)
                                    $Vnetconnobj | add-member  RoutingWeight $($VNETGWConnection.RoutingWeight)
 
                                    $Vnetconnobj | add-member  Tag $($VNETGWConnection.Tag)
                                    $Vnetconnobj | add-member  TagsTable $($VNETGWConnection.TagsTable)
                                    $Vnetconnobj | add-member  TrafficSelectorPolicies $($VNETGWConnection.TrafficSelectorPolicies)
                                    $Vnetconnobj | add-member  TunnelConnectionStatus $($VNETGWConnection.TunnelConnectionStatus)
                                    $Vnetconnobj | add-member  TunnelConnectionStatusText $($VNETGWConnection.TunnelConnectionStatusText)
                                    $Vnetconnobj | add-member  Type $($VNETGWConnection.Type)
                                    $Vnetconnobj | add-member  UseLocalAzureIpAddress $($VNETGWConnection.UseLocalAzureIpAddress)
                                    $Vnetconnobj | add-member  UsePolicyBasedTrafficSelectors $($VNETGWConnection.UsePolicyBasedTrafficSelectors)
                                    $Vnetconnobj | add-member  VirtualNetworkGateway1 $($VNETGWConnection.VirtualNetworkGateway1)
                                    $Vnetconnobj | add-member  VirtualNetworkGateway1Text $($VNETGWConnection.VirtualNetworkGateway1Text)
                                    $Vnetconnobj | add-member  VirtualNetworkGateway2 $($VNETGWConnection.VirtualNetworkGateway2)
                                    $Vnetconnobj | add-member  VirtualNetworkGateway2Text $($VNETGWConnection.VirtualNetworkGateway2Text)

 

                                   # $subobj | export-csv "c:\temp\address_prefixes_in_use.csv" -append -notypeinformation
                                   [array]$ConnectionTraffic +=  $Vnetconnobj
                    }

  


                }
 

         }
 



 $date = $(Get-Date -Format 'dd MMMM yyyy' )
 
    $CSS = @"
<Title> Azure Gateway Connection Traffic Report: $date </Title>
<Style>
th {
	font: bold 11px "Trebuchet MS", Verdana, Arial, Helvetica,
	sans-serif;
	color: #C1DAD7;
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


#$Address_prefixes = import-csv "c:\temp\address_prefixes_in_use.csv"

 
$ConnectionTraffic_report = ($ConnectionTraffic    | Select  Subscription, Resourcegroupname , Environment ,ConnectionName,ConnectionStatus,EgressBytesTransferred ,IngressBytesTransferred, ConnectionType,Location, SharedKey |`   
ConvertTo-Html -Head $CSS ).replace('0','<font color=red>0</font>') | out-file c:\temp\ConnectionTraffic_report.html
 
 
  invoke-item c:\temp\ConnectionTraffic_report.html




  $resultsfilename = 'networktrafficreport.csv'


$Connectionfullrecords = $ConnectionTraffic | select AuthorizationKey, `
ConnectionMode, `
ConnectionName, `
ConnectionProtocol, `
ConnectionStatus, `
ConnectionType, `
DpdTimeoutSeconds, `
EgressBytesTransferred, `
EgressNatRules, `
EgressNatRulesText, `
EnableBgp, `
EnablePrivateLinkFastPath, `
Environment, `
Etag, `
ExpressRouteGatewayBypass, `
GatewayCustomBgpIpAddresses, `
GatewayCustomBgpIpAddressesText, `
Id, `
IngressBytesTransferred, `
IngressNatRules, `
IngressNatRulesText, `
IpsecPolicies, `
LocalNetworkGateway2, `
LocalNetworkGateway2Text, `
Location, `
Name, `
Peer, `
PeerText, `
ProvisioningState, `
ResourceGroupName, `
ResourceGuid, `
RoutingWeight, `
SharedKey, `
Subscription, `
Tag, `
TagsTable, `
TrafficSelectorPolicies, `
TunnelConnectionStatus, `
TunnelConnectionStatusText, `
Type, `
UseLocalAzureIpAddress, `
UsePolicyBasedTrafficSelectors, `
VirtualNetworkGateway1, `
VirtualNetworkGateway1Text, `
VirtualNetworkGateway2, `
VirtualNetworkGateway2Text `
| export-csv $resultsfilename




 


##### storage subinfo

$Region = "West US"

 $subscriptionselected = '<subscription>'



$resourcegroupname = 'wolffautomationrg'
$subscriptioninfo = get-azsubscription -SubscriptionName $subscriptionselected 
$TenantID = $subscriptioninfo | Select-Object tenantid
$storageaccountname = 'wolffautosa'
$storagecontainer = 'networktraffic'
### end storagesub info

set-azcontext -Subscription $($subscriptioninfo.Name)  -Tenant $($TenantID.TenantId)


#BEGIN Create Storage Accounts
 
 
 
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
       

         Set-azStorageBlobContent -Container $storagecontainer -Blob $Resultsfilename  -File $Resultsfilename -Context $destContext -force
        
 




