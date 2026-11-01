/* ---------- 鏡の海 (a trial): in 裏海街 the sea has drained to a black mirror, flat and open, nothing to catch the board on.
   Riding leaves a line of light on it; bring the line back round to where it was and the ring closes, and every shadow inside
   it burns away at once. The shadows rise out of the mirror and come for Nagi; a touch costs a heart. Three minutes, then dawn.
   The drowned town shows through: hip roofs to ride up and fly off, a torii and an upturned boat to grind, the broken ends of
   the pier for kickers. The mirror really mirrors (a second look from under the water, cut at the surface). On the way to
   dawn: a swarm at 0:55 and 1:55, red shadows from 1:00 that cut the line, and at 2:20 a great shadow that takes three rings.
   Mio's blue marble helps: thrown (the 歩く button turns into ビー玉 out here), it rolls ahead and leaves a blue line from where
   she threw it; ride round and back onto that line, or throw it back across her own older line, and the ring closes the same way.
   Tricks help too: those of a jump, landed clean, take seconds off the marble's wait (a fall adds one), and line drawn while
   grinding burns gold, holds the whole line from fading while she is on the rail, and a ring with gold in it scores half again.
   Out from the command table (hqCommand in p5q_hq.js). Like the HQ it lies far off the map (x around MIR_X). ---------- */
const MIR_X=-9000,MIR_R=70;
const MIR_LIFE=8,MIR_STEP=0.5,MIR_GAP=14,MIR_CLOSE=2.6,MIR_MAX=700;   // the line lasts 8 s; a ring needs 7 m of line and closes within 2.6 m
const MIR_FOE={normal:{hp:1,sp:2.6,s:1,pts:10},fast:{hp:1,sp:4.3,s:0.9,pts:15},big:{hp:2,sp:1.8,s:1.6,pts:40},swarm:{hp:1,sp:3.3,s:0.72,pts:8},
  red:{hp:1,sp:2.4,s:1.05,pts:30},boss:{hp:3,sp:2.1,s:3,pts:500}};
const MIR={on:false,go:false,end:false,g:null,trail:[],foes:[],fx:[],t:0,dur:180,hearts:5,inv:0,kills:0,score:0,combo:0,comboT:0,best:0,spawnT:0,hudT:0,core:null,halo:null,head:null,
  waves:{},boss:null,bossDown:false,redSaid:false,moon:null,floor:null,rt:null,rcam:null,clip:null,ml:null,mcd:0,ball:null,mcore:null,mhalo:null};
const MIR_MCD=5;   // a marble every five seconds
// the drowned town, in metres from the middle of the mirror: [x, z, heading, length, width, height]
const MIR_ROOFS=[[-25,-20,0.3,14,7,2.2],[28,-8,1.2,12,6,1.8],[-30,22,-0.5,10,6,1.6],[22,34,0.8,16,7,2.4],[0,-46,0,18,8,2.6],[-50,-4,1.57,12,6,1.8],[45,-36,0.4,10,6,1.6],[50,30,-0.9,11,6,1.9]];
const MIR_BOATS=[[-12,-30,0.9,8,2.6,0.8],[36,10,-0.2,7,2.4,0.7]];
const MIR_RAMPS=[[-15,-12,Math.PI/2,6,3,1.3],[-23,-58,Math.PI/2,6,3,1.3],[12,6,-0.6,6,3,1.2],[-14,40,2.4,6,3,1.2],[40,-14,-2.2,6,3,1.3],[-22,-44,0.5,7,3,1.4],[-40,10,1.2,6,3,1.2]];
const MIR_TORII=[[0,-12],[-8,-58]];
// the height of the mirror's floor: hip roofs and boat hulls (a ridge with four slopes), and the planks of the kickers
function mirG(x,z){const lx=x-MIR_X;let y=0;
  for(const [rx,rz,a,L,W,h] of MIR_ROOFS.concat(MIR_BOATS)){const dx=lx-rx,dz=z-rz,al=dx*Math.sin(a)+dz*Math.cos(a),pe=dx*Math.cos(a)-dz*Math.sin(a);
    const k=Math.min(1-Math.abs(pe)/(W/2),(L/2-Math.abs(al))/(W/2));if(k>0)y=Math.max(y,h*Math.min(1,k));}
  for(const [rx,rz,a,L,W,h] of MIR_RAMPS){const dx=lx-rx,dz=z-rz,al=dx*Math.sin(a)+dz*Math.cos(a),pe=dx*Math.cos(a)-dz*Math.sin(a);
    if(al>0&&al<L&&Math.abs(pe)<W/2)y=Math.max(y,h*al/L);}
  return y;}
