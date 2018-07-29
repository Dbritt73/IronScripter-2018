Function Get-PerfCounters {
    [CmdletBinding()]
    Param (
        [Parameter( ValuefromPipeline=$true, 
                    ValueFromPipelineByPropertyName=$true)]
        [String[]]$ComputerName,

        [switch]$HTML,

        [switch]$csv
    )

    Begin {}

    Process {
    
        Foreach ($computer in $ComputerName) {
        
            Try {

                $CIM = @{
                
                    'ComputerName' = $computer;
                    'NameSpace' = 'root/CimV2';
                    'ClassName' = 'Win32_PerfFormattedData_PerfOS_Processor';
                    'ErrorAction' = 'Stop'
                    
                }

                $Processor = Get-CimInstance @CIM

                $CIM = @{
                
                    'ComputerName' = $computer;
                    'NameSpace' = 'root/CimV2';
                    'ClassName' = 'CIM_LogicalDisk';
                    'ErrorAction' = 'Stop'
                    
                }
                
                $Disk = Get-CimInstance @CIM | Where-Object {$_.Name -eq 'C:'}

                $CIM = @{
                
                    'ComputerName' = $computer;
                    'NameSpace' = 'root/CimV2';
                    'ClassName' = 'Win32_PerfFormattedData_PerfOS_Memory';
                    'ErrorAction' = 'Stop'
                    
                }

                $Memory =  Get-CimInstance @CIM

                $CIM = @{
                
                    'ComputerName' = $computer;
                    'NameSpace' = 'root/CimV2';
                    'ClassName' = 'Win32_PerfFormattedData_Tcpip_NetworkAdapter';
                    'ErrorAction' = 'Stop'
                    
                }

                $Network = Get-CimInstance @CIM | Where-Object {$_.BytesTotalPerSec -ne 0}

                $PerfProps = @{
                
                    'ComputerName' = $computer;
                    'TimeStamp' = (Get-Date);
                    'PercentageProcessorTime' = [int]($Processor | Measure-Object -Property PercentProcessorTime -Average | Select-Object -ExpandProperty Average);
                    'PercentFreeSpace(C:)' = [int](($disk.FreeSpace / $disk.Size) * 100);
                    'MemoryCommitedBytes' = $Memory.PercentCommittedBytesInUse;
                    'TotalNetBytesSent' = $Network | Sort-Object -Property BytesTotalPerSec -Descending | Select-Object -Property Name, BytesTotalPerSec -First 2
                    
                }

                $perfobj = New-Object -TypeName psobject -Property $perfProps
                $perfobj.PSObject.TypeNames.Insert(0,'CompPerf.Object')
                Write-Output -InputObject $perfobj 

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

    End {}
    
}


Function Invoke-Output {
    [cmdletBinding()]
    Param (
        [Parameter( ValuefromPipeline=$true, 
        ValueFromPipelineByPropertyName=$true)]
        [String[]]$ComputerName,

        [Switch]$Html,

        [Switch]$csv
    )

    Begin {}

    Process {
       # foreach ($computer in $computername) {
            Try {
            
                if ($PSBoundParameters.ContainsKey('html')) {

                    $Style = "<style>$(Get-content -Path .\ComputerOwnership.css)</style>"
                    $HTMLReport = $ComputerName | Get-PerfCounters | ConvertTo-Html -As 'Table' -Fragment -PreContent '<h2>PC Perf Counters</h2>' | Out-String

                    $HTMLParams = @{
                    
                        'Head' = "<title>PC Performance Counters</title>$Style";
                        'PreContent' = '<h1>PC Performance</h1>';
                        'PostContent' = "$HTMLReport"
                        
                    }

                    ConvertTo-Html @HTMLParams | Out-file -FilePath .\PCPerfCounters.html
                }
            } catch {
            
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

       # }

    }

    End {}
}