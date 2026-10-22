'use strict';

// STAGE 5　番犬の部屋：ドアの前の犬に近づくと飛びつかれる。ボールで気をそらす

Object.assign(ITEMS, {
  ball: { name: 'ボール', icon: '🎾' },
});

function makeDog() {
  const g = new THREE.Group();
  const fur = 0xd9a066, dark = 0x8a5a33;
  g.add(place(box(0.4, 0.32, 0.7, fur), 0, 0.42, 0));
  for (const [x, z] of [[-0.13, 0.25], [0.13, 0.25], [-0.13, -0.25], [0.13, -0.25]]) {
    g.add(place(box(0.1, 0.28, 0.1, fur), x, 0.14, z));
  }
  g.add(place(box(0.32, 0.06, 0.12, 0xd94b4b), 0, 0.6, 0.3));
  const head = place(new THREE.Group(), 0, 0.72, 0.38);
  head.add(place(box(0.34, 0.3, 0.32, fur), 0, 0, 0));
  head.add(place(box(0.18, 0.13, 0.16, 0xf1d2a8), 0, -0.06, 0.2));
  head.add(place(ball(0.035, 0x222222), 0, -0.02, 0.29));
  head.add(place(ball(0.03, 0x222222), -0.09, 0.06, 0.165), place(ball(0.03, 0x222222), 0.09, 0.06, 0.165));
  const earL = place(box(0.08, 0.15, 0.05, dark), -0.15, 0.12, -0.02);
  earL.rotation.z = 0.3;
  const earR = place(box(0.08, 0.15, 0.05, dark), 0.15, 0.12, -0.02);
  earR.rotation.z = -0.3;
  head.add(earL, earR);
  g.add(head);
  const tail = place(new THREE.Group(), 0, 0.55, -0.35);
  const tailMesh = place(cyl(0.03, 0.04, 0.3, dark), 0, 0.12, -0.05);
  tailMesh.rotation.x = -0.5;
  tail.add(tailMesh);
  g.add(tail);
  return { group: g, head, tail };
}

