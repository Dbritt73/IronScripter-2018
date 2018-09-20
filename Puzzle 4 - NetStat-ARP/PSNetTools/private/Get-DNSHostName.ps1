function Get-DNSHostName {
  <#
    .SYNOPSIS
    Describe purpose of "Get-DNSHostName" in 1-2 sentences.

    .DESCRIPTION
    Add a more complete description of what the function does.

    .PARAMETER IPAddress
    Describe parameter -IPAddress.

    .EXAMPLE
    Get-DNSHostName -IPAddress Value
    Describe what this call does

    .NOTES
    Place additional notes here.

    .LINK
    URLs to related sites
    The first link is opened by Get-Help -Online Get-DNSHostName

    .INPUTS
    List of input types that are accepted by this function.

    .OUTPUTS
    List of output types produced by this function.
  #>


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

                        'Hostname' = $Hostname

                    }

                    $DNSHostObj = New-Object -TypeName psobject -Property $DNSHostProps
                    $DNSHostObj.PSObject.TypeNames.Insert(0,'DNSHost.Object')
                    Write-Output -InputObject $DNSHostObj
                
            } Catch {

                $DNSHostProps = @{

                    'IPAddress' = $ip

                    'Hostname' = $ip

                }

                $DNSHostObj = New-Object -TypeName psobject -Property $DNSHostProps
                $DNSHostObj.PSObject.TypeNames.Insert(0,'DNSHost.Object')
                Write-Output -InputObject $DNSHostObj

            }

        }

    }

    End {}
    
}