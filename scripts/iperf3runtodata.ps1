$date = Get-Date -Format "yyyy-MM-dd-hh-mm"
$logpath = "c:\temp\iperfrun$date.json"
& "C:\Temp\iperf\iperf-3.1.3-win64\iperf3.exe" -c DATAVM -t 30 -p 1433 -P 32 -J --logfile $logpath