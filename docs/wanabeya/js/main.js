'use strict';

$('#hintBtn').addEventListener('click', () => {
  if (current && !current.ended) say('ヒント：' + current.def.hint(api));
});
$('#retryBtn').addEventListener('click', () => {
  if (current) loadStage(current.index);
});
$('#startBtn').addEventListener('click', () => startGame(0));

// 看板などの文字をフォントで描くため、読み込みを少し待ってから始める（最大1.5秒）
const fontsReady = document.fonts ? document.fonts.ready : Promise.resolve();
Promise.race([fontsReady, new Promise(r => setTimeout(r, 1500))]).then(() => {
  // タイトルの後ろにステージ1を表示しておく
  loadStage(0);
  showTitle();
});
