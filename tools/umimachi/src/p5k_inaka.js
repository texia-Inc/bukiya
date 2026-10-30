
/* ---------- 山のふもと: the country at the far end of the tram line. Rice fields and a few farmhouses round a little terminus,
   and a big mountain with a hairpin road, いろは坂, up to the observation deck on top. Racers wait in the car park at the summit:
   beat them down the mountain on the board — the car is faster on the straights, the board takes the hairpins tighter, and
   nothing stops you dropping off the road onto the bend below.
   The area lies far east of the town (x around INK_X, z around 0; the town is hidden while you are here) and is reached only
   by the tram; G() looks its heights up in a grid baked here. Local coordinates lx, lz are measured from (INK_X, 0). ---------- */
const INK_FIELDS=[[-200,-75,72,140],[-45,125,72,140]];
const INK_R=280,INK_CELL=2,INK_N=INK_R*2/INK_CELL+1,INK_GRADE=0.11,INK_TRACK=170;
const INK_BASE=new Float32Array(INK_N*INK_N),INK_HG=new Float32Array(INK_N*INK_N);   // the ground, and the ground with the road cut in
let AREA='town';
// instanced meshes get a material of their own: three r128 trips over one shared with another instanced mesh that has colours
const itm=c=>new THREE.MeshToonMaterial({color:c,gradientMap:GRAD});
// the road: a sample every metre from the station up to the summit car park {x,z (local), h, s}
const ROAD=[],CURVES=[];
{ const pts=[];const line=(x0,z0,x1,z1)=>{const n=Math.ceil(Math.hypot(x1-x0,z1-z0));for(let i=pts.length?1:0;i<=n;i++)pts.push([lerp(x0,x1,i/n),lerp(z0,z1,i/n),0]);};
  const arc=(cx,cz,a0,a1)=>{const n=Math.ceil(Math.abs(a1-a0)*10);CURVES.push({x:cx,z:cz,i:pts.length+(n>>1)});for(let i=1;i<=n;i++){const a=lerp(a0,a1,i/n);pts.push([cx+10*Math.cos(a),cz+10*Math.sin(a),1]);}};
  const PI=Math.PI;line(-60,165,-60,50);arc(-50,50,PI,1.5*PI);const s0=pts.length-1;
  for(let i=0;i<8;i++){const z=40-20*i,e=i%2===0;line(e?-50:50,z,e?50:-50,z);if(i<7){if(e)arc(50,z-10,PI/2,-PI/2);else arc(-50,z-10,PI/2,1.5*PI);}}
  arc(-50,-110,PI/2,PI);const s1=pts.length-1;line(-60,-110,-60,-127);
  let s=0;pts.forEach((p,i)=>{if(i)s+=Math.hypot(p[0]-pts[i-1][0],p[1]-pts[i-1][1]);ROAD.push({x:p[0],z:p[1],s,curve:p[2],h:0});});
  for(const r of ROAD)r.h=clamp(r.s-ROAD[s0].s,0,ROAD[s1].s-ROAD[s0].s)*INK_GRADE;
  ROAD.s0=s0;ROAD.s1=s1;}
const INK_TOP=ROAD[ROAD.length-1].h;
const DECK={x0:-4,x1:8,z0:-146,z1:-134,h:INK_TOP+3.6},RAMP={x0:-18,x1:-4,z0:-142,z1:-138};
const PARK={x0:-84,x1:-18,z0:-152,z1:-126};
// the mountain before the road is cut in: a steep south face whose height follows the rows of the road, a summit plateau, a long
// north slope, and a ring of hills round the edge with a cutting for the railway
function inkBase(lx,lz){const rowH=i=>(i*131.4+50)*INK_GRADE;let f;
  if(lz>=55)f=0;else if(lz>=40)f=rowH(0)*smooth((55-lz)/15);else if(lz>=-100)f=lerp(rowH(0),rowH(7),(40-lz)/140);
  else if(lz>=-114)f=lerp(rowH(7),INK_TOP+1,smooth((-100-lz)/14));else if(lz>=-168)f=INK_TOP+1+2.5*Math.sin((lz+114)/54*Math.PI);
  else f=(INK_TOP+1)*(1-smooth(clamp((-168-lz)/80,0,1)));
  f*=1-smooth(clamp((Math.abs(lx)-70)/120,0,1));
  let rim=38*smooth(clamp((Math.max(Math.abs(lx),Math.abs(lz))-205)/55,0,1));if(Math.abs(lz-INK_TRACK)<6&&lx<-150)rim=0;
  const n=lz<55?vnoise(lx/18,lz/18)*1.6:vnoise(lx/30,lz/30)*0.25;return Math.max(f,rim)+n;}
{ const best=new Float32Array(INK_N*INK_N).fill(99),bh=new Float32Array(INK_N*INK_N);
  for(let r=0;r<INK_N;r++)for(let c=0;c<INK_N;c++)INK_BASE[r*INK_N+c]=inkBase(-INK_R+c*INK_CELL,-INK_R+r*INK_CELL);
  for(const p of ROAD){const c0=Math.floor((p.x+INK_R-10)/INK_CELL),r0=Math.floor((p.z+INK_R-10)/INK_CELL);
    for(let r=r0;r<=r0+10;r++)for(let c=c0;c<=c0+10;c++){if(r<0||c<0||r>=INK_N||c>=INK_N)continue;const k=r*INK_N+c,d=Math.hypot(-INK_R+c*INK_CELL-p.x,-INK_R+r*INK_CELL-p.z);if(d<best[k]){best[k]=d;bh[k]=p.h;}}}
  for(let r=0;r<INK_N;r++)for(let c=0;c<INK_N;c++){const k=r*INK_N+c,lx=-INK_R+c*INK_CELL,lz=-INK_R+r*INK_CELL;let h=INK_BASE[k];
    if(best[k]<99)h=lerp(bh[k],h,smooth(clamp((best[k]-4.2)/5.6,0,1)));
    if(lx>PARK.x0-4&&lx<PARK.x1+4&&lz>PARK.z0-4&&lz<PARK.z1+4){const e=Math.min(lx-PARK.x0,PARK.x1-lx,lz-PARK.z0,PARK.z1-lz);h=lerp(h,INK_TOP,smooth(clamp((e+4)/4,0,1)));}
    if(lz>62&&lz<200&&Math.abs(lx)<195)h=0.05;   // the valley floor stays level
    INK_HG[k]=h;INK_BASE[k]=h;}}
