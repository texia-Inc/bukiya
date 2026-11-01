
/* ---------- the tram and its level crossings ---------- */
// the tram itself, its stops and riding it are in p5j_tram.js
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
  const T=TRAM;tramMove(dt);
  const xs=T.cars.map(g=>g.position.x);T.box.x0=Math.min(...xs)-6;T.box.x1=Math.max(...xs)+6;
  if(!RIDE.on&&AREA==='town'&&P.x>T.box.x0-0.3&&P.x<T.box.x1+0.3&&Math.abs(P.z-TRAM_Z)<1.7){P.z=TRAM_Z+(P.z<TRAM_Z?-1.75:1.75);if(T.v>0.5)P.bump=0.4;}   // on the rails as it comes: pushed to the side
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
// the black van of Oceangate: no logo, windows you cannot see through; it keeps going round the coast road
CARS.push({g:makeCar('#18191c',false,'van'),dir:-1,x:-30,z:COAST_Z+2.2,v:6,v0:5.5,van:true});const VAN=CARS[CARS.length-1];
CARS.forEach(c=>{c.box=collide(0,0,0,0,'car');});
function updateCars(dt){for(const c of CARS){if(c.scripted)continue;let gap=1e9;for(const o of CARS){if(o===c||o.dir!==c.dir)continue;let d=(o.x-c.x)*c.dir;if(d<0)d+=520;if(d<gap)gap=d;}
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
  chochin:{name:'提灯',d:(g,s)=>{g.fillStyle='#2b2520';g.fillRect(s*0.4,s*0.14,s*0.2,s*0.08);g.fillRect(s*0.4,s*0.78,s*0.2,s*0.08);g.fillStyle='#e8452f';g.beginPath();g.ellipse(s/2,s/2,s*0.24,s*0.3,0,0,7);g.fill();
    g.strokeStyle='rgba(0,0,0,.25)';g.lineWidth=1.5;for(let k=-2;k<=2;k++){g.beginPath();g.moveTo(s*0.27,s/2+k*s*0.1);g.lineTo(s*0.73,s/2+k*s*0.1);g.stroke();}}},
  kingyo:{name:'金魚',d:(g,s)=>{g.fillStyle='rgba(160,215,240,.75)';g.beginPath();g.moveTo(s*0.3,s*0.2);g.lineTo(s*0.7,s*0.2);g.lineTo(s*0.82,s*0.6);g.quadraticCurveTo(s/2,s*0.98,s*0.18,s*0.6);g.fill();
    g.fillStyle='#f2582a';g.beginPath();g.ellipse(s*0.5,s*0.6,s*0.12,s*0.07,0.3,0,7);g.fill();g.beginPath();g.moveTo(s*0.4,s*0.57);g.lineTo(s*0.3,s*0.5);g.lineTo(s*0.32,s*0.66);g.fill();g.fillStyle='#e8452f';g.fillRect(s*0.36,s*0.16,s*0.28,s*0.05);}},
  caramel:{name:'キャラメル',d:(g,s)=>{g.fillStyle='#f2c230';g.fillRect(s*0.24,s*0.3,s*0.52,s*0.4);g.fillStyle='#c8372d';g.fillRect(s*0.24,s*0.44,s*0.52,s*0.12);}},
  kendama:{name:'けん玉',d:(g,s)=>{g.fillStyle='#d9b26a';g.fillRect(s*0.46,s*0.4,s*0.08,s*0.48);g.fillRect(s*0.3,s*0.5,s*0.4,s*0.08);g.fillStyle='#c8372d';g.beginPath();g.arc(s/2,s*0.28,s*0.15,0,7);g.fill();}},
  nuigurumi:{name:'くまのぬいぐるみ',d:(g,s)=>{g.fillStyle='#e8b48a';g.beginPath();g.arc(s*0.3,s*0.26,s*0.1,0,7);g.arc(s*0.7,s*0.26,s*0.1,0,7);g.arc(s/2,s*0.42,s*0.22,0,7);g.arc(s/2,s*0.74,s*0.2,0,7);g.fill();
    g.fillStyle='#2b2520';g.beginPath();g.arc(s*0.42,s*0.4,s*0.03,0,7);g.arc(s*0.58,s*0.4,s*0.03,0,7);g.fill();}},
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
   start:['ナギ、今日もいい風だねえ。','商店街の「こむぎ堂」のメロンパンが食べたくてね。でも、この坂を下りるのがしんどくて…','ふたつ買ってきてくれるかい？ お代はあとでちゃんと渡すからね。'],
   steps:[{type:'have',item:'melon',n:2,at:'bakery',hint:'しおかぜ商店街の「こむぎ堂」でメロンパンを2つ買う'},
          {type:'deliver',to:'tome',item:'melon',n:2,hint:'神社の鳥居のそば、トメばあちゃんに届ける',text:['まあまあ、まだあったかいねえ。','ありがとうね。パン代と、これはお駄賃。','夕方になったら、桟橋の先へ行ってごらん。海に沈む夕日がきれいだよ。','暗くなったら、ばあちゃんのところへ帰っておいで。いっしょに家に帰ろうね。']}],
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
  // the summer festival (easy-going route, from the fourth day)
  {id:'fest_lantern',title:'提灯をつるそう',giver:'neko',when:{flags:{route:3}},
   start:['やあ、ナギちゃん。じつはわたし、町内会の会長でね。','あさっての夏祭りに向けて、神社の参道に提灯をつるしたいんだが、この腰では脚立にのぼれなくて…','この提灯を、鳥居をくぐった参道に飾ってきてくれないか。'],give:['chochin',6],
   steps:[{type:'place',at:[SHRINE.x,-128.5],item:'chochin',n:6,label:'提灯をつるす　神社の参道',hint:'神社の鳥居をくぐった参道に提灯をつるす',text:['参道の柱に縄を張って、提灯をひとつずつつるした。','夜になったら、きっときれいだ。']},
          {type:'talk',to:'neko',hint:'古書うみねこの店主に知らせる',text:['おお、ありがとう。これで神社が祭りの顔になった。','商店街のほうにも、町の若いのがつるしてくれたよ。夜が楽しみだねえ。']}],reward:500},
  {id:'fest_yatai',title:'屋台のみかん氷',giver:'okami',when:{flags:{route:3}},
   start:['ナギちゃん、ちょうどいいところに！','お祭りでね、魚松は今年「みかん氷」の屋台を出すんだよ。','八百吉でみかんを2袋、買ってきてくれないかい？'],
   steps:[{type:'have',item:'mikan',n:2,at:'yaoya',hint:'八百吉でみかんを2袋買う'},{type:'deliver',to:'okami',item:'mikan',n:2,hint:'魚松のおかみさんに届ける',text:['いいみかんだねえ！ これで甘いシロップができるよ。','屋台は神社の参道に出すからね。お祭りの日は食べにおいで！']}],reward:500},
  {id:'fest_yukata',title:'お祭りの浴衣',giver:'hana',when:{flags:{route:3}},
   start:['ナギちゃん、お祭りには浴衣で行くの？','トメさんがね、昔の浴衣をしまってあるって言ってたわよ。聞いてみたら？'],
   steps:[{type:'talk',to:'tome',hint:'トメばあちゃんに浴衣のことを聞く',text:['浴衣かい？ あるある。ナギのお母さんが、ちょうどナギくらいのころに着てたのがね。','たんすの奥から出しておいたよ。着がえのとき、着てごらん。']}],reward:200,
   done:()=>{SAVE.owned=SAVE.owned||{};for(const p of PRIZES)if(p.id==='yukata')SAVE.owned[p.key]=1;toast('浴衣を着られるようになった（着がえ C）',true);}},
  // the Oceangate route: the kids gather what the town saw
  {id:'og_evidence',title:'海街少年探偵団',giver:'sota',when:{flags:{route:2},seen:'o4_baker'},
   start:['おねえちゃん！ こむぎ堂のおじさんから聞いたよ。','おれたち「海街少年探偵団」も手伝う！ 町の人に、黒いバンのことを聞いて回ろうよ。','魚松のおかみさん、しおさいのマスター、桟橋の釣りのおじさん。みんな何か見てるはずだよ！'],
   steps:[{type:'talk',to:'okami',hint:'魚松のおかみさんに、黒いバンのことを聞く',text:['黒いバンの人たち？ ゆうべ、港で船に箱を積んでたよ。','「取り扱い注意」って、赤い字で書いてあったねえ。']},
          {type:'talk',to:'master',hint:'しおさいのマスターに聞く',text:['黒崎って男なら、店の前で電話してたよ。','「あさっての夜で、灯台も町も終わりだ」なんて言ってた。……冗談だといいんだが。']},
          {type:'talk',to:'fisher',hint:'桟橋の釣りのおじさんに聞く',text:['島の灯台の下に、見なれない機械が置いてあった。','夜になると、電波塔と同じリズムで赤く光るんだ。']},
          {type:'talk',to:'sota',hint:'浜辺のソウタくんに知らせる',text:['すごい、ぜんぶ集まった！','この証拠、こむぎ堂のおじさんに渡しておくね！ おれたち、いいチームだね！']}],reward:600},
  {id:'photo',title:'海街の景色めぐり',giver:'neko',
   start:['この町の古い写真集を見ていたら、今の景色も残したくなってね。','見晴らし台、神社の鳥居、海が見える踏切、駅のホーム、桟橋の先。この5か所の写真を撮ってきてくれないか。','カメラのマークのところで P キーか「写真を撮る」だ。'],
   steps:[{type:'photos',hint:'カメラのマークの5か所で写真を撮る'},{type:'talk',to:'neko',hint:'古書うみねこの店主に写真を見せる',text:['ほう…どれもいい写真だ。この町の夏が写っている。','お礼に、これを。またいい景色を見つけたら教えておくれ。']}],reward:800},
];
QUESTS.push(...inkQuests(),...ex1Quests());Object.assign(ITEMS,INK_ITEMS);   // the errands in the country (p5k_inaka.js)
// three save slots; slot 1 keeps the key the game has always used, so older saves open there
const S0={money:600,inv:{},qs:{},tracked:null,spots:[],day:1,hour:DAY_START,cap:DAY_CAP,flags:{},seen:{}};
const SLOTS=3,slotKey=k=>k===1?'umimachi_save':'umimachi_save'+k;
function loadSlot(k){try{const s=JSON.parse(store.get(slotKey(k))||'null');if(s&&typeof s.money==='number')return Object.assign(JSON.parse(JSON.stringify(S0)),s);}catch(e){}return null;}
let SLOT=clamp(+(store.get('umimachi_slot')||1)||1,1,SLOTS),SAVE=loadSlot(SLOT)||JSON.parse(JSON.stringify(S0));
function save(){if(ST.run&&ST.snap){store.set(slotKey(SLOT),ST.snap);return;}SAVE.at=Date.now();store.set(slotKey(SLOT),JSON.stringify(SAVE));}
const qs=id=>SAVE.qs[id]||(SAVE.qs[id]={state:0,step:0});
const QBY=id=>QUESTS.find(q=>q.id===id);
function invN(id){return SAVE.inv[id]||0;}
function addItem(id,n){SAVE.inv[id]=invN(id)+n;if(SAVE.inv[id]<=0)delete SAVE.inv[id];renderBag();}
function stepOf(q){const s=qs(q.id);return s.state===1?q.steps[s.step]:null;}
function available(q){const s=qs(q.id);return s.state===0&&(!q.requires||qs(q.requires).state===2)&&(!q.when||cond(q.when));}
function advance(q){const s=qs(q.id);s.step++;if(s.step>=q.steps.length){s.state=2;SAVE.money+=q.reward;SAVE.flags['bond_'+q.giver]=(SAVE.flags['bond_'+q.giver]||0)+1;toast(`おつかい完了「${q.title}」 +${q.reward}円`,true);
    if(q.rewardItem){addItem(...q.rewardItem);toast(`${ITEMS[q.rewardItem[0]].name}をもらった`);}if(q.done)q.done();
    if(SAVE.tracked===q.id){const nx=QUESTS.find(o=>qs(o.id).state===1);SAVE.tracked=storyGoal()||!nx?null:nx.id;}}   // back to today's aim when the story has one
  autoSteps();save();renderHUD();}
function autoSteps(){for(const q of QUESTS){const st=stepOf(q);if(st&&st.type==='have'&&invN(st.item)>=st.n){qs(q.id).step++;toast(`${ITEMS[st.item].name}がそろった。次は「${q.steps[qs(q.id).step].hint}」`);}
  if(st&&st.type==='photos'&&SPOTS.every(p=>SAVE.spots.includes(p.id))){qs(q.id).step++;toast('5か所すべて撮れた！');}}}
function accept(q){const s=qs(q.id);s.state=1;s.step=0;if(q.give){addItem(...q.give);toast(`${ITEMS[q.give[0]].name}をあずかった`);}SAVE.tracked=q.id;toast(`おつかい「${q.title}」をひきうけた`,true);autoSteps();save();renderHUD();}
function targetOf(q){const st=stepOf(q);if(!st)return null;
  if(st.type==='have'){if(st.at==='dagashi'){const a=SHOPS.dagashi.door,v=VEND[0];return Math.hypot(P.x-v.x,P.z-v.z)<Math.hypot(P.x-a[0],P.z-a[1])?[v.x,v.z]:a;}return SHOPS[st.at].door;}
  if(st.type==='deliver'||st.type==='talk'){const n=NPCS[st.to];return[n.x,n.z];}
  if(st.type==='post')return[POSTBOX.x,POSTBOX.z];if(st.type==='place')return st.at;if(st.type==='find')return[-60,-150];
  if(st.type==='photos'){let best=null,bd=1e9;for(const p of SPOTS){if(SAVE.spots.includes(p.id))continue;const d=Math.hypot(P.x-p.x,P.z-p.z);if(d<bd){bd=d;best=[p.x,p.z];}}return best;}
  return null;}

/* ---------- HUD ---------- */
function toast(t,gold){t=devText(t);const d=document.createElement('div');d.className='tst card'+(gold?' gold':'');d.textContent=t;const T=$('toast');T.appendChild(d);while(T.children.length>3)T.firstChild.remove();setTimeout(()=>d.remove(),2900);}
function renderBag(){const B=$('bag');B.innerHTML='';for(const id in SAVE.inv){const d=document.createElement('div');d.className='it';const im=document.createElement('img');im.src=ICON[id];im.alt=ITEMS[id].name;
  d.append(im,document.createTextNode('×'+SAVE.inv[id]));d.title=ITEMS[id].name;B.appendChild(d);}}
function renderHUD(){$('money').textContent=SAVE.money.toLocaleString('ja-JP');let q=SAVE.tracked&&QBY(SAVE.tracked);const tr=$('tracker');
  if(!(q&&qs(q.id).state===1)&&!ST.run&&state==='play'&&!storyGoal())q=activeQuests()[0];   // nothing for the story right now: show an errand rather than nothing
  if(MIR.on)mirHUD(tr);else if(DRONE.active)droneHUD(tr);else if(lightsBusy())lightsHUD(tr);else if(ogBusy())ogHUD(tr);else if(baseBusy())baseHUD(tr);else if(BOSS.on)bossHUD(tr);else if(DEF.on)defHUD(tr);else if(rescueOn()&&!URA.chase)rescueHUD(tr);else if(sortieOn())nestHUD(tr);else if(ISL.wait)islHUD(tr);else if(URA.on)uraHUD(tr);
  else if(q&&qs(q.id).state===1){const st=stepOf(q);tr.hidden=false;tr.innerHTML='';const b=document.createElement('b');b.textContent=q.title;const s=document.createElement('span');s.className='step';s.textContent=st.hint;tr.append(b,s);
    let m='';if(st.type==='have')m=`${ITEMS[st.item].name} ${Math.min(invN(st.item),st.n)} / ${st.n}`;if(st.type==='photos')m=`写真 ${SAVE.spots.length} / ${SPOTS.length}`;
    if(m){const e=document.createElement('span');e.className='meter';e.textContent=m;tr.appendChild(e);}
    // the other errands under it, each with its number (the same as on the map); tap one to follow it instead
    const act=activeQuests(),k0=act.indexOf(q);b.prepend(Object.assign(document.createElement('i'),{className:'qn',textContent:k0+1}));b.querySelector('.qn').style.background=QCOL[k0%QCOL.length];
    const goal=!ST.run&&storyGoal();
    if(act.length>1||goal){const box=document.createElement('div');box.className='others';
      if(goal){const r=document.createElement('button');r.className='oq';const n=Object.assign(document.createElement('i'),{className:'qn',textContent:'★'});n.style.background='var(--sun)';r.append(n,document.createTextNode('今日のめあて'));
        r.title=goal;r.onclick=e=>{e.stopPropagation();SAVE.tracked=null;save();renderHUD();};box.appendChild(r);}
      let shown=0;act.forEach((o,k)=>{if(o===q||++shown>4)return;const r=document.createElement('button');r.className='oq';const n=document.createElement('i');n.className='qn';n.textContent=k+1;n.style.background=QCOL[k%QCOL.length];
        r.append(n,document.createTextNode(o.title));r.title=stepOf(o).hint;r.onclick=e=>{e.stopPropagation();SAVE.tracked=o.id;save();renderHUD();};box.appendChild(r);});if(shown>4){const m=document.createElement('span');m.className='meter';m.textContent=`ほか ${shown-4}件（おつかい帳）`;box.appendChild(m);}tr.appendChild(box);}}
  else goalHUD(tr);renderBag();
  document.body.classList.toggle('battle',!!(MIR.on||DRONE.active||BOSS.on||DEF.on||sortieOn()||rescueOn()||URA.chase));}
// errands in hand, in a fixed order, and the colour each one has on the tracker and the map
// the errands a route depends on (the ones with `when`) are offered before the everyday ones by the same person
const STORY_FIRST=[...QUESTS].sort((a,b)=>!!b.when-!!a.when);
const activeQuests=()=>QUESTS.filter(q=>qs(q.id).state===1),QCOL=['#e2584a','#3a7bd5','#2e9a5a','#a070d0','#e8a23a','#d0508a'];
function renderLog(){const L=$('logList');L.innerHTML='';for(const q of QUESTS){const s=qs(q.id);if(s.state===0&&!available(q))continue;
  const d=document.createElement('div');d.className='q'+(SAVE.tracked===q.id?' on':'');const st=document.createElement('span');
  st.className='st '+(s.state===2?'done':s.state===1?'act':'new');st.textContent=s.state===2?'完了':s.state===1?'おつかい中':'まだ話していない';
  const b=document.createElement('b');b.textContent=q.title;const h=document.createElement('span');
  h.textContent=s.state===1?q.steps[s.step].hint:s.state===2?`お礼 ${q.reward}円をもらった`:`${NPCS[q.giver].name}が困っているみたい`;
  d.append(st,b,h);if(s.state===1)d.addEventListener('click',()=>{SAVE.tracked=q.id;save();renderLog();renderHUD();});L.appendChild(d);}}
let modal=null;
function openModal(id){modal=id;$(id).hidden=false;document.body.classList.toggle('closet',id==='closet');}function closeModal(){if(!modal)return;$(modal).hidden=true;modal=null;document.body.classList.remove('closet','cbig');canvas.focus();}
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
// phones: lines written with keys in mind name the on-screen buttons instead
function devText(s){return(('ontouchstart' in window)||navigator.maxTouchPoints>0)&&typeof s==='string'?s.replace(/ ?クリックか J キーで/g,'「撃つ」ボタンで').replace(/ ?P キーか「写真を撮る」/g,'「撮る」ボタン')
  .replace('L でライト','「ライト」ボタンでライト').replace('W で蹴って','「ける」で蹴って').replace('A D で曲がる','スティックで曲がる'):s;}
function say(who,lines,done){DLG={who,lines:lines.map(devText),done};$('dwho').textContent=who;$('dwho').hidden=!who;$('dtext').textContent=DLG.lines.shift();$('dialog').hidden=false;}
function nextLine(){if(!DLG||DLG.choice)return;if(DLG.lines.length){$('dtext').textContent=DLG.lines.shift();return;}const d=DLG.done;DLG=null;$('dialog').hidden=true;if(!ST.run)talkNpc=null;if(d)d();}
$('dialog').addEventListener('click',nextLine);
let talkNpc=null;
function talk(n){talkNpc=n;
  // an errand step for this person comes first, then the story's events, then new errands
  for(const q of QUESTS){const st=stepOf(q);if(!st)continue;
    if((st.type==='deliver'||st.type==='talk')&&st.to===n.id&&!(st.type==='deliver'&&invN(st.item)<st.n)){
      say(n.name,st.text,()=>{if(st.type==='deliver')addItem(st.item,-st.n);advance(q);});return;}}
  const ev=findEvent('talk',n.id);if(ev){runEvent(ev,n);return;}
  for(const q of QUESTS){const st=stepOf(q);if(st&&st.type==='deliver'&&st.to===n.id){say(n.name,[`${ITEMS[st.item].name}を${st.n}つ、持ってきてくれたら うれしいな。`]);return;}}
  for(const q of STORY_FIRST){if(q.giver===n.id&&available(q)){say(n.name,q.start,()=>accept(q));return;}}
  for(const q of QUESTS){if(q.giver===n.id&&qs(q.id).state===1&&q.wait){say(n.name,q.wait);return;}}
  if(n.id==='baker'&&!DRONE.active&&SAVE.flags.route===2&&SAVE.seen.o4_baker&&!SAVE.flags.drones_cleared){say(n.name,DRONE.lost?DRONE_RETRY:DRONE_TALK,startDrones);return;}
  if(n.id==='baker'){say(n.name,n.idle,()=>openShop('bakery'));return;}
  if(n.id==='maru'){say(n.name,n.idle,()=>openShop('dagashi'));return;}
  say(n.name||'町の人',[pick(n.idle.length?n.idle:['いい天気ですね。'])]);}

/* ---------- photos ---------- */
let ALBUM=(()=>{try{return JSON.parse(store.get('umimachi_album')||'[]');}catch(e){return[];}})(),photoReq=false;
function snap(){const src=renderer.domElement,w=640,h=Math.round(w*src.height/src.width);const c=document.createElement('canvas');c.width=w;c.height=h;const g=c.getContext('2d');g.drawImage(src,0,0,w,h);
  g.fillStyle='rgba(255,250,240,.85)';g.font='700 22px "Zen Maru Gothic", sans-serif';g.textAlign='right';g.fillText(placeName(),w-16,h-16);
  let url='';try{url=c.toDataURL('image/jpeg',0.78);}catch(e){}
  const near=SPOTS.find(p=>Math.hypot(P.x-p.x,P.z-p.z)<9);
  player.happyT=1.6;ALBUM.unshift({url,cap:near?near.name:placeName()});ALBUM=ALBUM.slice(0,12);
  let ok=store.set('umimachi_album',JSON.stringify(ALBUM));while(!ok&&ALBUM.length>1){ALBUM.pop();ok=store.set('umimachi_album',JSON.stringify(ALBUM));}
  const f=$('flash');f.style.transition='none';f.style.opacity=0.9;requestAnimationFrame(()=>{f.style.transition='opacity .5s';f.style.opacity=0;});
  const pq=QUESTS.find(q=>q.id==='photo'),st=pq&&stepOf(pq);
  if(near&&st&&st.type==='photos'&&!SAVE.spots.includes(near.id)){SAVE.spots.push(near.id);toast(`${near.name}を撮った（${SAVE.spots.length}/${SPOTS.length}）`,true);autoSteps();save();renderHUD();}
  else toast(near?`${near.name}で1枚`:'パシャ。アルバムに残した');}
function renderAlbum(){const A=$('albumGrid');A.innerHTML='';if(!ALBUM.length){const p=document.createElement('p');p.className='sub';p.textContent='まだ写真がありません。気に入った景色で撮ってみよう。';A.appendChild(p);return;}
  for(const a of ALBUM){const f=document.createElement('figure');const im=document.createElement('img');im.src=a.url;im.alt=a.cap;im.style.cursor='pointer';im.onclick=()=>sharePhoto(a);const c=document.createElement('figcaption');c.textContent=a.cap;f.append(im,c);A.appendChild(f);}}
// a photo leaves the game through the share sheet (the app writes it to a file first), or a download on a computer
async function sharePhoto(a){if(!a.url)return;const name='umimachi_'+Date.now()+'.jpg';
  if(APP.native&&APP.fs&&APP.share){try{const r=await APP.fs.writeFile({path:name,data:a.url.split(',')[1],directory:'CACHE'});await APP.share.share({title:a.cap,files:[r.uri]});}catch(e){}return;}
  try{const f=new File([await (await fetch(a.url)).blob()],name,{type:'image/jpeg'});if(navigator.canShare&&navigator.canShare({files:[f]})){await navigator.share({files:[f],title:a.cap});return;}}catch(e){if(e&&e.name==='AbortError')return;}
  const l=document.createElement('a');l.href=a.url;l.download=name;l.click();}
// leaving the app (home screen, a call) saves where you are
document.addEventListener('visibilitychange',()=>{if(document.hidden&&state==='play')save();});
$('photoBtn').addEventListener('click',()=>{photoReq=true;});
// phones: the menu button folds the tools away; choosing one folds them again. Tapping the tracker folds it to its title
$('menuBtn').addEventListener('click',()=>{const T=$('tools');T.classList.toggle('open');$('menuBtn').textContent=T.classList.contains('open')?'とじる':'メニュー';});
for(const id of ['logBtn','albumBtn','recapBtn','closetBtn','photoBtn','setBtn'])$(id).addEventListener('click',()=>{$('tools').classList.remove('open');$('menuBtn').textContent='メニュー';});
$('tracker').addEventListener('click',()=>{$('tracker').classList.toggle('mini');});$('lightBtn').addEventListener('click',toggleTorch);
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
function drawMap(){if(AREA==='mir'){mirMap();return;}const V=150,S=mapc.width/V,ink=AREA==='inaka',hq=AREA==='hq',bs=AREA==='base'||hq,isl=!ink&&!bs&&P.z>ISL_Z0,cx=P.x-(ink?INK_X-INK_R:bs?(hq?HQ.mapX0:BASE.mapX0):isl?ISL.x-120:MAP_X0),cz=P.z-(ink?-INK_R:bs?(hq?HQ.mapZ0:BASE.mapZ0):isl?ISL.z-70:MAP_Z0);mg.fillStyle=ink?'#bcd9a8':bs?'#3a3d42':'#7cc0e6';mg.fillRect(0,0,mapc.width,mapc.height);
  mg.drawImage(ink?INK.map:bs?(hq?HQ.map:BASE.map):isl?ISL.map:mapBase,cx-V/2,cz-V/2,V,V,0,0,mapc.width,mapc.height);
  const toM=(x,z)=>[(x-P.x)*S+mapc.width/2,(z-P.z)*S+mapc.height/2];
  for(const p of SPOTS){const [mx,my]=toM(p.x,p.z);mg.fillStyle=SAVE.spots.includes(p.id)?'#9aa6ae':'#1f7fc0';mg.beginPath();mg.arc(mx,my,5,0,7);mg.fill();}
  for(const q of QUESTS){if(!available(q))continue;const n=NPCS[q.giver],[mx,my]=toM(n.x,n.z);mg.fillStyle='#f2a33a';mg.beginPath();mg.arc(mx,my,7,0,7);mg.fill();mg.fillStyle='#fff';mg.font='900 11px sans-serif';mg.textAlign='center';mg.textBaseline='middle';mg.fillText('!',mx,my+1);}
  // every errand in hand has its numbered dot; the one followed is bigger and drawn last
  const act=activeQuests(),qt=SAVE.tracked&&QBY(SAVE.tracked);
  for(const q of act.filter(o=>o!==qt).concat(qt&&act.includes(qt)?[qt]:[])){const t=targetOf(q);if(!t)continue;const k=act.indexOf(q),big=q===qt;
    let [mx,my]=toM(t[0],t[1]);const W=mapc.width,pad=10,out=mx<pad||my<pad||mx>W-pad||my>W-pad;mx=clamp(mx,pad,W-pad);my=clamp(my,pad,W-pad);
    mg.fillStyle=QCOL[k%QCOL.length];mg.beginPath();mg.arc(mx,my,big?(out?7:9):(out?5:6.5),0,7);mg.fill();mg.strokeStyle='#fff';mg.lineWidth=big?2.5:1.5;mg.stroke();
    if(act.length>1){mg.fillStyle='#fff';mg.font=`900 ${big?11:9}px sans-serif`;mg.textAlign='center';mg.textBaseline='middle';mg.fillText(k+1,mx,my+1);}}
  mg.save();mg.translate(mapc.width/2,mapc.height/2);mg.rotate(-P.yaw+Math.PI);mg.fillStyle='#2b2520';mg.beginPath();mg.moveTo(0,-9);mg.lineTo(6,7);mg.lineTo(0,3);mg.lineTo(-6,7);mg.closePath();mg.fill();mg.restore();
  if(!bs){mg.fillStyle='rgba(43,37,32,.7)';mg.font='700 11px sans-serif';mg.textAlign='left';mg.fillText('山',6,14);mg.fillText('海',6,mapc.height-6);}}
function placeName(){const x=P.x,z=P.z;if(RIDE.on)return'うみまち線の車内';if(BOAT.on||z>ISL_Z0)return islPlace();if(AREA==='inaka')return inkPlace();if(AREA==='base')return'オーシャンゲートの基地';if(AREA==='hq')return'海街自警団の基地';if(AREA==='mir')return'裏海街　鏡の海';if(x>EKI.x0&&x<EKI.x1&&z>EKI.z0&&z<EKI.z1)return'うみまち駅前';
  if(Math.hypot(x-LOOKOUT.x,z-LOOKOUT.z)<16)return'見晴らし台';for(const d of RIDGE_DECKS)if(Math.hypot(x-d.x,z-d.z)<12)return d.name;if(Math.abs(x)>212&&z<SHORE)return x>0?'東の山':'西の山';if(x>-80&&x<-40&&z>-178&&z<-118)return'海街神社';
  const st=Math.abs(z-207)<3&&stopAt(x);if(st&&st.id!=='station')return st.name+' 停留所';
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
    const own=(it.colors||[]).filter((c,k)=>ownsKey(SAVE,S.slot+':'+it.id+':'+k)).length;
    if(own>1){const r=document.createElement('div');r.className='row';r.style.marginTop='4px';const cl=document.createElement('span');cl.className='cl';cl.textContent='色';r.appendChild(cl);
      it.colors.forEach((cs,k)=>{if(!ownsKey(SAVE,S.slot+':'+it.id+':'+k))return;const b=document.createElement('button');b.className='sw'+(k===(ci||0)?' on':'');const a=cs[0]||'#262222',c2=cs[1]||a;
        b.style.background=`linear-gradient(135deg,${a} 55%,${c2} 55%)`;b.title=it.name;b.onclick=()=>{setOutfit(S.slot,it.id,k);};r.appendChild(b);});col.appendChild(r);}
    box.appendChild(row);}}
