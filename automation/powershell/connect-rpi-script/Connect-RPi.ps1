<#
.SYNOPSIS
    Поиск устройства по MAC и подключение по SSH
.DESCRIPTION
    1. Raspberry Pi  (aa-bb-cc-dd-ee-01)  -> piuser
    2. Local server  (aa-bb-cc-dd-ee-02)  -> srvuser
    0. Enter MAC manually
.EXAMPLE
    .\Connect-Device.ps1                  # interactive menu
    .\Connect-Device.ps1 -Mac aa-bb-cc-dd-ee-02 -User srvuser
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$MacAddress = "aa-bb-cc-dd-ee-01",

    [Parameter(Mandatory = $false)]
    [string]$User = "piuser",

    [Parameter(Mandatory = $false)]
    [string]$Gateway = "192.168.1.1",

    [Parameter(Mandatory = $false)]
    [string]$Network = "192.168.1"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# -------------------------- DEVICE DB ----------------------------
$DeviceDb = @{
    "aa-bb-cc-dd-ee-01" = "piuser"
    "aa-bb-cc-dd-ee-02" = "srvuser"
}
# -------------------------- FUNCTIONS ----------------------------
function Write-Log {
    param([string]$Text)
    Write-Host ("[{0:yyyy-MM-dd HH:mm:ss}]  {1}" -f (Get-Date), $Text)
}

function Get-IpByMac {
    param([string]$Mac)
    $arp = arp -a 2>$null
    ($arp | Select-String $Mac | ForEach-Object {
        ($_.ToString().Trim() -split '\s+')[0]
    })[0]
}

function Invoke-NetworkScan {
    Write-Log "Parallel ping sweep $Network.1-254 (30 s timeout)"
    $jobs = 1..254 | ForEach-Object {
        Start-Job -ScriptBlock {
            param($Ip)
            if (Test-Connection $Ip -Count 1 -Quiet -ErrorAction SilentlyContinue) { $Ip }
        } -ArgumentList "$Network.$_"
    }
    $null = $jobs | Wait-Job -Timeout 30
    $jobs | Stop-Job -PassThru | Remove-Job -Force
}

# -------------------------- INTERACTIVE --------------------------
if (-not $PSBoundParameters.ContainsKey('MacAddress') -or
    $MacAddress -eq 'aa-bb-cc-dd-ee-01') {

    do {
        Write-Host "`nSelect device:"
        Write-Host "1. Raspberry Pi  (aa-bb-cc-dd-ee-01)"
        Write-Host "2. Local server  (aa-bb-cc-dd-ee-02)"
        Write-Host "0. Enter MAC manually"
        $c = Read-Host "Choice (0-2)"

        $ok = $true
        switch ($c) {
            '1' { $MacAddress = 'aa-bb-cc-dd-ee-01'; $User = 'piuser' }
            '2' { $MacAddress = 'aa-bb-cc-dd-ee-02'; $User = 'srvuser' }
            '0' { $MacAddress = Read-Host "MAC (xx-xx-xx-xx-xx-xx)" }
            default { Write-Host "Invalid choice"; $ok = $false }
        }
    } while (-not $ok)
}

# -------------------------- RESOLVE IP ---------------------------
Write-Log "Updating ARP table"
Test-Connection $Gateway -Count 2 -Quiet | Out-Null

Write-Log "Resolving MAC: $MacAddress"
$ip = Get-IpByMac -Mac $MacAddress

if (-not $ip) {
    Write-Log "Device not found"
    $ans = Read-Host "Scan network $Network.1-254? (y/n)"
    if ($ans -ne 'y') { exit 1 }

    Invoke-NetworkScan
    $ip = Get-IpByMac -Mac $MacAddress
    if (-not $ip) {
        Write-Log "Device still not found"
        exit 1
    }
    Write-Log "Found after scan: $ip"
} else {
    Write-Log "Found: $ip"
}

# -------------------------- SSH ----------------------------------
Write-Log "SSH to $User@$ip"
ssh "$User@$ip"
Write-Log "SSH session closed"
exit 0
