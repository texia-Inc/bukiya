/* ---------- the end of the extra story "オーシャンゲート" (ex1 8 → 10): the lantern, 裏海街 and the town's long night.
     8  the morning after the truth: grandma gives Nagi the old guard's lantern, lit from the lighthouse
     9  at night through the west tunnel into 裏海街: Mio's blue light leads to Sota on the beach, the shadows stunned by the
        lantern (L / the button, three charges that come back slowly); then the big shadow chases them both to the tunnel.
        Out on the coast road the town holds the line: shadow drones, then the shadows climbing out of the sea, driven back by
        the lantern; last the giant out of the sea, and the lighthouse's beam turned on it. Dawn: Sota home, Kurosaki's
        warning, and grandma opens the rock door in the east hill (the base of 海街自警団, the second story)
    10  done (ex1_done) ---------- */
const SOTA_LOOK={skin:'#e3b088',hair:'#1c1a1a',style:'short',cap:'#3a7bd5',shirt:'#f2c230',bottom:'shorts',bottomCol:'#3a6b8a',shoe:'#3a7bd5',scale:0.78};
const EX1R={sota:null,follow:false,trail:[],wisp:null,beam:null,giant:null,door:null,doorT:0};
const rescueOn=()=>URA.on&&SAVE.flags.ex1===9;
const lanternOn=()=>DEF.on||rescueOn();
// Mio's light in 裏海街: along the coast road to the beach where Sota is
const RESCUE_WP=[[-200,COAST_Z+1],[-168,COAST_Z+1],[-134,COAST_Z+1],[-104,COAST_Z+2],[-86,SHORE+6],[-74,SHORE+10]];
const SOTA_AT=[-72,SHORE+13];
/* ----- the lantern: a flash of the lighthouse's light. Shadows near it are stunned (in 裏海街) or driven back into the sea
   (on the coast road); the big one stops and loses you for a moment ----- */
const LAN={n:3,max:3,re:0,t:0,lt:null,fx:null};
const lanMeter=()=>'ランタン '+'●'.repeat(LAN.n)+'○'.repeat(LAN.max-LAN.n);
function lanternFlash(){if(LAN.n<1){toast('ランタンの灯りが、まだたまっていない');return;}LAN.n--;LAN.re=0;LAN.t=1;buzz('medium');
  if(!LAN.lt){LAN.lt=new THREE.PointLight('#ffd890',0,34,1.4);scene.add(LAN.lt);LAN.fx=glow('#ffe2a0',0,0,0,1);}
  const R=13,dd=(x,z)=>Math.hypot(P.x-x,P.z-z);
  if(URA.on)for(const s of URA.shadows){const p=s.h.g.position;if(dd(p.x,p.z)<R){s.stun=6;s.sus=0;}}
  if(URA.chase&&URA.big){const bg=URA.big.h.g.position,d=dd(bg.x,bg.z);
    if(d<22){URA.chase.stun=3.5;URA.chase.mode='roam';URA.chase.wait=0;const k=Math.min(6,30-d)/(d||1);bg.x-=(P.x-bg.x)*k*0.25;bg.z-=(P.z-bg.z)*k*0.25;URA.chase.tx=bg.x;URA.chase.tz=bg.z;
      toast('大きな影が、光にひるんだ！ いまのうちに');}}
  if(DEF.on)for(const s of DEF.list)if(!s.gone&&dd(s.g.position.x,s.g.position.z)<R+1){s.gone=1;DEF.killed++;}
  renderHUD();}
function updateLantern(dt){if(LAN.n<LAN.max){LAN.re+=dt;if(LAN.re>=(DEF.on?1.6:16)){LAN.n++;LAN.re=0;renderHUD();}}
  if(!LAN.lt)return;LAN.t=Math.max(0,LAN.t-dt*1.4);const k=LAN.t;
  LAN.lt.intensity=k*3;LAN.lt.position.set(P.x,P.y+1.6,P.z);LAN.fx.visible=k>0;LAN.fx.position.set(P.x,P.y+1.2,P.z);LAN.fx.scale.setScalar(2+24*(1-k));LAN.fx.material.opacity=k*0.7;}
