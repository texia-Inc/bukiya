/* ---------- the second story's sorties: out from the command table at night into 裏海街, to burn the shadows' nests one by one.
   Five nests, each a black heap with a red glow in the grey town, the next one marked. On the way the shadows walk their beats
   as ever (seen, and it is back to the tunnel). Close to a nest the fight starts: shadows crawl out of it and come for Nagi;
   a touch costs a heart (as many as in the drone fights), and a flash of the lantern sends them off and burns the nest when
   it is near enough. Hearts gone, and she is back at the tunnel with the nest whole again; every third time, the way home.
   Like the rescue, the sortie is free play between two events: SAVE.flags.sortie is the nest's number + 1 while it lasts. ---------- */
const NESTS=[{name:'浜の巣',x:40,z:COAST_Z+1},{name:'駅前の巣',x:62,z:TRAM_Z+6},{name:'まるやの巣',x:SHOPS.dagashi.door[0]+0.7,z:SHOPS.dagashi.door[1]-2.5},
  {name:'神社の巣',x:SHRINE.x,z:-140},{name:'坂道の巣',x:0,z:-60}];
const NEST_FREED=['（……ありがとう、おねえちゃん。やっと、海の音が聞こえる）','（まっくらだったの。……灯り、あったかいね）','（ラムネのビー玉、まだ持ってるよ。……帰れるかな）',
  '（お祭りの太鼓が、ずっと遠くで鳴ってた。……もうすぐ、帰れる）','（坂の上から、灯台が見えた。……ありがとう）'];
const NEST={on:false,i:0,g:null,core:null,glows:[],hp:0,max:0,fight:false,list:[],spawnT:0,hearts:5,inv:0,falls:0,killed:0,hudT:0,mark:null,asking:false};
const sortieOn=()=>URA.on&&(SAVE.flags.sortie||0)>0;
function nestBuild(){if(NEST.g)return;const g=new THREE.Group(),blk=new THREE.MeshBasicMaterial({color:'#0b0b0d'});world.add(g);
  NEST.core=new THREE.Mesh(new THREE.SphereGeometry(1.6,14,10),blk);NEST.core.position.y=1.2;NEST.core.scale.set(1,0.8,1);g.add(NEST.core);
  for(let k=0;k<9;k++){const a=k/9*TAU,r=1.3+(k%3)*0.5,m=new THREE.Mesh(new THREE.SphereGeometry(0.5+(k%4)*0.22,10,8),blk);m.position.set(Math.cos(a)*r,0.35+(k%2)*0.4,Math.sin(a)*r);g.add(m);}
  for(let k=0;k<4;k++){const s=glow('#ff3020',0,0,0,k?1.1:3.2);s.visible=true;g.add(s);s.position.set(k?Math.cos(k*2)*1.2:0,k?0.9+k*0.25:1.4,k?Math.sin(k*2)*1.2:0);NEST.glows.push(s);}
  NEST.g=g;g.visible=false;}
// start (or pick up again after a load) the sortie on nest i
function nestStart(i){nestBuild();const N=NESTS[i];Object.assign(NEST,{on:true,i,hp:4+2*i,max:4+2*i,fight:false,spawnT:1,hearts:DRONE.maxHp,inv:0,killed:0});nestClear(true);
  NEST.g.position.set(N.x,G(N.x,N.z),N.z);NEST.g.scale.setScalar(1);NEST.g.visible=true;
  if(!NEST.mark){NEST.mark=marker(MK.target);NEST.mark.scale.set(1.6,1.6,1);}LAN.n=LAN.max;renderHUD();}
function nestClear(keep){for(const s of NEST.list){world.remove(s.g);scene.remove(s.eye);}NEST.list.length=0;if(keep)return;
  NEST.on=false;NEST.fight=false;if(NEST.g)NEST.g.visible=false;if(NEST.mark)NEST.mark.visible=false;$('hurt').style.opacity=0;}
function nestHUD(tr){tr.hidden=false;tr.innerHTML='';const N=NESTS[NEST.i],b=document.createElement('b');b.textContent=`出撃：${N.name}`;const s=document.createElement('span');s.className='step';
  s.textContent=NEST.fight?'巣のそばでランタンを光らせて、巣を焼く。はい出してくる影も、光で追いはらえる':'影の住人に見つからないように、赤く光る巣へ。歩くと静か';
  const m=document.createElement('span');m.className='meter';const n=Math.ceil(Math.max(0,NEST.hp)/NEST.max*10);
  m.textContent=`巣 ${'■'.repeat(n)}${'□'.repeat(10-n)}　${'♥'.repeat(Math.max(0,NEST.hearts))}${'♡'.repeat(Math.max(0,DRONE.maxHp-NEST.hearts))}　${lanMeter()}`;tr.append(b,s,m);}
