// ───────────── 3D描画（Three.js・棒人間） ─────────────
renderer = new THREE.WebGLRenderer({ canvas: cvs, antialias: true, powerPreference: 'high-performance' });
const scene = new THREE.Scene();
scene.background = new THREE.Color(0x1b2416);
scene.fog = new THREE.Fog(0x1b2416, 900, 2000);
camera = new THREE.PerspectiveCamera(40, VW / VH, 10, 6000);
scene.add(new THREE.HemisphereLight(0xe8eeff, 0x40351f, 0.75));
const sun = new THREE.DirectionalLight(0xfff1d6, 0.6); sun.position.set(-0.5, 1, 0.35); scene.add(sun);
resize();

// ───────────── 地面（合戦ごとに描き直す） ─────────────
const GROUND_SCALE = 0.5;
const ground = document.createElement('canvas');
ground.width = WORLD_W * GROUND_SCALE; ground.height = WORLD_H * GROUND_SCALE;
function paintGround(st) {
  const g = ground.getContext('2d');
  g.setTransform(GROUND_SCALE, 0, 0, GROUND_SCALE, 0, 0);
  g.fillStyle = st.id === 's3' ? '#454631' : '#3d4a2b'; g.fillRect(0, 0, WORLD_W, WORLD_H);
  for (let i = 0; i < 900; i++) {
    const x = rand(0, WORLD_W), y = rand(0, WORLD_H), r = rand(20, 110);
    g.fillStyle = Math.random() < .5 ? 'rgba(80,96,52,.25)' : 'rgba(34,44,24,.25)';
    g.beginPath(); g.ellipse(x, y, r, r * rand(.5, 1), rand(0, 3), 0, TAU); g.fill();
  }
  for (const [w, c] of [[86, 'rgba(92,74,48,.85)'], [60, 'rgba(122,98,64,.9)']]) {
    g.strokeStyle = c; g.lineWidth = w; g.lineCap = 'round'; g.lineJoin = 'round';
    for (const r of st.roads) {
      g.beginPath(); g.moveTo(r[0][0], r[0][1]);
      for (let i = 1; i < r.length; i++) { const p = r[i - 1], q = r[i]; g.quadraticCurveTo((p[0] + q[0]) / 2 + rand(-60, 60), (p[1] + q[1]) / 2 + rand(-60, 60), q[0], q[1]); }
      g.stroke();
    }
  }
  if (st.river) { g.fillStyle = '#2a3a2a'; g.fillRect(st.river.x1 - 24, 0, st.river.x2 - st.river.x1 + 48, WORLD_H); }
  for (let i = 0; i < 4000; i++) {
    g.fillStyle = Math.random() < .7 ? 'rgba(110,130,70,.5)' : 'rgba(150,140,110,.4)';
    g.fillRect(rand(0, WORLD_W), rand(0, WORLD_H), rand(2, 5), rand(2, 5));
  }
}
const groundTex = new THREE.CanvasTexture(ground);
groundTex.anisotropy = Math.min(8, renderer.capabilities.getMaxAnisotropy());
const groundMesh = new THREE.Mesh(new THREE.PlaneGeometry(WORLD_W, WORLD_H), new THREE.MeshLambertMaterial({ map: groundTex }));
groundMesh.rotation.x = -Math.PI / 2; groundMesh.position.set(WORLD_W / 2, 0, WORLD_H / 2); scene.add(groundMesh);
const outerGround = new THREE.Mesh(new THREE.PlaneGeometry(WORLD_W * 3, WORLD_H * 3), new THREE.MeshLambertMaterial({ color: 0x1f2c1a }));
outerGround.rotation.x = -Math.PI / 2; outerGround.position.set(WORLD_W / 2, -1, WORLD_H / 2); scene.add(outerGround);

// ───────────── インスタンス描画（棒人間の部品をまとめて描く） ─────────────
function mkInst(geo, mat, cap) {
  const m = new THREE.InstancedMesh(geo, mat, cap);
  m.instanceMatrix.setUsage(THREE.DynamicDrawUsage);
  const c = new THREE.Color(1, 1, 1);
  for (let i = 0; i < cap; i++) m.setColorAt(i, c);
  m.count = 0; m.frustumCulled = false; scene.add(m);
  return m;
}
const CAP = { L: 6000, B: 700, C: 700, X: 700, S: 700 };
const LIMB = mkInst(new THREE.CylinderGeometry(1, 1, 1, 6), new THREE.MeshLambertMaterial(), CAP.L);
const BALL = mkInst(new THREE.SphereGeometry(1, 12, 8), new THREE.MeshLambertMaterial(), CAP.B);
const CONE = mkInst(new THREE.ConeGeometry(1, 1, 10), new THREE.MeshLambertMaterial(), CAP.C);
const BOX = mkInst(new THREE.BoxGeometry(1, 1, 1), new THREE.MeshLambertMaterial(), CAP.X);
const shGeo = new THREE.CircleGeometry(1, 16); shGeo.rotateX(-Math.PI / 2);
const SHADOW = mkInst(shGeo, new THREE.MeshBasicMaterial({ color: 0x000000, transparent: true, opacity: .32, depthWrite: false }), CAP.S);

