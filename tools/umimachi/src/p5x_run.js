/* ---------- the second story's nights out, as a roguelite: 「裏海街 — 光を取り戻す夜」. From the command table Nagi rides into
   裏海街 with the lighthouse's light in her board. Riding leaves a line of light behind her (it costs light, the gauge at the
   top); bring it back round and the ring closes: the shadows inside burn away, and a 影の核 inside it is worn down, more the
   bigger the ring (小・中・大・特大) and half again with gold in the line. Three places hold a core (the station square, the
   shopping street, the middle of the slope); break all three before dawn (five minutes) and a child held there comes home.
   The light comes back from riding, from tricks landed, rails and manuals; the shadows give light and 経験 when they burn,
   and at each level she picks one of three powers for the night. Here she jumps twice (the second jump in a burst of light),
   and the roofs bear her: up the slope of a tiled roof, along its ridge as a rail, from roof to roof round a block.
   Fall (the hearts gone) and she wakes back at the base with the shards she found; the base's rooms make the next night
   easier. SAVE.flags.run marks a night out; a save made out there wakes up back at the base.
   Five places in all (the harbour and the beach too); each night three of them hold a core, and the more children are home
   the harder the night. A place made clean is safe for a while, then the shadows creep back into it, one place at a time:
   ring it again to stop them, or its core comes back (never the end of the night). Its records are kept on this phone only. ---------- */
const RUN_AREAS=[{id:'eki',name:'駅前',x:61,z:186,r:30,hp:6},{id:'saka',name:'中央の坂',x:0,z:90,r:34,hp:8},{id:'shop',name:'商店街',x:-60,z:-20,r:38,hp:10},
  {id:'port',name:'港',x:-80,z:243,r:28,hp:8},{id:'hama',name:'浜',x:40,z:243,r:28,hp:8}];
// the children held out there; each one comes home when a night's three cores are broken
const NEST_FREED=['（……ありがとう、おねえちゃん。やっと、海の音が聞こえる）','（まっくらだったの。……灯り、あったかいね）','（ラムネのビー玉、まだ持ってるよ。……帰れるかな）',
  '（お祭りの太鼓が、ずっと遠くで鳴ってた。……もうすぐ、帰れる）','（坂の上から、灯台が見えた。……ありがとう）'];
const KIDS=NEST_FREED.length;
function D2_last(){const D=d2();D.last=SAVE.day;save();}
const RUN_START=[0,150,Math.PI],RUN_DUR=300,RUN_SAFE=90,RUN_ERODE=45,RUN_STEP=0.5,RUN_GAP=14,RUN_CLOSE=2.6,RUN_MAX=900;
const RUN_FOE={normal:{hp:1,sp:3.2,s:1,xp:10},fast:{hp:1,sp:5,s:0.9,xp:14},big:{hp:3,sp:2.2,s:1.6,xp:40},red:{hp:1,sp:2.8,s:1.05,xp:25}};
const RUN={on:false,go:false,end:false,t:0,night:0,trail:[],foes:[],cores:[],fx:[],deco:[],light:100,max:100,hearts:5,inv:0,xp:0,lv:1,lvQ:0,picking:false,kills:0,
  spawnT:0,hudT:0,jumps:0,maxJ:1,spd:1,life:10,perk:{},auraT:0,orbs:[],core:null,halo:null,head:null,g:null};
const runSpd=()=>RUN.go?RUN.spd:1;
const runNeed=lv=>40+lv*35;
// the powers of the night: a name, what it does, how many times it can be taken, and what it changes
const RUN_PERKS={
  heart:{name:'ハート＋1',info:'たえられる回数がひとつ増えて、ひとつ回復',max:3,fn:()=>{RUN.hmax++;RUN.hearts=Math.min(RUN.hmax,RUN.hearts+1);}},
  wheel:{name:'光の車輪',info:'速く走っているあいだは、ぶつかった影が消える',max:1},
  burst:{name:'光の爆発',info:'結界がつながると、まわりの影も吹き飛ぶ',max:3},
  bolt:{name:'光の落雷',info:'技を決めて着地すると、近くの影に雷が落ちる',max:3},
  orbit:{name:'ランタン旋回',info:'光の玉がまわりを回って、ふれた影を消す',max:3,fn:()=>runOrbs()},
  boost:{name:'ブースト',info:'いちばん速い速さが上がる',max:3,fn:()=>{RUN.spd+=0.12;}},
  jump:{name:'光のジャンプ',info:'空中でもう一回跳べる',max:2,fn:()=>{RUN.maxJ++;}},
  life:{name:'長い光',info:'光の線が長く残る',max:3,fn:()=>{RUN.life+=4;}},
  grind:{name:'グラインドチャージ',info:'手すりやマニュアルで、光が2倍たまる',max:1},
  aura:{name:'灯台の加護',info:'ときどき、まわりの影をまとめて浄化する',max:3},
  vessel:{name:'光の器',info:'光ゲージが大きくなって、満タンになる',max:2,fn:()=>{RUN.max+=40;RUN.light=RUN.max;}}};
const perkN=k=>RUN.perk[k]||0;
// the roofs she can ride: the tiled gables (a ridge along the face), the hipped ones, and the flat tops; the shops are gables too
const RUN_ROOFS=[];
function runRoofs(){if(RUN_ROOFS.length)return;
  const add=(b,kind,W,D,rh)=>{const s=Math.sin(b.yaw),c=Math.cos(b.yaw);RUN_ROOFS.push({b,kind,W,D,rh,s,c,x0:b.x0-1,x1:b.x1+1,z0:b.z0-1,z1:b.z1+1});
    if(kind==='g'&&W>3)RAILS.push({x0:b.cx-c*(W/2-0.4),z0:b.cz+s*(W/2-0.4),x1:b.cx+c*(W/2-0.4),z1:b.cz-s*(W/2-0.4),top:b.top+rh+0.06,run:true});};
  for(const e of gables)add(e.b,'g',e.W,e.D,1.3+e.D*0.12);for(const e of hips)add(e.b,'h',e.W,e.D,1.6);for(const e of parapets)add(e.b,'f',e.W,e.D,0);
  for(const id in SHOPS){const b=SHOPS[id];if(!RUN_ROOFS.some(r=>r.b===b))add(b,b.floors<3?'g':'f',along(b),deep(b),1.4+deep(b)*0.12);}}
