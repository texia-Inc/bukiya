// 群勢キャノン - Canvas 描画
(function (root) {
  'use strict';

  const { W, H } = root.CrowdSim;

  const COLORS = {
    floor: '#e3e6ee',
    floorLine: '#cfd4de',
    water: '#3b4a5c',
    rail: '#8a919c',
    railDark: '#5f6670',
    bushTop: '#5cb85c',
    bushSide: '#3c8f3f',
    bushDot: '#7fd27a',
    blue: '#3b6cf6',
    blueLight: '#7fa2ff',
    red: '#e8483f',
    redLight: '#ff8a7a',
    gateBlue: '#3b82f6',
    gateYellow: '#f5c518',
    gatePurple: '#8b3cf0',
    door: '#a8794a',
    doorDark: '#6b4a2b',
    rock: '#9a7550',
    rockDark: '#6e5136',
    gateGreen: '#22b07d',
    gatePost: '#7b5a3a',
    defense: 'rgba(232,72,63,0.35)',
  };

  function makeCanvas(w, h) {
    const c = document.createElement('canvas');
    c.width = w;
    c.height = h;
    return c;
  }

  // 兵のスプライト（影 + 体 + 頭）を一度だけ描いて使い回す
  function makeUnitSprite(body, light, scale, pxRatio) {
    const s = Math.ceil(12 * scale * pxRatio);
    const c = makeCanvas(s, s);
    const g = c.getContext('2d');
    g.scale(s / 12, s / 12);
    g.fillStyle = 'rgba(0,0,0,0.18)';
    g.beginPath();
    g.ellipse(6, 9.2, 3.8, 1.8, 0, 0, Math.PI * 2);
    g.fill();
    g.fillStyle = body;
    g.beginPath();
    g.ellipse(6, 6.6, 3.4, 3.1, 0, 0, Math.PI * 2);
    g.fill();
    g.fillStyle = light;
    g.beginPath();
    g.arc(6, 3.6, 2.2, 0, Math.PI * 2);
    g.fill();
    g.fillStyle = 'rgba(255,255,255,0.55)';
    g.beginPath();
    g.arc(5.3, 2.9, 0.8, 0, Math.PI * 2);
    g.fill();
    return c;
  }

  function seeded(i) {
    const x = Math.sin(i * 127.1 + 311.7) * 43758.5453;
    return x - Math.floor(x);
  }

  class Renderer {
    constructor(canvas) {
      this.canvas = canvas;
      this.ctx = canvas.getContext('2d');
      this.scale = 1;
      this.pxRatio = 1;
      this.particles = [];
      this.shake = 0;
      this.bg = null;
      this.bgFor = null;
    }

    resize(cssW, cssH) {
      const dpr = Math.min(window.devicePixelRatio || 1, 2);
      this.scale = Math.min(cssW / W, cssH / H);
      this.pxRatio = this.scale * dpr;
      const w = Math.round(W * this.scale);
      const h = Math.round(H * this.scale);
      this.canvas.style.width = w + 'px';
      this.canvas.style.height = h + 'px';
      this.canvas.width = Math.round(w * dpr);
      this.canvas.height = Math.round(h * dpr);
      this.sprites = {
        blue: makeUnitSprite(COLORS.blue, COLORS.blueLight, 1, this.pxRatio),
        red: makeUnitSprite(COLORS.red, COLORS.redLight, 1, this.pxRatio),
        giant: makeUnitSprite('#b0261f', COLORS.red, 2.3, this.pxRatio),
        boss: makeUnitSprite('#8f1a14', '#f0a060', 4.6, this.pxRatio),
      };
      this.bg = null;
    }

    // 床・水路・手すり（動かないもの）を事前描画
    buildBackground() {
      const c = makeCanvas(this.canvas.width, this.canvas.height);
      const g = c.getContext('2d');
      g.scale(this.pxRatio, this.pxRatio);
      g.fillStyle = COLORS.floor;
      g.fillRect(0, 0, W, H);
      g.strokeStyle = COLORS.floorLine;
      g.lineWidth = 0.6;
      for (let y = 0; y < H; y += 16) {
        const off = (y / 16) % 2 ? 12 : 0;
        g.beginPath();
        g.moveTo(0, y);
        g.lineTo(W, y);
        g.stroke();
        for (let x = off; x < W; x += 24) {
          g.beginPath();
          g.moveTo(x, y);
          g.lineTo(x, y + 16);
          g.stroke();
        }
      }
      // 両脇の水路と手すり
      for (const side of [0, 1]) {
        const x = side ? W - 8 : 0;
        g.fillStyle = COLORS.water;
        g.fillRect(x, 0, 8, H);
        g.fillStyle = COLORS.rail;
        g.fillRect(side ? W - 9 : 7, 0, 2, H);
        for (let y = 4; y < H; y += 10) {
          g.fillStyle = COLORS.railDark;
          g.fillRect(side ? W - 10 : 6, y, 4, 3);
        }
      }
      // 防衛ライン
      const dy = root.CrowdSim.CFG.defenseY;
      g.strokeStyle = COLORS.defense;
      g.setLineDash([6, 5]);
      g.lineWidth = 2;
      g.beginPath();
      g.moveTo(10, dy);
      g.lineTo(W - 10, dy);
      g.stroke();
      g.setLineDash([]);
      this.bg = c;
    }

    drawBush(g, o, alpha) {
      g.globalAlpha = alpha;
      const side = Math.min(8, o.h * 0.25);
      g.fillStyle = COLORS.bushSide;
      g.fillRect(o.x, o.y + o.h - side, o.w, side);
      g.fillStyle = COLORS.bushTop;
      g.fillRect(o.x, o.y, o.w, o.h - side);
      g.fillStyle = COLORS.bushDot;
      const n = Math.floor((o.w * o.h) / 60);
      for (let i = 0; i < n; i++) {
        const x = o.x + 2 + seeded(i + o.x * 7) * (o.w - 4);
        const y = o.y + 2 + seeded(i * 3 + o.y) * (o.h - side - 4);
        g.fillRect(x, y, 2, 2);
      }
      g.globalAlpha = 1;
    }

    drawFence(g, o) {
      g.fillStyle = COLORS.railDark;
      g.fillRect(o.x, o.y + 2, o.w, o.h);
      g.fillStyle = COLORS.rail;
      g.fillRect(o.x, o.y, o.w, o.h - 1);
      g.fillStyle = '#b6bcc6';
      for (let y = o.y; y < o.y + o.h; y += 14) g.fillRect(o.x - 1, y, o.w + 2, 4);
    }

    drawGate(g, gate) {
      const w = gate.x1 - gate.x0;
      const h = 15;
      const y = gate.y - h / 2;
      let color = COLORS.gateBlue;
      if (gate.color === 'purple') color = COLORS.gatePurple;
      else if (gate.type === 'add') color = COLORS.gateGreen;
      else if (gate.value >= 50) color = COLORS.gateYellow;
      g.fillStyle = 'rgba(0,0,0,0.15)';
      g.fillRect(gate.x0 + 2, y + 3, w, h);
      g.fillStyle = color;
      g.globalAlpha = 0.92;
      g.fillRect(gate.x0, y, w, h);
      g.globalAlpha = 1;
      if (gate.flash > 0) {
        g.fillStyle = `rgba(255,255,255,${gate.flash * 0.6})`;
        g.fillRect(gate.x0, y, w, h);
      }
      g.fillStyle = COLORS.gatePost;
      g.fillRect(gate.x0 - 1.5, y - 2, 3, h + 4);
      g.fillRect(gate.x1 - 1.5, y - 2, 3, h + 4);
    }

    // 倍率の文字は兵より手前に描く（群れに隠れないように）
    drawGateLabel(g, gate) {
      const w = gate.x1 - gate.x0;
      const label = (gate.type === 'mul' ? 'x' : '+') + gate.value;
      const size = 13 + gate.flash * 4;
      g.font = `900 ${size}px "Arial Black", "Hiragino Sans", sans-serif`;
      g.textAlign = 'center';
      g.textBaseline = 'middle';
      g.lineWidth = 3;
      g.strokeStyle = 'rgba(20,30,60,0.85)';
      g.strokeText(label, gate.x0 + w / 2, gate.y + 1);
      g.fillStyle = '#fff';
      g.fillText(label, gate.x0 + w / 2, gate.y + 1);
    }

    drawCannon(g, game) {
      const c = game.cannon;
      const y = root.CrowdSim.CFG.cannonY + c.recoil * 3;
      g.fillStyle = 'rgba(0,0,0,0.2)';
      g.beginPath();
      g.ellipse(c.x, y + 9, 16, 5, 0, 0, Math.PI * 2);
      g.fill();
      g.fillStyle = '#b07a43';
      g.fillRect(c.x - 13, y - 2, 26, 10);
      g.fillStyle = '#3a3f47';
      for (const s of [-1, 1]) {
        g.beginPath();
        g.arc(c.x + s * 12, y + 6, 4.5, 0, Math.PI * 2);
        g.fill();
        g.fillStyle = '#d9b27a';
        g.beginPath();
        g.arc(c.x + s * 12, y + 6, 1.8, 0, Math.PI * 2);
        g.fill();
        g.fillStyle = '#3a3f47';
      }
      // 封印を解いた砲台は砲身が増える
      const n = c.shots;
      const bw = n > 1 ? 6 : 8;
      for (let k = 0; k < n; k++) {
        const bx = c.x + (k - (n - 1) / 2) * 9;
        const grad = g.createLinearGradient(bx - bw, 0, bx + bw, 0);
        grad.addColorStop(0, '#4b5260');
        grad.addColorStop(0.5, '#9aa3b2');
        grad.addColorStop(1, '#4b5260');
        g.fillStyle = grad;
        g.beginPath();
        g.moveTo(bx - bw, y + 2);
        g.lineTo(bx - bw + 2, y - 20);
        g.lineTo(bx + bw - 2, y - 20);
        g.lineTo(bx + bw, y + 2);
        g.closePath();
        g.fill();
        g.fillStyle = '#5aa0ff';
        g.fillRect(bx - bw + 1.5, y - 21, (bw - 1.5) * 2, 3);
      }
      if (c.upgrade > 0) {
        g.strokeStyle = `rgba(120,190,255,${c.upgrade})`;
        g.lineWidth = 3;
        g.beginPath();
        g.arc(c.x, y - 6, 22 + (1 - c.upgrade) * 30, 0, Math.PI * 2);
        g.stroke();
      }
      g.fillStyle = '#9fd0ff';
      g.beginPath();
      g.arc(c.x, y + 2, 3, 0, Math.PI * 2);
      g.fill();
    }

    spawnParticles(game) {
      const d = game.deaths;
      for (let k = 0; k < d.length; k += 4) {
        if (this.particles.length > 900) break;
        this.particles.push({ x: d[k], y: d[k + 1], life: 1, team: d[k + 2], big: d[k + 3] });
      }
      d.length = 0;
      if (game.baseHit > 0.9) this.shake = 1;
    }

    draw(game, dt) {
      const g = this.ctx;
      if (!this.bg) this.buildBackground();
      this.spawnParticles(game);

      g.setTransform(1, 0, 0, 1, 0, 0);
      g.drawImage(this.bg, 0, 0);
      const sh = this.shake > 0 ? this.shake * 3 : 0;
      this.shake = Math.max(0, this.shake - dt * 4);
      g.setTransform(this.pxRatio, 0, 0, this.pxRatio, (Math.random() - 0.5) * sh * this.pxRatio, (Math.random() - 0.5) * sh * this.pxRatio);

      for (const gate of game.gates) this.drawGate(g, gate);
      for (const p of game.pickups) this.drawPickup(g, p);
      for (const f of game.feeders) this.drawFeeder(g, game, f);

      // 兵（敵 → 味方の順）
      this.drawTeam(g, game.red, this.sprites.red, this.sprites.giant, this.sprites.boss);
      this.drawTeam(g, game.blue, this.sprites.blue, null);
      for (const gate of game.gates) this.drawGateLabel(g, gate);

      // 障害物は兵より手前に描く（上から見下ろした立体感）
      for (const o of game.obstacles) {
        if (!o.alive) continue;
        if (o.kind === 'fence') this.drawFence(g, o);
        else if (o.kind === 'bush') this.drawBush(g, o, 1);
        else if (o.kind === 'crate') {
          this.drawCrate(g, o);
          this.drawHedgeHp(g, o, o.h / 2 + 9);
        } else if (o.kind === 'barricade') {
          this.drawBarricade(g, o);
          this.drawHedgeHp(g, o);
        }
        else {
          const ratio = o.hp / o.maxHp;
          this.drawBush(g, o, 0.45 + 0.55 * ratio);
          if (o.hitFlash > 0) {
            g.fillStyle = `rgba(255,255,255,${o.hitFlash * 0.35})`;
            g.fillRect(o.x, o.y, o.w, o.h);
          }
          this.drawHedgeHp(g, o);
        }
      }

      for (const d of game.doors) this.drawDoor(g, d);
      this.drawCannon(g, game);
      this.drawParticles(g, dt);
    }

    // 支点を中心に振れる木の扉
    drawDoor(g, d) {
      g.lineCap = 'round';
      g.strokeStyle = 'rgba(0,0,0,0.25)';
      g.lineWidth = 9;
      g.beginPath();
      g.moveTo(d.px + 2, d.py + 3);
      g.lineTo(d.x2 + 2, d.y2 + 3);
      g.stroke();
      g.strokeStyle = COLORS.doorDark;
      g.lineWidth = 8;
      g.beginPath();
      g.moveTo(d.px, d.py);
      g.lineTo(d.x2, d.y2);
      g.stroke();
      g.strokeStyle = COLORS.door;
      g.lineWidth = 5;
      g.beginPath();
      g.moveTo(d.px, d.py);
      g.lineTo(d.x2, d.y2);
      g.stroke();
      // 板の継ぎ目
      g.strokeStyle = COLORS.doorDark;
      g.lineWidth = 1;
      for (let t = 0.2; t < 1; t += 0.2) {
        const x = d.px + (d.x2 - d.px) * t;
        const y = d.py + (d.y2 - d.py) * t;
        const nx = -Math.sin(d.theta) * 3;
        const ny = Math.cos(d.theta) * 3;
        g.beginPath();
        g.moveTo(x - nx, y - ny);
        g.lineTo(x + nx, y + ny);
        g.stroke();
      }
      g.lineCap = 'butt';
      g.fillStyle = COLORS.railDark;
      g.beginPath();
      g.arc(d.px, d.py, 6, 0, Math.PI * 2);
      g.fill();
      g.fillStyle = COLORS.rail;
      g.beginPath();
      g.arc(d.px, d.py, 3.5, 0, Math.PI * 2);
      g.fill();
    }

    // レーンを流れてくる「+10」の帯。門へ飛び込むと倍率に加算
    drawFeeder(g, game, f) {
      const gate = game.gates[f.gate];
      const w = f.x1 - f.x0 - 12;
      const h = 13;
      const label = '+' + f.add;
      g.font = '900 11px "Arial Black", "Hiragino Sans", sans-serif';
      g.textAlign = 'center';
      g.textBaseline = 'middle';
      for (const it of f.items) {
        let cx = (f.x0 + f.x1) / 2;
        let cy = it.y;
        let k = 1;
        let a = 1;
        if (it.fly >= 0) {
          const t = it.fly;
          const tx = (gate.x0 + gate.x1) / 2;
          cx = cx + (tx - cx) * t;
          cy = it.sy + (gate.y - it.sy) * t - Math.sin(t * Math.PI) * 30;
          k = 1 - t * 0.4;
          a = 1 - t * 0.3;
        }
        g.globalAlpha = a;
        g.fillStyle = '#5b1fae';
        g.fillRect(cx - (w * k) / 2, cy - (h * k) / 2 + 3, w * k, h * k);
        g.fillStyle = COLORS.gatePurple;
        g.fillRect(cx - (w * k) / 2, cy - (h * k) / 2, w * k, h * k);
        g.lineWidth = 3;
        g.strokeStyle = 'rgba(30,10,60,0.85)';
        g.strokeText(label, cx, cy + 1);
        g.fillStyle = '#fff';
        g.fillText(label, cx, cy + 1);
      }
      g.globalAlpha = 1;
    }

    // 岩に封印された砲台
    drawCrate(g, o) {
      const ratio = o.hp / o.maxHp;
      const cx = o.x + o.w / 2;
      const cy = o.y + o.h / 2;
      g.save();
      g.globalAlpha = 0.55 + 0.45 * ratio;
      // 岩の塊
      g.globalAlpha = 0.25 + 0.75 * ratio;
      g.fillStyle = COLORS.rockDark;
      g.beginPath();
      g.ellipse(cx, cy + 4, o.w / 2, o.h / 2 - 2, 0, 0, Math.PI * 2);
      g.fill();
      g.fillStyle = COLORS.rock;
      g.beginPath();
      g.ellipse(cx, cy, o.w / 2 - 2, o.h / 2 - 4, 0, 0, Math.PI * 2);
      g.fill();
      g.fillStyle = COLORS.rockDark;
      for (let i = 0; i < 14; i++) {
        const a = seeded(i + o.x) * Math.PI * 2;
        const r = seeded(i * 7 + o.y) * 0.8;
        g.beginPath();
        g.arc(cx + Math.cos(a) * r * (o.w / 2 - 6), cy + Math.sin(a) * r * (o.h / 2 - 8), 1.6, 0, Math.PI * 2);
        g.fill();
      }
      // 岩から突き出た砲身の束（壊すとこの砲台が手に入る）
      g.globalAlpha = 1;
      for (let k = -1; k <= 1; k++) {
        const bx = cx + k * 11;
        const by = cy - 10 + Math.abs(k) * 3;
        g.fillStyle = '#244a9e';
        g.beginPath();
        g.arc(bx, by + 1.5, 6, 0, Math.PI * 2);
        g.fill();
        g.fillStyle = '#3a6fd8';
        g.beginPath();
        g.arc(bx, by, 6, 0, Math.PI * 2);
        g.fill();
        g.fillStyle = '#1b2230';
        g.beginPath();
        g.arc(bx, by, 3, 0, Math.PI * 2);
        g.fill();
      }
      if (o.hitFlash > 0) {
        g.globalAlpha = o.hitFlash * 0.35;
        g.fillStyle = '#fff';
        g.beginPath();
        g.ellipse(cx, cy, o.w / 2, o.h / 2, 0, 0, Math.PI * 2);
        g.fill();
      }
      g.restore();
    }

    // 黄色と黒の縞模様のバリケード
    drawBarricade(g, o) {
      const ratio = o.hp / o.maxHp;
      g.save();
      g.globalAlpha = 0.5 + 0.5 * ratio;
      g.beginPath();
      g.rect(o.x, o.y, o.w, o.h);
      g.clip();
      g.fillStyle = '#f5c518';
      g.fillRect(o.x, o.y, o.w, o.h);
      g.fillStyle = '#23262d';
      for (let x = o.x - o.h; x < o.x + o.w; x += 14) {
        g.beginPath();
        g.moveTo(x, o.y + o.h);
        g.lineTo(x + 7, o.y + o.h);
        g.lineTo(x + 7 + o.h, o.y);
        g.lineTo(x + o.h, o.y);
        g.closePath();
        g.fill();
      }
      if (o.hitFlash > 0) {
        g.fillStyle = `rgba(255,255,255,${o.hitFlash * 0.4})`;
        g.fillRect(o.x, o.y, o.w, o.h);
      }
      g.restore();
      g.fillStyle = 'rgba(0,0,0,0.25)';
      g.fillRect(o.x, o.y + o.h, o.w, 3);
    }

    // ボーナスブロック（触れると1回だけ兵が増える）
    drawPickup(g, p) {
      if (!p.alive && p.pop <= 0) return;
      const big = p.value >= 50;
      const label = '+' + p.value;
      g.save();
      if (!p.alive) {
        // 取った瞬間に膨らんで消える
        const k = 1 + (1 - p.pop) * 0.6;
        g.globalAlpha = p.pop;
        g.translate(p.x + p.w / 2, p.y + p.h / 2);
        g.scale(k, k);
        g.translate(-(p.x + p.w / 2), -(p.y + p.h / 2));
      }
      g.fillStyle = big ? '#b58a00' : '#1d4fc4';
      g.fillRect(p.x, p.y + 3, p.w, p.h);
      g.fillStyle = big ? COLORS.gateYellow : COLORS.gateBlue;
      g.fillRect(p.x, p.y, p.w, p.h);
      g.fillStyle = 'rgba(255,255,255,0.25)';
      g.fillRect(p.x, p.y, p.w, 2);
      g.font = '900 11px "Arial Black", "Hiragino Sans", sans-serif';
      g.textAlign = 'center';
      g.textBaseline = 'middle';
      g.lineWidth = 3;
      g.strokeStyle = 'rgba(20,30,60,0.85)';
      g.strokeText(label, p.x + p.w / 2, p.y + p.h / 2 + 1);
      g.fillStyle = '#fff';
      g.fillText(label, p.x + p.w / 2, p.y + p.h / 2 + 1);
      g.restore();
    }

    drawHedgeHp(g, o, dy) {
      const cx = o.x + o.w / 2;
      const cy = o.y + o.h / 2 + (dy || 0);
      g.font = '900 12px "Arial Black", "Hiragino Sans", sans-serif';
      g.textAlign = 'center';
      g.textBaseline = 'middle';
      g.lineWidth = 3;
      g.strokeStyle = 'rgba(20,60,20,0.9)';
      g.strokeText(String(o.hp), cx, cy);
      g.fillStyle = '#fff';
      g.fillText(String(o.hp), cx, cy);
    }

    drawTeam(g, t, sprite, giantSprite, bossSprite) {
      const s = 12 / this.pxRatio;
      const unit = sprite.width / this.pxRatio;
      for (let i = 0; i < t.n; i++) {
        const y = t.y[i];
        if (y < -30 || y > H + 12) continue;
        if (bossSprite && t.giant[i] === 2) {
          this.drawBoss(g, bossSprite, t.x[i], y, t.hp[i] / t.maxHp[i]);
        } else if (giantSprite && t.giant[i]) {
          const gs = giantSprite.width / this.pxRatio;
          g.drawImage(giantSprite, t.x[i] - gs / 2, y - gs * 0.6, gs, gs);
        } else {
          g.drawImage(sprite, t.x[i] - unit / 2, y - unit * 0.6, unit, unit);
        }
      }
      return s;
    }

    drawBoss(g, sprite, x, y, ratio) {
      const bs = sprite.width / this.pxRatio;
      g.drawImage(sprite, x - bs / 2, y - bs * 0.6, bs, bs);
      // 頭上の体力ゲージ
      const w = 40;
      const top = y - bs * 0.6 - 6;
      g.fillStyle = 'rgba(20,20,30,0.75)';
      g.fillRect(x - w / 2 - 1, top - 1, w + 2, 6);
      g.fillStyle = '#ff5a4a';
      g.fillRect(x - w / 2, top, w * Math.max(0, ratio), 4);
    }

    drawParticles(g, dt) {
      const ps = this.particles;
      let j = 0;
      for (let i = 0; i < ps.length; i++) {
        const p = ps[i];
        p.life -= dt * 2.2;
        if (p.life <= 0) continue;
        p.y -= dt * 18;
        const r = (p.big === 2 ? 22 : p.big ? 7 : 3) * (1.4 - p.life * 0.4);
        g.globalAlpha = p.life * 0.8;
        g.fillStyle = p.team ? '#ffe2dc' : '#ffffff';
        g.beginPath();
        g.arc(p.x, p.y, r, 0, Math.PI * 2);
        g.fill();
        ps[j++] = p;
      }
      ps.length = j;
      g.globalAlpha = 1;
    }
  }

  root.CrowdRenderer = Renderer;
})(self);
