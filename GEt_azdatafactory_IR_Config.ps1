Connect-AzAccount 

import-module Az.DataFactory -force 


set-azcontext -Subscription wolffentpsub

$IRPROPS = Get-AzDataFactoryV2IntegrationRuntime -ResourceGroupName "wolffADFRG" -DataFactoryName "wolffadf" -Name "wolffselfhostIR"  


$IRPROPS | gm 
 
($IRPROPS) | select -ExpandProperty DataFlowComeType 




$IRPROPS | Fl *



#(Get-AzDataFactoryV2IntegrationRuntimeNode -ResourceGroupName "wolffADFRG" -DataFactoryName "wolffadf" -IntegrationRuntimeName "wolffselfhostIR" -Name $($IRPROPS.Name) )
 


(Get-AzDataFactoryV2IntegrationRuntime -ResourceGroupName "wolffADFRG" -DataFactoryName "wolffadf" -Name "wolffselfhostIR") | fl *

$datafactory = Get-AzDataFactoryV2  -ResourceGroupName "wolffADFRG"  -Name wolffadf


Get-AzDataFactoryv2Pipeline  -DataFactory $datafactory


Get-AzDataFactoryV2ActivityRun   -ResourceGroupName wolffADFRG -DataFactoryName "wolffadf" 





