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

Description : Azure Communication Services SMS Sender
This PowerShell script enables automated retrieval and selection of phone numbers from an Azure Communication Services (ACS) resource and allows users to send SMS messages via a GUI interface.

🔐 Authentication & Context Setup

Authenticates using a managed identity and sets the Azure subscription context.

🔑 Retrieve ACS Connection String
The script fetches the primary access key from the ACS resource wolffacs in the resource group wolffcommsvcsrg and constructs a connection string for API access.

☎️ List Available Phone Numbers
Using the ACS REST API, the script retrieves a list of phone numbers associated with the service and displays them in a GUI for the user to select a "from" number.

📥 GUI Input for Recipient & Message
Two Windows Forms GUI prompts are used:

Phone Number Input: User enters the recipient's number.
Message Input: User types the SMS message content.
📤 Send SMS
The selected phone number and message are sent using the Azure CLI az communication sms send command.

📄 View Results
The response from the SMS send operation is logged to C:\temp\smslog.txt and displayed in a read-only GUI window.

🧩 Functions Included
get_number(): GUI to input recipient number.
get_MESSAGE(): GUI to input message content.
sendsms(): Sends the SMS using Azure CLI.
show_results(): Displays the SMS send log.
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



$fromnumber =  $phonelist | Select phonenumber,phoneNumberType, Capabilities | ogv -Title "Select the phone umber as a from number : " -passthru  | Select Phonenumber

$fromnumber   
 

###################################################################

function get_number()
{
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'enter nuber to send sms to: type quit to exit'
    $form.Size = New-Object System.Drawing.Size(600,200)
    $form.StartPosition = 'CenterScreen'

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(75,120)
    $okButton.Size = New-Object System.Drawing.Size(75,23)
    $okButton.Text = 'OK'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)
    <#
    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(150,120)
    $cancelButton.Size = New-Object System.Drawing.Size(75,23)
    $cancelButton.Text = 'Cancel'
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)
    
 #>

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10,20)
    $label.Size = New-Object System.Drawing.Size(280,20)
    $label.Text = 'Enter the phone number(s) to send to "1xxx-xx-xxxx":'
    $form.Controls.Add($label)

    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Location = New-Object System.Drawing.Point(10,40)
    $textBox.Size = New-Object System.Drawing.Size(560,50)
    $form.Controls.Add($textBox)

    $form.Topmost = $true

    $form.Add_Shown({$textBox.Select()})
    $result = $form.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK)
    {
        $x = $textBox.Text
        $x
    }

 if ($x -eq 'quit' -or $x -eq 'Cancel'){
         $form.close()
  
         exit
         }

        
}


function get_MESSAGE()
{
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'enter Message to send: type quit to exit'
    $form.Size = New-Object System.Drawing.Size(600,200)
    $form.StartPosition = 'CenterScreen'

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(75,120)
    $okButton.Size = New-Object System.Drawing.Size(75,23)
    $okButton.Text = 'OK'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)
 

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10,20)
    $label.Size = New-Object System.Drawing.Size(280,20)
    $label.Text = 'Enter the message you want to send to :'
    $form.Controls.Add($label)

    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Location = New-Object System.Drawing.Point(10,40)
    $textBox.Size = New-Object System.Drawing.Size(560,50)
    $form.Controls.Add($textBox)

    $form.Topmost = $true

    $form.Add_Shown({$textBox.Select()})
    $result = $form.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK)
    {
        $x = $textBox.Text
        $x
    }

 if ($x -eq 'quit' -or $x -eq 'Cancel'){
         $form.close()
  
         exit
         }

        
}

function show_results
{
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true, HelpMessage = "Responsfilename")]
        [ValidateNotNullOrEmpty()]
        [string]$responsefilname)
 
$textsresults = get-content "$responsefilname" -raw| Where-Object {$_ -match $regex} | ForEach-Object {
  write-output "$_ `r `n"

   
}

$form1 = New-Object System.Windows.forms.form
$form1.Text = "Results"
$form1.Size = New-Object System.Drawing.Size(700,700)
$form1.StartPosition = "CenterScreen"
$form1.MaximizeBox = $false
$form1.MinimizeBox = $false
$form1.ControlBox = $true
$form1.TopMost = $true

$TextBox = New-Object System.Windows.forms.TextBox
$TextBox.Location = New-Object System.Drawing.Point(10,10)
$TextBox.Size = New-Object System.Drawing.Size(650,500)
$TextBox.Multiline = $true
$TextBox.ScrollBars = "Vertical"
 
$TextBox.ReadOnly = $true
$TextBox.Text = "$textsresults"
$TextBox.AutoSize = $true
 
$form1.Controls.Add($TextBox)

$form1.ShowDialog()



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
    $ErrorActionPreference = "SILENTLYContinue"
 $result = az communication sms send `
  --connection-string "$connectionstring" `
  --sender "$($fromnumber.phoneNumber)" `
  --recipient $number `
  --message "$message"


 write-output "$result " |out-file c:\temp\smslog.txt  -Append
}

}
 
 
 cls
 
$number = get_number
   
$messages =  get_MESSAGE 

  $Request =  sendsms   -number $number -message "$messages"   
   
    

 show_results -responsefilname "c:\temp\smslog.txt" 
















