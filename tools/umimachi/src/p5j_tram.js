
/* ---------- the tram, うみまち線: two old green-and-cream cars built inside and out — real windows, sliding doors with steps,
   long seats, straps that swing as it brakes, ads, the driver's cab with the driver at the controller — calling at three stops.
   Car 0 always leads (its +x end is the cab); at the ends of the line, in the tunnels, the train turns round.
   At a stop, E at an open door gets you on: you sit facing the sea and ride, look about with A/D (or the stick), and E gets
   you off at whatever stop it comes to. The fare is 100 yen. ---------- */
const TRAM_STOPS=[{id:'pier',name:'さんばし前',x:-80},{id:'station',name:'うみまち駅',x:65},{id:'east',name:'ひがし浜',x:165}];
const TRAM={x:-260,dir:1,v:0,wait:0,at:null,door:0,cars:[],len:25,platS:()=>TRAM.dir>0?-1:1,seatS:()=>TRAM.dir>0?1:-1};   // platS/seatS: the platform side and the sea side, as the car's local z
const TRAM_SEATS=[-2.8,-2.1,-1.4,-0.7,0,0.7,1.4,2.1,2.8];
const TRAM_MAT={green:tm('#2f7d4f'),cream:tm('#efe6c8'),yel:tm('#f2c230'),roof:tm('#8f989f'),dark:tm('#2b2b2b'),floor:tm('#7a6450'),
  seat:tm('#9c3b34'),seatB:tm('#5a2622'),inner:tm('#e9e2cc'),ceil:tm('#f6f2e6'),metal:tm('#c9cdd2'),strap:tm('#f2f2ee'),bel:tm('#3a3a3a'),
  glass:new THREE.MeshBasicMaterial({color:'#cfe8f0',transparent:true,opacity:0.16,depthWrite:false,side:THREE.DoubleSide}),
  lamp:new THREE.MeshToonMaterial({color:'#fffaf0',gradientMap:GRAD,emissive:'#fff1c8',emissiveIntensity:0}),
  head:new THREE.MeshBasicMaterial({color:'#fff3c4'})};
NIGHT_MATS.push(TRAM_MAT.lamp);
const tramSignTex=canvasTex(256,48,(c,w,h)=>{c.fillStyle='#1d1d1d';c.fillRect(0,0,w,h);c.fillStyle='#fff6d8';c.font=signFont(28,true);c.textAlign='center';c.textBaseline='middle';c.fillText('うみまち線',w/2,h/2+1);});
const tramAdTex=(t,s,bg,fg)=>canvasTex(192,64,(c,w,h)=>{c.fillStyle=bg;c.fillRect(0,0,w,h);c.fillStyle=fg;c.textAlign='center';c.font=signFont(24,true);c.fillText(t,w/2,30);c.font=signFont(13);c.fillText(s,w/2,52);});
const TRAM_ADS=[['こむぎ堂','焼きたてメロンパン','#fff3d6','#8a4b1d'],['しおさい','珈琲とナポリタン','#e4f0f2','#24525e'],['駄菓子まるや','当たりが出たら もう一本','#ffe9ec','#b2324a'],
  ['魚松','今朝の地あじ','#e6eef8','#1f4a7a'],['はなもり','季節の花 あります','#eef6e6','#3d6b2e'],['夏まつり','海の上に 花火があがる','#2b3a6a','#ffd27a']].map(a=>tmap(tramAdTex(...a),{side:THREE.DoubleSide}));
const tramMapTex=tmap(canvasTex(256,64,(c,w,h)=>{c.fillStyle='#fffaf0';c.fillRect(0,0,w,h);c.strokeStyle='#2f7d4f';c.lineWidth=4;c.beginPath();c.moveTo(24,26);c.lineTo(w-24,26);c.stroke();
  c.fillStyle='#2b2520';c.font=signFont(12,true);c.textAlign='center';[...TRAM_STOPS,{name:'山のふもと'}].forEach((s,k)=>{const x=30+k*(w-60)/3;c.beginPath();c.arc(x,26,7,0,TAU);c.fillStyle='#fff';c.fill();c.stroke();c.fillStyle='#2b2520';c.fillText(s.name,x,54);});}),{side:THREE.DoubleSide});
