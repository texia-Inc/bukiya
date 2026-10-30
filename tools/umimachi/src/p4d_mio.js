
/* ---------- Mio's model: made in VRoid Studio (design/mio.vrm) and set in her rest pose in Blender (tools/umimachi/mio_vrm.py).
   It takes the place of her procedural figure; she only breathes, keeps her head a little bowed and turns it towards Nagi
   when Nagi comes close. If mio.glb cannot be loaded she stays the procedural figure. ---------- */
function makeMioVRM(gl,n){const model=gl.scene,B={};
  model.traverse(o=>{if(o.isBone)B[o.name]=o;if(!o.isMesh)return;o.castShadow=true;o.frustumCulled=false;
    const src=o.material,face=FACE_MATS.test(src.name||'');
    if(src.map){src.map.encoding=THREE.LinearEncoding;src.map.needsUpdate=true;}
    const col=src.map?new THREE.Color(1,1,1):src.color.clone().convertLinearToSRGB();
    const opt={map:src.map||null,color:col,skinning:!!o.isSkinnedMesh,morphTargets:!!o.morphTargetInfluences,transparent:src.transparent,alphaTest:src.alphaTest,side:src.side,depthWrite:src.depthWrite};
    o.material=face?new THREE.MeshBasicMaterial(opt):new THREE.MeshToonMaterial(Object.assign(opt,{gradientMap:GRAD}));
    if(face)UNLIT_MATS.push({m:o.material,c:col.clone()});});
  n.h.g.traverse(o=>{if(o.isMesh)o.visible=false;});n.h.g.add(model);
  const V=n.vrm={head:B.J_Bip_C_Head,neck:B.J_Bip_C_Neck,chest:B.J_Bip_C_UpperChest||B.J_Bip_C_Chest,q0:{},t:0,ly:0};
  for(const k of ['head','neck','chest'])if(V[k])V.q0[k]=V[k].quaternion.clone();}
const _mioL=new THREE.Vector3();
function poseMio(n,dt,look){const V=n.vrm;if(!V)return;V.t+=dt;
  let yaw=0;if(look){_mioL.copy(look);n.h.g.worldToLocal(_mioL);yaw=clamp(Math.atan2(_mioL.x,_mioL.z),-0.9,0.9);}
  V.ly+=(yaw-V.ly)*Math.min(1,dt*2.5);
  if(V.chest){V.chest.quaternion.copy(V.q0.chest);V.chest.rotateX(Math.sin(V.t*1.5)*0.012);}   // breathing
  if(V.neck){V.neck.quaternion.copy(V.q0.neck);V.neck.rotateY(V.ly*0.4);}
  if(V.head){V.head.quaternion.copy(V.q0.head);V.head.rotateY(V.ly*0.6);V.head.rotateX(0.1);}}   // a little bowed
if(window.MIO_GLTF)makeMioVRM(window.MIO_GLTF,NPCS.mio);
