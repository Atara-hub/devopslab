<#
.SYNOPSIS
    Finds a device by MAC and opens an SSH session.

.DESCRIPTION
    1. Raspberry Pi  (b8-27-eb-87-d4-6b)  -> TopUserServer
    2. Local server  (3e-8b-7d-09-73-2e)  -> adminserver
    0. Enter MAC manually

.EXAMPLE
    .\Connect-Device.ps1                  # interactive menu
    .\Connect-Device.ps1 -Mac 3e-8b-7d-09-73-2e -User adminserver
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$MacAddress = "b8-27-eb-87-d4-6b",

    [Parameter(Mandatory = $false)]
    [string]$User = "TopUserServer",

    [Parameter(Mandatory = $false)]
    [string]$Gateway = "192.168.1.1",

    [Parameter(Mandatory = $false)]
    [string]$Network = "192.168.1"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ------------------------------------------------------------------
# Device base
# ------------------------------------------------------------------
$DeviceDb = @{
    "b8-27-eb-87-d4-6b" = "TopUserServer"
    "3e-8b-7d-09-73-2e" = "adminserver"
}

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

# ------------------------------------------------------------------
# Interactive device selector (only if MAC not passed explicitly)
# ------------------------------------------------------------------
if ($PSBoundParameters.ContainsKey('MacAddress') -and
    $MacAddress -ne 'b8-27-eb-87-d4-6b') {
    # MAC передан вручную — пропускаем меню
}
else {
    if (-not $PSBoundParameters.ContainsKey('MacAddress')) {
        do {
            Write-Host "`nSelect device:"
            Write-Host "1. Raspberry Pi  (b8-27-eb-87-d4-6b)"
            Write-Host "2. Local server  (3e-8b-7d-09-73-2e)"
            Write-Host "0. Enter MAC manually"
            $c = Read-Host "Choice (0-2)"

            $ok = $true
            switch ($c) {
                '1' { $MacAddress = 'b8-27-eb-87-d4-6b'; $User = 'TopUserServer' }
                '2' { $MacAddress = '3e-8b-7d-09-73-2e'; $User = 'adminserver' }
                '0' {
                    $MacAddress = Read-Host "MAC (xx-xx-xx-xx-xx-xx)"
                }
                default {
                    Write-Host "Invalid choice" ; $ok = $false
                }
            }
        } while (-not $ok)
    }
}

# ------------------------------------------------------------------
# Resolve IP
# ------------------------------------------------------------------
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
}
else {
    Write-Log "Found: $ip"
}

# ------------------------------------------------------------------
# SSH
# ------------------------------------------------------------------
Write-Log "SSH to $User@$ip"
ssh "$User@$ip"
Write-Log "SSH session closed"
exit 0
