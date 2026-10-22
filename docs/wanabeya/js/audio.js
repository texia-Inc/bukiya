'use strict';

// 効果音と BGM。音声ファイルは使わず、Web Audio API でその場で合成する。
// ブラウザの制限で、最初のタップ・クリックまでは音が出ない。

const Sound = (() => {
  const SAVE_KEY = 'wanabeya.muted';
  let muted = false;
  try { muted = localStorage.getItem(SAVE_KEY) === '1'; } catch (e) { /* 保存できない環境でも鳴らせる */ }

  let ctx = null, master, sfxBus, musicBus, noiseBuf;

  function init() {
    if (ctx) {
      if (ctx.state === 'suspended') ctx.resume();
      return;
    }
    const AC = window.AudioContext || window.webkitAudioContext;
    if (!AC) return;
    ctx = new AC();
    master = ctx.createGain();
    master.gain.value = muted ? 0 : 1;
    master.connect(ctx.destination);
    sfxBus = ctx.createGain();
    sfxBus.gain.value = 0.7;
    sfxBus.connect(master);
    musicBus = ctx.createGain();
    musicBus.gain.value = 0.18;
    musicBus.connect(master);
    noiseBuf = ctx.createBuffer(1, ctx.sampleRate, ctx.sampleRate);
    const d = noiseBuf.getChannelData(0);
    for (let i = 0; i < d.length; i++) d[i] = Math.random() * 2 - 1;
    if (wantMood) startMusic(wantMood);
  }
  ['pointerdown', 'keydown'].forEach(ev => window.addEventListener(ev, init, true));

  // ---------- 音の部品 ----------
  // freq は数値か [開始, 終了]（終了へ向けて音程が変わる）
  function tone(freq, dur, { type = 'sine', vol = 0.3, at = 0, attack = 0.005, bus = sfxBus, filter } = {}) {
    const t = ctx.currentTime + Math.max(0, at);
    const [f0, f1] = Array.isArray(freq) ? freq : [freq, freq];
    const o = ctx.createOscillator();
    o.type = type;
    o.frequency.setValueAtTime(f0, t);
    if (f1 !== f0) o.frequency.exponentialRampToValueAtTime(Math.max(1, f1), t + dur);
    const g = ctx.createGain();
    g.gain.setValueAtTime(0.0001, t);
    g.gain.exponentialRampToValueAtTime(vol, t + attack);
    g.gain.exponentialRampToValueAtTime(0.0001, t + dur);
    let out = o;
    if (filter) {
      const f = ctx.createBiquadFilter();
      f.type = filter.type || 'lowpass';
      f.frequency.value = filter.freq;
      f.Q.value = filter.q || 1;
      o.connect(f);
      out = f;
    }
    out.connect(g);
    g.connect(bus);
    o.start(t);
    o.stop(t + dur + 0.05);
    return o;
  }

  function noise(dur, { vol = 0.3, at = 0, type = 'lowpass', freq = 1000, freqTo, q = 1, attack = 0.003, bus = sfxBus } = {}) {
    const t = ctx.currentTime + Math.max(0, at);
    const src = ctx.createBufferSource();
    src.buffer = noiseBuf;
    src.loop = true;
    const f = ctx.createBiquadFilter();
    f.type = type;
    f.Q.value = q;
    f.frequency.setValueAtTime(freq, t);
    if (freqTo) f.frequency.exponentialRampToValueAtTime(freqTo, t + dur);
    const g = ctx.createGain();
    g.gain.setValueAtTime(0.0001, t);
    g.gain.exponentialRampToValueAtTime(vol, t + attack);
    g.gain.exponentialRampToValueAtTime(0.0001, t + dur);
    src.connect(f);
    f.connect(g);
    g.connect(bus);
    src.start(t, Math.random() * 0.5);
    src.stop(t + dur + 0.05);
  }

  // ---------- 効果音 ----------
  const SFX = {
    // UI
    tap: () => tone(1100, 0.05, { type: 'triangle', vol: 0.06 }),
    step: () => noise(0.06, { vol: 0.06, freq: 500 }),
    get: () => [784, 988, 1319].forEach((f, i) => tone(f, 0.18, { type: 'triangle', vol: 0.18, at: i * 0.07 })),
    nope: () => {
      tone(260, 0.1, { type: 'square', vol: 0.05 });
      tone(200, 0.14, { type: 'square', vol: 0.05, at: 0.11 });
    },
    beep: () => tone(1250, 0.07, { type: 'square', vol: 0.05 }),
    unlock: () => {
      tone(988, 0.08, { type: 'square', vol: 0.05 });
      tone(1319, 0.14, { type: 'square', vol: 0.05, at: 0.09 });
      noise(0.05, { vol: 0.25, type: 'highpass', freq: 2500, at: 0.25 });
    },
    buzzer: () => tone(130, 0.4, { type: 'sawtooth', vol: 0.12, filter: { freq: 900 } }),

    // 物音
    click: () => noise(0.03, { vol: 0.25, type: 'highpass', freq: 3000 }),
    drawer: () => noise(0.28, { vol: 0.18, type: 'bandpass', freq: 900, freqTo: 500, q: 2, attack: 0.05 }),
    door: () => {
      tone([180, 260], 0.45, { type: 'sawtooth', vol: 0.04, filter: { freq: 700, q: 6 } });
      noise(0.4, { vol: 0.1, type: 'bandpass', freq: 600, freqTo: 300, q: 3, attack: 0.1 });
    },
    clunk: () => {
      tone([300, 120], 0.12, { type: 'square', vol: 0.12, filter: { freq: 800 } });
      noise(0.06, { vol: 0.3, freq: 900 });
    },
    whoosh: () => noise(0.3, { vol: 0.2, type: 'bandpass', freq: 400, freqTo: 2400, q: 1.5, attack: 0.12 }),
    rumble: () => noise(1.4, { vol: 0.4, freq: 160, attack: 0.2 }),
    rustle: () => noise(0.4, { vol: 0.15, type: 'highpass', freq: 2500, attack: 0.1 }),
    snip: () => {
      noise(0.04, { vol: 0.35, type: 'highpass', freq: 4000 });
      noise(0.04, { vol: 0.35, type: 'highpass', freq: 5000, at: 0.08 });
    },
    ticks: () => {
      for (let i = 0; i < 36; i++) noise(0.02, { vol: 0.12, type: 'highpass', freq: 3500, at: i * 0.05 * (1 + i / 40) });
    },
    ding: () => tone(1568, 0.8, { vol: 0.15 }),
    sparkle: () => [1568, 2093, 2637, 3136].forEach((f, i) => tone(f, 0.25, { type: 'triangle', vol: 0.06, at: i * 0.05 })),
    whirr: () => tone([200, 600], 0.4, { type: 'sawtooth', vol: 0.05, filter: { freq: 900, q: 4 } }),
    crackle: () => noise(0.05, { vol: 0.06, type: 'highpass', freq: 4000 }),
    bark: () => [0, 0.2].forEach(at => tone([620, 380], 0.13, { type: 'sawtooth', vol: 0.18, at, filter: { freq: 1400, q: 2 } })),
    pop: () => [0, 0.08, 0.15, 0.25, 0.31].forEach(at => noise(0.05, { vol: 0.3, type: 'bandpass', freq: 1500 + Math.random() * 1500, q: 2, at })),

    // ワナのリアクション
    splash: () => {
      noise(0.7, { vol: 0.45, freq: 3000, freqTo: 300 });
      tone([400, 120], 0.25, { vol: 0.2 });
    },
    clang: () => {
      [523, 1287, 2103, 2840].forEach((f, i) => tone(f, 1.3 - i * 0.2, { vol: 0.2 / (i + 1) }));
      noise(0.08, { vol: 0.35, type: 'highpass', freq: 1500 });
    },
    bonk: () => {
      tone([220, 60], 0.25, { vol: 0.5 });
      noise(0.06, { vol: 0.3, freq: 1200 });
    },
    thud: () => {
      tone([140, 45], 0.3, { vol: 0.5 });
      noise(0.12, { vol: 0.25, freq: 400 });
    },
    slip: () => tone([300, 1400], 0.25, { type: 'triangle', vol: 0.15 }),
    fall: () => tone([1200, 150], 1.0, { vol: 0.18 }),
    crash: () => {
      noise(0.35, { vol: 0.4, freq: 1800, freqTo: 200 });
      tone([90, 40], 0.4, { vol: 0.4 });
    },
    zap: () => {
      for (let i = 0; i < 24; i++) tone(200 + Math.random() * 1800, 0.04, { type: 'sawtooth', vol: 0.07, at: i * 0.04 });
      noise(1.0, { vol: 0.15, type: 'highpass', freq: 3000 });
    },
    boing: () => {
      const t = ctx.currentTime;
      const o = ctx.createOscillator(), g = ctx.createGain(), lfo = ctx.createOscillator(), depth = ctx.createGain();
      o.frequency.setValueAtTime(150, t);
      o.frequency.exponentialRampToValueAtTime(500, t + 0.12);
      o.frequency.exponentialRampToValueAtTime(250, t + 0.7);
      lfo.frequency.value = 18;
      depth.gain.value = 60;
      lfo.connect(depth);
      depth.connect(o.frequency);
      g.gain.setValueAtTime(0.0001, t);
      g.gain.exponentialRampToValueAtTime(0.35, t + 0.02);
      g.gain.exponentialRampToValueAtTime(0.0001, t + 0.75);
      o.connect(g);
      g.connect(sfxBus);
      o.start(t);
      lfo.start(t);
      o.stop(t + 0.8);
      lfo.stop(t + 0.8);
    },
    snap: () => {
      noise(0.05, { vol: 0.6, type: 'highpass', freq: 2500 });
      tone([2000, 500], 0.06, { type: 'square', vol: 0.1 });
    },
    splat: () => {
      noise(0.35, { vol: 0.45, freq: 1200, freqTo: 200 });
      tone([260, 70], 0.2, { vol: 0.3 });
    },

    // ジングル
    clear: () => {
      [523, 659, 784, 1047].forEach((f, i) => tone(f, 0.2, { type: 'square', vol: 0.06, at: i * 0.1, filter: { freq: 3000 } }));
      [523, 659, 784, 1047].forEach(f => tone(f, 0.9, { type: 'triangle', vol: 0.1, at: 0.45 }));
    },
    fail: () => {
      [[392, 0, 0.3], [370, 0.35, 0.3], [349, 0.7, 0.3], [330, 1.05, 0.9]].forEach(([f, at, d]) => {
        tone(f, d, { type: 'sawtooth', vol: 0.12, at, attack: 0.03, filter: { freq: 900, q: 3 } });
      });
    },
  };

  // ---------- BGM（8分音符ごとに少し先まで予約して鳴らす） ----------
  const _ = null;
  const BASS = [45, _, 52, _, 45, _, 52, _, 41, _, 48, _, 41, _, 48, _, 38, _, 45, _, 38, _, 45, _, 40, _, 47, _, 40, 44, 47, _];
  const MELODY = [76, _, _, 72, 74, _, 76, _, 77, _, 76, _, 74, _, 72, _, 74, _, _, 77, 76, _, 74, _, 71, _, 68, _, 71, _, _, _];
  const MOODS = {
    normal: { bpm: 104, melody: true, hat: true },
    dark: { bpm: 72, melody: false, hat: false, bell: true },
    final: { bpm: 126, melody: true, hat: true },
  };
  const mtof = n => 440 * Math.pow(2, (n - 69) / 12);

  let timer = null, mood = null, wantMood = null, step = 0, nextTime = 0;

  function schedule() {
    const m = MOODS[mood];
    const eighth = 60 / m.bpm / 2;
    while (nextTime < ctx.currentTime + 0.3) {
      const i = step % BASS.length;
      const at = nextTime - ctx.currentTime;
      if (BASS[i]) tone(mtof(BASS[i] - (m.bell ? 12 : 0)), eighth * 1.6, { type: 'triangle', vol: 0.5, at, bus: musicBus });
      if (m.melody && MELODY[i]) {
        tone(mtof(MELODY[i]), eighth * 1.8, { vol: 0.32, at, bus: musicBus });
        tone(mtof(MELODY[i] + 12), eighth, { type: 'triangle', vol: 0.05, at, bus: musicBus });
      }
      if (m.hat && i % 2 === 1) noise(0.03, { vol: 0.07, type: 'highpass', freq: 7000, at, bus: musicBus });
      if (m.bell && i % 8 === 4 && Math.random() < 0.6) tone(mtof(MELODY[(i + 12) % 32] || 76), 1.6, { vol: 0.1, at, bus: musicBus });
      nextTime += eighth;
      step++;
    }
  }

  function startMusic(name) {
    wantMood = name;
    if (!ctx) return;
    if (timer && mood === name) return;
    clearInterval(timer);
    mood = name;
    step = 0;
    nextTime = ctx.currentTime + 0.1;
    timer = setInterval(schedule, 60);
  }

  function stopMusic() {
    wantMood = null;
    mood = null;
    clearInterval(timer);
    timer = null;
  }

  return {
    sfx(name) {
      if (!ctx || muted || !SFX[name]) return;
      SFX[name]();
    },
    music: startMusic,
    stopMusic,
    get muted() { return muted; },
    toggle() {
      muted = !muted;
      try { localStorage.setItem(SAVE_KEY, muted ? '1' : '0'); } catch (e) { /* 保存できなくても切り替えは効く */ }
      if (master) master.gain.setTargetAtTime(muted ? 0 : 1, ctx.currentTime, 0.05);
      return muted;
    },
  };
})();
