Add-Type -AssemblyName System.IO.Compression.FileSystem

# Collects everything the live site needs into docs\ - the folder GitHub Pages serves.
# Leaves behind: originals (_raw, _materials_raw), the artifact build (_page.html),
# the source (_page.src.html) and the scripts - none of which belong on a web server.

$proj = 'C:\Users\user\Desktop\Claude\17_Soft-Haven-Interiors'
$site = "$proj\docs"

if (Test-Path $site) { Remove-Item $site -Recurse -Force }
New-Item -ItemType Directory -Force "$site\images\fabrics" | Out-Null

Copy-Item "$proj\index.html" $site
Copy-Item "$proj\images\*.jpg" "$site\images"
Copy-Item "$proj\images\*.png" "$site\images"
Copy-Item "$proj\images\fabrics\*.jpg" "$site\images\fabrics"

# Tell crawlers everything is fair game
Set-Content "$site\robots.txt" "User-agent: *`nAllow: /" -Encoding utf8

# Stops GitHub Pages running the folder through Jekyll, which ignores _ files
New-Item -ItemType File -Force "$site\.nojekyll" | Out-Null

$zip = "$proj\soft-haven-site.zip"
if (Test-Path $zip) { Remove-Item $zip -Force }
[System.IO.Compression.ZipFile]::CreateFromDirectory($site, $zip)

$n = (Get-ChildItem $site -Recurse -File -Force).Count
$kb = [math]::Round((Get-ChildItem $site -Recurse -File -Force | Measure-Object Length -Sum).Sum/1KB)
Write-Output ("docs\: {0} files, {1:N0} KB" -f $n, $kb)
Write-Output ("zip:   {0:N0} KB (drag-and-drop fallback)" -f ((Get-Item $zip).Length/1KB))
