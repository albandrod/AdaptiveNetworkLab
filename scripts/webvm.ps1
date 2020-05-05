<# Custom Script for Windows to install IIS #>
param (
    [string]$vmwebpip
)

Install-WindowsFeature -name Web-Server -IncludeManagementTools