// ───────────── 合戦の状態・戦闘処理 ─────────────
let G = null, P = null, STAGE = STAGES[0];
let uid = 0;
const EXP = { ashi: 2, archer: 2, leader: 20, officer: 80, boss: 200 };

function mkUnit(team, kind, x, y, opt = {}) {
  const d = KIND[kind];
  const look = opt.name ? OFFICER_LOOKS[opt.name] : null;
  const hpMul = team === 'E' && (kind === 'officer' || kind === 'boss' || kind === 'leader') ? STAGE.diff : 1;
  const hp = (opt.hp || d.hp) * hpMul;
  return {
    id: ++uid, team, kind, x, y, vx: 0, vy: 0, z: 0, vz: 0, r: d.r, hp, maxHp: hp, spd: d.spd * rand(.9, 1.1),
    face: rand(0, TAU), st: 'idle', t: 0, cd: rand(1, 3), stun: 0, name: opt.name || null, base: opt.base ?? null,
    home: { x, y }, flash: 0, offs: rand(-1.2, 1.2), dying: 0, color: look ? look.color : null, weapon: look ? look.weapon : d.weapon,
    swing: 1, combo: 0, tgt: null, tgtT: rand(0, .5), order: opt.order || null, spinV: 0, spinA: 0, alert: !!opt.alert, rageCd: 4,
  };
}
const soldierKind = () => Math.random() < STAGE.archerRate ? 'archer' : 'ashi';
function addUnit(u) { G.units.push(u); return u; }

function mkPlayer(ch) {
  const p = {
    char: ch, mv: MOVES[ch.weapon], x: STAGE.start.x, y: STAGE.start.y, vx: 0, vy: 0, z: 0, vz: 0, r: 16,
    hp: 1, maxHp: 1, mu: 30, face: -Math.PI / 2, st: 'idle', t: 0, atk: null, queued: null, inv: 0, flash: 0,
    airShot: false, diveCharge: false, mtick: 0, mfinal: false, atkMul: 1, team: 'A',
  };
  return p;
}
function applyStats(heal) {
  const cs = charSave(P.char.id);
  P.maxHp = Math.round(P.char.hp + (cs.lv - 1) * 45);
  P.atkMul = 1 + (cs.lv - 1) * .06;
  if (heal) P.hp = Math.min(P.maxHp, P.hp + P.maxHp * .25);
}

function newGame(si, cid) {
  STAGE = STAGES[si];
  const ch = charById(cid);
  G = {
    si, t: 0, ko: 0, units: [], fx: [], parts: [], items: [], texts: [], proj: [], rains: [], msgs: [], missions: [],
    talk: { q: [], cur: null, t: 0 }, shake: 0, hitstop: 0, slowmo: 0, combo: 0, comboT: 0, maxCombo: 0, over: null,
    focus: null, focusT: 0, bossWarnT: 0, musouTint: 0, nextKoMsg: 100, morale: 0, expGain: 0, lvUps: 0, cutin: null,
    flash: 0, zoom: 0, camReset: true, rescueT: 1,
    bases: STAGE.bases.map((b, i) => ({ ...b, i, w: 230, h: 190, owner: 'E', spawnT: rand(0, 2), allyT: 4, leader: null })),
    events: STAGE.events.map(e => ({ ...e, done: false })),
    spawn: { main: 0, roam: 8, ally: 1, near: 4 },
  };
  P = mkPlayer(ch); applyStats(false); P.hp = P.maxHp;
  for (const b of G.bases) {
    b.leader = addUnit(mkUnit('E', 'leader', b.x, b.y, { name: b.name + ' 兵長', base: b.i }));
    for (let k = 0; k < 10; k++) addUnit(mkUnit('E', soldierKind(), b.x + rand(-100, 100), b.y + rand(-80, 80), { base: b.i }));
  }
  for (const o of STAGE.officers) {
    if (o.hidden) continue;
    addUnit(mkUnit('E', 'officer', o.x, o.y, { name: o.name }));
    for (let k = 0; k < 8; k++) addUnit(mkUnit('E', soldierKind(), o.x + rand(-120, 120), o.y + rand(-120, 120)));
  }
  const bs = STAGE.boss;
  G.boss = addUnit(mkUnit('E', 'boss', bs.x, bs.y, { name: bs.name, hp: bs.hp }));
  const ec = STAGE.enemyCamp;
  for (let k = 0; k < 16; k++) addUnit(mkUnit('E', soldierKind(), ec.x + rand(-ec.w / 2 + 30, ec.w / 2 - 30), ec.y + rand(-ec.h / 2 + 30, ec.h / 2 - 30), { base: 'main' }));
  for (let k = 0; k < 22; k++) {
    const x = rand(400, WORLD_W - 400), y = rand(400, WORLD_H - 400);
    if (Math.hypot(x - P.x, y - P.y) < 700 || blocked(x, y)) continue;
    addUnit(mkUnit('E', soldierKind(), x, y));
  }
  for (const a of STAGE.allies) {
    addUnit(mkUnit('A', 'officer', a.x, a.y, { name: a.name, hp: 1500 }));
    for (let k = 0; k < 6; k++) addUnit(mkUnit('A', 'ashi', a.x + rand(-80, 80), a.y + rand(-80, 80)));
  }
  pushMsg(`${STAGE.name} ― 合戦開始`, COL.paper, true);
}