STAGES.push({
  title: 'STAGE 5　番犬の部屋',
  intro: 'ハッハッハッ…。 ドアの前に、何かいる。',

  setup(c) {
    const s = c.state;
    const DX = 0.4;
    c.room({ floor: 0xd8d2c6, wall: 0xf1ece2, trim: 0xb5ab98, line: 0xbdb3a1, door: { x: DX } });
    c.player.root.position.set(-0.6, 0, 2.2);
    c.player.root.rotation.y = Math.PI;

    // ---- 犬 ----
    const dog = makeDog();
    dog.group.position.set(DX, 0, -3.35);
    c.update(t => {
      dog.tail.rotation.z = Math.sin(t * 12) * 0.5;
      if (!s.dogAway) dog.head.rotation.z = Math.sin(t * 1.5) * 0.12;
    });

    const pounce = async () => {
      c.say('ワンワンッ！！');
      const p = c.player.root.position, d = dog.group.position;
      const sx = d.x, sz = d.z;
      await c.tween(0.3, e => {
        d.x = sx + (p.x - sx) * e * 0.7;
        d.z = sz + (p.z - sz) * e * 0.7;
        d.y = Math.sin(e * Math.PI) * 0.6;
      });
      await fallBack(c);
      c.update(t => { dog.head.rotation.x = Math.sin(t * 20) * 0.3; });
      c.say('ペロペロペロペロ…！！');
      c.fail('ドッキリ大成功…', 'ワンちゃんのペロペロ攻撃で動けない…。 気をそらせる物はないかな？');
      return false;
    };
    const guard = async () => (s.dogAway ? true : pounce());

    c.obj('dog', dog.group, {
      stand: () => (s.dogAway ? [2.4, 1.8] : [DX, -1.8]),
      onTap: async () => {
        if (s.dogAway) return c.say('ボールに夢中で、こっちには見向きもしない。');
        s.dogTaps = (s.dogTaps || 0) + 1;
        if (s.dogTaps === 1) c.say('人なつっこそうな犬がドアの前でおすわりしている。 近づいたら飛びつかれそう…。');
        else c.say('しっぽをブンブン振っている。 遊んでほしいみたいだ。');
      },
      onItem: {
        ball: async () => {
          c.removeItem('ball');
          s.dogAway = true;
          const p = c.player.root.position;
          const b = place(ball(0.12, 0xc8e04a), p.x, 1.0, p.z);
          c.root.add(b);
          const tx = 3.2, tz = 2.9;
          c.say('それっ！ ボールを投げた！');
          await c.tween(0.7, e => b.position.set(
            p.x + (tx - p.x) * e,
            1.0 + Math.sin(e * Math.PI) * 1.5 - 0.88 * e,
            p.z + (tz - p.z) * e,
          ), c.ease.linear);
          const d = dog.group.position, sx = d.x, sz = d.z;
          const ex = tx - 0.3, ez = tz - 0.7;
          dog.group.rotation.y = Math.atan2(ex - sx, ez - sz);
          await c.tween(1.0, (e, t) => {
            d.x = sx + (ex - sx) * t;
            d.z = sz + (ez - sz) * t;
            d.y = Math.abs(Math.sin(t * Math.PI * 6)) * 0.15;
          }, c.ease.linear);
          d.y = 0;
          c.say('犬は大喜びでボールを追いかけていった！');
        },
      },
    });

    // ---- ドアとテンキー（どちらも犬のすぐ近く）----
    const door = c.door(DX);
    addKeypad(c, { x: DX + 0.85, stand: [DX + 0.85, -2.6], code: '1122', onArrive: guard });
    c.obj('door', door.group, {
      stand: [DX, -2.6],
      onArrive: guard,
      onTap: async () => (s.unlocked ? openAndExit(c, door, DX) : c.say('鍵がかかっている。 横にテンキーがある。')),
    });

    // ---- おもちゃ箱（左の壁ぞい）----
    const toy = new THREE.Group();
    toy.add(place(box(0.8, 0.5, 0.6, 0x4d7cc9), 0, 0.25, 0));
    toy.add(place(box(0.81, 0.08, 0.61, 0xe0b04a), 0, 0.12, 0));
    const lid = place(new THREE.Group(), -0.4, 0.5, 0);
    lid.add(place(box(0.84, 0.06, 0.64, 0xd94b4b), 0.42, 0.03, 0));
    toy.add(lid);
    const toyBall = place(ball(0.12, 0xc8e04a), 0.1, 0.45, 0);
    toy.add(toyBall);
    toy.position.set(-3.5, 0, 2.0);
    c.obj('toyBox', toy, {
      stand: [-2.6, 2.0],
      onTap: async () => {
        if (s.gotBall) return c.say('ぬいぐるみしか残っていない。');
        s.gotBall = true;
        await c.tween(0.35, e => { lid.rotation.z = 1.7 * e; });
        await c.wait(0.25);
        toyBall.visible = false;
        c.addItem('ball');
        c.say('おもちゃ箱にボールが入っていた。');
      },
    });

    // ---- 犬小屋と表札 ----
    const house = new THREE.Group();
    house.add(place(box(1.0, 0.7, 0.9, 0xb5653f), 0, 0.35, 0));
    house.add(place(box(0.4, 0.5, 0.02, 0x2a1b12), 0, 0.27, 0.451));
    const roofL = place(box(0.65, 0.06, 1.0, 0x6b3f2a), -0.25, 0.86, 0);
    roofL.rotation.z = 0.6;
    const roofR = place(box(0.65, 0.06, 1.0, 0x6b3f2a), 0.25, 0.86, 0);
    roofR.rotation.z = -0.6;
    house.add(roofL, roofR);
    house.add(place(textPlane('ポチ\n11.22 生まれ', 0.5, 0.2), 0, 0.6, 0.452));
    house.position.set(3.0, 0, -3.3);
    c.obj('doghouse', house, {
      stand: [3.0, -2.2],
      onTap: async () => c.say('犬小屋だ。 表札に「ポチ　11.22 生まれ」と書いてある。'),
    });

    const bowl = new THREE.Group();
    bowl.add(cyl(0.2, 0.15, 0.1, 0xd94b4b, { side: THREE.DoubleSide }, 20, true));
    bowl.add(place(cyl(0.15, 0.15, 0.01, 0xd94b4b), 0, -0.045, 0));
    bowl.position.set(2.1, 0.05, -2.9);
    c.obj('bowl', bowl, {
      stand: [2.1, -2.2],
      onTap: async () => c.say('ドッグフードのお皿。 ピカピカに なめ尽くされている。'),
    });
  },

  hint(c) {
    const s = c.state;
    if (!s.dogAway && !c.hasItem('ball')) return 'ドアの前の犬…近づくと飛びつかれそう。 気をそらせる物を探そう。 おもちゃ箱は？';
    if (!s.dogAway) return 'ボールを犬にドラッグして投げてみよう。';
    if (!s.unlocked) return '犬の誕生日を、4ケタでテンキーに入力しよう。 犬小屋を調べてみて。';
    return 'ドアを開けて脱出しよう！';
  },
});
