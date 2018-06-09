Function Get-DisplayConnection {
    [CmdletBinding()]
    Param (
        [String[]]$InstanceName
    )

    Begin {}

    Process {

        $CIM = @{

            'NameSpace' = 'Root/WMI';
            'ClassName' = 'WmiMonitorConnectionParams'
            'ErrorAction' = 'Stop'
        }

        $connectionType = get-ciminstance @CIM | Where-object {$_.InstanceName -eq $InstanceName} | Select-Object -ExpandProperty VideoOutputTechnology
        
        Switch ($ConnectionType) {

            -2 {'Uninitialized'}
            -1 {'Other'}
            0 {'VGA'}
            1 {'S-Video'}
            2 {'Composite'}
            3 {'Component'}
            4 {'DVI'}
            5 {'HDMI'}
            6 {'LVDS'}
            8 {'D-Jpn'}
            9 {'SDI'}
            10 {'External-DP'}
            11 {'Embedded-DP'}
            12 {'External-UDI'}
            13 {'Embedded-IDU'}
            14 {'SDTV'}
            15 {'MiraCast'}

        }

    }

    End {}

}

Function Get-MonitorInfo {
    <#
    .SYNOPSIS
    Get model and serial number of the monitor(s) connected to the system queried

    .DESCRIPTION
    Get-MonitorInfo utilizes the Common Information Model (CIM) instances of the computer to pull the user friendly
    monitor name, monitor serial number, the computer name, computer model, and computer serial number. 

    .PARAMETER ComputerName
    Name of the computer on your network that you would like to query. Defaults to the local computer. 

    .EXAMPLE
    Get-MonitorInfo

    .NOTES
    Works on PowerShell 3.0 and higher
    #>
    [CmdletBinding()]
    Param (
        [Parameter( ValueFromPipelineByPropertyName=$True,
                    ValueFromPipeline=$True)]
        [String[]]$ComputerName = 'localhost'
    )

    foreach ($computer in $ComputerName) {

        Try {

            $WMI = @{
                'ComputerName' = $Computer;
                'Class' = 'wmiMonitorID';
                'NameSpace' = 'root\wmi';
                'ErrorAction' = 'stop'
            }

            $Monitors = Get-CimInstance @WMI

            $WMI = @{
                'ComputerName' = $Computer;
                'Class' = 'Win32_ComputerSystem';
                'ErrorAction' = 'Stop'
            }

            $System = Get-CimInstance @WMI

            $WMI = @{
                'ComputerName' = $computer;
                'Class' = 'Win32_Bios';
                'ErrorAction' = 'stop'
            }

            $Bios = Get-CimInstance @WMI

            foreach ($monitor in $Monitors) {

                $props = @{
                    'ComputerName' = $computer;
                    'ComputerType' = $System.model;
                    'ComputerSerial' = $Bios.SerialNumber;
                    'MonitorSerial' = ($Monitor.SerialNumberID | ForEach-Object {[Char]$_}) -Join "";
                    'MonitorType' = ($Monitor.UserFriendlyName | ForEach-Object {[Char]$_}) -Join ""
                    'ConnectionType' = Get-DisplayConnection -InstanceName $Monitor.InstanceName
                }

                $obj = New-Object -TypeName psobject -Property $props
                $obj.PsObject.Typenames.insert(0,'ComputerMonitorInfo')
                Write-Output $obj

            }

        } Catch {

            Write-Output "$($Error[0].Exception)"

        }

    }

}