function setOutfit(slot,id,ci){SAVE.outfit=Object.assign({},DEFAULT_OUTFIT,SAVE.outfit||{});SAVE.outfit[slot]=[id,ci];save();applyOutfit(player,SAVE.outfit);if(CL.big)renderMini();else renderCloset();}
function openCloset(){if(!player.vrm){toast('この端末では着がえられない（主人公のモデルを読み込めなかった）');return;}Object.assign(CL,{yaw:0.3,pitch:0.08,zoom:1,spin:false});closetBig(false);renderCloset();openModal('closet');}
// the big view: the list folds into a strip, and in it one slot at a time is changed with the arrows
const closetSlotsOn=()=>WARDROBE.filter(S=>{const its=S.items.filter(I=>ownsItem(SAVE,S.slot,I));return its.length>1||its.some(I=>(I.colors||[]).filter((c,k)=>ownsKey(SAVE,S.slot+':'+I.id+':'+k)).length>1);});
function closetBig(on){CL.big=on;$('closet').classList.toggle('big',on);document.body.classList.toggle('cbig',on);$('closetSheet').hidden=on;$('closetMini').hidden=!on;if(on){CL.zoom=Math.min(CL.zoom,1);renderMini();}else{CL.bg=0;CL.spin=false;renderCloset();}}
function renderMini(){const sl=closetSlotsOn();if(!sl.length){$('cmSlot').textContent='—';$('cmItem').textContent='まだ服がない';$('cmCols').innerHTML='';return;}
  CL.si=((CL.si||0)%sl.length+sl.length)%sl.length;const S=sl[CL.si],cur=Object.assign({},DEFAULT_OUTFIT,SAVE.outfit||{}),[id,ci]=cur[S.slot],it=findItem(S.slot,id),items=S.items.filter(I=>ownsItem(SAVE,S.slot,I));
  $('cmSlot').textContent=S.label;$('cmItem').textContent=it.name;$('cmIp').disabled=$('cmIn').disabled=items.length<2;$('cmSp').disabled=$('cmSn').disabled=sl.length<2;
  const r=$('cmCols');r.innerHTML='';(it.colors||[]).forEach((cs,k)=>{if(!ownsKey(SAVE,S.slot+':'+it.id+':'+k))return;const b=document.createElement('button');b.className='sw'+(k===(ci||0)?' on':'');const a=cs[0]||'#262222',c2=cs[1]||a;
    b.style.background=`linear-gradient(135deg,${a} 55%,${c2} 55%)`;b.onclick=()=>setOutfit(S.slot,it.id,k);r.appendChild(b);});r.hidden=r.children.length<2;
  $('cmBg').textContent='背景：'+['町','白','夕やけ','夜'][CL.bg||0];$('cmSpin').classList.toggle('on',!!CL.spin);}