// ───────────── 地形（川） ─────────────
function blocked(x, y) {
  const r = STAGE.river;
  if (!r || x < r.x1 || x > r.x2) return false;
  for (const b of r.bridges) if (y > b[0] + 8 && y < b[1] - 8) return false;
  return true;
}
function moveBody(u, dx, dy) {
  const nx = clamp(u.x + dx, 50, WORLD_W - 50), ny = clamp(u.y + dy, 50, WORLD_H - 50);
  if (!STAGE.river) { u.x = nx; u.y = ny; return; }
  if (!blocked(nx, u.y)) u.x = nx;
  if (!blocked(u.x, ny)) u.y = ny;
}
// 川の向こうへ行くときは橋を経由する
function waypoint(x, y, tx, ty) {
  const r = STAGE.river;
  if (!r) return [tx, ty];
  const mid = (r.x1 + r.x2) / 2, sA = x < mid, sB = tx < mid, inR = x >= r.x1 - 4 && x <= r.x2 + 4;
  if (sA === sB && !inR) return [tx, ty];
  let best = 0, bd = 1e9;
  for (const b of r.bridges) { const by = (b[0] + b[1]) / 2, c = Math.abs(by - y) + Math.abs(by - ty); if (c < bd) { bd = c; best = by; } }
  if (inR) return [sB ? r.x1 - 50 : r.x2 + 50, best];
  const ex = sA ? r.x1 - 30 : r.x2 + 30;
  if (Math.abs(y - best) > 30 || Math.abs(x - ex) > 50) return [ex, best];
  return [sA ? r.x2 + 50 : r.x1 - 50, best];
}
const inRect = (u, c) => Math.abs(u.x - c.x) < c.w / 2 && Math.abs(u.y - c.y) < c.h / 2;

// ───────────── 空間グリッド（近くの兵を素早く探す） ─────────────
const CELL = 128, GRID = new Map();
function buildGrid() {
  GRID.clear();
  for (const u of G.units) {
    if (u.dying) continue;
    const k = (u.x / CELL | 0) + (u.y / CELL | 0) * 64;
    let a = GRID.get(k); if (!a) { a = []; GRID.set(k, a); } a.push(u);
  }
}
function forNear(x, y, r, fn) {
  const x0 = Math.max(0, (x - r) / CELL | 0), x1 = (x + r) / CELL | 0, y0 = Math.max(0, (y - r) / CELL | 0), y1 = (y + r) / CELL | 0;
  for (let gy = y0; gy <= y1; gy++) for (let gx = x0; gx <= x1; gx++) { const a = GRID.get(gx + gy * 64); if (a) for (const u of a) fn(u); }
}

// ───────────── 演出の小物 ─────────────
function pushMsg(text, color = COL.paper, big = false) { G.msgs.push({ text, color, t: 0, life: big ? 3.2 : 2.6, big }); if (G.msgs.length > 4) G.msgs.shift(); }
function floatText(x, y, text, color, size = 14) { if (G.texts.length < 80) G.texts.push({ x, y, text, color, size, t: 0, life: .8 }); }
function sparks(x, y, n, color, spd = 260, h = 22) {
  for (let i = 0; i < n && G.parts.length < 560; i++) {
    const a = rand(0, TAU), s = rand(spd * .3, spd);
    G.parts.push({ x, y, vx: Math.cos(a) * s, vy: Math.sin(a) * s, h: h + rand(-4, 12), vh: rand(40, 240), life: rand(.2, .45), t: 0, color });
  }
}
function dust(x, y, n, spd = 160) {
  for (let i = 0; i < n && G.parts.length < 560; i++) {
    const a = rand(0, TAU), s = rand(spd * .3, spd);
    G.parts.push({ x, y, vx: Math.cos(a) * s, vy: Math.sin(a) * s, h: 3, vh: rand(30, 120), life: rand(.3, .6), t: 0, color: '#9a8466', grav: 200 });
  }
}
function fx(o) { o.t = 0; G.fx.push(o); return o; }
function queueSay(lines) { for (const [name, text] of lines) G.talk.q.push({ name: name === '$P' ? P.char.name : name, text: text.replace(/\$P/g, P.char.name) }); }
const basesLeft = () => G.bases.filter(b => b.owner === 'E').length;
const moraleMul = team => team === 'A' ? 1 + Math.max(0, G.morale) / 160 : 1 + Math.max(0, -G.morale) / 160;
function addMorale(v) { G.morale = clamp(G.morale + v, -100, 100); }
function dropItem(x, y, type) { G.items.push({ x: x + rand(-12, 12), y: y + rand(-12, 12), type, t: 0 }); }

// ───────────── ダメージ ─────────────
// 攻撃側チームと逆の兵に当たる。src は 'P'（プレイヤー）か兵
function hitArea(x, y, range, arc, face, set, h, src) {
  const team = src === 'P' ? 'A' : src.team;
  let n = 0;
  forNear(x, y, range + 30, u => {
    if (u.dying || u.team === team || set.has(u)) return;
    const dx = u.x - x, dy = u.y - y, d = Math.hypot(dx, dy);
    if (d > range + u.r) return;
    const ang = Math.atan2(dy, dx);
    if (arc < TAU - .01 && Math.abs(angDiff(ang, face)) > arc / 2 + (d < 30 ? 1 : 0)) return;
    set.add(u); damageUnit(u, h, d > 1 ? ang : face, src); n++;
  });
  if (team === 'E' && !set.has(P) && P.st !== 'down') {
    const dx = P.x - x, dy = P.y - y, d = Math.hypot(dx, dy);
    if (d <= range + P.r && P.z < 40) {
      const ang = Math.atan2(dy, dx);
      if (arc >= TAU - .01 || Math.abs(angDiff(ang, face)) <= arc / 2 + .3) { set.add(P); hurtPlayer(h.dmg, ang); }
    }
  }
  return n;
}

