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

#> 
  Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings 'true'

    import-module Az.Billing  

  
  $erroractionpreference = 'silentlycontinue'


Connect-AzAccount -identity # -Environment AzureUSGovernment

$tenantlist = get-aztenant | Select-Object -property *  
$subinfo  = ''
$submetadata = ''


foreach($tenant in $tenantlist)
{
    $tenant.ExtendedProperties.GetEnumerator() | ForEach-Object {
                      Write-Output "  $($_.key)   = $($_.Value)" }
  
 

    $subscriptions = get-azsubscription -TenantId $($tenant.id) 

    $subsallfields = $subscriptions | Select-Object *




        Foreach ($sub in $subsallfields)
        {
            Set-AzContext -Subscription $($sub.Name) -Tenant $sub.TenantId | out-null
  

            $subdataobj = new-object PSobject 

            $sub.ExtendedProperties.GetEnumerator() | ForEach-Object {

                   #Write-Output "$($_.key)   = $($_.Value)" 
 
                 $subdataobj | add-member -membertype Noteproperty -name $($_.key) -value $($_.value)

                  }



                Write-host " Billing account INformation " -ForegroundColor Green 

                     $billingdetails =    get-azbillingaccount -ExpandBillingProfile   -IncludeAddress -ExpandInvoiceSection

                      # $billingdetails 
                       $billingdetails.SoldTo | ForEach-Object {
                          
                         <# Write-Output "Firstname  = $($_.Firstname)"
                           Write-Output "Lastname = $($_.LastName)" 
                           Write-Output "Email = $($_.Email)" 
                           Write-Output "Phonenumber   = $($_.PhoneNumber)" 
                           Write-Output "Region  = $($_.Region)" 
                           #>
                        $subdataobj | add-member -membertype Noteproperty -name Subscription -value $($sub.name)
                        $subdataobj | add-member -membertype Noteproperty -name Firstname -value $($_.Firstname)
                        $subdataobj | add-member -membertype Noteproperty -name Lastname -value $($_.LastName)
                        $subdataobj | add-member -membertype Noteproperty -name Email -value $($_.Email)
                        $subdataobj | add-member -membertype Noteproperty -name Phonenumber -value $($_.PhoneNumber)
                        $subdataobj | add-member -membertype Noteproperty -name Region -value $($_.Region)
                        $subdataobj | add-member -membertype Noteproperty -name AddressLine1 -value $($_.AddressLine1)
                        $subdataobj | add-member -membertype Noteproperty -name City -value $($_.City)

                   } 
  

             
                  
  
  ######### Find Subscription owners 


            foreach($mtentnat in $($sub.ManagedByTenantIds))
            {
        
                $managedbytenantidrec += $($sub.ManagedByTenantIds)

            }

               $ownerlist =  get-AzRoleAssignment    -Scope "/subscriptions/$($sub.ID)"    -RoleDefinitionName owner
 
               $owners = $($ownerlist.SignInName)
 

                foreach($owner in $owners)
                {

                    $ownerobj = new-object PSObject 
                    if($($owner) -ne $null)
                    {
                 
                        $ownerobj | add-member -MemberType NoteProperty -Name ownername -value "'$($owner)'"
                    }
      

                    [Array]$ownerrec += $ownerobj



                }

#################  Add ownsers to hashtable record 


                 $subdataobj | Add-Member -MemberType NoteProperty -Name Owners   -value  "$($ownerrec.ownername)"
                  [array]$subinfo += $subobj 

         #################  Billing account information   
            
            
                $billing_account = Get-AzBillingAccount  -IncludeAddress

                ####### collect pretaxcost per subscription

 
                  $costalls =  Get-AzConsumptionUsageDetail -BillingPeriodName 202212  -IncludeAdditionalProperties   



                        $costfields = $costalls | select PretaxCost

 


                        foreach($itemcost in $costfields)
                        {

                            $costobj = new-object PSObject 
                            $costobj | Add-Member -MemberType NoteProperty -name pretaxcost -value $($itemcost.PretaxCost)
                            [array]$costsums += $costobj
     


                        }


                         [decimal]$totalcost = ($costsums | measure-object 'Pretaxcost' -sum).sum


                           

            #############################
            ## Assemble Report 


                $subobj = New-Object PSObject 

                $subobj | Add-Member -MemberType NoteProperty -Name Name   -value $($sub.Name) 
                $subobj | Add-Member -MemberType NoteProperty -Name State   -value $($sub.State) 
                $subobj | Add-Member -MemberType NoteProperty -Name SubscriptionId   -value $($sub.SubscriptionId) 
                $subobj | Add-Member -MemberType NoteProperty -Name HomeTenantId   -value $($sub.HomeTenantId) 
                $subobj | Add-Member -MemberType NoteProperty -Name ManagedByTenantIds   -value $managedbytenantidrec
                $subobj | Add-Member -MemberType NoteProperty -Name Owners   -value  "$($ownerrec.ownername)"
                $subobj | Add-Member -MemberType NoteProperty -Name BillingAccount  -value  "$($billing_account.Name) "
                $subobj | Add-Member -MemberType NoteProperty -Name currentcost  -value  "$totalcost"
                $subobj | Add-Member -MemberType NoteProperty -Name PhoneNumber   -value  "$($billing_account.soldto.phonenumber) "
                $subobj | Add-Member -MemberType NoteProperty -Name FirstName   -value  "$($billing_account.soldto.FirstName) "
                $subobj | Add-Member -MemberType NoteProperty -Name LastName   -value  "$($billing_account.soldto.LastName) "
                $subobj | Add-Member -MemberType NoteProperty -Name SoldTo   -value  "$($billing_account.soldto.Email) "
                $subobj | Add-Member -MemberType NoteProperty -Name AccountStatus   -value  "$($billing_account.AccountStatus)"
                $subobj | Add-Member -MemberType NoteProperty -Name Companyname   -value  "$($billing_account.SoldTo.CompanyName)"



 
             [array]$submetadata += $subdataobj
        
                 $managedbytenantidrec= ''
                 $ownerrec = ''
                  $billing_account = ''
        }

}
        
            $submetadata

            $subinfo


 
 
