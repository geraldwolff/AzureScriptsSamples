
 


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
 

#########################################

##  Get ist of subscriptions that will be read for discovery 
 
 $Subs =  Get-azSubscription | select Name, ID,TenantId



 $standards = ("PCI-DSS v3.2.1",
"SOC TSP",
"ISO 27001:2013",
"Azure CIS 1.1.0",
"Azure CIS 1.3.0",
"Azure CIS 1.4.0",
"NIST SP 800-53 R4",
"NIST SP 800-53 R5",
"NIST SP 800 171 R2",
"CMMC Level 3",
"FedRAMP H",
"FedRAMP M",
"HIPAA/HITRUST",
"SWIFT CSP CSCF v2020",
"UK OFFICIAL and UK NHS",
"Canada Federal PBMM",
"New Zealand ISM Restricted",
"New Zealand ISM Restricted v3.5",
"Australian Government ISM Protected",
"RMIT Malaysia"
)



 foreach($Subscription in  $subs)
    {

                             $SubscriptionName =  $Subscription.name

                             
                           $azcontext = (set-azcontext -SubscriptionName $SubscriptionName  -ErrorAction SilentlyContinue)

                       write-host "$SubscriptionName" -foregroundcolor yellow


 #Get-AzRegulatoryComplianceStandard

 

    foreach($standard in $standards ) 
       {
         

                   #Get-AzRegulatoryComplianceStandard -name "$standard"  -ErrorAction SilentlyContinue

                   $compliancecontrolassessments =  Get-AzRegulatoryComplianceControl -StandardName "$standard" -ErrorAction SilentlyContinue

            foreach($assessment in $compliancecontrolassessments)
            {
                  $Assementsresults = Get-AzRegulatoryComplianceAssessment -StandardName "$standard" -ControlName $($assessment.name)
            }
        }

}













