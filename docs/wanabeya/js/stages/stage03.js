'use strict';

// STAGE 3　タライの部屋：ドアの前の真上にタライ。ロープの根元を切ってから通る

Object.assign(ITEMS, {
  scissors: { name: 'はさみ', icon: '✂️' },
});

STAGES.push({
  title: 'STAGE 3　タライの部屋',
  intro: 'また知らない部屋だ。 天井のほうから、ギシ…ギシ…と音がする。',

  setup(c) {
    const s = c.state;
    const DX = 0.4, TZ = -3.0;   // タライはドアの前の真上
    c.room({ floor: 0xd6d9dd, wall: 0xeceef1, trim: 0xb3b9c2, line: 0xaeb3bb, door: { x: DX } });
    c.player.root.position.set(1.8, 0, 2.0);
    c.player.root.rotation.y = Math.PI;

    // ---- タライとロープ ----
    const tarai = makeTarai();
    tarai.position.set(DX, 2.55, TZ);
    const TOP = 3.4, RX = -3.88;
    const ropes = [
      rod(new THREE.Vector3(DX, 2.62, TZ), new THREE.Vector3(DX, TOP, TZ), 0.02, 0xc9a66b),
      rod(new THREE.Vector3(DX, TOP, TZ), new THREE.Vector3(RX, TOP, TZ), 0.02, 0xc9a66b),
      rod(new THREE.Vector3(RX, TOP, TZ), new THREE.Vector3(RX, 1.3, TZ), 0.02, 0xc9a66b),
    ];
    ropes.forEach(r => c.root.add(r));
    c.root.add(place(ball(0.07, 0x6c727c), DX, TOP, TZ), place(ball(0.07, 0x6c727c), RX, TOP, TZ));

    c.obj('tarai', tarai, {
      stand: [DX, -1.8],
      onTap: async () => {
        if (s.cut) return c.say('床に落ちたタライ。 ベコッとへこんでいる。');
        c.say('ドアの前の天井から、タライがぶら下がっている…！ ロープは左の壁のほうへ続いている。');
      },
      onItem: { scissors: async () => c.say('高くてロープに届かない。 ロープの根元なら…。') },
    });

    // ---- ロープの根元（左の壁のフック）----
    const hook = new THREE.Group();
    hook.add(place(box(0.04, 0.22, 0.14, 0x6c727c), 0, 0, 0));
    hook.add(place(ball(0.07, 0xc9a66b), 0.07, 0, 0));
    hook.position.set(-3.97, 1.3, TZ);
    c.obj('hook', hook, {
      stand: [-3.1, TZ],
      onTap: async () => {
        if (s.cut) return c.say('切れたロープの結び目だけが残っている。');
        c.say('ロープがフックに固く結ばれている。 天井を通って、ドアの前のタライにつながっているようだ。');
      },
      onItem: {
        scissors: async () => {
          if (s.cut) return;
          c.removeItem('scissors');
          s.cut = true;
          c.say('チョキン！');
          ropes.forEach(r => { r.visible = false; });
          await c.tween(0.45, e => { tarai.position.y = 2.55 - 2.44 * e; }, c.ease.in);
          c.burst(new THREE.Vector3(DX, 0.1, TZ), 0xc0c6cd, 14);
          await c.tween(0.35, e => {
            tarai.position.x = DX - 1.0 * e;
            tarai.position.z = TZ + 0.5 * e;
            tarai.rotation.y = 3 * e;
          }, c.ease.out);
          c.say('ガッシャーン！！ …タライが落ちた。 あぶなかった。');
        },
      },
    });

    // ---- ドアとテンキー ----
    const door = c.door(DX);
    addKeypad(c, { x: DX + 0.85, stand: [DX + 0.85, -2.3], code: '0314' });
    c.obj('door', door.group, {
      stand: [DX, -3.0],
      onArrive: async () => {
        if (s.cut) return true;
        c.say('…ん？ 上から何か――');
        await c.tween(0.3, e => { tarai.position.y = 2.55 - 0.97 * e; }, c.ease.in);
        stars(c);
        await c.tween(0.15, e => { c.player.body.scale.y = 1 - 0.2 * e; });
        c.say('ガーンッ！！');
        c.fail('ドッキリ大成功…', 'タライが頭に直撃。 ロープの先をたどってみよう。');
        return false;
      },
      onTap: async () => (s.unlocked ? openAndExit(c, door, DX) : c.say('鍵がかかっている。 横にテンキーがある。')),
    });

    // ---- 机とペン立て ----
    const desk = makeTable(1.4, 0.7, 0.76);
    desk.position.set(2.7, 0, -3.5);
    c.obj('desk', desk, {
      stand: [2.4, -2.6],
      onTap: async () => c.say('事務机だ。 引き出しは全部カラッポ。'),
    });

    const cup = new THREE.Group();
    cup.add(place(cyl(0.09, 0.08, 0.2, 0x4d7cc9), 0, 0.1, 0));
    const pen1 = place(cyl(0.012, 0.012, 0.28, 0xd94b4b), -0.03, 0.2, 0.02);
    pen1.rotation.z = 0.15;
    const pen2 = place(cyl(0.012, 0.012, 0.28, 0x23272e), 0.03, 0.2, -0.03);
    pen2.rotation.x = 0.15;
    const sc = new THREE.Group();
    sc.add(
      place(shade(new THREE.Mesh(new THREE.TorusGeometry(0.035, 0.012, 6, 14), mat(0xe0474c))), -0.03, 0.3, 0),
      place(shade(new THREE.Mesh(new THREE.TorusGeometry(0.035, 0.012, 6, 14), mat(0xe0474c))), 0.03, 0.3, 0),
      place(box(0.03, 0.16, 0.01, 0xc0c6cd, { metalness: 0.6 }), 0, 0.2, 0),
    );
    cup.add(pen1, pen2, sc);
    cup.position.set(3.0, 0.8, -3.45);
    c.obj('penCup', cup, {
      stand: [3.0, -2.6],
      onTap: async () => {
        if (s.gotScissors) return c.say('ペンしか残っていない。');
        s.gotScissors = true;
        sc.visible = false;
        c.addItem('scissors');
        c.say('ペン立てに はさみが刺さっていた。');
      },
    });

    // ---- カレンダー（左の壁）----
    const calendar = canvasPlane(0.8, 0.95, (g, W, H) => {
      g.fillStyle = '#ffffff';
      g.fillRect(0, 0, W, H);
      g.fillStyle = '#d94b4b';
      g.fillRect(0, 0, W, H * 0.2);
      g.fillStyle = '#ffffff';
      g.font = `800 ${H * 0.13}px 'M PLUS Rounded 1c', sans-serif`;
      g.textAlign = 'center';
      g.textBaseline = 'middle';
      g.fillText('3月', W / 2, H * 0.1);
      const cw = W / 7, ch = (H * 0.78) / 6, top = H * 0.22;
      g.font = `500 ${ch * 0.45}px 'M PLUS Rounded 1c', sans-serif`;
      for (let d = 1; d <= 31; d++) {
        const i = d + 2;   // 1日は水曜はじまり（日曜が左端）
        const x = (i % 7) * cw + cw / 2, y = top + Math.floor(i / 7) * ch + ch / 2;
        g.fillStyle = i % 7 === 0 ? '#d94b4b' : '#23272e';
        g.fillText(String(d), x, y);
        if (d === 14) {
          g.strokeStyle = '#d94b4b';
          g.lineWidth = 5;
          g.beginPath();
          g.arc(x, y, ch * 0.42, 0, Math.PI * 2);
          g.stroke();
        }
      }
    });
    calendar.rotation.y = Math.PI / 2;
    calendar.position.set(-3.98, 1.7, 0.8);
    c.obj('calendar', calendar, {
      stand: [-3.0, 0.8],
      onTap: async () => c.say('3月のカレンダー。 14日に赤い丸がついていて「大事な日」と書いてある。'),
    });

    // ---- ゴミ箱 ----
    const bin = cyl(0.22, 0.18, 0.5, 0x8d949e, { side: THREE.DoubleSide }, 20, true);
    bin.position.set(-3.3, 0.25, 2.8);
    c.obj('bin', bin, {
      stand: [-2.6, 2.4],
      onTap: async () => c.say('ゴミ箱の中に「タライ 10個入り」の空き箱が…。 イヤな予感しかしない。'),
    });
  },

  hint(c) {
    const s = c.state;
    if (!s.cut && !c.hasItem('scissors')) return 'ドアの前の真上にタライが…。 まずは何か切れる物を探そう。 机の上は？';
    if (!s.cut) return 'はさみを、左の壁のフック（ロープの根元）にドラッグしよう。';
    if (!s.unlocked) return 'カレンダーの丸がついた日付を、4ケタでテンキーに入力しよう。';
    return 'ドアを開けて脱出しよう！';
  },
});
