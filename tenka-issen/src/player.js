// ───────────── プレイヤー操作 ─────────────
function nearestFoe(maxD, cone = null) {
  let best = null, bd = maxD;
  for (const u of G.units) {
    if (u.dying || u.team !== 'E') continue;
    const d = Math.hypot(u.x - P.x, u.y - P.y);
    if (d >= bd) continue;
    if (cone !== null && Math.abs(angDiff(Math.atan2(u.y - P.y, u.x - P.x), P.face)) > cone) continue;
    bd = d; best = u;
  }
  return best;
}
function startAtk(k) {
  const def = P.mv[k];
  const mv = moveVec();
  if (mv.len > .2) P.face = Math.atan2(mv.y, mv.x);
  else { const t = nearestFoe(def.pose === 'bow' || def.pose === 'bowUp' ? 650 : 180); if (t) P.face = Math.atan2(t.y - P.y, t.x - P.x); }
  P.st = 'atk';
  P.atk = { k, def, t: 0, hs: def.hits.map(() => ({ fired: false, set: new Set(), last: -1 })) };
  P.queued = null;
  if (def.name) floatText(P.x, P.y, def.name, COL.gold, 15);
  if (def.heavy) sfx.heavy();
}
function startDodge() {
  const mv = moveVec();
  P.dodgeDir = mv.len > .2 ? Math.atan2(mv.y, mv.x) : P.face + Math.PI;
  P.st = 'dodge'; P.t = 0; P.inv = .32; P.queued = null;
}
function startJump() { P.st = 'jump'; P.vz = 560; P.z = .1; P.airShot = false; sfx.jump(); dust(P.x, P.y, 4); }
function startMusou() {
  const m = P.mv.musou;
  P.st = 'musou'; P.t = 0; P.mu = 0; P.mtick = 0; P.mfinal = false; P.inv = 3.2; P.z = 0; P.vz = 0;
  G.musouTint = 1; G.slowmo = .55; G.cutin = { t: 0, name: P.char.name, move: m.name };
  G.zoom = .6; sfx.musou();
}

function aimAngle(range) {
  const mv = moveVec();
  if (mv.len > .2) return Math.atan2(mv.y, mv.x);
  const t = nearestFoe(range, 1.1);
  return t ? Math.atan2(t.y - P.y, t.x - P.x) : P.face;
}

