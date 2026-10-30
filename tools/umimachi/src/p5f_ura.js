
/* ---------- the horror route "トンネルの向こう": 裏海街, the town on the other side of the west tunnel, stopped thirty years ago.
   The same streets, drained of colour and sunk in fog; nobody about but the faceless shadows walking their beats and the tram
   running with no driver. Nagi looks for three things Mio left behind by flashlight (L), keeping out of the shadows' sight —
   skating is loud, walking (F) is quiet, the light carries far. Seen for too long and a cold hand sends you back to the tunnel.
   After the third, the big shadow comes, and the only way out is the tunnel. It hunts by ear and by eye: the board it hears from
   far off, a walker only close by, and it sees you in front of it. Its tread and growl (and your heartbeat) grow louder as it
   comes near; the big wooden crates in the streets hide you, and it walks on by unless it saw you get in. ---------- */
const URA_START=[-222,COAST_Z+1.1,Math.PI/2],URA_EXIT=[-226,COAST_Z+1.1,5];
const URA_CLUES=[{id:'photo',name:'駅のホーム',x:62,z:TRAM_Z-1.5},{id:'marble',name:'駄菓子まるや',x:SHOPS.dagashi.door[0],z:SHOPS.dagashi.door[1]},{id:'diary',name:'神社の本殿',x:SHRINE.x,z:-157.5}];
const URA_BEATS=[[-45,-20,45,-20],[0,-120,0,-35],[0,40,0,190],[-150,COAST_Z,-30,COAST_Z],[25,COAST_Z+1,150,COAST_Z+1],[40,TRAM_Z-4,100,TRAM_Z-4],[SHRINE.x,-131,SHRINE.x,-152],[-120,-140,-120,60]];
const URA={on:false,shadows:[],sus:0,chase:null,hides:[],hide:null,mood:new THREE.Color('#4a5a54'),fog:new THREE.Color('#2a3430')};
const SHADE={skin:'#141518',hair:'#0b0b0d',style:'short',shirt:'#1b1c21',sleeves:'long',bottom:'pants',bottomCol:'#121316',shoe:'#0b0b0d'};
const torch=new THREE.SpotLight('#fff1d0',0,30,0.42,0.55,1);scene.add(torch);scene.add(torch.target);let torchOn=false;
const uraGlints=URA_CLUES.map(c=>{const g=glow('#bfefff',c.x,G(c.x,c.z)+0.9,c.z,1.4);return g;});
const omochi=makeCat({col:'#f2f2ee'});omochi.g.visible=false;world.add(omochi.g);
// hiding places for the chase: big wooden crates in the streets, only on this side of the tunnel
const URA_HIDE_AT=[[-200,COAST_Z-3],[-160,COAST_Z-3],[-118,COAST_Z-3],[-75,COAST_Z-3],[-35,COAST_Z-3],[5,COAST_Z-3],[45,COAST_Z-3],[90,COAST_Z-3],
  [62,TRAM_Z-6],[20,TRAM_Z-6],[-30,TRAM_Z-6],[SHOPS.dagashi.door[0]+4,SHOPS.dagashi.door[1]],[SHRINE.x+5,-140],[SHRINE.x-6,-125],
  [-45,-20],[0,-60],[0,20],[0,120],[-120,-40],[-120,60],[-80,170],[-160,190]];