function mirBuild(){if(MIR.g)return;const g=new THREE.Group();scene.add(g);MIR.g=g;g.visible=false;
  // the mirror: a deep blue that darkens outward, with soft patches of sheen (no points of light: those read as things to pick up)
  const fl=canvasTex(512,512,(c,w,h)=>{const r=c.createRadialGradient(w/2,h/2,8,w/2,h/2,w/2);r.addColorStop(0,'#1a2a44');r.addColorStop(0.55,'#0e1a2e');r.addColorStop(1,'#04070d');c.fillStyle=r;c.fillRect(0,0,w,h);
    for(let k=0;k<18;k++){const x=Math.random()*w,y=Math.random()*h,R=30+Math.random()*60,g=c.createRadialGradient(x,y,0,x,y,R);g.addColorStop(0,'rgba(120,150,200,.07)');g.addColorStop(1,'rgba(120,150,200,0)');c.fillStyle=g;c.fillRect(x-R,y-R,R*2,R*2);}});
  // and what stands above it, seen again from under the surface (mirReflect renders it each frame), rippling a little
  MIR.rt=new THREE.WebGLRenderTarget(256,256);MIR.rcam=new THREE.PerspectiveCamera();MIR.clip=new THREE.Plane(new THREE.Vector3(0,1,0),0);
  const fm=new THREE.ShaderMaterial({uniforms:{tBase:{value:fl},tRef:{value:MIR.rt.texture},texMat:{value:new THREE.Matrix4()},uT:{value:0},uDawn:{value:0}},
    vertexShader:'varying vec2 vUv;varying vec4 vRef;uniform mat4 texMat;void main(){vUv=uv;vRef=texMat*vec4(position,1.0);gl_Position=projectionMatrix*modelViewMatrix*vec4(position,1.0);}',
    fragmentShader:'uniform sampler2D tBase;uniform sampler2D tRef;uniform float uT;uniform float uDawn;varying vec2 vUv;varying vec4 vRef;'+
      'void main(){vec3 b=texture2D(tBase,vUv).rgb;vec4 r=vRef;r.x+=sin(vUv.y*180.0+uT*1.3)*0.005*r.w;r.y+=cos(vUv.x*150.0+uT*0.9)*0.003*r.w;'+
      'float e=smoothstep(0.5,0.18,length(vUv-0.5));gl_FragColor=vec4(b*(1.0+uDawn*0.6)+texture2DProj(tRef,r).rgb*(0.42+0.2*e)*e*(1.0-0.35*uDawn),1.0);}'});
  const floor=new THREE.Mesh(new THREE.CircleGeometry(MIR_R+90,72),fm);floor.rotation.x=-Math.PI/2;floor.position.set(MIR_X,0,0);g.add(floor);MIR.floor=floor;
  // the edge of the open water: a faint blue ring
  const edge=new THREE.Mesh(new THREE.RingGeometry(MIR_R-0.15,MIR_R+0.15,96),new THREE.MeshBasicMaterial({color:'#4a7ab8',transparent:true,opacity:0.5,blending:THREE.AdditiveBlending,depthWrite:false}));
  edge.rotation.x=-Math.PI/2;edge.position.set(MIR_X,0.03,0);g.add(edge);
  // the grey town far off across the mirror, a lamp here and there, and the moon
  const blk=new THREE.MeshBasicMaterial({color:'#0a0d14'}),win=new THREE.MeshBasicMaterial({color:'#e8c890',transparent:true,opacity:0.55});
  for(let k=0;k<70;k++){const a=k/70*TAU+Math.random()*0.04,r=165+Math.random()*25,w=6+Math.random()*12,h=4+Math.random()*14+(Math.abs(Math.sin(a*1.5))*16),x=MIR_X+Math.cos(a)*r,z=Math.sin(a)*r;
    const b=new THREE.Mesh(new THREE.BoxGeometry(w,h,6),blk);b.position.set(x,h/2,z);b.rotation.y=-a+Math.PI/2;g.add(b);
    if(Math.random()<0.35){const l=new THREE.Mesh(new THREE.PlaneGeometry(1,1.2),win);l.position.set(x-Math.cos(a)*3.1,1.5+Math.random()*(h-3),z-Math.sin(a)*3.1);l.lookAt(MIR_X,l.position.y,0);g.add(l);}}
  const moon=new THREE.Mesh(new THREE.CircleGeometry(9,32),new THREE.MeshBasicMaterial({color:'#e6ecf5',fog:false,transparent:true}));moon.position.set(MIR_X,70,-230);g.add(moon);MIR.moon=moon;
  // the street lamps of the drowned town, just beyond the open water, still burning
  for(let k=0;k<16;k++){const a=k/16*TAU+0.2,r=MIR_R+4+(k%3)*3,x=MIR_X+Math.cos(a)*r,z=Math.sin(a)*r,hh=2.4+(k%2)*1.2;
    const pole=new THREE.Mesh(new THREE.CylinderGeometry(0.09,0.11,hh,6),tm('#3a3f48'));pole.position.set(x,hh/2,z);pole.rotation.z=(k%4-1.5)*0.06;g.add(pole);
    const l=glow('#ffd9a0',x,hh+0.15,z,2.4);scene.remove(l);l.visible=true;g.add(l);}
  mirProps(g);
  // the line of light: a bright core and a soft halo, rebuilt from the trail every frame
  const rib=(w,col)=>{const geo=new THREE.BufferGeometry();geo.setAttribute('position',new THREE.BufferAttribute(new Float32Array(MIR_MAX*6),3));geo.setAttribute('color',new THREE.BufferAttribute(new Float32Array(MIR_MAX*6),3));
    const idx=[];for(let i=0;i<MIR_MAX-1;i++){const a=i*2;idx.push(a,a+1,a+2,a+1,a+3,a+2);}geo.setIndex(idx);
    const m=new THREE.Mesh(geo,new THREE.MeshBasicMaterial({vertexColors:true,transparent:true,blending:THREE.AdditiveBlending,depthWrite:false,side:THREE.DoubleSide,fog:false}));m.frustumCulled=false;m.userData={w,col:new THREE.Color(col)};g.add(m);return m;};
  MIR.halo=rib(1.5,'#2a5a9a');MIR.core=rib(0.32,'#bfe6ff');MIR.head=glow('#9fd4ff',0,0,0,2.2);
  MIR.halo.userData.gold=new THREE.Color('#8a5a18');MIR.core.userData.gold=new THREE.Color('#ffe6a0');
  MIR.mhalo=rib(1.3,'#2a2f9a');MIR.mcore=rib(0.28,'#9fb4ff');
  // the marble itself: a little blue glass ball with its own glow
  const ball=new THREE.Mesh(new THREE.SphereGeometry(0.16,14,10),new THREE.MeshBasicMaterial({color:'#7fb2ff'}));const bg=glow('#6f9cff',0,0,0,1.6);scene.remove(bg);bg.visible=true;bg.position.set(0,0,0);ball.add(bg);
  ball.visible=false;g.add(ball);MIR.ball=ball;}
