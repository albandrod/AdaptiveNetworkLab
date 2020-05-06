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