function uraCrates(){const wood=tm('#6b5a44'),slat=tm('#4e4132');
  for(const [x0,z0] of URA_HIDE_AT){let spot=null;
    for(let r=0;r<=9&&!spot;r+=1.5)for(let k=0;k<8&&!spot;k++){const x=x0+Math.cos(k/8*TAU)*r,z=z0+Math.sin(k/8*TAU)*r,y=G(x,z);
      if(y>SEA_Y+0.3&&Math.abs(y-G(x0,z0))<1.2&&!hits(x,z,1.9,y))spot={x,z,y};}
    if(!spot)continue;const g=new THREE.Group();g.position.set(spot.x,spot.y,spot.z);g.rotation.y=rnd()*TAU;world.add(g);
    const b=new THREE.Mesh(new THREE.BoxGeometry(1.5,1.4,1.5),wood);b.position.y=0.7;b.castShadow=true;outline(b,0.03);g.add(b);
    for(const y of [0.25,0.7,1.15])for(const sd of [-1,1]){const l=new THREE.Mesh(new THREE.BoxGeometry(1.54,0.12,0.06),slat);l.position.set(0,y,sd*0.76);g.add(l);}
    const lid=new THREE.Mesh(new THREE.BoxGeometry(1.2,0.08,1.0),slat);lid.position.set(0.15,1.44,0.1);lid.rotation.y=0.3;g.add(lid);
    const c=collide(spot.x-0.8,spot.x+0.8,spot.z-0.8,spot.z+0.8,'prop',spot.y+1.45);URA.hides.push({x:spot.x,z:spot.z,y:spot.y,g,c});}}
function uraEnter(){if(!URA.hides.length)uraCrates();for(const h of URA.hides){h.g.visible=true;if(h.c)h.c.on=true;}URA.on=true;SAVE.flags.in_ura=1;canvas.style.filter='saturate(.28) sepia(.3) hue-rotate(-12deg) brightness(1.12)';
  if(!URA.shadows.length)URA_BEATS.forEach(([x0,z0,x1,z1],k)=>{const h=makeHuman(SHADE);world.add(h.g);
    const eye=glow('#ff3020',0,0,0,0.9);URA.shadows.push({h,a:[x0,z0],b:[x1,z1],t:(k*0.37)%1,dir:1,sus:0,eye});});
  for(const s of URA.shadows){s.h.g.visible=true;s.sus=0;}
  omochi.g.position.set(URA_START[0]+3,G(URA_START[0]+3,URA_START[1]+2)+0.02,URA_START[1]+2);omochi.g.rotation.y=Math.PI/2;omochi.g.visible=true;
  scene.fog.near=12;scene.fog.far=150;renderHUD();}
function uraExit(){URA.on=false;for(const h of URA.hides){h.g.visible=false;if(h.c)h.c.on=false;}if(URA.hide)uraUnhide();SAVE.flags.in_ura=0;canvas.style.filter='';torchOn=false;torch.intensity=0;scene.fog.near=260;scene.fog.far=2600;
  for(const s of URA.shadows){s.h.g.visible=false;s.eye.visible=false;}omochi.g.visible=false;
  for(const c of CARS){c.g.visible=true;c.box.on=true;}for(const k in folkMesh)folkMesh[k].visible=true;for(const c of CATS)c.g.visible=true;$('hurt').style.opacity=0;$('lightBtn').hidden=true;renderHUD();}
function toggleTorch(){if(!URA.on)return;torchOn=!torchOn;toast(torchOn?'ライトをつけた（遠くまで見えるけど、見つかりやすい）':'ライトを消した');}
const clueLeft=()=>URA_CLUES.filter(c=>!SAVE.flags['clue_'+c.id]);
function uraHUD(tr){tr.hidden=false;tr.innerHTML='';const b=document.createElement('b');b.textContent=URA.chase?'逃げろ！':'裏海街';const s=document.createElement('span');s.className='step';
  s.textContent=URA.hide?'木箱の中で、じっと息をひそめる。足音が遠ざかったら、'+(hasTouch?'「出る」ボタンで外へ':'E で出る'):URA.chase?'西のトンネルへ。スケボーは遠くまで聞こえる。足音が近づいたら、木箱に隠れてやり過ごす':'影の住人に見つからないように、手がかりを探す。歩くと静か、スケボーとライトは目立つ';
  const m=document.createElement('span');m.className='meter';const L=clueLeft(),near=URA.chase?Math.round(uraAtt(URA.chase.d||99,70)*5):0;
  m.textContent=URA.chase?`気配 ${'■'.repeat(near)}${'□'.repeat(5-near)}`:L.length?`手がかり ${3-L.length} / 3　のこり：${L.map(c=>c.name).join('・')}`:'手がかりは そろった';tr.append(b,s,m);}