function miniItem(d){const sl=closetSlotsOn(),S=sl[CL.si];if(!S)return;const items=S.items.filter(I=>ownsItem(SAVE,S.slot,I)),cur=Object.assign({},DEFAULT_OUTFIT,SAVE.outfit||{}),i=items.findIndex(I=>I.id===cur[S.slot][0]);
  const I=items[((i+d)%items.length+items.length)%items.length],k=(I.colors||[[]]).findIndex((c,ci)=>ownsKey(SAVE,S.slot+':'+I.id+':'+ci));setOutfit(S.slot,I.id,Math.max(0,k));}
$('closetBig').onclick=()=>closetBig(true);$('cmBack').onclick=()=>closetBig(false);
$('cmSp').onclick=()=>{CL.si--;renderMini();};$('cmSn').onclick=()=>{CL.si++;renderMini();};$('cmIp').onclick=()=>miniItem(-1);$('cmIn').onclick=()=>miniItem(1);
$('cmBg').onclick=()=>{CL.bg=((CL.bg||0)+1)%4;renderMini();};$('cmSpin').onclick=()=>{CL.spin=!CL.spin;renderMini();};
$('cmShot').onclick=()=>{photoReq=true;const b=$('cmShot');b.textContent='アルバムへ！';setTimeout(()=>b.textContent='撮る',1200);};
$('cmView').onclick=()=>{Object.assign(CL,{yaw:0,pitch:0.08,zoom:1,spin:false});renderMini();};
// looking at her in the closet: a narrow lens, turned by dragging the space above the sheet, closer with a pinch or the wheel
const CL={yaw:0.3,pitch:0.08,zoom:1,pts:new Map(),pd:0};
const CLOSET_BG=[null,new THREE.Color(0xf4f1ea),new THREE.Color(0xf2b48a),new THREE.Color(0x1c2638)];
const closetFov=()=>camera.aspect<0.8?36:30;
{ const el=$('closet');
  el.addEventListener('pointerdown',e=>{if(e.target!==el)return;el.setPointerCapture(e.pointerId);CL.pts.set(e.pointerId,[e.clientX,e.clientY]);CL.pd=0;});
  el.addEventListener('pointermove',e=>{const q=CL.pts.get(e.pointerId);if(!q)return;
    if(CL.pts.size===1){CL.spin=false;CL.yaw-=(e.clientX-q[0])*0.012;CL.pitch=clamp(CL.pitch+(e.clientY-q[1])*0.006,-0.3,0.9);}
    q[0]=e.clientX;q[1]=e.clientY;
    if(CL.pts.size===2){const [a,b]=[...CL.pts.values()],d=Math.hypot(a[0]-b[0],a[1]-b[1]);if(CL.pd)CL.zoom=clamp(CL.zoom*CL.pd/d,0.3,1.5);CL.pd=d;}});
  const up=e=>{CL.pts.delete(e.pointerId);CL.pd=0;};el.addEventListener('pointerup',up);el.addEventListener('pointercancel',up);
  el.addEventListener('wheel',e=>{if(e.target!==el)return;e.preventDefault();CL.zoom=clamp(CL.zoom*Math.exp(e.deltaY*0.0012),0.3,1.5);},{passive:false});}
