# Fetches CC0 PBR texture sets from ambientCG and converts them to the PNG
# layout the game expects inside assets/textures_cc0/:
#
#   <name>.png         albedo
#   <name>_normal.png  OpenGL normal map
#   <name>_rough.png   roughness
#   <name>_ao.png      ambient occlusion (when the set provides one)
#
# ambientCG publishes every asset under CC0 1.0 (public domain), so these files
# can be shipped with the game. The game also works without this folder: it
# falls back to the procedural textures in assets/textures/.
#
# Usage (from the project root):
#   powershell -ExecutionPolicy Bypass -File tools/fetch_cc0_textures.ps1

param(
    [string]$Dest = (Join-Path (Split-Path $PSScriptRoot -Parent) "assets\textures_cc0"),
    [string]$Work = (Join-Path $env:TEMP "triple-zero-cc0")
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
Add-Type -AssemblyName System.Drawing

$sets = @(
    @{ name = "concrete"; id = "Concrete034_1K-JPG"; ao = $false },
    @{ name = "asphalt";  id = "Asphalt012_1K-JPG";  ao = $false },
    @{ name = "metal";    id = "Metal032_1K-JPG";    ao = $false },
    @{ name = "brick";    id = "Bricks075A_1K-JPG";  ao = $true  },
    @{ name = "ground";   id = "Ground037_1K-JPG";   ao = $true  }
)

function Convert-JpgToPng([string]$src, [string]$dst) {
    if (-not (Test-Path $src)) { return $false }
    $img = [System.Drawing.Image]::FromFile($src)
    try {
        $img.Save($dst, [System.Drawing.Imaging.ImageFormat]::Png)
    } finally {
        $img.Dispose()
    }
    return $true
}

New-Item -ItemType Directory -Force -Path $Dest | Out-Null
New-Item -ItemType Directory -Force -Path $Work | Out-Null

foreach ($set in $sets) {
    $id = $set.id
    $zip = Join-Path $Work ($id + ".zip")
    $dir = Join-Path $Work $id
    if (-not (Test-Path $zip)) {
        Write-Host ("download " + $id)
        Invoke-WebRequest -Uri ("https://ambientcg.com/get?file=" + $id + ".zip") -OutFile $zip -TimeoutSec 180
    }
    if (-not (Test-Path $dir)) {
        Expand-Archive -Path $zip -DestinationPath $dir -Force
    }

    $base = Join-Path $dir $id
    $maps = @(
        @{ suffix = "";        file = "_Color.jpg" },
        @{ suffix = "_normal"; file = "_NormalGL.jpg" },
        @{ suffix = "_rough";  file = "_Roughness.jpg" }
    )
    if ($set.ao) {
        $maps += @{ suffix = "_ao"; file = "_AmbientOcclusion.jpg" }
    }

    foreach ($map in $maps) {
        $src = $base + $map.file
        $dst = Join-Path $Dest ($set.name + $map.suffix + ".png")
        if (Convert-JpgToPng $src $dst) {
            Write-Host ("  " + $set.name + $map.suffix + ".png")
        } elseif ($map.suffix -eq "_ao") {
            Write-Host ("  (no AO for " + $set.name + ")")
        } else {
            Write-Warning ("missing " + $src)
        }
    }
}

$license = @"
CC0 1.0 Universal (public domain) texture sets.

Source: ambientCG - https://ambientcg.com
  concrete : Concrete034  https://ambientcg.com/view?id=Concrete034
  asphalt  : Asphalt012   https://ambientcg.com/view?id=Asphalt012
  metal    : Metal032     https://ambientcg.com/view?id=Metal032
  brick    : Bricks075A   https://ambientcg.com/view?id=Bricks075A
  ground   : Ground037    https://ambientcg.com/view?id=Ground037

These files were downloaded at 1K JPG and converted to PNG without altering
their pixels. ambientCG releases them under CC0 1.0, so attribution is not
required; this notice is kept for provenance.

The game prefers this folder over assets/textures/ when both exist, and falls
back to the procedural placeholders when it is absent.
"@
Set-Content -Path (Join-Path $Dest "LICENSE.txt") -Value $license -Encoding UTF8

Write-Host ("textures CC0 -> " + $Dest)
