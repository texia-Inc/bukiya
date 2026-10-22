'use strict';

// ゲームの土台：描画・入力・UI・ステージの読み込み。
// ステージの中身は stages.js に書く。

const $ = sel => document.querySelector(sel);
const ROOM = 4;      // 部屋は x, z とも -4〜4
const WALL_H = 3;
const WALL_T = 0.2;

// ===================== 描画 =====================
const canvas = $('#scene');
const renderer = new THREE.WebGLRenderer({ canvas, antialias: true });
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
renderer.shadowMap.enabled = true;
renderer.shadowMap.type = THREE.PCFSoftShadowMap;

const scene = new THREE.Scene();
scene.background = new THREE.Color(0x2b2f36);

// 斜め見下ろし（アイソメトリック風）の平行投影カメラ
const camera = new THREE.OrthographicCamera(-1, 1, 1, -1, 0.1, 100);
camera.position.set(12, 11, 12);
camera.lookAt(0, 0.8, 0);

const hemiLight = new THREE.HemisphereLight(0xffffff, 0x9098a4, 0.75);
scene.add(hemiLight);
const sun = new THREE.DirectionalLight(0xffffff, 0.75);
sun.position.set(5, 12, 7);
sun.castShadow = true;
sun.shadow.mapSize.set(2048, 2048);
Object.assign(sun.shadow.camera, { left: -9, right: 9, top: 9, bottom: -9, near: 1, far: 40 });
sun.shadow.bias = -0.0005;
scene.add(sun);

// 部屋の明るさ（暗い部屋のステージ用）。ステージを読み込むたびに標準へ戻す
function setLighting({ hemi = 0.75, sun: sunI = 0.75, bg = 0x2b2f36 } = {}) {
  hemiLight.intensity = hemi;
  sun.intensity = sunI;
  scene.background.set(bg);
}

function resize() {
  const w = window.innerWidth, h = window.innerHeight;
  renderer.setSize(w, h);
  const aspect = w / h;
  const half = Math.max(5.2, 6.8 / aspect);   // 縦長の画面でも部屋全体が入るように
  const shift = half * 0.08;                  // 下のUIぶん、部屋を少し上に寄せる
  camera.left = -half * aspect;
  camera.right = half * aspect;
  camera.top = half - shift;
  camera.bottom = -half - shift;
  camera.updateProjectionMatrix();
}
window.addEventListener('resize', resize);
resize();

// ===================== 形を作るヘルパー =====================
function mat(color, extra) {
  return new THREE.MeshStandardMaterial(Object.assign({ color, roughness: 0.85, metalness: 0 }, extra));
}
function shade(mesh) { mesh.castShadow = true; mesh.receiveShadow = true; return mesh; }
function box(w, h, d, color, extra) {
  return shade(new THREE.Mesh(new THREE.BoxGeometry(w, h, d), mat(color, extra)));
}
function cyl(rTop, rBot, h, color, extra, seg = 24, open = false) {
  return shade(new THREE.Mesh(new THREE.CylinderGeometry(rTop, rBot, h, seg, 1, open), mat(color, extra)));
}
function ball(r, color, extra) {
  return shade(new THREE.Mesh(new THREE.SphereGeometry(r, 24, 16), mat(color, extra)));
}
function place(obj, x, y, z) { obj.position.set(x, y, z); return obj; }

// 2点を結ぶ細い棒（ロープや電線）
function rod(a, b, r, color) {
  const dir = new THREE.Vector3().subVectors(b, a);
  const m = cyl(r, r, dir.length(), color, {}, 8);
  m.position.copy(a).addScaledVector(dir, 0.5);
  m.quaternion.setFromUnitVectors(new THREE.Vector3(0, 1, 0), dir.normalize());
  return m;
}

// canvas に描いた絵を貼った板（+z 向き）。draw(ctx, 幅px, 高さpx)
function canvasPlane(w, h, draw) {
  const PX = 256;
  const cv = document.createElement('canvas');
  cv.width = Math.round(w * PX);
  cv.height = Math.round(h * PX);
  draw(cv.getContext('2d'), cv.width, cv.height);
  const tex = new THREE.CanvasTexture(cv);
  tex.anisotropy = 4;
  const m = new THREE.Mesh(new THREE.PlaneGeometry(w, h), new THREE.MeshStandardMaterial({ map: tex, roughness: 0.9 }));
  m.receiveShadow = true;
  return m;
}

