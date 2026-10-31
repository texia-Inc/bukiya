/* ---------- the second extra story "海街自警団" (after ex1_done): the old guard's base inside the east hill, through the rock door.
   Like Oceangate's base it lies far off the map (x around HQ_X, flat ground, the town hidden). Five people keep five rooms:
   the armory (the baker: the pistols hit harder), the training room (the fishmonger's okami: more hits before you go down),
   the lantern workshop (the old-book shop: more charges, a wider flash, quicker to fill), the radio room (the café master:
   Oceangate's drones come to help) and the command table (grandma: out to the night's defense). A room goes up a level for
   money and 影のかけら, the shards the shadows leave behind. Every night the shadows come again, a little stronger.
   Sorties into 裏海街 and the last fight are still to come. Local coordinates lx, lz are measured from (HQ_X, 0). ---------- */
const HQ_X=-6000;
const HQ={g:new THREE.Group(),map:document.createElement('canvas'),built:false,people:{},signs:{},allies:[],allyT:0};scene.add(HQ.g);HQ.g.visible=false;
// purchase: not in yet, so every build has the second story (StoreKit comes last)
const dlc2Owned=()=>true;
const HQ_IN=[3,0,Math.PI/2],HQ_EXIT=[1.2,0];
// the rooms: who keeps them, where they stand, and what a level does
const FAC={
  arm:{name:'武器庫',npc:'baker',at:[14,-9.6],yaw:0,what:lv=>`撃つ力 ×${[1,1.5,2,2.5,3][lv-1]}`},
  dojo:{name:'鍛錬場',npc:'okami',at:[26,-9.6],yaw:0,what:lv=>`耐えられる回数 ${[5,6,7,8,10][lv-1]}`},
  lamp:{name:'灯りの工房',npc:'neko',at:[14,9.6],yaw:Math.PI,what:lv=>`ランタン ${[3,4,4,5,6][lv-1]}回・光の広さ ${[13,14.5,16,17.5,19][lv-1]}m`},
  radio:{name:'通信室',npc:'master',at:[26,9.6],yaw:Math.PI,what:lv=>lv<2?'援護なし':`オーシャンゲートの援護ドローン ${lv>=4?2:1}機（${[0,0,4,3,3,2][lv]}秒ごと）`},
  cmd:{name:'作戦室',npc:'tome',at:[38.5,0],yaw:-Math.PI/2}};
const FAC_COST=[null,null,{m:500,s:5},{m:1500,s:15},{m:3000,s:30},{m:6000,s:50}];   // to reach level 2…5
const d2=()=>SAVE.d2||(SAVE.d2={lv:{arm:1,dojo:1,lamp:1,radio:1},night:0,last:0});
const hqLv=k=>d2().lv[k]||1;
const shards=()=>SAVE.shards||0;
// what the levels do, set whenever no fight is on (the story's own fights get them too)
const lanR=()=>[13,14.5,16,17.5,19][hqLv('lamp')-1];
const lanRe=def=>def?[1.6,1.4,1.2,1.0,0.8][hqLv('lamp')-1]:[16,14,12,10,8][hqLv('lamp')-1];
function applyD2(){if(DRONE.active)return;DRONE.maxHp=[5,6,7,8,10][hqLv('dojo')-1];DRONE.dmg=[1,1.5,2,2.5,3][hqLv('arm')-1];
  const m=[3,4,4,5,6][hqLv('lamp')-1];if(LAN.max!==m){LAN.max=m;LAN.n=Math.min(LAN.n,m);}}
