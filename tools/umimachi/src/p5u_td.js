/* ---------- the nightly defense of the second story, seen from above: the town as a board. The shadows climb up from the beach
   along the streets toward the shrine (grandma's house); on glowing spots beside the streets Nagi sets the old guard's things —
   a stone lantern that flashes the lighthouse's light round it, an Oceangate drone that shoots from afar, a ring of salt that
   slows them, a lookout who hits the strongest hard. Each grows with its room in the base (and in the fight, with the light the
   shadows leave, up to Lv3). Three waves a night; the way they come changes night by night. A tap on 灯台の光 and then on the
   town brings the lighthouse's beam down there. Ten lights in the town; a shadow at the shrine puts one out.
   The camera: high over the bay, looking up the slope; a drag moves it, a pinch (or the wheel) brings it nearer. ---------- */
const TD_GOAL=[-60,-121];
const TD_PATHS={main:[[0,252],[0,-120],TD_GOAL],west:[[-120,250],[-120,-120],TD_GOAL],east:[[115,250],[115,-20],[0,-20],[0,-120],TD_GOAL],mid:[[0,252],[0,90],[-120,90],[-120,-120],TD_GOAL]};
const TD_PATH_NAME={main:'海へつづく坂',west:'西の坂道',east:'東の坂道から商店街',mid:'なか通りから西の坂道'};
const TD_SPOTS=[[4.5,195],[-4.5,140],[4.5,60],[-4.5,10],[4.5,-60],[-4.5,-100],[-117,195],[-123,130],[-117,40],[-123,-50],[118,195],[112,120],[118,40],[60,-16.5],[-30,-116.5],[-90,-123.5],[-60,93],[-60,236.5],[60,236.5]];
// what can be set on a spot: its cost in light, the room of the base it grows with, and what it does at each level
const TD_KIND={
  toro:{name:'灯籠',cost:4,fac:'lamp',info:'まわりに光を放って、近くの影をまとめて弱らせる'},
  drone:{name:'迎撃ドローン台',cost:5,fac:'radio',info:'遠くの影を、すばやく撃つ'},
  salt:{name:'塩の結界',cost:3,fac:'dojo',info:'上を通る影の足をおそくする'},
  guard:{name:'自警団の見張り',cost:6,fac:'arm',info:'近くでいちばん強い影を、強く撃つ'}};
function tdStat(t){const fb=hqLv(TD_KIND[t.kind].fac)-1,lv=t.lv;
  if(t.kind==='toro')return{cd:Math.max(1.2,2.4-0.2*fb),r:12+lv*2+fb,dmg:lv};
  if(t.kind==='drone')return{cd:Math.max(0.3,0.8-0.08*fb-0.1*(lv-1)),r:24+lv*2,dmg:1};
  if(t.kind==='salt')return{r:8+lv*2+fb,slow:0.35+0.1*lv};
  return{cd:Math.max(0.6,1.3-0.1*fb),r:18,dmg:2+lv-1+fb*0.5};}
const TD_FOE={normal:{hp:3,sp:7,s:2.4,pts:1,leak:1},fast:{hp:2,sp:12,s:2.1,pts:1,leak:1},big:{hp:12,sp:4.5,s:4.2,pts:4,leak:3}};
const TD={on:false,cam:{x:0,z:90,h:120},paths:[],lines:[],spots:[],towers:[],foes:[],fx:[],wave:0,waves:[],pts:0,lives:10,state:'prep',beamCD:0,beamArm:false,res:null,kills:0,
  spawnQ:[],spawnT:0,sel:null,ptr:new Map(),drag:null,night:1,len:{}};
// the path as a line on the ground, and the distance along it
function tdPathLen(id){const p=TD_PATHS[id];let L=0;for(let i=1;i<p.length;i++)L+=Math.hypot(p[i][0]-p[i-1][0],p[i][1]-p[i-1][1]);return L;}
function tdAt(id,d){const p=TD_PATHS[id];for(let i=1;i<p.length;i++){const a=p[i-1],b=p[i],l=Math.hypot(b[0]-a[0],b[1]-a[1]);if(d<=l||i===p.length-1){const k=clamp(d/l,0,1);return[lerp(a[0],b[0],k),lerp(a[1],b[1],k),Math.atan2(b[0]-a[0],b[1]-a[1])];}d-=l;}return p[p.length-1];}
// tonight: which ways they come, and the three waves
function tdPlan(n){const ways=n===1?['main']:n===2?['main','west']:n===3?['east']:n===4?['mid','main']:[['main','west','east'],['mid','east'],['west','east','main'],['mid','main','west']][n%4];
  const hp=1+0.15*(n-1),waves=[0,1,2].map(w=>{const list=[];const N=6+2*n+3*w,F=n>=2?2+w+(n>>1):0,B=w===2?1+Math.floor(n/3):w===1&&n>=4?1:0;
    for(let k=0;k<N;k++)list.push({kind:'normal'});for(let k=0;k<F;k++)list.splice(Math.floor(Math.random()*list.length),0,{kind:'fast'});for(let k=0;k<B;k++)list.push({kind:'big'});
    list.forEach((o,k)=>{o.path=ways[k%ways.length];o.hp=hp;});return list;});return{ways,waves};}
