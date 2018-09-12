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

                        'IPAddress' = $ip;
                        'Hostname' = $Hostname

                    }

                    $DNSHostObj = New-Object -TypeName psobject -Property $DNSHostProps
                    $DNSHostObj.PSObject.TypeNames.Insert(0,'DNSHost.Object')
                    Write-Output $DNSHostObj
                
            } Catch {

                $DNSHostProps = @{

                    'IPAddress' = $ip;
                    'Hostname' = $ip

                }

                $DNSHostObj = New-Object -TypeName psobject -Property $DNSHostProps
                $DNSHostObj.PSObject.TypeNames.Insert(0,'DNSHost.Object')
                Write-Output $DNSHostObj

            }

        }

    }

    End {}
    
}