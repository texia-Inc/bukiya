
/* ---------- the Oceangate route "シーサイド・コンスピラシー": Kurosaki and his men in black, running after Nagi on foot,
   and the last chase after the black van along the coast road. Nobody is hit; the board is the weapon. ---------- */
const SUIT={skin:'#e9c3a4',hair:'#15130f',style:'short',shirt:'#1d1f24',sleeves:'long',vest:'#2a2d33',bottom:'pants',bottomCol:'#1d1f24',shoe:'#0e0e10',glasses:true};
const OG={men:[],boss:null,run:null,van:null};
function ogMan(o){const h=makeHuman(Object.assign({},SUIT,o||{}));h.g.visible=false;world.add(h.g);return h;}
for(let k=0;k<3;k++)OG.men.push(ogMan(k===0?{hair:'#3a3a3a',shirt:'#f2f2ee',vest:'#1d1f24'}:{}));   // the first is Kurosaki: grey hair, white shirt
// the scene by the parked van: the van stops on the coast road by the east tunnel and the men stand round it
const OG_PARK=[200,COAST_Z+2.2];
function ogScene(on){VAN.scripted=on;OG.scene=on;if(!on)for(const h of OG.men)h.g.visible=false;for(const c of CARS)if(c!==VAN){c.g.visible=!on;c.box.on=!on;}if(on){VAN.x=OG_PARK[0];VAN.z=OG_PARK[1];VAN.v=0;VAN.g.position.set(VAN.x,G(VAN.x,VAN.z)+0.02,VAN.z);VAN.g.rotation.y=-Math.PI/2;
    const hl=VAN.g.userData.len/2+0.1;Object.assign(VAN.box,{x0:VAN.x-hl,x1:VAN.x+hl,z0:VAN.z-0.9,z1:VAN.z+0.9,top:G(VAN.x,VAN.z)+1.9,on:true});}
  OG.men.forEach((h,k)=>{h.g.visible=on;if(on){const x=OG_PARK[0]-2+k*2.2,z=OG_PARK[1]-2.4-(k%2)*0.6;h.g.position.set(x,G(x,z),z);h.g.rotation.y=Math.PI*(k?0.9:1.1);}});}
// the men run after you: get to the goal before one of them reaches you; caught, you start the run again
function pursuitP(o){return new Promise(res=>{ST.actor=null;talkNpc=null;OG.run={o,res,t:0};ogPlace();if(!OG.mark){OG.mark=marker(MK.target);OG.mark.scale.set(1.6,1.6,1);}renderHUD();});}
function ogPlace(){const o=OG.run.o;P.x=o.from[0];P.z=o.from[1];P.yaw=o.from[2];P.v=0;P.y=G(P.x,P.z);rideNow();camInit=false;OG.run.t=0;
  const F=[Math.sin(P.yaw),Math.cos(P.yaw)];OG.men.forEach((h,k)=>{const x=P.x-F[0]*(15+k*2)+(k-1)*2,z=P.z-F[1]*(15+k*2);h.g.visible=true;h.g.position.set(x,G(x,z),z);});}
// the van runs west along the coast road; catch up with its back bumper before it reaches the tunnel
function vanChaseP(){return new Promise(res=>{ST.actor=null;talkNpc=null;VAN.scripted=true;VAN.x=175;VAN.z=COAST_Z+2.2;VAN.v=9;
  P.x=203;P.z=COAST_Z+2.2;P.yaw=-Math.PI/2;P.v=6;P.y=G(P.x,P.z);rideNow();camInit=false;OG.van={res,t:0,near:0};$('fade').style.opacity=0;
  if(!OG.mark){OG.mark=marker(MK.target);OG.mark.scale.set(1.6,1.6,1);}renderHUD();});}
