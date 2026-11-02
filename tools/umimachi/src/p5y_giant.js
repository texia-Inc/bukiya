/* ---------- the last fight of the second story: the master of the shadows, risen to the waist out of the bay, and a ring of
   rails of light hung in the air round it. From the end of the pier a rail climbs up to the ring; the ring is four arcs with a
   gap between each (she flies across, or jumps). Riding them leaves a gold line, and once round the master the line closes
   into a ring of light that wears it down; worn enough, it reels (three times, and the lighthouse's beam finishes it).
   Its arm sweeps round the ring at the height of the rails, a red shadow on the sea first: jump over it. A fall into the sea
   or the hearts gone, and she is back at the end of the pier; the master keeps its wounds. ---------- */
const GNT_R=24,GNT_LIFE=22;
const GNT={on:false,res:null,g:null,rails:[],trail:[],t:0,st:0,gauge:0,need:4,hearts:5,inv:0,swept:0,ang:null,armT:5,arm:null,warn:null,sw:null,end:false,hudT:0,said:false};
const gntC=()=>({x:BOSS_AT.x,z:BOSS_AT.z});
// where the ring is lowest and highest: each arc climbs from 4.6 m to 5.4 m with a hump in the middle, so going round the way
// it was laid (anticlockwise seen from above) she drops a little onto each next arc
const gntArcY=u=>4.6+0.8*u+1.6*Math.sin(Math.PI*u);
function gntBuild(){if(GNT.g)return;const g=new THREE.Group();scene.add(g);GNT.g=g;g.visible=false;const C=gntC();
  const mat=new THREE.MeshBasicMaterial({color:'#ffe6a0',fog:false}),halo=new THREE.MeshBasicMaterial({color:'#ffcf70',transparent:true,opacity:0.22,blending:THREE.AdditiveBlending,depthWrite:false,fog:false});
  const draw=r=>{const a=new THREE.Vector3(r.x0,r.y0,r.z0),b=new THREE.Vector3(r.x1,r.y1,r.z1),L=a.distanceTo(b);
    for(const [m,w] of [[mat,0.06],[halo,0.28]]){const c=new THREE.Mesh(new THREE.CylinderGeometry(w,w,L,8,1,true),m);c.position.copy(a).add(b).multiplyScalar(0.5);c.lookAt(b);c.rotateX(Math.PI/2);g.add(c);}};
  // the ring: four arcs of four straight lengths, from the side facing the pier round anticlockwise
  const p0=Math.atan2(PIER.z1-C.z,(PIER.x0+PIER.x1)/2-C.x),pt=(a,u)=>({x:C.x+Math.cos(a)*GNT_R,z:C.z+Math.sin(a)*GNT_R,y:gntArcY(u)});
  const arc=80*Math.PI/180,gap=10*Math.PI/180;let first=null;
  for(let k=0;k<4;k++){let prev=null;for(let j=0;j<4;j++){const a0=p0+k*(arc+gap)+j*arc/4,a1=a0+arc/4,A=pt(a0,j/4),B=pt(a1,(j+1)/4);
      const r={x0:A.x,z0:A.z,y0:A.y,x1:B.x,z1:B.z,y1:B.y,gnt:true,ring:true};if(prev){prev.nx=r;r.pv=prev;}prev=r;if(!first)first=r;RAILS.push(r);GNT.rails.push(r);draw(r);}}
  // the rail up from the pier
  const S={x:(PIER.x0+PIER.x1)/2,z:PIER.z1-18},up={x0:S.x,z0:S.z,y0:PIER.y+0.6,x1:first.x0,z1:first.z0,y1:first.y0,gnt:true,nx:first};first.pv=up;
  RAILS.push(up);GNT.rails.push(up);draw(up);
  // the arm, from the master's shoulder out over the ring, and the red shadow it throws on the sea before it comes
  const arm=new THREE.Group(),blk=new THREE.MeshBasicMaterial({color:'#0b0b0d'}),bar=new THREE.Mesh(new THREE.BoxGeometry(32,1.1,1.4),blk);bar.position.x=19;arm.add(bar);
  const hand=new THREE.Mesh(new THREE.SphereGeometry(1.5,12,8),blk);hand.position.x=35;arm.add(hand);arm.position.set(C.x,30,C.z);arm.visible=false;g.add(arm);GNT.arm=arm;
  const warn=new THREE.Mesh(new THREE.RingGeometry(GNT_R-5,GNT_R+5,32,1,0,1),new THREE.MeshBasicMaterial({color:'#ff3020',transparent:true,opacity:0,blending:THREE.AdditiveBlending,depthWrite:false,side:THREE.DoubleSide,fog:false}));
  warn.rotation.x=Math.PI/2;warn.position.set(C.x,SEA_Y+0.3,C.z);g.add(warn);GNT.warn=warn;
  GNT.halo=runRib(g,1.5,'#2a5a9a','#8a5a18');GNT.core=runRib(g,0.32,'#bfe6ff','#ffe6a0');}
