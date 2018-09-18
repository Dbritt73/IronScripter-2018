Function Get-NetTCPStats {
  <#
    .SYNOPSIS
    Describe purpose of "Get-NetTCPStats" in 1-2 sentences.

    .DESCRIPTION
    Add a more complete description of what the function does.

    .PARAMETER ComputerName
    Describe parameter -ComputerName.

    .EXAMPLE
    Get-NetTCPStats -ComputerName Value
    Describe what this call does

    .NOTES
    Place additional notes here.

    .LINK
    URLs to related sites
    The first link is opened by Get-Help -Online Get-NetTCPStats

    .INPUTS
    List of input types that are accepted by this function.

    .OUTPUTS
    List of output types produced by this function.
  #>


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

                    'NameSpace' = 'root\StandardCIMv2'

                    'ClassName' = 'MSFT_NetTCPConnection'

                    #'CIMSession' = "$CimSession";
                    'ComputerName' = $computer

                    'ErrorAction' = 'Stop'

                    #'DebugPreference' = 'SilentlyContinue'

                }

                $TCPstat = Get-CimInstance @wmi

                foreach ($stat in $TCPstat) {

                    $TCPstatProps = @{

                        'LocalAddress' = $stat.LocalAddress

                        'LocalPort' = $stat.LocalPort

                        'RemotePort' = $stat.RemotePort

                        #'RemoteAddress' = $stat.RemoteAddress;
                        'RemoteAddress' = (Get-DNSHostName -IPAddress $stat.RemoteAddress).Hostname

                        'State' = Format-NetTCPConnectionState -State $stat.State

                    }

                    $TCPstatObj = New-Object -TypeName psobject -Property $TCPstatProps
                    $TCPstatObj.PSObject.TypeNames.Insert(0,'NetTCPStat.Object')
                    Write-Output -InputObject $TCPstatObj

                }
              #   Write-Debug "Test TCPStatObj"

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
                $info
                
            }

        }

    }

    End {}

}