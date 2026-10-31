/* ---------- the end of the second story: with the five nests burnt, the gate under the sea opens and its master comes.
   The morning after the fifth nest Kurosaki calls: Oceangate will mend the radio mast and raise the barrier again, but not
   before dawn. That night, from the command table, the last fight: the shadow drones and the shadows on the coast road, then
   the master rising in the bay. On the beach it throws dark orbs (dodge them) and sends shadows out of the sea; each one sent
   back by the lantern gathers the light (the gauge), and when it is full a flash calls the lighthouse's beam onto it. Three
   strikes and it sinks. Dawn: the mast lit red again, Mio and the children going home into the light, Natsumi meeting her
   at last. After that the nightly defense goes on as before (d2_done). ---------- */
const BOSS_AT={x:-50,z:352},BOSS_S=30;
const BOSS={on:false,hp:3,max:3,gauge:0,need:6,list:[],orbs:[],spawnT:0,orbT:3,hearts:5,inv:0,res:null,ready:false,striking:false,falls:0,hudT:0,g:null,eyes:[]};
function bossBuild(){if(BOSS.g)return;const h=makeHuman(SHADE);h.g.scale.setScalar(BOSS_S);world.add(h.g);BOSS.g=h;
  BOSS.eyes=[[0,0,32],[-0.09,-0.06,10],[0.09,-0.06,10]].map(([dx,dy,s])=>{const e=glow('#ff3020',0,0,0,s);e.userData.d=[dx,dy];return e;});h.g.visible=false;}
function bossShow(on,y){bossBuild();const g=BOSS.g.g;g.visible=on;for(const e of BOSS.eyes)e.visible=on;if(!on)return;g.position.set(BOSS_AT.x,y==null?SEA_Y-14:y,BOSS_AT.z);g.rotation.y=Math.PI;BOSS.y=g.position.y;}
function bossPose(dt){if(!BOSS.g||!BOSS.g.g.visible)return;const g=BOSS.g.g;poseHuman(BOSS.g,'stand',dt,{});g.position.y+=(BOSS.y-g.position.y)*Math.min(1,dt*1.5);
  const s=g.scale.x;BOSS.eyes.forEach((e,k)=>{const [dx,dy]=e.userData.d;e.position.set(g.position.x+dx*s,g.position.y+(1.62+dy)*s,g.position.z-0.3*s);e.material.opacity=k?0.6+0.3*Math.sin(clock*4+k):0.85+0.15*Math.sin(clock*6);});}
const bossEye=()=>BOSS.eyes[0].position.clone();
function bossP(){return new Promise(res=>{ST.actor=null;talkNpc=null;Object.assign(BOSS,{on:true,res,hp:3,gauge:0,need:6,spawnT:1,orbT:3,hearts:DRONE.maxHp,inv:0,ready:false,striking:false,falls:0});LAN.n=LAN.max;
  toast(hasTouch?'影を「ランタン」で追いはらって光をためろ。黒い玉はよけろ':'影を L キーで追いはらって光をためろ。黒い玉はよけろ',true);renderHUD();});}
function bossHUD(tr){tr.hidden=false;tr.innerHTML='';const b=document.createElement('b');b.textContent='異界の主';const s=document.createElement('span');s.className='step';
  s.textContent=BOSS.ready?'光が満ちた！ ランタンを光らせて、灯台の光を呼べ':'浜から上がってくる影をランタンで追いはらうと、光がたまる。黒い玉は、動いてよける';
  const m=document.createElement('span');m.className='meter';const gk=Math.min(BOSS.need,BOSS.gauge);
  m.textContent=`主 ${'■'.repeat(BOSS.hp)}${'□'.repeat(BOSS.max-BOSS.hp)}　光 ${'◆'.repeat(gk)}${'◇'.repeat(BOSS.need-gk)}　${'♥'.repeat(Math.max(0,BOSS.hearts))}${'♡'.repeat(Math.max(0,DRONE.maxHp-BOSS.hearts))}　${lanMeter()}`;tr.append(b,s,m);}
// the lantern's flash in the last fight: shadows near go back and fill the gauge; with the gauge full, the beam comes
function bossFlash(R){if(!BOSS.on||BOSS.striking)return;
  if(BOSS.ready){bossStrike();return;}
  for(const s of BOSS.list)if(!s.gone&&Math.hypot(P.x-s.g.position.x,P.z-s.g.position.z)<R+1){s.gone=1;bossGain();}}
