# Turns the pixiv VRM sample (VRM1_Constraint_Twist_Sample, modification and redistribution allowed) into the Umimachi heroine:
# long hair -> high ponytail with a scrunchie, shorter side locks, navy hoodie over a white shirt with a red bow, plaid skirt,
# black socks with a pink band, pink sneakers, amber eyes, a backpack with a bunny charm and a pink X hair clip.
# Blender works z-up with the model facing -y. Usage: python heroine_vrm.py -- in.glb out.glb
import bpy, bmesh, math, sys, os
import numpy as np
from mathutils import Vector

args = sys.argv[sys.argv.index('--') + 1:] if '--' in sys.argv else ['a.glb', 'heroine.glb']
SRC, OUT = args[0], args[1]

for o in list(bpy.data.objects):
    bpy.data.objects.remove(o)
bpy.ops.import_scene.gltf(filepath=SRC)
ARM = bpy.data.objects['Root']
BODY, FACE, HAIR = bpy.data.objects['Body'], bpy.data.objects['Face'], bpy.data.objects['Hair']
for n in ('Icosphere',):
    if n in bpy.data.objects:
        bpy.data.objects.remove(bpy.data.objects[n])

def ss(a, b, x):
    t = max(0.0, min(1.0, (x - a) / (b - a)))
    return t * t * (3 - 2 * t)

def dominant(ob):
    names = {g.index: g.name for g in ob.vertex_groups}
    out = []
    for v in ob.data.vertices:
        out.append(names[max(v.groups, key=lambda g: g.weight).group] if v.groups else '')
    return out

# ---------------------------------------------------------------- hair
dom = dominant(HAIR)
chain = [int(n.rsplit('_', 1)[1]) if n.startswith('J_Sec_Hair') else 0 for n in dom]
bm = bmesh.new(); bm.from_mesh(HAIR.data); bm.verts.ensure_lookup_table()
# the long back and side curtain (chains 5-10) goes: it becomes the ponytail
kill = [bm.verts[i] for i, c in enumerate(chain) if 5 <= c <= 10]
# side locks (chains 11, 12) stop at the jaw instead of the chest
roots = {}
for b in ARM.data.bones:
    if b.name in ('J_Sec_Hair1_11', 'J_Sec_Hair1_12'):
        roots[int(b.name[-2:])] = b.head_local.copy()
dl = bm.verts.layers.deform.active
names = {g.name: g.index for g in HAIR.vertex_groups}
side_ids = {names[n] for n in names if n.startswith('J_Sec_Hair') and n[-2:] in ('11', '12')}
for v in bm.verts:
    w = sum(wt for gi, wt in v[dl].items() if gi in side_ids)
    if w > 0.01:
        k = 11 if v.co.x < 0 else 12
        r = roots[k]
        d = v.co - r
        if d.z < 0:
            f = 1 - 0.5 * w
            v.co = Vector((r.x + d.x * (0.75 + 0.25 * f), r.y + d.y * f, r.z + d.z * f))
bmesh.ops.delete(bm, geom=kill, context='VERTS')
bm.to_mesh(HAIR.data); bm.free()

# ---------------------------------------------------------------- ponytail with its own bones
HEAD = ARM.data.bones['J_Bip_C_Head']
TIE = Vector((0.0, 0.112, 1.548))
PATH = [TIE, Vector((0, 0.17, 1.565)), Vector((0, 0.215, 1.49)), Vector((0, 0.215, 1.36)), Vector((0, 0.185, 1.2))]

def catmull(pts, n):
    P = [pts[0] * 2 - pts[1]] + pts + [pts[-1] * 2 - pts[-2]]
    segs = len(pts) - 1
    out = []
    for i in range(n):
        t = i / (n - 1) * segs
        k = min(int(t), segs - 1); u = t - k
        p0, p1, p2, p3 = P[k], P[k + 1], P[k + 2], P[k + 3]
        out.append(0.5 * ((2 * p1) + (-p0 + p2) * u + (2 * p0 - 5 * p1 + 4 * p2 - p3) * u * u + (-p0 + 3 * p1 - 3 * p2 + p3) * u ** 3))
    return out

