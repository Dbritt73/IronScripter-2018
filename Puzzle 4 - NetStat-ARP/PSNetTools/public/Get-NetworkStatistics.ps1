Function Get-NetworkStatistics {
  <#
    .SYNOPSIS
    Describe purpose of "Get-NetworkStatistics" in 1-2 sentences.

    .DESCRIPTION
    Add a more complete description of what the function does.

    .PARAMETER ComputerName
    Describe parameter -ComputerName.

    .EXAMPLE
    Get-NetworkStatistics -ComputerName Value
    Describe what this call does

    .NOTES
    Place additional notes here.

    .LINK
    URLs to related sites
    The first link is opened by Get-Help -Online Get-NetworkStatistics

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

                $TCP = Get-NetTCPStats -ComputerName $computer | Where-Object {($_.RemoteAddress -ne '0.0.0.0') -and ($_.RemoteAddress -notlike '::*')} 
                $UDP = Get-NetUDPStats -ComputerName $computer 

                $collection = [PSCustomObject]@()

                foreach ($connection in $TCP) {

                    $collection += [PSCustomObject]@{

                        'Protocol' = 'TCP'

                        'LocalAddress' = $connection.LocalAddress

                        'LocalPort' = $connection.LocalPort

                        'RemoteAddress' = $connection.RemoteAddress

                        #'RemoteAddress' = (Get-DNSHostName -IPAddress $Connection.RemoteAddress).Hostname;
                        'Remoteport' = $connection.Remoteport

                        'State' = $connection.State

                    }

                }

                Foreach ($connection in $UDP) {

                    $collection += [PSCustomObject]@{

                        'Protocol' = 'UDP'
                        
                        'LocalAddress' = $connection.LocalAddress

                        'LocalPort' = $connection.LocalPort

                        'RemoteAddress' = "$null"

                        'RemotePort' = "$null"

                        'State' = "$null"

                    }

                }

                $collection | ForEach-Object {

                    $_.psobject.typenames.insert(0,'NETSTAT.Object')

                }

                Write-Output -InputObject $collection


              # } Catch [System.Management.Automation.MethodInvocationException]  {

              #  Write-output $collection

              #  Return

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