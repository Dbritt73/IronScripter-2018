Function Get-WebArticle {
  <#
    .SYNOPSIS
    Describe purpose of "Get-WebArticle" in 1-2 sentences.

    .DESCRIPTION
    Add a more complete description of what the function does.

    .PARAMETER LinkPost
    Describe parameter -LinkPost.

    .EXAMPLE
    Get-WebArticle -LinkPost Value
    Describe what this call does

    .NOTES
    Place additional notes here.

    .LINK
    URLs to related sites
    The first link is opened by Get-Help -Online Get-WebArticle

    .INPUTS
    List of input types that are accepted by this function.

    .OUTPUTS
    List of output types produced by this function.
  #>


    [CmdletBinding()]
    Param(

        [String]$LinkPost

    )

    Begin {}

    Process {

        Try {

            Add-Type -path "$PSScriptroot\Net45\HtmlAgilityPack.dll"

            [Net.ServicePointManager]::SecurityProtocol = 'tls12, tls11, tls'
        
            $content = (Invoke-WebRequest -Uri $LinkPost).content
        
            $html = New-Object -TypeName HtmlAgilityPack.HtmlDocument
        
            $html.LoadHtml($content)
        
            $output = (($html.DocumentNode.Descendants('p').innertext)) | Format-StringWrap
        
            $output.Replace('&#8220;','').replace('&#8221;','').replace('&#8217;',"'").replace('&#8212;', '--') | more

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