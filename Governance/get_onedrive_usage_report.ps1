import-module activedirectory
 

 $credential2 = get-credential 


 Connect-MsolService  #-Credential $credential2 -AzureEnvironment AzureUSGovernmentCloud

 Connect-SPOService -Url "https://<tenantname>-admin.sharepoint.us"     

 Get-SPOSite "https://<tenantname>.sharepoint.us/sites/Infrastructure" -Detailed | select url, storageusagecurrent, Owner

  $date = get-date -Format 'MMddyyyy'

 clear-content c:\temp\Onedrive_usage.csv

 $onedriveUsage = ''

 $spologins = ((get-spouser -Site https://<tenantname>-my.sharepoint.us).LoginName)

foreach ($login in  $spologins )
{
    if($Login.Contains('@'))
    {
        $login=$login.Replace('@','_');
        $login=$login.Replace('.','_');
        $login=$login.Replace('.','_');
        $login="https://<tenantname>-my.sharepoint.us/personal/"+$login;

        Get-SPOSite -Identity  $login  | select URL, Owner,StorageUsageCurrent  , StorageQUota | sort-object Percent -descending | export-csv c:\temp\Onedrive_gov_usage_$date.csv -Append -notypeinformation

       $ODLOGIN = Get-SPOSite -Identity  $login 

       $percent = ( $($ODLOGIN.StorageUsageCurrent) / ($($ODLOGIN.storagequota) )).tostring("P")
$percent


        $loginobj = new-object PSObject

        $loginobj | add-member -membertype Noteproperty -name URL -value $($ODLOGIN.url)
        $loginobj | add-member -membertype Noteproperty -name Owner -value $($ODLOGIN.Owner)
        $loginobj | add-member -membertype Noteproperty -name StorageUsageCurrent -value $($ODLOGIN.StorageUsageCurrent)
        $loginobj | add-member -membertype Noteproperty -name StorageQUota -value $($ODLOGIN.StorageQUota)

        $loginobj | add-member -membertype Noteproperty -name percent -value $percent

        $loginobj | add-member -membertype Noteproperty -name Daterun -value $date
  

        [array]$onedriveUsage += $loginobj 
    } 
}



 
$CSS = @"
<Title>OneDrive for Business Usage Report:$(Get-Date -Format 'dd MMMM yyyy' )</Title>
<Header>
 
"<B>Company Confidential</B> <br><I>Report generated from  on $env:computername as a scheduled task</I><br><br>Please contact $contact with any questions "$(Get-Date -displayhint date)",$env:userdomain,$env:username
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



 

 (($onedriveUsage     |Select URL, Owner,StorageUsageCurrent  , StorageQUota, Percent, Daterun| sort-object StorageUsageCurrent,Percent -descending | `
ConvertTo-Html -Head $CSS ) )   | Out-File "c:\temp\onedriveUsage.html"
Invoke-Item "c:\temp\onedriveUsage.html"
    
 



     
       $ADUser_OneDriveUsage = $onedriveUsage | select URL, Owner,StorageUsageCurrent  , StorageQUota, Percent, Daterun | Sort-Object StorageUsageCurrent,percent -Descending
                        
 
             

