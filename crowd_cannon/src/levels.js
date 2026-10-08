// 群勢キャノン - ステージ定義
// 座標は論理座標（幅360 × 高さ640、y はマイナス方向が画面の上）
//   obstacles.kind: 'bush'  = 壊せない植え込み
//                   'hedge' = 味方の体当たりで壊せる生け垣（hp）
//                   'fence' = 柵（壊せない）
//                   'barricade' = 生け垣と同じく壊せる縞模様のバリケード
//   gates.type    : 'mul' = ×value / 'add' = +value（味方1人が通るたび）
//   pickups       : ボーナスブロック。最初に触れた1回だけ +value 人（取ると消える）
//                   'crate' = 岩に封印された砲台。壊すと1回で reward の数だけ撃てる（shots）
//   enemies.bosses: 最初から出てくるボス [{ x, y, hp }]
//   doors         : 開閉する扉。支点(px,py)・長さ len・角度 angles[0]⇔[1] を hold 秒ずつ待って swing 秒で振れる
//   feeders       : 扉の向こうから流れてくる「+add」の帯。門 gate の倍率に加算される
(function (root) {
  'use strict';

  // 画面上部の「じょうご型」の植え込み。敵はこの隙間から流れ込んでくる
  function funnel(gapX0, gapX1) {
    return [
      { kind: 'bush', x: 0, y: 60, w: gapX0, h: 150 },
      { kind: 'bush', x: gapX1, y: 60, w: 360 - gapX1, h: 150 },
    ];
  }
  // 縦一列に並んだボーナスブロック
  function pickupColumn(x, w, yBottom, count, step, value) {
    const out = [];
    for (let i = 0; i < count; i++) out.push({ x: x, y: yBottom - i * step, w: w, h: 12, value: value });
    return out;
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
    {
      name: '宝物の道',
      hint: '青い+1は取り放題。縞模様のバリケードを壊せば+99が並ぶ道へ！ ボスにも注意',
      enemies: { total: 2400, initial: 900, rate: 32, giantEvery: 25, bosses: [{ x: 180, y: -40, hp: 150 }] },
      obstacles: [
        ...funnel(120, 240),
        fence(244, 250, 485),
        { kind: 'barricade', x: 250, y: 462, w: 100, h: 22, hp: 70 },
      ],
      gates: [{ x0: 70, x1: 244, y: 495, type: 'mul', value: 4 }],
      pickups: [...pickupColumn(14, 46, 530, 15, 20, 1), ...pickupColumn(266, 68, 432, 7, 27, 99)],
    },
    {
      name: '開閉する扉',
      hint: '扉が赤の道をふさぐと紫の+10が流れ込み、門の倍率が上がる。岩の砲台を壊せば3連射！',
      enemies: { total: 9000, initial: 2800, rate: 170, giantEvery: 6, bosses: [{ x: 115, y: -80, hp: 400 }] },
      obstacles: [
        { kind: 'bush', x: 0, y: 60, w: 60, h: 270 },
        { kind: 'bush', x: 170, y: 20, w: 190, h: 60 },
        { kind: 'bush', x: 170, y: 80, w: 20, h: 220 },
        { kind: 'bush', x: 300, y: 80, w: 60, h: 250 },
        // 紫のレーンの入口の低い柵（兵は通れない。+10の帯だけが越えて流れてくる）
        { kind: 'fence', x: 184, y: 300, w: 120, h: 8 },
        fence(236, 360, 430),
        { kind: 'crate', x: 262, y: 372, w: 70, h: 52, hp: 60, reward: 'multishot', shots: 3 },
      ],
      gates: [{ x0: 60, x1: 236, y: 400, type: 'mul', value: 2, color: 'purple' }],
      doors: [{ px: 180, py: 302, len: 116, angles: [0, Math.PI], hold: [8, 4], swing: 1.2 }],
      feeders: [{ x0: 190, x1: 300, count: 12, startY: 282, spacing: 18, speed: 15, releaseY: 318, gate: 0, add: 10, door: 0 }],
    },
  ];

  if (typeof module !== 'undefined' && module.exports) module.exports = LEVELS;
  else root.CrowdLevels = LEVELS;
})(typeof self !== 'undefined' ? self : this);
