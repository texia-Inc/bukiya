'use strict';

// STAGE 10　仕掛け人の部屋：金庫の番号を解き、パイ投げマシンをおぼんで防いで脱出

Object.assign(ITEMS, {
  tray: { name: 'おぼん', icon: '🍽️' },
});

STAGES.push({
  title: 'STAGE 10　仕掛け人の部屋',
  intro: 'ここが最後の部屋…？ ドアの上に、物騒な機械が付いている。',

  setup(c) {
    const s = c.state;
    const DX = 0.0;
    c.room({ floor: 0xd9d3dc, wall: 0xf1edf3, trim: 0xb1a8b6, line: 0xbcb3c1, door: { x: DX } });
    c.player.root.position.set(1.0, 0, 2.4);
    c.player.root.rotation.y = Math.PI;

    // ---- パイ投げマシン（ドアの上）----
    const machine = new THREE.Group();
    machine.add(place(box(0.6, 0.38, 0.45, 0x6c727c), 0, 0, 0));
    const nozzle = place(cyl(0.08, 0.1, 0.3, 0x3a3f47), 0, -0.15, 0.25);
    nozzle.rotation.x = 0.9;
    machine.add(nozzle);
    machine.add(place(textPlane('PIE', 0.3, 0.14, { bg: '#ffd84a' }), 0, 0.05, 0.226));
    machine.position.set(DX, 2.6, -3.75);
    c.obj('machine', machine, {
      stand: [DX, -1.8],
      onTap: async () => c.say('ドアの上に「パイ投げマシン」…！ ドアの前に狙いを定めている。 高くて手が届かない。'),
    });

    // ---- おぼん（顔の前に構える）----
    const held = place(cyl(0.3, 0.3, 0.03, 0x8b5a3c), 0, 1.2, 0.45);
    held.rotation.x = Math.PI / 2;
    held.visible = false;
    c.player.body.add(held);
    const useTray = async () => {
      c.removeItem('tray');
      s.tray = true;
      held.visible = true;
      c.say('おぼんを顔の前に構えた。 …これで何が飛んできても大丈夫？');
    };
    c.obj('player', c.player.root, { onItem: { tray: useTray } });

    // ---- ドア ----
    const door = c.door(DX, 0x9a7fb0);
    c.obj('door', door.group, {
      stand: [DX, -3.0],
      onTap: async () => {
        if (!s.unlocked) return c.say('鍵がかかっている。');
        c.say('ドアを開けた――');
        await c.tween(0.6, e => { door.pivot.rotation.y = 1.4 * e; });
        c.say('ウィーン… ガシャッ！');
        await c.tween(0.15, e => { machine.position.z = -3.75 - 0.08 * Math.sin(e * Math.PI); });

        const p = c.player.root.position;
        const from = new THREE.Vector3(DX, 2.4, -3.45);
        const to = new THREE.Vector3(p.x, 1.2, p.z - (s.tray ? 0.5 : 0.3));
        const pie = new THREE.Group();
        pie.add(cyl(0.2, 0.16, 0.06, 0xd9b27a), place(ball(0.17, 0xffffff), 0, 0.05, 0));
        pie.children[1].scale.y = 0.5;
        pie.rotation.x = Math.PI / 2;
        c.root.add(pie);
        await c.tween(0.25, e => pie.position.lerpVectors(from, to, e), c.ease.in);
        c.burst(to, 0xffffff, s.tray ? 24 : 14);

        if (!s.tray) {
          pie.position.copy(to);
          pie.scale.setScalar(1.3);
          c.say('ベチャッ！！');
          await c.wait(0.4);
          return c.fail('ドッキリ大成功…', 'パイまみれ…。 ドアを開けると何かが飛んでくる。 顔を守れる物は？');
        }
        c.root.remove(pie);
        c.say('ベチャッ！ …おぼんでガード！ 完全回避だ！');
        await c.wait(0.6);
        held.visible = false;
        const colors = [0xe0474c, 0x4d7cc9, 0xffd84a, 0x5aa36b, 0xc77fa0];
        colors.forEach((col, i) => c.burst(new THREE.Vector3(DX + (i - 2) * 0.5, 2.2, -2.6), col, 14));
        await c.exitThrough(DX);
        c.clear();
      },
      onItem: {
        key: async () => {
          c.removeItem('key');
          s.unlocked = true;
          c.say('カチャリ。 鍵が開いた！');
        },
        tray: async () => c.say('ドアにおぼんを当てても意味がない。 自分が持たないと。'),
      },
    });

    // ---- 「押すな」ボタン ----
    const pedestal = new THREE.Group();
    pedestal.add(place(box(0.45, 0.9, 0.45, 0x9aa1ab), 0, 0.45, 0));
    const btn = place(cyl(0.15, 0.17, 0.08, 0xe0474c, { emissive: 0x6a0000 }), 0, 0.94, 0);
    pedestal.add(btn);
    pedestal.add(place(textPlane('ぜったいに\n押すな', 0.4, 0.3, { bg: '#ffd84a' }), 0, 0.6, 0.226));
    pedestal.position.set(2.4, 0, 0.8);
    c.obj('button', pedestal, {
      stand: [2.4, 1.6],
      onTap: async () => {
        s.buttonTaps = (s.buttonTaps || 0) + 1;
        if (s.buttonTaps === 1) return c.say('「ぜったいに押すな」と書いてある 大きな赤いボタン。');
        c.say('…押すなと言われると、押したくなる。 ポチッ。');
        await c.tween(0.15, e => { btn.position.y = 0.94 - 0.04 * e; });
        const tarai = makeTarai();
        const p = c.player.root.position;
        c.root.add(tarai);
        await c.tween(0.4, e => tarai.position.set(p.x, 4.5 - (4.5 - 1.56) * e, p.z), c.ease.in);
        stars(c);
        await c.tween(0.15, e => { c.player.body.scale.y = 1 - 0.2 * e; });
        c.say('ガーンッ！！');
        c.fail('ドッキリ大成功…', '押すなと言われたのに…。 ボタンは押さずに脱出しよう。');
      },
    });

    // ---- ポスター（奥の壁）----
    const poster = textPlane('金庫の番号は\n信号の色の順', 1.0, 0.7, { bg: '#fff7e0' });
    poster.position.set(-2.4, 1.6, -3.98);
    c.obj('poster', poster, {
      stand: [-2.4, -2.8],
      onTap: async () => c.say('ポスター：「金庫の番号は、信号の色の順」'),
    });

    // ---- ビンの棚（左の壁）----
    const shelf = new THREE.Group();
    shelf.add(place(box(0.4, 0.05, 1.4, 0x8b6b4e), 0, 0, 0));
    const bottles = [[-0.45, 0xe0474c, '4'], [0, 0xffd84a, '1'], [0.45, 0x4d7cc9, '7']];
    bottles.forEach(([z, col, num]) => {
      shelf.add(place(cyl(0.11, 0.11, 0.36, col, { roughness: 0.3, transparent: true, opacity: 0.85 }), 0, 0.205, z));
      shelf.add(place(cyl(0.04, 0.05, 0.12, col, { roughness: 0.3 }), 0, 0.44, z));
      const label = textPlane(num, 0.14, 0.16);
      label.rotation.y = Math.PI / 2;
      shelf.add(place(label, 0.115, 0.2, z));
    });
    shelf.position.set(-3.78, 1.1, -0.8);
    c.obj('bottles', shelf, {
      stand: [-2.9, -0.8],
      onTap: async () => c.say('3本のビン。 赤に「4」、黄に「1」、青に「7」と書いてある。'),
    });

    // ---- 金庫 ----
    const safe = new THREE.Group();
    safe.add(place(box(0.8, 0.8, 0.7, 0x3a3f47, { metalness: 0.4, roughness: 0.5 }), 0, 0.4, 0));
    safe.add(place(box(0.66, 0.66, 0.02, 0x1e2228), 0, 0.4, 0.351));
    const safeDoor = place(new THREE.Group(), -0.36, 0, 0.37);
    safeDoor.add(place(box(0.72, 0.72, 0.05, 0x50555d, { metalness: 0.5, roughness: 0.4 }), 0.36, 0.4, 0));
    const dial = place(cyl(0.1, 0.1, 0.04, 0xc0c6cd, { metalness: 0.7 }), 0.36, 0.45, 0.04);
    dial.rotation.x = Math.PI / 2;
    safeDoor.add(dial);
    safe.add(safeDoor);
    const safeKey = place(box(0.18, 0.04, 0.06, 0xe8b923, { metalness: 0.7, roughness: 0.3 }), 0, 0.12, 0.42);
    safeKey.visible = false;
    safe.add(safeKey);
    safe.position.set(2.8, 0, -3.4);
    c.obj('safe', safe, {
      stand: [2.8, -2.4],
      onTap: async () => {
        if (s.safeOpen) {
          if (s.gotKey) return c.say('金庫は空っぽだ。');
          s.gotKey = true;
          safeKey.visible = false;
          c.addItem('key');
          return c.say('金庫の中から鍵を取り出した！');
        }
        c.say('ダイヤル式の金庫。 3ケタの番号が必要だ。');
        const v = await c.keypad(3);
        if (v === null) return;
        if (v !== '714') return c.say('ブブーッ。 開かない。');
        s.safeOpen = true;
        await c.tween(0.5, e => { dial.rotation.y = 6 * e; });
        await c.tween(0.5, e => { safeDoor.rotation.y = -1.8 * e; });
        safeKey.visible = true;
        c.say('ガチャン！ 金庫が開いた。 中に鍵が入っている！');
      },
    });

    // ---- テーブルとおぼん ----
    const table = makeTable(1.2, 0.8, 0.72, 0xd9d4c7, 0x7d6b55);
    const trayOn = place(cyl(0.3, 0.3, 0.03, 0x8b5a3c), 0, 0.775, 0);
    table.add(trayOn);
    table.add(place(cyl(0.04, 0.04, 0.12, 0xffffff), 0.35, 0.82, 0.15));
    table.position.set(-1.9, 0, 1.9);
    c.obj('table', table, {
      stand: [-1.9, 1.1],
      onTap: async () => {
        if (s.gotTray) return c.say('コップが1つ置いてあるだけだ。');
        s.gotTray = true;
        trayOn.visible = false;
        c.addItem('tray');
        c.say('テーブルの上の おぼんを手に入れた。');
      },
    });
  },

  hint(c) {
    const s = c.state;
    if (!s.safeOpen) return '金庫の番号は3ケタ。 ポスターの「信号の色の順」と、左の壁のビンの数字を組み合わせよう。';
    if (!s.unlocked && !c.hasItem('key')) return '金庫の中の鍵を取ろう。';
    if (!s.unlocked) return '鍵をドアにドラッグしよう。';
    if (!s.tray && !c.hasItem('tray')) return 'ドアを開けたらパイ投げマシンが…。 顔を守れる物を探そう。 テーブルの上は？';
    if (!s.tray) return 'おぼんを自分（主人公）にドラッグして構えよう。';
    return '赤いボタンは押さずに、ドアを開けて脱出しよう！';
  },
});
