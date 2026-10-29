# 海街スケート — ソースと生成スクリプト

- `src/` … ゲーム本体のソース（パーツごとに分割）。`python3 src/build.py` で `docs/umimachi/index.html` を生成する。
  `umimachi_single.html`（モデル埋め込みの1ファイル版）も同時に作られる（コミット対象外）。
- `heroine_vrm.py` … 主人公モデル `docs/umimachi/heroine.glb` を pixiv の VRM サンプルから Blender で作るスクリプト。
  `pip install bpy pillow` した Python で `python heroine_vrm.py -- VRM1_Constraint_Twist_Sample.vrm(.glb に改名) heroine.glb`。
- `heroine_head.py` … 以前の手続き生成ヒロインの頭部（モデルを読み込めなかったときの予備）を作るスクリプト。
