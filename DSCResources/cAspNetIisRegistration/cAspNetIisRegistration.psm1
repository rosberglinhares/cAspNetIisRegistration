Set-Variable AspNet4xClrVersion -Option Constant -Value "4.0.30319"
Set-Variable DotNetFramework4xRootPath -Option Constant -Value (Join-Path $env:SystemRoot "Microsoft.NET\Framework64\v$AspNet4xClrVersion")
Set-Variable AspNetRegIisPath -Option Constant -Value (Join-Path $DotNetFramework4xRootPath "aspnet_regiis")
Set-Variable AspNetRegIisListVersionsArgs -Option Constant -Value "-lv"
Set-Variable AspNetRegIisInstallArgs -Option Constant -Value "-iru"
Set-Variable AspNetRegIisUninstallArgs -Option Constant -Value "-u"
Set-Variable AspNetIsapiPath -Option Constant -Value (Join-Path $DotNetFramework4xRootPath "aspnet_isapi.dll")

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure
    )

    $aspNet4Installed = Test-AspNet4xInstallation

    return !($Ensure -eq "Present" -xor $aspNet4Installed)
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure
    )

    if ($Ensure -eq "Present")
    {
        $aspNetRegIisOutput = & $AspNetRegIisPath $AspNetRegIisInstallArgs
    }
    else
    {
        $aspNetRegIisOutput = & $AspNetRegIisPath $AspNetRegIisUninstallArgs
    }

    if ($LastExitCode -ne 0)
    {
        throw "Error executing '$AspNetRegIisPath'. The command output was:`n$($aspNetRegIisOutput | Out-String)"
    }
}

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure
    )

    $configuration = @{}
    
    if (Test-AspNet4xInstallation)
    {
        $configuration.Add("Ensure", "Present")
    }
    else
    {
        $configuration.Add("Ensure", "Absent")
    }

    return $configuration
}

function Test-AspNet4xInstallation
{
    [OutputType([System.Boolean])]
    param ()

    $aspNetRegIisOutput = & $AspNetRegIisPath $AspNetRegIisListVersionsArgs

    if ($LastExitCode -eq 0)
    {
        $aspNet4Matches = $aspNetRegIisOutput | Select-String -Pattern "$([Regex]::Escape($AspNet4xClrVersion)).*$([Regex]::Escape($AspNetIsapiPath))"

        return $aspNet4Matches.Count -gt 0
    }
    else
    {
        throw "Error executing '$AspNetRegIisPath'. The command output was:`n$($aspNetRegIisOutput | Out-String)"
    }
}

Export-ModuleMember -Function *-TargetResource