/* ----- the hall: a cave in the hill, timber props, strings of bulbs, the five rooms round it ----- */
function hqBuild(){if(HQ.built)return;HQ.built=true;const g=HQ.g,X=HQ_X,W=44,D=28,H=6.5;
  const rock=tm('#6a5d50'),rock2=tm('#574b40'),wood=tm('#7a5a3a'),dark=tm('#4a3828');
  const ft=canvasTex(128,128,(c,w,h)=>{c.fillStyle='#8a7a66';c.fillRect(0,0,w,h);c.strokeStyle='rgba(60,46,34,.35)';c.lineWidth=3;for(let k=0;k<4;k++){c.beginPath();c.moveTo(0,k*32+16);c.lineTo(w,k*32+16);c.stroke();}
    c.fillStyle='rgba(255,255,255,.05)';for(let k=0;k<50;k++)c.fillRect(Math.random()*w,Math.random()*h,3,2);},true);ft.repeat.set(W/4,D/4);
  const floor=new THREE.Mesh(new THREE.PlaneGeometry(W,D),tmap(ft));floor.rotation.x=-Math.PI/2;floor.position.set(X+W/2,0.001,0);floor.receiveShadow=true;g.add(floor);
  const ceil=new THREE.Mesh(new THREE.PlaneGeometry(W,D),new THREE.MeshBasicMaterial({color:'#2e2620'}));ceil.rotation.x=Math.PI/2;ceil.position.set(X+W/2,H,0);g.add(ceil);
  // the walls: rough rock, a box each side and boulders along the foot
  for(const [x0,x1,z0,z1] of [[-1,0,-D/2,D/2],[W,W+1,-D/2,D/2],[-1,W+1,-D/2-1,-D/2],[-1,W+1,D/2,D/2+1]]){const m=new THREE.Mesh(new THREE.BoxGeometry(x1-x0,H,z1-z0),rock);m.position.set(X+(x0+x1)/2,H/2,(z0+z1)/2);g.add(m);collide(X+x0,X+x1,z0,z1,'bld',H);}
  // (none by the door, nor in front of the rooms)
  for(let k=0;k<34;k++){const side=k%4,t=(k*0.137+0.05)%1,s=0.8+((k*7)%5)*0.25,b=new THREE.Mesh(new THREE.DodecahedronGeometry(s,0),k%3?rock:rock2);
    const x=side<2?(side?W-0.2:0.2):t*W,z=side<2?(t-0.5)*D:(side===2?-D/2+0.2:D/2-0.2);if(side===0&&Math.abs(z)<2.5||side>=2&&x>9.5&&x<31)continue;b.position.set(X+x,s*0.4,z);b.rotation.set(k,k*2,k*3);b.castShadow=true;g.add(b);}
  // timber props and beams across the ceiling
  for(let x=6;x<W;x+=9){for(const z of [-D/2+0.5,D/2-0.5]){const p=new THREE.Mesh(new THREE.BoxGeometry(0.45,H,0.45),wood);p.position.set(X+x,H/2,z);outline(p,0.02);g.add(p);}
    const b=new THREE.Mesh(new THREE.BoxGeometry(0.4,0.45,D),dark);b.position.set(X+x,H-0.3,0);g.add(b);}
  // strings of bulbs
  const bulb=new THREE.MeshBasicMaterial({color:'#ffd88a'});
  for(let x=2;x<W;x+=1.6)for(const z of [-6,6]){const m=new THREE.Mesh(new THREE.SphereGeometry(0.09,8,6),bulb);m.position.set(X+x,H-0.9-Math.sin((x%9)/9*Math.PI)*0.5,z);g.add(m);}
  for(const z of [-6,6]){const w=new THREE.Mesh(new THREE.BoxGeometry(W,0.02,0.02),dark);w.position.set(X+W/2,H-1.1,z);g.add(w);}
  // the door to the hillside
  const door=new THREE.Mesh(new THREE.PlaneGeometry(2.4,3.0),new THREE.MeshBasicMaterial({color:'#cfe6ff'}));door.position.set(X+0.02,1.5,0);door.rotation.y=Math.PI/2;g.add(door);
  // the rooms
  const box=(w,h,d,mat,x,y,z,ol)=>{const m=new THREE.Mesh(new THREE.BoxGeometry(w,h,d),mat);m.position.set(X+x,y,z);m.castShadow=true;if(ol!==0)outline(m,0.02);g.add(m);return m;};
  // armory: a rack of pistols and a crate of shells
  box(4.5,2.4,0.5,wood,14,1.2,-13.2);for(let k=0;k<5;k++){box(0.5,0.18,0.12,tm('#2a2d33'),12.3+k*0.85,1.5,-12.85,0);box(0.12,0.28,0.12,tm('#2a2d33'),12.15+k*0.85,1.38,-12.85,0);}
  box(1.4,0.8,1,tm('#5d6b3a'),16.6,0.4,-11.6);collide(X+11.7,X+17.4,-13.5,-11,'prop',2.4);
  // training room: sandbags, a straw target, mats
  for(let k=0;k<3;k++)box(1.6,0.45,0.8,tm('#b8a888'),24.5+k*1.7,0.25+0*k,-12.8);for(let k=0;k<2;k++)box(1.5,0.45,0.8,tm('#a89878'),25.3+k*1.7,0.7,-12.8);
  const tgt=new THREE.Mesh(new THREE.CylinderGeometry(0.6,0.6,0.25,18),tm('#d8c27a'));tgt.rotation.x=Math.PI/2;tgt.position.set(X+29,1.4,-13.2);g.add(tgt);box(0.15,1.4,0.15,wood,29,0.7,-13.3);
  const mat=new THREE.Mesh(new THREE.PlaneGeometry(5,3),tm('#4f7a9a'));mat.rotation.x=-Math.PI/2;mat.position.set(X+26,0.01,-10.6);g.add(mat);collide(X+23.5,X+30,-13.5,-12.3,'prop',1);
  // lantern workshop: a bench of lanterns, glowing
  box(5,0.9,1.2,wood,14,0.45,12.8);for(let k=0;k<4;k++){box(0.32,0.45,0.32,tm('#b08a3a'),12.2+k*1.2,1.13,12.8,0);const l=glow('#ffd27a',X+12.2+k*1.2,1.15,12.8,0.9);l.visible=true;HQ.g.add(l);}
  collide(X+11.5,X+16.5,12.2,13.5,'prop',0.9);
  // radio room: a desk, a big set with dials, two screens
  box(5,0.9,1.2,tm('#3a3d42'),26,0.45,12.8);box(1.6,1.1,0.7,tm('#5a5f66'),24.6,1.45,13.1);
  for(let k=0;k<2;k++){const c=canvasTex(160,100,(c2,w,h)=>{c2.fillStyle='#0f2a1a';c2.fillRect(0,0,w,h);c2.strokeStyle='#7fe0a0';c2.lineWidth=2;c2.beginPath();for(let x=0;x<w;x+=4)c2.lineTo(x,h/2+Math.sin(x/9+k*2)*18*(k?0.5:1));c2.stroke();
      c2.fillStyle='#bff5cf';c2.font='12px monospace';c2.fillText(k?'OG-LINK':'CH 07',8,16);});
    const m=new THREE.Mesh(new THREE.PlaneGeometry(1.4,0.9),new THREE.MeshBasicMaterial({map:c}));m.position.set(X+26.6+k*1.6,1.55,13.38);m.rotation.y=Math.PI;g.add(m);}
  collide(X+23.5,X+28.5,12.2,13.5,'prop',0.9);
  // command table: the town spread out on it
  const tbl=box(5,0.9,3.2,wood,40.5,0.45,0);
  const mp=canvasTex(256,160,(c,w,h)=>{c.fillStyle='#e9dfc6';c.fillRect(0,0,w,h);c.fillStyle='#7cb6d8';c.fillRect(0,h*0.62,w,h*0.38);c.fillStyle='#c9b48a';c.fillRect(0,h*0.56,w,h*0.07);
    c.strokeStyle='#8a6a4a';c.lineWidth=3;c.beginPath();c.moveTo(w*0.5,0);c.lineTo(w*0.5,h*0.58);c.moveTo(0,h*0.4);c.lineTo(w,h*0.4);c.stroke();
    c.fillStyle='#d24a3a';for(const [x,y] of [[0.3,0.8],[0.55,0.75],[0.7,0.85],[0.42,0.7]]){c.beginPath();c.arc(w*x,h*y,5,0,7);c.fill();}c.fillStyle='#2b2520';c.font='bold 16px sans-serif';c.fillText('海街',w*0.06,h*0.2);});
  const top=new THREE.Mesh(new THREE.PlaneGeometry(4.6,2.9),new THREE.MeshBasicMaterial({map:mp}));top.rotation.x=-Math.PI/2;top.rotation.z=Math.PI/2;top.position.set(X+40.5,0.91,0);g.add(top);
  collide(X+38,X+43,-1.6,1.6,'prop',0.9);
  // the keepers, and a sign over each room
  for(const k in FAC){const F=FAC[k],n=NPCS[F.npc],h=makeHuman(n.h.o);g.add(h.g);h.g.position.set(X+F.at[0],0,F.at[1]);h.g.rotation.y=F.yaw;HQ.people[k]=h;
    collide(X+F.at[0]-0.4,X+F.at[0]+0.4,F.at[1]-0.4,F.at[1]+0.4,'npc');
    const c=document.createElement('canvas');c.width=256;c.height=64;const t=new THREE.CanvasTexture(c);const s=new THREE.Mesh(new THREE.PlaneGeometry(2.6,0.65),new THREE.MeshBasicMaterial({map:t,transparent:true}));
    const sx=k==='cmd'?43.6:F.at[0],sz=k==='cmd'?0:F.at[1]+(F.at[1]<0?-3.9:3.9);s.position.set(X+sx,3.3,sz);s.rotation.y=k==='cmd'?-Math.PI/2:F.at[1]<0?0:Math.PI;g.add(s);HQ.signs[k]={c,t};hqSign(k);}
  // the map
  const mc=HQ.map;mc.width=W+8;mc.height=D+8;const m2=mc.getContext('2d');m2.fillStyle='#3d342c';m2.fillRect(0,0,mc.width,mc.height);m2.fillStyle='#b8a890';m2.fillRect(4,4,W,D);
  m2.fillStyle='#e2a84a';for(const k in FAC){const F=FAC[k];m2.fillRect(4+F.at[0]-1.5,4+F.at[1]+D/2-1.5,3,3);}HQ.mapX0=X-4;HQ.mapZ0=-D/2-4;}