$('closetBtn').addEventListener('click',openCloset);
{ const c=$('yCv');for(const [ev,ty] of [['pointerdown','down'],['pointermove','move'],['pointerup','up'],['pointercancel','up']])c.addEventListener(ev,e=>{if(ty==='down')try{c.setPointerCapture(e.pointerId);}catch(_){}
    e.preventDefault();kingyoPtr(e,ty);shatekiPtr(e,ty);});
  $('yPlay').onclick=yStart;$('yClose').onclick=()=>{if(YG.on&&YG.S.game==='kingyo')kingyoBreak();YG.on=false;closeModal();};}
// the gacha at Maruya: rarity first, then an even pick among that rarity's prizes; duplicates turn into kakera
const RCOL={N:'#6f9fd0',R:'#d977a3',SR:'#e8b030'},RNAME={N:'ノーマル',R:'レア',SR:'スーパーレア'};
function swatchHTML(c){const a=c&&c[0]||'#262222',b=c&&c[1]||a;return `<span class="sw" style="display:inline-block;background:linear-gradient(135deg,${a} 55%,${b} 55%)"></span>`;}
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
const keys={};let jumpQ=false,actQ=false,kickQ=false,kickHold=false,footQ=false,trickQ=false;
// let go of every held key and button: when the window loses focus, and when a button is hidden under a finger (getting on the
// tram hides 「ける」, and a hidden button never hears the finger lift, so she would walk on by herself afterwards)
function releaseInputs(){for(const k in keys)keys[k]=false;kickHold=false;lookHold=false;$('bKick').classList.remove('on');}
window.addEventListener('keydown',e=>{if(e.repeat&&e.code!=='KeyW'&&e.code!=='ArrowUp')return;keys[e.code]=true;
  if(['ArrowUp','ArrowDown','ArrowLeft','ArrowRight','Space'].includes(e.code)&&state==='play')e.preventDefault();
  if(state!=='play')return;
  if(DLG&&DLG.choice){const i=+e.key-1;if(i>=0&&i<DLG.n)DLG.pick(i);return;}
  if(e.code==='Space')jumpQ=true;if((e.code==='KeyW'||e.code==='ArrowUp')&&!e.repeat)kickQ=true;if(e.code==='KeyE'||e.code==='Enter'){if(DLG)nextLine();else if(!modal)actQ=true;}
  if(e.code==='Escape')closeModal();if(e.code==='KeyQ'&&!DLG){if(modal==='log')closeModal();else if(!modal){renderLog();openModal('log');}}
  if(e.code==='KeyP'&&!modal&&!DLG)photoReq=true;if(e.code==='KeyF'&&!e.repeat)footQ=true;if(e.code==='KeyL'&&!e.repeat)toggleTorch();if(e.code==='KeyK'&&!e.repeat)trickQ=true;if(e.code==='KeyC'&&!DLG){if(modal==='closet')closeModal();else if(!modal)openCloset();}});
window.addEventListener('keyup',e=>{keys[e.code]=false;});
window.addEventListener('blur',()=>{for(const k in keys)keys[k]=false;if(stick.off)stick.off();else stick.on=false;FIRE.mouse=FIRE.touch=false;});
// looking back while R or the 振り返る button is held
let lookHold=false;const lookBack=()=>(keys.KeyR||lookHold)&&state==='play'&&!DLG&&!modal;
{ const b=$('bLook');b.addEventListener('pointerdown',e=>{e.preventDefault();lookHold=true;try{b.setPointerCapture(e.pointerId);}catch(_){}});
  for(const ev of ['pointerup','pointercancel','lostpointercapture'])b.addEventListener(ev,()=>{lookHold=false;});}
const stick={on:false,id:null,x:0,y:0};
// the floating stick: the ring jumps to where the thumb lands on the lower left, and goes back to its corner when let go
{ const el=$('stick'),ring=$('ring'),kn=$('knob');let ox=0,oy=0;const set=(e)=>{let dx=e.clientX-ox,dy=e.clientY-oy;const L=Math.hypot(dx,dy),m=50;if(L>m){dx*=m/L;dy*=m/L;}
    stick.x=dx/m;stick.y=dy/m;kn.style.transform=`translate(${dx}px,${dy}px)`;};
  const off=()=>{stick.on=false;stick.id=null;stick.x=stick.y=0;kn.style.transform='';el.classList.remove('on');ring.style.left=ring.style.top='';};stick.off=off;
  // a new thumb on the stick takes it over, so a lost "let go" can never leave it stuck
  el.addEventListener('pointerdown',e=>{if(stick.on&&e.pointerId===stick.id)return;stick.on=true;stick.id=e.pointerId;try{el.setPointerCapture(e.pointerId);}catch(_){}
    const r=el.getBoundingClientRect();ox=e.clientX;oy=e.clientY;ring.style.left=(ox-r.left)+'px';ring.style.top=(oy-r.top)+'px';el.classList.add('on');set(e);});
  el.addEventListener('pointermove',e=>{if(stick.on&&e.pointerId===stick.id)set(e);});
  for(const ev of ['pointerup','pointercancel','lostpointercapture'])el.addEventListener(ev,e=>{if(e.pointerId===stick.id)off();});
  // and when no finger is left on the screen at all, or the app goes to the background, everything held is let go
  const none=e=>{if(!e.touches||e.touches.length===0){off();releaseInputs();FIRE.touch=false;}};window.addEventListener('touchend',none,true);window.addEventListener('touchcancel',none,true);
  document.addEventListener('visibilitychange',()=>{if(document.hidden){off();releaseInputs();FIRE.touch=false;}});
  $('bJump').addEventListener('pointerdown',e=>{e.preventDefault();jumpQ=true;});
  $('bFoot').addEventListener('pointerdown',e=>{e.preventDefault();footQ=true;});
  $('bTrick').addEventListener('pointerdown',e=>{e.preventDefault();trickQ=true;});
  const kb=$('bKick');kb.addEventListener('pointerdown',e=>{e.preventDefault();kickQ=true;kickHold=true;kb.classList.add('on');try{kb.setPointerCapture(e.pointerId);}catch(_){}});
  for(const ev of ['pointerup','pointercancel','lostpointercapture'])kb.addEventListener(ev,()=>{kickHold=false;kb.classList.remove('on');});
  window.addEventListener('blur',releaseInputs);
  kb.addEventListener('contextmenu',e=>e.preventDefault());
  $('bAct').addEventListener('pointerdown',e=>{e.preventDefault();if(DLG)nextLine();else if(!modal)actQ=true;});
  const sb=$('bShoot');sb.addEventListener('pointerdown',e=>{e.preventDefault();FIRE.touch=true;sb.classList.add('on');try{sb.setPointerCapture(e.pointerId);}catch(_){}});
  for(const ev of ['pointerup','pointercancel','lostpointercapture'])sb.addEventListener(ev,()=>{FIRE.touch=false;sb.classList.remove('on');});}
