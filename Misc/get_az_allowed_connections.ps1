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

    Scriptname: get_az_allowed_connections.ps1
    Description:  Script to collect all Azure Allowed connections to subscription resources  
                  results show Resource and tcp UDP ports opened in and outbound  
                  Script will generate report in HTML and CSV
              

    Purpose:  Audit of alloexed connections to subscription resourcesin a tenant

#> 


Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings 'true'

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




Connect-AzAccount

import-module -name Az.Security -force

$allowedresourcelist = ''

 $Subs =  Get-azSubscription | select Name, ID,TenantId


 foreach($Subscription in  $subs)
    {

                             $SubscriptionName =  $Subscription.name

                             
                           $azcontext = (set-azcontext -SubscriptionName $SubscriptionName  -ErrorAction SilentlyContinue)

                       write-host "$SubscriptionName" -foregroundcolor yellow

       
        
    
       
           $allowedconnections =  Get-AzAllowedConnection  
        
        foreach($allowedconnection  in $allowedconnections)
        {
           $connectresources = $allowedconnection.ConnectableResources  
           foreach ($connectresource in $connectresources)
           {
            $inresource = ($($connectresource.InboundConnectedResources).ConnectedResourceId -split('/'))[-1]
            $intcpports = $connectresource.InboundConnectedResources.tcpports   
            $inudpports = $connectresource.InboundConnectedResources.udpports 

           

            Write-host -ForegroundColor cyan " $SubscriptionName Resource   $inresource "
            Write-host -ForegroundColor green "TCP in   $intcpports  UDp in  $inudpports"
     

            $outresource = ($($connectresource.OutboundConnectedResources).ConnectedResourceId -split('/'))[-1]
            $outcppports = $connectresource.OutboundConnectedResources.tcpports   
            $outudpports = $connectresource.OutboundConnectedResources.udpports 

           

            Write-host -ForegroundColor cyan " $SubscriptionName Resource  $outresource "
            Write-host -ForegroundColor green "TCP out  $outcppports  UDp out $outudpports"
    
            $allowedresounrceobj = new-object PSobject

            $allowedresounrceobj | Add-Member -MemberType NoteProperty -Name Subscription  -Value $SubscriptionName
            $allowedresounrceobj | Add-Member -MemberType NoteProperty -Name  Resource -Value $inresource
            $allowedresounrceobj | Add-Member -MemberType NoteProperty -Name intcpports  -Value  $($intcpports).getvalue(1)
            $allowedresounrceobj | Add-Member -MemberType NoteProperty -Name inudpports  -Value  $($inudpports).getvalue(1)
            $allowedresounrceobj | Add-Member -MemberType NoteProperty -Name outcppports  -Value  $($outcppports).getvalue(1)
            $allowedresounrceobj | Add-Member -MemberType NoteProperty -Name outudpports  -Value $($outudpports).getvalue(1)


            [array]$allowedresourcelist += $allowedresounrceobj

           }

        }  
        
     
         

        
}


## CSS to format output in tabular format

$CSS = @"
<Title>Allowed Connections Report:$(Get-Date -Format 'dd MMMM yyyy')</Title>
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



$allowedresourcelist | select Subscription , Resource, intcpports, inudpports, outcppports, outudpports -unique|  where Resource -ne ''| Export-Csv c:\temp\allowedconnections.csv -NoTypeInformation


 ($allowedresourcelist | select Subscription , Resource, intcpports, inudpports, outcppports, outudpports -Unique | where Resource -ne ''| `
 ConvertTo-Html -Head $CSS).replace('*','<font color=red>*</font>')    | Out-File "c:\temp\allowedconnections.html"

 Invoke-Item "c:\temp\allowedconnections.html"




























