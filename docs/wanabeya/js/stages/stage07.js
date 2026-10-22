'use strict';

// STAGE 7　びっくり箱の部屋：鍵はプレゼントの箱の中。素手で開けるとパンチが飛んでくる

Object.assign(ITEMS, {
  magicHand: { name: 'マジックハンド', icon: '🦾' },
});

STAGES.push({
  title: 'STAGE 7　びっくり箱の部屋',
  intro: '色とりどりの風船… パーティー会場みたいな部屋だ。',

  setup(c) {
    const s = c.state;
    const DX = 1.5;
    c.room({ floor: 0xe0d9e6, wall: 0xf4eff7, trim: 0xb9aec4, line: 0xc4b9cf, door: { x: DX } });
    c.player.root.position.set(2.2, 0, 2.2);
    c.player.root.rotation.y = Math.PI;

    // ---- 丸テーブルとプレゼントの箱 ----
    const TX = -0.6, TZ = -0.6;
    const table = new THREE.Group();
    table.add(place(cyl(0.65, 0.65, 0.06, 0xf2f2f2), 0, 0.74, 0));
    table.add(place(cyl(0.06, 0.06, 0.72, 0x9aa1ab), 0, 0.36, 0));
    table.add(place(cyl(0.3, 0.3, 0.04, 0x9aa1ab), 0, 0.02, 0));
    table.position.set(TX, 0, TZ);
    c.root.add(table);

    const present = place(new THREE.Group(), TX, 0.77, TZ);
    present.add(place(box(0.44, 0.36, 0.44, 0xd94b4b), 0, 0.18, 0));
    present.add(place(box(0.08, 0.365, 0.445, 0xffd84a), 0, 0.18, 0));
    present.add(place(box(0.445, 0.365, 0.08, 0xffd84a), 0, 0.18, 0));
    const lid = place(new THREE.Group(), 0, 0.36, 0);
    lid.add(place(box(0.48, 0.08, 0.48, 0xd94b4b), 0, 0.04, 0));
    lid.add(place(box(0.08, 0.085, 0.485, 0xffd84a), 0, 0.04, 0));
    lid.add(place(box(0.485, 0.085, 0.08, 0xffd84a), 0, 0.04, 0));
    lid.add(place(ball(0.07, 0xffd84a), -0.06, 0.12, 0), place(ball(0.07, 0xffd84a), 0.06, 0.12, 0));
    present.add(lid);
    const tag = textPlane('あけてね♡', 0.3, 0.12, { fg: '#d94b4b' });
    tag.position.set(0, 0.2, 0.226);
    present.add(tag);
    const keyIn = place(box(0.18, 0.04, 0.06, 0xe8b923, { metalness: 0.7, roughness: 0.3 }), 0, 0.38, 0);
    keyIn.visible = false;
    present.add(keyIn);

    // バネつきグローブ（world 座標で動かす）
    const glove = ball(0.17, 0xe0474c);
    glove.scale.set(1, 0.85, 1.2);
    glove.visible = false;
    const spring = cyl(0.03, 0.03, 1, 0xb0b5bd, { metalness: 0.6 }, 8);
    spring.visible = false;
    c.root.add(glove, spring);
    const base = new THREE.Vector3(TX, 1.2, TZ);
    const up = new THREE.Vector3(0, 1, 0);
    const setGlove = pos => {
      glove.position.copy(pos);
      const dir = new THREE.Vector3().subVectors(pos, base);
      spring.position.copy(base).addScaledVector(dir, 0.5);
      spring.scale.y = Math.max(0.01, dir.length());
      spring.quaternion.setFromUnitVectors(up, dir.normalize());
    };

    const STAND = [TX + 0.85, TZ + 0.85];
    const faceAt = new THREE.Vector3(STAND[0] - 0.2, 1.15, STAND[1] - 0.2);

    // ふたが飛び、グローブが reach（0〜1）の所まで伸びる
    const springOut = async reach => {
      c.say('ボヨヨーーンッ！！');
      c.sfx('boing');
      c.tween(0.3, e => { lid.position.y = 0.36 + 0.6 * e; lid.rotation.x = -1.2 * e; });
      glove.visible = spring.visible = true;
      const target = new THREE.Vector3().lerpVectors(base, faceAt, reach);
      await c.tween(0.15, e => setGlove(new THREE.Vector3().lerpVectors(base, target, e)), c.ease.out);
      c.update(t => setGlove(target.clone().add(new THREE.Vector3(0, Math.sin(t * 14) * 0.05, 0))));
    };

    c.obj('present', present, {
      stand: STAND,
      onTap: async () => {
        if (s.boxOpen) {
          if (s.gotKey) return c.say('空っぽの びっくり箱だ。');
          s.gotKey = true;
          keyIn.visible = false;
          c.addItem('key');
          return c.say('グローブをよけて、箱の中の鍵を取り出した！');
        }
        s.boxTaps = (s.boxTaps || 0) + 1;
        if (s.boxTaps === 1) {
          c.say('プレゼントの箱だ。 「あけてね♡」…。 耳をすますと、中から「ビヨン…」と音がする。');
          return c.closeup(tag, 'プレゼントの札');
        }
        await springOut(1);
        c.sfx('bonk');
        stars(c);
        await fallBack(c);
        c.fail('ドッキリ大成功…', 'びっくり箱のパンチが顔面に…。 離れたところから開けられないかな？');
      },
      onItem: {
        magicHand: async () => {
          c.removeItem('magicHand');
          const hand = new THREE.Group();
          hand.add(place(cyl(0.02, 0.02, 1.0, 0xffd84a), 0, 0.5, 0));
          hand.add(place(box(0.12, 0.06, 0.06, 0xe0474c), 0, 1.02, 0));
          hand.position.set(0.2, 0.75, 0.15);
          c.player.body.add(hand);
          await c.tween(0.3, e => { hand.rotation.x = 1.3 * e; });
          await springOut(0.45);
          s.boxOpen = true;
          keyIn.visible = true;
          await c.wait(0.4);
          c.player.body.remove(hand);
          c.say('マジックハンドで開けたら、パンチが空振りした！ 箱の中に鍵が見える。');
        },
      },
    });

    // ---- クローゼット（左の壁ぞい）----
    const closet = new THREE.Group();
    closet.add(place(box(0.7, 2.1, 1.2, 0xa6805e), 0, 1.05, 0));
    closet.add(place(box(0.02, 1.95, 1.1, 0x3a2a20), 0.351, 1.05, 0));
    const doorL = place(new THREE.Group(), 0.37, 0, -0.6);
    doorL.add(place(box(0.04, 1.95, 0.59, 0xb78f6a), 0, 1.05, 0.295));
    doorL.add(place(box(0.03, 0.2, 0.03, 0xd9d4c7), 0.035, 1.05, 0.52));
    const doorR = place(new THREE.Group(), 0.37, 0, 0.6);
    doorR.add(place(box(0.04, 1.95, 0.59, 0xb78f6a), 0, 1.05, -0.295));
    doorR.add(place(box(0.03, 0.2, 0.03, 0xd9d4c7), 0.035, 1.05, -0.52));
    closet.add(doorL, doorR);
    const handIn = new THREE.Group();
    handIn.add(place(cyl(0.02, 0.02, 1.0, 0xffd84a), 0, 0.6, 0), place(box(0.12, 0.06, 0.06, 0xe0474c), 0, 1.12, 0));
    handIn.position.set(0.25, 0, 0);
    handIn.visible = false;
    closet.add(handIn);
    closet.position.set(-3.6, 0, 1.6);
    c.obj('closet', closet, {
      stand: [-2.5, 1.6],
      onTap: async () => {
        if (s.closetOpen) return c.say('パーティー用の帽子しか残っていない。');
        s.closetOpen = true;
        handIn.visible = true;
        c.sfx('door');
        await c.tween(0.45, e => { doorL.rotation.y = 1.6 * e; doorR.rotation.y = -1.6 * e; });
        await c.wait(0.3);
        handIn.visible = false;
        c.addItem('magicHand');
        c.say('クローゼットの中に マジックハンドがあった。');
      },
    });

    // ---- ドア ----
    const door = c.door(DX, 0xc77fa0);
    addKeyDoor(c, door, DX);

    // ---- 風船 ----
    const balloons = new THREE.Group();
    [[0, 1.9, 0, 0xe0474c], [0.35, 2.1, 0.1, 0x4d7cc9], [-0.3, 2.0, 0.15, 0xffd84a], [0.1, 2.3, -0.2, 0x5aa36b]].forEach(([x, y, z, col]) => {
      const b = ball(0.22, col, { roughness: 0.3 });
      b.scale.y = 1.15;
      balloons.add(place(b, x, y, z));
      balloons.add(rod(new THREE.Vector3(x, y - 0.25, z), new THREE.Vector3(0, 0.2, 0), 0.006, 0xdddddd));
    });
    balloons.add(place(box(0.2, 0.2, 0.2, 0x9aa1ab), 0, 0.1, 0));
    balloons.position.set(-3.0, 0, -3.0);
    c.obj('balloons', balloons, {
      stand: [-2.2, -2.2],
      onTap: async () => {
        c.sfx('rustle');
        c.say('風船だ。 割ったらびっくりしそう…。 そっとしておこう。');
      },
    });
  },

  hint(c) {
    const s = c.state;
    if (!s.boxOpen && !c.hasItem('magicHand')) return 'プレゼントの箱… 中から変な音がする。 離れて開けられる道具を探そう。 クローゼットは？';
    if (!s.boxOpen) return 'マジックハンドをプレゼントの箱にドラッグしよう。';
    if (!s.unlocked && !c.hasItem('key')) return '箱の中の鍵を取ろう。';
    if (!s.unlocked) return '鍵をドアにドラッグしよう。';
    return 'ドアを開けて脱出しよう！';
  },
});
