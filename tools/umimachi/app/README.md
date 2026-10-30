# 海街スケート iOS アプリ

ゲーム（`docs/umimachi/index.html`）を Capacitor で包んだ iPhone アプリです。

- Bundle ID：`com.umimachi.app`
- Team：`8CQ4Y459JJ`（chaincam、ねこカード図鑑と同じ）
- 署名：自動（Automatically manage signing）
- 対応：iPhone のみ。縦と横の両方に対応。ステータスバーは出しません

## はじめて使うとき

```bash
cd tools/umimachi/app
npm install
```

## ゲームを直したあと

```bash
python3 ../src/build.py   # ゲームを作る
npm run sync              # www/ を作って、iOS プロジェクトにコピーする
npm run open              # Xcode で開く
```

`prepare.py` では、ネットから読んでいたものもアプリの中に入れます。
- three.js：`www/vendor/three.min.js`
- フォント：`www/fonts/`。ゲームで使う文字と、かな・英数字だけに減らします（全部で約 0.7MB）

フォントを減らすのに使う fonttools は、`.venv/` に自動で入ります。

アイコンと起動画面を作り直すときは `python3 make_icons.py` を実行します。

## App Store へ出すとき

1. App Store Connect →「マイ App」→「＋」→「新規 App」で、Bundle ID `com.umimachi.app` を選ぶ
   - Bundle ID が一覧にないときは、Xcode で一度ビルドするか、developer.apple.com の Identifiers で作る
2. Xcode で、上のデバイスを「Any iOS Device (arm64)」にして「Product」→「Archive」
3. Organizer →「Distribute App」→「App Store Connect」でアップロード → TestFlight で確かめる
4. 新しい版を出すときは、Xcode の「General」で Version と Build を上げる

`ITSAppUsesNonExemptEncryption` は false にしてあるので、輸出コンプライアンスの質問は出ません。