// 文字を書いた板。改行で複数行
function textPlane(text, w, h, { bg = '#fdfdf8', fg = '#23272e' } = {}) {
  return canvasPlane(w, h, (g, W, H) => {
    g.fillStyle = bg;
    g.fillRect(0, 0, W, H);
    const lines = text.split('\n');
    let size = H / (lines.length * 1.35);
    const font = () => `800 ${size}px 'M PLUS Rounded 1c', sans-serif`;
    g.font = font();
    const widest = () => Math.max(...lines.map(l => g.measureText(l).width));
    while (widest() > W * 0.88) { size *= 0.9; g.font = font(); }
    g.fillStyle = fg;
    g.textAlign = 'center';
    g.textBaseline = 'middle';
    lines.forEach((ln, i) => g.fillText(ln, W / 2, H / 2 + (i - (lines.length - 1) / 2) * size * 1.2));
  });
}

// ===================== アニメーション =====================
const ease = {
  linear: t => t,
  inOut: t => (t < 0.5 ? 2 * t * t : 1 - Math.pow(-2 * t + 2, 2) / 2),
  out: t => 1 - Math.pow(1 - t, 3),
  in: t => t * t * t,
};
let tweens = [];
let updaters = [];

// fn(イージング済みの進み具合, 生の進み具合) を sec 秒間毎フレーム呼ぶ
function tween(sec, fn, e = ease.inOut) {
  return new Promise(resolve => tweens.push({ start: performance.now(), dur: sec * 1000, fn, e, resolve }));
}
const wait = sec => tween(sec, () => {});

function loop(now) {
  requestAnimationFrame(loop);
  tweens = tweens.filter(tw => {
    const p = Math.min(1, Math.max(0, (now - tw.start) / tw.dur));
    tw.fn(tw.e(p), p);
    if (p >= 1) { tw.resolve(); return false; }
    return true;
  });
  updaters.forEach(u => u(now / 1000));
  renderer.render(scene, camera);
}
requestAnimationFrame(loop);

// 小さな粒が飛び散る演出
function burst(pos, color, n = 18) {
  const g = new THREE.Group();
  current.root.add(g);
  const parts = [];
  for (let i = 0; i < n; i++) {
    const m = new THREE.Mesh(new THREE.SphereGeometry(0.06, 8, 6), mat(color, { transparent: true, opacity: 0.85 }));
    const a = Math.random() * Math.PI * 2, sp = 1.2 + Math.random() * 2;
    parts.push({ m, vx: Math.cos(a) * sp, vz: Math.sin(a) * sp, vy: 1 + Math.random() * 2.5 });
    g.add(m);
  }
  return tween(0.8, (e, t) => {
    parts.forEach(p => p.m.position.set(pos.x + p.vx * t, pos.y + p.vy * t - 4.9 * t * t, pos.z + p.vz * t));
  }, ease.linear).then(() => g.parent && g.parent.remove(g));
}

// ===================== 部屋とドア =====================
let targets = [];   // タップ判定の対象
let objects = {};   // id -> 調べられる物の定義