function tdBuildBoard(){if(TD.g)return;TD.g=new THREE.Group();world.add(TD.g);
  for(const [x,z] of TD_SPOTS){const y=G(x,z)+paveY(x,z)+0.05,ring=new THREE.Mesh(new THREE.RingGeometry(1.6,2.1,24),new THREE.MeshBasicMaterial({color:'#7fd0ff',transparent:true,opacity:0.8,depthWrite:false}));
    ring.rotation.x=-Math.PI/2;ring.position.set(x,y,z);TD.g.add(ring);const plus=glow('#9fe0ff',x,y+1.2,z,3);plus.visible=true;scene.remove(plus);TD.g.add(plus);TD.spots.push({x,z,y,ring,plus,tower:null});}}
function tdShowPaths(){for(const l of TD.lines)TD.g.remove(l);TD.lines=[];
  for(const id of TD.paths){const pts=[],L=tdPathLen(id);for(let d=0;d<=L;d+=3){const [x,z]=tdAt(id,d);pts.push(new THREE.Vector3(x,G(x,z)+paveY(x,z)+0.6,z));}
    // a ribbon along the street, glowing red, so the way shows from high up
    const v=[],idx=[];for(let i=0;i<pts.length;i++){const a=pts[Math.max(0,i-1)],b=pts[Math.min(pts.length-1,i+1)],dx=b.x-a.x,dz=b.z-a.z,l=Math.hypot(dx,dz)||1,nx=-dz/l*1.6,nz=dx/l*1.6;
      v.push(pts[i].x+nx,pts[i].y,pts[i].z+nz,pts[i].x-nx,pts[i].y,pts[i].z-nz);if(i)idx.push(2*i-2,2*i-1,2*i,2*i-1,2*i+1,2*i);}
    const g=new THREE.BufferGeometry();g.setAttribute('position',new THREE.Float32BufferAttribute(v,3));g.setIndex(idx);
    const l=new THREE.Mesh(g,new THREE.MeshBasicMaterial({color:'#ff4a36',transparent:true,opacity:0.55,depthWrite:false,side:THREE.DoubleSide,blending:THREE.AdditiveBlending,fog:false}));TD.g.add(l);TD.lines.push(l);}}
/* ----- the night ----- */
function tdP(n){return new Promise(res=>{tdBuildBoard();const plan=tdPlan(n);
  Object.assign(TD,{on:true,res,night:n,paths:plan.ways,waves:plan.waves,wave:0,pts:12,lives:10,state:'prep',beamCD:0,beamArm:false,kills:0,spawnQ:[],sel:null});
  // the camera starts over the first of tonight's ways, near the beach where they come up (a drag shows the others);
  // on a wide screen, high enough to take them all in
  { let x0=1e9,x1=-1e9;for(const id of plan.ways)for(const [x] of TD_PATHS[id]){x0=Math.min(x0,x);x1=Math.max(x1,x);}
    TD.cam=camera.aspect<0.8?{x:TD_PATHS[plan.ways[0]][0][0],z:165,h:105}:{x:(x0+x1)/2,z:110,h:clamp((x1-x0+60)/1.4,90,170)};}
  for(const s of TD.spots){if(s.tower)tdRemove(s);}tdShowPaths();TD.g.visible=true;document.body.classList.add('td');$('td').hidden=false;ST.actor=null;talkNpc=null;
  tdUI();tdMsg(`今夜は「${plan.ways.map(w=>TD_PATH_NAME[w]).join('」と「')}」から来る。光る置き場所をタップして、守りを置こう`);});}
