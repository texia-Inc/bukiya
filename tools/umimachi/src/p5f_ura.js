
/* ---------- the horror route "トンネルの向こう": 裏海街, the town on the other side of the west tunnel, stopped thirty years ago.
   The same streets, drained of colour and sunk in fog; nobody about but the faceless shadows walking their beats and the tram
   running with no driver. Nagi looks for three things Mio left behind by flashlight (L), keeping out of the shadows' sight —
   skating is loud, walking (F) is quiet, the light carries far. Seen for too long and a cold hand sends you back to the tunnel.
   After the third, the big shadow comes, and the only way out is the tunnel, on the board. ---------- */
const URA_START=[-222,COAST_Z+1.1,Math.PI/2],URA_EXIT=[-226,COAST_Z+1.1,5];
const URA_CLUES=[{id:'photo',name:'駅のホーム',x:62,z:TRAM_Z-1.5},{id:'marble',name:'駄菓子まるや',x:SHOPS.dagashi.door[0],z:SHOPS.dagashi.door[1]},{id:'diary',name:'神社の本殿',x:SHRINE.x,z:-157.5}];
const URA_BEATS=[[-45,-20,45,-20],[0,-120,0,-35],[0,40,0,190],[-150,COAST_Z,-30,COAST_Z],[25,COAST_Z+1,150,COAST_Z+1],[40,TRAM_Z-4,100,TRAM_Z-4],[SHRINE.x,-131,SHRINE.x,-152],[-120,-140,-120,60]];
const URA={on:false,shadows:[],sus:0,chase:null,mood:new THREE.Color('#3a4a44'),fog:new THREE.Color('#1a2420')};
const SHADE={skin:'#141518',hair:'#0b0b0d',style:'short',shirt:'#1b1c21',sleeves:'long',bottom:'pants',bottomCol:'#121316',shoe:'#0b0b0d'};
const torch=new THREE.SpotLight('#fff1d0',0,30,0.42,0.55,1);scene.add(torch);scene.add(torch.target);let torchOn=false;
const uraGlints=URA_CLUES.map(c=>{const g=glow('#bfefff',c.x,G(c.x,c.z)+0.9,c.z,1.4);return g;});
const omochi=makeCat({col:'#f2f2ee'});omochi.g.visible=false;world.add(omochi.g);
function uraEnter(){URA.on=true;SAVE.flags.in_ura=1;canvas.style.filter='saturate(.28) sepia(.3) hue-rotate(-12deg) brightness(.96)';
  if(!URA.shadows.length)URA_BEATS.forEach(([x0,z0,x1,z1],k)=>{const h=makeHuman(SHADE);world.add(h.g);
    const eye=glow('#ff3020',0,0,0,0.9);URA.shadows.push({h,a:[x0,z0],b:[x1,z1],t:(k*0.37)%1,dir:1,sus:0,eye});});
  for(const s of URA.shadows){s.h.g.visible=true;s.sus=0;}
  omochi.g.position.set(URA_START[0]+3,G(URA_START[0]+3,URA_START[1]+2)+0.02,URA_START[1]+2);omochi.g.rotation.y=Math.PI/2;omochi.g.visible=true;
  scene.fog.near=12;scene.fog.far=150;renderHUD();}
function uraExit(){URA.on=false;SAVE.flags.in_ura=0;canvas.style.filter='';torchOn=false;torch.intensity=0;scene.fog.near=260;scene.fog.far=2600;
  for(const s of URA.shadows){s.h.g.visible=false;s.eye.visible=false;}omochi.g.visible=false;
  for(const c of CARS){c.g.visible=true;c.box.on=true;}for(const k in folkMesh)folkMesh[k].visible=true;for(const c of CATS)c.g.visible=true;$('hurt').style.opacity=0;$('lightBtn').hidden=true;renderHUD();}
function toggleTorch(){if(!URA.on)return;torchOn=!torchOn;toast(torchOn?'ライトをつけた（遠くまで見えるけど、見つかりやすい）':'ライトを消した');}
const clueLeft=()=>URA_CLUES.filter(c=>!SAVE.flags['clue_'+c.id]);
function uraHUD(tr){tr.hidden=false;tr.innerHTML='';const b=document.createElement('b');b.textContent=URA.chase?'逃げろ！':'裏海街';const s=document.createElement('span');s.className='step';
  s.textContent=URA.chase?'西のトンネルへ。スケボーで走りぬけろ':'影の住人に見つからないように、手がかりを探す。歩くと静か、スケボーとライトは目立つ';
  const m=document.createElement('span');m.className='meter';const L=clueLeft();m.textContent=URA.chase?'':L.length?`手がかり ${3-L.length} / 3　のこり：${L.map(c=>c.name).join('・')}`:'手がかりは そろった';tr.append(b,s,m);}
