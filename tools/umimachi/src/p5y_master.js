/* ---------- the master of the sea, fought out on 鏡の海 (a night of p5v_mirror.js with MIR.rule.master): the last fight of the
   second story, and a practice from the command table. It stands in the middle of the mirror, from the waist up, a hundred
   metres high, and reaches out with its two hands; the drowned town's roofs and torii are not out tonight, only the flat mirror.
   Round it Mio has hung rails of light, two rings of them: from the mirror in front of it they climb and run round its back.
   Ridden, they hold her line from fading; on the mirror alone she could never ride round anything so big before it faded. The inner ring is short and low and close to its hands; the
   outer one long and high and safe; forks on either side cross between them (the stick held to that side takes the fork), and
   each ring has its gaps at the back to jump. Ridden round its back and brought back to her line on the mirror, the ring closes
   round the whole master: three of those and it sinks to its chin, its head on the mirror, breathing out shadows; three rings
   round the head, and Mio's light comes down on it and it goes under.
   Its hands get in the way: one rises, hangs over where Nagi is going (its red shadow on the mirror) and slams down; then it lies
   on the mirror a while. Lying there, its arm is a rail: up the arm to the shoulder, and onto a ring of light round its neck,
   once round that and the master is ringed, quick, high, and only while the hand stays down. A ring closed round a lying hand
   burns it (gold line twice as hard, the armoury's third level one more); a burnt hand is still, and its arm no way up.
   Now and then the master tears a stretch of the rings away (it glows red first); it comes back after a while.
   In the story her hearts come back when they are gone (Mio's voice); in practice that is the end of the night. ---------- */
// where it stands (from the middle of the mirror), its size, how near she can ride to it (its body, then its sunken head), the
// rings a hand, the body and the head take
const MST_AT=[0,0],MST_S=60,MST_BODY=14,MST_HEADR=9,MST_HAND=4,MST_RINGS=3,MST_HEAD=3;
// the rails: the inner and outer rings (radius, height round the back), the ring round its neck (at its shoulders), the size of
// a hand, how high it hangs, how wide it strikes
const MST_RI=24,MST_HI=10,MST_RO=38,MST_HO=20,MST_RC=16,MST_YC=31,MST_HS=3,MST_UP=26,MST_HIT=10;
const MST={on:false,g:null,body:null,eyes:[],hands:[],head:null,phase:0,t:0,turn:0,cd:0,breath:0,tilt:0,hp:0,ringCD:0,beam:null,res:null,rule:null,
  chunks:[],collar:[],brk:0,via:null};