function makeTramCar(k){const g=new THREE.Group(),c=k===0?1:-1,ce=-c,doors=[],straps=[],wheels=[],folk=[];   // c: the cab end, ce: the end coupled to the other car
  const B=(w,h,d,mat,x,y,z,ol)=>{const m=new THREE.Mesh(new THREE.BoxGeometry(w,h,d),mat);m.position.set(x,y,z);m.castShadow=true;if(ol)outline(m,ol);g.add(m);return m;};
  const glass=(w,h,x,y,z,ry)=>{const m=new THREE.Mesh(new THREE.PlaneGeometry(w,h),TRAM_MAT.glass);m.position.set(x,y,z);m.rotation.y=ry||0;g.add(m);};
  // the sides: green below a yellow line, cream round the windows; the doors stand open in the wall
  const SEGS=[[-6,-4.55,1],[-3.45,3.45,5],[4.55,6,1]];
  for(const s of [-1,1]){const z=s*1.22,wm=[TRAM_MAT.green,TRAM_MAT.green,TRAM_MAT.green,TRAM_MAT.green,s>0?TRAM_MAT.green:TRAM_MAT.inner,s>0?TRAM_MAT.inner:TRAM_MAT.green];
    for(const [a,b,n] of SEGS){const L=b-a,cx=(a+b)/2;B(L,1.2,0.06,wm,cx,1.15,z,0.02);B(L,0.06,0.075,TRAM_MAT.yel,cx,1.76,z);B(L,0.5,0.06,TRAM_MAT.cream,cx,3.0,z,0.02);
      const p=0.16,w=(L-(n+1)*p)/n;for(let i=0;i<=n;i++)B(p,1.0,0.06,TRAM_MAT.cream,a+p/2+i*(w+p),2.29,z);
      for(let i=0;i<n;i++){const x=a+p+w/2+i*(w+p);glass(w,1.0,x,2.29,z);B(w,0.04,0.05,TRAM_MAT.cream,x,2.36,z);}}
    for(const dx of [-4,4]){const d=new THREE.Group();d.position.set(dx,0,s*1.27);g.add(d);
      const P=(w,h,mat,x,y)=>{const m=new THREE.Mesh(new THREE.BoxGeometry(w,h,0.04),mat);m.position.set(x,y,0);m.castShadow=true;d.add(m);};
      P(1.1,0.85,TRAM_MAT.green,0,1.33);P(1.1,0.06,TRAM_MAT.yel,0,1.76);P(0.14,1.0,TRAM_MAT.cream,-0.48,2.29);P(0.14,1.0,TRAM_MAT.cream,0.48,2.29);P(1.1,0.1,TRAM_MAT.cream,0,2.74);
      const gl=new THREE.Mesh(new THREE.PlaneGeometry(0.82,0.9),TRAM_MAT.glass);gl.position.set(0,2.25,0);d.add(gl);
      doors.push({g:d,x0:dx,open:-Math.sign(dx)*1.05,s});
      B(1.0,0.05,0.3,TRAM_MAT.dark,dx,0.62,s*1.32);B(1.1,0.35,0.05,TRAM_MAT.dark,dx,0.73,s*1.2);}}   // the step up from a low platform
  // the cab end: a wide windscreen, the destination board, the headlight and a bumper
  { const x=c*6,om=i=>i===(c>0?0:1)?TRAM_MAT.green:TRAM_MAT.inner,wm=[0,1,2,3,4,5].map(om);
    B(0.06,1.2,2.5,wm,x,1.15,0,0.02);B(0.075,0.06,2.5,TRAM_MAT.yel,x,1.76,0);B(0.06,0.5,2.5,TRAM_MAT.cream,x,3.0,0,0.02);
    for(const z of [-1.18,-0.66,0.66,1.18])B(0.06,1.0,z===-1.18||z===1.18?0.14:0.12,TRAM_MAT.cream,x,2.29,z);
    glass(1.2,1.0,x,2.29,0,Math.PI/2);for(const z of [-0.92,0.92])glass(0.4,1.0,x,2.29,z,Math.PI/2);
    const sg=new THREE.Mesh(new THREE.PlaneGeometry(1.1,0.22),tmap(tramSignTex));sg.position.set(x+c*0.035,2.98,0);sg.rotation.y=c*Math.PI/2;g.add(sg);
    const hl=new THREE.Mesh(new THREE.CircleGeometry(0.13,16),TRAM_MAT.head);hl.position.set(x+c*0.035,1.4,0);hl.rotation.y=c*Math.PI/2;g.add(hl);
    for(const z of [-0.95,0.95]){const t=new THREE.Mesh(new THREE.CircleGeometry(0.06,10),new THREE.MeshBasicMaterial({color:'#c8372d'}));t.position.set(x+c*0.035,0.95,z);t.rotation.y=c*Math.PI/2;g.add(t);}
    B(0.16,0.16,2.4,TRAM_MAT.dark,x+c*0.08,0.62,0);
    // inside the cab: a low partition, the controller and the brake handle
    for(const z of [-0.85,0.85])B(0.05,1.0,0.7,TRAM_MAT.inner,c*4.75,1.4,z);
    B(0.4,0.9,0.5,TRAM_MAT.dark,c*5.65,1.35,-0.55);const h=B(0.04,0.04,0.3,TRAM_MAT.metal,c*5.6,1.86,-0.55);h.rotation.x=0.4;
    B(0.35,0.06,0.35,TRAM_MAT.metal,c*5.65,1.82,-0.55);}
  // the coupled end: a doorway through to the other car, and the bellows between
  { const x=ce*6,wm=[0,1,2,3,4,5].map(i=>i===(ce>0?0:1)?TRAM_MAT.green:TRAM_MAT.inner);
    for(const z of [-0.88,0.88])B(0.06,2.7,0.74,wm,x,1.9,z,0.02);B(0.06,0.6,1.02,wm,x,2.95,0);
    if(k===0){for(const z of [-0.62,0.62])B(0.62,2.1,0.05,TRAM_MAT.bel,x+ce*0.31,1.95,z);B(0.62,0.05,1.25,TRAM_MAT.bel,x+ce*0.31,3.0,0);B(0.62,0.05,1.25,TRAM_MAT.floor,x+ce*0.31,0.88,0);}}
  // floor, underframe, roof
  B(11.94,0.08,2.38,TRAM_MAT.floor,0,0.86,0);B(12,0.3,2.3,TRAM_MAT.dark,0,0.45,0);
  B(12.1,0.16,2.6,TRAM_MAT.roof,0,3.33,0,0.03);B(11.6,0.14,1.9,TRAM_MAT.roof,0,3.46,0,0.02);B(11.94,0.04,2.38,TRAM_MAT.ceil,0,3.2,0);
  for(const z of [-0.45,0.45])B(10.5,0.04,0.14,TRAM_MAT.lamp,0,3.16,z);
  // trucks and wheels
  for(const bx of [-4,4]){B(2.2,0.3,1.9,TRAM_MAT.dark,bx,0.42,0);
    for(const wx of [-0.7,0.7])for(const wz of [-0.98,0.98]){const w=new THREE.Mesh(new THREE.CylinderGeometry(0.3,0.3,0.1,14),TRAM_MAT.metal);w.rotation.x=Math.PI/2;w.position.set(bx+wx,0.3,wz);g.add(w);wheels.push(w);}}
  if(k===0){const pb=B(0.8,0.12,0.8,TRAM_MAT.dark,0,3.6,0);   // the pantograph
    for(const a of [0.75,-0.75]){const m=B(0.04,0.9,0.04,TRAM_MAT.dark,a*0.3,3.95,0);m.rotation.z=a;}B(0.06,0.06,1.6,TRAM_MAT.dark,0,4.32,0);}
  // the long seats along both sides
  const seatRuns=[[-3.35,3.35],ce>0?[4.65,5.9]:[-5.9,-4.65]];
  for(const s of [-1,1])for(const [a,b] of seatRuns){const L=b-a,cx=(a+b)/2;
    B(L,0.36,0.4,TRAM_MAT.seatB,cx,1.08,s*1.0);B(L,0.12,0.48,TRAM_MAT.seat,cx,1.26,s*0.95);const bk=B(L,0.44,0.1,TRAM_MAT.seat,cx,1.58,s*1.15);bk.rotation.x=s*0.12;}
  // straps on rails, poles by the doors, luggage racks, ads above the windows and hanging down the middle
  for(const s of [-1,1]){const r=new THREE.Mesh(new THREE.CylinderGeometry(0.018,0.018,11.6,6),TRAM_MAT.metal);r.rotation.z=Math.PI/2;r.position.set(0,2.62,s*0.62);g.add(r);
    for(let x=-3.1;x<=3.11;x+=0.62){const p=new THREE.Group();p.position.set(x,2.62,s*0.62);g.add(p);
      const band=new THREE.Mesh(new THREE.BoxGeometry(0.03,0.22,0.012),TRAM_MAT.yel);band.position.y=-0.11;p.add(band);
      const ring=new THREE.Mesh(new THREE.TorusGeometry(0.055,0.012,6,14),TRAM_MAT.strap);ring.position.y=-0.27;p.add(ring);straps.push(p);}
    for(const x of [-3.42,3.42,ce*4.6])B(0.04,2.3,0.04,TRAM_MAT.metal,x,2.03,s*1.08);
    B(6.6,0.025,0.3,TRAM_MAT.metal,0,2.82,s*1.02);
    for(let i=0;i<4;i++){const ad=new THREE.Mesh(new THREE.PlaneGeometry(0.95,0.3),TRAM_ADS[(i+k*2+(s>0?3:0))%TRAM_ADS.length]);ad.position.set(-2.4+i*1.6,3.0,s*1.185);ad.rotation.y=s>0?Math.PI:0;g.add(ad);}
    for(const dx of [-4,4]){const m=new THREE.Mesh(new THREE.PlaneGeometry(1.0,0.25),tramMapTex);m.position.set(dx,2.95,s*1.185);m.rotation.y=s>0?Math.PI:0;g.add(m);}}
  for(let i=0;i<3;i++){const ad=new THREE.Mesh(new THREE.PlaneGeometry(0.62,0.4),TRAM_ADS[(i*2+k)%TRAM_ADS.length]);ad.position.set(-2+i*2,2.9,0);ad.rotation.y=Math.PI/2;g.add(ad);}
  return{g,doors,straps,wheels,folk,c};}
