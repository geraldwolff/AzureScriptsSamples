<#
 
.SYNOPSIS  
    script for Azure to check quota limit for sufficient allocation available to deploy Azure resources and request and quota limit increase

.DESCRIPTION  
   script for Azure to check quota limit for sufficient allocation available to deploy Azure resources and request and quota limit increase

Script: Check_quota_and_create_support_ticket_for_quota_increase_context_change.ps1

.EXAMPLE  

Example  .\Check_quota_and_create_support_ticket_for_quota_increase_context_change.ps1  - interactive script 
 
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


Connect-AzAccount

 


$subscriptions = get-azsubscription 

$subscriptionselected = $subscriptions | select name, id, tenantid | ogv -Title " Select the subscription to request quota increase for" -PassThru | `
Select name, ID, Tenantid 

set-azcontext -Subscription  "$($subscriptionselected.id)" -Tenant $($subscriptionselected.TenantId)
 
$context = get-azcontext   |  where name -like "*$($subscriptionselected.name)*"  





# install-module az.quota -allowclobber 

import-module az.quota -force 

Get-AzResourceProvider -ListAvailable | where ProviderNamespace -eq 'microsoft.quota' |  Register-AzResourceProvider -ErrorAction SilentlyContinue


Get-AzResourceProvider -ListAvailable | where ProviderNamespace -eq 'microsoft.quota'




############################   Get region/Location for request

        $locname  = Get-azLocation | `
                    select displayname, Location | `
                    Out-GridView -PassThru -Title "Choose a location"


            $regionlist = $locname

########################  Get Sku Family 

      $regionquotausage =    Get-AzVmUsage –Location $($regionlist.DisplayName)   -ErrorAction SilentlyContinue

 
 
   $regionquotaselected =  $regionquotausage    |`
       Out-GridView -Title " Select Sku Family quota to increase "  -PassThru | select name, CurrentValue, limit 
 
  #$regionquotaselected.Name.Value
  
  
  ################  Get current quota value 

  
$quota = get-azquota -Scope  "subscriptions/$($subscriptionselected.id)/providers/Microsoft.compute/locations/$($regionlist.Location)" -ResourceName   $($regionquotaselected.Name.Value)

write-host "Your current quota limit is $($quota.limit.value) for $($regionquotaselected.Name.Value) " -BackgroundColor yellow -ForegroundColor Blue
   #$quota


$increments = @()
for ($i = 0; $i -le 1000; $i += 50) {
    $increments += $i
}

##############################  Select limit for request
 

 $NewLimitIncrement = $($increments) | select  $_ | ogv -Title " Select new request total Amount " -PassThru 

  $NewLimitIncrement 




############################# Find current usage for the Sku/Family
 
 
$Location = "$($regionlist.Location)"
  

$VMFamily =  $($regionquotaselected.name.value)   


$Usage = Get-AzVMUsage -Location $Location | Where-Object { $_.Name.Value -eq $VMFamily } |`
 Select-Object @{label="Name";expression={$_.name.LocalizedValue}},currentvalue,limit, `
  @{label="PercentageUsed";expression={[math]::Round(($_.currentvalue/$_.limit)*100,1)}}


$NewLimit = $($Usage.Limit) + $($NewLimitIncrement)


##################################################################
#Ticket Details


$TicketName =  "Quota_Request"

$TicketTitle = "Quota Request"

$TicketDescription = "Quota request for $VMFamily with a new limit of $NewLimitIncrement "

$Severity = "minimal" #Minimal, Moderate, Critical, HighestCriticalImpact

 
####################
 
$owner = $($context.account) -split('@')
 

$email = $($context.account)
$AdditionalEmail = $($context.account)
$tz =  (Get-TimeZone).id
$locallanguage = (Get-UICulture).Name
$origincountryraw = (((Get-UICulture).displayname).Split('(')).Replace(')','')
$origincountry = ($origincountryraw)[-1]

$ContactFirstName = ($($ownername) -split (' '))[0]
$ContactLastName =  ($($ownername) -split (' '))[-1]
$TimeZone = "$tz"
$Language = "$locallanguage"
$Country = "$origincountry"
$PrimaryEmail = "$email"
$AdditionalEmail = "$email"

 