function damageUnit(u, h, ang, src) {
  const byP = src === 'P';
  let dmg = h.dmg * rand(.9, 1.1);
  if (byP) dmg *= P.atkMul;
  else if (src && src.team) dmg *= moraleMul(src.team) * (src.kind === 'ashi' || src.kind === 'archer' ? .5 : .75);
  if (u.kind === 'boss' && basesLeft() > 0) {
    dmg *= .2;
    if (byP && G.bossWarnT <= 0) { pushMsg(`総大将は砦に守られている（残り ${basesLeft()} 砦）`, '#e0a090'); G.bossWarnT = 4; }
  }
  let guarded = false;
  if ((u.kind === 'officer' || u.kind === 'boss') && u.stun <= 0 && u.z <= 0 && u.st !== 'wind' && u.st !== 'rage' && Math.random() < .22 && Math.abs(angDiff(u.face, ang + Math.PI)) < 1.2) {
    guarded = true; dmg *= .2;
    if (byP) { floatText(u.x, u.y, '防', '#9fc4ff', 18); sfx.guard(); }
    sparks(u.x - Math.cos(ang) * u.r, u.y - Math.sin(ang) * u.r, 6, '#bcd6ff', 200);
  }
  u.hp -= dmg; u.flash = .1; u.alert = true;
  if (byP && u.team === 'E') { u.tgt = P; u.tgtT = 1.2; }
  else if (src && src !== 'P' && !u.tgt) u.tgt = src;
  const kbMul = { ashi: 1, archer: 1, leader: .7, officer: .35, boss: .22 }[u.kind];
  if (!guarded) {
    u.vx += Math.cos(ang) * h.kb * kbMul; u.vy += Math.sin(ang) * h.kb * kbMul;
    u.stun = Math.max(u.stun, KIND[u.kind].stun); if (u.st !== 'rage') u.st = 'idle';
    const lm = { ashi: 1, archer: 1, leader: .85, officer: .35, boss: 0 }[u.kind];
    if (h.launch && lm > 0) { u.vz = Math.max(u.vz, h.launch * lm * rand(.85, 1.1)); u.spinV = rand(-1, 1) * (6 + h.launch / 60); }
  }
  if (byP && u.team === 'E') {
    G.combo++; G.comboT = 2.6; G.maxCombo = Math.max(G.maxCombo, G.combo);
    if (P.st !== 'musou') P.mu = Math.min(100, P.mu + (u.kind === 'ashi' || u.kind === 'archer' ? .9 : 1.6));
    sparks(u.x, u.y, u.kind === 'ashi' ? 5 : 9, guarded ? '#cfe0ff' : '#ffd88a', 260, 22 + u.z);
    if (u.kind !== 'ashi' && u.kind !== 'archer') { G.focus = u; G.focusT = 4; floatText(u.x + rand(-10, 10), u.y, Math.round(dmg), '#ffe2a0', 13); G.hitstop = Math.max(G.hitstop, .035); }
    if (h.kb >= 400) G.hitstop = Math.max(G.hitstop, .05);
    sfx.hit();
  } else if (Math.random() < .3) sparks(u.x, u.y, 2, '#ffd88a', 160, 22 + u.z);
  if (u.hp <= 0) killUnit(u, src, h);
}

function killUnit(u, src, h) {
  const byP = src === 'P';
  u.dying = 1.1; u.hp = 0; u.st = 'idle';
  // 決め手の一撃は派手に吹き飛ばす
  if (byP && h && h.kb >= 280 && (u.kind === 'ashi' || u.kind === 'archer' || u.kind === 'leader')) { u.vx *= 1.7; u.vy *= 1.7; u.vz = Math.max(u.vz, 380 + h.kb * .3); u.spinV = rand(-1, 1) * 16; }
  if (u.team === 'E') {
    if (byP) {
      G.ko++; addExp(EXP[u.kind]);
      if ((u.kind === 'ashi' || u.kind === 'archer') && Math.random() < .035) dropItem(u.x, u.y, Math.random() < .55 ? 'bun' : 'sake');
      if (G.ko >= G.nextKoMsg) { pushMsg(`${G.nextKoMsg}人斬り達成`, COL.paper); G.nextKoMsg += 100; }
    }
    if (u.kind !== 'ashi' && u.kind !== 'archer') {
      sparks(u.x, u.y, 26, '#ffcf70', 380); G.shake = Math.max(G.shake, .25);
      dropItem(u.x, u.y, u.kind === 'leader' ? 'bun' : 'bigbun');
      if (u.kind !== 'leader') dropItem(u.x + 20, u.y, 'sake');
    }
    if (u.kind === 'leader' && typeof u.base === 'number') {
      const b = G.bases[u.base]; b.owner = 'A'; addMorale(12);
      pushMsg(`${b.name}を制圧！（残り ${basesLeft()} 砦）`, '#9cc0ff', true); sfx.horn();
      for (let k = 0; k < 4; k++) addUnit(mkUnit('A', 'ashi', b.x + rand(-60, 60), b.y + rand(-50, 50)));
      if (basesLeft() === 0) pushMsg('総大将の守りが崩れた！ 本陣へ攻め込め', COL.gold, true);
    }
    if (u.kind === 'officer') { pushMsg(`敵将 ${u.name}、討ち取ったり！`, COL.gold, true); sfx.big(); addMorale(18); }
    if (u.kind === 'boss') { pushMsg(`${u.name}、討ち取ったり！`, COL.gold, true); sfx.big(); G.shake = .8; G.slowmo = .8; if (!G.over) G.over = { win: true, t: 2.4 }; }
  } else if (u.kind === 'officer') {
    pushMsg(`味方武将 ${u.name}、討死……`, '#ff9a8a', true); addMorale(-22);
  }
}

function addExp(n) {
  G.expGain += n;
  const cs = charSave(P.char.id);
  if (cs.lv >= MAX_LV) return;
  cs.exp += n;
  while (cs.lv < MAX_LV && cs.exp >= expNeed(cs.lv)) {
    cs.exp -= expNeed(cs.lv); cs.lv++; G.lvUps++;
    applyStats(true);
    pushMsg(`レベルアップ！ Lv ${cs.lv}`, COL.gold); floatText(P.x, P.y, 'Lv UP', COL.gold, 18); sfx.levelup();
  }
}

