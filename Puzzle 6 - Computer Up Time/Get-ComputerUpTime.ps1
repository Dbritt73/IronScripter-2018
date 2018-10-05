#!/usr/bin/env powershell
Function Get-ComputerUpTime {
  <#
    .SYNOPSIS
    Describe purpose of "Get-ComputerUpTime" in 1-2 sentences.

    .DESCRIPTION
    Add a more complete description of what the function does.

    .PARAMETER ComputerName
    Describe parameter -ComputerName.

    .EXAMPLE
    Get-ComputerUpTime -ComputerName Value
    Describe what this call does

    .NOTES
    Place additional notes here.

    .LINK
    URLs to related sites
    The first link is opened by Get-Help -Online Get-ComputerUpTime

    .INPUTS
    List of input types that are accepted by this function.

    .OUTPUTS
    List of output types produced by this function.
  #>


    [CmdletBinding()]
    Param (

        [Parameter( ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName = $true,
                    Position = 0)]
        [string[]]$ComputerName

    )

    Begin {}

    Process {

        foreach ($computer in $ComputerName) {

            Try {

                $WMI = @{
                
                    'ComputerName' = $computer
    
                    'ClassName' = 'Win32_OperatingSystem'
    
                    'ErrorAction' = 'Stop'
                    
                }
    
                $OS = Get-CimInstance @WMI
    
                $BootTime = (Get-Date) - $OS.LastBootUpTime
    
                [int]$days = $BootTime.Days
    
                $hoursPercent = $BootTime.Hours / 24
                
                $hours = '{0:n3}' -f $hoursPercent
    
                $UpTime = "$Days" + '.' + "$hours"
                $UpTime = $UpTime.Split('.')
                $UpTime = "$($UpTime[0])" + '.' + "$($UpTime[2])"
    
                $ObjProps = [ordered]@{
    
                    'ComputerName' = $OS.CSName
    
                    'LastBootTime' = $OS.LastBootUpTime
    
                    'Uptime' = $UpTime
    
                }
    
                $Object = New-Object -TypeName PSObject -Property $ObjProps
                $Object.PSObject.TypeNames.Insert(0,'System.UpTime')
                Write-Output -InputObject $Object
           
            } Catch {
            
                # get error record
                [Management.Automation.ErrorRecord]$e = $_
    
                # retrieve information about runtime error
                $info = [PSCustomObject]@{
                    
                    ComputerName = $computer
                    Date         = Get-Date
                    Exception    = $e.Exception.Message
                    Reason       = $e.CategoryInfo.Reason
                    Target       = $e.CategoryInfo.TargetName
                    Script       = $e.InvocationInfo.ScriptName
                    Line         = $e.InvocationInfo.ScriptLineNumber
                    Column       = $e.InvocationInfo.OffsetInLine
                  
                }
                
                # output information. Post-process collected info, and log info (optional)
                $info
                
            }

        }

    }

    End {}

}