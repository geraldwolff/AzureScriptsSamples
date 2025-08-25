






$Vnets = Get-AzVirtualNetwork 



foreach($vnet in $vnets)
{


        $VNetDetails=Get-AzVirtualNetwork -Name "$($vnet.name)"-ResourceGroupName "$($vnet.resourcegroupname)"

        #Fetch the SubnetConfig from the VNETConfig

        #$subnets = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet 
        
        $subnets  = $($VNetDetails.Subnets)

        Foreach($subnet in $subnets) 
        {

              $VnetSubnetConfig=Get-AzVirtualNetworkSubnetConfig -Name "$($subnet.name)" -VirtualNetwork $vnet

            #Fetch the IPUsage from the SubnetID.

            $PrivateIPUsage=Get-AzVirtualNetworkUsageList -ResourceGroupName "$($vnet.resourcegroupname)" -Name "$($Vnet.name)" | where ID -eq $VnetSubnetConfig.id

            [int] $TotalIPLimit=$PrivateIPUsage.Limit
            [int] $TotalIPUsed=$PrivateIPUsage.CurrentValue



            if($TotalIPUsed -lt $TotalIPLimit)
            {

                Write-Host "Private IP's are available in this Subnet for Usage."
                write-host "TotalIPLimit $TotalIPLimit - " -ForegroundColor cyan -NoNewline
                Write-Host "TotalIPUsed  $TotalIPUsed " -ForegroundColor red -BackgroundColor yellow


            }

            else

            {

                Write-Host "Private IP's are not available in this Subnet for Usage."

            }

        }
}




