for(let k=0;k<2;k++){const car=makeTramCar(k);world.add(car.g);TRAM.cars.push(car.g);car.g.userData.car=car;}
TRAM.box=collide(0,0,TRAM_Z-1.4,TRAM_Z+1.4,'tram');
// the people on board: the driver at the controller, and a few passengers on the seats
const TRAM_FOLK=[[0,1,-2.1,{skin:'#efc9aa',hair:'#e2ded8',style:'grey',shirt:'#c9b6d8',sleeves:'long',bottom:'long',bottomCol:'#5a4a6a',bend:0.15}],
  [0,-1,1.4,{skin:'#f1cdb0',hair:'#1c1a1a',style:'short',shirt:'#f2f2ee',bottom:'pants',bottomCol:'#2b3a5a',shoe:'#1d1d1d'}],
  [0,1,2.8,{skin:'#e3b088',hair:'#2b2520',style:'short',shirt:'#9ab8d8',sleeves:'long',bottom:'pants',bottomCol:'#3a3a3a'}],
  [1,-1,-1.4,{skin:'#f1cdb0',hair:'#3a2a1d',style:'long',shirt:'#f6d6a8',bottom:'skirt',bottomCol:'#6a8a5a'}],
  [1,1,0.7,{skin:'#d9a987',hair:'#2b2520',hat:'straw',shirt:'#e8e0c8',sleeves:'long',bottom:'pants',bottomCol:'#6b5a4a'}]];