const mstB=()=>[MIR_X+MST_AT[0],MST_AT[1]];
function mstBuild(){if(MST.g)return;const g=new THREE.Group();MIR.g.add(g);MST.g=g;
  const h=makeHuman(SHADE);h.g.scale.setScalar(MST_S);g.add(h.g);MST.body=h;
  for(const L of h.legs)for(const k of ['th','kn','ft'])if(L[k])L[k].visible=false;   // only from the waist up: the rest is under the mirror
  const gl=(col,s)=>{const e=glow(col,0,0,0,s);scene.remove(e);e.visible=true;g.add(e);return e;};
  MST.eyes=[[0,0,60],[-0.09,-0.06,22],[0.09,-0.06,22]].map(([dx,dy,s])=>{const e=gl('#ff3020',s);e.userData.d=[dx,dy];e.userData.s=e.scale.x;return e;});
  const dark=tm('#16131c');
  const flat=(geo,col,op)=>{const m=new THREE.Mesh(geo,new THREE.MeshBasicMaterial({color:col,transparent:true,opacity:op,blending:THREE.AdditiveBlending,depthWrite:false,side:THREE.DoubleSide,fog:false}));m.rotation.x=-Math.PI/2;g.add(m);return m;};
  const hand=sd=>{const hg=new THREE.Group(),palm=new THREE.Mesh(new THREE.SphereGeometry(1,14,10),dark);palm.scale.set(2.4,0.8,3);hg.add(palm);
    for(let k=0;k<4;k++){const f=new THREE.Mesh(new THREE.BoxGeometry(0.55,0.5,2.6),dark);f.position.set((k-1.5)*1.05,0,3.6);f.rotation.y=(k-1.5)*0.12;hg.add(f);}
    const th=new THREE.Mesh(new THREE.BoxGeometry(0.6,0.5,2),dark);th.position.set(sd*2.6,0,1);th.rotation.y=sd*0.7;hg.add(th);g.add(hg);
    const core=gl('#b070ff',9),arm=new THREE.Mesh(new THREE.CylinderGeometry(2.6,3.8,1,10),dark);g.add(arm);
    // the arm as a rail while the hand lies still: a line of light along its top, and the rail itself (its ends set each frame)
    const lit=new THREE.Mesh(new THREE.CylinderGeometry(0.16,0.16,1,6),new THREE.MeshBasicMaterial({color:'#ffe6a0',fog:false}));g.add(lit);
    const rail={x0:0,z0:0,x1:0,z1:0,y0:0,y1:0,mst:true,keep:14,off:true};RAILS.push(rail);
    return{g:hg,core,arm,lit,rail,mark:flat(new THREE.RingGeometry(MST_HIT-1,MST_HIT-0.3,48),'#b070ff',0.5),warn:flat(new THREE.CircleGeometry(MST_HIT,40),'#ff3020',0),sd,x:0,z:0,y:0,tx:0,tz:0,st:'rest',t:0,hp:MST_HAND,dead:false,fade:0};};
  MST.hands=[hand(-1),hand(1)];
  MST.head={core:gl('#b070ff',16),mark:flat(new THREE.RingGeometry(MST_HEADR+1,MST_HEADR+1.8,48),'#b070ff',0),x:0,y:0,z:0,hp:MST_HEAD};
  mstRails(g);
  MST.beam=new THREE.Mesh(new THREE.CylinderGeometry(10,14,240,24,1,true),new THREE.MeshBasicMaterial({color:'#fff1c8',transparent:true,opacity:0,blending:THREE.AdditiveBlending,depthWrite:false,side:THREE.DoubleSide,fog:false}));g.add(MST.beam);}
