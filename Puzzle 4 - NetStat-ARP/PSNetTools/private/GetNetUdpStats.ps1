Function Get-NetUDPStats {
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
                    'ClassName' = 'MSFT_NetUDPEndpoint';
                    #'CIMSession' = "$CimSession";
                    'ComputerName' = $computer;
                    'ErrorAction' = 'Stop'
                    #'DebugPreference' = 'SilentlyContinue'
                }

                $UDPstat = Get-CimInstance @wmi
              #  Write-Debug "UDPStat"
                foreach ($stat in $UDPstat) {

                    $UDPstatProps = @{

                        'LocalAddress' = $stat.LocalAddress;
                        'LocalPort' = $stat.LocalPort;
                        #'RemotePort' = "";
                        #'RemoteAddress' = "";
                        #'State' = ""
                    }

                    $UDPstatObj = New-Object -TypeName psobject -Property $UDPstatProps
                    $UDPstatObj.PSObject.TypeNames.Insert(0,'NetUDPStat.Object')
                    Write-Output $UDPstatObj
                   # Write-Debug "Test UDPStatObj"

                }

               # Write-Debug "Test UDPStatObj"

            } Catch {

                Write-Output "$($Error[0])"

            }

        }

    }

    End {}

}