// the chase: the big shadow comes from behind and gains on you; it pushes you back if it reaches you, and the tunnel ends it
function chaseP(){return new Promise(res=>{ST.actor=null;talkNpc=null;
  if(!URA.big){const h=makeHuman(SHADE);h.g.scale.setScalar(1.9);world.add(h.g);URA.big={h,eye:glow('#ff3020',0,0,0,2.2)};}
  const F=new THREE.Vector3(Math.sin(P.yaw),0,Math.cos(P.yaw)),p=new THREE.Vector3(P.x,0,P.z).addScaledVector(F,-24);
  URA.big.h.g.position.set(p.x,G(p.x,p.z),p.z);URA.big.h.g.visible=URA.big.eye.visible=true;URA.chase={t:0,res,v:6};
  if(!URA.goal){URA.goal=marker(MK.target);URA.goal.scale.set(1.6,1.6,1);}renderHUD();});}
function updateUra(dt){
  if(!URA.on&&SAVE.flags.in_ura&&state==='play')uraEnter();   // a save made in 裏海街 opens there again
  $('lightBtn').hidden=!URA.on;
  if(!URA.on)return;
  // the light of the other side: thick fog, a dead green sky, unlit windows, lamps that flicker
  scene.fog.color.copy(URA.fog);scene.background.copy(URA.fog);dome.material.color.copy(URA.mood);hemi.intensity=0.24;sun.intensity=0.06;
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
    const seen=!URA.chase&&!ST.run&&!DLG&&!modal&&d<R&&(fx*toX+fz*toZ>0.45||d<3);
    s.sus=clamp(s.sus+(seen?dt*(d<5?1.6:1):-dt*0.5),0,1);
    if(s.sus<0.05&&!URA.chase){s.t+=s.dir*dt*1.1/L;if(s.t>1){s.t=1;s.dir=-1;}if(s.t<0){s.t=0;s.dir=1;}}   // walks its beat unless it has noticed you
    const x=lerp(a[0],b[0],s.t),z=lerp(a[1],b[1],s.t);g.position.set(x,G(x,z),z);
    g.rotation.y=s.sus>0.05?Math.atan2(P.x-x,P.z-z):Math.atan2(fx,fz);poseHuman(s.h,'stand',dt,{});
    s.eye.visible=s.sus>0.02;s.eye.position.set(x,G(x,z)+1.62,z);s.eye.material.opacity=s.sus;top=Math.max(top,s.sus);}
  URA.sus=top;$('hurt').style.opacity=URA.chase?0.35+0.15*Math.sin(clock*6):top*0.7;
  if(top>=1&&!ST.run){for(const s of URA.shadows)s.sus=0;runEvent({id:'ura_caught',once:false,script:[
    ['fade','out'],['warp',...URA_START],['fade','in'],['say','','冷たい手が、肩にふれた――。','……気がつくと、トンネルの出口に立っていた。'],['say','nagi','（見つかっちゃだめだ。歩けば、足音は小さい……）']]});}
  // the chase
  const C=URA.chase;if(!C)return;C.t+=dt;C.v=Math.min(11.5,6.5+C.t*0.12);const bg=URA.big.h.g,dx=P.x-bg.position.x,dz=P.z-bg.position.z,dd=Math.hypot(dx,dz);
  bg.position.x+=dx/dd*C.v*dt;bg.position.z+=dz/dd*C.v*dt;bg.position.y=G(bg.position.x,bg.position.z);bg.rotation.y=Math.atan2(dx,dz);poseHuman(URA.big.h,'stand',dt,{});
  URA.big.eye.position.set(bg.position.x,bg.position.y+3.05,bg.position.z);URA.big.eye.material.opacity=0.8+0.2*Math.sin(clock*9);
  URA.goal.visible=true;URA.goal.position.set(URA_EXIT[0],G(URA_EXIT[0],URA_EXIT[1])+3.4+Math.sin(clock*3)*0.12,URA_EXIT[1]);
  if(dd<1.8){P.v*=0.3;P.bump=0.6;bg.position.x-=dx/dd*14;bg.position.z-=dz/dd*14;C.t=Math.max(0,C.t-8);toast('つかまりそう……！ 走って！');}
  if(Math.hypot(P.x-URA_EXIT[0],P.z-URA_EXIT[1])<URA_EXIT[2]){URA.chase=null;bg.visible=URA.big.eye.visible=false;URA.goal.visible=false;C.res();}}