// the chase: the big shadow comes from behind. It hunts what it hears or sees, goes to where it last knew you were, waits and
// sniffs, then wanders closer again. Caught, you are back at the last crate you hid in (or where the chase began)
function chaseP(){return new Promise(res=>{ST.actor=null;talkNpc=null;
  if(!URA.big){const h=makeHuman(SHADE);h.g.scale.setScalar(1.9);world.add(h.g);URA.big={h,eye:glow('#ff3020',0,0,0,2.2)};}
  const F=new THREE.Vector3(Math.sin(P.yaw),0,Math.cos(P.yaw)),p=new THREE.Vector3(P.x,0,P.z).addScaledVector(F,-30);
  URA.big.h.g.position.set(p.x,G(p.x,p.z),p.z);URA.big.h.g.visible=URA.big.eye.visible=true;
  URA.chase={t:0,res,mode:'hunt',tx:P.x,tz:P.z,wait:0,sp:0,d:30,grace:2,save:[P.x,P.z,P.yaw],saw:false,hudT:0,rec:[],replay:null};
  if(!URA.goal){URA.goal=marker(MK.target);URA.goal.scale.set(1.6,1.6,1);}
  toast('足音が近づいてきたら、木箱に隠れてやり過ごそう',true);renderHUD();});}
const uraAtt=(d,r)=>clamp(1-d/r,0,1)**2;
function uraNear(){if(URA.hide)return{kind:'unhide',d:0,label:'出る　木箱から',verb:'出る'};
  let best=null;for(const h of URA.hides){const d=Math.hypot(P.x-h.x,P.z-h.z);if(d<2.5&&(!best||d<best.d))best={kind:'hide',h,d,label:'隠れる　木箱',verb:'隠れる'};}return best;}
function uraAct(o){const C=URA.chase;
  if(o.kind==='hide'){URA.hide=o.h;P.v=0;P.air=false;player.g.visible=false;camInit=false;
    if(C){C.save=[o.h.x+1.6,o.h.z,P.yaw];C.saw=C.mode==='hunt'&&C.d<12;}renderHUD();}
  else uraUnhide();}
function uraUnhide(){const h=URA.hide;URA.hide=null;player.g.visible=true;if(h){const a=Math.atan2(P.x-h.x,P.z-h.z);P.x=h.x+Math.sin(a)*1.7;P.z=h.z+Math.cos(a)*1.7;P.y=G(P.x,P.z);}camInit=false;renderHUD();}
// peeking out over the lid of the crate: the view stays low and turns to the shadow
function uraHideCam(want,look){const h=URA.hide,bg=URA.big&&URA.chase?URA.big.h.g.position:null;
  const tx=bg?bg.x:h.x+Math.sin(P.yaw)*10,tz=bg?bg.z:h.z+Math.cos(P.yaw)*10,a=Math.atan2(tx-h.x,tz-h.z);
  want.set(h.x+Math.sin(a)*0.35,h.y+1.62,h.z+Math.cos(a)*0.35);look.set(tx,(bg?bg.y:h.y)+2.2,tz);}
// caught in the open: first a short replay from the side, so you see it reach you (the last 2 s, the end slowed down)
function uraCaught(){const C=URA.chase;C.grace=99;
  if(!URA.hide&&C.rec.length>20&&!C.replay){const t1=C.rec[C.rec.length-1].t;C.replay={t:0,f:C.rec.filter(r=>r.t>=t1-2),t1,side:1};
    const r0=C.replay.f[0];C.replay.t0=r0.t;C.replay.at=r0.t;document.body.classList.add('cine');$('hurt').style.opacity=0;
    const mx=(P.x+URA.big.h.g.position.x)/2,mz=(P.z+URA.big.h.g.position.z)/2,dx=P.x-URA.big.h.g.position.x,dz=P.z-URA.big.h.g.position.z,l=Math.hypot(dx,dz)||1;
    if(blocked(mx-dz/l*7,G(mx,mz)+2.4,mz+dx/l*7))C.replay.side=-1;
    $('cbarT').innerHTML='<span class="rpl">● リプレイ</span>';return;}
  uraCaughtReset();}
