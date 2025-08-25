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

Description : Azure Communication Services SMS Sender MAC Friendly
This PowerShell script enables users to send SMS messages using Azure Communication Services (ACS) via the Azure CLI and REST API. 
It supports interactive selection of sender numbers, input of recipient numbers in E.164 format, message composition, and result logging. 
It is designed to work across platforms (Windows/macOS/Linux) with minimal configuration.

🔧 Features
Azure Authentication using Managed Identity
ACS Key Retrieval and connection string generation
Phone Number Discovery via ACS REST API
Interactive Sender Selection from available ACS numbers
Recipient Input Validation in E.164 format (e.g., +14255550123)
Message Composition with input validation
SMS Sending using az communication sms send
Result Logging to a local file (smslog.txt)
Cross-Platform Result Viewer that opens logs in the default text editor
📦 Prerequisites
Azure CLI with az communication extension installed
PowerShell 7+
Logged into Azure with appropriate permissions to access ACS resources
ACS resource with SMS capabilities
🚀 How It Works
Authenticate to Azure using:


Set the subscription context:


Retrieve ACS keys and construct the connection string.

Call the ACS REST API to list available phone numbers.

Prompt the user to select a "from" number from the list.

Prompt for recipient number in E.164 format and validate it.

Prompt for message text and validate it.

Send the SMS using the Azure CLI and log the result.

Display results in the terminal and open the log file in the default editor.

📁 Output
SMS send results are appended to:

C:\temp\smslog.txt
Example log entry:


🖥️ Cross-Platform Support
The script detects the OS and uses the appropriate command to open the log file:

Windows: notepad.exe
macOS: open
Linux: xdg-open
📌 Notes
Ensure your ACS resource has SMS capabilities enabled.
The script uses az communication sms send, which requires the communication extension in Azure CLI.
You can customize the regex or log file path as needed.

 https://learn.microsoft.com/en-us/azure/communication-services/quickstarts/sms/send?tabs=windows&pivots=platform-azcli
 
 #> 

Connect-AzAccount -identity | out-null


set-azcontext -Subscription wolffentpsub

$subscription = get-azsubscription -SubscriptionName   wolffentpsub


  

##########################################################
## get source number for messageing 

########## Get connection string form ACS
try {
    
    # Retrieve the connection string from the ACS instance
    $acsResourceName = "wolffacs"
    $resourceGroupName = "wolffcommsvcsrg"

    $keys = Get-AzCommunicationServiceKey -ResourceGroupName $resourceGroupName -CommunicationServiceName $acsResourceName

    if ($keys.PrimaryKey) {
        $connectionString = "endpoint=https://$($acsResourceName).communication.azure.com/;accesskey=$($keys.PrimaryKey)"
        Write-Output "Connection string retrieved successfully:"
       # Write-Output $connectionString
    } else {
        Write-Output "Failed to retrieve connection string."
    }
} catch {
    Write-Output "An error occurred while retrieving the connection string: $_"
}

$acsResource = Get-AzCommunicationService -Name $acsResourceName -ResourceGroupName $resourceGroupName -SubscriptionId $($subscription.Id)

$acsEndpoint = "https://$($acsResource.HostName)"
$apiVersion = "2021-03-07"
$uri = "$acsEndpoint/phoneNumbers?api-version=$apiVersion"

$secureToken = (Get-AzAccessToken -ResourceUrl "https://communication.azure.com" -AsSecureString).Token
$token = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureToken)
)

# Set headers
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type"  = "application/json"
}
$phonelist = ''
$response = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers


# Output the list of phone numbers
$response.phonenumbers | ForEach-Object {

$phoneobj = new-object PSObject

$phoneobj | add-member -MemberType NoteProperty -Name  phoneNumber   -value  $($_.phoneNumber)
$phoneobj | add-member -MemberType NoteProperty -Name   phoneNumberType  -value $($_.phoneNumberType)
$phoneobj | add-member -MemberType NoteProperty -Name   Capabilities  -value $($_.capabilities)

[array]$phonelist += $phoneobj


    #Write-Output "Phone Number: $($_.phoneNumber), Type: $($_.phoneNumberType), Capabilities: $($_.capabilities)"
}