const _m = new THREE.Matrix4(), _q = new THREE.Quaternion(), _s = new THREE.Vector3(), _p = new THREE.Vector3(), _d = new THREE.Vector3(), _c = new THREE.Color();
const UP = new THREE.Vector3(0, 1, 0);
let nL = 0, nB = 0, nC = 0, nX = 0, nS = 0;
function put(mesh, i, col) { mesh.setMatrixAt(i, _m); _c.setHex(col); mesh.setColorAt(i, _c); }
function seg(a, b, r, col) {
  if (nL >= CAP.L) return;
  _d.set(b[0] - a[0], b[1] - a[1], b[2] - a[2]);
  const len = _d.length() || .001; _d.multiplyScalar(1 / len);
  _q.setFromUnitVectors(UP, _d);
  _p.set((a[0] + b[0]) / 2, (a[1] + b[1]) / 2, (a[2] + b[2]) / 2); _s.set(r, len, r);
  _m.compose(_p, _q, _s); put(LIMB, nL++, col);
}
function ball(a, r, col) { if (nB >= CAP.B) return; _q.identity(); _p.set(a[0], a[1], a[2]); _s.set(r, r, r); _m.compose(_p, _q, _s); put(BALL, nB++, col); }
function cone(a, r, h, col) { if (nC >= CAP.C) return; _q.identity(); _p.set(a[0], a[1], a[2]); _s.set(r, h, r); _m.compose(_p, _q, _s); put(CONE, nC++, col); }
function box(a, sx, sy, sz, yaw, col) { if (nX >= CAP.X) return; _q.setFromAxisAngle(UP, -yaw); _p.set(a[0], a[1], a[2]); _s.set(sx, sy, sz); _m.compose(_p, _q, _s); put(BOX, nX++, col); }
function blob(x, y, r) { if (nS >= CAP.S) return; _q.identity(); _p.set(x, 1, y); _s.set(r, 1, r); _m.compose(_p, _q, _s); SHADOW.setMatrixAt(nS++, _m); }

