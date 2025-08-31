@echo off
setlocal EnableDelayedExpansion

rem Generate timestamp for output filename using PowerShell (locale-agnostic)
for /f %%I in ('powershell -NoProfile -Command "(Get-Date).ToString(\"yyyyMMdd_HHmmss\")"') do set "TS=%%I"

set "OUT_DIR=%~dp0"
set "OUT_FILE=%OUT_DIR%network_adapters_dns_!TS!.txt"

rem Capture OS name for the header (preserve spaces)
for /f "usebackq delims=" %%D in (`powershell -NoProfile -Command "(Get-CimInstance -ClassName Win32_OperatingSystem).Caption"`) do set "OS_NAME=%%D"

echo Generating report: "%OUT_FILE%"

> "%OUT_FILE%" (
  echo Network adapters and DNS report
  echo Computer: %COMPUTERNAME%
  echo OS: !OS_NAME!
  echo Timestamp: %DATE% %TIME%
  echo.
  echo === Adapter summary ^(Name, Status, MAC, Speed^) ===
)

powershell -NoProfile -Command "Get-NetAdapter | Select-Object Name, InterfaceDescription, Status, MacAddress, LinkSpeed | Sort-Object Name | Format-Table -AutoSize | Out-String -Width 4096" >> "%OUT_FILE%"

>> "%OUT_FILE%" echo.
>> "%OUT_FILE%" echo === DNS servers per interface (IPv4 and IPv6) ===
powershell -NoProfile -Command "$dns = Get-DnsClientServerAddress -AddressFamily IPv4,IPv6 | Sort-Object InterfaceAlias,AddressFamily; $dns | ForEach-Object { $af = if ($_.AddressFamily -eq 2) { 'IPv4' } elseif ($_.AddressFamily -eq 23) { 'IPv6' } else { [string]$_.AddressFamily }; '{0,-35} {1,-5} {2}' -f $_.InterfaceAlias, $af, ($_.ServerAddresses -join ', ') }" >> "%OUT_FILE%"

>> "%OUT_FILE%" echo.
>> "%OUT_FILE%" echo === ipconfig /all (raw) ===
ipconfig /all >> "%OUT_FILE%"

echo Done. Report saved to: "%OUT_FILE%"

endlocal
