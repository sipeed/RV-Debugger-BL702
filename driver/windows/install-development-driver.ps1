$ErrorActionPreference = 'Stop'

$driverDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$inf = Join-Path $driverDirectory 'bl702_winusb_rev0501.inf'
$catalog = Join-Path $driverDirectory 'bl702_winusb_rev0501.cat'
$certificateFile = Join-Path $driverDirectory 'bl702_winusb_development.cer'
$certificateSubject = 'CN=BL702 WinUSB Development Driver'
$bl702HardwareId = 'USB\VID_0403&PID_6010&REV_0501&MI_00'

$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]::new($identity)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'Run this script from an elevated PowerShell prompt.'
}

$bl702 = @(Get-PnpDevice -PresentOnly | Where-Object {
    $ids = @((Get-PnpDeviceProperty -InstanceId $_.InstanceId -KeyName 'DEVPKEY_Device_HardwareIds' -ErrorAction SilentlyContinue).Data)
    $ids -contains $bl702HardwareId
})
if ($bl702.Count -ne 1) {
    throw "Expected one connected BL702 interface A with REV_0501, found $($bl702.Count)."
}

$realFtdiBefore = @(Get-PnpDevice -PresentOnly | Where-Object {
    $ids = @((Get-PnpDeviceProperty -InstanceId $_.InstanceId -KeyName 'DEVPKEY_Device_HardwareIds' -ErrorAction SilentlyContinue).Data)
    $ids -contains 'USB\VID_0403&PID_6010&REV_0500&MI_00'
})
foreach ($device in $realFtdiBefore) {
    $service = (Get-PnpDeviceProperty -InstanceId $device.InstanceId -KeyName 'DEVPKEY_Device_Service').Data
    if ($service -ne 'FTDIBUS') {
        throw "Real FTDI precondition failed for $($device.InstanceId): service=$service"
    }
}

$inf2Cat = Get-ChildItem -LiteralPath 'C:\Program Files (x86)\Windows Kits\10\bin' `
    -Recurse -Filter Inf2Cat.exe -File -ErrorAction SilentlyContinue |
    Where-Object { $_.DirectoryName -like '*\x86' } |
    Sort-Object FullName -Descending |
    Select-Object -First 1 -ExpandProperty FullName
if (-not $inf2Cat) {
    throw 'Inf2Cat.exe was not found. Install the Windows Driver Kit first.'
}

& $inf2Cat /driver:$driverDirectory /os:10_X64
if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $catalog)) {
    throw "Inf2Cat failed with exit code $LASTEXITCODE."
}

$certificate = Get-ChildItem Cert:\LocalMachine\My |
    Where-Object { $_.Subject -eq $certificateSubject -and $_.HasPrivateKey } |
    Sort-Object NotAfter -Descending |
    Select-Object -First 1
if (-not $certificate) {
    $certificate = New-SelfSignedCertificate -Type CodeSigningCert `
        -Subject $certificateSubject -CertStoreLocation Cert:\LocalMachine\My `
        -KeyAlgorithm RSA -KeyLength 2048 -HashAlgorithm SHA256 `
        -NotAfter (Get-Date).AddYears(5)
}

Export-Certificate -Cert $certificate -FilePath $certificateFile -Force | Out-Null
Import-Certificate -FilePath $certificateFile -CertStoreLocation Cert:\LocalMachine\Root | Out-Null
Import-Certificate -FilePath $certificateFile -CertStoreLocation Cert:\LocalMachine\TrustedPublisher | Out-Null
$signature = Set-AuthenticodeSignature -FilePath $catalog -Certificate $certificate -HashAlgorithm SHA256
if ($signature.Status -ne 'Valid') {
    throw "Catalog signing failed: $($signature.Status) $($signature.StatusMessage)"
}

& pnputil.exe /add-driver $inf /install
if ($LASTEXITCODE -ne 0) {
    throw "pnputil failed with exit code $LASTEXITCODE."
}

Start-Sleep -Seconds 3
$bl702Service = (Get-PnpDeviceProperty -InstanceId $bl702[0].InstanceId -KeyName 'DEVPKEY_Device_Service').Data
if ($bl702Service -ne 'WinUSB') {
    throw "BL702 postcondition failed: service=$bl702Service"
}
foreach ($device in $realFtdiBefore) {
    $service = (Get-PnpDeviceProperty -InstanceId $device.InstanceId -KeyName 'DEVPKEY_Device_Service').Data
    if ($service -ne 'FTDIBUS') {
        throw "Real FTDI postcondition failed for $($device.InstanceId): service=$service"
    }
}

Write-Output 'BL702 interface A now uses WinUSB. Real FTDI REV_0500 devices were not changed.'
