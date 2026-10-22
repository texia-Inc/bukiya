'use strict';

// ステージ共通の定義と部品。各 stageXX.js が STAGES に自分を追加する（読み込み順 = ステージ順）。
//
// ステージは setup(c) で部屋と「調べられる物」を作る。
//   c.obj(id, 3Dモデル, { stand: [x, z], onTap, onItem: { アイテムid: 処理 }, onArrive })
//   stand … 主人公が調べに行く立ち位置（関数でもよい）
//   onArrive … 立ち位置に着いた直後に呼ばれる。false を返すとそこで中断（ワナ用）
// hint(c) はヒントボタンで表示する文を返す。

const ITEMS = {
  key: { name: '鍵', icon: '🔑' },
};
const STAGES = [];

// ---------- ドアまわり ----------

function makeKeypad() {
  const g = new THREE.Group();
  g.add(place(box(0.26, 0.36, 0.05, 0x2d3138), 0, 0, 0));
  const led = place(box(0.18, 0.06, 0.02, 0xd94b4b, { emissive: 0xd94b4b, emissiveIntensity: 0.6 }), 0, 0.11, 0.03);
  g.add(led);
  for (let r = 0; r < 3; r++) {
    for (let q = 0; q < 3; q++) g.add(place(box(0.05, 0.04, 0.02, 0x9aa1ab), (q - 1) * 0.07, 0.02 - r * 0.06, 0.03));
  }
  return {
    group: g,
    unlock() {
      led.material.color.set(0x3cc27a);
      led.material.emissive.set(0x3cc27a);
    },
  };
}

// 奥の壁につけるテンキー。正しい番号で state.unlocked = true
function addKeypad(c, { x, y = 1.3, z = -3.97, stand, code, onArrive }) {
  const s = c.state;
  const kp = makeKeypad();
  kp.group.position.set(x, y, z);
  c.obj('keypad', kp.group, {
    stand,
    onArrive,
    onTap: async () => {
      if (s.unlocked) return c.say('ランプが緑に光っている。 鍵は開いた。');
      const v = await c.keypad(code.length);
      if (v === null) return;
      if (v === code) {
        s.unlocked = true;
        kp.unlock();
        c.sfx('unlock');
        c.say('ピッ…カチャッ。 鍵が開いた！');
      } else {
        c.sfx('buzzer');
        c.say('ブブーッ。 番号がちがうようだ。');
      }
    },
  });
  return kp;
}

async function openAndExit(c, door, x) {
  c.say('ドアを開けた！');
  c.sfx('door');
  await c.tween(0.6, e => { door.pivot.rotation.y = 1.4 * e; });
  await c.exitThrough(x);
  c.clear();
}

// 鍵で開くドア（鍵アイテムをドラッグで解錠）
function addKeyDoor(c, door, x, { onArrive, lockedMsg = '鍵がかかっている。' } = {}) {
  const s = c.state;
  c.obj('door', door.group, {
    stand: [x, -3.0],
    onArrive,
    onTap: async () => (s.unlocked ? openAndExit(c, door, x) : c.say(lockedMsg)),
    onItem: {
      key: async () => {
        c.removeItem('key');
        s.unlocked = true;
        c.sfx('unlock');
        c.say('カチャリ。 鍵が開いた！');
      },
    },
  });
}

// ---------- 主人公のリアクション ----------

// あおむけに倒れる
async function fallBack(c) {
  const b = c.player.body;
  await c.tween(0.35, e => {
    b.rotation.x = (-Math.PI / 2) * e;
    b.position.y = 0.28 * e;
  }, c.ease.in);
  c.sfx('thud');
}

// 頭の上に星が飛ぶ
function stars(c) {
  const p = c.player.root.position;
  return c.burst(new THREE.Vector3(p.x, p.y + 1.5, p.z), 0xffe14d, 12);
}

// ---------- 小道具 ----------

function makeBroom() {
  const g = new THREE.Group();
  g.add(place(cyl(0.025, 0.025, 1.5, 0xc79a5b), 0, 0.95, 0));
  g.add(place(box(0.3, 0.22, 0.08, 0xd8c27a), 0, 0.12, 0));
  return g;
}