// in the fight: the hearts and the master's wounds as they were at the start, and her on the pier facing the ring
function giantP(){return new Promise(res=>{gntBuild();ST.actor=null;talkNpc=null;
  Object.assign(GNT,{on:true,res,t:0,st:0,gauge:0,need:4,hearts:DRONE.maxHp,inv:0,swept:0,ang:null,armT:5,sw:null,end:false});GNT.trail.length=0;GNT.g.visible=true;
  gntPier();toast('桟橋の先の光のレールに跳び乗って、主のまわりを一周しろ！',true);renderHUD();});}
function gntPier(){P.grind=null;P.air=false;P.vy=0;P.x=(PIER.x0+PIER.x1)/2;P.z=PIER.z1-40;P.y=PIER.y;P.yaw=0;P.v=6;P.foot=false;GNT.swept=0;GNT.ang=null;GNT.trail.length=0;camInit=false;}
function gntHurt(why){if(why!=='sea'&&GNT.inv>0||GNT.end)return;GNT.inv=1.4;GNT.hearts--;buzz('heavy',true);renderHUD();
  if(GNT.hearts>0&&why!=='sea'){toast('主の腕に、はじかれた！');return;}
  $('fade').style.opacity=1;GNT.end=true;
  setTimeout(()=>{if(GNT.hearts<=0){GNT.hearts=DRONE.maxHp;toast('……まだ、終われない。ミオの声が、背中を押した',true);}else toast('海に落ちた！ 桟橋からやりなおし');
    gntPier();GNT.sw=null;GNT.arm.visible=false;GNT.warn.material.opacity=0;GNT.armT=4;GNT.end=false;$('fade').style.opacity=0;renderHUD();},700);}
// once round: the line closes in the air, a ring of light rises round the master and wears it down
function gntLap(){const C=gntC(),y=GNT.trail.reduce((s,p)=>s+p.y,0)/Math.max(1,GNT.trail.length);
  const ring=new THREE.Mesh(new THREE.TorusGeometry(GNT_R,0.5,8,64),new THREE.MeshBasicMaterial({color:'#ffe2a0',transparent:true,opacity:0.9,blending:THREE.AdditiveBlending,depthWrite:false,fog:false}));
  ring.rotation.x=Math.PI/2;ring.position.set(C.x,y,C.z);GNT.g.add(ring);GNT.fx=GNT.fx||[];GNT.fx.push({m:ring,t:0});
  const d=1+DRONE.dmg;GNT.gauge+=d;const p=bossEye();for(let k=0;k<5;k++)setTimeout(()=>sparks(p.clone().add(new THREE.Vector3(rnd()*12-6,rnd()*10-12,rnd()*6-3)),18,'#ffe2a0',8,0.4),k*120);
  sfx.boom(0.7);buzz('heavy',true);
  if(GNT.gauge>=GNT.need){GNT.gauge=0;GNT.st++;BOSS.y-=5;setTimeout(()=>{if(GNT.on)BOSS.y+=5;},1400);
    if(GNT.st>=3){gntFinish();return;}toast(`光の輪が、主をしめつけた！ 主がよろけた（${GNT.st}/3）`,true);}
  else runPop('光の輪！',`主に ${d%1?d.toFixed(1):d}　あと ${Math.ceil(GNT.need-GNT.gauge)}でよろける`);renderHUD();}
// the third time it reels: the lighthouse's beam swings round onto it
async function gntFinish(){GNT.end=true;GNT.sw=null;GNT.arm.visible=false;GNT.warn.material.opacity=0;gntPier();P.v=0;toast('いまだ！ 灯台の光が、主に向く！',true);
  await beamTurnP(gntC());const p=bossEye();for(let k=0;k<8;k++)setTimeout(()=>sparks(p.clone().add(new THREE.Vector3(rnd()*16-8,rnd()*10-6,rnd()*4)),20,'#ffe2a0',9,0.5),k*120);buzz('heavy',true);
  setTimeout(()=>{EX1R.beam=null;GNT.on=false;GNT.g.visible=false;GNT.trail.length=0;$('hurt').style.opacity=0;renderHUD();const r=GNT.res;GNT.res=null;if(r)r();},1800);}
// in the air over the ring she keeps to it: her heading turns along it and she is drawn back over it
function gntSteer(dt,C,r,a){if(!P.air||Math.abs(r-GNT_R)>4)return;const s=Math.sign(Math.sin(P.yaw)*-Math.sin(a)+Math.cos(P.yaw)*Math.cos(a))||1;
  P.yaw=Math.atan2(-Math.sin(a)*s,Math.cos(a)*s);const k=Math.min(1,dt*3);P.x+=(C.x+Math.cos(a)*GNT_R-P.x)*k;P.z+=(C.z+Math.sin(a)*GNT_R-P.z)*k;}
