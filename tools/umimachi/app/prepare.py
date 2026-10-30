# Copies the game into www/ for the iOS app, with everything it fetches from the web kept inside the app.
#   three.js  -> www/vendor/three.min.js
#   fonts     -> www/fonts/*.woff2, cut down to the characters the game uses (plus all kana and ASCII)
# Run after building the game (python3 ../src/build.py). `npm run sync` runs this and then `npx cap sync ios`.
import os, re, shutil, subprocess, sys, urllib.request
here = os.path.dirname(os.path.abspath(__file__))
docs = os.path.join(here, '..', '..', '..', 'docs', 'umimachi')
www, cache = os.path.join(here, 'www'), os.path.join(here, '.cache')
THREE = 'https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js'
FONTS = [  # family, weight, file in google/fonts
    ('Zen Maru Gothic', 500, 'zenmarugothic/ZenMaruGothic-Medium.ttf'),
    ('Zen Maru Gothic', 700, 'zenmarugothic/ZenMaruGothic-Bold.ttf'),
    ('Zen Maru Gothic', 900, 'zenmarugothic/ZenMaruGothic-Black.ttf'),
    ('Kaisei Decol', 700, 'kaiseidecol/KaiseiDecol-Bold.ttf'),
]

def fetch(url, name):
    p = os.path.join(cache, name)
    if not os.path.exists(p):
        os.makedirs(cache, exist_ok=True)
        print('download', url)
        urllib.request.urlretrieve(url, p)
    return p

# fonttools lives in a local venv so nothing is installed system-wide
py = os.path.join(here, '.venv', 'bin', 'python')
if not os.path.exists(py):
    subprocess.check_call([sys.executable, '-m', 'venv', os.path.join(here, '.venv')])
    subprocess.check_call([py, '-m', 'pip', '-q', 'install', 'fonttools', 'brotli'])

html = open(os.path.join(docs, 'index.html'), encoding='utf-8').read()
shutil.rmtree(www, ignore_errors=True)
os.makedirs(os.path.join(www, 'vendor'))
os.makedirs(os.path.join(www, 'fonts'))
for f in ('heroine.glb', 'mio.glb'):
    shutil.copy(os.path.join(docs, f), www)
shutil.copy(fetch(THREE, 'three.min.js'), os.path.join(www, 'vendor'))

chars = set(html) | set(map(chr, range(0x20, 0x7f)))
for a, b in ((0x3000, 0x30ff), (0xff00, 0xffef)):  # CJK punctuation, kana, full-width forms
    chars |= set(map(chr, range(a, b + 1)))
text = os.path.join(cache, 'chars.txt')
open(text, 'w', encoding='utf-8').write(''.join(sorted(c for c in chars if c.isprintable())))
css = []
for fam, w, src in FONTS:
    out = os.path.basename(src).replace('.ttf', '.woff2')
    subprocess.check_call([py, '-m', 'fontTools.subset', fetch('https://raw.githubusercontent.com/google/fonts/main/ofl/' + src, os.path.basename(src)),
                           '--text-file=' + text, '--flavor=woff2', '--layout-features=*', '--output-file=' + os.path.join(www, 'fonts', out)])
    css.append('@font-face{font-family:"%s";font-weight:%d;font-style:normal;font-display:swap;src:url(fonts/%s) format("woff2")}' % (fam, w, out))

page = html.replace('<link rel="preconnect" href="https://fonts.googleapis.com">\n', '')
page, n1 = re.subn(r'<link rel="stylesheet" href="https://fonts\.googleapis\.com/[^"]*">', '<style>' + ''.join(css) + '</style>', page)
page, n2 = re.subn(re.escape('<script src="' + THREE + '">'), '<script src="vendor/three.min.js">', page)
assert n1 == 1 and n2 == 1, 'font link or three.js tag not found in index.html'
assert 'https://' not in re.sub(r'<script>[\s\S]*?</script>', '', page), 'the page still loads something from the web'
open(os.path.join(www, 'index.html'), 'w', encoding='utf-8').write(page)
size = sum(os.path.getsize(os.path.join(d, f)) for d, _, fs in os.walk(www) for f in fs)
print('www ready, %.1f MB' % (size / 1e6))