function hqSign(k){const S=HQ.signs[k];if(!S)return;const c=S.c.getContext('2d');c.clearRect(0,0,256,64);c.fillStyle='rgba(60,42,28,.9)';c.fillRect(4,4,248,56);c.strokeStyle='#d8b878';c.lineWidth=3;c.strokeRect(6,6,244,52);
  c.fillStyle='#fff1d6';c.font=signFont(28,true);c.textAlign='center';c.textBaseline='middle';c.fillText(FAC[k].name+(k==='cmd'?'':`  Lv${hqLv(k)}`),128,34);S.t.needsUpdate=true;}
/* ----- in and out through the rock door ----- */
function rockFront(){const D=rockDoor(),p=D.g.position,a=D.g.rotation.y;return[p.x+Math.sin(a)*3.4,p.z+Math.cos(a)*3.4,a];}
function hqNear(){if(AREA==='town'){if(!SAVE.flags.ex1_done||SAVE.flags.x_door!==2||URA.on)return null;const [x,z]=rockFront(),d=Math.hypot(P.x-x,P.z-z);return d<3.2?{kind:'hq',enter:true,d,label:'入る　岩の扉（海街自警団の基地）',verb:'入る'}:null;}
  if(AREA!=='hq')return null;let best=null;const add=o=>{if(!best||o.d<best.d)best=o;};
  const dx=Math.hypot(P.x-(HQ_X+HQ_EXIT[0]),P.z-HQ_EXIT[1]);if(dx<2.6)add({kind:'hq',exit:true,d:dx,label:'出る　岩の扉',verb:'出る'});
  for(const k in FAC){const F=FAC[k],d=Math.hypot(P.x-(HQ_X+F.at[0]),P.z-F.at[1]);if(d<2.8)add({kind:'hq',k,d,label:`話す　${whoName(F.npc)}（${F.name}）`,verb:'話す'});}
  return best;}