for(const [k,s,x,o] of TRAM_FOLK){const car=TRAM.cars[k].userData.car,h=makeHuman(o);h.g.position.set(x,0.9,s*0.98);h.g.rotation.y=s>0?Math.PI:0;TRAM.cars[k].add(h.g);car.folk.push({h,s,x});}
{ const car=TRAM.cars[0].userData.car,h=makeHuman({skin:'#e0b48e',hair:'#2b2520',style:'short',cap:'#24323a',shirt:'#dfe5ea',sleeves:'long',bottom:'pants',bottomCol:'#24323a',shoe:'#1d1d1d'});
  h.g.position.set(5.2,0.9,-0.45);h.g.rotation.y=Math.PI/2;TRAM.cars[0].add(h.g);car.driver=h;}

// the low stops (a step up from the road, a step up again into the car) beside the line, north of the rails
for(const st of TRAM_STOPS){if(st.id==='station')continue;const x=st.x,y=G(x,207);
  const plat=M(new THREE.BoxGeometry(27,0.34,3.0),tm('#c9c2b4'),0.02);plat.position.set(x,y+0.17,207.2);plat.receiveShadow=true;world.add(plat);
  const edge=new THREE.Mesh(new THREE.BoxGeometry(27,0.02,0.3),tm('#f2c230'));edge.position.set(x,y+0.35,208.5);world.add(edge);
  const roof=M(new THREE.BoxGeometry(6,0.12,2.0),tm('#2e7d4f'),0.025);roof.position.set(x-3,y+2.75,206.6);roof.castShadow=true;world.add(roof);
  for(const px of [x-5.5,x-0.5])world.add(M(new THREE.CylinderGeometry(0.06,0.06,2.4,8),tm('#ddd'),0.01).translateX(px).translateY(y+1.55).translateZ(206.0));
  const sg=new THREE.Mesh(new THREE.BoxGeometry(2.2,0.55,0.08),[tm('#fff'),tm('#fff'),tm('#fff'),tm('#fff'),tmap(canvasTex(256,64,(c,w,h)=>{c.fillStyle='#fffaf0';c.fillRect(0,0,w,h);c.fillStyle='#2e7d4f';c.fillRect(0,h-12,w,12);
    c.fillStyle='#2b2520';c.font=signFont(28,true);c.textAlign='center';c.fillText(st.name,w/2,34);})),tm('#fff')]);
  sg.position.set(x-3,y+2.35,206.0);world.add(sg);
  const b=benchMesh();b.position.set(x-3,y+0.34,206.3);world.add(b);
  collide(x-13.5,x+13.5,205.7,208.7,'stop',y+0.34);}
