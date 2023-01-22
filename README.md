# WindowsSetupScript
A customizable setup script that I originally made to speed up making Windows 10/11 somewhat usable.

I've made it very customizable so it should be eazy for others to make it theirs.
## Configuration
$Options:
* InstallWingetPkgs - Install packages defined in $Options.Winget.Packages with winget = [bool]
* InstallScoop - Install the scoop package manager = [bool]
* InstallScoopPkgs - Install packages defined in $Options.Scoop.Packages with scoop = [bool]
* DarkMode - Enable/Disable Dark mode = [bool]
* DisableTelemetry - Disable Telemetry = [bool]
* InstallWsl - Install Windows Subsystem for Linux with the distro defined in $Options.WslDistro = [bool]
* RemoveOneDrive - Remove OneDrive = [bool]
* RemoveBloatware - Removes bloatware appxs defined in $Options.Bloatware = [bool]
* WslDistro - Distro to install when installing Windows Subsystem for Linux = [bool]
* Bloatware - Bloatware appx list used when $Options.RemoveBloatware is $True = [string[]]
* Winget
    * Packages - Packages to automatically install with winget if $Options.InstallWingetPkgs is $True = [string[]]
    * PackagePostInstall - Commands to happen after installing a package = ${[string] = [string[]]}
* Scoop
    * Buckets - Buckets to enable before installing any packages with scoop = [string[]]
    * Packages - Packages to install with scoop when $Options.InstallScoopPkgs is $True = [string[]]
    * GlobalPackages - Packages to install for all users with scoop when $Options.InstallScoopPkgs is $True = [string[]]
    * PackagePostInstall - Commands to happen after installing a package = ${[string] = [string[]]}
