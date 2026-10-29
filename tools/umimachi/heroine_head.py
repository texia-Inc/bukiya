# Builds the heroine's head, face UVs, hair and ponytail in Blender and writes them as compact mesh data for three.js.
# Coordinates are three.js ones (x right, y up, z forward), in metres, head-local (origin = centre of the skull).
import bpy, bmesh, math, json, base64, struct, sys, random
from mathutils import Vector

OUT = sys.argv[sys.argv.index('--') + 1] if '--' in sys.argv else 'heroine_head.json'
R = 0.135                     # skull radius used by the game's rig
SX, SY, SZ = 0.93, 1.0, 0.98  # the old head's proportions
UVS = 0.85                    # face texture spans x,y in [-UVS, UVS] (unit-sphere coordinates)
random.seed(7)

def ss(a, b, x):
    t = max(0.0, min(1.0, (x - a) / (b - a)))
    return t * t * (3 - 2 * t)

def shape(p):
    """unit sphere -> anime head: round cranium, tapered jaw and a small chin, soft cheeks, flatter face plane"""
    x, y, z = p
    fr = max(0.0, z)
    low = ss(0.05, -0.95, y)
    x *= 1 - low * (0.3 + 0.26 * fr) - 0.16 * low ** 3 * fr
    yn = y - low * fr * fr * 0.1 - 0.12 * low * low * ss(-0.1, 0.6, z) + 0.22 * low * low * ss(0.1, -0.7, z)
    z *= 1 - low * 0.34 * (1 - fr)
    if z > 0:
        z *= 1 - 0.07 * ss(-0.7, 0.2, y) * (1 - low * 0.5)
        z *= 1 + low * fr * 0.06
    cheek = math.exp(-((y + 0.22) / 0.25) ** 2) * ss(0.25, 0.75, abs(x)) * fr
    k = 1 + 0.035 * cheek
    x, yn, z = x * k, yn, z * k
    if z < 0:
        z *= 1 + 0.07 * ss(-0.3, 0.6, y)
    return Vector((x * SX, yn * SY, z * SZ))

def head_radius(d):
    """radius of the head surface along unit direction d (unit-sphere units, scaled)"""
    return shape(d.normalized()).length

def push_out(P, margin):
    d = P.normalized()
    r = head_radius(d) + margin
    return d * r if P.length < r else P

def new_obj(name, bm):
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me)
    bm.free()
    ob = bpy.data.objects.new(name, me)
    bpy.context.collection.objects.link(ob)
    return ob

def shade_smooth(ob):
    for p in ob.data.polygons:
        p.use_smooth = True

for o in list(bpy.data.objects):
    bpy.data.objects.remove(o)

# ---------- head ----------
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=40, v_segments=28, radius=1.0)
orig = {}
for v in bm.verts:
    # bmesh spheres are z-up: turn into y-up, face looking +z
    x, y, z = v.co.x, v.co.z, -v.co.y
    orig[v.index] = (x, y, z)
    v.co = shape((x, y, z))
uvl = bm.loops.layers.uv.new('UVMap')
for f in bm.faces:
    cz = sum(orig[l.vert.index][2] for l in f.loops) / len(f.loops)
    for l in f.loops:
        x, y, z = orig[l.vert.index]
        if cz < -0.05:
            l[uvl].uv = (0.02, 0.98)       # plain skin corner of the face texture
        else:
            l[uvl].uv = (0.5 + x * 0.5 / UVS, 0.5 + y * 0.5 / UVS)
# ears
for s in (-1, 1):
    e = bmesh.ops.create_uvsphere(bm, u_segments=12, v_segments=8, radius=1.0)
    for v in e['verts']:
        x, y, z = v.co.x * 0.11, v.co.z * 0.2, -v.co.y * 0.15
        v.co = Vector((s * 0.9 + x * 0.6, -0.08 + y, -0.05 + z)) * 1.0
        v.co.x *= SX
    for f in {f for v in e['verts'] for f in v.link_faces}:
        for l in f.loops:
            l[uvl].uv = (0.02, 0.98)
head = new_obj('head', bm)
shade_smooth(head)
m = head.modifiers.new('sub', 'SUBSURF'); m.levels = 1; m.render_levels = 1
head.scale = (R, R, R)

