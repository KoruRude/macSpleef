#Mac Address spoof/connector (with loop)
write-host "      __        __   ___     __       __  ___  ___        __ "
write-host "|__/ |__) |  | |  \ |__     /__  \ / /__   |  |__   |\/| /__ "
write-host "|  \ |  \ \__/ |__/ |___    .__/  |  .__/  |  |___  |  | .__/"
write-host "https://krude-systems.net/redirect.html"
write-host "Mac Address spoof/connector (with loop) - 21Jan2026"
write-host ""
# Requires -RunAsAdministrator

#hide hostname
net config server /Hidden:Yes

write-host "NOTE: I would strongly recomend changeing the device hostname before running this as it will try to hide it but if it fails then the device could be known by the hostname. You could always do 'DESKTOP-[random numbers/letters]' or specify a known hostname already on your network." -ForegroundColor Yellow

$loopCount = Read-Host -Prompt "Please enter number of times to loop"
write-host "Would you like the mfg prefix to be selected from a confirmed working pool(p) [y/n]"
$randomOrNot = Read-Host -Prompt "(default is y)"
$successfullMacs = ""

#main loop
for ($mainLoop; $mainLoop -le $loopCount; $mainLoop++){
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
    function Get-RandomMacAddress {
        if ($randomOrNot -contains "n"){
            $mac = "{0:X2}" -f (Get-Random -Minimum 0 -Maximum 256)

            for ($i = 0; $i -lt 5; $i++){
                $mac += "-" + "{0:X2}" -f (Get-Random -Minimum 0 -Maximum 256)
            }
            return $mac
        } else {
            #get prefix list
            write-host $args[0]
            switch (Get-Random -Minimum 0 -Maximum 3){ #for better efficiency in default or prefix mode, set these to confirmed successfull mac prefixes for your card as some mac prefixes dont work
                '0' { $mac = "02-BD-45" } 
                '1' { $mac = "36-85-B0" } 
                '2' { $mac = "56-38-F9" } 
                '3' { $mac = "56-38-F9" } 
            }

            for ($i = 0; $i -lt 3; $i++){
                $mac += "-" + "{0:X2}" -f (Get-Random -Minimum 0 -Maximum 256)
            }
            return $mac
        }
    }

    $newMac = (Get-RandomMacAddress $args)
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
    $skipSleep = $false
    if ($mac -eq $newMac){
        Write-Host "Mac address change successfull!" -ForegroundColor Green
        write-Host "New Mac: $newMac"
        $successfullMacs = $successfullMacs + $newMac + "; "
        write-host "Successfull Macs: $successfullMacs"
        
    } else  {
        Write-host "WARN: Mac address did not take! Try different MAC or use confirm working mfg prefix?" -ForegroundColor Yellow
        write-host "Attempted new mac: $newMac"
        Write-Host "Current mac: $mac"
        Write-Host "Switching to full random, de-incrementing loop, skipping sleep..."
        $randomOrNot = n
        $mainLoop = $mainLoop - 1
        $skipSleep = $true
    }
    if ($mainLoop -le $loopCount){
        write-host "Waiting 20 seconds" -NoNewLine
        $delayLoop = 0
        for ($delayLoop; $delayLoop -le 21; $delayLoop++){
            write-host "." -NoNewline
            start-sleep 1
        }
        write-host "."
    }
}

write-host "Successfull Macs: $successfullMacs"
write-host "Completed!"