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
<<<<<<< HEAD
    
        Foreach ($computer in $ComputerName) {
        
            Try {

                $CIM = @{
                
=======

        Foreach ($computer in $ComputerName) {

            Try {

                $CIM = @{

>>>>>>> 7497414c7100c52cfaa60d007d757f95faa1bb07
                    'ComputerName' = $computer;
                    'NameSpace' = 'root/CimV2';
                    'ClassName' = 'Win32_PerfFormattedData_PerfOS_Processor';
                    'ErrorAction' = 'Stop'
<<<<<<< HEAD
                    
=======

>>>>>>> 7497414c7100c52cfaa60d007d757f95faa1bb07
                }

                $Processor = Get-CimInstance @CIM

                $CIM = @{
<<<<<<< HEAD
                
=======

>>>>>>> 7497414c7100c52cfaa60d007d757f95faa1bb07
                    'ComputerName' = $computer;
                    'NameSpace' = 'root/CimV2';
                    'ClassName' = 'CIM_LogicalDisk';
                    'ErrorAction' = 'Stop'
<<<<<<< HEAD
                    
                }
                
                $Disk = Get-CimInstance @CIM | Where-Object {$_.Name -eq 'C:'}

                $CIM = @{
                
=======

                }

                $Disk = Get-CimInstance @CIM | Where-Object {$_.Name -eq 'C:'}

                $CIM = @{

>>>>>>> 7497414c7100c52cfaa60d007d757f95faa1bb07
                    'ComputerName' = $computer;
                    'NameSpace' = 'root/CimV2';
                    'ClassName' = 'Win32_PerfFormattedData_PerfOS_Memory';
                    'ErrorAction' = 'Stop'
<<<<<<< HEAD
                    
=======

>>>>>>> 7497414c7100c52cfaa60d007d757f95faa1bb07
                }

                $Memory =  Get-CimInstance @CIM

                $CIM = @{
<<<<<<< HEAD
                
=======

>>>>>>> 7497414c7100c52cfaa60d007d757f95faa1bb07
                    'ComputerName' = $computer;
                    'NameSpace' = 'root/CimV2';
                    'ClassName' = 'Win32_PerfFormattedData_Tcpip_NetworkAdapter';
                    'ErrorAction' = 'Stop'
<<<<<<< HEAD
                    
=======

>>>>>>> 7497414c7100c52cfaa60d007d757f95faa1bb07
                }

                $Network = Get-CimInstance @CIM | Where-Object {$_.BytesTotalPerSec -ne 0}

                $PerfProps = @{
<<<<<<< HEAD
                
=======

>>>>>>> 7497414c7100c52cfaa60d007d757f95faa1bb07
                    'ComputerName' = $computer;
                    'TimeStamp' = (Get-Date);
                    'PercentageProcessorTime' = [int]($Processor | Measure-Object -Property PercentProcessorTime -Average | Select-Object -ExpandProperty Average);
                    'PercentFreeSpace(C:)' = [int](($disk.FreeSpace / $disk.Size) * 100);
                    'MemoryCommitedBytes' = $Memory.PercentCommittedBytesInUse;
<<<<<<< HEAD
                    'TotalNetBytesSent' = $Network | Sort-Object -Property BytesTotalPerSec -Descending | Select-Object -Property Name, BytesTotalPerSec -First 2
                    
=======
                    'TotalNetBytesSent' = $Network | Sort-Object BytesTotalPerSec -Descending | Select-Object Name, BytesTotalPerSec -First 2

>>>>>>> 7497414c7100c52cfaa60d007d757f95faa1bb07
                }

                $perfobj = New-Object -TypeName psobject -Property $perfProps
                $perfobj.PSObject.TypeNames.Insert(0,'CompPerf.Object')
<<<<<<< HEAD
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
    
=======
                Write-Output $perfobj 

            } Catch {}

        }

    }

    End {}

>>>>>>> 7497414c7100c52cfaa60d007d757f95faa1bb07
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
<<<<<<< HEAD
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
=======

        Try {

            if ($PSBoundParameters.ContainsKey('html')) {

                $Style = "<style>$(Get-content .\style.css)</style>"
                $HTMLReport = $ComputerName | Get-PerfCounters | ConvertTo-Html -As 'Table' -Fragment -PreContent "<h2>PC Perf Counters</h2>" | Out-String

                $HTMLParams = @{

                    'Head' = "<title>PC Performance Counters</title>$Style";
                    'PreContent' = "<h1>PC Performance</h1>";
                    'PostContent' = "$HTMLReport"

                }
>>>>>>> 7497414c7100c52cfaa60d007d757f95faa1bb07

                ConvertTo-Html @HTMLParams | Out-file .\PCPerfCounters.html

            }

        } catch {}


    }

    End {}
    
}