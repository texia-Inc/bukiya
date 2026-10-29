
/* ---------- drone fight: Oceangate's surveillance drones over the town, shot down with the pair of pistols the baker (an old
   agent) lends. Only in this event do the pistols come out: the arms aim at the nearest drones in front and the shots alternate
   left and right. Drones circle ahead of you, take three hits, fall and burst on the ground. They shoot back: the eye glows and a
   red line points at you for a moment, then a slow red bolt flies where you are heading. Five hits and the drones pull out;
   talking to the baker again starts over. ---------- */
const DRONE={active:false,total:12,spawned:0,killed:0,spawnT:0,list:[],fx:[],bolts:[],fireT:0,side:1,t:0,hint:false,
  hp:5,maxHp:5,invT:0,hurt:0,volleyT:0,lost:false,dodgeHint:false,last:null,pv:new THREE.Vector3()};
const FIRE={mouse:false,touch:false};
const DRONE_TALK=['…おや、来たか。ちょっと耳を貸してくれ。','このところ、町の上を黒いドローンが飛び回ってる。オーシャンゲート社の監視ドローンだ。',
  '昔の仕事道具を貸してやる。…ああ、パン屋の前は別の仕事をしてたのさ。','スケボーに乗ったまま、クリックか J キーで撃てる。全部で12機、撃ち落としてくれ。','気をつけろ、向こうも撃ってくる。目が赤く光ったら、曲がってよけるんだ。'];
const DRONE_RETRY=['…派手にやられたな。ケガはないか？','もう一度行くか。止まっていると当たる。走りながら、曲がってよけるんだ。'];
const DM={body:tm('#2a2d33'),arm:tm('#40444c'),stripe:tm('#e0662a'),cam:tm('#15171a'),
  rotor:new THREE.MeshBasicMaterial({color:'#b8c0c8',transparent:true,opacity:0.4,depthWrite:false}),
  eye:new THREE.MeshBasicMaterial({color:'#ff3b30'}),hot:new THREE.MeshBasicMaterial({color:'#ffc2b8'}),flash:new THREE.MeshBasicMaterial({color:'#ffffff'}),
  bolt:new THREE.MeshBasicMaterial({color:'#ff4a3a'}),core:new THREE.MeshBasicMaterial({color:'#fff1ec'}),
  laser:new THREE.MeshBasicMaterial({color:'#ff3b30',transparent:true,opacity:0.35,depthWrite:false})};
function makeDrone(){const g=new THREE.Group(),rotors=[];
  const M=(geo,mat,ol,p)=>{const m=new THREE.Mesh(geo,mat);m.castShadow=true;if(ol)outline(m,ol);if(p)m.position.set(...p);g.add(m);return m;};
  const body=M(new THREE.BoxGeometry(0.46,0.15,0.4),DM.body,0.018);
  M(new THREE.BoxGeometry(0.47,0.03,0.1),DM.stripe,0,[0,0.08,0]);
  M(new THREE.SphereGeometry(0.085,14,10),DM.cam,0.012,[0,-0.06,0.17]);
  const eye=M(new THREE.SphereGeometry(0.04,10,8),DM.eye,0,[0,-0.06,0.245]);
  for(const [x,z] of [[1,1],[1,-1],[-1,1],[-1,-1]]){
    const arm=M(new THREE.BoxGeometry(0.05,0.035,0.42),DM.arm,0.01,[x*0.2,0.03,z*0.17]);arm.rotation.y=Math.atan2(x,z);
    M(new THREE.CylinderGeometry(0.035,0.035,0.06,10),DM.arm,0.01,[x*0.36,0.07,z*0.3]);
    rotors.push(M(new THREE.CylinderGeometry(0.17,0.17,0.008,18),DM.rotor,0,[x*0.36,0.105,z*0.3]));}
  g.scale.setScalar(1.25);scene.add(g);return{g,body,eye,rotors};}
function startDrones(){for(const d of DRONE.list){scene.remove(d.g);dropLaser(d);}for(const b of DRONE.bolts)scene.remove(b.m);DRONE.list.length=0;DRONE.bolts.length=0;
  Object.assign(DRONE,{active:true,spawned:0,killed:0,spawnT:0.6,t:0,hint:false,hp:DRONE.maxHp,invT:0,hurt:0,volleyT:1.5,lost:false});
  toast(hasTouch?'ドローンが来た！「撃つ」ボタンで撃ち落とせ':'ドローンが来た！ クリックか J キーで撃ち落とせ',true);renderHUD();}
