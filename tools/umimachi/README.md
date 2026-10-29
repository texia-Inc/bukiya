# 海街スケート — ソースと生成スクリプト

- `src/` … ゲーム本体のソース（パーツごとに分割）。`python3 src/build.py` で `docs/umimachi/index.html` を生成する。
  `umimachi_single.html`（モデル埋め込みの1ファイル版）も同時に作られる（コミット対象外）。
- `heroine_vrm.py` … 主人公モデル `docs/umimachi/heroine.glb` を、VRoid Studio で作った `design/nagi.vrm` から Blender で作るスクリプト。
  `Blender -b --python heroine_vrm.py -- design/nagi.vrm ../../docs/umimachi/heroine.glb`（`pip install bpy` した Python でも可）。
- `design/` … 主人公の設定画（全身4面・表情・小物）と VRoid のモデル。`design/outfits/` は同じモデルを別の服で書き出したもの（`heroine_vrm.py` が服だけを取り込む）。`VROID_GUIDE.md` … VRoid Studio での作り方。
- 着せ替え：服は `heroine.glb` の中の部品（`W_<名前>`）。`src/p4c_wardrobe.js` の `WARDROBE` 表が、スロットごとのアイテム・使う部品・色を決める。
  服を増やすには、`heroine_vrm.py` で部品を作り、`WARDROBE` に1行足す（ガチャのレア度は `RARITY`、セットは `COSTUME_SETS`）。
- `heroine_head.py` … 以前の手続き生成ヒロインの頭部（モデルを読み込めなかったときの予備）を作るスクリプト。
