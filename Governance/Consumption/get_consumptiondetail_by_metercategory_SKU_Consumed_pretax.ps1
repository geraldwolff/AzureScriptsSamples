

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

Connect-AzAccount #-Environment AzureUSGovernment


$resourcelist = ''
  $costsummary = ''

 foreach($sub in Get-AzSubscription)
 {
    Set-azcontext -Subscription $($sub.Name)

        $consumption = Get-AzConsumptionUsageDetail -BillingPeriodName '2022-06-01'  | Select-Object -Property *

        foreach($consumptioncategory in $consumption  )
        {

             $resourceinstance  = $consumptioncategory.instanceid.split('/')[-2]    


            $consumptionobj = New-OBject PSObject
            $consumptionobj | Add-Member -MemberType NoteProperty -Name resourcelist   -Value  $resourceinstance 
            $consumptionobj | Add-Member -MemberType NoteProperty -Name ID   -Value  $($consumptioncategory.id) 
            [array]$resourcelist += $consumptionobj

        }


      $resourcelist | Select-Object -Unique resourcelist  
 



        foreach($resource in ($resourcelist | where resourcelist -ne $null | select -unique resourcelist  ) )
        {
             foreach($consumptionitem in $consumption)
             {
                    if(($consumptionitem.instanceid.split('/')[-2])   -eq $($resource.resourcelist) )
                    {
                 
                        $resourcedata = Get-azresource -ResourceId $($consumptionitem.InstanceId) -ExpandProperties  
                         

                         #$resourcedata.sku
                          
 
                        $skuname =    $($resourcedata.sku.Name)
       
                           $skutier = $($resourcedata.sku.Tier)
                             $skufamily = $($resourcedata.sku.Tier)

                        if($($resource.resourcelist) -eq 'virtualMachines')
                        {
                            $vmname = ($consumptionitem.instanceid.split('/')[-1])
                            $size = (get-azvm -Name $vmname).HardwareProfile.VmSize
                            
                            $size 


                        }
                        else
                        {
                            $size = $($resourcedata.sku.size)

                        }

                       
                        [decimal]$Consumedcost += ($($consumptionitem.pretaxcost)) 
                        [decimal]$consumedquantity += ($($consumptionitem.UsageQuantity)) 

                    }
               }

               


                    $consumedobj = new-object PSObject 

                         $consumedobj | Add-Member -MemberType NoteProperty -Name instance -Value $resource.resourcelist
                         $consumedobj | Add-Member -MemberType NoteProperty -Name subscription -Value $($sub.Name)
                         $consumedobj | Add-Member -MemberType NoteProperty -Name Skuname -Value $skuname 
                         $consumedobj | Add-Member -MemberType NoteProperty -Name Skutier -Value $skutier
                         $consumedobj | Add-Member -MemberType NoteProperty -Name Skufamily -Value $skufamily
                         $consumedobj | Add-Member -MemberType NoteProperty -Name Size -Value $size
                         $consumedobj | Add-Member -MemberType NoteProperty -Name UsageQuantity -Value $consumedquantity
                         $consumedobj | Add-Member -MemberType NoteProperty -Name PretaxCostTotal -Value $consumedcost

                         [array]$costsummary += $consumedobj

                   $consumedcost =''       
        }



}
        $costsummary | sort-object subscription, instance | ft  -AutoSize










