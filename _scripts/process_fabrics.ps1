Add-Type -AssemblyName System.Drawing

$proj = 'C:\Users\user\Desktop\Claude\17_Soft-Haven-Interiors'
$raw  = "$proj\images\_materials_raw"
$dest = "$proj\images\fabrics"
New-Item -ItemType Directory -Force $dest | Out-Null

$codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
$eps = New-Object System.Drawing.Imaging.EncoderParameters 1
$eps.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality, 78)

$n = 0
foreach ($f in (Get-ChildItem "$raw\*.jpg" | Sort-Object Name)) {
  $n++
  $code = "SH-{0:D2}" -f $n
  $img = [System.Drawing.Image]::FromFile($f.FullName)
  try {
    $maxDim = 1100
    $scale = 1.0
    $long = [Math]::Max($img.Width, $img.Height)
    if ($long -gt $maxDim) { $scale = $maxDim / $long }
    $tw = [int][Math]::Round($img.Width * $scale)
    $th = [int][Math]::Round($img.Height * $scale)

    $bmp = New-Object System.Drawing.Bitmap $tw, $th
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode   = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.DrawImage($img, 0, 0, $tw, $th)
    $g.Dispose()

    $out = Join-Path $dest ("{0}.jpg" -f $code.ToLower())
    $bmp.Save($out, $codec, $eps)
    $bmp.Dispose()
    Write-Output ("{0}  {1}x{2}  {3} KB" -f $code, $tw, $th, [math]::Round((Get-Item $out).Length/1KB))
  } finally { $img.Dispose() }
}
Write-Output ''
Write-Output ("TOTAL {0} KB across {1} fabrics" -f [math]::Round((Get-ChildItem "$dest\*.jpg" | Measure-Object Length -Sum).Sum/1KB), $n)
