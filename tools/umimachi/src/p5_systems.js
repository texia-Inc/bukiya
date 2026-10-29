
/* ---------- the tram and its level crossings ---------- */
const tramTex=canvasTex(512,128,(g,w,h)=>{g.fillStyle='#efe6c8';g.fillRect(0,0,w,h);g.fillStyle='#2f7d4f';g.fillRect(0,h*0.58,w,h*0.42);g.fillStyle='#f2c230';g.fillRect(0,h*0.56,w,4);
  for(let k=0;k<7;k++){const x=22+k*68;g.fillStyle='#2b3a44';g.fillRect(x,18,50,40);g.fillStyle='rgba(255,255,255,.25)';g.fillRect(x+4,22,14,32);}
  g.fillStyle='#24323a';g.fillRect(w-70,18,20,76);});
const TRAM={x:-260,dir:1,v:0,wait:0,cars:[],len:25};
for(let k=0;k<2;k++){const g=new THREE.Group();const body=new THREE.Mesh(new THREE.BoxGeometry(12,2.9,2.5),[tm('#2f7d4f'),tm('#2f7d4f'),tm('#9aa3ab'),tm('#333'),tmap(tramTex),tmap(tramTex)]);
  body.position.y=1.85;body.castShadow=true;outline(body,0.05);g.add(body);
  const roof=new THREE.Mesh(new THREE.BoxGeometry(11.4,0.25,2.2),tm('#9aa3ab'));roof.position.y=3.4;g.add(roof);
  if(k===0){const pan=new THREE.Mesh(new THREE.BoxGeometry(1.6,0.06,0.06),tm('#444'));pan.position.set(0,4.1,0);pan.rotation.z=0.5;g.add(pan);}
  for(const x of [-4,4])g.add(new THREE.Mesh(new THREE.BoxGeometry(2,0.6,2.2),tm('#3a3a3a')).translateX(x).translateY(0.45));
  world.add(g);TRAM.cars.push(g);}
TRAM.box=collide(0,0,TRAM_Z-1.4,TRAM_Z+1.4,'tram');
const XINGS=STREETS.filter(S=>S.ax==='z'&&S.a<TRAM_Z&&S.b>TRAM_Z).map(S=>({S,x:S.c,down:0,gates:[],box:collide(S.c-S.w/2,S.c+S.w/2,TRAM_Z-4.2,TRAM_Z+4.2,'gate')}));
{ const armTex=canvasTex(128,16,(g,w,h)=>{for(let k=0;k<8;k++){g.fillStyle=k%2?'#1d1d1d':'#f2c230';g.fillRect(k*16,0,16,h);}});
  const xb=canvasTex(64,64,(g,w,h)=>{g.clearRect(0,0,w,h);g.save();g.translate(w/2,h/2);for(const a of [0.6,-0.6]){g.save();g.rotate(a);g.fillStyle='#f2c230';g.fillRect(-30,-6,60,12);g.fillStyle='#1d1d1d';for(let x=-30;x<30;x+=12)g.fillRect(x,-6,6,12);g.restore();}g.restore();});
  for(const X of XINGS){for(const sd of [-1,1]){const px=X.x+sd*(X.S.w/2+0.5),pz=TRAM_Z-sd*4.0,y=G(px,pz),g=new THREE.Group();g.position.set(px,y,pz);world.add(g);
      g.add(M(new THREE.CylinderGeometry(0.08,0.08,3.6,8),tm('#f2f2ee'),0.012).translateY(1.8));
      const cb=new THREE.Mesh(new THREE.PlaneGeometry(1.2,1.2),tmap(xb,{transparent:true,side:THREE.DoubleSide}));cb.position.y=3.5;g.add(cb);
      const lamps=[];for(const lx of [-0.3,0.3]){const l=new THREE.Mesh(new THREE.CircleGeometry(0.14,14),new THREE.MeshBasicMaterial({color:'#3a0d0a',side:THREE.DoubleSide}));l.position.set(lx,2.7,0.05);g.add(l);lamps.push(l);}
      const box=M(new THREE.BoxGeometry(0.4,0.6,0.4),tm('#2b2520'),0.012);box.position.set(-sd*0.0,0.9,0);g.add(box);
      const pivot=new THREE.Group();pivot.position.set(0,1.0,0);g.add(pivot);const arm=new THREE.Mesh(new THREE.BoxGeometry(X.S.w-0.4,0.09,0.09),tmap(armTex));arm.position.x=-sd*(X.S.w-0.4)/2;pivot.add(arm);
      X.gates.push({pivot,lamps,sd});collide(px-0.12,px+0.12,pz-0.12,pz+0.12,'pole');}
    decal(X.x,TRAM_Z,0,X.S.w,3.6,tmap(canvasTex(64,64,(g,w,h)=>{g.fillStyle='#4a4a4c';g.fillRect(0,0,w,h);g.fillStyle='rgba(0,0,0,.25)';for(let y=0;y<h;y+=8)g.fillRect(0,y,w,2);g.fillStyle='#a9aeb4';g.fillRect(0,h*0.33,w,3);g.fillRect(0,h*0.64,w,3);},true),{polygonOffset:true,polygonOffsetFactor:-7}));}}
function updateTram(dt){
  const T=TRAM;if(T.wait>0){T.wait-=dt;T.v=0;}else{const target=7;T.v+=(target-T.v)*Math.min(1,dt*0.6);}
  const before=T.x;T.x+=T.dir*T.v*dt;
  if((before-65)*(T.x-65)<=0&&T.wait<=0&&T.v>1){T.wait=9;T.x=65;}
  if(T.x>TRAM_X1-10&&T.dir>0){T.dir=-1;T.wait=4;}if(T.x<TRAM_X0+10&&T.dir<0){T.dir=1;T.wait=4;}
  T.cars.forEach((g,k)=>{const x=T.x-T.dir*(6.2+k*12.6)+T.dir*6.2;g.position.set(x,G(clamp(x,-CUT_X,CUT_X),TRAM_Z)+0.2,TRAM_Z);g.rotation.y=T.dir>0?0:Math.PI;});
  const xs=T.cars.map(g=>g.position.x);T.box.x0=Math.min(...xs)-6;T.box.x1=Math.max(...xs)+6;
  for(const X of XINGS){const d=Math.min(Math.abs(T.box.x0-X.x),Math.abs(T.box.x1-X.x));const inside=X.x>T.box.x0-2&&X.x<T.box.x1+2;
    const near=inside||d<55&&((T.dir>0&&T.box.x1<X.x)||(T.dir<0&&T.box.x0>X.x))&&T.v>0.3;X.down+=((near?1:0)-X.down)*Math.min(1,dt*1.6);X.box.on=X.down>0.5;
    for(const gt of X.gates){gt.pivot.rotation.z=gt.sd*(1-X.down)*-1.45;const on=X.down>0.1&&Math.floor(clock*3)%2===0;gt.lamps[0].material.color.set(X.down>0.1&&on?'#ff3a24':'#3a0d0a');gt.lamps[1].material.color.set(X.down>0.1&&!on?'#ff3a24':'#3a0d0a');}}
}

/* ---------- cars on the sea front ---------- */
const CAR_COLORS=['#d23b33','#f2f2ee','#2e5fa8','#1d1f22','#5aa36b','#8e9399','#f2c230'];
const carGeo={body:new THREE.BoxGeometry(1.8,0.85,4.2),cabin:new THREE.BoxGeometry(1.62,0.72,2.1),wheel:new THREE.CylinderGeometry(0.34,0.34,0.28,12).rotateZ(Math.PI/2),
  glass:new THREE.BoxGeometry(1.64,0.48,2.14),lamp:new THREE.BoxGeometry(1.4,0.16,0.08),sign:new THREE.BoxGeometry(0.55,0.24,0.28)};
// cars: a rounded side profile extruded across the width, glass laid on top, then lamps, bumpers, plates, mirrors and wheels with rims
const CAR_TYPES={
  sedan:{len:4.3,w:1.72,body:[[-2.15,0.3],[2.15,0.3],[2.18,0.7],[1.3,0.86],[0.55,1.32],[-0.85,1.36],[-1.72,1.0],[-2.17,0.86]],
    side:[[1.12,0.9],[0.55,1.25],[-0.82,1.29],[-1.58,0.97],[-1.62,0.9]],front:[[1.3,0.86],[0.55,1.32]],rear:[[-0.85,1.36],[-1.72,1.0]],wheel:[1.35,-1.35],r:0.32},
  kei:{len:3.4,w:1.48,body:[[-1.7,0.28],[1.7,0.28],[1.72,0.68],[1.45,0.82],[1.05,1.5],[-1.6,1.56],[-1.72,1.3],[-1.72,0.68]],
    side:[[1.32,0.88],[1.0,1.42],[-1.48,1.47],[-1.56,0.9]],front:[[1.45,0.82],[1.05,1.5]],rear:[[-1.6,1.56],[-1.72,1.3]],wheel:[1.12,-1.12],r:0.28},
  van:{len:4.6,w:1.76,body:[[-2.3,0.32],[2.3,0.32],[2.32,0.8],[2.05,0.95],[1.55,1.82],[-2.24,1.86],[-2.32,1.6],[-2.32,0.8]],
    side:[[1.9,1.0],[1.52,1.74],[-2.1,1.78],[-2.16,1.05]],front:[[2.05,0.95],[1.55,1.82]],rear:[[-2.24,1.86],[-2.32,1.6]],wheel:[1.5,-1.5],r:0.33},
  truck:{len:3.4,w:1.48,body:[[0.15,0.28],[1.7,0.28],[1.72,0.68],[1.45,0.82],[1.12,1.55],[0.15,1.6]],
    side:[[1.32,0.88],[1.05,1.46],[0.3,1.5],[0.3,0.9]],front:[[1.45,0.82],[1.12,1.55]],rear:null,wheel:[1.12,-1.12],r:0.28,bed:true},
};
const CAR_GEO={};
function carGeoFor(type){if(CAR_GEO[type])return CAR_GEO[type];const T=CAR_TYPES[type],ext=(pts,depth,bev)=>{const sh=new THREE.Shape();pts.forEach(([x,y],k)=>k?sh.lineTo(x,y):sh.moveTo(x,y));sh.closePath();
    const g=new THREE.ExtrudeGeometry(sh,{depth,bevelEnabled:bev>0,bevelThickness:bev,bevelSize:bev,bevelSegments:3,steps:1});g.translate(0,0,-depth/2);g.rotateY(-Math.PI/2);g.computeVertexNormals();return g;};
  return CAR_GEO[type]={body:ext(T.body,T.w-0.2,0.1),side:ext(T.side,T.w+0.03,0)};}
