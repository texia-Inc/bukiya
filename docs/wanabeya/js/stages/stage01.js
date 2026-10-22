'use strict';

// STAGE 1　目覚めの部屋：止まった時計とドアの上のバケツ

Object.assign(ITEMS, {
  battery:  { name: '電池', icon: '🔋' },
  umbrella: { name: '傘',   icon: '☂️' },
});

STAGES.push({
  title: 'STAGE 1　目覚めの部屋',
  intro: '……目が覚めると、知らない無機質な部屋にいた。 壁の時計が妙に気になる。',

  setup(c) {
    const s = c.state;
    const DX = 1.3;
    c.room({ floor: 0xdadde2, wall: 0xf0f1f3, trim: 0xb9bec7, line: 0xb0b5bd, door: { x: DX } });
    c.player.root.position.set(1.0, 0, 1.4);
    c.player.root.rotation.y = -Math.PI * 0.75;

    // ---- 壁掛け時計（左の壁）----
    const clock = new THREE.Group();
    const dial = cyl(0.55, 0.55, 0.06, 0xffffff);
    dial.rotation.z = Math.PI / 2;
    const rim = shade(new THREE.Mesh(new THREE.TorusGeometry(0.56, 0.05, 12, 40), mat(0x3a3f47)));
    rim.rotation.y = Math.PI / 2;
    clock.add(dial, rim);
    for (let i = 0; i < 12; i++) {
      const a = (i / 12) * Math.PI * 2;
      const tick = place(box(0.02, i % 3 ? 0.06 : 0.12, 0.03, 0x3a3f47), 0.035, Math.cos(a) * 0.44, -Math.sin(a) * 0.44);
      tick.rotation.x = -a;
      clock.add(tick);
    }
    const hourPivot = place(new THREE.Group(), 0.05, 0, 0);
    hourPivot.add(place(box(0.02, 0.28, 0.06, 0x22262c), 0, 0.12, 0));
    const minPivot = place(new THREE.Group(), 0.07, 0, 0);
    minPivot.add(place(box(0.02, 0.42, 0.04, 0x22262c), 0, 0.18, 0));
    clock.add(hourPivot, minPivot, place(ball(0.04, 0xd04848), 0.08, 0, 0));
    const setTime = min => {
      minPivot.rotation.x = -((min % 60) / 60) * Math.PI * 2;
      hourPivot.rotation.x = -(((min / 60) % 12) / 12) * Math.PI * 2;
    };
    setTime(10 * 60 + 10);
    clock.position.set(-3.95, 2.0, -1.2);

    c.obj('clock', clock, {
      stand: [-3.0, -1.2],
      onTap: async () => {
        if (!s.clockRunning) c.say('壁掛け時計。 針が止まっている…。 裏の電池ボックスが空っぽだ。');
        else c.say('時計は 7時20分 を指したまま止まっている。');
      },
      onItem: {
        battery: async () => {
          c.removeItem('battery');
          c.say('電池を入れてみた…');
          await c.tween(2.2, e => setTime(610 + 550 * e), c.ease.out);
          s.clockRunning = true;
          c.say('時計が勢いよく回り出し… 7時20分 でピタリと止まった。');
        },
      },
    });

    // ---- 机と引き出し ----
    const desk = makeTable(1.0, 1.6, 0.8);
    const drawer = place(new THREE.Group(), 0, 0.58, 0);
    drawer.add(place(box(0.84, 0.16, 0.7, 0xc3c8cf), 0, 0, 0));
    drawer.add(place(box(0.04, 0.03, 0.22, 0x50555d), 0.44, 0, 0));
    const battery = place(cyl(0.035, 0.035, 0.2, 0x36b37e), 0.15, 0.115, 0);
    battery.rotation.x = Math.PI / 2;
    drawer.add(battery);
    desk.add(drawer);
    desk.position.set(-3.45, 0, 1.6);

    c.obj('desk', desk, {
      stand: [-2.4, 1.9],
      onTap: async () => {
        if (s.drawerOpen) return c.say('引き出しはもう空っぽだ。');
        s.drawerOpen = true;
        await c.tween(0.4, e => { drawer.position.x = 0.5 * e; });
        await c.wait(0.25);
        battery.visible = false;
        c.addItem('battery');
        c.say('引き出しの中に電池が入っていた！');
      },
    });

    const memo = place(box(0.3, 0.012, 0.22, 0xfdfdf8), -3.3, 0.846, 1.05);
    memo.rotation.y = 0.3;
    c.obj('memo', memo, {
      stand: [-2.4, 1.1],
      onTap: async () => c.say('メモがある。「扉の番号は、時計が知っている」'),
    });

    // ---- ベッド ----
    const bed = makeBed();
    bed.position.set(-2.6, 0, -3.35);
    c.obj('bed', bed, {
      stand: [-2.4, -2.2],
      onTap: async () => {
        s.bedTaps = (s.bedTaps || 0) + 1;
        if (s.bedTaps === 1) c.say('冷たくて固いベッド。 さっきまでここで寝ていたらしい。');
        else c.say('ベッドの下をのぞいた。 …ホコリひとつない。 不気味だ。');
      },
    });

    // ---- ドア・テンキー・ドアの上のバケツ ----
    const door = c.door(DX);
    addKeypad(c, { x: 2.2, stand: [2.2, -3.0], code: '0720' });

    const bucket = new THREE.Group();
    bucket.add(
      cyl(0.2, 0.15, 0.3, 0x9aa3ad, { metalness: 0.5, roughness: 0.4, side: THREE.DoubleSide }, 20, true),
      place(cyl(0.15, 0.15, 0.02, 0x9aa3ad), 0, -0.14, 0),
      place(cyl(0.19, 0.19, 0.02, 0x4aa3e0), 0, 0.1, 0),
    );
    bucket.position.set(DX, 2.43, -3.98);

    const openUmbrella = async () => {
      c.removeItem('umbrella');
      s.umbrella = true;
      const u = c.player.umbrella;
      u.visible = true;
      await c.tween(0.3, e => u.scale.setScalar(0.3 + 0.7 * e), c.ease.out);
      c.say('傘をさした。 …室内で。');
    };

    c.obj('bucket', bucket, {
      stand: [DX, -2.2],
      onTap: async () => c.say('ドアの上にバケツが乗っている。 開けたら落ちてきそうだ…。 高くて手は届かない。'),
      onItem: { umbrella: openUmbrella },
    });
    c.obj('player', c.player.root, { onItem: { umbrella: openUmbrella } });

    c.obj('door', door.group, {
      stand: [DX, -3.0],
      onTap: async () => {
        if (!s.unlocked) return c.say('鍵がかかっている。 横にテンキーがあるようだ。');
        c.say('ドアを開けた――');
        c.tween(0.7, e => { door.pivot.rotation.y = 1.4 * e; });
        await c.wait(0.25);

        // バケツが傾いて水がこぼれる
        await c.tween(0.35, e => {
          bucket.rotation.x = 2.6 * e;
          bucket.position.z = -3.98 + 0.5 * e;
          bucket.position.y = 2.43 - 0.1 * e;
        }, c.ease.in);
        const p = c.player.root.position;
        const ty = s.umbrella ? 2.05 : 1.3;
        const blob = place(ball(0.25, 0x4aa3e0, { transparent: true, opacity: 0.8 }), DX, 2.3, -3.4);
        c.root.add(blob);
        await c.tween(0.22, e => {
          blob.position.set(DX + (p.x - DX) * e, 2.3 + (ty - 2.3) * e, -3.4 + (p.z + 3.4) * e);
          blob.scale.set(1, 1 + e, 1);
        }, c.ease.in);
        c.root.remove(blob);
        c.burst(new THREE.Vector3(p.x, ty, p.z), 0x4aa3e0, s.umbrella ? 28 : 14);

        const bx = bucket.position.x, by = bucket.position.y, bz = bucket.position.z;
        if (!s.umbrella) {
          // 頭にスポッ
          await c.tween(0.25, e => {
            bucket.position.set(bx + (p.x - bx) * e, by + (1.6 - by) * e, bz + (p.z - bz) * e);
            bucket.rotation.x = 2.6 + (Math.PI - 2.6) * e;
          }, c.ease.in);
          c.player.shirtMat.color.set(0x4f86c6);
          c.say('バシャーッ！！');
          return c.fail('ドッキリ大成功…', 'バケツの水で びしょぬれ。 ドアの上をよく見て、身を守る方法を考えよう。');
        }
        // 傘ではね返す
        await c.tween(0.5, e => {
          bucket.position.set(bx + 1.2 * e, by + (0.2 - by) * e + Math.sin(e * Math.PI) * 0.6, bz + 1.0 * e);
          bucket.rotation.z = -4 * e;
        }, c.ease.linear);
        c.say('傘で華麗にガード！');
        await c.wait(0.6);
        c.player.umbrella.visible = false;
        await c.exitThrough(DX);
        c.clear();
      },
      onItem: { umbrella: openUmbrella },
    });

    // ---- 傘立て ----
    const umbStand = new THREE.Group();
    umbStand.add(place(cyl(0.2, 0.18, 0.5, 0x4a5059, {}, 20), 0, 0.25, 0));
    const umb = new THREE.Group();
    const canopy = place(new THREE.Mesh(new THREE.ConeGeometry(0.09, 0.8, 12), mat(0xe0474c)), 0, 0.75, 0);
    canopy.rotation.x = Math.PI;
    umb.add(shade(canopy), place(cyl(0.02, 0.02, 0.25, 0x333333), 0, 1.27, 0));
    umbStand.add(umb);
    umbStand.position.set(3.3, 0, -3.3);
    c.obj('umbrellaStand', umbStand, {
      stand: [2.6, -2.5],
      onTap: async () => {
        if (s.gotUmbrella) return c.say('空っぽの傘立てだ。');
        s.gotUmbrella = true;
        umb.visible = false;
        c.addItem('umbrella');
        c.say('傘立てに傘が1本。 …室内なのに？ 一応もらっておこう。');
      },
    });
  },

  hint(c) {
    const s = c.state;
    if (!s.clockRunning && !c.hasItem('battery')) return 'あの時計、止まっているみたい。 机の中を調べてみよう。';
    if (!s.clockRunning) return '電池を時計にドラッグしてみよう。';
    if (!s.unlocked) return '時計が止まった時刻を、ドア横のテンキーに4ケタで入力しよう。';
    if (!s.umbrella && !c.hasItem('umbrella')) return 'ドアの上にバケツが…。 このまま開けたら危ない。 部屋の右奥を調べよう。';
    if (!s.umbrella) return '傘を自分（主人公）にドラッグしてみよう。';
    return 'ドアを開けて脱出しよう！';
  },
});
