// ───────────── 音（WebAudio で合成。音源ファイルなし） ─────────────
let AC = null, master = null, sfxBus = null, bgmBus = null, noiseBuf = null, lastHitSfx = 0;
function initAudio() {
  try {
    if (!AC) {
      AC = new (window.AudioContext || window.webkitAudioContext)();
      master = AC.createGain(); master.connect(AC.destination);
      const comp = AC.createDynamicsCompressor(); comp.connect(master);
      sfxBus = AC.createGain(); sfxBus.gain.value = .9; sfxBus.connect(comp);
      bgmBus = AC.createGain(); bgmBus.gain.value = .3; bgmBus.connect(comp);
      const len = AC.sampleRate;
      noiseBuf = AC.createBuffer(1, len, AC.sampleRate);
      const d = noiseBuf.getChannelData(0);
      for (let i = 0; i < len; i++) d[i] = Math.random() * 2 - 1;
    }
    AC.resume(); applyMute();
  } catch (e) { AC = null; }
}
function applyMute() {
  if (master) master.gain.value = SAVE.mute ? 0 : .8;
  for (const id of ['muteBtn1', 'muteBtn2']) { const b = $(id); if (b) b.textContent = SAVE.mute ? '音：オフ' : '音：オン'; }
}
function toggleMute() { SAVE.mute = !SAVE.mute; writeSave(); initAudio(); applyMute(); }

function noise(t, dur, freq, q, gain, type = 'bandpass', dest = sfxBus) {
  if (!AC) return;
  const src = AC.createBufferSource(); src.buffer = noiseBuf;
  const f = AC.createBiquadFilter(); f.type = type; f.frequency.value = freq; f.Q.value = q;
  const g = AC.createGain(); g.gain.setValueAtTime(gain, t); g.gain.exponentialRampToValueAtTime(.001, t + dur);
  src.connect(f); f.connect(g); g.connect(dest);
  src.start(t, Math.random() * .5); src.stop(t + dur + .05);
}
function osc(t, type, f0, f1, dur, gain, dest = sfxBus, attack = .005) {
  if (!AC) return;
  const o = AC.createOscillator(), g = AC.createGain();
  o.type = type; o.frequency.setValueAtTime(f0, t); o.frequency.exponentialRampToValueAtTime(Math.max(20, f1), t + dur);
  g.gain.setValueAtTime(0.0001, t); g.gain.linearRampToValueAtTime(gain, t + attack); g.gain.exponentialRampToValueAtTime(.001, t + dur);
  o.connect(g); g.connect(dest); o.start(t); o.stop(t + dur + .05);
}
const now = () => AC ? AC.currentTime : 0;
const sfx = {
  swing() { noise(now(), .09, 2600, 1.1, .14, 'highpass'); },
  heavy() { const t = now(); noise(t, .2, 700, .8, .25); osc(t, 'sine', 180, 70, .2, .15); },
  hit() { const n = performance.now(); if (n - lastHitSfx < 45) return; lastHitSfx = n; const t = now(); noise(t, .08, 900, 1.4, .28); osc(t, 'sine', 170, 55, .09, .2); },
  guard() { const t = now(); osc(t, 'triangle', 1400, 1200, .12, .12); noise(t, .05, 4000, 3, .1); },
  big() { const t = now(); osc(t, 'triangle', 120, 32, .5, .45); noise(t, .4, 280, .7, .4, 'lowpass'); },
  hurt() { osc(now(), 'square', 220, 90, .16, .16); },
  jump() { osc(now(), 'sine', 260, 520, .12, .08); },
  land() { const t = now(); noise(t, .15, 400, .8, .25, 'lowpass'); osc(t, 'sine', 120, 40, .18, .25); },
  arrow() { const t = now(); osc(t, 'triangle', 900, 300, .1, .09); noise(t, .08, 3000, 2, .08, 'highpass'); },
  boom() { const t = now(); osc(t, 'sawtooth', 90, 25, .6, .35); noise(t, .6, 500, .5, .5, 'lowpass'); },
  item() { const t = now(); osc(t, 'triangle', 880, 1760, .14, .12); osc(t + .08, 'triangle', 1320, 2000, .14, .1); },
  levelup() { const t = now(); [0, 4, 7, 12].forEach((s, i) => osc(t + i * .09, 'triangle', 523 * Math.pow(2, s / 12), 523 * Math.pow(2, s / 12), .3, .14)); },
  musou() { const t = now(); osc(t, 'sine', 98, 96, 1.8, .4, sfxBus, .02); osc(t, 'sine', 196.5, 195, 1.4, .2, sfxBus, .02); noise(t, .9, 1200, .5, .25); osc(t + .05, 'sawtooth', 220, 880, .45, .12); },
  // 法螺貝（砦制圧・合戦開始）
  horn() {
    if (!AC) return;
    const t = now(), o = AC.createOscillator(), g = AC.createGain(), f = AC.createBiquadFilter(), lfo = AC.createOscillator(), lg = AC.createGain();
    o.type = 'sawtooth'; o.frequency.setValueAtTime(140, t); o.frequency.linearRampToValueAtTime(155, t + .3); o.frequency.linearRampToValueAtTime(150, t + 1.3);
    lfo.frequency.value = 5; lg.gain.value = 3; lfo.connect(lg); lg.connect(o.frequency);
    f.type = 'lowpass'; f.frequency.value = 900; f.Q.value = 4;
    g.gain.setValueAtTime(.0001, t); g.gain.linearRampToValueAtTime(.22, t + .2); g.gain.setValueAtTime(.22, t + 1.1); g.gain.exponentialRampToValueAtTime(.001, t + 1.5);
    o.connect(f); f.connect(g); g.connect(sfxBus); o.start(t); lfo.start(t); o.stop(t + 1.6); lfo.stop(t + 1.6);
  },
};

