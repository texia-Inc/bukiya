
/* ---------- skateboard tricks: in the air, K (or the 技 button) turns the board, and which way depends on the stick or keys
   held at the moment: nothing a kickflip, back a heelflip, forward a varial flip, turning a 360 shove-it (a 540 with height to
   spare); press again in the air and the next one follows (two kickflips are a double flip). Come down on a rail and you grind
   along it — a 50-50 straight on, a boardslide coming in at an angle; Space pops you off. Each trick shows its name; land with
   the board still turning and you fall. In a fight they count: in the air after a trick, and on a rail, nothing can touch her;
   the tricks of a jump, landed, are worth seconds (the marble's wait in 鏡の海; elsewhere the lantern fills that much sooner and
   her shots burn twice as hard for as long), and a big one (three seconds or more) knocks the shadows round her back.
   Back and turning together, it is a body varial: she turns right round over the board, which stays where it is (with a flip
   in the same jump, a combo, worth more). On the ground K starts a manual (forward held, a nose manual): up on two wheels, kept
   level with forward and back; it is worth seconds as it goes, a jump out of it carries them into the air, and K just before
   coming down lands her straight back into one, so a line of them runs on. Off balance the line is lost; K again, or too slow,
   and it is paid. ---------- */
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

// bank: the seconds the tricks of this jump are worth (paid on a clean landing), last: the trick before, next: one pressed while
// another was still turning
const TRICK={name:'',sub:'',shown:0,airT:0,grab:0,bank:0,last:null,next:null,boostT:0,fx:[],jk:0,manQ:0,manNose:false,links:0};
const TRICK_NAME={flip:'キックフリップ',heel:'ヒールフリップ',varial:'バリアルフリップ',spin:'360ショービット',s540:'540ショービット',double:'ダブルフリップ',
  body:'ボディバリアル',man:'マニュアル',nose:'ノーズマニュアル',grind:'50-50グラインド',slide:'ボードスライド',grab:'インディーグラブ'};
// how far each turns the board (z: over, about its length; y: round, flat), how long it takes, and its worth in seconds
const TRICK_KIND={flip:{z:1,y:0,d:0.42,b:2},heel:{z:-1,y:0,d:0.42,b:2.5},varial:{z:1,y:0.5,d:0.5,b:2.5},spin:{z:0,y:1,d:0.42,b:2},
  s540:{z:0,y:1.5,d:0.6,b:3.5},double:{z:1,y:0,d:0.42,b:1.5},body:{z:0,y:-1,d:0.55,b:2.5},grab:{b:1}};
function trickAdd(kind){if(!TRICK_NAME[kind])return;TRICK.name=TRICK_NAME[kind];TRICK.sub='';TRICK.shown=1.1;if(TRICK_KIND[kind])TRICK.bank+=TRICK_KIND[kind].b;if(MIR.on)echoCopy(kind);
  // a flip and a body varial in the same jump: a combo
  const jk=TRICK.jk|(kind==='body'?2:TRICK_KIND[kind]&&TRICK_KIND[kind].z?1:0);if(jk===3&&TRICK.jk!==3){TRICK.bank+=1.5;TRICK.sub='コンボ ＋1.5秒';}TRICK.jk=jk;trickHUD();}
function trickHUD(){const el=$('trick');if(TRICK.shown<=0||state!=='play'){el.hidden=true;return;}el.hidden=false;el.innerHTML='';
  const a=document.createElement('div');a.className='tn';a.textContent=TRICK.name;el.appendChild(a);
  if(TRICK.sub){const b=document.createElement('div');b.className='ts';b.textContent=TRICK.sub;el.appendChild(b);}}
// landing with the board still turning is a fall; what the jump's tricks were worth is paid now (only 鏡の海 has a use for it)
function trickLand(clean){TRICK.jk=0;
  // K pressed just before coming down: straight into a manual, the seconds carried on
  if(clean&&TRICK.manQ>clock&&!P.foot&&!P.grind){TRICK.manQ=0;TRICK.last=TRICK.next=null;manStart(TRICK.manNose,true);return;}
  const b=Math.round(TRICK.bank*10)/10;TRICK.bank=0;TRICK.last=TRICK.next=null;TRICK.manQ=0;TRICK.links=0;
  const mir=MIR.on&&MIR.go&&!MIR.end;if(!clean)toast(mir?'失敗……　ビー玉の待ちが1秒のびた':'失敗……',false);if(mir)mirTrickLand(clean,b);else if(clean&&b>0&&trickFight())trickPay(b);if(RUN.go)runTrickLand(clean,b);}