const ogBusy=()=>!!(OG.run||OG.van||OG.trail);
function ogHUD(tr){if(OG.trail)return trailHUD(tr);tr.hidden=false;tr.innerHTML='';const b=document.createElement('b'),s=document.createElement('span'),m=document.createElement('span');s.className='step';m.className='meter';
  if(OG.run){b.textContent='逃げろ！';s.textContent=OG.run.o.hint;const g=OG.run.o.to;m.textContent=`のこり ${Math.round(Math.hypot(P.x-g[0],P.z-g[1]))} m`;}
  else{b.textContent='黒いバンを止めろ！';s.textContent=devText('W で蹴って追いつく。バンのうしろにぴったりつけたら勝ち');const d=Math.max(0,Math.round(Math.hypot(P.x-VAN.x,P.z-VAN.z)-2.6));
    m.textContent=`バンまで ${d} m　ねばり ${'■'.repeat(Math.round(OG.van.near/0.5))}${'□'.repeat(Math.max(0,5-Math.round(OG.van.near/0.5)))}`;}
  tr.append(b,s,m);}
// the end of the van chase: a camera beside the stopped van
function ogEndCam(){const k=OG.men[0],x=VAN.x-1.2,z=VAN.z-1.6;k.g.visible=true;k.g.position.set(x,G(x,z),z);k.g.rotation.y=Math.atan2(P.x-x,P.z-z);poseHuman(k,'stand',0.016,{});
  setCam([[VAN.x+4,G(VAN.x,VAN.z)+2.2,VAN.z-5.5],[VAN.x,G(VAN.x,VAN.z)+1.1,VAN.z],2,'cut']);}
function updateOG(dt){
  if(OG.trail)trailStep(dt);
  if(OG.scene)for(const c of CARS)if(c!==VAN){c.g.visible=false;c.box.on=false;}   // no traffic while the van is parked for the scene
  if(SAVE.drones&&!SAVE.flags.drones_cleared)SAVE.flags.drones_cleared=1;   // saves from before the story
  if(SAVE.flags.ending_org&&!OG.van&&!SAVE.flags.ex1){VAN.scripted=true;VAN.g.visible=false;VAN.box.on=false;}   // the van was taken away
  if(OG.run){const R=OG.run,o=R.o;R.t+=dt;const v=Math.min(8.4,6.2+R.t*0.08);
    for(const h of OG.men){const p=h.g.position,dx=P.x-p.x,dz=P.z-p.z,d=Math.hypot(dx,dz);p.x+=dx/d*v*dt;p.z+=dz/d*v*dt;p.y=G(p.x,p.z);h.g.rotation.y=Math.atan2(dx,dz);poseHuman(h,'walk',dt,{rate:13});
      if(d<1.3){$('fade').style.opacity=1;setTimeout(()=>{$('fade').style.opacity=0;},500);toast('つかまった……！ もう一度',true);R.t=0;ogPlace();break;}}
    OG.mark.visible=true;OG.mark.position.set(o.to[0],G(o.to[0],o.to[1])+3.2+Math.sin(clock*3)*0.12,o.to[1]);ogHUD($('tracker'));
    if(Math.hypot(P.x-o.to[0],P.z-o.to[1])<o.to[2]){OG.run=null;OG.mark.visible=false;for(const h of OG.men)h.g.visible=false;R.res();}}
  if(OG.van){const C=OG.van;C.t+=dt;VAN.v=Math.min(12.2,9+C.t*0.25);VAN.x-=VAN.v*dt;
    for(const c of CARS)if(c!==VAN){c.g.visible=false;c.box.on=false;}   // the coast road is cleared for the chase
    VAN.g.position.set(VAN.x,G(clamp(VAN.x,-CUT_X,CUT_X),VAN.z)+0.02,VAN.z);VAN.g.rotation.y=-Math.PI/2;for(const w of VAN.g.userData.wheels)w.rotation.x+=VAN.v*dt/0.3;
    const hl=VAN.g.userData.len/2+0.1;Object.assign(VAN.box,{x0:VAN.x-hl,x1:VAN.x+hl,z0:VAN.z-0.9,z1:VAN.z+0.9,top:G(VAN.x,VAN.z)+1.9,on:true});
    const behind=P.x-VAN.x,close=behind>hl&&behind<hl+3.2&&Math.abs(P.z-VAN.z)<1.6;C.near=close?C.near+dt:Math.max(0,C.near-dt*0.5);
    OG.mark.visible=true;OG.mark.position.set(VAN.x,G(VAN.x,VAN.z)+3.6+Math.sin(clock*3)*0.12,VAN.z);ogHUD($('tracker'));
    if(C.near>=2.5){OG.van=null;OG.scene=true;OG.mark.visible=false;VAN.v=0;C.res(true);}   // traffic stays away until the scene ends (['ogscene',false])
    else if(VAN.x<-CUT_X+6){toast('逃げられた……！ もう一度',true);VAN.x=175;P.x=203;P.z=COAST_Z+2.2;P.yaw=-Math.PI/2;P.v=6;P.y=G(P.x,P.z);camInit=false;C.t=0;C.near=0;}}}

