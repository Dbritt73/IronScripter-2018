Function Format-NetTCPConnectionState {
    [CmdletBinding()]
    param (
        [String[]]$state
    )

    Begin {}

    Process {

        Switch ($State) {

            0 {"Closed"}
            1 {"Listen"}
            2 {"SynSent"}
            3 {"SynReceived"}
            4 {"Established"}
            5 {"FinWait1"}
            6 {"FinWait2"}
            7 {"CloseWait"}
            8 {"Closing"}
            9 {"LastAck"}
            10 {"TimeWait"}
            11 {"DeleteTCB"}

        }

    }

    End {}
}