// heights in the country: the deck and its ramp, then the grid
function inkG(x,z){const lx=x-INK_X,lz=z;
  if(lx>DECK.x0&&lx<DECK.x1&&lz>DECK.z0&&lz<DECK.z1)return DECK.h;
  if(lx>RAMP.x0&&lx<RAMP.x1&&lz>RAMP.z0&&lz<RAMP.z1)return lerp(INK_TOP,DECK.h,(lx-RAMP.x0)/(RAMP.x1-RAMP.x0));
  const fx=clamp((lx+INK_R)/INK_CELL,0,INK_N-1.001),fz=clamp((lz+INK_R)/INK_CELL,0,INK_N-1.001),c=Math.floor(fx),r=Math.floor(fz),u=fx-c,v=fz-r,k=r*INK_N+c;
  return lerp(lerp(INK_HG[k],INK_HG[k+1],u),lerp(INK_HG[k+INK_N],INK_HG[k+INK_N+1],u),v);}
const inkY=(lx,lz)=>inkG(INK_X+lx,lz);

const INK={g:new THREE.Group(),map:document.createElement('canvas')};scene.add(INK.g);INK.g.visible=false;
{ const add=(m,x,y,z)=>{m.position.set(INK_X+x,y,z);INK.g.add(m);return m;};
  const Mi=(geo,mat,ol)=>{const m=new THREE.Mesh(geo,mat);m.castShadow=true;if(ol)outline(m,ol);return m;};
  // the ground: grass, rock where it is steep, the valley floor a lighter green
  { const pos=[],col=[],idx=[];for(let r=0;r<INK_N;r++)for(let c=0;c<INK_N;c++){const lx=-INK_R+c*INK_CELL,lz=-INK_R+r*INK_CELL,k=r*INK_N+c,h=INK_HG[k];
      pos.push(INK_X+lx,h,lz);const sl=Math.hypot(INK_HG[Math.min(k+1,INK_N*INK_N-1)]-h,INK_HG[Math.min(k+INK_N,INK_N*INK_N-1)]-h)/INK_CELL,n=vnoise(lx/9,lz/9),q=0.82+n*0.3;
      let cc=lz>58&&h<1?[0.5*q,0.66*q,0.36*q]:[0.3*q,0.48*q,0.24*q];if(sl>0.85)cc=[0.5*q,0.46*q,0.4*q];else if(sl>0.6)cc=[0.4*q,0.44*q,0.3*q];col.push(...cc);}
    for(let r=0;r<INK_N-1;r++)for(let c=0;c<INK_N-1;c++){const a=r*INK_N+c,b=a+INK_N;idx.push(a,b,a+1,a+1,b,b+1);}
    const geo=new THREE.BufferGeometry();geo.setAttribute('position',new THREE.Float32BufferAttribute(pos,3));geo.setAttribute('color',new THREE.Float32BufferAttribute(col,3));geo.setIndex(idx);geo.computeVertexNormals();
    const m=new THREE.Mesh(geo,tmap(null,{vertexColors:true}));m.receiveShadow=true;INK.g.add(m);}
  // the road: asphalt with white edges and a yellow centre line; guard rails on the downhill side
  { const tex=canvasTex(64,64,(g,w,h)=>{g.fillStyle='#5b5d61';g.fillRect(0,0,w,h);g.fillStyle='rgba(0,0,0,.12)';for(let i=0;i<60;i++)g.fillRect(Math.random()*w,Math.random()*h,2,2);
      g.fillStyle='#eeeeea';g.fillRect(2,0,3,h);g.fillRect(w-5,0,3,h);g.fillStyle='#f2c230';g.fillRect(w/2-2,0,4,h*0.55);},true);
    const pos=[],uv=[],idx=[];ROAD.forEach((p,i)=>{const q=ROAD[Math.min(i+1,ROAD.length-1)],o=ROAD[Math.max(i-1,0)],tx=q.x-o.x,tz=q.z-o.z,L=Math.hypot(tx,tz)||1,nx=-tz/L*3.6,nz=tx/L*3.6;
      for(const sd of [-1,1]){const x=p.x+nx*sd,z=p.z+nz*sd;pos.push(INK_X+x,Math.max(p.h,inkY(x,z))+0.06,z);uv.push(sd>0?1:0,p.s/6);}
      if(i){const a=(i-1)*2;idx.push(a,a+2,a+1,a+1,a+2,a+3);}});
    const geo=new THREE.BufferGeometry();geo.setAttribute('position',new THREE.Float32BufferAttribute(pos,3));geo.setAttribute('uv',new THREE.Float32BufferAttribute(uv,2));geo.setIndex(idx);geo.computeVertexNormals();
    const m=new THREE.Mesh(geo,tmap(tex,{side:THREE.DoubleSide,polygonOffset:true,polygonOffsetFactor:-2}));m.receiveShadow=true;INK.g.add(m);
    const posts=[],rails=[];for(let i=ROAD.s0;i<ROAD.length-12;i+=4){const p=ROAD[i],q=ROAD[i+4],tx=q.x-p.x,tz=q.z-p.z,L=Math.hypot(tx,tz)||1;
      let best=null;for(const sd of [-1,1]){const x=p.x-tz/L*4.1*sd,z=p.z+tx/L*4.1*sd,dh=inkY(p.x-tz/L*7*sd,p.z+tx/L*7*sd)-p.h;if(dh<-1&&(!best||dh<best.dh))best={x,z,dh,sd};}
      if(!best)continue;posts.push({x:best.x,z:best.z,y:p.h});const x2=q.x-tz/L*4.1*best.sd,z2=q.z+tx/L*4.1*best.sd;rails.push({x:(best.x+x2)/2,z:(best.z+z2)/2,y:(p.h+q.h)/2,yaw:Math.atan2(x2-best.x,z2-best.z),l:Math.hypot(x2-best.x,z2-best.z),p:Math.atan2(q.h-p.h,4)});}
    const pm=new THREE.InstancedMesh(new THREE.CylinderGeometry(0.06,0.06,0.8,6),itm('#d8dade'),posts.length);posts.forEach((e,k)=>{dummy.position.set(INK_X+e.x,e.y+0.4,e.z);dummy.rotation.set(0,0,0);dummy.scale.set(1,1,1);dummy.updateMatrix();pm.setMatrixAt(k,dummy.matrix);});INK.g.add(pm);
    const rm=new THREE.InstancedMesh(new THREE.BoxGeometry(0.06,0.3,1),itm('#eef0f2'),rails.length);rails.forEach((e,k)=>{dummy.position.set(INK_X+e.x,e.y+0.62,e.z);dummy.rotation.set(-e.p,e.yaw,0,'YXZ');dummy.scale.set(1,1,e.l+0.1);dummy.updateMatrix();rm.setMatrixAt(k,dummy.matrix);});rm.castShadow=true;INK.g.add(rm);}
  // a sign at each bend, lettered い ろ は … as on the real hairpin road
  CURVES.forEach((cv,k)=>{const ch='いろはにほへとちり'[k]||'',p=ROAD[cv.i],dx=p.x-cv.x,dz=p.z-cv.z,L=Math.hypot(dx,dz)||1,x=p.x+dx/L*5.2,z=p.z+dz/L*5.2,y=inkY(x,z);
    const s=Mi(new THREE.CylinderGeometry(0.05,0.05,2.2,6),tm('#ccc'));add(s,x,y+1.1,z);
    const t=new THREE.Mesh(new THREE.BoxGeometry(0.8,0.8,0.06),[tm('#fff'),tm('#fff'),tm('#fff'),tm('#fff'),tmap(canvasTex(64,64,(g,w,h)=>{g.fillStyle='#2a63b8';g.fillRect(0,0,w,h);g.fillStyle='#fff';g.font=signFont(44,true);g.textAlign='center';g.textBaseline='middle';g.fillText(ch,w/2,h/2+3);})),tm('#2a63b8')]);
    add(t,x,y+2.4,z);t.rotation.y=Math.atan2(-dx,-dz);});
  // trees on the mountain, away from the road
  { const list=[],r=mulberry(77);for(let n=0;n<2600&&list.length<1500;n++){const lx=(r()*2-1)*265,lz=-265+r()*330;let near=false;
      for(let i=0;i<ROAD.length;i+=3){if(Math.abs(ROAD[i].x-lx)<11&&Math.abs(ROAD[i].z-lz)<11){near=true;break;}}
      if(near||(lx>-110&&lx<75&&lz>-185&&lz<-95)||(lz>55&&Math.abs(lx)<200))continue;list.push({x:lx,z:lz,y:inkY(lx,lz),s:1.6+r()*1.6});}
    const trunk=new THREE.InstancedMesh(new THREE.CylinderGeometry(0.16,0.22,1.4,6),itm('#5b4636'),list.length),crown=new THREE.InstancedMesh(new THREE.ConeGeometry(1,2.6,7),itm('#2f5a34'),list.length);
    list.forEach((e,k)=>{dummy.rotation.set(0,0,0);dummy.position.set(INK_X+e.x,e.y+0.6*e.s,e.z);dummy.scale.setScalar(e.s);dummy.updateMatrix();trunk.setMatrixAt(k,dummy.matrix);
      dummy.position.y=e.y+2.3*e.s;dummy.updateMatrix();crown.setMatrixAt(k,dummy.matrix);});crown.castShadow=true;INK.g.add(trunk,crown);}
  // the railway: track from the tunnel in the hills to the buffer stop past the platform, and the little station
  { const ballast=Mi(new THREE.BoxGeometry(276,0.12,3.4),tm('#8a8276'));add(ballast,-146,0.06,INK_TRACK);ballast.castShadow=false;ballast.receiveShadow=true;
    for(const o of [-0.53,0.53])add(Mi(new THREE.BoxGeometry(276,0.12,0.08),tm('#a9aeb4')),-146,0.2,INK_TRACK+o);
    const sl=new THREE.InstancedMesh(new THREE.BoxGeometry(0.22,0.12,2.2),itm('#5b4636'),276);for(let k=0;k<276;k++){dummy.rotation.set(0,0,0);dummy.scale.set(1,1,1);dummy.position.set(INK_X-283+k,0.1,INK_TRACK);dummy.updateMatrix();sl.setMatrixAt(k,dummy.matrix);}INK.g.add(sl);
    add(Mi(new THREE.BoxGeometry(0.5,1,2.4),tm('#c8372d'),0.02),-7.5,0.5,INK_TRACK);
    const portal=Mi(new THREE.BoxGeometry(3,9,16),tm('#9a958c'),0.04);add(portal,-233,4.5,INK_TRACK);
    const hole=new THREE.Mesh(new THREE.BoxGeometry(3.2,5.2,5.4),new THREE.MeshBasicMaterial({color:'#0b0b0c'}));add(hole,-232.6,2.6,INK_TRACK);
    const plat=Mi(new THREE.BoxGeometry(32,0.34,3.4),tm('#c9c2b4'),0.02);add(plat,-60,0.17,INK_TRACK+3.3);plat.receiveShadow=true;
    add(new THREE.Mesh(new THREE.BoxGeometry(32,0.02,0.3),tm('#f2c230')),-60,0.35,INK_TRACK+1.75);
    collide(INK_X-76,INK_X-44,INK_TRACK+1.6,INK_TRACK+5,'stop',0.34);
    const roof=Mi(new THREE.BoxGeometry(10,0.14,2.4),tm('#7a4a2e'),0.025);add(roof,-60,2.9,INK_TRACK+3.8);
    for(const x of [-64,-56])add(Mi(new THREE.CylinderGeometry(0.07,0.07,2.6,8),tm('#6b4a2e')),x,1.6,INK_TRACK+4.6);
    const sgT=tmap(canvasTex(256,64,(c,w,h)=>{c.fillStyle='#fffaf0';c.fillRect(0,0,w,h);c.fillStyle='#7a4a2e';c.fillRect(0,h-12,w,12);
      c.fillStyle='#2b2520';c.font=signFont(28,true);c.textAlign='center';c.fillText('山のふもと',w/2,34);}));
    const sg=new THREE.Mesh(new THREE.BoxGeometry(2.6,0.6,0.08),[tm('#fff'),tm('#fff'),tm('#fff'),tm('#fff'),sgT,sgT]);add(sg,-60,2.45,INK_TRACK+4.6);
    const b=benchMesh();add(b,-60,0.34,INK_TRACK+4.2);b.rotation.y=Math.PI;
    // the station house: wooden, a tiled roof, a lamp
    const hs=Mi(new THREE.BoxGeometry(8,3,5),tm('#b08a5e'),0.03);add(hs,-36,1.5,INK_TRACK+7);
    const rf=Mi(new THREE.ConeGeometry(5.6,1.6,4),tm('#4a4f5a'),0.03);rf.rotation.y=Math.PI/4;rf.scale.set(1.15,1,0.8);add(rf,-36,3.8,INK_TRACK+7);
    collide(INK_X-40,INK_X-32,INK_TRACK+4.5,INK_TRACK+9.5,'bld');}
  // the valley: farmhouses, rice fields, telegraph poles along the lane
  { const houses=[[-130,190,0.2],[-22,191,0],[60,188,-0.15],[160,110,1.57],[165,182,0.1]];
    for(const [x,z,yaw] of houses){const g=new THREE.Group();g.position.set(INK_X+x,0,z);g.rotation.y=yaw;INK.g.add(g);
      const w=Mi(new THREE.BoxGeometry(10,3.2,7),tm('#e8dcc4'),0.03);w.position.y=1.6;g.add(w);
      const r=Mi(new THREE.CylinderGeometry(0.01,5.4,2.6,4,1),tm('#3d4250'),0.03);r.rotation.y=Math.PI/4;r.scale.set(1.45,1,1);r.position.y=4.5;g.add(r);
      for(const sx of [-2.5,2.5]){const d=new THREE.Mesh(new THREE.PlaneGeometry(1.6,1.2),tm('#4a5a66'));d.position.set(sx,1.9,3.51);g.add(d);}
      const dr=new THREE.Mesh(new THREE.PlaneGeometry(1.4,2.2),tm('#6b4a2e'));dr.position.set(0,1.1,3.51);g.add(dr);
      const c=Math.cos(yaw),s=Math.sin(yaw),hx=Math.abs(5*c)+Math.abs(3.5*s),hz=Math.abs(5*s)+Math.abs(3.5*c);collide(INK_X+x-hx,INK_X+x+hx,z-hz,z+hz,'bld');}
    const fields=[];for(const [x0,x1,z0,z1] of INK_FIELDS)
      for(let x=x0;x<x1-14;x+=17)for(let z=z0;z<z1-12;z+=15)fields.push({x:x+7,z:z+6});
    const wtr=new THREE.InstancedMesh(new THREE.PlaneGeometry(15,12),new THREE.MeshToonMaterial({color:'#8fb7a6',gradientMap:GRAD}),fields.length);
    const bank=new THREE.InstancedMesh(new THREE.BoxGeometry(16,0.25,13),itm('#7a6a4c'),fields.length);
    fields.forEach((f,k)=>{dummy.scale.set(1,1,1);dummy.rotation.set(-Math.PI/2,0,0);dummy.position.set(INK_X+f.x,0.18,f.z);dummy.updateMatrix();wtr.setMatrixAt(k,dummy.matrix);
      dummy.rotation.set(0,0,0);dummy.position.y=0.04;dummy.updateMatrix();bank.setMatrixAt(k,dummy.matrix);});wtr.receiveShadow=true;INK.g.add(bank,wtr);
    const rice=[],rr=mulberry(5);for(const f of fields)for(let i=0;i<34;i++)rice.push({x:f.x-6.5+(i%6)*2.6,z:f.z-5+Math.floor(i/6)*2.1+rr()*0.2});
    const rm=new THREE.InstancedMesh(new THREE.ConeGeometry(0.22,0.7,5),itm('#6fae4a'),rice.length);rice.forEach((e,k)=>{dummy.rotation.set(0,0,0);dummy.scale.set(1,1,1);dummy.position.set(INK_X+e.x,0.5,e.z);dummy.updateMatrix();rm.setMatrixAt(k,dummy.matrix);});INK.g.add(rm);
    const lane=new THREE.Mesh(new THREE.PlaneGeometry(240,5),tm('#b8ad98',{polygonOffset:true,polygonOffsetFactor:-1}));lane.rotation.x=-Math.PI/2;add(lane,30,0.08,158);
    for(let x=-183;x<=150;x+=26){add(Mi(new THREE.CylinderGeometry(0.12,0.14,8,6),tm('#8a7a62')),x,4,154.5);add(Mi(new THREE.BoxGeometry(0.12,0.12,1.6),tm('#8a7a62')),x,7.5,154.5);}}
  // the summit: the car park, a tea house, the observation deck with a roof and a telescope
  { const lot=new THREE.Mesh(new THREE.PlaneGeometry(PARK.x1-PARK.x0,PARK.z1-PARK.z0),tmap(canvasTex(128,64,(g,w,h)=>{g.fillStyle='#606266';g.fillRect(0,0,w,h);g.fillStyle='#e8e8e2';for(let x=6;x<w;x+=14)g.fillRect(x,4,2,18);}),{polygonOffset:true,polygonOffsetFactor:-2}));
    lot.rotation.x=-Math.PI/2;add(lot,(PARK.x0+PARK.x1)/2,INK_TOP+0.05,(PARK.z0+PARK.z1)/2);lot.receiveShadow=true;
    const tea=Mi(new THREE.BoxGeometry(9,3.2,6),tm('#a0784e'),0.03);add(tea,-72,INK_TOP+1.6,-160);
    const tr=Mi(new THREE.CylinderGeometry(0.01,6,2.4,4,1),tm('#3d4250'),0.03);tr.rotation.y=Math.PI/4;tr.scale.set(1.2,1,0.85);add(tr,-72,INK_TOP+4.4,-160);
    const nr=new THREE.Mesh(new THREE.PlaneGeometry(3,0.9),tmap(canvasTex(128,40,(g,w,h)=>{g.fillStyle='#2e4a7a';g.fillRect(0,0,w,h);g.fillStyle='#fff';g.font=signFont(24,true);g.textAlign='center';g.fillText('峠の茶屋',w/2,28);}),{side:THREE.DoubleSide}));
    add(nr,-72,INK_TOP+2.6,-156.95);collide(INK_X-76.5,INK_X-67.5,-163,-157,'bld');
    for(const x of [-79,-65]){const b=benchMesh();add(b,x,INK_TOP,-155.4);}
    const wood=tm('#8a6a4c'),D=DECK;
    const fl=Mi(new THREE.BoxGeometry(D.x1-D.x0,0.25,D.z1-D.z0),wood,0.02);add(fl,(D.x0+D.x1)/2,D.h-0.12,(D.z0+D.z1)/2);
    for(const x of [D.x0+0.4,D.x1-0.4])for(const z of [D.z0+0.4,D.z1-0.4]){const y0=inkY(x,z)-0.5;add(Mi(new THREE.BoxGeometry(0.35,D.h-y0+3.4,0.35),wood,0.01),x,(y0+D.h+3.4)/2,z);}
    const rp=Mi(new THREE.BoxGeometry(RAMP.x1-RAMP.x0+0.5,0.2,RAMP.z1-RAMP.z0),wood,0.02);rp.rotation.z=Math.atan2(D.h-INK_TOP,RAMP.x1-RAMP.x0);add(rp,(RAMP.x0+RAMP.x1)/2,(INK_TOP+D.h)/2-0.05,(RAMP.z0+RAMP.z1)/2);
    for(const [x0,x1,z0,z1] of [[D.x0,D.x1,D.z0,D.z0],[D.x0,D.x1,D.z1,D.z1],[D.x1,D.x1,D.z0,D.z1],[D.x0,D.x0,D.z0,RAMP.z0],[D.x0,D.x0,RAMP.z1,D.z1]]){
      const L=Math.hypot(x1-x0,z1-z0),m=Mi(new THREE.BoxGeometry(x1===x0?0.08:L,0.9,x1===x0?L:0.08),wood,0.01);add(m,(x0+x1)/2,D.h+0.45,(z0+z1)/2);
      collide(INK_X+Math.min(x0,x1)-0.1,INK_X+Math.max(x0,x1)+0.1,Math.min(z0,z1)-0.1,Math.max(z0,z1)+0.1,'wall',D.h+1);}
    const rf=Mi(new THREE.CylinderGeometry(0.01,5.2,1.8,4,1),tm('#6b3a2e'),0.03);rf.rotation.y=Math.PI/4;rf.scale.set(1.15,0.8,1.15);add(rf,(D.x0+D.x1)/2,D.h+4.1,(D.z0+D.z1)/2);
    const sc=new THREE.Group();sc.position.set(INK_X+6,D.h,-140);sc.rotation.y=Math.PI*0.75;INK.g.add(sc);
    sc.add(Mi(new THREE.CylinderGeometry(0.06,0.08,1.1,8),tm('#555'),0.01).translateY(0.55));const tb=Mi(new THREE.CylinderGeometry(0.12,0.09,0.7,10),tm('#2e6ab8'),0.012);tb.rotation.x=Math.PI/2-0.15;tb.position.y=1.2;sc.add(tb);
    INK.scope={x:INK_X+6,z:-140};}
  // bus stops at the foot and at the top
  INK.bus=[{x:-66,z:132,to:1,name:'山頂行き'},{x:-66,z:-129,to:0,name:'ふもと行き'}];
  for(const b of INK.bus){const y=inkY(b.x,b.z);add(Mi(new THREE.CylinderGeometry(0.05,0.05,2.2,6),tm('#ccc')),b.x,y+1.1,b.z);
    const t=new THREE.Mesh(new THREE.CircleGeometry(0.35,20),tmap(canvasTex(64,64,(g,w,h)=>{g.fillStyle='#e8452f';g.beginPath();g.arc(32,32,31,0,7);g.fill();g.fillStyle='#fff';g.font=signFont(22,true);g.textAlign='center';g.textBaseline='middle';g.fillText('バス',32,33);}),{side:THREE.DoubleSide}));
    add(t,b.x,y+2.3,b.z);t.rotation.y=Math.PI/2;}
  // the map in the corner
  { const m=INK.map;m.width=m.height=INK_R*2;const g=m.getContext('2d');g.fillStyle='#bcd9a8';g.fillRect(0,0,m.width,m.height);
    g.fillStyle='#9cc3b8';for(const [x0,x1,z0,z1] of INK_FIELDS)g.fillRect(x0+INK_R,z0+INK_R,x1-x0,z1-z0);
    g.fillStyle='#8fb07a';g.beginPath();g.ellipse(INK_R,INK_R-60,130,110,0,0,7);g.fill();
    g.strokeStyle='#fff';g.lineWidth=6;g.beginPath();ROAD.forEach((p,i)=>i?g.lineTo(p.x+INK_R,p.z+INK_R):g.moveTo(p.x+INK_R,p.z+INK_R));g.stroke();
    g.fillStyle='#606266';g.fillRect(PARK.x0+INK_R,PARK.z0+INK_R,PARK.x1-PARK.x0,PARK.z1-PARK.z0);g.fillStyle='#a88a64';g.fillRect(DECK.x0+INK_R,DECK.z0+INK_R,DECK.x1-DECK.x0,DECK.z1-DECK.z0);
    g.strokeStyle='#5a6b72';g.setLineDash([4,3]);g.lineWidth=2;g.beginPath();g.moveTo(0,INK_TRACK+INK_R);g.lineTo(INK_R-8,INK_TRACK+INK_R);g.stroke();g.setLineDash([]);}}