bpy.context.view_layer.objects.active = ARM
bpy.ops.object.mode_set(mode='EDIT')
eb = ARM.data.edit_bones
par = eb['J_Bip_C_Head']
TAIL_BONES = []
for i in range(4):
    b = eb.new('Tail%d' % i)
    b.head = PATH[i]; b.tail = PATH[i + 1]; b.parent = par; b.use_connect = i > 0
    par = b; TAIL_BONES.append(b.name)
bpy.ops.object.mode_set(mode='OBJECT')

N = 40
axis = catmull(PATH, N)
seglen = [0]
for i in range(1, N):
    seglen.append(seglen[-1] + (axis[i] - axis[i - 1]).length)
L = seglen[-1]

def radius(s):
    return (0.026 + 0.03 * math.sin(math.pi * min(1, s * 1.25)) ** 0.7) * (1 - ss(0.7, 1.0, s) * 0.85)

bm = bmesh.new()
uvl = bm.loops.layers.uv.new('UVMap')
dfl = bm.verts.layers.deform.new()
pt = bpy.data.objects.new('Ponytail', bpy.data.meshes.new('Ponytail'))
bpy.context.collection.objects.link(pt)
vg = [pt.vertex_groups.new(name=n) for n in TAIL_BONES]
vgh = pt.vertex_groups.new(name='J_Bip_C_Head')
STR = 14
RING = 6
for k in range(STR + 1):
    core = k == STR
    a0 = 2 * math.pi * k / STR
    u0 = (k % 4) * 0.25
    rings = []
    for i in range(N):
        s = seglen[i] / L
        P = axis[i]
        T = (axis[min(i + 1, N - 1)] - axis[max(i - 1, 0)]).normalized()
        side = Vector((1, 0, 0))
        nrm = T.cross(side).normalized()
        a = a0 + 1.1 * s + 0.15 * math.sin(k * 1.7)
        rr = radius(s) * (0 if core else 0.62) * (1 + 0.6 * ss(0.75, 1, s) * (0.5 + 0.5 * math.sin(k * 2.3)))
        C = P + (side * math.cos(a) + nrm * math.sin(a)) * rr
        outward = (C - P).normalized() if not core else nrm
        B = T.cross(outward).normalized()
        w = radius(s) * (1.0 if core else 0.55) * (1 - 0.92 * ss(0.55 + 0.1 * math.sin(k), 1.0, s))
        th = w * 0.35
        ring = []
        for j in range(RING):
            ang = 2 * math.pi * j / RING
            v = bm.verts.new(C + B * math.cos(ang) * w + outward * math.sin(ang) * th)
            seg = min(3.999, s * 4)
            bi = int(seg); f = seg - bi
            # blend each segment into the next so the bend is smooth
            if f < 0.5 and bi > 0:
                v[dfl][bi] = 0.5 + f; v[dfl][bi - 1] = 0.5 - f
            elif f >= 0.5 and bi < 3:
                v[dfl][bi] = 1.5 - f; v[dfl][bi + 1] = f - 0.5
            else:
                v[dfl][bi] = 1.0
            ring.append(v)
        rings.append((ring, s))
    for i in range(N - 1):
        ra, sa = rings[i]; rb, sb = rings[i + 1]
        for j in range(RING):
            f = bm.faces.new((ra[j], ra[(j + 1) % RING], rb[(j + 1) % RING], rb[j]))
            for l, (jj, s) in zip(f.loops, ((j, sa), (j + 1, sa), (j + 1, sb), (j, sb))):
                l[uvl].uv = (u0 + 0.22 * (jj / RING), 0.98 - 0.94 * s)
bm.to_mesh(pt.data); bm.free()
pt.data.materials.append(HAIR.data.materials[0])
pt.parent = ARM
m = pt.modifiers.new('Armature', 'ARMATURE'); m.object = ARM
for p in pt.data.polygons:
    p.use_smooth = True

# ---------------------------------------------------------------- helpers for rigid accessories (weighted 100% to one bone)
def mat(name, col, rough=0.8):
    m = bpy.data.materials.new(name); m.use_nodes = True
    b = m.node_tree.nodes['Principled BSDF']; b.inputs['Base Color'].default_value = (*col, 1); b.inputs['Roughness'].default_value = rough
    return m

def srgb(h):
    h = h.lstrip('#'); c = [int(h[i:i + 2], 16) / 255 for i in (0, 2, 4)]
    return tuple(x / 12.92 if x <= 0.04045 else ((x + 0.055) / 1.055) ** 2.4 for x in c)

