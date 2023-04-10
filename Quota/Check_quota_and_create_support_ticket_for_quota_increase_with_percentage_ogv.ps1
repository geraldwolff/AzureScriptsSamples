
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

    Script Name: Check_quota_and_create_support_ticket_for_quota_increase_with_percentage_ogv.ps1
    Description: Custom script to check on quota percentage based on requested use 
    NOTE:   Scripts interactive sscript to:
        - check quota based on location and sku type
        - creates an HTML report with the percentage against requested amount and recommended amount to increase limit
        - and submit a support ticket for capacity quota limit increase 


#> 

####### Suppress powershell module changes warning during execution 
$context = Connect-AzAccount


# install-module az.quota -allowclobber 

import-module az.quota -force 

Get-AzResourceProvider -ListAvailable | where ProviderNamespace -eq 'microsoft.quota' |  Register-AzResourceProvider -ErrorAction SilentlyContinue


Get-AzResourceProvider -ListAvailable | where ProviderNamespace -eq 'microsoft.quota'


$subscriptions = get-azsubscription 

$subscriptionselected = $subscriptions | select name, id, tenantid | ogv -Title " Select the subscription to request quota increase for" -PassThru | `
Select name, ID, Tenantid 




        $locname  = Get-azLocation | `
                    select displayname, Location | `
                    Out-GridView -PassThru -Title "Choose a location"


            $regionlist = $locname



      $regionquotausage =    Get-AzVmUsage –Location $($regionlist.DisplayName)   -ErrorAction SilentlyContinue


      #Get-AzQuota -Scope "subscriptions/9e223dbe-3399-4e19-88eb-0975f02ac87f/providers/Microsoft.Network/locations/eastus"

   $regionquotaselected =  $regionquotausage    |`
       Out-GridView -Title " Select Sku Family quota to increase "  -PassThru | select name, CurrentValue, limit 
 
  $regionquotaselected.Name.Value

  
$quota = get-azquota -Scope  "subscriptions/$($subscriptionselected.id)/providers/Microsoft.compute/locations/$($regionlist.Location)" -ResourceName   $($regionquotaselected.Name.Value)


$quota


$increments = @()
for ($i = 0; $i -le 1000; $i += 50) {
    $increments += $i
}

##############################

$QuotaPercentageThreshold = ''


$QuotaPercentageThreshold = @()
for ($i = 0; $i -le 100; $i += 10) {
    $QuotaPercentageThreshold += $i
}

 
 
 $newdesireThreshold = $($QuotaPercentageThreshold) | select  $_ | ogv -Title " Select new percentage threshold desired" -PassThru 

  $newdesireThreshold

#############################

 $NewLimitIncrement = $($increments) | select  $_ | ogv -Title " Select new request total Amount " -PassThru 

  $NewLimitIncrement 

#############################

 

#$QuotaPercentageThreshold = "0"
#$NewLimitIncrement = "25"
$Location = "$($regionlist.Location)"
$VMSize = 'Standard_D2_v2'

$SKU = Get-AzComputeResourceSku -Location $Location |`
 Where-Object ResourceType -eq "virtualMachines" | Select-Object Name,Family

  

$VMFamily =  $($regionquotaselected.name.value)  # | Where-Object Name -eq $VMSize | Select-Object -Property Family).Family


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
 $context = get-azcontext 
$owner = $($context.account) -split('@')
 
$ownername = ($owner[0]).split('.')

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
$Country = "USA"
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

    #  Uncomment to actually submit a ticket ##################

    New-AzSupportTicket `
        -Name "$TicketName" `
        -Title "$TicketTitle" `
        -Description "$TicketDescription" `
        -Severity "$Severity" `
        -ProblemClassificationId "/providers/Microsoft.Support/services/$ServiceNameGUID/problemClassifications/$ProblemClassificationGUID" `
        -QuotaTicketDetail @{QuotaChangeRequestVersion = "1.0" ; QuotaChangeRequests = (@{Region = "$Location"; Payload = "{`"VMFamily`":`"$VMFamily `",`
        `"NewLimit`":$NewLimit}"})} -CustomerContactDetail @{FirstName = "$ContactFirstName" ; LastName = "$ContactLastName" ; PreferredTimeZone = "$TimeZone" `
        ; PreferredSupportLanguage = "$Language" ; Country = "$Country" ; PreferredContactMethod = "Email" ; PrimaryEmailAddress = "$PrimaryEmail" } -AsJob
        
    #

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

