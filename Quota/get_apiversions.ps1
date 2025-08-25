#get-azresourceprovider 




 $((Get-AzResourceProvider -ProviderNamespace Microsoft.Web).ResourceTypes | ?{$_.ResourceTypeName -eq "serverFarms"}).ApiVersions