def accessory(name, bm, bone, material, smooth=True):
    me = bpy.data.meshes.new(name); bm.to_mesh(me); bm.free()
    ob = bpy.data.objects.new(name, me); bpy.context.collection.objects.link(ob)
    ob.data.materials.append(material)
    g = ob.vertex_groups.new(name=bone); g.add(range(len(me.vertices)), 1.0, 'REPLACE')
    ob.parent = ARM; mm = ob.modifiers.new('Armature', 'ARMATURE'); mm.object = ARM
    for p in me.polygons:
        p.use_smooth = smooth
    return ob

def xform(bm, scale=(1, 1, 1), rot=None, loc=(0, 0, 0)):
    from mathutils import Matrix, Euler
    M = Matrix.Translation(loc) @ (Euler(rot).to_matrix().to_4x4() if rot else Matrix()) @ Matrix.Diagonal((*scale, 1))
    bmesh.ops.transform(bm, matrix=M, verts=bm.verts)

PINK = mat('Accent_Pink', srgb('#ef6f8a'))
SCRUNCH = mat('Scrunchie', srgb('#d8455a'))
NAVY = mat('Hoodie_Navy', srgb('#2a2d45'))
RED = mat('Bow_Red', srgb('#c8323a'))
BLACK = mat('Pack_Black', srgb('#232327'))
BUNNY = mat('Bunny_Pink', srgb('#f7a6bd'))
DARK = mat('Dark', srgb('#2e2e33'))

# scrunchie at the tie
bm = bmesh.new()
for i in range(18):
    a = 2 * math.pi * i / 18
    for j in range(8):
        b = 2 * math.pi * j / 8
        r = 0.034 + 0.016 * math.cos(b) * (1 + 0.15 * math.sin(a * 5))
        bm.verts.new((r * math.cos(a), r * math.sin(a), 0.016 * math.sin(b)))
bm.verts.ensure_lookup_table()
for i in range(18):
    for j in range(8):
        q = [bm.verts[((i + di) % 18) * 8 + (j + dj) % 8] for di, dj in ((0, 0), (1, 0), (1, 1), (0, 1))]
        bm.faces.new(q)
d = (PATH[1] - PATH[0]).normalized()
xform(bm, rot=(math.pi / 2 - math.atan2(d.z, d.y), 0, 0), loc=TIE + d * 0.012)
accessory('Scrunchie', bm, 'J_Bip_C_Head', SCRUNCH)

# pink X clip on the left of the bangs
for s in (-1, 1):
    bm = bmesh.new(); bmesh.ops.create_cube(bm, size=1.0)
    xform(bm, scale=(0.04, 0.007, 0.009), rot=(0, s * 0.785, 0))
    xform(bm, rot=(0.25, 0, -0.55), loc=(0.078, -0.072, 1.545))
    accessory('ClipX%d' % (s + 1), bm, 'J_Bip_C_Head', PINK, smooth=False)

# red bow at the collar
for s in (-1, 1):
    bm = bmesh.new(); bmesh.ops.create_uvsphere(bm, u_segments=12, v_segments=8, radius=1.0)
    xform(bm, scale=(0.027, 0.012, 0.017), loc=(s * 0.027, -0.088, 1.262))
    accessory('BowL%d' % (s + 1), bm, 'J_Bip_C_UpperChest', RED)
    bm = bmesh.new(); bmesh.ops.create_cube(bm, size=1.0)
    xform(bm, scale=(0.014, 0.005, 0.045), rot=(0, s * 0.35, 0), loc=(s * 0.013, -0.09, 1.232))
    accessory('BowT%d' % (s + 1), bm, 'J_Bip_C_UpperChest', RED, smooth=False)
bm = bmesh.new(); bmesh.ops.create_uvsphere(bm, u_segments=10, v_segments=6, radius=0.011); xform(bm, loc=(0, -0.092, 1.262))
accessory('BowK', bm, 'J_Bip_C_UpperChest', RED)

