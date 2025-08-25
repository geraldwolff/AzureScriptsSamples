Azure Quota Check Script
A PowerShell script for Azure that checks quota limits to ensure sufficient allocation is available for deploying Azure resources.

Usage
powershell
Copy code
.\Check_quota_and_create_support_ticket_for_quota_increase_context_change_params.ps1 `
-SubscriptionId 'xxxxx-xxxxx-xxx-xxxxxx' `
-Location 'centralus' `
-SkuName 'standardFFamily' `
-Threshold 20 `
-Corecountrequests 500
Parameters
SubscriptionId: ID of the Azure subscription.
Location: Azure region to check for quota limits.
SkuName: SKU name of the resource to check for quota limits.
Threshold: The threshold percentage at which a support ticket will be opened for a quota increase.
Corecountrequests: The number of cores to request for deployment.
Version History
v1.0 - Initial Release
Notes
This code sample is provided "AS IS" without warranty of any kind, either expressed or implied, including but not limited to the implied warranties of merchantability and/or fitness for a particular purpose. This sample is not supported under any Microsoft standard support program or service. The script is provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample and documentation remains with you. In no event shall Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the script be liable for any damages whatsoever (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample or documentation, even if Microsoft has been advised of the possibility of such damages, rising out of the use of or inability to use the sample script, even if Microsoft has been advised of the possibility of such damages.