/* ---------- the country tram: two cars like the town's that bring you out of the tunnel to 山のふもと and take you back ---------- */
const INK_STOP={id:'inaka',name:'山のふもと'},INK_STOPX=-53.7;
const INKT={x:INK_STOPX,v:0,wait:1e9,at:INK_STOP,door:1,mode:'idle',cars:[],platS:()=>1,seatS:()=>-1,dir:1};
for(let k=0;k<2;k++){const car=makeTramCar(k);INK.g.add(car.g);INKT.cars.push(car.g);car.g.userData.car=car;
  const h=makeHuman({skin:'#e0b48e',hair:'#2b2520',style:'short',cap:'#24323a',shirt:'#dfe5ea',sleeves:'long',bottom:'pants',bottomCol:'#24323a',shoe:'#1d1d1d'});
  h.g.position.set(car.c*5.2,0.9,-0.45);h.g.rotation.y=car.c*Math.PI/2;car.g.add(h.g);car.driver=h;}
{ const car=INKT.cars[0].userData.car,h=makeHuman({skin:'#e3b088',hair:'#e2ded8',style:'grey',shirt:'#8aa08a',sleeves:'long',bottom:'long',bottomCol:'#5a4a3a',bend:0.25});
  h.g.position.set(-1.4,0.9,0.98);h.g.rotation.y=Math.PI;INKT.cars[0].add(h.g);car.folk.push({h,s:1,x:-1.4});}