// the mouse fires the pistols in the drone fight (left button on the 3D view)
canvas.addEventListener('mousedown',e=>{if(e.button===0&&DRONE.active)FIRE.mouse=true;});window.addEventListener('mouseup',()=>{FIRE.mouse=false;});
const hasTouch=('ontouchstart' in window)||navigator.maxTouchPoints>0;
if(hasTouch)for(const ev of ['contextmenu','selectstart'])document.addEventListener(ev,e=>e.preventDefault());   // no long-press menu or selection while playing
// Safari ignores user-scalable=no: a pinch would zoom the page and leave the buttons off screen (double taps: touch-action:manipulation)
if(hasTouch)for(const ev of ['gesturestart','gesturechange'])document.addEventListener(ev,e=>e.preventDefault());
/* ---------- settings: sound and its volume, vibration (the app), how much the picture draws, the how-to, back to the title ---------- */
const QUALITY=[{pr:1,grass:0,shadow:false,note:'草と影なし、解像度ひかえめ。電池が長もちして、熱くなりにくい'},
  {pr:1.75,grass:1,shadow:true,note:'いつもの画質'},{pr:2.5,grass:1.5,shadow:true,note:'草が多く、遠くまで。画面がくっきり（重くなる）'}];
function applyQuality(q){const Q=QUALITY[q]||QUALITY[1];renderer.setPixelRatio(Math.min(window.devicePixelRatio||1,Q.pr));resize();
  sun.castShadow=Q.shadow;GRASS.on=Q.grass>0;GRASS.per=Math.round((hasTouch?420:900)*Q.grass);GRASS.R=Math.round((hasTouch?30:42)*(Q.grass>1?1.2:1));
  for(const c of GRASS.chunks.values())if(c.m){scene.remove(c.m);c.m.dispose();}GRASS.chunks.clear();}
let QLV=clamp(+(store.get('umimachi_q')??1)|0,0,2);applyQuality(QLV);
function renderSettings(){$('setSnd').textContent=SND.on?'オン':'オフ';$('setVol').value=Math.round(SND.vol*100);$('setVol').disabled=!SND.on;
  $('setBuzzRow').hidden=!APP.native;$('setBuzz').textContent=store.get('umimachi_buzz')==='0'?'オフ':'オン';
  for(const b of $('setQ').children)b.classList.toggle('on',+b.dataset.q===QLV);$('setQNote').textContent=QUALITY[QLV].note;}
$('setBtn').addEventListener('click',()=>{renderSettings();openModal('setM');});
$('setClose').addEventListener('click',closeModal);
$('setSnd').addEventListener('click',sndToggle);
$('setVol').addEventListener('input',e=>{SND.vol=e.target.value/100;store.set('umimachi_vol',String(e.target.value));sndInit();sndApply();});
$('setBuzz').addEventListener('click',()=>{const off=store.get('umimachi_buzz')!=='0';store.set('umimachi_buzz',off?'0':'1');if(!off)buzz('medium',true);renderSettings();});
for(const b of $('setQ').children)b.addEventListener('click',()=>{QLV=+b.dataset.q;store.set('umimachi_q',String(QLV));applyQuality(QLV);renderSettings();});
$('setHelp').addEventListener('click',()=>{closeModal();openModal('helpM');});
$('helpClose').addEventListener('click',()=>{closeModal();if(state==='play'){renderSettings();openModal('setM');}});
$('setTitle').addEventListener('click',()=>{if(state==='play')save();location.reload();});
if(hasTouch){$('albumSub').textContent='メニューの「写真を撮る」で、いつでも1枚。最新の12枚が残ります。写真をタップすると保存や共有ができます。';$('creditsEnd').textContent='夏休みは、まだ続く。（タップでとじる）';}
function inputs(){let fwd=!!(keys.KeyW||keys.ArrowUp),back=!!(keys.KeyS||keys.ArrowDown),turn=((keys.KeyD||keys.ArrowRight)?1:0)-((keys.KeyA||keys.ArrowLeft)?1:0);
  fwd=fwd||kickHold;if(ST.run&&!storyFree())return{fwd:false,back:P.v>0.2,turn:0};   // events hold the board still
  if(stick.on){if(stick.y>0.45)back=true;if(stick.y<-0.45)fwd=true;   // pushing the stick forward kicks (on foot: runs) like holding W
   if(Math.abs(stick.x)>0.15)turn=clamp(stick.x*1.4,-1,1);}
  return{fwd,back,turn};}
const STEP=0.45;
function hits(x,z,r,y){for(const c of COLL){if(!c.on||c.top<=y+STEP||c.tag==='step')continue;   /* steps never stop you: you rise onto them one at a time */if(x+r>c.x0&&x-r<c.x1&&z+r>c.z0&&z-r<c.z1)return c;}return null;}
// the highest surface under you that you are above: ground, a wall top, a crate, a car roof
function groundAt(x,z,y){let g=G(x,z)+paveY(x,z);for(const c of COLL){if(!c.on||c.top>y+STEP||c.top<=g)continue;if(x>c.x0&&x<c.x1&&z>c.z0&&z<c.z1)g=c.top;}return g;}
// on the board now, with no hop-on (also when an event puts her straight on it)
function rideNow(){P.foot=false;P.carry='deck';P.tr=null;P.kickT=-1;P.kickCD=0.3;padLabels();}
// the board button says 歩く / スケボー (乗る and 降りる belong to the tram, the bus and the boat); on foot the big button runs
// (in the mirror sea the walk button throws Mio's marble)
function padLabels(){const f=!!P.foot,k=f?'走る':'ける',b=MIR.on?(MIR.mcd>0?'…':'ビー玉'):f?'スケボー':'歩く';
  if($('bKick').textContent!==k)$('bKick').textContent=k;if($('bFoot').textContent!==b)$('bFoot').textContent=b;}