const PLATE=canvasTex(64,32,(c,w,h)=>{c.fillStyle='#f4f4ee';c.fillRect(0,0,w,h);c.strokeStyle='#2e7d4f';c.lineWidth=3;c.strokeRect(2,2,w-4,h-4);c.fillStyle='#2e7d4f';c.font='bold 13px sans-serif';c.textAlign='center';c.fillText('海街 50',w/2,14);c.font='bold 11px sans-serif';c.fillText('あ 12-34',w/2,27);});
const plateM=tmap(PLATE),glassM=tm('#2c3a46'),tireM=tm('#18181a'),rimM=tm('#d8dbe0'),greyM=tm('#8e9196'),darkM=tm('#2a2a2c'),headM=new THREE.MeshBasicMaterial({color:'#fff6d8'}),tailM=new THREE.MeshBasicMaterial({color:'#e8352a'});
function makeCar(color,taxi,type){type=type||(taxi?'sedan':pick(['sedan','kei','kei','van','truck']));const T=CAR_TYPES[type],Gg=carGeoFor(type),g=new THREE.Group(),paint=tm(color);
  const add=(geo,mat,x,y,z,ol)=>{const m=new THREE.Mesh(geo,mat);m.position.set(x,y,z);m.castShadow=true;if(ol)outline(m,ol);g.add(m);return m;};
  const body=add(Gg.body,paint,0,0,0,0.03);add(Gg.side,glassM,0,0,0);
  const Fz=Math.max(...T.body.map(p=>p[0]))+0.1,Rz=Math.min(...T.body.map(p=>p[0]))-0.1,W=T.w/2;
  const pane=(a,b,w)=>{const dx=a[0]-b[0],dy=a[1]-b[1],l=Math.hypot(dx,dy),m=add(new THREE.PlaneGeometry(w,l),glassM,0,(a[1]+b[1])/2,(a[0]+b[0])/2);
    m.rotation.x=Math.atan2(-dx,-dy);m.translateZ(0.02);return m;};
  pane(T.front[0],T.front[1],T.w*0.84);if(T.rear)pane(T.rear[0],T.rear[1],T.w*0.8);
  const bump=new THREE.BoxGeometry(T.w+0.04,0.2,0.16);add(bump,greyM,0,0.4,Fz-0.02,0.01);if(!T.bed)add(bump,greyM,0,0.4,Rz+0.02,0.01);
  for(const s of [-1,1]){add(new THREE.BoxGeometry(0.3,0.13,0.05),headM,s*(W-0.28),0.66,Fz-0.04);
    if(!T.bed)add(new THREE.BoxGeometry(0.22,0.16,0.05),tailM,s*(W-0.22),0.72,Rz+0.04);
    add(new THREE.BoxGeometry(0.06,0.09,0.13),paint,s*(W+0.06),T.front[0][1]+0.16,T.front[0][0]-0.12,0.008);}
  add(new THREE.BoxGeometry(T.w*0.5,0.14,0.04),darkM,0,0.58,Fz-0.03);
  add(new THREE.PlaneGeometry(0.34,0.17),plateM,0,0.45,Fz+0.07);if(!T.bed){const rp=add(new THREE.PlaneGeometry(0.34,0.17),plateM,0,0.45,Rz-0.07);rp.rotation.y=Math.PI;}
  const wg=new THREE.CylinderGeometry(T.r,T.r,0.22,16).rotateZ(Math.PI/2),rg=new THREE.CylinderGeometry(T.r*0.6,T.r*0.6,0.235,12).rotateZ(Math.PI/2),wheels=[];
  for(const z of T.wheel)for(const s of [-1,1]){const w=add(wg,tireM,s*(W-0.15),T.r,z,0.01);add(rg,rimM,s*(W-0.15),T.r,z);wheels.push(w);}
  if(T.bed){add(new THREE.BoxGeometry(T.w,0.08,1.85),paint,0,0.68,-0.8,0.02);for(const s of [-1,1])add(new THREE.BoxGeometry(0.06,0.32,1.85),paint,s*(W-0.03),0.88,-0.8,0.012);
    add(new THREE.BoxGeometry(T.w,0.32,0.06),paint,0,0.88,-1.7,0.012);add(new THREE.BoxGeometry(T.w,0.06,0.06),darkM,0,1.05,0.12);
    for(let k=0;k<4;k++)add(new THREE.BoxGeometry(0.5,0.3,0.4),tm('#c9a06a'),-0.35+(k%2)*0.55,0.87,-0.45-Math.floor(k/2)*0.6,0.01);
    for(const s of [-1,1])add(new THREE.BoxGeometry(0.18,0.14,0.05),tailM,s*(W-0.2),0.6,-1.72);}
  if(taxi){const sg=new THREE.Group();sg.position.set(0,1.36,-0.15);g.add(sg);const lamp=new THREE.Mesh(new THREE.BoxGeometry(0.5,0.22,0.24),[tm('#f7f4e8'),tm('#f7f4e8'),tm('#f7f4e8'),tm('#f7f4e8'),
      tmap(canvasTex(64,32,(c,w,h)=>{c.fillStyle='#f7f4e8';c.fillRect(0,0,w,h);c.fillStyle='#d23a2c';c.font='bold 16px sans-serif';c.textAlign='center';c.textBaseline='middle';c.fillText('TAXI',w/2,h/2+1);})),tm('#f7f4e8')]);lamp.position.y=0.11;sg.add(lamp);outline(lamp,0.008);
    const band=add(new THREE.BoxGeometry(T.w+0.03,0.07,T.len*0.7),tm('#2b2b2b'),0,0.86,-0.1);}
  g.userData={type,len:T.len,w:T.w,wheels};world.add(g);return g;}
const CARS=[];
const KEI=['#bfe3d0','#f2e6c6','#bcd6ee','#f2f2ee','#e8b5b5','#f4f2ec'];
for(let k=0;k<9;k++){const dir=k%2?-1:1,taxi=k===2||k===5,type=taxi?'sedan':['kei','sedan','van','kei','truck','sedan','kei'][k%7];
  CARS.push({g:makeCar(taxi?'#f2c230':type==='kei'||type==='truck'?pick(KEI):pick(CAR_COLORS),taxi,type),dir,x:-250+k*57,z:COAST_Z+(dir>0?-2.2:2.2),v:7,v0:6+rnd()*3});}
for(const [x,z,yaw,col] of [[80,201.5,Math.PI/2,'#f2c230'],[93.6,60,0,'#f2f2ee'],[-123.8,120,Math.PI,'#2e5fa8'],[60,92.2,Math.PI/2,'#d23b33'],[-60,172.2,-Math.PI/2,'#5aa36b']]){
  const g=makeCar(col,col==='#f2c230');g.position.set(x,G(x,z)+0.02,z);g.rotation.y=yaw;const c=Math.abs(Math.cos(yaw)),s=Math.abs(Math.sin(yaw)),hl=g.userData.len/2+0.1,hw=g.userData.w/2;
  collide(x-(hw*c+hl*s),x+(hw*c+hl*s),z-(hw*s+hl*c),z+(hw*s+hl*c),'car',G(x,z)+(g.userData.type==='van'?1.9:g.userData.type==='kei'?1.58:g.userData.type==='truck'?0.95:1.38));}
CARS.forEach(c=>{c.box=collide(0,0,0,0,'car');});
function updateCars(dt){for(const c of CARS){let gap=1e9;for(const o of CARS){if(o===c||o.dir!==c.dir)continue;let d=(o.x-c.x)*c.dir;if(d<0)d+=520;if(d<gap)gap=d;}
    const pd=(P.x-c.x)*c.dir;if(Math.abs(P.z-c.z)<2.2&&pd>0&&pd<9)gap=Math.min(gap,pd);
    const tv=gap<7?0:gap<16?c.v0*(gap-7)/9:c.v0;c.v+=(tv-c.v)*Math.min(1,dt*2.5);c.x+=c.dir*c.v*dt;if(c.x>260)c.x-=520;if(c.x<-260)c.x+=520;for(const w of c.g.userData.wheels)w.rotation.x+=c.v*dt/0.3;
    c.g.position.set(c.x,G(clamp(c.x,-CUT_X,CUT_X),c.z)+0.02,c.z);c.g.rotation.y=c.dir>0?Math.PI/2:-Math.PI/2;const hl=c.g.userData.len/2+0.1;Object.assign(c.box,{x0:c.x-hl,x1:c.x+hl,z0:c.z-0.9,z1:c.z+0.9,top:G(clamp(c.x,-CUT_X,CUT_X),c.z)+1.45});}}

