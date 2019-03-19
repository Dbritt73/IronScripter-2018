Function Get-DisplayConnection {
  <#
    .SYNOPSIS
    Get each monitor instance on a local or remote computer and returns the connection type used by the monitor

    .DESCRIPTION
    Get-DisplayConnection

    .PARAMETER InstanceName
    Describe parameter -InstanceName.

    .EXAMPLE
    Get-DisplayConnection -InstanceName Value
    Describe what this call does

    .NOTES
    Place additional notes here.

    .LINK
    URLs to related sites
    The first link is opened by Get-Help -Online Get-DisplayConnection

    .INPUTS
    List of input types that are accepted by this function.

    .OUTPUTS
    List of output types produced by this function.
  #>


    [CmdletBinding()]
    Param (
        [Parameter( Mandatory=$true,
                    HelpMessage='Add help message for user')]
        [String[]]$InstanceName,

        [Parameter( Mandatory=$true,
                    HelpMessage='Add help message for user')]
        [string]$ComputerName

    )

    Begin {}

    Process {

        foreach ($computer in $ComputerName) {

            Try {

                $CIM = @{

                    'NameSpace'    = 'Root/WMI'
                    'ComputerName' = $Computer
                    'ClassName'    = 'WmiMonitorConnectionParams'
                    'ErrorAction'  = 'Stop'

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
                    13 {'Embedded-UDI'}
                    14 {'SDTV'}
                    15 {'MiraCast'}

                }

            } Catch {

                # get error record
                [Management.Automation.ErrorRecord]$e = $_

                # retrieve information about runtime error
                $info = [PSCustomObject]@{

                    Date         = (Get-Date)
                    ComputerName = $computer
                    Exception    = $e.Exception.Message
                    Reason       = $e.CategoryInfo.Reason
                    Target       = $e.CategoryInfo.TargetName
                    Script       = $e.InvocationInfo.ScriptName
                    Line         = $e.InvocationInfo.ScriptLineNumber
                    Column       = $e.InvocationInfo.OffsetInLine

                }

                # output information. Post-process collected info, and log info (optional)
                Write-Output -InputObject $info

            }

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
    monitor name, monitor serial number, the computer name, computer model, connection type, and computer serial number. 

    .PARAMETER ComputerName
    Name of the computer on your network that you would like to query. Defaults to the local computer. 

    .EXAMPLE
    Get-MonitorInfo

    .NOTES
    Works on PowerShell 3.0 and higher
    #>

    [CmdletBinding()]
    Param (
        [Parameter( position = 0,
                    ValueFromPipelineByPropertyName = $True,
                    ValueFromPipeline = $True)]
        [string[]]$ComputerName = 'localhost'
    )

    foreach ($computer in $ComputerName) {

        Try {

            $WMI = @{

                'ComputerName' = $Computer
                'Class'        = 'wmiMonitorID'
                'NameSpace'    = 'root\wmi'
                'ErrorAction'  = 'stop'

            }

            $Monitors = Get-CimInstance @WMI

            $WMI = @{

                'ComputerName' = $Computer
                'Class'        = 'Win32_ComputerSystem'
                'ErrorAction'  = 'Stop'

            }

            $System = Get-CimInstance @WMI

            $WMI = @{

                'ComputerName' = $computer
                'Class'        = 'Win32_Bios'
                'ErrorAction'  = 'stop'

            }

            $Bios = Get-CimInstance @WMI

            foreach ($monitor in $Monitors) {

                $splat = @{

                    'ComputerName' = $computer
                    'InstanceName' = $Monitor.InstanceName

                }

                $props = [ordered]@{

                    'ComputerName'   = $computer
                    'ComputerType'   = $System.model
                    'ComputerSerial' = $Bios.SerialNumber
                    'MonitorType'    = ($Monitor.UserFriendlyName | ForEach-Object {[Char]$_}) -Join ''
                    'MonitorSerial'  = ($Monitor.SerialNumberID | ForEach-Object {[Char]$_}) -Join ''
                    'MonitorYear'    = $Monitor.YearOfManufacture
                    'ConnectionType' = Get-DisplayConnection @splat

                }

                $obj = New-Object -TypeName psobject -Property $props
                $obj.PsObject.Typenames.insert(0,'ComputerMonitorInfo')
                Write-Output -InputObject $obj

            }

        } Catch {

            # get error record
            [Management.Automation.ErrorRecord]$e = $_

            # retrieve information about runtime error
            $info = [PSCustomObject]@{

                Date         = (Get-Date)
                ComputerName = $computer
                Exception    = $e.Exception.Message
                Reason       = $e.CategoryInfo.Reason
                Target       = $e.CategoryInfo.TargetName
                Script       = $e.InvocationInfo.ScriptName
                Line         = $e.InvocationInfo.ScriptLineNumber
                Column       = $e.InvocationInfo.OffsetInLine

            }

            # output information. Post-process collected info, and log info (optional)
            Write-output -inputobject $info

        }

    }

}
