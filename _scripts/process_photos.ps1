Add-Type -AssemblyName System.Drawing

$raw  = 'C:\Users\user\Desktop\Claude\17_Soft-Haven-Interiors\images\_raw'
$dest = 'C:\Users\user\Desktop\Claude\17_Soft-Haven-Interiors\images'

$codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
$eps = New-Object System.Drawing.Imaging.EncoderParameters 1
$eps.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality, 82)

function Save-Crop {
  param($srcFile, $outFile, $cx, $cy, $cw, $ch, $maxDim = 1400)

  $img = [System.Drawing.Image]::FromFile($srcFile)
  try {
    if ($cw -le 0) { $cx = 0; $cy = 0; $cw = $img.Width; $ch = $img.Height }
    if (($cx + $cw) -gt $img.Width)  { $cw = $img.Width  - $cx }
    if (($cy + $ch) -gt $img.Height) { $ch = $img.Height - $cy }

    # target size after clamping the long edge
    $scale = 1.0
    $long = [Math]::Max($cw, $ch)
    if ($long -gt $maxDim) { $scale = $maxDim / $long }
    $tw = [int][Math]::Round($cw * $scale)
    $th = [int][Math]::Round($ch * $scale)

    $bmp = New-Object System.Drawing.Bitmap $tw, $th
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode   = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality

    $srcRect = New-Object System.Drawing.Rectangle $cx, $cy, $cw, $ch
    $dstRect = New-Object System.Drawing.Rectangle 0, 0, $tw, $th
    $g.DrawImage($img, $dstRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
    $g.Dispose()

    $bmp.Save($outFile, $codec, $eps)
    $bmp.Dispose()
    $kb = [math]::Round((Get-Item $outFile).Length/1KB)
    Write-Output ("{0,-14} {1}x{2}  {3} KB" -f (Split-Path $outFile -Leaf), $tw, $th, $kb)
  } finally { $img.Dispose() }
}

# --- hero + about -------------------------------------------------
Save-Crop "$raw\p2.jpg" "$dest\hero-1.jpg" 0 0 0 0            # grey blackout + sheer
Save-Crop "$raw\p7.jpg" "$dest\hero-2.jpg" 0 0 1024 1240      # fabric rolls, strip caption band
Save-Crop "$raw\p5.jpg" "$dest\hero-3.jpg" 0 0 0 0            # taupe living room
Save-Crop "$raw\p6.jpg" "$dest\about.jpg"  0 0 0 0            # white sheers, tall

# --- gallery ------------------------------------------------------
# p3 / p4 are two-photo collages of real installed jobs: split each down the middle
Save-Crop "$raw\p3.jpg" "$dest\work-1.jpg" 0   0 758 1024     # b&w geometric, left frame
Save-Crop "$raw\p4.jpg" "$dest\work-2.jpg" 0   0 758 1024     # brown & cream, left frame
Save-Crop "$raw\p1.jpg" "$dest\work-3.jpg" 32 25 876 568      # grey eyelet, strip frame + caption
Save-Crop "$raw\p8.jpg" "$dest\work-4.jpg" 0   0 0   0        # cushions on sofa
Save-Crop "$raw\p3.jpg" "$dest\work-5.jpg" 778 0 758 1024     # b&w geometric, right frame
Save-Crop "$raw\p4.jpg" "$dest\work-6.jpg" 778 0 758 1024     # brown & cream, right frame

Write-Output ''
Write-Output ("TOTAL {0} KB" -f [math]::Round((Get-ChildItem "$dest\*.jpg" | Measure-Object Length -Sum).Sum/1KB))
