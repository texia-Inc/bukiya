# Turns the VRoid Studio model of Nagi (design/nagi.vrm, made in VRoid Studio: summer school uniform, high ponytail) into the
# Umimachi heroine with a wardrobe: the body keeps its plain skin, and every garment is its own part named W_<part> so the game
# can show, hide and tint them (see the WARDROBE table in the game). Garments that tint are exported white or light grey; the game
# multiplies in the colour.
#   The model is scaled to the size of the pixiv VRM sample the game was first built on (same VRoid skeleton, ~3.5% taller), so
#   every position below is in that sample's space and the game's rig and leg IK fit unchanged.
#   hair: VRoid's ponytail is re-weighted onto a bone chain Tail0-3 that the game swings
#   from VRoid: W_tops (shirt), W_tie (ribbon), W_skirt (pleated skirt), W_shoes (loafers)
#   made here: W_sleeves / W_socks / W_sockband / W_kneesocks / W_tights / W_shorts (thin shells copied from the skin),
#   W_strip / W_zip (shirt and zip showing through an open hoodie), W_hood, W_bow_*, W_clip_*, W_glasses_*, W_scrunchie,
#   W_pack_* (backpack, straps, bunny charm) and the gacha costume pieces
# Blender works z-up with the model facing -y.
# Usage: Blender -b --python heroine_vrm.py -- nagi.vrm(renamed .glb) heroine.glb   (or a Python with `pip install bpy`)
import bpy, bmesh, math, sys, os, re
import numpy as np
from mathutils import Vector

args = sys.argv[sys.argv.index('--') + 1:] if '--' in sys.argv else ['nagi.glb', 'heroine.glb']
SRC, OUT = args[0], args[1]

for o in list(bpy.data.objects):
    bpy.data.objects.remove(o)
bpy.ops.import_scene.gltf(filepath=SRC)
ARM = bpy.data.objects['Armature']
BODY, FACE, HAIR = bpy.data.objects['Body'], bpy.data.objects['Face'], bpy.data.objects['Hair']
for o in list(bpy.data.objects):
    if o.type == 'MESH' and o.parent is None:      # VRoid's stray icosphere
        bpy.data.objects.remove(o)

# VRoid names materials like 'N00_000_00_Body_00_SKIN (Instance)'; the game matches 'Body_00_SKIN', 'Hair_00_HAIR', 'Face_...'
for m in bpy.data.materials:
    m.name = re.sub(r'^N\d+_\d+(_\d+)?_| \(Instance\)$', '', m.name)

# scale to the sample's size (its head bone sat at 1.3863)
K = ARM.data.bones['J_Bip_C_Head'].head_local.z / 1.3863
ARM.scale = (1 / K,) * 3
bpy.ops.object.select_all(action='DESELECT')
for o in bpy.data.objects:
    o.select_set(True)
bpy.context.view_layer.objects.active = ARM
bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)

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

# ---------------------------------------------------------------- ponytail: VRoid's strands 03-05 (J_Sec_Hair<depth>_<strand>) hang from the
# tie; the game does not simulate the VRM spring bones, so their weights move onto a chain Tail0-3 along strand 03 that it swings
def strand(s):
    return [ARM.data.bones[n] for n in ('J_Sec_Hair%d_%s' % (d, s) for d in range(1, 10)) if n in ARM.data.bones]
main = strand('03')
spine = [b.head_local.copy() for b in main] + [main[-1].tail_local.copy()]
TIE = spine[0]
acc = [0.0]
for i in range(1, len(spine)):
    acc.append(acc[-1] + (spine[i] - spine[i - 1]).length)
def along(t):
    d = t * acc[-1]
    i = max(k for k in range(len(acc) - 1) if acc[k] <= d) if d < acc[-1] else len(acc) - 2
    f = (d - acc[i]) / max(1e-6, acc[i + 1] - acc[i])
    return spine[i].lerp(spine[i + 1], min(1.0, f))
PATH = [along(i / 4) for i in range(5)]

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

PONY = {g.index for g in HAIR.vertex_groups if g.name.startswith('J_Sec_Hair') and g.name[-2:] in ('03', '04', '05')}
TG = [HAIR.vertex_groups.new(name=n) for n in TAIL_BONES]
top, bottom = TIE.z, min(b.tail_local.z for s in ('03', '04', '05') for b in strand(s)[-1:])
for v in HAIR.data.vertices:
    w = sum(g.weight for g in v.groups if g.group in PONY)
    if w <= 0:
        continue
    for gi in [g.group for g in v.groups if g.group in PONY]:
        HAIR.vertex_groups[gi].remove([v.index])
    # how far down the tail the vertex hangs picks the segment; neighbouring segments blend
    seg = min(3.999, max(0.0, (top - v.co.z) / (top - bottom)) * 4)
    bi = int(seg); f = seg - bi
    if f < 0.5 and bi > 0:
        TG[bi].add([v.index], w * (0.5 + f), 'ADD'); TG[bi - 1].add([v.index], w * (0.5 - f), 'ADD')
    elif f >= 0.5 and bi < 3:
        TG[bi].add([v.index], w * (1.5 - f), 'ADD'); TG[bi + 1].add([v.index], w * (f - 0.5), 'ADD')
    else:
        TG[bi].add([v.index], w, 'ADD')

