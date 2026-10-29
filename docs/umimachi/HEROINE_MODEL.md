# 主人公モデルについて

`heroine.glb` は pixiv Inc. の VRM サンプルモデル「VRM1_Constraint_Twist_Sample」
（https://github.com/vrm-c/vrm-specification の samples、および pixiv/three-vrm の examples に収録）を改変したものです。

- 元モデルのライセンス: VRM Public License 1.0 (https://vrm.dev/licenses/1.0/)
- 元モデルのメタ情報: 改変・改変物の再配布可 (allowModificationRedistribution)、再配布可、法人の商用利用可、クレジット表記不要
- 著作権: (c) 2022 pixiv Inc.

改変内容（`tools/umimachi/heroine_vrm.py` で Blender から再生成できます）:
長い後ろ髪をポニーテールに変更、横髪を短く、琥珀色の目。服は着せ替え用の部品（`W_` で始まる名前）に分け、
パーカー・スカート・靴下・スニーカーなどの普段着と、ガチャの衣装（魔女の帽子・マント、ねこ耳・しっぽ、角・羽、迷彩、セーラーえりなど）を追加。
不要なシェイプキーと法線マップを削除し、テクスチャを縮小。