# ---------- hair cap: the head pushed out, the face cut away, given a little thickness ----------
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=40, v_segments=28, radius=1.0)
kill = []
for v in bm.verts:
    x, y, z = v.co.x, v.co.z, -v.co.y
    d = Vector((x, y, z))
    bump = 1.0 + 0.035 * math.sin(5 * math.atan2(x, -z) + 1.3) * ss(-0.2, 0.6, y)
    v.co = shape((x, y, z)) * (1.075 * bump)
    hairline = 0.5 - 0.25 * ss(0.35, 0.85, abs(x))     # forehead is hidden by bangs, sides come down to the temples
    if (z > 0.2 and y < hairline) or (z > -0.1 and y < -0.15 - 0.0 * abs(x)) or y < -0.62:
        kill.append(v)
bmesh.ops.delete(bm, geom=kill, context='VERTS')
cap = new_obj('cap', bm)
shade_smooth(cap)
m = cap.modifiers.new('solid', 'SOLIDIFY'); m.thickness = 0.05; m.offset = -1
cap.scale = (R, R, R)

# ---------- strands: lens-shaped ribbons along a Catmull-Rom path, flat side facing away from the skull ----------
def catmull(pts, n):
    P = [pts[0] * 2 - pts[1]] + pts + [pts[-1] * 2 - pts[-2]]
    out = []
    segs = len(pts) - 1
    for i in range(n):
        t = i / (n - 1) * segs
        k = min(int(t), segs - 1)
        u = t - k
        p0, p1, p2, p3 = P[k], P[k + 1], P[k + 2], P[k + 3]
        out.append(0.5 * ((2 * p1) + (-p0 + p2) * u + (2 * p0 - 5 * p1 + 4 * p2 - p3) * u * u + (-p0 + 3 * p1 - 3 * p2 + p3) * u ** 3))
    return out

STRANDS = []
def strand(pts, w, thick=0.32, n=18, ring=6, margin=0.07, prof=None, shade=0.0, curl=0.0, centre=Vector((0, 0, 0))):
    pts = [Vector(p) for p in pts]
    S = catmull(pts, n)
    S = [push_out(p, margin) if margin is not None else p for p in S]
    STRANDS.append((S, w, thick, ring, prof, shade, curl, centre))

def build_strands(name, items, scale):
    bm = bmesh.new()
    col = bm.loops.layers.color.new('Col')
    for S, w, thick, ring, prof, shade, curl, centre in items:
        n = len(S)
        rings = []
        for i, P in enumerate(S):
            T = (S[min(i + 1, n - 1)] - S[max(i - 1, 0)]).normalized()
            N = (P - centre)
            N = (N - T * N.dot(T)).normalized()
            B = T.cross(N).normalized()
            t = i / (n - 1)
            ww = w * (prof(t) if prof else (1 - t) ** 0.75 * (0.8 + 0.45 * math.sin(math.pi * min(1, t * 1.6))))
            ring_v = []
            for k in range(ring):
                a = 2 * math.pi * k / ring
                ca, sa = math.cos(a), math.sin(a)
                # lens cross-section, bowed so the ribbon wraps around the head
                off = B * ca * ww + N * (sa * ww * thick - (ca * ca) * ww * curl)
                ring_v.append(bm.verts.new(P + off))
            rings.append((ring_v, t))
        for i in range(n - 1):
            a, ta = rings[i]
            b, tb = rings[i + 1]
            for k in range(ring):
                f = bm.faces.new((a[k], a[(k + 1) % ring], b[(k + 1) % ring], b[k]))
                for l in f.loops:
                    tt = ta if l.vert in a else tb
                    side = (l.vert.co - centre).length
                    c = 0.82 + 0.3 * tt + shade
                    l[col] = (c, c, c, 1.0)
        bm.faces.new(rings[0][0][::-1])
    ob = new_obj(name, bm)
    shade_smooth(ob)
    ob.scale = (scale, scale, scale)
    return ob

def sph(theta, y, r=1.0):
    """point on the head at azimuth theta (0 = front, +x = pi/2) and height y"""
    c = math.sqrt(max(0.0, 1 - y * y))
    d = Vector((math.sin(theta) * c, y, math.cos(theta) * c))
    return d * head_radius(d) * r