const stopAt=x=>TRAM_STOPS.find(s=>Math.abs(x-s.x)<14);

// running: speed up gently, brake into each stop (so the train halts with the platform beside both cars), wait with the doors
// open, and turn round in the tunnels at the ends of the line — except that riding into the east tunnel takes you on to the country
function nextStop(T){let best=null;for(const s of TRAM_STOPS){const sx=s.x+T.dir*6.3,d=(sx-T.x)*T.dir;if(d>-0.5&&s!==T.left&&(!best||d<best.d))best={s,sx,d};}
  if(!best){const ex=T.dir>0?TRAM_X1-10:TRAM_X0+10;best={s:null,sx:ex,d:(ex-T.x)*T.dir};}return best;}   // the stop it has just left does not count, however close
function tramMove(dt){const T=TRAM,v0=T.v;
  if(T.wait>0){T.wait-=dt;T.v=0;if(T.wait<=0){const me=RIDE.on&&RIDE.train===T;if(!T.at){T.dir*=-1;if(me)tramTurnFade();}T.left=T.at;T.at=null;if(me){const n=nextStop(T);toast(n.s?`次は　${n.s.name}　です`:'次は　終点、山のふもと　です');}}}
  else{const n=nextStop(T),tgt=Math.min(7,Math.sqrt(2*1.1*Math.max(0,n.d))+0.25);T.v+=clamp(tgt-T.v,-2.4*dt,0.9*dt);
    const step=T.v*dt;if(step>=n.d-0.005){T.x=n.sx;T.v=0;T.at=n.s;T.wait=n.s?(n.s.id==='station'?14:11):4;const me=RIDE.on&&RIDE.train===T;if(n.s&&me)toast(`${n.s.name}　です`);
      if(!n.s&&T.dir>0&&me)townToInk();}else T.x+=T.dir*step;}
  T.acc=(T.v-v0)/Math.max(dt,1e-3);
  T.door+=((T.at&&T.wait>1.2?1:0)-T.door)*Math.min(1,dt*2.5);
  T.cars.forEach((g,k)=>{const x=T.x-T.dir*(6.2+k*12.6)+T.dir*6.2;g.position.set(x,G(clamp(x,-CUT_X,CUT_X),TRAM_Z)+0.2,TRAM_Z);g.rotation.y=T.dir>0?0:Math.PI;
    const car=g.userData.car;if(!car)return;
    for(const f of car.folk)f.h.g.visible=!URA.on;if(car.driver)car.driver.g.visible=!URA.on;   // in 裏海街 it runs empty, with no driver
    for(const d of car.doors)d.g.position.x=d.x0+d.open*smooth(T.door);
    for(const w of car.wheels)w.rotation.y+=T.v*dt/0.3;
    const near=Math.hypot(P.x-x,P.z-TRAM_Z)<45;if(!near)return;
    for(const p of car.straps){p.rotation.z+=(clamp(T.acc*0.12,-0.35,0.35)-p.rotation.z)*Math.min(1,dt*3);p.rotation.x=Math.sin(clock*1.3+p.position.x)*0.03*T.v/7;}
    for(const f of car.folk)poseHuman(f.h,'sit',dt,{look:RIDE.on&&RIDE.car===k?player.g.position:null});
    if(car.driver){poseHuman(car.driver,'stand',dt,{});for(const a of car.driver.arms){a.sh.rotation.x=-0.75;a.el.rotation.x=-0.8;}}});}
