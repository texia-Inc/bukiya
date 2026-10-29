
/* ---------- the heroine model: made in VRoid Studio and reworked in Blender (tools/umimachi/heroine_vrm.py), driven by the skater rig ----------
   The procedural skater still computes the pose (and carries the board); its body is hidden and the model's bones follow it:
   torso, neck and head copy the rig's rotations, the arms swing to the rig's elbow and hand positions, and the legs are solved
   with their own two-bone IK so the sneakers stay on the deck. */
const FACE_MATS=/^(Face|Eye|FaceMouth|FaceEyeline|FaceBrow|EyeHighlight)/;
function olSkinned(w,morph){const key='s'+w.toFixed(4)+(morph?'m':'');if(OL[key])return OL[key];
  const m=new THREE.MeshBasicMaterial({color:'#2d241d',side:THREE.BackSide,skinning:true,morphTargets:!!morph});
  m.onBeforeCompile=sh=>{sh.vertexShader=sh.vertexShader.replace('#include <begin_vertex>','vec3 transformed = position + normal * '+w.toFixed(4)+';');};
  m.customProgramCacheKey=()=>'ols'+key;return OL[key]=m;}
function makeSkaterVRM(gl){
  const h=makeSkater();
  h.root.traverse(o=>{if(o.isMesh){let p=o,onBoard=false;while(p){if(p===h.board){onBoard=true;break;}p=p.parent;}if(!onBoard)o.visible=false;}});
  const model=gl.scene;model.scale.setScalar(1/0.96);h.root.add(model);
  const B={};model.traverse(o=>{if(o.isBone)B[o.name]=o;});
  const morphs=[],parts=[],hair=[],guns=[];
  model.traverse(o=>{if(!o.isMesh)return;o.castShadow=true;o.frustumCulled=false;
    const src=o.material,name=src.name||'',face=FACE_MATS.test(name);
    if(src.map){src.map.encoding=THREE.LinearEncoding;src.map.needsUpdate=true;}
    const col=src.map?new THREE.Color(1,1,1):src.color.clone().convertLinearToSRGB();
    const opt={map:src.map||null,color:col,skinning:!!o.isSkinnedMesh,morphTargets:!!o.morphTargetInfluences,transparent:src.transparent,alphaTest:src.alphaTest,side:src.side,depthWrite:src.depthWrite};
    o.material=face?new THREE.MeshBasicMaterial(opt):new THREE.MeshToonMaterial(Object.assign(opt,{gradientMap:GRAD}));
    if(o.morphTargetDictionary)morphs.push(o);
    // wardrobe parts (W_*) can be shown, hidden and tinted; white parts take the tint, coloured ones keep their colour
    if(/^W_/.test(o.name))parts.push({name:o.name,mesh:o,base:o.material.color.clone(),map0:o.material.map,tintable:o.material.color.r>0.98&&o.material.color.g>0.98&&o.material.color.b>0.98});
    if(/^Hair/.test(name)&&o.material.map){o.userData.map0=o.material.map;hair.push(o);}
    if(/^Gun_/.test(o.name)){guns.push(o);o.visible=false;}   // the pistols, out only in the drone fight
    const olw=/HAIR|Hair/.test(name)?0.0022:/Body_00|Tops|Bottoms|Shoes|Cloth_(Skirt|Pack|Hood|Sleeves|Socks|KneeSocks)/.test(name)?0.0026:0;
    if(olw&&o.isSkinnedMesh&&!src.transparent){const ol=new THREE.SkinnedMesh(o.geometry,olSkinned(olw,!!o.morphTargetInfluences));ol.bind(o.skeleton,o.bindMatrix);ol.frustumCulled=false;
      if(o.morphTargetInfluences)ol.morphTargetInfluences=o.morphTargetInfluences;o.parent.add(ol);o.userData.ol=ol;ol.position.copy(o.position);ol.quaternion.copy(o.quaternion);ol.scale.copy(o.scale);}});
  model.updateMatrixWorld(true);
  // rest pose, in the model's own space
  const inv=new THREE.Matrix4().copy(model.matrixWorld).invert(),rest={};
  for(const n in B){const b=B[n],m=new THREE.Matrix4().multiplyMatrices(inv,b.matrixWorld),p=new THREE.Vector3(),q=new THREE.Quaternion(),s=new THREE.Vector3();m.decompose(p,q,s);rest[n]={p,q,local:b.quaternion.clone()};}
  const dirRest=(a,b)=>rest[b].p.clone().sub(rest[a].p).normalize();
  const legs={},arms={};
  for(const [S,sx] of [['L',1],['R',-1]]){
    legs[sx]={up:B['J_Bip_'+S+'_UpperLeg'],lo:B['J_Bip_'+S+'_LowerLeg'],ft:B['J_Bip_'+S+'_Foot'],dUp:dirRest('J_Bip_'+S+'_UpperLeg','J_Bip_'+S+'_LowerLeg'),dLo:dirRest('J_Bip_'+S+'_LowerLeg','J_Bip_'+S+'_Foot'),
      l1:rest['J_Bip_'+S+'_UpperLeg'].p.distanceTo(rest['J_Bip_'+S+'_LowerLeg'].p),l2:rest['J_Bip_'+S+'_LowerLeg'].p.distanceTo(rest['J_Bip_'+S+'_Foot'].p),n:S};
    arms[sx]={up:B['J_Bip_'+S+'_UpperArm'],lo:B['J_Bip_'+S+'_LowerArm'],hand:B['J_Bip_'+S+'_Hand'],dUp:dirRest('J_Bip_'+S+'_UpperArm','J_Bip_'+S+'_LowerArm'),dLo:dirRest('J_Bip_'+S+'_LowerArm','J_Bip_'+S+'_Hand'),n:S,
      l1:rest['J_Bip_'+S+'_UpperArm'].p.distanceTo(rest['J_Bip_'+S+'_LowerArm'].p),l2:rest['J_Bip_'+S+'_LowerArm'].p.distanceTo(rest['J_Bip_'+S+'_Hand'].p)};}
  const hipDrop=rest.J_Bip_C_Hips.p.y-rest.J_Bip_L_UpperLeg.p.y;
  const tail=[0,1,2,3].map(i=>B['Tail'+i]).filter(Boolean);
  const ctail=[0,1,2,3].map(i=>B['CTail'+i]).filter(Boolean);
  // the model's twist/aim helper bones (VRMC_node_constraint in the source file), evaluated here every frame
  const cons=[];
  for(const S of ['L','R']){
    for(const [n,src] of [['J_Aim_'+S+'_Shoulder','J_Bip_'+S+'_LowerArm'],['J_Aim_'+S+'_TopsUpperArm','J_Bip_'+S+'_LowerArm'],['J_Aim_'+S+'_UpperLeg','J_Bip_'+S+'_LowerLeg']])
      if(B[n]&&B[src])cons.push({aim:true,b:B[n],n,src:B[src],d:dirRest(n,src)});
    for(const [n,src,w] of [['J_Roll_'+S+'_UpperArm','J_Bip_'+S+'_UpperArm',0.5],['J_Roll_'+S+'_Elbow','J_Bip_'+S+'_LowerArm',0.5],['J_Roll_'+S+'_LowerArm','J_Bip_'+S+'_Hand',0.5],['J_Roll_'+S+'_Hand','J_Bip_'+S+'_Hand',1]])
      if(B[n]&&B[src])cons.push({aim:false,b:B[n],n,src:B[src],sn:src,w});}
  // the muzzles, as points on the hand bones: the middle of the front face of each slide (the barrel runs along the arm, +x on the left)
  const muzzle={};
  for(const [S,sx] of [['L',1],['R',-1]]){const g=guns.find(o=>o.name==='Gun_'+S);if(!g)continue;
    const pos=g.geometry.attributes.position,pts=[];let far=-1e9;
    for(let i=0;i<pos.count;i++){const w=g.localToWorld(new THREE.Vector3().fromBufferAttribute(pos,i)),x=w.clone().applyMatrix4(inv).x*sx;pts.push([x,w]);far=Math.max(far,x);}
    const tip=new THREE.Vector3();let n=0;for(const [x,w] of pts)if(x>far-0.004){tip.add(w);n++;}tip.multiplyScalar(1/n);
    const hand=B['J_Bip_'+S+'_Hand'],m=new THREE.Object3D();hand.add(m);m.position.copy(hand.worldToLocal(tip));muzzle[sx]=m;}
  h.vrm={model,B,rest,legs,arms,hipDrop,morphs,tail,ctail,cons,parts,hair,guns,muzzle,expr:{},t:0};
  return h;}