// the roofs, the boats, the kickers and the torii: shapes to match mirG, and rails along the ridges, keels and the torii's beams
function mirProps(g){const hip=(L,W,h)=>{const a=L/2,b=W/2,c=Math.max(0,a-b),P=[[b,0,-a],[b,0,a],[0,h,c],[0,h,-c],[-b,0,a],[-b,0,-a]],v=[];
    const q=(i,j,k)=>v.push(...P[i],...P[j],...P[k]);q(0,2,1);q(0,3,2);q(4,3,5);q(4,2,3);q(1,2,4);q(5,3,0);
    const geo=new THREE.BufferGeometry();geo.setAttribute('position',new THREE.Float32BufferAttribute(v,3));geo.computeVertexNormals();return geo;};
  const put=(geo,col,x,z,a,y)=>{const m=new THREE.Mesh(geo,tm(col));m.position.set(MIR_X+x,y||0,z);m.rotation.y=a;outline(m,0.03);g.add(m);return m;};
  const rail=(x,z,a,half,top)=>{const s=Math.sin(a),c=Math.cos(a);RAILS.push({x0:MIR_X+x-s*half,z0:z-c*half,x1:MIR_X+x+s*half,z1:z+c*half,top});};
  for(const [x,z,a,L,W,h] of MIR_ROOFS){put(hip(L,W,h),'#3d4452',x,z,a);
    const cap=new THREE.Mesh(new THREE.BoxGeometry(0.22,0.18,Math.max(0.4,L-W)),tm('#262b34'));cap.position.set(MIR_X+x,h+0.04,z);cap.rotation.y=a;g.add(cap);if(L-W>2)rail(x,z,a,(L-W)/2-0.3,h+0.1);}
  for(const [x,z,a,L,W,h] of MIR_BOATS){put(hip(L,W,h),'#5a4634',x,z,a);if(L-W>2)rail(x,z,a,(L-W)/2-0.2,h+0.05);}
  for(const [x,z,a,L,W,h] of MIR_RAMPS){const geo=new THREE.BoxGeometry(W,h,L),p=geo.attributes.position;for(let i=0;i<p.count;i++)if(p.getY(i)>0&&p.getZ(i)<0)p.setY(i,-h/2);geo.computeVertexNormals();
    put(geo,'#6b5a44',x+Math.sin(a)*L/2,z+Math.cos(a)*L/2,a,h/2);}
  for(const [x,z] of MIR_TORII){const red='#b8442e';
    // tall enough to ride under, and nothing here stops the board (not even the posts: catching on things is no fun out here);
    // the kicker beside it sends her up onto the beam
    for(const sx of [-2.4,2.4]){const p=new THREE.Mesh(new THREE.CylinderGeometry(0.24,0.28,2.5,10),tm(red));p.position.set(MIR_X+x+sx,1.25,z);outline(p,0.02);g.add(p);}
    const k=new THREE.Mesh(new THREE.BoxGeometry(6.6,0.26,0.45),tm('#2a2224'));k.position.set(MIR_X+x,2.48,z);outline(k,0.02);g.add(k);
    const n=new THREE.Mesh(new THREE.BoxGeometry(6.0,0.16,0.3),tm(red));n.position.set(MIR_X+x,2.05,z);g.add(n);
    RAILS.push({x0:MIR_X+x-3.1,z0:z,x1:MIR_X+x+3.1,z1:z,top:2.62});}}
// the reflection: the scene again from the camera's mirror image under the surface, everything below the surface cut away
function mirReflect(){if(!MIR.on||AREA!=='mir'||!MIR.rt)return;const sz=renderer.getDrawingBufferSize(new THREE.Vector2()),w=Math.max(64,sz.x>>1),h=Math.max(64,sz.y>>1);
  if(MIR.rt.width!==w||MIR.rt.height!==h)MIR.rt.setSize(w,h);
  const c=camera,v=MIR.rcam;c.updateMatrixWorld();const d=c.getWorldDirection(new THREE.Vector3()),t=c.position.clone().add(d);t.y=-t.y;
  const up=new THREE.Vector3(0,1,0).applyQuaternion(c.quaternion);up.y=-up.y;v.position.set(c.position.x,-c.position.y,c.position.z);v.up.copy(up);v.lookAt(t);
  v.fov=c.fov;v.aspect=c.aspect;v.near=c.near;v.far=c.far;v.updateProjectionMatrix();v.updateMatrixWorld();
  const M=MIR.floor.material.uniforms.texMat.value;M.set(0.5,0,0,0.5,0,0.5,0,0.5,0,0,0.5,0.5,0,0,0,1);M.multiply(v.projectionMatrix).multiply(v.matrixWorldInverse).multiply(MIR.floor.matrixWorld);
  // the stars stay out of the water: points of light down there read as something to pick up
  const sv=NIGHT.stars.visible;NIGHT.stars.visible=false;MIR.floor.visible=false;const su=renderer.shadowMap.autoUpdate;renderer.shadowMap.autoUpdate=false;renderer.clippingPlanes=[MIR.clip];
  renderer.setRenderTarget(MIR.rt);renderer.clear();renderer.render(scene,v);renderer.setRenderTarget(null);
  renderer.clippingPlanes=[];renderer.shadowMap.autoUpdate=su;MIR.floor.visible=true;NIGHT.stars.visible=sv;MIR.floor.material.uniforms.uT.value=clock;}