function hurtPlayer(dmg, ang) {
  if (P.inv > 0 || G.over || P.st === 'down') return;
  dmg *= STAGE.diff * moraleMul('E');
  P.hp -= dmg; P.flash = .15; P.mu = Math.min(100, P.mu + 2.5);
  G.shake = Math.max(G.shake, .15); sfx.hurt();
  sparks(P.x, P.y, 8, '#ff7a6a', 240);
  const armor = (P.st === 'atk' && P.atk.def.armor) || P.st === 'musou';
  if (!armor) {
    P.st = 'hurt'; P.t = .28; P.vx = Math.cos(ang) * 260; P.vy = Math.sin(ang) * 260; P.queued = null;
    if (P.z > 0) { P.vz = Math.max(P.vz, 120); }
  }
  P.inv = .4;
  if (P.hp <= 0) { P.hp = 0; P.st = 'down'; if (!G.over) G.over = { win: false, t: 1.8, reason: `${P.char.name}、力尽きる` }; pushMsg('無念……', '#ff8a7a', true); }
}

// ───────────── 飛び道具と矢の雨 ─────────────
function fireProj(spec, x, y, h, face, src, vh = 0) {
  const n = spec.n || 1;
  for (let i = 0; i < n; i++) {
    const a = face + (n > 1 ? (i / (n - 1) - .5) * spec.spread : 0);
    G.proj.push({
      p: spec.p, x, y, h, vh, ang: a, vx: Math.cos(a) * spec.spd, vy: Math.sin(a) * spec.spd, t: 0, life: spec.life, r: spec.r,
      dmg: spec.dmg, kb: spec.kb, launch: spec.launch || 0, pierce: !!spec.pierce, explode: spec.explode || null,
      hit: new Set(), src, team: src === 'P' ? 'A' : src.team,
    });
  }
}
function explode(p) {
  fx({ type: 'ring', x: p.x, y: p.y, r: p.explode.range, life: .4, color: 0xffa040 });
  fx({ type: 'cone', x: p.x, y: p.y, face: 0, arc: TAU, r: p.explode.range * .8, life: .3, color: 0xff8030 });
  sparks(p.x, p.y, 30, '#ffb050', 420, 15); dust(p.x, p.y, 10, 260);
  hitArea(p.x, p.y, p.explode.range, TAU, 0, new Set(), p.explode, p.src);
  G.shake = Math.max(G.shake, .45); sfx.boom();
}
function updateProj(dt) {
  for (const p of G.proj) {
    p.t += dt; p.x += p.vx * dt; p.y += p.vy * dt;
    if (p.vh) { p.h += p.vh * dt; if (p.h <= 4) { p.h = 4; p.t = p.life; } }
    if (p.p === 'fire' && Math.random() < .6) G.parts.push({ x: p.x, y: p.y, vx: rand(-30, 30), vy: rand(-30, 30), h: p.h, vh: rand(10, 60), life: .3, t: 0, color: '#ff9030' });
    if (p.done) continue;
    if (p.team === 'A') {
      forNear(p.x, p.y, p.r + 30, u => {
        if (p.done || u.dying || u.team === 'A' || p.hit.has(u) || u.z > p.h + 30) return;
        if (Math.hypot(u.x - p.x, u.y - p.y) > p.r + u.r) return;
        p.hit.add(u); damageUnit(u, p, p.ang, p.src);
        if (!p.pierce) p.done = true;
      });
    } else {
      if (!p.hit.has(P) && P.z < 40 && Math.hypot(P.x - p.x, P.y - p.y) < p.r + P.r) { p.hit.add(P); hurtPlayer(p.dmg, p.ang); p.done = true; }
      if (!p.done) forNear(p.x, p.y, p.r + 30, u => {
        if (p.done || u.dying || u.team === 'E' || p.hit.has(u)) return;
        if (Math.hypot(u.x - p.x, u.y - p.y) > p.r + u.r) return;
        p.hit.add(u); damageUnit(u, p, p.ang, p.src); p.done = true;
      });
    }
    if ((p.done || p.t >= p.life) && p.explode && !p.exploded) { p.exploded = true; explode(p); }
  }
  G.proj = G.proj.filter(p => !p.done && p.t < p.life);
}
function updateRains(dt) {
  for (const r of G.rains) {
    r.next -= dt;
    if (r.next <= 0 && r.left > 0) {
      r.next = r.every; r.left--;
      for (let i = 0; i < 6; i++) { const a = rand(0, TAU), d = rand(0, r.radius); fx({ type: 'fall', x: r.x + Math.cos(a) * d, y: r.y + Math.sin(a) * d, life: .18 }); }
      fx({ type: 'ring', x: r.x, y: r.y, r: r.radius, life: .2, color: 0xbcd6ff });
      hitArea(r.x, r.y, r.radius, TAU, 0, new Set(), r.h, r.src);
      dust(r.x + rand(-r.radius, r.radius) * .6, r.y + rand(-r.radius, r.radius) * .6, 3);
      if (r.src === 'P') sfx.arrow();
    }
  }
  G.rains = G.rains.filter(r => r.left > 0);
}