function inkTrainMove(dt){const T=INKT,v0=T.v;
  if(T.mode==='arrive'){const d=INK_STOPX-T.x,tgt=Math.min(8,Math.sqrt(2*1.1*Math.max(0,d))+0.25);T.v+=clamp(tgt-T.v,-2.4*dt,0.9*dt);
    if(T.v*dt>=d-0.005){T.x=INK_STOPX;T.v=0;T.mode='idle';T.at=INK_STOP;T.wait=1e9;if(RIDE.on)toast('終点、山のふもと です');}else T.x+=T.v*dt;}
  else if(T.mode==='depart'){T.wait-=dt;if(T.wait<=0){T.at=null;T.v=Math.min(8,T.v+0.9*dt);T.x-=T.v*dt;if(T.x<-236){if(RIDE.on&&RIDE.train===T)inkToTown();else{T.mode='idle';T.x=INK_STOPX;T.at=INK_STOP;T.wait=1e9;T.v=0;}}}}
  T.acc=(T.v-v0)/Math.max(dt,1e-3)*(T.mode==='depart'?-1:1);
  T.door+=((T.at&&T.mode==='idle'?1:0)-T.door)*Math.min(1,dt*2.5);
  T.cars.forEach((g,k)=>{const x=T.x-k*12.6;g.position.set(INK_X+x,0.2,INK_TRACK);g.rotation.y=0;const car=g.userData.car;
    for(const d of car.doors)d.g.position.x=d.x0+d.open*smooth(T.door);for(const w of car.wheels)w.rotation.y+=T.v*dt/0.3;
    if(AREA!=='inaka')return;for(const p of car.straps)p.rotation.z+=(clamp(T.acc*0.12,-0.35,0.35)-p.rotation.z)*Math.min(1,dt*3);
    for(const f of car.folk)poseHuman(f.h,'sit',dt,{});poseHuman(car.driver,'stand',dt,{});for(const a of car.driver.arms){a.sh.rotation.x=-0.75;a.el.rotation.x=-0.8;}});}