// 攻撃判定を1つ処理する
function runHit(h, hs, A) {
  const t = A.t;
  if (h.kind === 'arc') {
    const t2 = h.t2 ?? h.t + .06;
    if (t < h.t || t > t2) return;
    const ox = P.x + Math.cos(P.face) * (h.off || 0), oy = P.y + Math.sin(P.face) * (h.off || 0);
    let tick = !hs.fired;
    if (h.every && t - hs.last >= h.every) { hs.set.clear(); hs.last = t; tick = true; }
    if (tick) { attackFx(h, ox, oy, A.def); if (!hs.fired) sfx.swing(); }
    hs.fired = true;
    hitArea(ox, oy, h.range, h.arc, P.face, hs.set, h, 'P');
  } else if (!hs.fired && t >= h.t) {
    hs.fired = true;
    if (h.kind === 'proj') {
      const a = h.aim ? aimAngle(700) : P.face;
      P.face = a;
      fireProj(h, P.x + Math.cos(a) * 20, P.y + Math.sin(a) * 20, 30, a, 'P');
      if (h.p === 'wave') sfx.swing(); else sfx.arrow();
    } else if (h.kind === 'rain') {
      G.rains.push({ x: P.x + Math.cos(P.face) * h.at, y: P.y + Math.sin(P.face) * h.at, radius: h.radius, left: h.ticks, every: h.every, next: .15, h, src: 'P' });
      sfx.arrow();
    }
  }
}
function attackFx(h, x, y, def) {
  const style = h.fx || (h.arc >= TAU - .01 ? 'spin' : 'slash');
  const sw = def.swing || 1;
  if (style === 'slash') fx({ type: 'slash', x, y, face: P.face, arc: h.arc, r: h.range, swing: sw, life: .16, color: 0xfff0c8, h: 20 });
  else if (style === 'spin') fx({ type: 'slash', x, y, face: rand(0, TAU), arc: TAU, r: h.range, swing: 1, life: .18, color: 0xfff0c8, h: 18 });
  else if (style === 'thrust') fx({ type: 'thrust', x, y, face: P.face, r: h.range, life: .14, color: 0xffffff });
  else if (style === 'ring') { fx({ type: 'ring', x, y, r: h.range, life: .35 }); fx({ type: 'slash', x, y, face: P.face, arc: TAU, r: h.range * .8, life: .22, color: 0xffe296, h: 18 }); sfx.big(); }
  else if (style === 'cone') { fx({ type: 'cone', x, y, face: P.face, arc: h.arc, r: h.range, life: .3 }); sfx.big(); dust(x + Math.cos(P.face) * 60, y + Math.sin(P.face) * 60, 8, 220); }
  else if (style === 'quake') {
    fx({ type: 'ring', x, y, r: h.range, life: .45, color: 0xffd070 }); fx({ type: 'ring', x, y, r: h.range * .6, life: .35, color: 0xffffff });
    dust(x, y, 18, 320); G.shake = Math.max(G.shake, .55); G.zoom = Math.max(G.zoom, .35); sfx.boom();
  } else if (style === 'spike') {
    for (let i = 0; i < 4; i++) fx({ type: 'spike', x: x + rand(-26, 26), y: y + rand(-26, 26), s: rand(.7, 1.3), life: .55 });
    dust(x, y, 5, 180); G.shake = Math.max(G.shake, .25); sfx.heavy();
  }
}
function landHit(spec, big) {
  fx({ type: 'ring', x: P.x, y: P.y, r: spec.range, life: .4, color: big ? 0xffd070 : 0xfff0d2 });
  if (big) fx({ type: 'cone', x: P.x, y: P.y, face: 0, arc: TAU, r: spec.range * .8, life: .3 });
  dust(P.x, P.y, big ? 18 : 10, big ? 320 : 220);
  hitArea(P.x, P.y, spec.range, TAU, P.face, new Set(), spec, 'P');
  G.shake = Math.max(G.shake, big ? .5 : .3); G.zoom = Math.max(G.zoom, big ? .4 : .2);
  big ? sfx.boom() : sfx.land();
}

