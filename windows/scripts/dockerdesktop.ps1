Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco feature disable --name showDownloadProgress

choco install docker-desktop -y --pre

DISM /Online /Enable-Feature /All /NoRestart /FeatureName:Microsoft-Hyper-V
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
