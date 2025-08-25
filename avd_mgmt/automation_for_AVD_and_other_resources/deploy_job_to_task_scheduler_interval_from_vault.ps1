<#
.\Deploy_audit_scheduled_tasks_intervals_15Minute_Azvault.PS1
Version History  
v1.0   - Initial Release  
 

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
#####################################################################
## Script name: Deploy_audit_scheduled_tasks_intervals_15Minute_Azvault.PS1
## Created by: Jerry Wolff
## create Date: 4/1/2015
## Modified Date: 4/15/2023
##                converted to use azure keyvault to get local task runas account credentials 
##                Require modules : 'Az.DesktopVirtualization','az.avd', 'az' ,'az.keyvault','nuget' 
## NOTE:  Use in Azure Government tenant may require staging module if direct internet is not accessible for the module downloads
## Description: Script to read a list of scripts from a jobs folder
##   and create scheduled tasks shutdown delay - Deploy scripts from c:\programdata\jobs
##
##
#####################################################################
 
#####################################################################
## SCript name: Deploy_audit_scheduled_tasks_intervals
## Created by: Jerry Wolff
## create Date: 4/1/2015
## Modified Date: 4/15/2023 
## Description: Script to read a list of scripts from a jobs folder
##   and create scheduled tasks for jobs  - Deploy scripts from c:\programdata\jobs
##    modified to leverage aaure keyvault
##     install-module az  -allowclobber  -Confirm
##     import-module Az.KeyVault -Force
##      install-module nuget   -allowclobber  -Confirm
#####################################################################

<########  Azure module 
'Az.DesktopVirtualization','az.avd', 'az' ,'az.keyvault','nuget' | foreach-object {

install-module -name $_ -allowclobber
import-module -name $_ -force

 update-module $_ -force

}
#>


   # Authenticate with Azure

 $account = connect-azaccount     -id #-Environment AzureUSGovernment 

 $sub = get-azsubscription -SubscriptionName $($account.Context.Subscription.Name)

 set-azcontext -Subscription $($sub.Name)


 $keyvault = 'wolffentpkeyvault'
 $serviceprincipal = 'wwolffadmin'
 
    $keyvaultname = (get-azkeyvault -name $keyvault) 
     
 
 
# Get the secret object from the Key Vault
$secret = Get-AzKeyVaultSecret -VaultName $($keyVaultName.VaultName) -Name  $serviceprincipal

# Get the secret value as a plain text string
$secretValue = $($secret.SecretValue)
   
 $ptsecret =  [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secretValue)) 
 $username = $($secret.Name)

# Authenticate with Azure AD using the application credentials
$credential = New-Object System.Management.Automation.PSCredential($username, $secretValue )


 

Function Create_tempfolder
{
    if   ( !(  Test-Path  -path 'c:\temp')) {
    New-Item -ItemType Directory -path 'C:\temp' -verbose
    write-host " Temp folder created " -ForegroundColor Green -BackgroundColor Black
    }


} 


create_tempfolder


function check_jobs_folder
{

    if   ( !(  Test-Path  -path 'C:\ProgramData\Jobs')) {
    write-warning " C:\ProgramData\Jobs folder does not exist or is not accessible - nothing to create task with" 
  
 exit 1
    } 
     

}
check_jobs_folder

 
# Get the credentials #
# $creds = Get-Credential
 $UserName = $credential.UserName
 $Password = $credential.GetNetworkCredential().Password
 

Function New-ScheduledTaskFolder

    {

     Param ($taskpath)

     $ErrorActionPreference = "stop"

     $scheduleObject = New-Object -ComObject schedule.service

     $scheduleObject.connect()

     $rootFolder = $scheduleObject.GetFolder("\")

        Try {$null = $scheduleObject.GetFolder($taskpath)}

        Catch { $null = $rootFolder.CreateFolder($taskpath) }

        Finally { $ErrorActionPreference = "continue" } }

  $timehour = Get-Date -format "HH tt"

   


Function Create-AndRegisterApplogTask

{

 Param ($taskname, $taskpath,$taskdescription, $username, $Password , $taskfolder, $tasksscript)

 $action = New-ScheduledTaskAction -Execute 'C:\Windows\System32\WindowsPowerShell\v1.0\Powershell.exe' -argument "-ExecutionPolicy Bypass  c:\programdata\jobs\$taskname"
 
 $trigger =  New-ScheduledTaskTrigger -AtLogOn  -User $env:username
$pr = New-ScheduledTaskPrincipal  -Groupid  "INTERACTIVE" 
$trigger.Repetition = (New-ScheduledTaskTrigger -once -at "$timehour" -RepetitionInterval (New-TimeSpan -Minutes 5) -RepetitionDuration (New-TimeSpan -hours 24)).repetition


 Register-ScheduledTask  -Action $action -Trigger $trigger -TaskName  $taskname -Description "$taskdescription" -TaskPath $taskpath -RunLevel Highest   -User "$username" -Password "$Password"  

}

 

Function Create-NewApplotTaskSettings

{

 Param ($taskname, $taskpath,$username, $Password)

 $settings = New-ScheduledTaskSettingsSet -WakeToRun -Hidden   -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Hours 3) -RestartCount 3

 Set-ScheduledTask -TaskName $taskname -Settings $settings -TaskPath $taskpath  -User "$username" -Password "$Password" 

}



### ENTRY POINT ###
#
#taskname = "applog"
 
$timespan = new-timespan -days 0 -hours 0 -minutes 15

 
$tasksfolder ="C:\programdata\Jobs\"
$tasksscripts = Get-ChildItem  $tasksfolder | select name,LastWriteTime |where-object  {$_.LastWriteTime -gt ((get-date) - $timespan) }
$tasksscripts | convertto-csv | out-file c:\temp\tasks_scripts.csv

$tasklist = import-csv c:\temp\tasks_scripts.csv
foreach ($tasksscriptname in $tasklist)
{
$tasksscript = $tasksscriptname.Name
$tasksscript
 
$taskname = $tasksscript
$taskdescription = "AVD_Task_maintenance $taskscript"
$taskpath = "AVD_Maintenance"

If(Get-ScheduledTask -TaskName $taskname -EA 0)

  {Unregister-ScheduledTask -TaskName $taskname -Confirm:$false}

New-ScheduledTaskFolder -taskname $taskname -taskpath $taskpath  -taskfolder $taskfolder -taskscript $tasksscripts -Argument "$taskfolder$taskname" 

Create-AndRegisterApplogTask -taskname $taskname -taskpath $taskpath -taskfolder $taskfolder -taskdescription $taskdescription -taskscript $tasksscripts -Username $username -Password $Password -Argument "c:\programdata\jobs\$taskname" | Out-Null

Create-NewApplotTaskSettings -taskname $taskname -taskpath $taskpath -User  $username -Password $Password  | Out-Null
}








