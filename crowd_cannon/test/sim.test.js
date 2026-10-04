// node --test crowd_cannon/test/*.test.js
const test = require('node:test');
const assert = require('node:assert');
const { Game, CFG } = require('../src/sim.js');
const LEVELS = require('../src/levels.js');

const empty = (over) => ({
  name: 'test',
  enemies: { total: 0, initial: 0, rate: 0 },
  obstacles: [],
  gates: [],
  ...over,
});

function run(game, seconds, x) {
  for (let t = 0; t < seconds * 60 && game.state === 'playing'; t++) {
    if (x !== undefined) game.setTarget(x);
    game.step(1 / 60);
    game.deaths.length = 0;
  }
}

test('門を下から通過すると兵が倍率どおりに増える（1つの門は1回だけ）', () => {
  const g = new Game(empty({ enemies: { total: 1, initial: 0, rate: 0 }, gates: [{ x0: 100, x1: 260, y: 400, type: 'mul', value: 5 }] }), 1);
  g.fireOne();
  run(g, 2.5);
  assert.strictEqual(g.blue.n, 5);
});

test('+門は通過した兵1人につき value 人増える', () => {
  const g = new Game(empty({ enemies: { total: 1, initial: 0, rate: 0 }, gates: [{ x0: 100, x1: 260, y: 400, type: 'add', value: 3 }] }), 1);
  g.fireOne();
  run(g, 2.5);
  assert.strictEqual(g.blue.n, 4);
});

test('生け垣は兵の体当たりで壊れる', () => {
  const g = new Game(empty({ enemies: { total: 1, initial: 0, rate: 0 }, obstacles: [{ kind: 'hedge', x: 120, y: 380, w: 120, h: 30, hp: 5 }] }), 1);
  g.firing = true;
  run(g, 3, 180);
  assert.strictEqual(g.obstacles[0].alive, false);
});

test('兵の上限を超えて増えない', () => {
  const g = new Game(empty({ enemies: { total: 1, initial: 0, rate: 0 }, gates: [{ x0: 10, x1: 350, y: 400, type: 'mul', value: 99 }, { x0: 10, x1: 350, y: 370, type: 'mul', value: 99 }] }), 1);
  g.firing = true;
  run(g, 4, 180);
  assert.ok(g.blue.n <= CFG.maxBlue);
  assert.ok(g.peakBlue >= CFG.maxBlue - 1);
});

test('敵を全滅させると勝利', () => {
  const g = new Game(empty({ enemies: { total: 50, initial: 50, rate: 0 }, gates: [{ x0: 10, x1: 350, y: 450, type: 'mul', value: 10 }] }), 1);
  g.firing = true;
  run(g, 60, 180);
  assert.strictEqual(g.state, 'won');
});

test('何もしないと砦が落ちて敗北', () => {
  const g = new Game(LEVELS[0], 1);
  run(g, 120);
  assert.strictEqual(g.state, 'lost');
  assert.strictEqual(g.baseHp, 0);
});

test('ステージ1は真ん中の門を狙い続ければクリアできる', () => {
  const g = new Game(LEVELS[0], 3);
  g.firing = true;
  run(g, 120, 180);
  assert.strictEqual(g.state, 'won');
});

test('全ステージの門は32個以下（ビットマスクで管理）', () => {
  for (const lv of LEVELS) assert.ok(lv.gates.length <= 32, lv.name);
});