// the rails of light, as chains of short straight lengths (3°, so the board turns smoothly round), drawn as smooth tubes in
// stretches of about 30° (a stretch is what the master tears away). r.mst: only there to catch in this fight
function mstRails(g){const [bx,bz]=mstB(),D=Math.PI/180,sm=u=>u*u*(3-2*u),lo=0.35;
  const halo=()=>new THREE.MeshBasicMaterial({color:'#ffcf70',transparent:true,opacity:0.25,blending:THREE.AdditiveBlending,depthWrite:false,fog:false});
  const pt=(R,a,y)=>new THREE.Vector3(bx+R*Math.sin(a*D),Math.max(y,lo),bz+R*Math.cos(a*D));
  // a chain through the points, cut into stretches with a tube each; returns its lengths
  const chain=(pts,tear,loop)=>{const segs=[];
    for(let k=0;k<pts.length-1;k++){const p=pts[k],q=pts[k+1],r={x0:p.x,z0:p.z,x1:q.x,z1:q.z,y0:p.y,y1:q.y,mst:true,keep:14};if(segs.length){segs[segs.length-1].nx=r;r.pv=segs[segs.length-1];}segs.push(r);RAILS.push(r);}
    if(loop){segs[segs.length-1].nx=segs[0];segs[0].pv=segs[segs.length-1];}
    const per=tear?10:segs.length;
    for(let k=0;k<segs.length;k+=per){const s=segs.slice(k,k+per),cp=pts.slice(k,k+s.length+1),cv=new THREE.CatmullRomCurve3(cp,!!loop&&per===segs.length),
        core=new THREE.MeshBasicMaterial({color:'#ffe6a0',fog:false}),ha=halo(),c={segs:s,pts:cp,core,halo:ha,meshes:[],tear,warn:0,gone:0};
      for(const [m,w] of [[core,0.1],[ha,0.36]]){const t=new THREE.Mesh(new THREE.TubeGeometry(cv,s.length*3,w,8,!!loop&&per===segs.length),m);g.add(t);c.meshes.push(t);}
      MST.chunks.push(c);}
    return segs;};
  const ring=(R,a0,a1,yAt)=>{const n=Math.max(1,Math.round(Math.abs(a1-a0)/3)),pts=[];for(let k=0;k<=n;k++){const a=a0+(a1-a0)*k/n;pts.push(pt(R,a,yAt(a)));}return{segs:chain(pts,true),a0,a1,n};};
  const at=(rg,a)=>rg.segs[Math.round((a-rg.a0)/(rg.a1-rg.a0)*rg.n)];   // the length that starts at angle a
  // the inner ring: up from the mirror at 20° and 340°, 7 m round the back, a gap at 180–192
  const iy=a=>a<=180?(a<100?lo+(MST_HI-lo)*sm((a-20)/80):MST_HI):(a>260?lo+(MST_HI-lo)*sm((340-a)/80):MST_HI);
  const iL=ring(MST_RI,20,180,iy),iR=ring(MST_RI,192,340,iy);
  // the outer ring: up from 28° and 332°, 13 m round the back, two gaps (146–154, 206–214)
  const oy=a=>a<=180?(a<108?lo+(MST_HO-lo)*sm((a-28)/80):MST_HO):(a>252?lo+(MST_HO-lo)*sm((332-a)/80):MST_HO);
  const oL=ring(MST_RO,28,146,oy),oM=ring(MST_RO,154,206,oy),oR=ring(MST_RO,214,332,oy);
  // the forks: on the left from the inner ring at 80° out and up to the outer at 115°; on the right from the outer at 244° in and
  // down to the inner at 279°. Each joins its rings both ways
  const fork=(R0,a0,y0,R1,a1,y1,from,to)=>{const pts=[];for(let k=0;k<=12;k++){const u=k/12,e=sm(u);pts.push(pt(lerp(R0,R1,e),lerp(a0,a1,u),lerp(y0,y1,e)));}
    const s=chain(pts,false),f0=s[0],f1=s[s.length-1];from.alt=f0;f0.pv=from;f1.nx=to;to.palt=f1;};
  fork(MST_RI,80,iy(80),MST_RO,115,oy(115),at(iL,77),at(oL,115));
  fork(MST_RO,244,oy(244),MST_RI,279,iy(279),at(oR,241),at(iR,279));
  // the ring round its neck, reached only up an arm (switched on with the arms)
  {const pts=[];for(let k=0;k<=120;k++)pts.push(pt(MST_RC,k*3,MST_YC));const s=chain(pts,false,true);MST.collar=s;for(const r of s)r.off=true;MST.collarChunk=MST.chunks[MST.chunks.length-1];}
  for(const H of MST.hands){const a=H.sd>0?90:270;H.rail.nx=MST.collar[H.sd>0?a/3:a/3-1];}
  // where to jump on: a soft ring of light on the mirror under each low end
  for(const [R,a] of [[MST_RI,20],[MST_RI,340],[MST_RO,28],[MST_RO,332]]){const p=pt(R,a,0),m=new THREE.Mesh(new THREE.RingGeometry(1.6,2.1,32),halo());m.rotation.x=-Math.PI/2;m.position.set(p.x,0.05,p.z);g.add(m);}}
