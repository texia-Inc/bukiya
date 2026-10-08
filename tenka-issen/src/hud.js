// ───────────── 画面表示（HUD） ─────────────
const FONT_D = '"Shippori Mincho B1", serif', FONT_B = '"Zen Kaku Gothic New", sans-serif';
function labelText(text, x, y, font, color, align = 'center') {
  ctx.font = font; ctx.textAlign = align;
  ctx.fillStyle = 'rgba(0,0,0,.7)'; ctx.fillText(text, x + 1, y + 1);
  ctx.fillStyle = color; ctx.fillText(text, x, y);
}
function speakerStyle(name) {
  const ch = CHARS.find(c => c.name === name);
  if (ch) return { color: '#' + ch.col.toString(16).padStart(6, '0'), ally: true };
  const lk = OFFICER_LOOKS[name];
  const ally = STAGE.allies.some(a => a.name === name);
  return { color: lk ? lk.color : '#555', ally };
}

function drawLabels() {
  for (const b of G.bases) {
    if (!inView(b.x, b.y)) continue;
    const s = toScreen(b.x, 85, b.y - 95);
    if (s.ok) labelText(b.name, s.x, s.y, `700 15px ${FONT_D}`, b.owner === 'E' ? '#f0b0a0' : '#b8ceff');
  }
  const ec = STAGE.enemyCamp, ac = STAGE.allyCamp;
  for (const [c, t, col] of [[ec, '敵本陣', '#f0b0a0'], [ac, '自軍本陣', '#b8ceff']]) {
    if (!inView(c.x, c.y)) continue;
    const s = toScreen(c.x, 60, c.y - c.h / 2);
    if (s.ok) labelText(t, s.x, s.y, `800 19px ${FONT_D}`, col);
  }
  for (const u of G.units) {
    if (u.kind === 'ashi' || u.kind === 'archer' || u.dying || !inView(u.x, u.y)) continue;
    const s = toScreen(u.x, KIND[u.kind].H * 1.3 + 10 + u.z, u.y);
    if (!s.ok) continue;
    const ally = u.team === 'A';
    labelText(u.name, s.x, s.y - 8, `700 ${u.kind === 'boss' ? 14 : 12}px ${FONT_B}`, ally ? '#b8d0ff' : u.kind === 'boss' ? '#ffb090' : u.kind === 'officer' ? '#f3d58c' : '#e8d2b0');
    const w = u.kind === 'leader' ? 40 : 54;
    ctx.fillStyle = 'rgba(0,0,0,.6)'; ctx.fillRect(s.x - w / 2, s.y - 3, w, 4);
    ctx.fillStyle = ally ? '#4a8ae0' : '#d0453a'; ctx.fillRect(s.x - w / 2, s.y - 3, w * Math.max(0, u.hp / u.maxHp), 4);
  }
  for (const t of G.texts) {
    const s = toScreen(t.x, 55 + t.t * 40, t.y);
    if (!s.ok) continue;
    ctx.globalAlpha = 1 - t.t / t.life;
    labelText(t.text, s.x, s.y, `700 ${t.size}px ${FONT_B}`, t.color);
  }
  ctx.globalAlpha = 1;
}

function bar(x, y, w, h, v, c1, c2, label) {
  ctx.fillStyle = 'rgba(8,10,14,.75)'; ctx.fillRect(x - 2, y - 2, w + 4, h + 4);
  const g = ctx.createLinearGradient(x, 0, x + w, 0); g.addColorStop(0, c1); g.addColorStop(1, c2);
  ctx.fillStyle = g; ctx.fillRect(x, y, w * clamp(v, 0, 1), h);
  ctx.strokeStyle = 'rgba(236,228,210,.35)'; ctx.lineWidth = 1; ctx.strokeRect(x - .5, y - .5, w + 1, h + 1);
  if (label) { ctx.font = `700 11px ${FONT_B}`; ctx.textAlign = 'left'; ctx.fillStyle = COL.paper; ctx.fillText(label, x + 4, y + h - 3); }
}
function wrapText(text, maxW) {
  const lines = []; let cur = '';
  for (const ch of text) { if (ctx.measureText(cur + ch).width > maxW && cur) { lines.push(cur); cur = ch; } else cur += ch; }
  if (cur) lines.push(cur);
  return lines;
}

