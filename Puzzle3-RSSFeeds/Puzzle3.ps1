Function Get-RSSFeedList {
    [CmdletBinding()]
    Param (
        [Parameter( ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName =$true)]
        [String[]]$URL
    )

    Begin {

        $index = 1

    }

    Process {

        Foreach ($link in $url) {

            Try {

                $feed = Invoke-RestMethod -Uri $link

                foreach ($post in $feed) {

                    $postprops = [ordered]@{

                        'Index' =$index;
                        'Title' = $post.title;
                        'Date' = [DateTime]$post.pubdate;
                        'Author' = $post.creator.'#cdata-section';
                        'Link' = $post.Link

                    }

                    $index++

                    $ListObject = New-Object -TypeName psobject -Property $postprops
                    $ListObject.PSObject.TypeNames.Insert(0,'FeedList.Object')
                    Write-Output $ListObject

                }

            } Catch {}

        }

    }

    End{}

}


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
    word-wrap borrwoed from: https://stackoverflow.com/questions/1059663/is-there-a-way-to-wordwrap-results-of-a-powershell-cmdlet
    #>

    [CmdletBinding()]
    Param(
        [parameter( Mandatory=1,
                    ValueFromPipeline=1,
                    ValueFromPipelineByPropertyName=1)]
        [Object[]]$chunk
    )

    Begin {}

    Process {

        $Lines = @()

        foreach ($line in $chunk) {

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


Function Get-WebArticle {
    [CmdletBinding()]
    Param(

        [String]$LinkPost

    )

    Add-Type -path "$PSScriptroot\Net45\HtmlAgilityPack.dll"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $content = (Invoke-WebRequest -Uri $LinkPost).content
    
    $html = New-Object HtmlAgilityPack.HtmlDocument
    
    $html.LoadHtml($content)
    
    $output = (($html.DocumentNode.Descendants('p').innertext)) | Format-StringWrap
    $output.Replace("&#8220;","").replace("&#8221;","").replace("&#8217;","'") | more


}


Function Get-Feed {
    <#
    .SYNOPSIS
    Short description
    
    .DESCRIPTION
    Long description
    
    .PARAMETER FeedLink
    Parameter description
    
    .EXAMPLE
    An example
    
    .NOTES
    General notes
    #>

    [CmdletBinding()]
    Param (
        [Parameter( ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName =$true)]
        [string[]]$FeedLink #= 'https://powershell.org/feed'

    )

    Begin {}

    Process {

        $FeedPosts = $feedlink | Get-RSSFeedList

        $FeedPosts | Format-Table | Out-string | Write-Host
        $Selected = Read-Host -Prompt "What post would you like to read? Add 'C' to view in console"

        if (($Selected -like "*C") -or ($Selected -like "*c")) {

            $Selected = $Selected.TrimEnd('c')
            $SelectedPost = $FeedPosts | Where-Object {$_.index -eq $Selected} 
            $LinkPost = $SelectedPost | Select-Object -ExpandProperty 'link'

            $SelectedPost
            Get-WebArticle -LinkPost $LinkPost

        } else {

            Start-Process ($FeedPosts | Where-Object {$_.index -eq $Selected} | Select-Object -ExpandProperty 'link')

        }
        

    }

    End {}

}