// 棒人間。局所座標 (前, 横, 上) をワールド座標 [x, 高さ, y] に変換して部品を置く
function figure(u, H, o) {
  const yaw = u.face + (o.spin || 0), cf = Math.cos(yaw), sf = Math.sin(yaw);
  const tilt = o.tilt || 0, ct = Math.cos(tilt), st = Math.sin(tilt), lift = (o.lift || 0) + (u.z || 0);
  const J = (lf, ls, lu) => { const f2 = lf * ct + lu * st, u2 = -lf * st + lu * ct; return [u.x + cf * f2 - sf * ls, u2 + lift, u.y + sf * f2 + cf * ls]; };
  const sw = Math.sin(u.walk || 0) * (o.move || 0), ln = (o.lean || 0) * H;
  const W = o.white;
  const col = W ? 0xffffff : o.col, body = W ? 0xffffff : o.body, r = o.lw;
  const tuck = o.tuck ? .14 * H : 0;
  const hip = J(0, 0, .5 * H), neck = J(ln, 0, .84 * H), head = J(ln * 1.15, 0, .97 * H);
  const hl = J(0, -.07 * H, .5 * H), hr = J(0, .07 * H, .5 * H);
  const kl = J(sw * .12 * H + .05 * H + tuck, -.09 * H, .26 * H + tuck), fl = J(sw * .2 * H, -.1 * H, tuck * 1.2);
  let kr = J(-sw * .12 * H + .05 * H + tuck, .09 * H, .26 * H + tuck), fr = J(-sw * .2 * H, .1 * H, tuck * 1.2);
  if (o.kick) { kr = J(.22 * H, .08 * H, .42 * H); fr = J(.48 * H, .08 * H, .46 * H); }
  seg(hl, kl, r, col); seg(kl, fl, r, col); seg(hr, kr, r, col); seg(kr, fr, r, col);
  seg(hip, neck, r * 1.5, body); seg(J(ln * .85, -.15 * H, .79 * H), J(ln * .85, .15 * H, .79 * H), r * 1.2, body); seg(hl, hr, r * 1.2, body);
  const sl = J(ln * .85, -.15 * H, .79 * H), sr = J(ln * .85, .15 * H, .79 * H);
  // 左手
  let hdlL;
  if (o.bow) hdlL = [ln + .34 * H, -.04 * H, .8 * H];
  else hdlL = [ln + .08 * H - sw * .14 * H, -.21 * H, .52 * H];
  seg(sl, J(...hdlL), r, col);
  // 右手と武器（wa: 体の正面からの横角、wr: 仰角、ext: 突きの伸び）
  const wa = o.wa || 0, wr = o.wr || 0, ext = (o.ext || 0) * H;
  const dx = Math.cos(wa) * Math.cos(wr), dy = Math.sin(wa) * Math.cos(wr), dz = Math.sin(wr);
  let hx = ln * .85 + dx * (.34 * H + ext), hy = .15 * H + dy * (.34 * H + ext), hz = .79 * H + dz * (.34 * H + ext);
  if (o.bow) { hx = ln + .02 * H; hy = .05 * H; hz = .8 * H; }
  const hand = J(hx, hy, hz);
  seg(sr, hand, r, col);
  const wcol = W ? 0xffffff : o.wcol, wl = o.wl;
  const at = k => J(hx + dx * wl * k, hy + dy * wl * k, hz + dz * wl * k);
  switch (o.weapon) {
    case 'katana': case 'odachi':
      seg(hand, at(.22), o.ww * .9, 0x1b1b1b); seg(at(.22), at(1), o.ww, wcol);
      break;
    case 'yari': case 'spear':
      seg(J(hx - dx * wl * .35, hy - dy * wl * .35, hz - dz * wl * .35), at(.8), o.ww * .7, 0x6e5232);
      seg(at(.8), at(1.02), o.ww * 1.1, wcol);
      break;
    case 'yumi': {
      // 弓は左手で縦に持つ。中央が前へふくらむ
      const L = hdlL, ba = o.bowA || 0, fx2 = Math.cos(ba), fy2 = Math.sin(ba);
      const pts = [];
      for (let i = 0; i <= 6; i++) { const s = i / 3 - 1, bulge = (1 - s * s) * .1 * H; pts.push(J(L[0] + fx2 * bulge, L[1] + fy2 * bulge, L[2] + s * .44 * H)); }
      for (let i = 0; i < 6; i++) seg(pts[i], pts[i + 1], 1.3, W ? 0xffffff : 0x5a3a1e);
      const mid = o.bow ? hand : J(L[0] - fx2 * .02 * H, L[1] - fy2 * .02 * H, L[2]);
      seg(pts[0], mid, .5, 0xe8e0d0); seg(mid, pts[6], .5, 0xe8e0d0);
      break;
    }
  }
  ball(head, .12 * H, W ? 0xffffff : o.head);
  if (!o.hat) ball(J(ln * 1.15 + .075 * H, 0, .95 * H), .07 * H, W ? 0xffffff : 0xd9bf98);
  if (o.hat) cone(J(ln * 1.15, 0, 1.07 * H), .22 * H, .08 * H, W ? 0xffffff : 0x2b2622);
  if (o.crest) {
    const c0 = J(ln * 1.15 + .1 * H, 0, 1.02 * H);
    seg(c0, J(ln * 1.15 + .2 * H, -.1 * H, 1.2 * H), 1.3, o.crest);
    seg(c0, J(ln * 1.15 + .2 * H, .1 * H, 1.2 * H), 1.3, o.crest);
  }
  if (o.flag) {
    seg(J(-.09 * H, 0, .55 * H), J(-.09 * H, 0, 1.38 * H), .9, 0x2a2016);
    box(J(-.09 * H, .07 * H, 1.2 * H), 1.4, .28 * H, .14 * H, yaw, o.flag);
  }
  blob(u.x, u.y, H * .34 * (1 - Math.min(.6, (u.z || 0) / 300)));
}

