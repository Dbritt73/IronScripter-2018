Function Get-RSSFeedList {
  <#
    .SYNOPSIS
    Describe purpose of "Get-RSSFeedList" in 1-2 sentences.

    .DESCRIPTION
    Add a more complete description of what the function does.

    .PARAMETER URL
    Describe parameter -URL.

    .EXAMPLE
    Get-RSSFeedList -URL Value
    Describe what this call does

    .NOTES
    Place additional notes here.

    .LINK
    URLs to related sites
    The first link is opened by Get-Help -Online Get-RSSFeedList

    .INPUTS
    List of input types that are accepted by this function.

    .OUTPUTS
    List of output types produced by this function.
  #>


    [CmdletBinding()]
    Param (
        [Parameter( Mandatory = $True,
                    HelpMessage='Add help message for user',
                    ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName = $true)]
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

                        'Index' =$index

                        'Title' = $post.title

                        'Date' = [DateTime]$post.pubdate

                        'Author' = $post.creator.'#cdata-section'

                        'Link' = $post.Link

                    }

                    $index++

                    $ListObject = New-Object -TypeName psobject -Property $postprops
                    $ListObject.PSObject.TypeNames.Insert(0,'FeedList.Object')
                    Write-Output -InputObject $ListObject

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

    }

    End{}

}