function mstChunk(c,on){c.gone=on?0:1;for(const r of c.segs)r.off=!on;for(const m of c.meshes)m.visible=on;}
// out onto the mirror (from mirScript): the master up at the edge, a hand to either side of it
function mstStart(rule){mstBuild();Object.assign(MST,{on:true,rule,phase:0,t:0,turn:0,cd:5,breath:6,tilt:0,hp:MST_RINGS,ringCD:0,brk:14,via:null});MST.g.visible=true;if(MIR.props)MIR.props.visible=false;
  const [bx,bz]=mstB(),b=MST.body.g;b.position.set(bx,-0.92*MST_S,bz);b.rotation.set(0,0,0);b.scale.setScalar(MST_S);
  for(const c of MST.chunks){if(c!==MST.collarChunk)mstChunk(c,true);c.warn=0;c.core.color.set('#ffe6a0');c.halo.color.set('#ffcf70');}
  MST.hands.forEach(H=>{Object.assign(H,{x:bx+H.sd*26,z:bz+46,y:0,st:'rest',t:0,hp:MST_HAND,dead:false,fade:0});H.g.visible=H.arm.visible=H.core.visible=true;H.g.scale.setScalar(MST_HS);H.warn.material.opacity=0;});
  MST.head.hp=MST_HEAD;MST.head.core.visible=false;MST.head.mark.material.opacity=0;MST.beam.material.opacity=0;for(const e of MST.eyes)e.visible=true;}
function mstStop(){MST.on=false;MST.res=null;if(MST.g)MST.g.visible=false;if(MIR.props)MIR.props.visible=true;for(const H of MST.hands)H.rail.off=true;for(const r of MST.collar)r.off=true;for(const c of MST.chunks)for(const r of c.segs)r.off=true;}
const mstDmg=gold=>(gold?2:1)+(hqLv('arm')>=3?1:0);
// a hand slams down where she is heading: away from the master, inside the open water
function mstAim(H){const v=Math.min(P.v,12);let x=P.x+Math.sin(P.yaw)*v,z=P.z+Math.cos(P.yaw)*v;const l=Math.hypot(x-MIR_X,z);
  if(l>MIR_R-6){x=MIR_X+(x-MIR_X)/l*(MIR_R-6);z=z/l*(MIR_R-6);}
  const [bx,bz]=mstB(),d=Math.hypot(x-bx,z-bz),m=MST_BODY+MST_HIT;if(d<m){x=bx+(x-bx)/(d||1)*m;z=bz+(z-bz)/(d||1)*m;}H.tx=x;H.tz=z;H.ox=H.x;H.oz=H.z;}
function mstSlam(H){H.warn.material.opacity=0;const p=new THREE.Vector3(H.x,mirG(H.x,H.z)+0.3,H.z);sparks(p,30,'#b070ff',10,0.14);sfx.boom&&sfx.boom(0.8);
  const w=new THREE.Mesh(new THREE.RingGeometry(0.8,1,48),new THREE.MeshBasicMaterial({color:'#c090ff',transparent:true,opacity:0.6,blending:THREE.AdditiveBlending,depthWrite:false,side:THREE.DoubleSide,fog:false}));
  w.rotation.x=-Math.PI/2;w.position.copy(p);MIR.g.add(w);MIR.fx.push({m:w,t:0,dur:0.6,kind:'wave'});
  const dx=P.x-H.x,dz=P.z-H.z,d=Math.hypot(dx,dz);P.bump=Math.max(P.bump,d<MST_HIT*2.5?0.5:0.2);
  if(d<MST_HIT&&MIR.inv<=0&&!mirSafe()){MIR.inv=1.3;MIR.hearts--;buzz('heavy',true);P.v*=0.3;const l=d||1;P.x=H.x+dx/l*(MST_HIT+0.5);P.z=H.z+dz/l*(MST_HIT+0.5);renderHUD();
    if(MIR.hearts<=0){mirFinish(false);return;}toast('主の手に、たたかれた！');}
  else buzz('light',true);}