/* ----- Sota: found on the beach of 裏海街, then at her heels ----- */
function rescueSota(mode,x,z,yaw){if(!EX1R.sota){EX1R.sota=makeHuman(SOTA_LOOK);world.add(EX1R.sota.g);}const h=EX1R.sota;h.g.visible=!!mode;EX1R.mode=mode;EX1R.follow=false;EX1R.trail=[];
  if(!mode)return;x=x==null?SOTA_AT[0]:x;z=z==null?SOTA_AT[1]:z;h.g.position.set(x,G(x,z)+paveY(x,z),z);h.g.rotation.y=yaw==null?Math.PI*0.85:yaw;poseHuman(h,mode,0.016,{});}
function sotaStep(dt){const h=EX1R.sota;if(!h||!h.g.visible&&!URA.hide)return;
  if(!EX1R.follow){poseHuman(h,EX1R.mode||'stand',dt,{look:Math.hypot(P.x-h.g.position.x,P.z-h.g.position.z)<9?player.g.position:null});return;}
  h.g.visible=!URA.hide;const T=EX1R.trail,last=T[T.length-1];
  if(!last||Math.hypot(P.x-last[0],P.z-last[1])>6){T.length=0;T.push([P.x-Math.sin(P.yaw)*1.8,P.z-Math.cos(P.yaw)*1.8],[P.x,P.z]);}
  else if(Math.hypot(P.x-last[0],P.z-last[1])>0.3)T.push([P.x,P.z]);
  // the point 1.4 m back (and a step aside) along where she went
  let need=1.4,i=T.length-1,px=P.x,pz=P.z,x=px,z=pz;
  while(i>=0){const d=Math.hypot(T[i][0]-px,T[i][1]-pz);if(d>=need){const k=need/d;x=px+(T[i][0]-px)*k;z=pz+(T[i][1]-pz)*k;break;}need-=d;px=x=T[i][0];pz=z=T[i][1];i--;}
  if(i>0)T.splice(0,i);
  {const dx=P.x-x,dz=P.z-z,l=Math.hypot(dx,dz);if(l>0.3){x+=dz/l*1.1;z-=dx/l*1.1;}}   // a step to her side, out of the camera's way
  const g=h.g.position,sp=Math.hypot(x-g.x,z-g.z)/Math.max(dt,1e-3);if(sp>0.05)h.g.rotation.y=Math.atan2(x-g.x,z-g.z);
  g.set(x,G(x,z)+paveY(x,z),z);poseHuman(h,sp>0.6?'walk':'stand',dt,{rate:3+Math.min(sp,9)*0.9});}
/* ----- Mio's light: it floats a little way ahead, to the next point after the one nearest her ----- */
function rescueStart(){LAN.n=LAN.max;LAN.re=0;if(!EX1R.wisp)EX1R.wisp=glow('#7fd0ff',0,0,0,1.3);EX1R.wisp.visible=true;EX1R.wisp.position.set(RESCUE_WP[0][0],G(...RESCUE_WP[0])+1.6,RESCUE_WP[0][1]);rescueSota(false);}
function wispStep(dt){const w=EX1R.wisp;if(!w)return;w.visible=rescueOn()&&!URA.chase&&!SAVE.flags.x_found;if(!w.visible)return;
  let n=0,bd=1e9;RESCUE_WP.forEach(([x,z],k)=>{const d=Math.hypot(P.x-x,P.z-z);if(d<bd){bd=d;n=k;}});
  const [tx,tz]=RESCUE_WP[Math.min(n+1,RESCUE_WP.length-1)],ty=G(tx,tz)+1.6+Math.sin(clock*2)*0.25,k=Math.min(1,dt*1.5);
  w.position.x+=(tx-w.position.x)*k;w.position.y+=(ty-w.position.y)*k;w.position.z+=(tz-w.position.z)*k;w.material.opacity=0.6+0.35*Math.sin(clock*4);}
/* ----- the town's defense: the shadows climb out of the sea onto the beach and walk for the coast road. A flash of the
   lantern near them sends them back; five that reach the road and the town's lights go out, and it starts again ----- */
const DEF={on:false,list:[],total:14,killed:0,lives:5,spawned:0,spawnT:0,res:null,hudT:0};
function defendP(){return new Promise(res=>{ST.actor=null;talkNpc=null;Object.assign(DEF,{on:true,res,killed:0,lives:5,spawned:0,spawnT:1});LAN.n=LAN.max;
  toast(hasTouch?'海から上がってくる影に近づいて、「ランタン」ボタンで追いはらえ':'海から上がってくる影に近づいて、L キーで追いはらえ',true);renderHUD();});}
