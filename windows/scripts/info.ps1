Write-Host "HypervisorPresent ?"
$(Get-ComputerInfo).HypervisorPresent
Write-Host "Hyper-v Enabled ?"
$(Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V-All -Online).State
Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V-All -Online
Write-Host "Containers Enabled ?"
$(Get-WindowsOptionalFeature -FeatureName containers -Online).State
Get-WindowsOptionalFeature -FeatureName containers -Online
Write-Host "Windows Version:"
$(gwmi win32_operatingsystem).Version
