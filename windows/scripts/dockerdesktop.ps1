Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco feature disable --name showDownloadProgress

choco install vscode docker-desktop -y

DISM /Online /Enable-Feature /All /NoRestart /FeatureName:Microsoft-Hyper-V