########### Prepare for storage account export

 
$csvresults = $submetadata | select-object  Tenants, `
Subscription, `
Environment, `
SubscriptionPolices, `
Account, `
AuthorizationSource, `
Owners, `
HomeTenant , `
Firstname, `
Lastname, `
Email, `
Phonenumber, `
Region, `
AddressLine1, `
City   



$csvresults2 = $subinfo | select name,  state, SubscriptionId, HomeTenantId, ManagedByTenantIds, owners,BillingAccount,currentcost, PhoneNumber,FirstName,LastName,SoldTo,AccountStatus, Companyname  




 
 $resultsfilename1 = "Tenant_subscription_details.csv"

  $resultsfilename2 = "Tenant_subscription_owners.csv"



$csvresults  | export-csv $resultsfilename1  -NoTypeInformation   

$csvresults2  | export-csv $resultsfilename2  -NoTypeInformation   

 
# end vmss data 


##### storage subinfo

$Region =  "West US"

 $subscriptionselected = 'Subscription'



$resourcegroupname = 'wolffautorg'
$subscriptioninfo = get-azsubscription -SubscriptionName $subscriptionselected 
$TenantID = $subscriptioninfo | Select-Object tenantid
$storageaccountname = 'wolffgovernancesa'
$storagecontainer = 'automationresults'


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
        $StorageKey = (Get-AzStorageAccountKey -ResourceGroupName $resourcegroupname -StorageAccountName $storageaccountname).value | select -first 1
        $destContext = New-azStorageContext  -StorageAccountName $storageaccountname `
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
       

         Set-azStorageBlobContent -Container $storagecontainer -Blob $resultsfilename1  -File $resultsfilename1 -Context $destContext -force
        
        Set-azStorageBlobContent -Container $storagecontainer -Blob $resultsfilename2  -File $resultsfilename2   -Context $destContext -force
 
 
     
 
 