function spawnDrone(){const a=(rnd()*2-1)*0.9,r=13+rnd()*9,h=3.2+rnd()*3,d=makeDrone();
  const ang=P.yaw+a;d.g.position.set(P.x+Math.sin(ang)*(r+28),G(P.x,P.z)+h+7,P.z+Math.cos(ang)*(r+28));
  Object.assign(d,{hp:3,off:{a,r,h},ph:rnd()*TAU,v:new THREE.Vector3(),dead:false,vy:0,spin:new THREE.Vector3(),hitT:0,fireT:2.5+rnd()*2,charge:0,laser:null});DRONE.list.push(d);DRONE.spawned++;}
// the drones the pistols can reach: alive, within range, and in front of you
function droneTargets(){const out=[];for(const d of DRONE.list){if(d.dead)continue;const dx=d.g.position.x-P.x,dz=d.g.position.z-P.z,dist=Math.hypot(dx,dz);
    let da=Math.atan2(dx,dz)-P.yaw;da=Math.atan2(Math.sin(da),Math.cos(da));if(dist<48&&Math.abs(da)<1.35)out.push([dist,d]);}
  return out.sort((a,b)=>a[0]-b[0]).map(x=>x[1]);}
function muzzleOf(sx){const V=player.vrm;if(V&&V.muzzle[sx])return V.muzzle[sx].getWorldPosition(new THREE.Vector3());
  return player.g.localToWorld(new THREE.Vector3(sx*0.25,1.25,0.55));}
// effects: tracers, muzzle flashes, sparks, smoke puffs, fireballs and shell casings, each fading out on its own clock
const FXG={box:new THREE.BoxGeometry(1,1,1),ball:new THREE.SphereGeometry(1,12,8),shell:new THREE.CylinderGeometry(0.006,0.006,0.022,6)};
const FLASH_TEX=canvasTex(64,64,(c,w,h)=>{const g=c.createRadialGradient(32,32,2,32,32,30);g.addColorStop(0,'rgba(255,255,230,1)');g.addColorStop(0.35,'rgba(255,214,110,.9)');g.addColorStop(1,'rgba(255,140,40,0)');
  c.fillStyle=g;c.beginPath();for(let k=0;k<16;k++){const a=k/16*TAU,r=k%2?12:31;c.lineTo(32+Math.cos(a)*r,32+Math.sin(a)*r);}c.closePath();c.fill();});
function fx(o,life,upd){scene.add(o);DRONE.fx.push({o,t:0,life,upd});return o;}
function tracer(a,b){const m=new THREE.Mesh(FXG.box,new THREE.MeshBasicMaterial({color:'#fff0a8',transparent:true,opacity:0.95,depthWrite:false}));
  m.position.copy(a).add(b).multiplyScalar(0.5);m.lookAt(b);m.scale.set(0.035,0.035,a.distanceTo(b));fx(m,0.09,(f,k)=>{m.material.opacity=0.95*(1-k);});}
function flash(p){const s=new THREE.Sprite(new THREE.SpriteMaterial({map:FLASH_TEX,transparent:true,depthWrite:false}));s.position.copy(p);s.scale.setScalar(0.42);s.material.rotation=rnd()*TAU;
  fx(s,0.06,(f,k)=>{s.material.opacity=1-k;});}
function sparks(p,n,col,speed,size){for(let i=0;i<n;i++){const m=new THREE.Mesh(FXG.box,new THREE.MeshBasicMaterial({color:col,transparent:true}));m.position.copy(p);m.scale.setScalar(size);
    const v=new THREE.Vector3(rnd()-0.5,rnd()*0.8,rnd()-0.5).normalize().multiplyScalar(speed*(0.4+rnd()));
    fx(m,0.35+rnd()*0.3,(f,k,dt)=>{v.y-=9.8*dt;m.position.addScaledVector(v,dt);m.material.opacity=1-k;});}}