function mirRibbon(m,T){T=T||MIR.trail;const pos=m.geometry.attributes.position.array,col=m.geometry.attributes.color.array,n=T.length,w=m.userData.w/2;
  for(let i=0;i<n;i++){const p=T[i],q=T[Math.min(n-1,i+1)],o=T[Math.max(0,i-1)],dx=q.x-o.x,dz=q.z-o.z,l=Math.hypot(dx,dz)||1,nx=-dz/l*w,nz=dx/l*w;
    // young line is bright; it keeps its light as long as it still counts, and goes out only in its last moment (a line dimming
    // for seconds looked used up while it could still close a ring)
    const age=MIR.t-p.t,k=clamp((MIR_LIFE-age)/0.4,0,1)*(age<0.3?1.6:1),j=i*6,c=p.g&&m.userData.gold||m.userData.col;
    pos[j]=p.x+nx;pos[j+1]=p.y;pos[j+2]=p.z+nz;pos[j+3]=p.x-nx;pos[j+4]=p.y;pos[j+5]=p.z-nz;
    for(let e=0;e<2;e++){col[j+e*3]=c.r*k;col[j+e*3+1]=c.g*k;col[j+e*3+2]=c.b*k;}}
  m.geometry.setDrawRange(0,Math.max(0,n-1)*6);m.geometry.attributes.position.needsUpdate=true;m.geometry.attributes.color.needsUpdate=true;}
function mirEnter(){mirBuild();Object.assign(MIR,{on:true,go:false,end:false,t:0,hearts:DRONE.maxHp,inv:0,kills:0,score:0,combo:0,comboT:0,spawnT:1.5,best:(d2().mirBest||0),waves:{},boss:null,bossDown:false,bossSaid:false,redSaid:false,ml:null,mcd:0});if(MIR.ball)MIR.ball.visible=false;
  MIR.trail.length=0;mirClearFoes();MIR.g.visible=true;scene.fog.near=40;scene.fog.far=230;canvas.style.filter='saturate(.6) hue-rotate(8deg)';renderHUD();}
function mirExit(){MIR.on=false;MIR.go=false;mirClearFoes();for(const f of MIR.fx)MIR.g.remove(f.m);MIR.fx.length=0;MIR.trail.length=0;if(MIR.g)MIR.g.visible=false;if(MIR.head)MIR.head.visible=false;
  scene.fog.near=260;scene.fog.far=2600;canvas.style.filter='';$('hurt').style.opacity=0;renderHUD();}
function mirClearFoes(){for(const f of MIR.foes){MIR.g.remove(f.g);scene.remove(f.eye);if(f.aura)scene.remove(f.aura);}MIR.foes.length=0;MIR.boss=null;}
// a shadow rises out of the mirror somewhere ahead of her or to the side, never right on top of her
function mirWhere(spread,r0,r1){let x,z;for(let k=0;k<8;k++){const a=P.yaw+(rnd()-0.5)*spread,r=r0+rnd()*(r1-r0);x=P.x+Math.sin(a)*r;z=P.z+Math.cos(a)*r;if(Math.hypot(x-MIR_X,z)<MIR_R-4)break;}
  const l=Math.hypot(x-MIR_X,z);if(l>MIR_R-4){x=MIR_X+(x-MIR_X)/l*(MIR_R-4);z=z/l*(MIR_R-4);}return[x,z];}
function mirSpawn(){const t=MIR.t,kind=t>80&&rnd()<0.15?'big':t>60&&rnd()<0.22?'red':t>40&&rnd()<0.25?'fast':'normal';mirAdd(kind,...mirWhere(2.6,15,27));
  if(kind==='red'&&!MIR.redSaid){MIR.redSaid=true;toast('赤い影は、光の線を切る！ 先に囲んでしまえ',true);}}
function mirAdd(kind,x,z){const F=MIR_FOE[kind],h=makeHuman(SHADE);h.g.scale.setScalar(F.s);h.g.position.set(x,mirG(x,z)-1.6*F.s,z);MIR.g.add(h.g);
  const f={h,g:h.g,kind,hp:F.hp,sp:F.sp*(0.9+rnd()*0.2),up:0,gone:0,fade:0,stun:0,eye:glow(kind==='big'||kind==='boss'?'#ff6020':'#ff3020',0,0,0,0.9*F.s)};
  // the red ones and the great one carry a glow of their own, so they are told apart at a distance
  if(kind==='red'||kind==='boss'){f.aura=glow(kind==='red'?'#ff2a2a':'#8a3cff',0,0,0,kind==='red'?2.6:9);f.aura.visible=true;}
  MIR.foes.push(f);return f;}
// a swarm: small ones coming up together from one side
function mirSwarm(n){const [cx,cz]=mirWhere(1.6,22,28);for(let k=0;k<n;k++)mirAdd('swarm',cx+(rnd()-0.5)*6,cz+(rnd()-0.5)*6);toast('影の群れが来る！ 大きく囲め',true);sfx.notice&&sfx.notice();}
function mirPop(t){TRICK.name=t;TRICK.sub='';TRICK.shown=1.8;trickHUD();}
// a jump landed (trickLand): its tricks take seconds off the marble's wait; a fall puts one back on
function mirTrickLand(clean,b){if(!clean){MIR.mcd=Math.max(MIR.mcd,0)+1;renderHUD();return;}
  if(b<=0||MIR.mcd<=0)return;MIR.mcd=Math.max(0,MIR.mcd-b);TRICK.sub=MIR.mcd>0?`ビー玉 −${b}秒`:`ビー玉 −${b}秒　投げられる！`;TRICK.shown=Math.max(TRICK.shown,1.4);trickHUD();renderHUD();}
