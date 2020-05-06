<# Custom Script for Windows to install FTP Filezilla Server and configure #>
param (
    [string]$vmdatapip
)


# Create temp directory for downloaded files
New-Item -ItemType Directory -Path C:\Temp -ErrorAction SilentlyContinue

#download FileZilla Server Setup
Invoke-WebRequest -Uri "https://dl3.cdn.filezilla-project.org/server/FileZilla_Server-0_9_60_2.exe?h=oIa-aSu6lbMgd6gPSawDwg&x=1588730979" -OutFile "C:\Temp\filezillaserver.exe"

#Download Iperf
Invoke-WebRequest -Uri "https://iperf.fr/download/windows/iperf-3.1.3-win64.zip" -OutFile "C:\Temp\iperf.zip"

#unzip Iperf
New-Item -ItemType Directory -Path C:\Temp\iperf -ErrorAction SilentlyContinue
Expand-Archive "C:\Temp\iperf.zip" -DestinationPath C:\temp\iperf

# Execute iperf as a process as a listner on 1433 to mimic SQL port
cd /
cd "C:\Temp\iperf\iperf-3.1.3-win64"
.\iperf3.exe -p 1433 -s -D -I C:\Temp\sqlpid.txt

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

cd /

# Install FileZilla Server
.\temp\filezillaserver.exe /S /D="C:\Program Files (x86)\FileZilla Server"

#Obtain Azure MetaData Instance
$ASRPIP = Invoke-RestMethod -Method GET -Uri http://169.254.169.254/metadata/instance?api-version=2017-04-02 -Headers @{"Metadata"="True"}

#Opbtain Public IP Address assigned
$ASRPIP = $ASRPIP.network.interface.ipv4.ipaddress.publicipaddress

#Create a backup file
Copy-Item -Path "C:\Program Files (x86)\FileZilla Server\fileZilla Server.xml" -Destination "C:\Program Files (x86)\FileZilla Server\FileZilla Server.xml.bkp" -Force

#Restore from backup
## Copy-Item -Path "C:\Program Files (x86)\FileZilla Server\fileZilla Server.xml.bkp" -Destination "C:\Program Files (x86)\FileZilla Server\FileZilla Server.xml" -Force

# path of XML config for FileZilla Server
$path = 'C:\Program Files (x86)\FileZilla Server\fileZilla Server.xml'

# Download Modified FileZilla Server Configuration for Passive FTP.
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/swiftsolves-msft/AdaptiveNetworkLab/master/scripts/FileZilla%20Server.xml" -OutFile $path

# Obtain XML config as a object 
[xml]$xml = (Get-Content $path)

# Specific public ip setting is on line 12 
## $xml.FileZillaServer.Settings.Item[12].InnerText

# Create a variable to replace the public ip address from the parameter passed into script     
$node = $xml.FileZillaServer.Settings.Item[12]

# replace
$node.'#text' = $ASRPIP

# Save update changes
$xml.Save($path)

# Restart Service
Restart-Service "FileZilla Server"