function makeTarai() {
  const g = new THREE.Group();
  const metal = { metalness: 0.6, roughness: 0.35, side: THREE.DoubleSide };
  g.add(cyl(0.5, 0.36, 0.22, 0xc0c6cd, metal, 28, true));
  g.add(place(cyl(0.36, 0.36, 0.02, 0xc0c6cd, metal, 28), 0, -0.1, 0));
  const rim = shade(new THREE.Mesh(new THREE.TorusGeometry(0.5, 0.025, 8, 32), mat(0xaab1b9, metal)));
  rim.rotation.x = Math.PI / 2;
  g.add(place(rim, 0, 0.11, 0));
  return g;
}

// 奥の壁ぞいに置くベッド（長い辺が x 方向）
function makeBed(frame = 0x8d949e, blanket = 0xaeb7c2) {
  const g = new THREE.Group();
  g.add(place(box(2.2, 0.3, 1.1, frame), 0, 0.15, 0));
  g.add(place(box(2.1, 0.18, 1.0, 0xf7f7f7), 0, 0.39, 0));
  g.add(place(box(0.45, 0.12, 0.7, 0xffffff), -0.75, 0.54, 0));
  g.add(place(box(1.3, 0.06, 1.04, blanket), 0.38, 0.5, 0));
  return g;
}

function makePlant() {
  const g = new THREE.Group();
  g.add(place(cyl(0.25, 0.2, 0.45, 0xb8a58c), 0, 0.225, 0));
  g.add(place(ball(0.32, 0x5a9e5f), 0, 0.75, 0));
  g.add(place(ball(0.24, 0x4b8a50), 0.18, 1.0, 0.05));
  g.add(place(ball(0.2, 0x6bb070), -0.15, 1.05, -0.08));
  return g;
}

// 脚4本のテーブル（w: x方向, d: z方向）
function makeTable(w, d, h = 0.75, top = 0x9aa1ab, leg = 0x6c727c) {
  const g = new THREE.Group();
  g.add(place(box(w, 0.08, d, top), 0, h, 0));
  const lx = w / 2 - 0.08, lz = d / 2 - 0.08;
  for (const [x, z] of [[-lx, -lz], [lx, -lz], [-lx, lz], [lx, lz]]) {
    g.add(place(box(0.07, h - 0.04, 0.07, leg), x, (h - 0.04) / 2, z));
  }
  return g;
}

// 本がぎっしりの本棚（前面が +z）
function makeBookshelf(w = 1.6, h = 2.0, wood = 0x8b6b4e) {
  const g = new THREE.Group();
  g.add(place(box(w, h, 0.05, wood), 0, h / 2, -0.2));
  g.add(place(box(0.06, h, 0.45, wood), -w / 2 + 0.03, h / 2, 0));
  g.add(place(box(0.06, h, 0.45, wood), w / 2 - 0.03, h / 2, 0));
  const rows = Math.floor(h / 0.63);
  const pitch = (h - 0.05) / rows;
  for (let r = 0; r <= rows; r++) g.add(place(box(w, 0.05, 0.45, wood), 0, 0.03 + r * pitch, 0));
  const colors = [0xc9544d, 0x4d7cc9, 0xe0b04a, 0x5aa36b, 0x8a5fb0, 0xd9d4c7, 0x3f4a5a];
  const widths = [0.1, 0.12, 0.08, 0.14, 0.1, 0.09, 0.13, 0.11, 0.1, 0.12];
  for (let r = 0; r < rows; r++) {
    const y = 0.06 + r * pitch;
    let x = -w / 2 + 0.08, i = r * 3;
    while (x < w / 2 - 0.2) {
      const bw = widths[i % widths.length];
      const bh = Math.min(pitch - 0.1, 0.38 + ((i * 7) % 5) * 0.03);
      g.add(place(box(bw - 0.01, bh, 0.3, colors[i % colors.length]), x + bw / 2, y + bh / 2, 0));
      x += bw;
      i++;
    }
  }
  return g;
}