// through the tunnels: the town tram's east end comes out here, and this one's west end comes out at the town
function townToInk(){const f=$('fade');f.style.opacity=1;
  setTimeout(()=>{Object.assign(INKT,{x:-240,v:6,mode:'arrive',at:null,wait:0});RIDE.train=INKT;RIDE.s=INKT.seatS();RIDE.x=pickSeat(INKT,RIDE.car,RIDE.s,RIDE.x);setArea('inaka');camInit=false;toast('トンネルを抜けると、山と田んぼが広がっていた');
    setTimeout(()=>{f.style.opacity=0;},250);},850);}
function inkToTown(){const f=$('fade');f.style.opacity=1;
  setTimeout(()=>{Object.assign(TRAM,{x:TRAM_X1-12,dir:-1,v:6,wait:0,at:null,left:null});RIDE.train=TRAM;RIDE.s=TRAM.seatS();RIDE.x=pickSeat(TRAM,RIDE.car,RIDE.s,RIDE.x);Object.assign(INKT,{mode:'idle',x:INK_STOPX,v:0,at:INK_STOP,wait:1e9});
    setArea('town');camInit=false;toast('次は　ひがし浜　です');setTimeout(()=>{f.style.opacity=0;},250);},850);}
// the town and the country are never both shown
function setArea(a){if(a===AREA)return;AREA=a;const ink=a==='inaka';INK.g.visible=ink;
  for(const o of world.children){if(o===player.g)continue;if(ink){o.userData.vis=o.visible;o.visible=false;}else if(o.userData.vis!==undefined){o.visible=o.userData.vis;delete o.userData.vis;}}}