// ───────────── 兵の行動 ─────────────
function findTarget(u) {
  const D = KIND[u.kind];
  let best = null, bd = D.aggro;
  if (u.team === 'E' && P.st !== 'down') { const d = Math.hypot(P.x - u.x, P.y - u.y) * .75; if (d < bd) { bd = d; best = P; } }
  forNear(u.x, u.y, D.aggro, o => {
    if (o.dying || o.team === u.team) return;
    const d = Math.hypot(o.x - u.x, o.y - u.y);
    if (d < bd) { bd = d; best = o; }
  });
  return best;
}
function marchPoint(u) {
  if (u.order && u.order.type === 'assault') return [STAGE.allyCamp.x, STAGE.allyCamp.y];
  if (u.team === 'A') {
    let best = null, bd = 1e9;
    for (const b of G.bases) if (b.owner === 'E') { const d = Math.hypot(b.x - u.x, b.y - u.y); if (d < bd) { bd = d; best = b; } }
    return best ? [best.x, best.y] : [STAGE.enemyCamp.x, STAGE.enemyCamp.y];
  }
  if (u.order && u.order.type === 'raid') return [STAGE.allyCamp.x, STAGE.allyCamp.y];
  return null;
}
function npcStrike(u) {
  const D = KIND[u.kind];
  const tgt = u.tgt;
  if (D.ranged) {
    if (tgt) { const a = Math.atan2(tgt.y - u.y, tgt.x - u.x) + rand(-.08, .08); fireProj({ p: 'arrow', n: 1, spd: 620, life: .9, r: 12, dmg: D.dmg, kb: 60 }, u.x, u.y, 26, a, u); }
    return;
  }
  const arc = (u.kind === 'boss' && u.combo % 3 === 2) ? TAU : D.arc;
  const range = arc === TAU ? D.reach * 1.3 : D.reach;
  fx({ type: 'slash', x: u.x, y: u.y, face: u.face, arc, r: range, life: .16, color: u.team === 'E' ? 0xff785a : 0x8fb0ff, h: 16 });
  u.swing *= -1; u.combo++;
  const big = u.kind === 'officer' || u.kind === 'boss';
  hitArea(u.x, u.y, range, arc, u.face, new Set(), { dmg: D.dmg, kb: big ? 260 : 110, launch: big && u.combo % 3 === 0 ? 260 : 0 }, u);
}

function updateUnits(dt) {
  let winders = 0;
  for (const u of G.units) if (u.st === 'wind' && u.tgt === P && (u.kind === 'ashi' || u.kind === 'archer')) winders++;
  for (const u of G.units) {
    // 空中（打ち上げ・バウンド）
    if (u.z > 0 || u.vz > 0) {
      u.vz -= 1200 * dt; u.z += u.vz * dt; u.spinA += u.spinV * dt;
      if (u.z <= 0) {
        u.z = 0;
        if (u.vz < -330) { u.vz = -u.vz * .3; u.spinV *= .5; dust(u.x, u.y, 5); }
        else { u.vz = 0; u.spinV = 0; u.spinA = 0; if (!u.dying) u.stun = Math.max(u.stun, .35); }
      }
    }
    const fr = Math.pow(u.z > 0 ? .3 : .004, dt); u.vx *= fr; u.vy *= fr;
    if (u.dying) { u.dying -= dt; moveBody(u, u.vx * dt, u.vy * dt); continue; }
    u.flash = Math.max(0, u.flash - dt);
    const [mx, my] = think(u, dt, winders);
    if (u.st === 'wind' && u.tgt === P && u.t > KIND[u.kind].wind - dt * 1.5) winders++;
    moveBody(u, (mx + u.vx) * dt, (my + u.vy) * dt);
  }
  // 押し合い
  for (const a of G.units) {
    if (a.dying || a.z > 10) continue;
    forNear(a.x, a.y, 40, b => {
      if (b.id <= a.id || b.dying || b.z > 10) return;
      const dx = b.x - a.x, dy = b.y - a.y, rr = a.r + b.r;
      if (dx > rr || dx < -rr || dy > rr || dy < -rr) return;
      const d = Math.hypot(dx, dy) || .01;
      if (d < rr) { const push = (rr - d) / 2, nx = dx / d, ny = dy / d; moveBody(a, -nx * push, -ny * push); moveBody(b, nx * push, ny * push); }
    });
    const dx = a.x - P.x, dy = a.y - P.y, rr = a.r + P.r, d = Math.hypot(dx, dy) || .01;
    if (d < rr && P.z < 20) moveBody(a, dx / d * (rr - d), dy / d * (rr - d));
  }
  G.units = G.units.filter(u => !(u.dying && u.dying <= 0));
}

