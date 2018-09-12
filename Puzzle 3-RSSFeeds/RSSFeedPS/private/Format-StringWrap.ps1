Function Format-StringWrap {
    <#

    .SYNOPSIS
    wraps a string or an array of strings at the console width without breaking within a word

    .PARAMETER chunk
    a string or an array of strings

    .EXAMPLE
    word-wrap -chunk $string

    .EXAMPLE
    $string | word-wrap

    .Notes
    Used to parse long strings without breaking a word in the middle when writing to console

    .Link
    https://stackoverflow.com/questions/1059663/is-there-a-way-to-wordwrap-results-of-a-powershell-cmdlet

    #>

    [CmdletBinding()]
    Param(
        [parameter( Mandatory=1,
                    ValueFromPipeline=1,
                    ValueFromPipelineByPropertyName=1)]
        [Object[]]$text
    )

    Begin {}

    Process {

        $Lines = @()

        foreach ($line in $text) {

            $str = ''
            $counter = 0

            $line -split '\s' | Foreach-object {

                $counter += $_.Length + 1

                if ($counter -gt $Host.UI.RawUI.BufferSize.Width) {

                    $Lines += ,$str.trim()
                    $str =  ''
                    $counter = $_.Length + 1

                }

                $str = "$str$_ "

            }

            $Lines += ,$str.trim()

        }

        $Lines.replace('.  ',".`n")

    }

    End {}

}