/* ---------- items, shops, errands ---------- */
const ITEMS={
  melon:{name:'メロンパン',d:(g,s)=>{g.fillStyle='#e9b44c';g.beginPath();g.arc(s/2,s/2,s*0.36,0,7);g.fill();g.strokeStyle='rgba(150,90,30,.55)';g.lineWidth=2;for(let k=-2;k<=2;k++){g.beginPath();g.moveTo(s*0.2,s/2+k*s*0.12);g.lineTo(s*0.8,s/2+k*s*0.12);g.stroke();}}},
  anpan:{name:'あんパン',d:(g,s)=>{g.fillStyle='#a8662f';g.beginPath();g.arc(s/2,s/2,s*0.36,0,7);g.fill();g.fillStyle='#f3e7d0';g.beginPath();g.arc(s/2,s*0.44,s*0.06,0,7);g.fill();}},
  cream:{name:'クリームパン',d:(g,s)=>{g.fillStyle='#e0a95c';g.beginPath();g.ellipse(s/2,s/2,s*0.38,s*0.28,0,0,7);g.fill();g.strokeStyle='rgba(120,70,20,.5)';g.lineWidth=2;for(let k=-1;k<=1;k++){g.beginPath();g.moveTo(s/2+k*s*0.14,s*0.3);g.lineTo(s/2+k*s*0.18,s*0.42);g.stroke();}}},
  shokupan:{name:'食パン',d:(g,s)=>{g.fillStyle='#d99a4e';g.fillRect(s*0.18,s*0.28,s*0.64,s*0.48);g.fillStyle='#f6e3bb';g.fillRect(s*0.24,s*0.36,s*0.52,s*0.36);}},
  ramune:{name:'ラムネ',d:(g,s)=>{g.fillStyle='#8fd0f0';g.beginPath();g.moveTo(s*0.38,s*0.85);g.lineTo(s*0.62,s*0.85);g.lineTo(s*0.62,s*0.45);g.lineTo(s*0.55,s*0.32);g.lineTo(s*0.55,s*0.15);g.lineTo(s*0.45,s*0.15);g.lineTo(s*0.45,s*0.32);g.lineTo(s*0.38,s*0.45);g.fill();
    g.fillStyle='#3a7bd5';g.fillRect(s*0.38,s*0.55,s*0.24,s*0.14);g.fillStyle='#fff';g.beginPath();g.arc(s/2,s*0.36,s*0.04,0,7);g.fill();}},
  ocha:{name:'お茶',d:(g,s)=>{g.fillStyle='#5a9a3a';g.fillRect(s*0.36,s*0.25,s*0.28,s*0.6);g.fillStyle='#f2f2ee';g.fillRect(s*0.36,s*0.42,s*0.28,s*0.18);g.fillStyle='#3a6b2a';g.fillRect(s*0.42,s*0.15,s*0.16,s*0.1);}},
  kinako:{name:'きなこ棒',d:(g,s)=>{g.fillStyle='#d9b26a';g.fillRect(s*0.4,s*0.2,s*0.2,s*0.5);g.fillStyle='#c9a06a';g.fillRect(s*0.48,s*0.7,s*0.04,s*0.15);}},
  mikan:{name:'みかん',d:(g,s)=>{g.fillStyle='#f29a2e';g.beginPath();g.arc(s/2,s*0.54,s*0.3,0,7);g.fill();g.fillStyle='#4f8a3a';g.beginPath();g.ellipse(s*0.56,s*0.26,s*0.1,s*0.05,-0.5,0,7);g.fill();}},
  himono:{name:'あじの干物',d:(g,s)=>{g.fillStyle='#b88a5a';g.beginPath();g.ellipse(s/2,s/2,s*0.38,s*0.18,0,0,7);g.fill();g.beginPath();g.moveTo(s*0.86,s/2);g.lineTo(s*0.96,s*0.36);g.lineTo(s*0.96,s*0.64);g.fill();g.fillStyle='#2b2520';g.beginPath();g.arc(s*0.22,s*0.48,s*0.03,0,7);g.fill();}},
  bouquet:{name:'花束',d:(g,s)=>{g.fillStyle='#e9e2d4';g.beginPath();g.moveTo(s*0.5,s*0.92);g.lineTo(s*0.26,s*0.45);g.lineTo(s*0.74,s*0.45);g.fill();
    for(const [x,y,c] of [[0.38,0.34,'#e2584a'],[0.6,0.3,'#f2c230'],[0.5,0.42,'#f0a0b8'],[0.32,0.48,'#ffffff'],[0.66,0.46,'#a070d0']]){g.fillStyle=c;g.beginPath();g.arc(s*x,s*y,s*0.1,0,7);g.fill();}}},
  letter:{name:'手紙',d:(g,s)=>{g.fillStyle='#fffaf0';g.fillRect(s*0.18,s*0.3,s*0.64,s*0.42);g.strokeStyle='#c9b9a2';g.lineWidth=2;g.strokeRect(s*0.18,s*0.3,s*0.64,s*0.42);g.beginPath();g.moveTo(s*0.18,s*0.3);g.lineTo(s/2,s*0.52);g.lineTo(s*0.82,s*0.3);g.stroke();g.fillStyle='#d23a2c';g.fillRect(s*0.66,s*0.34,s*0.1,s*0.1);}},
};
const ICON={};for(const id in ITEMS){const c=document.createElement('canvas');c.width=c.height=64;ITEMS[id].d(c.getContext('2d'),64);ICON[id]=c.toDataURL();}
const MENUS={
  bakery:{title:'こむぎ堂',sub:'焼きたてのパンがならんでいる。',items:[['melon',150,'外はさくさく、中はふんわり'],['anpan',130,'つぶあん たっぷり'],['cream',140,'自家製カスタード'],['shokupan',280,'朝ごはんに 1斤']]},
  dagashi:{title:'駄菓子 まるや',sub:'昔ながらのお菓子と冷えたラムネ。',items:[['ramune',120,'ビー玉入り'],['kinako',20,'当たりつき']]},
  yaoya:{title:'八百吉',sub:'朝どれの野菜と果物。',items:[['mikan',200,'甘いのを ひと袋']]},
  fish:{title:'魚松',sub:'港から届いたばかり。',items:[['himono',400,'港で干した あじ']]},
  flower:{title:'花のはなもり',sub:'季節の花がそろっている。',items:[['bouquet',300,'小さな花束']]},
  vend:{title:'自動販売機',sub:'よく冷えている。',items:[['ramune',130,''],['ocha',120,'']]},
};
const SPOTS=[{id:'lookout',name:'見晴らし台',x:0,z:-209},{id:'torii',name:'神社の鳥居',x:-60,z:-119.5},{id:'crossing',name:'海が見える踏切',x:3,z:TRAM_Z-7},{id:'station',name:'うみまち駅',x:62,z:TRAM_Z-1.5},{id:'pier',name:'桟橋の先',x:-80,z:PIER.z1-4}];
const QUESTS=[
  {id:'melon',title:'メロンパンをふたつ',giver:'tome',
   start:['あら、スケボーのお嬢ちゃん。いい風だねえ。','商店街の「こむぎ堂」のメロンパンが食べたくてね。でも、この坂を下りるのがしんどくて…','ふたつ買ってきてくれるかい？ お代はあとでちゃんと渡すからね。'],
   steps:[{type:'have',item:'melon',n:2,at:'bakery',hint:'しおかぜ商店街の「こむぎ堂」でメロンパンを2つ買う'},
          {type:'deliver',to:'tome',item:'melon',n:2,hint:'神社の鳥居のそば、トメさんに届ける',text:['まあまあ、まだあったかいねえ。','ありがとうね。パン代と、これはお駄賃。坂の上の景色も、ゆっくり見ておいき。']}],
   reward:500,wait:['こむぎ堂は、坂を下りた商店街にあるよ。']},
  {id:'flower',title:'花束のおとどけ',giver:'hana',
   start:['ちょうどよかった！ 喫茶しおさいのマスターから、お店に飾る花束を頼まれてて。','でも今、手がはなせないの。届けてくれる？ 商店街の向かいの方よ。'],give:['bouquet',1],
   steps:[{type:'deliver',to:'master',item:'bouquet',n:1,hint:'喫茶しおさいのマスターに花束を届ける',text:['おお、はなもりさんの花束だね。','いい香りだ。お店がぱっと明るくなるよ。ありがとう。']}],reward:400,wait:['しおさいは同じ商店街、本屋さんのとなりよ。']},
  {id:'letter',title:'手紙をポストへ',giver:'master',requires:'flower',
   start:['そうだ、ついでにもうひとつ頼めるかな。','遠くの友だちへの手紙なんだ。海岸通りの赤いポストに入れてきてくれないか。'],give:['letter',1],
   steps:[{type:'post',item:'letter',hint:'海岸通りの赤いポストに手紙を入れる',text:['ことん。手紙がポストの中に落ちた。']},{type:'talk',to:'master',hint:'喫茶しおさいのマスターに知らせる',text:['ありがとう。返事が来たら、きみにも話すよ。','これはお礼。今度はコーヒーを飲みにおいで。']}],reward:300},
  {id:'ramune',title:'浜辺にラムネを',giver:'sota',
   start:['ねえねえ！ 今からみんなで砂のお城をつくるんだ。','でも、のどがかわいちゃって…。ラムネを3本買ってきてくれない？ 商店街の「まるや」か、自販機にあるよ！'],
   steps:[{type:'have',item:'ramune',n:3,at:'dagashi',hint:'駄菓子まるや か 自販機でラムネを3本買う'},{type:'deliver',to:'sota',item:'ramune',n:3,hint:'浜辺のソウタくんに届ける',text:['やったー！ ビー玉、ころころいってる！','おねえちゃん、ありがと！ これ、お母さんからもらったおこづかい！']}],reward:400,wait:['まるやは商店街の、魚屋さんの反対側だよ！']},
  {id:'cat',title:'迷子のミケ',giver:'okami',
   start:['ちょいと聞いておくれ。うちの三毛猫のミケが、朝から帰ってこないんだよ。','あの子は高いところが好きでねえ。坂の上の神社のあたりかもしれない。見かけたら教えておくれ。'],
   steps:[{type:'find',hint:'神社のあたりでミケを探す',text:['ニャア。…いた！ 本殿の石段で、のんびり日なたぼっこしている。']},{type:'talk',to:'okami',hint:'魚松のおかみさんに知らせる',text:['神社の石段に？ まったく、あの子ったら！','知らせてくれてありがとね。これ、うちの干物。持っておいき。']}],reward:600,rewardItem:['himono',1]},
  {id:'photo',title:'海街の景色めぐり',giver:'neko',
   start:['この町の古い写真集を見ていたら、今の景色も残したくなってね。','見晴らし台、神社の鳥居、海が見える踏切、駅のホーム、桟橋の先。この5か所の写真を撮ってきてくれないか。','カメラのマークのところで P キーか「写真を撮る」だ。'],
   steps:[{type:'photos',hint:'カメラのマークの5か所で写真を撮る'},{type:'talk',to:'neko',hint:'古書うみねこの店主に写真を見せる',text:['ほう…どれもいい写真だ。この町の夏が写っている。','お礼に、これを。またいい景色を見つけたら教えておくれ。']}],reward:800},
];
const S0={money:600,inv:{},qs:{},tracked:null,spots:[]};
let SAVE=(()=>{try{const s=JSON.parse(store.get('umimachi_save')||'null');if(s&&typeof s.money==='number')return Object.assign({},S0,s);}catch(e){}return JSON.parse(JSON.stringify(S0));})();
function save(){store.set('umimachi_save',JSON.stringify(SAVE));}
const qs=id=>SAVE.qs[id]||(SAVE.qs[id]={state:0,step:0});
const QBY=id=>QUESTS.find(q=>q.id===id);
function invN(id){return SAVE.inv[id]||0;}
function addItem(id,n){SAVE.inv[id]=invN(id)+n;if(SAVE.inv[id]<=0)delete SAVE.inv[id];renderBag();}
function stepOf(q){const s=qs(q.id);return s.state===1?q.steps[s.step]:null;}
function available(q){const s=qs(q.id);return s.state===0&&(!q.requires||qs(q.requires).state===2);}
function advance(q){const s=qs(q.id);s.step++;if(s.step>=q.steps.length){s.state=2;SAVE.money+=q.reward;toast(`おつかい完了「${q.title}」 +${q.reward}円`,true);
    if(q.rewardItem){addItem(...q.rewardItem);toast(`${ITEMS[q.rewardItem[0]].name}をもらった`);}
    if(SAVE.tracked===q.id){const nx=QUESTS.find(o=>qs(o.id).state===1);SAVE.tracked=nx?nx.id:null;}}
  autoSteps();save();renderHUD();}