function tdEnd(won){TD.on=false;document.body.classList.remove('td');$('td').hidden=true;$('tdMenu').hidden=true;TD.g.visible=false;
  for(const f of TD.foes)tdFoeGone(f);TD.foes=[];for(const s of TD.spots)if(s.tower)tdRemove(s);for(const o of TD.fx)scene.remove(o.o);TD.fx=[];const r=TD.res;TD.res=null;r({won,kills:TD.kills,lives:TD.lives});}
function tdStartWave(){if(TD.state!=='prep')return;TD.state='wave';TD.spawnQ=TD.waves[TD.wave].slice();TD.spawnT=0.5;$('tdMenu').hidden=true;TD.sel=null;tdMsg(null);tdUI();}
function tdSpawn(o){const K=TD_FOE[o.kind],h=makeHuman(SHADE);h.g.scale.setScalar(K.s);world.add(h.g);
  const f={kind:o.kind,path:o.path,d:0,L:tdPathLen(o.path),hp:K.hp*o.hp,max:K.hp*o.hp,sp:K.sp*(0.9+Math.random()*0.2),off:(Math.random()-0.5)*2.4,h,
    eye:glow('#ff3020',0,0,0,K.s*1.1),halo:glow('#ff2a1a',0,0,0,K.s*2.2),bar:new THREE.Sprite(new THREE.SpriteMaterial({color:'#ff6a50',depthTest:false})),hit:0};
  f.bar.scale.set(3,0.35,1);scene.add(f.bar);f.eye.visible=f.halo.visible=true;f.halo.material.opacity=0.35;TD.foes.push(f);}
function tdFoeGone(f){world.remove(f.h.g);scene.remove(f.eye);scene.remove(f.halo);scene.remove(f.bar);}
function tdHit(f,dmg){if(f.hp<=0)return;f.hp-=dmg;f.hit=0.12;if(f.hp<=0){TD.kills++;TD.pts+=TD_FOE[f.kind].pts;const p=f.h.g.position.clone();p.y+=2;sparks(p,14,'#ffe2a0',6,0.12);tdUI();}}
/* ----- the things on the spots ----- */
function tdPlace(s,kind){const K=TD_KIND[kind];if(TD.pts<K.cost)return;TD.pts-=K.cost;const g=new THREE.Group();g.position.set(s.x,s.y,s.z);TD.g.add(g);
  if(kind==='toro'){const st=tm('#9a968c');for(const [w,h,y] of [[1.6,0.4,0.2],[0.6,1.4,1.1],[1.4,0.3,1.95],[1.0,0.9,2.55],[1.7,0.3,3.15]]){const m=new THREE.Mesh(new THREE.BoxGeometry(w,h,w),st);m.position.y=y;outline(m,0.03);g.add(m);}
    const l=glow('#ffd88a',0,2.55,0,4.5);l.visible=true;scene.remove(l);g.add(l);}
  else if(kind==='drone'){const p=new THREE.Mesh(new THREE.CylinderGeometry(0.25,0.4,2.6,8),tm('#3a3d42'));p.position.y=1.3;g.add(p);const d=makeDrone();scene.remove(d.g);d.g.scale.setScalar(2.4);d.g.position.y=3.6;g.add(d.g);g.userData.d=d;}
  else if(kind==='salt'){const r=new THREE.Mesh(new THREE.RingGeometry(0.3,1,24),new THREE.MeshBasicMaterial({color:'#f4f4ff',transparent:true,opacity:0.8,depthWrite:false}));r.rotation.x=-Math.PI/2;r.position.y=0.08;g.add(r);g.userData.ring=r;
    const pile=new THREE.Mesh(new THREE.ConeGeometry(0.7,0.9,10),tm('#f2f2f6'));pile.position.y=0.45;g.add(pile);}
  else{const c=new THREE.Mesh(new THREE.BoxGeometry(1.6,1.0,1.6),tm('#8a6a44'));c.position.y=0.5;outline(c,0.03);g.add(c);const h=makeHuman(NPCS.baker.h.o);h.g.scale.setScalar(1.6);h.g.position.y=1.0;g.add(h.g);g.userData.h=h;}
  s.tower={kind,lv:1,g,t:0.5,spent:K.cost};s.plus.visible=false;buzz('light');tdUI();}
