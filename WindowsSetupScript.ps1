#Requires -RunAsAdministrator

<#
.LICENSE
    Copyright 2023 Natalia Łotocka

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
.REPOSITORY
    https://github.com/natawie/WindowsSetupScript
.AUTHOR
    Natalia Łotocka
    https://natawie.gay
#>

$Options = @{
    InstallWingetPkgs = $True
    InstallScoop = $True
    InstallScoopPkgs = $True
    DarkMode = $True
    DisableTelemetry = $True
    InstallWsl = $True
    RemoveOneDrive = $True
    RemoveBloatware = $True
    WslDistro = [string]"Debian" # select one listed by "wsl --list --online"
    Bloatware = [string[]](
        "WindowsCamera",
        "OfficeHub",
        "SkypeApp",
        "GetStarted",
        "ZuneMusic",
        "WindowsMaps",
        "SolitaireCollection",
        "BingFinance",
        "ZuneVideo",
        "BingNews",
        "OneNote",
        "People",
        "BingSports",
        "BingWeather",
        "SoundRecorder",
        "Clipchamp",
        "MicrosoftEdge"
    )
    Winget = @{
        Packages = [string[]](
            "Microsoft.VCRedist.2015+.x86",
            "Microsoft.VCRedist.2015+.x64",
            "gerardog.gsudo",
            "Neovim.Neovim.Nightly",
            "Microsoft.WindowsTerminal",
            "Microsoft.VisualStudio.2022.BuildTools",
            "VSCodium.VSCodium",
            "GnuWin32.Grep",
            "Starship.Starship",
            "Librewolf.Librewolf",
            "clsid2.mpc-hc",
            "CiderCollective.Cider.Nightly",
            "MSYS2.MSYS2",
            "Python.Python.3.11",
            "Rustlang.Rustup",
            "XP89DCGQ3K6VLD", # powertoys
            "Git.Git",
            "OBSProject.OBSStudio",
            "Microsoft.PowerShell", # powershell 7
            "Discord.Discord",
            "Valve.Steam",
            "Autohotkey.Autohotkey",
            "LGUG2Z.komorebi"
        )
        PackagePostInstall = @{
            "gerardog.gsudo" = [string[]]("gsudo config CacheMode Auto")
            "GnuWin32.Grep" = [string[]]("Set-ItemProperty -path HKCU:\Environment\ -Name Path -Value `"C:\Program Files (x86)\GnuWin32\bin;`$((Get-ItemProperty -path HKCU:\Environment\ -Name Path).Path)`"")
            "Starship.Starship" = [string[]](
                "New-Item -ItemType Directory -Force -Path `"$HOME/.config/powershell`"",
                "Add-Content -Value `"Invoke-Expression (&starship init powershell)`" -Path `"$HOME/.config/powershell/config.ps1`"",
                "New-Item -ItemType Directory -Force -Path `"$HOME/Documents/WindowsPowerShell`"",
                "New-Item -ItemType SymbolicLink -Path `"$HOME/Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1`" -Target `"$HOME/.config/powershell/config.ps1`"",
                "New-Item -ItemType Directory -Force -Path `"$HOME/Documents/PowerShell`"",
                "New-Item -ItemType SymbolicLink -Path `"$HOME/Documents/PowerShell/Microsoft.PowerShell_profile.ps1`" -Target `"$HOME/.config/powershell/config.ps1`""
            )
            "LGUG2Z.komorebi" = [string[]](
                "Add-Content -Value `"komorebic start -a`" -Path `"$HOME/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Start-up/komorebi.bat`"",
                "Invoke-WebRequest `"https://raw.githubusercontent.com/natawie/WindowsSetupScript/main/komorebi.ahk`" -OutFile `"$HOME/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Start-up/komorebi.ahk`""
            )
        }
    }
    Scoop = @{
        # what buckets to enable during InstallScoopPkgs
        Buckets = [string[]](
            "nerd-fonts"
        )
        # packages for the current user
        Packages = [string[]](
            "neofetch"
        )
        # packages encompassing the whole system
        # use it if required (eg. for fonts)
        # or if you want to install something for all users
        GlobalPackages = [string[]](
            "CodeNewRoman-NF-Mono"
        )
        PackagePostInstall = @{}
    }
}