function defHUD(tr){tr.hidden=false;tr.innerHTML='';const b=document.createElement('b');b.textContent='町を守れ';const s=document.createElement('span');s.className='step';
  s.textContent='海から上がってくる影を、海岸通りに入れるな。近くでランタンを光らせると追いはらえる（灯りはすぐたまる）';
  const m=document.createElement('span');m.className='meter';m.textContent=`追いはらった ${DEF.killed} / ${DEF.total}　町の灯り ${'●'.repeat(DEF.lives)}${'○'.repeat(5-DEF.lives)}　${lanMeter()}`;tr.append(b,s,m);}
function defSpawn(){const h=makeHuman(SHADE),x=TRUTH.x-42+rnd()*84,z=SHORE+12+rnd()*6;world.add(h.g);h.g.position.set(x,SEA_Y-1.8,z);h.g.rotation.y=Math.PI;
  DEF.list.push({h,g:h.g,eye:glow('#ff3020',0,0,0,0.9),up:0,sp:1.5+rnd()*0.8+DEF.spawned*0.04,gone:0,fade:0});DEF.spawned++;}
function defClear(){for(const s of DEF.list){world.remove(s.g);scene.remove(s.eye);}DEF.list.length=0;}
function updateDefend(dt){if(!DEF.on)return;const busy=!!(DLG||modal);
  DEF.spawnT-=dt;const alive=DEF.list.filter(s=>!s.gone).length;
  if(!busy&&DEF.spawned<DEF.total&&alive<5&&DEF.spawnT<=0){defSpawn();DEF.spawnT=1.4+rnd()*0.9;}
  for(const s of DEF.list.slice()){const p=s.g.position;
    if(s.gone){s.fade+=dt*1.6;const k=Math.min(1,s.fade);s.g.scale.set(1-k*0.6,1-k*0.9,1-k*0.6);p.z+=dt*3;s.eye.visible=false;
      if(rnd()<dt*25)sparks(new THREE.Vector3(p.x,p.y+1,p.z),1,'#ffe2a0',2,0.05);
      if(k>=1){world.remove(s.g);scene.remove(s.eye);DEF.list.splice(DEF.list.indexOf(s),1);}continue;}
    const gy=Math.max(G(p.x,p.z),SEA_Y-0.4);
    if(s.up<1){s.up=Math.min(1,s.up+dt*0.7);p.y=lerp(SEA_Y-1.8,gy,s.up);poseHuman(s.h,'stand',dt,{});}
    else if(!busy){p.z-=s.sp*dt;p.y=Math.max(G(p.x,p.z)+paveY(p.x,p.z),SEA_Y-0.4);poseHuman(s.h,'walk',dt,{rate:3.6});}
    s.eye.visible=true;s.eye.position.set(p.x,p.y+1.62,p.z);s.eye.material.opacity=0.7+0.3*Math.sin(clock*7+p.x);
    if(p.z<COAST_Z-1){s.gone=1;s.fade=0.5;DEF.lives--;buzz('heavy',true);toast(DEF.lives>0?`影が町に入った！ 町の灯り のこり${DEF.lives}`:'町の灯りが、消えてしまった……',true);
      if(DEF.lives<=0){DEF.on=false;setTimeout(()=>{defClear();Object.assign(DEF,{on:true,killed:0,lives:5,spawned:0,spawnT:2});LAN.n=LAN.max;toast('もう一度！ 影を海岸通りに入れるな',true);renderHUD();},2600);}}}
  if(DEF.on&&DEF.spawned>=DEF.total&&DEF.list.every(s=>s.gone)){DEF.on=false;toast('影を、海へ追い返した！',true);const r=DEF.res;setTimeout(()=>{defClear();renderHUD();r();},1500);}
  DEF.hudT-=dt;if(DEF.hudT<=0){DEF.hudT=0.25;renderHUD();}}
/* ----- the giant out of the sea, and the lighthouse's beam turned on it (applyLight takes EX1R.beam over its own turn) ----- */
const GIANT={x:30,z:345},GS=22;   // the giant's spot out in the bay and its size
function giantRise(){if(!EX1R.giant){const h=makeHuman(SHADE);h.g.scale.setScalar(GS);world.add(h.g);EX1R.giant={h,eye:glow('#ff3020',0,0,0,24)};}
  const G0=EX1R.giant;G0.h.g.visible=G0.eye.visible=true;G0.h.g.position.set(GIANT.x,SEA_Y-40,GIANT.z);G0.h.g.rotation.y=Math.PI;G0.h.g.scale.setScalar(GS);G0.t=0;G0.mode='rise';}