function Select-FromPhoneNumber {
    param (
        [Parameter(Mandatory = $true)]
        [array]$PhoneList
    )

    Write-Host "Select the phone number to use as the 'from' number:`n"

    for ($i = 0; $i -lt $PhoneList.Count; $i++) {
        $entry = $PhoneList[$i]
        Write-Host "$($i + 1): $($entry.phonenumber) - $($entry.phoneNumberType) - $($entry.Capabilities)"
    }

    while ($true) {
        $selection = Read-Host "`nEnter the number of your choice (1-$($PhoneList.Count))"
        if ($selection -match '^\d+$' -and $selection -ge 1 -and $selection -le $PhoneList.Count) {
            $fromNumber = $PhoneList[$selection - 1].phonenumber
            Write-Host "`nSelected phone number: $fromNumber"
            return $fromNumber
        } else {
            Write-Host "Invalid selection. Please try again." -ForegroundColor Red
        }
    }
}

# Example usage:
  $fromNumber = Select-FromPhoneNumber -PhoneList $phonelist

$fromnumber   
 
function Get-E164PhoneNumber {
    param (
        [string]$Prompt = "Enter phone number in E.164 format (e.g., +14255550123):"
    )

    while ($true) {
        $phoneNumber = Read-Host $Prompt

        if ($phoneNumber -match '^\+\d{10,15}$') {
            Write-Host "Valid E.164 phone number entered: $phoneNumber"
            return $phoneNumber
        } else {
            Write-Host "Invalid format. Please enter a number like +14255550123." -ForegroundColor Red
        }
    }
}

 
 

function Get-Message {
    param (
        [string]$Prompt = "Enter the message text to send:"
    )

    while ($true) {
        $message = Read-Host $Prompt

        if (![string]::IsNullOrWhiteSpace($message)) {
            Write-Host "Message captured: $message"
            return $message
        } else {
            Write-Host "Message cannot be empty. Please enter some text." -ForegroundColor Red
        }
    }
}

 
 
 
function Show_Results {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Response filename")]
        [ValidateNotNullOrEmpty()]
        [string]$ResponseFilename
    )

    # Optional: Define a regex pattern if needed
    $regex = '.*'  # Match all lines by default
    if (-Not (Test-Path $ResponseFilename)) {
        Write-Error "File '$ResponseFilename' not found."
        return
    }

    $textResults = Get-Content -Path $ResponseFilename -Raw | 
                   Select-String -Pattern $regex | 
                   ForEach-Object { $_.Line }

    if ($textResults.Count -eq 0) {
        Write-Host "No matching results found."
        return
    }

    # Display results in terminal
    Write-Host "`n--- Results ---`n"
    $textResults | Out-Host

    # Optional: Write to a temp file and open in default text editor
    $tempFile = [System.IO.Path]::GetTempFileName()
    $textResults | Set-Content -Path $tempFile

    Write-Host "`nOpening results in default text editor..."

    if ($IsWindows) {
        Start-Process notepad.exe $tempFile
    } elseif ($IsMacOS) {
        & open $tempFile
    } elseif ($IsLinux) {
        & xdg-open $tempFile
    } else {
        Write-Warning "Cannot determine OS to open the file automatically."
    }
}

 

function sendsms {
    <#     
    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true, HelpMessage = "enter the Phone number to send to:")]
                [ValidateNotNullOrEmpty()]
        [string]$number,
        [string]$message
        )

Process {
    $ErrorActionPreference = "SilentlyContinue"
 $result = az communication sms send `
  --connection-string "$connectionstring" `
  --sender "$($fromnumber)" `
  --recipient $number `
  --message "$message"


 write-output "$result " |out-file c:\temp\smslog.txt  -Append
}

}
 
 
 cls
 
$number = Get-E164PhoneNumber
   
$messages =  Get-Message 

  $Request =  sendsms   -number $number -message "$messages"   
   
    

 show_results  "c:\temp\smslog.txt" 


