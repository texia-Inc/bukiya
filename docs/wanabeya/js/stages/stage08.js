'use strict';

// STAGE 8　だまし絵の部屋：見えているドアは壁に描かれた絵。本物の出口は本棚の向こう

STAGES.push({
  title: 'STAGE 8　だまし絵の部屋',
  intro: 'やっと出口が見えた！ …でも、あのドア、なんだか平べったくない？',

  setup(c) {
    const s = c.state;
    const DX = 2.2;        // 本物のドア（本棚の裏）
    const FX = -1.4;       // 絵のドア
    c.room({ floor: 0xd9d6d0, wall: 0xedeae4, trim: 0xaea89d, line: 0xbab4a9, door: { x: DX } });
    c.player.root.position.set(0.2, 0, 2.2);
    c.player.root.rotation.y = Math.PI;

    // ---- 壁に描かれたドア ----
    const painted = canvasPlane(1.3, 2.4, (g, W, H) => {
      g.fillStyle = '#edeae4';
      g.fillRect(0, 0, W, H);
      const fx = W * 0.04, fy = H * 0.07;
      g.fillStyle = '#5d6470';
      g.fillRect(fx, fy, W - fx * 2, H - fy);
      const px = W * 0.1, py = H * 0.1;
      const grad = g.createLinearGradient(px, 0, W - px, 0);
      grad.addColorStop(0, '#9aa3ad');
      grad.addColorStop(1, '#7f8893');
      g.fillStyle = grad;
      g.fillRect(px, py, W - px * 2, H - py);
      g.strokeStyle = 'rgba(0,0,0,0.18)';
      g.lineWidth = 12;
      g.strokeRect(px + W * 0.08, py + H * 0.06, W - px * 2 - W * 0.16, H * 0.32);
      g.strokeRect(px + W * 0.08, py + H * 0.45, W - px * 2 - W * 0.16, H * 0.38);
      g.fillStyle = '#d0d4da';
      g.beginPath();
      g.arc(W * 0.78, H * 0.58, W * 0.045, 0, Math.PI * 2);
      g.fill();
    });
    painted.position.set(FX, 1.2, -3.99);
    c.obj('fakeDoor', painted, {
      stand: [FX, -3.0],
      onTap: async () => {
        c.say('よし、出口だ！');
        const p = c.player.root.position;
        await c.tween(0.2, e => { p.z = -3.0 - 0.5 * e; }, c.ease.in);
        c.sfx('bonk');
        stars(c);
        c.say('ゴンッ！！');
        await c.tween(0.2, e => { p.z = -3.5 + 0.4 * e; });
        await fallBack(c);
        c.fail('ドッキリ大成功…', 'それは壁に描かれた ドアの絵だった…。 よく見ると、ドアノブに影がない。');
      },
    });

    // ---- 本物のドアとテンキー（最初は本棚に隠れている）----
    const door = c.door(DX, 0x8a929e);
    addKeypad(c, { x: DX - 0.85, stand: [DX - 0.85, -3.0], code: '1852' });
    c.obj('door', door.group, {
      stand: [DX, -3.0],
      onTap: async () => (s.unlocked ? openAndExit(c, door, DX) : c.say('本物のドアだ！ 鍵がかかっている。 横にテンキーがある。')),
    });

    // ---- 本棚（1冊だけ飛び出している）----
    const SHIFT = 1.95;
    const shelf = makeBookshelf(1.9, 2.5);
    const sticking = place(box(0.1, 0.4, 0.3, 0xd94b4b), 0.3, 1.0, 0.12);
    shelf.add(sticking);
    shelf.position.set(DX, 0, -3.72);
    c.obj('shelf', shelf, {
      stand: () => (s.shelfMoved ? [DX - SHIFT, -2.6] : [DX, -2.6]),
      onTap: async () => {
        if (s.shelfMoved) return c.say('本がぎっしり並んでいる。');
        c.say('1冊だけ飛び出している本がある…。 押しこんでみた。');
        await c.tween(0.3, e => { sticking.position.z = 0.12 - 0.12 * e; });
        c.sfx('click');
        await c.wait(0.3);
        c.say('ゴゴゴゴゴ……');
        c.sfx('rumble');
        await c.tween(1.4, e => { shelf.position.x = DX - SHIFT * e; }, c.ease.inOut);
        s.shelfMoved = true;
        c.say('本棚が動いて、奥から本物のドアが現れた！');
      },
    });

    // ---- 風景画（左の壁）----
    const painting = new THREE.Group();
    painting.add(place(box(0.05, 0.9, 1.2, 0x8b6b4e), 0, 0, 0));
    const art = canvasPlane(1.1, 0.8, (g, W, H) => {
      const sky = g.createLinearGradient(0, 0, 0, H);
      sky.addColorStop(0, '#8ec5ef');
      sky.addColorStop(1, '#d9eefb');
      g.fillStyle = sky;
      g.fillRect(0, 0, W, H);
      g.fillStyle = '#6aa86f';
      g.beginPath();
      g.moveTo(0, H);
      g.lineTo(W * 0.3, H * 0.55);
      g.lineTo(W * 0.55, H * 0.75);
      g.lineTo(W * 0.8, H * 0.5);
      g.lineTo(W, H * 0.7);
      g.lineTo(W, H);
      g.fill();
      g.fillStyle = 'rgba(255,255,255,0.95)';
      g.font = `800 ${H * 0.2}px 'M PLUS Rounded 1c', sans-serif`;
      g.textAlign = 'center';
      g.textBaseline = 'middle';
      ['2', '5', '8', '1'].forEach((d, i) => g.fillText(d, W * (0.2 + i * 0.2), H * (0.2 + (i % 2) * 0.1)));
    });
    art.rotation.y = Math.PI / 2;
    painting.add(place(art, 0.03, 0, 0));
    painting.position.set(-3.97, 1.7, -0.6);
    c.obj('painting', painting, {
      stand: [-3.0, -0.6],
      onTap: async () => {
        c.say('風景画だ。 空の雲が「2 5 8 1」の形に見える…。');
        await c.closeup(art, '風景画');
      },
    });

    // ---- メモの乗った小さなテーブル ----
    const table = makeTable(0.7, 0.7, 0.7, 0xb7a78f, 0x7d6b55);
    const memo = place(box(0.3, 0.012, 0.22, 0xfdfdf8), 0, 0.746, 0);
    memo.rotation.y = -0.4;
    table.add(memo);
    table.position.set(-2.6, 0, 2.0);
    c.obj('memo', table, {
      stand: [-1.8, 2.0],
      onTap: async () => {
        s.readMemo = true;
        c.say('メモ：「本物の出口は 本の向こう。 番号は 絵の数字を 逆から」');
        await c.closeup(textCanvas('本物の出口は 本の向こう。\n番号は\n絵の数字を 逆から', 1.2, 0.9), 'メモ');
      },
    });
  },

  hint(c) {
    const s = c.state;
    if (!s.readMemo && !s.shelfMoved) return 'あのドア、なんだか平べったい…？ まずは部屋のメモを読んでみよう。';
    if (!s.shelfMoved) return 'メモの通り「本の向こう」…。 本棚を調べてみよう。';
    if (!s.unlocked) return '左の壁の絵の数字を逆から読んで、テンキーに入力しよう。';
    return '本物のドアから脱出しよう！';
  },
});