function updateGiant(dt){if(!GNT.on)return;const busy=!!(DLG||modal),C=gntC();
  for(const f of (GNT.fx||[]).slice()){f.t+=dt/1.2;f.m.scale.setScalar(1+f.t*0.3);f.m.position.y+=dt*4;f.m.material.opacity=0.9*(1-f.t);if(f.t>=1){GNT.g.remove(f.m);f.m.geometry.dispose();GNT.fx.splice(GNT.fx.indexOf(f),1);}}
  runRibbon(GNT.core,GNT.trail,GNT.t,GNT_LIFE);runRibbon(GNT.halo,GNT.trail,GNT.t,GNT_LIFE);
  if(busy||GNT.end)return;GNT.t+=dt;GNT.inv-=dt;
  const dx=P.x-C.x,dz=P.z-C.z,r=Math.hypot(dx,dz),a=Math.atan2(dz,dx),onRing=P.grind&&P.grind.r.ring,flying=P.air&&Math.abs(r-GNT_R)<5&&P.y>SEA_Y+1;
  gntSteer(dt,C,r,a);
  // into the sea
  if(P.y<SEA_Y+0.6&&!onPier(P.x,P.z)){gntHurt('sea');return;}
  // round the master: the angle she has gone, and the line behind her
  if(onRing||flying){if(GNT.ang!=null){let d=a-GNT.ang;d=Math.atan2(Math.sin(d),Math.cos(d));GNT.swept+=d;}GNT.ang=a;
    const T=GNT.trail,l=T[T.length-1];if(!l||Math.hypot(P.x-l.x,P.z-l.z)>0.5)T.push({x:P.x,y:P.y+0.08,z:P.z,t:GNT.t,g:1});
    if(Math.abs(GNT.swept)>=TAU){GNT.swept-=TAU*Math.sign(GNT.swept);gntLap();}}
  else if(!P.grind){GNT.ang=null;GNT.swept=0;}
  while(GNT.trail.length&&GNT.t-GNT.trail[0].t>GNT_LIFE)GNT.trail.shift();while(GNT.trail.length>RUN_MAX)GNT.trail.shift();
  // the arm: a red shadow on the sea across the ring ahead of her, then the arm sweeping over it at the height of the rails
  GNT.armT-=dt;
  if(!GNT.sw&&GNT.armT<=0&&GNT.t>4){const dir=P.grind&&P.grind.r.ring?P.grind.dir:1,a0=a+dir*1.6,a1=a+dir*0.3;GNT.sw={a0,a1,t:0,warn:1.6};
    const lo=Math.min(a0,a1);GNT.warn.geometry.dispose();GNT.warn.geometry=new THREE.RingGeometry(GNT_R-5,GNT_R+5,24,1,lo,Math.abs(a1-a0));
    if(!GNT.said){GNT.said=true;toast('赤い影の上を、主の腕がなぎはらう！ レールの上でジャンプしてよけろ',true);}}
  const S=GNT.sw;
  if(S){S.t+=dt;const arm=GNT.arm;arm.visible=true;
    if(S.t<S.warn){GNT.warn.material.opacity=0.25+0.2*Math.sin(S.t*14);arm.rotation.y=-S.a0;arm.position.y=lerp(arm.position.y,24,dt*3);}
    else{const k=Math.min(1,(S.t-S.warn)/0.55),aa=lerp(S.a0,S.a1,k);arm.rotation.y=-aa;arm.position.y=lerp(arm.position.y,5.6,Math.min(1,dt*14));GNT.warn.material.opacity=0.35*(1-k);
      let d=a-aa;d=Math.atan2(Math.sin(d),Math.cos(d));
      if(Math.abs(d)<0.12&&r>GNT_R-6&&r<GNT_R+6&&(P.grind||!P.air))gntHurt('arm');
      if(k>=1){GNT.sw=null;arm.visible=false;arm.position.y=30;GNT.warn.material.opacity=0;GNT.armT=Math.max(3.5,7-GNT.st)+rnd()*2;}}}
  $('hurt').style.opacity=Math.max(GNT.inv>0.8?0.5:0,GNT.hearts===1?0.3+0.1*Math.sin(clock*5):0);
  GNT.hudT-=dt;if(GNT.hudT<=0){GNT.hudT=0.25;renderHUD();}}
function giantHUD(tr){tr.hidden=false;tr.innerHTML='';const b=document.createElement('b');b.textContent='影の主';const s=document.createElement('span');s.className='step';
  s.textContent=GNT.sw?'赤い影から腕がくる！ ジャンプでよけろ':`光のレールで、主のまわりを一周しろ（いま ${Math.round(Math.abs(GNT.swept)/TAU*100)}%）`;
  const m=document.createElement('span');m.className='meter';const gk=Math.min(GNT.need,Math.floor(GNT.gauge));
  m.textContent=`よろけ ${'■'.repeat(GNT.st)}${'□'.repeat(3-GNT.st)}　光 ${'◆'.repeat(gk)}${'◇'.repeat(Math.max(0,GNT.need-gk))}　${'♥'.repeat(Math.max(0,GNT.hearts))}${'♡'.repeat(Math.max(0,DRONE.maxHp-GNT.hearts))}`;tr.append(b,s,m);}