function bossGain(){if(BOSS.ready)return;BOSS.gauge++;if(BOSS.gauge>=BOSS.need){BOSS.ready=true;buzz('medium');toast('光が満ちた！ ランタンを光らせて、灯台の光を呼べ！',true);}renderHUD();}
async function bossStrike(){BOSS.striking=true;BOSS.ready=false;const T={x:BOSS_AT.x,z:BOSS_AT.z};
  for(const o of BOSS.orbs){scene.remove(o.m);}BOSS.orbs.length=0;
  await beamTurnP(T);const p=bossEye();for(let k=0;k<6;k++)setTimeout(()=>sparks(p.clone().add(new THREE.Vector3(rnd()*16-8,rnd()*10-6,rnd()*4)),20,'#ffe2a0',9,0.5),k*120);
  buzz('heavy',true);BOSS.hp--;BOSS.y-=4;BOSS.gauge=0;BOSS.need+=2;renderHUD();
  toast(BOSS.hp>0?`灯台の光が、主をつらぬいた！（のこり ${BOSS.hp}）`:'灯台の光が、主をつらぬいた！',true);
  setTimeout(()=>{EX1R.beam=null;BOSS.striking=false;if(BOSS.hp<=0&&BOSS.on){BOSS.on=false;bossClear();const r=BOSS.res;r();}},1800);}
function bossClear(){for(const s of BOSS.list){world.remove(s.g);scene.remove(s.eye);}BOSS.list.length=0;for(const o of BOSS.orbs)scene.remove(o.m);BOSS.orbs.length=0;$('hurt').style.opacity=0;}
function bossHurt(){if(BOSS.inv>0)return;BOSS.inv=1.3;BOSS.hearts--;buzz('heavy',true);P.v*=0.4;renderHUD();
  if(BOSS.hearts>0){toast('やられた！');return;}
  // down: back on her feet a little way up the beach; the master keeps its wounds
  BOSS.falls++;$('fade').style.opacity=1;BOSS.striking=true;
  setTimeout(()=>{bossClear();BOSS.hearts=DRONE.maxHp;BOSS.gauge=0;BOSS.ready=false;LAN.n=LAN.max;P.x=BOSS_AT.x;P.z=COAST_Z+2;P.yaw=0;P.y=G(P.x,P.z);camInit=false;BOSS.striking=false;
    $('fade').style.opacity=0;toast('……まだ、終われない。ミオの声が、背中を押した',true);},900);}
const ORB_G=new THREE.SphereGeometry(0.45,12,8),ORB_M=new THREE.MeshBasicMaterial({color:'#0b0b0d'});
function bossOrb(){const a=bossEye(),c=new THREE.Vector3(P.x,P.y+1,P.z),t=a.distanceTo(c)/18;
  const lead=new THREE.Vector3(Math.sin(P.yaw),0,Math.cos(P.yaw)).multiplyScalar(P.v*t*0.8),aim=c.add(lead);
  const m=new THREE.Group(),core=new THREE.Mesh(ORB_G,ORB_M),gl=glow('#ff3020',0,0,0,1.6);gl.visible=true;scene.remove(gl);m.add(core,gl);m.position.copy(a);scene.add(m);
  BOSS.orbs.push({m,v:aim.sub(a).setLength(18),life:6});}