function boom(p){const b=new THREE.Mesh(FXG.ball,new THREE.MeshBasicMaterial({color:'#ffb347',transparent:true,depthWrite:false}));b.position.copy(p);
  fx(b,0.55,(f,k)=>{b.scale.setScalar(0.3+2.1*Math.sqrt(k));b.material.opacity=1-k;b.material.color.setHSL(0.08-0.06*k,1,0.6-0.25*k);});
  for(let i=0;i<5;i++){const s=new THREE.Mesh(FXG.ball,new THREE.MeshBasicMaterial({color:'#5a5552',transparent:true,depthWrite:false}));s.position.copy(p).add(new THREE.Vector3(rnd()-0.5,rnd()*0.4,rnd()-0.5));
    fx(s,1.4+rnd(),(f,k,dt)=>{s.position.y+=dt*1.2;s.scale.setScalar(0.25+1.1*k);s.material.opacity=0.7*(1-k);});}
  sparks(p,14,'#ffcf6a',7,0.07);sparks(p,8,'#2a2d33',5,0.09);}
function shell(sx){const V=player.vrm,h=V?V.arms[sx].hand.getWorldPosition(new THREE.Vector3()):muzzleOf(sx);const m=new THREE.Mesh(FXG.shell,tm('#d4a84a'));m.position.copy(h);m.position.y+=0.05;
  const side=new THREE.Vector3(Math.cos(P.yaw),0,-Math.sin(P.yaw)).multiplyScalar(sx*1.6),v=side.add(new THREE.Vector3(0,2.2,0)),sp=new THREE.Vector3(rnd()*20,rnd()*20,rnd()*20);
  fx(m,0.9,(f,k,dt)=>{v.y-=9.8*dt;m.position.addScaledVector(v,dt);m.rotation.x+=sp.x*dt;m.rotation.y+=sp.y*dt;const gy=G(m.position.x,m.position.z)+0.01;if(m.position.y<gy){m.position.y=gy;v.multiplyScalar(0.3);v.y=Math.abs(v.y);}});}
function shoot(sx,d){const a=muzzleOf(sx);let b;
  if(d){b=d.g.position.clone().add(new THREE.Vector3(rnd()-0.5,rnd()-0.5,rnd()-0.5).multiplyScalar(0.3));
    if(rnd()<0.82){damage(d,b);}else b.add(b.clone().sub(a).normalize().multiplyScalar(12));}
  else b=a.clone().add(new THREE.Vector3(Math.sin(P.yaw),0.02,Math.cos(P.yaw)).multiplyScalar(40));
  tracer(a,b);flash(a);shell(sx);}
// return fire: a short aim with a red line, then a bolt led toward where you are going
const CHARGE=0.7,BOLT_V=16;
function chest(){return new THREE.Vector3(P.x,P.y+1.05,P.z);}
function dropLaser(d){if(d.laser){scene.remove(d.laser);d.laser=null;}d.eye.scale.setScalar(1);}
function droneShot(d){dropLaser(d);const a=d.eye.getWorldPosition(new THREE.Vector3()),c=chest(),t=a.distanceTo(c)/BOLT_V;
  const aim=c.addScaledVector(DRONE.pv,t*0.9).add(new THREE.Vector3(rnd()-0.5,(rnd()-0.5)*0.5,rnd()-0.5).multiplyScalar(0.7));
  const m=new THREE.Group(),glow=new THREE.Mesh(FXG.ball,DM.bolt),core=new THREE.Mesh(FXG.ball,DM.core);glow.scale.set(0.12,0.12,0.42);core.scale.set(0.05,0.05,0.24);m.add(glow,core);
  m.position.copy(a);m.lookAt(aim);scene.add(m);DRONE.bolts.push({m,v:aim.sub(a).setLength(BOLT_V),life:4});sparks(a,4,'#ff6a50',2,0.04);}
function hurtPlayer(p){DRONE.hp--;DRONE.invT=1.2;DRONE.hurt=1;P.bump=Math.max(P.bump,0.5);P.v*=0.6;sparks(p,10,'#ff5a40',4,0.05);renderHUD();
  if(DRONE.hp<=0){loseDrones();return;}
  if(!DRONE.dodgeHint){DRONE.dodgeHint=true;toast('当たった！ 走りながら曲がると、よけやすい');}}