function uraReplayStep(dt){const C=URA.chase,R=C.replay,bg=URA.big.h.g;R.at+=dt*(R.t1-R.at<0.8?0.4:1);   // slow for the last moment
  const f=R.f;let i=0;while(i<f.length-2&&f[i+1].t<R.at)i++;const a=f[i],b=f[i+1]||a,k=b.t>a.t?clamp((R.at-a.t)/(b.t-a.t),0,1):1;
  P.x=lerp(a.x,b.x,k);P.y=lerp(a.y,b.y,k);P.z=lerp(a.z,b.z,k);P.yaw=a.yaw;P.v=a.v;P.foot=a.foot;
  bg.position.set(lerp(a.bx,b.bx,k),lerp(a.by,b.by,k),lerp(a.bz,b.bz,k));bg.rotation.y=a.br;
  if(a.sp>0.5)poseHuman(URA.big.h,'walk',dt*(R.t1-R.at<0.8?0.4:1),{rate:2.2+a.sp*0.45});
  URA.big.eye.position.set(bg.position.x,bg.position.y+3.05,bg.position.z);
  if(R.at>=R.t1){if((R.hold=(R.hold||0)+dt)>0.6){C.replay=null;document.body.classList.remove('cine');$('cbarT').innerHTML='';uraCaughtReset();}}}
// the replay camera: from the side of the line between her and the shadow, a little above, both in the picture
function uraReplayCam(want,look){const C=URA.chase,R=C.replay,bg=URA.big.h.g.position,mx=(P.x+bg.x)/2,mz=(P.z+bg.z)/2,dx=P.x-bg.x,dz=P.z-bg.z,l=Math.hypot(dx,dz)||1,
    s=R.side,d=6+Math.min(l,12)*0.45,sw=(R.at-R.t0)*0.25;
  want.set(mx-dz/l*d*s+dx/l*sw,G(mx,mz)+2.3,mz+dx/l*d*s+dz/l*sw);look.set(mx,G(mx,mz)+1.5,mz);}
function uraReplayPose(dt){player.g.position.set(P.x,P.y,P.z);player.g.rotation.set(0,P.yaw,0);const sl=URA.chase.replay&&URA.chase.replay.t1-URA.chase.replay.at<0.8?0.4:1;
  if(P.foot){player.root.rotation.set(0,0,0);poseRunner(player,dt*sl,{v:P.v,turn:0,air:false,vy:0,tr:null,carry:P.carry});}
  else{player.root.rotation.set(0,0,0);poseSkater(player,dt*sl,{v:P.v,turn:0,push:false,brake:false,air:false});}}
function uraCaughtReset(){const C=URA.chase;if(URA.hide)uraUnhide();C.grace=99;C.rec=[];$('fade').style.opacity=1;P.v=0;
  setTimeout(()=>{P.x=C.save[0];P.z=C.save[1];P.yaw=C.save[2];P.y=G(P.x,P.z);const a=rnd()*TAU,bg=URA.big.h.g;
    bg.position.set(P.x+Math.sin(a)*40,0,P.z+Math.cos(a)*40);C.mode='roam';C.tx=bg.position.x;C.tz=bg.position.z;C.grace=3;camInit=false;$('fade').style.opacity=0;
    toast('冷たい手が、肩にふれた――。気がつくと、さっきの場所にいた',true);},900);}
