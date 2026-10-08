// ───────────── 画面遷移・武将選択・結果・メインループ ─────────────
let selChar = charById(SAVE.lastChar).id;
let selStage = clamp(SAVE.lastStage || 0, 0, STAGES.length - 1);
let builtStage = -1;
const stageUnlocked = i => i === 0 || !!SAVE.cleared[STAGES[i - 1].id];
const STAGE_NO = ['第一戦', '第二戦', '第三戦'];
const hex6 = n => '#' + n.toString(16).padStart(6, '0');

function monSvg(type, color) {
  const c = hex6(color);
  const petals = [0, 1, 2, 3, 4].map(i => { const a = i / 5 * TAU - Math.PI / 2; return `<circle cx="${20 + Math.cos(a) * 8}" cy="${20 + Math.sin(a) * 8}" r="6" fill="${c}"/>`; }).join('');
  const shapes = {
    circle: `<circle cx="20" cy="20" r="13" fill="none" stroke="${c}" stroke-width="3"/><circle cx="20" cy="20" r="5" fill="${c}"/>`,
    flower: petals + '<circle cx="20" cy="20" r="3" fill="#141a24"/>',
    diamond: `<path d="M20 5 L35 20 L20 35 L5 20Z" fill="none" stroke="${c}" stroke-width="3"/><path d="M20 13 L27 20 L20 27 L13 20Z" fill="${c}"/>`,
    moon: `<circle cx="20" cy="20" r="13" fill="${c}"/><circle cx="26" cy="16" r="11" fill="#141a24"/>`,
  };
  return `<svg class="mon" viewBox="0 0 40 40" aria-hidden="true"><circle cx="20" cy="20" r="19" fill="#141a24" stroke="rgba(236,228,210,.3)"/>${shapes[type]}</svg>`;
}
function faceHtml(name) {
  const n = name === '$P' ? charById(selChar).name : name;
  const st = (() => { const ch = CHARS.find(c => c.name === n); if (ch) return hex6(ch.col); const lk = OFFICER_LOOKS[n]; return lk ? lk.color : '#555'; })();
  return { n, color: st };
}
const esc = s => String(s).replace(/[&<>"]/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));

function showOnly(id) {
  for (const o of ['title', 'select', 'brief', 'result', 'pause']) $(o).hidden = o !== id;
  $('pad').hidden = !(isTouch && id === null);
}

function renderPicks() {
  $('charPicks').innerHTML = CHARS.map(c => {
    const cs = charSave(c.id);
    return `<button class="pick" data-char="${c.id}" aria-pressed="${c.id === selChar}">${monSvg(c.mon, c.crest)}<b>${esc(c.name)}</b><small>${esc(c.title)} ・ Lv ${cs.lv}</small></button>`;
  }).join('');
  $('stagePicks').innerHTML = STAGES.map((s, i) => {
    const ok = stageUnlocked(i), rank = SAVE.cleared[s.id];
    return `<button class="pick" data-stage="${i}" aria-pressed="${i === selStage}" ${ok ? '' : 'disabled'}><b>${STAGE_NO[i]}　${esc(s.name)}</b><span class="rank">${rank || ''}</span><small>${ok ? (rank ? '攻略済み' : '未攻略') : '前の合戦に勝つと出陣できる'}</small></button>`;
  }).join('');
  const ch = charById(selChar), cs = charSave(ch.id);
  $('selName').textContent = `${ch.name}　${ch.title}`;
  $('selLv').textContent = cs.lv >= MAX_LV ? `Lv ${cs.lv}（最大）` : `Lv ${cs.lv}　次のレベルまで ${expNeed(cs.lv) - cs.exp}`;
  $('selDesc').textContent = ch.desc + `　無双奥義「${MOVES[ch.weapon].musou.name}」`;
  document.querySelectorAll('#charPicks .pick').forEach(b => b.addEventListener('click', () => { selChar = b.dataset.char; renderPicks(); setupShowcase(); }));
  document.querySelectorAll('#stagePicks .pick').forEach(b => b.addEventListener('click', () => { selStage = +b.dataset.stage; renderPicks(); setupShowcase(); }));
}

// 武将選択画面：選んだ武将が技を披露する
const DEMO = ['attack', 'attack', 'attack', 'charge', null, 'attack', 'attack', 'attack', 'attack', 'attack', null, 'jump', 'charge', null, 'charge', null];
const DEMO_GAP = { attack: .2, charge: .9, jump: .25 };
function setupShowcase() {
  newGame(selStage, selChar);
  G.units = []; G.msgs = []; G.talk.q = []; G.events = [];
  P.x = STAGE.show.x; P.y = STAGE.show.y; P.face = Math.PI / 2 - .5; P.mu = 0;
  G.demo = { i: 0, t: .6, ax: P.x, ay: P.y };
  if (builtStage !== selStage) { buildStageVisuals(); builtStage = selStage; }
}
function updateShowcase(dt) {
  G.t += dt; buildGrid();
  const D = G.demo;
  act = {};
  D.t -= dt;
  if (D.t <= 0) {
    const a = DEMO[D.i % DEMO.length]; D.i++;
    if (a) act[a] = true;
    D.t = a ? DEMO_GAP[a] : 1.2;
    if (!a && P.st === 'idle') { P.x = D.ax; P.y = D.ay; }
  }
  updatePlayer(dt);
  if (P.st === 'idle') P.face = turnToward(P.face, Math.PI / 2 - .5, 3 * dt);
  updateProj(dt); updateRains(dt);
  for (const p of G.parts) { p.t += dt; p.x += p.vx * dt; p.y += p.vy * dt; p.vx *= .9; p.vy *= .9; p.h = Math.max(0, p.h + p.vh * dt); p.vh -= (p.grav || 700) * dt; }
  G.parts = G.parts.filter(p => p.t < p.life);
  for (const f of G.fx) f.t += dt; G.fx = G.fx.filter(f => f.t < f.life);
  for (const t of G.texts) t.t += dt; G.texts = G.texts.filter(t => t.t < t.life);
  G.shake = 0; G.zoom = 0; G.cutin = null; G.slowmo = 0;
}

function enterSelect() {
  state = 'select'; paused = false;
  showOnly('select'); renderPicks(); setupShowcase();
  bgmPlay('title');
}
function enterBrief() {
  if (!stageUnlocked(selStage)) return;
  SAVE.lastChar = selChar; SAVE.lastStage = selStage; writeSave();
  const s = STAGES[selStage];
  state = 'brief'; showOnly('brief');
  $('briefKicker').textContent = STAGE_NO[selStage];
  $('briefTitle').textContent = s.name;
  $('briefDesc').textContent = s.desc;
  $('briefTalk').innerHTML = s.brief.map(([name, text]) => {
    const f = faceHtml(name);
    return `<div class="say"><span class="face" style="background:${f.color}">${esc(f.n[0])}</span><div><b>${esc(f.n)}</b>${esc(text.replace(/\$P/g, charById(selChar).name))}</div></div>`;
  }).join('');
  $('startBtn').focus();
}
function startBattle() {
  initAudio();
  newGame(selStage, selChar);
  buildStageVisuals(); builtStage = selStage;
  state = 'play'; paused = false;
  showOnly(null); clearActions();
  bgmPlay('battle'); sfx.horn();
}
function setPaused(v) { paused = v; $('pause').hidden = !v; if (!v) clearActions(); }

function fmtTime(t) { const s = Math.floor(t); return `${Math.floor(s / 60)}:${String(s % 60).padStart(2, '0')}`; }
function finishBattle() {
  if (state !== 'play') return;
  const win = !!G.over.win;
  if (win) addExp(150 * (G.si + 1));
  let rank = 'C';
  if (win) {
    const score = G.ko * 2 + G.maxCombo - G.t / 3 + (G.morale + 100) * 2 + (G.missionOk || 0) * 40;
    rank = score > 1100 ? 'S' : score > 700 ? 'A' : 'B';
    const prev = SAVE.cleared[STAGE.id];
    if (!prev || 'SABC'.indexOf(rank) < 'SABC'.indexOf(prev)) SAVE.cleared[STAGE.id] = rank;
  }
  writeSave();
  state = 'result';
  const cs = charSave(P.char.id);
  $('resTitle').textContent = win ? '勝利' : '敗北';
  $('resTitle').className = win ? 'win' : 'lose';
  $('resKicker').textContent = `${STAGE_NO[G.si]} ・ ${STAGE.name}`;
  $('resLead').textContent = win ? `${G.boss.name}を討ち取った。最大 ${G.maxCombo} 連撃。` : `${G.over.reason || '敗走'}。最大 ${G.maxCombo} 連撃。`;
  $('sKo').textContent = G.ko; $('sTime').textContent = fmtTime(G.t); $('sRank').textContent = rank;
  $('resExp').textContent = `経験値 +${G.expGain}　${P.char.name} Lv ${cs.lv}` + (G.lvUps ? `（${G.lvUps} レベル上がった）` : '');
  const hasNext = win && G.si + 1 < STAGES.length;
  $('nextBtn').hidden = !hasNext;
  showOnly('result');
  (hasNext ? $('nextBtn') : $('againBtn')).focus();
  bgmPlay(win ? 'win' : 'lose');
}

$('toSelect').addEventListener('click', () => { initAudio(); enterSelect(); });
$('backTitle').addEventListener('click', () => { state = 'title'; showOnly('title'); });
$('toBrief').addEventListener('click', enterBrief);
$('briefBack').addEventListener('click', enterSelect);
$('startBtn').addEventListener('click', startBattle);
$('againBtn').addEventListener('click', startBattle);
$('nextBtn').addEventListener('click', () => { selStage = Math.min(STAGES.length - 1, G.si + 1); enterBrief(); });
$('resSelect').addEventListener('click', enterSelect);
$('resumeBtn').addEventListener('click', () => setPaused(false));
$('retreatBtn').addEventListener('click', () => { paused = false; enterSelect(); });
$('muteBtn1').addEventListener('click', toggleMute);
$('muteBtn2').addEventListener('click', toggleMute);
document.addEventListener('visibilitychange', () => { if (document.hidden && state === 'play') setPaused(true); });
applyMute();

// ───────────── 起動・メインループ ─────────────
newGame(0, selChar);
P.x = 1450; P.y = 1500; G.msgs = []; G.talk.q = [];
buildStageVisuals(); builtStage = 0;
let lastT = performance.now();
function loop(t) {
  const rdt = Math.min(.05, (t - lastT) / 1000); lastT = t;
  if (state === 'play' && !paused) {
    readActions();
    let dt = Math.min(.033, rdt);
    if (G.slowmo > 0) { G.slowmo -= dt; dt *= .3; }
    if (G.hitstop > 0) G.hitstop -= dt;
    else { update(dt); clearActions(); }
  } else if (state === 'select' || state === 'brief') {
    updateShowcase(Math.min(.033, rdt));
  }
  render();
  requestAnimationFrame(loop);
}
requestAnimationFrame(loop);

// 動作確認用（URL の末尾が #debug のときだけ有効）
if (location.hash === '#debug') window.TK = { get G() { return G; }, get P() { return P; }, update, pressed, readActions, setSel: (c, s) => { selChar = c; selStage = s; }, startBattle, enterSelect, STAGES, get state() { return state; }, camera };