function giantStep(dt){const G0=EX1R.giant;if(!G0||!G0.h.g.visible)return;G0.t+=dt;const g=G0.h.g;poseHuman(G0.h,'stand',dt,{});
  if(G0.mode==='rise')g.position.y=lerp(SEA_Y-40,SEA_Y-13,clamp(G0.t/4,0,1)**0.6);
  else{const k=clamp(G0.t/3.5,0,1);g.position.y=lerp(SEA_Y-13,SEA_Y-50,k*k);g.scale.setScalar(GS*(1-k*0.5));
    if(rnd()<dt*40)sparks(new THREE.Vector3(GIANT.x+(rnd()-0.5)*20,g.position.y+26+rnd()*12,GIANT.z),1,'#ffe2a0',6,0.8);if(k>=1){g.visible=G0.eye.visible=false;}}
  const s=g.scale.x;G0.eye.position.set(g.position.x,g.position.y+1.62*s,g.position.z-0.3*s);G0.eye.material.opacity=G0.mode==='rise'?0.85+0.15*Math.sin(clock*5):Math.max(0,1-G0.t);}
// the beam swings round from wherever it was to the giant (the lamp's two cones point along x; rotation.y = θ aims (cos θ, −sin θ))
function beamAt(){const p=NIGHT.beam.position;return Math.atan2(-(GIANT.z-p.z),GIANT.x-p.x);}
function beamTurnP(){return new Promise(res=>{let a0=NIGHT.beam.rotation.y,a1=beamAt();a1=a0+Math.atan2(Math.sin(a1-a0),Math.cos(a1-a0));let t=0;
  const f=()=>{t+=1/60;const k=clamp(t/2.2,0,1);EX1R.beam=lerp(a0,a1,k*k*(3-2*k));if(k<1)setTimeout(f,16);else res();};f();});}
function giantFall(){const G0=EX1R.giant;G0.mode='fall';G0.t=0;}
/* ----- the rock door in the east hill (Oceangate has the west one): shut, then opened at dawn, and left open for the second story ----- */
const ROCK_DOOR={x:228,z:-60};
function rockDoor(){if(EX1R.door)return EX1R.door;const g=new THREE.Group(),x=ROCK_DOOR.x,z=ROCK_DOOR.z,e=0.8;
  const gx=(G(x+e,z)-G(x-e,z))/(2*e),gz=(G(x,z+e)-G(x,z-e))/(2*e),yaw=Math.atan2(-gx,-gz);   // facing downhill
  g.position.set(x,G(x,z),z);g.rotation.y=yaw;world.add(g);
  const rock=tm('#6f6a62'),dk=tm('#4d4943'),moss=tm('#5d7046');
  for(const [px,py,pz,s] of [[-2.6,1.4,-0.6,1.9],[2.6,1.5,-0.6,2],[0,3.6,-0.8,2.4],[-1.6,3.2,-1,1.6],[1.8,3.3,-1,1.7]]){const m=new THREE.Mesh(new THREE.DodecahedronGeometry(s,0),rock);m.position.set(px,py,pz);m.scale.set(1,0.85,0.8);m.rotation.set(px,py,pz);m.castShadow=true;outline(m,0.03);g.add(m);}
  const light=new THREE.Mesh(new THREE.PlaneGeometry(2.4,3.0),new THREE.MeshBasicMaterial({color:'#ffcf7a'}));light.position.set(0,1.5,-0.25);g.add(light);
  const halves=[-1,1].map(sx=>{const m=new THREE.Mesh(new THREE.BoxGeometry(1.25,3.1,0.4),dk);m.position.set(sx*0.62,1.55,0);m.castShadow=true;outline(m,0.025);g.add(m);
    const v=new THREE.Mesh(new THREE.BoxGeometry(1.0,0.5,0.06),moss);v.position.set(0,1.2-sx*0.4,0.22);m.add(v);return m;});
  const c=collide(x-2,x+2,z-2,z+2,'prop',G(x,z)+3.2);EX1R.door={g,halves,light,c,open:0};g.visible=false;c.on=false;return EX1R.door;}
