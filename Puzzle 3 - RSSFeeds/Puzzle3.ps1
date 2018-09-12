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
    Get-Feed reads a RSS feed and prompts console user whioch article they want to read, either in console or the default web browser

    .DESCRIPTION
    Get-Feed utilizes the included Get-RSSFeedList to present the host with an indexed list of the most resent posts in
    the feed. The user then has the option to select the index number of the post they want to read, if they appened the
    letter 'C' to the index then the post will be written to the console. If only the number was provided, Get-Feed will
    launch the default browser and navigate to the posts web address.

    .PARAMETER FeedLink
    The link to the RSS feed for the site you want to scrape

    .EXAMPLE
    Get-Feed -FeedLink 'https://plaentpowershell.com/feed'

    .NOTES
    *Solution to Puzzle 3 of the Iron Scripter 2018 challenge
    *Works with PowerShell Core on Windows
    *First time using the HTMLAgilityPack
        *For getting parsed html results and be compatible with PowerShell Core.

    .LINK
    http://html-agility-pack.net/

    #>

    [CmdletBinding()]
    Param (

        [Parameter( ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName =$true)]
        [string[]]$FeedLink

    )

    Begin {}

    Process {

        $FeedPosts = $feedlink | Get-RSSFeedList

        $FeedPosts | Format-Table | Out-string | Write-Host
        $Selected = Read-Host -Prompt "What post would you like to read? Add 'C' to view in console"

        if (($Selected -clike '*C') -or ($Selected -clike '*c') ) {

            if ($Selected -clike '*C') {

                $Selected = $Selected.TrimEnd('C')

            } elseif ($Selected -clike '*c') {

                $Selected = $Selected.TrimEnd('c')

            }

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

