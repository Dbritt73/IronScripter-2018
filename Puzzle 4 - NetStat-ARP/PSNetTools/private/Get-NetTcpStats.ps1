Function Get-NetTCPStats {
    [CmdletBinding()]
    Param (
        [String[]]$ComputerName
    )

    Begin {}

    Process {

        Foreach ($computer in $ComputerName) {

            Try {
                #$CimSession = New-CimSession -ComputerName $computer -ErrorAction 'Stop'
                #Get-CimInstance -Namespace root\StandardCimV2 -ClassName MSFT_NetTCPConnection
                $wmi = @{

                    'NameSpace' = 'root\StandardCIMv2';
                    'ClassName' = 'MSFT_NetTCPConnection';
                    #'CIMSession' = "$CimSession";
                    'ComputerName' = $computer;
                    'ErrorAction' = 'Stop';
                    #'DebugPreference' = 'SilentlyContinue'

                }

                $TCPstat = Get-CimInstance @wmi

                foreach ($stat in $TCPstat) {

                    $TCPstatProps = @{

                        'LocalAddress' = $stat.LocalAddress;
                        'LocalPort' = $stat.LocalPort;
                        'RemotePort' = $stat.RemotePort;
                        #'RemoteAddress' = $stat.RemoteAddress;
                        'RemoteAddress' = (Get-DNSHostName -IPAddress $stat.RemoteAddress).Hostname;
                        'State' = Format-NetTCPConnectionState -State $stat.State

                    }

                    $TCPstatObj = New-Object -TypeName psobject -Property $TCPstatProps
                    $TCPstatObj.PSObject.TypeNames.Insert(0,'NetTCPStat.Object')
                    Write-Output $TCPstatObj

                }
             #   Write-Debug "Test TCPStatObj"

            } Catch {

                Write-Output "$($Error[0])"
            }

        }

    }

    End {}

}