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

 


 Connect-AzAccount #-identity


     $token = Get-AzAccessToken

 $date = get-date 
 $Azrolesreport = ''

 
        # Authenticate to Azure

                # Switch to Azure Resource Manager mode
                #switch-AzureMode -Name AzureResourceManager

                <# Select an Azure Subscription for which to report usage data #>
                $subscriptions =  Get-AzSubscription  
               

       

      
   


        foreach($sub in $subscriptions) 
        {

                $subscriptionName = $sub.name
          

                    set-AZcontext -subscription $subscriptionname 
                    
         $token = Get-AzAccessToken

              $rgs = Get-AzResourceGroup


              foreach ( $rg in $rgs) 
                {
                       $roledetails =  Get-AzRoleAssignment -ResourceGroupName  $($rg.ResourceGroupName) 


                   foreach($roleassignment in  $roledetails) 
                   {

                           $roleobj = new-object PSObject 

                            
                           $roleobj | Add-Member -MemberType NoteProperty -name ResourceGroup -value $($rg.ResourceGroupName)
                           $roleobj | Add-Member -MemberType NoteProperty -name DisplayName -value $($roleassignment.DisplayName)
                           $roleobj | Add-Member -MemberType NoteProperty -name SignInName -value $($roleassignment.SignInName)
                           $roleobj | Add-Member -MemberType NoteProperty -name RoleDefinitionName -value $($roleassignment.RoleDefinitionName)
                           $roleobj | Add-Member -MemberType NoteProperty -name Subscriptionname -value $($sub.name)
                           $roleobj | Add-Member -MemberType NoteProperty -name Subscriptionid -value $($sub.Id)
                           $roleobj | Add-Member -MemberType NoteProperty -name ObjectType -value $($roleassignment.ObjectType)
                           $roleobj | Add-Member -MemberType NoteProperty -name CanDelegate -value $($roleassignment.CanDelegate)
                           $roleobj | Add-Member -MemberType NoteProperty -name Scope -value $($roleassignment.Scope)
                           [array]$Azrolesreport += $roleobj



                   }

            }
             
     }
 
  

  $resultsfilename = "role_audit_report.csv"

   $Azrolesreport  | Select  ResourceGroup, DisplayName , SignInName, RoleDefinitionName,Subscriptionname,Subscriptionid, ObjectType, CanDelegate |`   
   export-csv $resultsfilename  -NoTypeInformation   

 


$Region =  "West US"

 $subscriptionselected = 'Subscription'



$resourcegroupname = 'wolffautomationrg'
$subscriptioninfo = get-azsubscription -SubscriptionName $subscriptionselected 
$TenantID = $subscriptioninfo | Select-Object tenantid
$storageaccountname = 'wolffautosa'
$storagecontainer = 'rolesaudit'


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
       

         Set-azStorageBlobContent -Container $storagecontainer -Blob $resultsfilename  -File $resultsfilename -Context $destContext -Force
 
 

