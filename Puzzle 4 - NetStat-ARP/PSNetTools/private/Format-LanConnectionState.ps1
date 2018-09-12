Function Format-LANConnectionState {
    [CmdletBinding()]
    param (
        [String[]]$state
        )

    Begin {}

    Process {

        Switch ($State) {

            0 {"Unreachable"}
            1 {"Incomplete"}
            2 {"Probe"}
            3 {"Delay"}
            4 {"Stale"}
            5 {"Reachable"}
            6 {"Permanent"}

        }

    }

    End {}
}