// the ring closed: the points from i on make its edge
function mirRing(poly){let A=0;for(let k=0;k<poly.length;k++){const a=poly[k],b=poly[(k+1)%poly.length];A+=a.x*b.z-b.x*a.z;}A=Math.abs(A)/2;
  if(A<10)return false;
  const inside=(x,z)=>{let c=false;for(let a=0,b=poly.length-1;a<poly.length;b=a++){const p=poly[a],q=poly[b];if((p.z>z)!==(q.z>z)&&x<(q.x-p.x)*(z-p.z)/(q.z-p.z)+p.x)c=!c;}return c;};
  let hit=0,pts=0;
  for(const f of MIR.foes){if(f.gone||f.up<0.5||!inside(f.g.position.x,f.g.position.z))continue;f.hp--;hit++;
    const p=f.g.position.clone();p.y+=1;sparks(p,14,'#cfeeff',6,0.1);
    if(f.hp<=0){f.gone=1;MIR.kills++;pts+=MIR_FOE[f.kind].pts;mirOrb(p,f.kind==='boss'?8:1);if(f.kind==='boss'){MIR.bossDown=true;MIR.t=Math.max(MIR.t,MIR.dur-3);}}
    else if(f.kind==='boss'){f.stun=1.6;const dx=p.x-P.x,dz=p.z-P.z,l=Math.hypot(dx,dz)||1;f.g.position.x+=dx/l*4;f.g.position.z+=dz/l*4;
      sparks(p.clone().setY(p.y+2),30,'#d8c0ff',9,0.16);setTimeout(()=>mirPop(`大きな影がひるんだ！　のこり ${f.hp}回`),300);}}
  // the light rises from the whole ring, and the ground inside it flashes
  const sh=new THREE.Shape(poly.map(p=>new THREE.Vector2(p.x,-p.z))),fill=new THREE.Mesh(new THREE.ShapeGeometry(sh),new THREE.MeshBasicMaterial({color:'#7fc8ff',transparent:true,opacity:0.5,blending:THREE.AdditiveBlending,depthWrite:false,side:THREE.DoubleSide,fog:false}));
  fill.rotation.x=-Math.PI/2;fill.position.y=0.06;MIR.g.add(fill);MIR.fx.push({m:fill,t:0,dur:0.9,kind:'fill'});
  const wp=[],wi=[];poly.forEach((p,k)=>{wp.push(p.x,p.y-0.05,p.z,p.x,p.y+0.95,p.z);if(k){const a=(k-1)*2;wi.push(a,a+1,a+2,a+1,a+3,a+2);}});const a=(poly.length-1)*2;wi.push(a,a+1,0,a+1,1,0);
  const wg=new THREE.BufferGeometry();wg.setAttribute('position',new THREE.Float32BufferAttribute(wp,3));wg.setIndex(wi);
  const wall=new THREE.Mesh(wg,new THREE.MeshBasicMaterial({color:'#a8dcff',transparent:true,opacity:0.7,blending:THREE.AdditiveBlending,depthWrite:false,side:THREE.DoubleSide,fog:false}));MIR.g.add(wall);MIR.fx.push({m:wall,t:0,dur:1.1,kind:'wall'});
  MIR.comboT>0?MIR.combo++:MIR.combo=1;MIR.comboT=4;
  const fast=P.v>10?0.5:0,gold=poly.some(p=>p.g)?1.5:1,mult=(1+0.5*Math.max(0,hit-1)+fast)*gold,got=Math.round(pts*mult*(1+(MIR.combo-1)*0.25));MIR.score+=got;
  if(MIR.bossDown&&!MIR.bossSaid){MIR.bossSaid=true;mirPop('大きな影を、追いはらった！');}
  else if(hit)mirPop(`${hit>1?`${hit}体同時`:''}${gold>1?'金の線で':''}浄化！ ×${mult.toFixed(1)}${MIR.combo>1?`　${MIR.combo}コンボ`:''}`);else mirPop('結界');
  buzz(hit?'heavy':'light',true);if(hit)sfx.boom(0.6);renderHUD();return true;}
// the children the shadows held: little lights going up out of where they were
function mirOrb(p,n){for(let k=0;k<n;k++){const s=new THREE.Sprite(new THREE.SpriteMaterial({map:GLOW_TEX,color:'#fff0c0',transparent:true,depthWrite:false,blending:THREE.AdditiveBlending,fog:false}));
  s.scale.setScalar(0.9);s.position.set(p.x+(rnd()-0.5)*n*0.4,p.y,p.z+(rnd()-0.5)*n*0.4);MIR.g.add(s);MIR.fx.push({m:s,t:-k*0.15,dur:2.2,kind:'orb',vx:(rnd()-0.5)*0.6});}}
// a new point on the line: does it close a ring? (near an old point, or the newest stretch crossing an old one)
function mirClose(){const T=MIR.trail,n=T.length-1,p=T[n],o=T[n-1];if(n<MIR_GAP)return;
  const cross=(a,b,c,d)=>{const r=(b.x-a.x)*(d.z-c.z)-(b.z-a.z)*(d.x-c.x);if(!r)return false;const s=((c.x-a.x)*(d.z-c.z)-(c.z-a.z)*(d.x-c.x))/r,u=((c.x-a.x)*(b.z-a.z)-(c.z-a.z)*(b.x-a.x))/r;return s>=0&&s<=1&&u>=0&&u<=1;};
  // back onto the marble's line: her way round since the throw, then the marble's line back to where she threw it
  const L=MIR.ml,ia=L?T.indexOf(L.anchor):-1;
  if(ia>=0&&n-ia>=6)for(let j=3;j<L.pts.length;j++){const q=L.pts[j];if(Math.hypot(q.x-p.x,q.z-p.z)<MIR_CLOSE||mirCross(o,p,L.pts[j-1],q)){
    if(mirRing(T.slice(ia).concat(L.pts.slice(0,j+1).reverse()))){T.splice(0,n);mirMarbleDone();return;}break;}}
  for(let i=0;i<=n-MIR_GAP;i++){if(Math.hypot(T[i].x-p.x,T[i].z-p.z)<MIR_CLOSE||(i<n-MIR_GAP&&mirCross(o,p,T[i],T[i+1]))){if(mirRing(T.slice(i)))T.splice(0,n);return;}}}
