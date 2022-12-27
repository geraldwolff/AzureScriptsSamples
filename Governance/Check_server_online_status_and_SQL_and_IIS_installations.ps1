#-----------------------------------------

######################################################################

# Created: 11/28/2016

# Modified:  

# Author: J Wolff  
 
# Requires: Powershell v2

# Check_server_online_status_and_SQL_installations.ps1
#Description: Read server list from excel in 1 column and add users while updating SQL Db with status

######################################################################
 $DBINSTANCE = "$env:computername"

#  .

clear-content c:\temp\Versions_inventory.txt


         
 #Get-Module -ListAvailable | Import-Module
 function Get-Type
{
    param($type)

$types = @(
'System.Boolean',
'System.Byte[]',
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
function Out-DataTable
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


 $ErrorActionPreference = "Continue"
#-----------------------------------------------------------------------------------
# setup SQL snapin and assembly
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
 
##############################################################################################
 $truncate_SQL_config_tables =  { Invoke-Sqlcmd -query "use audit;
                       truncate table [AUDIT].[dbo].[Version_Audit]
 
                                     " -serverinstance "$DBINSTANCE" -querytimeout 99999  }

                        invoke-command  $truncate_SQL_config_tables
  

function check_for_sql  
{


 $check_for_sql = { Invoke-Sqlcmd -query "  SELECT @@VERSION as version
                                
                GO " -serverinstance  $Server    -querytimeout 999999 } 

 $SQL_status= Get-WmiObject -Class Win32_Service -ComputerName $server | select DisplayName,  State | ? { $_.DisplayName -like "*SQL Server (MSSQLSERVER)*" } | % { "$($_.DisplayName) is $($_.state)" } | select -First 1

  $sql_version = invoke-command $check_for_sql 

  
$sql_versionstring = $sql_version.version

$sql_versionstring

  write-host  "$server , $SQL_status, $sql_versionstring"   -ForegroundColor Red -BackgroundColor green

   $logSQL_information =  { Invoke-Sqlcmd -query "use audit; INSERT INTO [AUDIT].[dbo].[Version_Audit]
                                   ([Server]
                                         ,[IIS_Version]
                                          ,[SQL_Version]
                                          ,[Online_Status]
                                          ,[Date_Run]
                                                                       )
                             VALUES      ('$server',
                                         '',
                                     '$sql_versionstring',
                                    '$SQL_status'
                                 
                                    ,GETDATE()
                                        )  " -serverinstance "$DBINSTANCE" -querytimeout 99999  }

                                    invoke-command $logSQL_information

 }
  
function check_for_IIS 
{
 
 $webarray =@()

  
 $sites = {Invoke-Command -ComputerName $server -ScriptBlock { $(Get-ItemProperty HKLM:\SOFTWARE\Microsoft\InetStp\)} } 

 
   
 $IIS_Status =invoke-command $sites 
                        
 

                          # write-output  "$server, $IIS_status"   | out-file c:\temp\Versions_inventory.txt -append 
                              $iis_information =  { Invoke-Sqlcmd -query "use audit;
                                   IF EXISTS(SELECT 1 FROM  [AUDIT].[dbo].[Version_Audit]  where [Server]='$server') 
                                    BEGIN 
  
	                                 update [AUDIT].[dbo].[Version_Audit]
                                        set 
                                      [IIS_Version]='$IIS_Status'
         
                                          where [Server] = '$server'
 
                                 End
                                 else 
                                Begin
                                 insert into [dbo].[Version_Audit]([Server]
                                    ,[IIS_Version]
                                     ,[SQL_Version]
                                     ,[Online_Status]
                                     ,[Date_Run]
                                        ) values('$server',
                                       '$IIS_Status',
                                        '',
                                      '', GETDATe() )
                                  end  
                                      " -serverinstance "$DBINSTANCE" -querytimeout 99999  }

                                            invoke-command $iis_information
 
                     write-host "$server, $status , $IIS_status ,$SQL_status , $sql_versionstring"  -backgroundcolor "Yellow" -foregroundcolor "BLACk"
 
 }
#---------------------------------------------------
  
 
Function ping_check{

      foreach ($Server in  $computers) {

		if (test-Connection -ComputerName $Server -Count 2 -Quiet ) { 
		
			    write-Host "$Server is alive and Pinging " -ForegroundColor Green
                write-host " $server is being checked for SQL and IIS installation"  -ForegroundColor yellow
                 
                 check_for_sql 
                 check_for_IIS 

                $status = 'Online'
                
               		
					} else
					
					{ 
                 check_for_sql 
                 check_for_IIS 
                        $status = 'Offline'
                        Write-Warning "$Server seems dead not pinging"
                       write-output "$server is  $status" | out-file c:\temp\Versions_inventory.txt -append 
			
					}

                     
    
    
                  

         
        }
  }
########################################
#-------------------------------------------------------------
Function get_servers 
{


$server_list =   { Invoke-Sqlcmd -query " 
                        use AUDIT
                        Go
                            SELECT  [name]
       
                          FROM [AUDIT].[dbo].[master_server_status]
                          order by name asc

                    GO" -serverinstance  $DBINSTANCE  -querytimeout 999999 } 




Invoke-Command $server_list |out-file "C:\temp\computerIIS_SQL_list.csv"
}

 get_servers


 
 
 ########################################################################
 ########################################################################

 
#$computerlist =  Import-csv "c:\temp\computer_list.csv" 
 
# $computerlist

 $computerlist = gc "C:\temp\computerIIS_SQL_list.csv" |  select -skip 3


foreach ($computers in $computerlist ){
      
         $computers = $computers.trim()

       ping_check($computers)
           
           write-host "$computers **** " -ForegroundColor Blue -BackgroundColor Yellow

          Write-Output "$server, $status , $IIS_status ,$SQL_status , $sql_versionstring " | export-csv "C:\temp\versions.csv" 
   
            
                 $Versions = import-csv "C:\temp\versions.csv" 

                 $datatable =   $Versions   | out-datatable 
                #  $datatable

                 $cn = new-object System.Data.SqlClient.SqlConnection("Data Source=$dbinstance;Integrated Security=SSPI;Initial Catalog=AUDIT");
                 $cn.Open()

                 $bc = new-object ("System.Data.SqlClient.SqlBulkCopy") $cn
                 $bc.DestinationTableName = "[dbo].[Version_Audit]"
                 $bc.WriteToServer($datatable)
                 $cn.Close()
 
 
    } 
 