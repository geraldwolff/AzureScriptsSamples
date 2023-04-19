<#
.SYNOPSIS  
 Wrapper script for get_orphanedPIPs_report.ps1
.DESCRIPTION  
Script to collect all NICs that are not attached to a resource
.EXAMPLE  
        get_orphanedPIPs_report.ps1
Version History  
v1.0   - Initial Release  
 



.NOTES
get_orphanedPIPs_report.ps1
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
 
 $DirectoryToCreate = 'C:\temp'

 if (-not (Test-Path -LiteralPath $DirectoryToCreate)) {
    
    try {
        New-Item -Path $DirectoryToCreate -ItemType Directory -ErrorAction Stop | Out-Null #-Force
    }
    catch {
        Write-Error -Message "Unable to create directory '$DirectoryToCreate'. Error was: $_" -ErrorAction Stop
    }
    "Successfully created directory '$DirectoryToCreate'."

}
else {
    "Directory already existed"
}

 ######################33
 ##  Necessary Modules to be imported.

import-module Az.Compute -force 

 ############
 ## connect to Azure with authorized credentials 
 
 Connect-AzAccount

 ##### use for access to Azure Gov tenants
# Connect-AzAccount -Environment AzureUSGovernment
 
 $date = get-date 
 

 $orphanedicsreport = ''
 $orphaneddeleted =  ''
				  
            $subs  = get-Azsubscription 
            
 
foreach($sub in $subs)
{		 
     Set-AzContext  -Subscription $Sub.name
 
   
            $nics =	 Get-AzNetworkInterface    | where-object virtualmachine -eq $null
            $nics
        

        foreach($nicresource in  $nics)
         {

          
                    
            
                        $PIP = $(($nicresource | Select-Object -expandproperty Ipconfigurations).PublicIpAddress).ipaddress

                            $NICobj = New-Object PSOBject 

                            $NICobj | add-member ResourceGroupName "$($nicresource.ResourceGroupName)"
                            $NICobj | add-member Location "$($nicresource.Location)"
                            $NICobj | add-member VirtualMachine "$($nicresource.VirtualMachine)"
                            $NICobj | add-member PrivateIP "$(($nicresource  | Select-Object -expandproperty Ipconfigurations).PrivateIpAddress)"
                            $NICobj | add-member DnsSettings "$($orphanednic.DnsSettings.DnsServers)"
                            $NICobj | add-member NetworkSecurityGroup "$($nicresource.NetworkSecurityGroup)"
                            $NICobj | add-member Primary "$($nicresource.Primary)"
                            $NICobj | add-member EnableIPForwarding "$($nicresource.EnableIPForwarding)" 
                            $NICobj | add-member Name "$($nicresource.Name)" 
                            $NICobj | add-member PublicIpAddress "$PIP"   
                            $NICobj | add-member Tags "$($nicresource.Etag.Values)"   
                            $NICobj | add-member EnableAcceleratedNetworking "$($nicresource.EnableAcceleratedNetworking)"
                                               
                           [array]$orphanedicsreport +=     $NICobj

 
               
                
            }

    }
  
 $orphanedicsreport  | export-csv "c:\temp\orphaned_NICS_to_be_removed.csv" -append -notypeinformation


     $CSS = @"
<Title>Orphaned Network Interface Objects to be deleted Report:$(Get-Date -Format 'dd MMMM yyyy' )</Title>
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



 

(($orphanedicsreport | Select  ResourceGroupName, @{Name='VirtualMachine';E={IF ($_.VirtualMachine -eq ''){'Orphaned to be deleted'}Else{$_.VirtualMachine}}},PrivateIP , DnsSettings,NetworkSecurityGroup ,Primary , EnableIPForwarding, Name,PublicIpAddress ,Tags,EnableAcceleratedNetworking |`
  ConvertTo-Html -Head $CSS ).replace('Orphaned to be deleted','<font color=red>Orphaned to be deleted</font>'))   | out-file  "c:\temp\orphaned_NICS_to_be_removed.html"
invoke-item "c:\temp\orphaned_NICS_to_be_removed.html"
 

 





