const mirCross=(a,b,c,d)=>{const r=(b.x-a.x)*(d.z-c.z)-(b.z-a.z)*(d.x-c.x);if(!r)return false;const s=((c.x-a.x)*(d.z-c.z)-(c.z-a.z)*(d.x-c.x))/r,u=((c.x-a.x)*(b.z-a.z)-(c.z-a.z)*(b.x-a.x))/r;return s>=0&&s<=1&&u>=0&&u<=1;};
// the marble: thrown from where she is, rolling the way she faces and slowing, a point of line every half metre
function mirThrow(){if(MIR.mcd>0||P.foot||!MIR.go||MIR.end)return;const T=MIR.trail,l=T[T.length-1],y=mirG(P.x,P.z)+0.05;
  if(!l||Math.hypot(P.x-l.x,P.z-l.z)>0.3)T.push({x:P.x,y,z:P.z,t:MIR.t});
  const sp=Math.max(22,P.v+14);MIR.ml={anchor:T[T.length-1],pts:[{x:P.x,y,z:P.z,t:MIR.t}],x:P.x,z:P.z,dx:Math.sin(P.yaw),dz:Math.cos(P.yaw),v:sp,t0:MIR.t,roll:true};
  MIR.mcd=MIR_MCD;MIR.ball.visible=true;sfx.pop&&sfx.pop();buzz('light',true);}
function mirMarbleDone(){MIR.ml=null;MIR.ball.visible=false;}
function mirMarble(dt){const L=MIR.ml;if(!L)return;
  if(MIR.t-L.t0>MIR_LIFE){mirMarbleDone();return;}
  if(L.roll){L.v-=16*dt;L.x+=L.dx*L.v*dt;L.z+=L.dz*L.v*dt;if(L.v<=3||Math.hypot(L.x-MIR_X,L.z)>MIR_R-0.5)L.roll=false;
    const q=L.pts[L.pts.length-1];if(Math.hypot(L.x-q.x,L.z-q.z)>MIR_STEP){L.pts.push({x:L.x,y:mirG(L.x,L.z)+0.05,z:L.z,t:MIR.t});
      // thrown back across her own older line: her line from there to the throw, and the marble's line, make the ring
      const T=MIR.trail,ia=T.indexOf(L.anchor),k=L.pts.length-1,m=L.pts[k],m0=L.pts[k-1];
      if(ia>=0&&k>=3)for(let i=0;i<ia-5;i++)if(Math.hypot(T[i].x-m.x,T[i].z-m.z)<MIR_CLOSE||mirCross(m0,m,T[i],T[i+1])){
        if(mirRing(T.slice(i,ia+1).concat(L.pts.slice(1)))){T.splice(0,T.length-1);mirMarbleDone();return;}break;}}}
  MIR.ball.position.set(L.x,mirG(L.x,L.z)+0.16,L.z);MIR.ball.rotation.x+=L.v*dt*4;}
function mirHUD(tr){tr.hidden=false;tr.innerHTML='';const b=document.createElement('b');b.textContent='鏡の海（試作）';const s=document.createElement('span');s.className='step';
  s.textContent=MIR.go?'走ると光の線が残る。線をつないで影を囲め。ビー玉を投げると、その先まで青い線がのびる':'……';
  const m=document.createElement('span');m.className='meter';const left=Math.max(0,Math.ceil(MIR.dur-MIR.t));
  m.textContent=`のこり ${left/60|0}:${String(left%60).padStart(2,'0')}　${'♥'.repeat(Math.max(0,MIR.hearts))}${'♡'.repeat(Math.max(0,DRONE.maxHp-MIR.hearts))}　浄化 ${MIR.kills}　スコア ${MIR.score}　ビー玉 ${MIR.mcd>0?'○':'●'}${MIR.boss&&!MIR.boss.gone?`　大きな影 ${'■'.repeat(Math.max(0,MIR.boss.hp))}`:''}`;tr.append(b,s,m);}
function mirMap(){const V=150,S=mapc.width/V,W=mapc.width,H=mapc.height,toM=(x,z)=>[(x-P.x)*S+W/2,(z-P.z)*S+H/2];mg.fillStyle='#05080e';mg.fillRect(0,0,W,H);
  const [cx,cz]=toM(MIR_X,0);mg.fillStyle='#0f1c30';mg.beginPath();mg.arc(cx,cz,MIR_R*S,0,TAU);mg.fill();mg.strokeStyle='#4a7ab8';mg.lineWidth=1.5;mg.stroke();
  const line=(T,col)=>{mg.strokeStyle=col;mg.lineWidth=2;mg.beginPath();T.forEach((p,k)=>{const [x,y]=toM(p.x,p.z);k?mg.lineTo(x,y):mg.moveTo(x,y);});mg.stroke();};
  line(MIR.trail,'#9fd4ff');if(MIR.ml)line(MIR.ml.pts,'#8f9cff');
  mg.fillStyle='#4a5260';for(const [x0,z0,a,L,W] of MIR_ROOFS.concat(MIR_BOATS,MIR_RAMPS)){const [x,y]=toM(MIR_X+x0,z0);mg.save();mg.translate(x,y);mg.rotate(-a);mg.fillRect(-W/2*S,-L/2*S,W*S,L*S);mg.restore();}
  for(const f of MIR.foes){if(f.gone)continue;const [x,y]=toM(f.g.position.x,f.g.position.z);mg.fillStyle=f.kind==='boss'?'#b070ff':f.kind==='red'?'#ff8070':'#ff4030';mg.beginPath();mg.arc(x,y,f.kind==='boss'?6:f.kind==='big'?4:f.kind==='swarm'?2:2.6,0,TAU);mg.fill();}
  mg.save();mg.translate(W/2,H/2);mg.rotate(-P.yaw+Math.PI);mg.fillStyle='#fff';mg.beginPath();mg.moveTo(0,-7);mg.lineTo(5,5);mg.lineTo(-5,5);mg.closePath();mg.fill();mg.restore();}
