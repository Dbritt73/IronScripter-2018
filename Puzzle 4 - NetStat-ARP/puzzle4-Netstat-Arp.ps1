
Function Format-NetTCPConnectionState {
    [CmdletBinding()]
    param (

        [String[]]$state

    )

    Begin {}

    Process {

        Switch ($State) {

            0  {'Closed'}
            1  {'Listen'}
            2  {'SynSent'}
            3  {'SynReceived'}
            4  {'Established'}
            5  {'FinWait1'}
            6  {'FinWait2'}
            7  {'CloseWait'}
            8  {'Closing'}
            9  {'LastAck'}
            10 {'TimeWait'}
            11 {'DeleteTCB'}

        }

    }

    End {}

}


function Get-DNSHostName {
    [CmdletBinding()]
    Param (

        [String[]]$IPAddress

    )

    Begin {}

    Process {

        Foreach ($ip in $ipaddress) {

            Try {

                #$hostname = [system.net.dns]::GetHostEntry("$ip").Hostname
                $hostname = [System.net.dns]::Resolve($ip).Hostname

                    $DNSHostProps = @{

                        'IPAddress' = $ip
                        'Hostname'  = $Hostname

                    }

                $DNSHostObj = New-Object -TypeName psobject -Property $DNSHostProps
                $DNSHostObj.PSObject.TypeNames.Insert(0,'DNSHost.Object')
                Write-Output -InputObject $DNSHostObj

            } Catch {

                $DNSHostProps = @{

                    'IPAddress' = $ip
                    'Hostname'  = $ip

                }

                $DNSHostObj = New-Object -TypeName psobject -Property $DNSHostProps
                $DNSHostObj.PSObject.TypeNames.Insert(0,'DNSHost.Object')
                Write-Output -InputObject $DNSHostObj

            }

        }

    }

    End {}

}


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

                    'NameSpace'    = 'root\StandardCIMv2'
                    'ClassName'    = 'MSFT_NetTCPConnection'
                    #'CIMSession'  = "$CimSession"
                    'ComputerName' = $computer
                    'ErrorAction'  = 'Stop'

                }

                $TCPstat = Get-CimInstance @wmi

                foreach ($stat in $TCPstat) {

                    $TCPstatProps = @{

                        'LocalAddress'  = $stat.LocalAddress
                        'LocalPort'     = $stat.LocalPort
                        'RemotePort'    = $stat.RemotePort
                        'RemoteAddress' = (Get-DNSHostName -IPAddress $stat.RemoteAddress).Hostname
                        'State'         = Format-NetTCPConnectionState -State $stat.State

                    }

                    $TCPstatObj = New-Object -TypeName psobject -Property $TCPstatProps
                    $TCPstatObj.PSObject.TypeNames.Insert(0,'NetTCPStat.Object')
                    Write-Output -InputObject $TCPstatObj

                }

            } Catch {

                # get error record
                [Management.Automation.ErrorRecord]$e = $_

                # retrieve information about runtime error
                $info = [PSCustomObject]@{

                    Exception = $e.Exception.Message
                    Reason    = $e.CategoryInfo.Reason
                    Target    = $e.CategoryInfo.TargetName
                    Script    = $e.InvocationInfo.ScriptName
                    Line      = $e.InvocationInfo.ScriptLineNumber
                    Column    = $e.InvocationInfo.OffsetInLine

                }

                # output information. Post-process collected info, and log info (optional)
                Write-Output -InputObject $info

            }

        }

    }

    End {}

}


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

                    'NameSpace'    = 'root\StandardCIMv2'
                    'ClassName'    = 'MSFT_NetUDPEndpoint'
                    #'CIMSession'  = "$CimSession"
                    'ComputerName' = $computer
                    'ErrorAction'  = 'Stop'

                }

                $UDPstat = Get-CimInstance @wmi

                foreach ($stat in $UDPstat) {

                    $UDPstatProps = @{

                        'LocalAddress' = $stat.LocalAddress
                        'LocalPort'    = $stat.LocalPort
                        #'RemotePort' = ""
                        #'RemoteAddress' = ""
                        #'State' = ""
                    }

                    $UDPstatObj = New-Object -TypeName psobject -Property $UDPstatProps
                    $UDPstatObj.PSObject.TypeNames.Insert(0,'NetUDPStat.Object')
                    Write-Output -InputObject $UDPstatObj

                }

            } Catch {

                # get error record
                [Management.Automation.ErrorRecord]$e = $_

                # retrieve information about runtime error
                $info = [PSCustomObject]@{

                    Exception = $e.Exception.Message
                    Reason    = $e.CategoryInfo.Reason
                    Target    = $e.CategoryInfo.TargetName
                    Script    = $e.InvocationInfo.ScriptName
                    Line      = $e.InvocationInfo.ScriptLineNumber
                    Column    = $e.InvocationInfo.OffsetInLine

                }

                # output information. Post-process collected info, and log info (optional)
                Write-Output -InputObject $info

            }

        }

    }

    End {}

}