# hood lying on the shoulders behind the neck
bm = bmesh.new()
for i in range(13):
    a = math.pi * (0.1 + 0.8 * i / 12)          # half ring around the back of the neck
    for j in range(8):
        b = 2 * math.pi * j / 8
        R = 0.105 + 0.03 * math.cos(b)
        bm.verts.new((R * math.cos(a), 0.035 + R * math.sin(a) * 0.95, 1.33 + 0.028 * math.sin(b) + 0.02 * math.sin(a)))
bm.verts.ensure_lookup_table()
for i in range(12):
    for j in range(8):
        bm.faces.new([bm.verts[(i + di) * 8 + (j + dj) % 8] for di, dj in ((0, 0), (1, 0), (1, 1), (0, 1))])
accessory('Hood', bm, 'J_Bip_C_UpperChest', NAVY)

# backpack with a bunny charm, straps over the shoulders
bm = bmesh.new(); bmesh.ops.create_cube(bm, size=1.0); bmesh.ops.bevel(bm, geom=bm.edges[:], offset=0.02, segments=2, affect='EDGES')
xform(bm, scale=(0.26, 0.11, 0.3), loc=(0, 0.17, 1.12))
accessory('Pack', bm, 'J_Bip_C_UpperChest', BLACK)
bm = bmesh.new(); bmesh.ops.create_cube(bm, size=1.0); bmesh.ops.bevel(bm, geom=bm.edges[:], offset=0.01, segments=2, affect='EDGES')
xform(bm, scale=(0.19, 0.04, 0.13), loc=(0, 0.235, 1.06))
accessory('PackPocket', bm, 'J_Bip_C_UpperChest', DARK)
for s in (-1, 1):
    bm = bmesh.new()
    pts = [(s * 0.1, 0.13, 1.24), (s * 0.1, 0.06, 1.33), (s * 0.1, -0.035, 1.31), (s * 0.105, -0.075, 1.2), (s * 0.11, -0.06, 1.05)]
    for p in pts:
        bm.verts.new((p[0] - 0.016, p[1], p[2])); bm.verts.new((p[0] + 0.016, p[1], p[2]))
    bm.verts.ensure_lookup_table()
    for i in range(len(pts) - 1):
        bm.faces.new([bm.verts[2 * i], bm.verts[2 * i + 1], bm.verts[2 * i + 3], bm.verts[2 * i + 2]])
    bmesh.ops.solidify(bm, geom=bm.faces[:], thickness=0.006)
    accessory('Strap%d' % (s + 1), bm, 'J_Bip_C_UpperChest', BLACK)
bm = bmesh.new(); bmesh.ops.create_uvsphere(bm, u_segments=12, v_segments=8, radius=0.03); xform(bm, loc=(0.12, 0.2, 0.98))
accessory('Bunny', bm, 'J_Bip_C_UpperChest', BUNNY)
for s in (-1, 1):
    bm = bmesh.new(); bmesh.ops.create_uvsphere(bm, u_segments=8, v_segments=6, radius=1.0)
    xform(bm, scale=(0.009, 0.007, 0.024), rot=(0, s * 0.25, 0), loc=(0.12 + s * 0.014, 0.2, 1.025))
    accessory('BunnyEar%d' % (s + 1), bm, 'J_Bip_C_UpperChest', BUNNY)

# plaid pleated skirt around the hips
from PIL import Image, ImageDraw
W = 256
img = Image.new('RGB', (W, 128), '#555868'); d = ImageDraw.Draw(img)
for x in range(0, W, 32): d.rectangle([x, 0, x + 13, 128], fill='#43454f')
for y in range(0, 128, 32): d.rectangle([0, y, W, y + 13], fill='#43454f')
for x in range(8, W, 32): d.rectangle([x, 0, x + 1, 128], fill='#8f91a0')
for y in range(8, 128, 32): d.rectangle([0, y, W, y + 1], fill='#8f91a0')
for x in range(24, W, 64): d.rectangle([x, 0, x, 128], fill='#b04450')
plaid_path = os.path.abspath('plaid.png'); img.save(plaid_path)
PLAID = bpy.data.materials.new('Skirt_Plaid'); PLAID.use_nodes = True
tn = PLAID.node_tree.nodes.new('ShaderNodeTexImage'); tn.image = bpy.data.images.load(plaid_path)
PLAID.node_tree.links.new(tn.outputs['Color'], PLAID.node_tree.nodes['Principled BSDF'].inputs['Base Color'])
bm = bmesh.new(); uv = bm.loops.layers.uv.new('UVMap')
NS, NR = 56, 6
top, bot = 0.975, 0.755
rows = []
for r in range(NR + 1):
    t = r / NR
    z = top + (bot - top) * t
    ring = []
    for i in range(NS):
        a = 2 * math.pi * i / NS
        pleat = (0.011 if i % 2 else -0.004) * t
        R = 0.15 + 0.075 * t ** 0.9 + pleat
        ring.append(bm.verts.new((R * math.sin(a), 0.012 + R * math.cos(a) * 0.86, z)))
    rows.append(ring)
