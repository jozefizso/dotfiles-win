function InjectDriversToWIM {
    # Copyright (c) 2025 Niklas Rast
    # https://niklasrast.io/blog/post-0078
    #

    Write-Host "This function will inject OEM drivers Windows install file." -ForegroundColor Yellow

    #Set USB path and check that install file(s) exist
    $usb = Read-Host -Prompt "Please enter drive path for pre-created windows install stick (for example: D:)"
    $wim = "$usb\sources\install.wim"
    $swm = "$usb\sources\install.swm"
    $installfile
    switch ($true) {
        { Test-Path $wim } { 
            Write-Host "Installer is WIM" -ForegroundColor Green
            $installfile = "wim"
        }
        { Test-Path $swm } { 
            Write-Host "Installer is SWM" -ForegroundColor Green
            $installfile = "swm"
        }
        Default { 
            Write-Host "There is no WIM or SWM file located at $usb\sources" -ForegroundColor Red; break
        }
    }

    #Set DRIVER path
    $driver = Read-Host -Prompt "Please enter path for enterprise driver pack (for example: C:\Data\drivers\x13_drivers)"
    if (Test-Path -Path $driver) {Write-Host "Found driver directory" -ForegroundColor Green} else {Write-Host "No valid driver directory path found!" -ForegroundColor Red}

    #Create Temp path
    New-Item -Path C:\ -Name Data-ItemType Directory -Force
    New-Item -Path C:\Data -Name temp -ItemType Directory -Force
    New-Item -Path C:\Data\temp\IMAGE -Name IMAGE -ItemType Directory -Force
    New-Item -Path C:\Data\temp\IMAGE -Name Source -ItemType Directory -Force
    New-Item -Path C:\Data\temp\IMAGE -Name Mount -ItemType Directory -Force 

    #Remove all SWM files from the Sources folder on the usb drive
    Move-Item -Path $usb\Sources\*.$installfile -Destination C:\Data\temp\IMAGE\Source -Force
    if (Test-Path -Path C:\Data\temp\IMAGE\Source\boot.wim) { Move-Item -Path C:\Data\temp\IMAGE\Source\boot.wim -Destination $usb\Sources\ -Force }
    switch ($installfile) {
        wim {Move-Item -Path C:\Data\temp\IMAGE\Source\install.wim -Destination C:\Data\temp\IMAGE\Source\install_org.wim -Force}
        swm {dism /export-image /sourceimagefile:C:\Data\temp\IMAGE\Source\install.$installfile /swmfile:C:\Data\temp\IMAGE\Source\install*.$installfile /sourceindex:1 /destinationimagefile:C:\Data\temp\IMAGE\Source\install_org.wim /Compress:max /CheckIntegrity}
    }
    
    #Get wim index number by choice
    Dism.exe /Get-WimInfo /WimFile:C:\Data\temp\IMAGE\Source\install_org.wim
    $index = Read-Host -Prompt "Please enter Index number where you want to inject drivers (for example 5)"

    #Extract needed version by Index number
    Dism.exe /Export-Image /SourceImageFile:C:\Data\temp\IMAGE\Source\install_org.wim /SourceIndex:$index /DestinationImageFile:C:\Data\temp\IMAGE\Source\install.wim
    Remove-Item -Path C:\Data\temp\IMAGE\Source\install_org.wim -Force

    #Inject drivers to WIM
    Dism.exe /Mount-Wim /WimFile:C:\Data\temp\IMAGE\Source\install.wim /Index:1 /MountDir:C:\Data\temp\IMAGE\Mount
    Dism.exe /Image:C:\Data\temp\IMAGE\Mount /Add-Driver /Driver:$driver /recurse
    Dism.exe /Unmount-Wim /MountDir:C:\Data\temp\IMAGE\Mount /Commit

    #Split WIM to SWM files
    Dism /Split-Image /ImageFile:C:\Data\temp\IMAGE\Source\install.wim /SWMFile:C:\Data\temp\IMAGE\install.swm /FileSize:3900

    #Move SWM files to usb
    Move-Item -Path C:\Data\temp\IMAGE\*.swm -Destination $usb\sources -Force

    #Cleanup
    Remove-Item -Path "C:\Data\temp\IMAGE" -Recurse -Force
}