function updatePlayer(dt) {
  const mv = moveVec(), spd = P.char.spd;
  P.inv = Math.max(0, P.inv - dt); P.flash = Math.max(0, P.flash - dt);
  if (act.musou && P.mu >= 100 && P.st !== 'musou' && P.st !== 'down') startMusou();
  // 空中の物理
  const airborne = P.st === 'jump' || P.st === 'dive' || (P.st === 'hurt' && P.z > 0);
  if (airborne) {
    P.vz -= (P.st === 'dive' ? 2600 : 1500) * dt; P.z += P.vz * dt;
    if (P.z <= 0) {
      P.z = 0; P.vz = 0;
      if (P.st === 'dive') { const J = P.diveCharge ? P.mv.JC : P.mv.J; landHit(J.land, P.diveCharge); P.st = 'land'; P.t = P.diveCharge ? .32 : .22; }
      else if (P.st === 'jump') { P.st = 'idle'; dust(P.x, P.y, 5); sfx.land(); }
    }
  }

  switch (P.st) {
    case 'idle': {
      P.vx = mv.x * spd; P.vy = mv.y * spd;
      if (mv.len > .1) P.face = turnToward(P.face, Math.atan2(mv.y, mv.x), 18 * dt);
      if (act.dodge) startDodge();
      else if (act.jump) startJump();
      else if (act.attack) startAtk(P.mv.combo[0]);
      else if (act.charge) startAtk(P.mv.charge.idle);
      break;
    }
    case 'jump': {
      P.vx = mv.x * spd * .9; P.vy = mv.y * spd * .9;
      if (mv.len > .1) P.face = turnToward(P.face, Math.atan2(mv.y, mv.x), 12 * dt);
      if (act.attack && P.mv.J.air && !P.airShot) {
        P.airShot = true; P.face = aimAngle(650);
        fireProj(P.mv.J.air, P.x, P.y, P.z + 30, P.face, 'P', -P.z * 1.6);
        floatText(P.x, P.y, P.mv.J.name, COL.gold, 14); sfx.arrow(); P.vz = Math.max(P.vz, 200);
      } else if ((act.attack && P.mv.J.land) || act.charge) {
        P.st = 'dive'; P.diveCharge = !!act.charge; P.vz = Math.min(P.vz, -250);
        const J = P.diveCharge ? P.mv.JC : P.mv.J; if (J.name) floatText(P.x, P.y, J.name, COL.gold, 15);
        if (P.diveCharge) P.vz = 420; // 大技は少し跳ね上がってから落ちる
      }
      break;
    }
    case 'dive': P.vx *= .9; P.vy *= .9; break;
    case 'land': P.t -= dt; P.vx = P.vy = 0; if (P.t <= 0) P.st = 'idle'; break;
    case 'atk': {
      const A = P.atk, def = A.def;
      A.t += dt;
      const firstHit = def.hits[0].t;
      if (A.t < firstHit && mv.len > .2) P.face = turnToward(P.face, Math.atan2(mv.y, mv.x), 14 * dt);
      let sp = 0;
      if (def.dash && A.t >= def.dash.t0 && A.t <= def.dash.t1) sp = def.dash.spd;
      else if (def.back && A.t >= def.back.t0 && A.t <= def.back.t1) sp = def.back.spd;
      else if (def.step && A.t < firstHit + .06) sp = def.step * 1.6 * (1 - A.t / (firstHit + .06));
      P.vx = Math.cos(P.face) * sp; P.vy = Math.sin(P.face) * sp;
      if (def.move && mv.len > .1) { P.vx += mv.x * def.move; P.vy += mv.y * def.move; }
      def.hits.forEach((h, i) => runHit(h, A.hs[i], A));
      if (def.dash && A.t >= def.dash.t0 && A.t <= def.dash.t1 && G.parts.length < 540) G.parts.push({ x: P.x, y: P.y, vx: 0, vy: 0, h: 0, vh: 0, life: .2, t: 0, color: '#a0b8ff', ghost: true });
      if (A.t > .04) {
        const ci = P.mv.combo.indexOf(A.k);
        if (act.attack && ci >= 0 && ci < P.mv.combo.length - 1) P.queued = P.mv.combo[ci + 1];
        if (act.charge && P.mv.charge[A.k]) P.queued = P.mv.charge[A.k];
      }
      const lastEnd = Math.max(...def.hits.map(h => h.t2 ?? h.t));
      if (act.dodge && A.t > lastEnd) { startDodge(); break; }
      if (act.jump && A.t > lastEnd && A.k[0] === 'N') { startJump(); break; }
      if (A.t >= def.dur) { if (P.queued) startAtk(P.queued); else P.st = 'idle'; }
      break;
    }
    case 'dodge': {
      P.t += dt;
      const sp = 620 * (1 - P.t / .26);
      P.vx = Math.cos(P.dodgeDir) * sp; P.vy = Math.sin(P.dodgeDir) * sp;
      if (P.t >= .26) P.st = 'idle';
      break;
    }
    case 'hurt': {
      P.t -= dt; P.vx *= Math.pow(.02, dt); P.vy *= Math.pow(.02, dt);
      if (P.t <= 0 && P.z <= 0) P.st = 'idle';
      break;
    }
    case 'musou': updateMusou(dt, mv); break;
    case 'down': P.vx = P.vy = 0; break;
  }
  const ox = P.x, oy = P.y;
  moveBody(P, P.vx * dt, P.vy * dt);
  P.vxr = (P.x - ox) / Math.max(dt, 1e-4); P.vyr = (P.y - oy) / Math.max(dt, 1e-4);
}

