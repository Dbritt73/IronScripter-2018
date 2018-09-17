Function Get-FolderStats {
    [CmdletBinding()]
    Param (
        [String[]]$FolderPath
    )

    Begin {}

    Process {

        foreach ($Path in $FolderPath) {

            Try {

                $files = Get-ChildItem -Path $Path -Recurse -File | Measure-Object -Property Length -Sum
                $Folders = Get-ChildItem -Path $Path -Recurse -Directory | Measure-Object

                $ObjProps = [Ordered]@{

                    'TimeStamp' = (Get-Date);
                    'Size' = [Math]::Round(($files.Sum / 1MB));
                    'Files' = $files.Count;
                    'Folders' = $folders.Count

                }

                $Obj = New-Object -TypeName PSObject -Property $ObjProps
                $Obj.psobject.typenames.insert(0, 'Folder.Stats')
                Write-output -InputObject $Obj

            } Catch {}

        }

    }

    End {}

}


Function Remove-OldItems {
    [CmdletBinding()]
    Param (
        
        [string[]]$FolderPath,

        [int]$hours

    )

    Begin {}

    Process {}

    End {}

}