// ───────────── ゲームデータ（武将・技・兵種・合戦） ─────────────
const WORLD_W = 3200, WORLD_H = 2400;

// 兵種。H は棒人間の背丈
const KIND = {
  ashi:    { r: 12, hp: 50,   spd: 80,  dmg: 15, aggro: 520, reach: 46,  arc: 1.4, wind: .65, stun: .45, H: 34, weapon: 'spear' },
  archer:  { r: 12, hp: 40,   spd: 72,  dmg: 13, aggro: 640, reach: 430, arc: .3,  wind: .9,  stun: .45, H: 34, weapon: 'yumi', ranged: true },
  leader:  { r: 15, hp: 300,  spd: 92,  dmg: 22, aggro: 420, reach: 58,  arc: 1.8, wind: .55, stun: .35, H: 40, weapon: 'katana' },
  officer: { r: 19, hp: 1300, spd: 118, dmg: 34, aggro: 480, reach: 80,  arc: 2.2, wind: .45, stun: .18, H: 50 },
  boss:    { r: 22, hp: 3200, spd: 110, dmg: 44, aggro: 540, reach: 95,  arc: 2.6, wind: .5,  stun: .14, H: 56, weapon: 'odachi' },
};

// 武将ごとの技表。hits の kind: arc=範囲攻撃 / proj=飛び道具 / rain=範囲に降る矢
const fissure = () => Array.from({ length: 6 }, (_, i) => ({ t: .3 + i * .05, kind: 'arc', off: 60 + i * 62, range: 64, arc: TAU, dmg: 66, kb: 300, launch: 470, fx: 'spike' }));
const arrowShot = (dmg = 19) => ({ t: .08, kind: 'proj', p: 'arrow', n: 1, spd: 980, life: .62, r: 16, dmg, kb: 90, aim: 1 });
const MOVES = {
  katana: {
    combo: ['N1', 'N2', 'N3', 'N4', 'N5'], charge: { idle: 'C1', N1: 'C2', N2: 'C3', N3: 'C4', N4: 'C5' },
    N1: { dur: .30, step: 90, swing: 1, pose: 'slash', hits: [{ t: .07, t2: .15, kind: 'arc', range: 78, arc: 2.0, dmg: 20, kb: 150 }] },
    N2: { dur: .30, step: 90, swing: -1, pose: 'slash', hits: [{ t: .07, t2: .15, kind: 'arc', range: 78, arc: 2.0, dmg: 20, kb: 150 }] },
    N3: { dur: .32, step: 100, swing: 1, pose: 'slash', hits: [{ t: .08, t2: .17, kind: 'arc', range: 84, arc: 2.4, dmg: 24, kb: 170 }] },
    N4: { dur: .34, step: 110, swing: -1, pose: 'slash', hits: [{ t: .08, t2: .18, kind: 'arc', range: 86, arc: 2.6, dmg: 26, kb: 190 }] },
    N5: { dur: .50, step: 40, swing: 1, pose: 'spin', hits: [{ t: .12, t2: .24, kind: 'arc', range: 110, arc: TAU, dmg: 38, kb: 340, launch: 300, fx: 'spin' }] },
    C1: { dur: .50, armor: 1, pose: 'thrust', name: '衝波', hits: [{ t: .18, kind: 'proj', p: 'wave', n: 1, spd: 620, life: .6, r: 54, dmg: 48, kb: 300, launch: 420, pierce: 1 }] },
    C2: { dur: .55, armor: 1, pose: 'thrust', name: '突進斬', dash: { t0: .1, t1: .38, spd: 680 }, hits: [{ t: .1, t2: .38, every: .07, kind: 'arc', range: 68, arc: TAU, dmg: 16, kb: 120, fx: 'spin' }] },
    C3: { dur: .62, armor: 1, pose: 'spin', name: '旋風', hits: [{ t: .2, t2: .3, kind: 'arc', range: 148, arc: TAU, dmg: 54, kb: 380, launch: 480, fx: 'ring' }] },
    C4: { dur: .64, armor: 1, pose: 'overhead', name: '烈破', hits: [{ t: .22, t2: .32, kind: 'arc', range: 185, arc: 1.6, dmg: 72, kb: 600, launch: 300, fx: 'cone' }] },
    C5: { dur: .88, armor: 1, pose: 'overhead', name: '地裂', hits: [{ t: .32, t2: .42, kind: 'arc', range: 220, arc: TAU, dmg: 96, kb: 560, launch: 580, fx: 'quake' }] },
    J: { name: '兜割り', land: { range: 100, dmg: 34, kb: 300, launch: 340 } },
    JC: { name: '天落斬', land: { range: 175, dmg: 62, kb: 440, launch: 500 } },
    musou: { name: '天下一閃', style: 'spin', dur: 2.8, tick: .1, until: 2.3, range: 128, dmg: 17, kb: 90, launch: 130, moveSpd: 175, final: { t: 2.4, range: 315, dmg: 160, kb: 640, launch: 700 } },
  },
  yari: {
    combo: ['N1', 'N2', 'N3', 'N4', 'N5'], charge: { idle: 'C1', N1: 'C2', N2: 'C3', N3: 'C4', N4: 'C5' },
    N1: { dur: .30, step: 70, pose: 'thrust', hits: [{ t: .08, t2: .16, kind: 'arc', range: 122, arc: .6, dmg: 21, kb: 170, fx: 'thrust' }] },
    N2: { dur: .30, step: 70, pose: 'thrust', hits: [{ t: .08, t2: .16, kind: 'arc', range: 122, arc: .6, dmg: 21, kb: 170, fx: 'thrust' }] },
    N3: { dur: .36, step: 60, swing: 1, pose: 'slash', hits: [{ t: .09, t2: .19, kind: 'arc', range: 112, arc: 2.6, dmg: 22, kb: 180 }] },
    N4: { dur: .38, step: 90, pose: 'thrust', hits: [{ t: .08, t2: .24, every: .08, kind: 'arc', range: 130, arc: .65, dmg: 16, kb: 120, fx: 'thrust' }] },
    N5: { dur: .52, step: 40, pose: 'spin', hits: [{ t: .12, t2: .26, kind: 'arc', range: 126, arc: TAU, dmg: 36, kb: 330, launch: 320, fx: 'spin' }] },
    C1: { dur: .52, armor: 1, pose: 'thrustUp', name: '昇竜突', hits: [{ t: .16, t2: .26, kind: 'arc', range: 140, arc: .9, dmg: 42, kb: 140, launch: 600, fx: 'thrust' }] },
    C2: { dur: .62, armor: 1, pose: 'thrust', name: '連突', hits: [{ t: .08, t2: .5, every: .06, kind: 'arc', range: 140, arc: .75, dmg: 12, kb: 70, fx: 'thrust' }] },
    C3: { dur: .60, armor: 1, swing: 1, pose: 'slash', name: '大薙ぎ', hits: [{ t: .2, t2: .3, kind: 'arc', range: 155, arc: 4.4, dmg: 52, kb: 440, launch: 260 }] },
    C4: { dur: .66, armor: 1, pose: 'thrust', name: '突撃', dash: { t0: .08, t1: .4, spd: 740 }, hits: [{ t: .08, t2: .4, every: .07, kind: 'arc', range: 80, arc: 1.4, dmg: 16, kb: 220, fx: 'none' }, { t: .42, t2: .5, kind: 'arc', range: 155, arc: .8, dmg: 62, kb: 540, launch: 320, fx: 'thrust' }] },
    C5: { dur: .92, armor: 1, pose: 'spin', name: '旋槍嵐', hits: [{ t: .12, t2: .6, every: .1, kind: 'arc', range: 152, arc: TAU, dmg: 22, kb: 100, launch: 170, fx: 'spin' }, { t: .68, t2: .76, kind: 'arc', range: 195, arc: TAU, dmg: 70, kb: 540, launch: 540, fx: 'ring' }] },
    J: { name: '降り突き', land: { range: 100, dmg: 36, kb: 300, launch: 340 } },
    JC: { name: '天槍落とし', land: { range: 170, dmg: 60, kb: 440, launch: 520 } },
    musou: { name: '千本桜突き', style: 'thrust', dur: 2.8, tick: .06, until: 2.3, range: 178, arc: .9, dmg: 13, kb: 60, launch: 70, moveSpd: 120, final: { t: 2.4, range: 290, dmg: 155, kb: 640, launch: 660 } },
  },
  odachi: {
    combo: ['N1', 'N2', 'N3', 'N4'], charge: { idle: 'C1', N1: 'C2', N2: 'C3', N3: 'C4', N4: 'C5' },
    N1: { dur: .48, step: 70, swing: 1, armor: 1, pose: 'slash', heavy: 1, hits: [{ t: .2, t2: .3, kind: 'arc', range: 112, arc: 2.6, dmg: 42, kb: 300 }] },
    N2: { dur: .48, step: 70, swing: -1, armor: 1, pose: 'slash', heavy: 1, hits: [{ t: .2, t2: .3, kind: 'arc', range: 112, arc: 2.6, dmg: 42, kb: 300 }] },
    N3: { dur: .56, step: 50, armor: 1, pose: 'overhead', heavy: 1, hits: [{ t: .26, t2: .34, kind: 'arc', range: 128, arc: 1.3, dmg: 58, kb: 240, launch: 360, fx: 'cone' }] },
    N4: { dur: .62, step: 40, armor: 1, pose: 'spin', heavy: 1, hits: [{ t: .22, t2: .34, kind: 'arc', range: 126, arc: TAU, dmg: 54, kb: 400, launch: 320, fx: 'spin' }] },
    C1: { dur: .78, armor: 1, pose: 'overhead', name: '叩き割り', hits: [{ t: .36, t2: .44, kind: 'arc', range: 180, arc: TAU, dmg: 68, kb: 440, launch: 460, fx: 'quake' }] },
    C2: { dur: .62, armor: 1, pose: 'upper', name: '天衝', hits: [{ t: .2, t2: .3, kind: 'arc', range: 130, arc: 1.8, dmg: 58, kb: 140, launch: 680 }] },
    C3: { dur: .95, armor: 1, pose: 'spin', name: '大旋風', move: 130, hits: [{ t: .12, t2: .75, every: .12, kind: 'arc', range: 140, arc: TAU, dmg: 30, kb: 220, launch: 160, fx: 'spin' }] },
    C4: { dur: .85, armor: 1, pose: 'overhead', name: '地割れ', hits: fissure() },
    C5: { dur: 1.05, armor: 1, pose: 'overhead', name: '大爆砕', hits: [{ t: .42, t2: .5, kind: 'arc', range: 255, arc: TAU, dmg: 122, kb: 640, launch: 640, fx: 'quake' }] },
    J: { name: '岩落とし', land: { range: 125, dmg: 50, kb: 360, launch: 400 } },
    JC: { name: '天崩', land: { range: 205, dmg: 82, kb: 500, launch: 560 } },
    musou: { name: '鬼神大断', style: 'slam', dur: 2.9, tick: .34, until: 2.35, range: 168, dmg: 46, kb: 360, launch: 380, moveSpd: 150, final: { t: 2.45, range: 345, dmg: 210, kb: 720, launch: 740 } },
  },
  yumi: {
    combo: ['N1', 'N2', 'N3', 'N4', 'N5'], charge: { idle: 'C1', N1: 'C2', N2: 'C3', N3: 'C4', N4: 'C5' },
    N1: { dur: .24, pose: 'bow', hits: [arrowShot()] },
    N2: { dur: .24, pose: 'bow', hits: [arrowShot()] },
    N3: { dur: .24, pose: 'bow', hits: [arrowShot()] },
    N4: { dur: .26, pose: 'bow', hits: [arrowShot(22)] },
    N5: { dur: .38, pose: 'bow', hits: [{ t: .1, kind: 'proj', p: 'arrow', n: 5, spread: .7, spd: 960, life: .6, r: 16, dmg: 22, kb: 130, aim: 1 }] },
    C1: { dur: .50, armor: 1, pose: 'bow', name: '貫き矢', hits: [{ t: .22, kind: 'proj', p: 'bigarrow', n: 1, spd: 1250, life: .75, r: 28, dmg: 52, kb: 280, launch: 280, pierce: 1, aim: 1 }] },
    C2: { dur: .50, armor: 1, pose: 'bow', name: '扇射ち', hits: [{ t: .18, kind: 'proj', p: 'arrow', n: 9, spread: 1.5, spd: 920, life: .55, r: 18, dmg: 27, kb: 170, launch: 140 }] },
    C3: { dur: .55, armor: 1, pose: 'kick', name: '爆蹴', back: { t0: .22, t1: .45, spd: -430 }, hits: [{ t: .1, t2: .18, kind: 'arc', range: 98, arc: TAU, dmg: 36, kb: 500, launch: 380, fx: 'ring' }] },
    C4: { dur: .60, armor: 1, pose: 'bowUp', name: '雨矢', hits: [{ t: .2, kind: 'rain', at: 270, radius: 145, ticks: 7, every: .09, dmg: 24, kb: 80, launch: 180 }] },
    C5: { dur: .75, armor: 1, pose: 'bow', name: '大火矢', hits: [{ t: .3, kind: 'proj', p: 'fire', n: 1, spd: 820, life: .6, r: 24, dmg: 40, kb: 200, aim: 1, explode: { range: 185, dmg: 98, kb: 580, launch: 580 } }] },
    J: { name: '空射ち', air: { kind: 'proj', p: 'arrow', n: 5, spread: .9, spd: 920, life: .5, r: 16, dmg: 22, kb: 120 } },
    JC: { name: '落雷矢', land: { range: 155, dmg: 52, kb: 440, launch: 440 } },
    musou: { name: '天弓・雨月', style: 'rain', dur: 2.8, tick: .06, until: 2.3, range: 300, dmg: 18, kb: 60, launch: 160, moveSpd: 130, final: { t: 2.4, range: 305, dmg: 150, kb: 600, launch: 660 } },
  },
};