function chaseStep(dt){const C=URA.chase;if(C.replay){uraReplayStep(dt);return;}C.t+=dt;C.grace-=dt;const bg=URA.big.h.g,hid=!!URA.hide;
  const dx=P.x-bg.position.x,dz=P.z-bg.position.z,dd=Math.hypot(dx,dz)||1;C.d=dd;
  // what it knows: the board from far off, a walker close by, anyone in front of it in the fog; nobody in a crate
  const loud=!P.foot&&P.v>2.5,facing=(Math.sin(bg.rotation.y)*dx+Math.cos(bg.rotation.y)*dz)/dd;
  const knows=!hid&&C.grace<=0&&(dd<(loud?40:9)||(dd<20&&facing>0.3));
  if(knows){C.mode='hunt';C.tx=P.x;C.tz=P.z;}else if(C.mode==='hunt'){C.mode='search';C.wait=0;}
  const pick=(r0,r1)=>{const a=rnd()*TAU,r=r0+rnd()*(r1-r0);C.tx=P.x+Math.sin(a)*r;C.tz=P.z+Math.cos(a)*r;};
  const tdx=C.tx-bg.position.x,tdz=C.tz-bg.position.z,td=Math.hypot(tdx,tdz);let sp=0;
  if(C.mode==='hunt')sp=Math.min(9.6,7.2+C.t*0.04);
  else if(td>1.5)sp=C.mode==='search'?4.4:3.4;
  else{C.wait+=dt;   // at the spot: it stands and sniffs, then wanders off and closes in again
    if(hid&&C.saw&&Math.hypot(URA.hide.x-bg.position.x,URA.hide.z-bg.position.z)<4){uraCaught();return;}
    if(C.wait>(C.mode==='search'?2.8:1.2)){C.mode='roam';C.wait=0;pick(hid?18:14,hid?34:30);}}
  // far behind, it does not give up: it comes out of the fog somewhere nearer
  if(dd>70||(C.mode==='hunt'&&dd>50)){const F=[Math.sin(P.yaw),Math.cos(P.yaw)],a=(rnd()-0.5)*1.6,r=34;
    bg.position.x=P.x+(F[0]*Math.cos(a)-F[1]*Math.sin(a))*r;bg.position.z=P.z+(F[1]*Math.cos(a)+F[0]*Math.sin(a))*r;C.mode='roam';pick(6,14);}
  C.sp=sp;if(sp>0&&td>0.01){const k=Math.min(td,sp*dt)/td;bg.position.x+=tdx*k;bg.position.z+=tdz*k;bg.rotation.y=Math.atan2(tdx,tdz);}
  else if(C.mode!=='hunt')bg.rotation.y+=Math.sin(C.t*1.7)*dt*1.2;   // looking round
  bg.position.y=G(bg.position.x,bg.position.z);if(sp>0.5)poseHuman(URA.big.h,'walk',dt,{rate:2.2+sp*0.45});else poseHuman(URA.big.h,'stand',dt,{});
  URA.big.eye.position.set(bg.position.x,bg.position.y+3.05,bg.position.z);URA.big.eye.material.opacity=0.8+0.2*Math.sin(clock*9);
  URA.goal.visible=true;URA.goal.position.set(URA_EXIT[0],G(URA_EXIT[0],URA_EXIT[1])+3.4+Math.sin(clock*3)*0.12,URA_EXIT[1]);
  $('hurt').style.opacity=Math.max(uraAtt(dd,40)*0.75,C.mode==='hunt'?0.3:0.1);
  C.hudT-=dt;if(C.hudT<=0){C.hudT=0.25;uraHUD($('tracker'));}
  C.rec.push({t:C.t,x:P.x,y:P.y,z:P.z,yaw:P.yaw,v:P.v,foot:P.foot,bx:bg.position.x,by:bg.position.y,bz:bg.position.z,br:bg.rotation.y,sp:C.sp});
  while(C.rec.length&&C.t-C.rec[0].t>3)C.rec.shift();
  if(!hid&&dd<1.7&&C.grace<=0){uraCaught();return;}
  if(!hid&&Math.hypot(P.x-URA_EXIT[0],P.z-URA_EXIT[1])<URA_EXIT[2]){URA.chase=null;bg.visible=URA.big.eye.visible=false;URA.goal.visible=false;C.res();}}