Function Get-NetworkStatistics {
    [CmdletBinding()]
    Param(

        [string[]]$ComputerName

    )

    Begin {}

    Process {

        Foreach ($computer in $ComputerName) {

            Try {

                $TCP = Get-NetTCPStats -ComputerName $computer |
                    Where-Object {($_.RemoteAddress -ne '0.0.0.0') -and ($_.RemoteAddress -notlike '::*')}

                $UDP = Get-NetUDPStats -ComputerName $computer

                $collection = [PSCustomObject]@()

                foreach ($connection in $TCP) {

                    $collection += [PSCustomObject]@{

                        'Protocol'      = 'TCP'
                        'LocalAddress'  = $connection.LocalAddress
                        'LocalPort'     = $connection.LocalPort
                        'RemoteAddress' = $connection.RemoteAddress
                        #'RemoteAddress' = (Get-DNSHostName -IPAddress $Connection.RemoteAddress).Hostname
                        'Remoteport'    = $connection.Remoteport
                        'State'         = $connection.State

                    }

                }

                Foreach ($connection in $UDP) {

                    $collection += [PSCustomObject]@{

                        'Protocol'      = 'UDP'
                        'LocalAddress'  = $connection.LocalAddress
                        'LocalPort'     = $connection.LocalPort
                        'RemoteAddress' = "$null"
                        'RemotePort'    = "$null"
                        'State'         = "$null"

                    }

                }

                $collection | ForEach-Object {

                    $_.psobject.typenames.insert(0,'NETSTAT.Object')

                }

                Write-Output -InputObject $collection

            } Catch {

                # get error record
                [Management.Automation.ErrorRecord]$e = $_

                # retrieve information about runtime error
                $info = [PSCustomObject]@{

                    Exception = $e.Exception.Message
                    Reason    = $e.CategoryInfo.Reason
                    Target    = $e.CategoryInfo.TargetName
                    Script    = $e.InvocationInfo.ScriptName
                    Line      = $e.InvocationInfo.ScriptLineNumber
                    Column    = $e.InvocationInfo.OffsetInLine

                }

                # output information. Post-process collected info, and log info (optional)
                Write-Output -InputObject $info

            }

        }

    }

    End {}

}


Function Format-LANConnectionState {
    [CmdletBinding()]
    param (

        [String[]]$state

    )

    Begin {}

    Process {

        Switch ($State) {

            0 {'Unreachable'}
            1 {'Incomplete'}
            2 {'Probe'}
            3 {'Delay'}
            4 {'Stale'}
            5 {'Reachable'}
            6 {'Permanent'}

        }

    }

    End {}

}


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

                    'NameSpace'    = 'Root\StandardCimV2'
                    'ClassName'    = 'MSFT_NetNeighbor'
                    'ComputerName' = $computer
                    'ErrorAction'  = 'Stop'

                }

                $NetNeighbor = Get-CimInstance @wmi

                Foreach ($Connection in $NetNeighbor){

                    $ARPprops = @{

                        'Interface'       = $Connection.interfacealias
                        'IPAddress'       = $Connection.IPAddress
                        'PhysicalAddress' = $Connection.LinkLayerAddress
                        'State'           = Format-LANConnectionState -state $Connection.State

                    }

                    $ArpObj = New-Object -TypeName PSObject -Property $ARPprops
                    $ArpObj.psobject.TypeNames.insert(0,'Arp.Object')
                    Write-Output -InputObject $ArpObj

                }

            } Catch {

                # get error record
                [Management.Automation.ErrorRecord]$e = $_

                # retrieve information about runtime error
                $info = [PSCustomObject]@{

                    Exception = $e.Exception.Message
                    Reason    = $e.CategoryInfo.Reason
                    Target    = $e.CategoryInfo.TargetName
                    Script    = $e.InvocationInfo.ScriptName
                    Line      = $e.InvocationInfo.ScriptLineNumber
                    Column    = $e.InvocationInfo.OffsetInLine

                }

                # output information. Post-process collected info, and log info (optional)
                Write-Output -InputObject $info

            }

        }

    }

    End {}

}