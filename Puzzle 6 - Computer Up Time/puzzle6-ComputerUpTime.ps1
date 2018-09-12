Function Get-ComputerUpTime {
    [CmdletBinding()]
    Param (
        [String[]]$ComputerName
    )

    Begin {}

    Process {
        Foreach ($computer in $Computername) {
            Try {
                $WMI = @{
                    'ComputerName' = $computer;
                    'ClassName' = 'Win32_OperatingSystem';
                    'ErrorAction' = 'Stop'
                }

                $OS = Get-CimInstance @WMI

                $Uptime = (Get-Date) - $OS.LastBootUpTime

                [int]$days = $Uptime.Days

                $hoursPercent = $uptime.Hours / 24
                
                $hours = "{0:n3}" -f $hoursPercent

                Write-debug 'test'

                $output = "$Days" + '.' + "$hours"
                $output = $output.Split('.')
                $output = "$($output[0])" + '.' + "$($output[2])"
                Write-output $output

            } Catch {}
        }
    }

    End {}
}

#-----------------------------------------------------------------------------------------------------------------------

Function Get-ComputerTimeStats {
    [CmdletBinding()]
    Param (
        [string[]]$ComputerName
    )

    Begin {}
    
    Process {
        
        foreach ($computer in $computername) {

            Try {
                $Wmi = @{
                    'Computername' = $computer;
                    'Class' = 'win32_OperatingSystem';

                }

                $OS = Get-CimInstance @Wmi

                $ObjectProperties = @{
                    'ComputerName' = $OS.CSName;
                    'LastBootTime' = $OS.LastBootUpTime;
                    'Uptime' = Get-ComputerUpTime -ComputerName $computer
                }

                $Object = New-Object -TypeName PSObject -Property $ObjectProperties
                $Object.PSObject.TypeNames.Insert(0,'SystemUpTime')
                Write-Output $Object

            } Catch {
                $error[0]
            }
        }
    }

    End {}
}