function autoSteps(){for(const q of QUESTS){const st=stepOf(q);if(st&&st.type==='have'&&invN(st.item)>=st.n){qs(q.id).step++;toast(`${ITEMS[st.item].name}がそろった。次は「${q.steps[qs(q.id).step].hint}」`);}
  if(st&&st.type==='photos'&&SPOTS.every(p=>SAVE.spots.includes(p.id))){qs(q.id).step++;toast('5か所すべて撮れた！');}}}
function accept(q){const s=qs(q.id);s.state=1;s.step=0;if(q.give){addItem(...q.give);toast(`${ITEMS[q.give[0]].name}をあずかった`);}SAVE.tracked=q.id;toast(`おつかい「${q.title}」をひきうけた`,true);autoSteps();save();renderHUD();}
function targetOf(q){const st=stepOf(q);if(!st)return null;
  if(st.type==='have'){if(st.at==='dagashi'){const a=SHOPS.dagashi.door,v=VEND[0];return Math.hypot(P.x-v.x,P.z-v.z)<Math.hypot(P.x-a[0],P.z-a[1])?[v.x,v.z]:a;}return SHOPS[st.at].door;}
  if(st.type==='deliver'||st.type==='talk'){const n=NPCS[st.to];return[n.x,n.z];}
  if(st.type==='post')return[POSTBOX.x,POSTBOX.z];if(st.type==='find')return[-60,-150];
  if(st.type==='photos'){let best=null,bd=1e9;for(const p of SPOTS){if(SAVE.spots.includes(p.id))continue;const d=Math.hypot(P.x-p.x,P.z-p.z);if(d<bd){bd=d;best=[p.x,p.z];}}return best;}
  return null;}

/* ---------- HUD ---------- */
function toast(t,gold){const d=document.createElement('div');d.className='tst card'+(gold?' gold':'');d.textContent=t;const T=$('toast');T.appendChild(d);while(T.children.length>3)T.firstChild.remove();setTimeout(()=>d.remove(),2900);}
function renderBag(){const B=$('bag');B.innerHTML='';for(const id in SAVE.inv){const d=document.createElement('div');d.className='it';const im=document.createElement('img');im.src=ICON[id];im.alt=ITEMS[id].name;
  d.append(im,document.createTextNode('×'+SAVE.inv[id]));d.title=ITEMS[id].name;B.appendChild(d);}}
function renderHUD(){$('money').textContent=SAVE.money.toLocaleString('ja-JP');const q=SAVE.tracked&&QBY(SAVE.tracked),tr=$('tracker');
  if(q&&qs(q.id).state===1){const st=stepOf(q);tr.hidden=false;tr.innerHTML='';const b=document.createElement('b');b.textContent=q.title;const s=document.createElement('span');s.className='step';s.textContent=st.hint;tr.append(b,s);
    let m='';if(st.type==='have')m=`${ITEMS[st.item].name} ${Math.min(invN(st.item),st.n)} / ${st.n}`;if(st.type==='photos')m=`写真 ${SAVE.spots.length} / ${SPOTS.length}`;
    if(m){const e=document.createElement('span');e.className='meter';e.textContent=m;tr.appendChild(e);}}
  else tr.hidden=true;renderBag();}
function renderLog(){const L=$('logList');L.innerHTML='';for(const q of QUESTS){const s=qs(q.id);if(s.state===0&&!available(q))continue;
  const d=document.createElement('div');d.className='q'+(SAVE.tracked===q.id?' on':'');const st=document.createElement('span');
  st.className='st '+(s.state===2?'done':s.state===1?'act':'new');st.textContent=s.state===2?'完了':s.state===1?'おつかい中':'まだ話していない';
  const b=document.createElement('b');b.textContent=q.title;const h=document.createElement('span');
  h.textContent=s.state===1?q.steps[s.step].hint:s.state===2?`お礼 ${q.reward}円をもらった`:`${NPCS[q.giver].name}が困っているみたい`;
  d.append(st,b,h);if(s.state===1)d.addEventListener('click',()=>{SAVE.tracked=q.id;save();renderLog();renderHUD();});L.appendChild(d);}}
let modal=null;
function openModal(id){modal=id;$(id).hidden=false;}function closeModal(){if(!modal)return;$(modal).hidden=true;modal=null;canvas.focus();}
$('logBtn').addEventListener('click',()=>{renderLog();openModal('log');});$('logClose').addEventListener('click',closeModal);
$('albumBtn').addEventListener('click',()=>{renderAlbum();openModal('albumM');});$('albumClose').addEventListener('click',closeModal);
$('shopClose').addEventListener('click',closeModal);
let shopCam=null;
function openShop(key){shopCam=key;const m=MENUS[key];$('shopName').textContent=m.title;$('shopSub').textContent=m.sub;const L=$('shopList');L.innerHTML='';L.style.cssText='display:flex;flex-direction:column;gap:8px';
  const draw=()=>{L.innerHTML='';for(const [id,price,note] of m.items){const r=document.createElement('div');r.className='row';const im=document.createElement('img');im.src=ICON[id];im.alt='';
    const nm=document.createElement('div');nm.className='nm';nm.textContent=ITEMS[id].name;if(note){const sm=document.createElement('small');sm.textContent=note;nm.appendChild(sm);}
    const own=invN(id);if(own){const sm=document.createElement('small');sm.textContent=`持っている数 ${own}`;nm.appendChild(sm);}
    const pr=document.createElement('span');pr.className='pr';pr.textContent=price+'円';const bt=document.createElement('button');bt.className='buy';bt.textContent='買う';bt.disabled=SAVE.money<price;
    bt.addEventListener('click',()=>{if(SAVE.money<price)return;SAVE.money-=price;addItem(id,1);toast(`${ITEMS[id].name}を買った（-${price}円）`);autoSteps();save();renderHUD();draw();});
    r.append(im,nm,pr,bt);L.appendChild(r);}$('shopMoney').textContent=`さいふ ${SAVE.money.toLocaleString('ja-JP')}円`;};
  draw();openModal('shop');}
// dialog
let DLG=null;
function say(who,lines,done){DLG={who,lines:lines.slice(),done};$('dwho').textContent=who;$('dtext').textContent=DLG.lines.shift();$('dialog').hidden=false;}
function nextLine(){if(!DLG)return;if(DLG.lines.length){$('dtext').textContent=DLG.lines.shift();return;}const d=DLG.done;DLG=null;$('dialog').hidden=true;talkNpc=null;if(d)d();}
$('dialog').addEventListener('click',nextLine);
let talkNpc=null;
function talk(n){talkNpc=n;
  for(const q of QUESTS){const st=stepOf(q);if(!st)continue;
    if((st.type==='deliver'||st.type==='talk')&&st.to===n.id){
      if(st.type==='deliver'&&invN(st.item)<st.n){say(n.name,[`${ITEMS[st.item].name}を${st.n}つ、持ってきてくれたら うれしいな。`]);return;}
      say(n.name,st.text,()=>{if(st.type==='deliver')addItem(st.item,-st.n);advance(q);});return;}}
  for(const q of QUESTS){if(q.giver===n.id&&available(q)){say(n.name,q.start,()=>accept(q));return;}}
  for(const q of QUESTS){if(q.giver===n.id&&qs(q.id).state===1&&q.wait){say(n.name,q.wait);return;}}
  if(n.id==='baker'){say(n.name,n.idle,()=>openShop('bakery'));return;}
  if(n.id==='maru'){say(n.name,n.idle,()=>openShop('dagashi'));return;}
  say(n.name||'町の人',[pick(n.idle.length?n.idle:['いい天気ですね。'])]);}

