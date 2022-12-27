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

connect-azaccount 



Clear-Content "c:\temp\NSG_audit.csv" 

$subs = get-azsubscription 

foreach($sub in $subs) 
{

    Set-azContext -Subscription  $sub.name  -verbose 
 

    $niclist = Get-azNetworkInterface | where-object networksecuritygroup  -ne $null 
 
         foreach($nic in $niclist)
         {
            $nic = Get-azNetworkInterface   -Name  $($nic.Name) -ResourceGroupName $nic.ResourceGroupName

          $nsg = $nic.NetworkSecurityGroup  
          $nsgname = ($nsg.ID).Split("/")[-1] 
          $nicname = $nic.name
          $resourcegroup = $nic.ResourceGroupName

           # Get-azNetworkSecurityGroup  -ResourceGroupName  $resourcegroup    -Name $nicname  
            
            $vm = ($nic.VirtualMachine.id).Split("/")[-1] 
            $PublicIPS =  Get-azPublicIpAddress -ResourceGroupName $resourcegroup |    Where-Object {($_.id).Split("/")[-1] -like "$vm*"}

               $PIP = $PublicIPS.Where({$_.Id -eq $nic.IpConfigurations.publicipaddress.id}).ipaddress

               $vmobj = new-object PSObject 

                $vmobj | add-member  -membertype NoteProperty -name   SubscriptionName  -value "$($sub.name)"                                                                                    
                $vmobj | add-member  -membertype NoteProperty -name   resourcegroupname  -value "$resourcegroup"         
                $vmobj | add-member  -membertype NoteProperty -name   VMName  -value "$vm"
                $vmobj | add-member  -membertype NoteProperty -name   vmloc -Value "$($nic.Location)"
                $vmobj | add-member  -membertype NoteProperty -name   NIC -Value "$nicname"
                $vmobj | add-member  -membertype NoteProperty -name   NetworsecurityGroup  -Value "$nsgname"
                $vmobj | add-member  -membertype NoteProperty -name   publicipaddress -value "$PIP"

                $vmobj | export-csv "c:\temp\NSG_audit.csv" -append -notypeinformation
        
            }
   

                                  
   }
                    
 

$CSS = @"
<Title>NSG Audit Report:$(Get-Date -Format 'dd MMMM yyyy' )</Title>
<Header>
 
"<B>Company Confidential</B> <br><I>Report generated from {3} on $env:computername {0} by {1}\{2} as a scheduled task</I><br><br>Please contact $contact with any questions "$(Get-Date -displayhint date)",$env:userdomain,$env:username
 </Header>

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





$nsgaudit = import-csv "c:\temp\NSG_audit.csv" 
 

(($nsgaudit   | Sort-Object -Property SubscriptionName,resourcegroupname,VMName,vmloc,NIC,NetworsecurityGroup,publicipaddress |`
Select SubscriptionName,resourcegroupname, VMName,vmloc,NIC,@{Name='NetworsecurityGroup';E={IF ($_.NetworsecurityGroup -eq ''){'not enabled'}Else{$_.NetworsecurityGroup}}},publicipaddress  |`
ConvertTo-Html -Head $CSS ).replace('not enabled','<font color=red>not enabled</font>'))    | Out-File "c:\temp\NSG_audit.html"
 Invoke-Item "c:\temp\NSG_audit.html"
    

 