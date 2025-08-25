Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings 'true'

Connect-AzAccount #-identity

$date = get-date
$Azrolesreport = ''

$subscriptions =  Get-AzSubscription  

foreach($sub in $subscriptions) 
{
    $subscriptionName = $sub.name
    $token = Get-AzAccessToken
    set-AZcontext -subscription $subscriptionname 

    $resources = (Get-AzResource )

    $i = 0

    foreach($resource in  $resources )
    {
        $i = $i +1
        write-host " $($resource.name)  - $($resources.count -$i)" -ForegroundColor Green

        $allassignments = Get-AzRoleAssignment -Scope $resource.ResourceId

        foreach($assignment in $allassignments)
        {
            if($($assignment.Scope) -eq $($resource.ResourceId))
            {
                $inheritancesource = "made directly on the resource $($resource.Name)"
                $inheritance = 'no'
                write-host "$inheritance" -ForegroundColor cyan
            }
            else
            {
                $inheritancesource = "inherited from scope $($assignment.Scope)"
                $inheritance = 'yes'
            }
            try  
                {  
                    # Attempt to get the user  
                    $user = Get-AzADUser -ObjectId $($assignment.objectid)  -erroraction ignore
  
                    if($user -ne $null)  
                    {  
                        # Print the user, resource, and role details  
                      #  Write-Output "User: $($user.DisplayName) Resource: $($resource.Name) Role: $($roleDefinition.Name) Role Description: $($roleDefinition.Description)"  
                        $username = $($user.DisplayName)
                    }  
                }  
                catch  
                {  
                    # If the user retrieval failed, it might be a group  
                    try  
                    {  
                        # Attempt to get the group  
                        $group = Get-AzADGroup -ObjectId $objectId  
  
                        if($group -ne $null)  
                        {  
                            # Print the group, resource, and role details  
                           # Write-Output "Group: $($group.DisplayName) Resource: $($resource.Name) Role: $($roleDefinition.Name) Role Description: $($roleDefinition.Description)"  
                            $groupname = $($group.DisplayName)
                        }  
                    }  
                    catch  
                    {  
                        # If the group retrieval also failed, it might be a service principal or something else  
                        #Write-Output "Unrecognized ObjectId: $objectId Resource: $($resource.Name) Role: $($roleDefinition.Name) Role Description: $($roleDefinition.Description)" 
                        $groupname = 'none' 
                    }  
                } 




            $roleobj = new-object PSObject 

            $roleobj | Add-Member -MemberType NoteProperty -name ResourceGroup -value $resource.ResourceGroupName
            $roleobj | Add-Member -MemberType NoteProperty -name RoleAssignmentName -value $($assignment.DisplayName)
            $roleobj | Add-Member -MemberType NoteProperty -name RoleAssignmentID -value $($assignment.RoleAssignmentId)
            $roleobj | Add-Member -MemberType NoteProperty -name inheritance -value $inheritance
            $roleobj | Add-Member -MemberType NoteProperty -name user -value $username
            $roleobj | Add-Member -MemberType NoteProperty -name Group -value $groupname
            $roleobj | Add-Member -MemberType NoteProperty -name inheritancesource -value $inheritancesource
            $roleobj | Add-Member -MemberType NoteProperty -name DisplayName -value $($assignment.DisplayName)
            $roleobj | Add-Member -MemberType NoteProperty -name SignInName -value $($assignment.SignInName)
            $roleobj | Add-Member -MemberType NoteProperty -name RoleDefinitionName -value $($assignment.RoleDefinitionName)
            $roleobj | Add-Member -MemberType NoteProperty -name Subscriptionname -value $($sub.name)
            $roleobj | Add-Member -MemberType NoteProperty -name Subscriptionid -value $($sub.Id)
            $roleobj | Add-Member -MemberType NoteProperty -name ObjectType -value $($assignment.ObjectType)
            $roleobj | Add-Member -MemberType NoteProperty -name CanDelegate -value $($assignment.CanDelegate)
            $roleobj | Add-Member -MemberType NoteProperty -name Scope -value $($assignment.Scope)
            $roleobj | Add-Member -MemberType NoteProperty -name Resource -value $($resource.name)
            $roleobj | Add-Member -MemberType NoteProperty -name resourcetype -value $($resource.ResourceType)

            if( $($resource.Tags) ) 
            {
                ($($resource.TAGS)).GetEnumerator() | foreach-object {
                    $roleobj | Add-Member -MemberType NoteProperty -name $($_.key) -value $($_.value)
                }              
            }
            else
            {
                $roleobj | Add-Member -MemberType NoteProperty -name tag -value none
            }

         

            [array]$Azrolesreport += $roleobj
        }

        Write-Progress -Activity "Getting role assignments for $resource" -PercentComplete ($resources.IndexOf($resource) / $resources.Count * 100)
    }
}

          
 
    $CSS = @" 
  Azure Role Audit $date
<Title> Azure Role Audit $date Report: $date </Title>
<Style>
th {
	font: bold 11px "Trebuchet MS", Verdana, Arial, Helvetica,
	sans-serif;
	color: #FFFFFF;
	border-right: 1px solid #4B0082;
	border-bottom: 1px solid #4B0082;
	border-top: 1px solid #4B0082;
	letter-spacing: 2px;
	text-transform: uppercase;
	text-align: left;
	padding: 6px 6px 6px 12px;
	background: #5F9EA0;
}
td {
	font: 11px "Trebuchet MS", Verdana, Arial, Helvetica,
	sans-serif;
	border-right: 1px solid #4B0082;
	border-bottom: 1px solid #4B0082;
	background: #fff;
	padding: 6px 6px 6px 12px;
	color: #4B0082;
}
</Style>
"@


 

 

 ((($Azrolesreport| SELECT  ResourceGroup `
       ,resource `
      ,RoleAssignmentName `
      ,RoleAssignmentID `
      ,inheritance `
      ,inheritancesource `
      ,displayname `
      ,SignInName `
      ,RoleDefinitionName `
      ,Subscriptionname `
      ,Subscriptionid `
      ,ObjectType `
      ,CanDelegate `
      ,Scope `
      ,resourcetype `
      ,purpose `
      ,Owner | `
ConvertTo-Html -Head $CSS ).replace("root","<font color=red>root</font>")).replace("subscriptions","<font color=green>subscriptions</font>"))| out-file "C:\TEMP\azure_role_audit.html"
Invoke-Item    "C:\TEMP\azure_role_audit.html"                                                                                                     




$resultsfilename = 'rolesauditreport.csv'

$rolesauditreport =  $Azrolesreport| SELECT  ResourceGroup `
       ,resource `
      ,RoleAssignmentName `
      ,RoleAssignmentID `
      ,inheritance `
      ,inheritancesource `
      ,displayname `
      ,SignInName `
      ,RoleDefinitionName `
      ,Subscriptionname `
      ,Subscriptionid `
      ,ObjectType `
      ,CanDelegate `
      ,Scope `
      ,resourcetype `
      ,purpose `
      ,Owner | export-csv  $resultsfilename  -notypeinformation




 ##### storage subinfo

#connect-azaccount 
 

$Region =  "West US"

 $subscriptionselected = 'wolffentpSub'



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


             #Upload  .csv to storage account

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


 

