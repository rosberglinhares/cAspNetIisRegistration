# cAspNetIisRegistration

A PowerShell DSC module with resources for ASP.NET IIS registration in Windows versions prior to Windows Server 2012 / Windows 8.

Refer to https://support.microsoft.com/en-us/kb/2736284 for details.

## Usage

```
Configuration MySystemConfiguration
{
    Import-DscResource –ModuleName "PSDesiredStateConfiguration"
    Import-DscResource –ModuleName "cAspNetIisRegistration"

    Node localhost
    {
        WindowsFeature IIS
        {
            Name = "Web-WebServer"
            Ensure = "Present"
        }

        cAspNetIisRegistration AspNetIisReg
        {
            Ensure = "Present"
        }
    }
}

MySystemConfiguration

Start-DscConfiguration -Wait -Force -Verbose -Path ".\MySystemConfiguration"
```