# ---------------------------------------------------------------- helpers for rigid accessories (weighted 100% to one bone)
def mat(name, col, rough=0.8):
    m = bpy.data.materials.new(name); m.use_nodes = True
    nt = m.node_tree
    b = next((n for n in nt.nodes if n.type == 'BSDF_PRINCIPLED'), None)
    if b is None:      # Blender 5 starts new materials without nodes
        b = nt.nodes.new('ShaderNodeBsdfPrincipled')
        out = next((n for n in nt.nodes if n.type == 'OUTPUT_MATERIAL'), None) or nt.nodes.new('ShaderNodeOutputMaterial')
        nt.links.new(b.outputs['BSDF'], out.inputs['Surface'])
    b.inputs['Base Color'].default_value = (*col, 1); b.inputs['Roughness'].default_value = rough
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

WHITE = (1.0, 1.0, 1.0)
PINK = mat('Cloth_Clip', WHITE)
SCRUNCH = mat('Cloth_Scrunchie', WHITE)
NAVY = mat('Cloth_Hood', WHITE)
RED = mat('Cloth_Bow', WHITE)
BLACK = mat('Cloth_Pack', WHITE)
STRAP = mat('Cloth_Strap', srgb('#1c1c20'))
BUNNY = mat('Cloth_Bunny', srgb('#f7a6bd'))
DARK = mat('Cloth_Pocket', srgb('#2e2e33'))

# scrunchie round the ponytail where it leaves the crown: sized from the hair that hangs on Tail0
t0 = HAIR.vertex_groups['Tail0'].index
PT = np.array([v.co[:] for v in HAIR.data.vertices if any(g.group == t0 and g.weight > 0.3 for g in v.groups)])
def tail_slice(z):
    s = PT[(PT[:, 2] > z - 0.012) & (PT[:, 2] < z + 0.012)]
    c = s.mean(0)
    return Vector(c), float(np.percentile(np.linalg.norm((s - c)[:, :2], axis=1), 85))
RING_C, RING_R = tail_slice(TIE.z + 0.015)
bm = bmesh.new()
for i in range(18):
    a = 2 * math.pi * i / 18
    for j in range(8):
        b = 2 * math.pi * j / 8
        r = RING_R + 0.004 + 0.016 * math.cos(b) * (1 + 0.15 * math.sin(a * 5))
        bm.verts.new((r * math.cos(a), r * math.sin(a), 0.016 * math.sin(b)))
bm.verts.ensure_lookup_table()
for i in range(18):
    for j in range(8):
        q = [bm.verts[((i + di) % 18) * 8 + (j + dj) % 8] for di, dj in ((0, 0), (1, 0), (1, 1), (0, 1))]
        bm.faces.new(q)
d = (tail_slice(TIE.z - 0.06)[0] - RING_C).normalized()
xform(bm, rot=(math.pi / 2 - math.atan2(d.z, d.y), 0, 0), loc=RING_C)
accessory('W_scrunchie', bm, 'J_Bip_C_Head', SCRUNCH)

# pink X clip on the left of the bangs
for s in (-1, 1):
    bm = bmesh.new(); bmesh.ops.create_cube(bm, size=1.0)
    xform(bm, scale=(0.04, 0.007, 0.009), rot=(0, s * 0.785, 0))
    xform(bm, rot=(0.25, 0, -0.55), loc=(0.078, -0.072, 1.545))
    accessory('W_clip_%d' % (s + 1), bm, 'J_Bip_C_Head', PINK, smooth=False)

# red bow at the collar
for s in (-1, 1):
    bm = bmesh.new(); bmesh.ops.create_uvsphere(bm, u_segments=12, v_segments=8, radius=1.0)
    xform(bm, scale=(0.027, 0.012, 0.017), loc=(s * 0.027, -0.088, 1.262))
    accessory('W_bow_l%d' % (s + 1), bm, 'J_Bip_C_UpperChest', RED)
    bm = bmesh.new(); bmesh.ops.create_cube(bm, size=1.0)
    xform(bm, scale=(0.014, 0.005, 0.045), rot=(0, s * 0.35, 0), loc=(s * 0.013, -0.09, 1.232))
    accessory('W_bow_t%d' % (s + 1), bm, 'J_Bip_C_UpperChest', RED, smooth=False)
bm = bmesh.new(); bmesh.ops.create_uvsphere(bm, u_segments=10, v_segments=6, radius=0.011); xform(bm, loc=(0, -0.092, 1.262))
accessory('W_bow_k', bm, 'J_Bip_C_UpperChest', RED)

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
accessory('W_hood', bm, 'J_Bip_C_UpperChest', NAVY)

# backpack with a bunny charm, straps over the shoulders
bm = bmesh.new(); bmesh.ops.create_cube(bm, size=1.0); bmesh.ops.bevel(bm, geom=bm.edges[:], offset=0.02, segments=2, affect='EDGES')
xform(bm, scale=(0.26, 0.11, 0.3), loc=(0, 0.17, 1.12))
accessory('W_pack', bm, 'J_Bip_C_UpperChest', BLACK)
bm = bmesh.new(); bmesh.ops.create_cube(bm, size=1.0); bmesh.ops.bevel(bm, geom=bm.edges[:], offset=0.01, segments=2, affect='EDGES')
xform(bm, scale=(0.19, 0.04, 0.13), loc=(0, 0.235, 1.06))
accessory('W_pack_pocket', bm, 'J_Bip_C_UpperChest', DARK)
for s in (-1, 1):
    bm = bmesh.new()
    pts = [(s * 0.1, 0.13, 1.24), (s * 0.1, 0.06, 1.33), (s * 0.1, -0.035, 1.31), (s * 0.105, -0.075, 1.2), (s * 0.11, -0.06, 1.05)]
    for p in pts:
        bm.verts.new((p[0] - 0.016, p[1], p[2])); bm.verts.new((p[0] + 0.016, p[1], p[2]))
    bm.verts.ensure_lookup_table()
    for i in range(len(pts) - 1):
        bm.faces.new([bm.verts[2 * i], bm.verts[2 * i + 1], bm.verts[2 * i + 3], bm.verts[2 * i + 2]])
    bmesh.ops.solidify(bm, geom=bm.faces[:], thickness=0.006)
    accessory('W_pack_strap%d' % (s + 1), bm, 'J_Bip_C_UpperChest', STRAP)