function updateMusou(dt, mv) {
  const m = P.mv.musou;
  P.t += dt; P.inv = .25;
  P.vx = mv.x * m.moveSpd; P.vy = mv.y * m.moveSpd;
  if (mv.len > .1) P.face = turnToward(P.face, Math.atan2(mv.y, mv.x), 8 * dt);
  P.mtick -= dt;
  const h = { dmg: m.dmg, kb: m.kb, launch: m.launch };
  if (P.t < m.until && P.mtick <= 0) {
    P.mtick = m.tick;
    if (m.style === 'spin') {
      fx({ type: 'slash', x: P.x, y: P.y, face: rand(0, TAU), arc: 3.4, r: m.range, swing: 1, life: .14, color: 0xffd778, h: 20 });
      hitArea(P.x, P.y, m.range, TAU, P.face, new Set(), h, 'P');
      if (Math.random() < .5) sfx.swing();
    } else if (m.style === 'thrust') {
      const f = P.face + rand(-.35, .35);
      fx({ type: 'thrust', x: P.x, y: P.y, face: f, r: m.range, life: .1, color: 0xffd0e0 });
      hitArea(P.x, P.y, m.range, m.arc, P.face, new Set(), h, 'P');
      if (Math.random() < .2) for (let i = 0; i < 3; i++) G.parts.push({ x: P.x + rand(-80, 80), y: P.y + rand(-80, 80), vx: rand(-40, 40), vy: rand(-40, 40), h: rand(30, 70), vh: rand(-20, 20), grav: 30, life: 1, t: 0, color: '#ffb0c8' });
      if (Math.random() < .3) sfx.swing();
    } else if (m.style === 'slam') {
      fx({ type: 'ring', x: P.x, y: P.y, r: m.range, life: .35, color: 0xff7050 });
      fx({ type: 'cone', x: P.x, y: P.y, face: 0, arc: TAU, r: m.range * .7, life: .25, color: 0xff9060 });
      for (let i = 0; i < 5; i++) { const a = rand(0, TAU); fx({ type: 'spike', x: P.x + Math.cos(a) * rand(40, m.range), y: P.y + Math.sin(a) * rand(40, m.range), s: rand(.6, 1.1), life: .5 }); }
      dust(P.x, P.y, 12, 280); hitArea(P.x, P.y, m.range, TAU, P.face, new Set(), h, 'P');
      G.shake = Math.max(G.shake, .3); sfx.heavy();
    } else if (m.style === 'rain') {
      const a = rand(0, TAU), d = rand(30, m.range), x = P.x + Math.cos(a) * d, y = P.y + Math.sin(a) * d;
      fx({ type: 'fall', x, y, life: .18 }); fx({ type: 'ring', x, y, r: 55, life: .2, color: 0xbcd6ff });
      hitArea(x, y, 55, TAU, 0, new Set(), h, 'P');
      if (Math.random() < .4) sfx.arrow();
    }
  }
  if (P.t >= m.final.t && !P.mfinal) {
    P.mfinal = true;
    fx({ type: 'ring', x: P.x, y: P.y, r: m.final.range, life: .55, color: 0xffd66e });
    fx({ type: 'ring', x: P.x, y: P.y, r: m.final.range * .65, life: .45, color: 0xffffff });
    fx({ type: 'cone', x: P.x, y: P.y, face: 0, arc: TAU, r: m.final.range * .9, life: .35, color: 0xffe0a0 });
    dust(P.x, P.y, 30, 420);
    hitArea(P.x, P.y, m.final.range, TAU, P.face, new Set(), m.final, 'P');
    G.shake = .9; G.hitstop = .14; G.flash = 1; G.zoom = .8; sfx.boom();
  }
  if (P.t >= m.dur) { P.st = 'idle'; P.inv = .5; }
}