// a stretch of the rings torn away: the one ahead of her if she is up on them, else any; red first, gone a while, then back
function mstTear(){const live=MST.chunks.filter(c=>c.tear&&!c.gone&&!c.warn);if(!live.length)return;
  const F=[Math.sin(P.yaw),Math.cos(P.yaw)],ax=P.x+F[0]*14,az=P.z+F[1]*14,dist=c=>Math.min(...c.pts.map(p=>Math.hypot(p.x-ax,p.z-az)));
  const c=P.grind&&P.grind.r.mst?live.sort((a,b)=>dist(a)-dist(b))[0]:live[Math.floor(rnd()*live.length)];c.warn=1.6;toast('主が、レールをこわそうとしている！');}
function mstTears(dt,run){if(!run||MST.phase!==0)return;MST.brk-=dt;if(MST.brk<=0){MST.brk=13+rnd()*4;mstTear();}
  for(const c of MST.chunks){if(c.warn>0){c.warn-=dt;const k=0.5+0.5*Math.sin(MST.t*18);c.core.color.setRGB(1,0.35+0.3*k,0.25);c.halo.color.setRGB(1,0.2,0.15);
      if(c.warn<=0){c.warn=0;mstChunk(c,false);c.gone=10;const p=c.pts[c.pts.length>>1];sparks(p.clone(),30,'#ff6a5a',8,0.12);buzz('light',true);}}
    else if(c.gone>0&&c!==MST.collarChunk){c.gone-=dt;if(c.gone<=0){mstChunk(c,true);c.core.color.set('#ffe6a0');c.halo.color.set('#ffcf70');sparks(c.pts[c.pts.length>>1].clone(),20,'#ffe6a0',6,0.1);}}}}