function hqAct(o){runEvent({id:'hq_act',once:false,script:[['call',()=>hqTalk(o)]]});}
async function hqTalk(o){
  if(o.enter){if(!dlc2Owned()){await sayP('',['追加ストーリー2「海街自警団」を手に入れると、ここから基地に入れます。']);return;}
    await steps([['fade','out'],['warp',HQ_X+HQ_IN[0],HQ_IN[1],HQ_IN[2]],['fade','in']]);return;}
  if(o.exit){const [x,z,a]=rockFront();await steps([['fade','out'],['warp',x,z,a],['fade','in']]);return;}
  const F=FAC[o.k];ST.actor=null;
  if(o.k==='cmd')return hqCommand();
  for(;;){const lv=hqLv(o.k),c=FAC_COST[lv+1];
    const opts=[...(c?[`レベル${lv+1}にする（${c.m}円・かけら${c.s}）`]:[]),'いまの強さを聞く','やめる'];
    const i=await askP(F.npc,`${F.name} Lv${lv}　（さいふ ${SAVE.money}円・影のかけら ${shards()}）`,opts),pick=opts[i];
    if(pick==='やめる')return;
    if(pick==='いまの強さを聞く'){await sayP(F.npc,[`いまは ${F.what(lv)}。`+(c?`次のレベルで ${F.what(lv+1)} になる。`:'これ以上は、上げようがないね。')]);continue;}
    if(SAVE.money<c.m||shards()<c.s){await sayP(F.npc,[SAVE.money<c.m?'お金が足りないね。おつかいや、夜の防衛でかせいでおいで。':'影のかけらが足りない。夜の防衛で、影を追いはらうと手に入るよ。']);continue;}
    SAVE.money-=c.m;SAVE.shards=shards()-c.s;d2().lv[o.k]=lv+1;hqSign(o.k);applyD2();save();renderHUD();buzz('medium');
    toast(`${F.name}が Lv${lv+1} になった！ ${F.what(lv+1)}`,true);await sayP(F.npc,[HQ_UP[o.k]]);}}