function updateInaka(dt){const want=P.x>INK_X-600?'inaka':'town';if(want!==AREA&&!(RIDE.on))setArea(want);inkTrainMove(dt);updateTouge(dt);}
function inkNear(){if(AREA!=='inaka')return null;let best=null;
  for(const b of INK.bus){const d=Math.hypot(P.x-INK_X-b.x,P.z-b.z);if(d<2.6&&(!best||d<best.d))best={kind:'bus',b,d,label:`乗る　バス（${b.name}・100円）`,verb:'乗る'};}
  const d=Math.hypot(P.x-INK.scope.x,P.z-INK.scope.z);if(d<2.2&&P.y>DECK.h-0.5)best={kind:'scope',d,label:'のぞく　望遠鏡',verb:'のぞく'};
  return best;}
function inkAct(o){if(o.kind==='scope'){say('',['望遠鏡をのぞくと、はるか遠くに海が光っている。','あの光の下に、海街があるんだ……。']);return;}
  const to=INK.bus[o.b.to],f=$('fade');f.style.opacity=1;if(SAVE.money>=100){SAVE.money-=100;renderHUD();}
  setTimeout(()=>{P.x=INK_X+to.x+2;P.z=to.z+(o.b.to?2:-2);P.y=inkG(P.x,P.z);P.v=0;P.yaw=o.b.to?0:Math.PI;camInit=false;
    if(!P.foot){P.foot=true;P.carry='hand';}f.style.opacity=0;toast(o.b.to?'バスにゆられて、山のてっぺんに着いた':'バスで山をおりた');},900);}
function inkPlace(){const lx=P.x-INK_X,lz=P.z;
  if(lx>DECK.x0-2&&lx<DECK.x1+2&&lz>DECK.z0-2&&lz<DECK.z1+2&&P.y>DECK.h-1)return'山頂の展望台';
  if(lx>PARK.x0-6&&lx<PARK.x1+6&&lz>PARK.z0-14&&lz<PARK.z1+4)return'いろは峠 山頂';
  if(Math.abs(lz-INK_TRACK)<10&&lx>-90&&lx<-20)return'山のふもと駅';
  if(lz<55)return'いろは坂';return'山のふもと';}

/* ---------- the racers of いろは峠 and the downhill battles ---------- */
function makeRacerCar(col,wing){const g=new THREE.Group(),p=tm(col),dark=tm('#1d1f22'),gl=tm('#2b3a44');
  const B=(w,h,d,m,x,y,z,ol)=>{const o=new THREE.Mesh(new THREE.BoxGeometry(w,h,d),m);o.position.set(x,y,z);o.castShadow=true;if(ol)outline(o,ol);g.add(o);return o;};
  B(1.76,0.5,4.3,p,0,0.55,0,0.03);const cab=B(1.5,0.46,2.0,p,0,1.02,-0.25,0.02);B(1.52,0.36,1.7,gl,0,1.02,-0.2);
  B(1.6,0.06,0.3,dark,0,0.66,2.12);if(wing){B(1.7,0.06,0.42,dark,0,1.18,-2.0);for(const x of [-0.6,0.6])B(0.06,0.32,0.2,dark,x,0.98,-2.0);}
  for(const x of [-0.55,0.55]){const l=new THREE.Mesh(new THREE.BoxGeometry(0.42,0.14,0.04),new THREE.MeshBasicMaterial({color:'#fff6d8'}));l.position.set(x,0.62,2.16);g.add(l);
    const t=new THREE.Mesh(new THREE.BoxGeometry(0.4,0.12,0.04),new THREE.MeshBasicMaterial({color:'#c8372d'}));t.position.set(x,0.66,-2.16);g.add(t);}
  const wheels=[];for(const x of [-0.82,0.82])for(const z of [-1.35,1.35]){const w=new THREE.Mesh(new THREE.CylinderGeometry(0.33,0.33,0.24,14),dark);w.rotation.z=Math.PI/2;w.position.set(x,0.33,z);g.add(w);wheels.push(w);}
  g.userData.wheels=wheels;return g;}