function buildRoom(root, o) {
  const S = ROOM, T = WALL_T, H = WALL_H;
  const floorMat = mat(o.floor);
  const addFloor = (x0, x1, z0, z1) => {
    if (x1 - x0 < 0.001 || z1 - z0 < 0.001) return;
    const m = shade(new THREE.Mesh(new THREE.BoxGeometry(x1 - x0, T, z1 - z0), floorMat));
    m.position.set((x0 + x1) / 2, -T / 2, (z0 + z1) / 2);
    m.userData.objId = '__floor';
    root.add(m);
    targets.push(m);
  };
  if (o.hole) {
    // 落とし穴用に床をくり抜き、下に真っ暗な穴を置く
    const { x0, x1, z0, z1 } = o.hole;
    addFloor(-S, x0, -S, S);
    addFloor(x1, S, -S, S);
    addFloor(x0, x1, -S, z0);
    addFloor(x0, x1, z1, S);
    const pit = new THREE.Mesh(new THREE.BoxGeometry(x1 - x0, 3, z1 - z0), new THREE.MeshBasicMaterial({ color: 0x0b0c0e }));
    root.add(place(pit, (x0 + x1) / 2, -T - 0.01 - 1.5, (z0 + z1) / 2));
  } else {
    addFloor(-S, S, -S, S);
  }

  const grid = new THREE.GridHelper(2 * S, 2 * S, o.line, o.line);
  grid.position.y = 0.003;
  grid.material.transparent = true;
  grid.material.opacity = 0.35;
  root.add(grid);

  // 左の壁（x = -4）
  root.add(place(box(T, H, 2 * S + T, o.wall), -S - T / 2, H / 2, -T / 2));
  root.add(place(box(0.03, 0.12, 2 * S, o.trim), -S + 0.015, 0.06, 0));

  // 奥の壁（z = -4）。ドアの所は穴をあけ、向こうに外の光を置く
  const bz = -S - T / 2;
  const backPiece = (x0, x1) => {
    if (x1 - x0 < 0.001) return;
    root.add(place(box(x1 - x0, H, T, o.wall), (x0 + x1) / 2, H / 2, bz));
    root.add(place(box(x1 - x0, 0.12, 0.03, o.trim), (x0 + x1) / 2, 0.06, -S + 0.015));
  };
  if (o.door) {
    const { x, w = 1.1, h = 2.2 } = o.door;
    backPiece(-S, x - w / 2);
    backPiece(x + w / 2, S);
    root.add(place(box(w, H - h, T, o.wall), x, h + (H - h) / 2, bz));
    const glow = new THREE.Mesh(new THREE.PlaneGeometry(w, h), new THREE.MeshBasicMaterial({ color: 0xfff6dc }));
    root.add(place(glow, x, h / 2, -S - T - 0.05));
  } else {
    backPiece(-S, S);
  }
}

// 奥の壁につくドア。pivot.rotation.y を増やすと外側へ開く
function buildDoor(x, color = 0x8a929e, w = 1.1, h = 2.2) {
  const frameColor = 0x5d6470;
  const g = place(new THREE.Group(), x, 0, -ROOM);
  g.add(place(box(0.08, h + 0.08, 0.3, frameColor), -w / 2 - 0.04, (h + 0.08) / 2, 0));
  g.add(place(box(0.08, h + 0.08, 0.3, frameColor), w / 2 + 0.04, (h + 0.08) / 2, 0));
  g.add(place(box(w + 0.16, 0.08, 0.3, frameColor), 0, h + 0.04, 0));
  const pivot = place(new THREE.Group(), -w / 2, 0, -0.1);
  pivot.add(place(box(w, h, 0.07, color), w / 2, h / 2, 0));
  pivot.add(place(ball(0.05, 0xd0d4da, { metalness: 0.6, roughness: 0.3 }), w - 0.12, 1.0, 0.06));
  g.add(pivot);
  return { group: g, pivot };
}

// ===================== 主人公 =====================
let player = null;

function createPlayer() {
  const root = new THREE.Group();
  const body = new THREE.Group();
  root.add(body);
  const shirt = place(cyl(0.24, 0.3, 0.55, 0xf08a4b), 0, 0.62, 0);
  const hair = new THREE.Mesh(new THREE.SphereGeometry(0.315, 24, 12, 0, Math.PI * 2, 0, Math.PI * 0.55), mat(0x3a2a22));
  body.add(
    place(cyl(0.22, 0.24, 0.35, 0x3d4452), 0, 0.18, 0),
    shirt,
    place(ball(0.3, 0xffdcb8), 0, 1.15, 0),
    place(shade(hair), 0, 1.17, -0.02),
    place(ball(0.04, 0x222222), -0.1, 1.15, 0.27),
    place(ball(0.04, 0x222222), 0.1, 1.15, 0.27),
  );
  // 開いた傘（使ったときだけ表示）
  const umbrella = new THREE.Group();
  umbrella.add(
    place(new THREE.Mesh(new THREE.ConeGeometry(0.8, 0.35, 16, 1, true), mat(0xe0474c, { side: THREE.DoubleSide })), 0, 1.95, 0),
    place(cyl(0.025, 0.025, 1.1, 0x333333), 0, 1.4, 0),
  );
  umbrella.position.set(0.22, 0, 0.05);
  umbrella.visible = false;
  body.add(umbrella);
  return { root, body, shirtMat: shirt.material, umbrella };
}