// the height of the roofs at (x, z), if one is there no higher than she can step up to
function runRoof(x,z,y){let g=-1e9;
  for(const r of RUN_ROOFS){if(x<r.x0||x>r.x1||z<r.z0||z>r.z1)continue;const dx=x-r.b.cx,dz=z-r.b.cz,a=dx*r.c-dz*r.s,p=dx*r.s+dz*r.c;let h=-1e9;
    if(r.kind==='g'){if(Math.abs(a)<=r.W*0.55&&Math.abs(p)<=r.D*0.56)h=r.b.top+r.rh*(1-Math.abs(p)/(r.D*0.56));}
    else if(r.kind==='h'){const k=Math.max(Math.abs(a)/(r.W*0.55),Math.abs(p)/(r.D*0.55));if(k<=1)h=r.b.top+r.rh*(1-k);}
    else if(Math.abs(a)<=r.W/2&&Math.abs(p)<=r.D/2)h=r.b.top;
    if(h>g&&h<=y+STEP)g=h;}
  return g;}
// the second jump (and a third, with the power): a burst of light under the board
function runJump(){if(!RUN.go||RUN.end||RUN.jumps>=RUN.maxJ||P.grind)return false;RUN.jumps++;P.vy=9;TRICK.airT=0;
  sparks(new THREE.Vector3(P.x,P.y,P.z),16,'#bfe6ff',5,0.1);runWave(P.x,P.y+0.1,P.z,'#bfe6ff',3);buzz('light',true);return true;}
function runBuild(){if(RUN.g)return;const g=new THREE.Group();scene.add(g);RUN.g=g;
  const rib=(w,col,gold)=>{const geo=new THREE.BufferGeometry();geo.setAttribute('position',new THREE.BufferAttribute(new Float32Array(RUN_MAX*6),3));geo.setAttribute('color',new THREE.BufferAttribute(new Float32Array(RUN_MAX*6),3));
    const idx=[];for(let i=0;i<RUN_MAX-1;i++){const a=i*2;idx.push(a,a+1,a+2,a+1,a+3,a+2);}geo.setIndex(idx);
    const m=new THREE.Mesh(geo,new THREE.MeshBasicMaterial({vertexColors:true,transparent:true,blending:THREE.AdditiveBlending,depthWrite:false,side:THREE.DoubleSide,fog:false}));m.frustumCulled=false;
    m.userData={w,col:new THREE.Color(col),gold:new THREE.Color(gold)};g.add(m);return m;};
  RUN.halo=rib(1.5,'#2a5a9a','#8a5a18');RUN.core=rib(0.32,'#bfe6ff','#ffe6a0');RUN.head=glow('#9fd4ff',0,0,0,2.2);}
// the line lies flat across the way she went (up the slope of a roof, through the air after a jump)
function runRibbon(m){const T=RUN.trail,pos=m.geometry.attributes.position.array,col=m.geometry.attributes.color.array,n=T.length,w=m.userData.w/2;
  for(let i=0;i<n;i++){const p=T[i],q=T[Math.min(n-1,i+1)],o=T[Math.max(0,i-1)],dx=q.x-o.x,dz=q.z-o.z,l=Math.hypot(dx,dz)||1,nx=-dz/l*w,nz=dx/l*w;
    const age=RUN.t-p.t,k=clamp((RUN.life-age)/0.4,0,1)*(age<0.3?1.6:1),j=i*6,c=p.g?m.userData.gold:m.userData.col;
    pos[j]=p.x+nx;pos[j+1]=p.y;pos[j+2]=p.z+nz;pos[j+3]=p.x-nx;pos[j+4]=p.y;pos[j+5]=p.z-nz;
    for(let e=0;e<2;e++){col[j+e*3]=c.r*k;col[j+e*3+1]=c.g*k;col[j+e*3+2]=c.b*k;}}
  m.geometry.setDrawRange(0,Math.max(0,n-1)*6);m.geometry.attributes.position.needsUpdate=true;m.geometry.attributes.color.needsUpdate=true;}
// the cores: a black heap with red eyes of light, breathing, smaller as it wears down
// tonight's three places: the first night the three nearest the start, then any three of the five
function runAreas(){if(!RUN.night)return RUN_AREAS.slice(0,3);return RUN_AREAS.slice().sort(()=>rnd()-0.5).slice(0,3);}
function runCoreMake(A){const g=new THREE.Group(),blk=new THREE.MeshBasicMaterial({color:'#0b0b0d'}),y=G(A.x,A.z)+paveY(A.x,A.z);
  const c=new THREE.Mesh(new THREE.SphereGeometry(1.8,14,10),blk);c.position.y=1.8;g.add(c);
  for(let k=0;k<9;k++){const a=k/9*TAU,r=1.5+(k%3)*0.5,m=new THREE.Mesh(new THREE.SphereGeometry(0.55+(k%4)*0.22,10,8),blk);m.position.set(Math.cos(a)*r,0.4+(k%2)*0.4,Math.sin(a)*r);g.add(m);}
  const glows=[];for(let k=0;k<4;k++){const s=glow('#ff3020',0,0,0,k?1.2:3.6);scene.remove(s);s.visible=true;g.add(s);s.position.set(k?Math.cos(k*2)*1.3:0,k?1.1+k*0.3:2,k?Math.sin(k*2)*1.3:0);glows.push(s);}
  const pil=new THREE.Mesh(new THREE.CylinderGeometry(0.6,1.4,40,12,1,true),new THREE.MeshBasicMaterial({color:'#7a2030',transparent:true,opacity:0.25,blending:THREE.AdditiveBlending,depthWrite:false,side:THREE.DoubleSide}));
  pil.position.y=20;g.add(pil);   // a dim red column over it, seen from across the town
  const hp=Math.round(A.hp*(1+0.2*RUN.night));g.position.set(A.x,y,A.z);RUN.g.add(g);return{a:A,g,glows,pil,hp,max:hp,done:false,spawnT:0,safe:0,ero:0,deco:[]};}