// 武将（プレイヤーキャラクター）
const CHARS = [
  { id: 'jin',   name: '天城 迅',   title: '疾風の剣士',   weapon: 'katana', hp: 1200, spd: 235, col: 0x26407a, body: 0x1e3366, head: 0x1a1f2c, crest: 0xf0cc6a, flag: 0xd4ae55, mon: 'circle',
    desc: '刀。速さと攻撃範囲のバランスが良い。衝撃波や突進斬で、離れた敵にも届く。' },
  { id: 'chiyo', name: '鷹宮 千代', title: '紅槍の姫武者', weapon: 'yari',   hp: 1100, spd: 248, col: 0x8a2a3a, body: 0x6e1f2c, head: 0x2a1418, crest: 0xe8e8f0, flag: 0xe0e0e8, mon: 'flower',
    desc: '槍。前方に長く届く突きと、広い薙ぎ払い。動きが速く、突撃で敵陣を貫く。' },
  { id: 'gou',   name: '岩鉄 豪',   title: '鬼の大太刀',   weapon: 'odachi', hp: 1550, spd: 205, col: 0x4a4a52, body: 0x34343c, head: 0x1c1c22, crest: 0xc0392b, flag: 0x8a1f18, mon: 'diamond',
    desc: '大太刀。振りは遅いが一撃が重い。攻撃中は敵の攻撃でひるまない。体力が多い。' },
  { id: 'rin',   name: '白鷺 凛',   title: '月影の弓取り', weapon: 'yumi',   hp: 1000, spd: 242, col: 0xc8ccd8, body: 0x9aa0b4, head: 0x2a2e3a, crest: 0x8fb8ff, flag: 0x5a7ab8, mon: 'moon',
    desc: '弓。離れた敵を射抜く。近づかれたら爆蹴で突き放す。無双奥義では矢の雨を降らせる。' },
];
const charById = id => CHARS.find(c => c.id === id) || CHARS[0];

