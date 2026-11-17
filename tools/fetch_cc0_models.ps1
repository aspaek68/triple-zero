# Fetches CC0 glTF props from Poly Haven into assets/models_cc0/.
#
# Every Poly Haven asset is released under CC0 1.0 (public domain), so these
# models can ship with the game. Each logical prop gets its own folder:
#
#   assets/models_cc0/<name>/<name>.gltf   (renamed copy of the 1k glTF)
#   assets/models_cc0/<name>/<id>.bin
#   assets/models_cc0/<name>/textures/*.jpg
#
# The game looks these up before its own generated .glb props and falls back to
# procedural primitives when the folder is absent.
#
# Usage (from the project root):
#   powershell -ExecutionPolicy Bypass -File tools/fetch_cc0_models.ps1

param(
    [string]$Dest = (Join-Path (Split-Path $PSScriptRoot -Parent) "assets\models_cc0")
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# logical in-game prop name -> Poly Haven asset id
$sets = @(
    @{ name = "barrel";     id = "Barrel_01" },
    @{ name = "crate";      id = "old_military_crate" },
    @{ name = "streetlamp"; id = "street_lamp_01" },
    @{ name = "barrier";    id = "concrete_road_barrier" },
    @{ name = "dumpster";   id = "metal_trash_can" },
    @{ name = "planter";    id = "planter_box_01" }
)

function Save-File([string]$url, [string]$dst, [string]$md5) {
    $dir = Split-Path $dst -Parent
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    if (Test-Path $dst) {
        if (-not $md5) { return }
        $have = (Get-FileHash -Path $dst -Algorithm MD5).Hash.ToLower()
        if ($have -eq $md5.ToLower()) { return }
    }
    Invoke-WebRequest -Uri $url -OutFile $dst -TimeoutSec 300
    if ($md5) {
        $have = (Get-FileHash -Path $dst -Algorithm MD5).Hash.ToLower()
        if ($have -ne $md5.ToLower()) {
            throw ("md5 mismatch for " + $dst)
        }
    }
}

New-Item -ItemType Directory -Force -Path $Dest | Out-Null

foreach ($set in $sets) {
    $id = $set.id
    $name = $set.name
    $dir = Join-Path $Dest $name
    New-Item -ItemType Directory -Force -Path $dir | Out-Null

    Write-Host ("fetch " + $id + " -> " + $name)
    $files = Invoke-RestMethod -Uri ("https://api.polyhaven.com/files/" + $id) -TimeoutSec 60
    # The API nests the 1k entry one level down: gltf."1k".gltf.{url,include}.
    $gltf = $files.gltf.'1k'.gltf
    if (-not $gltf) {
        Write-Warning ($id + " has no 1k glTF")
        continue
    }

    # The glTF itself, renamed to the logical name so EnvBuilder can find it.
    $gltfDst = Join-Path $dir ($name + ".gltf")
    Save-File $gltf.url $gltfDst $gltf.md5

    # Buffers and textures, at the relative paths the glTF expects.
    foreach ($prop in $gltf.include.PSObject.Properties) {
        $rel = $prop.Name -replace '/', '\'
        $dst = Join-Path $dir $rel
        Save-File $prop.Value.url $dst $prop.Value.md5
    }
    Write-Host ("  " + $name + ".gltf + " + @($gltf.include.PSObject.Properties).Count + " file(s)")
}

$license = @"
CC0 1.0 Universal (public domain) 3D props.

Source: Poly Haven - https://polyhaven.com
  barrel     : Barrel_01            https://polyhaven.com/a/Barrel_01
  crate      : old_military_crate   https://polyhaven.com/a/old_military_crate
  streetlamp : street_lamp_01       https://polyhaven.com/a/street_lamp_01
  barrier    : concrete_road_barrier https://polyhaven.com/a/concrete_road_barrier
  dumpster   : metal_trash_can      https://polyhaven.com/a/metal_trash_can
  planter    : planter_box_01       https://polyhaven.com/a/planter_box_01

Downloaded as 1k glTF (binary + JPG textures) without altering the geometry.
Poly Haven releases these under CC0 1.0, so attribution is not required; this
notice is kept for provenance.

The game scales each prop to its in-game height, drops it on the floor and falls
back to the procedural .glb props in assets/models/ when this folder is absent.
"@
Set-Content -Path (Join-Path $Dest "LICENSE.txt") -Value $license -Encoding UTF8

Write-Host ("models CC0 -> " + $Dest)