# bangs: messy, fanned across the forehead, tips stopping above the eyes
bang_x = [-0.62, -0.47, -0.33, -0.2, -0.07, 0.05, 0.18, 0.31, 0.45, 0.6]
for i, bx in enumerate(bang_x):
    th = bx * 1.05
    root = sph(th * 0.6, 0.86, 1.08)
    tipy = [0.3, 0.2, 0.26, 0.17, 0.24, 0.16, 0.25, 0.18, 0.22, 0.32][i]
    sway = 0.07 * (1 if i % 2 else -1) + bx * 0.15
    mid = sph(th + sway * 0.5, 0.6, 1.1)
    tip = sph(th + sway, tipy, 1.06)
    tip = tip + Vector((0, 0, 0.04))
    strand([root, mid, tip], 0.19 + 0.04 * (i % 3), thick=0.3, margin=0.055, shade=(-0.06 if i % 3 == 1 else 0.04), curl=0.25)
# a few long bang pieces between and beside the eyes
for bx, ty in [(-0.11, -0.02), (0.12, 0.04), (-0.4, 0.05)]:
    strand([sph(bx * 0.5, 0.88, 1.08), sph(bx, 0.55, 1.1), sph(bx * 1.15, ty, 1.05) + Vector((0, 0, 0.05))], 0.11, thick=0.3, margin=0.06, curl=0.2)
# side locks framing the face: hang straight down beside the cheeks
for s in (-1, 1):
    strand([sph(s * 1.0, 0.72, 1.09), Vector((s * 0.9, 0.2, 0.5)), Vector((s * 0.84, -0.35, 0.44)), Vector((s * 0.78, -0.82, 0.36))],
           0.2, thick=0.3, margin=0.06, curl=0.3, prof=lambda t: (1 - t) ** 0.6 * (0.9 + 0.3 * math.sin(math.pi * t)))
    strand([sph(s * 1.35, 0.68, 1.08), Vector((s * 0.97, 0.1, 0.12)), Vector((s * 0.92, -0.42, 0.1))], 0.24, thick=0.3, margin=0.07, curl=0.3, shade=-0.05)
# short layers over the sides, wisps at the nape, and the back hair swept up into the ponytail
for k in range(6):
    for sg in (-1, 1):
        th = sg * math.radians(95 + k * 12)
        endy = [-0.2, -0.42, -0.28, -0.5, -0.3, -0.45][k]
        strand([sph(th, 0.6, 1.07), sph(th, 0.1, 1.1), sph(th + sg * 0.05, endy, 1.14)], 0.3, thick=0.28, margin=0.075, curl=0.25,
               shade=(-0.06 if k % 2 else 0.02))
for k in range(5):
    th = math.pi + (k - 2) * 0.22
    strand([sph(th, -0.2, 1.07), sph(th + (k - 2) * 0.04, -0.5, 1.09), sph(th + (k - 2) * 0.08, -0.68, 1.12)], 0.2, thick=0.28, margin=0.06, curl=0.2)
TIE = Vector((0, 0.74, -0.85))
for k in range(9):
    th = math.pi + (k - 4) * 0.3
    r0 = sph(th, -0.45, 1.075)
    m1 = sph(th - (k - 4) * 0.06, 0.15, 1.1)
    strand([r0, m1, TIE * 1.05 + Vector(((k - 4) * 0.03, 0, 0))], 0.3, thick=0.22, margin=0.06, curl=0.3,
           prof=lambda t: 1.0 - 0.55 * t, shade=(-0.07 if k % 2 else 0.0))
# messy tufts on the crown
for x, z, l in [(-0.3, 0.1, 0.6), (0.34, 0.0, 0.6), (0.05, -0.2, 0.7)]:
    r = sph(math.atan2(x, z + 0.3), 0.93, 1.06)
    strand([r, r + Vector((x * 0.3, 0.13 * l, -0.22)), r + Vector((x * 0.6, 0.02, -0.45))], 0.24, thick=0.32, margin=None, curl=0.15)
# ahoge
a0 = sph(0.1, 0.99, 1.05)
strand([a0, a0 + Vector((0.04, 0.3, 0.06)), a0 + Vector((0.18, 0.44, -0.04)), a0 + Vector((0.3, 0.33, -0.16))], 0.07, thick=0.6, margin=None,
       prof=lambda t: (1 - t) ** 0.6)
