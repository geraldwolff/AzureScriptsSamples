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

    Scriptname: get_azsecurity_topology.ps1
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

 

#get-command -verb get -Noun *threat, *threatd*
 Connect-AzAccount 
 import-module az.security -force


 $sectopologylist = ''

 $Subs =  Get-azSubscription | select Name, ID,TenantId


 foreach($Subscription in  $subs)
    {

                             $SubscriptionName =  $Subscription.name

                             
                           $azcontext = (set-azcontext -SubscriptionName $SubscriptionName  -ErrorAction SilentlyContinue)

                       write-host "$SubscriptionName" -foregroundcolor yellow
 
 
                $sectopology = Get-AzSecurityTopology
                #$sectopology.TopologyResources  

    foreach($sectopologyitem in $sectopology)
    {
            $resources = $($sectopologyitem.TopologyResources.ResourceId) -split('/')[-1]
  
            foreach($resouce in $resources)
            {
 

                    $sectopologyresources= $($sectopologyitem.TopologyResources)



                    foreach($sectopologyresourcesitem in $sectopologyresources) 
                    {
                        $sectopologyobj = new-object PSobject

                        $sectopologyobj | Add-Member -MemberType NoteProperty -Name Subscription  -Value $SubscriptionName
                        $sectopologyobj | Add-Member -MemberType NoteProperty -Name CalculatedDateTime -Value "$($sectopologyitem.CalculatedDateTime)"
                        $sectopologyobj | Add-Member -MemberType NoteProperty -Name ResourceType -Value $($sectopologyitem.name)
                        $sectopologyobj | Add-Member -MemberType NoteProperty -Name Resource  -Value   $resouce
                        $sectopologyobj | Add-Member -MemberType NoteProperty -Name Severity  -Value  $($sectopologyresourcesitem.Severity) 
                        $sectopologyobj | Add-Member -MemberType NoteProperty -Name NetworkZones  -Value  $($sectopologyresourcesitem.NetworkZones) 
                        $sectopologyobj | Add-Member -MemberType NoteProperty -Name Location  -Value $($sectopologyresourcesitem.Location) 
                        $sectopologyobj | Add-Member -MemberType NoteProperty -Name TopologyScore  -Value  $($sectopologyresourcesitem.TopologyScore) 
                        $sectopologyobj | Add-Member -MemberType NoteProperty -Name Parents  -Value $($sectopologyresourcesitem.Parents).ResourceId

                        [array]$sectopologylist += $sectopologyobj

                   }
                }
        }
  }  
        
     
      


## CSS to format output in tabular format

$CSS = @"
<Title>Security Toplogy Report:$(Get-Date -Format 'dd MMMM yyyy')</Title>
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



$sectopologylist | select Subscription , CalculatedDateTime, ResourceType, Resource, Severity, NetworkZones ,Location , TopologyScore,Parents  -unique | where resource -ne ''| Export-Csv c:\temp\sectopology.csv -NoTypeInformation


 ($sectopologylist | select Subscription , CalculatedDateTime, ResourceType, Resource, Severity, NetworkZones ,Location , TopologyScore,Parents  -Unique | where resource -ne '' | `
 ConvertTo-Html -Head $CSS).replace('*','<font color=red>*</font>')    | Out-File "c:\temp\sectopology.html"

 Invoke-Item "c:\temp\sectopology.html"

























