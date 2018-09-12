Function Get-NetworkStatistics {
    [CmdletBinding()]
    Param(
        [string[]]$ComputerName
    )

    Begin {}

    Process {

        Foreach ($computer in $ComputerName) {

            Try {

                $TCP = Get-NetTCPStats -ComputerName $computer | Where-Object {($_.RemoteAddress -ne '0.0.0.0') -and ($_.RemoteAddress -notlike '::*')} 
                $UDP = Get-NetUDPStats -ComputerName $computer 

                $collection = [PSCustomObject]@()

                foreach ($connection in $TCP) {

                    $collection += [PSCustomObject]@{

                        'Protocol' = 'TCP';
                        'LocalAddress' = $connection.LocalAddress;
                        'LocalPort' = $connection.LocalPort;
                        'RemoteAddress' = $connection.RemoteAddress;
                        #'RemoteAddress' = (Get-DNSHostName -IPAddress $Connection.RemoteAddress).Hostname;
                        'Remoteport' = $connection.Remoteport;
                        'State' = $connection.State

                    }

                }

                Foreach ($connection in $UDP) {

                    $collection += [PSCustomObject]@{

                        'Protocol' = 'UDP'
                        'LocalAddress' = $connection.LocalAddress;
                        'LocalPort' = $connection.LocalPort;
                        'RemoteAddress' = "$null";
                        'RemotePort' = "$null";
                        'State' = "$null"

                    }

                }

                $collection | ForEach-Object {

                    $_.psobject.typenames.insert(0,'NETSTAT.Object')

                }

                Write-Output $collection


           # } Catch [System.Management.Automation.MethodInvocationException]  {

              #  Write-output $collection

              #  Return

            } Catch {

                #Write-Output "$($Error[0])"
                Write-output "$($error[0].exception.GetType().Fullname)"

            }

        }

    }

    End {}

}