// ───────────── BGM（都節音階・太鼓と三味線と笛） ─────────────
const MIYAKO = [0, 1, 5, 7, 8];
const nf = (deg, base = 146.83) => { const o = Math.floor(deg / 5), i = ((deg % 5) + 5) % 5; return base * Math.pow(2, o + MIYAKO[i] / 12); };
function taiko(t, g) { osc(t, 'sine', 120, 42, .4, .55 * g, bgmBus, .003); noise(t, .1, 180, .7, .25 * g, 'lowpass', bgmBus); }
function shime(t, g) { noise(t, .05, 2200, 1.5, .22 * g, 'bandpass', bgmBus); }
function pluck(t, f, dur, g) {
  if (!AC) return;
  const o = AC.createOscillator(), o2 = AC.createOscillator(), fl = AC.createBiquadFilter(), gn = AC.createGain();
  o.type = 'sawtooth'; o2.type = 'square'; o.frequency.setValueAtTime(f * 1.01, t); o.frequency.exponentialRampToValueAtTime(f, t + .03); o2.frequency.value = f * 2.003;
  fl.type = 'lowpass'; fl.frequency.setValueAtTime(4200, t); fl.frequency.exponentialRampToValueAtTime(500, t + dur); fl.Q.value = 2;
  gn.gain.setValueAtTime(.0001, t); gn.gain.linearRampToValueAtTime(.16 * g, t + .004); gn.gain.exponentialRampToValueAtTime(.001, t + dur);
  o.connect(fl); o2.connect(fl); fl.connect(gn); gn.connect(bgmBus); o.start(t); o2.start(t); o.stop(t + dur + .05); o2.stop(t + dur + .05);
}
function flute(t, f, dur, g) {
  if (!AC) return;
  const o = AC.createOscillator(), gn = AC.createGain(), lfo = AC.createOscillator(), lg = AC.createGain();
  o.type = 'sine'; o.frequency.setValueAtTime(f * .97, t); o.frequency.linearRampToValueAtTime(f, t + .08);
  lfo.frequency.value = 5.2; lg.gain.setValueAtTime(0, t); lg.gain.linearRampToValueAtTime(f * .012, t + dur * .6); lfo.connect(lg); lg.connect(o.frequency);
  gn.gain.setValueAtTime(.0001, t); gn.gain.linearRampToValueAtTime(.12 * g, t + .07); gn.gain.setValueAtTime(.12 * g, t + dur * .8); gn.gain.exponentialRampToValueAtTime(.001, t + dur);
  o.connect(gn); gn.connect(bgmBus); o.start(t); lfo.start(t); o.stop(t + dur + .05); lfo.stop(t + dur + .05);
  noise(t, .12, 2500, 1, .03 * g, 'bandpass', bgmBus);
}
function koto(t, f, g) { osc(t, 'triangle', f, f, 1.2, .14 * g, bgmBus, .003); osc(t, 'sine', f * 2, f * 2, .6, .05 * g, bgmBus, .003); }

