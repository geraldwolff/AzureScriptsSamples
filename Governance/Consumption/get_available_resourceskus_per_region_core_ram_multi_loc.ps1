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

 ######################
 ##  Necessary Modules to be imported.

import-module Az.Compute -force 

 ############
 ## connect to Azure with authorized credentials 
 
 Connect-AzAccount




$Locations  = Get-azLocation | `
select displayname | `
Out-GridView -PassThru -Title "Choose a location"

foreach($locname in $locations)
{

    $Available_resourceskus  = Get-AzComputeResourceSku  $locname.DisplayName     


    $Available_Sizes = Get-AZVMSize -Location $locname.DisplayName  | select *



    $skuavaiability_chart = ''

    #### Source data fields

    <#
    ResourceType : virtualMachines
    Name         : Standard_E16bs_v5
    Tier         : Standard
    Size         : E16bs_v5
    Family       : standardEBSv5Family
    Kind         : 
    Capacity     : 
    Locations    : {westus}
    LocationInfo : {Microsoft.Azure.Management.Compute.Models.ResourceSkuLocationInfo}
    ApiVersions  : {}
    Costs        : {}
    Capabilities : {MaxResourceVolumeMB, OSVhdSizeMB, vCPUs, MemoryPreservingMaintenanceSupported...}
    Restrictions : {}
    #>

    <#

    MaxDataDiskCount     : 32
    MemoryInMB           : 131072
    Name                 : Standard_E16-4s_v3
    NumberOfCores        : 16
    OSDiskSizeInMB       : 1047552
    ResourceDiskSizeInMB : 262144
    RequestId            : 09d2fa0e-5e34-45e7-bef5-29c5c2ce8940
    StatusCode           : OK

    #>

    foreach ($Available_resourcesku in $Available_resourceskus)
    {
        foreach($Available_Size in $Available_Sizes | where-object {$_.name -eq $($Available_resourcesku.Name) } )
        {
        
            $regionalSkuStatusobj = new-object PSObject 


            $regionalSkuStatusobj | Add-Member -MemberType NoteProperty -Name  ResourceType     -Value   $($Available_resourcesku.ResourceType)
            $regionalSkuStatusobj | Add-Member -MemberType NoteProperty -Name  Name     -Value   $($Available_resourcesku.Name)
            $regionalSkuStatusobj | Add-Member -MemberType NoteProperty -Name Tier      -Value   $($Available_resourcesku.Tier)
            $regionalSkuStatusobj | Add-Member -MemberType NoteProperty -Name Size      -Value   $($Available_resourcesku.Size)
            $regionalSkuStatusobj | Add-Member -MemberType NoteProperty -Name Family      -Value   $($Available_resourcesku.Family)
            $regionalSkuStatusobj | Add-Member -MemberType NoteProperty -Name Kind      -Value   $($Available_resourcesku.Kind)
            $regionalSkuStatusobj | Add-Member -MemberType NoteProperty -Name Capacity      -Value   $($Available_resourcesku.Capacity)
            $regionalSkuStatusobj | Add-Member -MemberType NoteProperty -Name Locations      -Value   $($Available_resourcesku.Locations)
            $regionalSkuStatusobj | Add-Member -MemberType NoteProperty -Name LocationInfo      -Value   $($Available_resourcesku.LocationInfo.Capacity)
            $regionalSkuStatusobj | Add-Member -MemberType NoteProperty -Name ApiVersions      -Value   $($Available_resourcesku.ApiVersions)
            $regionalSkuStatusobj | Add-Member -MemberType NoteProperty -Name Costs      -Value   $($Available_resourcesku.Costs)
            $regionalSkuStatusobj | Add-Member -MemberType NoteProperty -Name Capabilities      -Value $($Available_resourcesku.Capabilities.Capacity)
            $regionalSkuStatusobj | Add-Member -MemberType NoteProperty -Name Restrictions      -Value ($($Available_resourcesku.Restrictions).reasoncode  | select -first 1)
            $regionalSkuStatusobj | Add-Member -MemberType NoteProperty -Name SizeMaxDataDiskCount      -Value $( $Available_Size.MaxDataDiskCount)  
            $regionalSkuStatusobj | Add-Member -MemberType NoteProperty -Name MemoryInMB      -Value $( $Available_Size.MemoryInMB)  
            $regionalSkuStatusobj | Add-Member -MemberType NoteProperty -Name SKUName      -Value  $($Available_Size.name) 
            $regionalSkuStatusobj | Add-Member -MemberType NoteProperty -Name NumberOfCores      -Value   $( $Available_Size.NumberOfCores)
            $regionalSkuStatusobj | Add-Member -MemberType NoteProperty -Name OSDiskSizeInMB      -Value   $( $Available_Size.OSDiskSizeInMB)
            $regionalSkuStatusobj | Add-Member -MemberType NoteProperty -Name ResourceDiskSizeInMB      -Value  $($Available_Size.ResourceDiskSizeInMB)  
            $regionalSkuStatusobj | Add-Member -MemberType NoteProperty -Name RequestId      -Value    $($Available_Size.RequestId) 
            $regionalSkuStatusobj | Add-Member -MemberType NoteProperty -Name StatusCode      -Value    $($Available_Size.StatusCode) 
 
                                                            
            [array]$skuavaiability_chart += $regionalSkuStatusobj    


        }



    }                       


$skuavaiability_chart | export-csv c:\temp\azureskuavailability_by_region.csv


$CSS = @"
<Title>Azure Capacity by Location Report:$(Get-Date -Format 'dd MMMM yyyy' )</Title>
<Header>
 
"<B>Azure Capacity</B> <br><I>Report generated from {3} on $env:computername {0} by {1}\{2} as a scheduled task</I><br><br>Please contact $contact with any questions "$(Get-Date -displayhint date)",$env:userdomain,$env:username
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





 $location = $($locname.Displayname).replace(' ','')
 

(($skuavaiability_chart  | Select Locations, ResourceType,  Tier, Size,Family ,Kind, Capacity,  LocationInfo,  ApiVersions,   Costs,  Capabilities, Restrictions ,MaxDataDiskCount, MemoryInMB, `
  Name, NumberOfCores, OSDiskSizeInMB , ResourceDiskSizeInMB, RequestId, StatusCode | `
ConvertTo-Html -Head $CSS ).replace('NotAvailableForSubscription','<font color=red>NotAvailableForSubscription</font>'))    | Out-File c:\temp\azureskuavailability_by_region_$location.html
 Invoke-Item c:\temp\azureskuavailability_by_region_$location.html


 (($skuavaiability_chart  | Select Locations, ResourceType,  Tier, Size,Family ,Kind, Capacity,  LocationInfo,  ApiVersions,   Costs,  Capabilities, Restrictions ,MaxDataDiskCount, MemoryInMB, `
  Name, NumberOfCores, OSDiskSizeInMB , ResourceDiskSizeInMB, RequestId, StatusCode | where restrictions -eq 'NotAvailableForSubscription' | `
ConvertTo-Html -Head $CSS ).replace('NotAvailableForSubscription','<font color=red>NotAvailableForSubscription</font>'))    | Out-File c:\temp\azureskuavailability_restricted_by_region_$location.html
 Invoke-Item c:\temp\azureskuavailability_restricted_by_region_$location.html

}