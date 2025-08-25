function Get-AzureOpenAIToken{
    <#  .SYNOPSIS
       Get an azure token for user or managed identity thats required to authenticate to Azure OpenAI with Rest API.
       Also construct the header if you are using an Azure OpenAI API key instead of Azure AD authentication.
    .PARAMETER ManagedIdentity
        Use this parameter if you want to use a managed identity to authenticate to Azure OpenAI.
    .PARAMETER User
        Use this parameter if you want to use a user to authenticate to Azure OpenAI.
    .PARAMETER APIKey
        Use this parameter if you want to use an API key to authenticate to Azure OpenAI.

    .EXAMPLE
        # Manually specify username and password to acquire an authentication token:
        Get-AzureOpenAIToken -APIKey "ghgkfhgfgfgkhgh"
        Get-AzureOpenAIToken -ManagedIdentity $true
        Get-AzureOpenAIToken -User $true
    .NOTES
        Author: Alexander Holmeset
        Twitter: @AlexHolmeset
        Website: https://www.alexholmeset.blog
        Created: 09-02-2023
        Updated: Jerry wolff 
        Modification: to be more nteractive with looped prompts and color changes for quest and Responses 
        Version history:
        1.0.0 - (09-02-2023) Function created  
    #>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [string]$APIKey,
    [Parameter(Mandatory=$false)]
    [string]$ManagedIdentity,
    [Parameter(Mandatory=$false)]
    [string]$User
)

Process {
    $ErrorActionPreference = "Stop"

    if (Get-Module -ListAvailable -Name Az.Accounts) {
       # Write-Host "You have the Az.Accounts module installed"
    } 
    else {
        Write-Host "You need to install the Az.Accounts module";
        break
    }

    If(!$MyHeader){


    If($ManagedIdentity -eq $true)
    {
        "managed"
        try {
        Connect-AzAccount -Identity

        $MyTokenRequest = Get-AzAccessToken -ResourceUrl "https://cognitiveservices.azure.com"
        $MyToken = $MyTokenRequest.token
            If(!$MyToken){
                Write-Warning "Failed to get API access token!"
                Exit 1
            }
        $Global:MyHeader = @{"Authorization" = "Bearer $MyToken" }
       }
        catch [System.Exception]
        {
        Write-Warning "Failed to get Access Token, Error message: $($_.Exception.Message)"; break
        }
    
    }
      If($User -eq $true)
      { 
        "USER"
        try {
            Connect-AzAccount
    
            $MyTokenRequest = Get-AzAccessToken -ResourceUrl "https://cognitiveservices.azure.com"
            $MyToken = $MyTokenRequest.token
                If(!$MyToken){
                    Write-Warning "Failed to get API access token!"
                    Exit 1
                }
            $Global:MyHeader = @{"Authorization" = "Bearer $MyToken" }
           }
          catch [System.Exception] 
          {
                Write-Warning "Failed to get Access Token, Error message: $($_.Exception.Message)"; break
          }
   
      }

     If($APIkey)
        {
            "APIKEY"

            $Global:MyHeader = @{"api-key"  = $apikey}

                        

        }
    }




    }
}