const hexOf = s => parseInt(String(s).slice(1), 16);
const WEAPON_LOOK = {
  katana: { wl: 44, ww: 1.7, wcol: 0xeef3f8 }, odachi: { wl: 66, ww: 2.8, wcol: 0xe2e6ea }, yari: { wl: 70, ww: 1.5, wcol: 0xe8edf2 },
  spear: { wl: 44, ww: 1.2, wcol: 0xc8ced6 }, yumi: { wl: 0, ww: 1 },
};
function unitLook(u) {
  const D = KIND[u.kind], E = u.team === 'E';
  const o = { H: D.H, lw: 1.5, head: 0xcfb48e, weapon: u.weapon };
  if (u.kind === 'ashi' || u.kind === 'archer') {
    Object.assign(o, E ? { col: 0x6e3226, body: u.kind === 'archer' ? 0x7a4a2c : 0x8a3a2c, flag: 0xa3352a } : { col: 0x24406e, body: 0x2e4f86, flag: 0x3f68b8 }, { hat: true });
  } else if (u.kind === 'leader') {
    Object.assign(o, { lw: 1.8, col: 0x7a4e20, body: 0x8a5a24, flag: 0xa3352a, hat: true, crest: 0xcfd3da });
  } else {
    const c = u.color ? hexOf(u.color) : 0x6b3d8f;
    Object.assign(o, { lw: u.kind === 'boss' ? 2.6 : 2.2, col: c, body: c, head: u.kind === 'boss' ? 0x2c2a30 : 0x3a2f28, crest: u.kind === 'boss' ? 0xe8c060 : E ? 0xd4ae55 : 0xd8e4ff, flag: E ? (u.kind === 'boss' ? 0xd4ae55 : 0xa3352a) : 0x3f68b8 });
  }
  return Object.assign(o, WEAPON_LOOK[o.weapon]);
}
function poseUnit(u) {
  const o = unitLook(u), D = KIND[u.kind];
  o.move = Math.min(1, (u.spdNow || 0) / 50);
  const long = o.weapon === 'spear' || o.weapon === 'yari';
  o.wa = long ? .2 : .55; o.wr = long ? .02 : -.35;
  if (o.weapon === 'yumi') { o.wa = .8; o.wr = -.5; }
  if (u.st === 'wind') {
    const k = 1 - u.t / D.wind;
    if (o.weapon === 'yumi') { o.bow = true; o.lean = -.04; }
    else if (long) { o.wa = 0; o.wr = .25 * k; o.lean = -.06; o.ext = -.1 * k; }
    else { o.wa = -1.2 * u.swing; o.wr = .5; o.lean = -.04; }
  } else if (u.st === 'rec') { if (long) { o.wa = 0; o.ext = .2; } else if (o.weapon !== 'yumi') o.wa = 1.1 * -u.swing; o.wr = 0; o.lean = .12; }
  else if (u.st === 'dash') { o.wa = 0; o.wr = .1; o.lean = .25; o.move = 1.4; }
  else if (u.st === 'rageWind') { o.wa = 0; o.wr = 1.3; o.lean = -.1; }
  else if (u.st === 'rage') { o.wa = (G.t * 20) % TAU; o.wr = 0; o.lean = .15; }
  if (u.stun > 0 && u.z <= 0) o.tilt = -.28;
  if (u.z > 0) { o.tilt = -Math.min(1.5, u.z / 60); o.spin = u.spinA; o.move = 0; }
  if (u.dying) { const k = clamp((1.1 - u.dying) / .3, 0, 1); o.tilt = Math.min(o.tilt || 0, -Math.PI / 2 * k); o.spin = u.spinA; o.lift = u.dying < .3 ? -(.3 - u.dying) * 40 : 0; o.move = 0; }
  if (u.flash > 0) o.white = true;
  return o;
}
function posePlayer() {
  const ch = P.char;
  const o = Object.assign({ H: 46, lw: 2.1, col: ch.col, body: ch.body, head: ch.head, crest: ch.crest, flag: ch.flag, weapon: ch.weapon }, WEAPON_LOOK[ch.weapon]);
  o.move = Math.min(1, Math.hypot(P.vxr || 0, P.vyr || 0) / 60);
  const yumi = ch.weapon === 'yumi', long = ch.weapon === 'yari';
  o.wa = long ? .3 : .75; o.wr = long ? 0 : -.4;
  if (yumi) { o.wa = .8; o.wr = -.5; }
  if (P.st === 'atk') {
    const def = P.atk.def, h0 = def.hits[0], t = P.atk.t, t2 = h0.t2 ?? h0.t + .06;
    let k = clamp(t / (t2 + .02), 0, 1), sw = def.swing || 1;
    if (h0.every && t >= h0.t) { const c = (t - h0.t) / h0.every; k = c % 1; if (Math.floor(c) % 2) sw = -sw; }
    const arc = Math.min(h0.arc || 2, 3.6);
    o.lean = .12; o.move = 0;
    switch (def.pose) {
      case 'slash': o.wa = -sw * arc / 2 + sw * arc * k; o.wr = 0; break;
      case 'thrust': o.wa = 0; o.wr = .05; o.ext = Math.sin(k * Math.PI) * .3; o.lean = .2; break;
      case 'thrustUp': o.wa = 0; o.wr = -.2 + 1.3 * k; o.ext = .2; break;
      case 'spin': o.wa = (k * TAU * 1.5) % TAU; o.wr = 0; break;
      case 'overhead': o.wa = 0; o.wr = 1.3 - 2.1 * k; o.lean = .1 + .25 * k; break;
      case 'upper': o.wa = 0; o.wr = -.7 + 2 * k; o.lean = -.05; break;
      case 'bow': o.bow = true; o.lean = .02; break;
      case 'bowUp': o.bow = true; o.lean = -.12; break;
      case 'kick': o.kick = true; o.lean = -.1; break;
    }
    if (def.dash && t >= def.dash.t0 && t <= def.dash.t1) { o.lean = .3; o.move = 1.5; }
  } else if (P.st === 'dodge') { o.lean = .35; o.move = 1.5; }
  else if (P.st === 'jump') { o.tuck = true; if (yumi && P.airShot) o.bow = true; }
  else if (P.st === 'dive') { o.tuck = true; o.wa = 0; o.wr = -1.2; o.lean = .3; }
  else if (P.st === 'land') { o.lift = -5; o.lean = .3; o.wa = 0; o.wr = -1.1; }
  else if (P.st === 'hurt') { o.tilt = -.35; }
  else if (P.st === 'musou') {
    const m = P.mv.musou;
    if (m.style === 'spin') { o.wa = (G.t * 26) % TAU; o.wr = .05; o.lean = .1; }
    else if (m.style === 'thrust') { o.wa = 0; o.ext = Math.abs(Math.sin(G.t * 40)) * .3; o.lean = .2; }
    else if (m.style === 'slam') { const k = (P.t % m.tick) / m.tick; o.wa = 0; o.wr = 1.3 - 2.3 * k; o.lean = .1 + .2 * k; }
    else if (m.style === 'rain') { o.bow = true; o.lean = -.15; }
  } else if (P.st === 'down') { o.tilt = -Math.PI / 2; o.move = 0; }
  if (P.flash > 0) o.col = o.body = 0xff6a5a;
  return o;
}

