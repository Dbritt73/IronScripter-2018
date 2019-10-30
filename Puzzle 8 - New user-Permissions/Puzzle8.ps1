Function Invoke-NewLocalUser {
    [CmdletBinding()]
    Param (
        [String[]]$ComputerName = 'LocalHost',

        #[pscredential]$UserCredential = (Get-Credential)
        [String]$UserName,

        [string]$UserPassword

    )

    Begin {

        #$UserCredential = Get-Credential

    }

    Process {

        foreach ($computer in $ComputerName) {

            Try {

                $password = $UserPassword | ConvertTo-SecureString -AsPlainText -Force
                Invoke-Command -ComputerName $computer -ScriptBlock {

                    New-LocalUser -Name $Using:Username -Password $Using:Password

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
                Write-Output -InputObject $info

            }

        }

    }

    End {}
}


Function Invoke-NewItem {
    [CmdletBinding()]
    Param (
        [String[]]$ComputerName = 'LocalHost',

        [string]$ItemType,

        [string]$ItemName,

        [String]$ItemPath
    )

    Begin {}

    Process {

        Foreach ($computer in $ComputerName) {

            Try {

                Invoke-Command -ComputerName $computer -ScriptBlock {

                    New-Item -ItemType $using:itemtype -Name $using:ItemName -Path $Using:ItemPath

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
                Write-Output -InputObject $info

            }

        }

    }

    End {}

}


Function Invoke-SetPermissions {
    <#
    .SYNOPSIS
        This allows an easy method to set a file system access ACE
    .PARAMETER Path
        The file path of a file
    .PARAMETER Identity
        The security principal you'd like to set the ACE to.  This should be specified like
        DOMAIN\user or LOCALMACHINE\User.
    .PARAMETER AccessRight
        One of many file system rights.  For a list:
        http://msdn.microsoft.com/en-us/library/system.security.accesscontrol.filesystemrights(v=vs.110).aspx

        FullControl - Specifies the right to exert full control over a folder or file, and to modify access control and
        audit rules. This value represents the right to do anything with a file and is the combination of all rights in
        this enumeration.

        ListDirectory - Specifies the right to read the contents of a directory.

        Modify - Specifies the right to read, write, list folder contents, delete folders and files, and run application
        files. This right includes the ReadAndExecute right, the Write right, and the Delete right.

        ReadandExecute - Specifies the right to open and copy folders or files as read-only, and to run application
        files. This right includes the Read right and the ExecuteFile right.

    .PARAMETER InheritanceFlags
        The flags to set on how you'd like the object inheritance to be set.  Possible values are
        ContainerInherit, None or ObjectInherit.
        http://msdn.microsoft.com/en-us/library/system.security.accesscontrol.inheritanceflags(v=vs.110).aspx
    .PARAMETER PropagationFlags
        The flag that specifies on how you'd permission propagation to behave. Possible values are
        InheritOnly, None or NoPropagateInherit.
        http://msdn.microsoft.com/en-us/library/system.security.accesscontrol.propagationflags(v=vs.110).aspx
    .PARAMETER AccessType
        The type (Allow or Deny) of permissions to add. http://msdn.microsoft.com/en-us/library/w4ds5h86(v=vs.110).aspx

    .EXAMPLE
        Set-Permission -path '\\SERVER1\Share' -Identity DOMAIN\user -AccessRight 'FullControl' -InheritanceFlags 'None' -PropagationFlags 'None' -Accesstype 'Allow'

        This example demonstrates using Set-permission to grant fullcontrol to the path for DOMAIN\user with no inheritance or propagation

    .Notes
        Original script code was borrowed from Adam Bertram's PowerShell fundamentals course on Pluralsights
    #>
    [CmdletBinding()]
    param (

        [string[]]$computerName = 'LocalHost',

        [Parameter( Mandatory = $true,
                    HelpMessage='Path to location where permissions to be set')]
        [ValidateScript({ Test-Path -Path $_ })]
        [string]$Path,

        [Parameter( Mandatory = $true,
                    HelpMessage='user or group to grant/remove permissions for')]
        [string]$Identity,

        [Parameter( Mandatory = $true,
                    HelpMessage='FullControl,ListDirectory,Modify,Read,ReadandExecute')]
        [ValidateSet('FullControl','ListDirectory','Modify','Read','ReadandExecute')]
        [string]$AccessRight,

        [Parameter( Mandatory = $true,
                    HelpMessage="'ContainerInherit','None','ObjectInherit','ContainerInherit,ObjectInherit'")]
        [ValidateSet('ContainerInherit','None','ObjectInherit','ContainerInherit,ObjectInherit')]
        [string]$InheritanceFlags,

        [Parameter( Mandatory = $true,
                    HelpMessage="InheritOnly','None','NoPropagateInherit")]
        [ValidateSet('InheritOnly','None','NoPropagateInherit')]
        [string]$PropagationFlags,

        [Parameter( Mandatory = $true,
                    HelpMessage='Allow or Deny')]
        [ValidateSet('Allow','Deny')]
        [string]$AccessType
    )

    Begin {}

    Process {

        Foreach ($computer in $computerName) {

            try {

                $Acl = (Get-Item -Path $Path).GetAccessControl('Access')
                $AccessRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList ($Identity, $AccessRight, $InheritanceFlags, $PropagationFlags, $AccessType)
                $Acl.SetAccessRule($AccessRule)
                Set-Acl -Path $Path -AclObject $Acl

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
                Write-Output -InputObject $info

            }

        }

    }

    End {}

}


#Controller
Invoke-NewLocalUser -UserName 'Bill Bennsson' -UserPassword 'password'
Invoke-NewLocalUser -UserName 'Andy Pandien' -UserPassword 'password'

Invoke-NewItem -ItemType 'Directory' -ItemPath "$env:HOMEDRIVE\" -ItemName 'SpecialFolder'
Invoke-NewItem -ItemType 'File' -ItemPath "$env:HOMEDRIVE\SpecialFolder" -ItemName 'SpecialFile.txt'

Invoke-SetPermissions -Path "$env:HOMEDRIVE\SpecialFolder\SpecialFile.txt" -Identity "$ENV:COMPUTERNAME\Bill Bennsson" -AccessRight 'Modify' -InheritanceFlags 'None' -PropagationFlags 'None' -AccessType 'Allow'
Invoke-SetPermissions -Path "$env:HOMEDRIVE\SpecialFolder\SpecialFile.txt" -Identity "$ENV:COMPUTERNAME\Andy Pandien" -AccessRight 'Read' -InheritanceFlags 'None' -PropagationFlags 'None' -AccessType 'Allow'


