'use strict';

// STAGE 2　天井の鍵：電灯にぶら下がった鍵と、色のちがう床（落とし穴）

Object.assign(ITEMS, {
  broom: { name: 'ほうき', icon: '🧹' },
  plank: { name: '板',     icon: '🪵' },
});

STAGES.push({
  title: 'STAGE 2　天井の鍵',
  intro: '次の部屋だ。 ドアの前の床… なにか変じゃないか？',

  setup(c) {
    const s = c.state;
    s.keyOnLamp = true;
    const DX = 0.6;
    const HOLE = { x0: DX - 0.5, x1: DX + 0.5, z0: -4, z1: -3 };
    c.room({ floor: 0xd3d0ca, wall: 0xe9e6e0, trim: 0xa9a49b, line: 0xb4afa6, door: { x: DX }, hole: HOLE });
    c.player.root.position.set(1.6, 0, 1.8);
    c.player.root.rotation.y = Math.PI;

    // ---- 落とし穴のフタ（色のちがう床）----
    const tile = place(new THREE.Group(), HOLE.x0, 0, (HOLE.z0 + HOLE.z1) / 2);
    tile.add(place(box(1.0, 0.2, 1.0, 0xbfb9ae), 0.5, -0.1, 0));
    const crackA = place(box(0.45, 0.004, 0.025, 0x7d776d), 0.45, 0.002, 0.1);
    crackA.rotation.y = 0.5;
    const crackB = place(box(0.3, 0.004, 0.025, 0x7d776d), 0.7, 0.002, -0.12);
    crackB.rotation.y = -0.7;
    tile.add(crackA, crackB);

    const plank = place(box(0.55, 0.06, 1.6, 0xb07a45), DX, 0.03, -3.15);
    plank.visible = false;
    c.root.add(plank);

    c.obj('tile', tile, {
      stand: [DX, -2.3],
      onTap: async () => {
        if (s.plank) return c.say('板をかけてある。 これなら安心だ。');
        c.say('この床だけ色がちがう…。 よく見るとヒビのような線がある。');
      },
      onItem: {
        plank: async () => {
          c.removeItem('plank');
          s.plank = true;
          plank.visible = true;
          await c.tween(0.25, e => { plank.position.y = 0.4 - 0.37 * e; }, c.ease.in);
          c.sfx('thud');
          c.say('板を渡した。 これで床が抜けても大丈夫…なはず。');
        },
      },
    });

    const fallIn = async () => {
      c.say('ガコンッ！？');
      c.sfx('crash');
      c.sfx('fall');
      const p = c.player.root.position;
      c.tween(0.3, e => { tile.rotation.z = -1.5 * e; }, c.ease.in);
      await c.wait(0.12);
      await c.tween(0.6, e => {
        p.y = -3 * e;
        c.player.root.rotation.y += 0.2;
      }, c.ease.in);
      c.fail('ドッキリ大成功…', '落とし穴に まっさかさま。 色のちがう床には気をつけよう。');
    };

    // ---- ドア（立ち位置がフタの上）----
    const door = c.door(DX, 0x7e8c7a);
    addKeyDoor(c, door, DX, {
      onArrive: async () => {
        if (s.plank) return true;
        await fallIn();
        return false;
      },
    });
    c.obj('door', door.group, { stand: [DX, -3.35] });

    // ---- 電灯と鍵 ----
    const LX = -0.8, LZ = -1.0;
    const lamp = new THREE.Group();
    lamp.add(
      place(cyl(0.015, 0.015, 0.8, 0x333333), 0, 3.25, 0),
      place(new THREE.Mesh(new THREE.ConeGeometry(0.42, 0.32, 24, 1, true), mat(0x3f6e8c, { side: THREE.DoubleSide })), 0, 2.72, 0),
      place(ball(0.12, 0xfff3c4, { emissive: 0xffe9a0, emissiveIntensity: 0.9 }), 0, 2.6, 0),
    );
    const keyString = place(cyl(0.008, 0.008, 0.3, 0x888888), 0.15, 2.42, 0);
    lamp.add(keyString);
    lamp.add(place(new THREE.PointLight(0xffe2a0, 0.35, 7), 0, 2.5, 0));
    lamp.position.set(LX, 0, LZ);

    const key = new THREE.Group();
    const gold = { metalness: 0.7, roughness: 0.3 };
    key.add(
      place(shade(new THREE.Mesh(new THREE.TorusGeometry(0.07, 0.022, 8, 20), mat(0xe8b923, gold))), 0, 0.12, 0),
      place(box(0.03, 0.2, 0.03, 0xe8b923, gold), 0, -0.03, 0),
      place(box(0.03, 0.04, 0.07, 0xe8b923, gold), 0, -0.1, 0.04),
    );
    key.position.set(LX + 0.15, 2.18, LZ);
    c.root.add(key);

    const knock = async () => {
      if (!s.keyOnLamp) return c.say('もう何もぶら下がっていない。');
      c.removeItem('broom');
      const held = makeBroom();
      held.position.set(0.28, 0.6, 0.12);
      c.player.body.add(held);
      for (let i = 0; i < 2; i++) {
        c.sfx('whoosh');
        await c.tween(0.18, e => { held.rotation.x = 0.1 + 0.4 * e; });
        await c.tween(0.18, e => { held.rotation.x = 0.5 - 0.4 * e; });
      }
      s.keyOnLamp = false;
      keyString.visible = false;
      await c.tween(0.5, e => {
        key.position.y = 2.18 - 2.13 * e;
        key.rotation.z = e * 6;
      }, c.ease.in);
      key.rotation.set(-Math.PI / 2, 0, 0.6);
      c.sfx('sparkle');
      c.burst(key.position.clone(), 0xe8b923, 10);
      c.player.body.remove(held);
      c.say('ほうきで突っついたら、鍵が落ちてきた！');
    };

    c.obj('lamp', lamp, {
      stand: [LX + 0.1, LZ + 0.75],
      onTap: async () => {
        if (s.keyOnLamp) c.say('電灯だ。 …よく見ると鍵がぶら下がっている！ でも高くて手が届かない。');
        else c.say('ただの電灯だ。');
      },
      onItem: { broom: knock },
    });
    c.obj('key', key, {
      stand: [LX + 0.1, LZ + 0.75],
      onTap: async () => {
        if (s.keyOnLamp) return c.say('鍵が電灯にぶら下がっている。 高くて手が届かない…。');
        key.visible = false;
        c.addItem('key');
        c.say('鍵を拾った！');
      },
      onItem: { broom: knock },
    });

    // ---- ロッカー ----
    const locker = new THREE.Group();
    locker.add(place(box(0.7, 2.0, 0.8, 0x6f8fa6), 0, 1.0, 0));
    locker.add(place(box(0.02, 1.9, 0.72, 0x2c3540), 0.351, 1.0, 0));
    const lockDoor = place(new THREE.Group(), 0.37, 0, 0.4);
    lockDoor.add(place(box(0.04, 1.9, 0.78, 0x7f9fb6), 0, 1.0, -0.39));
    for (let i = 0; i < 3; i++) lockDoor.add(place(box(0.01, 0.03, 0.4, 0x4b6274), 0.025, 1.65 - i * 0.08, -0.39));
    lockDoor.add(place(box(0.03, 0.16, 0.03, 0xcccccc), 0.035, 1.0, -0.7));
    locker.add(lockDoor);
    const broomIn = makeBroom();
    broomIn.position.set(0.25, 0.05, 0);
    broomIn.rotation.z = 0.08;
    broomIn.visible = false;
    locker.add(broomIn);
    locker.position.set(-3.6, 0, 0.6);

    c.obj('locker', locker, {
      stand: [-2.5, 0.6],
      onTap: async () => {
        if (s.lockerOpen) return c.say('ロッカーはもう空っぽだ。');
        s.lockerOpen = true;
        broomIn.visible = true;
        c.sfx('door');
        await c.tween(0.45, e => { lockDoor.rotation.y = -1.9 * e; });
        await c.wait(0.3);
        broomIn.visible = false;
        c.addItem('broom');
        c.say('ロッカーの中に ほうきが入っていた。');
      },
    });

    // ---- 本棚 ----
    const shelf = makeBookshelf();
    shelf.position.set(-2.3, 0, -3.75);
    c.obj('shelf', shelf, {
      stand: [-2.3, -2.7],
      onTap: async () => {
        if (s.gotPlank) return c.say('むずかしそうな本ばかりだ。 『落とし穴の作り方』…？');
        s.gotPlank = true;
        c.addItem('plank');
        c.say('本棚と壁のすき間に、板がはさまっていた！');
      },
    });

    // ---- 観葉植物 ----
    const plant = makePlant();
    plant.position.set(3.2, 0, -3.2);
    c.obj('plant', plant, {
      stand: [2.5, -2.5],
      onTap: async () => c.say('観葉植物…と思ったら造花だった。'),
    });

    c.obj('player', c.player.root, { onTap: async () => c.say('（さっきはヒドい目にあった…。 慎重にいこう）') });
  },

  hint(c) {
    const s = c.state;
    if (!s.plank && !c.hasItem('plank')) return 'ドアの前の色のちがう床が怪しい…。 本棚のあたりを調べてみよう。';
    if (!s.plank) return '板を怪しい床にドラッグしてみよう。';
    if (s.keyOnLamp && !c.hasItem('broom')) return '電灯の鍵に届く長い物はないかな？ ロッカーを調べてみよう。';
    if (s.keyOnLamp) return 'ほうきを電灯にドラッグしてみよう。';
    if (!s.unlocked && !c.hasItem('key')) return '床に落ちた鍵を拾おう。';
    if (!s.unlocked) return '鍵をドアにドラッグしよう。';
    return 'ドアを開けて脱出しよう！';
  },
});
