Add-Type -AssemblyName System.Drawing

$projectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$terrainSourcePath = Join-Path $projectRoot 'assets/sprites/terrain/terrain_atlas.png'
$tileOutputDirectory = Join-Path $projectRoot 'assets/sprites/terrain/tiles'

function Export-Region {
	param(
		[System.Drawing.Bitmap]$Source,
		[int]$SourceX,
		[int]$SourceY,
		[int]$SourceWidth,
		[int]$SourceHeight,
		[int]$OutputWidth,
		[int]$OutputHeight,
		[string]$OutputPath
	)

	$sourceRectangle = [System.Drawing.Rectangle]::new($SourceX, $SourceY, $SourceWidth, $SourceHeight)
	$cropped = $Source.Clone($sourceRectangle, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
	$output = [System.Drawing.Bitmap]::new($OutputWidth, $OutputHeight, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
	$graphics = [System.Drawing.Graphics]::FromImage($output)
	try {
		$graphics.Clear([System.Drawing.Color]::Transparent)
		$graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
		$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
		$graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
		$graphics.DrawImage($cropped, [System.Drawing.Rectangle]::new(0, 0, $OutputWidth, $OutputHeight))
		$output.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
	}
	finally {
		$graphics.Dispose()
		$output.Dispose()
		$cropped.Dispose()
	}
}

function Resize-Png {
	param([string]$Path, [int]$Width, [int]$Height)

	$source = [System.Drawing.Bitmap]::new($Path)
	$tempPath = "$Path.optimized.png"
	try {
		Export-Region -Source $source -SourceX 0 -SourceY 0 -SourceWidth $source.Width -SourceHeight $source.Height -OutputWidth $Width -OutputHeight $Height -OutputPath $tempPath
	}
	finally {
		$source.Dispose()
	}
	Move-Item -LiteralPath $tempPath -Destination $Path -Force
}

if (-not (Test-Path -LiteralPath $terrainSourcePath)) {
 throw 'Falta assets/sprites/terrain/terrain_atlas.png.'
}

New-Item -ItemType Directory -Path $tileOutputDirectory -Force | Out-Null

$terrainAtlas = [System.Drawing.Bitmap]::new($terrainSourcePath)
try {
	$terrainBounds = @(
		@(@(60, 14, 330, 367), @(45, 13, 329, 367), @(29, 13, 329, 367)),
		@(@(60, 3, 330, 368), @(43, 3, 330, 368), @(28, 3, 330, 368)),
		@(@(60, 0, 330, 366), @(43, 0, 330, 366), @(29, 0, 329, 366))
	)
	$terrainNames = @('path', 'grass', 'mountain')
	for ($row = 0; $row -lt 3; $row++) {
		for ($column = 0; $column -lt 3; $column++) {
			$bounds = $terrainBounds[$row][$column]
			$outputPath = Join-Path $tileOutputDirectory ("{0}_{1:D2}.png" -f $terrainNames[$row], ($column + 1))
			Export-Region -Source $terrainAtlas -SourceX ($column * 418 + $bounds[0]) -SourceY ($row * 418 + $bounds[1]) -SourceWidth $bounds[2] -SourceHeight $bounds[3] -OutputWidth 180 -OutputHeight 208 -OutputPath $outputPath
		}
	}
}
finally {
	$terrainAtlas.Dispose()
}

# These are rendered at the logical sizes below with the camera at 1x. Two
# source pixels per displayed pixel keep them crisp during moderate zoom-in.
Resize-Png -Path (Join-Path $projectRoot 'assets/sprites/base/main_tower.png') -Width 352 -Height 352
Resize-Png -Path (Join-Path $projectRoot 'assets/sprites/terrain/spawn_portal.png') -Width 224 -Height 336
Resize-Png -Path (Join-Path $projectRoot 'assets/sprites/terrain/treasure_chest.png') -Width 168 -Height 168
Resize-Png -Path (Join-Path $projectRoot 'assets/sprites/ui/tower_card_button.png') -Width 288 -Height 296

Get-ChildItem -LiteralPath $tileOutputDirectory -File | Select-Object FullName,Length