// the camera rides higher and farther back here, so the line and the ring round the shadows are in view
function mirCam(want,look){const F=new THREE.Vector3(Math.sin(P.yaw),0,Math.cos(P.yaw)),p=new THREE.Vector3(P.x,P.y,P.z);
  want.copy(p).addScaledVector(F,-(7+P.v*0.25));want.y+=5.5+P.v*0.15;look.copy(p).addScaledVector(F,4);look.y+=0.6;}
function mirStep(dt){const busy=!!(DLG||modal);
  if(MIR.head)MIR.head.visible=MIR.go&&!P.foot;if(MIR.head)MIR.head.position.set(P.x,0.3,P.z);
  for(const f of MIR.fx.slice()){f.t+=dt;const k=Math.max(0,f.t/f.dur);
    if(f.kind==='orb'){f.m.position.y+=dt*(f.t>0?2.4:0);f.m.position.x+=f.vx*dt;f.m.material.opacity=f.t<0?0:Math.min(1,f.t*3)*(1-k);}
    else if(f.kind==='wall'){f.m.scale.y=1+k*6;f.m.material.opacity=0.7*(1-k);}else f.m.material.opacity=0.5*(1-k);
    if(k>=1){MIR.g.remove(f.m);if(f.kind!=='orb')f.m.geometry.dispose();f.m.material.dispose();MIR.fx.splice(MIR.fx.indexOf(f),1);}}
  if(MIR.go&&!busy&&!MIR.end){MIR.t+=dt;MIR.comboT-=dt;MIR.inv-=dt;MIR.mcd-=dt;mirMarble(dt);
    // the line: a point every half metre while she rides (in the air too), the old end fading away
    const T=MIR.trail,l=T[T.length-1];if(!P.foot&&(!l||Math.hypot(P.x-l.x,P.z-l.z)>MIR_STEP)){if(l&&Math.hypot(P.x-l.x,P.z-l.z)>4)T.length=0;T.push({x:P.x,y:mirG(P.x,P.z)+0.05,z:P.z,t:MIR.t,g:P.grind?1:0});mirClose();}
    // on a rail the whole line stops fading (each point for four seconds at most)
    if(P.grind)for(const p of T)if((p.ext||0)<4){p.t+=dt;p.ext=(p.ext||0)+dt;}
    while(T.length&&MIR.t-T[0].t>MIR_LIFE)T.shift();while(T.length>MIR_MAX)T.shift();
    MIR.spawnT-=dt;const alive=MIR.foes.filter(f=>!f.gone).length,want=Math.min(16,4+Math.floor(MIR.t/14));
    if(MIR.spawnT<=0&&alive<want){mirSpawn();MIR.spawnT=1.1+rnd()*0.6;}
    // the night's turns: two swarms, and the great one before dawn
    const W=MIR.waves;if(MIR.t>55&&!W.s1){W.s1=1;mirSwarm(9);}if(MIR.t>115&&!W.s2){W.s2=1;mirSwarm(12);}
    if(MIR.t>140&&!W.boss){W.boss=1;MIR.boss=mirAdd('boss',...mirWhere(1.2,26,30));toast('大きな影が来る！ 3回囲んで、追いはらえ',true);buzz('heavy',true);}
    if(MIR.t>=MIR.dur)mirFinish(true);}
  // a line drawn in the middle of a combo burns gold
  const gold=MIR.combo>=3&&MIR.comboT>0;MIR.core.userData.col.set(gold?'#ffe6a0':'#bfe6ff');MIR.halo.userData.col.set(gold?'#8a5a18':'#2a5a9a');
  mirRibbon(MIR.core);mirRibbon(MIR.halo);const ML=MIR.ml?MIR.ml.pts:[];mirRibbon(MIR.mcore,ML);mirRibbon(MIR.mhalo,ML);
  for(const f of MIR.foes.slice()){const p=f.g.position,S=MIR_FOE[f.kind].s;
    if(f.gone){f.fade+=dt*2;const k=Math.min(1,f.fade);f.g.scale.set(S*(1-k*0.6),S*(1-k*0.9),S*(1-k*0.6));f.eye.visible=false;if(f.aura)f.aura.visible=false;if(rnd()<dt*25)sparks(new THREE.Vector3(p.x,p.y+1,p.z),1,'#cfeeff',2,0.05);
      if(k>=1){MIR.g.remove(f.g);scene.remove(f.eye);if(f.aura)scene.remove(f.aura);MIR.foes.splice(MIR.foes.indexOf(f),1);}continue;}
    const gy=mirG(p.x,p.z);f.stun-=dt;
    if(f.up<1){f.up=Math.min(1,f.up+dt*(f.kind==='boss'?0.35:0.8));p.y=lerp(gy-1.6*S,gy,f.up);poseHuman(f.h,'stand',dt,{});}
    else if(f.stun>0){p.y=gy;poseHuman(f.h,'stand',dt,{});}
    else if(!busy&&!MIR.end){let dx=P.x-p.x,dz=P.z-p.z;const d=Math.hypot(dx,dz)||1;dx/=d;dz/=d;
      // a red one walking over the line breaks it there: everything older than that point is gone
      if(f.kind==='red'){const T=MIR.trail;for(let j=T.length-1;j>=0;j--)if(Math.hypot(T[j].x-p.x,T[j].z-p.z)<0.9){T.splice(0,j+1);sparks(new THREE.Vector3(p.x,gy+0.2,p.z),10,'#ff6a5a',4,0.08);break;}}
      // they keep a little apart, so a crowd of them is a crowd and not one heap
      for(const o of MIR.foes)if(o!==f&&!o.gone){const ex=p.x-o.g.position.x,ez=p.z-o.g.position.z,e=Math.hypot(ex,ez);if(e<1.4&&e>0){dx+=ex/e*0.6;dz+=ez/e*0.6;}}
      const m=Math.hypot(dx,dz)||1;p.x+=dx/m*f.sp*dt;p.z+=dz/m*f.sp*dt;p.y=mirG(p.x,p.z);f.g.rotation.y=Math.atan2(P.x-p.x,P.z-p.z);poseHuman(f.h,'walk',dt,{rate:3.8});
      if(d<0.75+0.35*S&&MIR.inv<=0){MIR.inv=1.3;MIR.hearts--;buzz('heavy',true);P.v*=0.4;
        // a small one is spent by the touch; a big one stays, and throws her back
        if(f.kind==='big'||f.kind==='boss'){const kx=P.x-p.x,kz=P.z-p.z,kl=Math.hypot(kx,kz)||1;P.x+=kx/kl*2.5;P.z+=kz/kl*2.5;P.v=0;f.stun=0.8;}else f.gone=1;renderHUD();if(MIR.hearts<=0){mirFinish(false);break;}toast('冷たい手が、ふれた！');}}
    f.eye.visible=true;f.eye.position.set(p.x,p.y+1.62*S,p.z);f.eye.material.opacity=0.7+0.3*Math.sin(clock*7+p.x);
    if(f.aura){f.aura.position.set(p.x,p.y+1.1*S,p.z);f.aura.material.opacity=(f.kind==='boss'?0.45:0.35)+0.15*Math.sin(clock*4+p.z);}}
  $('hurt').style.opacity=MIR.go?Math.max(MIR.inv>0.7?0.5:0,MIR.hearts===1?0.3+0.1*Math.sin(clock*5):0):0;
  MIR.hudT-=dt;if(MIR.hudT<=0){MIR.hudT=0.25;renderHUD();}}