// ───────────── 背景（砦・本陣・川・森）を合戦ごとに組み立てる ─────────────
let sceneryGroup = null;
const baseFlagMats = [];
function disposeGroup(gr) { gr.traverse(o => { if (o.geometry) o.geometry.dispose(); if (o.material) o.material.dispose(); }); scene.remove(gr); }
function buildStageVisuals() {
  paintGround(STAGE); groundTex.needsUpdate = true;
  if (sceneryGroup) disposeGroup(sceneryGroup);
  const grp = sceneryGroup = new THREE.Group(); scene.add(grp);
  const add = (geo, mat, x, y, z) => { const m = new THREE.Mesh(geo, mat); m.position.set(x, y, z); grp.add(m); return m; };
  const wood = new THREE.MeshLambertMaterial({ color: 0x6b4a2a });
  const posts = [];
  const rail = (x, y, len, alongX) => { for (const h of [9, 20]) add(new THREE.BoxGeometry(alongX ? len : 3, 3, alongX ? 3 : len), wood, x, h, y); };
  baseFlagMats.length = 0;
  G.bases.forEach((b, i) => {
    const w = b.w, h = b.h, x0 = b.x - w / 2, y0 = b.y - h / 2;
    for (let x = x0; x <= x0 + w + .1; x += 18) { posts.push([x, y0]); if (Math.abs(x - b.x) > 30) posts.push([x, y0 + h]); }
    for (let y = y0 + 18; y < y0 + h; y += 18) { posts.push([x0, y]); posts.push([x0 + w, y]); }
    rail(b.x, y0, w, true); rail(x0, b.y, h, false); rail(x0 + w, b.y, h, false);
    rail(x0 + (w / 2 - 30) / 2, y0 + h, w / 2 - 30, true); rail(x0 + w - (w / 2 - 30) / 2, y0 + h, w / 2 - 30, true);
    const mat = new THREE.MeshLambertMaterial({ color: 0xa3352a });
    baseFlagMats[i] = mat;
    for (const [fx2, fy] of [[x0 + 14, y0 + 14], [x0 + w - 14, y0 + 14], [b.x - 40, y0 + h - 10], [b.x + 40, y0 + h - 10]]) {
      add(new THREE.CylinderGeometry(1.2, 1.2, 70, 5), new THREE.MeshLambertMaterial({ color: 0x2a2016 }), fx2, 35, fy);
      add(new THREE.BoxGeometry(1.5, 34, 16), mat, fx2, 50, fy + 8);
    }
  });
  const postInst = new THREE.InstancedMesh(new THREE.CylinderGeometry(2.4, 3, 28, 5), wood, Math.max(1, posts.length));
  posts.forEach(([x, y], i) => { _m.makeTranslation(x, 14, y); postInst.setMatrixAt(i, _m); });
  grp.add(postInst);
  // 陣幕
  const curtain = (c, stripe, gateSouth) => {
    const white = new THREE.MeshLambertMaterial({ color: 0xece4d2 }), sMat = new THREE.MeshLambertMaterial({ color: stripe });
    const wall = (x, y, len, alongX) => {
      add(new THREE.BoxGeometry(alongX ? len : 2, 34, alongX ? 2 : len), white, x, 17, y);
      add(new THREE.BoxGeometry(alongX ? len : 2.4, 7, alongX ? 2.4 : len), sMat, x, 24, y);
    };
    const { x, y, w, h } = c, half = (w - 90) / 2;
    wall(x - w / 2, y, h, false); wall(x + w / 2, y, h, false);
    if (gateSouth) { wall(x, y - h / 2, w, true); wall(x - w / 2 + half / 2, y + h / 2, half, true); wall(x + w / 2 - half / 2, y + h / 2, half, true); }
    else { wall(x, y + h / 2, w, true); wall(x - w / 2 + half / 2, y - h / 2, half, true); wall(x + w / 2 - half / 2, y - h / 2, half, true); }
  };
  curtain(STAGE.enemyCamp, 0xa3352a, true);
  curtain(STAGE.allyCamp, 0x3f68b8, STAGE.allyCamp.y < STAGE.start.y ? true : false);
  // 川と橋
  const rv = STAGE.river;
  if (rv) {
    const water = new THREE.Mesh(new THREE.PlaneGeometry(rv.x2 - rv.x1 + 30, WORLD_H + 600), new THREE.MeshLambertMaterial({ color: 0x2f5a78, emissive: 0x0a1a28, transparent: true, opacity: .92 }));
    water.rotation.x = -Math.PI / 2; water.position.set((rv.x1 + rv.x2) / 2, 2, WORLD_H / 2); grp.add(water);
    for (const [a, b] of rv.bridges) {
      add(new THREE.BoxGeometry(rv.x2 - rv.x1 + 80, 6, b - a), new THREE.MeshLambertMaterial({ color: 0x7a5a36 }), (rv.x1 + rv.x2) / 2, 5, (a + b) / 2);
      for (const yy of [a + 3, b - 3]) add(new THREE.BoxGeometry(rv.x2 - rv.x1 + 80, 4, 4), wood, (rv.x1 + rv.x2) / 2, 18, yy);
    }
  }
  // 森
  const trees = [];
  for (let i = 0; i < 420; i++) {
    const side = i % 4;
    let x, y;
    if (side === 0) { x = rand(-150, WORLD_W + 150); y = rand(-220, 70); }
    else if (side === 1) { x = rand(-150, WORLD_W + 150); y = rand(WORLD_H + 60, WORLD_H + 260); }
    else if (side === 2) { x = rand(-220, 70); y = rand(0, WORLD_H); }
    else { x = rand(WORLD_W - 70, WORLD_W + 220); y = rand(0, WORLD_H); }
    trees.push([x, y, rand(.8, 1.4)]);
  }
  const canopy = new THREE.InstancedMesh(new THREE.ConeGeometry(30, 90, 7), new THREE.MeshLambertMaterial({ color: STAGE.id === 's3' ? 0x34361f : 0x24371f }), trees.length);
  const trunk = new THREE.InstancedMesh(new THREE.CylinderGeometry(4, 5, 30, 5), new THREE.MeshLambertMaterial({ color: 0x3a2a1a }), trees.length);
  trees.forEach(([x, y, s], i) => {
    _q.identity(); _s.set(s, s, s);
    _p.set(x, 70 * s, y); _m.compose(_p, _q, _s); canopy.setMatrixAt(i, _m);
    _p.set(x, 15 * s, y); _m.compose(_p, _q, _s); trunk.setMatrixAt(i, _m);
  });
  grp.add(canopy); grp.add(trunk);
}