async function walkTo(x, z) {
  const p = player.root.position;
  const sx = p.x, sz = p.z, dx = x - sx, dz = z - sz;
  const dist = Math.hypot(dx, dz);
  if (dist < 0.05) return;
  player.root.rotation.y = Math.atan2(dx, dz);
  await tween(dist / 3.5, (e, t) => {
    p.x = sx + dx * t;
    p.z = sz + dz * t;
    player.body.position.y = Math.abs(Math.sin(t * dist * 6)) * 0.08;
  }, ease.linear);
  player.body.position.y = 0;
}

function face(x, z) {
  const p = player.root.position;
  player.root.rotation.y = Math.atan2(x - p.x, z - p.z);
}

// 奥のドアから外へ出ていく
async function exitThrough(x) {
  await walkTo(x, -3.4);
  await walkTo(x, -5.2);
  player.root.visible = false;
}

// ===================== UI =====================
let sayTimer = null;
function say(text) {
  clearInterval(sayTimer);
  const el = $('#message');
  const chars = Array.from(text);
  let i = 0;
  el.textContent = '';
  sayTimer = setInterval(() => {
    el.textContent = chars.slice(0, ++i).join('');
    if (i >= chars.length) clearInterval(sayTimer);
  }, 28);
}

let toastTimer = null;
function toast(text) {
  const el = $('#toast');
  el.textContent = text;
  el.classList.add('show');
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => el.classList.remove('show'), 1400);
}

function ripple(x, y) {
  const r = document.createElement('div');
  r.className = 'ripple';
  r.style.left = x + 'px';
  r.style.top = y + 'px';
  document.body.appendChild(r);
  setTimeout(() => r.remove(), 500);
}

// ----- 持ち物 -----
const SLOT_COUNT = 5;
let inventory = [];
let selectedItem = null;

function renderInventory() {
  const inv = $('#inventory');
  inv.innerHTML = '';
  for (let i = 0; i < SLOT_COUNT; i++) {
    const id = inventory[i];
    const slot = document.createElement('div');
    slot.className = 'slot';
    if (id) {
      slot.classList.add('filled');
      if (id === selectedItem) slot.classList.add('selected');
      slot.innerHTML = `<span class="icon">${ITEMS[id].icon}</span><span class="name">${ITEMS[id].name}</span>`;
      slot.addEventListener('pointerdown', e => startDrag(e, id));
    }
    inv.appendChild(slot);
  }
}
function addItem(id) {
  inventory.push(id);
  renderInventory();
  toast(`${ITEMS[id].icon} ${ITEMS[id].name} を手に入れた`);
}
function removeItem(id) {
  inventory = inventory.filter(i => i !== id);
  if (selectedItem === id) selectedItem = null;
  renderInventory();
}
const hasItem = id => inventory.includes(id);

// ----- テンキー -----
function keypad(len) {
  return new Promise(resolve => {
    const el = $('#keypad');
    const disp = el.querySelector('.display');
    let code = '';
    const update = () => { disp.textContent = code.padEnd(len, '_'); };
    const onClick = e => {
      const btn = e.target.closest('[data-k]');
      if (!btn) return;
      const k = btn.dataset.k;
      if (k === 'close') finish(null);
      else if (k === 'C') { code = ''; update(); }
      else if (k === 'OK') { if (code.length === len) finish(code); }
      else if (code.length < len) { code += k; update(); }
    };
    const finish = v => {
      el.classList.add('hidden');
      el.removeEventListener('click', onClick);
      resolve(v);
    };
    update();
    el.addEventListener('click', onClick);
    el.classList.remove('hidden');
  });
}

