param(
    [Parameter(Mandatory=$false)]
    [string]$MacAddress = "b8-27-eb-87-d4-6b",
    
    [Parameter(Mandatory=$false)]
    [string]$Username = "TopUserServer",
    
    [Parameter(Mandatory=$false)]
    [string]$Gateway = "192.168.1.1"
)

<#
.SYNOPSIS
    Connects to Raspberry Pi via SSH by MAC address discovery
.DESCRIPTION
    Finds Raspberry Pi in local network by MAC address and connects via SSH
#>

# ==================== SETTINGS ====================
# You can quickly change MAC addresses and other parameters here

# Default MAC address for search
$DefaultMacAddress = "b8-27-eb-87-d4-6b"

# Alternative MAC addresses (for different devices)
$AlternativeDevices = @{
    "Raspberry_Pi_1" = "b8-27-eb-87-d4-6b"
    "Raspberry_Pi_2" = "dc-a6-32-00-00-00"  # Example for RPi 4
    "Raspberry_Pi_3" = "e4-5f-01-00-00-00"  # Example for RPi 3B+
    "My_Laptop"      = "00-11-22-33-44-55"  # Example for laptop
    "Work_PC"        = "aa-bb-cc-dd-ee-ff"  # Example for work PC
}

# Connection parameters
$DefaultUsername = "TopUserServer"
$DefaultGateway = "192.168.1.1"
$NetworkRange = "192.168.1"  # Will scan 192.168.1.1-254

# ===================================================

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message"
}

function Show-DeviceList {
    Write-Host ""
    Write-Host "=== Available devices for search ===" -ForegroundColor Cyan
    Write-Host "1. Main device (MAC: $DefaultMacAddress)" -ForegroundColor Yellow
    $index = 2
    foreach ($device in $AlternativeDevices.GetEnumerator()) {
        Write-Host "$index. $($device.Key) (MAC: $($device.Value))" -ForegroundColor Green
        $index++
    }
    Write-Host "0. Enter MAC address manually" -ForegroundColor Magenta
    Write-Host "===================================" -ForegroundColor Cyan
    Write-Host ""
}

# Validate prerequisites
if (-not (Get-Command ssh -ErrorAction SilentlyContinue)) {
    Write-Error "SSH client not found. Please install OpenSSH client."
    exit 1
}

try {
    Write-Log "Updating ARP table... Pinging gateway: $Gateway"
    if ($Gateway) {
        $pingResult = Test-Connection -ComputerName $Gateway -Count 2 -Quiet
        if (-not $pingResult) {
            Write-Warning "Gateway ping failed, but continuing..."
        }
    }
} catch {
    Write-Warning "Error pinging gateway: $($_.Exception.Message)"
}

# Get MAC address for search
$targetMac = $MacAddress
$manualChoice = $false

if ($MacAddress -eq $DefaultMacAddress -and -not $PSBoundParameters.ContainsKey('MacAddress')) {
    # If default MAC is used and parameter wasn't passed, ask user
    Show-DeviceList
    $choice = Read-Host "Select device to search (0-$($AlternativeDevices.Count + 1))"
    
    switch ($choice) {
        "1" { 
            $targetMac = $DefaultMacAddress
            Write-Log "Selected main device: $targetMac"
        }
        "0" { 
            $targetMac = Read-Host "Enter MAC address in format xx-xx-xx-xx-xx-xx"
            $manualChoice = $true
            Write-Log "Manual MAC address entered: $targetMac"
        }
        default {
            $index = [int]$choice - 2
            $deviceKeys = $AlternativeDevices.Keys | Sort-Object
            if ($index -ge 0 -and $index -lt $deviceKeys.Count) {
                $selectedKey = $deviceKeys[$index]
                $targetMac = $AlternativeDevices[$selectedKey]
                Write-Log "Selected device '$selectedKey': $targetMac"
            } else {
                Write-Warning "Invalid choice, using default MAC"
                $targetMac = $DefaultMacAddress
            }
        }
    }
}

# Get ARP table
Write-Log "Searching for device with MAC: $targetMac"
$arpOutput = arp -a 2>$null

# Check exit code and display arp -a on error
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Error "Failed to execute arp command. Current ARP table:" -ForegroundColor Red
    Write-Host "=== ARP TABLE OUTPUT ===" -ForegroundColor Red
    arp -a | Write-Host -ForegroundColor Red
    Write-Host "=== END ARP TABLE ===" -ForegroundColor Red
    Write-Host ""
    exit 1
}

