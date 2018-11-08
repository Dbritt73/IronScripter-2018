Function Test-FileLock {
    #https://stackoverflow.com/questions/24992681/powershell-check-if-a-file-is-locked
    [CmdletBinding()]
    Param (
        
    [parameter(Mandatory=$true)]
    [String[]]$Path

    )

    Begin {}

    Process {

        foreach ($item in $Path) {

            Try {
                
                $File = New-Object System.IO.FileInfo $item
                
                if ((Test-Path -Path $Path) -eq $false) {

                    #Write-Output $false

                    $Props = @{

                        'Path' = $Item;
                        'Locked' = 'NA'

                    }

                    $Object = New-Object -TypeName psobject -Property $props
                    $Object.PSObject.TypeNames.Insert(0,'Report.FileLock')
                    Write-Output -InputObject $Object
              
                  } Else {

                    $Stream = $File.Open([System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
  
                    if ($Stream) {
              
                      $Stream.Close()
              
                    }
              
                    #Write-Output $false
                    $Props = @{

                        'Path' = $Item;
                        'Locked' = 'False'

                    }

                    $Object = New-Object -TypeName psobject -Property $props
                    $Object.PSObject.TypeNames.Insert(0,'Report.FileLock')
                    Write-Output -InputObject $Object

                  }

            } Catch {

                # file is locked by a process.
                Write-Output $True

            }

        }

    }

    End {}

}