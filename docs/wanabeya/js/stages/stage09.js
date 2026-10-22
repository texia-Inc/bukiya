'use strict';

// STAGE 9　ネズミ捕りの台所：鍵がネズミ捕りの上に。素手で取ると指をはさまれる

Object.assign(ITEMS, {
  tongs: { name: 'トング', icon: '🥢' },
});

STAGES.push({
  title: 'STAGE 9　ネズミ捕りの台所',
  intro: '台所みたいな部屋だ。 床の真ん中に、何か置いてある。',

  setup(c) {
    const s = c.state;
    const DX = -1.4;
    c.room({ floor: 0xd2d6cf, wall: 0xf2f2ec, trim: 0xa8ad9f, line: 0xb7bcae, door: { x: DX } });
    c.player.root.position.set(2.4, 0, 2.4);
    c.player.root.rotation.y = Math.PI;

    // ---- ネズミ捕り ----
    const MX = 0.6, MZ = -0.4;
    const trap = new THREE.Group();
    trap.add(place(box(0.55, 0.04, 0.32, 0xc9a26b), 0, 0.02, 0));
    trap.add(place(box(0.12, 0.012, 0.1, 0xffd84a), 0, 0.046, 0.06));
    const bar = place(new THREE.Group(), 0, 0.05, 0);
    const steel = { metalness: 0.7, roughness: 0.3 };
    bar.add(
      place(box(0.015, 0.015, 0.15, 0xc0c6cd, steel), -0.2, 0, -0.075),
      place(box(0.015, 0.015, 0.15, 0xc0c6cd, steel), 0.2, 0, -0.075),
      place(box(0.415, 0.015, 0.015, 0xc0c6cd, steel), 0, 0, -0.15),
    );
    trap.add(bar);
    const coil = shade(new THREE.Mesh(new THREE.TorusGeometry(0.03, 0.01, 6, 12), mat(0xc0c6cd, steel)));
    coil.rotation.y = Math.PI / 2;
    trap.add(place(coil, -0.22, 0.06, 0));
    const trapKey = place(box(0.16, 0.03, 0.05, 0xe8b923, { metalness: 0.7, roughness: 0.3 }), 0, 0.066, 0.06);
    trap.add(trapKey);
    trap.position.set(MX, 0, MZ);

    const snap = async () => {
      await c.tween(0.12, e => { bar.rotation.x = Math.PI * e; }, c.ease.in);
      c.sfx('snap');
    };

    c.obj('trap', trap, {
      stand: [MX, MZ + 0.8],
      onTap: async () => {
        if (s.gotKey) return c.say('バネが はじけたネズミ捕り。 もう用はない。');
        s.trapTaps = (s.trapTaps || 0) + 1;
        if (s.trapTaps === 1) return c.say('ネズミ捕りの上に鍵が乗っている…。 素手で取ったら はさまれそうだ。');
        c.say('そーっと手をのばして…');
        await c.wait(0.5);
        await snap();
        c.sfx('bonk');
        stars(c);
        const b = c.player.body;
        await c.tween(0.6, (e, t) => { b.position.y = Math.abs(Math.sin(t * Math.PI * 4)) * 0.3; }, c.ease.linear);
        c.say('バチーンッ！！');
        c.fail('ドッキリ大成功…', '指をネズミ捕りにはさまれた…。 何かで はさんで取れないかな？');
      },
      onItem: {
        tongs: async () => {
          c.removeItem('tongs');
          const t = new THREE.Group();
          t.add(place(box(0.03, 0.6, 0.02, 0xc0c6cd, steel), -0.02, 0.3, 0), place(box(0.03, 0.6, 0.02, 0xc0c6cd, steel), 0.02, 0.3, 0));
          t.position.set(0.2, 0.7, 0.15);
          c.player.body.add(t);
          await c.tween(0.35, e => { t.rotation.x = 2.2 * e; });
          await snap();
          c.burst(new THREE.Vector3(MX, 0.15, MZ), 0xc0c6cd, 10);
          trapKey.visible = false;
          s.gotKey = true;
          await c.tween(0.3, e => { t.rotation.x = 2.2 * (1 - e); });
          c.player.body.remove(t);
          c.addItem('key');
          c.say('トングでつまんだ瞬間… バチンッ！ トングでよかった。 鍵を手に入れた！');
        },
      },
    });

    // ---- 流し台（奥の壁ぞい）と引き出し ----
    const counter = new THREE.Group();
    counter.add(place(box(3.0, 0.86, 0.7, 0xe9ebee), 0, 0.43, 0));
    counter.add(place(box(3.04, 0.05, 0.74, 0x6c727c), 0, 0.885, 0));
    counter.add(place(box(0.7, 0.03, 0.45, 0x3a3f47), -0.6, 0.9, 0));
    const faucet = place(cyl(0.025, 0.025, 0.35, 0xc0c6cd, steel), -0.6, 1.08, -0.25);
    counter.add(faucet);
    for (const x of [0.7, 1.15]) counter.add(place(cyl(0.16, 0.16, 0.02, 0x23272e), x, 0.92, 0));
    counter.position.set(2.1, 0, -3.62);
    c.obj('counter', counter, {
      stand: [1.5, -2.6],
      onTap: async () => c.say('流し台だ。 ピカピカに磨かれている。'),
    });

    const drawer = place(new THREE.Group(), 2.9, 0.62, -3.24);
    drawer.add(place(box(0.8, 0.32, 0.08, 0xd5d9df), 0, 0, 0));
    drawer.add(place(box(0.24, 0.04, 0.04, 0x6c727c), 0, 0, 0.05));
    const tongsIn = place(box(0.05, 0.02, 0.4, 0xc0c6cd, steel), 0, 0.09, -0.2);
    tongsIn.visible = false;
    drawer.add(tongsIn);
    c.obj('drawer', drawer, {
      stand: [2.9, -2.5],
      onTap: async () => {
        if (s.gotTongs) return c.say('フォークとスプーンしか残っていない。');
        s.gotTongs = true;
        tongsIn.visible = true;
        c.sfx('drawer');
        await c.tween(0.35, e => { drawer.position.z = -3.24 + 0.35 * e; });
        await c.wait(0.3);
        tongsIn.visible = false;
        c.addItem('tongs');
        c.say('引き出しに トングが入っていた。');
      },
    });

    // ---- 冷蔵庫（左の壁ぞい）----
    const fridge = new THREE.Group();
    fridge.add(place(box(0.8, 1.9, 0.8, 0xf7f7f7), 0, 0.95, 0));
    fridge.add(place(box(0.02, 0.01, 0.78, 0xb0b5bd), 0.401, 1.25, 0));
    fridge.add(place(box(0.04, 0.4, 0.04, 0x9aa1ab), 0.42, 1.5, 0.3), place(box(0.04, 0.3, 0.04, 0x9aa1ab), 0.42, 0.9, 0.3));
    fridge.position.set(-3.5, 0, 1.4);
    c.obj('fridge', fridge, {
      stand: [-2.6, 1.4],
      onTap: async () => c.say('冷蔵庫。 中には麦茶しか入っていない。'),
    });

    // ---- ダイニングテーブルと置き手紙 ----
    const table = makeTable(1.2, 0.8, 0.72, 0xc9a26b, 0x7d6b55);
    table.add(place(box(0.28, 0.012, 0.2, 0xfdfdf8), 0.2, 0.766, 0.1));
    table.position.set(-1.0, 0, 2.2);
    c.obj('table', table, {
      stand: [-1.0, 1.4],
      onTap: async () => {
        c.say('置き手紙：「ネズミが出るので、ワナを仕掛けておきました。 素手でさわらないように」');
        await c.closeup(textCanvas('ネズミが出るので、\nワナを仕掛けておきました。\n素手でさわらないように', 1.2, 0.9), '置き手紙');
      },
    });

    // ---- ドア ----
    const door = c.door(DX, 0x8fa39a);
    addKeyDoor(c, door, DX);
  },

  hint(c) {
    const s = c.state;
    if (!s.gotKey && !c.hasItem('tongs')) return 'ネズミ捕りの上の鍵… 素手は危ない。 はさんで取る道具を探そう。 流し台の引き出しは？';
    if (!s.gotKey) return 'トングをネズミ捕りにドラッグしよう。';
    if (!s.unlocked) return '鍵をドアにドラッグしよう。';
    return 'ドアを開けて脱出しよう！';
  },
});
