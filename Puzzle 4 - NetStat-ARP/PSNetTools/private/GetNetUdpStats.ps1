Function Get-NetUDPStats {
  <#
    .SYNOPSIS
    Describe purpose of "Get-NetUDPStats" in 1-2 sentences.

    .DESCRIPTION
    Add a more complete description of what the function does.

    .PARAMETER ComputerName
    Describe parameter -ComputerName.

    .EXAMPLE
    Get-NetUDPStats -ComputerName Value
    Describe what this call does

    .NOTES
    Place additional notes here.

    .LINK
    URLs to related sites
    The first link is opened by Get-Help -Online Get-NetUDPStats

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

                    'ClassName' = 'MSFT_NetUDPEndpoint'

                    #'CIMSession' = "$CimSession";
                    'ComputerName' = $computer

                    'ErrorAction' = 'Stop'
                    #'DebugPreference' = 'SilentlyContinue'
                }

                $UDPstat = Get-CimInstance @wmi

                foreach ($stat in $UDPstat) {

                    $UDPstatProps = @{

                        'LocalAddress' = $stat.LocalAddress

                        'LocalPort' = $stat.LocalPort

                        #'RemotePort' = "";
                        #'RemoteAddress' = "";
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
                $info
                
            }

        }

    }

    End {}

}