function drawHUD() {
  const small = VW < 560, left = 16, top = 14;
  // 画面効果
  if (G.musouTint > 0) {
    const g = ctx.createRadialGradient(VW / 2, VH / 2, Math.min(VW, VH) * .25, VW / 2, VH / 2, Math.max(VW, VH) * .7);
    g.addColorStop(0, 'rgba(0,0,0,0)'); g.addColorStop(1, `rgba(120,70,0,${.45 * G.musouTint})`);
    ctx.fillStyle = g; ctx.fillRect(0, 0, VW, VH);
  }
  if (G.flash > 0) { ctx.fillStyle = `rgba(255,245,220,${G.flash * .6})`; ctx.fillRect(0, 0, VW, VH); }
  // 武将の体力・無双
  const cs = charSave(P.char.id);
  const bw = small ? Math.min(190, VW - 230) : 270;
  labelText(P.char.name, left, top + 16, `800 18px ${FONT_D}`, COL.paper, 'left');
  ctx.font = `800 18px ${FONT_D}`;
  labelText(`Lv ${cs.lv}`, left + ctx.measureText(P.char.name).width + 10, top + 16, `700 12px ${FONT_B}`, COL.gold, 'left');
  bar(left, top + 26, bw, 14, P.hp / P.maxHp, '#3f9a4a', '#8ad46a', `体力 ${Math.ceil(P.hp)}`);
  const full = P.mu >= 100;
  bar(left, top + 46, bw * .85, 10, P.mu / 100, full ? '#f5c84c' : '#8a6a20', full ? '#fff0a0' : '#d4ae55');
  ctx.font = `700 11px ${FONT_B}`; ctx.textAlign = 'left';
  ctx.fillStyle = full ? (Math.floor(G.t * 4) % 2 ? '#fff0a0' : COL.gold) : COL.paper;
  ctx.fillText(full ? (isTouch ? '無双 可' : '無双 [L]') : '無双', left + bw * .85 + 8, top + 55);
  labelText('撃破数', left, top + 80, `700 11px ${FONT_B}`, COL.paper, 'left');
  labelText(G.ko, left + 44, top + 84, `800 26px ${FONT_D}`, COL.paper, 'left');
  labelText(`残り砦 ${basesLeft()} / ${G.bases.length}`, left, top + 102, `700 11px ${FONT_B}`, 'rgba(236,228,210,.8)', 'left');
  // 戦況ゲージ
  const mw2 = small ? 120 : 200, mx2 = small ? left : (VW - mw2) / 2, my2 = small ? top + 116 : top + 8;
  labelText('戦況', mx2 + mw2 / 2, my2 + 2, `700 11px ${FONT_B}`, COL.paper);
  const mv = (G.morale + 100) / 200;
  ctx.fillStyle = 'rgba(8,10,14,.75)'; ctx.fillRect(mx2 - 2, my2 + 6, mw2 + 4, 12);
  ctx.fillStyle = '#3f68b8'; ctx.fillRect(mx2, my2 + 8, mw2 * mv, 8);
  ctx.fillStyle = '#a3352a'; ctx.fillRect(mx2 + mw2 * mv, my2 + 8, mw2 * (1 - mv), 8);
  ctx.fillStyle = COL.paper; ctx.fillRect(mx2 + mw2 / 2 - 1, my2 + 5, 2, 14);
  // 連撃
  if (G.combo >= 3) {
    const s = 1 + Math.max(0, G.comboT - 2.4) * 2;
    ctx.save(); ctx.translate(VW - 24, VH * .42); ctx.scale(s, s);
    labelText(G.combo, 0, 0, `800 40px ${FONT_D}`, G.combo >= 100 ? '#ffd86a' : COL.paper, 'right');
    labelText('連撃', 0, 18, `700 13px ${FONT_B}`, COL.gold, 'right');
    ctx.restore();
  }
  // ミニマップ
  const mw = small ? 120 : 180, mh = mw * WORLD_H / WORLD_W, mx = VW - mw - 14, my = 14, sx = mw / WORLD_W, sy = mh / WORLD_H;
  ctx.fillStyle = 'rgba(10,14,20,.72)'; ctx.fillRect(mx, my, mw, mh);
  if (STAGE.river) { ctx.fillStyle = 'rgba(60,110,150,.7)'; ctx.fillRect(mx + STAGE.river.x1 * sx, my, (STAGE.river.x2 - STAGE.river.x1) * sx, mh); }
  ctx.strokeStyle = 'rgba(212,174,85,.6)'; ctx.lineWidth = 1; ctx.strokeRect(mx + .5, my + .5, mw - 1, mh - 1);
  for (const u of G.units) {
    if (u.dying || (u.kind !== 'ashi' && u.kind !== 'archer')) continue;
    ctx.fillStyle = u.team === 'E' ? 'rgba(220,80,60,.6)' : 'rgba(110,160,255,.7)';
    ctx.fillRect(mx + u.x * sx - .5, my + u.y * sy - .5, 1.5, 1.5);
  }
  for (const b of G.bases) { ctx.fillStyle = b.owner === 'E' ? COL.enemy : COL.ally; ctx.fillRect(mx + b.x * sx - 5, my + b.y * sy - 4, 10, 8); }
  for (const [c, col] of [[STAGE.enemyCamp, COL.enemy], [STAGE.allyCamp, COL.ally]]) { ctx.strokeStyle = col; ctx.lineWidth = 2; ctx.strokeRect(mx + (c.x - c.w / 2) * sx, my + (c.y - c.h / 2) * sy, c.w * sx, c.h * sy); }
  for (const u of G.units) {
    if (u.dying || (u.kind !== 'officer' && u.kind !== 'boss')) continue;
    ctx.fillStyle = u.team === 'A' ? '#8fb8ff' : u.kind === 'boss' ? '#ff6040' : '#f3d58c';
    ctx.beginPath(); ctx.arc(mx + u.x * sx, my + u.y * sy, u.kind === 'boss' ? 4 : 3, 0, TAU); ctx.fill();
  }
  const mis = G.missions.find(m => !m.done);
  if (mis && Math.floor(G.t * 4) % 2) { ctx.strokeStyle = '#ffd88a'; ctx.lineWidth = 2; ctx.beginPath(); ctx.arc(mx + mis.unit.x * sx, my + mis.unit.y * sy, 7, 0, TAU); ctx.stroke(); }
  ctx.strokeStyle = 'rgba(236,228,210,.5)'; ctx.lineWidth = 1; ctx.strokeRect(mx + view.x * sx, my + view.y * sy, view.w * sx, view.h * sy);
  ctx.fillStyle = '#fff'; ctx.beginPath(); ctx.arc(mx + P.x * sx, my + P.y * sy, 3, 0, TAU); ctx.fill();
  const sec = Math.floor(G.t);
  labelText(`${Math.floor(sec / 60)}:${String(sec % 60).padStart(2, '0')}`, VW - 14, my + mh + 16, `700 12px ${FONT_B}`, COL.paper, 'right');
  // 任務
  let ty = my + mh + 34;
  for (const m of G.missions) {
    const txt = m.done ? (m.ok ? '達成' : '失敗') : m.type === 'rescue' ? `残り ${Math.ceil(m.t)}秒` : m.campT ? `本陣陥落まで ${Math.ceil(10 - m.campT)}秒` : '';
    labelText('任務', VW - 14, ty, `700 11px ${FONT_B}`, COL.gold, 'right');
    labelText(m.text, VW - 14, ty + 16, `700 ${small ? 12 : 13}px ${FONT_B}`, m.done ? (m.ok ? '#9cf09a' : '#ff9a8a') : '#ffe6b0', 'right');
    if (txt) labelText(txt, VW - 14, ty + 32, `700 12px ${FONT_B}`, COL.paper, 'right');
    ty += 50;
    // 画面外の目標を矢印で示す
    if (!m.done) {
      const s = toScreen(m.unit.x, 30, m.unit.y);
      if (s.x < 30 || s.x > VW - 30 || s.y < 30 || s.y > VH - 30) {
        const a = Math.atan2(s.y - VH / 2, s.x - VW / 2), R = Math.min(VW, VH) * .42;
        const ax = VW / 2 + Math.cos(a) * R, ay = VH / 2 + Math.sin(a) * R;
        ctx.save(); ctx.translate(ax, ay); ctx.rotate(a);
        ctx.fillStyle = '#ffd88a'; ctx.beginPath(); ctx.moveTo(16, 0); ctx.lineTo(-8, -10); ctx.lineTo(-3, 0); ctx.lineTo(-8, 10); ctx.closePath(); ctx.fill();
        ctx.restore();
      }
    }
  }
  // 武将の体力（攻撃した相手）
  if (G.focus && !G.focus.dying && G.focusT > 0) {
    const e = G.focus, w = Math.min(420, VW - 40), x = (VW - w) / 2, y = isTouch ? VH - 230 : 64;
    labelText(e.name, VW / 2, y - 8, `800 16px ${FONT_D}`, e.kind === 'boss' ? '#ffb090' : '#f3d58c');
    bar(x, y, w, 10, e.hp / e.maxHp, '#8a1f18', '#e0503c');
  }
  // 大きな知らせ
  let my3 = VH * (small ? .33 : .24);
  for (const m of G.msgs) {
    const a = Math.min(1, m.t * 5, (m.life - m.t) * 2);
    ctx.globalAlpha = a; ctx.textAlign = 'center';
    ctx.font = m.big ? `800 ${small ? 18 : 24}px ${FONT_D}` : `700 14px ${FONT_B}`;
    const tw = Math.min(VW - 32, ctx.measureText(m.text).width);
    ctx.fillStyle = 'rgba(10,12,16,.65)'; ctx.fillRect(VW / 2 - tw / 2 - 16, my3 - (m.big ? 25 : 18), tw + 32, m.big ? 34 : 26);
    ctx.fillStyle = m.color; ctx.fillText(m.text, VW / 2, my3, VW - 40);
    my3 += m.big ? 40 : 30;
  }
  ctx.globalAlpha = 1;
  drawTalk(small);
  drawCutin();
  if (joy.id !== null) {
    ctx.strokeStyle = 'rgba(236,228,210,.35)'; ctx.lineWidth = 2; ctx.beginPath(); ctx.arc(joy.ox, joy.oy, 50, 0, TAU); ctx.stroke();
    const dx = joy.x - joy.ox, dy = joy.y - joy.oy, d = Math.hypot(dx, dy), m = Math.min(50, d);
    ctx.fillStyle = 'rgba(236,228,210,.4)'; ctx.beginPath(); ctx.arc(joy.ox + (d ? dx / d * m : 0), joy.oy + (d ? dy / d * m : 0), 22, 0, TAU); ctx.fill();
  }
}