function stepPlayer(dt){if(TD.on){P.v=0;jumpQ=kickQ=footQ=trickQ=false;return;}   // the board is a map from above: she waits at the shrine

  if(RIDE.on){rideStep(dt);return;}if(BOAT.on){boatStep(dt);return;}
  if(URA.chase&&URA.chase.replay){jumpQ=kickQ=footQ=trickQ=false;uraReplayPose(dt);return;}   // the replay of being caught moves her, not the keys
  if(URA.hide){P.v=0;jumpQ=kickQ=footQ=trickQ=false;uraPeek(dt,DLG||modal?0:inputs().turn);return;}   // in a crate in 裏海街: still and out of sight
  const busy=!!(DLG||modal);const I=busy?{fwd:false,back:true,turn:0}:inputs();
  if(P.grind){grindStep(dt);return;}
  const F=[Math.sin(P.yaw),Math.cos(P.yaw)];
  // the slope under her: on a bridge it is the deck's, not the ground far below
  const gs=(x,z)=>{let g=G(x,z)+paveY(x,z);for(const c of COLL)if(c.on&&c.tag==='bridge'&&c.top<=P.y+STEP&&c.top>g&&x>c.x0&&x<c.x1&&z>c.z0&&z<c.z1)g=c.top;return g;};
  const g1=gs(P.x+F[0]*0.6,P.z+F[1]*0.6),g0=gs(P.x-F[0]*0.6,P.z-F[1]*0.6),slope=(g1-g0)/1.2;
  const sand=P.z>SHORE+0.5&&P.z<ISL_Z0&&!onPier(P.x,P.z);
  // stepping off and on: F (or the button) starts a short transition; on foot she runs instead of kicking
  if(footQ&&!P.air&&!busy&&!P.tr)P.tr=P.foot?{type:'on',t:0,dur:0.6}:{type:'off',t:0,dur:0.85};footQ=false;
  if(P.tr){P.tr.t+=dt/P.tr.dur;if(P.tr.t>=1){const ty=P.tr.type;P.tr=null;
      if(ty==='off'){P.foot=true;P.carry='hand';}else if(ty==='stow')P.carry='back';else rideNow();
      padLabels();}}
  padLabels();
  const onFoot=P.foot||!!(P.tr&&P.tr.type!=='stow');
  // on foot with the touch stick, she walks the way the stick points on the screen (away from the camera = forward) and turns
  // smoothly to face it; a small push walks, a full push runs. On the board the stick still steers like the keys.
  // holding the run button, though, the stick steers like the board's: left and right turn her, and she runs on at full speed
  // with the camera behind her (pointing the way on the screen while running made her circle as the camera came round)
  if(onFoot&&stick.on&&!busy&&!ST.run&&kickHold){I.fwd=true;I.mag=1;I.back=false;I.turn=Math.abs(stick.x)>0.12?clamp(stick.x*0.6,-0.6,0.6):0;footCamYaw=P.yaw;}
  else if(onFoot&&stick.on&&!busy&&!ST.run){const m=Math.hypot(stick.x,stick.y);I.turn=0;I.back=false;I.fwd=false;
    if(m>0.25){const cy=footCamYaw,want=cy-Math.atan2(stick.x,-stick.y);let d=want-P.yaw;d=Math.atan2(Math.sin(d),Math.cos(d));
      P.yaw+=clamp(d,-7*dt,7*dt);I.fwd=true;I.mag=clamp((m-0.25)/0.55,0.35,1);}
    // the camera swings round behind her only slowly, so "right on the screen" stays put long enough to walk there
    // (and only while she walks roughly away from it — walking sideways or back, the camera holds its direction)
    let dc=P.yaw-footCamYaw;dc=Math.atan2(Math.sin(dc),Math.cos(dc));footCamYaw+=dc*Math.min(1,dt*(P.v>0.5?1.2:0)*Math.pow(Math.max(0,Math.cos(dc)),4));}
  else footCamYaw=P.yaw;
  let a=onFoot?0:-9.8*slope*(AREA==='inaka'?0.9:0.5)-(0.25+(sand?3.2:0))*Math.sign(P.v);
  if(onFoot){const still=P.tr&&P.tr.type!=='stow',tgt=still?0:I.fwd?7.5*(I.mag||1)*(1-clamp(slope,0,0.6)*0.5)*(sand?0.7:1):0;
    P.v+=(tgt-P.v)*Math.min(1,dt*(tgt>P.v?1.6:still?5:6));kickQ=false;P.kickT=-1;
    if(P.foot&&P.carry==='hand'&&P.v>0.4&&!P.tr&&!player.backBusy)P.tr={type:'stow',t:0,dur:0.4};
    if(P.foot&&P.carry==='back'&&player.backBusy&&!P.tr)P.carry='hand';}
  // each kick: the back foot plants, shoves, and the board surges forward; holding the key keeps kicking
  P.kickCD-=dt;if(P.kickT>=0){P.kickT+=dt/0.48;if(P.kickT>=1)P.kickT=-1;}
  if(!onFoot&&(kickQ||I.fwd)&&!P.air&&!busy&&!P.man&&P.kickCD<=0&&P.kickT<0){P.kickT=0;P.kickCD=0.42;P.kicked=false;}kickQ=false;
  if(P.kickT>0.35&&!P.kicked){P.kicked=true;P.v=Math.min(P.v+1.3+3.3*Math.max(0,1-P.v/13),13.5);}
  P.push=P.kickT>=0;
  P.brake=I.back&&!onFoot&&!P.man;if(P.brake&&!P.air)a-=P.v>0.2?4.2:0;if(P.man)a-=0.3;
  P.v=clamp(P.v+a*dt,0,16);if(Math.abs(P.v)<0.04&&!I.fwd)P.v=0;
  P.turn+=(I.turn-P.turn)*Math.min(1,8*dt);
  P.yaw-=P.turn*(onFoot?3.2:2.3-Math.min(1.1,P.v*0.1))*dt;
  const nx=P.x+F[0]*P.v*dt,nz=P.z+F[1]*P.v*dt,R=0.3;
  let ok=true;const water=G(nx,nz)<SEA_Y+0.1&&!onPier(nx,nz);if(water){ok=false;if(P.v>1)toast('海には入れない…ここから先は泳ぐしかない');P.v=0;}
  const c=ok&&!hits(P.x,P.z,R,P.y)&&hits(nx,nz,R,P.y);   // already inside something (a tram stopping on her, a gate coming down): she can always get out
  if(c){const hx=hits(nx,P.z,R,P.y),hz=hits(P.x,nz,R,P.y);
    if(!hx){P.x=nx;P.v*=0.7;}else if(!hz){P.z=nz;P.v*=0.7;}else{if(P.v>3.5){P.bump=0.35;}P.v*=0.15;}}
  else if(ok){P.x=nx;P.z=nz;}
  // at the edge of the open water she slides round along it (by the heading after this frame's turn, so steering in gets her off it)
  if(P.x>INK_X-600){P.x=clamp(P.x,INK_X-270,INK_X+270);P.z=clamp(P.z,-270,270);}else if(P.x<MIR_X+1500){const dx=P.x-MIR_X,l=Math.hypot(dx,P.z);if(l>MIR_R){const ox=dx/l,oz=P.z/l,fx=Math.sin(P.yaw),fz=Math.cos(P.yaw),d=fx*ox+fz*oz;P.x=MIR_X+ox*MIR_R;P.z=oz*MIR_R;if(d>0){const tx=fx-ox*d,tz=fz-oz*d;P.yaw=Math.hypot(tx,tz)>0.15?Math.atan2(tx,tz):Math.atan2(-oz,ox);}}}
  else if(P.x<HQ_X+1200){P.x=clamp(P.x,HQ_X+0.6,HQ_X+43.4);P.z=clamp(P.z,-13.4,13.4);}else if(P.x<BASE_X+600){P.x=clamp(P.x,BASE_X-1,BASE_X+240);P.z=clamp(P.z,-36,20);}else if(P.z>ISL_Z0)islClamp();else{P.x=clamp(P.x,-336,336);P.z=clamp(P.z,-255,PIER.z1);}
  const gy=groundAt(P.x,P.z,P.y);P.onTop=gy>G(P.x,P.z)+0.2;
  if(jumpQ&&!P.air&&!busy&&!(P.tr&&P.tr.type!=='stow')){P.vy=onFoot?5.6:7.6;P.air=true;if(!onFoot){TRICK.airT=0;TRICK.grab=0;}if(P.man){P.man=null;$('manBar').hidden=true;}}jumpQ=false;
  if(trickQ&&!busy)trickStart(I);trickQ=false;if(P.air&&!onFoot)trickAir(dt);if(P.grind)return;if(P.man&&!P.air)manStep(dt,I,onFoot,busy);
  if(!P.air&&P.y-gy>0.3){P.air=true;P.vy=0;}
  if(P.air){P.vy-=13.5*dt;P.y+=P.vy*dt;if(P.y<=gy){if(P.vy<-9)P.bump=0.25;P.y=gy;P.air=false;P.vy=0;
      if(!onFoot){if(P.trick){P.trick=null;P.v*=0.3;P.bump=0.5;trickLand(false);}else trickLand(true);}}}else P.y+=(gy-P.y)*Math.min(1,18*dt);
  player.g.position.set(P.x,P.y,P.z);
  const pitch=P.air?-P.vy*0.03:Math.atan(-slope);
  // a body varial turns her right round over the board, which stays put
  const tk=P.trick,bs=tk&&tk.type==='body'?tk.t*tk.dir:0;player.g.rotation.set(0,P.yaw+TAU*bs,0);
  if(onFoot){player.root.rotation.set(0,0,0);poseRunner(player,dt,{v:P.v,turn:P.turn,air:P.air,vy:P.vy,tr:P.tr,carry:P.carry});}
  else{player.root.rotation.set(pitch*0.8,0,clamp(P.turn*P.v*0.03,-0.25,0.25));
    if(P.tr&&P.tr.type==='stow')P.tr=null;
    poseSkater(player,dt,{v:P.v,turn:P.turn,push:P.push,kick:P.kickT,brake:P.brake&&P.v>0.3,air:P.air,vy:P.vy,flip:tk?tk.t*TRICK_KIND[tk.type].z:0,spin:tk?(bs?-bs:tk.t*TRICK_KIND[tk.type].y):0,tkp:tk?tk.t:0,man:P.man?(P.man.nose?-1:1):0,bal:P.man?P.man.bal:0});}
}

/* ---------- interaction ---------- */
let near=null;
function findNear(){if(RIDE.on)return rideNear();if(BOAT.on)return null;let best=null,bd=1e9;const add=(d,o)=>{if(d<bd){bd=d;best=o;}};
  const il=islNear();if(il)add(il.d,il);if(URA.on){const u=uraNear();if(u)add(u.d-0.3,u);}const hn=hqNear();if(hn)add(hn.d-0.3,hn);
  const tn=tramNear();if(tn)add(tn.d-0.5,tn);const yt=festNear();if(yt)add(yt.d-0.4,yt);const ik=inkNear();if(ik)add(ik.d,ik);
  // someone with a story event waiting comes first when two people stand close together
  for(const id in NPCS){const n=NPCS[id];if(!present(n))continue;const d=Math.hypot(P.x-n.x,P.z-n.z);if(d<2.7)add(d-(findEvent('talk',id)?1.2:0),{kind:'npc',n,label:`話す　${n.name||'町の人'}`,verb:'話す'});}
  for(const id of ['bakery','dagashi','yaoya','fish','flower']){const b=SHOPS[id],d=Math.hypot(P.x-b.door[0],P.z-b.door[1]);if(d<2.4)add(d+0.3,{kind:'shop',id,label:`入る　${MENUS[id].title}`,verb:'入る'});}
  for(const v of VEND){const d=Math.hypot(P.x-v.x,P.z-v.z);if(d<1.6)add(d,{kind:'shop',id:'vend',label:'買う　自動販売機',verb:'買う'});}
  const lq=QBY('letter'),ls=stepOf(lq);if(ls&&ls.type==='post'){const d=Math.hypot(P.x-POSTBOX.x,P.z-POSTBOX.z);if(d<2.2)add(d,{kind:'post',label:'手紙を入れる　ポスト',verb:'入れる'});}
  for(const q of QUESTS){const st=stepOf(q);if(st&&st.type==='place'){const d=Math.hypot(P.x-st.at[0],P.z-st.at[1]);if(d<2.6)add(d,{kind:'place',q,label:st.label,verb:st.verb||'飾る'});}}
  const gp=SHOPS.dagashi.gacha;if(gp){const d=Math.hypot(P.x-gp.x,P.z-gp.z);if(d<1.9)add(d-0.2,{kind:'gacha',label:'まわす　カプセルトイ（1回100円）',verb:'まわす'});}
  const cd=Math.hypot(P.x-MIKE.x,P.z-MIKE.z);if(cd<2.6)add(cd,{kind:'cat',label:'なでる　三毛猫',verb:'なでる'});
  for(const p of SPOTS){const d=Math.hypot(P.x-p.x,P.z-p.z);if(d<7&&!best)add(d+5,{kind:'spot',p,label:`写真を撮る　${p.name}`,verb:'撮る'});}
  return best;}
function act(o){if(!o)return;
  if(o.kind==='npc')talk(o.n);else if(o.kind==='shop')openShop(o.id);
  else if(o.kind==='post'){const q=QBY('letter'),st=stepOf(q);say('ポスト',st.text,()=>{addItem('letter',-1);advance(q);});}
  else if(o.kind==='cat'){const q=QBY('cat'),st=stepOf(q);if(st&&st.type==='find')say('ミケ',phaseOf(SAVE.hour)==='night'?['ニャア。…いた！ 本殿の石の上で、丸くなって眠っている。']:st.text,()=>advance(q));else{const ph=phaseOf(SAVE.hour);say('三毛猫',[ph==='night'?'丸くなって、すやすや眠っている。なでると、しっぽだけが少しゆれた。':ph==='evening'?'ゴロゴロ…。夕日をあびて、目を細めている。':ph==='morning'?'ゴロゴロ…。朝の石の上で、毛づくろいをしている。':'ゴロゴロ…。日なたであくびをしている。']);}}
  else if(o.kind==='spot')photoReq=true;
  else if(o.kind==='place'){const st=stepOf(o.q);say('',st.text,()=>{if(st.item)addItem(st.item,-st.n);if(st.gain){addItem(...st.gain);toast(`${ITEMS[st.gain[0]].name}を手に入れた`);}advance(o.q);});}
  else if(o.kind==='gacha')openGacha();else if(o.kind==='yatai')yataiAct(o);
  else if(o.kind==='tram')boardTram(o);else if(o.kind==='alight')alightTram();else if(o.kind==='bus'||o.kind==='scope')inkAct(o);
  else if(o.kind==='hide'||o.kind==='unhide')uraAct(o);else if(o.kind==='hq')hqAct(o);
  else if(o.kind==='boat'||o.kind==='lhdoor'||o.kind==='lhdown'||o.kind==='lamp')islAct(o);}