function updateUra(dt){
  if(!URA.on&&SAVE.flags.in_ura&&state==='play')uraEnter();   // a save made in 裏海街 opens there again
  $('lightBtn').hidden=!URA.on;
  if(!URA.on)return;
  // the light of the other side: thick fog, a dead green sky, unlit windows, lamps that flicker
  scene.fog.color.copy(URA.fog);scene.background.copy(URA.fog);dome.material.color.copy(URA.mood);hemi.intensity=0.5;sun.intensity=0.22;
  for(const m of NIGHT_MATS)m.emissiveIntensity=0;NIGHT.stars.material.opacity=0;
  for(const m of NIGHT.lamps){m.visible=Math.random()>0.08;m.material.opacity=0.55+Math.random()*0.3;}
  for(const c of CARS){c.g.visible=false;c.box.on=false;}for(const k in folkMesh)folkMesh[k].visible=false;for(const c of CATS)c.g.visible=false;
  URA_CLUES.forEach((c,k)=>{const g=uraGlints[k];g.visible=!SAVE.flags['clue_'+c.id];g.material.opacity=0.5+0.4*Math.sin(clock*3+k);});
  // the flashlight, held at the chest and pointing where she goes
  const F=new THREE.Vector3(Math.sin(P.yaw),0,Math.cos(P.yaw));torch.intensity=torchOn?2.4:0;
  torch.position.set(P.x,P.y+1.1,P.z).addScaledVector(F,0.7);torch.target.position.set(P.x,P.y+0.4,P.z).addScaledVector(F,9);torch.target.updateMatrixWorld();
  const me=new THREE.Vector3(P.x,P.y,P.z),loud=!P.foot&&P.v>4.5,quiet=P.foot&&P.v<4;
  let top=0;
  for(const s of URA.shadows){const g=s.h.g,a=s.a,b=s.b,L=Math.hypot(b[0]-a[0],b[1]-a[1]);
    const d=Math.hypot(P.x-g.position.x,P.z-g.position.z);
    const R=(8+(torchOn?6:0)+(loud?6:0))*(quiet?0.65:1);
    const fx=(b[0]-a[0])/L*s.dir,fz=(b[1]-a[1])/L*s.dir,toX=(P.x-g.position.x)/(d||1),toZ=(P.z-g.position.z)/(d||1);
    const seen=!URA.chase&&!URA.hide&&!ST.run&&!DLG&&!modal&&d<R&&(fx*toX+fz*toZ>0.45||d<3);
    s.sus=clamp(s.sus+(seen?dt*(d<5?1.6:1):-dt*0.5),0,1);
    if(s.sus<0.05&&!URA.chase){s.t+=s.dir*dt*1.1/L;if(s.t>1){s.t=1;s.dir=-1;}if(s.t<0){s.t=0;s.dir=1;}}   // walks its beat unless it has noticed you
    const x=lerp(a[0],b[0],s.t),z=lerp(a[1],b[1],s.t);g.position.set(x,G(x,z),z);
    g.rotation.y=s.sus>0.05?Math.atan2(P.x-x,P.z-z):Math.atan2(fx,fz);if(s.sus<0.05)poseHuman(s.h,'walk',dt,{rate:4.6});else poseHuman(s.h,'stand',dt,{});
    s.eye.visible=s.sus>0.02;s.eye.position.set(x,G(x,z)+1.62,z);s.eye.material.opacity=s.sus;top=Math.max(top,s.sus);}
  URA.sus=top;if(!URA.chase)$('hurt').style.opacity=top*0.7;
  if(top>=1&&!ST.run){for(const s of URA.shadows)s.sus=0;runEvent({id:'ura_caught',once:false,script:[
    ['fade','out'],['warp',...URA_START],['fade','in'],['say','','冷たい手が、肩にふれた――。','……気がつくと、トンネルの出口に立っていた。'],['say','nagi','（見つかっちゃだめだ。歩けば、足音は小さい……）']]});}
  if(URA.chase)chaseStep(dt);}