function think(u, dt, winders) {
  const D = KIND[u.kind];
  if (u.stun > 0 || u.z > 0) { u.stun -= dt; return [0, 0]; }
  if (G.over) { u.st = 'idle'; return [0, 0]; }
  // 総大将の奥義（体力半分以下で解禁）
  if (u.st === 'rageWind') { u.t -= dt; if (u.t <= 0) { u.st = 'rage'; u.t = 1.6; u.tick = 0; sfx.big(); } return [0, 0]; }
  if (u.st === 'rage') {
    u.t -= dt; u.tick -= dt; u.face += dt * 14;
    if (u.tick <= 0) {
      u.tick = .15;
      fx({ type: 'slash', x: u.x, y: u.y, face: rand(0, TAU), arc: 3.6, r: 175, life: .15, color: 0xff4a30, h: 18 });
      hitArea(u.x, u.y, 175, TAU, 0, new Set(), { dmg: 26, kb: 200, launch: 160 }, u);
    }
    if (u.t <= 0) { u.st = 'rec'; u.t = 1.2; u.rageCd = rand(6, 9); }
    const a = Math.atan2(P.y - u.y, P.x - u.x); return [Math.cos(a) * 90, Math.sin(a) * 90];
  }
  if (u.st === 'wind') {
    u.t -= dt;
    if (u.tgt && u.kind !== 'ashi') u.face = turnToward(u.face, Math.atan2(u.tgt.y - u.y, u.tgt.x - u.x), 4 * dt);
    if (u.t <= 0) {
      npcStrike(u);
      if ((u.kind === 'officer' || u.kind === 'boss') && u.combo % 3 !== 0) { u.st = 'wind'; u.t = .22; }
      else { u.st = 'rec'; u.t = u.kind === 'ashi' || u.kind === 'archer' ? .5 : .35; }
    }
    return [0, 0];
  }
  if (u.st === 'rec') { u.t -= dt; if (u.t <= 0) u.st = 'idle'; return [0, 0]; }
  if (u.st === 'dash') {
    u.t -= dt;
    if (u.t <= 0 || (u.tgt && Math.hypot(u.tgt.x - u.x, u.tgt.y - u.y) < D.reach * .8)) { u.st = 'wind'; u.t = .12; }
    return [Math.cos(u.face) * 430, Math.sin(u.face) * 430];
  }
  // 標的の更新
  u.tgtT -= dt;
  if (u.tgt && (u.tgt.dying || (u.tgt === P && P.st === 'down'))) u.tgt = null;
  if (u.tgtT <= 0) {
    u.tgtT = rand(.4, .7);
    const assault = u.order && u.order.type === 'assault';
    const t = findTarget(u);
    if (assault) u.tgt = t && Math.hypot(t.x - u.x, t.y - u.y) < 150 ? t : null;
    else if (!u.tgt || (t && t !== u.tgt && Math.random() < .5)) u.tgt = t;
    // 持ち場から離れすぎたら戻る
    if (u.team === 'E' && u.base !== null && !u.order && Math.hypot(u.x - u.home.x, u.y - u.home.y) > 700 && u.tgt !== P) u.tgt = null;
  }
  const tgt = u.tgt;
  if (tgt) {
    const dx = tgt.x - u.x, dy = tgt.y - u.y, d = Math.hypot(dx, dy) || 1;
    u.face = turnToward(u.face, Math.atan2(dy, dx), 6 * dt);
    let gx, gy, stop;
    if (D.ranged) {
      const want = 300;
      const k = d > D.reach ? 1 : d < want - 60 ? -1 : 0;
      gx = u.x + dx / d * 50 * k; gy = u.y + dy / d * 50 * k; stop = 6;
    } else if (tgt === P && u.kind === 'ashi') {
      const ring = 40 + (u.offs + 1.2) * 14, ang = Math.atan2(u.y - P.y, u.x - P.x) + u.offs * .25;
      gx = P.x + Math.cos(ang) * ring; gy = P.y + Math.sin(ang) * ring; stop = 6;
    } else { gx = tgt.x - dx / d * D.reach * .7; gy = tgt.y - dy / d * D.reach * .7; stop = 8; }
    [gx, gy] = waypoint(u.x, u.y, gx, gy);
    let mx = 0, my = 0;
    const tdx = gx - u.x, tdy = gy - u.y, td = Math.hypot(tdx, tdy);
    if (td > stop) { const s = u.spd * Math.min(1, td / 40); mx = tdx / td * s; my = tdy / td * s; }
    u.cd -= dt;
    if (u.cd <= 0 && d < D.reach + (tgt.r || 14) + 6) {
      if (u.kind === 'ashi' || u.kind === 'archer') {
        if (tgt !== P || winders < 6) { u.st = 'wind'; u.t = D.wind; }
        u.cd = tgt === P ? rand(1.8, 3.4) / Math.max(.6, moraleMul('E')) : rand(1.2, 2.4);
      } else if (u.kind === 'boss' && u.rage && u.rageCd <= 0 && tgt === P) {
        u.st = 'rageWind'; u.t = 1.0; floatText(u.x, u.y, '鬼哭の太刀', '#ff7050', 18);
      } else { u.st = 'wind'; u.t = D.wind; u.combo = 0; u.cd = rand(1.0, 2.0); }
    } else if ((u.kind === 'officer' || u.kind === 'boss') && u.cd <= 0 && d > 140 && d < 300 && Math.random() < dt * .8) {
      u.st = 'dash'; u.t = .45; u.face = Math.atan2(dy, dx); u.combo = 0; u.cd = rand(1.2, 2.2);
      if (u.team === 'E') floatText(u.x, u.y, '！', '#ff9a7a', 22);
    }
    if (u.rage) u.rageCd -= dt;
    return [mx, my];
  }
  // 行軍・待機
  const mp = marchPoint(u);
  if (mp) {
    const [gx, gy] = waypoint(u.x, u.y, mp[0] + u.offs * 40, mp[1] + u.offs * 30);
    const dx = gx - u.x, dy = gy - u.y, d = Math.hypot(dx, dy);
    if (d > 60) { u.face = turnToward(u.face, Math.atan2(dy, dx), 4 * dt); const s = u.spd * (u.kind === 'officer' ? .8 : .7); return [dx / d * s, dy / d * s]; }
  }
  u.t -= dt;
  if (u.t <= 0) { u.t = rand(1.5, 4); u.wx = u.home.x + rand(-90, 90); u.wy = u.home.y + rand(-90, 90); if (mp) { u.wx = u.x + rand(-80, 80); u.wy = u.y + rand(-80, 80); } }
  if (u.wx !== undefined) {
    const wdx = u.wx - u.x, wdy = u.wy - u.y, wd = Math.hypot(wdx, wdy);
    if (wd > 8) { u.face = turnToward(u.face, Math.atan2(wdy, wdx), 3 * dt); return [wdx / wd * u.spd * .35, wdy / wd * u.spd * .35]; }
  }
  return [0, 0];
}