function mstStep(dt,busy){if(!MST.on)return;const b=MST.body.g,S=MST_S,run=MIR.go&&!busy&&!MIR.end,[bx,bz]=mstB();MST.t+=dt;MST.ringCD-=dt;
  poseHuman(MST.body,'stand',dt,{});
  // she cannot ride into it (up on its rails, or in the air over it, she is above it)
  {const R=MST.phase>=1?MST_HEADR:MST_BODY,dx=P.x-bx,dz=P.z-bz,d=Math.hypot(dx,dz);if(d<R&&!P.grind&&P.y<4){const l=d||1;P.x=bx+dx/l*R;P.z=bz+dz/l*R;}}
  // its body: up to the waist and breathing, then sunk to its chin (MST.tilt runs 0 to 1 as it goes down), then under Mio's light
  const want=MST.phase>=1?1:0;MST.tilt+=(want-MST.tilt)*Math.min(1,dt*0.8);
  if(MST.phase<2)b.position.y=lerp(-0.92*S,6-1.62*S,MST.tilt)+Math.sin(MST.t*0.8)*0.3;
  const hy=b.position.y+1.62*S,hz=b.position.z,hx=b.position.x;
  MST.eyes.forEach((e,k)=>{const [dx,dy]=e.userData.d;e.position.set(hx+dx*S,hy+dy*S,hz+0.12*S);e.scale.setScalar(e.userData.s*(1-0.5*MST.tilt));e.material.opacity=MST.phase>=2?Math.max(0,e.material.opacity-dt):k?0.6+0.3*Math.sin(clock*4+k):0.85+0.15*Math.sin(clock*6);});
  mstTears(dt,run);
  // off the end of a ring in the air (over a gap), she keeps round it: the heading bends along the ring and she is drawn back onto it
  if(P.air&&!P.grind&&P.y>2&&MST.phase===0){const dx=P.x-bx,dz=P.z-bz,r=Math.hypot(dx,dz)||1;
    for(const R of [MST_RI,MST_RO]){if(Math.abs(r-R)>2.5)continue;const ox=dx/r,oz=dz/r,tx=oz,tz=-ox,s=Math.sin(P.yaw)*tx+Math.cos(P.yaw)*tz>0?1:-1;
      P.yaw=Math.atan2(tx*s,tz*s);const k=Math.min(1,dt*6);P.x+=ox*(R-r)*k;P.z+=oz*(R-r)*k;break;}}
  // the hands, one at a time with a breath between (long enough to ride round the one lying down): resting on the mirror, rising,
  // hanging over her way with a red shadow under them, slamming down
  if(run)MST.cd-=dt;
  MST.hands.forEach((H,k)=>{const sx=hx+H.sd*0.26*S,sy=b.position.y+1.42*S,sz=b.position.z,gy=mirG(H.x,H.z);
    if(H.dead){H.fade+=dt;H.g.position.y-=dt*2;H.g.scale.setScalar(Math.max(0.01,MST_HS*(1-H.fade*0.5)));H.core.visible=H.mark.visible=H.warn.visible=H.lit.visible=false;H.arm.visible=false;H.rail.off=true;if(H.fade>2)H.g.visible=false;return;}
    if(run){H.t-=dt;
      if(H.st==='rest'){H.y=gy;if(MST.cd<=0&&(MST.turn===k||MST.hands[1-k].dead)&&MST.phase===0){H.st='lift';H.t=0.8;mstAim(H);}}
      else if(H.st==='lift'){const u=1-H.t/0.8;H.x=lerp(H.ox,H.tx,u);H.z=lerp(H.oz,H.tz,u);H.y=lerp(gy,MST_UP,Math.min(1,u*1.4));if(H.t<=0){H.st='aim';H.t=1.8;}}
      else if(H.st==='aim'){H.x=H.tx;H.z=H.tz;H.y=MST_UP+Math.sin(MST.t*9)*0.3;H.warn.material.opacity=0.2+0.4*(1-H.t/1.8)+0.1*Math.sin(MST.t*20);if(H.t<=0){H.st='slam';H.t=0.2;}}
      else if(H.st==='slam'){H.y=lerp(gy,MST_UP,Math.max(0,H.t/0.2));if(H.t<=0){H.y=gy;H.st='rest';MST.cd=3.4;MST.turn=1-k;mstSlam(H);}}}
    H.g.position.set(H.x,H.y+0.5*MST_HS,H.z);H.g.rotation.y=Math.atan2(H.x-sx,H.z-sz);
    H.warn.visible=H.st==='aim';H.warn.position.set(H.tx,mirG(H.tx,H.tz)+0.07,H.tz);
    H.mark.visible=H.st==='rest';H.mark.position.set(H.x,gy+0.06,H.z);H.mark.material.opacity=0.35+0.25*Math.sin(MST.t*4+k);
    H.core.position.set(H.x,H.y+1.6*MST_HS,H.z);H.core.material.opacity=0.6+0.3*Math.sin(MST.t*5+k);
    // the arm: from the shoulder to the wrist; lying still, a rail from the wrist up to the ring round the neck
    const wx=H.x-Math.sin(H.g.rotation.y)*2.5*MST_HS,wz=H.z-Math.cos(H.g.rotation.y)*2.5*MST_HS,wy=H.y+0.8*MST_HS,d=new THREE.Vector3(wx-sx,wy-sy,wz-sz),L=d.length();
    H.arm.position.set((sx+wx)/2,(sy+wy)/2,(sz+wz)/2);H.arm.scale.set(1,L,1);H.arm.quaternion.setFromUnitVectors(new THREE.Vector3(0,1,0),d.normalize());
    // (not where the wrist lies on one of the rings: there she would catch the ring instead)
    const R=H.rail,wr=Math.hypot(wx-bx,wz-bz),up=H.st==='rest'&&MST.phase===0&&Math.abs(wr-MST_RI)>3&&Math.abs(wr-MST_RO)>3,cx=bx+H.sd*MST_RC;
    if(up&&!(P.grind&&P.grind.r===R))Object.assign(R,{x0:wx,z0:wz,y0:wy+0.3,x1:cx,z1:bz,y1:MST_YC});
    R.off=!up;if(P.grind&&P.grind.r===R)MST.via=H;
    H.lit.visible=up;if(up){const a=new THREE.Vector3(R.x0,R.y0,R.z0),c=new THREE.Vector3(R.x1,R.y1,R.z1),e=c.clone().sub(a);H.lit.position.copy(a).add(c).multiplyScalar(0.5);H.lit.scale.set(1,e.length(),1);H.lit.quaternion.setFromUnitVectors(new THREE.Vector3(0,1,0),e.normalize());}});
  // the ring round the neck: lit while an arm leads up to it; once she is on it, only while the hand she came up from stays down
  {const onC=P.grind&&MST.collar.includes(P.grind.r),on=MST.phase===0&&(onC?!!MST.via&&!MST.via.rail.off:MST.hands.some(H=>!H.rail.off));for(const r of MST.collar)r.off=!on;for(const m of MST.collarChunk.meshes)m.visible=on;}
  // ringed three times: it sinks to its chin, its head on the mirror, breathing out shadows (its hands go under with it)
  if(MST.phase===0&&MST.hp<=0){MST.phase=1;MST.breath=4;for(const H of MST.hands)H.dead=true;toast('主が、しずんでいく！ 頭のまわりを、光の線で囲め',true);buzz('heavy',true);}
  const Hd=MST.head;Hd.x=hx;Hd.z=hz;Hd.y=hy;
  if(MST.phase===1){Hd.core.visible=MST.tilt>0.6;Hd.core.position.set(hx,Math.max(2,hy-0.1*MST_S),hz+0.12*MST_S);Hd.core.material.opacity=0.6+0.3*Math.sin(MST.t*3);
    Hd.mark.position.set(hx,0.06,hz);Hd.mark.material.opacity=MST.tilt>0.6?0.35+0.25*Math.sin(MST.t*4):0;
    if(run){MST.breath-=dt;if(MST.breath<=0){MST.breath=8;mirSwarm(6);mirAdd('red',...mirWhere(1.6,14,22));}}}
  else Hd.mark.material.opacity=0;
  // the end: Mio's light down on it, and it sinks into the mirror
  if(MST.phase===2){MST.t2+=dt;Hd.core.visible=false;MST.beam.position.set(hx,120,hz);MST.beam.material.opacity=Math.min(0.75,MST.t2*0.8)*(MST.t2>3?Math.max(0,1-(MST.t2-3)):1);
    b.position.y-=dt*Math.min(8,MST.t2*4);if(MST.t2>4&&!MIR.end)mirFinish(true);}}
