Function Get-NetworkAddressResolution {
  <#
    .SYNOPSIS
    Describe purpose of "Get-NetworkAddressResolution" in 1-2 sentences.

    .DESCRIPTION
    Add a more complete description of what the function does.

    .PARAMETER ComputerName
    Describe parameter -ComputerName.

    .EXAMPLE
    Get-NetworkAddressResolution -ComputerName Value
    Describe what this call does

    .NOTES
    Place additional notes here.

    .LINK
    URLs to related sites
    The first link is opened by Get-Help -Online Get-NetworkAddressResolution

    .INPUTS
    List of input types that are accepted by this function.

    .OUTPUTS
    List of output types produced by this function.
  #>


    [CmdletBinding()]
    Param(

        [string[]]$ComputerName
        
    )

    Begin {}

    Process {

        Foreach ($computer in $ComputerName) {

            Try {

                $wmi = @{

                    'NameSpace' = 'Root\StandardCimV2'

                    'ClassName' = 'MSFT_NetNeighbor'

                    'ComputerName' = $computer

                    'ErrorAction' = 'Stop'

                }

                $NetNeighbor = Get-CimInstance @wmi
                Foreach ($Connection in $NetNeighbor){

                    $ARPprops = @{

                        'Interface' = $Connection.interfacealias

                        'IPAddress' = $Connection.IPAddress

                        'PhysicalAddress' = $Connection.LinkLayerAddress

                        'State' = Format-LANConnectionState -state $Connection.State

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
                $info

            }

        }

    }

    End {}

}