Function ReloadPath {
    [OutputType([void])]
    param ()
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

Function IsApplicationInstalled {
    [OutputType([bool])]
    param (
        [string]$Name
    )

    if (Get-Command $Name -errorAction SilentlyContinue) {
        return $True
    } else {
        return $False
    }
}

Function InstallScoop {
    [OutputType([void])]
    param ()
    if (IsApplicationInstalled("scoop")) {
        Write-Output "Skipping `"InstallScoop`": scoop is already installed"
    } else {
        Write-Output "Installing scoop"
        Invoke-RestMethod get.scoop.sh | Invoke-Expression
        ReloadPath
    }
}

Function InstallWingetPkgs {
    [OutputType([void])]
    param ()
    foreach ($Package in $Options.Winget.Packages) {
        Write-Output "Installing $Package with winget"
        winget install --id $Package --accept-package-agreements
        ReloadPath
        if ($Options.Winget.PackagePostInstall.ContainsKey("$Package")) {
            Write-Output "$Package post-install"
            foreach ($command in $Options.Winget.PackagePostInstall["$Package"]) {
                Invoke-Command -script ([scriptblock]::Create($command))
            }
        }
    }
}

Function InstallScoopPkgs {
    [OutputType([void])]
    param ()
    foreach ($Bucket in $Options.Scoop.Buckets) {
        Write-Output "Enabling the $Bucket bucket in scoop"
        scoop bucket add $Bucket
    }

    foreach ($Package in $Options.Scoop.Packages) {
        Write-Output "Installing $Package with scoop"
        scoop install $Package
        ReloadPath
        if ($Options.Scoop.PackagePostInstall.ContainsKey("$Package")) {
            Write-Output "$Package post-install"
            foreach ($command in $Options.Scoop.PackagePostInstall["$Package"]) {
                Invoke-Command -script [scriptblock]::Create($command)
            }
        }
    }

    foreach ($Package in $Options.Scoop.GlobalPackages) {
        Write-Output "Installing $Package globally with scoop"
        scoop install -g $Package
        ReloadPath
        if ($Options.Scoop.PackagePostInstall.ContainsKey("$Package")) {
            Write-Output "$Package post-install"
            foreach ($command in $Options.Scoop.PackagePostInstall["$Package"]) {
                Invoke-Command -script [scriptblock]::Create($command)
            }
        }
    }
}

Function DarkMode {
    [OutputType([void])]
    param ()
    if ($Options.DarkMode) {
        Write-Output "Enabling dark mode"
    } else {
        Write-Output "Disabling dark mode"
    }
    Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name SystemUsesLightTheme -Value (1-[int]$Options.DarkMode) -Type Dword -Force
    Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value (1-[int]$Options.DarkMode) -Type Dword -Force
}

Function DisableTelemetry {
    [OutputType([void])]
    param ()
    Write-Output "Disabling telemetry"
    sc config DiagTrack start= disabled
    sc config dmwappushservice start= disabled
}

Function InstallWsl {
    [OutputType([void])]
    param ()
    Write-Output "Installing WSL with $($Options.WslDistro)"
    wsl --install $Options.WslDistro -n
}

Function RemoveOneDrive {
    [OutputType([void])]
    param ()
    Write-Output "Removing OneDrive"
    Get-Process onedrive | Stop-Process -Force
    Start-Process "$env:SystemRoot\SysWOW64\OneDriveSetup.exe" "/uninstall"
}

Function RemoveBloatware {
    [OutputType([void])]
    param ()
    Write-Output "Removing Bloatware"
    foreach ($app in $Options.Bloatware) {
        Write-Output "Removing $app"
        Get-AppxPackage *$app* | Remove-AppxPackage
    }
}

Function Main {
    [OutputType([void])]
    param ()
    if ((Read-Host "Have you changed all the options in this file to your liking? (yes or no)") -ne "yes") {
        throw "Execution stopped. Make all desired changed"
    }
    if ($Options.InstallWingetPkgs -and !(IsApplicationInstalled("winget"))) {
        throw "Can't do InstallWingetPkgs: winget is not installed`nInstall ""App Installer"" from the Microsoft Store!"
    }
    if ($Options.InstallScoopPkgs -and !(IsApplicationInstalled("scoop")) -and !($Options.InstallScoop)) {
        throw "Can't do InstallScoopPkgs: scoop is not installed`nEither enable ""InstallScoop"" in `$Options or install scoop manually"
    }
    if ($Options.InstallWsl -and !(Get-ComputerInfo -property "HyperVRequirementVirtualizationFInvoke-RestMethodwareEnabled")) {
        throw "Can't do InstallWsl: Virtualization is not enabled in fInvoke-RestMethodware!"
    }
    if ($Options.InstallWsl -and !($Options.WslDistro)) {
        throw "Can't do InstallWsl: `$Options.WslDistro is not set!"
    }
    if ($Options.DisableTelemetry) {
        DisableTelemetry
    }
    DarkMode
    if ($Options.RemoveOneDrive) {
        RemoveOneDrive
    }
    if ($Options.RemoveBloatware) {
        RemoveBloatware
    }
    if ($Options.InstallWingetPkgs) {
        InstallWingetPkgs
    }
    if ($Options.InstallScoop) {
        InstallScoop
    }
    if ($Options.InstallScoopPkgs) {
        InstallScoopPkgs
    }
    if ($Options.InstallWsl) {
        InstallWsl
    }
}

Main