// a ring closed: round the whole master, round a hand lying on the mirror, or round the head
function mstRing(inside,gold){if(!MST.on||MST.phase===2)return null;const n=mstDmg(gold),[bx,bz]=mstB();
  if(MST.phase===0){let msg=null;
    if(inside(bx,bz)&&MST.ringCD<=0){MST.hp--;MST.ringCD=3;sparks(new THREE.Vector3(bx,30,bz),80,'#ffe6a0',22,0.3);buzz('heavy',true);
      msg=MST.hp>0?`主をまるごと囲んだ！　のこり ${MST.hp}`:'主をしめつけた！';}
    for(const H of MST.hands){if(H.dead||H.st!=='rest'||!inside(H.x,H.z))continue;H.hp-=n;sparks(new THREE.Vector3(H.x,H.y+MST_HS,H.z),40,'#d8c0ff',12,0.2);
      if(H.hp<=0){H.dead=true;msg=msg||`主の${H.sd<0?'右':'左'}手を焼いた！`;}else msg=msg||`主の手が焼ける！　のこり ${H.hp}`;}
    return msg;}
  const Hd=MST.head;if(MST.tilt<0.6||!inside(Hd.x,Hd.z))return null;Hd.hp-=n;sparks(new THREE.Vector3(Hd.x,Hd.y+2,Hd.z),40,'#d8c0ff',10,0.18);
  if(Hd.hp>0)return`主の頭を焼いた！　のこり ${Hd.hp}`;
  MST.phase=2;MST.t2=0;for(const f of MIR.foes)f.gone=1;buzz('heavy',true);return'ミオの光が、主をつらぬく！';}
