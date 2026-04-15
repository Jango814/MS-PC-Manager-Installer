# Function to install winget if missing
function Ensure-Winget {
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "winget already installed"
        return
    }

    Write-Host "winget not found. Installing..."

    $bundle = "$env:TEMP\Microsoft.DesktopAppInstaller.msixbundle"
    $xaml = "$env:TEMP\Microsoft.UI.Xaml.appx"

    try {
        # Download dependencies
        Invoke-WebRequest -Uri "https://aka.ms/Microsoft.UI.Xaml.2.8.x64.appx" -OutFile $xaml -UseBasicParsing
        Add-AppxPackage -Path $xaml

        # Download winget (App Installer)
        Invoke-WebRequest -Uri "https://aka.ms/getwinget" -OutFile $bundle -UseBasicParsing
        Add-AppxPackage -Path $bundle

        Write-Host "winget installed successfully"

        # Refresh PATH / command availability
        Start-Sleep -Seconds 5
    }
    catch {
        Write-Error "Failed to install winget: $_"
        exit 1
    }
}

# Get current region
$currentRegion = Get-WinHomeLocation
Write-Host "Current Region Code:" $currentRegion.GeoId

# Set region to United States (GeoId = 244)
Set-WinHomeLocation -GeoId 244
Set-Culture en-US
Set-WinSystemLocale en-US

Write-Host "Region temporarily set to United States"

Start-Sleep -Seconds 5

# Ensure winget is installed
Ensure-Winget

# Install or update Microsoft PC Manager
if (Get-Command winget -ErrorAction SilentlyContinue) {
    winget install 9PM860492SZD -e --accept-package-agreements --accept-source-agreements
} else {
    Write-Error "winget still not available after install attempt"
}

Start-Sleep -Seconds 10

# Restore original region
Set-WinHomeLocation -GeoId $currentRegion.GeoId

Write-Host "Region restored to original setting"

exit 0