/* ---------- camera ---------- */
const camPos=new THREE.Vector3(),camLook=new THREE.Vector3();let camInit=false,footCamYaw=0,CAMOFF=0;
const reduceMotion=window.matchMedia&&window.matchMedia('(prefers-reduced-motion: reduce)').matches;
function blocked(x,y,z){for(const c of COLL){if(c.tag!=='bld'||c.on===false)continue;if(x>c.x0-0.3&&x<c.x1+0.3&&z>c.z0-0.3&&z<c.z1+0.3&&y<(c.top||99)+2.5)return true;}
  if(Math.abs(x)>195)for(const e of HILL_TREES){if(Math.abs(e.x-x)<e.s*1.1&&Math.abs(e.z-z)<e.s*1.1&&y<e.y+e.s*2.7&&Math.hypot(e.x-x,e.z-z)<e.s*1.05)return true;}return false;}
// where a scene's camera can stand: above the ground, out of buildings, crates and walls, out of the trees and the sea-front pines
function camClear(x,y,z){if(y<G(x,z)+0.3||blocked(x,y,z))return false;
  for(const c of COLL)if(c.on!==false&&c.tag==='prop'&&x>c.x0-0.2&&x<c.x1+0.2&&z>c.z0-0.2&&z<c.z1+0.2&&y<(c.top||1)+0.3)return false;
  if(AREA!=='town')return true;
  for(const e of PINES){if(Math.abs(x-e.x)<3&&Math.abs(z-e.z)<3){const g=G(e.x,e.z);if(Math.hypot(x-e.x,z-e.z)<2.7&&y>g+e.h*0.4&&y<g+e.h*1.15)return false;}}
  for(const e of TREES){if(Math.abs(x-e.x)<e.s&&Math.abs(z-e.z)<e.s&&Math.hypot(x-e.x,z-e.z)<e.s*0.9&&y<G(e.x,e.z)+e.s*1.9)return false;}
  return true;}
// a scene's shot, made to fit: on a phone held upright the frame is narrow, so a shot of people close by steps back along its line (up to 1.5×, at most 6 m; a view into the distance stays)
// to take in what a wide screen would; and on any screen, a camera that would stand in a wall or a tree, or whose view of what
// it looks at is cut by one, moves along the same line to the nearest place that is clear. Worked out once for each shot
function camFit(c){if(c.fit&&c.fitA===camera.aspect<0.8)return c.fit.clone();
  const p=c.pos,l=c.look,d=p.clone().sub(l),D=d.length(),up=camera.aspect<0.8&&D<16?Math.min(1.5,1+6/D):1,ks=[];   // only shots of people close by, and never more than 6 m further
  for(let k=up;k>=0.999;k-=0.1)ks.push(k);for(let k=0.9;k>=0.35;k-=0.1)ks.push(k);
  // (a view into the distance only needs the few metres round the camera clear, not the whole way)
  const t0=D<16?0.2:Math.max(0.2,1-3/D),clearTo=q=>{for(let t=t0;t<=1.001;t+=Math.min(0.1,(1-t0)/4)){const x=lerp(l.x,q.x,t),y=lerp(l.y,q.y,t),z=lerp(l.z,q.z,t);if(!camClear(x,y,z))return false;}return true;};
  let best=p.clone();for(const k of ks){const q=l.clone().addScaledVector(d,k);if(clearTo(q)){best=q;break;}}
  c.fit=best;c.fitA=camera.aspect<0.8;return best.clone();}
function updateCamera(dt){
  const cyaw=P.foot&&stick.on?footCamYaw:P.yaw,F=new THREE.Vector3(Math.sin(cyaw),0,Math.cos(cyaw)),p=new THREE.Vector3(P.x,P.y,P.z);let want,look,rate=4;
  if(state==='title'){const a=Math.sin(clock*0.12)*0.35;want=new THREE.Vector3(P.x+Math.sin(a)*1.9-0.4,P.y+1.25,P.z-Math.cos(a)*1.9);look=new THREE.Vector3(P.x+0.35,P.y+0.95,P.z);rate=2;}
  else if(TD.on){want=new THREE.Vector3();look=new THREE.Vector3();tdCam(want,look);rate=8;}
  else if(ST.cam){look=ST.cam.look.clone();want=camFit(ST.cam);rate=ST.cam.rate;}
  else if(RIDE.on){want=new THREE.Vector3();look=new THREE.Vector3();rideCam(want,look);rate=0;}
  else if(BOAT.on){want=new THREE.Vector3();look=new THREE.Vector3();boatCam(want,look);rate=3;}
  else if(URA.chase&&URA.chase.replay){want=new THREE.Vector3();look=new THREE.Vector3();uraReplayCam(want,look);rate=URA.chase.replay.at===URA.chase.replay.t0?0:5;}
  else if(URA.hide){want=new THREE.Vector3();look=new THREE.Vector3();uraHideCam(want,look);rate=5;}
  else if(talkNpc&&Math.hypot(P.x-talkNpc.x,P.z-talkNpc.z)<8){const n=talkNpc,m=new THREE.Vector3((P.x+n.x)/2,P.y,(P.z+n.z)/2),d=new THREE.Vector3(n.x-P.x,0,n.z-P.z).normalize(),side=new THREE.Vector3(-d.z,0,d.x);
    want=m.clone().addScaledVector(side,3.4).addScaledVector(d,-0.6);want.y+=1.5;if(blocked(want.x,want.y,want.z))want=m.clone().addScaledVector(side,-3.4).setY(m.y+1.5);look=m.clone();look.y+=1.15;rate=3;}
  else if(modal==='closet'){const fw=player.hips.getWorldDirection(new THREE.Vector3());fw.y=0;fw.normalize();
    // she stands in the space above the sheet: far enough back to fit there, the aim lowered so she sits in its middle
    // drag turns the view round her, a pinch or the wheel brings it closer (and up to her face)
    if(CL.spin)CL.yaw+=dt*0.5;
    const sh=$(CL.big?'closetMini':'closetSheet').getBoundingClientRect(),f=clamp(sh.top/innerHeight,0.3,1),tn=Math.tan(closetFov()*Math.PI/360),dist=clamp(1.85/(2*tn*f*0.9),2.3,9)*CL.zoom;
    const a=Math.atan2(fw.x,fw.z)+CL.yaw,cy=lerp(1.0,1.5,clamp((1-CL.zoom)/0.6,0,1));
    want=p.clone().addScaledVector(new THREE.Vector3(Math.sin(a),0,Math.cos(a)),dist*Math.cos(CL.pitch));want.y+=cy+dist*Math.sin(CL.pitch);
    look=p.clone();look.y+=cy-dist*(1-1.03*f)*tn;rate=10;}   // her middle a little below the middle of the space, clear of the money and clock
  else if(modal==='shop'&&shopCam&&SHOPS[shopCam]){const b=SHOPS[shopCam];const fw=new THREE.Vector3(Math.sin(b.yaw),0,Math.cos(b.yaw));
    want=new THREE.Vector3(b.fx,b.base,b.fz).addScaledVector(fw,7);want.y+=2.4;look=new THREE.Vector3(b.fx,b.base+2.4,b.fz);rate=3;}
  else if(MIR.on&&!ST.run){want=new THREE.Vector3();look=new THREE.Vector3();mirCam(want,look);rate=4;}
  else if(lookBack()){want=p.clone().addScaledVector(F,-0.45);want.y+=1.55;look=p.clone().addScaledVector(F,-20);look.y+=1.2;rate=0;}   // her eyes turned back: from just behind her head, down the way she came (her body stays out of the picture)
  else{const back=3.3+P.v*0.12,up=1.45+P.v*0.035;want=p.clone().addScaledVector(F,-back);want.y+=up;look=p.clone().addScaledVector(F,2.2);look.y+=1.05;
    // in the drone fight the camera moves over her shoulder, so the raised pistols and the shots are in view
    const aw=player.aimW||0;if(aw>0.01){const side=new THREE.Vector3(-F.z,0,F.x);want.addScaledVector(side,-1.0*aw).addScaledVector(F,1.1*aw);want.y+=0.1*aw;look.addScaledVector(side,-0.5*aw);look.y+=0.6*aw;}
    // on this side of the walls. How far the camera can get from her head toward a spot before a wall stops it (0…1; pressed
    // against a wall herself, the first open step counts as the start). With a wall close behind her, it swings round to her
    // side, where there is room, rather than squeezing in at her back; and if it still cannot get far, it rises to look down
    { const h=p.clone();h.y+=1.3;
      const reach=q=>{let open=false;for(let t=0.06;t<=1.001;t+=0.06){const b=blocked(lerp(h.x,q.x,t),lerp(h.y,q.y,t),lerp(h.z,q.z,t));if(!b)open=true;else if(open)return t-0.06;}return 1;};
      const turn=(q,o)=>{const dx=q.x-p.x,dz=q.z-p.z,c=Math.cos(o),s=Math.sin(o);return new THREE.Vector3(p.x+dx*c-dz*s,q.y,p.z+dx*s+dz*c);};
      let off=0;if(reach(want)<0.75){let best=reach(want);for(const o of [0.6,-0.6,1.2,-1.2,1.7,-1.7]){const k=reach(turn(want,o))-Math.abs(o)*0.1;if(k>best+0.05){best=k;off=o;}}}
      CAMOFF+=(off-CAMOFF)*Math.min(1,dt*4);if(Math.abs(CAMOFF)>0.01)want=turn(want,CAMOFF);
      const k=reach(want);if(k<1){const kk=Math.max(0.1,k);want.lerpVectors(h,want,kk);want.y+=(1-kk)*1.9;look.lerp(new THREE.Vector3(P.x,P.y+0.7,P.z).addScaledVector(F,1.4),(1-kk)*0.8);rate=14;}}
    if(AREA==='base'||AREA==='hq')want.y=Math.min(want.y,(AREA==='base'?BASE_H:6.5)-0.5);
    want.y=Math.max(want.y,G(want.x,want.z)+0.6);}
  if(!camInit||rate===0){camPos.copy(want);camLook.copy(look);camInit=true;}   // on the tram the view rides with the car
  camPos.lerp(want,1-Math.exp(-dt*rate));camLook.lerp(look,1-Math.exp(-dt*(rate+3)));
  camera.position.copy(camPos);if(P.bump>0&&!reduceMotion){camera.position.y+=(Math.random()-.5)*P.bump*0.3;}P.bump=Math.max(0,P.bump-dt);
  camera.lookAt(camLook);const fov=modal==='closet'?closetFov():camera.aspect<0.8?(ST.cam?84:72):58;camera.fov+=(fov+(reduceMotion?0:P.v*0.6)-camera.fov)*Math.min(1,3*dt);camera.updateProjectionMatrix();
  dome.position.copy(camera.position);
  const sp=state==='title'?new THREE.Vector3(0,30,-120):p;sun.position.copy(sp).addScaledVector(sunDir,70);sun.target.position.copy(sp);sun.target.updateMatrixWorld();
}