/* ---------- photos ---------- */
let ALBUM=(()=>{try{return JSON.parse(store.get('umimachi_album')||'[]');}catch(e){return[];}})(),photoReq=false;
function snap(){const src=renderer.domElement,w=360,h=Math.round(w*src.height/src.width);const c=document.createElement('canvas');c.width=w;c.height=h;const g=c.getContext('2d');g.drawImage(src,0,0,w,h);
  g.fillStyle='rgba(255,250,240,.85)';g.font='700 13px "Zen Maru Gothic", sans-serif';g.textAlign='right';g.fillText(placeName(),w-10,h-10);
  let url='';try{url=c.toDataURL('image/jpeg',0.78);}catch(e){}
  const near=SPOTS.find(p=>Math.hypot(P.x-p.x,P.z-p.z)<9);
  player.happyT=1.6;ALBUM.unshift({url,cap:near?near.name:placeName()});ALBUM=ALBUM.slice(0,12);
  let ok=store.set('umimachi_album',JSON.stringify(ALBUM));while(!ok&&ALBUM.length>1){ALBUM.pop();ok=store.set('umimachi_album',JSON.stringify(ALBUM));}
  const f=$('flash');f.style.transition='none';f.style.opacity=0.9;requestAnimationFrame(()=>{f.style.transition='opacity .5s';f.style.opacity=0;});
  const pq=QUESTS.find(q=>q.id==='photo'),st=pq&&stepOf(pq);
  if(near&&st&&st.type==='photos'&&!SAVE.spots.includes(near.id)){SAVE.spots.push(near.id);toast(`${near.name}を撮った（${SAVE.spots.length}/${SPOTS.length}）`,true);autoSteps();save();renderHUD();}
  else toast(near?`${near.name}で1枚`:'パシャ。アルバムに残した');}
function renderAlbum(){const A=$('albumGrid');A.innerHTML='';if(!ALBUM.length){const p=document.createElement('p');p.className='sub';p.textContent='まだ写真がありません。気に入った景色で撮ってみよう。';A.appendChild(p);return;}
  for(const a of ALBUM){const f=document.createElement('figure');const im=document.createElement('img');im.src=a.url;im.alt=a.cap;const c=document.createElement('figcaption');c.textContent=a.cap;f.append(im,c);A.appendChild(f);}}
$('photoBtn').addEventListener('click',()=>{photoReq=true;});
// markers floating in the world
const markTex=(ch,bg)=>canvasTex(64,64,(g,w,h)=>{g.fillStyle=bg;g.beginPath();g.arc(32,30,24,0,7);g.fill();g.beginPath();g.moveTo(22,48);g.lineTo(42,48);g.lineTo(32,62);g.fill();
  g.fillStyle='#fff';g.font='900 32px "Zen Maru Gothic", sans-serif';g.textAlign='center';g.textBaseline='middle';g.fillText(ch,32,31);});
const MK={quest:new THREE.SpriteMaterial({map:markTex('!','#f2a33a'),depthTest:false}),target:new THREE.SpriteMaterial({map:markTex('↓','#e2584a'),depthTest:false}),
  cam:new THREE.SpriteMaterial({map:canvasTex(64,64,(g,w,h)=>{g.fillStyle='#1f7fc0';g.beginPath();g.arc(32,32,26,0,7);g.fill();g.fillStyle='#fff';g.fillRect(16,24,32,22);g.fillRect(26,19,12,6);g.fillStyle='#1f7fc0';g.beginPath();g.arc(32,35,7,0,7);g.fill();}),depthTest:false})};
const markers=[];function marker(mat){const s=new THREE.Sprite(mat);s.scale.set(0.9,0.9,1);s.renderOrder=5;scene.add(s);markers.push(s);return s;}
const qMarks={};for(const q of QUESTS)qMarks[q.id]=marker(MK.quest);
const tMark=marker(MK.target);tMark.scale.set(1.3,1.3,1);
const beam=new THREE.Mesh(new THREE.CylinderGeometry(0.6,0.6,40,16,1,true),new THREE.MeshBasicMaterial({color:'#ffd27a',transparent:true,opacity:0.22,depthWrite:false,side:THREE.DoubleSide}));scene.add(beam);
const camMarks=SPOTS.map(p=>{const s=marker(MK.cam);s.position.set(p.x,G(p.x,p.z)+2.6,p.z);return s;});

/* ---------- the map ---------- */
const MAP_X0=-320,MAP_Z0=-260,MAPW=640,MAPH=700;
const mapBase=document.createElement('canvas');mapBase.width=MAPW;mapBase.height=MAPH;
{ const g=mapBase.getContext('2d');g.fillStyle='#bcd9a8';g.fillRect(0,0,MAPW,MAPH);
  g.fillStyle='#e9dcb5';g.fillRect(0,SHORE-MAP_Z0,MAPW,40);g.fillStyle='#7cc0e6';g.fillRect(0,SHORE+(0-SEA_Y)/0.035-MAP_Z0,MAPW,MAPH);
  g.fillStyle='#8fbf80';g.fillRect(0,0,MAPW,-182-MAP_Z0);g.fillRect(0,0,120,MAPH*0.7);g.fillRect(MAPW-118,0,118,MAPH*0.7);
  for(const b of BLD){g.fillStyle=b.kind==='named'?'#e2a070':'#d8d0c2';g.fillRect(b.x0-MAP_X0,b.z0-MAP_Z0,b.x1-b.x0,b.z1-b.z0);}
  for(const S of STREETS){const bx=streetBox(S,0);g.fillStyle=S.kind==='shop'?'#f2e2c4':'#ffffff';g.fillRect(bx.x0-MAP_X0,bx.z0-MAP_Z0,bx.x1-bx.x0,bx.z1-bx.z0);}
  g.strokeStyle='#5a6b72';g.setLineDash([4,3]);g.lineWidth=2;g.beginPath();g.moveTo(0,TRAM_Z-MAP_Z0);g.lineTo(MAPW,TRAM_Z-MAP_Z0);g.stroke();g.setLineDash([]);
  g.fillStyle='#a88a64';g.fillRect(PIER.x0-MAP_X0,PIER.z0-MAP_Z0,PIER.x1-PIER.x0,PIER.z1-PIER.z0);
  g.fillStyle='#d8452f';g.fillRect(SHRINE.x-MAP_X0-3,SHRINE.z-MAP_Z0-2,6,4);}
const mapc=$('mapc'),mg=mapc.getContext('2d');
function drawMap(){const V=150,S=mapc.width/V,cx=P.x-MAP_X0,cz=P.z-MAP_Z0;mg.fillStyle='#7cc0e6';mg.fillRect(0,0,mapc.width,mapc.height);
  mg.drawImage(mapBase,cx-V/2,cz-V/2,V,V,0,0,mapc.width,mapc.height);
  const toM=(x,z)=>[(x-P.x)*S+mapc.width/2,(z-P.z)*S+mapc.height/2];
  for(const p of SPOTS){const [mx,my]=toM(p.x,p.z);mg.fillStyle=SAVE.spots.includes(p.id)?'#9aa6ae':'#1f7fc0';mg.beginPath();mg.arc(mx,my,5,0,7);mg.fill();}
  for(const q of QUESTS){if(!available(q))continue;const n=NPCS[q.giver],[mx,my]=toM(n.x,n.z);mg.fillStyle='#f2a33a';mg.beginPath();mg.arc(mx,my,7,0,7);mg.fill();mg.fillStyle='#fff';mg.font='900 11px sans-serif';mg.textAlign='center';mg.textBaseline='middle';mg.fillText('!',mx,my+1);}
  const q=SAVE.tracked&&QBY(SAVE.tracked),t=q&&targetOf(q);
  if(t){let [mx,my]=toM(t[0],t[1]);const W=mapc.width,pad=10,out=mx<pad||my<pad||mx>W-pad||my>W-pad;mx=clamp(mx,pad,W-pad);my=clamp(my,pad,W-pad);
    mg.fillStyle='#e2584a';mg.beginPath();mg.arc(mx,my,out?6:8,0,7);mg.fill();mg.strokeStyle='#fff';mg.lineWidth=2;mg.stroke();}
  mg.save();mg.translate(mapc.width/2,mapc.height/2);mg.rotate(-P.yaw+Math.PI);mg.fillStyle='#2b2520';mg.beginPath();mg.moveTo(0,-9);mg.lineTo(6,7);mg.lineTo(0,3);mg.lineTo(-6,7);mg.closePath();mg.fill();mg.restore();
  mg.fillStyle='rgba(43,37,32,.7)';mg.font='700 11px sans-serif';mg.textAlign='left';mg.fillText('山',6,14);mg.fillText('海',6,mapc.height-6);}
function placeName(){const x=P.x,z=P.z;
  if(Math.hypot(x-LOOKOUT.x,z-LOOKOUT.z)<16)return'見晴らし台';for(const d of RIDGE_DECKS)if(Math.hypot(x-d.x,z-d.z)<12)return d.name;if(Math.abs(x)>212&&z<SHORE)return x>0?'東の山':'西の山';if(x>-80&&x<-40&&z>-178&&z<-118)return'海街神社';
  if(onPier(x,z))return'桟橋';if(z>SHORE)return'しおさい海岸';if(x>STATION.x0-4&&x<STATION.x1+4&&Math.abs(z-TRAM_Z)<8)return'うみまち駅';
  if(Math.abs(z-TRAM_Z)<4)return'うみまち線の線路';
  let best=null,bd=1e9;for(const S of STREETS){const b=streetBox(S,3);if(x>b.x0&&x<b.x1&&z>b.z0&&z<b.z1){const d=S.ax==='z'?Math.abs(x-S.c):Math.abs(z-S.c);if(d<bd){bd=d;best=S;}}}
  return best?best.name:'海街の路地';}