$ContactFirstName  
$ContactLastName  
$TimeZone 
$Language  
$Country  
$PrimaryEmail  
$AdditionalEmail 







######################

$ServiceNameGUID = "06bfd9d3-516b-d5c6-5802-169c800dec89" 
$ProblemClassificationGUID = "599a339a-a959-d783-24fc-81a42d3fd5fb"


 #Get-AzSupportService   | where name -eq $ServiceNameGUID | Get-AzSupportProblemClassification | where displayname -like '*Compute*'
  
 
 #Get-AzSupportService    | Get-AzSupportProblemClassification | where-object { $_.Name -eq "599a339a-a959-d783-24fc-81a42d3fd5fb"}

  ##################  Verify request

Write-Output "$($Usage.Name.LocalizedValue): You have consumed Percentage: $($USage.PercentageUsed)% | $($Usage.CurrentValue) /$($Usage.Limit) of available quota"

 if ($($USage.Limit -lt $NewLimitIncrement))
 { 

    Write-Output "Creating support case"

   Write-host "$($USage.Limit) is less than $NewLimit selected. The request for Limit of $NewLimit will be submitted " -ForegroundColor green
   
   Write-host "Please review request " -ForegroundColor Cyan

   Write-host "  
        Description $TicketDescription `
        Severity $Severity `
        QuotaTicketDetail QuotaChangeRequestVersion = 1.0 `
        QuotaChangeRequests = Region = $Location;`
        Payload =  VMFamily :$VMFamily  `
        NewLimit:$NewLimit `
        CustomerContactDetail FirstName = $ContactFirstName ; LastName = $ContactLastName `
        PreferredTimeZone = $TimeZone `
        PreferredSupportLanguage = $Language `
        Country = $Country `
        PreferredContactMethod = Email `
        PrimaryEmailAddress = $PrimaryEmail   " -ForegroundColor cyan
   

   $answer = 'Confirm','Cancel'

   $answerselected = $answer | ogv -Title " Please provide confirmation" -PassThru 

   if ($answerselected  -eq 'Confirm')
   {
    

    Write-host " processing order: ......... 
        Description $TicketDescription `
        Severity $Severity `
        QuotaTicketDetail QuotaChangeRequestVersion = 1.0 `
        QuotaChangeRequests = Region = $Location;`
        Payload =  VMFamily :$VMFamily  `
        NewLimit:$NewLimit `
        CustomerContactDetail FirstName = $ContactFirstName ; LastName = $ContactLastName `
        PreferredTimeZone = $TimeZone `
        PreferredSupportLanguage = $Language `
        Country = $Country `
        PreferredContactMethod = Email `
        PrimaryEmailAddress = $PrimaryEmail " -ForegroundColor green -BackgroundColor black

    <#

    New-AzSupportTicket `
        -Name "$TicketName" `
        -Title "$TicketTitle" `
        -Description "$TicketDescription" `
        -Severity "$Severity" `
        -ProblemClassificationId "/providers/Microsoft.Support/services/$ServiceNameGUID/problemClassifications/$ProblemClassificationGUID" `
        -QuotaTicketDetail @{QuotaChangeRequestVersion = "1.0" ; QuotaChangeRequests = (@{Region = "$Location"; Payload = "{`"VMFamily`":`"$VMFamily `",`
        `"NewLimit`":$NewLimit}"})} -CustomerContactDetail @{FirstName = "$ContactFirstName" ; LastName = "$ContactLastName" ; PreferredTimeZone = "$TimeZone" `
        ; PreferredSupportLanguage = "$Language" ; Country = "$Country" ; PreferredContactMethod = "Email" ; PrimaryEmailAddress = "$PrimaryEmail" } 
        
    #>

    }
    else
        {

            write-warning " You elected to cancel the order"  
            
            
        }
}
  
 else
 {
        write-warning "$($USage.Limit) is greater than $NewLimitIncrement selected" 


 }



