# Setup Flutter project for SoftEther VPN Client
# Run this script to initialize the Flutter project

# Check if Flutter is installed
$flutterPath = Get-Command flutter -ErrorAction SilentlyContinue

if ($null -eq $flutterPath) {
    Write-Host "Flutter SDK not found. Please install Flutter first." -ForegroundColor Red
    Write-Host "Visit: https://flutter.dev/docs/get-started/install/windows" -ForegroundColor Yellow
    exit 1
}

# Navigate to the flutter client directory
$projectDir = Join-Path $PSScriptRoot "flutter_client"
Set-Location -Path $projectDir

# Initialize Flutter project (if not already initialized)
if (-not (Test-Path "pubspec.lock")) {
    Write-Host "Initializing Flutter project..." -ForegroundColor Green
    flutter create --platforms=android,ios --org com.softethervpn .
}

# Get dependencies
Write-Host "Getting Flutter dependencies..." -ForegroundColor Green
flutter pub get

# Create ios directory if it doesn't exist
$iosDir = Join-Path $projectDir "ios"
if (-not (Test-Path $iosDir)) {
    New-Item -Path $iosDir -ItemType Directory | Out-Null
}

# Create directories for iOS Swift files
$iosSwiftDir = Join-Path $iosDir "Runner" | Join-Path -ChildPath "SoftEtherVPN"
if (-not (Test-Path $iosSwiftDir)) {
    New-Item -Path $iosSwiftDir -ItemType Directory -Force | Out-Null
}

# Copy Swift VPN implementation files to the iOS directory
$swiftSrcDir = Join-Path $PSScriptRoot "SoftEtherVPN-iOS"

if (Test-Path $swiftSrcDir) {
    Write-Host "Copying Swift VPN implementation files..." -ForegroundColor Green
    
    # Get all Swift files that implement the VPN functionality
    $swiftFiles = Get-ChildItem -Path $swiftSrcDir -Filter "*.swift" -Recurse
    
    foreach ($file in $swiftFiles) {
        $destPath = Join-Path $iosSwiftDir $file.Name
        Copy-Item -Path $file.FullName -Destination $destPath -Force
    }
}

# Run Flutter doctor to check setup
Write-Host "Checking Flutter setup..." -ForegroundColor Green
flutter doctor

Write-Host "Setup complete!" -ForegroundColor Green
Write-Host "To run the app on an Android device or emulator: flutter run" -ForegroundColor Yellow
Write-Host "To build the app for iOS, you'll need a Mac for final compilation." -ForegroundColor Yellow
Write-Host "You can develop the UI and Android version fully on Windows." -ForegroundColor Yellow
