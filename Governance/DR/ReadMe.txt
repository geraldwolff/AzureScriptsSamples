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

Summary 
        bulk backup_restore_from_recoverypoint_bulk
        This PowerShell script connects to an Azure Recovery Services Vault, 
        allows the user to select a backup VM, and then allows the user to select 
        a recovery point for that VM. 

        It then creates a storage account and restores the selected recovery point 
        to the storage account. Finally, it provides the restore job status for the user to review.

         The script includes error handling and requires user input for some selections. 
         A disclaimer at the beginning of the script warns that it is not supported under
          any Microsoft standard support program or service, and is provided as-is without warranty.

    Note: this version will fail and produce a warning if the Vm being restored was deleted and the resourcegroup no longer exists
          This version is sequential from the select VMs restorepoints 


#> 