// 敵・味方の武将の見た目
const OFFICER_LOOKS = {
  '鬼塚 剛蔵':   { weapon: 'yari',   color: '#6b3d8f' },
  '朱雀院 楓':   { weapon: 'katana', color: '#2f7a72' },
  '岩切 大膳':   { weapon: 'odachi', color: '#8a6420' },
  '黒鉄 玄斎':   { weapon: 'odachi', color: '#1c1a1f' },
  '榊原 宗典':   { weapon: 'yari',   color: '#3a5a8a' },
  '犬飼 小太郎': { weapon: 'katana', color: '#2f6a9a' },
};

// 合戦。$P はプレイヤー武将の名前に置き換わる
const STAGES = [
  {
    id: 's1', name: '初陣 ・ 黒鉄峠の戦い', diff: .9, archerRate: .08,
    desc: '峠に築かれた五つの砦を落とし、敵総大将・黒鉄玄斎を討て。砦が残る間、総大将は堅く守られている。',
    start: { x: 260, y: 2060 }, show: { x: 560, y: 1820 }, allyCamp: { x: 230, y: 2150, w: 280, h: 200 }, enemyCamp: { x: 2850, y: 370, w: 400, h: 300 },
    bases: [{ name: '西の砦', x: 700, y: 1350 }, { name: '南の砦', x: 1500, y: 1980 }, { name: '中央砦', x: 1700, y: 1100 }, { name: '北の砦', x: 1100, y: 480 }, { name: '東の砦', x: 2500, y: 1320 }],
    roads: [[[250, 2150], [700, 1350], [1100, 480], [2850, 350]], [[250, 2150], [1500, 1980], [2500, 1320], [2850, 350]], [[700, 1350], [1700, 1100], [2500, 1320]], [[1500, 1980], [1700, 1100], [1100, 480]]],
    officers: [{ name: '鬼塚 剛蔵', x: 1250, y: 1650 }, { name: '朱雀院 楓', x: 1950, y: 800 }, { name: '岩切 大膳', x: 2300, y: 1700 }],
    boss: { name: '黒鉄 玄斎', x: 2850, y: 360, hp: 3000 },
    allies: [{ name: '榊原 宗典', x: 480, y: 1880 }],
    brief: [['榊原 宗典', '若、敵は黒鉄峠の砦に籠もっております。まずは手前の西と南の砦から崩しましょうぞ。'], ['$P', '任せておけ。砦の兵長を討てば、砦はこちらのものだな。'], ['榊原 宗典', 'いかにも。砦を落とすほど味方の士気も上がりまする。']],
    events: [
      { at: { t: 2 }, say: [['$P', '天下一閃、ここに推参！']] },
      { at: { bases: 3 }, say: [['鬼塚 剛蔵', '小僧が調子に乗りおって！ わしの槍を受けてみよ！']] },
      { at: { t: 75 }, ambush: { near: '榊原 宗典', n: 14 }, say: [['榊原 宗典', 'むう、伏兵か！ 若、助太刀を願いまする！']] },
      { at: { bases: 0 }, say: [['黒鉄 玄斎', '砦をすべて落としたか……。よかろう、この玄斎自ら相手をしてやる。']] },
      { at: { bossHp: .5 }, rage: 1, say: [['黒鉄 玄斎', '小癪な……！ 鬼哭の太刀、受けてみよ！']] },
    ],
  },
  {
    id: 's2', name: '朱雀川の渡河戦', diff: 1.05, archerRate: .16,
    desc: '朱雀川を挟んだ戦い。橋を渡って東岸の砦を攻めよ。川は橋でしか渡れない。途中、敵の奇襲と本陣への突撃に注意。',
    start: { x: 360, y: 1200 }, show: { x: 520, y: 880 }, allyCamp: { x: 230, y: 1200, w: 280, h: 220 }, enemyCamp: { x: 2950, y: 1200, w: 360, h: 300 },
    river: { x1: 1520, x2: 1690, bridges: [[470, 610], [1130, 1270], [1810, 1950]] },
    bases: [{ name: '西岸北砦', x: 900, y: 560 }, { name: '西岸南砦', x: 900, y: 1840 }, { name: '東岸北砦', x: 2220, y: 540 }, { name: '東岸南砦', x: 2220, y: 1860 }, { name: '川沿い砦', x: 2380, y: 1200 }],
    roads: [[[230, 1200], [900, 560], [1600, 540], [2220, 540], [2950, 1200]], [[230, 1200], [900, 1840], [1600, 1880], [2220, 1860], [2950, 1200]], [[230, 1200], [1600, 1200], [2380, 1200], [2950, 1200]]],
    officers: [{ name: '岩切 大膳', x: 2050, y: 1200 }, { name: '鬼塚 剛蔵', x: 2500, y: 800, hidden: true }],
    boss: { name: '朱雀院 楓', x: 2950, y: 1200, hp: 3300 },
    allies: [{ name: '榊原 宗典', x: 560, y: 1000 }, { name: '犬飼 小太郎', x: 560, y: 1420 }],
    brief: [['犬飼 小太郎', '$P殿！ 朱雀川の向こうに朱雀院楓の本陣がございます。橋は三本、いずれも敵の砦が睨んでおります。'], ['榊原 宗典', '川は深い。橋のほかは渡れませぬ。焦らず西岸の砦から片付けるがよろしかろう。'], ['$P', 'わかった。小太郎、無茶はするなよ。']],
    events: [
      { at: { t: 2 }, say: [['朱雀院 楓', '川を渡れるものなら渡ってみなさい。朱雀の炎で迎えてあげる。']] },
      { at: { t: 70 }, ambush: { x: 1150, y: 1200, n: 18, officer: '鬼塚 剛蔵' }, say: [['鬼塚 剛蔵', 'かかったな！ 背後はがら空きよ！'], ['犬飼 小太郎', '伏兵です！ 鬼塚剛蔵が現れました！']] },
      { at: { t: 150 }, assault: '岩切 大膳', say: [['岩切 大膳', '本陣を突く！ 者ども、続けぃ！'], ['榊原 宗典', '岩切大膳が本陣へ向かっておる！ 食い止めてくだされ！']] },
      { at: { bossHp: .5 }, rage: 1, say: [['朱雀院 楓', 'やるわね……。本気で焼き尽くしてあげる！']] },
    ],
  },
  {
    id: 's3', name: '決戦 ・ 鬼哭ヶ原', diff: 1.2, archerRate: .2,
    desc: '天下分け目の決戦。六つの砦と三人の猛将、そして黒鉄玄斎。敵は本陣への突撃と挟み撃ちを仕掛けてくる。',
    start: { x: 1600, y: 2060 }, show: { x: 1250, y: 1780 }, allyCamp: { x: 1600, y: 2200, w: 320, h: 200 }, enemyCamp: { x: 1600, y: 280, w: 420, h: 300 },
    bases: [{ name: '左翼砦', x: 600, y: 1650 }, { name: '右翼砦', x: 2600, y: 1650 }, { name: '西の丘砦', x: 850, y: 950 }, { name: '東の丘砦', x: 2350, y: 950 }, { name: '中央前砦', x: 1600, y: 1450 }, { name: '中央奥砦', x: 1600, y: 760 }],
    roads: [[[1600, 2200], [1600, 1450], [1600, 760], [1600, 280]], [[1600, 2200], [600, 1650], [850, 950], [1600, 280]], [[1600, 2200], [2600, 1650], [2350, 950], [1600, 280]], [[850, 950], [1600, 760], [2350, 950]]],
    officers: [{ name: '鬼塚 剛蔵', x: 900, y: 1300 }, { name: '岩切 大膳', x: 2300, y: 1300 }, { name: '朱雀院 楓', x: 1600, y: 1100 }],
    boss: { name: '黒鉄 玄斎', x: 1600, y: 300, hp: 4300 },
    allies: [{ name: '榊原 宗典', x: 1250, y: 1950 }, { name: '犬飼 小太郎', x: 1950, y: 1950 }],
    brief: [['榊原 宗典', 'いよいよ決戦にござる。鬼哭ヶ原、ここで勝てば天下は定まりましょう。'], ['犬飼 小太郎', '敵は猛将揃い。左右の砦から挟み撃ちを狙っているようです。'], ['$P', '玄斎を討てば終わりだ。皆、生きて帰るぞ！']],
    events: [
      { at: { t: 2 }, say: [['黒鉄 玄斎', '来たか。鬼哭ヶ原を貴様らの墓場にしてくれる。']] },
      { at: { t: 90 }, assault: '鬼塚 剛蔵', say: [['鬼塚 剛蔵', '本陣を落とせば終わりよ！ 突っ込めぃ！'], ['犬飼 小太郎', '鬼塚が本陣へ！ 止めてください！']] },
      { at: { t: 170 }, ambush: { x: 400, y: 2000, n: 16 }, ambush2: { x: 2800, y: 2000, n: 16 }, say: [['榊原 宗典', '左右から伏兵！ 挟み撃ちにござる！']] },
      { at: { bases: 2 }, say: [['朱雀院 楓', '玄斎様には指一本触れさせない！']] },
      { at: { bossHp: .5 }, rage: 1, say: [['黒鉄 玄斎', 'ぬうう……鬼哭の太刀、とくと味わえ！']] },
    ],
  },
];