/* ---------- player ---------- */
const player=window.HEROINE_GLTF?makeSkaterVRM(HEROINE_GLTF):makeSkater();world.add(player.g);
if(player.vrm)applyOutfit(player,SAVE.outfit);
// the closet: one row per slot with its items and colour sets; changes show on the heroine at once and are saved
function renderCloset(){const box=$('closetSlots');box.innerHTML='';const cur=Object.assign({},DEFAULT_OUTFIT,SAVE.outfit||{});
  for(const S of WARDROBE){const [id,ci]=cur[S.slot];const it=findItem(S.slot,id);const items=S.items.filter(I=>ownsItem(SAVE,S.slot,I));const row=document.createElement('div');row.className='cslot';
    const lab=document.createElement('b');lab.textContent=S.label;row.appendChild(lab);const col=document.createElement('div');row.appendChild(col);
    if(items.length>1){const r=document.createElement('div');r.className='row';for(const I of items){const b=document.createElement('button');b.className='chip'+(I.id===it.id?' on':'');b.textContent=I.name;
        b.onclick=()=>{const k=(I.colors||[[]]).findIndex((c,ci)=>ownsKey(SAVE,S.slot+':'+I.id+':'+ci));setOutfit(S.slot,I.id,Math.max(0,k));};r.appendChild(b);}col.appendChild(r);}
    if(it.colors&&it.colors.length>1){const r=document.createElement('div');r.className='row';r.style.marginTop='4px';
      it.colors.forEach((cs,k)=>{if(!ownsKey(SAVE,S.slot+':'+it.id+':'+k))return;const b=document.createElement('button');b.className='sw'+(k===(ci||0)?' on':'');const a=cs[0]||'#7a4a30',c2=cs[1]||a;
        b.style.background=`linear-gradient(135deg,${a} 55%,${c2} 55%)`;b.title=it.name;b.onclick=()=>{setOutfit(S.slot,it.id,k);};r.appendChild(b);});col.appendChild(r);}
    box.appendChild(row);}}
function setOutfit(slot,id,ci){SAVE.outfit=Object.assign({},DEFAULT_OUTFIT,SAVE.outfit||{});SAVE.outfit[slot]=[id,ci];save();applyOutfit(player,SAVE.outfit);renderCloset();}
function openCloset(){if(!player.vrm){toast('この端末では着がえられない（主人公のモデルを読み込めなかった）');return;}renderCloset();openModal('closet');}
$('closetBtn').addEventListener('click',openCloset);
// the gacha at Maruya: rarity first, then an even pick among that rarity's prizes; duplicates turn into kakera
const RCOL={N:'#6f9fd0',R:'#d977a3',SR:'#e8b030'},RNAME={N:'ノーマル',R:'レア',SR:'スーパーレア'};
function swatchHTML(c){const a=c&&c[0]||'#7a4a30',b=c&&c[1]||a;return `<span class="sw" style="display:inline-block;background:linear-gradient(135deg,${a} 55%,${b} 55%)"></span>`;}
function gachaInfo(){SAVE.owned=SAVE.owned||{};const have=PRIZES.filter(p=>SAVE.owned[p.key]).length;
  $('gachaInfo').innerHTML=`さいふ <b>${SAVE.money}</b>円 ・ かけら <b>${SAVE.kakera||0}</b> ・ コレクション <b>${have}</b>/${PRIZES.length}<br><small>出る確率　スーパーレア${RATES.SR*100}%・レア${RATES.R*100}%・ノーマル${RATES.N*100}%</small>`;
  $('gachaOne').disabled=SAVE.money<100;$('gachaFive').disabled=SAVE.money<500;}
function renderGachaShop(){const box=$('gachaShop');box.innerHTML='';
  const sets=document.createElement('div');sets.className='grp';sets.innerHTML='<b>セット</b><br>'+COSTUME_SETS.map(S=>{const got=S.keys.filter(k=>{const [sl,id]=k.split(':');const it=findItem(sl,id);return it&&ownsItem(SAVE,sl,it);}).length;
    return `<span class="it${got===S.keys.length?' have':''}">${S.icon} ${S.name} ${got}/${S.keys.length}</span>`;}).join('');box.appendChild(sets);
  for(const r of ['SR','R','N']){const g=document.createElement('div');g.className='grp';g.innerHTML=`<b>${RNAME[r]}</b>（交換 かけら${KAKERA_COST[r]}）<br>`;
    for(const p of PRIZES.filter(p=>p.r===r)){const have=!!SAVE.owned[p.key],sp=document.createElement('span');sp.className='it'+(have?' have':'');sp.innerHTML=swatchHTML(p.col)+(have?p.name:'？？？');
      if(!have){const b=document.createElement('button');b.textContent='交換';b.disabled=(SAVE.kakera||0)<KAKERA_COST[r];b.onclick=()=>{SAVE.kakera-=KAKERA_COST[r];SAVE.owned[p.key]=1;save();showPrizes([{p,isNew:true}]);renderGachaShop();gachaInfo();};sp.appendChild(b);}
      g.appendChild(sp);}box.appendChild(g);}}
function showPrizes(res){const st=$('gachaStage');st.innerHTML='';
  res.forEach(({p,isNew},i)=>{const cap=document.createElement('div');cap.className='cap';cap.style.setProperty('--c',RCOL[p.r]);cap.style.animationDelay=(i*0.12)+'s,'+(0.5+i*0.12)+'s';st.appendChild(cap);});
  setTimeout(()=>{st.innerHTML='';res.forEach(({p,isNew,dup},i)=>{const d=document.createElement('div');d.className='prize';d.style.animationDelay=(i*0.08)+'s';
      d.innerHTML=`<span class="rr r-${p.r}">${RNAME[p.r]}</span><div class="nm">${p.name}</div>${swatchHTML(p.col)}${isNew?'<span class="nw">NEW</span>':`<div><small>ダブり → かけら+${KAKERA_DUP[p.r]}</small></div>`}`;
      if(player.vrm){const b=document.createElement('button');b.className='btn ghost';b.textContent='着てみる';b.onclick=()=>{setOutfit(p.slot,p.id,p.ci);toast(p.name+' を着てみた');};d.appendChild(b);}
      st.appendChild(d);});},1300);}
function pull(n){if(SAVE.money<100*n)return;SAVE.money-=100*n;SAVE.owned=SAVE.owned||{};const res=[];
  for(let i=0;i<n;i++){const p=drawPrize();const isNew=!SAVE.owned[p.key];if(isNew)SAVE.owned[p.key]=1;else SAVE.kakera=(SAVE.kakera||0)+KAKERA_DUP[p.r];res.push({p,isNew});}
  save();renderHUD();showPrizes(res);gachaInfo();renderGachaShop();}
function openGacha(){$('gachaStage').innerHTML='<div style="font-size:42px">🎰</div>';gachaInfo();renderGachaShop();openModal('gacha');}
$('gachaOne').addEventListener('click',()=>pull(1));$('gachaFive').addEventListener('click',()=>pull(5));$('gachaClose').addEventListener('click',closeModal);$('closetClose').addEventListener('click',closeModal);
$('closetReset').addEventListener('click',()=>{SAVE.outfit=JSON.parse(JSON.stringify(DEFAULT_OUTFIT));save();applyOutfit(player,SAVE.outfit);renderCloset();});
const P={x:3,z:-196,yaw:Math.PI,v:0,y:0,vy:0,air:false,turn:0,push:false,brake:false,bump:0,kickT:-1,kickCD:0,foot:false,tr:null,carry:'deck'};P.y=G(P.x,P.z);
const keys={};let jumpQ=false,actQ=false,kickQ=false,kickHold=false,footQ=false;
window.addEventListener('keydown',e=>{if(e.repeat&&e.code!=='KeyW'&&e.code!=='ArrowUp')return;keys[e.code]=true;
  if(['ArrowUp','ArrowDown','ArrowLeft','ArrowRight','Space'].includes(e.code)&&state==='play')e.preventDefault();
  if(state!=='play')return;
  if(e.code==='Space')jumpQ=true;if((e.code==='KeyW'||e.code==='ArrowUp')&&!e.repeat)kickQ=true;if(e.code==='KeyE'||e.code==='Enter'){if(DLG)nextLine();else if(!modal)actQ=true;}
  if(e.code==='Escape')closeModal();if(e.code==='KeyQ'&&!DLG){if(modal==='log')closeModal();else if(!modal){renderLog();openModal('log');}}
  if(e.code==='KeyP'&&!modal&&!DLG)photoReq=true;if(e.code==='KeyF'&&!e.repeat)footQ=true;if(e.code==='KeyC'&&!DLG){if(modal==='closet')closeModal();else if(!modal)openCloset();}});
window.addEventListener('keyup',e=>{keys[e.code]=false;});
window.addEventListener('blur',()=>{for(const k in keys)keys[k]=false;stick.on=false;});
const stick={on:false,id:null,x:0,y:0};
{ const el=$('stick'),kn=$('knob');const set=(e)=>{const r=el.getBoundingClientRect();let dx=e.clientX-(r.left+r.width/2),dy=e.clientY-(r.top+r.height/2);const L=Math.hypot(dx,dy),m=r.width/2-10;if(L>m){dx*=m/L;dy*=m/L;}
    stick.x=dx/m;stick.y=dy/m;kn.style.transform=`translate(${dx}px,${dy}px)`;};
  el.addEventListener('pointerdown',e=>{stick.on=true;stick.id=e.pointerId;try{el.setPointerCapture(e.pointerId);}catch(_){}set(e);});
  el.addEventListener('pointermove',e=>{if(stick.on&&e.pointerId===stick.id)set(e);});
  for(const ev of ['pointerup','pointercancel','lostpointercapture'])el.addEventListener(ev,()=>{stick.on=false;stick.x=stick.y=0;kn.style.transform='';});
  $('bJump').addEventListener('pointerdown',e=>{e.preventDefault();jumpQ=true;});
  $('bFoot').addEventListener('pointerdown',e=>{e.preventDefault();footQ=true;});
  const kb=$('bKick');kb.addEventListener('pointerdown',e=>{e.preventDefault();kickQ=true;kickHold=true;kb.classList.add('on');try{kb.setPointerCapture(e.pointerId);}catch(_){}});
  for(const ev of ['pointerup','pointercancel','lostpointercapture'])kb.addEventListener(ev,()=>{kickHold=false;kb.classList.remove('on');});
  kb.addEventListener('contextmenu',e=>e.preventDefault());
  $('bAct').addEventListener('pointerdown',e=>{e.preventDefault();if(DLG)nextLine();else if(!modal)actQ=true;});}