function mirFinish(won){if(MIR.end)return;MIR.end=true;for(const f of MIR.foes)f.gone=1;MIR.trail.length=0;mirMarbleDone();
  const D=d2(),best=MIR.score>(D.mirBest||0),got=Math.floor(MIR.kills/2)+(won?10:0)+(MIR.bossDown?15:0);if(best)D.mirBest=MIR.score;SAVE.shards=shards()+got;save();
  runEvent({id:'mir_end',once:false,script:[['wait',1.2],
    ['say','',won?(MIR.bossDown?'大きな影がくずれて、東の空が白んできた。鏡の海の影が、朝の光にとけていく。':'夜が明けてきた。鏡の海の影が、朝の光にとけていく。'):'影の手に、のみこまれた……。',`浄化した影 ${MIR.kills}体　スコア ${MIR.score}${best?'（自己ベスト！）':`（ベスト ${D.mirBest||0}）`}`,`影のかけら +${got}`],
    ['fade','out'],['call',mirExit],['warp',HQ_X+HQ_IN[0],HQ_IN[1],HQ_IN[2]],['call',()=>{P.foot=true;P.carry='back';padLabels();}],['fade','in'],
    ['say','tome','おかえり。……試しの夜は、どうだったかい。']]});}
// out from the command table
function mirScript(){const first=!SAVE.seen.mir_first;SAVE.seen.mir_first=1;return[
  ['fade','out'],['call',()=>{applyD2();mirEnter();}],['time',23.3,0],['warp',MIR_X,30,Math.PI],['call',rideNow],
  ['cam',[MIR_X+10,5,38],[MIR_X,0.8,28],1.2,'cut'],['fade','in'],
  ['say','tome','（無線の声）……ここが、裏海街の海さ。水がひいて、まるで鏡みたいだろう。',
    ...(first?['スケボーで走ると、ランタンの光が足もとに線になって残る。','その線で、影をぐるっと囲んでごらん。線がつながったら、中の影はまとめて消えるよ。','たくさん囲むほど、いっぺんに追いはらえる。','ミオのビー玉も持っておいき。投げると、転がった先まで青い光の線がのびる。その線につなげても、囲めるよ。',
     '技を決めて着地すると、ビー玉が早くたまる。屋根のてっぺんや鳥居をすべると、線が金色になって消えにくくなるし、金の線で囲めば点も上がるさ。','……三分、もちこたえな。']:['今夜も、光の線で囲んでやりな。ビー玉も、技も使うんだよ。'])],
  ['cam','off'],['call',()=>{MIR.go=true;toast('走って、線で囲め！',true);}]];}
// the sky on the way to dawn: from the second minute the east pales, the moon goes thin, the mirror catches the light
const MIR_DAWN={top:new THREE.Color('#5a6f98'),bg:new THREE.Color('#b87a6c'),hemi:new THREE.Color('#ffd8c0')};
function mirDawn(){const k=MIR.end&&MIR.bossDown?1:smooth(clamp((MIR.t/MIR.dur-0.35)/0.65,0,1));
  dome.material.color.lerp(MIR_DAWN.top,k*0.6);scene.background.lerp(MIR_DAWN.bg,k*0.45);scene.fog.color.lerp(MIR_DAWN.bg,k*0.3);hemi.color.lerp(MIR_DAWN.hemi,k*0.4);hemi.intensity+=k*0.15;
  if(MIR.moon)MIR.moon.material.opacity=1-k*0.8;if(MIR.floor)MIR.floor.material.uniforms.uDawn.value=k;}
function updateMirror(dt){if(MIR.on){if(footQ&&!DLG&&!modal)mirThrow();footQ=false;if(P.foot&&!P.tr&&!ST.run)rideNow();mirStep(dt);mirDawn();}
  else if(AREA==='mir'&&!ST.run){P.x=HQ_X+HQ_IN[0];P.z=HQ_IN[1];P.yaw=HQ_IN[2];P.y=0;camInit=false;}}   // a save made out there wakes up back at the base