// ----- 結果画面 -----
function showResult(kind, big, sub, actions) {
  const el = $('#result');
  const panel = el.querySelector('.panel');
  panel.classList.remove('clear', 'fail');
  panel.classList.add(kind);
  panel.querySelector('.big').textContent = big;
  panel.querySelector('.sub').textContent = sub;
  const box = panel.querySelector('.actions');
  box.innerHTML = '';
  actions.forEach(a => {
    const b = document.createElement('button');
    b.type = 'button';
    b.className = 'primary';
    b.textContent = a.label;
    b.addEventListener('click', a.fn);
    box.appendChild(b);
  });
  el.classList.remove('hidden');
}

// ----- 進行状況の保存（使えない環境では保存しないだけ） -----
const SAVE_KEY = 'wanabeya.cleared';
function loadProgress() {
  try { return Number(localStorage.getItem(SAVE_KEY)) || 0; } catch (e) { return 0; }
}
function saveProgress(n) {
  try { if (n > loadProgress()) localStorage.setItem(SAVE_KEY, String(n)); } catch (e) { /* 保存できなくても遊べる */ }
}

// ===================== ステージ =====================
let current = null;
let busy = false;

function registerObj(id, mesh, def) {
  mesh.userData.objId = id;
  objects[id] = Object.assign(objects[id] || { id }, def, { mesh });
  if (!targets.includes(mesh)) targets.push(mesh);
  if (!mesh.parent) current.root.add(mesh);
}

function loadStage(index) {
  if (current) scene.remove(current.root);
  tweens = [];
  updaters = [];
  objects = {};
  targets = [];
  inventory = [];
  selectedItem = null;
  busy = false;
  $('#result').classList.add('hidden');
  $('#keypad').classList.add('hidden');
  setLighting();

  const def = STAGES[index];
  const root = new THREE.Group();
  scene.add(root);
  current = { index, def, root, state: {}, ended: false };

  player = createPlayer();
  root.add(player.root);
  registerObj('player', player.root, { onTap: async () => say('（自分だ。 …なんだか嫌な予感がする）') });

  $('#stageTitle').textContent = def.title;
  def.setup(api);
  renderInventory();
  say(def.intro);
}

async function clearStage() {
  current.ended = true;
  saveProgress(current.index + 1);
  await wait(0.3);
  const last = current.index === STAGES.length - 1;
  if (last) {
    showResult('clear', '回避成功！', `全${STAGES.length}ステージクリア！ おめでとう！`, [{ label: 'タイトルへ', fn: showTitle }]);
  } else {
    const next = current.index + 1;
    showResult('clear', '回避成功！', `${current.def.title} クリア`, [{ label: '次のステージへ ▶', fn: () => loadStage(next) }]);
  }
}

async function failStage(big, sub) {
  current.ended = true;
  await wait(0.5);
  const idx = current.index;
  showResult('fail', big, sub, [{ label: 'もう一度 ↺', fn: () => loadStage(idx) }]);
}

function showTitle() {
  $('#result').classList.add('hidden');
  const sel = $('#stageSelect');
  sel.innerHTML = '';
  const cleared = loadProgress();
  if (cleared > 0) {
    STAGES.forEach((st, i) => {
      if (i > cleared) return;
      const b = document.createElement('button');
      b.type = 'button';
      b.textContent = `STAGE ${i + 1}`;
      b.addEventListener('click', () => startGame(i));
      sel.appendChild(b);
    });
  }
  $('#title').classList.remove('hidden');
}

function startGame(index) {
  $('#title').classList.add('hidden');
  loadStage(index);
}

// ステージから使う機能
const api = {
  get state() { return current.state; },
  get root() { return current.root; },
  get player() { return player; },
  obj: registerObj,
  room: o => buildRoom(current.root, o),
  door: buildDoor,
  lighting: setLighting,
  say, addItem, removeItem, hasItem, keypad,
  walkTo, face, exitThrough,
  tween, wait, ease, burst,
  update: fn => updaters.push(fn),
  clear: clearStage,
  fail: failStage,
};

// ===================== 入力 =====================
const raycaster = new THREE.Raycaster();
const ndc = new THREE.Vector2();

