// ブキヤ・サバイバーの Web 公開用：描画解像度の上限（既定は2倍）。
// スマホは3倍密度が多く、塗るピクセル数が増えて重くなるため、Flutter が読む
// devicePixelRatio を起動前に抑える。URL に ?dpr=3 を付けると上限を変えられる。
// Pages のワークフローがサバイバーのビルドにだけ読み込ませる。
(function () {
  var q = new URLSearchParams(window.location.search).get('dpr');
  var cap = q ? Number(q) : 2;
  var real = window.devicePixelRatio;
  if (cap > 0 && real > cap) {
    Object.defineProperty(window, 'devicePixelRatio', {
      get: function () { return cap; },
    });
  }
})();
