Function Test-FileLock {
  <#
    .SYNOPSIS
    Describe purpose of "Test-FileLock" in 1-2 sentences.

    .DESCRIPTION
    Add a more complete description of what the function does.

    .PARAMETER Path
    Describe parameter -Path.

    .EXAMPLE
    Test-FileLock -Path Value
    Describe what this call does

    .NOTES
    Place additional notes here.

    .LINK
    URLs to related sites
    https://stackoverflow.com/questions/24992681/powershell-check-if-a-file-is-locked

    .INPUTS
    List of input types that are accepted by this function.

    .OUTPUTS
    List of output types produced by this function.
  #>

    [CmdletBinding()]
    Param (

        [parameter( Mandatory = $true,
                    HelpMessage = 'Add help message for user',
                    ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName = $true)]
        [String[]]$Path

    )

    Begin {}

    Process {

        foreach ($item in $Path) {

            Try {

                $File = New-Object -TypeName System.IO.FileInfo -ArgumentList $item

                if ((Test-Path -Path $Path) -eq $false) {

                    $Props = @{

                        'Path'   = $Item
                        'Locked' = 'NA'

                    }

                    $Object = New-Object -TypeName psobject -Property $props
                    $Object.PSObject.TypeNames.Insert(0,'Report.FileLock')
                    Write-Output -InputObject $Object

                  } Else {

                    $Stream = $File.Open([System.IO.FileMode]::Open,
                                [System.IO.FileAccess]::ReadWrite,
                                    [System.IO.FileShare]::None)

                    if ($Stream) {

                        $Stream.Close()

                    }

                    $Props = @{

                        'Path'   = $Item
                        'Locked' = $False

                    }

                    $Object = New-Object -TypeName psobject -Property $props
                    $Object.PSObject.TypeNames.Insert(0,'Report.FileLock')
                    Write-Output -InputObject $Object

                }

            } Catch {

                # file is locked by a process.
                $Props = @{

                    'Path'   = $Item
                    'Locked' = $True

                }

                $Object = New-Object -TypeName psobject -Property $props
                $Object.PSObject.TypeNames.Insert(0,'Report.FileLock')
                Write-Output -InputObject $Object

            }

        }

    }

    End {}

}