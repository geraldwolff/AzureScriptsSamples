# Login to Azure
Connect-AzAccount

$subscriptions = get-azsubscription 

$azarcconnectedextstatus = ''
foreach ($subscription in $subscriptions)
{
  
    # Select a subscription
    Set-AzContext -SubscriptionId $($subscription.id) 

    # Get all Azure Arc enabled servers
    $servers = Get-AzConnectedMachine

    foreach ($server in $servers) {

            $machine = Get-AzConnectedMachine -ResourceGroupName "$($server.ResourceGroupName)" -Name "$($server.Name)"
  #$machine
        # Get the update status of the server
        
       
       
        $updateStatus = Get-AzConnectedMachineExtension -MachineName "$($server.Name)" -ResourceGroupName "$($server.ResourceGroupName)"
          

          foreach($extensionstatus in $updateStatus)
          {
          
          
          
          $arcextensionobj = new-object PSobject

            $arcextensionobj  | Add-Member -MemberType NoteProperty -name Name -value $($extensionstatus.Name)
            $arcextensionobj  | Add-Member -MemberType NoteProperty -name ResourceGroupName -value $($extensionstatus.ResourceGroupName)
            $arcextensionobj  | Add-Member -MemberType NoteProperty -name Location -value $($extensionstatus.Location)
            $arcextensionobj  | Add-Member -MemberType NoteProperty -name TypeHandlerVersion -value $($extensionstatus.TypeHandlerVersion)
            $arcextensionobj  | Add-Member -MemberType NoteProperty -name ProvisioningState -value $($extensionstatus.ProvisioningState)
                       
        [array]$azarcconnectedextstatus += $arcextensionobj
        }
    }
}


$azarcconnectedextstatus





 $date = $(Get-Date -Format 'dd MMMM yyyy' )
 
    $CSS = @"
<Title> Azure Recovery services Storage Report: $date </Title>
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


 

 
 $azarconnectedextdata = ($azarcconnectedextstatus | Select Name, `
Location,`
ResourceGroupName,`
Status,`
TypeHandlerVersion,`
ProvisioningState   | ConvertTo-Html -Head $CSS )  | out-file "c:\temp\azarcconnectedextensionreport.html" 

invoke-item "c:\temp\azarcconnectedextensionreport.html" 



#####################################################################################
 ######### Uncomment and configure to send results to storage account blob 


 
 $date = $(Get-Date -Format 'dd MMMM yyyy' )
 
########### Prepare for storage account export

 $resultsfilename = "azarcconnectedextensionreport.csv"



$csvresults = ($azarcconnectedextstatus   | Select  | Select Name, `
Location,`
ResourceGroupName,`
Status,`
TypeHandlerVersion,`
ProvisioningState )| export-csv $resultsfilename -notypeinformation 



  

# end vmss data 


##### storage subinfo

$Region = "westus"
 $date = Get-Date -Format MMddyyyy
 $subscriptionselected = 'wolffentpsub'



$resourcegroupname = 'wolffautomationrg'
$subscriptioninfo = get-azsubscription -SubscriptionName $subscriptionselected 
$TenantID = $subscriptioninfo | select tenantid
$storageaccountname = 'wolffautosa'
$storagecontainer = 'azarcconnectedextensionreport'
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
       

         Set-azStorageBlobContent -Container $storagecontainer -Blob $resultsfilename  -File $resultsfilename -Context $destContext -FORCE
        
        
 

























