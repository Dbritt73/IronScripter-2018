Function Format-NetTCPConnectionState {
  <#
    .SYNOPSIS
    Describe purpose of "Format-NetTCPConnectionState" in 1-2 sentences.

    .DESCRIPTION
    Add a more complete description of what the function does.

    .PARAMETER state
    Describe parameter -state.

    .EXAMPLE
    Format-NetTCPConnectionState -state Value
    Describe what this call does

    .NOTES
    Place additional notes here.

    .LINK
    URLs to related sites
    The first link is opened by Get-Help -Online Format-NetTCPConnectionState

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

            0 {'Closed'}
            1 {'Listen'}
            2 {'SynSent'}
            3 {'SynReceived'}
            4 {'Established'}
            5 {'FinWait1'}
            6 {'FinWait2'}
            7 {'CloseWait'}
            8 {'Closing'}
            9 {'LastAck'}
            10 {'TimeWait'}
            11 {'DeleteTCB'}

        }

    }

    End {}
}