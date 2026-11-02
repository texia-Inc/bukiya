# Joins the parts into the game. Run from this folder:  python3 build.py
#   ../../../docs/umimachi/index.html  GitHub Pages build (loads heroine.glb next to it)
#   umimachi_single.html               one-file build with the model embedded (for sharing as a single page)
import base64, os
here = os.path.dirname(os.path.abspath(__file__))
parts = ['p1_shell.html', 'p1b_gltf.html', 'p1c_app.html', 'p2_core.js', 'p2b_nature.js', 'p3_props.js', 'head_lib.js', 'head_data.js', 'p4_people.js', 'p4b_vrm.js', 'p4c_wardrobe.js', 'p4d_mio.js', 'p5b_drones.js', 'p5c_story.js', 'p5e_festival.js', 'p5f_ura.js', 'p5g_og.js', 'p5h_true.js', 'p5i_tricks.js', 'p5d_events.js', 'p5j_tram.js', 'p5k_inaka.js', 'p5m_shima.js', 'p5o_base.js', 'p5n_ex1.js', 'p5p_rescue.js', 'p5q_hq.js', 'p5s_final.js', 'p5t_recap.js', 'p5v_mirror.js', 'p5w_d3.js', 'p5x_run.js', 'p5y_master.js', 'p5z_jin.js', 'p5l_sound.js', 'p5_systems.js']
# main() stops between the parts of the town so the loading bar can move (not before p5_systems.js: by then the page listens
# for focus and the like, and those must not run half-built)
STEPS = {'p2b_nature.js': '海と山', 'p3_props.js': '町の小物', 'head_lib.js': '顔', 'p4_people.js': '町の人', 'p4b_vrm.js': 'ナギとミオ',
         'p5b_drones.js': '物語', 'p5e_festival.js': '夏祭り', 'p5f_ura.js': '裏海街', 'p5j_tram.js': '電車', 'p5k_inaka.js': 'いなか',
         'p5m_shima.js': '島', 'p5o_base.js': '基地', 'p5q_hq.js': '作戦室', 'p5v_mirror.js': '鏡の海', 'p5x_run.js': '裏海街の夜',
         'p5g_og.js': '物語', 'p5i_tricks.js': '技', 'p5d_events.js': '物語', 'p5n_ex1.js': '物語', 'p5s_final.js': '物語', 'p5l_sound.js': '音'}
def part(f):
    s = open(os.path.join(here, f), encoding='utf-8').read()
    if not f.endswith('.js') or f in ('p2_core.js', 'p5_systems.js'):
        return s
    k = parts.index(f) - parts.index('p2_core.js')
    n = parts.index('p5_systems.js') - parts.index('p2_core.js')
    step = next((STEPS[g] for g in reversed(parts[:parts.index(f) + 1]) if g in STEPS), '町')
    return "await LD.tick(%.3f,'%sをつくっています');\n" % (0.5 + 0.45 * k / n, step) + s
src = ''.join(part(f) for f in parts)
def page(s):
    head, body = s.split('</style>\n', 1)
    return ('<!doctype html>\n<html lang="ja">\n<head>\n<meta charset="utf-8">\n'
            '<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no, viewport-fit=cover">\n'
            + head + '</style>\n</head>\n<body>\n' + body + '\n</body>\n</html>\n')
docs = os.path.join(here, '..', '..', '..', 'docs', 'umimachi')
open(os.path.join(docs, 'index.html'), 'w', encoding='utf-8').write(page(src))
glb = base64.b64encode(open(os.path.join(docs, 'heroine.glb'), 'rb').read()).decode()
i = src.index('<script>\n// the loading bar')
single = src[:i] + '<script type="application/octet-stream" id="heroineGLB">' + glb + '</script>\n' + src[i:]
open(os.path.join(here, 'umimachi_single.html'), 'w', encoding='utf-8').write(page(single))
print('built', len(src), len(single))
