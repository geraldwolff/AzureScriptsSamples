<#
.SYNOPSIS  
 Wrapper script for start & stop Az VM's
.DESCRIPTION  
 Wrapper script for start & stop Az VM's 
 Note:  Tagging the resource is a necessary pre-req as it leverages the tags to identify resources to act upon
.EXAMPLE  
.\automation_sequencestart_stop_by_sub_by_tag.ps1  -Action "Value2" -Subscription "Subscriptionname"
Version History  
v1.0   - Initial Release  
 

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
 

param(

[String]$Action = $(throw "Value for Action is missing Start/Stop"),
[String]$Subscription = $(throw "Value for Action is missing")
)

#----------------------------------------------------------------------------------
#---------------------LOGIN TO AZURE AND SELECT THE SUBSCRIPTION-------------------
#----------------------------------------------------------------------------------
try
{
    "Logging in to Azure..."
   Connect-AzAccount -Identity
  
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}

Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"

$ErrorActionPreference = 'silentlyContinue'



  $action = 'Start'

         $subscriptions = Get-azSubscription -SubscriptionName $Subscription

 
            Set-azcontext -Subscription $Subscriptions.Name

            $vms = get-azvm -status | ? {$_.Tags.Keys -like "*Sequence*" }   |select name,subscription, Resourcegroup, powerstate, tags, id

            $startstopsequences = 1,2,3



switch($Action) {
           stop {$actionsequence = "Sequencestop"}
       
           start {$actionsequence = "Sequencestart"}
        
 
    
            Default {"none"}
}

$vMsequencelist = ''
  $sequence = ''

    foreach($vm in $vms)
    {

                      $tags = Get-AzVM -Name $($vm.name) -status | ? {$_.Tags.Keys -eq "$actionsequence"}   
                   
                     $sequencevaluename = $($tags.tags.Keys) | ? { $_ -eq "$actionsequence" } 
               

                      $tagdata = Get-AzTag -ResourceId $tags.id  
                    
                     $tagkey =  $tagdata.Properties.TagsProperty["$($actionsequence)"]   
                    
                 

                 $vMOrderobj = New-object PSObject 

                         $vMOrderobj| add-member -MemberType NoteProperty -Name  VMNAME  -Value $($vm.Name)
                          $vMOrderobj | add-member -MemberType NoteProperty -Name Powerstate  -Value $($vm.powerstate)
                          $vMOrderobj | add-member -MemberType NoteProperty -Name Sequencetag  -Value   $sequencevaluename
                          $vMOrderobj| add-member -MemberType NoteProperty -Name  TagSequencenumber -Value   "$($tagkey)"
                          $vMOrderobj| add-member -MemberType NoteProperty -Name  Subscription -Value  $($subscriptions.name)
                          $vMOrderobj| add-member -MemberType NoteProperty -Name  Resourcegroup -Value  $($VM.Resourcegroupname)
                          
                      [array]$vMsequencelist +=   $vMOrderobj

                     $Sequencelist  = $vMsequencelist | where vmname -ne $null | sort-object TagSequencenumber 
                 
        } 

        $Sequencelist 
        $Sequencelist | Measure-Object | select count 

 foreach($sequence in $Sequencelist)
 {

    if ($actionsequence.Trim().ToLower() -eq "Sequencestop")
    {
         
 
                    try
                        { 
                            $tagdata = Get-AzTag -ResourceId $sequence.id  
                    
                            $tagkey =  $tagdata.Properties.TagsProperty["$($actionsequence)"]  
                         
                          $vmobj = New-object PSObject 

                          $vmobj | add-member -MemberType NoteProperty -Name  VMNAME  -Value $($sequence.VMName)
                          $vmobj | add-member -MemberType NoteProperty -Name Powerstate  -Value $($sequence.powerstate)
                          $vmobj | add-member -MemberType NoteProperty -Name Sequencetag  -Value $($sequence.Sequencetag)
                          $vmobj | add-member -MemberType NoteProperty -Name  TagSequencenumber -Value  $($sequence.TagSequencenumber)
                
                          
                          $vmobj           

                    write-host " Executing action : $($actionsequence) on $($sequence.vmname) Sequence  $($sequence.TagSequencenumber)" -ForegroundColor Green

                                Write-Output "Stopping the VM : $($sequence.VMName) "

                            $Status = get-azvm -Name $($sequence.VMName) -Status | stop-azvm -force

                                if($Status -eq $null)
                                {
                                    Write-Output "Error occured while stopping the Virtual Machine."
                                }
                                else
                                {
                                   Write-Output "Successfully stopped the VM  $($sequence.VMName) "
                                   $VMState = (get-azvm -Name $($sequence.VMName) -Status) | select name, powerstate
                                   Write-Output "$($VMState.name) - $($vmstate.PowerState)  "
                                }
                            }
                                              
                        catch
                        {
                            Write-Output "Error Occurred..."
                            Write-Output $_.Exception
                        }
         }
               
             


             if($actionsequence.Trim().ToLower() -eq "Sequencestart")
             {
 
              
      
                    try
                        {
                           
                         
                          $vmobj = New-object PSObject 

                          $vmobj | add-member -MemberType NoteProperty -Name  VMNAME  -Value $($sequence.VMName)
                          $vmobj | add-member -MemberType NoteProperty -Name Powerstate  -Value $($sequence.powerstate)
                          $vmobj | add-member -MemberType NoteProperty -Name Sequencetag  -Value $($sequence.Sequencetag)
                          $vmobj | add-member -MemberType NoteProperty -Name  TagSequencenumber -Value  $($sequence.TagSequencenumber)
                
                          
                          $vmobj           
                            write-host " Executing action : $($actionsequence) on $($sequence.vmname) Sequence  $($sequence.TagSequencenumber)" -ForegroundColor cyan

 
                                 Write-Output "VM action is : $($actionsequence) and Sequence - $($sequence.TagSequencenumber) "

                                Write-Output "Starting the VM :  $($sequence.VMName) "

                                $Status = get-azvm -Name $($sequence.VMName) -Status  | Start-AzVM 
                                if($Status -eq $null)
                                {
                                    Write-Output "Error occured while starting the Virtual Machine $($vm.name) "
                                }
                                else
                                {
                                    Write-Output "Successfully started the VM  $($sequence.VMName)"
                                    $VMState = (get-azvm -Name $($sequence.VMName)-Status) | select name, powerstate
                                   Write-Output "$($VMState.name) - $($vmstate.PowerState)  "
                                }
                               
                        }
                    
                    catch
                    {
                        Write-Output "Error Occurred..."
                        Write-Output $_.Exception
                    }

                  } 
    }
   