/* ---------- loop ---------- */
let state='title',clock=0,last=performance.now();
function updateNPCs(dt){for(const id in NPCS){const n=NPCS[id],d=Math.hypot(P.x-n.x,P.z-n.z),here=present(n);n.box.on=here;n.h.g.visible=d<110&&here;if(!n.h.g.visible)continue;
    const giving=QUESTS.some(q=>q.giver===id&&available(q));
    poseHuman(n.h,n.mode,dt,{look:d<9||talkNpc===n?player.g.position:null,wave:giving&&d<14&&d>3&&n.mode!=='sit'});
    if(n.vrm)poseMio(n,dt,d<9||talkNpc===n?_mioL.set(P.x,P.y+1.3,P.z).clone():null);}
  for(const c of CATS)poseCat(c,dt,Math.hypot(P.x-c.g.position.x,P.z-c.g.position.z)<3);}
function updateMarkers(){const calm=!!(DLG||modal||ST.run||URA.on);for(const q of QUESTS){const m=qMarks[q.id],n=NPCS[q.giver];m.visible=available(q)&&state==='play'&&!calm;if(m.visible)m.position.set(n.x,n.h.g.position.y+(n.mode==='sit'?1.75:2.25)+Math.sin(clock*3)*0.08,n.z);}
  const q=SAVE.tracked&&QBY(SAVE.tracked),t=q&&targetOf(q);tMark.visible=beam.visible=!!t&&state==='play'&&!calm;
  if(t){const y=G(t[0],t[1]);tMark.position.set(t[0],y+2.9+Math.sin(clock*3)*0.12,t[1]);beam.position.set(t[0],y+20,t[1]);beam.material.opacity=clamp(Math.hypot(P.x-t[0],P.z-t[1])/60,0,1)*0.22;}
  const pq=QBY('photo'),ps=stepOf(pq);SPOTS.forEach((p,k)=>{camMarks[k].visible=state==='play'&&!calm&&(!ps||!SAVE.spots.includes(p.id));camMarks[k].position.y=G(p.x,p.z)+2.6+Math.sin(clock*2+k)*0.08;});}
let placeT=0;
function frame(now){const dt=Math.min(0.05,(now-last)/1000);last=now;clock+=dt;
  WIND.t.value=clock;updateGrass();updateWindLines(dt);updateStory(dt);
  if(state==='play'){if(talkNpc&&!ST.run&&Math.hypot(P.x-talkNpc.x,P.z-talkNpc.z)>6){DLG=null;$('dialog').hidden=true;talkNpc=null;}
    if(ST.run&&!storyFree())jumpQ=kickQ=footQ=trickQ=false;updateTricks(dt);
    updateDrones(dt);stepPlayer(dt);near=DLG||modal?null:ST.run?(ISL.wait?islNear():URA.chase?uraNear():null):findNear();if(actQ&&near)act(near);actQ=false;
    const pr=$('prompt');if(near&&!DLG&&!modal&&(!ST.run||storyFree())){pr.hidden=false;pr.innerHTML='';if(hasTouch)pr.textContent=near.label.replace(near.verb,'').replace(/^[\s　]+/,'')||near.label;   // phones: the button already says the verb
      else{const k=document.createElement('kbd');k.textContent='E';pr.append(k,document.createTextNode(near.label));}}else pr.hidden=true;
    // the act button is there only when there is something to do with it: someone or something close by, or a line to read on
    const ba=$('bAct'),can=!!(near&&!DLG&&!modal&&(!ST.run||storyFree())),next=!!(DLG&&!DLG.choice);ba.style.visibility=can||next?'visible':'hidden';ba.textContent=next?'次へ':can?near.verb:'話す';
    placeT-=dt;if(placeT<=0){$('place').textContent=placeName();placeT=0.5;}drawMap();}
  else{player.g.position.set(P.x,P.y,P.z);player.g.rotation.set(0,P.yaw,0);poseSkater(player,dt,{v:0,turn:0,push:false,brake:false,air:false});}
  updateTram(dt);updateInaka(dt);updateIsland(dt);updateCars(dt);updateFolk(dt,P.x,P.z,false);updateNPCs(dt);updateMarkers();
  waveTex.offset.set((clock*0.004)%1,(clock*0.006)%1);foamTex.offset.x=(clock*0.02)%1;
  updateCamera(dt);updateSound(dt);mirReflect();renderer.render(scene,camera);
  // while dressing, the heroine is drawn again on top, so a stall or a post between her and the camera never hides her
  if(modal==='closet'){player.g.traverse(o=>o.layers.enable(1));renderer.autoClear=false;renderer.clearDepth();const su=renderer.shadowMap.autoUpdate;renderer.shadowMap.autoUpdate=false;
    // a plain colour behind her (the sky colour unless one is picked); in the big view the town can stay behind her instead
    const bg=scene.background;scene.background=CL.big&&!CL.bg?null:CL.bg?CLOSET_BG[CL.bg]:bg;
    camera.layers.set(1);renderer.render(scene,camera);scene.background=bg;camera.layers.set(0);renderer.shadowMap.autoUpdate=su;renderer.autoClear=true;}
  if(photoReq){photoReq=false;snap();}
  requestAnimationFrame(frame);}
function startGame(k){SLOT=k;store.set('umimachi_slot',String(k));const fresh=!loadSlot(k);SAVE=loadSlot(k)||JSON.parse(JSON.stringify(S0));if(fresh)setTimeout(()=>toast(hasTouch?'操作は「メニュー」→「設定」→「あそびかた」で見られる':'操作は右の「設定」→「あそびかた」で見られる'),6000);if(player.vrm)applyOutfit(player,SAVE.outfit);
  state='play';P.yaw=0;$('title').hidden=true;$('hud').hidden=false;$('stick').hidden=!hasTouch;$('bLook').hidden=!hasTouch;$('pad').hidden=!hasTouch;camInit=false;renderClock();renderHUD();save();canvas.focus();
  toast(hasTouch?'右の「ける」ボタンで地面をけって進もう':'W か ↑ を押すたびに、地面をひと蹴り');if(!SAVE.qs.melon)toast('坂の上の鳥居のそばで、おばあちゃんが手を振っている');
  // test entries: index.html#hour=20 sets the clock, #at=-80,330 starts there, #day=3 jumps to that morning, #set=route:3 sets flags (they combine with &)
  const hr=/hour=([\d.]+)/.exec(location.hash),at=/at=(-?[\d.]+),(-?[\d.]+)/.exec(location.hash),dy=/day=(\d+)/.exec(location.hash);
  if(dy){SAVE.day=+dy[1];SAVE.hour=DAY_START;SAVE.cap=DAY_CAP;SAVE.qs.melon=SAVE.qs.melon||{state:2,step:1};for(const e of EVENTS){const m=/^d(\d)_/.exec(e.id);if(m&&+m[1]<SAVE.day)SAVE.seen[e.id]=1;else delete SAVE.seen[e.id];}
    if(SAVE.day<=3)for(const k of ['route','in_ura','clues','clue_photo','clue_marble','clue_diary','fest_day','contest_done','ending_calm','ending_horror'])delete SAVE.flags[k];}
  const fl=/set=([\w:,-]+)/.exec(location.hash);if(fl)for(const kv of fl[1].split(',')){const [k,v]=kv.split(':');SAVE.flags[k]=v==null?1:+v;}   // #set=route:3,met_mio:1
  if(hr)SAVE.hour=SAVE.cap=+hr[1];if(at){P.x=+at[1];P.z=+at[2];P.y=G(P.x,P.z);P.yaw=0;}
  if(location.hash==='#drones')startDrones();}   // test entry: index.html#drones starts the drone fight at once
// the title lists the save slots: continue, start, or erase (a second press confirms)
function renderSlots(){const box=$('slots');box.innerHTML='';
  for(let k=1;k<=SLOTS;k++){const s=loadSlot(k),row=document.createElement('div');row.className='slot';row.setAttribute('role','listitem');
    const info=document.createElement('div');info.className='si';const b=document.createElement('b');b.textContent=`セーブ ${k}`;info.appendChild(b);
    if(s){const done=QUESTS.filter(q=>s.qs[q.id]&&s.qs[q.id].state===2).length,at=s.at?new Date(s.at):null;
      info.appendChild(document.createTextNode(`${s.day}日目・${PHASE_NAME[phaseOf(s.hour)]}　さいふ ${s.money.toLocaleString('ja-JP')}円　おつかい ${done}/${QUESTS.length}`+(at?`　${at.getMonth()+1}/${at.getDate()} ${String(at.getHours()).padStart(2,'0')}:${String(at.getMinutes()).padStart(2,'0')}`:'')));}
    else info.appendChild(document.createTextNode('まだ何もない'));
    const go=document.createElement('button');go.className='btn';go.textContent=s?'つづきから':'はじめる';go.addEventListener('click',()=>startGame(k));row.append(info,go);
    if(s){const del=document.createElement('button');del.className='btn ghost del';del.textContent='消す';
      del.addEventListener('click',()=>{if(del.dataset.sure){store.set(slotKey(k),'null');renderSlots();return;}del.dataset.sure=1;del.textContent='本当に消す？';});row.appendChild(del);}
    if(k===SLOT&&s)row.style.boxShadow='inset 0 0 0 2px var(--sea)';box.appendChild(row);}}
renderSlots();
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
// Mio's model, the same way (the procedural figure stays if it cannot be fetched; the single-file build does without it)
const mioReady=new Promise(res=>{if(!window.THREE||!THREE.GLTFLoader||document.getElementById('heroineGLB'))return res();const t=setTimeout(res,25000);
  new THREE.GLTFLoader().load('mio.glb',g=>{window.MIO_GLTF=g;clearTimeout(t);res();},undefined,()=>{clearTimeout(t);res();});});
Promise.all([fontReady,heroineReady,mioReady,window.APP&&APP.ready]).then(main);
</script>