// 旋律: [開始ステップ, 音階度数, 長さ(ステップ)]
const MELODY_A = [[0, 7, 4], [4, 9, 2], [6, 8, 2], [8, 7, 4], [12, 5, 4], [16, 7, 2], [18, 8, 2], [20, 9, 4], [24, 10, 6], [32, 9, 4], [36, 8, 2], [38, 7, 2], [40, 5, 4], [44, 4, 4], [48, 5, 2], [50, 7, 2], [52, 5, 4], [56, 4, 8]];
const MELODY_B = [[0, 10, 2], [2, 9, 2], [4, 10, 4], [8, 12, 4], [12, 11, 2], [14, 10, 2], [16, 9, 6], [24, 7, 4], [28, 8, 4], [32, 9, 2], [34, 10, 2], [36, 12, 4], [40, 11, 4], [44, 10, 4], [48, 9, 4], [52, 8, 2], [54, 7, 2], [56, 5, 8]];
const BASS = [0, 0, 4, 0, 3, 0, 2, 1];
const TRACKS = {
  title: {
    bpm: 76, play(s, t, spb) {
      const bar = s % 64;
      if (bar % 4 === 0) koto(t, nf([0, 2, 4, 5, 7, 5, 4, 2][(s / 4) % 8 | 0], 146.83), .9);
      if (bar === 0 || bar === 32) taiko(t, .6);
      for (const [st, d, l] of MELODY_A) if (st === bar && (s % 128) >= 64) flute(t, nf(d, 146.83), l * spb * 1.1, .9);
    },
  },
  battle: {
    bpm: 138, play(s, t, spb) {
      const st = s % 16, bar = s % 64, I = BGM.intensity;
      if ([0, 3, 6, 8, 10, 12].includes(st)) taiko(t, st === 0 ? 1 : .7);
      if (I > 0 && st % 2 === 1) taiko(t, .35);
      if (st % 4 === 2) shime(t, .8);
      if (bar >= 60) shime(t, .6);
      if (st % 2 === 0) pluck(t, nf(BASS[(st / 2) % 8], 73.42 * 2), .22, .9);
      const mel = (s % 128) < 64 ? MELODY_A : MELODY_B;
      for (const [s0, d, l] of mel) if (s0 === bar) { flute(t, nf(d), l * spb, .8); if (I > 0) pluck(t, nf(d + 5), .25, .5); }
    },
  },
  boss: {
    bpm: 152, play(s, t, spb) {
      const st = s % 16, bar = s % 64;
      if ([0, 2, 3, 6, 8, 10, 11, 14].includes(st)) taiko(t, st % 8 === 0 ? 1 : .65);
      if (st % 2 === 1) shime(t, .7);
      pluck(t, nf([0, 1, 0, 3, 0, 1, 4, 3][(st / 2) % 8 | 0], 73.42 * 2), .14, .8);
      for (const [s0, d, l] of MELODY_B) if (s0 === bar) flute(t, nf(d - 1), l * spb, .9);
    },
  },
  win: { bpm: 100, once: 24, play(s, t, spb) { if ([0, 4, 8, 12].includes(s)) taiko(t, 1); const n = { 0: 5, 4: 7, 8: 9, 12: 10, 16: 12 }[s]; if (n !== undefined) flute(t, nf(n), s === 16 ? spb * 8 : spb * 4, 1); } },
  lose: { bpm: 70, once: 20, play(s, t, spb) { const n = { 0: 7, 4: 6, 8: 5, 12: 3 }[s]; if (n !== undefined) flute(t, nf(n), spb * 5, .9); if (s === 0 || s === 12) taiko(t, .6); } },
};
const BGM = { track: null, step: 0, next: 0, timer: null, intensity: 0 };
function bgmPlay(name) {
  if (!AC || BGM.track === name) return;
  BGM.track = name; BGM.step = 0; BGM.next = AC.currentTime + .08;
  if (!BGM.timer) BGM.timer = setInterval(bgmTick, 25);
}
function bgmTick() {
  if (!AC || !BGM.track) return;
  const tr = TRACKS[BGM.track], spb = 60 / tr.bpm / 4;
  if (BGM.next < AC.currentTime - .5) BGM.next = AC.currentTime + .05; // タブ復帰時の取りこぼし対策
  while (BGM.next < AC.currentTime + .15) {
    if (tr.once && BGM.step >= tr.once) { BGM.track = null; return; }
    tr.play(BGM.step, BGM.next, spb);
    BGM.next += spb; BGM.step++;
  }
}