for r in range(NR):
    for i in range(NS):
        f = bm.faces.new((rows[r][i], rows[r][(i + 1) % NS], rows[r + 1][(i + 1) % NS], rows[r + 1][i]))
        for l, (ii, rr) in zip(f.loops, ((i, r), (i + 1, r), (i + 1, r + 1), (i, r + 1))):
            l[uv].uv = (ii / NS * 5, (1 - rr / NR) * 0.6)
bmesh.ops.solidify(bm, geom=bm.faces[:], thickness=0.004)
accessory('Skirt', bm, 'J_Bip_C_Hips', PLAID)

# ---------------------------------------------------------------- texture painting by 3D position (rasterise each triangle in UV space)
def paint(ob, matname, rule):
    me = ob.data
    mi = [i for i, m in enumerate(me.materials) if m and m.name.startswith(matname)][0]
    m = me.materials[mi]
    node = [n for n in m.node_tree.nodes if n.type == 'TEX_IMAGE' and n.image and not n.image.name.endswith(('nml', 'spe', 'outline'))][0]
    im = node.image
    W, H = im.size
    px = np.array(im.pixels[:], dtype=np.float32).reshape(H, W, 4)
    out = px.copy()
    me.calc_loop_triangles()
    uvd = me.uv_layers.active.data
    for tri in me.loop_triangles:
        if tri.material_index != mi:
            continue
        P = [me.vertices[v].co for v in tri.vertices]
        U = np.array([uvd[l].uv[:] for l in tri.loops]) * [W, H]
        x0, y0 = np.floor(U.min(0)).astype(int) - 1; x1, y1 = np.ceil(U.max(0)).astype(int) + 1
        x0, y0 = max(x0, 0), max(y0, 0); x1, y1 = min(x1, W - 1), min(y1, H - 1)
        if x1 < x0 or y1 < y0:
            continue
        gx, gy = np.meshgrid(np.arange(x0, x1 + 1) + 0.5, np.arange(y0, y1 + 1) + 0.5)
        (ax, ay), (bx, by), (cx, cy) = U
        den = (by - cy) * (ax - cx) + (cx - bx) * (ay - cy)
        if abs(den) < 1e-9:
            continue
        l1 = ((by - cy) * (gx - cx) + (cx - bx) * (gy - cy)) / den
        l2 = ((cy - ay) * (gx - cx) + (ax - cx) * (gy - cy)) / den
        l3 = 1 - l1 - l2
        ins = (l1 > -0.08) & (l2 > -0.08) & (l3 > -0.08)
        if not ins.any():
            continue
        X = l1 * P[0].x + l2 * P[1].x + l3 * P[2].x
        Y = l1 * P[0].y + l2 * P[1].y + l3 * P[2].y
        Z = l1 * P[0].z + l2 * P[1].z + l3 * P[2].z
        ys, xs = np.nonzero(ins)
        for yy, xx in zip(ys, xs):
            c = rule(X[yy, xx], Y[yy, xx], Z[yy, xx], px[y0 + yy, x0 + xx])
            if c is not None:
                out[y0 + yy, x0 + xx, :3] = c
    im.pixels[:] = out.ravel()
    im.update()

def hexf(h):
    h = h.lstrip('#'); return np.array([int(h[i:i + 2], 16) / 255 for i in (0, 2, 4)])

def lum(p):
    return float(0.3 * p[0] + 0.59 * p[1] + 0.11 * p[2])

NAVY_C = hexf('#33395e'); NAVY_D = hexf('#262a46')
GREY_C = hexf('#a4a6b0'); SOCK = hexf('#2a2a30'); SOCKPINK = hexf('#f0879c')
WHITE_C = hexf('#f6f5f1')

