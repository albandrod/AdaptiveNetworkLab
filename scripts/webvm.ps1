<# Custom Script for Windows to install IIS #>
param (
    [string]$vmwebpip
)

# Install IIS
Install-WindowsFeature -name Web-Server -IncludeManagementTools

# Modify listening port to 8089
Set-WebBinding -Name 'Default Web Site' -BindingInformation "*:80:" -PropertyName Port -Value 8089


# Create temp directory for downloaded files
New-Item -ItemType Directory -Path C:\Temp -ErrorAction SilentlyContinue

#Download Cosmos DB Emulator
Invoke-WebRequest -Uri "https://aka.ms/cosmosdb-emulator" -OutFile "C:\Temp\cosmosdbemulator.exe"

#Download Iperf
Invoke-WebRequest -Uri "https://iperf.fr/download/windows/iperf-3.1.3-win64.zip" -OutFile "C:\Temp\iperf.zip"

#unzip Iperf
New-Item -ItemType Directory -Path C:\Temp\iperf -ErrorAction SilentlyContinue
Expand-Archive "C:\Temp\iperf.zip" -DestinationPath C:\temp\iperf

# Disable IE Enhanced Configuration
function Disable-ieESC {
    $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
    $UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
    Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0
    Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0
    Stop-Process -Name Explorer
    Write-Host "IE Enhanced Security Configuration (ESC) has been disabled." -ForegroundColor Green
}
Disable-ieESC

# Disable Windows FireWall
Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled False
