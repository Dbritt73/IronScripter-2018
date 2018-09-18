Function Format-LANConnectionState {
  <#
    .SYNOPSIS
    Describe purpose of "Format-LANConnectionState" in 1-2 sentences.

    .DESCRIPTION
    Add a more complete description of what the function does.

    .PARAMETER state
    Describe parameter -state.

    .EXAMPLE
    Format-LANConnectionState -state Value
    Describe what this call does

    .NOTES
    Place additional notes here.

    .LINK
    URLs to related sites
    The first link is opened by Get-Help -Online Format-LANConnectionState

    .INPUTS
    List of input types that are accepted by this function.

    .OUTPUTS
    List of output types produced by this function.
  #>


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