// the lantern's flash at the nest: the shadows near it go, and the nest burns if it is within the light
function nestFlash(R){if(!NEST.on)return;const dd=p=>Math.hypot(P.x-p.x,P.z-p.z);
  for(const s of NEST.list)if(!s.gone&&dd(s.g.position)<R+1){s.gone=1;NEST.killed++;}
  if(NEST.fight&&dd(NEST.g.position)<R+2){NEST.hp-=DRONE.dmg||1;const p=NEST.g.position.clone();p.y+=1.4;sparks(p,18,'#ffe2a0',6,0.12);buzz('heavy',true);
    if(NEST.hp<=0)nestBurnt();else toast(`巣が光に焼かれていく……（のこり ${Math.ceil(NEST.hp)}）`);}
  renderHUD();}
function nestBurnt(){const p=NEST.g.position.clone();p.y+=1;boom(p);for(let k=0;k<4;k++)setTimeout(()=>sparks(p.clone().add(new THREE.Vector3(rnd()*3-1.5,rnd()*2,rnd()*3-1.5)),16,'#ffe2a0',7,0.12),k*180);
  for(const s of NEST.list)s.gone=1;NEST.fight=false;SAVE.flags.sortie=0;setTimeout(()=>{NEST.g.visible=false;NEST.mark.visible=false;nestClear();runEvent({id:'nest_done',once:false,script:nestDoneScript(NEST.i,NEST.killed)});},900);}
function nestFall(){NEST.fight=false;NEST.falls++;$('fade').style.opacity=1;P.v=0;
  setTimeout(()=>{nestClear(true);NEST.hp=NEST.max;NEST.hearts=DRONE.maxHp;LAN.n=LAN.max;P.x=URA_START[0];P.z=URA_START[1];P.yaw=URA_START[2];P.y=G(P.x,P.z);camInit=false;$('fade').style.opacity=0;$('hurt').style.opacity=0;
    toast('影にのまれた……。気がつくと、トンネルの出口にいた',true);if(NEST.falls%3===0)nestRetire();},900);}
async function nestRetire(){NEST.asking=true;const i=await askP('',`${NEST.falls}回やられてしまった……。どうする？`,['もう少しがんばる','今夜は引きあげる']);NEST.asking=false;
  if(i===1)runEvent({id:'nest_back',once:false,script:[['say','tome','（無線の声）……無理はおしでないよ。今夜は引きあげな。'],...nestHome()]});}
const nestHome=()=>[['fade','out'],['call',()=>{nestClear();SAVE.flags.sortie=0;}],['ura',false],['call',()=>ex1Kurosaki(false)],['warp',...HOME],['day']];
function nestDoneScript(i,killed){const last=i===NESTS.length-1,got=15+10*i+killed;return[
  ['say','','巣が、灯りの中でくずれ落ちた。','黒い霧がほどけて、小さな光が、いくつも空へのぼっていく。'],
  ['call',()=>ex1Marble(true)],['say','子どもの声',NEST_FREED[i]],['call',()=>ex1Marble(false)],
  ['call',()=>{const D=d2();D.nest=i+1;D.last=SAVE.day;SAVE.shards=shards()+got;SAVE.money+=300+i*100;save();renderHUD();toast(`影のかけら +${got}　お礼 +${300+i*100}円`,true);}],
  ...(last?[['say','tome','（無線の声）……これで、町のまわりの巣は、ぜんぶ焼けたよ。','でもね、ナギ。海の底のほうに、まだ大きな気配がある。……ここからが、本番さ。']]
    :[['say','tome','（無線の声）よくやった、ナギ。のこる巣は、あと'+(NESTS.length-i-1)+'つ。','今夜は帰っておいで。']]),
  ...nestHome()];}