const _q1=new THREE.Quaternion(),_q2=new THREE.Quaternion(),_q3=new THREE.Quaternion(),_mq=new THREE.Quaternion(),_a=new THREE.Vector3(),_b=new THREE.Vector3(),_c=new THREE.Vector3(),_d=new THREE.Vector3();
// give bone b the model-space rotation q (model space = the model root's frame)
function setModelQ(V,b,q){b.parent.getWorldQuaternion(_q1);V.model.getWorldQuaternion(_mq);_q1.premultiply(_mq.invert());b.quaternion.copy(_q1.invert().multiply(q));b.updateMatrixWorld(true);}
function toModel(V,v){return V.model.worldToLocal(v);}
function swingTo(V,b,restName,dRest,dWant){_q2.setFromUnitVectors(dRest,_d.copy(dWant).normalize());_q3.copy(_q2).multiply(V.rest[restName].q);setModelQ(V,b,_q3);return _q2;}
function nodeQ(V,node,out){node.getWorldQuaternion(out);V.model.getWorldQuaternion(_mq);return out.premultiply(_mq.invert());}
function driveVRM(h,dt,s){const V=h.vrm,B=V.B,R=V.rest;V.t+=dt;
  h.g.updateMatrixWorld(true);
  // hips sit between the rig's hip joints
  const lt=h.legs[0].th,rt=h.legs[1].th;lt.getWorldPosition(_a);rt.getWorldPosition(_b);_a.add(_b).multiplyScalar(0.5);toModel(V,_a);_a.y+=V.hipDrop;
  const hips=B.J_Bip_C_Hips;hips.position.copy(hips.parent.worldToLocal(V.model.localToWorld(_a.clone())));
  const qh=nodeQ(V,h.hips,new THREE.Quaternion()),qt=nodeQ(V,h.torso,new THREE.Quaternion()),qhd=nodeQ(V,h.head,new THREE.Quaternion());
  const mul=(q,n)=>new THREE.Quaternion().copy(q).multiply(R[n].q);
  setModelQ(V,hips,mul(qh,'J_Bip_C_Hips'));
  setModelQ(V,B.J_Bip_C_Spine,mul(new THREE.Quaternion().copy(qh).slerp(qt,0.45),'J_Bip_C_Spine'));
  setModelQ(V,B.J_Bip_C_Chest,mul(new THREE.Quaternion().copy(qh).slerp(qt,0.8),'J_Bip_C_Chest'));
  setModelQ(V,B.J_Bip_C_UpperChest,mul(qt,'J_Bip_C_UpperChest'));
  for(const n of ['J_Bip_L_Shoulder','J_Bip_R_Shoulder']){B[n].quaternion.copy(R[n].local);B[n].updateMatrixWorld(true);}
  setModelQ(V,B.J_Bip_C_Neck,mul(new THREE.Quaternion().copy(qt).slerp(qhd,0.4),'J_Bip_C_Neck'));
  setModelQ(V,B.J_Bip_C_Head,mul(qhd,'J_Bip_C_Head'));
  // arms: swing each segment toward the rig's elbow and hand
  for(const A of h.arms){const M=V.arms[A.sx>0?1:-1];   // rig side +x is the model's left
    A.sh.getWorldPosition(_a);A.el.getWorldPosition(_b);A.el.localToWorld(_c.set(0,-0.25,0));toModel(V,_a);toModel(V,_b);toModel(V,_c);
    const up=M.up,lo=M.lo,gr=h.pose.gr||0;
    const hold=h.hold&&h.hold.sx===A.sx?h.hold:null;
    if((gr>0.01&&A.sx!==1)||hold){   // the back hand reaches for the toe edge of the deck in a grab; on foot, the left hand holds the nose
      const S0=up.getWorldPosition(new THREE.Vector3());toModel(V,S0);
      const E0=S0.clone().addScaledVector(_d.copy(_b).sub(_a).normalize(),M.l1),H0=E0.clone().addScaledVector(_d.copy(_c).sub(_b).normalize(),M.l2);
      const w=hold?hold.w:gr,T=hold?hold.T.clone():h.board.localToWorld(new THREE.Vector3(-0.1,0.16,-0.02));toModel(V,T);
      const dd=Math.min(S0.distanceTo(T),M.l1+M.l2-1e-3),dir=T.clone().sub(S0).normalize(),aa=(M.l1*M.l1-M.l2*M.l2+dd*dd)/(2*dd),hh=Math.sqrt(Math.max(0,M.l1*M.l1-aa*aa));
      const pole=E0.clone().sub(S0);pole.addScaledVector(dir,-pole.dot(dir)).normalize();
      const E1=S0.clone().addScaledVector(dir,aa).addScaledVector(pole,hh),H1=S0.clone().addScaledVector(dir,dd);
      const E=E0.lerp(E1,w),Hh=H0.lerp(H1,w);_a.copy(S0);_b.copy(E);_c.copy(Hh);}
    swingTo(V,up,'J_Bip_'+M.n+'_UpperArm',M.dUp,_d.copy(_b).sub(_a));
    const sw=swingTo(V,lo,'J_Bip_'+M.n+'_LowerArm',M.dLo,_d.copy(_c).sub(_b));
    _q3.copy(sw).multiply(R['J_Bip_'+M.n+'_Hand'].q);setModelQ(V,M.hand,_q3);}
  // legs: two-bone IK onto the rig's ankles, knees pointing forward and a little out
  for(const L of h.legs){const M=V.legs[L.sx>0?1:-1];
    M.up.getWorldPosition(_a);toModel(V,_a);L.ft.getWorldPosition(_b);toModel(V,_b);_b.y+=0.005;
    // a leg that cannot quite reach (the pushing foot on the ground) stretches up to 8%
    const raw=_a.distanceTo(_b),k=clamp(raw/((M.l1+M.l2)*0.995),1,1.08);M.up.scale.setScalar(k);M.ft.scale.setScalar(1/k);
    const l1=M.l1*k,l2=M.l2*k,d=Math.min(raw,l1+l2-1e-3),dir=_c.copy(_b).sub(_a).normalize(),a=(l1*l1-l2*l2+d*d)/(2*d),hh=Math.sqrt(Math.max(0,l1*l1-a*a));
    const pole=_d.set(L.sx*(h.kneeOut!=null?h.kneeOut:0.18),0,1);nodeQ(V,h.hips,_q1);pole.applyQuaternion(_q1);pole.addScaledVector(dir,-pole.dot(dir)).normalize();
    const knee=_a.clone().addScaledVector(dir,a).addScaledVector(pole,hh),tgt=_a.clone().addScaledVector(dir,d);
    swingTo(V,M.up,'J_Bip_'+M.n+'_UpperLeg',M.dUp,knee.clone().sub(_a));
    swingTo(V,M.lo,'J_Bip_'+M.n+'_LowerLeg',M.dLo,tgt.clone().sub(knee));
    setModelQ(V,M.ft,mul(nodeQ(V,L.ft,new THREE.Quaternion()),'J_Bip_'+M.n+'_Foot'));}
  // aiming the pistols (h.aim: world targets per side, h.aimW: 0-1): each arm straight at its target, rolled so the gun stands
  // upright and cants a little inward. The gun's top faces the model's front in the T-pose.
  for(const g of V.guns)g.visible=!!h.gunsOut;
  const aw=h.aimW||0;
  if(aw>0.001&&h.aim)for(const sx of [1,-1]){const M=V.arms[sx],T=h.aim[sx];if(!T)continue;
    const S0=toModel(V,M.up.getWorldPosition(new THREE.Vector3())),dir=toModel(V,T.clone()).sub(S0).normalize();
    const sUp=new THREE.Quaternion().setFromUnitVectors(M.dUp,dir),sLo=new THREE.Quaternion().setFromUnitVectors(M.dLo,dir);
    const top=new THREE.Vector3(0,0,1).applyQuaternion(sLo),want=new THREE.Vector3(-sx*0.35,1,0);
    top.addScaledVector(dir,-top.dot(dir)).normalize();want.addScaledVector(dir,-want.dot(dir)).normalize();
    const roll=new THREE.Quaternion().setFromUnitVectors(top,want),bones=[M.up,M.lo,M.hand];
    const tgt=[[sUp,'UpperArm'],[sLo,'LowerArm'],[sLo,'Hand']].map(([s,n])=>roll.clone().multiply(s).multiply(R['J_Bip_'+M.n+'_'+n].q));
    const cur=bones.map(b=>nodeQ(V,b,new THREE.Quaternion()));
    bones.forEach((b,k)=>setModelQ(V,b,cur[k].slerp(tgt[k],aw)));}
  for(const C of V.cons){if(C.aim){C.b.getWorldPosition(_a);C.src.getWorldPosition(_b);toModel(V,_a);toModel(V,_b);swingTo(V,C.b,C.n,C.d,_b.sub(_a));}
    else{_q1.copy(R[C.sn].local).invert().multiply(C.src.quaternion);_q2.identity().slerp(_q1,C.w);C.b.quaternion.copy(R[C.n].local).multiply(_q2);C.b.updateMatrixWorld(true);}}
  // ponytail: sways with speed, turns and jumps
  const acc=clamp(h.tailV||0,-0.35,0.35),sw=Math.sin(h.t*2.3)*0.06,turn=clamp(s.turn||0,-1,1);
  V.tail.forEach((b,k)=>{b.quaternion.copy(R[b.name].local);
    _q1.setFromEuler(new THREE.Euler(-(k?acc*0.6+(s.v||0)*0.02*(k===1?1:0.5):0)-Math.sin(h.t*3+k)*0.03,0,(sw*(k+1)*0.6+turn*0.15*k)));
    b.quaternion.multiply(_q1);});
  // the costume tail swishes lazily and streams back with speed
  V.ctail.forEach((b,k)=>{b.quaternion.copy(R[b.name].local);_q1.setFromEuler(new THREE.Euler(Math.sin(V.t*2.2+k*0.7)*0.12+(s.v||0)*0.012*k,0,Math.sin(V.t*1.6+k*0.9)*0.22*(k+1)*0.5));b.quaternion.multiply(_q1);});
  // face: blink, smile and the happy squint follow the rig's expression state
  const want={};const map=h.faceM&&h.faces;let ex='smile';if(map)for(const k in h.faces)if(h.faces[k]===h.faceM.map)ex=k;
  if(ex==='blink')want.Fcl_EYE_Close=1;else if(ex==='happy'){want.Fcl_ALL_Joy=1;}else if(ex==='smile'){want.Fcl_ALL_Fun=0.55;}else{want.Fcl_ALL_Fun=0.15;}
  if(s.talk&&Math.floor(h.t*7)%2)want.Fcl_MTH_A=0.5;
  for(const m of V.morphs){const D=m.morphTargetDictionary;for(const key in D){const short=key.replace(/^.*\./,'');const target=want[short]||0;const i=D[key];
      const cur=m.morphTargetInfluences[i];m.morphTargetInfluences[i]=short==='Fcl_EYE_Close'?target:cur+(target-cur)*Math.min(1,dt*10);}}
}