function runEnter(){runBuild();runRoofs();for(const c of RUN.cores)RUN.g.remove(c.g);for(const d of RUN.deco)RUN.g.remove(d);RUN.deco.length=0;
  const lv=k=>hqLv(k);RUN.max=100+20*(lv('lamp')-1);RUN.hmax=DRONE.maxHp;
  Object.assign(RUN,{on:true,go:false,end:false,t:0,light:RUN.max,hearts:RUN.hmax,inv:0,xp:0,lv:1,lvQ:0,picking:false,kills:0,spawnT:2,jumps:0,maxJ:1,spd:1,life:10,perk:{},auraT:0,
    night:d2().nest||0,bigRing:0,bigHit:0});
  RUN.trail.length=0;runClearFoes();runOrbs();RUN.cores=runAreas().map(runCoreMake);runTint();RUN.g.visible=true;SAVE.flags.run=1;renderHUD();}
function runExit(){RUN.on=false;RUN.go=false;runClearFoes();for(const f of RUN.fx)RUN.g.remove(f.m);RUN.fx.length=0;RUN.trail.length=0;RUN.perk={};runOrbs();
  if(RUN.g)RUN.g.visible=false;if(RUN.head)RUN.head.visible=false;SAVE.flags.run=0;$('hurt').style.opacity=0;renderHUD();}
function runClearFoes(){for(const f of RUN.foes){world.remove(f.g);f.eye.visible=false;f.aura.visible=false;MIR_POOL.push({h:f.h,eye:f.eye,aura:f.aura});}RUN.foes.length=0;}
// somewhere open near (x, z): on the ground, out of the sea, not inside a building
function runSpot(x0,z0,r0,r1){for(let k=0;k<12;k++){const a=rnd()*TAU,r=r0+rnd()*(r1-r0),x=clamp(x0+Math.cos(a)*r,-225,225),z=clamp(z0+Math.sin(a)*r,-200,COAST_Z+3),y=G(x,z);
    if(y>SEA_Y+0.3&&!hits(x,z,0.5,y+0.2)&&Math.hypot(x-P.x,z-P.z)>9)return[x,z];}return null;}
function runAdd(kind,x,z){const F=RUN_FOE[kind],{h,eye,aura}=mirFigure(),y=G(x,z)+paveY(x,z);h.g.scale.setScalar(F.s);h.g.position.set(x,y-1.6*F.s,z);h.g.rotation.set(0,0,0);world.add(h.g);
  eye.material.color.set(kind==='big'?'#ff6020':'#ff3020');eye.scale.setScalar(0.9*F.s);aura.visible=kind==='red';if(aura.visible){aura.material.color.set('#ff2a2a');aura.scale.setScalar(2.6);}
  const f={h,g:h.g,kind,hp:F.hp,sp:F.sp*(0.9+rnd()*0.2)*(1+0.05*RUN.night),up:0,gone:0,fade:0,stun:0,eye,aura};RUN.foes.push(f);return f;}
function runSpawn(){const t=RUN.t+RUN.night*15,live=RUN.cores.filter(c=>!c.done),kind=t>150&&rnd()<0.12?'big':t>90&&rnd()<0.18?'red':t>45&&rnd()<0.25?'fast':'normal';
  const c=live.length&&rnd()<0.6?live[rnd()*live.length|0]:null,at=c?runSpot(c.a.x,c.a.z,6,c.a.r):runSpot(P.x+Math.sin(P.yaw)*18,P.z+Math.cos(P.yaw)*18,0,12);
  if(!at)return;runAdd(kind,...at);if(kind==='red'&&!RUN.redSaid){RUN.redSaid=true;toast('赤い影は、光の線を切る！',true);}}
function runPop(t,sub){TRICK.name=t;TRICK.sub=sub||'';TRICK.shown=1.8;trickHUD();}
// a ring of light going out over the ground (a jump, a burst, the lighthouse's blessing)
function runWave(x,y,z,col,R){const w=new THREE.Mesh(new THREE.RingGeometry(0.8,1,48),new THREE.MeshBasicMaterial({color:col,transparent:true,opacity:0.6,blending:THREE.AdditiveBlending,depthWrite:false,side:THREE.DoubleSide,fog:false}));
  w.rotation.x=-Math.PI/2;w.position.set(x,y,z);RUN.g.add(w);RUN.fx.push({m:w,t:0,dur:0.5,kind:'wave',R});}