/* ---------- the extra story "オーシャンゲート": the old iron door in the retaining wall by the west tunnel, and the tail.
   The van drives slowly through town to the door. Keep it in sight, but keep out of the men's: when it stops, one gets out
   and looks back down the road. Close by, the board is heard; in his sight for too long, and they know. ---------- */
const OG_DOOR={x:-219,z:234.7};
// a squat concrete block sticking out of the bank, an iron door in its face: it looks like something for the tunnel's upkeep
{ const y=G(OG_DOOR.x,OG_DOOR.z+0.6),g=new THREE.Group();g.position.set(OG_DOOR.x,y,OG_DOOR.z);world.add(g);OG_DOOR.y=y;OG_DOOR.g=g;
  const conc=tm('#b9b4aa'),iron=tm('#5d5a54'),rust=tm('#7a4e34');
  const blk=M(new THREE.BoxGeometry(3.4,3.3,4.2),conc,0.03);blk.position.set(0,1.45,-2.1);g.add(blk);
  const cap=M(new THREE.BoxGeometry(3.7,0.25,4.5),conc,0.02);cap.position.set(0,3.2,-2.1);g.add(cap);
  const fr=M(new THREE.BoxGeometry(1.7,2.5,0.12),tm('#3e3c38'),0.02);fr.position.set(-0.4,1.25,0.04);g.add(fr);
  const dr=M(new THREE.BoxGeometry(1.36,2.25,0.1),iron,0.015);dr.position.set(-0.4,1.15,0.1);g.add(dr);OG_DOOR.door=dr;
  for(const yy of [0.5,1.85]){const h=M(new THREE.BoxGeometry(1.2,0.08,0.04),rust);h.position.set(-0.4,yy,0.17);g.add(h);}
  const sign=new THREE.Mesh(new THREE.PlaneGeometry(0.9,0.42),tmap(canvasTex(192,90,(c,w,h)=>{c.fillStyle='#f2efe6';c.fillRect(0,0,w,h);c.fillStyle='#c8372d';c.fillRect(0,0,w,26);
    c.fillStyle='#fff';c.font=signFont(18,true);c.textAlign='center';c.textBaseline='middle';c.fillText('管理用通路',w/2,14);c.fillStyle='#2b2520';c.font=signFont(17,true);c.fillText('関係者以外',w/2,46);c.fillText('立入禁止',w/2,70);})));
  sign.position.set(1.05,1.6,0.02);g.add(sign);
  collide(OG_DOOR.x-1.75,OG_DOOR.x+1.75,OG_DOOR.z-4.3,OG_DOOR.z,'prop',y+3.3);
  OG_DOOR.lamp=glow('#ff4030',OG_DOOR.x-0.4,y+2.75,OG_DOOR.z+0.2,0.7);}
// the van's way: east along なか通り, down 西の坂道, then west on the coast road to the door. It stops twice on the way
const TRAIL_WP=[[96,90.2],[-112,90.2],[-118,94],[-118,150],[-118,COAST_Z-2],[-124,COAST_Z+1.8],[-160,COAST_Z+1.8],[OG_DOOR.x+4,COAST_Z+0.6],[OG_DOOR.x+0.5,OG_DOOR.z+3.2]];
const TRAIL_STOPS=[{at:[-112,90.2],look:Math.PI/2},{at:[-118,190],look:Math.PI},{at:[-160,COAST_Z+1.8],look:Math.PI/2}];
const TRAIL_LEN=(()=>{let s=0;const L=[0];for(let i=1;i<TRAIL_WP.length;i++){s+=Math.hypot(TRAIL_WP[i][0]-TRAIL_WP[i-1][0],TRAIL_WP[i][1]-TRAIL_WP[i-1][1]);L.push(s);}return L;})();
TRAIL_STOPS.forEach(s=>{let best=0,bd=1e9;for(let i=1;i<TRAIL_WP.length;i++){const a=TRAIL_WP[i-1],b=TRAIL_WP[i],dx=b[0]-a[0],dz=b[1]-a[1],l=Math.hypot(dx,dz),
  t=clamp(((s.at[0]-a[0])*dx+(s.at[1]-a[1])*dz)/(l*l),0,1),d=Math.hypot(a[0]+dx*t-s.at[0],a[1]+dz*t-s.at[1]);if(d<bd){bd=d;best=TRAIL_LEN[i-1]+l*t;}}s.s=best;});