const hasTouch=('ontouchstart' in window)||navigator.maxTouchPoints>0;
function inputs(){let fwd=!!(keys.KeyW||keys.ArrowUp),back=!!(keys.KeyS||keys.ArrowDown),turn=((keys.KeyD||keys.ArrowRight)?1:0)-((keys.KeyA||keys.ArrowLeft)?1:0);
  fwd=fwd||kickHold;
  if(stick.on){if(stick.y>0.45)back=true;if(Math.abs(stick.x)>0.15)turn=clamp(stick.x*1.4,-1,1);}
  return{fwd,back,turn};}
const STEP=0.45;
function hits(x,z,r,y){for(const c of COLL){if(!c.on||c.top<=y+STEP)continue;if(x+r>c.x0&&x-r<c.x1&&z+r>c.z0&&z-r<c.z1)return c;}return null;}
// the highest surface under you that you are above: ground, a wall top, a crate, a car roof
function groundAt(x,z,y){let g=G(x,z);for(const c of COLL){if(!c.on||c.top>y+STEP||c.top<=g)continue;if(x>c.x0&&x<c.x1&&z>c.z0&&z<c.z1)g=c.top;}return g;}
function stepPlayer(dt){
  const busy=!!(DLG||modal);const I=busy?{fwd:false,back:true,turn:0}:inputs();
  const F=[Math.sin(P.yaw),Math.cos(P.yaw)];
  const g1=G(P.x+F[0]*0.6,P.z+F[1]*0.6),g0=G(P.x-F[0]*0.6,P.z-F[1]*0.6),slope=(g1-g0)/1.2;
  const sand=P.z>SHORE+0.5&&!onPier(P.x,P.z);
  // stepping off and on: F (or the button) starts a short transition; on foot she runs instead of kicking
  if(footQ&&!P.air&&!busy&&!P.tr)P.tr=P.foot?{type:'on',t:0,dur:0.6}:{type:'off',t:0,dur:0.85};footQ=false;
  if(P.tr){P.tr.t+=dt/P.tr.dur;if(P.tr.t>=1){const ty=P.tr.type;P.tr=null;
      if(ty==='off'){P.foot=true;P.carry='hand';}else if(ty==='stow')P.carry='back';else{P.foot=false;P.carry='deck';P.kickT=-1;P.kickCD=0.3;}
      $('bFoot').textContent=P.foot?'乗る':'降りる';}}
  const onFoot=P.foot||!!(P.tr&&P.tr.type!=='stow');
  let a=onFoot?0:-9.8*slope*0.5-(0.25+(sand?3.2:0))*Math.sign(P.v);
  if(onFoot){const still=P.tr&&P.tr.type!=='stow',tgt=still?0:I.fwd?7.5*(1-clamp(slope,0,0.6)*0.5)*(sand?0.7:1):0;
    P.v+=(tgt-P.v)*Math.min(1,dt*(tgt>P.v?1.6:still?5:6));kickQ=false;P.kickT=-1;
    if(P.foot&&P.carry==='hand'&&P.v>0.4&&!P.tr&&!player.backBusy)P.tr={type:'stow',t:0,dur:0.4};
    if(P.foot&&P.carry==='back'&&player.backBusy&&!P.tr)P.carry='hand';}
  // each kick: the back foot plants, shoves, and the board surges forward; holding the key keeps kicking
  P.kickCD-=dt;if(P.kickT>=0){P.kickT+=dt/0.48;if(P.kickT>=1)P.kickT=-1;}
  if(!onFoot&&(kickQ||I.fwd)&&!P.air&&!busy&&P.kickCD<=0&&P.kickT<0){P.kickT=0;P.kickCD=0.42;P.kicked=false;}kickQ=false;
  if(P.kickT>0.35&&!P.kicked){P.kicked=true;P.v=Math.min(P.v+1.3+3.3*Math.max(0,1-P.v/13),13.5);}
  P.push=P.kickT>=0;
  P.brake=I.back&&!onFoot;if(I.back&&!P.air&&!onFoot)a-=P.v>0.2?4.2:0;
  P.v=clamp(P.v+a*dt,0,16);if(Math.abs(P.v)<0.04&&!I.fwd)P.v=0;
  P.turn+=(I.turn-P.turn)*Math.min(1,8*dt);
  P.yaw-=P.turn*(onFoot?3.2:2.3-Math.min(1.1,P.v*0.1))*dt;
  const nx=P.x+F[0]*P.v*dt,nz=P.z+F[1]*P.v*dt,R=0.3;
  let ok=true;const water=G(nx,nz)<SEA_Y+0.1&&!onPier(nx,nz);if(water){ok=false;if(P.v>1)toast('海には入れない…ここから先は泳ぐしかない');P.v=0;}
  const c=ok&&hits(nx,nz,R,P.y);
  if(c){const hx=hits(nx,P.z,R,P.y),hz=hits(P.x,nz,R,P.y);
    if(!hx){P.x=nx;P.v*=0.7;}else if(!hz){P.z=nz;P.v*=0.7;}else{if(P.v>3.5){P.bump=0.35;}P.v*=0.15;}}
  else if(ok){P.x=nx;P.z=nz;}
  P.x=clamp(P.x,-336,336);P.z=clamp(P.z,-255,PIER.z1);
  const gy=groundAt(P.x,P.z,P.y);P.onTop=gy>G(P.x,P.z)+0.2;
  if(jumpQ&&!P.air&&!busy&&!(P.tr&&P.tr.type!=='stow')){P.vy=onFoot?5.6:7.6;P.air=true;}jumpQ=false;
  if(!P.air&&P.y-gy>0.3){P.air=true;P.vy=0;}
  if(P.air){P.vy-=13.5*dt;P.y+=P.vy*dt;if(P.y<=gy){if(P.vy<-9)P.bump=0.25;P.y=gy;P.air=false;P.vy=0;}}else P.y+=(gy-P.y)*Math.min(1,18*dt);
  player.g.position.set(P.x,P.y,P.z);
  const pitch=P.air?-P.vy*0.03:Math.atan(-slope);
  player.g.rotation.set(0,P.yaw,0);
  if(onFoot){player.root.rotation.set(0,0,0);poseRunner(player,dt,{v:P.v,turn:P.turn,air:P.air,vy:P.vy,tr:P.tr,carry:P.carry});}
  else{player.root.rotation.set(pitch*0.8,0,clamp(P.turn*P.v*0.03,-0.25,0.25));
    if(P.tr&&P.tr.type==='stow')P.tr=null;
    poseSkater(player,dt,{v:P.v,turn:P.turn,push:P.push,kick:P.kickT,brake:P.brake&&P.v>0.3,air:P.air,vy:P.vy});}
}

/* ---------- interaction ---------- */
let near=null;
function findNear(){let best=null,bd=1e9;const add=(d,o)=>{if(d<bd){bd=d;best=o;}};
  for(const id in NPCS){const n=NPCS[id];const d=Math.hypot(P.x-n.x,P.z-n.z);if(d<2.7)add(d,{kind:'npc',n,label:`話す　${n.name||'町の人'}`,verb:'話す'});}
  for(const id of ['bakery','dagashi','yaoya','fish','flower']){const b=SHOPS[id],d=Math.hypot(P.x-b.door[0],P.z-b.door[1]);if(d<2.4)add(d+0.3,{kind:'shop',id,label:`入る　${MENUS[id].title}`,verb:'入る'});}
  for(const v of VEND){const d=Math.hypot(P.x-v.x,P.z-v.z);if(d<1.6)add(d,{kind:'shop',id:'vend',label:'買う　自動販売機',verb:'買う'});}
  const lq=QBY('letter'),ls=stepOf(lq);if(ls&&ls.type==='post'){const d=Math.hypot(P.x-POSTBOX.x,P.z-POSTBOX.z);if(d<2.2)add(d,{kind:'post',label:'手紙を入れる　ポスト',verb:'入れる'});}
  const gp=SHOPS.dagashi.gacha;if(gp){const d=Math.hypot(P.x-gp.x,P.z-gp.z);if(d<1.9)add(d-0.2,{kind:'gacha',label:'まわす　カプセルトイ（1回100円）',verb:'まわす'});}
  const cd=Math.hypot(P.x-MIKE.x,P.z-MIKE.z);if(cd<2.6)add(cd,{kind:'cat',label:'なでる　三毛猫',verb:'なでる'});
  for(const p of SPOTS){const d=Math.hypot(P.x-p.x,P.z-p.z);if(d<7&&!best)add(d+5,{kind:'spot',p,label:`写真を撮る　${p.name}`,verb:'撮る'});}
  return best;}
function act(o){if(!o)return;
  if(o.kind==='npc')talk(o.n);else if(o.kind==='shop')openShop(o.id);
  else if(o.kind==='post'){const q=QBY('letter'),st=stepOf(q);say('ポスト',st.text,()=>{addItem('letter',-1);advance(q);});}
  else if(o.kind==='cat'){const q=QBY('cat'),st=stepOf(q);if(st&&st.type==='find')say('ミケ',st.text,()=>advance(q));else say('三毛猫',['ゴロゴロ…。日なたであくびをしている。']);}
  else if(o.kind==='spot')photoReq=true;
  else if(o.kind==='gacha')openGacha();}