const HQ_UP={arm:'よし、手入れは終わった。これで一発の重みがちがうぞ。',dojo:'いい汗かいたね！ これで、ちょっとやそっとじゃ倒れないよ。',
  lamp:'ランタンのガラスを、灯台のレンズのかけらで張りかえた。前より、ずっと遠くまで光が届く。',radio:'黒崎の連中と、回線をつないだ。夜は、やつらのドローンが手を貸してくれる。'};
/* ----- the command table: out to tonight's defense ----- */
function nightPlan(n){return{drones:Math.min(4+2*n,16),boss:n%3===0,shadows:Math.min(10+3*n,36),alive:Math.min(4+(n>>1),9),spd:0.06*n};}
async function hqCommand(){const D=d2(),ph=phaseOf(SAVE.hour),dark=ph==='evening'||ph==='night',done=D.last===SAVE.day,n=D.night+1;
  const opts=[...(dark&&!done?['今夜の防衛に出る']:[]),...(!dark?['日が暮れるまで休む']:[]),'話を聞く','やめる'];
  const i=await askP('tome',done?'今夜の町は守った。……ゆっくりお休み。':dark?`${n}日目の夜。……今夜も、来るよ。`:'やつらが来るのは、日が暮れてからだよ。',opts),pick=opts[i];
  if(pick==='日が暮れるまで休む'){await steps([['fade','out'],['time',18.6,0],['fade','in']]);return;}
  if(pick==='話を聞く'){await sayP('tome',[...(n<=1?['施設は、お金と影のかけらで強くなる。かけらは、夜の防衛で影を追いはらうと手に入るよ。']:[]),
    nightPlan(n).boss?'今夜は、大きいのが混じってる。気をつけな。':'夜ごとに、やつらの数は増えていく。施設をきたえておくんだよ。',
    'いずれは、こっちから裏海街に攻めこむ。……その準備は、まだこれからさ。']);return;}
  if(pick!=='今夜の防衛に出る')return;
  const N=nightPlan(n),got={sh:0,dr:0};
  await steps([['fade','out'],['call',()=>{applyD2();EX1.still=true;}],['time',21,0],['warp',TRUTH.x+4,TRUTH.z,0],['fade','in'],
    ['say','tome','（無線の声）来たよ、ナギ。まずは空のドローン、それから浜の影だ。','町に、一匹も入れるんじゃないよ！'],
    ['drones',{total:N.drones,boss:N.boss?1:0,title:`${n}日目の夜：影のドローン`}],['call',()=>{got.dr=DRONE.killed+(N.boss?10:0);}],
    ['say','baker','（無線の声）上は片づいた！ 浜だ！'],
    ['call',()=>defendP({total:N.shadows,alive:N.alive,spd:N.spd})],['call',()=>{got.sh=DEF.killed;}],
    ['call',()=>{const s=got.sh+got.dr;SAVE.shards=shards()+s;SAVE.money+=200+n*50;D.night=n;D.last=SAVE.day;save();renderHUD();
      toast(`影のかけら +${s}　お礼 +${200+n*50}円`,true);}],
    ['say','tome','（無線の声）よくやったね。今夜も、町の灯りは守られた。','かけらは、基地に持って帰っておいで。'],
    ['fade','out'],['call',()=>ex1Kurosaki(false)],['warp',...HOME],['day']]);}