function trailAt(s){let i=1;while(i<TRAIL_WP.length-1&&TRAIL_LEN[i]<s)i++;const a=TRAIL_WP[i-1],b=TRAIL_WP[i],l=TRAIL_LEN[i]-TRAIL_LEN[i-1]||1,t=clamp((s-TRAIL_LEN[i-1])/l,0,1);
  return{x:lerp(a[0],b[0],t),z:lerp(a[1],b[1],t),yaw:Math.atan2(b[0]-a[0],b[1]-a[1])};}
// can the man see her? Nothing tall (a house, a wall, a parked car) on the line between his eyes and her
function ogSight(x0,z0,y0,x1,z1,y1){const d=Math.hypot(x1-x0,z1-z0),n=Math.ceil(d/0.7);
  for(let k=1;k<n;k++){const t=k/n,x=lerp(x0,x1,t),z=lerp(z0,z1,t),y=lerp(y0,y1,t);
    for(const c of COLL){if(!c.on||c.tag==='step')continue;if(x>c.x0&&x<c.x1&&z>c.z0&&z<c.z1&&(c.top==null||c.top>y))return false;}}return true;}
function trailP(){return new Promise(res=>{ST.actor=null;talkNpc=null;OG.trail={res,s:0,v:0,stop:-1,stopT:0,sus:0,lost:0,caught:0,hudT:0};trailPlace();$('fade').style.opacity=0;
  if(!OG.mark){OG.mark=marker(MK.target);OG.mark.scale.set(1.6,1.6,1);}renderHUD();});}
function trailPlace(){const T=OG.trail;T.s=0;T.v=0;T.stop=-1;T.stopT=0;T.sus=0;T.lost=0;T.next=0;VAN.scripted=true;VAN.g.visible=true;
  P.x=128;P.z=90.2;P.yaw=-Math.PI/2;P.v=0;P.y=G(P.x,P.z);P.foot=true;P.carry='back';camInit=false;for(const h of OG.men)h.g.visible=false;trailVan();}
function trailVan(){const T=OG.trail,a=trailAt(T.s);VAN.x=a.x;VAN.z=a.z;VAN.g.position.set(a.x,G(a.x,a.z)+0.02,a.z);VAN.g.rotation.y=a.yaw;
  const hl=VAN.g.userData.len/2+0.1,c=Math.abs(Math.sin(a.yaw)),s=Math.abs(Math.cos(a.yaw));Object.assign(VAN.box,{x0:a.x-(hl*c+0.9*s),x1:a.x+(hl*c+0.9*s),z0:a.z-(hl*s+0.9*c),z1:a.z+(hl*s+0.9*c),top:G(a.x,a.z)+1.9,on:true});return a;}
function trailHUD(tr){const T=OG.trail;tr.hidden=false;tr.innerHTML='';const b=document.createElement('b'),s=document.createElement('span'),m=document.createElement('span');s.className='step';m.className='meter';
  b.textContent='黒いバンをつけろ';s.textContent=T.stop>=0?'男がうしろを見ている！ 家や車のかげに隠れて、やり過ごす':T.lost>0?'バンが遠い！ 見失わないように追いかける':'近づきすぎず、見失わずに。スケボーの音は近くだと気づかれる';
  const n=Math.round(T.sus*5);m.textContent=`あやしまれ度 ${'■'.repeat(n)}${'□'.repeat(5-n)}`;tr.append(b,s,m);}
