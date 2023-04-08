<#
.SYNOPSIS  
 Wrapper script for get_vm_aggregate_usage_unused_VMs 
.DESCRIPTION  
Script to collect usage data over period of time to identify unused VMs
.EXAMPLE  
.\automation_get_vm_aggregate_usage_unused_VM.ps1  -FromTime "<Date_Time_12:00:00>" -ToTime "<Date_Time_12:00:00>" -Interval ('Hourly', 'Daily')
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

try
{
    "Logging in to Azure..."
   Connect-AzAccount -Identity
  
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}

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
 

Function Get-AzureUsage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [datetime]$FromTime,
 
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [datetime]$ToTime,
 
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Hourly', 'Daily')]
        [string]$Interval = 'Daily',

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Int]$daysRange

    )
    
    Write-Verbose -Message "Querying usage data [$($FromTime) - $($ToTime)]..."
    $usageData = $null

 

    do {    
        $params = @{
            ReportedStartTime      = $FromTime
            ReportedEndTime        = $ToTime
            AggregationGranularity = $Interval
            ShowDetails            = $true
        }

        if ((Get-Variable -Name usageData -ErrorAction Ignore) -and $usageData) {
            Write-Verbose -Message "Querying usage data with continuation token $($usageData.ContinuationToken)..."
            $params.ContinuationToken = $usageData.ContinuationToken
        }
        $usageData = Get-UsageAggregates @params
        $usageData.UsageAggregations | Select-Object -ExpandProperty Properties
    } while ('ContinuationToken' -in $usageData.psobject.properties.name -and $usageData.ContinuationToken)
}

$usagesummary = ''

$days = 7

 #get the last 3 days data
         #end date
         $ToTime = Get-Date -Hour 0 -Minute 0 -Second 0 -Format "MM/dd/yyyy HH:mm:ss"

         #start date
         $FromTime = get-date (get-date).AddDays(-$days)  -Hour 0 -Minute 0 -Second 0 -Format "MM/dd/yyyy HH:mm:ss"
        
        # Solution 1
        #$midnight = Get-Date -Hour 0 -Minute 0 -Second 0
 
        # Solution 2
       # $midnight = [datetime]::Today

$azureusage = Get-AzureUsage -FromTime $FromTime -ToTime $ToTime -Interval  Daily -daysrange 7

$azureusageresources = $azureusage | where-object {$_.MeterCategory -like '*Machine*'} 

foreach($azusageresource in $azureusageresources)
{

   $resourceuri =  ($azusageresource.InstanceData.split(':')[2]).split('"')[1]
    $resourcedata =  Get-AzResource -ResourceId    $resourceuri
    $tags = get-aztag -ResourceId  $resourceuri
    $tagkey = "$($tags.Properties.TagsProperty.keys)"
    $tagvalues = $($tags.Properties.TagsProperty.Values)

    $resouceobj = New-Object PSObject
    $resouceobj | Add-Member -MemberType NoteProperty -name ResourceName  -Value  $($resourcedata.name)
    $resouceobj | Add-Member -MemberType NoteProperty -name ResourceGroupName  -Value  $($resourcedata.ResourceGroupName)
    $resouceobj | Add-Member -MemberType NoteProperty -name Tag  -Value  "$($tags.Properties.TagsProperty.keys)"
    $resouceobj | Add-Member -MemberType NoteProperty -name Tagvalue   "$($tagvalues)"
    $resouceobj | Add-Member -MemberType NoteProperty -name MeterCategory  -Value  $($azusageresource.MeterCategory)
    $resouceobj | Add-Member -MemberType NoteProperty -name MeterId -Value  $($azusageresource.MeterId)
    $resouceobj | Add-Member -MemberType NoteProperty -name MeterName -Value   $($azusageresource.MeterName)
    $resouceobj | Add-Member -MemberType NoteProperty -name MeterRegion -Value   $($azusageresource.MeterRegion)
    $resouceobj | Add-Member -MemberType NoteProperty -name MeterSubCategory -Value   $($azusageresource.MeterSubCategory)
    $resouceobj | Add-Member -MemberType NoteProperty -name Quantity -Value  $($azusageresource.Quantity)
    $resouceobj | Add-Member -MemberType NoteProperty -name Unit -Value  $($azusageresource.Unit)
    $resouceobj | Add-Member -MemberType NoteProperty -name UsageEndTime -Value  $($azusageresource.UsageEndTime)
    $resouceobj | Add-Member -MemberType NoteProperty -name UsageStartTime -Value  $($azusageresource.UsageStartTime)

    [array]$usagesummary += $resouceobj
}





#$usagesummary | where-object {$_.MeterCategory -eq 'Virtual Machines'} 




$CSS = @"
<Title>VM Usage $days range   Report:$(Get-Date -Format 'dd MMMM yyyy' )</Title>
<Header>
 
"<B>VM Usage $days day range   Report:$(Get-Date -Format 'dd MMMM yyyy' ) - 
Company Confidential</B> <br><I>Report generated from {3} on $env:computername {0} by {1}\{2} as a scheduled task</I><br><br>Please contact $contact with any questions "$(Get-Date -displayhint date)",$env:userdomain,$env:username
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





 
 

(($usagesummary |
Select ResourceName,resourcegroupname,  Tag, Tagvalue,MeterId ,MeterName,MeterRegion,MeterSubCategory,Quantity,Unit,UsageEndTime,UsageStartTime |`
ConvertTo-Html -Head $CSS ).replace('Quantity','<font color=red>Quantity</font>'))   | Out-File "c:\temp\vm_Usage.html"
 Invoke-Item "c:\temp\vm_Usage.html"