function Get-Completion {
    <#  .SYNOPSIS
        Get a text completion from Azure OpenAI Completion endpoint.
    .PARAMETER DeploymentName
        A deployment name should be provided.
    .PARAMETER ResourceName
        A Resource  name should be provided.
    .PARAMETER Prompt
        A prompt name should be provided.
    .PARAMETER Token
        A token name should be provided.                
    .EXAMPLE
        Get-Completion -DeploymentName $DeploymentName -ResourceName $ResourceName -maxtokens 100 -prompt "What is the meaning of life?"
    .NOTES
        Author: Alexander Holmeset
        Twitter: @AlexHolmeset
        Website: https://www.alexholmeset.blog
        Created: 09-02-2023
        Updated: 
        Version history:
        1.0.0 - (09-02-2023) Function created      
    #>[CmdletBinding()]
    param (
        [parameter(Mandatory = $true, HelpMessage = "Your azure openai deployment name")]
        [ValidateNotNullOrEmpty()]
        [string]$DeploymentName,
        [parameter(Mandatory = $true, HelpMessage = "your azure openai resource name")]
        [ValidateNotNullOrEmpty()]
        [string]$ResourceName,
        [parameter(Mandatory = $true, HelpMessage = "Your Azure OpenAI prompt")]
        [ValidateNotNullOrEmpty()]
        [string]$Prompt,
        [parameter(Mandatory = $true, HelpMessage = "Max number of tokens allowed to be used in this request")]
        [ValidateNotNullOrEmpty()]
        [int]$Maxtokens
        )

Process {
    $ErrorActionPreference = "Continue"
         $APIVersion = "2023-03-15-preview"
    # Construct URI
   #  $uri = "https://wolffentpopenai.openai.azure.com/openai/deployments/wolffentpoaisearch/completions?api-version=2023-03-15-preview"
    # https://wolffentpopenai.openai.azure.com/openai/deployments/wolffentpoaisearch/chat/completions?api-version=2023-03-15-preview

      $uri =  "https://$resourcename.openai.azure.com/openai/deployments/$deploymentname/completions?api-version=$APIVersion"
    # Construct Body
$Body = @"
{
"prompt": "$Prompt",
"max_tokens": $maxtokens,
 "temperature": 0.09,
  "top_p": 0.01,
  "frequency_penalty": 0.7,
  "presence_penalty": 0.7,
  "stop" : ["Human:","AI:"]
}
"@




    try {
        $Global:Request = invoke-restmethod -Method POST -Uri $uri -ContentType "application/json" -Body $body  -Headers $Global:MyHeader

        }
    catch [System.Exception]
     {
      Write-Warning "Failed to to POST request: $($_.Exception.Message)"; break
     }
    return $Request
    }
}


function write_response($prompt)
{
     $question = read-host "ask to guru as questions (maybe it wont be gibberish): "
     $oldquestion = "$question"

    do
    {
        if($question -eq '')
        {
                $question = read-host "ask to guru as questions (maybe it wont be gibberish): "
            
        }

        if ($question -eq 'quit')
        {
            Exit 
            "Token cost"
            $Request.usage

        }
        if($question -ne $oldquestion -and $question -ne 'quit' -and $question -ne 'regenerate')
        {
        $prompt = $question
        $oldquestion = $question
        }


    $Prompt = "$question" 

        If($prompt -eq 'regenerate')
        {
            $prompt = "$oldquestion"
       
   
            $Request = Get-Completion -DeploymentName $DeploymentName -ResourceName $ResourceName -Maxtokens 200 -Prompt $Prompt

            Write-host "$oldquestion" -ForegroundColor cyan 
            write-host ""
            $answersarray = ($($Request.choices.text)) 
            $answers = ($answersarray).Split("'r'n")
            $answerscount = $($answers.count)
            $i = 0
            do
            {

            write-host "$($answers)  `r`n" -ForegroundColor green 
            $i = $i +1
         
            }until ($i -ge $answerscount)

         
        }
        else
        {
      
            $Request = Get-Completion -DeploymentName $DeploymentName -ResourceName $ResourceName -Maxtokens 200 -Prompt $Prompt

            Write-host "$question" -ForegroundColor cyan 

            write-host ""

            $answersarray = ($($Request.choices.text)) 
            $answers = ($answersarray).Split("`r`n")
            $answerscount = $($answers.count)

            $i = 0

            do
            {

            write-host "$($answers[$i]) `r`n" -ForegroundColor green 
            $i = $i +1
         
            } until ($i -ge $answerscount)

           
            
        }
         write-host "`r`n"
      return
     
 } until ($question -eq 'quit')
}
######################################################################

#Connect-AzAccount   -Identity 
Clear-AzContext -Force

#Get-AzureOpenAIToken -ManagedIdentity $true
 Get-AzureOpenAIToken -User $true
 $DeploymentName = "wolffentpoaisearch"
 $resourcename = "wolffentpopenai"
 
  
 cls
do
{
  

$Prompt = "$question" 

write_response -prompt "$Prompt"


} until ($question -eq 'quit')

"Token cost"
$Request.usage
