// ───────────── 増援 ─────────────
function updateSpawns(dt) {
  let nE = 0, nA = 0, roam = 0, nearP = 0;
  const per = {}, perA = {};
  for (const u of G.units) {
    if (u.dying) continue;
    if (u.team === 'E') {
      nE++;
      if (u.base !== null) per[u.base] = (per[u.base] || 0) + 1;
      else if (u.kind === 'ashi' || u.kind === 'archer') roam++;
      if (Math.abs(u.x - P.x) < 650 && Math.abs(u.y - P.y) < 650) nearP++;
    } else { nA++; if (u.home && u.spawnBase !== undefined) perA[u.spawnBase] = (perA[u.spawnBase] || 0) + 1; }
  }
  const rate = 1 / Math.max(.6, moraleMul('E') / moraleMul('A'));
  if (nE < 200) {
    for (const b of G.bases) {
      if (b.owner !== 'E') continue;
      b.spawnT -= dt;
      if (b.spawnT <= 0) { b.spawnT = 1.7 * rate; if ((per[b.i] || 0) < 15) addUnit(mkUnit('E', soldierKind(), b.x + rand(-90, 90), b.y + rand(-70, 70), { base: b.i })); }
    }
    G.spawn.main -= dt;
    if (G.spawn.main <= 0) { G.spawn.main = 2.2; const c = STAGE.enemyCamp; if ((per.main || 0) < 18) addUnit(mkUnit('E', soldierKind(), c.x + rand(-c.w / 3, c.w / 3), c.y + rand(-c.h / 3, c.h / 3), { base: 'main' })); }
    // 本陣へ向かう敵の部隊
    G.spawn.roam -= dt;
    if (G.spawn.roam <= 0) {
      G.spawn.roam = 10 * rate;
      if (roam < 36) {
        const srcs = G.bases.filter(b => b.owner === 'E'); const s = srcs.length ? pick(srcs) : STAGE.enemyCamp;
        for (let k = 0; k < 6; k++) addUnit(mkUnit('E', soldierKind(), s.x + rand(-60, 60), s.y + rand(-60, 60), { order: { type: 'raid' } }));
      }
    }
    // プレイヤーの周りが寂しくならないように
    G.spawn.near -= dt;
    if (G.spawn.near <= 0) {
      G.spawn.near = 1.5;
      if (nearP < 14 && P.st !== 'down') {
        for (let tries = 0; tries < 6; tries++) {
          const a = rand(0, TAU), r = rand(650, 850);
          const x = clamp(P.x + Math.cos(a) * r, 100, WORLD_W - 100), y = clamp(P.y + Math.sin(a) * r, 100, WORLD_H - 100);
          if (blocked(x, y) || inRect({ x, y }, { ...STAGE.allyCamp, w: STAGE.allyCamp.w + 200, h: STAGE.allyCamp.h + 200 })) continue;
          for (let k = 0; k < 4; k++) addUnit(mkUnit('E', soldierKind(), x + rand(-40, 40), y + rand(-40, 40), { alert: true }));
          break;
        }
      }
    }
  }
  if (nA < 46) {
    G.spawn.ally -= dt;
    if (G.spawn.ally <= 0) {
      G.spawn.ally = 2.6 / moraleMul('A');
      const c = STAGE.allyCamp;
      addUnit(mkUnit('A', 'ashi', c.x + rand(-c.w / 3, c.w / 3), c.y + rand(-c.h / 3, c.h / 3)));
    }
    for (const b of G.bases) {
      if (b.owner !== 'A') continue;
      b.allyT -= dt;
      if (b.allyT <= 0) { b.allyT = 5; const u = addUnit(mkUnit('A', 'ashi', b.x + rand(-60, 60), b.y + rand(-50, 50))); u.spawnBase = b.i; }
    }
  }
}

