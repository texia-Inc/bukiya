'use strict';

// STAGE 6　ビリビリの部屋：ドアノブに電気。分電盤のブレーカーを落としてから開ける

Object.assign(ITEMS, {
  smallKey: { name: '小さな鍵', icon: '🗝️' },
});

STAGES.push({
  title: 'STAGE 6　ビリビリの部屋',
  intro: 'バチッ…バチバチッ…。 どこかから火花の音がする。',

  setup(c) {
    const s = c.state;
    s.power = true;
    const DX = -0.6;
    c.room({ floor: 0xcfd4d9, wall: 0xe6eaee, trim: 0xa3abb5, line: 0xa9b0b9, door: { x: DX } });
    c.player.root.position.set(1.4, 0, 2.2);
    c.player.root.rotation.y = Math.PI;

    // ---- ドアノブの火花 ----
    const KNOB = new THREE.Vector3(DX + 0.43, 1.0, -3.96);
    const sparks = [];
    for (let i = 0; i < 5; i++) {
      const sp = new THREE.Mesh(new THREE.BoxGeometry(0.05, 0.05, 0.05), new THREE.MeshBasicMaterial({ color: 0xfff27a }));
      c.root.add(sp);
      sparks.push(sp);
    }
    c.update(() => {
      sparks.forEach(sp => {
        sp.visible = s.power && Math.random() < 0.35;
        sp.position.set(KNOB.x + (Math.random() - 0.5) * 0.3, KNOB.y + (Math.random() - 0.5) * 0.3, KNOB.z + Math.random() * 0.15);
      });
    });

    // ---- 電線：ドアノブ → 分電盤 ----
    const BX = 2.4;
    c.root.add(
      rod(new THREE.Vector3(DX + 0.62, 1.0, -3.97), new THREE.Vector3(BX, 1.0, -3.97), 0.02, 0x222222),
      rod(new THREE.Vector3(BX, 1.0, -3.97), new THREE.Vector3(BX, 1.45, -3.97), 0.02, 0x222222),
    );

    // ---- 分電盤 ----
    const panel = new THREE.Group();
    panel.add(place(box(0.55, 0.65, 0.12, 0x9aa1ab), 0, 0, 0));
    panel.add(place(box(0.45, 0.55, 0.02, 0x2d3138), 0, 0, 0.061));
    const lever = place(new THREE.Group(), 0, 0, 0.07);
    lever.add(place(box(0.08, 0.2, 0.06, 0xd94b4b), 0, 0.1, 0));
    lever.rotation.x = -0.3;
    panel.add(lever);
    const cover = place(new THREE.Group(), -0.275, 0, 0.075);
    cover.add(place(box(0.55, 0.65, 0.03, 0xb7bdc5), 0.275, 0, 0));
    cover.add(place(ball(0.03, 0x50555d), 0.48, 0, 0.02));
    panel.add(cover);
    panel.add(place(textPlane('⚡ 分電盤', 0.4, 0.1, { bg: '#ffd84a' }), 0, 0.42, 0.01));
    panel.position.set(BX, 1.8, -3.92);

    c.obj('panel', panel, {
      stand: [BX, -3.0],
      onTap: async () => {
        if (!s.panelOpen) return c.say('分電盤だ。 小さな鍵穴があって開かない。 電線がドアのほうへ続いている。');
        if (!s.power) return c.say('ブレーカーは落ちている。 部屋は静かだ。');
        s.power = false;
        await c.tween(0.25, e => { lever.rotation.x = -0.3 + 2.5 * e; });
        c.lighting({ hemi: 0.55, sun: 0.6 });
        c.say('ガチャン。 ブレーカーを落とした。 バチバチ音が止まった。');
      },
      onItem: {
        smallKey: async () => {
          c.removeItem('smallKey');
          s.panelOpen = true;
          await c.tween(0.4, e => { cover.rotation.y = -1.8 * e; });
          c.say('分電盤のフタが開いた。 中に赤いレバーがある。');
        },
      },
    });

    // ---- ドア（鍵はかかっていないが…）----
    const door = c.door(DX, 0x7d8794);
    c.obj('door', door.group, {
      stand: [DX, -3.0],
      onTap: async () => {
        if (!s.power) return openAndExit(c, door, DX);
        c.say('ビリビリビリッ！！！');
        const b = c.player.body, shirt = c.player.shirtMat;
        await c.tween(1.0, (e, t) => {
          b.position.x = (Math.random() - 0.5) * 0.08;
          shirt.color.set(Math.floor(t * 20) % 2 ? 0xfff27a : 0x23272e);
        }, c.ease.linear);
        b.position.x = 0;
        shirt.color.set(0x55555a);
        stars(c);
        await fallBack(c);
        c.fail('ドッキリ大成功…', 'ドアノブに電気が流れていた…。 電線の行き先を調べよう。');
      },
    });

    // ---- じゅうたん（下に小さな鍵）----
    const rug = new THREE.Group();
    rug.add(place(box(2.4, 0.02, 1.6, 0x9c4a4a), 0, 0.01, 0));
    rug.add(place(box(2.0, 0.022, 1.2, 0xc06a5a), 0, 0.012, 0));
    rug.add(place(box(1.2, 0.024, 0.5, 0xe0b04a), 0, 0.013, 0));
    const smallKey = place(box(0.12, 0.02, 0.05, 0xc0c6cd, { metalness: 0.7, roughness: 0.3 }), 1.0, 0.03, 0.62);
    smallKey.visible = false;
    rug.add(smallKey);
    rug.position.set(0.6, 0, 0.6);
    c.obj('rug', rug, {
      stand: [2.1, 1.5],
      onTap: async () => {
        if (s.gotSmallKey) return c.say('ふかふかのじゅうたん。');
        s.gotSmallKey = true;
        smallKey.visible = true;
        await c.wait(0.4);
        smallKey.visible = false;
        c.addItem('smallKey');
        c.say('じゅうたんの端をめくると… 小さな鍵が隠してあった！');
      },
    });

    // ---- スタンドライトとイス ----
    const lamp = new THREE.Group();
    lamp.add(place(cyl(0.2, 0.22, 0.04, 0x3a3f47), 0, 0.02, 0));
    lamp.add(place(cyl(0.02, 0.02, 1.5, 0x3a3f47), 0, 0.77, 0));
    lamp.add(place(new THREE.Mesh(new THREE.ConeGeometry(0.28, 0.32, 20, 1, true), mat(0xf2e6c8, { side: THREE.DoubleSide })), 0, 1.6, 0));
    lamp.position.set(-3.3, 0, 2.6);
    c.obj('lamp', lamp, {
      stand: [-2.6, 2.2],
      onTap: async () => c.say(s.power ? 'スタンドライト。 これも電気で動いている。' : 'ブレーカーを落としたので消えている。'),
    });

    const chair = new THREE.Group();
    chair.add(place(box(0.5, 0.06, 0.5, 0x6b7280), 0, 0.45, 0));
    chair.add(place(box(0.5, 0.55, 0.06, 0x6b7280), 0, 0.75, -0.22));
    for (const [x, z] of [[-0.2, -0.2], [0.2, -0.2], [-0.2, 0.2], [0.2, 0.2]]) chair.add(place(box(0.05, 0.43, 0.05, 0x3a3f47), x, 0.215, z));
    chair.position.set(-2.8, 0, -2.6);
    chair.rotation.y = 0.5;
    c.obj('chair', chair, {
      stand: [-2.0, -1.9],
      onTap: async () => c.say('イスだ。 座ったら何か起きそうで、座る気になれない。'),
    });
  },

  hint(c) {
    const s = c.state;
    if (!s.panelOpen && !c.hasItem('smallKey')) return 'ドアノブがバチバチ光っている…。 電線の先の分電盤を開ける鍵を探そう。 足元のじゅうたんは？';
    if (!s.panelOpen) return '小さな鍵を分電盤にドラッグしよう。';
    if (s.power) return '分電盤のレバーを下ろして、電気を止めよう。';
    return 'ドアを開けて脱出しよう！';
  },
});