// every frame of a sortie: the nest breathing, the fight round it
function nestStep(dt){if(!sortieOn()){if(NEST.on&&!URA.on)nestClear();return;}
  if(!NEST.on)nestStart(SAVE.flags.sortie-1);   // a save made out there picks up again at the tunnel's mouth
  const g=NEST.g,N=NESTS[NEST.i],d=Math.hypot(P.x-g.position.x,P.z-g.position.z),k=NEST.hp/NEST.max,busy=!!(DLG||modal||NEST.asking);
  g.scale.setScalar(0.55+0.45*k+Math.sin(clock*3)*0.04);NEST.glows.forEach((s,j)=>{s.material.opacity=(0.6+0.4*Math.sin(clock*(4+j)+j))*(0.4+0.6*k);});
  NEST.mark.visible=!NEST.fight;NEST.mark.position.set(N.x,G(N.x,N.z)+4.2+Math.sin(clock*3)*0.15,N.z);
  if(!NEST.fight&&d<22&&!URA.hide&&!busy&&NEST.hp>0){NEST.fight=true;NEST.spawnT=0.5;toast('影の巣だ！ そばでランタンを光らせて、巣を焼け',true);for(const s of URA.shadows)s.sus=0;}
  if(NEST.fight&&d>45){NEST.fight=false;for(const s of NEST.list)s.gone=1;toast('巣から離れた');}
  NEST.inv-=dt;
  if(NEST.fight&&!busy){NEST.spawnT-=dt;const alive=NEST.list.filter(s=>!s.gone).length;
    if(NEST.spawnT<=0&&alive<3+NEST.i){const h=makeHuman(SHADE),a=rnd()*TAU,x=g.position.x+Math.cos(a)*2.2,z=g.position.z+Math.sin(a)*2.2;world.add(h.g);h.g.position.set(x,G(x,z)-1.6,z);
      NEST.list.push({h,g:h.g,eye:glow('#ff3020',0,0,0,0.9),up:0,sp:2+NEST.i*0.3+rnd()*0.5,gone:0,fade:0});NEST.spawnT=2.4-NEST.i*0.25+rnd()*0.6;}}
  for(const s of NEST.list.slice()){const p=s.g.position;
    if(s.gone){s.fade+=dt*1.8;const f=Math.min(1,s.fade);s.g.scale.set(1-f*0.6,1-f*0.9,1-f*0.6);s.eye.visible=false;if(rnd()<dt*25)sparks(new THREE.Vector3(p.x,p.y+1,p.z),1,'#ffe2a0',2,0.05);
      if(f>=1){world.remove(s.g);scene.remove(s.eye);NEST.list.splice(NEST.list.indexOf(s),1);}continue;}
    const gy=G(p.x,p.z);
    if(s.up<1){s.up=Math.min(1,s.up+dt*0.9);p.y=lerp(gy-1.6,gy,s.up);poseHuman(s.h,'stand',dt,{});}
    else if(!busy){const dx=P.x-p.x,dz=P.z-p.z,l=Math.hypot(dx,dz)||1;if(l>0.9){p.x+=dx/l*s.sp*dt;p.z+=dz/l*s.sp*dt;}p.y=G(p.x,p.z);s.g.rotation.y=Math.atan2(dx,dz);poseHuman(s.h,'walk',dt,{rate:3.8});
      if(l<1.15&&NEST.inv<=0){NEST.inv=1.3;NEST.hearts--;buzz('heavy',true);P.v*=0.3;s.gone=1;renderHUD();if(NEST.hearts<=0){nestFall();break;}toast('冷たい手が、ふれた！');}}
    s.eye.visible=true;s.eye.position.set(p.x,p.y+1.62,p.z);s.eye.material.opacity=0.7+0.3*Math.sin(clock*7+p.x);}
  if(NEST.fight)$('hurt').style.opacity=Math.max(NEST.inv>0.7?0.5:0,NEST.hearts===1?0.3+0.1*Math.sin(clock*5):0);
  NEST.hudT-=dt;if(NEST.hudT<=0){NEST.hudT=0.25;renderHUD();}}
// out from the command table (hqCommand in p5q_hq.js)
function sortieScript(i){const N=NESTS[i];return[
  ['fade','out'],['call',()=>{applyD2();SAVE.flags.sortie=i+1;D2_last();}],['ura',true],['time',23.2,0],['warp',...URA_START],['call',()=>nestStart(i)],
  ['cam',[URA_START[0]+9,G(URA_START[0],URA_START[1])+3,URA_START[1]-4],[URA_START[0]-2,G(URA_START[0],URA_START[1])+1.2,URA_START[1]],1.2,'cut'],['fade','in'],
  ['say','tome','（無線の声）……ザザッ……聞こえるかい、ナギ。今夜の目標は「'+N.name+'」だよ。','赤く光ってるのが見えたら、それが巣だ。影の住人には、見つかるんじゃないよ。'],
  ...(i===0?[['say','ミオの声','（ナギ……巣の中には、向こうに残された子たちが閉じこめられてるの）','（灯りで焼いて。そうすれば、あの子たちは光のほうへ帰れる）']]:[]),
  ['cam','off']];}
function D2_last(){const D=d2();D.last=SAVE.day;save();}
