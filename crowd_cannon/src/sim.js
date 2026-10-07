// 群勢キャノン - ゲームロジック（描画なし・ブラウザ/Node両対応）
(function (root) {
  'use strict';

  // 論理座標系（縦長 9:16）
  const W = 360;
  const H = 640;
  const WORLD_TOP = -360; // 画面外（上）に敵の待機エリアがある
  const CELL = 12;
  const GW = Math.ceil(W / CELL);
  const GH = Math.ceil((H - WORLD_TOP) / CELL);
  const NCELLS = GW * GH;

  const CFG = {
    blueRadius: 3.2,
    redRadius: 3.4,
    giantRadius: 7,
    giantHp: 12,
    bossRadius: 15,
    bossHp: 250,
    doorHalf: 3.5,
    blueSpeed: 78,
    redSpeed: 20,
    fireInterval: 0.1,
    maxBlue: 2600,
    maxRed: 3000,
    cannonY: 572,
    defenseY: 604,
    baseHp: 50,
    minX: 10,
    maxX: W - 10,
    senseCells: 3,
    senseDist: 40,
  };

  function clamp(v, lo, hi) {
    return v < lo ? lo : v > hi ? hi : v;
  }
  function cellX(x) {
    const c = Math.floor(x / CELL);
    return c < 0 ? 0 : c >= GW ? GW - 1 : c;
  }
  function cellY(y) {
    const c = Math.floor((y - WORLD_TOP) / CELL);
    return c < 0 ? 0 : c >= GH ? GH - 1 : c;
  }

  // 決定的な乱数（テストで再現できるように）
  function makeRng(seed) {
    let s = seed >>> 0 || 1;
    return function () {
      s ^= s << 13;
      s ^= s >>> 17;
      s ^= s << 5;
      return (s >>> 0) / 4294967296;
    };
  }

  // 1陣営ぶんのユニット（Structure of Arrays + 空間グリッド）
  class Team {
    constructor(cap) {
      this.cap = cap;
      this.n = 0;
      this.x = new Float32Array(cap);
      this.y = new Float32Array(cap);
      this.vx = new Float32Array(cap);
      this.vy = new Float32Array(cap);
      this.r = new Float32Array(cap);
      this.hp = new Int16Array(cap);
      this.maxHp = new Int16Array(cap);
      this.gates = new Uint32Array(cap);
      this.giant = new Uint8Array(cap);
      this.seek = new Uint8Array(cap);
      this.dead = new Uint8Array(cap);
      this.cell = new Int32Array(cap);
      this.items = new Int32Array(cap);
      this.cellCount = new Int32Array(NCELLS);
      this.cellStart = new Int32Array(NCELLS + 1);
    }

    add(x, y, vx, vy, r, hp, gates, giant) {
      if (this.n >= this.cap) return -1;
      const i = this.n++;
      this.x[i] = x;
      this.y[i] = y;
      this.vx[i] = vx;
      this.vy[i] = vy;
      this.r[i] = r;
      this.hp[i] = hp;
      this.maxHp[i] = hp;
      this.gates[i] = gates;
      this.giant[i] = giant;
      this.seek[i] = 0;
      this.dead[i] = 0;
      return i;
    }

    buildGrid() {
      const cc = this.cellCount;
      const cs = this.cellStart;
      cc.fill(0);
      for (let i = 0; i < this.n; i++) {
        const c = cellY(this.y[i]) * GW + cellX(this.x[i]);
        this.cell[i] = c;
        cc[c]++;
      }
      let s = 0;
      for (let c = 0; c < NCELLS; c++) {
        cs[c] = s;
        s += cc[c];
        cc[c] = cs[c];
      }
      cs[NCELLS] = s;
      for (let i = 0; i < this.n; i++) this.items[cc[this.cell[i]]++] = i;
    }

    compact() {
      let j = 0;
      for (let i = 0; i < this.n; i++) {
        if (this.dead[i]) continue;
        if (i !== j) {
          this.x[j] = this.x[i];
          this.y[j] = this.y[i];
          this.vx[j] = this.vx[i];
          this.vy[j] = this.vy[i];
          this.r[j] = this.r[i];
          this.hp[j] = this.hp[i];
          this.maxHp[j] = this.maxHp[i];
          this.gates[j] = this.gates[i];
          this.giant[j] = this.giant[i];
          this.seek[j] = this.seek[i];
          this.dead[j] = 0;
        }
        j++;
      }
      this.n = j;
    }
  }

  // 障害物を考慮した経路（フローフィールド）
  // blue: 上方向へ。破壊可能な生け垣は「通れる」扱い → 突っ込んで壊す
  // red : 防衛ラインへ。生きている障害物はすべて避ける
  function buildFlow(obstacles, team, foe, doors) {
    const blocked = new Uint8Array(NCELLS);
    // 扉（線分）が通るマスもふさぐ
    for (const d of doors || []) {
      const len = Math.hypot(d.x2 - d.px, d.y2 - d.py);
      for (let t = 0; t <= len; t += 3) {
        const x = d.px + ((d.x2 - d.px) * t) / len;
        const y = d.py + ((d.y2 - d.py) * t) / len;
        for (const [ox, oy] of [[-3, -3], [3, -3], [-3, 3], [3, 3]]) {
          blocked[cellY(y + oy) * GW + cellX(x + ox)] = 1;
        }
      }
    }
    for (const o of obstacles) {
      if (!o.alive) continue;
      if (team === 'blue' && !foe && isBreakable(o)) continue;
      const cx0 = cellX(o.x + 0.01);
      const cx1 = cellX(o.x + o.w - 0.01);
      const cy0 = cellY(o.y + 0.01);
      const cy1 = cellY(o.y + o.h - 0.01);
      for (let cy = cy0; cy <= cy1; cy++) {
        for (let cx = cx0; cx <= cx1; cx++) blocked[cy * GW + cx] = 1;
      }
    }

    const INF = 1 << 29;
    const dist = new Int32Array(NCELLS).fill(INF);
    const queue = new Int32Array(NCELLS);
    let head = 0;
    let tail = 0;
    if (foe) {
      // 敵がいるマス（の周り）を目的地にする → 群れが敵の大軍へ流れ込む
      for (let i = 0; i < foe.n; i++) {
        const fx = cellX(foe.x[i]);
        const fy = cellY(foe.y[i]);
        for (let oy = -1; oy <= 1; oy++) {
          for (let ox = -1; ox <= 1; ox++) {
            const nx = fx + ox;
            const ny = fy + oy;
            if (nx < 0 || ny < 0 || nx >= GW || ny >= GH) continue;
            const c = ny * GW + nx;
            if (blocked[c] || dist[c] === 0) continue;
            dist[c] = 0;
            queue[tail++] = c;
          }
        }
      }
    } else if (team === 'blue') {
      for (let cx = 0; cx < GW; cx++) {
        if (!blocked[cx]) {
          dist[cx] = 0;
          queue[tail++] = cx;
        }
      }
    } else {
      for (let cy = cellY(CFG.defenseY); cy < GH; cy++) {
        for (let cx = 0; cx < GW; cx++) {
          const c = cy * GW + cx;
          if (!blocked[c]) {
            dist[c] = 0;
            queue[tail++] = c;
          }
        }
      }
    }
    const inQ = new Uint8Array(NCELLS);
    for (let k = 0; k < tail; k++) inQ[queue[k]] = 1;
    let count = tail;
    tail %= NCELLS;
    while (count > 0) {
      const c = queue[head];
      head = (head + 1) % NCELLS;
      count--;
      inQ[c] = 0;
      const cx = c % GW;
      const cy = (c / GW) | 0;
      for (let oy = -1; oy <= 1; oy++) {
        for (let ox = -1; ox <= 1; ox++) {
          if (!ox && !oy) continue;
          const nx = cx + ox;
          const ny = cy + oy;
          if (nx < 0 || ny < 0 || nx >= GW || ny >= GH) continue;
          const nc = ny * GW + nx;
          const d = dist[c] + 1;
          if (blocked[nc] || dist[nc] <= d) continue;
          if (ox && oy && (blocked[cy * GW + nx] || blocked[ny * GW + cx])) continue;
          dist[nc] = d;
          if (!inQ[nc]) {
            inQ[nc] = 1;
            queue[tail] = nc;
            tail = (tail + 1) % NCELLS;
            count++;
          }
        }
      }
    }

    const dirX = new Float32Array(NCELLS);
    const dirY = new Float32Array(NCELLS);
    const defY = team === 'blue' ? -1 : 1;
    for (let cy = 0; cy < GH; cy++) {
      for (let cx = 0; cx < GW; cx++) {
        const c = cy * GW + cx;
        const d = dist[c];
        if (d >= INF) {
          // 障害物マスにはみ出したユニット用: 周りの通れるマスの向きを借りる
          let sx = 0;
          let sy = 0;
          let best = INF;
          for (let oy = -1; oy <= 1; oy++) {
            for (let ox = -1; ox <= 1; ox++) {
              const nx = cx + ox;
              const ny = cy + oy;
              if (nx < 0 || ny < 0 || nx >= GW || ny >= GH) continue;
              const v = dist[ny * GW + nx];
              if (v < best) {
                best = v;
                sx = ox;
                sy = oy;
              }
            }
          }
          if (best < INF) {
            const l = Math.hypot(sx, sy);
            dirX[c] = sx / l;
            dirY[c] = sy / l;
          } else {
            dirY[c] = defY;
          }
          continue;
        }
        const at = (x, y) => {
          if (x < 0 || y < 0 || x >= GW || y >= GH) return d + 1;
          const v = dist[y * GW + x];
          return v >= INF ? d + 1 : v;
        };
        let gx = at(cx - 1, cy) - at(cx + 1, cy);
        let gy = at(cx, cy - 1) - at(cx, cy + 1);
        // 斜めも少し混ぜてなめらかに
        gx += 0.5 * (at(cx - 1, cy - 1) - at(cx + 1, cy + 1) + at(cx - 1, cy + 1) - at(cx + 1, cy - 1));
        gy += 0.5 * (at(cx - 1, cy - 1) - at(cx + 1, cy + 1) - at(cx - 1, cy + 1) + at(cx + 1, cy - 1));
        const len = Math.hypot(gx, gy);
        if (len < 1e-6 || d === 0) {
          dirY[c] = defY;
        } else {
          dirX[c] = gx / len;
          dirY[c] = gy / len;
        }
      }
    }
    // 味方の基本経路: 真上に壊せない障害物がなければまっすぐ上へ進む
    // （行き止まりの通路でも、遠回りせず生け垣やバリケードに突っ込ませる）
    if (team === 'blue' && !foe) {
      for (let cy = 0; cy < GH; cy++) {
        for (let cx = 0; cx < GW; cx++) {
          let clear = true;
          for (let k = 1; k <= 3 && clear; k++) {
            const ny = cy - k;
            if (ny >= 0 && blocked[ny * GW + cx]) clear = false;
          }
          if (clear && !blocked[cy * GW + cx]) {
            dirX[cy * GW + cx] = 0;
            dirY[cy * GW + cx] = -1;
          }
        }
      }
    }
    return { dirX, dirY };
  }

  // 味方の体当たりで壊せる障害物（生け垣・バリケード）
  function isBreakable(o) {
    return o.kind === 'hedge' || o.kind === 'barricade' || o.kind === 'crate';
  }

  function smooth(t) {
    const u = clamp(t, 0, 1);
    return u * u * (3 - 2 * u);
  }

  // 開閉する扉: angles[0] で待機 → 振れる → angles[1] で待機 → 戻る、を繰り返す
  function updateDoorGeom(d) {
    const a = d.angles[0];
    const b = d.angles[1];
    if (d.phase === 0) d.theta = a;
    else if (d.phase === 1) d.theta = a + (b - a) * smooth(d.phaseT / d.swing);
    else if (d.phase === 2) d.theta = b;
    else d.theta = b + (a - b) * smooth(d.phaseT / d.swing);
    d.x2 = d.px + Math.cos(d.theta) * d.len;
    d.y2 = d.py + Math.sin(d.theta) * d.len;
  }

  function cloneLevel(level) {
    return {
      obstacles: level.obstacles.map((o) => ({
        kind: o.kind,
        x: o.x,
        y: o.y,
        w: o.w,
        h: o.h,
        hp: o.hp || 0,
        maxHp: o.hp || 0,
        reward: o.reward || null,
        shots: o.shots || 0,
        alive: true,
        hitFlash: 0,
      })),
      gates: level.gates.map((g, idx) => ({
        id: idx,
        baseX0: g.x0,
        baseX1: g.x1,
        x0: g.x0,
        x1: g.x1,
        y: g.y,
        type: g.type,
        value: g.value,
        color: g.color || null,
        move: g.move || null,
        flash: 0,
      })),
      // ボーナスブロック: 最初に触れた兵がいると1回だけ value 人増え、消える
      pickups: (level.pickups || []).map((p) => ({
        x: p.x,
        y: p.y,
        w: p.w,
        h: p.h,
        value: p.value,
        alive: true,
        pop: 0,
      })),
      doors: (level.doors || []).map((d) => {
        const door = { px: d.px, py: d.py, len: d.len, angles: d.angles, hold: d.hold, swing: d.swing, phase: 0, phaseT: 0 };
        updateDoorGeom(door);
        return door;
      }),
      // 流れてくる「+N」の帯: 扉が開いている間だけレーンを下って、門の倍率に加算される
      feeders: (level.feeders || []).map((f) => ({
        x0: f.x0,
        x1: f.x1,
        spacing: f.spacing,
        speed: f.speed,
        releaseY: f.releaseY,
        gate: f.gate,
        add: f.add,
        door: f.door,
        top: f.startY - (f.count - 1) * f.spacing - 12,
        items: Array.from({ length: f.count }, (_, k) => ({ y: f.startY - k * f.spacing, fly: -1, sy: 0 })),
      })),
    };
  }

  class Game {
    constructor(level, seed) {
      this.level = level;
      this.rand = makeRng(seed || (Date.now() & 0xffffffff));
      const c = cloneLevel(level);
      this.obstacles = c.obstacles;
      this.gates = c.gates;
      this.pickups = c.pickups;
      this.doors = c.doors;
      this.feeders = c.feeders;
      this.blue = new Team(CFG.maxBlue);
      this.red = new Team(CFG.maxRed);
      this.cannon = { x: W / 2, targetX: W / 2, recoil: 0, shots: 1, upgrade: 0 };
      this.firing = false;
      this.fireTimer = 0;
      this.time = 0;
      this.state = 'playing'; // playing | won | lost
      this.redToSpawn = level.enemies.total;
      this.redSpawned = 0;
      this.spawnTimer = 0;
      this.kills = 0;
      this.baseHp = CFG.baseHp;
      this.baseHit = 0;
      this.fired = 0;
      this.peakBlue = 0;
      this.deaths = []; // 描画用: [x, y, team(0=blue,1=red), giant]
      // 通路（柵・生け垣・門）より上に出た兵は、敵の大軍を探して向かう
      let laneTop = H;
      for (const o of this.obstacles) if (o.kind !== 'bush') laneTop = Math.min(laneTop, o.y);
      for (const g of this.gates) laneTop = Math.min(laneTop, g.y);
      for (const p of this.pickups) laneTop = Math.min(laneTop, p.y);
      for (const d of this.doors) laneTop = Math.min(laneTop, d.py);
      this.laneTop = laneTop - 6;
      this.updateFlow();
      this.spawnInitialRed(level.enemies.initial);
      for (const b of level.enemies.bosses || []) {
        this.red.add(b.x, b.y, 0, CFG.redSpeed, CFG.bossRadius, b.hp || CFG.bossHp, 0, 2);
      }
      this.seekFlow = buildFlow(this.obstacles, 'blue', this.red, this.doors);
    }

    get enemiesLeft() {
      return this.red.n + this.redToSpawn;
    }


    // 生け垣が壊れたら経路を引き直す
    updateFlow() {
      this.blueFlow = buildFlow(this.obstacles, 'blue', null, this.doors);
      this.redFlow = buildFlow(this.obstacles, 'red', null, this.doors);
      this.flowDirty = false;
      this.seekTimer = 0;
    }

    insideObstacle(x, y, pad) {
      for (const o of this.obstacles) {
        if (!o.alive) continue;
        if (x > o.x - pad && x < o.x + o.w + pad && y > o.y - pad && y < o.y + o.h + pad) return true;
      }
      return false;
    }

    spawnRedAt(x, y) {
      this.redSpawned++;
      this.redToSpawn--;
      const ge = this.level.enemies.giantEvery;
      const giant = ge && this.redSpawned % ge === 0 ? 1 : 0;
      const r = giant ? CFG.giantRadius : CFG.redRadius;
      this.red.add(x, y, 0, CFG.redSpeed, r, giant ? CFG.giantHp : 1, 0, giant);
    }

    spawnInitialRed(count) {
      const bottom = this.level.enemies.spawnBottom || 50;
      let tries = 0;
      while (count > 0 && this.redToSpawn > 0 && this.red.n < CFG.maxRed && tries < count * 50) {
        tries++;
        const x = CFG.minX + 4 + this.rand() * (CFG.maxX - CFG.minX - 8);
        const y = WORLD_TOP + 20 + this.rand() * (bottom - WORLD_TOP - 20);
        if (this.insideObstacle(x, y, 5)) continue;
        this.spawnRedAt(x, y);
        count--;
      }
    }

    setTarget(x) {
      this.cannon.targetX = clamp(x, CFG.minX + 8, CFG.maxX - 8);
    }

    fireOne() {
      const c = this.cannon;
      // 封印された砲台を解放すると、1回で複数の兵を撃ち出す
      for (let k = 0; k < c.shots; k++) {
        const off = (k - (c.shots - 1) / 2) * 8;
        const x = clamp(c.x + off + (this.rand() - 0.5) * 6, CFG.minX, CFG.maxX);
        const i = this.blue.add(x, CFG.cannonY - 18, off * 0.5 + (this.rand() - 0.5) * 10, -CFG.blueSpeed * 1.8, CFG.blueRadius, 1, 0, 0);
        if (i >= 0) {
          this.fired++;
          c.recoil = 1;
        }
      }
    }

    updateDoors(dt) {
      for (const d of this.doors) {
        d.phaseT += dt;
        const dur = d.phase === 0 ? d.hold[0] : d.phase === 2 ? d.hold[1] : d.swing;
        if (d.phaseT >= dur) {
          d.phaseT -= dur;
          d.phase = (d.phase + 1) % 4;
          this.flowDirty = true;
        }
        updateDoorGeom(d);
      }
    }

    // 扉の先端がレーンの入口をふさいでいるか
    laneBlocked(f) {
      const d = this.doors[f.door];
      return !!d && d.y2 < d.py + 25 && d.x2 > f.x0 - 10 && d.x2 < f.x1 + 10;
    }

    updateFeeders(dt) {
      for (const f of this.feeders) {
        const d = this.doors[f.door];
        const blocked = this.laneBlocked(f);
        let cap = blocked ? d.py - 9 : Infinity;
        const gate = this.gates[f.gate];
        for (const it of f.items) {
          if (it.fly >= 0) {
            it.fly += dt / 0.45;
            if (it.fly >= 1) {
              it.done = true;
              gate.value += f.add;
              gate.flash = 1;
            }
            continue;
          }
          it.y = Math.min(it.y + f.speed * dt, cap);
          if (!blocked && it.y >= f.releaseY) {
            it.fly = 0;
            it.sy = it.y;
            continue;
          }
          cap = it.y - f.spacing;
        }
        f.items = f.items.filter((it) => !it.done);
      }
    }

    collideDoors(t, i) {
      // 紫のレーン（帯専用）に押し込まれた兵は柵の手前に戻す
      for (const f of this.feeders) {
        const d = this.doors[f.door];
        if (t.x[i] > f.x0 && t.x[i] < f.x1 && t.y[i] < d.py + 8 && t.y[i] > f.top) t.y[i] = d.py + 14;
      }
      const rad = t.r[i] + CFG.doorHalf;
      for (const d of this.doors) {
        const ex = d.x2 - d.px;
        const ey = d.y2 - d.py;
        const x = t.x[i];
        const y = t.y[i];
        const u = clamp(((x - d.px) * ex + (y - d.py) * ey) / (ex * ex + ey * ey), 0, 1);
        const dx = x - (d.px + ex * u);
        const dy = y - (d.py + ey * u);
        const d2 = dx * dx + dy * dy;
        if (d2 >= rad * rad) continue;
        if (d2 > 1e-6) {
          const dd = Math.sqrt(d2);
          t.x[i] = x + (dx / dd) * (rad - dd);
          t.y[i] = y + (dy / dd) * (rad - dd);
        } else {
          t.y[i] = y + rad;
        }
      }
    }

    step(dt) {
      if (this.state !== 'playing') return;
      this.time += dt;
      const rand = this.rand;
      const blue = this.blue;
      const red = this.red;

      // 門の移動
      for (const g of this.gates) {
        if (g.move) {
          const off = Math.sin(this.time * g.move.speed * Math.PI * 2) * g.move.range;
          g.x0 = g.baseX0 + off;
          g.x1 = g.baseX1 + off;
        }
        g.flash = Math.max(0, g.flash - dt * 4);
      }
      for (const o of this.obstacles) o.hitFlash = Math.max(0, o.hitFlash - dt * 6);
      for (const p of this.pickups) p.pop = Math.max(0, p.pop - dt * 3);
      this.updateDoors(dt);
      this.updateFeeders(dt);

      // 砲台
      const c = this.cannon;
      c.x += (c.targetX - c.x) * Math.min(1, dt * 14);
      c.recoil = Math.max(0, c.recoil - dt * 8);
      c.upgrade = Math.max(0, c.upgrade - dt * 0.8);
      this.baseHit = Math.max(0, this.baseHit - dt * 3);
      if (this.firing) {
        this.fireTimer -= dt;
        while (this.fireTimer <= 0) {
          this.fireOne();
          this.fireTimer += CFG.fireInterval;
        }
      } else {
        this.fireTimer = Math.max(0, this.fireTimer - dt);
      }

      // 敵の増援
      const en = this.level.enemies;
      this.spawnTimer += dt * en.rate;
      while (this.spawnTimer >= 1) {
        this.spawnTimer -= 1;
        if (this.redToSpawn <= 0 || red.n >= CFG.maxRed) continue;
        for (let t = 0; t < 6; t++) {
          const x = CFG.minX + 4 + rand() * (CFG.maxX - CFG.minX - 8);
          const y = WORLD_TOP + 8 + rand() * 50;
          if (this.insideObstacle(x, y, 5)) continue;
          this.spawnRedAt(x, y);
          break;
        }
      }
      if (this.spawnTimer > 4) this.spawnTimer = 4;

      blue.buildGrid();
      red.buildGrid();

      this.steer(blue, red, this.blueFlow, CFG.blueSpeed, dt, this.seekFlow, this.laneTop);
      this.steer(red, blue, this.redFlow, CFG.redSpeed, dt, null, 0);

      this.moveBlue(dt);
      this.moveRed(dt);

      blue.buildGrid();
      red.buildGrid();
      this.separate(blue);
      this.separate(red);
      this.combat();

      blue.compact();
      red.compact();
      if (this.flowDirty) this.updateFlow();
      this.seekTimer -= dt;
      if (this.seekTimer <= 0) {
        this.seekFlow = buildFlow(this.obstacles, 'blue', red, this.doors);
        this.seekTimer = 0.25;
      }
      if (blue.n > this.peakBlue) this.peakBlue = blue.n;

      if (this.state === 'playing' && this.redToSpawn <= 0 && red.n === 0) this.state = 'won';
    }

    // 近くの敵がいれば向かう、いなければフローフィールドに従う
    steer(team, foe, flow, speed, dt, seekFlow, seekAboveY) {
      const k = Math.min(1, dt * 7);
      const sc = CFG.senseCells;
      const sd2 = CFG.senseDist * CFG.senseDist;
      const fcs = foe.cellStart;
      const fit = foe.items;
      for (let i = 0; i < team.n; i++) {
        const x = team.x[i];
        const y = team.y[i];
        const cx = cellX(x);
        const cy = cellY(y);
        let best = sd2;
        let tx = 0;
        let ty = 0;
        for (let oy = -sc; oy <= sc; oy++) {
          const ny = cy + oy;
          if (ny < 0 || ny >= GH) continue;
          for (let ox = -sc; ox <= sc; ox++) {
            const nx = cx + ox;
            if (nx < 0 || nx >= GW) continue;
            const cc = ny * GW + nx;
            for (let p = fcs[cc], e = fcs[cc + 1]; p < e; p++) {
              const j = fit[p];
              const dx = foe.x[j] - x;
              const dy = foe.y[j] - y;
              const d2 = dx * dx + dy * dy;
              if (d2 < best) {
                best = d2;
                tx = dx;
                ty = dy;
              }
            }
          }
        }
        const gi = team.giant[i];
        const sp = gi === 2 ? speed * 0.55 : gi ? speed * 0.75 : speed;
        let dx;
        let dy;
        if (best < sd2) {
          const d = Math.sqrt(best) || 1;
          dx = tx / d;
          dy = ty / d;
        } else {
          const fc = cy * GW + cx;
          // 一度通路を抜けた兵は、以後ずっと敵を探して動く
          if (seekFlow && y < seekAboveY) team.seek[i] = 1;
          const f = team.seek[i] ? seekFlow : flow;
          dx = f.dirX[fc];
          dy = f.dirY[fc];
        }
        team.vx[i] += (dx * sp - team.vx[i]) * k;
        team.vy[i] += (dy * sp - team.vy[i]) * k;
      }
    }

    moveBlue(dt) {
      const b = this.blue;
      const n = b.n; // 分裂で増えた分はこのフレームでは動かさない
      for (let i = 0; i < n; i++) {
        if (b.dead[i]) continue;
        const py = b.y[i];
        b.x[i] = clamp(b.x[i] + b.vx[i] * dt, CFG.minX, CFG.maxX);
        b.y[i] += b.vy[i] * dt;
        const x = b.x[i];
        const y = b.y[i];

        // 門の通過判定（下から上へ通過したときだけ）
        for (const g of this.gates) {
          const bit = 1 << g.id;
          if (b.gates[i] & bit) continue;
          if (py > g.y && y <= g.y && x >= g.x0 && x <= g.x1) {
            b.gates[i] |= bit;
            g.flash = 1;
            const extra = g.type === 'mul' ? g.value - 1 : g.value;
            const mask = b.gates[i];
            for (let k = 0; k < extra; k++) {
              const spread = Math.min(60, 10 + extra * 0.6);
              const nx = clamp(x + (this.rand() - 0.5) * spread, g.x0 + 2, g.x1 - 2);
              const ny = g.y - 1 - this.rand() * (6 + Math.min(24, extra * 0.3));
              if (b.add(nx, ny, b.vx[i] + (this.rand() - 0.5) * 30, b.vy[i], CFG.blueRadius, 1, mask, 0) < 0) break;
            }
          }
        }

        // ボーナスブロックに触れたら、その場で兵が増える
        for (const p of this.pickups) {
          if (!p.alive) continue;
          if (x < p.x - 3 || x > p.x + p.w + 3 || y < p.y - 3 || y > p.y + p.h + 3) continue;
          p.alive = false;
          p.pop = 1;
          for (let k = 0; k < p.value; k++) {
            const nx = clamp(p.x + this.rand() * p.w, CFG.minX, CFG.maxX);
            const ny = p.y - this.rand() * Math.min(30, 4 + p.value * 0.3);
            if (b.add(nx, ny, (this.rand() - 0.5) * 30, b.vy[i], CFG.blueRadius, 1, b.gates[i], 0) < 0) break;
          }
        }

        if (y < WORLD_TOP + 6) {
          b.dead[i] = 1;
          continue;
        }
        this.collideObstacles(b, i, true);
        if (!b.dead[i]) this.collideDoors(b, i);
      }
    }

    moveRed(dt) {
      const r = this.red;
      for (let i = 0; i < r.n; i++) {
        r.x[i] = clamp(r.x[i] + r.vx[i] * dt, CFG.minX, CFG.maxX);
        r.y[i] += r.vy[i] * dt;
        this.collideObstacles(r, i, false);
        this.collideDoors(r, i);
        if (r.y[i] >= CFG.defenseY && !r.dead[i]) {
          // 防衛ラインを越えた敵は砦にダメージを与えて消える
          r.dead[i] = 1;
          this.baseHp -= r.giant[i] === 2 ? 25 : r.giant[i] ? 5 : 1;
          this.baseHit = 1;
          this.pushDeath(r.x[i], r.y[i], 1, r.giant[i]);
          if (this.baseHp <= 0) {
            this.baseHp = 0;
            this.state = 'lost';
          }
        }
      }
    }

    collideObstacles(t, i, isBlue) {
      const rad = t.r[i];
      for (const o of this.obstacles) {
        if (!o.alive) continue;
        const x = t.x[i];
        const y = t.y[i];
        if (x < o.x - rad || x > o.x + o.w + rad || y < o.y - rad || y > o.y + o.h + rad) continue;
        const qx = clamp(x, o.x, o.x + o.w);
        const qy = clamp(y, o.y, o.y + o.h);
        let dx = x - qx;
        let dy = y - qy;
        const d2 = dx * dx + dy * dy;
        if (d2 >= rad * rad) continue;

        if (isBlue && isBreakable(o)) {
          // 生け垣に体当たりして削る
          t.dead[i] = 1;
          o.hp -= 1;
          o.hitFlash = 1;
          this.pushDeath(x, y, 0, 0);
          if (o.hp <= 0) {
            o.alive = false;
            this.flowDirty = true;
            if (o.reward === 'multishot') {
              this.cannon.shots = o.shots || 3;
              this.cannon.upgrade = 1;
            }
          }
          return;
        }

        if (d2 > 1e-6) {
          const d = Math.sqrt(d2);
          const push = (rad - d) / d;
          t.x[i] = x + dx * push;
          t.y[i] = y + dy * push;
        } else {
          // 中心がめり込んでいる場合は一番近い辺へ押し出す
          const l = x - o.x;
          const rr = o.x + o.w - x;
          const tp = y - o.y;
          const bt = o.y + o.h - y;
          const m = Math.min(l, rr, tp, bt);
          if (m === l) t.x[i] = o.x - rad;
          else if (m === rr) t.x[i] = o.x + o.w + rad;
          else if (m === tp) t.y[i] = o.y - rad;
          else t.y[i] = o.y + o.h + rad;
        }
      }
    }

    separate(t) {
      const cs = t.cellStart;
      const it = t.items;
      for (let i = 0; i < t.n; i++) {
        if (t.dead[i]) continue;
        const x = t.x[i];
        const y = t.y[i];
        const ri = t.r[i];
        const cx = cellX(x);
        const cy = cellY(y);
        let checks = 0;
        let px = 0;
        let py = 0;
        for (let oy = -1; oy <= 1 && checks < 14; oy++) {
          const ny = cy + oy;
          if (ny < 0 || ny >= GH) continue;
          for (let ox = -1; ox <= 1 && checks < 14; ox++) {
            const nx = cx + ox;
            if (nx < 0 || nx >= GW) continue;
            const cc = ny * GW + nx;
            for (let p = cs[cc], e = cs[cc + 1]; p < e && checks < 14; p++) {
              const j = it[p];
              if (j === i || t.dead[j]) continue;
              checks++;
              const dx = x - t.x[j];
              const dy = y - t.y[j];
              const min = ri + t.r[j];
              const d2 = dx * dx + dy * dy;
              if (d2 >= min * min) continue;
              if (d2 < 1e-6) {
                px += (i & 1 ? 0.5 : -0.5);
                continue;
              }
              const d = Math.sqrt(d2);
              const f = ((min - d) / d) * 0.5;
              // 巨人は押されにくい
              const w = t.giant[i] > t.giant[j] ? 0.15 : 1;
              px += dx * f * w;
              py += dy * f * w;
            }
          }
        }
        // 密度の勾配で押し広げる（同じ場所に何百体も重なるのを防ぐ）
        const cnt = (gx, gy) => {
          if (gx < 0 || gy < 0 || gx >= GW || gy >= GH) return 4;
          const cc = gy * GW + gx;
          return cs[cc + 1] - cs[cc];
        };
        const here = cnt(cx, cy);
        if (here > 4) {
          px += (cnt(cx - 1, cy) - cnt(cx + 1, cy)) * 0.02;
          py += (cnt(cx, cy - 1) - cnt(cx, cy + 1)) * 0.02;
          // 中心からずらす
          px += ((x % CELL) - CELL / 2) * 0.01 * (here - 4);
          py += (((y - WORLD_TOP) % CELL) - CELL / 2) * 0.01 * (here - 4);
        }
        // 押し合いで群れが加速しすぎないよう上限をつける
        const pl = px * px + py * py;
        if (pl > 1.0) {
          const k = 1.0 / Math.sqrt(pl);
          px *= k;
          py *= k;
        }
        t.x[i] = clamp(x + px, CFG.minX, CFG.maxX);
        t.y[i] = y + py;
      }
    }

    combat() {
      const b = this.blue;
      const r = this.red;
      const cs = r.cellStart;
      const it = r.items;
      for (let i = 0; i < b.n; i++) {
        if (b.dead[i]) continue;
        const x = b.x[i];
        const y = b.y[i];
        const cx = cellX(x);
        const cy = cellY(y);
        let hit = -1;
        for (let oy = -1; oy <= 1 && hit < 0; oy++) {
          const ny = cy + oy;
          if (ny < 0 || ny >= GH) continue;
          for (let ox = -1; ox <= 1 && hit < 0; ox++) {
            const nx = cx + ox;
            if (nx < 0 || nx >= GW) continue;
            const cc = ny * GW + nx;
            for (let p = cs[cc], e = cs[cc + 1]; p < e; p++) {
              const j = it[p];
              if (r.dead[j]) continue;
              const dx = r.x[j] - x;
              const dy = r.y[j] - y;
              const min = r.r[j] + b.r[i] + 0.8;
              if (dx * dx + dy * dy < min * min) {
                hit = j;
                break;
              }
            }
          }
        }
        if (hit < 0) continue;
        b.dead[i] = 1;
        this.pushDeath(x, y, 0, 0);
        r.hp[hit] -= 1;
        if (r.hp[hit] <= 0) {
          r.dead[hit] = 1;
          this.kills++;
          this.pushDeath(r.x[hit], r.y[hit], 1, r.giant[hit]);
        }
      }
    }

    pushDeath(x, y, team, giant) {
      if (this.deaths.length < 800) this.deaths.push(x, y, team, giant);
    }
  }

  const api = { Game, CFG, isBreakable, W, H, WORLD_TOP, CELL, buildFlow, makeRng };
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  else root.CrowdSim = api;
})(typeof self !== 'undefined' ? self : this);
