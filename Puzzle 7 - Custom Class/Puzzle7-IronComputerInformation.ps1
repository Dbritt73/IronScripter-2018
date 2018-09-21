Class IronComputerInformation {

    [string]$ComputerName
    [string]$BIOSmfgr
    [string]$BIOSversion
    [String]$Domain
    [int]$NumberofProcessors
    [int]$NumberofCores
    [double]$TotalPhyscialMemory
    [string]$OSName
    [string]$OSArch
    [string]$TimeZone
    [double]$SizeofCDrive
    [double]$FreeSpace
    
    #Default Constructor
    IronComputerInformation(){}

    #Contructor with arguments
    IronComputerInformation ([String]$ComputerName, [string]$Domain) {

        #try-catch block had broke this
        if (($ComputerName -eq '') -or ($ComputerName -eq $Null)) {

            #Write-output "ComputerName is empty or null"
            throw [System.InvalidOperationException]::new("ComputerName is empty or Null")

        } 

        if (($Domain -eq '') -or ($Domain -eq $Null)) {

            #Write-Output "Domain is empty or Null"
            throw [System.InvalidOperationException]::new("Domain is empty or Null")

        }

            $this.ComputerName = $ComputerName
            $this.Domain = $Domain
        
    }

    [void] GetComputerInfo() {

        $compsys = Get-CimInstance -ClassName 'Win32_ComputerSystem'

        $this.ComputerName = $compsys.Name
        $this.TotalPhyscialMemory = [math]::Ceiling($compsys.TotalPhysicalMemory / 1GB)

        $this.Domain = $compsys.Domain
        $this.NumberofProcessors = $compsys.NumberofProcessors

    }
    
    [void] GetCoresInfo() {

        $proc = Get-CimInstance -ClassName 'Win32_Processor'

        $this.NumberofCores = $proc.NumberOfCores

    }

    [void] GetBiosInfo() {

        $bios = Get-CimInstance -ClassName 'Win32_BIOS'

        $this.BIOSmfgr = $bios.Manufacturer
        $this.BIOSversion = $bios.Version

    }

    [void] GetOsInfo() {

        $OS = Get-CimInstance -ClassName 'win32_OperatingSystem'

        $this.OSName = $os.Caption
        $this.OSArch = $os.OSArchitecture

    }

    [void] GetTimeZoneInfo() {

        $this.TimeZone = (Get-TimeZone).DisplayName

    }

    [void] GetDiskInfo() {

        $disks = Get-CimInstance -ClassName 'Win32_LogicalDisk' -Filter "DeviceID='C:'"

        $this.SizeofCDrive = [math]::Round(($disks.Size /1GB) , 2)
        $this.FreeSpace = [math]::Round(($disks.FreeSpace / 1GB) , 2)

    }

    [void] GetAllInfo() {

        $this.GetComputerInfo()
        $this.GetCoresInfo()
        $this.GetBiosInfo()
        $this.GetOsInfo()
        $this.GetTimeZoneInfo()
        $this.GetDiskInfo()

    }

    [double] CalcFreeSpacePerc() {

        if (($this.SizeofCDrive -eq 0) -or ($this.FreeSpace -eq 0)) {
            
            $this.GetDiskInfo()

        }

        $perc = ($this.FreeSpace / $this.SizeofCDrive) * 100

        return [math]::Round($perc, 3)

    }

    #Contructor to take local computername and get all info
    IronComputerInformation ([string]$ComputerName) {

        if (($ComputerName -eq '') -or ($ComputerName -eq $Null)) {

            throw [System.InvalidOperationException]::new("computername is empty or nulll")

        }

        if ($ComputerName -ne $env:COMPUTERNAME) {

            Throw "$ComputerName not equal to local computername"
            
        }

        $this.GetAllInfo()
    }

}