function tdRemove(s){TD.g.remove(s.tower.g);s.tower=null;s.plus.visible=true;}
function tdUpgrade(s){const T=s.tower,c=TD_KIND[T.kind].cost*T.lv;if(T.lv>=3||TD.pts<c)return;TD.pts-=c;T.spent+=c;T.lv++;T.g.scale.setScalar(1+0.15*(T.lv-1));buzz('light');tdUI();}
function tdMenu(s){const m=$('tdMenu');TD.sel=s;m.innerHTML='';m.hidden=false;const add=(label,dis,fn,sub)=>{const b=document.createElement('button');b.className='btn tdo';b.disabled=dis;b.innerHTML=label+(sub?`<small>${sub}</small>`:'');b.onclick=e=>{e.stopPropagation();fn();};m.appendChild(b);};
  if(!s.tower){for(const k in TD_KIND){const K=TD_KIND[k];add(`${K.name}　<b>${K.cost}</b>`,TD.pts<K.cost,()=>{tdPlace(s,k);tdMenu(s);},K.info+`（${FAC[K.fac].name} Lv${hqLv(K.fac)}）`);}}
  else{const T=s.tower,K=TD_KIND[T.kind],c=K.cost*T.lv;const h=document.createElement('b');h.textContent=`${K.name} Lv${T.lv}`;m.appendChild(h);
    if(T.lv<3)add(`強化する（Lv${T.lv+1}）　<b>${c}</b>`,TD.pts<c,()=>{tdUpgrade(s);tdMenu(s);});
    add(`片づける（灯り +${Math.floor(T.spent/2)}）`,false,()=>{TD.pts+=Math.floor(T.spent/2);tdRemove(s);tdMenu(s);tdUI();});}
  add('とじる',false,()=>{m.hidden=true;TD.sel=null;});}
/* ----- the lighthouse's beam ----- */
function tdBeam(p){TD.beamArm=false;TD.beamCD=Math.max(12,25-2*(hqLv('lamp')-1));const col=new THREE.Mesh(new THREE.CylinderGeometry(9,9,160,24,1,true),new THREE.MeshBasicMaterial({color:'#fff1c8',transparent:true,opacity:0.0,depthWrite:false,side:THREE.DoubleSide,blending:THREE.AdditiveBlending}));
  col.position.set(p.x,p.y+80,p.z);scene.add(col);TD.fx.push({o:col,t:0,life:1.4,upd:(f,k)=>{col.material.opacity=k<0.3?k/0.3*0.7:0.7*(1-(k-0.3)/0.7);col.scale.set(1-k*0.4,1,1-k*0.4);}});
  setTimeout(()=>{if(!TD.on)return;for(const f of TD.foes)if(Math.hypot(f.h.g.position.x-p.x,f.h.g.position.z-p.z)<16)tdHit(f,8);sparks(p.clone().setY(p.y+2),30,'#fff1c8',10,0.3);buzz('heavy',true);},400);tdUI();}
/* ----- the screen: the line at the top, the buttons, the message ----- */
function tdUI(){if(!TD.on)return;$('tdWave').textContent=TD.state==='wave'?`${TD.night}日目の夜　第${TD.wave+1}波 / 3`:`${TD.night}日目の夜　準備（次は第${TD.wave+1}波）`;
  $('tdLives').textContent='町の灯り '+'●'.repeat(Math.max(0,TD.lives))+'○'.repeat(Math.max(0,10-TD.lives));$('tdPts').textContent=`灯り ${TD.pts}`;
  const go=$('tdGo');go.hidden=TD.state!=='prep';go.textContent=TD.wave===0?'影を迎えうつ':'次の波へ';
  const bm=$('tdBeam');bm.disabled=TD.beamCD>0;bm.classList.toggle('on',TD.beamArm);bm.textContent=TD.beamCD>0?`灯台の光（${Math.ceil(TD.beamCD)}）`:TD.beamArm?'光を落とす場所をタップ':'灯台の光';}
function tdMsg(t){const m=$('tdMsg');m.hidden=!t;if(t)m.textContent=t;}
/* ----- the camera over the town, and the touches ----- */
function tdCam(want,look){const c=TD.cam;look.set(c.x,0,c.z);look.y=G(c.x,c.z);want.set(c.x,look.y+c.h,c.z+c.h*0.32);}   // nearly straight down, so the narrow streets show between the roofs
function tdPick(cx,cy){const r=new THREE.Raycaster();r.setFromCamera(new THREE.Vector2(cx/innerWidth*2-1,-(cy/innerHeight)*2+1),camera);const o=r.ray.origin,d=r.ray.direction;
  for(let t=0;t<1500;t+=1.5){const p=o.clone().addScaledVector(d,t);if(p.y<=G(p.x,p.z))return p;}return null;}
