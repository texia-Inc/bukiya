'use strict';

// STAGE 4　まっくらな部屋：明かりを見つけないと、ドアの前のバナナの皮が見えない

Object.assign(ITEMS, {
  banana: { name: 'バナナの皮', icon: '🍌' },
});

STAGES.push({
  title: 'STAGE 4　まっくらな部屋',
  intro: '真っ暗で ほとんど何も見えない…。 どこかで何かが ぼんやり光っている。',

  setup(c) {
    const s = c.state;
    const DX = 1.2;
    c.lighting({ hemi: 0.06, sun: 0.04, bg: 0x07080a });
    c.room({ floor: 0xc9ccd1, wall: 0xe2e4e8, trim: 0xa7adb6, line: 0x9da3ab, door: { x: DX } });
    c.player.root.position.set(0.0, 0, 1.6);
    c.player.root.rotation.y = Math.PI;

    // ---- 光るシールつきのサイドテーブル（左の壁）----
    const side = new THREE.Group();
    side.add(place(box(0.6, 0.6, 0.6, 0x7c838d), 0, 0.3, 0));
    const drawer = place(new THREE.Group(), 0.31, 0.38, 0);
    drawer.add(place(box(0.04, 0.2, 0.5, 0x9aa1ab), 0, 0, 0));
    const starShape = new THREE.Shape();
    for (let i = 0; i < 10; i++) {
      const r = i % 2 ? 0.035 : 0.08, a = (i / 10) * Math.PI * 2 - Math.PI / 2;
      if (i === 0) starShape.moveTo(Math.cos(a) * r, -Math.sin(a) * r);
      else starShape.lineTo(Math.cos(a) * r, -Math.sin(a) * r);
    }
    const star = new THREE.Mesh(new THREE.ShapeGeometry(starShape), new THREE.MeshBasicMaterial({ color: 0x8dffc0 }));
    star.rotation.y = Math.PI / 2;
    drawer.add(place(star, 0.025, 0, 0));
    const torch = place(cyl(0.04, 0.05, 0.22, 0xe0b04a), 0, 0.13, 0);
    torch.rotation.z = Math.PI / 2;
    torch.visible = false;
    drawer.add(torch);
    side.add(drawer);
    side.position.set(-3.6, 0, -1.2);

    c.obj('sideTable', side, {
      stand: [-2.7, -1.2],
      onTap: async () => {
        if (s.light) return c.say('引き出しは空っぽだ。 光るシールが貼ってある。');
        torch.visible = true;
        await c.tween(0.35, e => { drawer.position.x = 0.31 + 0.35 * e; });
        await c.wait(0.25);
        torch.visible = false;
        s.light = true;
        const light = new THREE.PointLight(0xfff1d0, 1.6, 6, 1.5);
        light.position.set(0, 1.7, 0.3);
        c.player.body.add(light);
        c.lighting({ hemi: 0.14, sun: 0.06, bg: 0x07080a });
        c.say('引き出しに懐中電灯が入っていた！ スイッチオン。 これで周りが見える。');
      },
    });

    // ---- 電気のスイッチ（左の壁）----
    const sw = new THREE.Group();
    sw.add(place(box(0.03, 0.2, 0.14, 0xf0f1f3), 0, 0, 0));
    sw.add(place(box(0.03, 0.06, 0.04, 0xcfd3d8), 0.02, 0.02, 0));
    sw.position.set(-3.98, 1.3, 1.8);
    c.obj('switch', sw, {
      stand: [-3.1, 1.8],
      onTap: async () => c.say('電気のスイッチだ。 カチカチ…。 電球が切れているらしい。'),
    });

    // ---- ベッド ----
    const bed = makeBed(0x6b7280, 0x55606e);
    bed.position.set(-2.4, 0, -3.35);
    c.obj('bed', bed, {
      stand: [-2.4, -2.2],
      onTap: async () => c.say('ベッドだ。 毛布がひんやりしている。'),
    });

    // ---- ドアの前のバナナの皮 ----
    const banana = new THREE.Group();
    const peel = 0xf2cf3a;
    for (let i = 0; i < 4; i++) {
      const piece = ball(0.07, peel);
      piece.scale.set(3, 0.35, 1);
      piece.rotation.y = (i / 4) * Math.PI * 2 + 0.3;
      piece.position.set(Math.cos(piece.rotation.y) * 0.1, 0.02, -Math.sin(piece.rotation.y) * 0.1);
      banana.add(piece);
    }
    banana.add(place(ball(0.05, 0x8a6a2a), 0, 0.03, 0));
    banana.position.set(DX, 0.01, -2.95);
    c.obj('banana', banana, {
      stand: [DX + 0.8, -2.4],
      onTap: async () => {
        if (!s.light) return c.say('暗くてよく見えない…。 何か落ちている？');
        s.bananaGone = true;
        banana.visible = false;
        c.addItem('banana');
        c.say('バナナの皮だ！ 踏んだら大変だった…。 拾っておこう。');
      },
    });

    // ---- ドア ----
    const door = c.door(DX);
    addKeyDoor(c, door, DX, {
      lockedMsg: '鍵がかかっている。',
      onArrive: async () => {
        if (s.bananaGone) return true;
        c.say('ツルッ――');
        c.tween(0.5, e => banana.position.set(DX, 0.01 + Math.sin(e * Math.PI) * 0.8, -2.95 + 1.2 * e), c.ease.linear);
        await fallBack(c);
        stars(c);
        c.say('ドテーンッ！！');
        c.fail('ドッキリ大成功…', '暗やみに バナナの皮が落ちていた。 まずは明かりを探そう。');
        return false;
      },
    });

    // ---- ゴミ箱（鍵が入っている）----
    const bin = cyl(0.24, 0.2, 0.55, 0x5d6470, { side: THREE.DoubleSide }, 20, true);
    bin.position.set(3.2, 0.275, 1.6);
    c.obj('bin', bin, {
      stand: [2.5, 1.6],
      onTap: async () => {
        if (!s.light) return c.say('ゴミ箱…かな？ 暗くて中が見えない。');
        if (s.gotKey) return c.say('もう何も入っていない。');
        s.gotKey = true;
        c.addItem('key');
        c.say('ゴミ箱をあさったら… 鍵が出てきた！');
      },
      onItem: {
        banana: async () => {
          c.removeItem('banana');
          c.say('バナナの皮をゴミ箱に捨てた。 ゴミはゴミ箱へ。');
        },
      },
    });
  },

  hint(c) {
    const s = c.state;
    if (!s.light) return '暗やみで光っている物を調べよう。';
    if (!s.bananaGone) return 'ドアの前の床をよく照らしてみよう。 何か落ちていない？';
    if (!s.unlocked && !c.hasItem('key')) return '部屋の右手前のゴミ箱をあさってみよう。';
    if (!s.unlocked) return '鍵をドアにドラッグしよう。';
    return 'ドアを開けて脱出しよう！';
  },
});