async function trailRetire(){const T=OG.trail;T.asking=true;const i=await askP('',`${T.caught}回見つかってしまった……。どうする？`,['もう少しがんばる','先に進む（リタイア）']);T.asking=false;
  if(OG.trail!==T)return;if(i===0)return;T.s=TRAIL_LEN[TRAIL_LEN.length-1];P.x=OG_DOOR.x+16;P.z=COAST_Z-4;P.y=G(P.x,P.z);P.yaw=-Math.PI/2;camInit=false;}
function trailStep(dt){const T=OG.trail;if(T.asking||T.pause)return;const end=TRAIL_LEN[TRAIL_LEN.length-1],man=OG.men[1];
  for(const c of CARS)if(c!==VAN){c.g.visible=false;c.box.on=false;}
  // the van: slow in town, stopping where the man gets out to look back
  if(T.stop>=0){T.stopT+=dt;if(T.stopT>6.5){T.stop=-1;man.g.visible=false;}}
  else{const st=TRAIL_STOPS[T.next];const tv=st&&st.s-T.s<10?Math.max(0.6,(st.s-T.s)*0.7):end-T.s<12?Math.max(0.8,(end-T.s)*0.5):6.2;
    T.v+=(tv-T.v)*Math.min(1,dt*1.5);T.s=Math.min(end,T.s+T.v*dt);
    if(st&&T.s>=st.s-0.3){T.stop=T.next;T.next++;T.stopT=0;T.v=0;}}
  const a=trailVan();for(const w of VAN.g.userData.wheels)w.rotation.x+=T.v*dt/0.3;
  const back=[-Math.sin(a.yaw),-Math.cos(a.yaw)],hl=VAN.g.userData.len/2;
  const dx=P.x-a.x,dz=P.z-a.z,d=Math.hypot(dx,dz),loud=!P.foot&&P.v>3;
  let see=0;
  if(T.stop>=0){const st=TRAIL_STOPS[T.stop],mx=a.x+back[0]*(hl+1),mz=a.z+back[1]*(hl+1),my=G(mx,mz);man.g.visible=true;
    const look=Math.atan2(back[0],back[1])+Math.sin(T.stopT*1.1)*0.75;man.g.position.set(mx,my,mz);man.g.rotation.y=look;poseHuman(man,'stand',dt,{});
    const ex=P.x-mx,ez=P.z-mz,ed=Math.hypot(ex,ez)||1,face=(Math.sin(look)*ex+Math.cos(look)*ez)/ed;
    if(T.stopT>0.8&&ed<40&&face>0.55&&ogSight(mx,mz,my+1.6,P.x,P.z,P.y+(P.foot?1.2:1.0)))see=ed<15?1.6:ed<28?1:0.6;
    if(loud&&ed<16)see=Math.max(see,0.8);}
  else{if(d<9)see=0.5;if(loud&&d<14)see=Math.max(see,0.7);}
  T.sus=clamp(T.sus+(see?dt*see*0.55:-dt*0.25),0,1);$('hurt').style.opacity=T.sus*0.6;
  T.lost=d>58?T.lost+dt:0;
  OG.mark.visible=true;OG.mark.position.set(a.x,G(a.x,a.z)+3.6+Math.sin(clock*3)*0.12,a.z);
  T.hudT-=dt;if(T.hudT<=0){T.hudT=0.2;trailHUD($('tracker'));}
  const fail=T.sus>=1?'気づかれた……！':T.lost>4?'見失った……！':null;
  if(fail){T.caught++;$('fade').style.opacity=1;$('hurt').style.opacity=0;toast(fail+' もう一度',true);
    T.pause=true;setTimeout(()=>{if(OG.trail!==T)return;trailPlace();T.pause=false;$('fade').style.opacity=0;if(T.caught%3===0)trailRetire();},700);return;}
  if(T.s>=end-0.05){OG.trail=null;OG.mark.visible=false;$('hurt').style.opacity=0;man.g.visible=false;T.res();}}
// once the men are inside: the van stays parked by the door until the scene is over
function trailDone(){VAN.scripted=false;VAN.x=-30;VAN.z=COAST_Z+2.2;VAN.v=0;VAN.g.rotation.y=-Math.PI/2;for(const c of CARS){c.g.visible=true;c.box.on=true;}}