function doorStep(dt){const D=EX1R.door;if(!D)return;const show=!!SAVE.flags.x_door&&AREA==='town'&&!URA.on;D.g.visible=show;D.c.on=show;if(!show)return;
  const want=SAVE.flags.x_door>1?1:0;D.open+=(want-D.open)*Math.min(1,dt*0.9);for(const [i,m] of D.halves.entries())m.position.x=(i?1:-1)*(0.62+D.open*1.3);}
function updateRescue(dt){updateLantern(dt);sotaStep(dt);wispStep(dt);updateDefend(dt);giantStep(dt);if(SAVE.flags.x_door)rockDoor();doorStep(dt);
  if(lanternOn())$('lightBtn').textContent=lanMeter();else if($('lightBtn').textContent!=='ライト')$('lightBtn').textContent='ライト';
  if(DEF.on)$('lightBtn').hidden=false;}
function rescueHUD(tr){tr.hidden=false;tr.innerHTML='';const b=document.createElement('b');b.textContent='裏海街';const s=document.createElement('span');s.className='step';
  s.textContent='ミオの青い光を追って、ソウタくんを探す。影に見つかりそうになったら、ランタンを光らせてひるませる';
  const m=document.createElement('span');m.className='meter';m.textContent=lanMeter();tr.append(b,s,m);}