const RACERS=[
  {id:'r_kenji',name:'ケンジ',car:'#f2f2ee',wing:false,o:{skin:'#e3b088',hair:'#d9a050',style:'short',shirt:'#2e5fa8',sleeves:'short',bottom:'pants',bottomCol:'#3a3a40',shoe:'#f2f2ee'},vtop:12.5,lat:3.6,acc:2.2,prize:500},
  {id:'r_madoka',name:'マドカ',car:'#d23b33',wing:true,o:{skin:'#f1cdb0',hair:'#1c1a1a',style:'long',shirt:'#1d1f22',sleeves:'long',bottom:'pants',bottomCol:'#2b2f36',shoe:'#d23b33'},vtop:14.5,lat:4.6,acc:2.8,prize:1000},
  {id:'r_gen',name:'ゲンさん',car:'#1d1f22',wing:true,o:{skin:'#d9a987',hair:'#2b2520',style:'short',cap:'#c8372d',shirt:'#f2f2ee',sleeves:'short',bottom:'pants',bottomCol:'#3a4a6a',shoe:'#1d1d1d'},vtop:16.5,lat:5.6,acc:3.4,prize:2000}];
RACERS.forEach((r,k)=>{const x=-74+k*8,z=-136;r.home={x,z};const c=makeRacerCar(r.car,r.wing);c.position.set(INK_X+x,INK_TOP+0.02,z-4.5);INK.g.add(c);r.parked=c;
  collide(INK_X+x-1,INK_X+x+1,z-6.8,z-2.2,'car');
  const n=placeNPC(r.id,r.o,INK_X+x+1.6,z-1.2,0.3,'stand',r.name,['この峠は、夜がいちばん速く走れるんだ。']);INK.g.add(n.h.g);});
// the battles: ['touge', 1|2|3] puts you and the car side by side at the top; the first down to the gate at the foot wins
const TOUGE={on:false,res:null};
const INK_START=ROAD.length-6,INK_FIN=ROAD.findIndex(p=>p.z<=60);   // the start just below the car park, the gate near the foot
function speedPlan(R){const v=ROAD.map((p,i)=>{if(!p.curve)return R.vtop;return Math.min(R.vtop,Math.sqrt(R.lat*10));});
  for(let i=1;i<v.length;i++)v[i]=Math.min(v[i],Math.sqrt(v[i-1]*v[i-1]+2*6.5));return v;}   // going down the road means going down the list: brake in time for the bend below
function tougeP(lv){return new Promise(res=>{const R=RACERS[lv-1];ST.actor=null;talkNpc=null;
  const s=ROAD[INK_START],q=ROAD[INK_START-4],yaw=Math.atan2(q.x-s.x,q.z-s.z),sx=Math.cos(yaw),sz=-Math.sin(yaw);
  P.x=INK_X+s.x-sx*1.7;P.z=s.z-sz*1.7;P.yaw=yaw;P.v=0;P.y=inkG(P.x,P.z);rideNow();camInit=false;
  if(!TOUGE.car){TOUGE.car=new THREE.Group();INK.g.add(TOUGE.car);TOUGE.gate=new THREE.Group();INK.g.add(TOUGE.gate);
    const p=ROAD[INK_FIN],y=p.h;for(const sd of [-1,1])TOUGE.gate.add(new THREE.Mesh(new THREE.CylinderGeometry(0.12,0.12,5,8),tm('#ddd')).translateX(INK_X+p.x+sd*4.6).translateY(y+2.5).translateZ(p.z));
    const bn=new THREE.Mesh(new THREE.PlaneGeometry(9.4,1.1),tmap(canvasTex(256,32,(g,w,h)=>{for(let i=0;i<16;i++){g.fillStyle=i%2?'#1d1d1d':'#f2f2ee';g.fillRect(i*16,0,16,h);}g.fillStyle='#c8372d';g.fillRect(w/2-50,0,100,h);g.fillStyle='#fff';g.font=signFont(22,true);g.textAlign='center';g.fillText('GOAL',w/2,24);}),{side:THREE.DoubleSide}));
    bn.position.set(INK_X+p.x,y+4.6,p.z);TOUGE.gate.add(bn);}
  TOUGE.car.clear();const body=makeRacerCar(R.car,R.wing);TOUGE.car.add(body);TOUGE.body=body;TOUGE.car.visible=TOUGE.gate.visible=true;R.parked.visible=false;
  Object.assign(TOUGE,{on:false,res,R,plan:speedPlan(R),ci:INK_START,cf:0,cv:0,t:0,count:3.4,pi:INK_START,lane:1.7,drift:0});});}