function updateBoss(dt){bossPose(dt);if(!BOSS.on)return;const busy=!!(DLG||modal)||BOSS.striking;BOSS.inv-=dt;
  // shadows out of the sea, coming for her
  BOSS.spawnT-=dt;const alive=BOSS.list.filter(s=>!s.gone).length;
  if(!busy&&alive<4+(3-BOSS.hp)&&BOSS.spawnT<=0){const h=makeHuman(SHADE),x=clamp(P.x-20+rnd()*40,-115,15),z=SHORE+12+rnd()*5;world.add(h.g);h.g.position.set(x,SEA_Y-1.8,z);
    BOSS.list.push({h,g:h.g,eye:glow('#ff3020',0,0,0,0.9),up:0,sp:2+rnd()*0.6+(3-BOSS.hp)*0.25,gone:0,fade:0});BOSS.spawnT=1.3+rnd()*0.8;}
  for(const s of BOSS.list.slice()){const p=s.g.position;
    if(s.gone){s.fade+=dt*1.8;const f=Math.min(1,s.fade);s.g.scale.set(1-f*0.6,1-f*0.9,1-f*0.6);s.eye.visible=false;if(f>=1){world.remove(s.g);scene.remove(s.eye);BOSS.list.splice(BOSS.list.indexOf(s),1);}continue;}
    const gy=Math.max(G(p.x,p.z),SEA_Y-0.4);
    if(s.up<1){s.up=Math.min(1,s.up+dt*0.8);p.y=lerp(SEA_Y-1.8,gy,s.up);poseHuman(s.h,'stand',dt,{});}
    else if(!busy){const dx=P.x-p.x,dz=P.z-p.z,l=Math.hypot(dx,dz)||1;if(l>0.9){p.x+=dx/l*s.sp*dt;p.z+=dz/l*s.sp*dt;}p.y=Math.max(G(p.x,p.z)+paveY(p.x,p.z),SEA_Y-0.4);s.g.rotation.y=Math.atan2(dx,dz);poseHuman(s.h,'walk',dt,{rate:3.8});
      if(l<1.15&&BOSS.inv<=0){s.gone=1;bossHurt();}}
    s.eye.visible=true;s.eye.position.set(p.x,p.y+1.62,p.z);s.eye.material.opacity=0.7+0.3*Math.sin(clock*7+p.x);}
  // the dark orbs, faster as it weakens
  if(!busy){BOSS.orbT-=dt;if(BOSS.orbT<=0){bossOrb();if(BOSS.hp===1)setTimeout(()=>BOSS.on&&!BOSS.striking&&bossOrb(),450);BOSS.orbT=3.2-(3-BOSS.hp)*0.6+rnd()*0.6;}}
  const me=new THREE.Vector3(P.x,P.y+1,P.z);
  for(const o of BOSS.orbs.slice()){const p=o.m.position;o.life-=dt;if(!busy)p.addScaledVector(o.v,dt);let gone=o.life<=0;
    if(!gone&&p.distanceTo(me)<0.95){bossHurt();gone=true;}
    else if(!gone&&p.y<Math.max(G(p.x,p.z),SEA_Y)+0.1){sparks(p,8,'#3a3236',4,0.08);gone=true;}
    if(gone){scene.remove(o.m);BOSS.orbs.splice(BOSS.orbs.indexOf(o),1);}}
  $('hurt').style.opacity=Math.max(BOSS.inv>0.8?0.5:0,BOSS.hearts===1?0.3+0.1*Math.sin(clock*5):0);
  BOSS.hudT-=dt;if(BOSS.hudT<=0){BOSS.hudT=0.25;renderHUD();}}
// the people on the beach at dawn: Mio (shown again, off the pier), Natsumi, grandma, the baker, Kurosaki
const D2END={mio:false};
{ const m0=NPCS.mio.show;NPCS.mio.show=()=>D2END.mio||m0(); }
function d2Gather(on){const at={tome:[-5,-1.5],natsumi:[-2.5,1.5],baker:[4.5,-1.5],mio:[1.6,3.4]};
  for(const id in at){const n=NPCS[id];
    if(on){if(!n.home)n.home={x:n.x,z:n.z,yaw:n.yaw,y:n.h.g.position.y,mode:n.mode};const x=BOSS_AT.x+at[id][0],z=SHORE+3+at[id][1];n.x=x;n.z=z;n.mode='stand';
      n.h.g.position.set(x,G(x,z),z);n.h.g.rotation.y=id==='mio'?Math.PI:Math.atan2(BOSS_AT.x-x,SHORE+7-z);}
    else if(n.home){const o=n.home;n.x=o.x;n.z=o.z;n.mode=o.mode;n.h.g.position.set(o.x,o.y,o.z);n.h.g.rotation.y=o.yaw;delete n.home;}
    Object.assign(n.box,{x0:n.x-n.rad,x1:n.x+n.rad,z0:n.z-n.rad,z1:n.z+n.rad});}
  D2END.mio=on;}
function d2Lights(on){if(!D2END.lights)D2END.lights=Array.from({length:14},()=>glow('#bfefff',0,0,0,0.8));
  D2END.lights.forEach((l,k)=>{l.visible=on;l.userData.t=k*0.4;});D2END.up=on;}
