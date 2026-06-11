param(
  [string]$InstallDir = $env:ATLAS_INSTALL_DIR,
  [string]$Version = $env:ATLAS_VERSION,
  [switch]$NoPath
)

$ErrorActionPreference = "Stop"

$Repo = if ($env:ATLAS_RELEASE_REPO) { $env:ATLAS_RELEASE_REPO } else { "AtlasCloudAI/cli" }
$VersionUrl = if ($env:ATLAS_VERSION_URL) { $env:ATLAS_VERSION_URL } else { "https://raw.githubusercontent.com/$Repo/main/VERSION" }

function Normalize-Version {
  param([string]$RawVersion)

  $Normalized = ($RawVersion -replace "\s", "") -replace "^v", ""
  if ([string]::IsNullOrWhiteSpace($Normalized) -or $Normalized -notmatch "^[0-9]" -or $Normalized.Contains("/") -or $Normalized.Contains("\")) {
    throw "Invalid Atlas CLI version: $RawVersion"
  }
  return $Normalized
}

if ([string]::IsNullOrWhiteSpace($Version)) {
  try {
    $Version = Normalize-Version -RawVersion (Invoke-WebRequest -UseBasicParsing -Uri $VersionUrl).Content
  } catch {
    throw "Could not resolve latest Atlas CLI version from ${VersionUrl}. Pass -Version 0.1.14 or set ATLAS_VERSION. $($_.Exception.Message)"
  }
} else {
  $Version = Normalize-Version -RawVersion $Version
}

$Tag = "v$Version"
if ([string]::IsNullOrWhiteSpace($InstallDir)) {
  $LocalAppData = if ($env:LOCALAPPDATA) { $env:LOCALAPPDATA } else { Join-Path $HOME "AppData\Local" }
  $InstallDir = Join-Path $LocalAppData "AtlasCloud\bin"
}

$ProcessorArch = if ($env:PROCESSOR_ARCHITEW6432) {
  $env:PROCESSOR_ARCHITEW6432
} else {
  $env:PROCESSOR_ARCHITECTURE
}

switch -Regex ($ProcessorArch) {
  "^(AMD64|x86_64)$" { $Arch = "amd64"; break }
  "^(ARM64|AARCH64)$" { $Arch = "arm64"; break }
  default { throw "Unsupported Windows architecture: $ProcessorArch" }
}

$ArchiveName = "cli_${Version}_windows_${Arch}.zip"
$ReleaseBase = "https://github.com/$Repo/releases/download/$Tag"
$ArchiveUrl = "$ReleaseBase/$ArchiveName"
$ChecksumsUrl = "$ReleaseBase/checksums.txt"
$TempDir = Join-Path ([System.IO.Path]::GetTempPath()) "atlas-installer-$([System.Guid]::NewGuid())"
$ArchivePath = Join-Path $TempDir $ArchiveName
$ChecksumsPath = Join-Path $TempDir "checksums.txt"
$ExtractDir = Join-Path $TempDir "extract"

function Download-File {
  param(
    [string]$Uri,
    [string]$OutFile
  )

  Invoke-WebRequest -UseBasicParsing -Uri $Uri -OutFile $OutFile
}

function Get-ExpectedChecksum {
  param(
    [string]$ChecksumsFile,
    [string]$FileName
  )

  foreach ($Line in Get-Content -LiteralPath $ChecksumsFile) {
    $Parts = @($Line -split "\s+" | Where-Object { $_ })
    if ($Parts.Count -ge 2 -and $Parts[-1] -eq $FileName) {
      return $Parts[0].ToLowerInvariant()
    }
  }

  throw "Checksum for $FileName not found."
}

function Add-ToUserPath {
  param([string]$Directory)

  $Current = [Environment]::GetEnvironmentVariable("Path", "User")
  $Segments = @()
  if (-not [string]::IsNullOrWhiteSpace($Current)) {
    $Segments = @($Current -split ";" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
  }

  $Target = $Directory.TrimEnd("\")
  foreach ($Segment in $Segments) {
    if ($Segment.TrimEnd("\") -ieq $Target) {
      return $false
    }
  }

  $NextPath = if ([string]::IsNullOrWhiteSpace($Current)) {
    $Directory
  } else {
    "$Current;$Directory"
  }
  [Environment]::SetEnvironmentVariable("Path", $NextPath, "User")
  $env:Path = "$Directory;$env:Path"
  return $true
}

try {
  New-Item -ItemType Directory -Force -Path $TempDir, $ExtractDir, $InstallDir | Out-Null

  Write-Host "Downloading $ArchiveUrl"
  Download-File -Uri $ArchiveUrl -OutFile $ArchivePath
  Download-File -Uri $ChecksumsUrl -OutFile $ChecksumsPath

  $Expected = Get-ExpectedChecksum -ChecksumsFile $ChecksumsPath -FileName $ArchiveName
  $Actual = (Get-FileHash -Algorithm SHA256 -LiteralPath $ArchivePath).Hash.ToLowerInvariant()
  if ($Actual -ne $Expected) {
    throw "Checksum mismatch for ${ArchiveName}: expected $Expected, got $Actual"
  }

  Expand-Archive -LiteralPath $ArchivePath -DestinationPath $ExtractDir -Force
  $Binary = Get-ChildItem -LiteralPath $ExtractDir -Recurse -Filter "atlas.exe" | Select-Object -First 1
  if (-not $Binary) {
    throw "atlas.exe not found in $ArchiveName"
  }

  $Target = Join-Path $InstallDir "atlas.exe"
  Copy-Item -LiteralPath $Binary.FullName -Destination $Target -Force

  $PathChanged = $false
  if (-not $NoPath -and $env:ATLAS_NO_PATH -ne "1") {
    $PathChanged = Add-ToUserPath -Directory $InstallDir
  }

  if ($env:ATLAS_TELEMETRY -eq "1") {
    $TelemetryUrl = "https://api.atlascloud.ai/i/v1?os=windows&arch=$Arch&version=$Version&products=atlas&channel=installps1"
    try {
      Invoke-WebRequest -UseBasicParsing -Uri $TelemetryUrl | Out-Null
    } catch {
      # Telemetry is opt-in and must never make installation fail.
    }
  }

  Write-Host ""
  Write-Host "Installed: atlas"
  Write-Host "  $Target"
  if ($PathChanged) {
    Write-Host ""
    Write-Host "Added to user PATH. Open a new terminal if 'atlas' is not found in the current session."
  }
  Write-Host ""
  Write-Host "Next: atlas auth login"
} finally {
  if (Test-Path -LiteralPath $TempDir) {
    Remove-Item -LiteralPath $TempDir -Recurse -Force -ErrorAction SilentlyContinue
  }
}
