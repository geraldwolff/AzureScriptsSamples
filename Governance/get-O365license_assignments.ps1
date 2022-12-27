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












 Connect-MsolService
$O365licenseassignment = ''

 
  $roleinfo =   Get-Msoluser 
        foreach($roleid in $roleinfo)
        {
 
                          $roleobj = new-object PSObject 
 
                            $roleobj | Add-Member -MemberType NoteProperty -name  isLicensed -value "$($roleid.isLicensed)"
                           $roleobj | Add-Member -MemberType NoteProperty -name  UserPrincipalName -value "$($roleid.UserPrincipalName)"
                           $roleobj | Add-Member -MemberType NoteProperty -name  DisplayName -value "$($roleid.DisplayName)"
 



                      [array]$O365licenseassignment += $roleobj
                 
        }
  
 


     $CSS = @"
<Title>User Azure Group membership matrix Report:$(Get-Date -Format 'dd MMMM yyyy' )</Title>
<Style>
th {
	font: bold 11px "Trebuchet MS", Verdana, Arial, Helvetica,
	sans-serif;
	color: #FFFFFF;
	border-right: 1px solid #DC143C;
	border-bottom: 1px solid #DC143C;
	border-top: 1px solid #DC143C;
	letter-spacing: 2px;
	text-transform: uppercase;
	text-align: left;
	padding: 6px 6px 6px 12px;
	background: #5F9EA0;
}
td {
	font: 11px "Trebuchet MS", Verdana, Arial, Helvetica,
	sans-serif;
	border-right: 1px solid #DC143C;
	border-bottom: 1px solid #DC143C;
	background: #fff;
	padding: 6px 6px 6px 12px;
	color: #6D929B;
}
</Style>
"@



 

(($O365licenseassignment   | Select  UserPrincipalName, DisplayName , isLicensed  | select * -Unique |`
 ConvertTo-Html -Head $CSS ).replace('True','<font color=red>True</font>'))   | out-file  "c:\temp\O365licenseassignment.html"
invoke-item "c:\temp\O365licenseassignment.html"
 