// the fights out in the town (the drones, the shadows of the nests, the shore, the lord of the other side)
const trickFight=()=>!!(DRONE.active||DEF.on||BOSS.on||RUN.go);
// a jump with a trick in it, or a rail: up there the cold hands, the drones' shots and the dark orbs cannot reach her
const trickSafe=()=>!!(P.grind||P.air&&(P.trick||TRICK.bank>0));
// a jump's tricks landed in a fight: the lantern fills sooner, the shots burn harder for a while, and a big one knocks the
// shadows back (each fight walks its own list)
function trickPay(b){if(LAN.n<LAN.max)LAN.re+=b;TRICK.boostT=clock+b;const subs=DRONE.active?[`光 ×2（${b}秒）`]:[];if(LAN.n<LAN.max)subs.push(`ランタン −${b}秒`);
  if(b>=3){const n=trickWave(DEF.on?DEF.list:BOSS.on?BOSS.list:RUN.go?RUN.foes:[]);if(n)subs.unshift('影をはじき飛ばした！');}
  TRICK.sub=subs.join('　');TRICK.shown=Math.max(TRICK.shown,1.4);trickHUD();renderHUD();}
// how hard her shots hit just now
const trickDmg=()=>clock<(TRICK.boostT||0)?2:1;
// a ring of light out from her board: the shadows in the list near her are thrown back and stand stunned for a moment
function trickWave(list){const R=7;let n=0;
  for(const s of list){if(s.gone||s.up<1)continue;const p=s.g.position,dx=p.x-P.x,dz=p.z-P.z,d=Math.hypot(dx,dz)||1;if(d>R)continue;
    p.x+=dx/d*(R-d+2);p.z+=dz/d*(R-d+2);s.stun=1.2;n++;sparks(new THREE.Vector3(p.x,p.y+1,p.z),6,'#ffe2a0',4,0.06);}
  const w=new THREE.Mesh(new THREE.RingGeometry(0.8,1,48),new THREE.MeshBasicMaterial({color:'#ffe2a0',transparent:true,opacity:0.6,blending:THREE.AdditiveBlending,depthWrite:false,side:THREE.DoubleSide,fog:false}));
  w.rotation.x=-Math.PI/2;w.position.set(P.x,P.y+0.08,P.z);scene.add(w);TRICK.fx.push({m:w,t:0});buzz('heavy',true);return n;}
// the seconds of air she has left: what decides whether there is time for a 540
function airLeft(){const h=Math.max(0,P.y-groundAt(P.x,P.z,P.y));return(P.vy+Math.sqrt(Math.max(0,P.vy*P.vy+27*h)))/13.5;}
// starting a trick in the air: which one from what is held; pressed while one is turning, it goes next
function trickStart(I){if(P.foot||P.grind)return;
  if(!P.air){if(P.man)manEnd(true);else if(P.v>2.2)manStart(!!I.fwd,false);return;}
  if(P.trick){TRICK.next={fwd:I.fwd,back:I.back,turn:I.turn};return;}
  // too near the ground to turn the board: it is a manual waiting for the landing
  if(airLeft()<0.3){TRICK.manQ=clock+0.45;TRICK.manNose=!!I.fwd;return;}
  const turning=Math.abs(I.turn)>0.4||Math.abs(P.turn)>0.4;
  let type=turning?(I.back?'body':I.fwd?'varial':airLeft()>0.8?'s540':'spin'):I.back?'heel':I.fwd?'varial':'flip';
  if(type==='flip'&&(TRICK.last==='flip'||TRICK.last==='double'))type='double';
  P.trick={type,t:0,dir:(I.turn||P.turn)>0?-1:1};}
