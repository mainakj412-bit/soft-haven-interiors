Add-Type -AssemblyName System.Drawing

# Builds the two generated files from _page.src.html (the only file you edit):
#   index.html  - standalone page for real hosting, images stay as separate files
#   _page.html  - artifact build, every photo inlined as a base64 data URI
#                 (published artifacts cannot load relative image paths)

$proj = 'C:\Users\user\Desktop\Claude\17_Soft-Haven-Interiors'
$src  = Get-Content "$proj\_page.src.html" -Raw -Encoding UTF8
$utf8 = New-Object System.Text.UTF8Encoding $false

# ---------- 1. index.html ----------
$head = @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="description" content="Soft Haven Interiors makes custom curtains, sheers and fabric decor in Nakuru, Kenya. Made to measure, quality fabric, clean finishing. Order on WhatsApp 0799 282 690.">
<meta property="og:title" content="Soft Haven Interiors - Your Home, Your Haven.">
<meta property="og:description" content="Custom curtains, sheers and fabric styling for beautiful living spaces. Nakuru, Kenya.">
<meta property="og:type" content="website">
<link rel="icon" href="images/logo-mark.png">
<link rel="apple-touch-icon" href="images/logo-mark.png">
'@
$index = $head + $src + "`n</body>`n</html>`n"
$index = $index -replace '(?s)(</style>)', "`$1`n</head>`n<body>"
[System.IO.File]::WriteAllText("$proj\index.html", $index, $utf8)
Write-Output ("index.html   {0:N0} KB" -f ((Get-Item "$proj\index.html").Length/1KB))

# ---------- 2. _page.html ----------
$codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
$tmp = Join-Path $env:TEMP 'shv_embed'
New-Item -ItemType Directory -Force $tmp | Out-Null

function Inline-Images {
  param($html, $files, $prefix, $maxDim, $quality)

  $eps = New-Object System.Drawing.Imaging.EncoderParameters 1
  $eps.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality, $quality)
  $bytes = 0

  foreach ($f in $files) {
    $img = [System.Drawing.Image]::FromFile($f.FullName)
    try {
      $scale = 1.0
      $long = [Math]::Max($img.Width, $img.Height)
      if ($long -gt $maxDim) { $scale = $maxDim / $long }
      $tw = [int][Math]::Round($img.Width * $scale)
      $th = [int][Math]::Round($img.Height * $scale)

      $bmp = New-Object System.Drawing.Bitmap $tw, $th
      $g = [System.Drawing.Graphics]::FromImage($bmp)
      $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
      $g.DrawImage($img, 0, 0, $tw, $th)
      $g.Dispose()
      $out = Join-Path $tmp $f.Name
      $bmp.Save($out, $codec, $eps)
      $bmp.Dispose()
    } finally { $img.Dispose() }

    $b64 = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($out))
    $bytes += $b64.Length
    $html = $html.Replace("$prefix$($f.Name)", "data:image/jpeg;base64,$b64")
  }
  # Write-Host, not Write-Output: anything written to the pipeline here would be
  # returned alongside $html and corrupt the result.
  Write-Host ("  inlined {0,-18} {1,3} files  {2:N0} KB" -f $prefix, $files.Count, ($bytes/1KB))
  return $html
}

$page = $src
# PNG logos are re-encoded to JPEG for the embed (they have no transparency, only a
# cream ground) but are still matched on their original .png filename.
$page = Inline-Images $page (Get-ChildItem "$proj\images\*.png")         'images/'         460 82
$page = Inline-Images $page (Get-ChildItem "$proj\images\*.jpg")         'images/'         900 72
$page = Inline-Images $page (Get-ChildItem "$proj\images\fabrics\*.jpg") 'images/fabrics/' 520 68

[System.IO.File]::WriteAllText("$proj\_page.html", $page, $utf8)
Write-Output ("_page.html   {0:N0} KB" -f ((Get-Item "$proj\_page.html").Length/1KB))