const _tq=new THREE.Vector3();
function nearestRoad(lx,lz,i0){let bi=i0,bd=1e9;for(let i=Math.max(0,i0-60);i<Math.min(ROAD.length,i0+60);i++){const d=(ROAD[i].x-lx)**2+(ROAD[i].z-lz)**2;if(d<bd){bd=d;bi=i;}}return{i:bi,d:Math.sqrt(bd)};}
function updateTouge(dt){const T=TOUGE;if(!T.res)return;const tr=$('tracker'),R=T.R;tr.hidden=false;
  // the car: along the road at its planned speed, in its lane, sliding wide through the hairpins
  const placeCar=()=>{const i=Math.max(1,Math.min(ROAD.length-1,T.ci)),p=ROAD[i],q=ROAD[i-1],tx=q.x-p.x,tz=q.z-p.z,L=Math.hypot(tx,tz)||1,f=T.cf;
    const x=lerp(p.x,q.x,f)+tz/L*T.lane,z=lerp(p.z,q.z,f)-tx/L*T.lane,h=lerp(p.h,q.h,f);T.car.position.set(INK_X+x,h+0.02,z);
    T.car.rotation.set(Math.atan2(p.h-q.h,1),Math.atan2(tx,tz)+T.drift,0,'YXZ');for(const w of T.body.userData.wheels)w.rotation.x+=T.cv*dt/0.33;};
  if(!T.on){T.count-=dt;placeCar();tr.innerHTML=`<b>峠バトル vs ${R.name}</b><span class="step">ふもとのゴールまで、先に着いたほうの勝ち。道を飛び降りる近道もあり</span><span class="meter">${T.count>0.2?Math.ceil(T.count-0.2):'スタート！'}</span>`;
    if(T.count<=0.2){T.on=true;toast('スタート！',true);}return;}
  T.t+=dt;
  const want=T.plan[T.ci]||R.vtop;T.cv+=clamp(want-T.cv,-6.5*dt,R.acc*dt);let mv=T.cv*dt;
  while(mv>0&&T.ci>INK_FIN){const seg=Math.hypot(ROAD[T.ci].x-ROAD[T.ci-1].x,ROAD[T.ci].z-ROAD[T.ci-1].z),left=(1-T.cf)*seg;if(mv<left){T.cf+=mv/seg;mv=0;}else{mv-=left;T.ci--;T.cf=0;}}
    const cu=ROAD[T.ci].curve,a=ROAD[T.ci],b=ROAD[Math.max(0,T.ci-1)],c=ROAD[Math.max(0,T.ci-2)];
  let dy=Math.atan2(c.x-b.x,c.z-b.z)-Math.atan2(b.x-a.x,b.z-a.z);dy=Math.atan2(Math.sin(dy),Math.cos(dy));
  T.drift+=((cu&&T.cv>5?0.5*Math.sign(dy):0)-T.drift)*Math.min(1,dt*3);   // the tail steps out through the hairpins
  placeCar();if(cu&&T.cv>6&&Math.random()<dt*30)sparks(T.car.position.clone().add(_tq.set(0,0.3,0)),1,'#e8e8e8',1.5,0.18);
  // her: how far down the road she has got, and the gap
  const n=nearestRoad(P.x-INK_X,P.z,T.pi);if(n.d<14)T.pi=n.i;
  const gap=Math.round((ROAD[T.ci].s-ROAD[T.pi].s));
  tr.innerHTML=`<b>峠バトル vs ${R.name}</b><span class="step">ふもとのゴールへ。S でブレーキ、カーブは早めに</span><span class="meter">${gap>=0?`${R.name}より ${gap} m 前`:`${R.name}まで ${-gap} m`}　${T.t.toFixed(1)} 秒</span>`;
  const cd=T.car.position.distanceTo(_tq.set(P.x,P.y,P.z));if(cd<1.8&&!P.air){P.v*=0.6;P.bump=0.4;}
  const g=ROAD[INK_FIN],won=Math.hypot(P.x-INK_X-g.x,P.z-g.z)<5.5,lost=T.ci<=INK_FIN||T.t>240;
  if(won||lost){const r=T.res;T.res=null;T.on=false;tr.hidden=true;toast(won?'勝った！':`${R.name}が先にゴールした……`,true);(won?sfx.win:sfx.lose)();setTimeout(()=>{T.car.visible=T.gate.visible=false;R.parked.visible=true;},1500);r(won);}}

// talking to the racers: each takes you on once the one before is beaten; afterwards they will race you again for fun
RACERS.forEach((R,k)=>{const lv=k+1,key='touge'+lv,prev=k?'touge'+k:null,back=['warp',INK_X+R.home.x,R.home.z+2.6,Math.PI];
  const L=[[['say',R.id,'お、スケボーの子か。こんな山の上まで、よく来たな。','ここはいろは峠。おれたち走り屋が、下りの速さを競ってるんだ。'],'どうだ、おれと下りで勝負してみるか？ ふもとのゴールに、先に着いたほうの勝ちだ。',
      ['……マジかよ。ヘアピンで抜かれるなんて思わなかった。','次はマドカに挑んでみな。あいつの赤いのは速いぜ。'],['へへっ、まだまだだな。いつでも相手になるぜ。']],
    [['say',R.id,'ケンジに勝ったの？ スケボーで？ ……ふうん。'],'じゃあ、わたしとも走ってもらおうかな。手加減はしないよ。',
      ['うそ……。あの近道、ふつうは怖くて飛べないよ。','いちばん速いのはゲンさん。峠の主って呼ばれてる人。'],['ふふ、まだ甘いね。ヘアピンの手前でちゃんと減速しなきゃ。']],
    [['say',R.id,'マドカから聞いたよ。板一枚で、この峠を下りるお嬢さんがいるってな。'],'わしはこの峠を、三十年走ってきた。……一本、走ろうか。',
      ['……見事だ。いろは峠の新しい主は、お嬢さんだな。','また走りに来るといい。この山は、いつでも待っとる。'],['まだ若いな。だが、筋はいい。また来なさい。']]][k];
  EVENTS.push({id:'tg_'+lv,on:{talk:R.id},mark:true,once:false,when:{test:()=>!SAVE.flags[key]&&(!prev||SAVE.flags[prev])},script:[['cam','npc',R.id,3.4],L[0],
    ['ask',R.id,L[1],[['勝負する！',[['cam','off'],['touge',lv],['fade','out'],back,['fade','in'],['cam','npc',R.id,3.4],
        ['if',{test:()=>SAVE.flags.touge_win===1},[['say',R.id,...L[2]],['set',key],['money',R.prize]],[['say',R.id,...L[3]]]]]],
      ['また今度',[['say',R.id,'そうか。気が向いたら声をかけな。']]]]],['cam','off']]});
  EVENTS.push({id:'tg_'+lv+'_again',on:{talk:R.id},once:false,when:{test:()=>!!SAVE.flags[key]},script:[
    ['ask',R.id,'もう一本、走るか？',[['走る！',[['touge',lv],['fade','out'],back,['fade','in'],['if',{test:()=>SAVE.flags.touge_win===1},[['say',R.id,'やっぱり速いな。']],[['say',R.id,'今日はおれの勝ちだな。']]]]],['やめておく',[]]]]]});
  if(prev)EVENTS.push({id:'tg_'+lv+'_wait',on:{talk:R.id},once:false,when:{test:()=>!SAVE.flags[prev]},script:[['say',R.id,k===1?'わたしと走りたいなら、まずはケンジに勝ってからね。':'わしと走りたいなら、マドカに勝ってからだな。']]});});
