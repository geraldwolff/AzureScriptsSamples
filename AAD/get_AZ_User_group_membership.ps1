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

    Scriptname: get_AZ_User_group_membership.ps1
    Description:  Script to collect all Azure AD User and information on group memberships 
                   Script will generate report in HTML and CSV
                  

    Purpose:  Audit of AZure AD users, group memberships  

    Note: in order for process counter to show it must be in the first tab of PowerShell ISE

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

 ######################33
 ##  Necessary Modules to be imported.

 import-module  AzureAD -force

 
 ############
 ## connect to Azure with authorized credentials 
 
 Connect-AzAccount  

  #set-azcontext  

#Get-AzADUser
$Membergroupassignment = ''

$azgroups = Get-AzADGroup  


$j = 0

foreach($azgroup in $azgroups)
{


                 ################### counter for AZ User Groups 
 

                        $j = $j+1
                                # Determine the completion percentage
                                $JCompleted = ($j/$azgroups.count) * 100
                                $Jactivity = "Processing groups" + ($j + 1);
         
                       Write-Progress -Activity " $Jactivity " -Status "Progress:" -PercentComplete $JCompleted  


                        #################### end progress counter for AZ User Groups     

 


    $i = 0

     $azgroupmembers =  Get-AzADGroupMember -GroupObjectId $($azgroup.ID)  

 $azgroupmembers
 

              foreach($rolemember in $azgroupmembers)
                {
          
                       ################### counter for AZ User Group members
 

                        $i = $i+1
                                # Determine the completion percentage
                                $Completed = ($i/$azgroupmembers.count) * 100
                                $activity = "Processing Members" + ($i + 1);
         
                                Write-Progress -Activity " $activity " -Status "Progress:" -PercentComplete $Completed  


                        #################### end progress counter for AZ User Group members                   

                       $roleaccounts = Get-AzADUser -DisplayName  $($rolemember.DisplayName)

                       foreach($roleaccount in $roleaccounts)
                       {

                            $rolegroupobj = new-object PSObject 
                            $rolegroupobj | Add-Member -MemberType NoteProperty -name  Group -value "$($azgroup.DisplayName)"
                            $rolegroupobj | Add-Member -MemberType NoteProperty -name  RoleMember -value "$($roleaccount.DisplayName)"  
                            $rolegroupobj | Add-Member -MemberType NoteProperty -name  User -value "$($roleaccount.UserPrincipalName)"
                            $rolegroupobj | Add-Member -MemberType NoteProperty -name  UsageLocation -value "$($roleaccount.UsageLocation)"
 
  

                            [array]$Membergroupassignment += $rolegroupobj
                        }

         }
}




     $CSS = @"
<Title>User Azure Group membership matrix Report:$(Get-Date -Format 'dd MMMM yyyy' )</Title>
<Style>
th {
	font: bold 11px "Trebuchet MS", Verdana, Arial, Helvetica,
	sans-serif;
	color: #FFFFFF;
	border-right: 1px solid #7CFC00;
	border-bottom: 1px solid #7CFC00;
	border-top: 1px solid #7CFC00;
	letter-spacing: 2px;
	text-transform: uppercase;
	text-align: left;
	padding: 6px 6px 6px 12px;
	background: #5F9EA0;
}
td {
	font: 11px "Trebuchet MS", Verdana, Arial, Helvetica,
	sans-serif;
	border-right: 1px solid #7CFC00;
	border-bottom: 1px solid #7CFC00;
	background: #fff;
	padding: 6px 6px 6px 12px;
	color: #6D929B;
}
</Style>
"@



 

 ($Membergroupassignment   | Select  Group,RoleMember, User, UsageLocation |`
  ConvertTo-Html -Head $CSS )   | out-file  "c:\temp\Membergroupassignment.html"
invoke-item "c:\temp\Membergroupassignment.html"
 

