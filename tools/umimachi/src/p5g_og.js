
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
const ogBusy=()=>!!(OG.run||OG.van);
function ogHUD(tr){tr.hidden=false;tr.innerHTML='';const b=document.createElement('b'),s=document.createElement('span'),m=document.createElement('span');s.className='step';m.className='meter';
  if(OG.run){b.textContent='逃げろ！';s.textContent=OG.run.o.hint;const g=OG.run.o.to;m.textContent=`のこり ${Math.round(Math.hypot(P.x-g[0],P.z-g[1]))} m`;}
  else{b.textContent='黒いバンを止めろ！';s.textContent='W で蹴って追いつく。バンのうしろにぴったりつけたら勝ち';const d=Math.max(0,Math.round(Math.hypot(P.x-VAN.x,P.z-VAN.z)-2.6));
    m.textContent=`バンまで ${d} m　ねばり ${'■'.repeat(Math.round(OG.van.near/0.5))}${'□'.repeat(Math.max(0,5-Math.round(OG.van.near/0.5)))}`;}
  tr.append(b,s,m);}
// the end of the van chase: a camera beside the stopped van
function ogEndCam(){const k=OG.men[0],x=VAN.x-1.2,z=VAN.z-1.6;k.g.visible=true;k.g.position.set(x,G(x,z),z);k.g.rotation.y=Math.atan2(P.x-x,P.z-z);poseHuman(k,'stand',0.016,{});
  setCam([[VAN.x+4,G(VAN.x,VAN.z)+2.2,VAN.z-5.5],[VAN.x,G(VAN.x,VAN.z)+1.1,VAN.z],2,'cut']);}
function updateOG(dt){
  if(OG.scene)for(const c of CARS)if(c!==VAN){c.g.visible=false;c.box.on=false;}   // no traffic while the van is parked for the scene
  if(SAVE.drones&&!SAVE.flags.drones_cleared)SAVE.flags.drones_cleared=1;   // saves from before the story
  if(SAVE.flags.ending_org&&!OG.van){VAN.scripted=true;VAN.g.visible=false;VAN.box.on=false;}   // the van was taken away
  if(OG.run){const R=OG.run,o=R.o;R.t+=dt;const v=Math.min(8.4,6.2+R.t*0.08);
    for(const h of OG.men){const p=h.g.position,dx=P.x-p.x,dz=P.z-p.z,d=Math.hypot(dx,dz);p.x+=dx/d*v*dt;p.z+=dz/d*v*dt;p.y=G(p.x,p.z);h.g.rotation.y=Math.atan2(dx,dz);poseHuman(h,'walk',dt,{rate:13});
      if(d<1.3){$('fade').style.opacity=1;setTimeout(()=>{$('fade').style.opacity=0;},500);toast('つかまった……！ もう一度',true);ogPlace();break;}}
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
