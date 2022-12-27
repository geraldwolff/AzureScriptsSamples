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

connect-azaccount 


#install-module -name  azspeedtest -allowclobber
import-module azspeedtest
import-module az -force

######################################


$regions = Get-azregion


$speedresults = $null
$date = $(Get-Date -Format 'dd MMMM yyyy')

foreach($region in $regions)
{
    $sourceregion = "Westus2"
    $region
        $results = test-azregionlatency -Region "$sourceregion", "$region"  -Iterations 50  

        $results 


 

        foreach($result in $results)
        {
            if("$($result.region)" -notmatch "$sourceregion")
            {
                $speedobj = new-object PSObject 

                $speedobj | Add-Member -MemberType NoteProperty -Name SourceComputername -value "$($result.computername)"
                $speedobj | Add-Member -MemberType NoteProperty -Name SourceRegion -value "$sourceregion"
                $speedobj | Add-Member -MemberType NoteProperty -Name Minimum -value "$($result.Minimum)"
                $speedobj | Add-Member -MemberType NoteProperty -Name Average -value "$($result.Average)"
                $speedobj | Add-Member -MemberType NoteProperty -Name Maximum -value "$($result.Maximum)"
                $speedobj | Add-Member -MemberType NoteProperty -Name TotalTime -value "$($result.TotalTime)"
                $speedobj | Add-Member -MemberType NoteProperty -Name Region -value "$($result.Region)"
                $speedobj | Add-Member -MemberType NoteProperty -Name Record_date -value "$date"

                [array]$speedresults += $speedobj
            }
        }
}


<#
 
                $datatable =  $speedresults  | out-datatable 
                #  $datatable

                    $cn = new-object System.Data.SqlClient.SqlConnection("Data Source=$DBinstance;Integrated Security=SSPI;Initial Catalog=AUDIT");
                    $cn.Open()

                    $bc = new-object ("System.Data.SqlClient.SqlBulkCopy") $cn
                    $bc.DestinationTableName = "dbo.Azure_network_latency"
                    $bc.WriteToServer($datatable)
                    $cn.Close()
 
 #>

$CSS = @"
<Title> Network Latency Performance Report: $date </Title>
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

  

$speedresultsreport = ($speedresults  | Select  SourceComputername,SourceRegion, Minimum, Average,Maximum, TotalTime, Region  | `
	ConvertTo-Html -Head $CSS) 

$speedresultsreport | out-file c:\temp\networkperformance.html 

 invoke-item c:\temp\networkperformance.html

  