/* ---------- camera ---------- */
const camPos=new THREE.Vector3(),camLook=new THREE.Vector3();let camInit=false;
const reduceMotion=window.matchMedia&&window.matchMedia('(prefers-reduced-motion: reduce)').matches;
function blocked(x,y,z){for(const c of COLL){if(c.tag!=='bld')continue;if(x>c.x0-0.3&&x<c.x1+0.3&&z>c.z0-0.3&&z<c.z1+0.3&&y<(c.top||99)+2.5)return true;}
  if(Math.abs(x)>195)for(const e of HILL_TREES){if(Math.abs(e.x-x)<e.s*1.1&&Math.abs(e.z-z)<e.s*1.1&&y<e.y+e.s*2.7&&Math.hypot(e.x-x,e.z-z)<e.s*1.05)return true;}return false;}
function updateCamera(dt){
  const F=new THREE.Vector3(Math.sin(P.yaw),0,Math.cos(P.yaw)),p=new THREE.Vector3(P.x,P.y,P.z);let want,look,rate=4;
  if(state==='title'){const a=Math.sin(clock*0.12)*0.35;want=new THREE.Vector3(P.x+Math.sin(a)*1.9-0.4,P.y+1.25,P.z-Math.cos(a)*1.9);look=new THREE.Vector3(P.x+0.35,P.y+0.95,P.z);rate=2;}
  else if(talkNpc){const n=talkNpc,m=new THREE.Vector3((P.x+n.x)/2,P.y,(P.z+n.z)/2),d=new THREE.Vector3(n.x-P.x,0,n.z-P.z).normalize(),side=new THREE.Vector3(-d.z,0,d.x);
    want=m.clone().addScaledVector(side,3.4).addScaledVector(d,-0.6);want.y+=1.5;if(blocked(want.x,want.y,want.z))want=m.clone().addScaledVector(side,-3.4).setY(m.y+1.5);look=m.clone();look.y+=1.15;rate=3;}
  else if(modal==='closet'){const fw=player.hips.getWorldDirection(new THREE.Vector3());fw.y=0;fw.normalize();
    want=p.clone().addScaledVector(fw,3.3).addScaledVector(new THREE.Vector3(-fw.z,0,fw.x),0.7);want.y+=1.05;look=p.clone();look.y+=0.05;rate=4;}
  else if(modal==='shop'&&shopCam&&SHOPS[shopCam]){const b=SHOPS[shopCam];const fw=new THREE.Vector3(Math.sin(b.yaw),0,Math.cos(b.yaw));
    want=new THREE.Vector3(b.fx,b.base,b.fz).addScaledVector(fw,7);want.y+=2.4;look=new THREE.Vector3(b.fx,b.base+2.4,b.fz);rate=3;}
  else{const back=3.3+P.v*0.12,up=1.45+P.v*0.035;want=p.clone().addScaledVector(F,-back);want.y+=up;look=p.clone().addScaledVector(F,2.2);look.y+=1.05;
    for(let t=1;t>0.25&&blocked(want.x,want.y,want.z);t-=0.1){want=p.clone().addScaledVector(F,-back*t);want.y+=up;}
    want.y=Math.max(want.y,G(want.x,want.z)+0.6);}
  if(!camInit){camPos.copy(want);camLook.copy(look);camInit=true;}
  camPos.lerp(want,1-Math.exp(-dt*rate));camLook.lerp(look,1-Math.exp(-dt*(rate+3)));
  camera.position.copy(camPos);if(P.bump>0&&!reduceMotion){camera.position.y+=(Math.random()-.5)*P.bump*0.3;}P.bump=Math.max(0,P.bump-dt);
  camera.lookAt(camLook);const fov=camera.aspect<0.8?72:58;camera.fov+=(fov+(reduceMotion?0:P.v*0.6)-camera.fov)*Math.min(1,3*dt);camera.updateProjectionMatrix();
  dome.position.copy(camera.position);
  const sp=state==='title'?new THREE.Vector3(0,30,-120):p;sun.position.copy(sp).addScaledVector(sunDir,70);sun.target.position.copy(sp);sun.target.updateMatrixWorld();
}

/* ---------- loop ---------- */
let state='title',clock=0,last=performance.now();
function updateNPCs(dt){for(const id in NPCS){const n=NPCS[id],d=Math.hypot(P.x-n.x,P.z-n.z);n.h.g.visible=d<110;if(!n.h.g.visible)continue;
    const giving=QUESTS.some(q=>q.giver===id&&available(q));
    poseHuman(n.h,n.mode,dt,{look:d<9||talkNpc===n?player.g.position:null,wave:giving&&d<14&&d>3&&n.mode!=='sit'});}
  for(const c of CATS)poseCat(c,dt,Math.hypot(P.x-c.g.position.x,P.z-c.g.position.z)<3);}
function updateMarkers(){const calm=!!(DLG||modal);for(const q of QUESTS){const m=qMarks[q.id],n=NPCS[q.giver];m.visible=available(q)&&state==='play'&&!calm;if(m.visible)m.position.set(n.x,n.h.g.position.y+(n.mode==='sit'?1.75:2.25)+Math.sin(clock*3)*0.08,n.z);}
  const q=SAVE.tracked&&QBY(SAVE.tracked),t=q&&targetOf(q);tMark.visible=beam.visible=!!t&&state==='play'&&!calm;
  if(t){const y=G(t[0],t[1]);tMark.position.set(t[0],y+2.9+Math.sin(clock*3)*0.12,t[1]);beam.position.set(t[0],y+20,t[1]);beam.material.opacity=clamp(Math.hypot(P.x-t[0],P.z-t[1])/60,0,1)*0.22;}
  const pq=QBY('photo'),ps=stepOf(pq);SPOTS.forEach((p,k)=>{camMarks[k].visible=state==='play'&&!calm&&(!ps||!SAVE.spots.includes(p.id));camMarks[k].position.y=G(p.x,p.z)+2.6+Math.sin(clock*2+k)*0.08;});}
let placeT=0;
function frame(now){const dt=Math.min(0.05,(now-last)/1000);last=now;clock+=dt;
  if(state==='play'){if(talkNpc&&Math.hypot(P.x-talkNpc.x,P.z-talkNpc.z)>6){DLG=null;$('dialog').hidden=true;talkNpc=null;}
    stepPlayer(dt);near=DLG||modal?null:findNear();if(actQ&&near)act(near);actQ=false;
    const pr=$('prompt');if(near&&!DLG&&!modal){pr.hidden=false;pr.innerHTML='';const k=document.createElement('kbd');k.textContent=hasTouch?near.verb:'E';pr.append(k,document.createTextNode(near.label));$('bAct').textContent=near.verb;}else{pr.hidden=true;$('bAct').textContent='話す';}
    placeT-=dt;if(placeT<=0){$('place').textContent=placeName();placeT=0.5;}drawMap();}
  else{player.g.position.set(P.x,P.y,P.z);player.g.rotation.set(0,P.yaw,0);poseSkater(player,dt,{v:0,turn:0,push:false,brake:false,air:false});}
  updateTram(dt);updateCars(dt);updateFolk(dt,P.x,P.z,false);updateNPCs(dt);updateMarkers();
  waveTex.offset.set((clock*0.004)%1,(clock*0.006)%1);foamTex.offset.x=(clock*0.02)%1;
  updateCamera(dt);renderer.render(scene,camera);
  if(photoReq){photoReq=false;snap();}
  requestAnimationFrame(frame);}
$('startBtn').addEventListener('click',()=>{state='play';P.yaw=0;$('title').hidden=true;$('hud').hidden=false;$('stick').hidden=!hasTouch;$('pad').hidden=!hasTouch;camInit=false;renderHUD();canvas.focus();
  toast(hasTouch?'右の「ける」ボタンで地面をけって進もう':'W か ↑ を押すたびに、地面をひと蹴り');if(!SAVE.qs.melon)toast('坂の上の鳥居のそばで、おばあちゃんが手を振っている');});
$('resetBtn').addEventListener('click',()=>{SAVE=JSON.parse(JSON.stringify(S0));save();$('resetBtn').hidden=true;toast('はじめからにした');renderHUD();});
if(Object.keys(SAVE.qs).length||SAVE.money!==S0.money){$('resetBtn').hidden=false;$('startBtn').textContent='散歩のつづきへ';}
updateFolk(0,P.x,P.z,true);
$('loading').hidden=true;$('title').hidden=false;
requestAnimationFrame(t=>{last=t;requestAnimationFrame(frame);});
}
const fontReady=document.fonts&&document.fonts.load?Promise.race([Promise.all([document.fonts.load('700 20px "Zen Maru Gothic"'),document.fonts.load('700 20px "Kaisei Decol"')]),new Promise(r=>setTimeout(r,2500))]).catch(()=>{}):Promise.resolve();
// the heroine model sits next to the page; if it cannot be fetched the game falls back to the procedural skater
const heroineReady=new Promise(res=>{if(!window.THREE||!THREE.GLTFLoader)return res();const t=setTimeout(res,25000);
  const ok=g=>{window.HEROINE_GLTF=g;clearTimeout(t);res();},fail=()=>{clearTimeout(t);res();},ld=new THREE.GLTFLoader();
  const emb=document.getElementById('heroineGLB');   // the single-file build carries the model inline
  if(emb){try{const bin=Uint8Array.from(atob(emb.textContent.trim()),c=>c.charCodeAt(0));ld.parse(bin.buffer,'',ok,fail);}catch(e){fail();}}
  else ld.load('heroine.glb',ok,undefined,fail);});
Promise.all([fontReady,heroineReady]).then(main);
</script>