function visibleChain(o) {
  for (; o; o = o.parent) if (!o.visible) return false;
  return true;
}

function pick(clientX, clientY) {
  const r = canvas.getBoundingClientRect();
  ndc.set(((clientX - r.left) / r.width) * 2 - 1, -((clientY - r.top) / r.height) * 2 + 1);
  raycaster.setFromCamera(ndc, camera);
  for (const h of raycaster.intersectObjects(targets, true)) {
    if (!visibleChain(h.object)) continue;
    let o = h.object;
    while (o && !o.userData.objId) o = o.parent;
    if (o) return { id: o.userData.objId, point: h.point };
  }
  return null;
}

const clamp = (v, a, b) => Math.min(b, Math.max(a, v));
const worldPos = new THREE.Vector3();

// 物を調べる / アイテムを使う。主人公がそこまで歩いてから実行する
async function interact(hit, itemId) {
  if (busy || !current || current.ended) return;
  busy = true;
  try {
    if (hit.id === '__floor') {
      if (itemId) return say(`${ITEMS[itemId].name}は ここでは使えないようだ。`);
      await walkTo(clamp(hit.point.x, -3.5, 3.5), clamp(hit.point.z, -3.5, 3.5));
      return;
    }
    const o = objects[hit.id];
    const stand = typeof o.stand === 'function' ? o.stand() : o.stand;
    if (stand) {
      await walkTo(stand[0], stand[1]);
      o.mesh.getWorldPosition(worldPos);
      face(worldPos.x, worldPos.z);
    }
    if (o.onArrive && !(await o.onArrive())) return;
    if (itemId) {
      const fn = o.onItem && o.onItem[itemId];
      if (fn) await fn();
      else say(`${ITEMS[itemId].name}は ここでは使えないようだ。`);
    } else if (o.onTap) {
      await o.onTap();
    }
  } finally {
    busy = false;
  }
}

// ----- 3D画面のタップ -----
let down = null;
canvas.addEventListener('pointerdown', e => { down = { x: e.clientX, y: e.clientY }; });
canvas.addEventListener('pointerup', e => {
  if (!down || drag) return;
  const moved = Math.hypot(e.clientX - down.x, e.clientY - down.y);
  down = null;
  if (moved > 10) return;
  ripple(e.clientX, e.clientY);
  const hit = pick(e.clientX, e.clientY);
  if (!hit) return;
  if (selectedItem) {
    const id = selectedItem;
    selectedItem = null;
    renderInventory();
    interact(hit, id);
  } else {
    interact(hit, null);
  }
});

// ----- 持ち物のドラッグ（タップなら選択→次のタップで使う） -----
const ghost = $('#ghost');
let drag = null;

function startDrag(e, id) {
  if (busy || !current || current.ended) return;
  e.preventDefault();
  drag = { id, x0: e.clientX, y0: e.clientY, moved: false };
  ghost.textContent = ITEMS[id].icon;
}

window.addEventListener('pointermove', e => {
  if (drag) {
    if (!drag.moved && Math.hypot(e.clientX - drag.x0, e.clientY - drag.y0) > 8) {
      drag.moved = true;
      ghost.classList.add('show');
    }
    if (drag.moved) ghost.style.transform = `translate(${e.clientX}px, ${e.clientY}px) translate(-50%, -60%)`;
  } else if (e.pointerType === 'mouse' && e.target === canvas) {
    const hit = pick(e.clientX, e.clientY);
    canvas.style.cursor = hit && hit.id !== '__floor' ? 'pointer' : 'default';
  }
});

window.addEventListener('pointerup', e => {
  if (!drag) return;
  const d = drag;
  drag = null;
  ghost.classList.remove('show');
  if (!d.moved) {
    selectedItem = selectedItem === d.id ? null : d.id;
    renderInventory();
    if (selectedItem) say(`${ITEMS[d.id].name}：使いたい場所をタップしよう。`);
    return;
  }
  const hit = pick(e.clientX, e.clientY);
  if (hit) interact(hit, d.id);
});

window.addEventListener('pointercancel', () => {
  drag = null;
  ghost.classList.remove('show');
});
