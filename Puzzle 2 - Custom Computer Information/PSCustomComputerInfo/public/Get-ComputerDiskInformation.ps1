Function Get-ComputerDiskInformation {
    <#
    .SYNOPSIS
    Gets Logical Disk infromation from a Windows computer.

    .DESCRIPTION
    Get-ComputerDiskInformation utilizes the Common Information Model (CIM) to query the win32_logicaldisk instance for
    information on the logical disks mounted in Windows. The cmdlet can be run locally or against one or more remote
    endpoints.

    .EXAMPLE
    Get-ComputerDiskInformation -ComputerName 'SERVER1'

    .EXAMPLE
    'Server1' | Get-ComputerDiskInformation

    .EXAMPLE
    (Get-Content .\computers.txt) | Get-ComputerDiskInformation

    .NOTES
    Compatable with PowerShell 6.0
    Part of my solution to the Iron Scripter 2018 prequel puzzle 2 released January 21, 2018
    #>

    [CmdletBinding()]
    Param (
        [Parameter( ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName = $true)]
        [String[]]$ComputerName = 'localhost'
    )

    Begin {}

    Process {

        Foreach ($computer in $ComputerName) {

            Try {

                $WMI = @{

                    'ComputerName' = $computer
                    'Class'        = 'Win32_LogicalDisk'
                    'ErrorAction'  = 'Stop'

                }

                $Disks = Get-CimInstance @WMI

                Foreach ($disk in $disks ) {

                    $DiskProps = @{

                        'Drive'       = $Disk.DeviceID
                        'DriveType'   = $disk.Description
                        'Size'        = $disk.size
                        'FreeSpace'   = $Disk.FreeSpace
                        'Compressed'  = $disk.Compressed
                        'PercentUsed' = ((($disk.Size - $disk.FreeSpace) / $disk.size) * 100)

                    }

                    Write-Debug -Message 'Test DiskProps'

                    $DiskObject = New-Object -TypeName PSObject -Property $DiskProps
                    $DiskObject.PSObject.TypeNames.Insert(0,'Custom.DiskInformation')
                    Write-Output -InputObject $DiskObject

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
                Write-Output -InputObject $info

            }

        }

    }

    End {}

}