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


Connect-AzureAD


$authperms = ''
$authroleperms = ''

# Get OAuth2 Permissions/delegated permissions
$azureoauthpermissions = (Get-AzureADServicePrincipal).OAuth2Permissions

<#
AdminConsentDescription : Allows the app to read and write financials data on behalf of the signed-in user.
AdminConsentDisplayName : Read and write financials data
Id                      : f534bf13-55d4-45a9-8f3c-c92fe64d6131
IsEnabled               : True
Type                    : User
UserConsentDescription  : Allows the app to read and write financials data on your behalf.
UserConsentDisplayName  : Read and write financials data
Value                   : Financials.ReadWrite.All


#>

# Get App roles/application permissions
$ApprolesPermissions = (Get-AzureADServicePrincipal).AppRoles

<#
AllowedMemberTypes : {Application}
Description        : Allows the app to have full control of all site collections without a signed in user.
DisplayName        : Have full control of all site collections
Id                 : a82116e5-55eb-4c41-a434-62fe8a61c773
IsEnabled          : True
Value              : Sites.FullControl.All


#>


Foreach($azureoauthpermission in $azureoauthpermissions)
{
    $azureoauthpermobj = new-object PSobject 


     $azureoauthpermobj | Add-Member -MemberType NoteProperty  -Name AdminConsentDescription     -value $($azureoauthpermission.AdminConsentDescription)
     $azureoauthpermobj | Add-Member -MemberType NoteProperty -Name  AdminConsentDisplayName    -value $($azureoauthpermission.AdminConsentDisplayName)
     $azureoauthpermobj | Add-Member -MemberType NoteProperty -Name  Id    -value $($azureoauthpermission.Id)
     $azureoauthpermobj | Add-Member -MemberType NoteProperty -Name IsEnabled     -value $($azureoauthpermission.IsEnabled)
     $azureoauthpermobj | Add-Member -MemberType NoteProperty -Name Type     -value $($azureoauthpermission.Type)
     $azureoauthpermobj | Add-Member -MemberType NoteProperty -Name UserConsentDescription     -value $($azureoauthpermission.UserConsentDescription)
     $azureoauthpermobj | Add-Member -MemberType NoteProperty -Name UserConsentDisplayName     -value $($azureoauthpermission.UserConsentDisplayName)
     $azureoauthpermobj | Add-Member -MemberType NoteProperty -Name Value     -value $($azureoauthpermission.Value)
     
     [array]$authperms += $azureoauthpermobj


     }


Foreach($ApprolesPermission in $ApprolesPermissions)
{
    $ApprolesPermobj = new-object PSobject 


     $ApprolesPermobj | Add-Member -MemberType NoteProperty -Name AllowedMemberTypes     -value $($ApprolesPermission.AllowedMemberTypes)
     $ApprolesPermobj | Add-Member -MemberType NoteProperty -Name  Description    -value $($ApprolesPermission.Description)
     $ApprolesPermobj | Add-Member -MemberType NoteProperty -Name  DisplayName    -value $($ApprolesPermission.DisplayName)
     $ApprolesPermobj | Add-Member -MemberType NoteProperty -Name  Id    -value $($ApprolesPermission.Id)
     $ApprolesPermobj | Add-Member -MemberType NoteProperty -Name IsEnabled     -value $($ApprolesPermission.IsEnabled)
     $ApprolesPermobj | Add-Member -MemberType NoteProperty -Value value $($ApprolesPermission.value)
 
     
     [array]$authroleperms += $ApprolesPermobj


     }


$CSS = @"
<Title> Oauth Permissions and Roles Report: $date </Title>
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

  

$authpermsresultsreport = ($authperms  | Select  AdminConsentDescription,AdminConsentDisplayName, Id, IsEnabled,Type, value   | `
	ConvertTo-Html -Head $CSS) 

$authpermsresultsreport | out-file c:\temp\authperms.html 

 invoke-item  c:\temp\authperms.html 

  

  $authrolepermsresultsreport = ($authroleperms  | Select  AllowedMemberTypes,Description, DisplayName, Id,IsEnabled, value | `
	ConvertTo-Html -Head $CSS) 

$authrolepermsresultsreport | out-file c:\temp\authroleperms.html 

 invoke-item c:\temp\authroleperms.html

