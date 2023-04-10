<#
 
.SYNOPSIS  
    script for Azure to check quota limit for sufficient allocation available to deploy Azure resources

.DESCRIPTION  
   script for Azure to check quota limit for sufficient allocation available to deploy Azure resources

Script: Check_quota_and_create_support_ticket_for_quota_increase_context_change_params.ps1

.EXAMPLE  

Example C:\Users\jerrywolff\OneDrive - Microsoft\Documents\azure\PS1\Quota> .\Check_quota_and_create_support_ticket_for_quota_increase_context_change_params.ps1 -SubscriptionId 'xxxxx-xxxxx-xxx-xxxxxx' -Location 'centralus' -SkuName standardFFamily -Threshold 20 -Corecountrequests 500

 
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


         param(
            [Parameter(Mandatory = $true)]
            [string]$SubscriptionId,

            [Parameter(Mandatory = $true)]
            [string]$Location,

            [Parameter(Mandatory = $true)]
            [string]$SkuName,

            [Parameter(Mandatory = $true)]
            [int]$Threshold,

            [Parameter(Mandatory = $true)]
            [int]$Corecountrequests
        )



 Connect-AzAccount

        import-module az.capacity -Force -ErrorAction SilentlyContinue
        import-module  az.quota -Force -ErrorAction SilentlyContinue

         sl 'C:\Users\jerrywolff\OneDrive - Microsoft\Documents\azure\PS1\Quota'

          Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings 'true'


$subscriptions = get-azsubscription -SubscriptionId $SubscriptionId

$subscriptionselected = $subscriptions | select name, id, tenantid  

set-azcontext -Subscription  "$($subscriptionselected.id)" -Tenant $($subscriptionselected.TenantId)
 
$context = get-azcontext   |  where name -like "*$($subscriptionselected.name)*"  





# install-module az.quota -allowclobber 

import-module az.quota -force 

Get-AzResourceProvider -ListAvailable | where ProviderNamespace -eq 'microsoft.quota' |  Register-AzResourceProvider -ErrorAction SilentlyContinue


Get-AzResourceProvider -ListAvailable | where ProviderNamespace -eq 'microsoft.quota'


   $region =   get-azlocation | where-object {$_.location -eq "$Location" }
 

############################   Get region/Location for request
 
    If( $($region.Location) -eq $null )
    {
            write-host "$Location was not found  Please check spelling and or use the location name ex: 'centralus' instead of 'Central US' " -ForegroundColor Red -BackgroundColor white

            $validregions = get-azlocation | select Location 

            Write-host " Valid region/location names are: $($validregions.location)   "   -ForegroundColor Red -BackgroundColor white
            exit

         }
         Else
         {

        ########################  Get Sku Family 
        #$skuname = 'standardFFamily'
            $regionquotausage =    Get-AzVmUsage –Location $Location   -ErrorAction SilentlyContinue

        if(!($($regionquotausage.name.value) | where-object {$_ -eq "$skuname"}) )
        {
                Write-Warning " $skuname was not found or is not properly named Please try one of the following " 
                write-host "$($regionquotausage.name.value)" -ForegroundColor DarkRed -BackgroundColor white  
                exit
         }
          else{
   
 
                 $regionquotaselected = $($regionquotausage.name.value)  | Where-Object {$_ -eq "$skuname"}
                write-host " $($regionquotaselected.name.Value)" -ForegroundColor Green
          }
}
  
  ################  Get current quota value 

  
$quota = get-azquota -Scope  "subscriptions/$($subscriptionselected.id)/providers/Microsoft.compute/locations/$location" -ResourceName   "$regionquotaselected"

write-host "Your current quota limit is $($quota.limit.value) for   $regionquotaselected " -BackgroundColor yellow -ForegroundColor Blue
   #$quota


 
##############################  Select limit for request
 

 

  $NewLimitIncrement = $Corecountrequests




############################# Find current usage for the Sku/Family
 
 
$Location = "$($regionlist.Location)"
  

$VMFamily =  $regionquotaselected  


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



