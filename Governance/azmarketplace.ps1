 install-module -name az -allowclobber

 update-module -name az -force 
import-module -name az -force
import-module Az.MarketplaceOrdering


Connect-AzAccount

get-azmarketplaceTerms -publisher "MicrosoftWindowsServer" -Product "WindowsServer" -name "Windows-server-Datacenter" | set-azmarketplaceterms -accept


Get-AzMarketplaceTerms -Publisher "MicrosoftWindowsServer" -Product "WindowsServer" -Name "2012-R2-Datacenter" | set-azmarketplaceterms -accept


Get-AzMarketplaceTerms -Publisher 'MicrosoftWindowsServer' -Product 'WindowsServer' -Name '2019-Datacenter' | set-azmarketplaceterms -accept



Get-AzPriceSheet -Location 'West US 2' -Name 'Standard_LRS' -Product 'AzureStorage' -Publisher 'Microsoft.Azure.Storage'




$subscriptionid = '01e7c251-3bed-4242-9d93-a5851b2e6671'

 
 Invoke-WebRequest -uri https://management.azure.com/subscriptions/$subscriptionId/providers/Microsoft.Consumption/pricesheets/default?api-version=2021-10-01



$webReq = Invoke-WebRequest -Uri https://azure.microsoft.com/api/v1/pricing/virtual-machines/calculator/?culture=en-us | ConvertFrom-Json
foreach($obj in $webReq.offers.psobject.properties)
{
    $obj.value | Add-Member -NotePropertyName Name -NotePropertyValue $obj.Name -PassThru
}


























