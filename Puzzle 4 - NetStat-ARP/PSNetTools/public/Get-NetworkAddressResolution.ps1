Function Get-NetworkAddressResolution {
    [CmdletBinding()]
    Param(
        [string[]]$ComputerName
    )

    Begin {}

    Process {

        Foreach ($computer in $ComputerName) {

            Try {

                $wmi = @{

                    'NameSpace' = 'Root\StandardCimV2';
                    'ClassName' = 'MSFT_NetNeighbor';
                    'ComputerName' = $computer;
                    'ErrorAction' = 'Stop'

                }
                $NetNeighbor = Get-CimInstance @wmi
                Foreach ($Connection in $NetNeighbor){

                    $ARPprops = @{

                        'Interface' = $Connection.interfacealias;
                        'IPAddress' = $Connection.IPAddress;
                        'PhysicalAddress' = $Connection.LinkLayerAddress;
                        'State' = Format-LANConnectionState -state $Connection.State

                    }

                    $ArpObj = New-Object -TypeName PSObject -Property $ARPprops
                    $ArpObj.psobject.TypeNames.insert(0,"Arp.Object")
                    Write-Output $ArpObj

                }

            } Catch {}

        }

    }

    End {}