// ───────────── エフェクト ─────────────
const fxGroup = new THREE.Group(); scene.add(fxGroup);
const poolGroup = new THREE.Group(); scene.add(poolGroup);
let frameId = 0;
function fxMat(color, opacity, additive = true) {
  return new THREE.MeshBasicMaterial({ color, transparent: true, opacity, depthWrite: false, side: THREE.DoubleSide, blending: additive ? THREE.AdditiveBlending : THREE.NormalBlending });
}
function placeSector(mesh, x, h, y, start, len, r) { mesh.position.set(x, h, y); mesh.rotation.set(-Math.PI / 2, 0, -start - len); mesh.scale.set(r, r, 1); }
function syncFx() {
  for (const f of G.fx) {
    const k = f.t / f.life;
    if (f.type === 'spike') {
      const grow = Math.min(1, k * 4), sink = k > .6 ? (k - .6) / .4 : 0, hgt = 46 * f.s * grow * (1 - sink);
      cone([f.x, hgt / 2, f.y], 13 * f.s, Math.max(.1, hgt), 0x7a6a58);
      continue;
    }
    if (f.type === 'fall') { const y0 = 200 * (1 - k); seg([f.x, 10 + y0, f.y], [f.x + 4, 40 + y0, f.y + 4], .9, 0xd8d0b8); continue; }
    if (!f.mesh) {
      let geo, col = new THREE.Color(f.color ?? 0xfff0d2);
      if (f.type === 'slash') geo = new THREE.RingGeometry(.5, 1, 28, 1, 0, Math.min(f.arc, TAU));
      else if (f.type === 'ring') { geo = new THREE.RingGeometry(.86, 1, 56); if (f.color === undefined) col = new THREE.Color(0xfff0d2); }
      else if (f.type === 'thrust') geo = new THREE.CircleGeometry(1, 6, 0, .2);
      else { geo = new THREE.CircleGeometry(1, 28, 0, f.arc); if (f.color === undefined) col = new THREE.Color(0xffe0a0); }
      f.mesh = new THREE.Mesh(geo, fxMat(col, 1)); fxGroup.add(f.mesh);
    }
    const m = f.mesh; m.userData.frame = frameId;
    if (f.type === 'slash') { const arc = Math.min(f.arc, TAU); placeSector(m, f.x, f.h || 18, f.y, f.face - arc / 2, arc, f.r * (.85 + .25 * k)); m.material.opacity = .6 * (1 - k); }
    else if (f.type === 'ring') { placeSector(m, f.x, 3, f.y, 0, TAU, f.r * (.3 + .7 * k)); m.material.opacity = 1 - k; }
    else if (f.type === 'thrust') { placeSector(m, f.x, 22, f.y, f.face - .1, .2, f.r * (.8 + .3 * k)); m.material.opacity = .8 * (1 - k); }
    else { placeSector(m, f.x, 4, f.y, f.face - f.arc / 2, f.arc, f.r * (.5 + .5 * k)); m.material.opacity = .7 * (1 - k); }
  }
  for (const p of G.proj) {
    const bx = p.x - Math.cos(p.ang) * 24, by = p.y - Math.sin(p.ang) * 24;
    if (p.p === 'wave') {
      if (!p.mesh) { p.mesh = new THREE.Mesh(new THREE.RingGeometry(.72, 1, 18, 1, 0, 2.2), fxMat(new THREE.Color(0xcfe6ff), 1)); fxGroup.add(p.mesh); }
      p.mesh.userData.frame = frameId;
      placeSector(p.mesh, p.x - Math.cos(p.ang) * 20, 16, p.y - Math.sin(p.ang) * 20, p.ang - 1.1, 2.2, p.r);
      p.mesh.material.opacity = 1 - p.t / p.life;
    } else if (p.p === 'fire') ball([p.x, p.h, p.y], 8, 0xffa040);
    else if (p.p === 'bigarrow') { seg([bx - Math.cos(p.ang) * 14, p.h, by - Math.sin(p.ang) * 14], [p.x, p.h, p.y], 2, 0xbfe0ff); }
    else seg([bx, p.h - p.vh * .02, by], [p.x, p.h, p.y], .9, p.team === 'E' ? 0x9a8060 : 0xe0d4b0);
  }
  for (const m of fxGroup.children.slice()) {
    if (m.userData.frame !== frameId) { fxGroup.remove(m); m.geometry.dispose(); m.material.dispose(); }
  }
}
const teleGeo = {}, auraGeo = new THREE.RingGeometry(.86, 1, 40);
for (const k in KIND) teleGeo[k] = new THREE.CircleGeometry(1, 24, 0, KIND[k].arc);
const rageGeo = new THREE.CircleGeometry(1, 40);
const telePool = [], auraPool = [];
function poolMesh(pool, i, make) { if (!pool[i]) { pool[i] = make(); poolGroup.add(pool[i]); } pool[i].visible = true; return pool[i]; }