/* ----- Oceangate's help: one or two of their drones ahead of Nagi to either side (out of the camera's way), picking off a drone or a shadow now and then ----- */
function allyStep(dt){const lv=hqLv('radio'),want=(DRONE.active||DEF.on)&&lv>=2?(lv>=4?2:1):0;
  while(HQ.allies.length<want){const d=makeDrone();d.g.scale.setScalar(1.1);HQ.allies.push(d);toast('オーシャンゲートの援護ドローンが来た！');}
  HQ.allies.forEach((d,k)=>{d.g.visible=k<want;if(!d.g.visible)return;const sd=k?-1:1,a=P.yaw+sd*(0.55+Math.sin(clock*0.7+k)*0.15),w=new THREE.Vector3(P.x+Math.sin(a)*7,P.y+6+Math.sin(clock*2+k)*0.3,P.z+Math.cos(a)*7);
    d.g.position.lerp(w,Math.min(1,dt*3));d.g.rotation.y=a;for(const r of d.rotors)r.rotation.y+=dt*40;});
  if(!want)return;HQ.allyT-=dt;if(HQ.allyT>0||DLG||modal)return;HQ.allyT=[0,0,4,3,3,2][lv];
  const from=HQ.allies[(clock*10|0)%want].g.position.clone();
  if(DRONE.active){const t=DRONE.list.filter(d=>!d.dead&&d.g.position.distanceTo(from)<55).sort((a,b)=>a.g.position.distanceTo(from)-b.g.position.distanceTo(from))[0];
    if(t){const p=t.g.position.clone();tracer(from,p);damage(t,p);if(!t.dead)damage(t,p);}}
  else if(DEF.on){const t=DEF.list.filter(s=>!s.gone&&s.up>=1).sort((a,b)=>a.g.position.z-b.g.position.z)[0];
    if(t){tracer(from,t.g.position.clone().setY(t.g.position.y+1));t.gone=1;DEF.killed++;}}}
