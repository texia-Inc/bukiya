// 群勢キャノン - 入力・ゲームループ・画面遷移
(function () {
  'use strict';

  const { Game, W } = self.CrowdSim;
  const LEVELS = self.CrowdLevels;
  const SAVE_KEY = 'crowd_cannon_unlocked';

  const $ = (id) => document.getElementById(id);
  const canvas = $('game');
  const stage = $('stage');
  const renderer = new self.CrowdRenderer(canvas);

  let game = null;
  let levelIndex = 0;
  let paused = true;
  let unlocked = loadUnlocked();

  function loadUnlocked() {
    try {
      const v = parseInt(localStorage.getItem(SAVE_KEY) || '1', 10);
      return Math.max(1, Math.min(LEVELS.length, v || 1));
    } catch (e) {
      return 1;
    }
  }
  function saveUnlocked(n) {
    unlocked = Math.max(unlocked, Math.min(LEVELS.length, n));
    try {
      localStorage.setItem(SAVE_KEY, String(unlocked));
    } catch (e) {
      /* 保存できない環境でも遊べるようにする */
    }
  }

  function resize() {
    const rect = stage.getBoundingClientRect();
    renderer.resize(rect.width, rect.height);
  }
  window.addEventListener('resize', resize);

  // ---- 画面 ----
  function show(id) {
    for (const el of document.querySelectorAll('.overlay')) el.hidden = el.id !== id;
  }

  function buildLevelList() {
    const list = $('levels');
    list.innerHTML = '';
    LEVELS.forEach((lv, i) => {
      const b = document.createElement('button');
      b.className = 'level';
      b.disabled = i + 1 > unlocked;
      b.innerHTML = `<span class="num">${i + 1}</span><span class="lname">${lv.name}</span>`;
      b.addEventListener('click', () => startLevel(i));
      list.appendChild(b);
    });
  }

  function startLevel(i) {
    levelIndex = i;
    game = new Game(LEVELS[i]);
    renderer.particles.length = 0;
    $('stageName').textContent = `ステージ${i + 1}  ${LEVELS[i].name}`;
    $('hint').textContent = LEVELS[i].hint;
    $('hint').classList.remove('fade');
    setTimeout(() => $('hint').classList.add('fade'), 4500);
    show(null);
    $('hud').hidden = false;
    paused = false;
    updateHud();
  }

  function finish(won) {
    paused = true;
    if (won) saveUnlocked(levelIndex + 2);
    $('resultTitle').textContent = won ? 'ステージクリア！' : '防衛失敗…';
    $('resultTitle').className = won ? 'win' : 'lose';
    $('resultStats').innerHTML =
      `倒した敵 <b>${game.kills.toLocaleString()}</b><br>` +
      `最大兵力 <b>${game.peakBlue.toLocaleString()}</b><br>` +
      `砦の耐久 <b>${game.baseHp}</b>`;
    const next = $('nextBtn');
    next.hidden = !won || levelIndex + 1 >= LEVELS.length;
    $('allClear').hidden = !(won && levelIndex + 1 >= LEVELS.length);
    show('result');
  }

  $('startBtn').addEventListener('click', () => startLevel(Math.min(unlocked, LEVELS.length) - 1));
  $('selectBtn').addEventListener('click', () => {
    buildLevelList();
    show('select');
  });
  $('backBtn').addEventListener('click', () => show('title'));
  $('retryBtn').addEventListener('click', () => startLevel(levelIndex));
  $('nextBtn').addEventListener('click', () => startLevel(levelIndex + 1));
  $('menuBtn').addEventListener('click', () => {
    $('hud').hidden = true;
    buildLevelList();
    show('select');
  });
  $('pauseBtn').addEventListener('click', (e) => {
    e.stopPropagation();
    if (!game || game.state !== 'playing') return;
    paused = true;
    game.firing = false;
    show('pause');
  });
  $('resumeBtn').addEventListener('click', () => {
    show(null);
    paused = false;
  });
  $('quitBtn').addEventListener('click', () => {
    $('hud').hidden = true;
    buildLevelList();
    show('select');
  });

  // ---- 入力: 押している間発射、左右ドラッグで砲台移動 ----
  function toWorldX(clientX) {
    const r = canvas.getBoundingClientRect();
    return ((clientX - r.left) / r.width) * W;
  }
  canvas.addEventListener('pointerdown', (e) => {
    if (!game || paused) return;
    canvas.setPointerCapture(e.pointerId);
    game.setTarget(toWorldX(e.clientX));
    game.firing = true;
  });
  canvas.addEventListener('pointermove', (e) => {
    if (!game || paused) return;
    if (e.pointerType === 'mouse' && e.buttons === 0) return;
    game.setTarget(toWorldX(e.clientX));
  });
  const stop = () => {
    if (game) game.firing = false;
  };
  canvas.addEventListener('pointerup', stop);
  canvas.addEventListener('pointercancel', stop);

  const keys = new Set();
  window.addEventListener('keydown', (e) => {
    if (!game || paused) return;
    keys.add(e.key);
    if (e.key === ' ') {
      game.firing = true;
      e.preventDefault();
    }
  });
  window.addEventListener('keyup', (e) => {
    keys.delete(e.key);
    if (e.key === ' ' && game) game.firing = false;
  });

  // ---- HUD ----
  let hudTimer = 0;
  function updateHud() {
    if (!game) return;
    $('blueCount').textContent = game.blue.n.toLocaleString();
    $('redCount').textContent = game.enemiesLeft.toLocaleString();
    const total = game.level.enemies.total;
    $('progressFill').style.width = `${(100 * (total - game.enemiesLeft)) / total}%`;
    $('baseHp').textContent = game.baseHp;
    $('baseFill').style.width = `${(100 * game.baseHp) / self.CrowdSim.CFG.baseHp}%`;
  }

  // ---- ループ（固定ステップ） ----
  const STEP = 1 / 60;
  let acc = 0;
  let last = performance.now();
  function frame(now) {
    const dt = Math.min(0.1, (now - last) / 1000);
    last = now;
    if (game && !paused) {
      const dir = (keys.has('ArrowRight') || keys.has('d') ? 1 : 0) - (keys.has('ArrowLeft') || keys.has('a') ? 1 : 0);
      if (dir) game.setTarget(game.cannon.targetX + dir * 260 * dt);
      acc += dt;
      let n = 0;
      while (acc >= STEP && n < 3) {
        game.step(STEP);
        acc -= STEP;
        n++;
      }
      if (n === 3) acc = 0;
      hudTimer -= dt;
      if (hudTimer <= 0) {
        updateHud();
        hudTimer = 0.1;
      }
      if (game.state !== 'playing') {
        updateHud();
        setTimeout(() => finish(game.state === 'won'), 700);
        paused = true;
      }
    }
    if (game) renderer.draw(game, dt);
    requestAnimationFrame(frame);
  }

  // タイトル画面の背景として、デモ盤面を表示
  resize();
  game = new Game(LEVELS[1], 7);
  show('title');
  $('hud').hidden = true;
  requestAnimationFrame(frame);
})();
