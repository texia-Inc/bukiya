# Turns the VRoid Studio model of Mio (design/mio.vrm: the girl in the white dress on the pier) into docs/umimachi/mio.glb.
# Mio only stands, breathes and turns her head in the game, so her hands are clasped behind her back here and that
# becomes the rest pose; the game moves nothing but the spine, neck and head. Sizes stay VRoid's metres.
# Blender works z-up with the model facing -y.
# Usage: Blender -b --python mio_vrm.py -- design/mio.vrm ../../docs/umimachi/mio.glb
import bpy, sys, os, re, shutil, tempfile
from mathutils import Vector, Quaternion

args = sys.argv[sys.argv.index('--') + 1:] if '--' in sys.argv else ['design/mio.vrm', '../../docs/umimachi/mio.glb']
SRC, OUT = args[0], args[1]
for o in list(bpy.data.objects):
    bpy.data.objects.remove(o)
src = SRC
if src.endswith('.vrm'):     # the glTF importer takes a .vrm once it is called .glb
    src = shutil.copy(SRC, os.path.join(tempfile.mkdtemp(), 'mio.glb'))
bpy.ops.import_scene.gltf(filepath=src)
ARM = next(o for o in bpy.data.objects if o.type == 'ARMATURE')
for o in list(bpy.data.objects):
    if o.type == 'MESH' and o.parent is None:      # VRoid's stray icosphere
        bpy.data.objects.remove(o)
# VRoid names materials like 'N00_000_00_Body_00_SKIN (Instance)'; the game matches 'Face_...', 'Eye...' for the unlit face
for m in bpy.data.materials:
    m.name = re.sub(r'^N\d+_\d+(_\d+)?_| \(Instance\)$', '', m.name)

def pose(rots):
    """rotate bones (about armature-space axes, each about its own head) and make the result the rest pose"""
    bpy.context.view_layer.objects.active = ARM
    bpy.ops.object.mode_set(mode='POSE')
    for name, q in rots.items():
        pb = ARM.pose.bones.get(name)
        if pb:
            r = pb.bone.matrix_local.to_quaternion()
            pb.rotation_mode = 'QUATERNION'
            pb.rotation_quaternion = r.inverted() @ q @ r
    bpy.ops.object.mode_set(mode='OBJECT')
    bpy.context.view_layer.update()
    for o in bpy.data.objects:
        mod = next((m for m in o.modifiers if m.type == 'ARMATURE'), None) if o.type == 'MESH' else None
        if not mod:
            continue
        bpy.context.view_layer.objects.active = o
        if o.data.shape_keys:         # a mesh with shape keys cannot take the modifier: bake the pose into each key instead
            keys = o.data.shape_keys.key_blocks
            dg = bpy.context.evaluated_depsgraph_get()
            for kb in keys:
                for k2 in keys:
                    k2.value = 0
                kb.value = 1 if kb != keys[0] else 0
                o.active_shape_key_index = list(keys).index(kb)
                dg.update()
                ev = o.evaluated_get(dg).data
                if len(ev.vertices) == len(kb.data):
                    for v, d in zip(ev.vertices, kb.data):
                        d.co = v.co
            for k2 in keys:
                k2.value = 0
            o.data.vertices.foreach_set('co', [c for d in keys[0].data for c in d.co])
        else:
            bpy.ops.object.modifier_apply(modifier=mod.name)
            o.modifiers.new('Armature', 'ARMATURE').object = ARM
    bpy.context.view_layer.objects.active = ARM
    bpy.ops.object.mode_set(mode='POSE'); bpy.ops.pose.armature_apply(); bpy.ops.object.mode_set(mode='OBJECT')

# hands clasped behind the back: the upper arms hang down and swing back, the elbows bend so the forearms cross behind the
# waist (each pass is made the rest pose before the next, so its axes are the armature's)
UP_DOWN, UP_BACK, FORE_IN, FORE_BACK, HAND = 1.3, 0.24, 1.25, -0.12, 0.35
# 1) arms down from the T-pose (the left arm points +x, the right -x) and back (back is +y), hands lightly closed
rots = {'J_Bip_L_UpperArm': Quaternion((1, 0, 0), UP_BACK) @ Quaternion((0, 1, 0), UP_DOWN),
        'J_Bip_R_UpperArm': Quaternion((1, 0, 0), UP_BACK) @ Quaternion((0, 1, 0), -UP_DOWN)}
CURL = {'Index': (0.5, 0.6, 0.4), 'Middle': (0.55, 0.65, 0.45), 'Ring': (0.6, 0.7, 0.45), 'Little': (0.65, 0.75, 0.45)}
for S, sx in (('L', 1), ('R', -1)):
    for f, angs in CURL.items():
        for i, a in enumerate(angs):
            rots['J_Bip_%s_%s%d' % (S, f, i + 1)] = Quaternion((0, 1, 0), a * sx)
pose(rots)
# 2) the forearms turn in towards the middle of the back (about y) and a little further back (about x)
pose({'J_Bip_L_LowerArm': Quaternion((1, 0, 0), FORE_BACK) @ Quaternion((0, 1, 0), FORE_IN),
      'J_Bip_R_LowerArm': Quaternion((1, 0, 0), FORE_BACK) @ Quaternion((0, 1, 0), -FORE_IN)})
# 3) the hands follow on round so one rests in the other
pose({'J_Bip_L_Hand': Quaternion((0, 1, 0), HAND), 'J_Bip_R_Hand': Quaternion((0, 1, 0), -HAND)})

# keep only the base colour texture, and keep it small
for m in bpy.data.materials:
    if not m.use_nodes:
        continue
    for n in list(m.node_tree.nodes):
        if n.type == 'NORMAL_MAP':
            m.node_tree.nodes.remove(n)
LIMIT = {'Face_00': 1024, 'Body_00': 1024, 'Tops': 512, 'Onepiece': 512}
for im in bpy.data.images:
    if im.size[0] == 0:
        continue
    lim = next((v for k, v in LIMIT.items() if k in im.name), 512)
    w, h = im.size
    s = min(1.0, lim / max(w, h))
    if s < 1:
        im.scale(max(1, int(w * s)), max(1, int(h * s)))

bpy.ops.export_scene.gltf(filepath=OUT, export_format='GLB', use_selection=False, export_skins=True, export_morph=True,
                          export_morph_normal=False, export_animations=False, export_image_format='AUTO', export_yup=True,
                          export_extras=False, export_cameras=False, export_lights=False)
print('wrote', OUT, os.path.getsize(OUT))
