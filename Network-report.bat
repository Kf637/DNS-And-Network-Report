@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem Use UTF-8 code page to reduce garbled characters in redirected output
chcp 65001 >nul

rem Timestamp: prefer WMIC if available, else build ISO-like from DATE/TIME
set "TS="
for /f "tokens=2 delims==" %%I in ('wmic os get LocalDateTime /value 2^>nul ^| find "="') do set "LDT=%%I"
if defined LDT (
  rem LDT is YYYYMMDDhhmmss.mmm... -> make YYYY-MM-DD_HH-mm-ss
  set "TS=!LDT:~0,4!-!LDT:~4,2!-!LDT:~6,2!_!LDT:~8,2!-!LDT:~10,2!-!LDT:~12,2!"
) else (
  rem Parse DATE into tokens (locale dependent). Try common patterns to build YYYY-MM-DD.
  for /f "tokens=1-4 delims=/.- " %%a in ("%DATE%") do (
    set "p1=%%a" & set "p2=%%b" & set "p3=%%c" & set "p4=%%d"
  )
  set "yyyy=" & set "mm=" & set "dd="
  rem If first token length is 4 -> yyyy-mm-dd
  if "!p1:~4,1!"=="" (
    set "yyyy=!p1!" & set "mm=!p2!" & set "dd=!p3!"
  ) else (
    rem Assume dd/mm/yyyy or mm/dd/yyyy; try yyyy as third token
    if "!p3:~4,1!"=="" (
      set "yyyy=!p3!" & set "mm=!p2!" & set "dd=!p1!"
    ) else (
      rem Fallback: just use sanitized DATE as yyyy-mm-dd-ish
      set "yyyy=!p3!" & set "mm=!p1!" & set "dd=!p2!"
    )
  )
  rem Zero-pad mm and dd if needed
  if "!mm:~1,1!"=="" set "mm=0!mm!"
  if "!dd:~1,1!"=="" set "dd=0!dd!"
  rem Parse TIME (HH:mm:ss.cc)
  set "tt=%TIME%"
  set "hh=!tt:~0,2!"
  if "!hh:~0,1!"==" " set "hh=0!hh:~1,1!"
  set "mi=!tt:~3,2!"
  set "ss=!tt:~6,2!"
  set "TS=!yyyy!-!mm!-!dd!_!hh!-!mi!-!ss!"
)

rem Final fallback if TS is still empty; build from DATE/TIME and sanitize, else use RANDOM
if not defined TS (
  set "TS=1970-01-01_00-00-00"
)
if "%TS%"=="" set "TS=%RANDOM%"

set "OUT_DIR=%~dp0"
set "OUT_FILE=%OUT_DIR%network_adapters_dns_%TS%.txt"

rem OS name from registry
for /f "tokens=2,*" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName ^| find "ProductName"') do set "OS_NAME=%%B"

echo Generating report: "%OUT_FILE%"

rem Create file with UTF-8 BOM so editors detect encoding correctly
set "TMPHEX=%TEMP%\utf8bom.hex"
> "%TMPHEX%" echo EF BB BF
certutil -f -decodehex "%TMPHEX%" "%OUT_FILE%" >nul
del "%TMPHEX%" >nul 2>&1

>> "%OUT_FILE%" (
  echo Network adapters and DNS report
  echo Computer: %COMPUTERNAME%
  echo OS: %OS_NAME%
  echo Timestamp: %DATE% %TIME%
  echo.
  echo === Adapter summary ^(Admin State, State, Type, Name^) ===
)
netsh interface show interface >> "%OUT_FILE%"

>> "%OUT_FILE%" echo.
>> "%OUT_FILE%" echo === DNS servers per interface ^(IPv4^) ===
netsh interface ip show dnsservers >> "%OUT_FILE%"

>> "%OUT_FILE%" echo.
>> "%OUT_FILE%" echo === DNS servers per interface ^(IPv6^) ===
netsh interface ipv6 show dnsservers >> "%OUT_FILE%"

>> "%OUT_FILE%" echo.
>> "%OUT_FILE%" echo === MAC addresses ^(by connection^) ===
getmac /v /fo table >> "%OUT_FILE%"

>> "%OUT_FILE%" echo.
>> "%OUT_FILE%" echo === ipconfig /all ^(raw^) ===
ipconfig /all >> "%OUT_FILE%"

echo Done. Report saved to: "%OUT_FILE%"

endlocal

