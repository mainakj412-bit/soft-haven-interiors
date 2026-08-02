Add-Type -AssemblyName System.Drawing

$proj = 'C:\Users\user\Desktop\Claude\17_Soft-Haven-Interiors'
$srcFile = "$proj\images\_raw\logo_1024.jpg"
$dest = "$proj\images"

$codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/png' }

function Save-Png {
  param($outFile, $cx, $cy, $cw, $ch, $size)
  $img = [System.Drawing.Image]::FromFile($srcFile)
  try {
    $bmp = New-Object System.Drawing.Bitmap $size, $size
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode   = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $srcR = New-Object System.Drawing.Rectangle $cx, $cy, $cw, $ch
    $dstR = New-Object System.Drawing.Rectangle 0, 0, $size, $size
    $g.DrawImage($img, $dstR, $srcR, [System.Drawing.GraphicsUnit]::Pixel)
    $g.Dispose()
    $bmp.Save($outFile, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Output ("{0,-16} {1}x{1}  {2} KB" -f (Split-Path $outFile -Leaf), $size, [math]::Round((Get-Item $outFile).Length/1KB))
  } finally { $img.Dispose() }
}

# full circular badge - mark + wordmark + tagline
Save-Png "$dest\logo.png" 0 0 1024 1024 640

# just the house / curtain / cushion mark.
# Mark centre is ~(516,292); the wordmark starts at y~520, so 226 is the largest
# half-size that keeps the whole circle and excludes the text.
Save-Png "$dest\logo-mark.png" 290 66 452 452 240
