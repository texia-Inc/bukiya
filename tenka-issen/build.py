import os
here = os.path.dirname(os.path.abspath(__file__))
order = ['core', 'audio', 'data', 'game', 'player', 'render3d', 'hud', 'ui']
js = "(() => {\n'use strict';\n" + "\n".join(open(os.path.join(here, 'src', f + '.js')).read() for f in order) + "\n})();"
shell = open(os.path.join(here, 'shell.html')).read()
page = shell.replace('/*__GAME_JS__*/', js)
os.makedirs(os.path.join(here, 'dist'), exist_ok=True)
open(os.path.join(here, 'dist', 'game.html'), 'w').write(page)
head = '<!doctype html>\n<html lang="ja">\n<head>\n<meta charset="utf-8">\n<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">\n<meta name="description" content="戦国無双風の斜め見下ろし3D・棒人間アクション。武将4人で3つの合戦を戦い抜け。">\n'
open(os.path.join(here, 'dist', 'index.html'), 'w').write(head + page.replace('<canvas', '</head>\n<body>\n<canvas', 1) + '\n</body>\n</html>\n')
# (game.js は出力しない)
print('built', len(page), 'bytes')
