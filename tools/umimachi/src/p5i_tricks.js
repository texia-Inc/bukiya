
/* ---------- skateboard tricks: in the air, K (or the 技 button) flips the board — a kickflip, or a 360 shove-it when you are
   turning. Come down on a rail and you grind along it; Space pops you off. Each trick shows its name; land with the board still
   turning and you fall. ---------- */
// the rails: handrails both sides of the slope down to the sea (broken at the cross streets) and the pier railings
const RAILS=[];
for(const sx of [-1,1])for(const [a,b] of [[-196,-128],[-112,-28],[-12,82],[98,162],[178,204]])RAILS.push({x0:sx*4.75,z0:a,x1:sx*4.75,z1:b,h:0.5});
for(const x of [PIER.x0+0.1,PIER.x1-0.1])RAILS.push({x0:x,z0:PIER.z0+8,x1:x,z1:PIER.z1-0.4,top:PIER.y+0.9});
const railY=(r,x,z)=>r.top!=null?r.top:G(x,z)+r.h;
{ const metal=tm('#9aa3ab'),posts=[];
  for(const r of RAILS){const L=Math.hypot(r.x1-r.x0,r.z1-r.z0);if(r.top!=null)continue;   // the pier railings are already there
    const a=new THREE.Vector3(r.x0,railY(r,r.x0,r.z0),r.z0),b=new THREE.Vector3(r.x1,railY(r,r.x1,r.z1),r.z1);
    const m=new THREE.Mesh(new THREE.CylinderGeometry(0.035,0.035,a.distanceTo(b),8),metal);m.position.copy(a).add(b).multiplyScalar(0.5);m.lookAt(b);m.rotateX(Math.PI/2);outline(m,0.012);world.add(m);
    for(let t=0;t<=L;t+=3.2){const x=lerp(r.x0,r.x1,t/L),z=lerp(r.z0,r.z1,t/L);posts.push({x,z,y:G(x,z)});}}
  inst(new THREE.CylinderGeometry(0.03,0.03,0.5,6),metal,posts,(e,d)=>{d.position.set(e.x,e.y+0.25,e.z);},{ol:0.01});}

const TRICK={name:'',shown:0,airT:0,grab:0};
const TRICK_NAME={flip:'キックフリップ',spin:'360ショービット',grind:'グラインド',grab:'インディーグラブ'};
// a trick just shows its name for a moment; there is no score
function trickAdd(kind){if(!TRICK_NAME[kind])return;TRICK.name=TRICK_NAME[kind];TRICK.shown=1.1;trickHUD();}
function trickHUD(){const el=$('trick');if(TRICK.shown<=0||state!=='play'){el.hidden=true;return;}el.hidden=false;el.innerHTML='';
  const a=document.createElement('div');a.className='tn';a.textContent=TRICK.name;el.appendChild(a);}
// landing with the board still turning is a fall
function trickLand(clean){if(!clean)toast('失敗……',false);}
// starting a trick in the air
function trickStart(){if(!P.air||P.foot||P.trick||P.grind)return;P.trick={type:Math.abs(P.turn)>0.4?'spin':'flip',t:0};}
// called every frame from stepPlayer while she is in the air on the board
function trickAir(dt){TRICK.airT+=dt;
  if(player.pose&&player.pose.gr>0.6&&!TRICK.grab){TRICK.grab=1;trickAdd('grab');}   // the indy grab near the top of a big jump
  if(P.trick){P.trick.t+=dt/0.42;if(P.trick.t>=1){trickAdd(P.trick.type);P.trick=null;}}
  // catching a rail on the way down
  // no catching while slow, or just after leaving a rail (otherwise a stop on the rail drops you straight back onto it)
  if(P.vy>4||P.v<2.5||clock<(P.grindCD||0))return;const F=[Math.sin(P.yaw),Math.cos(P.yaw)];
  for(const r of RAILS){const dx=r.x1-r.x0,dz=r.z1-r.z0,L=Math.hypot(dx,dz),ux=dx/L,uz=dz/L;
    const t=clamp(((P.x-r.x0)*ux+(P.z-r.z0)*uz)/L,0,1),px=r.x0+dx*t,pz=r.z0+dz*t;if(Math.hypot(P.x-px,P.z-pz)>0.8)continue;
    const ry=railY(r,px,pz),al=F[0]*ux+F[1]*uz;if(P.y<ry-0.5||P.y>ry+1.1||Math.abs(al)<0.7||t<=0||t>=1)continue;
    if(P.trick){trickLand(false);P.trick=null;}   // a board still flipping cannot catch the rail
    P.grind={r,t,dir:Math.sign(al),L,ux,uz,sc:0};P.air=false;P.vy=0;P.x=px;P.z=pz;P.y=ry;P.yaw=Math.atan2(ux*P.grind.dir,uz*P.grind.dir);trickAdd('grind');return;}}
// on the rail: gravity along it, a little friction, sparks; Space pops off, the rail's end drops you off
function grindStep(dt){const g=P.grind,r=g.r;
  const ry0=railY(r,P.x,P.z),nx=P.x+g.ux*g.dir*0.5,nz=P.z+g.uz*g.dir*0.5,slope=(railY(r,nx,nz)-ry0)/0.5;
  P.v=clamp(P.v+(-9.8*slope*0.5-0.35)*dt,0,16);g.t+=g.dir*P.v*dt/g.L;
  P.x=r.x0+(r.x1-r.x0)*g.t;P.z=r.z0+(r.z1-r.z0)*g.t;P.y=railY(r,P.x,P.z);
  TRICK.shown=Math.max(TRICK.shown,0.4);trickHUD();
  if(Math.random()<dt*25)sparks(new THREE.Vector3(P.x,P.y+0.05,P.z),1,'#ffd27a',2.2,0.035);
  const off=g.t<=0||g.t>=1,pop=jumpQ,slow=P.v<1.2;jumpQ=false;
  if(off||pop||slow){P.grind=null;P.air=true;P.vy=pop?6.8:off?2.2:0;TRICK.airT=0;P.grindCD=clock+0.8;
    if(slow){const cx=r.top!=null?(PIER.x0+PIER.x1)/2:0;P.x+=0.7*(Math.sign(cx-P.x)||1);}}   // too slow: she steps off toward the road (or the middle of the pier); the rails all run along z
  player.g.position.set(P.x,P.y,P.z);player.g.rotation.set(0,P.yaw,0);player.root.rotation.set(0,0,0);
  poseSkater(player,dt,{v:P.v,turn:0,push:false,brake:false,air:false,grind:true});}
function updateTricks(dt){if(TRICK.shown>0){TRICK.shown-=dt;if(TRICK.shown<=0)$('trick').hidden=true;}
  $('bTrick').hidden=!hasTouch||state!=='play'||P.foot;}
