// ───────────── 基本ユーティリティ・入力・セーブ ─────────────
const TAU = Math.PI * 2;
const rand = (a, b) => a + Math.random() * (b - a);
const clamp = (v, a, b) => v < a ? a : v > b ? b : v;
const angDiff = (a, b) => { let d = (a - b) % TAU; if (d > Math.PI) d -= TAU; if (d < -Math.PI) d += TAU; return d; };
const turnToward = (cur, target, maxStep) => cur + clamp(angDiff(target, cur), -maxStep, maxStep);
const pick = arr => arr[Math.floor(Math.random() * arr.length)];
const $ = id => document.getElementById(id);
const COL = { paper: '#ece4d2', gold: '#d4ae55', enemy: '#a3352a', ally: '#3f68b8' };

const cvs = $('game'), hud = $('hud'), ctx = hud.getContext('2d');
let renderer = null, camera = null;
let VW = 0, VH = 0, DPR = 1;
function resize() {
  DPR = Math.min(2, window.devicePixelRatio || 1);
  VW = window.innerWidth; VH = window.innerHeight;
  hud.width = Math.round(VW * DPR); hud.height = Math.round(VH * DPR);
  hud.style.width = VW + 'px'; hud.style.height = VH + 'px';
  if (renderer) { renderer.setPixelRatio(DPR); renderer.setSize(VW, VH); camera.aspect = VW / VH; camera.updateProjectionMatrix(); }
}
window.addEventListener('resize', resize); resize();

// 画面状態: title / select / brief / play / result
let state = 'title', paused = false;

// ───────────── 入力 ─────────────
const keys = {}, pressed = {};
const isTouch = matchMedia('(pointer: coarse)').matches || 'ontouchstart' in window;
window.addEventListener('keydown', e => {
  const k = e.key.toLowerCase();
  if (!keys[k]) pressed[k] = true;
  keys[k] = true;
  if ([' ', 'arrowup', 'arrowdown', 'arrowleft', 'arrowright'].includes(k)) e.preventDefault();
  if ((k === 'p' || k === 'escape') && state === 'play') setPaused(!paused);
});
window.addEventListener('keyup', e => { keys[e.key.toLowerCase()] = false; });
window.addEventListener('blur', () => { for (const k in keys) keys[k] = false; if (state === 'play') setPaused(true); });

const touchAct = {};
const joy = { id: null, ox: 0, oy: 0, x: 0, y: 0 };
document.querySelectorAll('#pad .bt').forEach(b => {
  b.addEventListener('pointerdown', e => {
    e.preventDefault(); b.classList.add('on');
    const a = b.dataset.act;
    if (a === 'pause') { if (state === 'play') setPaused(!paused); return; }
    touchAct[a] = true;
  });
  const off = () => b.classList.remove('on');
  b.addEventListener('pointerup', off); b.addEventListener('pointercancel', off); b.addEventListener('pointerleave', off);
});
hud.addEventListener('pointerdown', e => {
  if (e.pointerType === 'mouse') return;
  if (e.clientX < VW * 0.55 && joy.id === null) { joy.id = e.pointerId; joy.ox = joy.x = e.clientX; joy.oy = joy.y = e.clientY; }
});
hud.addEventListener('pointermove', e => { if (e.pointerId === joy.id) { joy.x = e.clientX; joy.y = e.clientY; } });
const joyEnd = e => { if (e.pointerId === joy.id) joy.id = null; };
hud.addEventListener('pointerup', joyEnd); hud.addEventListener('pointercancel', joyEnd);

function moveVec() {
  let x = 0, y = 0;
  if (keys.a || keys.arrowleft) x -= 1;
  if (keys.d || keys.arrowright) x += 1;
  if (keys.w || keys.arrowup) y -= 1;
  if (keys.s || keys.arrowdown) y += 1;
  if (joy.id !== null) {
    const dx = joy.x - joy.ox, dy = joy.y - joy.oy, d = Math.hypot(dx, dy);
    if (d > 8) { const m = Math.min(1, d / 50); x = dx / d * m; y = dy / d * m; }
  }
  const l = Math.hypot(x, y);
  if (l > 1) { x /= l; y /= l; }
  return { x, y, len: Math.min(1, l) };
}
let act = {};
function readActions() {
  act = {
    attack: pressed.j || pressed.z || touchAct.attack,
    charge: pressed.k || pressed.x || touchAct.charge,
    musou: pressed.l || pressed.c || touchAct.musou,
    jump: pressed[' '] || touchAct.jump,
    dodge: pressed.shift || pressed.i || touchAct.dodge,
  };
}
function clearActions() { for (const k in pressed) pressed[k] = false; for (const k in touchAct) touchAct[k] = false; }

// ───────────── セーブ（この端末のブラウザに保存） ─────────────
const SAVE_KEY = 'tenka-issen-save-v2';
function loadSave() {
  try { const s = JSON.parse(localStorage.getItem(SAVE_KEY)); if (s && s.chars) return s; } catch (e) { /* 保存なし */ }
  return { chars: {}, cleared: {}, mute: false, lastChar: 'jin', lastStage: 0 };
}
const SAVE = loadSave();
function writeSave() { try { localStorage.setItem(SAVE_KEY, JSON.stringify(SAVE)); } catch (e) { /* 保存できない環境 */ } }
function charSave(id) { return SAVE.chars[id] || (SAVE.chars[id] = { lv: 1, exp: 0 }); }
const MAX_LV = 30;
const expNeed = lv => 60 + lv * 45;
