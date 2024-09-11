FROM mcr.microsoft.com/windows/servercore:ltsc2022


# Download the tools
SHELL ["cmd", "/S", "/C"]
ADD "https://aka.ms/vs/15/release/vs_community.exe" "C:\TEMP\vs_community.exe"
ADD "https://dist.nuget.org/win-x86-commandline/v4.7.0/nuget.exe" "C:\TEMP\nuget.exe"


# Install VS 2017 community
RUN C:\TEMP\vs_community.exe --includeRecommended --includeOptional --quiet --nocache --norestart --wait \
    --installPath C:\BuildTools \
    --add Microsoft.VisualStudio.Workload.VCTools \
    --add Microsoft.VisualStudio.Component.Windows10SDK \
    --add Microsoft.VisualStudio.Component.Windows81SDK \
    --add Microsoft.VisualStudio.Component.VC.v141.x86.x64 \
    || IF "%ERRORLEVEL%"=="3010" EXIT 0


# Install SSDT NuGet
RUN "C:\TEMP\nuget.exe" install Microsoft.Data.Tools.Msbuild -Version 10.0.61804.210


# Install Chocolatey
ENV chocolateyUseWindowsCompression = false

SHELL ["powershell.exe", "-ExecutionPolicy", "Bypass", "-Command"]
RUN Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')); \
    [System.Environment]::SetEnvironmentVariable('PATH', "\"${env:PATH};%ALLUSERSPROFILE%\chocolatey\bin\"", 'Machine'); \
    choco feature enable -n allowGlobalConfirmation;


# Install git tools with chocolatey
RUN choco install git -y \
    git-lfs -y \
    python -y \
    git-credential-manager-for-windows -y


# Launch VS2017 developer command prompt when started
SHELL ["cmd", "/S", "/C"]
ENTRYPOINT [ "CMD", "/k", "C:/Program Files (x86)/Microsoft Visual Studio/2017/Community/Common7/Tools/VsDevCmd.bat" ]