// Omochi at Mio's feet on the beach (the cat of 裏海街's tunnel mouth); gone with her, the cat by the boats is gone too
function mochiShow(on){omochi.g.visible=on;if(!on)return;const x=BOSS_AT.x+2.6,z=SHORE+5.6;omochi.g.position.set(x,G(x,z)+0.02,z);omochi.g.rotation.y=Math.PI*0.8;}
const BEACH_CAT=CATS.find(c=>Math.abs(c.g.position.x+108.5)<0.1);
function updateD2End(dt){if(SAVE.flags.mochi_gone&&BEACH_CAT)BEACH_CAT.g.visible=false;if(omochi.g.visible&&!URA.on)poseCat(omochi,dt,false);if(!D2END.up)return;D2END.lights.forEach((l,k)=>{const t=(l.userData.t+=dt*0.35),x=BOSS_AT.x+Math.sin(k*2.3)*7,z=SHORE+8+Math.cos(k*1.7)*4;
  l.position.set(x+Math.sin(t*2+k)*0.6,G(x,Math.min(z,SHORE))+0.8+(t%6)*2.2,z);l.material.opacity=Math.max(0,1-(t%6)/6);});}
const FINAL_EVENTS=[
  {id:'d2_c1',when:{flags:{ex1_done:1,d2c:0},test:()=>(d2().nest||0)>=NESTS.length&&d2().last<SAVE.day&&!URA.on},script:[
    ['say','','朝。ポケットの無線が、ザザッと鳴った。'],
    ['say','黒崎','（無線の声）……聞こえるか、海街の。海の底で、門が開きかけている。','巣を焼かれた異界の者どもが、門の向こうの「主」を呼んでいる。……今夜、やつが来るぞ。'],
    ['say','黒崎','（無線の声）オーシャンゲートは、電波塔を直して結界を張りなおす。だが、それには夜明けまでかかる。'],
    ['say','tome','（無線の声）……それまで、わたしたちで町を守りきるってことだね。'],
    ['call',()=>ex1Marble(true)],
    ['say','ミオの声','（ナギ……あの主がいるかぎり、向こうの子たちは帰れない。わたしも）','（今夜、終わらせよう。わたしも、いっしょに戦う）'],
    ['call',()=>ex1Marble(false)],
    ['set','d2c'],['call',()=>toast('日が暮れたら、作戦室のばあちゃんに話して、最後の戦いへ',true)]]},
];
EVENTS.splice(EVENTS.findIndex(e=>e.id==='dusk'),0,...FINAL_EVENTS);
// the last night, from the command table
function finalScript(){const N=nightPlan(d2().night+4);return[
  ['fade','out'],['call',()=>{applyD2();EX1.still=true;D2_last();}],['time',21.5,0],['warp',TRUTH.x+4,TRUTH.z,0],['fade','in'],
  ['say','tome','（無線の声）みんな、配置についたね。','オーシャンゲートが電波塔を直すまで、なんとしても持ちこたえるよ！'],
  ['say','黒崎','（無線の声）こちら黒崎。全機、海街自警団を援護しろ。……今夜だけは、命令はひとつだ。町を守れ。'],
  ['drones',{total:Math.max(12,N.drones),boss:1,title:'最後の夜：影のドローン'}],
  ['say','baker','（無線の声）上は片づいた！ ナギちゃん、浜だ！'],
  ['call',()=>defendP({total:Math.max(24,N.shadows),alive:Math.max(7,N.alive),spd:Math.max(0.4,N.spd)})],
  ['fade','out'],['warp',BOSS_AT.x,COAST_Z+2,0],['call',()=>bossShow(true,SEA_Y-40)],['time',23.5,0],
  ['cam',[BOSS_AT.x+14,G(BOSS_AT.x,SHORE)+2.4,SHORE+1],[BOSS_AT.x,SEA_Y+22,BOSS_AT.z],1.2,'cut'],['fade','in'],
  ['call',()=>{BOSS.y=SEA_Y-14;}],['wait',3],
  ['say','','海が、まっぷたつに割れた。','山よりも大きな影が、ゆっくりと立ち上がる。……赤い目が、三つ。'],
  ['say','黒崎','（無線の声）主だ……！ 電波塔は、まだか！'],
  ['say','master','（無線の声）あと少しだ！ 夜明けまで、もたせてくれ！'],
  ['call',()=>ex1Marble(true)],
  ['say','ミオの声','（ナギ、影を追いはらって、光をためて。光が満ちたら、わたしが灯台の光をあいつに向ける）'],
  ['call',()=>ex1Marble(false)],
  ['cam','off'],
  ['call',bossP],
  // it sinks
  ['cam',[BOSS_AT.x+14,G(BOSS_AT.x,SHORE)+2.4,SHORE+1],[BOSS_AT.x,SEA_Y+18,BOSS_AT.z],1.2,'cut'],
  ['call',()=>{BOSS.y=SEA_Y-70;}],['wait',3.5],
  ['say','','三度目の光につらぬかれて、主は、声にならない声をあげた。','そして、門といっしょに、海の底へしずんでいった。'],
  ['set','mast_lit'],['say','','……そのとき、山の上の電波塔に、赤い灯りがともった。'],
  ['say','master','（無線の声）結界、張りなおした！ ……門が、閉じていく！'],
  ['call',()=>bossShow(false)],
  // dawn
  ['fade','out'],['call',()=>{d2Gather(true);ex1Kurosaki(false);EX1.still=true;d2Lights(true);}],['time',5.9,0],['warp',BOSS_AT.x-0.6,SHORE+1,0],
  ['cam',[BOSS_AT.x+1.5,G(BOSS_AT.x,SHORE)+2,SHORE-4.5],[BOSS_AT.x-0.5,G(BOSS_AT.x,SHORE)+1.1,SHORE+4],1.2,'cut'],['fade','in'],
  ['say','','夜が明けた。','波打ちぎわから、小さな光がいくつも、白みはじめた空へのぼっていく。'],
  ['say','mio','……ナギ。'],
  ['say','nagi','ミオ！ ……ほんとうに、ミオだ。'],
  ['say','mio','巣にとじこめられてた子たち、みんな、光のほうへ帰っていくよ。……ナギの灯りのおかげ。'],
  ['say','natsumi','……ミオ？'],
  ['say','mio','ナツミちゃん。……おとなになったね。'],
  ['say','natsumi','ミオ……ごめんね。あの夜、いっしょに行ってあげられなくて。ずっと、ずっと……'],
  ['say','mio','ううん。ナツミちゃんが、ナギをこの町に連れてきてくれた。だから、わたしは帰れるの。'],
  ['say','mio','わたしも、みんなといっしょに行くね。……もう、迷子じゃないから。'],
  ['say','mio','ナギ。ビー玉、ずっと持っててね。……灯台の灯りが見えるところに、わたしはいるよ。'],
  ['call',()=>mochiShow(true)],
  ['cam',[BOSS_AT.x+4.1,G(BOSS_AT.x,SHORE)+1.3,SHORE+2.8],[BOSS_AT.x+1.8,G(BOSS_AT.x,SHORE)+0.8,SHORE+6.4],1.2,'cut'],
  ['say','','足もとで、ニャア、と声がした。白い猫が、ミオを見上げている。'],
  ['say','mio','おもち！ ……ずっと、ナギのそばにいてくれたんだね。','あの夜、わたしについてきて、それからずっと、こっちとあっちを行ったり来たりしてたの。……ナギを、わたしのところまで連れてきてくれた。'],
  ['say','natsumi','……やっぱり、あのときのおもちだったのね。'],
  ['ask','mio','おもちは、どうしたい？',[
    ['ミオといっしょに行く',[['set','mochi_gone'],['say','','おもちは、ミオの腕の中にぴょんと飛びこんだ。'],['say','mio','うん。いっしょに帰ろう、おもち。']]],
    ['ナギのそばに残る',[['set','mochi_stay'],['say','','おもちは、ナギの足にすりよって、ミオを見上げた。'],['say','mio','そっか。……ナギのこと、たのんだよ、おもち。']]]]],
  ['say','','ミオは、ふわりと笑って、朝の光の中にとけていった。'],
  ['call',()=>{D2END.mio=false;if(SAVE.flags.mochi_gone)mochiShow(false);}],
  ['cam',[BOSS_AT.x+1.5,G(BOSS_AT.x,SHORE)+2,SHORE-4.5],[BOSS_AT.x-0.5,G(BOSS_AT.x,SHORE)+1.1,SHORE+4],1.2,'cut'],['wait',1.5],
  ['say','tome','……行ったね。'],
  ['say','baker','黒崎のやつ、「借りは返した」だとさ。……素直じゃないね。'],
  ['say','tome','異界の門は閉じた。でも、灯台の灯りがあるかぎり、また何かが寄ってくるかもしれない。','海街自警団は、これからもこの町を守るよ。……ナギ、あんたもね。'],
  ['say','nagi','うん。……この町の夏を、守るよ。'],
  ['say','','――追加ストーリー2「海街自警団」　おしまい。'],
  ['credits'],
  ['set','d2_done'],
  ['fade','out'],['call',()=>{d2Gather(false);d2Lights(false);mochiShow(false);EX1.still=false;ex1Kurosaki(false);}],['cam','off'],['warp',...HOME],['day'],
  ['call',()=>toast('基地の作戦室から、夜の防衛はこれからも続けられる',true)]];}
