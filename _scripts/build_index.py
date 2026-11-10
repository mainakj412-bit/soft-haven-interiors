"""Port of the index.html step in build.ps1, for machines without PowerShell.

Writes index.html exactly as build.ps1 does (fixed <head> prelude, then
_page.src.html verbatim, then the closing tags, with </head><body> spliced in
after the stylesheet) and copies it into docs/. It does not build _page.html
and does not copy images: new photos still need copying into docs/images.

    python3 _scripts/build_index.py
"""
import pathlib
import shutil

PROJ = pathlib.Path(__file__).resolve().parent.parent

HEAD = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="description" content="Soft Haven Interiors makes custom curtains, sheers and fabric decor in Nakuru, Kenya. Made to measure, quality fabric, clean finishing. Order on WhatsApp 0799 282 690.">
<meta property="og:title" content="Soft Haven Interiors - Your Home, Your Haven.">
<meta property="og:description" content="Custom curtains, sheers and fabric styling for beautiful living spaces. Nakuru, Kenya.">
<meta property="og:type" content="website">
<link rel="icon" href="images/logo-mark.png">
<link rel="apple-touch-icon" href="images/logo-mark.png">"""

src = (PROJ / '_page.src.html').read_text(encoding='utf-8')
index = HEAD + src + '\n</body>\n</html>\n'
index = index.replace('</style>', '</style>\n</head>\n<body>')

(PROJ / 'index.html').write_text(index, encoding='utf-8', newline='')
shutil.copyfile(PROJ / 'index.html', PROJ / 'docs' / 'index.html')
print('index.html  {:,} KB  (copied to docs/)'.format(len(index.encode('utf-8')) // 1024))