function tdTap(cx,cy){const p=tdPick(cx,cy);if(!p)return;
  if(TD.beamArm){tdBeam(p);return;}
  let best=null,bd=10;for(const s of TD.spots){const d=Math.hypot(s.x-p.x,s.z-p.z);if(d<bd){bd=d;best=s;}}
  if(best)tdMenu(best);else{$('tdMenu').hidden=true;TD.sel=null;}}
{ const C=canvas,P2=TD.ptr;
  C.addEventListener('pointerdown',e=>{if(!TD.on)return;P2.set(e.pointerId,{x:e.clientX,y:e.clientY,x0:e.clientX,y0:e.clientY,t:performance.now()});try{C.setPointerCapture(e.pointerId);}catch(_){}});
  C.addEventListener('pointermove',e=>{if(!TD.on||!P2.has(e.pointerId))return;const q=P2.get(e.pointerId),c=TD.cam;
    if(P2.size===1){const k=c.h/innerHeight*1.5;c.x=clamp(c.x-(e.clientX-q.x)*k,-160,160);c.z=clamp(c.z-(e.clientY-q.y)*k,-150,250);}
    else{const o=[...P2.entries()].find(([id])=>id!==e.pointerId)[1],d0=Math.hypot(q.x-o.x,q.y-o.y),d1=Math.hypot(e.clientX-o.x,e.clientY-o.y);if(d0>10)c.h=clamp(c.h*d0/d1,50,220);}
    q.x=e.clientX;q.y=e.clientY;});
  const up=e=>{if(!TD.on||!P2.has(e.pointerId))return;const q=P2.get(e.pointerId);P2.delete(e.pointerId);
    if(Math.hypot(e.clientX-q.x0,e.clientY-q.y0)<10&&performance.now()-q.t<450&&P2.size===0)tdTap(e.clientX,e.clientY);};
  C.addEventListener('pointerup',up);C.addEventListener('pointercancel',e=>P2.delete(e.pointerId));
  C.addEventListener('wheel',e=>{if(!TD.on)return;TD.cam.h=clamp(TD.cam.h*(1+e.deltaY*0.001),50,220);},{passive:true});
  $('tdGo').addEventListener('click',()=>tdStartWave());$('tdBeam').addEventListener('click',()=>{if(TD.beamCD<=0){TD.beamArm=!TD.beamArm;tdUI();}});}
