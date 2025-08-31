# DNS And Network Report

A simple Windows batch script that exports all network adapters and their DNS server configuration to a timestamped text file. It also appends a full `ipconfig /all` for raw reference.

- Script: `Network-report.bat`
- Output: `network_adapters_dns_YYYYMMDD_HHMMSS.txt` saved in the same folder as the script

## Requirements
- Windows 10/11 or Windows Server 2016+ (PowerShell 5.1+ is built-in)
- No admin rights required (read-only commands)
- Uses built-in PowerShell cmdlets:
  - `Get-NetAdapter`
  - `Get-DnsClientServerAddress`
  - Falls back to raw `ipconfig /all` for completeness

## What it collects
- System header (Computer name, User, OS, Timestamp)
- Adapter summary: Name, Description, Status, MAC, Link Speed
- DNS server addresses per interface (IPv4 and IPv6)
- Full `ipconfig /all` output

## How to run
Execute the batch file: `Network-report.bat`. It will create a timestamped report in the same folder and print the path when done.

## Example Output

```
Network adapters and DNS report
Computer: DESKTOP-XXXXXXX
OS: Microsoft Windows 11 Pro
Timestamp: 31/08/2025 15:29:22.21

=== Adapter summary (Name, Status, MAC, Speed) ===

Name                         InterfaceDescription                     Status       MacAddress        LinkSpeed
----                         --------------------                     ------       ----------        ---------
Bluetooth Network Connection Bluetooth Device (Personal Area Network) Disconnected XXXXXXXXXXXXXXXXXXXX 3 Mbps   
Ethernet                     Realtek PCIe GbE Family Controller       Up           XXXXXXXXXXXXXXXXXXXX 1 Gbps   
Wi-Fi                        RZ608 Wi-Fi 6E 80MHz                     Disconnected XXXXXXXXXXXXXXXXXXXX 0 bps    




=== DNS servers per interface (IPv4 and IPv6) ===
Bluetooth Network Connection        IPv4  
Bluetooth Network Connection        IPv6  
Ethernet                            IPv4  XXXXXXXXXXXX, XXXXXXXXXXXX
Ethernet                            IPv6  
Local Area Connection* 1            IPv4  
Local Area Connection* 1            IPv6  
Local Area Connection* 2            IPv4  
Local Area Connection* 2            IPv6  
Loopback Pseudo-Interface 1         IPv4  
Loopback Pseudo-Interface 1         IPv6  fec0:0:0:ffff::1, fec0:0:0:ffff::2, fec0:0:0:ffff::3
Wi-Fi                               IPv4  
Wi-Fi                               IPv6  

=== ipconfig /all (raw) ===

Windows IP Configuration

   Host Name . . . . . . . . . . . . : DESKTOP-XXXXXXX
   Primary Dns Suffix  . . . . . . . : 
   Node Type . . . . . . . . . . . . : Hybrid
   IP Routing Enabled. . . . . . . . : No
   WINS Proxy Enabled. . . . . . . . : No

Ethernet adapter Ethernet:

   Connection-specific DNS Suffix  . : 
   Description . . . . . . . . . . . : Realtek PCIe GbE Family Controller
   Physical Address. . . . . . . . . : XXXXXXXXXXXXXXXXXXXX
   DHCP Enabled. . . . . . . . . . . : Yes
   Autoconfiguration Enabled . . . . : Yes
   IPv4 Address. . . . . . . . . . . : 192.168.50.23(Preferred) 
   Subnet Mask . . . . . . . . . . . : 255.255.255.0
   Lease Obtained. . . . . . . . . . : Sunday, 31 August 2025 06:59:59
   Lease Expires . . . . . . . . . . : Sunday, 31 August 2025 16:59:58
   Default Gateway . . . . . . . . . : 192.168.50.1
   DHCP Server . . . . . . . . . . . : 192.168.50.1
   DNS Servers . . . . . . . . . . . : 1.1.1.1
                                       8.8.8.8
   NetBIOS over Tcpip. . . . . . . . : Enabled

Wireless LAN adapter Wi-Fi:

   Media State . . . . . . . . . . . : Media disconnected
   Connection-specific DNS Suffix  . : 
   Description . . . . . . . . . . . : RZ608 Wi-Fi 6E 80MHz
   Physical Address. . . . . . . . . : XXXXXXXXXXXXXXXXXXXX
   DHCP Enabled. . . . . . . . . . . : Yes
   Autoconfiguration Enabled . . . . : Yes

Wireless LAN adapter Local Area Connection* 1:

   Media State . . . . . . . . . . . : Media disconnected
   Connection-specific DNS Suffix  . : 
   Description . . . . . . . . . . . : Microsoft Wi-Fi Direct Virtual Adapter
   Physical Address. . . . . . . . . : XXXXXXXXXXXXXXXXXXXX
   DHCP Enabled. . . . . . . . . . . : Yes
   Autoconfiguration Enabled . . . . : Yes

Wireless LAN adapter Local Area Connection* 2:

   Media State . . . . . . . . . . . : Media disconnected
   Connection-specific DNS Suffix  . : 
   Description . . . . . . . . . . . : Microsoft Wi-Fi Direct Virtual Adapter #2
   Physical Address. . . . . . . . . : XXXXXXXXXXXXXXXXXXXX
   DHCP Enabled. . . . . . . . . . . : Yes
   Autoconfiguration Enabled . . . . : Yes

Ethernet adapter Bluetooth Network Connection:

   Media State . . . . . . . . . . . : Media disconnected
   Connection-specific DNS Suffix  . : 
   Description . . . . . . . . . . . : Bluetooth Device (Personal Area Network)
   Physical Address. . . . . . . . . : XXXXXXXXXXXXXXXXXXXX
   DHCP Enabled. . . . . . . . . . . : Yes
   Autoconfiguration Enabled . . . . : Yes
```

## Troubleshooting
- If you see empty IPv4/IPv6 DNS lines for an adapter, that interface likely has no DNS configured for that family, or it’s disconnected.
- If `Get-NetAdapter`/`Get-DnsClientServerAddress` aren’t found, ensure you’re on Windows 10/11 (or Server 2016+) where the NetTCPIP module is available by default.

