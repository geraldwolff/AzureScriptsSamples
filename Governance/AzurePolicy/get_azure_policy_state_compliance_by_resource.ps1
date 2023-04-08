

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

 ######################33
 ##  Necessary Modules to be imported.

 import-module  Az.OperationalInsights -force

 import-module Az.PolicyInsights -Force 

 ############
 ## connect to Azure with authorized credentials 
 
 Connect-AzAccount

 
#########################################

##  Get ist of subscriptions that will be read for discovery 
 
 



#########################################
##  uncomment this line if anomalies in queries display deprecation messages - This will allow script to continue discovery

##$ErrorActionPreference = 'silentlyContinue'

### get the list of subscriptions accessible by the credentials provided   

#########################################
### Clear Array collector 
## This is used to collect data using the custom schema in $resultobj
   $policystateresults = ''

#########################################

##  Get ist of subscriptions that will be read for discovery 
 
 $Subs =  Get-azSubscription | select Name, ID,TenantId


 foreach($Subscription in  $subs)
    {

                             $SubscriptionName =  $Subscription.name

                             
                           $azcontext = (set-azcontext -SubscriptionName $SubscriptionName  -ErrorAction SilentlyContinue )

                       write-host "$SubscriptionName" -foregroundcolor yellow





                $resourcegroups = get-azresourcegroup

            foreach($resourcegroup in $resourcegroups)
            {
               $policyStates =  Get-AzPolicyState -All
           #     $policyStates | gm 
                
            #$policydefinition =  Get-AzPolicyDefinition
          #  $policydefinition.Properties.Description

          foreach($policystate in $policystates) 
          {
                #Get-AzPolicySetDefinition -SubscriptionId 

          $resourcename =   (Get-AzResource -ResourceGroupName $($ResourceGroup.ResourceGroupName) | where resourceid -eq "$($policystate.resourceid)") 
           $resourcename.Name
           $resourcetag = (Get-AzResource -ResourceGroupName $($ResourceGroup.ResourceGroupName) | where resourceid -eq "$($policystate.resourceid)").tags
    
        

            $policystateobj = new-object PSObject 

              $policystateobj | Add-Member -MemberType NoteProperty -name   SubscriptionId    -value   $($policystate.SubscriptionId )
              $policystateobj | Add-Member -MemberType NoteProperty -name  ResourceType     -value      $($policystate.ResourceType ) 
              $policystateobj | Add-Member -MemberType NoteProperty -name  ResourceTags     -value      $($policystate.ResourceTags) 
              $policystateobj | Add-Member -MemberType NoteProperty -name  ResourceLocation     -value    $($policystate.ResourceLocation ) 
              $policystateobj | Add-Member -MemberType NoteProperty -name  IsCompliant     -value   $($policystate.IsCompliant )
              $policystateobj | Add-Member -MemberType NoteProperty -name  ResourceName     -value   $($resourcename.Name )
              $policystateobj | Add-Member -MemberType NoteProperty -name  ComplianceState     -value   $($policystate.ComplianceState )
              $policystateobj | Add-Member -MemberType NoteProperty -name  EffectiveParameters     -value   $($policystate.EffectiveParameters )
              $policystateobj | Add-Member -MemberType NoteProperty -name  ResourceId     -value      $($policystate.ResourceId ) 
              $policystateobj | Add-Member -MemberType NoteProperty -name  ResourceGroup     -value   $($policystate.ResourceGroup )
              $policystateobj | Add-Member -MemberType NoteProperty -name  PolicySetDefinitionVersion     -value     $($policystate.PolicySetDefinitionVersion )
              $policystateobj | Add-Member -MemberType NoteProperty -name  PolicySetDefinitionParameters     -value     $($policystate.PolicySetDefinitionParameters )  
              $policystateobj | Add-Member -MemberType NoteProperty -name  PolicySetDefinitionOwner     -value   $($policystate.PolicySetDefinitionOwner )
              $policystateobj | Add-Member -MemberType NoteProperty -name  PolicySetDefinitionName     -value     $($policystate.PolicySetDefinitionName )
              $policystateobj | Add-Member -MemberType NoteProperty -name  PolicySetDefinitionId     -value       $($policystate.PolicySetDefinitionId )
              $policystateobj | Add-Member -MemberType NoteProperty -name  PolicySetDefinitionCategory     -value   $($policystate.PolicySetDefinitionCategory )
              $policystateobj | Add-Member -MemberType NoteProperty -name  PolicyEvaluationDetails     -value     $($policystate.PolicyEvaluationDetails )
              $policystateobj | Add-Member -MemberType NoteProperty -name  PolicyDefinitionVersion     -value     $($policystate.PolicyDefinitionVersion )  
              $policystateobj | Add-Member -MemberType NoteProperty -name  PolicyDefinitionReferenceId     -value   $($policystate.PolicyDefinitionReferenceId )
              $policystateobj | Add-Member -MemberType NoteProperty -name  PolicyDefinitionName     -value     $($policystate.PolicyDefinitionName )
              $policystateobj | Add-Member -MemberType NoteProperty -name  PolicyDefinitionId     -value       $($policystate.PolicyDefinitionId )
              $policystateobj | Add-Member -MemberType NoteProperty -name  PolicyDefinitionGroupNames     -value   $($policystate.PolicyDefinitionGroupNames )
              $policystateobj | Add-Member -MemberType NoteProperty -name  PolicyDefinitionCategory     -value     $($policystate.PolicyDefinitionCategory )
              $policystateobj | Add-Member -MemberType NoteProperty -name  PolicyDefinitionAction     -value      $($policystate.PolicyDefinitionAction ) 
              $policystateobj | Add-Member -MemberType NoteProperty -name  PolicyAssignmentVersion     -value   $($policystate.PolicyAssignmentVersion )
              $policystateobj | Add-Member -MemberType NoteProperty -name  PolicyAssignmentScope     -value     $($policystate.PolicyAssignmentScope )
              $policystateobj | Add-Member -MemberType NoteProperty -name  PolicyAssignmentParameters     -value    $($policystate.PolicyAssignmentParameters )   
              $policystateobj | Add-Member -MemberType NoteProperty -name  PolicyAssignmentOwner     -value   $($policystate.PolicyAssignmentOwner )
              $policystateobj | Add-Member -MemberType NoteProperty -name  PolicyAssignmentName     -value     $($policystate.PolicyAssignmentName )
              $policystateobj | Add-Member -MemberType NoteProperty -name  PolicyAssignmentId     -value     $($policystate.PolicyAssignmentId )  


              [array]$policystateresults += $policystateobj



              
           }   
              #  Get-AzPolicyRemediation -ResourceGroupName "$($resourcegroup.resourcegroupname)" # -Name "remediation1" -IncludeDetail

            }


    }


    #########################################
