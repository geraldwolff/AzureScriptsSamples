import-module az.monitor



# Login to Azure
Connect-AzAccount

$subscriptions = get-azsubscription 

$subselected = $subscriptions | ogv -Title " select subscription to use:" -PassThru | select * 

$laws = Get-AzOperationalInsightsWorkspace 


$lawselected = $laws | ogv -Title "select the log anaytics workspace to send diagnostic logs to: " -PassThru | select * -first 1



$dataflow = New-AzDataFlowObject -Stream Microsoft-InsightsMetrics -Destination $($lawselected.ResourceId)
$windowsEvent = New-AzWindowsEventLogDataSourceObject -Name appTeam1AppEvents -Stream Microsoft-WindowsEvent -XPathQuery "System![System[(Level = 1 or Level = 2 or Level = 3)]]","Application!*[System[(Level = 1 or Level = 2 or Level = 3)]]"
$performanceCounter1 = New-AzPerfCounterDataSourceObject -CounterSpecifier "\\Processor(_Total)\\% Processor Time","\\Memory\\Committed Bytes","\\LogicalDisk(_Total)\\Free Megabytes","\\PhysicalDisk(_Total)\\Avg. Disk Queue Length" -Name cloudTeamCoreCounters -SamplingFrequencyInSecond 15 -Stream Microsoft-Perf
$performanceCounter2 = New-AzPerfCounterDataSourceObject -CounterSpecifier "\\Process(_Total)\\Thread Count" -Name appTeamExtraCounters -SamplingFrequencyInSecond 30 -Stream Microsoft-Perf
New-AzDataCollectionRule -Name wolffinsightmetricsDCR -ResourceGroupName $($lawselected.ResourceGroupName) -Location "$($lawselected.location)" -DataFlow $dataflow -DataSourcePerformanceCounter $performanceCounter1,$performanceCounter2 -DataSourceWindowsEventLog $windowsEvent -DestinationAzureMonitorMetricName "azureMonitorMetrics-default"






$dataflow2 = New-AzDataFlowObject -Stream Microsoft-Perf,Microsoft-Syslog -Destination $($lawselected.ResourceId)
$performanceCounter3 = New-AzPerfCounterDataSourceObject -CounterSpecifier "\\Processor(_Total)\\% Processor Time","\\Memory\\Committed Bytes","\\LogicalDisk(_Total)\\Free Megabytes","\\PhysicalDisk(_Total)\\Avg. Disk Queue Length" -Name cloudTeamCoreCounters -SamplingFrequencyInSecond 15 -Stream Microsoft-Perf
$performanceCounter4 = New-AzPerfCounterDataSourceObject -CounterSpecifier "\\Process(_Total)\\Thread Count" -Name appTeamExtraCounters -SamplingFrequencyInSecond 30 -Stream Microsoft-Perf
$windowsEvent1 = New-AzWindowsEventLogDataSourceObject -Name cloudSecurityTeamEvents -Stream Microsoft-WindowsEvent -XPathQuery "Security!*"
$windowsEvent2 = New-AzWindowsEventLogDataSourceObject -Name appTeam1AppEvents -Stream Microsoft-WindowsEvent -XPathQuery "System![System[(Level = 1 or Level = 2 or Level = 3)]]", "Application!*[System[(Level = 1 or Level = 2 or Level = 3)]]"
$logAnalytics = New-AzLogAnalyticsDestinationObject -Name centralWorkspace -WorkspaceResourceId /subscriptions/9e223dbe-3399-4e19-88eb-0975f02ac87f/resourcegroups/amcs-test/providers/microsoft.operationalinsights/workspaces/amcs-logtest-ws
$cronlog = New-AzSyslogDataSourceObject -FacilityName cron -LogLevel Debug,Critical,Emergency -Name cronSyslog -Stream Microsoft-Syslog
$syslog = New-AzSyslogDataSourceObject -FacilityName syslog -LogLevel Alert,Critical,Emergency -Name syslogBase -Stream Microsoft-Syslog
New-AzDataCollectionRule -Name wolffsyslogdcr -ResourceGroupName $($lawselected.ResourceGroupName) -Location "$($lawselected.location)" -DataFlow $dataflow2 -DataSourcePerformanceCounter $performanceCounter3,$performanceCounter4 -DataSourceWindowsEventLog $windowsEvent1,$windowsEvent2 -DestinationLogAnalytic $logAnalytics -DataSourceSyslog $cronlog,$syslog

 
   
 