def tops_rule(x, y, z, p):
    l = min(1.0, lum(p) * 1.12)
    if y < -0.03 and z > 0.95:
        if abs(x) < 0.042 and z < 1.285:
            return WHITE_C * (0.85 + 0.15 * l)          # the white shirt showing through the open front
        if abs(x) < 0.05 and z < 1.285:
            return GREY_C                               # zip
    return NAVY_C * (0.7 + 0.35 * l)

def body_rule(x, y, z, p):
    ax = abs(x)
    if z > 1.18 and 0.12 < ax < 0.515:                 # long sleeves down to the wrist (the model stands in T-pose)
        return NAVY_D if ax > 0.495 else NAVY_C * 0.95
    if 0.02 < z < 0.33 and ax < 0.16:                  # black crew socks with a pink band
        if 0.296 < z < 0.316:
            return SOCKPINK
        return SOCK
    return None

paint(BODY, 'Tops_01', tops_rule)
paint(BODY, 'Body_00', body_rule)

def recolor(matname, fn):
    for m in bpy.data.materials:
        if m.name.startswith(matname) and m.use_nodes:
            for n in m.node_tree.nodes:
                if n.type == 'TEX_IMAGE' and n.image and not n.image.name.endswith(('nml', 'spe', 'outline')):
                    im = n.image; W, H = im.size
                    px = np.array(im.pixels[:], dtype=np.float32).reshape(H, W, 4)
                    px[..., :3] = fn(px[..., :3]); im.pixels[:] = px.ravel(); im.update()
                    return

def shorts(c):
    return c * 0 + hexf('#2c2f44') * (0.7 + 0.5 * c.mean(-1, keepdims=True))

def shoes(c):
    l = c.mean(-1, keepdims=True)
    pink = hexf('#f07a93') * (0.85 + 0.4 * l)
    return np.where(l < 0.35, pink, c)

def iris(c):
    # warm the brown iris towards amber and lift it
    r, g, b = c[..., 0:1], c[..., 1:2], c[..., 2:3]
    l = 0.3 * r + 0.59 * g + 0.11 * b
    amber = np.concatenate([l * 2.3, l * 1.35, l * 0.35], -1)
    return np.clip(0.35 * c + 0.75 * amber, 0, 1)

recolor('Bottoms_01', shorts)
recolor('Shoes_01', shoes)
recolor('EyeIris_00', iris)

# ---------------------------------------------------------------- slim down: drop unused shape keys, normal/specular maps, shrink textures
KEEP = ('Basis', 'Fcl_EYE_Close', 'Fcl_ALL_Joy', 'Fcl_ALL_Fun', 'Fcl_EYE_Joy', 'Fcl_MTH_A', 'Fcl_MTH_Fun', 'Fcl_MTH_Joy', 'Fcl_ALL_Surprised')
FACE.active_shape_key_index = 0
for kb in list(FACE.data.shape_keys.key_blocks):
    if not any(kb.name.endswith(k) for k in KEEP):
        FACE.shape_key_remove(kb)
for m in bpy.data.materials:
    if not m.use_nodes:
        continue
    for n in list(m.node_tree.nodes):
        if n.type == 'TEX_IMAGE' and n.image and n.image.name.endswith(('nml', 'spe', 'outline')):
            m.node_tree.nodes.remove(n)
        elif n.type == 'NORMAL_MAP':
            m.node_tree.nodes.remove(n)
LIMIT = {'Body_00': 1024, 'Tops_01': 1024, 'Face_00': 1024, 'HairBack_00': 512, 'Hair_00': 512, 'Bottoms_01': 256, 'Shoes_01': 256}
for im in bpy.data.images:
    if im.size[0] == 0:
        continue
    lim = LIMIT.get(im.name, 512)
    w, h = im.size
    s = min(1.0, lim / max(w, h))
    if s < 1:
        im.scale(max(1, int(w * s)), max(1, int(h * s)))

bpy.ops.export_scene.gltf(filepath=OUT, export_format='GLB', use_selection=False, export_skins=True, export_morph=True,
                          export_morph_normal=False, export_animations=False, export_image_format='AUTO', export_yup=True,
                          export_extras=False, export_cameras=False, export_lights=False)
print('wrote', OUT, os.path.getsize(OUT))