hair = build_strands('hair', STRANDS, R)

# ---------- ponytail: four bundles, each in its own bone's frame, hanging along -y from the joint ----------
TAIL = [[0.04, 0.052, 0.08], [0.052, 0.062, 0.17], [0.062, 0.034, 0.2], [0.034, 0.006, 0.15]]
tails = []
for si, (rt, rb, ln) in enumerate(TAIL):
    STRANDS = []
    top = 0.25 * ln if si else 0.0
    nst = 10
    for k in range(nst):
        a = 2 * math.pi * k / nst + si * 0.5
        core = k == 0
        pts = []
        for j in range(5):
            t = j / 4
            y = top - (ln + top) * t
            r = (rt + (rb - rt) * t) * (0.0 if core else 0.7)
            spl = (0.9 * t * t * rt if si == 3 else 0.06 * rt * math.sin(k * 2.1 + si))
            aa = a + 0.7 * t
            pts.append(Vector((math.cos(aa) * (r + spl), y, math.sin(aa) * (r + spl) * 0.8)))
        w = (rt + rb) * 0.5 * (0.85 if core else 0.48)
        prof = (lambda t: (1 - t) ** 0.7 + 0.05) if si == 3 else (lambda t: 1.0 - 0.15 * t)
        STRANDS.append(([p for p in catmull(pts, 10)], w, 0.55 if core else 0.4, 8, prof, (-0.05 if k % 2 else 0.03), 0.0,
                        Vector((0, 0, 0)) if core else None))
    # bundle strands face outward from the bundle's axis
    fixed = []
    for S, w, th, ring, prof, shade, curl, centre in STRANDS:
        fixed.append((S, w, th, ring, prof, shade, curl, Vector((0, S[len(S) // 2].y, 0)) if centre is None else Vector((0.001, S[len(S) // 2].y, 0.001))))
    tails.append(build_strands('tail%d' % si, fixed, 1.0))

# ---------- export ----------
def b64(fmt, arr):
    return base64.b64encode(struct.pack('<%d%s' % (len(arr), fmt), *arr)).decode()

def export(ob, uv=False, col=False):
    dg = bpy.context.evaluated_depsgraph_get()
    ev = ob.evaluated_get(dg)
    me = ev.to_mesh()
    me.calc_loop_triangles()
    mw = ob.matrix_world
    uvd = me.uv_layers.active.data if uv else None
    cold = me.color_attributes.get('Col') if col else None
    verts, index, key = [], [], {}
    for tri in me.loop_triangles:
        for li in tri.loops:
            vi = me.loops[li].vertex_index
            u = tuple(round(c, 4) for c in uvd[li].uv) if uv else None
            c = round(cold.data[li].color[0], 3) if col else None
            k = (vi, u, c)
            if k not in key:
                key[k] = len(verts)
                v = me.vertices[vi]
                p = mw @ v.co
                n = (mw.to_3x3() @ v.normal).normalized()
                verts.append((p, n, u, c))
            index.append(key[k])
    lim = max(max(abs(c) for c in p) for p, _, _, _ in verts) * 1.001
    pos = [int(round(c / lim * 32767)) for p, _, _, _ in verts for c in p]
    nor = [int(round(c * 127)) for _, n, _, _ in verts for c in n]
    d = {'n': len(verts), 'lim': lim, 'pos': b64('h', pos), 'nor': b64('b', nor)}
    d['idx'] = b64('H' if len(verts) < 65536 else 'I', index)
    d['i32'] = len(verts) >= 65536
    if uv:
        d['uv'] = b64('H', [int(round(min(1, max(0, c)) * 65535)) for _, _, u, _ in verts for c in u])
    if col:
        d['col'] = b64('B', [int(round(min(1.2, c) / 1.2 * 255)) for _, _, _, c in verts])
    ev.to_mesh_clear()
    print(ob.name, len(verts), 'verts', len(index) // 3, 'tris')
    return d

# the hair cap's solidify needs real scale applied so its thickness is in head units
data = {'head': export(head, uv=True), 'cap': export(cap), 'hair': export(hair, col=True)}
for i, t in enumerate(tails):
    data['tail%d' % i] = export(t, col=True)
json.dump(data, open(OUT, 'w'))
print('wrote', OUT)
