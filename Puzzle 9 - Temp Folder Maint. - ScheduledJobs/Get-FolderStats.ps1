Function Get-FolderStats {
  <#
      .SYNOPSIS
      Describe purpose of "Get-FolderStats" in 1-2 sentences.

      .DESCRIPTION
      Add a more complete description of what the function does.

      .PARAMETER FolderPath
      Describe parameter -FolderPath.

      .EXAMPLE
      Get-FolderStats -FolderPath Value
      Describe what this call does

      .NOTES
      Place additional notes here.

      .LINK
      URLs to related sites
      The first link is opened by Get-Help -Online Get-FolderStats

      .INPUTS
      List of input types that are accepted by this function.

      .OUTPUTS
      List of output types produced by this function.
  #>


    [CmdletBinding()]
    Param (
        [String[]]$FolderPath
    )

    Begin {
  
        $ErrorActionPreference = 'Stop'
  
    }

    Process {

        foreach ($Path in $FolderPath) {

            Try {

                $files = Get-ChildItem -Path $Path -Recurse -File | Measure-Object -Property Length -Sum
                $Folders = Get-ChildItem -Path $Path -Recurse -Directory | Measure-Object

                $ObjProps = [Ordered]@{

                    'TimeStamp' = (Get-Date)

                    'Path' = $Path

                    'Size' = [Math]::Round(($files.Sum / 1MB))

                    'Files' = $files.Count

                    'Folders' = $folders.Count

                }

                $Obj = New-Object -TypeName PSObject -Property $ObjProps
                $Obj.psobject.typenames.insert(0, 'Folder.Stats')
                Write-output -InputObject $Obj

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