function runKill(f,p){if(f.gone)return;f.gone=1;RUN.kills++;RUN.light=Math.min(RUN.max,RUN.light+3);runXP(RUN_FOE[f.kind].xp);sparks((p||f.g.position).clone().setY(f.g.position.y+1),12,'#cfeeff',6,0.1);}
function runXP(n){RUN.xp+=n;while(RUN.xp>=runNeed(RUN.lv)){RUN.xp-=runNeed(RUN.lv);RUN.lv++;RUN.lvQ++;}}
function runHit(f,d){f.hp-=d;if(f.hp<=0)runKill(f);else{f.stun=1;sparks(f.g.position.clone().setY(f.g.position.y+1.5),10,'#cfeeff',5,0.1);}}
// the ring closed: the size of it, the shadows and the cores inside
function runRing(poly){let A=0,cx=0,cz=0;for(let k=0;k<poly.length;k++){const a=poly[k],b=poly[(k+1)%poly.length];A+=a.x*b.z-b.x*a.z;cx+=a.x;cz+=a.z;}A=Math.abs(A)/2;cx/=poly.length;cz/=poly.length;
  if(A<10)return false;
  const inside=(x,z)=>{let c=false;for(let a=0,b=poly.length-1;a<poly.length;b=a++){const p=poly[a],q=poly[b];if((p.z>z)!==(q.z>z)&&x<(q.x-p.x)*(z-p.z)/(q.z-p.z)+p.x)c=!c;}return c;};
  const tier=A<80?0:A<300?1:A<900?2:3,gold=poly.some(p=>p.g)?1.5:1,size=['小','中','大','特大'][tier];let hit=0,cores=0;
  for(const f of RUN.foes){if(f.gone||f.up<0.5||!inside(f.g.position.x,f.g.position.z))continue;runHit(f,tier>=1?2:1);hit++;}
  for(const c of RUN.cores)if(c.done&&c.ero>0&&inside(c.a.x,c.a.z)){runHold(c);cores++;runPop(`${c.a.name}の影を止めた`,'しばらくは、だいじょうぶ');}
  for(const c of RUN.cores){if(c.done||!inside(c.a.x,c.a.z))continue;const d=(tier+1)*DRONE.dmg*gold;c.hp-=d;cores++;runXP(Math.round(d*10));
    const p=c.g.position.clone();p.y+=2;sparks(p,30,'#ffe2a0',9,0.16);buzz('heavy',true);if(c.hp<=0)runPurify(c);else runPop(`影の核に ${d%1?d.toFixed(1):d} ダメージ`,`${c.a.name}　のこり ${Math.ceil(c.hp)}`);}
  if(perkN('burst')){const R=5+2*perkN('burst');for(const f of RUN.foes)if(!f.gone&&f.up>=0.5&&Math.hypot(f.g.position.x-P.x,f.g.position.z-P.z)<R){runKill(f);hit++;}runWave(P.x,P.y+0.1,P.z,'#ffe6a0',R);}
  runXP(tier*8);RUN.bigRing=Math.max(RUN.bigRing,A);
  // the light rises from the whole ring: a wall of it along the line, and the ground inside flashes
  const ym=poly.reduce((s,p)=>s+p.y,0)/poly.length,sh=new THREE.Shape(poly.map(p=>new THREE.Vector2(p.x,-p.z)));
  const fill=new THREE.Mesh(new THREE.ShapeGeometry(sh),new THREE.MeshBasicMaterial({color:'#7fc8ff',transparent:true,opacity:0.45,blending:THREE.AdditiveBlending,depthWrite:false,depthTest:false,side:THREE.DoubleSide,fog:false}));
  fill.rotation.x=-Math.PI/2;fill.position.y=ym+0.1;RUN.g.add(fill);RUN.fx.push({m:fill,t:0,dur:0.9,kind:'fill'});
  const wp=[],wi=[];poly.forEach((p,k)=>{wp.push(p.x,p.y-0.05,p.z,p.x,p.y+1.2,p.z);if(k){const a=(k-1)*2;wi.push(a,a+1,a+2,a+1,a+3,a+2);}});const a=(poly.length-1)*2;wi.push(a,a+1,0,a+1,1,0);
  const wg=new THREE.BufferGeometry();wg.setAttribute('position',new THREE.Float32BufferAttribute(wp,3));wg.setIndex(wi);
  const wall=new THREE.Mesh(wg,new THREE.MeshBasicMaterial({color:gold>1?'#ffe2a0':'#a8dcff',transparent:true,opacity:0.7,blending:THREE.AdditiveBlending,depthWrite:false,side:THREE.DoubleSide,fog:false}));RUN.g.add(wall);RUN.fx.push({m:wall,t:0,dur:1.1,kind:'wall'});
  RUN.bigHit=Math.max(RUN.bigHit,hit);
  if(!cores)runPop(`結界（${size}）`,hit?`${hit}体 浄化${gold>1?'　金の線':''}`:'');
  if(hit||cores)sfx.boom(0.6);buzz(hit||cores?'heavy':'light',true);renderHUD();return true;}
// a core broken: the place comes back. Lamps light round it, the ground there takes on a warm light, and the whole town a
// little of its colour
function runPurify(c){c.done=true;c.safe=RUN_SAFE;c.ero=0;const p=c.g.position.clone();p.y+=1.5;boom(p);for(let k=0;k<5;k++)setTimeout(()=>sparks(p.clone().add(new THREE.Vector3(rnd()*4-2,rnd()*3,rnd()*4-2)),20,'#ffe2a0',8,0.14),k*160);
  c.g.visible=false;runXP(80);RUN.light=RUN.max;for(const f of RUN.foes)if(!f.gone&&Math.hypot(f.g.position.x-c.a.x,f.g.position.z-c.a.z)<c.a.r)runKill(f);
  const A=c.a,ring=[],R=A.r*0.9,N=24,M=6;
  // the warm ground: a disc that follows the slope
  const pos=[],idx=[];for(let i=0;i<=M;i++)for(let j=0;j<N;j++){const r=R*i/M,a=j/N*TAU,x=A.x+Math.cos(a)*r,z=A.z+Math.sin(a)*r;pos.push(x,G(x,z)+paveY(x,z)+0.12,z);}
  for(let i=0;i<M;i++)for(let j=0;j<N;j++){const a=i*N+j,b=i*N+(j+1)%N,c2=a+N,d=b+N;idx.push(a,c2,b,b,c2,d);}
  const geo=new THREE.BufferGeometry();geo.setAttribute('position',new THREE.Float32BufferAttribute(pos,3));geo.setIndex(idx);
  const disc=new THREE.Mesh(geo,new THREE.MeshBasicMaterial({color:'#ffb860',transparent:true,opacity:0.16,blending:THREE.AdditiveBlending,depthWrite:false,side:THREE.DoubleSide}));disc.userData.o0=0.16;RUN.g.add(disc);RUN.deco.push(disc);c.deco.push(disc);
  for(let k=0;k<10;k++){const a=k/10*TAU,x=A.x+Math.cos(a)*R*0.7,z=A.z+Math.sin(a)*R*0.7,l=glow('#ffd9a0',x,G(x,z)+3.4,z,2.6);scene.remove(l);l.visible=true;l.userData.o0=l.material.opacity;RUN.g.add(l);RUN.deco.push(l);c.deco.push(l);}
  runTint();
  toast(`${A.name}を浄化した！ 色と灯りが、少しもどってきた`,true);buzz('heavy',true);
  if(RUN.cores.every(o=>o.done))setTimeout(()=>runFinish(true),1600);renderHUD();}
