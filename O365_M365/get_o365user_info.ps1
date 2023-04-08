 
 <#
.NotePropertyS

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

 


install-module -name msonline -allowclobber 
import-module -name msonline -Verbose -force


Connect-MsolService # -Credential $UserCredential


 $information = ''
 $O365userinformation = ''

$x = Get-MsolUser -all -Verbose

foreach ($i in $x)
    {
       $y = Get-MsolContact  -All | Where-Object UserPrincipalName -eq "$i.emailaddress"
       $i | Add-Member -MemberType NoteProperty -Name IsMailboxEnabled -Value $y.IsMailboxEnabled
      
      $information = $i | select -Property *   
      $yinfo = $y | select -Property *    

      $information  | export-csv c:\temp\o365info.csv -Append -NoTypeInformation
      $yinfo | export-csv c:\temp\o365Yinfo.csv -Append -NoTypeInformation
    }

 $role = Get-MsolRole   -RoleName "Company Administrator"


Get-MsolRoleMember -RoleObjectId $role.ObjectId


$x = get-msoluser -all  -Verbose  | select -Property *
 
foreach ($i in $x)
    {
         
        $msrole = Get-MsolUserRole  -ObjectId $($i.ObjectId)
         $msrole 
       write-host " $($i.UserPrincipalName) " -ForegroundColor Green

                   $msroleobj = new-object PSobject  

                  $msroleobj | Add-Member -MemberType NoteProperty -Name Rolename  -Value $($msrole.Name)
                  $msroleobj | Add-Member -MemberType NoteProperty -Name RoleDisplayname -Value $($msrole.Displayname)
                  $msroleobj | Add-Member -MemberType NoteProperty -Name Description -Value $($msrole.Description)   
               
                  [array]$information += $msroleobj  
 

                  $infodetailsobj = new-object PSobject 

                $infodetailsobj | add-member -MemberType NoteProperty -Name  IsMailboxEnabled   -value $($i.IsMailboxEnabled)
                $infodetailsobj | add-member -MemberType NoteProperty -Name  Country   -value  $($i.Country)
                $infodetailsobj | add-member -MemberType NoteProperty -Name  DisplayName   -value  $($i.DisplayName)
                $infodetailsobj | add-member -MemberType NoteProperty -Name  FirstName   -value  $($i.FirstName)
                $infodetailsobj | add-member -MemberType NoteProperty -Name  LastName   -value      $($i.LastName)            
                $infodetailsobj | add-member -MemberType NoteProperty -Name  IsLicensed   -value  $($i.IsLicensed)
                $infodetailsobj | add-member -MemberType NoteProperty -Name  LastPasswordChangeTimestamp   -value    $($i.LastPasswordChangeTimestamp)                              
                $infodetailsobj | add-member -MemberType NoteProperty -Name  LicenseAssignmentDetails   -value  "$($i.LicenseAssignmentDetails.accountsku.skupartnumber)"
                $infodetailsobj | add-member -MemberType NoteProperty -Name  Licenses   -value  "$($i.Licenses.accountskuid)"
                $infodetailsobj | add-member -MemberType NoteProperty -Name  PreferredLanguage   -value  $($i.PreferredLanguage)
                $infodetailsobj | add-member -MemberType NoteProperty -Name  SignInName   -value  $($i.SignInName)
                $infodetailsobj | add-member -MemberType NoteProperty -Name  UserPrincipalName   -value    $($i.UserPrincipalName)              
                $infodetailsobj | add-member -MemberType NoteProperty -Name  WhenCreated   -value  $($i.UserPrincipalName)
                $infodetailsobj | add-member -MemberType NoteProperty -Name  UserType   -value   $($i.UserType) 
                $infodetailsobj | add-member -MemberType NoteProperty -Name  PasswordNeverExpires   -value  $($i.PasswordNeverExpires)
                  
                
                [array]$O365userinformation += $infodetailsobj

                
                   
                
               



     
}
 




 $information | Select Rolename, RoleDisplayname,Description  | export-csv c:\temp\o365roleinfo.csv   -NoTypeInformation

 $O365userinformation | select IsMailboxEnabled,Country, DisplayName,FirstName, LastName, IsLicensed, LastPasswordChangeTimestamp `
 LicenseAssignmentDetails, Licenses,PreferredLanguage,SignInName, UserPrincipalName, WhenCreated, UserType, PasswordNeverExpires   | `
 export-csv c:\temp\O365infoDetails.csv -NoTypeInformation 
 

$CSS = @"
<Title> O365 users  Report: $date </Title>
<Style>
th {
	font: bold 11px "Trebuchet MS", Verdana, Arial, Helvetica,
	sans-serif;
	color: #FFFFFF;
	border-right: 1px solid #9400D3;
	border-bottom: 1px solid #9400D3;
	border-top: 1px solid #9400D3;
	letter-spacing: 2px;
	text-transform: uppercase;
	text-align: left;
	padding: 6px 6px 6px 12px;
	background: #5F9EA0;
}
td {
	font: 11px "Trebuchet MS", Verdana, Arial, Helvetica,
	sans-serif;
	border-right: 1px solid #9400D3;
	border-bottom: 1px solid #9400D3;
	background: #fff;
	padding: 6px 6px 6px 12px;
	color: #1E90FF
}
</Style>
"@

  

$O365userresults  = ($information | Select Rolename, RoleDisplayname,Description   | `
	ConvertTo-Html -Head $CSS) |  out-file c:\temp\O365userresults.html 

 invoke-item  c:\temp\O365userresults.html 


  ($O365userinformation | select IsMailboxEnabled,Country, DisplayName,FirstName, LastName, IsLicensed, LastPasswordChangeTimestamp, `
 LicenseAssignmentDetails, Licenses,PreferredLanguage,SignInName, UserPrincipalName, WhenCreated, UserType, PasswordNeverExpires   | `
 	ConvertTo-Html -Head $CSS) |  out-file c:\temp\O365infoDetails.html 

 Invoke-Item c:\temp\O365infoDetails.html 


