// 合戦中の会話（顔の丸・名前・台詞）
function drawTalk(small) {
  const c = G.talk.cur;
  if (!c) return;
  const w = Math.min(small ? VW - 32 : 480, VW - 32);
  const x = 16, y0 = 200;
  ctx.font = `500 14px ${FONT_B}`;
  const shown = c.text.slice(0, Math.floor(c.t * 30));
  const lines = wrapText(shown, w - 70);
  const h = 34 + Math.max(1, lines.length) * 20;
  const y = small ? y0 : VH - 20 - h;
  const a = Math.min(1, c.t * 6, (c.dur - c.t) * 4);
  ctx.globalAlpha = a;
  ctx.fillStyle = 'rgba(12,15,22,.86)'; ctx.fillRect(x, y, w, h);
  const st = speakerStyle(c.name);
  ctx.fillStyle = st.ally ? '#3f68b8' : '#a3352a'; ctx.fillRect(x, y, 3, h);
  ctx.fillStyle = st.color; ctx.beginPath(); ctx.arc(x + 30, y + 30, 18, 0, TAU); ctx.fill();
  ctx.strokeStyle = 'rgba(255,255,255,.4)'; ctx.lineWidth = 1; ctx.stroke();
  labelText(c.name[0], x + 30, y + 37, `800 18px ${FONT_D}`, '#fff');
  labelText(c.name, x + 58, y + 20, `700 12px ${FONT_B}`, st.ally ? '#b8d0ff' : '#f0b0a0', 'left');
  ctx.font = `500 14px ${FONT_B}`; ctx.fillStyle = COL.paper; ctx.textAlign = 'left';
  lines.forEach((l, i) => ctx.fillText(l, x + 58, y + 40 + i * 20));
  ctx.globalAlpha = 1;
}

// 無双奥義のカットイン
function drawCutin() {
  const c = G.cutin;
  if (!c) return;
  const k = c.t / 1.3, ease = k < .2 ? k / .2 : k > .8 ? (1 - k) / .2 : 1;
  const bh = Math.min(VH * .12, 90) * ease;
  ctx.fillStyle = '#000'; ctx.fillRect(0, 0, VW, bh); ctx.fillRect(0, VH - bh, VW, bh);
  const cy = VH * .5, slide = (1 - Math.min(1, k / .25)) * VW * .6;
  ctx.save(); ctx.globalAlpha = ease;
  ctx.translate(VW / 2 + slide, cy); ctx.rotate(-.08);
  ctx.fillStyle = 'rgba(10,8,4,.82)'; ctx.fillRect(-VW, -48, VW * 2, 96);
  ctx.fillStyle = COL.gold; ctx.fillRect(-VW, -48, VW * 2, 3); ctx.fillRect(-VW, 45, VW * 2, 3);
  const fs = Math.min(64, VW / 7);
  labelText(c.move, 0, 14, `800 ${fs}px ${FONT_D}`, '#fff3c8');
  labelText(c.name, 0, -26, `700 15px ${FONT_B}`, COL.gold);
  ctx.restore();
}