function tramTurnFade(){const f=$('fade');f.style.opacity=1;setTimeout(()=>{f.style.opacity=0;},700);}

/* ---------- riding ---------- */
const RIDE={on:false,train:TRAM,car:0,s:-1,x:0,look:0};
const canRide=()=>!URA.on&&!DRONE.active&&!ST.run&&state==='play';
const tramOpen=T=>T.at&&T.door>0.8&&T.wait>1.2;
// the door on the platform side (north of the rails) of a car, in the world, and a point on the platform in front of it
function tramDoor(T,k,dx,out,side){const g=T.cars[k],s=side||T.platS();return g.localToWorld(new THREE.Vector3(dx,0,s*(1.3+(out||0))));}
function tramNear(){const T=AREA==='inaka'?INKT:TRAM;if(!tramOpen(T)||!canRide())return null;let best=null,bd=3.6;   // the doors open on both sides
  for(let k=0;k<2;k++)for(const dx of [-4,4])for(const sd of [-1,1]){const p=tramDoor(T,k,dx,0.8,sd),d=Math.hypot(P.x-p.x,P.z-p.z);if(d<bd){bd=d;best={kind:'tram',T,k,dx,d,label:'乗る　うみまち線',verb:'乗る'};}}
  return best;}
function rideNear(){const T=RIDE.train;return tramOpen(T)?{kind:'alight',label:`降りる　${T.at.name}`,verb:'降りる'}:null;}
// the free seat on that side of the car nearest to x
function pickSeat(T,k,s,near){const taken=T.cars[k].userData.car.folk.filter(f=>f.s===s).map(f=>f.x);
  const free=TRAM_SEATS.filter(x=>!taken.some(t=>Math.abs(t-x)<0.6));free.sort((a,b)=>Math.abs(a-near)-Math.abs(b-near));return free[0];}
