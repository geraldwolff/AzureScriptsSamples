Add-Type -AssemblyName System.Windows.Forms
 

Function Measure-NetworkSpeed{
    # The test file has to be a 10MB file for the math to work. If you want to change sizes, modify the math to match
    $TestFile  = "https://go.microsoft.com/fwlink/?linkid=2216182&clcid=0x409"
   # $TempFile  = Join-Path -Path $env:TEMP -ChildPath 'testfile.tmp'
    $TempFile = "c:\temp\TempFile.tmp"
    $WebClient = New-Object Net.WebClient
    $TimeTaken = Measure-Command { $WebClient.DownloadFile($TestFile,$TempFile) } | Select-Object -ExpandProperty TotalSeconds
    $filesize = (get-item -path $TempFile).length
  $downloadSpeed = $filesize / $($TimeTaken)
     $SpeedMbps = $([math]::Round($downloadSpeed / 1MB, 2))

   $SpeedMbps
 
}
 

$button3 = New-Object System.Windows.Forms.Button

function Show-PerformanceMetrics {
    Clear-Host

    $LoadHistory = @()

    # Create a new form
    $Form = New-Object System.Windows.Forms.Form
    $Form.Text = "Performance Metrics"
    $Form.Size = New-Object System.Drawing.Size(50,55)
    $form.AutoSize = $true
    $form.AutoSizeMode = $true
    $form.Controls = $true
    $form.AutoSizeMode = $true
    #
    
    $button3.TabIndex = 1
    $button3.Name = "button3"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 75
    $System_Drawing_Size.Height = 23
    $button3.Size = $System_Drawing_Size
    $button3.UseVisualStyleBackColor = $True

    $button3.Text = "Close"

    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 160
    $System_Drawing_Point.Y = 15
    $button3.Location = $System_Drawing_Point
    $button3.DataBindings.DefaultDataSourceUpdateMode = 0
    $button3.add_Click($button3_OnClick)

    $form.Controls.Add($button3)

    #######



    # Create a table view control
   # $dataGrid1 = New-Object System.Windows.Forms.DataGrid
    $GridView = New-Object System.Windows.Forms.DataGrid
    $GridView.Dock = [System.Windows.Forms.DockStyle]::Fill
    $gridview.Resize = $true 
    $GridView.DataBindings.DefaultDataSourceUpdateMode = 0
    $GridView.HeaderForeColor = [System.Drawing.Color]::FromArgb(255,1,95,0)
    $GridView.Name = "dataGrid1"
    $GridView.DataMember = ""
    $GridView.TabIndex = 0
    $gridview.ColumnHeadersVisible = $true
    $gridview.PreferredColumnWidth = 150
    $GridView.AutoSize  = $true

    $Form.Controls.Add($GridView) 

        #####
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 350
    $System_Drawing_Size.Height = 150
    $gridview.Size = $System_Drawing_Size


    #######


    # Create a button to show the function parameters
    $ShowCommandButton = New-Object System.Windows.Forms.Button
    $ShowCommandButton.Text = "Show Command"
    $ShowCommandButton.Dock = [System.Windows.Forms.DockStyle]::Top
    $Form.Controls.Add($ShowCommandButton,$GridView)

    # Create an event handler for the button
    $ShowCommandButton.Add_Click({
        $SelectedRow = $GridView.SelectedRows[0]
        $SelectedRowValues = @{}
        foreach ($Cell in $SelectedRow.Cells) {
            $SelectedRowValues[$Cell.OwningColumn.HeaderText] = $Cell.Value
        }

        $SelectedRowValues | Show-Command
    })

    # Show the form

    $Form.Show()

            while (1) {
                # Calculate different metrics. Can be updated by editing the value-key pairs in $Currentload.
                $OS = Get-Ciminstance Win32_OperatingSystem 
                $CurrentLoad = [ordered]@{ "CPU Load" = (Get-CimInstance win32_processor).LoadPercentage 
                "RAM Usage (%)"  = (100 - ($OS.FreePhysicalMemory/$OS.TotalVisibleMemorySize)*100) 
                "Network Speed (MB/sec)" = (Measure-NetworkSpeed) }




            $LoadHistory = New-Object System.Collections.ArrayList

            $Script:CMDinfo = $CurrentLoad  
            $LoadHistory.AddRange($CMDinfo)


            $GridView.DataSource = $LoadHistory 

            $GridView.Update()
            $GridView.Refresh()
 
            # Reset cursor and overwrite prior output
            $host.UI.RawUI.CursorPosition = @{x=0; y=1}
            $form.Update()
            # Wait for 1 second
            Start-Sleep -Seconds 2
            
            
            # Close
$button3_OnClick= 
{
$form.Close()
}

        }
}

Show-PerformanceMetrics




