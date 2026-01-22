#Mac Address spoof/connector
write-host "      __        __   ___     __       __  ___  ___        __ "
write-host "|__/ |__) |  | |  \ |__     /__  \ / /__   |  |__   |\/| /__ "
write-host "|  \ |  \ \__/ |__/ |___    .__/  |  .__/  |  |___  |  | .__/"
write-host "https://krude-systems.net/redirect.html"
write-host "Mac Address spoof/connector - 21Jan2026"
write-host ""

#hide hostname
write-host "NOTE: This is an attempt and is not guaranteed to actually hide your hostname if you need anonymity I would strongly recomend temporarily changeing your hostname. You could always do 'DESKTOP-[random numbers/letters]' or specify a known hostname already on your network." -ForegroundColor Yellow
$input = Read-Host -Prompt "Hide/Show hostname to network [h/s (h-default)]"
if ($input -contains "s"){
    net config server /Hidden:No
} else {
    net config server /Hidden:Yes
}

$input = Read-Host -Prompt "Would you like the new mac to be random or specified [r/s]?"
$input2 = Read-Host -Prompt "Would you like the mfg prefix to be selected from a confirmed working pool [y/n]?"


if ($input -contains "s"){
    if ($input2 -contains "n"){
        $mac = Read-Host -Prompt "Enter new mac address [XX-XX-XX-XX-XX-XX]"
    } else {
        $mac = Read-Host -Prompt "Enter new mac address suffix [XX-XX-XX]"
    }
} else {
}

# Get WiFi adapter
$adapter = Get-NetAdapter | Where-Object {$_.Name -like "*Wi-Fi*" -or $_.Name -like "*Wireless*"}
if (-not $adapter) {
    Write-Host "WiFi adapter not found!" -ForegroundColor Red
    exit
}

$startingAdapter = $adapter.MacAddress

Write-Host "Using adapter: $($adapter.Name)" -ForegroundColor Green
Write-Host "Current MAC: $($adapter.MacAddress)" -ForegroundColor Cyan

# Generate random MAC address
function Get-NewMacAddress {
    if (!$input2 -contains "n"){
        #XX-XX-XX-XX-XX-XX
        if ($input -contains "s"){
            return $mac
        } else {
            $mac = "{0:X2}" -f (Get-Random -Minimum 0 -Maximum 256)

            for ($i = 0; $i -lt 5; $i++){
                $mac += "-" + "{0:X2}" -f (Get-Random -Minimum 0 -Maximum 256)
            }
            return $mac
        }
    } else {
        #XX-XX-XX
        $macTmp = $mac
        #get prefix list
        write-host $args[0]
        switch (Get-Random -Minimum 0 -Maximum 3){
            '0' { $mac = "02-BD-45" } 
            '1' { $mac = "36-85-B0" } 
            '2' { $mac = "56-38-F9" } 
            '3' { $mac = "56-38-F9" } 
        }
        if ($input2 -contains "s"){
            $mac = $mac + '-' + $macTmp
            return $mac
        } else {
            for ($i = 0; $i -lt 3; $i++){
                $mac += "-" + "{0:X2}" -f (Get-Random -Minimum 0 -Maximum 256)
            }
            return $mac
        }
    }
}

$loop = $true
while ($loop){
    $newMac = (Get-NewMacAddress)
    Write-Host "Confirm change to mac address: $newMac"
    $response = Read-Host -Prompt "Confirm [y] Re-Randomize [r] Quit [q]"
    switch ($response){
        'y' { $loop = $false }
        'r' { $loop = $true }
        'q' { exit }
    }
}

Write-Host "New MAC will be: $newMac" -ForegroundColor Yellow

# Disable adapter
Write-Host "Disabling adapter..." -ForegroundColor Yellow
Disable-NetAdapter -Name $adapter.Name -Confirm:$false
Start-Sleep -Seconds 3

# Change MAC via Registry
Write-Host "Changing MAC address via registry..." -ForegroundColor Yellow
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}"
$found = $false

Get-ChildItem $regPath | ForEach-Object {
    $path = $_.PSPath
    $desc = (Get-ItemProperty -Path $path -Name "DriverDesc" -ErrorAction SilentlyContinue).DriverDesc
    
    if ($desc -eq $adapter.InterfaceDescription) {
        try {
            # Remove dashes for registry value
            #$macValue = $newMac -replace "-", ""
            $macValue = $newMac
            Set-ItemProperty -Path $path -Name "NetworkAddress" -Value $macValue -Type String
            Write-Host "MAC address updated successfully!" -ForegroundColor Green
            $found = $true
        }
        catch {
            Write-Host "Error updating registry: $_" -ForegroundColor Red
        }
    }
}

if (-not $found) {
    Write-Host "Could not find adapter in registry!" -ForegroundColor Red
    Enable-NetAdapter -Name $adapter.Name -Confirm:$false
    exit
}

# Re-enable adapter
Write-Host "Re-enabling adapter..." -ForegroundColor Yellow
Enable-NetAdapter -Name $adapter.Name -Confirm:$false
Start-Sleep -Seconds 5

#Verify
# Get WiFi adapter
$adapter = Get-NetAdapter | Where-Object {$_.Name -like "*Wi-Fi*" -or $_.Name -like "*Wireless*"}
if (-not $adapter) {
    Write-Host "WiFi adapter not found!" -ForegroundColor Red
    exit
}

$mac = $adapter.MacAddress
if ($mac -eq $newMac){
    Write-Host "Mac address change successfull!" -ForegroundColor Green
    write-Host "New Mac: $newMac"
} else  {
    Write-host "WARN: Mac address did not take! Try different MAC or use confirm working mfg prefix?" -ForegroundColor Yellow
    write-host "Attempted new mac: $newMac"
    Write-Host "Current mac: $mac"
}