function boardTram(o){const T=o.T,s=T.seatS();
  Object.assign(RIDE,{on:true,train:T,car:o.k,s,x:pickSeat(T,o.k,s,o.dx),look:0});if(T===INKT){T.mode='depart';T.wait=4;}P.foot=true;P.carry='hand';P.tr=null;P.v=0;P.air=false;P.grind=null;
  document.body.classList.add('riding');camInit=false;tramTurnFade();
  toast(hasTouch?'うみまち線に乗った（スティックで まわりを見る）':'うみまち線に乗った（A / D で まわりを見る）');}
function alightTram(){const T=RIDE.train,dx=RIDE.x<0?-4:4;const p=tramDoor(T,RIDE.car,dx,2.6);
  RIDE.on=false;document.body.classList.remove('riding');P.x=p.x;P.z=p.z;P.y=groundAt(P.x,P.z,G(P.x,P.z)+1);if(AREA==='inaka')P.y=Math.max(P.y,0.34);P.yaw=Math.PI;P.v=0;camInit=false;tramTurnFade();
  if(SAVE.money>=100){SAVE.money-=100;toast(`${T.at.name}で降りた（運賃 -100円）`);renderHUD();save();}else toast('運転士さん「今日はいいよ。またどうぞ」');}
// on board: she sits on the long seat on the sea side, the board stood up at her side
function rideStep(dt){jumpQ=kickQ=footQ=trickQ=false;const g=RIDE.train.cars[RIDE.car];
  const I=DLG||modal?{turn:0}:inputs();RIDE.look=clamp(RIDE.look+I.turn*dt*1.6,-1.3,1.3);
  const p=g.localToWorld(new THREE.Vector3(RIDE.x,0.9,RIDE.s*0.98));P.x=p.x;P.z=p.z;P.y=p.y;P.yaw=g.rotation.y+(RIDE.s>0?Math.PI:0);P.v=0;
  player.g.position.copy(p);player.g.rotation.set(0,P.yaw,0);player.root.rotation.set(0,0,0);poseSitter(player,dt,RIDE.look);}
function poseSitter(h,dt,look){const P=h.pose;h.t+=dt;h.kneeOut=0.12;P.c=0;P.push=0;P.sd=0;P.tk=0;P.gr=0;
  h.hips.position.set(0,0.47,0.0);h.hips.rotation.set(0,0,0);
  h.torso.rotation.set(0.04+Math.sin(h.t*1.6)*0.01,look*0.15,0);h.head.rotation.order='YXZ';h.head.rotation.set(0.04,look*0.55,0);
  for(const a of h.arms){a.sh.rotation.set(-0.45,0,a.sx*0.14);a.el.rotation.x=-0.95;}
  const hy=0.4;for(const L of h.legs)solveLeg(L,L.sx*0.09,hy,0,L.sx*0.11,ANK_G,0.42);
  h.root.updateMatrixWorld(true);
  const up=boardUpright({p:new THREE.Vector3(),q:new THREE.Quaternion()});up.p.x+=0.08;up.p.z+=0.38;setBoard(h,up.p,up.q);
  h.hold={sx:1,w:1,T:h.board.localToWorld(new THREE.Vector3(0.0,0.06,0.4))};
  if(h.faceM)animHeroine(h,dt,{v:0,turn:0,air:false});
  if(h.vrm)driveVRM(h,dt,{v:0,turn:0,air:false});}
// the view on board: from across the aisle, her on the seat with the sea going by in the windows behind; A/D look along the car
function rideCam(want,look){const g=RIDE.train.cars[RIDE.car],s=RIDE.s;
  want.copy(g.localToWorld(new THREE.Vector3(RIDE.x-1.1,1.95,-s*0.55)));
  look.copy(g.localToWorld(new THREE.Vector3(RIDE.x+0.25+RIDE.look*3.5,1.75,s*1.2)));}