function mstHUD(){if(!MST.on)return null;
  return{step:MST.phase===0?'レールで主のうしろを回って、主をまるごと囲め（分かれ道は左右に倒す）。たたいたあとの腕からは、首の輪へのぼれる':'しずんだ主の頭のまわりを、線で囲め',
    meter:MST.phase===0?`主 ${'■'.repeat(Math.max(0,MST.hp))}　手 ${MST.hands.map(H=>H.dead?'×':'■'.repeat(Math.max(0,Math.ceil(H.hp)))).join(' / ')}`:`頭 ${'■'.repeat(Math.max(0,MST.head.hp))}`};}
function mstMap(toM){if(!MST.on)return;
  if(MST.phase===0){mg.lineWidth=2;for(const c of MST.chunks){if(c.gone&&!c.warn||c===MST.collarChunk&&MST.collar[0].off)continue;mg.strokeStyle=c.warn?'#ff6a5a':'#ffe6a0';mg.beginPath();
    c.pts.forEach((p,k)=>{const [x,y]=toM(p.x,p.z);k?mg.lineTo(x,y):mg.moveTo(x,y);});mg.stroke();}}
  mg.fillStyle='#b070ff';
  for(const H of MST.hands){if(H.dead)continue;const [x,y]=toM(H.x,H.z);mg.beginPath();mg.arc(x,y,H.st==='rest'?5:3,0,TAU);mg.fill();}
  if(MST.phase===1){const [x,y]=toM(MST.head.x,MST.head.z);mg.beginPath();mg.arc(x,y,7,0,TAU);mg.fill();}
  const [x,y]=toM(...mstB());mg.fillStyle='#3a1c52';mg.beginPath();mg.arc(x,y,7,0,TAU);mg.fill();}
// the night's end: in the story it goes on from the dawn (finalScript waits on masterP); in practice back to the base
function mstEnd(won){if(MST.rule&&!MST.rule.practice)return null;
  return{post:[['say','tome',won?'……あの主を、たおしちまうとはね。本番も、その調子でいきな。':'……内の輪は早いけど、手のそばを通る。外の輪は遠回りだけど、安全さ。うまく乗りかえな。']]};}
// the last fight of the story: out onto the mirror, and back (on a black screen) once the master has sunk
function masterP(){return new Promise(res=>{MST.res=res;steps(mirScript(MST_RULE.story));});}
async function mstStoryEnd(){const r=MST.res;await fadeP(true);mirExit();if(r)r();}
const MST_RULE={
  story:{master:true,practice:false,title:'最後の戦い：海の主',intro:[]},
  practice:{master:true,practice:true,title:'海の主（練習）',intro:['あれが、海の主さ。……練習だから、やられても物語は進まないよ。',
    '主のまわりに、ミオちゃんが光のレールを二重にかけてくれた。鏡の上の低いはしに向かって跳べば、乗れるよ。レールは主の背中を回って、反対がわへおりてくる。すき間は跳びこえな。',
    '内の輪は短くて早いけど、主の手のそばを通る。外の輪は高くて遠回りだけど、安全だ。分かれ道で左右に倒せば、乗りかえられる。',
    'こんなに大きいと、鏡の上を走るだけじゃ、ひと回りする前に線が消えちまう。でもレールに乗っているあいだは、線は消えない。','レールで背中を回って、鏡の上の線とつなげば、主をまるごと囲める。三回囲めば、主は鏡にしずむ。最後は、頭のまわりを三回囲むんだ。',
    '主の手が鏡をたたいたら、その腕は光る。腕をのぼれば、首のまわりの輪に出られる。そこを一周すれば、それだけで主を囲めるよ。手が動きだす前にね。',
    '主はときどき、レールをこわす。赤く光ったら、すぐにほかの道へ。たたいたあとの手も、囲めば焼ける。焼いた手は、もう動かないよ。']}};
