 
$context = connect-azaccount  

 set-azcontext -Subscription wolffentpsub

 $spnrec = ''
 
    $vaultname = 'wolffkv' 
    $spnname = 'wolffcommsvcspn'


                $subscription = get-azsubscription | ogv -Title "select a subscription: " -PassThru | select name, id, tenantid -first 1


                $subscription 


                set-azcontext -Subscription $($subscription.name) -Tenant $($tenant.tenantid) 


                 Write-host " Tenant/sub : $($subscription.name)  - $($tenant.tenantid)  " -foregroundcolor Green

                 $sp = New-AzADServicePrincipal -DisplayName "$spnname"

               $erviceprincipalinfo = get-AzADServicePrincipal -DisplayName "$spnname"

                 
                $sp | fl *


                ($sp.PasswordCredentials).GetEnumerator() | Foreach-object {


                    $spnobj = new-object PSObject 

                    $spnobj | Add-Member -MemberType NoteProperty -name Tenantid -Value $($tenant.tenantid)
                    $spnobj | Add-Member -MemberType NoteProperty -name Applicationid -Value $($sp.AppId)
                    $spnobj | Add-Member -MemberType NoteProperty -name Displayname -value $($sp.DisplayName)
                    $spnobj | Add-Member -MemberType NoteProperty -name ClientID -Value $($sp.AppId)
                    $spnobj | Add-Member -MemberType NoteProperty -name Appid -Value $($sp.AppId)
                    $spnobj | Add-Member -MemberType NoteProperty -name Clientsecret -Value $($_.secrettext)
                    $spnobj | Add-Member -MemberType NoteProperty -name Keyid -Value $($_.keyId)
                    $spnobj | Add-Member -MemberType NoteProperty -name Enddate -Value $($_.enddatetime)
                    $spnobj | Add-Member -MemberType NoteProperty -name startdate -Value $($_.startdatetime)
                    $spnobj | Add-Member -MemberType NoteProperty -name objectid -Value $($sp.Id)


                    [array]$spnrec += $spnobj
    
              } ## foreach-object end


        $spnrec 
    

######add role 

    Get-AzRoleDefinition -Name 'Resource Policy Contributor'

            New-AzRoleAssignment -objectid $($spnrec.objectid) `
             -RoleDefinitionName 'Resource Policy Contributor' `
             -Scope /providers/Microsoft.Management/managementGroups/$($subscription.tenantid)

#########
 
                Get-AzKeyVault -VaultName "$vaultname" -ResourceGroupName "Adminrg"

                 $secureSecretValue = ConvertTo-SecureString -String "$($spnrec.Clientsecret)" -AsPlainText -Force


                Set-AzKeyVaultSecret -VaultName "$vaultname" -Name "$($spnrec.clientid)" `
                -SecretValue  $secureSecretValue -Tag @{Purpose = "Spnautomation"; Clientid ="$($spnrec.clientid)" ; Enddatetime = "$($spnrec.Enddate)"; keyid = "$($spnrec.keyid)"}`
                -ContentType "$($spnrec.appid)"

                Get-AzKeyVaultsecret -VaultName "$vaultname" -Name "$($spnrec.clientid)"  -AsPlainText

                ####cleanup previous ones

                    
                Remove-AzKeyVaultKey -VaultName "$vaultname" -Name "$($spnrec.displayname)" -Force -InRemovedState -ErrorAction Ignore

                add-AzKeyVaultKey -VaultName "$vaultname" -Name "$($spnrec.displayname)"`
                 -Tag @{Purpose = "Spnautomation"; Clientid ="$($spnrec.clientid)" ; Enddatetime = "$($spnrec.Enddate)"; keyid = "$($spnrec.keyid)"} `
                 -Destination Software 

              
                Get-AzKeyVaultKey -VaultName "$vaultname" -Name "$($spnrec.displayname)"
 

            $serviceprincipal =  get-AzADServicePrincipal -DisplayName "$($spnrec.displayname)"

            $credsecret =       Get-AzKeyVaultsecret -VaultName "$vaultname" -name "$($serviceprincipal.appid)"  -AsPlainText

            $clientkeyinfo =  Get-AzKeyVaultKey -VaultName "$vaultname" -name "$($serviceprincipal.displayname)" 

            $secureSecretValue = ConvertTo-SecureString -String "$credsecret" -AsPlainText -Force

            $credentials =   New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $spnname , $secureSecretValue





 
















