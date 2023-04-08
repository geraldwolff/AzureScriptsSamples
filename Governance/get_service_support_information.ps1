


$ServiceNameGUID = "06bfd9d3-516b-d5c6-5802-169c800dec89" 
$ProblemClassificationGUID = "599a339a-a959-d783-24fc-81a42d3fd5fb"


 Get-AzSupportService   | where name -eq $ServiceNameGUID | Get-AzSupportProblemClassification
  
 
 Get-AzSupportService    | Get-AzSupportProblemClassification | where-object { $_.Name -eq "599a339a-a959-d783-24fc-81a42d3fd5fb"}
