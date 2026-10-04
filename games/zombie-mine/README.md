# ゾンビ採掘場（プロトタイプ）

ブルドーザーで鉱石を押して炉へ運ぶ放置系ゲームの試作です。`index.html` 1ファイルで動きます（Three.js r128 と Google Fonts を CDN から読み込み）。

## 遊び方
- ドラッグ（PC は WASD / 矢印キー）で操作、スペースでダッシュ
- 鉱石を炉に押し込んでコインを稼ぎ、床のパッドに乗って強化・門の解放
- 出荷場のトロッコを満たすと鉱山クリア。ワールドマップから10の鉱山と3つの竜の巣へ

## ローカルで動かす
```bash
cd games/zombie-mine
python3 -m http.server 8080   # http://localhost:8080
```
ファイルを直接ブラウザで開いても動きます。進行はブラウザの localStorage に保存されます。

## 公開
`.github/workflows/zombie-mine-pages.yml` が `main` への push（`games/**` の変更時）で GitHub Pages にデプロイします。
リポジトリの Settings → Pages → Source を「GitHub Actions」にしてください。