## CSS to format output in tabular format

$CSS = @"
<Title>Policystate Report:$(Get-Date -Format 'dd MMMM yyyy' )</Title>
<Header>
 
"<B>Company Confidential</B> <br><I>Report generated from {3} on $env:computername {0} by {1}\{2} as a scheduled task</I><br><br>Please contact $contact with any questions "$(Get-Date -displayhint date)",$env:userdomain,$env:username
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





 
#########################################
## Section to create output into HTML tabular format in C:\temp  Change the path if that is not the desired location or it was not previously created
## No logic added intentionally to create a directory.

(($policystateresults | where Resourcename -ne $nulll | sort-object SubscriptionId, ResourceGroup, Resourcename, Resourcetype | Select SubscriptionId,`
ResourceGroup,`
Resourcename, `
ResourceType,`
ResourceTags,`
ResourceLocation,`
PolicyDefinitionGroupNames,`
PolicyDefinitionAction,`
IsCompliant,`
ComplianceState,`
EffectiveParameters,`
ResourceId,`
PolicySetDefinitionVersion,`
PolicySetDefinitionParameters,`
PolicySetDefinitionOwner,`
PolicySetDefinitionName,`
PolicySetDefinitionId,`
PolicySetDefinitionCategory,`
PolicyEvaluationDetails,`
PolicyDefinitionVersion,`
PolicyDefinitionReferenceId,`
PolicyDefinitionName,`
PolicyDefinitionId,`

PolicyDefinitionCategory,`

PolicyAssignmentVersion,`
PolicyAssignmentScope,`
PolicyAssignmentParameters,`
PolicyAssignmentOwner,`
PolicyAssignmentName,`
PolicyAssignmentId |`
ConvertTo-Html -Head $CSS ).replace('NonCompliant','<font color=red>NonCompliant</font>').replace('False','<font color=red>False</font>'))   | Out-File "c:\temp\az_policystate_information_resources.html"


#########################################
## Lauch resulting html file

 Invoke-Item "c:\temp\az_policystate_information_resources.html"

























