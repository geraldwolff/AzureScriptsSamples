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





 $querylist = ''

 $workbookpath  = "C:\temp\"
 $workbook = "subscription_workbook.json"
###########################

# Read in the Azure Workbook template
$json = Get-Content -Path "$($workbookpath)$($workbook)"  -Raw | ConvertFrom-Json

# Extract the query from the workbook parameters
#$parameters = $json.items | Where-Object { $_.type -eq 9 } | Select-Object -ExpandProperty content
 

# Extract the subscription IDs from the workbook source data
#$sourceData = $json.items | Where-Object { $_.type -eq 11 } | Select-Object -ExpandProperty content #.links

$sourcequeries = $json.items  | select-object -ExpandProperty content
$queries = $sourcequeries.items.content.query 

$links = $($sourceData).links 

  
    Foreach($jsonitem in ($sourcequeries | where-object { $_.items.content.query  -ne $null}) )
    {

         #   Write-host "$($jsonitem.items.content.query)" -ForegroundColor Cyan



        foreach($jsonitemcontent in ($($jsonitem.items.content) | where query -ne $null )  )
        {

            $contentprops = $($jsonitem.items.content)  
    
            $contenttypes = $($jsonitem.items.type)

            foreach($contenttype in $contenttypes)
            {
 
                $jsoncontentobj = new-object PSObject 

               $contentitems =  $($jsonitem.items.content)  
               $Feature =  $($contentitems.json) -replace('{#','')
     
                $jsoncontentobj | Add-Member -MemberType NoteProperty -Name Type -value $($contenttype)
                $jsoncontentobj | Add-Member -MemberType NoteProperty -Name Feature -value "$Feature"
                $jsoncontentobj | Add-Member -MemberType NoteProperty -Name Version -value $($jsonitemcontent.version)  
                $jsoncontentobj | Add-Member -MemberType NoteProperty -Name title -value $($jsonitemcontent.title)      
                $jsoncontentobj | Add-Member -MemberType NoteProperty -Name noDataMessage -value $($jsonitemcontent.noDataMessage)
                $jsoncontentobj | Add-Member -MemberType NoteProperty -Name queryType -value $($jsonitemcontent.queryType)  
                $jsoncontentobj | Add-Member -MemberType NoteProperty -Name resourceType -value $($jsonitemcontent.resourceType)      
                $jsoncontentobj | Add-Member -MemberType NoteProperty -Name crossComponentResources -value $($jsonitemcontent.crossComponentResources)
                $jsoncontentobj | Add-Member -MemberType NoteProperty -Name query -value $($jsonitemcontent.query).ToString()  
           
 
        
               # $jsoncontentobj
                [array]$querylist +=    $jsoncontentobj
               


            } 
    }
 
 }

 
 
     $CSS = @"
<Title>$workbook Query ReportReport:$(Get-Date -Format 'dd MMMM yyyy' )</Title>
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



 

(($querylist | Select     Version,title, noDataMessage,queryType , resourceType, crossComponentResources,query  |`
  ConvertTo-Html -Head $CSS ).replace('Â Â','')) | out-file  "c:\temp\$($workbook)Queries.html"
invoke-item  "c:\temp\$($workbook)Queries.html"
 
 $querylist | Select -unique   Version,title, noDataMessage,queryType , resourceType, crossComponentResources,query |  `
 export-csv "C:\temp\$($workbook)Queries.csv" -NoTypeInformation
 

 





















