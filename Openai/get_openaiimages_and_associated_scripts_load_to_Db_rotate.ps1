 <#'sqlserver','az', 'az.storage' ,'az.keyvault','nuget','ps2exe' | foreach-object {
  if((Get-InstalledModule -name $_))
  { 
    Write-Host " Module $_ exists  - updating" -ForegroundColor Green
         #update-module $_ -force | Out-Null
     import-module -name $_ -force | Out-Null
    }
    else
    {
    write-host "module $_ does not exist - installing" -ForegroundColor red -BackgroundColor white
     
        install-module -name $_ -allowclobber -force | Out-Null
        import-module -name $_ -force | Out-Null
    }
   #  Get-InstalledModule
}
#>
   
  Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings 'true'


### uncomment when using for AAzure Automation

Connect-AzAccount 
 

   
 $keyvault = 'wolffentpkeyvault'
 $serviceprincipal = 'wwolffsqladmin'
 
    $keyvaultname = (get-azkeyvault -name $keyvault) 
     
 
 
# Get the secret object from the Key Vault
$secret = Get-AzKeyVaultSecret -VaultName $($keyVaultName.VaultName) -Name  $serviceprincipal

# Get the secret value as a plain text string
$secretValue = $($secret.SecretValue)
   
 $ptsecret =  [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secretValue)) 
 $username = $($secret.Name)

# Authenticate with Azure AD using the application credentials
$credential = New-Object System.Management.Automation.PSCredential($username, $secretValue )

 

      $AZStoragelist =''  

             $subscriptionlist =  Get-AZSubscription -SubscriptionName 'wolffentpsub' |select  name, ID 
 
             $SubscriptionName =  $($subscriptionlist.name)
             
             $SubscriptionID =  $Subscription.ID 

            set-AZcontext -SubscriptionName  $SubscriptionName | out-null

           #  write-host "$SubscriptionName" -foregroundcolor yellow

            #Get-Command -Module Azure -Noun *Storage*`


             #$SubscriptionName 
             $storageaccounts = Get-AZStorageAccount -Name wolffautosa -ResourceGroupName wolffautomationrg | select StorageAccountName, context, PrimaryEndpoints,AccountType, ProvisioningState ,PrimaryLocation ,Resourcegroupname ,Tags


                foreach($storageaccount in $storageaccounts )
                { 
                            $StorageAccountName = $storageaccount.StorageAccountName
                            $storageaccountrg = $storageaccount.resourcegroupname
                              

                                 #$stgacct = Get-AZStorageAccount | Format-Table -Property StorageAccountName, Location, AccountType, StorageAccountStatus

                                 Set-AZContext -SubscriptionName $SubscriptionName | out-null

                          #       Set-AZStorageAccount -StorageAccountName $StorageAccountName -ResourceGroupName $storageaccountrg
 
                               $stgkey =  (Get-AZStorageAccountKey -Name $StorageAccountName -ResourceGroupName $storageaccountrg -erroraction silentlycontinue)
  
                      
                               # $stgkey.value
                                $storageacctkeyprimary = ($stgkey.value ) | select -First 1
                                $storageacctkeySecondary = ($stgkey.value ) | select -skip 1  
                                $storageacctkeyStorageAccountName = $StorageAccountName
 
 

                              $storageaccountendpoints = $storageaccount.PrimaryEndpoints
                              $storageaccountlocation = $storageaccount.PrimaryLocation
                              $storageaccount_type =  $storageaccount.AccountType
                              $storeageaccountstatus = $storageaccount.StatusOfPrimary
                    
                               # $ctx = $storageaccount.context
                                $ctx = New-AZStorageContext -StorageAccountName  $StorageAccountName -StorageAccountKey $storageacctkeyprimary 
                               $containers = Get-AzStorageContainer  -context $ctx




                               foreach($containeritem in $containers | where name -like '*image*')
                              {
                                   # Get-AZStorageBlob -Context  $ctx  -Container $containeritem.Name

                                    $containername = $containeritem.name  

                                    #List the snapshots of a blob.

                                    $blobs =   Get-AZStorageBlob –Context $Ctx  -Container $ContainerName | where length -gt 0   | Sort-Object length -desc  



                                      foreach($blob in  $blobs )
                                      {

 
                                        $BlobType = $blob.blobtype
                                        $blobname = $blob.Name
                                        $blobcontenttype = $blob.ContentType
                                        $bloblastmodified = $blob.LastModified
                                        $blobcontect = $blob.Context
                                        $blobICloudBlob = $blob.ICloudBlob.Name
                                  
                                            $Resource = Get-AzResource -Name $StorageAccountName | select -Property *


                                           $Resource.Tags.GetEnumerator() | ForEach-Object {

                                               #Write-Output "$($_.key)   = $($_.Value)"
                                        
 
                                              $obj | add-member -membertype Noteproperty -name $($_.key) -value $($_.value) -ErrorAction SilentlyContinue

                                              }
                                      # $blobcontent  =  get-AzStorageBlobContent  -cloudblob $blob.ICloudBlob   -Context   $blobcontect  
                                       # Generate a SAS for the blob
                                        $sas = New-AzStorageBlobSASToken -Blob $blob.Name -Container $ContainerName -Permission "r" -Context $ctx -ErrorAction SilentlyContinue
                                        # Combine the blob's URI with the SAS token
                                        $blobcontentlink = $blob.ICloudBlob.Uri.AbsoluteUri + $sas

                                        $obj = new-object PSObject
                                        $obj | add-member -membertype NoteProperty -name "subscriptioname" -value "$SubscriptionName"
                                        $obj | add-member -membertype NoteProperty -name "storageaccountname" -value "$storageaccountname"
                                        $obj | add-member -membertype NoteProperty -name "storageaccountendpoints" -value "$storageaccountendpoints"
                                        $obj | add-member -membertype NoteProperty -name "storageaccountlocation" -value "$storageaccountlocation "
                                        $obj | add-member -membertype NoteProperty -name "storageaccount_type" -value "$storageaccount_type"
                                        $obj | add-member -membertype NoteProperty -name "storageaccountstatus" -value "$storageaccountstatus"
                                        $obj | add-member -membertype NoteProperty -name "storageacctkeyStorageAccountName" -value "$storageacctkeyStorageAccountName"   
                                        $obj | add-member -membertype NoteProperty -name "containername" -value "$containername"
                                        $obj | add-member -membertype NoteProperty -name "BlobType" -value "$BlobType"
                                        $obj | add-member -membertype NoteProperty -name "blobname" -value "$blobname"   
                                        $obj | add-member -membertype NoteProperty -name "blobcontenttype" -value "$blobcontenttype"
                                        $obj | add-member -membertype NoteProperty -name "bloblastmodified" -value "$bloblastmodified"
                                        $obj | add-member -membertype NoteProperty -name "blobcontext" -value "$blobcontext"                                    
                                        $obj | add-member -membertype NoteProperty -name "blobICloudBlob" -value "$blobICloudBlob"
                                        $obj | add-member -membertype NoteProperty -name "blobSize" -Value $($blob.Length)
                                        $obj | Add-Member -MemberType NoteProperty -Name  "Linktoblob" -Value $blobcontentlink
                                        $obj | Add-Member -MemberType NoteProperty -Name  "Date" -Value (get-date)

                                   [array]$AZStoragelist +=     $obj  

                                 }
                }

        }

    


    