// the town's colour, a little more for each place made clean
function runTint(){const n=RUN.cores.filter(o=>o.done).length;canvas.style.filter=`saturate(${0.28+0.22*n}) sepia(${0.3-0.08*n}) hue-rotate(-12deg) brightness(1.12)`;}
// the shadows creeping back: once a clean place has had its while, they come back into it (one place at a time). Its lamps
// fade as they do; a ring round it stops them, and if they get all the way its core is back, half worn already
function runErode(dt){if(RUN.cores.every(c=>c.done))return;const done=RUN.cores.filter(c=>c.done);let e=done.find(c=>c.ero>0);
  for(const c of done)if(c!==e)c.safe-=dt;
  if(!e){e=done.filter(c=>c.safe<=0).sort((a,b)=>a.safe-b.safe)[0];if(!e)return;e.ero=0.001;toast(`${e.a.name}に、影がもどりはじめた！ もう一度囲めば止まる`,true);buzz('heavy',true);}
  e.ero+=dt/RUN_ERODE;for(const d of e.deco)d.material.opacity=d.userData.o0*(1-0.8*e.ero);
  if(e.ero>=1){e.done=false;e.ero=0;e.hp=Math.ceil(e.max/2);e.g.visible=true;for(const d of e.deco){RUN.g.remove(d);RUN.deco.splice(RUN.deco.indexOf(d),1);}e.deco.length=0;
    runTint();toast(`${e.a.name}が、影にのみこまれた。核がもどってきた`,true);buzz('heavy',true);renderHUD();}}
function runHold(c){c.ero=0;c.safe=RUN_SAFE;for(const d of c.deco)d.material.opacity=d.userData.o0;}
// the orbiting lights of ランタン旋回
function runOrbs(){const n=perkN('orbit');while(RUN.orbs.length<n){const s=glow('#ffe6a0',0,0,0,1.4);scene.remove(s);s.visible=true;if(RUN.g)RUN.g.add(s);RUN.orbs.push(s);}
  while(RUN.orbs.length>n){const s=RUN.orbs.pop();if(s.parent)s.parent.remove(s);}}
// a jump landed: light back for its tricks, and with 光の落雷, lightning onto the nearest shadows
function runTrickLand(clean,b){if(!clean||b<=0){renderHUD();return;}RUN.light=Math.min(RUN.max,RUN.light+b*12);RUN.inv=Math.max(RUN.inv,0.5);
  TRICK.sub=(TRICK.sub?TRICK.sub+'　':'')+`光 +${Math.round(b*12)}`;TRICK.shown=Math.max(TRICK.shown,1.4);trickHUD();
  for(let k=0;k<perkN('bolt');k++){const t=RUN.foes.filter(f=>!f.gone&&f.up>=0.5).sort((a,c)=>Math.hypot(a.g.position.x-P.x,a.g.position.z-P.z)-Math.hypot(c.g.position.x-P.x,c.g.position.z-P.z))[0];
    if(!t||Math.hypot(t.g.position.x-P.x,t.g.position.z-P.z)>20)break;const p=t.g.position;
    const col=new THREE.Mesh(new THREE.CylinderGeometry(0.35,0.35,30,8,1,true),new THREE.MeshBasicMaterial({color:'#fff1c8',transparent:true,opacity:0.9,blending:THREE.AdditiveBlending,depthWrite:false,fog:false}));
    col.position.set(p.x,p.y+15,p.z);RUN.g.add(col);RUN.fx.push({m:col,t:0,dur:0.4,kind:'bolt'});runKill(t);}
  renderHUD();}
// the lantern's flash out here: the shadows near her stand stunned
function runFlash(R){if(!RUN.go)return;for(const f of RUN.foes)if(!f.gone&&Math.hypot(f.g.position.x-P.x,f.g.position.z-P.z)<R)f.stun=Math.max(f.stun,2.5);}
// a power at each level: three of them to pick from (the first before setting out)
async function runPick(){const keys=Object.keys(RUN_PERKS).filter(k=>perkN(k)<RUN_PERKS[k].max).sort(()=>rnd()-0.5).slice(0,3);
  if(!keys.length){RUN.lvQ=0;return;}
  const i=await askP('',RUN.lv<=1&&!RUN.t?'最初の力を、ひとつえらぶ':`レベル ${RUN.lv - RUN.lvQ + 1}！ 力をひとつえらぶ`,keys.map(k=>`${RUN_PERKS[k].name}${perkN(k)?` ${perkN(k)+1}`:''}　—　${RUN_PERKS[k].info}`));
  const k=keys[i]||keys[0];RUN.perk[k]=perkN(k)+1;if(RUN_PERKS[k].fn)RUN_PERKS[k].fn();RUN.lvQ--;toast(`${RUN_PERKS[k].name}を手に入れた`,false);renderHUD();}
