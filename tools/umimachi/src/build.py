# Joins the parts into the game. Run from this folder:  python3 build.py
#   ../../../docs/umimachi/index.html  GitHub Pages build (loads heroine.glb next to it)
#   umimachi_single.html               one-file build with the model embedded (for sharing as a single page)
import base64, os
here = os.path.dirname(os.path.abspath(__file__))
parts = ['p1_shell.html', 'p1b_gltf.html', 'p2_core.js', 'p3_props.js', 'head_lib.js', 'head_data.js', 'p4_people.js', 'p4b_vrm.js', 'p4c_wardrobe.js', 'p5b_drones.js', 'p5c_story.js', 'p5e_festival.js', 'p5f_ura.js', 'p5g_og.js', 'p5d_events.js', 'p5_systems.js']
src = ''.join(open(os.path.join(here, f), encoding='utf-8').read() for f in parts)
def page(s):
    head, body = s.split('</style>\n', 1)
    return ('<!doctype html>\n<html lang="ja">\n<head>\n<meta charset="utf-8">\n'
            '<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">\n'
            + head + '</style>\n</head>\n<body>\n' + body + '\n</body>\n</html>\n')
docs = os.path.join(here, '..', '..', '..', 'docs', 'umimachi')
open(os.path.join(docs, 'index.html'), 'w', encoding='utf-8').write(page(src))
glb = base64.b64encode(open(os.path.join(docs, 'heroine.glb'), 'rb').read()).decode()
i = src.index('<script>\nfunction main(){')
single = src[:i] + '<script type="application/octet-stream" id="heroineGLB">' + glb + '</script>\n' + src[i:]
open(os.path.join(here, 'umimachi_single.html'), 'w', encoding='utf-8').write(page(single))
print('built', len(src), len(single))
