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
  Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings 'true'

  $erroractionpreference = 'silentlycontinue'

Connect-AzAccount # -identity -Environment AzureUSGovernment

$tenantlist = get-aztenant | Select-Object -property *  
 
$costreport = ''

$today = get-date -format 'yyyyMM'
$today
$numberofmonths = 5

 $date = ((Get-Date).AddMonths(-$numberofmonths) )
 
$datestart = get-date($today) -Format 'yyyyMM'
 

$invoicerpt = ''
 

foreach($tenant in $tenantlist)
{

    set-azcontext -Tenant $($tenant.Id) 

$month = $numberofmonths 

    do
    {
          $billing_account = Get-AzBillingAccount  -IncludeAddress
        
        $billingmonth = ((Get-Date).AddMonths(-$month)) 
        $billingdate = get-date($billingmonth ) -Format 'yyyyMM'

        $billingdate

                ####### collect pretaxcost per subscription
              
                  $costalls =  Get-AzConsumptionUsageDetail -BillingPeriodName $billingdate  -IncludeAdditionalProperties   

            $a =0

                        $costfields = $costalls | select-object *

                foreach($costield in $costfields)
                {
                     $a = $a+1

                    # Determine the completion percentage
                    $ResourcesCompleted = ($a/$costfields.count) * 100
                    $Resourceactivity = "costs  - Processing Iteration " + ($a + 1);

                    $costobj = new-object PSObject 

                     $costield.Tags.GetEnumerator() | ForEach-Object {

               #    Write-Output "$($_.key)   = $($_.Value)" 
                   $costtags = "$($_.key)   = $($_.Value)" 
 
                  # $costobj | add-member -membertype Noteproperty -name $($_.key) -value $($_.value)

                   }

                $costobj | add-member -membertype noteproperty -name AccountName           -value $($costield.AccountName)
                $costobj | add-member -membertype noteproperty -name AdditionalInfo        -value $($costield.AdditionalInfo)
                $costobj | add-member -membertype noteproperty -name AdditionalProperties  -value $($costield.AdditionalProperties)
                $costobj | add-member -membertype noteproperty -name BillableQuantity      -value $($costield.BillableQuantity)
                $costobj | add-member -membertype noteproperty -name BillingPeriodId       -value $($costield.BillingPeriodId)
                $costobj | add-member -membertype noteproperty -name BillingPeriodName     -value $($costield.BillingPeriodName)
                $costobj | add-member -membertype noteproperty -name ConsumedService       -value $($costield.ConsumedService)
                $costobj | add-member -membertype noteproperty -name CostCenter            -value $($costield.CostCenter)
                $costobj | add-member -membertype noteproperty -name Currency              -value $($costield.Currency)
                $costobj | add-member -membertype noteproperty -name DepartmentName        -value $($costield.DepartmentName)
                $costobj | add-member -membertype noteproperty -name Id                    -value $($costield.Id)
                $costobj | add-member -membertype noteproperty -name InstanceId            -value $($costield.InstanceId)
                $costobj | add-member -membertype noteproperty -name InstanceLocation      -value $($costield.InstanceLocation)
                $costobj | add-member -membertype noteproperty -name InstanceName          -value $($costield.InstanceName)
                $costobj | add-member -membertype noteproperty -name InvoiceId             -value $($costield.InvoiceId)
                $costobj | add-member -membertype noteproperty -name InvoiceName           -value $($costield.InvoiceName)
                $costobj | add-member -membertype noteproperty -name IsEstimated           -value $($costield.IsEstimated)
                $costobj | add-member -membertype noteproperty -name MeterDetails          -value $($costield.MeterDetails)
                $costobj | add-member -membertype noteproperty -name MeterId               -value $($costield.MeterId)
                $costobj | add-member -membertype noteproperty -name Name                  -value $($costield.Name)
                $costobj | add-member -membertype noteproperty -name PretaxCost            -value $($costield.PretaxCost)
                $costobj | add-member -membertype noteproperty -name Product               -value $($costield.Product)
                $costobj | add-member -membertype noteproperty -name SubscriptionGuid      -value $($costield.SubscriptionGuid)
                $costobj | add-member -membertype noteproperty -name SubscriptionName      -value $($costield.SubscriptionName)
                $costobj | add-member -membertype noteproperty -name Tags                  -value $costtags
                $costobj | add-member -membertype noteproperty -name Type                  -value $($costield.Type)
                $costobj | add-member -membertype noteproperty -name UsageEnd              -value $($costield.UsageEnd)
                $costobj | add-member -membertype noteproperty -name UsageQuantity         -value $($costield.UsageQuantity)
                $costobj | add-member -membertype noteproperty -name UsageStart            -value $($costield.UsageStart)

                [array]$costreport += $costobj

                        


                    }
            $month = $month -1

        }until ($month -eq  0)

 

        

}
                           
     set-azcontext -Tenant $($tenant.Id) 

       $invoices =  Get-AzBillingInvoice  | select -Property *
                     $invoice

        foreach ($invoice in $invoices)
        {
           $Subscriptionname = get-azsubscription -SubscriptionId $($invoice.SubscriptionId)  -TenantId $($tenantlist.Id) | select name

                $Invoiceobj = new-object PSObject

                        $Invoiceobj | Add-Member -MemberType NoteProperty -Name Name -value $($invoice.name)
                        $Invoiceobj | Add-Member -MemberType NoteProperty -Name InvoiceDate -value $($invoice.InvoiceDate)
                        $Invoiceobj | Add-Member -MemberType NoteProperty -Name InvoicePeriodStartDate -value $($invoice.InvoicePeriodStartDate)
                        $Invoiceobj | Add-Member -MemberType NoteProperty -Name InvoicePeriodEndDate -value $($invoice.InvoicePeriodEndDate)
                        $Invoiceobj | Add-Member -MemberType NoteProperty -Name Status -value $($invoice.Status)
                        $Invoiceobj | Add-Member -MemberType NoteProperty -Name SubscriptionId -value $($invoice.SubscriptionId)
                        $Invoiceobj | Add-Member -MemberType NoteProperty -Name Subscriptionname -value $($Subscriptionname.Name)
                        $Invoiceobj | Add-Member -MemberType NoteProperty -Name subtotal -value $($invoice.SubTotal)
                        $Invoiceobj | Add-Member -MemberType NoteProperty -Name AmountDue -value $($invoice.AmountDue).Value
                        $Invoiceobj | Add-Member -MemberType NoteProperty -Name BilledAmount -value $($invoice.BilledAmount).Value
                        $Invoiceobj | Add-Member -MemberType NoteProperty -Name TaxAmount -value $($invoice.TaxAmount).Value
                        $Invoiceobj | Add-Member -MemberType NoteProperty -Name DueDate -value $($invoice.DueDate)                        
                        
                                            
                        [array]$invoicerpt +=  $Invoiceobj 
        }
  

 