function loseDrones(){DRONE.active=false;DRONE.lost=true;for(const d of DRONE.list)dropLaser(d);renderHUD();
  toast('やられた… ドローンが引き上げていく',true);setTimeout(()=>toast('こむぎ堂の主人にもう一度話しかけると、やり直せる'),1800);}
function damage(d,p){d.hp--;d.hitT=0.08;sparks(p,6,'#fff3c0',4,0.04);
  if(d.hp<=0){d.dead=true;d.vy=1.5;d.spin.set(rnd()*6-3,rnd()*10-5,rnd()*6-3);DRONE.killed++;SAVE.money+=50;
    sparks(d.g.position,10,'#ffcf6a',5,0.06);renderHUD();if(DRONE.killed>=DRONE.total)finishDrones();}}
function finishDrones(){DRONE.active=false;SAVE.money+=1000;SAVE.drones=(SAVE.drones||0)+1;SAVE.flags.drones_cleared=1;save();renderHUD();
  toast('ドローンを全部撃ち落とした！ お礼 +1000円',true);setTimeout(()=>toast('こむぎ堂の主人「いい腕だ。…このことは、町のみんなには内緒だぞ」'),1800);}
function updateDrones(dt){DRONE.t+=dt;const busy=!!(DLG||modal),me=chest();
  // how you are moving, for the drones to lead their shots
  if(DRONE.last&&dt>0)DRONE.pv.lerp(me.clone().sub(DRONE.last).divideScalar(dt),Math.min(1,dt*6));DRONE.last=me.clone();
  DRONE.invT-=dt;DRONE.volleyT-=dt;DRONE.hurt=Math.max(0,DRONE.hurt-dt*1.6);
  // spawning: four at a time until all twelve have come
  if(DRONE.active){DRONE.spawnT-=dt;const alive=DRONE.list.filter(d=>!d.dead).length;
    if(DRONE.spawned<DRONE.total&&alive<4&&DRONE.spawnT<=0){spawnDrone();DRONE.spawnT=1.6;}}
  for(const d of DRONE.list.slice()){const p=d.g.position;
    if(d.dead){d.vy-=12*dt;p.y+=d.vy*dt;d.g.rotation.x+=d.spin.x*dt;d.g.rotation.y+=d.spin.y*dt;d.g.rotation.z+=d.spin.z*dt;
      if(rnd()<dt*30)sparks(p,1,'#4a4644',1,0.08);
      if(p.y<=G(p.x,p.z)+0.25){boom(p.clone());scene.remove(d.g);DRONE.list.splice(DRONE.list.indexOf(d),1);}continue;}
    // after a lost fight the rest climb away and go
    if(!DRONE.active){d.v.y+=7*dt;p.addScaledVector(d.v,dt);for(const ro of d.rotors)ro.rotation.y+=dt*40;
      if(p.y>G(p.x,p.z)+40){scene.remove(d.g);DRONE.list.splice(DRONE.list.indexOf(d),1);}continue;}
    // each drone keeps a spot ahead of you that drifts slowly, and turns its camera on you
    const ang=P.yaw+d.off.a+Math.sin(DRONE.t*0.35+d.ph)*0.45,r=d.off.r+Math.sin(DRONE.t*0.5+d.ph*2)*3;
    const want=new THREE.Vector3(P.x+Math.sin(ang)*r,0,P.z+Math.cos(ang)*r);want.y=G(want.x,want.z)+d.off.h+Math.sin(DRONE.t*1.3+d.ph)*0.5;
    if(p.distanceTo(want)>90)p.copy(want).add(new THREE.Vector3(0,8,0));
    const acc=want.sub(p).multiplyScalar(2.2).sub(d.v.clone().multiplyScalar(1.6));d.v.addScaledVector(acc,dt);if(d.v.length()>14)d.v.setLength(14);p.addScaledVector(d.v,dt);
    d.g.lookAt(P.x,P.y+1.2,P.z);d.g.rotateX(clamp(d.v.length()*0.02,0,0.25));
    for(const ro of d.rotors)ro.rotation.y+=dt*40;
    // aiming and firing back, one drone at a time so the shots come in a rhythm you can dodge
    d.fireT-=dt;
    if(!busy&&!d.charge&&d.fireT<=0&&DRONE.volleyT<=0&&p.distanceTo(me)<36){d.charge=CHARGE;DRONE.volleyT=0.9;
      d.laser=new THREE.Mesh(FXG.box,DM.laser);scene.add(d.laser);}
    if(d.charge>0){d.charge-=dt;const k=1-d.charge/CHARGE,e=d.eye.getWorldPosition(new THREE.Vector3());d.eye.scale.setScalar(1+1.6*k);
      d.laser.position.copy(e).add(me).multiplyScalar(0.5);d.laser.lookAt(me);d.laser.scale.set(0.02,0.02,e.distanceTo(me));
      if(d.charge<=0){d.charge=0;if(busy)dropLaser(d);else droneShot(d);d.fireT=2.6+rnd()*2.2;}}
    d.hitT-=dt;d.eye.material=d.hitT>0?DM.flash:d.charge>0&&(DRONE.t*16|0)%2?DM.hot:DM.eye;}
  // the bolts: hit you, the ground, or run out
  for(const b of DRONE.bolts.slice()){const m=b.m,p=m.position;let gone=false;b.life-=dt;
    if(!busy)p.addScaledVector(b.v,dt);
    if(DRONE.active&&!busy&&DRONE.invT<=0&&p.distanceTo(me)<0.5){hurtPlayer(p.clone());gone=true;}
    else if(p.y<G(p.x,p.z)+0.05){sparks(p,5,'#ff7a5a',3,0.04);gone=true;}
    else if(b.life<=0)gone=true;
    if(gone){scene.remove(m);DRONE.bolts.splice(DRONE.bolts.indexOf(b),1);}}
  $('hurt').style.opacity=Math.max(DRONE.hurt,DRONE.active&&DRONE.hp===1?0.3+0.1*Math.sin(DRONE.t*5):0);
  // the pistols: out for the whole fight, raised when there is something to shoot at or the trigger is held
  const firing=DRONE.active&&!busy&&(FIRE.mouse||FIRE.touch||!!keys.KeyJ);
  const canAim=!(P.foot&&P.carry==='hand')&&!(P.tr&&P.tr.type!=='stow');
  if(DRONE.active&&firing&&!canAim&&!DRONE.hint){DRONE.hint=true;toast('板を手に持っていると撃てない。走り出すと背中に背負う');}
  const T=DRONE.active?droneTargets():[];
  player.gunsOut=DRONE.active;
  const want=DRONE.active&&canAim&&!busy&&(T.length||firing)?1:0;player.aimW=(player.aimW||0)+(want-(player.aimW||0))*Math.min(1,dt*10);
  const ahead=new THREE.Vector3(P.x+Math.sin(P.yaw)*30,P.y+1.4,P.z+Math.cos(P.yaw)*30);
  player.aim={1:T[0]?T[0].g.position:ahead,'-1':(T[1]||T[0])?(T[1]||T[0]).g.position:ahead};
  DRONE.fireT-=dt;
  if(firing&&canAim&&player.aimW>0.7&&DRONE.fireT<=0){DRONE.fireT=0.11;const sx=DRONE.side;DRONE.side=-sx;shoot(sx,sx===1?T[0]:(T[1]||T[0]));}
  for(const f of DRONE.fx.slice()){f.t+=dt;const k=Math.min(1,f.t/f.life);f.upd(f,k,dt);if(k>=1){scene.remove(f.o);if(f.o.material&&f.o.material!==DM.flash&&f.o.geometry!==FXG.shell)f.o.material.dispose();DRONE.fx.splice(DRONE.fx.indexOf(f),1);}}
  $('bShoot').hidden=!(DRONE.active&&hasTouch);}
// the tracker shows the fight while it is on
function droneHUD(tr){tr.hidden=false;tr.innerHTML='';const b=document.createElement('b');b.textContent='ドローン迎撃';const s=document.createElement('span');s.className='step';
  s.textContent=(hasTouch?'「撃つ」ボタンで撃つ。':'クリックか J キーで撃つ。')+'近いドローンを自動でねらう。赤い光は曲がってよける';
  const m=document.createElement('span');m.className='meter';
  m.textContent=`撃ち落とした ${DRONE.killed} / ${DRONE.total}　${'♥'.repeat(Math.max(0,DRONE.hp))}${'♡'.repeat(DRONE.maxHp-Math.max(0,DRONE.hp))}`;tr.append(b,s,m);}
