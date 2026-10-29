# 主人公モデルについて

`heroine.glb` は、主人公「汐見ナギ」（仮）を VRoid Studio 2.16 で作った `tools/umimachi/design/nagi.vrm` を、Blender で改変したものです。

- 作り方：設定画（`tools/umimachi/design/`）をもとに、VRoid Studio のプリセット（髪型・顔・衣装）を選び、色と体型を調整。
  手順は `tools/umimachi/VROID_GUIDE.md`。VRoid Studio の操作は vroid-harness（https://github.com/shi3z/mac-vroid-harness）で自動化。
- VRoid Studio で作ったモデルと、その中のプリセットのアイテムは、商用を含めて利用できます（VRoid Studio 利用規約）。

改変内容（`tools/umimachi/heroine_vrm.py` で Blender から再生成できます）:
最初に使っていた pixiv の VRM サンプルと同じ大きさに拡大（同じ VRoid の骨格で、約3.5%）。ポニーテールを、ゲームが揺らす骨 Tail0〜3 に付け替え。
服を着せ替え用の部品（`W_` で始まる名前）に分け、ゲームで色を乗せるスカートとリボンは明るいグレーに。
肌のテクスチャに描かれたハイソックスを消し、くつ下・タイツ・スパッツなどを肌から作った部品に。パーカー、シュシュ、ガチャの衣装（魔女の帽子・マント、
ねこ耳・しっぽ、角・羽、迷彩、セーラーえりなど）を追加。使わないシェイプキーとテクスチャを削除し、テクスチャを縮小。