/* ----- every frame ----- */
function updateTD(dt){if(!TD.on)return;
  hemi.intensity=Math.max(hemi.intensity,1.05);sun.intensity=Math.max(sun.intensity,0.55);   // moonlight enough to read the town by
  const zs=Math.max(1,TD.cam.h/70);for(const s of TD.spots){s.ring.scale.setScalar(Math.max(1,TD.cam.h/90));s.plus.scale.setScalar(3*zs);}
  if(DLG||modal)return;
  for(const s of TD.spots){if(!s.tower){s.plus.material.opacity=0.55+0.35*Math.sin(clock*3+s.x);s.ring.material.opacity=TD.sel===s?1:0.6;}else s.ring.material.opacity=TD.sel===s?1:0.25;}
  if(TD.beamCD>0){TD.beamCD-=dt;if(TD.beamCD<=0)tdUI();}
  for(const o of TD.fx.slice()){o.t+=dt;const k=o.t/o.life;o.upd(o,Math.min(1,k));if(k>=1){scene.remove(o.o);TD.fx.splice(TD.fx.indexOf(o),1);}}
  if(TD.state==='wave'){TD.spawnT-=dt;if(TD.spawnQ.length&&TD.spawnT<=0){tdSpawn(TD.spawnQ.shift());TD.spawnT=0.8+Math.random()*0.5;}}
  // the shadows walk up their streets; slowed on salt
  for(const f of TD.foes.slice()){if(f.hp<=0){f.fade=(f.fade||0)+dt*2;const k=Math.min(1,f.fade);f.h.g.scale.set(TD_FOE[f.kind].s*(1-k*0.6),TD_FOE[f.kind].s*(1-k*0.9),TD_FOE[f.kind].s*(1-k*0.6));f.eye.visible=f.halo.visible=f.bar.visible=false;
      if(k>=1){tdFoeGone(f);TD.foes.splice(TD.foes.indexOf(f),1);}continue;}
    let slow=1;for(const s of TD.spots){const T=s.tower;if(T&&T.kind==='salt'){const S=tdStat(T);if(Math.hypot(f.h.g.position.x-s.x,f.h.g.position.z-s.z)<S.r)slow=Math.min(slow,1-S.slow);}}
    f.d+=f.sp*slow*dt;const [x0,z0,a]=tdAt(f.path,f.d),x=x0+Math.cos(a)*f.off,z=z0-Math.sin(a)*f.off,g=f.h.g;g.position.set(x,G(x,z)+paveY(x,z),z);g.rotation.y=a;poseHuman(f.h,'walk',dt*slow,{rate:3+f.sp*0.4});
    const s=TD_FOE[f.kind].s;f.eye.position.set(x,g.position.y+1.62*s,z);f.halo.position.set(x,g.position.y+0.3,z);f.halo.scale.setScalar(s*2.6*zs);f.halo.material.opacity=0.8;f.bar.position.set(x,g.position.y+2.1*s+0.6*zs,z);f.bar.scale.set(3*zs*f.hp/f.max,0.35*zs,1);
    f.hit-=dt;f.eye.material.opacity=f.hit>0?1:0.85;
    if(f.d>=f.L){TD.lives-=TD_FOE[f.kind].leak;f.hp=0;f.fade=1;tdFoeGone(f);TD.foes.splice(TD.foes.indexOf(f),1);buzz('heavy',true);toast('影が神社までたどり着いた！ 町の灯りが消えていく',true);tdUI();
      if(TD.lives<=0){TD.state='lost';tdLost();return;}}}
  // the things on the spots do their work
  for(const s of TD.spots){const T=s.tower;if(!T||T.kind==='salt'){if(T&&T.kind==='salt'){const S=tdStat(T);T.g.userData.ring.scale.setScalar(S.r*(0.96+0.04*Math.sin(clock*3)));}continue;}
    const S=tdStat(T);T.t-=dt;if(T.kind==='drone'){const d=T.g.userData.d;d.g.position.y=3.6+Math.sin(clock*2+s.x)*0.2;for(const r of d.rotors)r.rotation.y+=dt*40;}
    if(T.t>0||TD.state!=='wave')continue;
    const near=TD.foes.filter(f=>f.hp>0&&Math.hypot(f.h.g.position.x-s.x,f.h.g.position.z-s.z)<S.r);if(!near.length)continue;T.t=S.cd;
    if(T.kind==='toro'){for(const f of near)tdHit(f,S.dmg);const ring=new THREE.Mesh(new THREE.RingGeometry(0.8,1.2,32),new THREE.MeshBasicMaterial({color:'#ffd88a',transparent:true,depthWrite:false,side:THREE.DoubleSide}));
      ring.rotation.x=-Math.PI/2;ring.position.set(s.x,s.y+0.3,s.z);scene.add(ring);TD.fx.push({o:ring,t:0,life:0.6,upd:(o,k)=>{ring.scale.setScalar(1+k*S.r);ring.material.opacity=1-k;}});}
    else{const tgt=T.kind==='guard'?near.reduce((a,b)=>b.hp>a.hp?b:a):near.reduce((a,b)=>(b.d>a.d?b:a));const from=new THREE.Vector3(s.x,s.y+(T.kind==='drone'?3.6:2.6),s.z),to=tgt.h.g.position.clone();to.y+=2;
      tracer(from,to);tdHit(tgt,S.dmg);}}
  // the wave is over when nobody is left to come
  if(TD.state==='wave'&&!TD.spawnQ.length&&!TD.foes.some(f=>f.hp>0)){TD.wave++;TD.pts+=3;
    if(TD.wave>=3){TD.state='won';tdMsg('三つの波を、守りきった！');setTimeout(()=>tdEnd(true),1800);}
    else{TD.state='prep';tdMsg(`第${TD.wave}波を追い返した（灯り +3）。守りを足したら「次の波へ」`);}tdUI();}}
async function tdLost(){tdMsg('町の灯りが、ぜんぶ消えてしまった……');const i=await askP('',`${TD.night}日目の夜。……どうする？`,['もう一度、はじめから守る','今夜はあきらめる']);
  if(!TD.on)return;if(i===0){const n=TD.night,r=TD.res;for(const f of TD.foes)tdFoeGone(f);TD.foes=[];TD.on=false;await tdP(n).then(r);return;}tdEnd(false);}
