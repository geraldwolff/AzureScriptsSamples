##########################################################################################
 
 connect-azaccount 
   
$curr_date =  Get-Date 
 
$activity_logs = ''
# set min age of files
$max_days = "-1"

 
# determine how far back we go based on current date
$bak_date = $curr_date.AddDays($max_days).Date

$bk_date_range =  $bak_date.ToString("yyyyMMdd")




$subscriptions = Get-azSubscription | select name, ID


    $CSS = @"
<Title>Capacity Report:$(Get-Date -Format 'dd MMMM yyyy' )</Title>
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



foreach($subscription in $subscriptions) 
{
    Set-azContext -Subscription $subscription.name
 
  #$acvtivity_logs =   Get-azLog  -ErrorAction SilentlyContinue

 $acvtivity_logs =  Get-azLog -StartTime $bak_date -EndTime $curr_date

     <#
     Authorization     : 
                    Scope     : /subscriptions/097a388a-49e5-4e9d-8ed9-7ad5b6420597/resourceGroups/uw2srg
                    elevate/providers/Microsoft.Storage/storageAccounts/uw2srgelevatediag620
                    Action    : Microsoft.Storage/storageAccounts/listKeys/action
                    Role      : 
                    Condition : 
                    Caller            : 
                    CorrelationId     : 41e25dc5-5449-4877-94dc-5d28bf56e7ae
                    Category          : Administrative
                    EventTimestamp    : 11/8/2017 1:36:11 PM
                    OperationName     : Microsoft.Storage/storageAccounts/listKeys/action
                    ResourceGroupName : uw2srgelevate
                    ResourceId        : 
                    Status            : Succeeded
                    SubscriptionId    : 097a388a-49e5-4e9d-8ed9-7ad5b6420597
                    SubStatus         : OK


     #>


     foreach($activity in  $acvtivity_logs)
     {
     $obj = New-Object PSOBject 

     if ($activity.authorization.Scope)
     {
     $scope = ($($activity.authorization.Scope).split('/')[-1])  
     }
     Else{
             $scope = "not_available"
     }

    $obj | add-member -membertype NoteProperty -name  Scope -value "$scope"
    $obj | add-member  -membertype NoteProperty -name Action -value  "$($activity.authorization.Action)"
   # $obj | add-member  -membertype NoteProperty -name Role  -value "$($activity.authorization.Role)"
    #$obj | add-member   -membertype NoteProperty -name Condition -value  "$($activity.authorization.Condition)"
    $obj | add-member   -membertype NoteProperty -name Caller  -value "$($activity.Caller)"
    $obj | add-member  -membertype NoteProperty -name CorrelationId  -value "$($activity.CorrelationId)"
    $obj | add-member  -membertype NoteProperty -name Category -value  "$($activity.Category)"
    $obj | add-member  -membertype NoteProperty -name EventTimestamp -value  "$($activity.EventTimestamp)"
    $obj | add-member  -membertype NoteProperty -name OperationName -value  "$($activity.OperationName)"
    $obj | add-member  -membertype NoteProperty -name ResourceGroupName  -value "$($activity.ResourceGroupName)"
    $obj | add-member  -membertype NoteProperty -name ResourceId -value  "$($activity.ResourceId)"
    $obj | add-member  -membertype NoteProperty -name Status -value  "$($activity.Status)"
    $obj | add-member  -membertype NoteProperty -name SubscriptionId  -value "$($activity.SubscriptionId)"
    $obj | add-member  -membertype NoteProperty -name SubStatus -value  "$($activity.SubStatus)"

    [array]$activity_logs += $obj 
    
  
     }

}

    


     $CSS = @"
<Title>activity Logs  Detail information :$(Get-Date -Format 'dd MMMM yyyy' )</Title>
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




########read in collected results and create the html report


 

 (((($activity_logs   |select Status,`
 Scope,`
Action,`
#Role,`
#Condition,`
Caller,`
CorrelationId,`
Category,`
EventTimestamp,`
OperationName,`
ResourceGroupName,`
ResourceId,`

SubscriptionId `
| ConvertTo-Html -Head $CSS ).replace('Failed','<font color=red>Failed</font>').replace('Succeeded','<font color=green>Succeeded</font>'))).replace('Updated','<font color=orange>Updated</font>')).replace('not_available','<font color=Red>not_available</font>') `
| out-file  "C:\temp\activitylog.html" 

Invoke-Item  "C:\temp\activitylog.html" 

 
 