$date = $(Get-Date -Format 'dd MMMM yyyy' )
 
    $CSS = @"
<Title> OpenAiImages requested : $date </Title>
<Style>
th {
	font: bold 11px "Trebuchet MS", Verdana, Arial, Helvetica,
	sans-serif;
	color: #FFFFFF;
	border-right: 1px solid #FF45007;
	border-bottom: 1px solid #FF4500;
	border-top: 1px solid #FF4500;
	letter-spacing: 2px;
	text-transform: uppercase;
	text-align: left;
	padding: 6px 6px 6px 12px;
	background: #5F9EA0;
}
td {
	font: 11px "Trebuchet MS", Verdana, Arial, Helvetica,
	sans-serif;
	border-right: 1px solid #FF4500;
	border-bottom: 1px solid #FF4500;
	background: #fff;
	padding: 6px 6px 6px 12px;
	color: #6D929B;
}
</Style>
"@


($AZStoragelist| Select subscriptioname,  storageaccountname, storageaccountendpoints, storageaccountlocation, storageaccount_type , storageaccountstatus, storageacctkeyStorageAccountName, containername,BlobType,blobname,blobcontenttype, bloblastmodified,blobcontext,blobICloudBlob,blobSize,Linktoblob| `   
ConvertTo-Html -Head $CSS )  | out-file "c:\temp\azstorage.html" 

Invoke-Item "c:\temp\azstorage.html" 


####################################################  db load
# get-module -ListAvailable | import-module -force -verbose
 install-module sqlserver | out-null
 update-module sqlserver| out-null
 import-module sqlserver| out-null
 

 # Add the SQL Server provider.
#System.Reflection.Assembly::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
 


       $sqlcredusername = $username
       $sqlcredpwd =  $ptsecret

 
 set-azcontext -Subscription wolffentpsub | out-null


$server = Get-AzSqlServer -ServerName wolffentpsqlsvr01
$servername = $($server.FullyQualifiedDomainName)
$resourceGroupName = $($server.ResourceGroupName)


$databaseName = 'openaiimages'

  
 

   $create_image_table  =  { Invoke-Sqlcmd -query "

                USE [openaiimages] ;
                GO
                declare  @date [nvarchar] (max)  = CONVERT(VARCHAR(10), GETDATE(), 112)
                declare @oldtable [nvarchar] (max) = concat('[dbo].[images',@date,']')

                Print(@oldtable) 

                EXEC sp_rename '[dbo].[images]', @oldtable
                go

                /****** Object:  Table [dbo].[Images]    Script Date: 1/31/2019 10:32:11 AM ******/
                SET ANSI_NULLS ON
                GO

                SET QUOTED_IDENTIFIER ON
                GO

                CREATE TABLE [dbo].[images](
                    [ID]   [varchar](max)   DEFAULT NEWID(),
                    [subscriptioname] [varchar](max) NULL,
                    [storageaccountname] [varchar](max) NULL,
                    [storageaccountendpoints] [varchar](max) NULL,
                    [storageaccountlocation] [varchar](max) NULL,
                    [storageaccount_type] [varchar](max) NULL,
                    [storageaccountstatus] [varchar](max) NULL,
                    [storageacctkeyStorageAccountName] [varchar](max) NULL,
                    [containername] [varchar](max) NULL,
                    [BlobType] [varchar](max) NULL,
                    [blobname] [varchar](max) NULL,
                    [blobcontenttype] [varchar](max) NULL,
                    [bloblastmodified] [varchar](max) NULL,
                    [blobcontext] [varchar](max) NULL,
                    [blobICloudBlob] [varchar](max) NULL,
                    [blobSize] [varchar](max) NULL,
                    [Linktoblob] [varchar](max) NULL,
	                [date] [varchar](max) NULL 
 
                )

                select * from sys.tables

                GO" -serverinstance $servername    -querytimeout 999 -database $databaseName -Username "$sqlcredusername" -Password "$sqlcredpwd" } 

                            invoke-command  $create_image_table
 


   $get_openaiimages  =  { Invoke-Sqlcmd -query "

        

                 USE [openaiimages]
                GO

       

                SET QUOTED_IDENTIFIER ON
                GO
                Select * from images 

                 

                GO"-serverinstance $servername    -querytimeout 999 -database $databaseName -Username "$sqlcredusername" -Password $sqlcredpwd } 

                            invoke-command  $get_openaiimages






$dbinstance = $env:computername
 #######################
function Get-Type
{
    param($type)

$types = @(
'System.Boolean',
'System.Byte',
'System.Byte',
'System.Char',
'System.Datetime',
'System.Decimal',
'System.Double',
'System.Guid',
'System.Int16',
'System.Int32',
'System.Int64',
'System.Single',
'System.UInt16',
'System.UInt32',
'System.UInt64')

    if ( $types -contains $type ) {
        Write-Output "$type"
    }
    else {
        Write-Output 'System.String'
        
    }
} #Get-Type



#######################
<#
.SYNOPSIS
Creates a DataTable for an object
.DESCRIPTION
Creates a DataTable based on an objects properties.
.INPUTS
Object
    Any object can be piped to Out-DataTable
.OUTPUTS
   System.Data.DataTable
.EXAMPLE
$dt = Get-psdrive| Out-DataTable
This example creates a DataTable from the properties of Get-psdrive and assigns output to $dt variable
.NOTES
 
#>
function out-datatable
{
    [CmdletBinding()]
    param([Parameter(Position=0, Mandatory=$true, ValueFromPipeline = $true)] [PSObject[]]$InputObject)

    Begin
    {
        $dt = new-object Data.datatable  
        $First = $true 
    }
    Process
    {
        foreach ($object in $InputObject)
        {
            $DR = $DT.NewRow()  
            foreach($property in $object.PsObject.get_properties())
            {  
                if ($first)
                {  
                    $Col =  new-object Data.DataColumn  
                    $Col.ColumnName = $property.Name.ToString()  
                    if ($property.value)
                    {
                        if ($property.value -isnot [System.DBNull]) {
                            $Col.DataType = [System.Type]::GetType("$(Get-Type $property.TypeNameOfValue)")
                         }
                    }
                    $DT.Columns.Add($Col)
                }  
                if ($property.Gettype().IsArray) {
                    $DR.Item($property.Name) =$property.value | ConvertTo-XML -AS String -NoTypeInformation -Depth 1
                }  
               else {
                    $DR.Item($property.Name) = $property.value
                }
            }  
            $DT.Rows.Add($DR)  
            $First = $false
        }
    } 
     
    End
    {
        Write-Output @(,($dt))
    }

} #Out-DataTable



 $ConnectionString = ("Server=tcp:wolffentpsqlsvr01.database.windows.net,1433;Initial Catalog=openaiimages;Persist Security Info=False;User ID=$sqlcredusername;Password=$sqlcredpwd;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;")
 
 $date = get-date

 $datatable =   $AZStoragelist| Select ID , subscriptioname `
      ,storageaccountname `
      ,storageaccountendpoints `
      ,storageaccountlocation `
      ,storageaccount_type `
      ,storageaccountstatus `
      ,storageacctkeyStorageAccountName `
      ,containername `
      ,BlobType `
      ,blobname `
      ,blobcontenttype `
      ,bloblastmodified `
      ,blobcontext `
      ,blobICloudBlob `
      ,blobSize `
      ,Linktoblob `
      ,date  | where-object {$_.subscriptioname -ne '' -and $_.subscriptioname -ne $null}| out-datatable 

  #$datatable



                                 $cn = new-object System.Data.SqlClient.SqlConnection( $ConnectionString);
                                 $cn.Open()

                                 $bc = new-object ("System.Data.SqlClient.SqlBulkCopy") $cn
                                 $bc.DestinationTableName = "dbo.images"
                                 $bc.WriteToServer($datatable)
                                 $cn.Close()
   


 