const EX1B_EVENTS=[
  {id:'x4_morning',when:{flags:{ex1:8}},script:[
    ['if',{test:()=>Math.hypot(P.x-HOME[0],P.z-HOME[1])>12},[['fade','out'],['warp',...HOME],['fade','in']]],
    ['cam','npc','tome',3.4],
    ['say','tome','おはよう、ナギ。……ゆうべは、よく眠れなかったろう。'],
    ['say','','ばあちゃんは、古いランタンをナギの前に置いた。真鍮の枠に、厚いガラス。'],
    ['say','tome','30年前、自警団で使っていたランタンさ。けさ、釣りのおじさんに島まで船を出してもらってね。灯台の灯りを、分けてもらったんだよ。'],
    ['say','tome','異界の者は、灯台の灯りがなにより苦手でね。かかげれば、しばらくひるんで動けなくなる。','ただし、一度光らせたら、灯りがたまるまで少し待つんだよ。'],
    ['say','nagi','（ガラスの中で、小さな灯りがゆらゆらしている。……あったかい）'],
    ['say','tome','裏海街への道は、夜にしか開かない。日が暮れたら、西のトンネルへお行き。','ミオちゃんの声を、よく聞くんだよ。'],
    ['set','x_lantern'],['set','ex1',9],['cam','off'],
    ['call',()=>toast(hasTouch?'夜になったら、西のトンネルへ（裏海街では「ランタン」ボタンで光らせる）':'夜になったら、西のトンネルへ（裏海街では L キーでランタンを光らせる）',true)]]},
  {id:'x4_tunnel',on:{near:[-210,COAST_Z+1.1,8]},when:{flags:{ex1:9,in_ura:0},phase:'night'},script:[
    ['cam',[-203,G(-203,COAST_Z)+2.6,COAST_Z+6],[-226,G(-226,COAST_Z)+1.5,COAST_Z+1],1.2,'cut'],
    ['say','','夜の西のトンネル。奥の暗がりから、つめたい風が吹いてくる。'],
    ['call',()=>ex1Marble(true)],
    ['say','ミオの声','（ナギ……こっち。わたしの光を、追いかけて）'],
    ['call',()=>ex1Marble(false)],
    ['say','nagi','（ソウタくん、待ってて）'],
    ['fade','out'],['ura',true],['call',rescueStart],['time',23.3,0],['cam','off'],['warp',...URA_START],
    ['cam',[URA_START[0]+9,G(URA_START[0],URA_START[1])+3,URA_START[1]-4],[URA_START[0]-2,G(URA_START[0],URA_START[1])+1.2,URA_START[1]],1.2,'cut'],['fade','in'],
    ['say','','トンネルを抜けると、色のない海街。……30年前に止まったままの町。'],
    ['say','','霧の中に、青い光がひとつ、ふわりと浮かんでいた。'],
    ['say','ミオの声','（影の住人は、前しか見ていない。歩けば、足音は小さいよ）','（見つかりそうになったら、ランタンを光らせて。ソウタくんは、浜辺にいる）'],
    ['cam','off']]},
  {id:'x4_sota',on:{near:[SOTA_AT[0],SOTA_AT[1],6]},when:{flags:{ex1:9,in_ura:1}},script:[
    ['call',()=>rescueSota('sit')],['set','x_found'],
    ['cam',[SOTA_AT[0]-3,G(...SOTA_AT)+1.6,SOTA_AT[1]-4.5],[SOTA_AT[0],G(...SOTA_AT)+0.7,SOTA_AT[1]],1.5,'cut'],
    ['say','','波打ちぎわに、小さな背中がうずくまっていた。'],
    ['say','nagi','ソウタくん！'],
    ['call',()=>rescueSota('stand',null,null,Math.atan2(P.x-SOTA_AT[0],P.z-SOTA_AT[1]))],
    ['say','sota','……おねえちゃん？ ほんとに、おねえちゃん……？','夜中に、だれかに呼ばれた気がして……気がついたら、ここにいたんだ。','色がなくて、だれもいなくて……ずっと、こわかった。'],
    ['say','nagi','もう大丈夫。いっしょに帰ろう。'],
    ['call',()=>ex1Marble(true)],
    ['say','ミオの声','（ナギ、急いで。大きいのが来る……！ 西のトンネルまで走って！）'],
    ['call',()=>ex1Marble(false)],
    ['say','','背後で、地面がきしむ音がした。ふり返ると、霧の向こうに、家よりも大きな影。'],
    ['say','sota','おねえちゃん……！'],
    ['say','nagi','手をはなさないで！ 走るよ！'],
    ['cam','off'],['call',()=>{EX1R.follow=true;}],
    ['chase'],
    ['fade','out'],['ura',false],['call',()=>{rescueSota('stand',TRUTH.x+GATHER.tome[0]+19.2,TRUTH.z+GATHER.tome[1]+0.4,Math.PI);ex1Gather(true);ex1Kurosaki(true);}],
    ['time',23.8,0],['warp',TRUTH.x+4,TRUTH.z,-Math.PI/2],
    ['cam',[TRUTH.x+6,TRUTH.y+3.6,TRUTH.z-9],[TRUTH.x+2,TRUTH.y+1,TRUTH.z+2],1.5,'cut'],['fade','in'],
    ['say','','トンネルを転がり出て、海岸通りまで走りぬけると、みんなが待っていた。'],
    ['say','tome','ナギ！ ソウタ！ ……よかった。よかったねえ。'],
    ['say','sota','ばあちゃん……！'],
    ['say','黒崎','喜ぶのはあとだ。……見ろ。'],
    ['cam',[TRUTH.x,TRUTH.y+4,TRUTH.z-6],[TRUTH.x,TRUTH.y,TRUTH.z+40],1.2,'cut'],
    ['say','','海のほうから、霧が押しよせてくる。ブウウン……と、色のない羽音。','波打ちぎわから、影の住人が、つぎつぎにはい上がってきた。'],
    ['say','baker','影のドローンまで連れてきやがった。ナギちゃん、まずは上だ！ おれの道具を使え！'],
    ['say','tome','そのあとは、浜から上がってくる影だよ。ランタンで追いはらうんだ。','町に、一匹も入れるんじゃないよ！'],
    ['cam','off'],
    ['drones',{total:8,title:'霧の中の影のドローンを落とせ'}],
    ['say','baker','（無線の声）上は片づいた！ ナギちゃん、浜だ！'],
    ['call',defendP],
    ['fade','out'],['warp',TRUTH.x+4,TRUTH.z,-Math.PI/2],['call',giantRise],
    ['cam',[GIANT.x-16,TRUTH.y+2.4,COAST_Z+4],[GIANT.x,SEA_Y+20,GIANT.z],1.2,'cut'],['fade','in'],
    ['wait',1.5],
    ['say','','そのとき、海が、ふくれあがった。','霧の中から、山のような影が立ち上がる。……町を見下ろす、ふたつの赤い目。'],
    ['say','黒崎','まずい……！ あれが上がってきたら、結界どころじゃない！'],
    ['call',()=>ex1Marble(true)],
    ['say','ミオの声','（ナギ、ランタンを灯台に向けて！ 灯台の灯りを、あいつに！）'],
    ['ask','nagi','（どうする？）',[['ランタンを、灯台にかかげる',[]],['……おねがい、ミオ！',[]]]],
    ['call',()=>{LAN.n=LAN.max;lanternFlash();ex1Marble(false);}],
    ['cam',[TRUTH.x-6,TRUTH.y+3,TRUTH.z-4],[(GIANT.x+ISL.x)/2,30,(GIANT.z+ISL.z)/2],1.2,'cut'],
    ['call',beamTurnP],
    ['say','','島の灯台の光が、ぐるりと向きを変えた。まっすぐ、大きな影の胸へ。'],
    ['call',giantFall],
    ['cam',[GIANT.x-16,TRUTH.y+2.4,COAST_Z+4],[GIANT.x,SEA_Y+16,GIANT.z],1.2,'cut'],
    ['wait',1],
    ['say','','光につらぬかれた影は、声にならない声をあげて、霧といっしょに海へしずんでいった。'],
    ['wait',1.5],
    ['call',()=>{EX1R.beam=null;}],
    ['say','sota','……やった。やったよ、おねえちゃん！'],
    ['say','ミオの声','（ありがとう、ナギ。……向こうの子たちにも、灯りが見えたよ）'],
    // dawn
    ['fade','out'],['call',()=>rescueSota(false)],['set','sota_back'],['time',5.4,0],
    ['cam',[TRUTH.x+2,TRUTH.y+3.2,TRUTH.z-8],[TRUTH.x,TRUTH.y+1.5,TRUTH.z+30],1.2,'cut'],['fade','in'],
    ['say','','夜が明けた。霧は晴れて、海はいつもの色にもどっていた。'],
    ['say','','ソウタくんのお母さんが、浜へ走ってきて、ソウタくんを抱きしめた。……何度も、何度も。'],
    ['cam',[TRUTH.x+1,TRUTH.y+1.8,TRUTH.z+6.5],[TRUTH.x-3,TRUTH.y+1.3,TRUTH.z],1.5,'cut'],
    ['say','黒崎','……今夜のは、ほんの先ぶれだ。灯台の灯りがあるかぎり、道は開く。','次は、もっと大きなものが来るぞ。'],
    ['say','黒崎','オーシャンゲートは、この町に残る。結界を張りなおすまでな。……トメさん、あんたたちも、もう一度やる気か。'],
    ['say','tome','わかりきったことを聞くんじゃないよ。'],
    ['say','tome','ナギ、ついておいで。見せたいものがある。'],
    ['fade','out'],['call',()=>{ex1Gather(false);ex1Kurosaki(false);SAVE.flags.x_door=1;rockDoor();}],['time',6.2,0],
    ['call',()=>{const D=rockDoor(),p=D.g.position,a=D.g.rotation.y;setCam([[p.x+Math.sin(a)*11+Math.cos(a)*3,p.y+3.4,p.z+Math.cos(a)*11-Math.sin(a)*3],[p.x,p.y+1.8,p.z],1.2,'cut']);
      P.x=p.x+Math.sin(a)*5;P.z=p.z+Math.cos(a)*5;P.yaw=a+Math.PI;P.y=G(P.x,P.z);P.v=0;camInit=false;}],['fade','in'],
    ['say','','町の東の山。草にうもれた岩の前で、ばあちゃんが杖をついた。'],
    ['say','tome','山の中に、わたしたちの基地がある。30年、眠らせておいたけどね。'],
    ['call',()=>{SAVE.flags.x_door=2;}],['wait',0.5],
    ['say','','ゴゴゴゴ……。岩の扉が、ゆっくりと左右に開いていく。','奥から、あたたかい灯りがもれてきた。'],
    ['wait',1.5],
    ['say','tome','海街自警団は、今日からまた始まるよ。','ナギ。……あんたも、来てくれるかい。'],
    ['say','nagi','うん。……この町は、わたしが守る。'],
    ['say','','――追加ストーリー1「オーシャンゲート」　おしまい。'],
    ['set','ex1_done'],['set','ex1',10],
    ['ask','','追加ストーリー2「海街自警団」――山の中の基地を立てなおし、町をおそう異界の者と戦う。',[
      ['くわしく見る',[['say','','追加ストーリー2「海街自警団」は、ただいま準備中です。','基地の施設をきたえて、武器と力を強くし、オーシャンゲートといっしょに異界の者を迎えうつ物語。','配信まで、もうしばらくお待ちください。']]],
      ['あとで',[]]]],
    ['fade','out'],['cam','off'],['warp',...HOME],['day']]},
];
EVENTS.splice(EVENTS.findIndex(e=>e.id==='dusk'),0,...EX1B_EVENTS);