function runHUD(tr){tr.hidden=false;tr.innerHTML='';const b=document.createElement('b');b.textContent='裏海街の夜';const s=document.createElement('span');s.className='step';
  const left=RUN.cores.filter(c=>!c.done).map(c=>c.a.name);
  const ero=RUN.cores.find(c=>c.done&&c.ero>0);
  s.textContent=!RUN.go?'……':ero?`${ero.a.name}に影がもどってくる！ 囲んで止めろ（${Math.round(ero.ero*100)}%）`:left.length?`走ると光の線が残る。影の核（赤い柱）を線で囲んでこわせ。のこり：${left.join('・')}`:'夜明けだ';
  const m=document.createElement('span');m.className='meter';const tl=Math.max(0,Math.ceil(RUN_DUR-RUN.t)),lk=Math.round(RUN.light/RUN.max*10);
  m.textContent=`のこり ${tl/60|0}:${String(tl%60).padStart(2,'0')}　${'♥'.repeat(Math.max(0,RUN.hearts))}${'♡'.repeat(Math.max(0,RUN.hmax-RUN.hearts))}　光 ${'■'.repeat(lk)}${'□'.repeat(10-lk)}　Lv${RUN.lv}（${Math.floor(RUN.xp/runNeed(RUN.lv)*100)}%）　浄化 ${RUN.cores.filter(c=>c.done).length}/${RUN.cores.length}`;
  tr.append(b,s,m);}
// the little map: the cores (red, gold once broken), the line, the shadows
function runMap(toM){for(const c of RUN.cores){const [x,y]=toM(c.a.x,c.a.z),W=mapc.width,px=clamp(x,8,W-8),py=clamp(y,8,W-8);
    mg.fillStyle=c.done?(c.ero>0&&Math.sin(clock*8)>0?'#a050d0':'#ffc860'):'#d02838';mg.beginPath();mg.arc(px,py,c.done?5:7,0,TAU);mg.fill();mg.strokeStyle='#fff';mg.lineWidth=1.5;mg.stroke();}
  mg.strokeStyle='#9fd4ff';mg.lineWidth=2;mg.beginPath();RUN.trail.forEach((p,k)=>{const [x,y]=toM(p.x,p.z);k?mg.lineTo(x,y):mg.moveTo(x,y);});mg.stroke();
  for(const f of RUN.foes){if(f.gone)continue;const [x,y]=toM(f.g.position.x,f.g.position.z);mg.fillStyle=f.kind==='red'?'#ff8070':'#ff4030';mg.beginPath();mg.arc(x,y,f.kind==='big'?3.5:2.2,0,TAU);mg.fill();}}
// a new point on the line: does it close a ring? (near an old point, or the newest stretch crossing an old one)
function runClose(){const T=RUN.trail,n=T.length-1,p=T[n],o=T[n-1];if(n<RUN_GAP)return;
  for(let i=0;i<=n-RUN_GAP;i++){if(Math.hypot(T[i].x-p.x,T[i].z-p.z)<RUN_CLOSE||(i<n-RUN_GAP&&mirCross(o,p,T[i],T[i+1]))){if(runRing(T.slice(i)))T.splice(0,n);return;}}}
function runHurt(f){if(RUN.inv>0||trickSafe())return;RUN.inv=1.3;RUN.hearts--;buzz('heavy',true);P.v*=0.4;
  if(f.kind==='big'){const kx=P.x-f.g.position.x,kz=P.z-f.g.position.z,kl=Math.hypot(kx,kz)||1;P.x+=kx/kl*2;P.z+=kz/kl*2;f.stun=0.8;}else f.gone=1;
  renderHUD();if(RUN.hearts<=0){runFinish(false);return;}toast('冷たい手が、ふれた！');}
