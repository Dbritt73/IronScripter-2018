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
    Get-Feed -FeedLink 'https://powershell.org/feed'

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

        [Parameter( Mandatory=$True,
                    HelpMessage='Add help message for user',
                    ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName =$true)]
        [string[]]$FeedLink

    )

    Begin {}

    Process {

        Try {

            $FeedPosts = $feedlink | Get-RSSFeedList

            $FeedPosts | Format-Table | Out-string | Write-Host
            $Selected = Read-Host -Prompt "What post would you like to read? Add 'C' to view in console"
    
            if ( ($Selected -clike '*C') -or ($Selected -clike '*c') ) {
    
                if ($Selected -clike '*C') {
    
                    $Selected = $Selected.TrimEnd('C')
    
                } elseif ($Selected -clike '*c') {
    
                    $Selected = $Selected.TrimEnd('c')
    
                }
    
                $SelectedPost = $FeedPosts | Where-Object {$_.index -eq $Selected} -ErrorAction 'stop'
                $LinkPost = $SelectedPost | Select-Object -ExpandProperty 'link'
    
                $SelectedPost
                Get-WebArticle -LinkPost $LinkPost
    
            } else {
    
                Start-Process -FilePath ($FeedPosts | Where-Object {$_.index -eq $Selected} | Select-Object -ExpandProperty 'link')
    
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
            $info
            
        }

    }

    End {}

}