bm = bmesh.new(); bmesh.ops.create_uvsphere(bm, u_segments=12, v_segments=8, radius=0.03); xform(bm, loc=(0.12, 0.2, 0.98))
accessory('W_pack_bunny', bm, 'J_Bip_C_UpperChest', BUNNY)
for s in (-1, 1):
    bm = bmesh.new(); bmesh.ops.create_uvsphere(bm, u_segments=8, v_segments=6, radius=1.0)
    xform(bm, scale=(0.009, 0.007, 0.024), rot=(0, s * 0.25, 0), loc=(0.12 + s * 0.014, 0.2, 1.025))
    accessory('W_pack_bunnyear%d' % (s + 1), bm, 'J_Bip_C_UpperChest', BUNNY)

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

# ---------------------------------------------------------------- garments as parts
def split_material(ob, matname, name):
    """move the faces using the materials named matname... into their own object (same weights, same armature)"""
    dup = ob.copy(); dup.data = ob.data.copy(); dup.name = name; bpy.context.collection.objects.link(dup)
    mis = {i for i, m in enumerate(dup.data.materials) if m and m.name.startswith(matname)}
    for o, keep in ((dup, True), (ob, False)):
        bm = bmesh.new(); bm.from_mesh(o.data)
        bmesh.ops.delete(bm, geom=[f for f in bm.faces if (f.material_index in mis) != keep], context='FACES')
        bm.to_mesh(o.data); bm.free()
    # drop the material slots the part no longer uses
    for o in (dup, ob):
        used = {p.material_index for p in o.data.polygons}
        for i in reversed(range(len(o.data.materials))):
            if i not in used:
                o.active_material_index = i
                bpy.context.view_layer.objects.active = o
                bpy.ops.object.material_slot_remove()
    return dup

def shell(ob, pred, name, offset, material, mat_index=None):
    """copy the faces of ob that satisfy pred (face centre) and push them out along the normals: a garment that bends exactly like the skin"""
    dup = ob.copy(); dup.data = ob.data.copy(); dup.name = name; bpy.context.collection.objects.link(dup)
    bm = bmesh.new(); bm.from_mesh(dup.data)
    bmesh.ops.delete(bm, geom=[f for f in bm.faces if not ((mat_index is None or f.material_index == mat_index) and pred(f.calc_center_median()))], context='FACES')
    bm.normal_update()
    for v in bm.verts:
        v.co += v.normal * offset
    bm.to_mesh(dup.data); bm.free()
    dup.data.materials.clear(); dup.data.materials.append(material)
    for p in dup.data.polygons:
        p.material_index = 0; p.use_smooth = True
    return dup