function updateRun(dt){
  if(!RUN.on){if(SAVE.flags.run&&state==='play'&&!ST.run){SAVE.flags.run=0;runEvent({id:'run_lost',once:false,script:[['fade','out'],['ura',false],['warp',HQ_X+HQ_IN[0],HQ_IN[1],HQ_IN[2]],['fade','in']]});}return;}
  const busy=!!(DLG||modal||ST.run);
  for(const f of RUN.fx.slice()){f.t+=dt;const k=Math.min(1,f.t/f.dur);
    if(f.kind==='wall'){f.m.scale.y=1+k*5;f.m.material.opacity=0.7*(1-k);}else if(f.kind==='wave'){f.m.scale.setScalar(1+k*(f.R||6));f.m.material.opacity=0.6*(1-k);}else if(f.kind==='bolt')f.m.material.opacity=0.9*(1-k);else f.m.material.opacity=0.45*(1-k);
    if(k>=1){RUN.g.remove(f.m);f.m.geometry.dispose();f.m.material.dispose();RUN.fx.splice(RUN.fx.indexOf(f),1);}}
  for(const c of RUN.cores){if(c.done)continue;const k=c.hp/c.max;c.g.scale.setScalar(0.6+0.4*k+Math.sin(clock*3)*0.04);c.glows.forEach((s,j)=>{s.material.opacity=(0.6+0.4*Math.sin(clock*(4+j)+j))*(0.4+0.6*k);});c.pil.material.opacity=0.18+0.08*Math.sin(clock*2);}
  if(RUN.head){RUN.head.visible=RUN.go&&!P.foot;RUN.head.position.set(P.x,P.y+0.3,P.z);}
  if(RUN.go&&!busy&&!RUN.end&&RUN.lvQ>0&&!RUN.picking&&!ST.run){RUN.picking=true;runPick().then(()=>{RUN.picking=false;});}
  if(RUN.go&&!busy&&!RUN.end){RUN.t+=dt;RUN.inv-=dt;if(!P.air)RUN.jumps=0;
    // the light: back a little while she rides, more on a rail or in a manual
    const gm=perkN('grind')?2:1;if(!P.foot&&!P.air)RUN.light+=dt*(P.grind?12*gm:P.man?8*gm:2.5);RUN.light=Math.min(RUN.max,RUN.light);
    // the line: a point every half metre while she rides and has light (in the air too); the old end fading away
    const T=RUN.trail,l=T[T.length-1];
    if(!P.foot&&RUN.light>0&&(!l||Math.hypot(P.x-l.x,P.z-l.z)>RUN_STEP)){if(l&&Math.hypot(P.x-l.x,P.z-l.z)>4)T.length=0;
      T.push({x:P.x,y:P.y+0.08,z:P.z,t:RUN.t,g:P.grind||P.man||P.air&&(P.trick||TRICK.bank>0)?1:0});RUN.light=Math.max(0,RUN.light-0.25);runClose();
      if(RUN.light<=0&&!RUN.dry){RUN.dry=true;toast('光が切れた！ 技を決めるか、手すりをすべって光をためろ',true);}}
    if(RUN.light>20)RUN.dry=false;
    if(P.grind)for(const p of T)if((p.ext||0)<4){p.t+=dt;p.ext=(p.ext||0)+dt;}
    while(T.length&&RUN.t-T[0].t>RUN.life)T.shift();while(T.length>RUN_MAX)T.shift();
    RUN.spawnT-=dt;const alive=RUN.foes.filter(f=>!f.gone).length,want=Math.min(18+2*RUN.night,6+RUN.night+Math.floor(RUN.t/20));
    if(RUN.spawnT<=0&&alive<want){runSpawn();RUN.spawnT=0.9+rnd()*0.6;}
    if(perkN('aura')){RUN.auraT-=dt;if(RUN.auraT<=0){RUN.auraT=12;const R=6+3*perkN('aura');for(const f of RUN.foes)if(!f.gone&&f.up>=0.5&&Math.hypot(f.g.position.x-P.x,f.g.position.z-P.z)<R)runKill(f);runWave(P.x,P.y+0.1,P.z,'#ffe2a0',R);}}
    runErode(dt);if(RUN.t>=RUN_DUR)runFinish(false);}
  runRibbon(RUN.core);runRibbon(RUN.halo);
  RUN.orbs.forEach((s,k)=>{const a=clock*2.6+k/RUN.orbs.length*TAU;s.position.set(P.x+Math.cos(a)*2.6,P.y+1,P.z+Math.sin(a)*2.6);s.material.opacity=0.85;
    if(RUN.go&&!busy)for(const f of RUN.foes)if(!f.gone&&f.up>=0.5&&Math.hypot(f.g.position.x-s.position.x,f.g.position.z-s.position.z)<1.1)runKill(f);});
  const fast=perkN('wheel')&&!P.foot&&P.v>8;
  for(const f of RUN.foes.slice()){const p=f.g.position,S=RUN_FOE[f.kind].s;
    if(f.gone){f.fade+=dt*2;const k=Math.min(1,f.fade);f.g.scale.set(S*(1-k*0.6),S*(1-k*0.9),S*(1-k*0.6));f.eye.visible=false;f.aura.visible=false;
      if(k>=1){world.remove(f.g);MIR_POOL.push({h:f.h,eye:f.eye,aura:f.aura});RUN.foes.splice(RUN.foes.indexOf(f),1);}continue;}
    const gy=G(p.x,p.z)+paveY(p.x,p.z);f.stun-=dt;
    if(f.up<1){f.up=Math.min(1,f.up+dt*0.8);p.y=lerp(gy-1.6*S,gy,f.up);poseHuman(f.h,'stand',dt,{});}
    else if(f.stun>0){p.y=gy;poseHuman(f.h,'stand',dt,{});}
    else if(!busy&&!RUN.end&&RUN.go){let dx=P.x-p.x,dz=P.z-p.z;const d=Math.hypot(dx,dz)||1;dx/=d;dz/=d;
      if(f.kind==='red'){const T=RUN.trail;for(let j=T.length-1;j>=0;j--)if(Math.hypot(T[j].x-p.x,T[j].z-p.z)<0.9&&Math.abs(T[j].y-gy)<2){T.splice(0,j+1);sparks(new THREE.Vector3(p.x,gy+0.2,p.z),10,'#ff6a5a',4,0.08);break;}}
      for(const o of RUN.foes)if(o!==f&&!o.gone){const ex=p.x-o.g.position.x,ez=p.z-o.g.position.z,e=Math.hypot(ex,ez);if(e<1.4&&e>0){dx+=ex/e*0.6;dz+=ez/e*0.6;}}
      const m=Math.hypot(dx,dz)||1;p.x+=dx/m*f.sp*dt;p.z+=dz/m*f.sp*dt;p.y=G(p.x,p.z)+paveY(p.x,p.z);f.g.rotation.y=Math.atan2(P.x-p.x,P.z-p.z);poseHuman(f.h,'walk',dt,{rate:3.8});
      // a touch: only from the same height (up on a roof she is out of their reach)
      if(d<0.75+0.35*S&&Math.abs(P.y-p.y)<1.6){if(fast)runKill(f);else runHurt(f);}}
    f.eye.visible=true;f.eye.position.set(p.x,p.y+1.62*S,p.z);f.eye.material.opacity=0.7+0.3*Math.sin(clock*7+p.x);
    if(f.aura.visible){f.aura.position.set(p.x,p.y+1.1*S,p.z);f.aura.material.opacity=0.35+0.15*Math.sin(clock*4+p.z);}}
  $('hurt').style.opacity=RUN.go?Math.max(RUN.inv>0.7?0.5:0,RUN.hearts===1?0.3+0.1*Math.sin(clock*5):0):0;
  RUN.hudT-=dt;if(RUN.hudT<=0){RUN.hudT=0.25;renderHUD();}}