// 火花・土煙
const PMAX = 600;
const pPos = new Float32Array(PMAX * 3), pCol = new Float32Array(PMAX * 3);
const pGeo = new THREE.BufferGeometry();
pGeo.setAttribute('position', new THREE.BufferAttribute(pPos, 3));
pGeo.setAttribute('color', new THREE.BufferAttribute(pCol, 3));
const sparksMesh = new THREE.Points(pGeo, new THREE.PointsMaterial({ size: 7, vertexColors: true, transparent: true, blending: THREE.AdditiveBlending, depthWrite: false }));
sparksMesh.frustumCulled = false; scene.add(sparksMesh);
const colorCache = {};
const styleColor = s => colorCache[s] || (colorCache[s] = new THREE.Color().setStyle(s));

// ───────────── カメラと描画 ─────────────
const _v = new THREE.Vector3();
function toScreen(x, h, y) { _v.set(x, h, y).project(camera); return { x: (_v.x + 1) / 2 * VW, y: (1 - _v.y) / 2 * VH, ok: _v.z > -1 && _v.z < 1 }; }
const camS = { x: 0, y: 0 };
const view = { x: 0, y: 0, w: 1000, h: 700 };
let lastRender = performance.now();
let inView = () => true;

function render() {
  const now2 = performance.now(), rdt = Math.max(.001, Math.min(.05, (now2 - lastRender) / 1000)); lastRender = now2;
  frameId++;
  const aspect = VW / VH;
  if (state === 'select' || state === 'brief') {
    // 武将選択：キャラクターに寄る
    const wide = VW >= 900;
    const ax = G.demo ? G.demo.ax : P.x, ay = G.demo ? G.demo.ay : P.y;
    camera.position.set(ax + 70, 105, ay + 250);
    camera.lookAt(ax, 26, ay);
    if (wide) camera.setViewOffset(VW, VH, 235, 0, VW, VH); else camera.setViewOffset(VW, VH, 0, VH * .3, VW, VH);
    camS.x = P.x; camS.y = P.y;
  } else {
    if (camera.view && camera.view.enabled) camera.clearViewOffset();
    const dist = (aspect < 1 ? 860 : 620) * (1 - G.zoom * .15);
    const tx = clamp(P.x, 200, WORLD_W - 200), ty = clamp(P.y, 200, WORLD_H - 120);
    if (G.camReset) { camS.x = tx; camS.y = ty; G.camReset = false; }
    camS.x += (tx - camS.x) * .12; camS.y += (ty - camS.y) * .12;
    const sh = G.shake * 14, sx = camS.x + rand(-sh, sh), sy = camS.y + rand(-sh, sh);
    camera.position.set(sx, dist * .8, sy + dist * .62);
    camera.lookAt(sx, 0, sy - 20);
    view.w = dist * .95 * Math.max(aspect, .6); view.h = dist;
  }
  view.x = camS.x - view.w / 2; view.y = camS.y - view.h * .62;
  inView = (x, y) => x > camS.x - view.w * .75 && x < camS.x + view.w * .75 && y > camS.y - view.h * .95 && y < camS.y + view.h * .6;

  nL = nB = nC = nX = nS = 0;
  P.walk = (P.walk || 0) + Math.min(Math.hypot(P.vxr || 0, P.vyr || 0), 600) * rdt * .085;
  figure(P, 46, posePlayer());
  let ti = 0, ai = 0;
  for (const u of G.units) {
    if (!inView(u.x, u.y)) { u.px = u.x; u.py = u.y; continue; }
    u.spdNow = Math.hypot(u.x - (u.px ?? u.x), u.y - (u.py ?? u.y)) / rdt; u.px = u.x; u.py = u.y;
    u.walk = (u.walk || rand(0, 6)) + Math.min(u.spdNow, 500) * rdt * .1;
    const o = poseUnit(u);
    figure(u, o.H, o);
    if (u.team === 'E' && (u.st === 'wind' || u.st === 'rageWind') && !u.dying && u.stun <= 0) {
      const D = KIND[u.kind], rageW = u.st === 'rageWind';
      const k = rageW ? 1 - u.t : 1 - u.t / D.wind;
      const m = poolMesh(telePool, ti++, () => new THREE.Mesh(teleGeo.ashi, fxMat(new THREE.Color(0xff4a2a), .3, false)));
      if (rageW) { m.geometry = rageGeo; m.material.opacity = .15 + .35 * k; placeSector(m, u.x, 1.5, u.y, 0, TAU, 175); }
      else if (D.ranged) { m.geometry = teleGeo.archer; m.material.opacity = .12 + .2 * k; placeSector(m, u.x, 1.5, u.y, u.face - D.arc / 2, D.arc, 260); }
      else { m.geometry = teleGeo[u.kind]; m.material.opacity = .14 + .3 * k; placeSector(m, u.x, 1.5, u.y, u.face - D.arc / 2, D.arc, D.reach); }
    }
    if ((u.kind === 'officer' || u.kind === 'boss') && !u.dying) {
      const m = poolMesh(auraPool, ai++, () => new THREE.Mesh(auraGeo, fxMat(new THREE.Color(0xd4ae55), .6)));
      m.material.color.setHex(u.team === 'A' ? 0x6a9aff : u.kind === 'boss' ? 0xff4a30 : 0xd4ae55); m.material.opacity = .6;
      placeSector(m, u.x, 2, u.y, 0, TAU, u.r + 8 + Math.sin(G.t * 6) * 2);
    }
  }
  if (state === 'play' && (P.mu >= 100 || P.st === 'musou')) {
    const m = poolMesh(auraPool, ai++, () => new THREE.Mesh(auraGeo, fxMat(new THREE.Color(0xd4ae55), .6)));
    m.material.color.setHex(0xffd66e); m.material.opacity = P.st === 'musou' ? .9 : .4 + .3 * Math.sin(G.t * 8);
    placeSector(m, P.x, 2, P.y, 0, TAU, P.st === 'musou' ? P.mv.musou.range * .9 : P.r + 12);
  }
  for (let i = ti; i < telePool.length; i++) telePool[i].visible = false;
  for (let i = ai; i < auraPool.length; i++) auraPool[i].visible = false;
  // アイテム
  for (const it of G.items) {
    if (!inView(it.x, it.y)) continue;
    const bob = 14 + Math.sin(it.t * 5) * 4;
    if (it.type === 'sake') { ball([it.x, bob, it.y], 7, 0xc99a4a); ball([it.x, bob + 9, it.y], 4.5, 0xc99a4a); }
    else ball([it.x, bob, it.y], it.type === 'bigbun' ? 10 : 7, 0xf3ede0);
    blob(it.x, it.y, 8);
  }
  syncFx();
  for (const [mesh, n] of [[LIMB, nL], [BALL, nB], [CONE, nC], [BOX, nX], [SHADOW, nS]]) {
    mesh.count = n; mesh.instanceMatrix.needsUpdate = true;
    if (mesh.instanceColor) mesh.instanceColor.needsUpdate = true;
  }
  G.bases.forEach((b, i) => { if (baseFlagMats[i]) baseFlagMats[i].color.setHex(b.owner === 'E' ? 0xa3352a : 0x3f68b8); });

  let pn = 0;
  for (const p of G.parts) {
    if (pn >= PMAX) break;
    const a = 1 - p.t / p.life;
    if (p.ghost) { pPos[pn * 3] = p.x; pPos[pn * 3 + 1] = 20; pPos[pn * 3 + 2] = p.y; const c = styleColor(p.color); pCol[pn * 3] = c.r * a * .5; pCol[pn * 3 + 1] = c.g * a * .5; pCol[pn * 3 + 2] = c.b * a * .5; pn++; continue; }
    const c = styleColor(p.color);
    pPos[pn * 3] = p.x; pPos[pn * 3 + 1] = p.h; pPos[pn * 3 + 2] = p.y;
    pCol[pn * 3] = c.r * a; pCol[pn * 3 + 1] = c.g * a; pCol[pn * 3 + 2] = c.b * a; pn++;
  }
  pGeo.setDrawRange(0, pn); pGeo.attributes.position.needsUpdate = true; pGeo.attributes.color.needsUpdate = true;

  renderer.render(scene, camera);
  ctx.setTransform(DPR, 0, 0, DPR, 0, 0);
  ctx.clearRect(0, 0, VW, VH);
  if (state === 'play' || state === 'result') { drawLabels(); drawHUD(); }
}