$arpLines = $arpOutput | Select-String -Pattern $targetMac -CaseSensitive

if ($arpLines) {
    $line = $arpLines.Line.Trim()
    $parts = ($line -split '\s+') | Where-Object { $_ -ne '' }
    $ip = $parts[0]

    Write-Host ""
    Write-Host "✅ Device found!" -ForegroundColor Green
    Write-Host "IP: $ip" -ForegroundColor Yellow
    Write-Host "MAC: $targetMac" -ForegroundColor Yellow
    Write-Host ""

    Write-Log "Connecting via SSH: $Username@$ip..."
    
    # Execute SSH connection
    ssh "$Username@$ip"
    
    Write-Log "SSH session ended."
} else {
    Write-Host ""
    Write-Warning "Device not found in network."
    Write-Host "Check:" -ForegroundColor Yellow
    Write-Host "  - Is device powered on?" -ForegroundColor Red
    Write-Host "  - Is it connected to network?" -ForegroundColor Red
    Write-Host "  - Correct MAC address: $targetMac" -ForegroundColor Red
    Write-Host ""
    
    # Display ARP table for debugging
    Write-Host "Current ARP table for debugging:" -ForegroundColor Red
    Write-Host "================================" -ForegroundColor Red
    arp -a | Write-Host
    Write-Host "================================" -ForegroundColor Red
    Write-Host ""

    # Offer user to run full network scan
    $scanChoice = Read-Host "Run network scan ($NetworkRange.1-254)? (yes/no)"
    
    if ($scanChoice -match "^(yes|y)$") {
        Write-Log "Starting fast network scan ($NetworkRange.1 - $NetworkRange.254)..."
        
        # Create jobs for parallel ping
        $jobs = @()
        1..254 | ForEach-Object {
            $ip = "$NetworkRange.$_"
            $jobs += Start-Job -ScriptBlock {
                param($ip)
                if (Test-Connection -ComputerName $ip -Count 1 -Quiet -ErrorAction SilentlyContinue) {
                    Write-Host "Active: $ip" -ForegroundColor Green
                    return $ip
                }
            } -ArgumentList $ip
        }
        
        # Wait for all jobs with timeout
        Write-Host "Scanning network... Please wait (timeout: 30 seconds)." -ForegroundColor Yellow
        $completedJobs = $jobs | Wait-Job -Timeout 30
        
        # Collect results only from completed jobs
        $results = @()
        foreach ($job in $completedJobs) {
            if ($job.State -eq 'Completed') {
                $result = Receive-Job -Job $job
                if ($result) {
                    $results += $result
                }
            }
        }
        
        # Stop and remove all jobs (including unfinished ones)
        $jobs | Stop-Job -ErrorAction SilentlyContinue
        $jobs | Remove-Job -Force
        
        Write-Log "Network scan completed. Found $($results.Count) active hosts."
        
        Write-Log "Re-checking ARP table after scan..."

        # Update ARP table after scanning
        $arpOutput = arp -a 2>$null
        $arpLines = $arpOutput | Select-String -Pattern $targetMac -CaseSensitive

        if ($arpLines) {
            $line = $arpLines.Line.Trim()
            $parts = ($line -split '\s+') | Where-Object { $_ -ne '' }
            $ip = $parts[0]

            Write-Host ""
            Write-Host "✅ Device found after scan!" -ForegroundColor Green
            Write-Host "IP: $ip" -ForegroundColor Yellow
            Write-Host "MAC: $targetMac" -ForegroundColor Yellow
            Write-Host ""

            Write-Log "Connecting via SSH: $Username@$ip..."
            ssh "$Username@$ip"
            Write-Log "SSH session ended."
        } else {
            Write-Host ""
            Write-Warning "Device still not found after scan."
            Write-Host "Verify MAC address or physical connection." -ForegroundColor Red
            Write-Host ""
            
            # Display ARP table after scanning
            Write-Host "ARP table after scan:" -ForegroundColor Red
            Write-Host "=====================" -ForegroundColor Red
            arp -a | Write-Host
            Write-Host "=====================" -ForegroundColor Red
            Write-Host ""
        }
    } else {
        Write-Host "Network scan skipped by user."
    }
}