// the end of the night: all three broken (a child comes home, and it is morning), or dawn first, or the hearts gone (back to
// the base, the shards kept)
function runFinish(won){if(RUN.end)return;RUN.end=true;for(const f of RUN.foes)f.gone=1;RUN.trail.length=0;
  const D=d2(),n=RUN.cores.filter(c=>c.done).length,got=Math.floor(RUN.kills/3)+n*5+(won?10:0),i=D.nest||0;SAVE.shards=shards()+got;if(won)SAVE.money+=300+i*100;save();
  const rec=runRecord(won),sum=`浄化した場所 ${n}/${RUN.cores.length}　浄化した影 ${RUN.kills}体　Lv${RUN.lv}`,dawn=!won&&RUN.hearts>0;
  runEvent({id:'run_end',once:false,script:[['wait',1.2],
    ['say','',won?'三つの核がくずれて、裏海街に、ほんの少し色がもどった。':dawn?'東の空が白んできた。……核は、まだ残っている。':'影の手に、のみこまれた……。',sum,`影のかけら +${got}${won?`　お礼 +${300+i*100}円`:''}`,...rec],
    ...(won?[['call',()=>ex1Marble(true)],['say','子どもの声',NEST_FREED[i]||NEST_FREED[0]],['call',()=>ex1Marble(false)],
      ['call',()=>{D.nest=i+1;D.last=SAVE.day;save();}],
      ['say','tome',...(i+1>=KIDS?['（無線の声）……これで、閉じこめられてた子は、みんな帰ってきたよ。','でもね、ナギ。海の底のほうに、まだ大きな気配がある。……ここからが、本番さ。']:
        ['（無線の声）よくやった、ナギ。子どもがひとり、光のほうへ帰っていったよ。','まだ向こうには、帰れない子がいる。……今夜は帰っておいで。'])],
      ['fade','out'],['call',runExit],['ura',false],['call',()=>ex1Kurosaki(false)],['warp',...HOME],['day']]:
     [['fade','out'],['call',runExit],['ura',false],['warp',HQ_X+HQ_IN[0],HQ_IN[1],HQ_IN[2]],['call',()=>{P.foot=true;P.carry='back';padLabels();}],['fade','in'],
      ['say','tome','おかえり。……拾ってきたかけらで、施設をきたえておいき。','力がついたら、また出撃すればいい。夜は、まだ長いよ。']])]});}
// the night's records, kept on this phone: the quickest night, the biggest ring, the most shadows in one ring and in a night
function runRecord(won){const R=SAVE.runRec||(SAVE.runRec={}),news=[];
  const best=(k,v,lower)=>{if(v>0&&(R[k]==null||(lower?v<R[k]:v>R[k]))){const had=R[k]!=null;R[k]=v;if(had)news.push(k);}};
  R.nights=(R.nights||0)+1;if(won)best('fast',Math.round(RUN.t),true);best('ring',Math.round(RUN.bigRing));best('hit',RUN.bigHit);best('kills',RUN.kills);save();
  const name={fast:`いちばん早い夜明け ${R.fast/60|0}分${R.fast%60}秒`,ring:`いちばん大きい結界 ${R.ring}㎡`,hit:`一度に浄化 ${R.hit}体`,kills:`一夜で浄化 ${R.kills}体`};
  return news.length?['新記録！　'+news.map(k=>name[k]).join('　')]:[];}
function runRecords(){const R=SAVE.runRec;if(!R||!R.nights)return 'まだ記録はない。';
  return `出撃 ${R.nights}回　${R.fast!=null?`いちばん早い夜明け ${R.fast/60|0}分${R.fast%60}秒　`:''}いちばん大きい結界 ${R.ring||0}㎡　一度に浄化 ${R.hit||0}体　一夜で浄化 ${R.kills||0}体`;}
// out from the command table
function runScript(){const first=!SAVE.seen.run_first;SAVE.seen.run_first=1;return[
  ['fade','out'],['call',()=>{applyD2();}],['ura',true],['call',runEnter],['time',23.2,0],['warp',...RUN_START],['call',rideNow],
  ['cam',[RUN_START[0]+8,G(RUN_START[0],RUN_START[1])+4,RUN_START[1]+6],[RUN_START[0],G(RUN_START[0],RUN_START[1])+1,RUN_START[1]-8],1.2,'cut'],['fade','in'],
  ['say','tome','（無線の声）……ザザッ……聞こえるかい、ナギ。町の三つの場所に、赤い柱が立ってるだろう。あれが「影の核」さ。',
    ...(RUN.night?[`今夜は${RUN.cores.map(c=>c.a.name).join('と')}だ。帰ってきた子がふえるほど、影も本気になってくるよ。`]:[]),
    ...(first?['核のまわりに、子どもがひとり閉じこめられてる。','スケボーで走ると、灯台の光が線になって残る。その線で核をぐるっと囲めば、核はけずれていく。大きく囲むほど、よく効くよ。',
      '線を引くと光がへる。技を決めて着地したり、手すりや屋根のてっぺんをすべったりすれば、またたまる。','この町じゃ、空中でもう一回跳べる。屋根の上も走れるよ。屋根の上から囲むのも、ありさ。',
      '影をたおすと、力がついてくる。力がついたら、ひとつえらんで持っておいき。','こわした場所も、しばらくすると影がもどってくる。そうなったら、もう一度囲んでおやり。',
      '三つの核をぜんぶこわせば、夜明けに子どもが帰ってくる。']:['今夜も、三つの核をこわしておいで。'])],
  ['cam','off'],['call',()=>{RUN.go=true;RUN.lvQ=1;toast('走って、線で囲め！',true);}]];}