function hqHUD(){const D=d2();return `影のかけら ${shards()}　防衛 ${D.night}夜`;}
function d2Goal(f,eve,night){const D=d2();
  if(!f.d2)return '町の東の山の岩の扉から、海街自警団の基地へ';
  if(AREA==='hq')return (eve||night)&&D.last!==SAVE.day?`作戦室のばあちゃんに話して、今夜の防衛に出る（${hqHUD()}）`:`施設の人に話して、基地を強くする（${hqHUD()}）`;
  return (eve||night)&&D.last!==SAVE.day?'基地の作戦室で、ばあちゃんに話して防衛に出る':`基地で施設を強くする。夜は防衛（${hqHUD()}）`;}
// every frame: the hall's warm light, the keepers looking round, the levels, the allies
function updateHQ(dt){if(SAVE.flags.ex1_done)applyD2();allyStep(dt);if(AREA!=='hq')return;hqBuild();
  scene.fog.color.set('#2a221c');scene.background.set('#2a221c');scene.fog.near=10;scene.fog.far=80;hemi.color.set('#ffe6c4');hemi.groundColor.set('#5a4a3a');hemi.intensity=0.95;sun.intensity=0.15;
  for(const m of NIGHT_MATS)m.emissiveIntensity=0;NIGHT.stars.material.opacity=0;
  for(const k in HQ.people){const h=HQ.people[k],p=h.g.position,near=Math.hypot(P.x-p.x,P.z-p.z)<9;poseHuman(h,'stand',dt,{look:near?player.g.position:null});}}
const HQ_EVENTS=[
  {id:'d2_intro',when:{flags:{ex1_done:1,d2:0},test:()=>AREA==='hq'},script:[
    ['cam',[HQ_X+8,3.2,-4],[HQ_X+30,1.4,0],1.2,'cut'],
    ['say','','岩の扉の奥は、山をくりぬいた広い洞窟だった。','太い木の柱に、はだか電球がずらりとつるされている。'],
    ['say','tome','ようこそ、海街自警団の基地へ。30年ぶりに、灯りを入れたよ。'],
    ['cam',[HQ_X+14,2.4,-4],[HQ_X+14,1.3,-12],1.2,'cut'],
    ['say','baker','武器庫だ。おれの古い道具を、ここで手入れしておく。','お金と影のかけらがあれば、もっと強くしてやれるぞ。'],
    ['cam',[HQ_X+26,2.4,-4],[HQ_X+26,1.3,-12],1.2,'cut'],
    ['say','okami','鍛錬場だよ。体をきたえりゃ、ちょっとやそっとじゃ倒れなくなるさ。'],
    ['cam',[HQ_X+14,2.4,4],[HQ_X+14,1.3,12],1.2,'cut'],
    ['say','neko','灯りの工房。灯台の灯りを、ランタンにたくさんためられるようにする。光も、もっと遠くまで届くようになるよ。'],
    ['cam',[HQ_X+26,2.4,4],[HQ_X+26,1.3,12],1.2,'cut'],
    ['say','master','通信室だ。黒崎の連中と、ここでつながってる。','設備をよくすれば、夜にはオーシャンゲートのドローンが援護に来てくれる。'],
    ['cam',[HQ_X+34,2.6,3],[HQ_X+40,1.3,0],1.2,'cut'],
    ['say','tome','そして、ここが作戦室。','異界の者は、これから夜ごとに来る。倒した影は「影のかけら」を落とす。それを集めて、基地を強くするんだよ。'],
    ['say','tome','日が暮れたら、わたしに声をかけな。いっしょに町を守ろう。','……いずれは、こっちから裏海街に攻めこむ。ミオちゃんが言ってた、向こうに残された子たちのためにもね。'],
    ['set','d2'],['cam','off'],['call',()=>toast('施設の人に話すと、お金と影のかけらで強くできる',true)]]},
];
EVENTS.splice(EVENTS.findIndex(e=>e.id==='dusk'),0,...HQ_EVENTS);