#$costreport


 $resultsfilename = "AzureBillingCosts.csv"

 $resultsfilename2 = "invoices.csv"
 


$costreport |select `
AccountName          , `
AdditionalInfo       , `
AdditionalProperties , `
BillableQuantity     , `
BillingPeriodId      , `
BillingPeriodName    , `
ConsumedService      , `
CostCenter           , `
Currency             , `
DepartmentName       , `
Id                   , `
InstanceId           , `
InstanceLocation     , `
InstanceName         , `
InvoiceId            , `
InvoiceName          , `
IsEstimated          , `
MeterDetails         , `
MeterId              , `
Name                 , `
PretaxCost           , `
Product              , `
SubscriptionGuid     , `
SubscriptionName     , `
Tags                 , `
Type                 , `
UsageEnd             , `
UsageQuantity        , `
UsageStart          | export-csv $resultsfilename  -NoTypeInformation   

 
 
 
$invoicerpt|  Select name, InvoiceDate, InvoicePeriodStartDate, InvoicePeriodEndDate, Status, SubscriptionId,Subscriptionname,subtotal,AmountDue,BilledAmount,TaxAmount, DueDate| export-csv $resultsfilename2  -NoTypeInformation 


##### storage subinfo

connect-azaccount 
 

$Region =  "West US"

 $subscriptionselected = 'wolffentpSub'



$resourcegroupname = 'wolffautomationrg'
$subscriptioninfo = get-azsubscription -SubscriptionName $subscriptionselected 
$TenantID = $subscriptioninfo | Select-Object tenantid
$storageaccountname = 'wolffautosa'
$storagecontainer = 'wpicorpbilling'


### end storagesub info

set-azcontext -Subscription $($subscriptioninfo.Name)  -Tenant $($TenantID.TenantId)

 

#BEGIN Create Storage Accounts
 
 
 
 try
 {
     if (!(Get-AzStorageAccount -ResourceGroupName $resourcegroupname -Name $storageaccountname ))
    {  
        Write-Host "Storage Account Does Not Exist, Creating Storage Account: $storageAccount Now"

        # b. Provision storage account
        New-AzStorageAccount -ResourceGroupName $resourcegroupname  -Name $storageaccountname -Location $region -AccessTier Hot -SkuName Standard_LRS -Kind BlobStorage -Tag @{"owner" = "Jerry wolff"; "purpose" = "Az Automation storage write" } -Verbose
 
     
        Get-AzStorageAccount -Name   $storageaccountname  -ResourceGroupName  $resourcegroupname  -verbose
     }
   }
   Catch
   {
         WRITE-DEBUG "Storage Account Aleady Exists, SKipping Creation of $storageAccount"
   
   } 
        $StorageKey = (Get-AzStorageAccountKey -ResourceGroupName $resourcegroupname  –StorageAccountName $storageaccountname).value | select -first 1
        $destContext = New-azStorageContext  –StorageAccountName $storageaccountname `
                                        -StorageAccountKey $StorageKey


             #Upload user.csv to storage account

        try
            {
                  if (!(get-azstoragecontainer -Name $storagecontainer -Context $destContext))
                     { 
                         New-azStorageContainer $storagecontainer -Context $destContext
                        }
             }
        catch
             {
                Write-Warning " $storagecontainer container already exists" 
             }
       

         Set-azStorageBlobContent -Container $storagecontainer -Blob $resultsfilename  -File $resultsfilename -Context $destContext -Force


$storageaccountname = 'wolffautosa'
$storagecontainer = 'invoices'
       try
            {
                  if (!(get-azstoragecontainer -Name $storagecontainer -Context $destContext))
                     { 
                         New-azStorageContainer $storagecontainer -Context $destContext
                        }
             }
        catch
             {
                Write-Warning " $storagecontainer container already exists" 
             }
       
 
          Set-azStorageBlobContent -Container $storagecontainer -Blob $resultsfilename2  -File $resultsfilename2 -Context $destContext -Force
