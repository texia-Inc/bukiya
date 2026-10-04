// 群勢キャノン - ステージ定義
// 座標は論理座標（幅360 × 高さ640、y はマイナス方向が画面の上）
//   obstacles.kind: 'bush'  = 壊せない植え込み
//                   'hedge' = 味方の体当たりで壊せる生け垣（hp）
//                   'fence' = 柵（壊せない）
//   gates.type    : 'mul' = ×value / 'add' = +value（味方1人が通るたび）
(function (root) {
  'use strict';

  // 画面上部の「じょうご型」の植え込み。敵はこの隙間から流れ込んでくる
  function funnel(gapX0, gapX1) {
    return [
      { kind: 'bush', x: 0, y: 60, w: gapX0, h: 150 },
      { kind: 'bush', x: gapX1, y: 60, w: 360 - gapX1, h: 150 },
    ];
  }
  function fence(x, y0, y1) {
    return { kind: 'fence', x: x, y: y0, w: 6, h: y1 - y0 };
  }

  const LEVELS = [
    {
      name: 'はじめての防衛',
      hint: '画面を押し続けて発射！ ×5の門をくぐらせて兵を増やそう',
      enemies: { total: 1200, initial: 600, rate: 45 },
      obstacles: [...funnel(130, 230), fence(110, 300, 440), fence(244, 300, 440)],
      gates: [{ x0: 116, x1: 244, y: 410, type: 'mul', value: 5 }],
    },
    {
      name: '三つの道',
      hint: '生け垣を壊せば奥の門が使える。×99を狙え！',
      enemies: { total: 9000, initial: 2400, rate: 200 },
      obstacles: [
        ...funnel(130, 230),
        fence(100, 270, 440),
        fence(240, 270, 440),
        { kind: 'hedge', x: 10, y: 345, w: 90, h: 55, hp: 90 },
        { kind: 'hedge', x: 246, y: 355, w: 104, h: 50, hp: 35 },
      ],
      gates: [
        { x0: 10, x1: 100, y: 285, type: 'mul', value: 99 },
        { x0: 10, x1: 100, y: 305, type: 'mul', value: 99 },
        { x0: 10, x1: 100, y: 325, type: 'mul', value: 99 },
        { x0: 106, x1: 240, y: 410, type: 'mul', value: 20 },
        { x0: 246, x1: 350, y: 290, type: 'mul', value: 20 },
        { x0: 246, x1: 350, y: 335, type: 'mul', value: 20 },
      ],
    },
    {
      name: '揺れる門',
      hint: '動く×10の門にタイミングを合わせよう。巨人は12発で倒れる',
      enemies: { total: 6000, initial: 1800, rate: 95, giantEvery: 30 },
      obstacles: [...funnel(120, 240)],
      gates: [
        { x0: 120, x1: 240, y: 360, type: 'mul', value: 10, move: { range: 105, speed: 0.12 } },
        { x0: 10, x1: 350, y: 470, type: 'add', value: 2 },
      ],
    },
    {
      name: '城壁突破',
      hint: '固い生け垣の奥に×50。壊すまで左の道で耐えろ',
      enemies: { total: 8000, initial: 1800, rate: 80, giantEvery: 20 },
      obstacles: [
        ...funnel(130, 230),
        fence(177, 250, 460),
        { kind: 'hedge', x: 183, y: 395, w: 167, h: 55, hp: 80 },
      ],
      gates: [
        { x0: 10, x1: 177, y: 430, type: 'mul', value: 3 },
        { x0: 10, x1: 177, y: 330, type: 'mul', value: 4 },
        { x0: 183, x1: 350, y: 320, type: 'mul', value: 50 },
      ],
    },
    {
      name: '大軍勢',
      hint: '三つの道を使い分けて、押し寄せる大軍を食い止めろ！',
      enemies: { total: 11000, initial: 2400, rate: 130, giantEvery: 15 },
      obstacles: [
        ...funnel(120, 240),
        fence(120, 250, 470),
        fence(234, 250, 470),
        { kind: 'hedge', x: 126, y: 420, w: 108, h: 45, hp: 260 },
      ],
      gates: [
        { x0: 10, x1: 120, y: 440, type: 'mul', value: 2 },
        { x0: 10, x1: 120, y: 400, type: 'mul', value: 2 },
        { x0: 10, x1: 120, y: 360, type: 'mul', value: 2 },
        { x0: 10, x1: 120, y: 320, type: 'mul', value: 2 },
        { x0: 10, x1: 120, y: 280, type: 'mul', value: 2 },
        { x0: 126, x1: 234, y: 300, type: 'mul', value: 99 },
        { x0: 240, x1: 350, y: 440, type: 'add', value: 10 },
        { x0: 240, x1: 350, y: 330, type: 'mul', value: 4 },
      ],
    },
  ];

  if (typeof module !== 'undefined' && module.exports) module.exports = LEVELS;
  else root.CrowdLevels = LEVELS;
})(typeof self !== 'undefined' ? self : this);
