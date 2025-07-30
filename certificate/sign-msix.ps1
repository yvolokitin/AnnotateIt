# --- CONFIGURATION ---
$certSubject = "CN=AnnotateItDevCert"
$certFriendlyName = "AnnotateIt Dev Cert"
$certFolder = "C:\repos\AnnotateIt\certificate"
$certPath = "$certFolder\annotateit_dev_cert.pfx"
$certPassword = ConvertTo-SecureString -String "1234" -Force -AsPlainText
$msixPath = "C:\repos\AnnotateIt\build\windows\x64\runner\Release\annotateit.msix"
$signtoolPath = "C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x64\signtool.exe"

# --- CHECK ADMIN ---
if (-not ([Security.Principal.WindowsPrincipal] `
  [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
  [Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "You must run this script as Administrator."
    exit 1
}

# --- CHECK PREREQUISITES ---
if (-not (Test-Path $msixPath)) {
    Write-Error ".msix file not found at: $msixPath"
    exit 1
}

if (-not (Test-Path $signtoolPath)) {
    Write-Error "signtool.exe not found at: $signtoolPath"
    Write-Host "Make sure the Windows 10/11 SDK is installed."
    exit 1
}

# --- CREATE OUTPUT FOLDER ---
if (-not (Test-Path $certFolder)) {
    New-Item -ItemType Directory -Path $certFolder | Out-Null
}

# --- CREATE CERTIFICATE ---
Write-Host "Creating self-signed certificate..."
try {
    $cert = New-SelfSignedCertificate `
        -Type Custom `
        -Subject $certSubject `
        -KeyUsage DigitalSignature `
        -KeyExportPolicy Exportable `
        -FriendlyName $certFriendlyName `
        -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.3") `
        -CertStoreLocation "Cert:\CurrentUser\My"
} catch {
    Write-Error "Failed to create certificate. Reason: $_"
    exit 1
}

# --- EXPORT CERTIFICATE ---
Write-Host "Exporting certificate to $certPath..."
try {
    Export-PfxCertificate `
        -Cert $cert `
        -FilePath $certPath `
        -Password $certPassword
} catch {
    Write-Error "Failed to export .pfx file. Reason: $_"
    exit 1
}

# --- INSTALL CERT TO TRUSTED PEOPLE ---
Write-Host "Installing certificate to TrustedPeople store..."
try {
    Import-PfxCertificate `
        -FilePath $certPath `
        -CertStoreLocation "Cert:\CurrentUser\TrustedPeople" `
        -Password $certPassword | Out-Null
} catch {
    Write-Error "Failed to import certificate. Reason: $_"
    exit 1
}

# --- SIGN THE MSIX ---
Write-Host "Signing .msix package..."
try {
    $thumbprint = $cert.Thumbprint
    & "$signtoolPath" sign /fd SHA256 /sha1 $thumbprint "$msixPath"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✅ Success! .msix file signed and ready for installation."
    } else {
        Write-Error "❌ signtool failed. Exit code: $LASTEXITCODE"
        exit 1
    }
} catch {
    Write-Error "❌ signtool failed to sign the .msix file. Reason: $_"
    exit 1
}