// ───────────── 任務・イベント・会話・士気 ─────────────
function addMission(m) { G.missions.push(m); pushMsg('任務：' + m.text, '#ffd88a', true); sfx.horn(); }
function updateMissions(dt) {
  G.rescueT -= dt;
  if (G.rescueT <= 0) {
    G.rescueT = 1;
    for (const u of G.units) {
      if (u.team !== 'A' || u.kind !== 'officer' || u.dying || u.rescueAsked || u.hp > u.maxHp * .4) continue;
      let foes = 0; forNear(u.x, u.y, 260, o => { if (!o.dying && o.team === 'E') foes++; });
      if (foes < 3) continue;
      u.rescueAsked = true;
      addMission({ type: 'rescue', unit: u, t: 45, text: `${u.name}を救援せよ` });
      queueSay([[u.name, 'むう……囲まれたか。誰か、援軍を！']]);
    }
  }
  for (const m of G.missions) {
    if (m.done) { m.doneT -= dt; continue; }
    const finish = (ok, text) => { m.done = true; m.ok = ok; m.doneT = 3; if (ok) G.missionOk = (G.missionOk || 0) + 1; pushMsg(text, ok ? '#9cf09a' : '#ff9a8a', true); };
    if (m.type === 'rescue') {
      m.t -= dt;
      if (m.unit.dying || m.unit.hp <= 0) finish(false, '救援失敗……');
      else if (Math.hypot(P.x - m.unit.x, P.y - m.unit.y) < 220) {
        m.unit.hp = Math.min(m.unit.maxHp, m.unit.hp + m.unit.maxHp * .45); addMorale(10); dropItem(m.unit.x, m.unit.y, 'bigbun');
        finish(true, '救援成功！'); queueSay([[m.unit.name, `かたじけない、${P.char.name}殿！`]]); addExp(30);
      } else if (m.t <= 0) { finish(false, '救援失敗……'); addMorale(-8); }
    } else if (m.type === 'defend') {
      if (m.unit.dying || m.unit.hp <= 0) { finish(true, '本陣を守り抜いた！'); addMorale(10); addExp(40); }
      else if (inRect(m.unit, { ...STAGE.allyCamp, w: STAGE.allyCamp.w + 60, h: STAGE.allyCamp.h + 60 })) {
        if (!m.campT) pushMsg(`${m.unit.name}が本陣に侵入！ 急げ！`, '#ff9a8a', true);
        m.campT = (m.campT || 0) + dt;
        if (m.campT >= 10) { finish(false, '本陣陥落……'); if (!G.over) G.over = { win: false, t: 2, reason: '本陣が陥落した' }; }
      } else if (m.campT) m.campT = Math.max(0, m.campT - dt * .5);
    }
  }
  G.missions = G.missions.filter(m => !m.done || m.doneT > 0);
}
function spawnAmbush(a) {
  let x = a.x, y = a.y;
  if (a.near) { const u = G.units.find(o => o.name === a.near && !o.dying); if (!u) return; x = u.x + rand(-60, 60); y = u.y + rand(-60, 60); }
  for (let k = 0; k < a.n; k++) {
    const ang = rand(0, TAU), r = rand(120, 220);
    let sx = x + Math.cos(ang) * r, sy = y + Math.sin(ang) * r;
    if (blocked(sx, sy)) { sx = x; sy = y; }
    addUnit(mkUnit('E', soldierKind(), sx, sy, { alert: true }));
  }
  if (a.officer) addUnit(mkUnit('E', 'officer', x, y, { name: a.officer, alert: true }));
  fx({ type: 'ring', x, y, r: 240, life: .6, color: 0xff6040 });
  sfx.horn();
}
function runEvent(ev) {
  if (ev.say) queueSay(ev.say);
  if (ev.ambush) spawnAmbush(ev.ambush);
  if (ev.ambush2) spawnAmbush(ev.ambush2);
  if (ev.assault) {
    const u = G.units.find(o => o.name === ev.assault && !o.dying && o.team === 'E');
    if (u) {
      u.order = { type: 'assault' }; u.tgt = null; u.spd *= .85;
      for (let k = 0; k < 10; k++) addUnit(mkUnit('E', soldierKind(), u.x + rand(-80, 80), u.y + rand(-80, 80), { order: { type: 'assault' } }));
      addMission({ type: 'defend', unit: u, text: `${u.name}の本陣突入を阻止せよ` });
    }
  }
  if (ev.rage && G.boss && !G.boss.dying) { G.boss.rage = true; G.boss.rageCd = 1.5; }
}
function updateEvents() {
  for (const ev of G.events) {
    if (ev.done) continue;
    const a = ev.at;
    const ok = (a.t !== undefined && G.t >= a.t) || (a.bases !== undefined && basesLeft() <= a.bases) || (a.bossHp !== undefined && G.boss && G.boss.hp <= G.boss.maxHp * a.bossHp);
    if (ok) { ev.done = true; runEvent(ev); }
  }
}
function updateTalk(dt) {
  const T = G.talk;
  if (T.cur) { T.t += dt; if (T.t > T.cur.dur) T.cur = null; }
  if (!T.cur && T.q.length) { T.cur = T.q.shift(); T.cur.dur = 2.2 + T.cur.text.length * .075; T.t = 0; }
}
function updateMorale(dt) {
  const own = G.bases.filter(b => b.owner === 'A').length / G.bases.length;
  const target = own * 50 - 15;
  G.morale += (target - G.morale) * .015 * dt;
}

function update(dt) {
  G.t += dt;
  buildGrid();
  updatePlayer(dt);
  updateUnits(dt);
  buildGrid();
  updateProj(dt); updateRains(dt);
  updateSpawns(dt);
  updateEvents(); updateMissions(dt); updateTalk(dt); updateMorale(dt);
  for (const it of G.items) {
    it.t += dt;
    if (Math.hypot(it.x - P.x, it.y - P.y) < 30 && P.st !== 'down') {
      it.got = true; sfx.item();
      if (it.type === 'bun') { P.hp = Math.min(P.maxHp, P.hp + 250); floatText(P.x, P.y, '体力回復', '#9fe09a', 15); }
      if (it.type === 'bigbun') { P.hp = Math.min(P.maxHp, P.hp + 600); floatText(P.x, P.y, '体力大回復', '#9fe09a', 16); }
      if (it.type === 'sake') { P.mu = Math.min(100, P.mu + 50); floatText(P.x, P.y, '無双ゲージ上昇', COL.gold, 15); }
    }
  }
  G.items = G.items.filter(it => !it.got && it.t < 30);
  for (const p of G.parts) { p.t += dt; p.x += p.vx * dt; p.y += p.vy * dt; p.vx *= .9; p.vy *= .9; p.h = Math.max(0, p.h + p.vh * dt); p.vh -= (p.grav || 700) * dt; }
  G.parts = G.parts.filter(p => p.t < p.life);
  for (const f of G.fx) f.t += dt;
  G.fx = G.fx.filter(f => f.t < f.life);
  for (const t of G.texts) t.t += dt;
  G.texts = G.texts.filter(t => t.t < t.life);
  for (const m of G.msgs) m.t += dt;
  G.msgs = G.msgs.filter(m => m.t < m.life);
  G.comboT -= dt; if (G.comboT <= 0) G.combo = 0;
  G.focusT -= dt; if (G.focusT <= 0) G.focus = null;
  G.bossWarnT -= dt;
  G.shake = Math.max(0, G.shake - dt * 1.6);
  G.flash = Math.max(0, G.flash - dt * 2.5);
  G.zoom = Math.max(0, G.zoom - dt * 1.5);
  G.musouTint = P.st === 'musou' ? 1 : Math.max(0, G.musouTint - dt * 2);
  if (G.cutin) { G.cutin.t += dt; if (G.cutin.t > 1.3) G.cutin = null; }
  const bossNear = G.boss && !G.boss.dying && Math.hypot(G.boss.x - P.x, G.boss.y - P.y) < 650;
  bgmPlay(bossNear ? 'boss' : 'battle');
  BGM.intensity = P.st === 'musou' || G.combo >= 50 ? 1 : 0;
  if (G.over) { G.over.t -= dt; if (G.over.t <= 0) finishBattle(); }
}