// called every frame from stepPlayer while she is in the air on the board
function trickAir(dt){TRICK.airT+=dt;
  if(player.pose&&player.pose.gr>0.6&&!TRICK.grab){TRICK.grab=1;trickAdd('grab');}   // the indy grab near the top of a big jump
  if(P.trick){P.trick.t+=dt/TRICK_KIND[P.trick.type].d;if(P.trick.t>=1){trickAdd(P.trick.type);TRICK.last=P.trick.type;P.trick=null;if(TRICK.next){const n=TRICK.next;TRICK.next=null;trickStart(n);}}}
  // catching a rail on the way down
  // no catching while slow, or just after leaving a rail (otherwise a stop on the rail drops you straight back onto it)
  if(P.vy>4||P.v<2.5||clock<(P.grindCD||0))return;const F=[Math.sin(P.yaw),Math.cos(P.yaw)];
  for(const r of RAILS){if(r.run&&!RUN.go)continue;const dx=r.x1-r.x0,dz=r.z1-r.z0,L=Math.hypot(dx,dz),ux=dx/L,uz=dz/L;
    const t=clamp(((P.x-r.x0)*ux+(P.z-r.z0)*uz)/L,0,1),px=r.x0+dx*t,pz=r.z0+dz*t;if(Math.hypot(P.x-px,P.z-pz)>0.8)continue;
    const ry=railY(r,px,pz),al=F[0]*ux+F[1]*uz;if(P.y<ry-0.5||P.y>ry+1.1||Math.abs(al)<0.7||t<=0||t>=1)continue;
    // a board still flipping cannot catch the rail; caught clean, it is a landing
    TRICK.manQ=0;if(P.trick){trickLand(false);P.trick=null;}else trickLand(true);
    // straight on, a 50-50; at an angle, a boardslide (the board across the rail, only how she looks: the camera keeps along it)
    const sl=Math.abs(al)<0.9,rot=sl?(F[0]*uz-F[1]*ux>0?1:-1)*Math.PI/2:0;
    P.grind={r,t,dir:Math.sign(al),L,ux,uz,sc:0,rot};P.air=false;P.vy=0;P.x=px;P.z=pz;P.y=ry;P.yaw=Math.atan2(ux*P.grind.dir,uz*P.grind.dir);trickAdd(sl?'slide':'grind');return;}}
// a manual: up on the back wheels (the front ones for a nose manual); link: landed into from a jump, a step in a line
function manStart(nose,link){P.man={nose,bal:0,t:0,ph:Math.random()*9};if(link){TRICK.links++;TRICK.bank+=1;}
  trickAdd(nose?'nose':'man');if(TRICK.links)TRICK.sub=`つなぎ ×${TRICK.links}`;TRICK.shown=1.2;trickHUD();}
// called every frame from stepPlayer while she is in one: the board wants to tip, the stick (or W / S) holds it level, and the
// seconds count up as she goes
function manStep(dt,I,onFoot,busy){const m=P.man;if(onFoot||busy||P.v<1.5){manEnd(true);return;}
  m.t+=dt;TRICK.bank+=dt*(m.nose?0.9:0.6);
  const hold=stick.on?clamp(-stick.y*1.4,-1,1):I.fwd?1:I.back?-1:0,wob=(0.5*Math.sin(m.t*1.7+m.ph)+0.35*Math.sin(m.t*3.1+m.ph*2))*(1+m.t*0.08);
  m.bal+=((m.bal*1.4+wob)-hold*2.2)*dt;
  if(Math.abs(m.bal)>=1){manEnd(false);return;}
  TRICK.sub=(TRICK.links?`つなぎ ×${TRICK.links}　`:'')+`${TRICK.bank.toFixed(1)}秒`;TRICK.shown=Math.max(TRICK.shown,0.4);trickHUD();
  const el=$('manBar');el.hidden=false;el.firstChild.style.left=`${50+m.bal*46}%`;el.classList.toggle('warn',Math.abs(m.bal)>0.65);}
// out of it: kept level (K again, or too slow) it is paid like a landing; off balance the board drops and the line is lost
function manEnd(clean){P.man=null;$('manBar').hidden=true;if(!clean){TRICK.bank=0;TRICK.links=0;P.v*=0.6;P.bump=0.3;}trickLand(clean);}
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
  player.g.position.set(P.x,P.y,P.z);player.g.rotation.set(0,P.yaw+(g.rot||0),0);player.root.rotation.set(0,0,0);
  poseSkater(player,dt,{v:P.v,turn:0,push:false,brake:false,air:false,grind:true});}
function updateTricks(dt){if(!P.man&&!$('manBar').hidden)$('manBar').hidden=true;if(TRICK.shown>0){TRICK.shown-=dt;if(TRICK.shown<=0)$('trick').hidden=true;}
  for(const f of TRICK.fx.slice()){f.t+=dt/0.5;f.m.scale.setScalar(1+f.t*6);f.m.material.opacity=0.6*(1-f.t);if(f.t>=1){scene.remove(f.m);f.m.geometry.dispose();f.m.material.dispose();TRICK.fx.splice(TRICK.fx.indexOf(f),1);}}
  $('bTrick').hidden=!hasTouch||state!=='play'||P.foot;}