# VRoid's textures are up to 2048px: halve them before painting (the slim-down at the end sets the final sizes)
for im in bpy.data.images:
    if max(im.size) > 1024:
        im.scale(im.size[0] // 2, im.size[1] // 2)

TOPS = split_material(BODY, 'Tops_01', 'W_tops')
TIE_PART = split_material(BODY, 'Accessory_Tie', 'W_tie')
SKIRT = split_material(BODY, 'Bottoms_01', 'W_skirt')
SHOES = split_material(BODY, 'Shoes_01', 'W_shoes')
skin_i = [i for i, m in enumerate(BODY.data.materials) if m and m.name.startswith('Body_00')][0]

# VRoid paints the knee socks into the skin texture: paint them over with the skin of the thighs (socks are W_ parts here)
thigh = []
paint(BODY, 'Body_00', lambda x, y, z, p: thigh.append(p[:3].copy()) if 0.6 < z < 0.72 else None)
SKIN = np.median(np.array(thigh), 0)
paint(BODY, 'Body_00', lambda x, y, z, p: SKIN if z < 0.5 and np.abs(p[:3] - SKIN).sum() > 0.1 else None)

shell(BODY, lambda c: 0.7 < c.z < 0.99 and abs(c.x) < 0.2, 'W_shorts', 0.0035, mat('Bottoms_Shorts', WHITE), skin_i)
shell(BODY, lambda c: c.z > 1.18 and 0.12 < abs(c.x) < 0.515, 'W_sleeves', 0.0055, mat('Cloth_Sleeves', WHITE), skin_i)
shell(BODY, lambda c: 0.075 < c.z < 0.33 and abs(c.x) < 0.16, 'W_socks', 0.0032, mat('Cloth_Socks', WHITE), skin_i)
shell(BODY, lambda c: 0.296 < c.z < 0.316 and abs(c.x) < 0.16, 'W_sockband', 0.0046, mat('Cloth_SockBand', WHITE), skin_i)
shell(BODY, lambda c: 0.075 < c.z < 0.47 and abs(c.x) < 0.16, 'W_kneesocks', 0.0032, mat('Cloth_KneeSocks', WHITE), skin_i)
shell(BODY, lambda c: 0.075 < c.z < 0.9 and abs(c.x) < 0.2, 'W_tights', 0.0022, mat('Cloth_Tights', WHITE), skin_i)
# an open hoodie shows the shirt and a zip down the front
shell(TOPS, lambda c: c.y < -0.03 and 0.95 < c.z < 1.285 and abs(c.x) < 0.042, 'W_strip', 0.0022, mat('Cloth_Strip', WHITE))
shell(TOPS, lambda c: c.y < -0.03 and 0.95 < c.z < 1.285 and 0.042 <= abs(c.x) < 0.05, 'W_zip', 0.0026, mat('Cloth_Zip', WHITE))
# round glasses
GL = mat('Cloth_Glasses', WHITE)
for s_ in (-1, 1):
    bm = bmesh.new(); bmesh.ops.create_circle(bm, cap_ends=False, segments=20, radius=0.0215)
    bmesh.ops.extrude_edge_only(bm, edges=bm.edges[:])
    xform(bm, rot=(math.pi / 2, 0, 0), loc=(s_ * 0.034, -0.104, 1.449))
    for v in bm.verts:
        d = Vector((v.co.x - s_ * 0.034, 0, v.co.z - 1.449))
        if d.length > 0.0205:
            v.co += d.normalized() * 0.0035
    accessory('W_glasses_%d' % (s_ + 1), bm, 'J_Bip_C_Head', GL)
bm = bmesh.new(); bmesh.ops.create_cube(bm, size=1.0); xform(bm, scale=(0.022, 0.003, 0.003), loc=(0, -0.106, 1.452))
accessory('W_glasses_b', bm, 'J_Bip_C_Head', GL, smooth=False)

# ---------------------------------------------------------------- themed gacha pieces (hats, ears, wings, tails, collars...)
from mathutils import Matrix, Euler
from mathutils.bvhtree import BVHTree

def tube(pts, rad, ring=12, n=None, cap=True):
    """a tube along a Catmull-Rom path; rad(t) gives the radius (0 at the tip makes a point)"""
    P = catmull([Vector(p) for p in pts], n or 6 * len(pts))
    bm = bmesh.new(); rings = []
    for i, c in enumerate(P):
        T = (P[min(i + 1, len(P) - 1)] - P[max(i - 1, 0)]).normalized()
        a = Vector((0, 0, 1)) if abs(T.z) < 0.9 else Vector((1, 0, 0))
        X = T.cross(a).normalized(); Y = T.cross(X).normalized()
        r = rad(i / (len(P) - 1))
        rings.append([bm.verts.new(c + (X * math.cos(2 * math.pi * k / ring) + Y * math.sin(2 * math.pi * k / ring)) * r) for k in range(ring)])
    for i in range(len(rings) - 1):
        for k in range(ring):
            bm.faces.new((rings[i][k], rings[i][(k + 1) % ring], rings[i + 1][(k + 1) % ring], rings[i + 1][k]))
    if cap:
        bm.faces.new(rings[0][::-1])
        if rad(1) > 1e-4:
            bm.faces.new(rings[-1])
    return bm, P

def chain_weights(ob, bones, pts_axis):
    """weight every vertex of ob to a chain of bones by how far along the axis it is (smoothly blended)"""
    groups = [ob.vertex_groups.get(b) or ob.vertex_groups.new(name=b) for b in bones]
    L = [0.0]
    for i in range(1, len(pts_axis)):
        L.append(L[-1] + (pts_axis[i] - pts_axis[i - 1]).length)
    for v in ob.data.vertices:
        j = min(range(len(pts_axis)), key=lambda i: (pts_axis[i] - v.co).length)
        s = min(0.999, L[j] / L[-1]) * len(bones)
        bi = int(s); f = s - bi
        for g in groups:
            g.remove([v.index])
        if f < 0.5 and bi > 0:
            groups[bi].add([v.index], 0.5 + f, 'REPLACE'); groups[bi - 1].add([v.index], 0.5 - f, 'REPLACE')
        elif f >= 0.5 and bi < len(bones) - 1:
            groups[bi].add([v.index], 1.5 - f, 'REPLACE'); groups[bi + 1].add([v.index], f - 0.5, 'REPLACE')
        else:
            groups[bi].add([v.index], 1.0, 'REPLACE')

def rigid(name, bm, bone, material, smooth=True):
    return accessory(name, bm, bone, material, smooth)

HEADB, CHEST, HIPS = 'J_Bip_C_Head', 'J_Bip_C_UpperChest', 'J_Bip_C_Hips'
def M_(name, col=(1.0, 1.0, 1.0)):
    return mat('Cloth_' + name, col)

# witch hat: a wide brim and a crooked cone, with a band
bm = bmesh.new()
for i in range(32):
    a = 2 * math.pi * i / 32
    for r in (0.1, 0.22):
        bm.verts.new((r * math.cos(a), r * math.sin(a), -0.012 * (r - 0.1) / 0.12))
bm.verts.ensure_lookup_table()
for i in range(32):
    j = (i + 1) % 32
    bm.faces.new((bm.verts[2 * i], bm.verts[2 * j], bm.verts[2 * j + 1], bm.verts[2 * i + 1]))
bmesh.ops.solidify(bm, geom=bm.faces[:], thickness=0.006)
xform(bm, rot=(-0.1, 0, 0), loc=(0, 0.02, 1.598))
rigid('W_witchhat', bm, HEADB, M_('WitchHat'))
bm, _ = tube([(0, 0.02, 1.592), (0, 0.03, 1.69), (0.03, 0.08, 1.79), (0.085, 0.13, 1.83)], lambda t: 0.106 * (1 - t) ** 0.9, ring=20)
rigid('W_witchhat_crown', bm, HEADB, M_('WitchHat2'))
bm, _ = tube([(0, 0.02, 1.594), (0, 0.022, 1.615)], lambda t: 0.1075, ring=24, n=3)
rigid('W_witchhat_band', bm, HEADB, M_('WitchBand'))

# cat ears with pink insides
for sx in (-1, 1):
    bm = bmesh.new()
    b0 = bm.verts.new((sx * 0.035, 0.01, 1.596)); b1 = bm.verts.new((sx * 0.088, 0.03, 1.575)); b2 = bm.verts.new((sx * 0.06, 0.045, 1.595))
    tip = bm.verts.new((sx * 0.08, 0.02, 1.672))
    for f in ((b0, b1, tip), (b1, b2, tip), (b2, b0, tip), (b0, b2, b1)):
        bm.faces.new(f if sx > 0 else f[::-1])
    rigid('W_catears_%d' % (sx + 1), bm, HEADB, M_('CatEars'), smooth=False)
    bm = bmesh.new()
    i0 = bm.verts.new((sx * 0.045, 0.006, 1.6)); i1 = bm.verts.new((sx * 0.08, 0.02, 1.585)); it = bm.verts.new((sx * 0.076, 0.012, 1.655))
    bm.faces.new((i0, i1, it) if sx > 0 else (it, i1, i0))
    rigid('W_catears_in%d' % (sx + 1), bm, HEADB, M_('CatEarsIn', srgb('#f2a6b8')), smooth=False)

# little devil horns
for sx in (-1, 1):
    bm, _ = tube([(sx * 0.045, -0.025, 1.595), (sx * 0.062, -0.022, 1.64), (sx * 0.05, -0.005, 1.675)], lambda t: 0.017 * (1 - t), ring=10)
    rigid('W_horns_%d' % (sx + 1), bm, HEADB, M_('Horns'))

# halo
bm = bmesh.new()
for i in range(32):
    a = 2 * math.pi * i / 32
    for j in range(8):
        b = 2 * math.pi * j / 8
        r = 0.075 + 0.008 * math.cos(b)
        bm.verts.new((r * math.cos(a), r * math.sin(a), 0.008 * math.sin(b)))
bm.verts.ensure_lookup_table()
for i in range(32):
    for j in range(8):
        bm.faces.new([bm.verts[((i + di) % 32) * 8 + (j + dj) % 8] for di, dj in ((0, 0), (1, 0), (1, 1), (0, 1))])
xform(bm, rot=(0.28, 0, 0), loc=(0, 0.035, 1.705))
rigid('W_halo', bm, HEADB, M_('Halo'))

# beret, worn at an angle
bm = bmesh.new(); bmesh.ops.create_uvsphere(bm, u_segments=24, v_segments=12, radius=1.0)
for v in bm.verts:
    if v.co.z < -0.2:
        v.co.z = -0.2
xform(bm, scale=(0.122, 0.118, 0.045), rot=(0.12, -0.28, 0), loc=(0.012, 0.02, 1.6))
rigid('W_beret', bm, HEADB, M_('Beret'))
bm, _ = tube([(0.02, 0.02, 1.645), (0.022, 0.02, 1.66)], lambda t: 0.006, ring=8, n=3)
rigid('W_beret_nub', bm, HEADB, M_('BeretNub'))

# sailor cap: a short crown with a rolled brim and a ribbon band
bm, _ = tube([(0, 0.01, 1.588), (0, 0.012, 1.648)], lambda t: 0.094 - 0.006 * t, ring=24, n=4)
rigid('W_marinecap', bm, HEADB, M_('MarineCap'))
bm = bmesh.new()
for i in range(28):
    a = 2 * math.pi * i / 28
    for j in range(8):
        b = 2 * math.pi * j / 8
        r = 0.1 + 0.014 * math.cos(b)
        bm.verts.new((r * math.cos(a), 0.01 + r * math.sin(a), 1.592 + 0.014 * math.sin(b)))
bm.verts.ensure_lookup_table()
for i in range(28):
    for j in range(8):
        bm.faces.new([bm.verts[((i + di) % 28) * 8 + (j + dj) % 8] for di, dj in ((0, 0), (1, 0), (1, 1), (0, 1))])
rigid('W_marinecap_brim', bm, HEADB, M_('MarineCap2'))
bm, _ = tube([(0, 0.012, 1.604), (0, 0.012, 1.618)], lambda t: 0.0955, ring=24, n=3)
rigid('W_marinecap_band', bm, HEADB, M_('MarineBand'))

# sunglasses: frames like the round glasses, with dark lenses
SUNF = M_('SunFrame'); LENS = M_('Lens', srgb('#15181d'))
for sx in (-1, 1):
    bm = bmesh.new(); bmesh.ops.create_circle(bm, cap_ends=False, segments=20, radius=0.023)
    bmesh.ops.extrude_edge_only(bm, edges=bm.edges[:])
    xform(bm, rot=(math.pi / 2, 0, 0), loc=(sx * 0.034, -0.106, 1.449))
    for v in bm.verts:
        d = Vector((v.co.x - sx * 0.034, 0, v.co.z - 1.449))
        if d.length > 0.022:
            v.co += d.normalized() * 0.004
    rigid('W_sunglasses_%d' % (sx + 1), bm, HEADB, SUNF)
    bm = bmesh.new(); bmesh.ops.create_circle(bm, cap_ends=True, segments=20, radius=0.023)
    xform(bm, rot=(math.pi / 2, 0, 0), loc=(sx * 0.034, -0.105, 1.449))
    rigid('W_sunglasses_lens%d' % (sx + 1), bm, HEADB, LENS)
bm = bmesh.new(); bmesh.ops.create_cube(bm, size=1.0); xform(bm, scale=(0.022, 0.003, 0.003), loc=(0, -0.107, 1.453))
rigid('W_sunglasses_b', bm, HEADB, SUNF, smooth=False)

# choker with a bell
bm = bmesh.new()
for i in range(28):
    a = 2 * math.pi * i / 28
    for j in range(6):
        b = 2 * math.pi * j / 6
        r = 0.041 + 0.0045 * math.cos(b)
        bm.verts.new((r * math.cos(a), 0.026 + r * 0.98 * math.sin(a), 1.343 + 0.006 * math.sin(b)))
bm.verts.ensure_lookup_table()
for i in range(28):
    for j in range(6):
        bm.faces.new([bm.verts[((i + di) % 28) * 6 + (j + dj) % 6] for di, dj in ((0, 0), (1, 0), (1, 1), (0, 1))])
rigid('W_choker', bm, 'J_Bip_C_Neck', M_('Choker'))
bm = bmesh.new(); bmesh.ops.create_uvsphere(bm, u_segments=12, v_segments=8, radius=0.011); xform(bm, loc=(0, -0.022, 1.332))
rigid('W_choker_bell', bm, 'J_Bip_C_Neck', M_('Bell', srgb('#e8c04a')))

# dog tags on a ball chain
SILVER = M_('Tag', srgb('#c5c9cf'))
bm, _ = tube([(0, 0.068, 1.33), (0.05, 0.03, 1.33), (0.048, -0.05, 1.27), (0.02, -0.09, 1.215), (0, -0.098, 1.205),
              (-0.02, -0.09, 1.215), (-0.048, -0.05, 1.27), (-0.05, 0.03, 1.33), (0, 0.068, 1.33)], lambda t: 0.0022, ring=6, cap=False)
rigid('W_dogtag_chain', bm, CHEST, SILVER)
for k, (dx, rz) in enumerate(((-0.006, 0.12), (0.008, -0.1))):
    bm = bmesh.new(); bmesh.ops.create_cube(bm, size=1.0); bmesh.ops.bevel(bm, geom=bm.edges[:], offset=0.003, segments=2, affect='EDGES')
    xform(bm, scale=(0.022, 0.004, 0.034), rot=(0.15, rz, 0), loc=(dx, -0.104 - 0.003 * k, 1.183))
    rigid('W_dogtag_%d' % k, bm, CHEST, SILVER)

# sailor collar: rays cast at the top find the body, so the collar lies on it
dg = bpy.context.evaluated_depsgraph_get()
TB = BVHTree.FromObject(TOPS, dg)
def on_tops(theta, z, off):
    d = Vector((math.sin(theta), math.cos(theta), 0))      # theta 0 = back (+y), pi = front
    o = Vector((0, 0.012, z)) + d * 0.5
    hit = TB.ray_cast(o, -d)
    if hit[0] is None:
        return None
    p = hit[0] + d * off
    # the model stands in T-pose: rays at the shoulders can hit the outstretched arms, so keep the collar on the shoulders
    c = Vector((0, 0.012, p.z)); h = Vector((p.x - c.x, p.y - c.y, 0))
    lim = 0.155
    if h.length > lim:
        p = c + h.normalized() * lim
    return p
def collar_band(theta):
    a = abs(theta)
    hi = 1.33 if a < 2.3 else 1.33 - (a - 2.3) / (math.pi - 2.3) * 0.13
    if a < 1.0:
        lo = 1.17
    elif a < 1.5:
        lo = 1.17 + (a - 1.0) / 0.5 * 0.1
    elif a < 2.3:
        lo = 1.27
    else:
        lo = 1.27 - (a - 2.3) / (math.pi - 2.3) * 0.085
    return lo, hi
def collar(name, t0, t1, off, material):
    bm = bmesh.new(); NT = 72; NZ = 6; grid = []
    for i in range(NT + 1):
        th = -math.pi * 0.985 + 2 * math.pi * 0.985 * i / NT
        lo, hi = collar_band(th); row = []
        for j in range(NZ + 1):
            z = lo + (hi - lo) * (t0 + (t1 - t0) * j / NZ)
            p = on_tops(th, z, off)
            row.append(bm.verts.new(p) if p else None)
        grid.append(row)
    for i in range(NT):
        for j in range(NZ):
            q = (grid[i][j], grid[i + 1][j], grid[i + 1][j + 1], grid[i][j + 1])
            if all(q):
                bm.faces.new(q)
    return rigid(name, bm, CHEST, material)
collar('W_sailorcollar', 0.0, 1.0, 0.007, M_('SailorCollar'))
collar('W_sailorcollar_line', 0.12, 0.24, 0.0085, M_('SailorLine'))

# cape hanging from the shoulders
bm = bmesh.new(); rows = []
for r in range(9):
    t = r / 8; z = 1.335 - 0.45 * t; row = []
    for i in range(25):
        th = -1.5 + 3.0 * i / 24
        rx = 0.2 + 0.13 * t; ry = 0.105 + 0.12 * t
        row.append(bm.verts.new((rx * math.sin(th), 0.015 + ry * math.cos(th), z + 0.015 * math.cos(th * 3) * t)))
    rows.append(row)
for r in range(8):
    for i in range(24):
        bm.faces.new((rows[r][i], rows[r][i + 1], rows[r + 1][i + 1], rows[r + 1][i]))
bmesh.ops.solidify(bm, geom=bm.faces[:], thickness=0.004)
rigid('W_cape', bm, CHEST, M_('Cape'))

# bat wings and feathered angel wings on the back
for sx in (-1, 1):
    bm = bmesh.new()
    root = Vector((sx * 0.04, 0.13, 1.21))
    outline_pts = [(0.05, 0.02), (0.2, 0.17), (0.36, 0.2), (0.42, 0.12), (0.33, 0.05), (0.27, -0.03), (0.19, 0.02), (0.13, -0.06), (0.06, -0.02)]
    vs = [bm.verts.new(root)] + [bm.verts.new(root + Vector((sx * x, 0.09 * x, z))) for x, z in outline_pts]
    for i in range(1, len(vs) - 1):
        bm.faces.new((vs[0], vs[i], vs[i + 1]) if sx > 0 else (vs[0], vs[i + 1], vs[i]))
    bmesh.ops.solidify(bm, geom=bm.faces[:], thickness=0.004)
    rigid('W_batwings_%d' % (sx + 1), bm, CHEST, M_('BatWings'), smooth=False)
    for row in range(3):
        for k in range(6 - row):
            bm = bmesh.new(); bmesh.ops.create_uvsphere(bm, u_segments=10, v_segments=6, radius=1.0)
            L = 0.11 - 0.012 * row
            a = 0.25 + k * 0.17
            xform(bm, scale=(0.022, 0.006, L))
            xform(bm, rot=(0.0, sx * (2.4 - a), 0))
            base = Vector((sx * (0.06 + 0.055 * k + 0.02 * row), 0.15 + 0.012 * k, 1.27 - 0.045 * row - 0.012 * k))
            xform(bm, loc=base)
            rigid('W_angelwings_%d_%d_%d' % (sx + 1, row, k), bm, CHEST, M_('AngelWings'))

# tails: their own little bone chain from the small of the back
bpy.context.view_layer.objects.active = ARM
bpy.ops.object.mode_set(mode='EDIT')
TP = [Vector((0, 0.12, 0.9)), Vector((0, 0.23, 0.86)), Vector((0, 0.32, 0.93)), Vector((0, 0.37, 1.06)), Vector((0.02, 0.35, 1.17))]
par = ARM.data.edit_bones[HIPS]; CT = []
for i in range(4):
    b = ARM.data.edit_bones.new('CTail%d' % i); b.head = TP[i]; b.tail = TP[i + 1]; b.parent = par; b.use_connect = i > 0; par = b; CT.append(b.name)
bpy.ops.object.mode_set(mode='OBJECT')
def tail_part(name, rad, material, extra=None):
    bm, axis = tube(TP, rad, ring=10, n=36)
    if extra:
        extra(bm)
    me = bpy.data.meshes.new(name); bm.to_mesh(me); bm.free()
    ob = bpy.data.objects.new(name, me); bpy.context.collection.objects.link(ob); ob.data.materials.append(material)
    for p in me.polygons:
        p.use_smooth = True
    chain_weights(ob, CT, axis)
    ob.parent = ARM; m = ob.modifiers.new('Armature', 'ARMATURE'); m.object = ARM
    return ob
tail_part('W_cattail', lambda t: 0.018 * (1 - 0.35 * t) * (1 if t < 0.97 else 0.5), M_('CatTail'))
def spade(bm):
    tip = TP[-1]; d = (TP[-1] - TP[-2]).normalized()
    side = Vector((1, 0, 0)); up = d
    pts = [tip, tip + side * 0.03 + up * 0.02, tip + up * 0.06, tip - side * 0.03 + up * 0.02]
    vs = [bm.verts.new(p) for p in pts]
    f = bm.faces.new(vs)
    bmesh.ops.solidify(bm, geom=[f], thickness=0.006)
tail_part('W_deviltail', lambda t: 0.0085 * (1 - 0.3 * t), M_('DevilTail'), spade)

# pumpkin pouch on the hip
ORANGE = M_('Pumpkin', srgb('#f08a24')); STEM = M_('PumpkinStem', srgb('#4f7a34')); BLK = M_('PumpkinFace', srgb('#2a1a10'))
bm = bmesh.new(); bmesh.ops.create_uvsphere(bm, u_segments=24, v_segments=12, radius=1.0)
for v in bm.verts:
    a = math.atan2(v.co.y, v.co.x)
    v.co *= 1 + 0.07 * math.cos(8 * a) * (1 - abs(v.co.z))
xform(bm, scale=(0.062, 0.058, 0.05), loc=(0.17, -0.03, 0.86))
rigid('W_pumpkin', bm, HIPS, ORANGE)
bm, _ = tube([(0.17, -0.03, 0.905), (0.175, -0.03, 0.925)], lambda t: 0.008, ring=8, n=3)
rigid('W_pumpkin_stem', bm, HIPS, STEM)
for k, (dx, dz, sc) in enumerate(((-0.022, 0.012, 0.011), (0.022, 0.012, 0.011), (0.0, -0.016, 0.02))):
    bm = bmesh.new(); v0 = bm.verts.new((-sc, 0, -sc * 0.6)); v1 = bm.verts.new((sc, 0, -sc * 0.6)); v2 = bm.verts.new((0, 0, sc * (0.6 if k < 2 else -0.2)))
    bm.faces.new((v0, v1, v2))
    xform(bm, rot=(0, 0, -0.35), loc=(0.17 + dx * 0.94 - 0.012, -0.03 - 0.06, 0.86 + dz))
    rigid('W_pumpkin_face%d' % k, bm, HIPS, BLK, smooth=False)

# a black skirt with a ragged zigzag hem
bm = bmesh.new(); NS, NR = 56, 6; top, bot = 0.975, 0.73; rows = []
for r in range(NR + 1):
    t = r / NR; ring = []
    for i in range(NS):
        a = 2 * math.pi * i / NS
        R = 0.15 + 0.085 * t ** 0.9
        z = top + (bot - top) * t - (0.035 if (i % 4 in (1, 2)) else 0.0) * t
        ring.append(bm.verts.new((R * math.sin(a), 0.012 + R * math.cos(a) * 0.86, z)))
    rows.append(ring)
for r in range(NR):
    for i in range(NS):
        bm.faces.new((rows[r][i], rows[r][(i + 1) % NS], rows[r + 1][(i + 1) % NS], rows[r + 1][i]))
bmesh.ops.solidify(bm, geom=bm.faces[:], thickness=0.004)
rigid('W_skirtzig', bm, HIPS, M_('SkirtZig'))

# paw gloves (a shell over the hands) and cargo pockets on the thighs
shell(BODY, lambda c: c.z > 1.18 and abs(c.x) > 0.505, 'W_paws', 0.006, M_('Paws'), skin_i)
for sx, nm in ((1, 'L'), (-1, 'R')):
    bm = bmesh.new(); bmesh.ops.create_cube(bm, size=1.0); bmesh.ops.bevel(bm, geom=bm.edges[:], offset=0.006, segments=2, affect='EDGES')
    xform(bm, scale=(0.03, 0.07, 0.075), loc=(sx * 0.135, -0.005, 0.79))
    rigid('W_cargo_pocket%s' % nm, bm, 'J_Bip_%s_UpperLeg' % nm, M_('CargoPocket'))

def recolor(matname, fn):
    for m in bpy.data.materials:
        if m.name.startswith(matname) and m.use_nodes:
            for n in m.node_tree.nodes:
                if n.type == 'TEX_IMAGE' and n.image and not n.image.name.endswith(('nml', 'spe', 'outline')):
                    im = n.image; W, H = im.size
                    px = np.array(im.pixels[:], dtype=np.float32).reshape(H, W, 4)
                    px[..., :3] = fn(px[..., :3]); im.pixels[:] = px.ravel(); im.update()
                    return

def light_grey(c):
    # keep the pattern (plaid, stripes) as light greys so the game's tint gives the colour
    l = 0.3 * c[..., 0] + 0.59 * c[..., 1] + 0.11 * c[..., 2]
    lo, hi = np.percentile(l, 2), np.percentile(l, 98)
    g = np.clip(0.55 + 0.45 * (l - lo) / max(1e-3, hi - lo), 0, 1)
    return np.repeat(g[..., None], 3, -1)

recolor('Bottoms_01', light_grey)
recolor('Accessory_Tie', light_grey)

# ---------------------------------------------------------------- slim down: drop unused shape keys, normal/specular maps, shrink textures
KEEP = ('Basis', 'Fcl_EYE_Close', 'Fcl_ALL_Joy', 'Fcl_ALL_Fun', 'Fcl_EYE_Joy', 'Fcl_MTH_A', 'Fcl_MTH_Fun', 'Fcl_MTH_Joy', 'Fcl_ALL_Surprised')
FACE.active_shape_key_index = 0
for kb in list(FACE.data.shape_keys.key_blocks):
    if not any(kb.name.endswith(k) for k in KEEP):
        FACE.shape_key_remove(kb)
# keep only the base colour texture of each material (VRoid also exports normal, emission and MToon maps the game does not use)
LIMIT = {'Body_00': 1024, 'Tops_01': 1024, 'Face_00': 1024, 'Hair_00': 512, 'HairBack_00': 512, 'Bottoms_01': 512}
size = {}
for m in bpy.data.materials:
    if not m.use_nodes:
        continue
    bsdf = next((n for n in m.node_tree.nodes if n.type == 'BSDF_PRINCIPLED'), None)
    # everything that feeds the base colour (VRoid routes the texture through mix nodes)
    base, todo = set(), [l.from_node for l in m.node_tree.links if bsdf and l.to_node == bsdf and l.to_socket.name == 'Base Color']
    while todo:
        n = todo.pop()
        if n not in base:
            base.add(n); todo += [l.from_node for l in m.node_tree.links if l.to_node == n]
    for n in list(m.node_tree.nodes):
        if n.type == 'TEX_IMAGE' and bsdf and n not in base:     # VRoid's materials come in unlit (no BSDF): their one texture stays
            m.node_tree.nodes.remove(n)
        elif n.type == 'NORMAL_MAP':
            m.node_tree.nodes.remove(n)
        elif n.type == 'TEX_IMAGE' and n.image:
            lim = next((v for k, v in LIMIT.items() if m.name.startswith(k)), 256)
            size[n.image.name] = max(size.get(n.image.name, 0), lim)
for im in bpy.data.images:
    if im.size[0] == 0 or im.name not in size:
        continue
    w, h = im.size
    s = min(1.0, size[im.name] / max(w, h))
    if s < 1:
        im.scale(max(1, int(w * s)), max(1, int(h * s)))

# a part with two materials becomes a group of meshes in three.js named after the mesh data: name it after the part
for o in bpy.data.objects:
    if o.type == 'MESH' and o.name.startswith('W_'):
        o.data.name = o.name

bpy.ops.export_scene.gltf(filepath=OUT, export_format='GLB', use_selection=False, export_skins=True, export_morph=True,
                          export_morph_normal=False, export_animations=False, export_image_format='AUTO', export_yup=True,
                          export_extras=False, export_cameras=False, export_lights=False)
print('wrote', OUT, os.path.getsize(OUT))
