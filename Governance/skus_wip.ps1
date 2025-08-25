<<<<<<< HEAD
<<<<<<<< HEAD:Governance/skus_wip.ps1
﻿<#
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
 


 ######################33
 ##  Necessary Modules to be imported.

import-module Az.Compute -force 

 ############
 ## connect to Azure with authorized credentials 
 
 Connect-AzAccount




 
$Available_resourceskus  = Get-AzComputeResourceSku  | Select-Object -Property * | select -First 1


 

$Available_resourceskus | fl *





<#

ResourceType    : disks
Name            : Premium_LRS
Tier            : Premium
Size            : P20
Family          : 
Kind            : 
Capacity        : 
Locations       : {westeurope}
LocationInfo    : {Microsoft.Azure.Management.Compute.Models.ResourceSkuLocationInf
                  o}
ApiVersions     : {}
Costs           : {}
Capabilities    : {MaxSizeGiB, MinSizeGiB, MaxIOps, MinIOps...}
Restrictions    : {}
RestrictionInfo : {}

#>



========
# AzureScriptsSamples

## ⚠️ Disclaimer

> THIS CODE SAMPLE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  
> This sample is not supported under any Microsoft standard support program or service.  
> The script is provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose.  
> The entire risk arising out of the use or performance of the sample and documentation remains with you.  
> In no event shall Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the script be liable for any damages whatsoever (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample or documentation, even if Microsoft has been advised of the possibility of such damages.

## 📘 Overview

**AzureScriptsSamples** is a collection of PowerShell scripts that can be used to manage and monitor Azure tenants, subscriptions, and resources. These scripts cover a wide range of common tasks in Azure administration, such as:

- Enforcing governance policies
- Gathering resource inventories
- Monitoring usage and costs
- Automating Azure and Office 365 administration

The repository is organized into folders by category, with each folder grouping scripts by their purpose or by the Azure service they target.

#### 📂 Table of Contents

- AAD – Azure Active Directory scripts  
- AzureOpenAI – Azure OpenAI Service scripts  
- AzurePolicy – Azure Policy management scripts  
- Changes_Additions_removals – Scripts for tracking changes and additions  
- Consumption – Azure consumption monitoring scripts  
- CostOptimization – Azure cost optimization scripts  
- Governance – Azure governance and compliance scripts  
- Inventory – Azure resource inventory scripts  
- Misc – Miscellaneous Azure scripts  
- Monitoring – Azure resource monitoring scripts  
- Network – Azure networking scripts  
- O365_M365 – Office 365/Microsoft 365 management scripts  
- OpenAI – OpenAI API integration scripts  
- Quota – Azure service quota checking scripts  
- Runbooks – Azure Automation runbook scripts  
- Sample output – Example output files from scripts  
- avd_mgmt – Azure Virtual Desktop management scripts  
- healthcheck – Azure health check scripts  
- workbook_json_extract – Azure Workbook data extraction scripts  
- Usage – How to use these scripts  
- Contributing – Contribution guidelines

## 📁 Folders and Categories

### AAD
This folder contains scripts for managing Azure Active Directory (AAD). These scripts help automate directory tasks such as user and group management, role assignments, and retrieving directory information.

### AzureOpenAI
This folder contains scripts for interacting with the Azure OpenAI Service. The scripts demonstrate how to configure and use Azure's OpenAI capabilities through PowerShell.

### AzurePolicy
This folder contains scripts for managing Azure Policy, including creating or updating policy definitions, assigning policies, and retrieving compliance reports.

### Changes_Additions_removals
Scripts and tools for tracking or documenting changes in the environment, helping with change management and auditing.

### Consumption
Scripts for monitoring Azure consumption and usage, gathering data about resource usage and costs.

### CostOptimization
Scripts for optimizing Azure costs, identifying cost-saving opportunities using consumption data and Azure Advisor recommendations.

### Governance
Scripts for managing Azure governance tasks such as tagging enforcement, naming conventions, and compliance auditing.

### Inventory
Scripts for collecting and managing Azure inventory across subscriptions and regions.

### Misc
Miscellaneous scripts that address various Azure-related tasks or utilities.

### Monitoring
Scripts for monitoring Azure resources, tracking health, status, and performance.

### Network
Scripts for managing and analyzing Azure networking components.

### O365_M365
Scripts for managing Office 365 and Microsoft 365 environments via PowerShell.

### OpenAI
Scripts related to OpenAI API usage outside of Azure's hosted service.

### Quota
Scripts for checking Azure quotas and usage limits.

### Runbooks
Scripts designed as Azure Automation runbooks for scheduled tasks.

### Sample output
Sample output files generated by scripts, provided as references.

### avd_mgmt
Scripts for Azure Virtual Desktop (AVD) management.

### healthcheck
Scripts to perform health checks on Azure resources and configurations.

### workbook_json_extract
Scripts for extracting and processing data from Azure Monitor Workbooks.

## 🚀 Usage

To use these scripts, clone or download the repository to your local machine or open it in Azure Cloud Shell. Each script is standalone and can be run using PowerShell.

### Prerequisites
- Install the latest Az PowerShell module or use Azure Cloud Shell.
- Run `Connect-AzAccount` to authenticate.
- Office 365 scripts may require AzureAD or Microsoft Graph modules.
- OpenAI scripts may require API keys or specific modules.

### Running in Azure Cloud Shell
Use Azure Cloud Shell in the Azure Portal to run scripts without local setup. Clone the repository and run the scripts as needed.

### Script Usage
Many scripts prompt for input or have parameters. Read the top of each script for usage instructions. Some scripts produce output files (CSV, HTML, etc.).

⚠️ Test scripts in a non-production environment before running. Review the script code to understand its actions.

## 🤝 Contributing

Contributions are welcome! Follow these guidelines:

- Fork the repository and make changes in a new branch.
- Add comments explaining the script's purpose and usage.
- Test your script and sanitize any sample output.
- Open a Pull Request with a clear description.
- Ensure no sensitive information is included.
- Contributions are under the same license and disclaimer as this repository.

Thank you for contributing! If you find this repository useful, give it a star ⭐ on GitHub. For issues or suggestions, feel free to open an issue.

Happy scripting! 🎉
>>>>>>>> d52ce840e8be3c3b3ed9cc2c09f1fb868b28362c:README.md
=======
﻿<#
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
 


 ######################33
 ##  Necessary Modules to be imported.

import-module Az.Compute -force 

 ############
 ## connect to Azure with authorized credentials 
 
 Connect-AzAccount




 
$Available_resourceskus  = Get-AzComputeResourceSku  | Select-Object -Property * | select -First 1


 

$Available_resourceskus | fl *





<#

ResourceType    : disks
Name            : Premium_LRS
Tier            : Premium
Size            : P20
Family          : 
Kind            : 
Capacity        : 
Locations       : {westeurope}
LocationInfo    : {Microsoft.Azure.Management.Compute.Models.ResourceSkuLocationInf
                  o}
ApiVersions     : {}
Costs           : {}
Capabilities    : {MaxSizeGiB, MinSizeGiB, MaxIOps, MinIOps...}
Restrictions    : {}
RestrictionInfo : {}

#>



>>>>>>> d52ce840e8be3c3b3ed9cc2c09f1fb868b28362c
