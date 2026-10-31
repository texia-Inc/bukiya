
/* ---------- the named shops ---------- */
function signFont(px,bold){return `${bold?900:700} ${px}px "Zen Maru Gothic", "Hiragino Maru Gothic ProN", sans-serif`;}
function bread(g,x,y,s,type){g.save();g.translate(x,y);
  if(type===0){g.fillStyle='#e9b44c';g.beginPath();g.ellipse(0,0,s,s*0.72,0,0,7);g.fill();g.strokeStyle='rgba(150,90,30,.5)';g.lineWidth=1.2;for(let k=-2;k<=2;k++){g.beginPath();g.moveTo(-s+2,k*s*0.28);g.lineTo(s-2,k*s*0.28);g.stroke();}}
  else if(type===1){g.fillStyle='#a8662f';g.beginPath();g.ellipse(0,0,s,s*0.7,0,0,7);g.fill();g.fillStyle='#3a2416';g.beginPath();g.arc(0,-s*0.15,s*0.12,0,7);g.fill();}
  else{g.fillStyle='#d99a4e';g.fillRect(-s*1.2,-s*0.6,s*2.4,s*1.2);g.fillStyle='#f3d9a8';g.fillRect(-s*1.2,-s*0.6,s*2.4,s*0.3);}
  g.restore();}
function namedFacade(b){const fl=b.floors,W=512,Hh=256*fl,id=b.id,r=mulberry(id.length*91);
  return canvasTex(W,Hh,(g,w,h)=>{g.fillStyle=b.wall;g.fillRect(0,0,w,h);g.fillStyle='rgba(0,0,0,.04)';for(let y=0;y<h;y+=10)g.fillRect(0,y,w,1);
    for(let f=1;f<fl;f++){const y0=h-(f+1)*256;for(let k=0;k<3;k++){const x=40+k*156;
        g.fillStyle='#f7f4ee';g.fillRect(x-5,y0+66,124,108);const gr=g.createLinearGradient(x,y0,x+114,y0+170);gr.addColorStop(0,'#62808f');gr.addColorStop(1,'#3d5463');g.fillStyle=gr;g.fillRect(x,y0+71,114,98);
        g.fillStyle='rgba(255,255,255,.25)';g.beginPath();g.moveTo(x+20,y0+169);g.lineTo(x+60,y0+71);g.lineTo(x+78,y0+71);g.lineTo(x+38,y0+169);g.fill();
        g.fillStyle=CURT[(k+id.length)%CURT.length];g.fillRect(x,y0+71,30,98);g.fillStyle='#dcd6cb';g.fillRect(x-10,y0+172,134,8);
        if(id==='hotel'){g.fillStyle='rgba(120,120,120,.6)';g.fillRect(x-8,y0+186,130,4);for(let xx=x-8;xx<x+122;xx+=10)g.fillRect(xx,y0+190,2,40);g.fillRect(x-8,y0+228,130,4);}}
      g.fillStyle='rgba(0,0,0,.08)';g.fillRect(0,y0,w,4);}
    const y0=h-256;
    // sign board
    g.fillStyle=b.accent;g.fillRect(14,y0+8,w-28,64);g.fillStyle='rgba(255,255,255,.16)';g.fillRect(14,y0+8,w-28,8);
    g.fillStyle='#fffaf0';g.font=signFont(40,true);g.textAlign='center';g.textBaseline='middle';g.fillText(b.sign,w/2,y0+42);
    g.font=signFont(13);g.fillStyle='rgba(255,250,240,.8)';g.fillText(b.sub,w/2,y0+64);
    // shop front
    const fy=y0+84,fh=172;
    g.fillStyle='#5a4535';g.fillRect(16,fy,w-32,fh);
    if(id==='yaoya'||id==='fish'){g.fillStyle='#2e2a26';g.fillRect(24,fy+8,w-48,fh-8);g.fillStyle='rgba(255,236,196,.35)';g.fillRect(24,fy+8,w-48,40);
      for(let k=0;k<30;k++){g.fillStyle=id==='yaoya'?pick(['#e8a23a','#d8402f','#5a9a3a','#f2d05a','#8a4a8a']):pick(['#c9d6dc','#9fb4c0','#e9ecef']);g.beginPath();g.arc(40+r()*(w-80),fy+70+r()*80,8+r()*8,0,7);g.fill();}}
    else{const gw=w-200;g.fillStyle='#e9e2d4';g.fillRect(24,fy+8,gw,fh-14);
      const gr=g.createLinearGradient(0,fy,0,fy+fh);gr.addColorStop(0,'#fff2d6');gr.addColorStop(1,'#e9c99a');g.fillStyle=gr;g.fillRect(30,fy+14,gw-12,fh-26);
      if(id==='bakery'){for(let s=0;s<3;s++){g.fillStyle='#8a6a4c';g.fillRect(36,fy+52+s*42,gw-24,5);for(let k=0;k<7;k++)bread(g,56+k*((gw-60)/7),fy+42+s*42,11,(k+s)%3);}}
      else if(id==='flower'){for(let k=0;k<60;k++){g.fillStyle=pick(['#e2584a','#f2c230','#f0a0b8','#ffffff','#a070d0','#4f9a5a','#3f8a4f']);g.beginPath();g.arc(40+r()*(gw-30),fy+40+r()*(fh-60),5+r()*9,0,7);g.fill();}}
      else if(id==='books'){for(let s=0;s<4;s++){g.fillStyle='#6b4a2e';g.fillRect(34,fy+48+s*30,gw-20,4);for(let x=38;x<gw;x+=7+r()*6){g.fillStyle=pick(['#8a3b2e','#24466e','#3f6b3a','#c9a43a','#5a4532','#e9e2d4']);g.fillRect(x,fy+22+s*30,6,26);}}}
      else if(id==='cafe'){g.fillStyle='rgba(120,70,40,.6)';g.fillRect(30,fy+110,gw-12,6);for(let k=0;k<3;k++){g.fillStyle='#fff3b0';g.beginPath();g.arc(70+k*90,fy+40,10,0,7);g.fill();g.fillStyle='rgba(255,240,180,.4)';g.beginPath();g.arc(70+k*90,fy+40,24,0,7);g.fill();}
        g.fillStyle='#7a3f2a';g.font=signFont(18,true);g.fillText('珈琲  ナポリタン  プリン',30+(gw-12)/2,fy+140);}
      else if(id==='dagashi'){for(let k=0;k<14;k++){const x=40+(k%7)*((gw-40)/7),y=fy+40+Math.floor(k/7)*60;g.fillStyle='rgba(220,240,250,.8)';g.fillRect(x,y,30,40);g.fillStyle=pick(['#e2584a','#f2c230','#4f9a5a','#3a7bd5','#f0a0b8']);g.fillRect(x+4,y+14,22,22);}}
      else if(id==='post'){g.fillStyle='#e9eef0';g.fillRect(30,fy+14,gw-12,fh-26);g.fillStyle='#c8372d';g.fillRect(30,fy+90,gw-12,10);g.fillStyle='#8a8f94';g.fillRect(40,fy+100,gw-32,40);}
      else if(id==='umi'){g.fillStyle='#8b6a4c';g.fillRect(30,fy+14,gw-12,fh-26);g.fillStyle='rgba(240,230,210,.7)';for(let x=36;x<gw+10;x+=12)g.fillRect(x,fy+18,6,fh-34);}
      else if(id==='hotel'){g.fillStyle='#e9eef0';g.fillRect(30,fy+14,gw-12,fh-26);g.fillStyle='#b8a27a';g.fillRect(50,fy+100,120,40);}
      // door
      const dx=w-160;g.fillStyle='#3d5463';g.fillRect(dx,fy+18,120,fh-18);g.fillStyle='rgba(255,255,255,.2)';g.fillRect(dx+10,fy+24,40,fh-30);g.fillStyle='#e7c46a';g.fillRect(dx+56,fy+90,8,20);
      if(id==='umi'||id==='cafe'||id==='bakery'){g.fillStyle=b.accent;g.fillRect(dx-6,fy+14,132,52);g.fillStyle='#fffaf0';g.font=signFont(18,true);g.fillText(id==='umi'?'営業中':id==='cafe'?'OPEN':'焼きたて',dx+60,fy+40);}
    }
  });}
const NAMED=[];
for(const id in SHOPS){const b=SHOPS[id],W=along(b),D=deep(b);
  const grp=new THREE.Group();grp.position.set(b.fx,b.base,b.fz);grp.rotation.y=b.yaw;world.add(grp);
  const side=tm(b.wall),front=tmap(namedFacade(b));
  const body=new THREE.Mesh(boxG,[side,side,roofTop,under,front,side]);body.scale.set(W,b.h,D);body.position.set(0,b.h/2,-D/2);body.receiveShadow=true;grp.add(body);
  boxEdges(b.cx,b.base,b.cz,b.yaw,W,b.h,D);
  if(b.floors<3){const roof=new THREE.Mesh(prism,tmap(kawara,{color:pick(['#46505e','#5d6470','#3a3d44','#6b4a2e'])}));const rh=1.4+D*0.12,sy=rh/1.5;
    roof.scale.set(W*1.1,sy,D*1.12/1.732);roof.position.set(0,b.h+sy*0.5,-D/2);roof.castShadow=true;grp.add(roof);}
  else{const par=new THREE.Mesh(boxG,tm('#d9d4cb'));par.scale.set(W+0.3,0.5,D+0.3);par.position.set(0,b.h+0.25,-D/2);grp.add(par);}
  const awn=new THREE.Mesh(new THREE.BoxGeometry(W*0.9,0.07,1.5),tmap(awnTex,{color:b.awn}));awn.position.set(0,2.98,0.66);awn.rotation.x=0.3;awn.castShadow=true;grp.add(awn);outline(awn,0.02);
  const toWorld=(u,v)=>{const X=[Math.cos(b.yaw),-Math.sin(b.yaw)],F=[Math.sin(b.yaw),Math.cos(b.yaw)];return[b.fx+X[0]*u+F[0]*v,b.fz+X[1]*u+F[1]*v];};
  b.door=toWorld(W/2-160/512*W+60/512*W,1.4);b.grp=grp;NAMED.push(b);
  b.local=(u,y,v)=>{const p=toWorld(u,v);return new THREE.Vector3(p[0],b.base+y,p[1]);};
}
/* what stands outside each shop */
function addAt(b,mesh,u,y,v,yaw){mesh.position.set(u,y,v);if(yaw)mesh.rotation.y=yaw;b.grp.add(mesh);return mesh;}
function M(geo,mat,ol){const m=new THREE.Mesh(geo,mat);m.castShadow=true;if(ol)outline(m,ol);return m;}
const chalk=(lines,bg)=>canvasTex(128,192,(g,w,h)=>{g.fillStyle='#6b4a2e';g.fillRect(0,0,w,h);g.fillStyle=bg||'#2f3a33';g.fillRect(8,8,w-16,h-16);
  g.fillStyle='#fffaf0';g.font=signFont(17,true);g.textAlign='center';lines.forEach((l,k)=>g.fillText(l,w/2,40+k*34));});
function aBoard(b,u,v,lines){const m=tmap(chalk(lines),{side:THREE.DoubleSide});for(const s of [-1,1]){const p=M(new THREE.PlaneGeometry(0.6,0.9),m,0);p.rotation.x=s*0.22;p.position.set(0,0.45,s*0.1);
    const g=new THREE.Group();g.add(p);addAt(b,g,u,0,v,s>0?0:Math.PI);}}
{ const B=SHOPS.bakery,W=along(B);aBoard(B,-W/2+1.2,1.6,['本日の','焼きたて','メロンパン','150円']);
  const tbl=M(new THREE.BoxGeometry(1.6,0.08,0.7),tm('#8a6a4c'),0.02);addAt(B,tbl,-W/2+3.4,0.85,1.0);
  for(const x of [-0.7,0.7])addAt(B,M(new THREE.BoxGeometry(0.06,0.85,0.6),tm('#6b4a2e')),-W/2+3.4+x,0.42,1.0);
  for(let k=0;k<3;k++){const bs=M(new THREE.CylinderGeometry(0.22,0.17,0.12,14),tm('#c9a06a'),0.012);addAt(B,bs,-W/2+2.9+k*0.5,0.95,1.0);
    for(let j=0;j<3;j++){const l=M(new THREE.SphereGeometry(0.075,10,8),tm(['#e9b44c','#a8662f','#d99a4e'][k]));l.scale.set(1.3,0.7,1);addAt(B,l,-W/2+2.85+k*0.5+(j-1)*0.08,1.03,1.0+(j%2)*0.06);}}
  const bench=benchMesh();addAt(B,bench,W/2-2.4,0,1.3);}
{ const B=SHOPS.flower,W=along(B);for(let t=0;t<3;t++){const st=M(new THREE.BoxGeometry(W*0.7,0.08,0.45),tm('#e9e2d4'),0.015);addAt(B,st,-0.5,0.35+t*0.35,0.5+t*-0.22+0.6);
    for(let k=0;k<6;k++){const x=-0.5-W*0.3+0.25+k*(W*0.7-0.5)/5;const bk=M(new THREE.CylinderGeometry(0.15,0.12,0.3,12),tm('#9aa6ae'));addAt(B,bk,x,0.54+t*0.35,0.6+t*-0.22+0.6);
      const fl=M(new THREE.SphereGeometry(0.2,10,8),tm(pick(['#e2584a','#f2c230','#f0a0b8','#ffffff','#a070d0','#ff8a3d'])));fl.scale.set(1,0.8,1);addAt(B,fl,x,0.82+t*0.35,0.6+t*-0.22+0.6);
      const lf=M(new THREE.SphereGeometry(0.16,8,6),tm('#4f9a5a'));addAt(B,lf,x+0.08,0.72+t*0.35,0.62+t*-0.22+0.6);}}}
{ const B=SHOPS.books,W=along(B);const spines=canvasTex(128,64,(g,w,h)=>{for(let x=0;x<w;x+=6+Math.floor(rnd()*5)){g.fillStyle=pick(['#8a3b2e','#24466e','#3f6b3a','#c9a43a','#5a4532','#e9e2d4','#6b4a8a']);g.fillRect(x,0,8,h);}});
  for(const u of [-W/2+1.2,-W/2+2.6]){const cart=M(new THREE.BoxGeometry(1.1,0.9,0.55),[tm('#7a5638'),tm('#7a5638'),tmap(spines),tm('#7a5638'),tmap(spines),tm('#7a5638')],0.02);addAt(B,cart,u,0.45,0.9);}
  aBoard(B,W/2-2.6,1.6,['古本','100円から','どうぞ','ごゆっくり']);}
{ const B=SHOPS.cafe,W=along(B);for(const u of [-W/2+1.6,-W/2+4.2]){const t=new THREE.Group();
    t.add(M(new THREE.CylinderGeometry(0.42,0.42,0.05,18),tm('#f2f2ee'),0.012).translateY(0.74));t.add(M(new THREE.CylinderGeometry(0.04,0.04,0.74,8),tm('#555')).translateY(0.37));
    t.add(M(new THREE.CylinderGeometry(0.03,0.03,2.3,8),tm('#ddd')).translateY(1.15));
    const um=M(new THREE.ConeGeometry(1.25,0.5,10,1,true),tmap(canvasTex(128,32,(g,w,h)=>{for(let k=0;k<10;k++){g.fillStyle=k%2?'#fffaf0':'#2f6b8a';g.fillRect(k*w/10,0,w/10,h);}}),{side:THREE.DoubleSide}),0);um.position.y=2.25;t.add(um);
    for(const a of [0,Math.PI]){const ch=M(new THREE.BoxGeometry(0.4,0.05,0.4),tm('#7a3f2a'),0.01);ch.position.set(Math.sin(a)*0.75,0.45,Math.cos(a)*0.75);t.add(ch);
      const bk=M(new THREE.BoxGeometry(0.4,0.45,0.04),tm('#7a3f2a'),0.01);bk.position.set(Math.sin(a)*0.95,0.7,Math.cos(a)*0.95);bk.rotation.y=a;t.add(bk);}
    addAt(B,t,u,0,1.9);collide(...(()=>{const p=B.local(u,0,1.9);return[p.x-0.5,p.x+0.5,p.z-0.5,p.z+0.5];})(),'prop');}
  aBoard(B,W/2-1.0,1.5,['本日の','コーヒー','400円','']);}
{ const B=SHOPS.dagashi,W=along(B);for(let k=0;k<3;k++){const g=new THREE.Group();g.add(M(new THREE.BoxGeometry(0.42,0.6,0.38),tm(['#e2584a','#3a7bd5','#f2c230'][k]),0.012).translateY(0.3));
    const dm=M(new THREE.SphereGeometry(0.2,14,10,0,TAU,0,Math.PI/2),tm('#dff1fa',{transparent:true,opacity:0.7}));dm.position.y=0.6;g.add(dm);
    for(let j=0;j<5;j++){const c=new THREE.Mesh(new THREE.SphereGeometry(0.045,8,6),tm(pick(['#e2584a','#f2c230','#4f9a5a','#f0a0b8','#ffffff'])));c.position.set((j-2)*0.06,0.66,(j%2)*0.05);g.add(c);}
addAt(B,g,-W/2+0.6+k*0.5,0,1.0);}
  B.gacha=B.local(-W/2+1.1,0,1.0);   // the capsule machines are the gacha
  { const sg=new THREE.Mesh(new THREE.PlaneGeometry(1.3,0.42),tmap(canvasTex(256,84,(c,w,h)=>{c.fillStyle='#f2c230';c.fillRect(0,0,w,h);c.fillStyle='#c8372d';c.fillRect(0,h-12,w,12);
      c.fillStyle='#3a2416';c.font=signFont(34,true);c.textAlign='center';c.textBaseline='middle';c.fillText('ガチャ 100円',w/2,h/2-4);})));
    const pole=M(new THREE.BoxGeometry(0.05,1.25,0.05),tm('#7a5638'),0.01);addAt(B,pole,-W/2+1.1,0.62,1.32);addAt(B,sg,-W/2+1.1,1.32,1.34);}
  const bench=benchMesh('#c8372d');addAt(B,bench,W/2-1.8,0,1.2);
  const ice=M(new THREE.BoxGeometry(1.0,0.75,0.6),tm('#f2f2ee'),0.015);addAt(B,ice,0.4,0.38,1.0);}
{ const B=SHOPS.yaoya,W=along(B);for(let k=0;k<4;k++){const g=new THREE.Group();const cr=M(new THREE.BoxGeometry(0.7,0.25,0.5),tm('#b98f6a'),0.012);cr.position.y=0.62;cr.rotation.x=-0.35;g.add(cr);
    const col=['#f29a2e','#d8402f','#5a9a3a','#f2d05a'][k];for(let j=0;j<8;j++){const f=new THREE.Mesh(new THREE.SphereGeometry(0.085,8,6),tm(col));f.position.set(-0.24+(j%4)*0.16,0.78+(j>3?0.06:0),-0.08+(j>3?-0.08:0.08));g.add(f);}
    g.add(M(new THREE.BoxGeometry(0.7,0.55,0.08),tm('#8a6a4c')).translateY(0.27).translateZ(0.2));addAt(B,g,-W/2+0.8+k*0.85,0,0.9);}}
{ const B=SHOPS.fish,W=along(B);for(let k=0;k<2;k++){const g=new THREE.Group();g.add(M(new THREE.BoxGeometry(1.6,0.12,0.8),tm('#dfe8ee'),0.012).translateY(0.85));
    g.add(new THREE.Mesh(new THREE.BoxGeometry(1.6,0.85,0.06),tm('#2e5fa8')).translateY(0.42).translateZ(0.38));
    for(let j=0;j<6;j++){const f=new THREE.Mesh(new THREE.SphereGeometry(0.1,10,6),tm('#b9c7cf'));f.scale.set(2.6,0.45,0.9);f.position.set(-0.55+(j%3)*0.55,0.95,-0.18+(j>2?0.32:0));g.add(f);}
    addAt(B,g,-W/2+1.3+k*1.9,0,1.0);}}
{ const B=SHOPS.post;const p=postBox();addAt(B,p,-along(B)/2+1.0,0,1.2);}
{ const B=SHOPS.umi,W=along(B);const nr=tmap(canvasTex(128,64,(g,w,h)=>{g.fillStyle='#24466e';g.fillRect(0,0,w,h);g.fillStyle='rgba(255,255,255,.2)';for(let x=0;x<w;x+=32)g.fillRect(x,0,2,h);
    g.fillStyle='#fffaf0';g.font=signFont(30,true);g.textAlign='center';g.textBaseline='middle';g.fillText('めし',w/2,h/2);}),{side:THREE.DoubleSide});
  addAt(B,M(new THREE.PlaneGeometry(1.5,0.75),nr,0),W/2-160/512*W+60/512*W,2.2,0.08);aBoard(B,-W/2+1.2,1.5,['しらす丼','850円','あじフライ','700円']);}
function benchMesh(cloth){const g=new THREE.Group(),wd=tm('#8a6a4c');for(let k=0;k<3;k++)g.add(M(new THREE.BoxGeometry(1.6,0.05,0.12),wd,0.01).translateY(0.45).translateZ(-0.15+k*0.15));
  for(const x of [-0.7,0.7])g.add(M(new THREE.BoxGeometry(0.06,0.45,0.42),tm('#5a5a5a')).translateY(0.22).translateX(x));
  if(cloth){const c=M(new THREE.BoxGeometry(1.62,0.03,0.48),tm(cloth));c.position.y=0.49;g.add(c);}
  else for(let k=0;k<2;k++)g.add(M(new THREE.BoxGeometry(1.6,0.12,0.04),wd,0.01).translateY(0.72+k*0.16).translateZ(-0.24));
  return g;}
function postBox(){const g=new THREE.Group(),red=tm('#d23a2c');g.add(M(new THREE.CylinderGeometry(0.24,0.24,1.05,18),red,0.02).translateY(0.62));
  const top=M(new THREE.SphereGeometry(0.24,18,8,0,TAU,0,Math.PI/2),red,0.02);top.position.y=1.15;g.add(top);
  g.add(new THREE.Mesh(new THREE.BoxGeometry(0.22,0.04,0.06),tm('#2b2520')).translateY(0.95).translateZ(0.23));
  g.add(M(new THREE.CylinderGeometry(0.28,0.3,0.1,18),tm('#3a3a3a')).translateY(0.05));
  const pl=new THREE.Mesh(new THREE.PlaneGeometry(0.2,0.2),tmap(canvasTex(32,32,(c,w,h)=>{c.fillStyle='#fff';c.fillRect(0,0,w,h);c.fillStyle='#d23a2c';c.font='bold 24px sans-serif';c.textAlign='center';c.textBaseline='middle';c.fillText('〒',w/2,h/2+1);})));
  pl.position.set(0,0.7,0.245);g.add(pl);return g;}

/* ---------- street furniture ---------- */
const POLES=[],WIRES=[];
function sag(a,b,dip){let prev=a;for(let k=1;k<=6;k++){const t=k/6,q=[lerp(a[0],b[0],t),lerp(a[1],b[1],t)-Math.sin(Math.PI*t)*dip,lerp(a[2],b[2],t)];WIRES.push(...prev,...q);prev=q;}}
function nearAnyCross(S,t,m){return crossings(S).some(o=>Math.abs(t-o.c)<o.w/2+o.sw+m)||(S.ax==='z'&&Math.abs(t-TRAM_Z)<6);}
function nearDoor(x,z){for(const b of NAMED){if(Math.hypot(x-b.door[0],z-b.door[1])<3.2)return true;}return false;}
for(const S of STREETS){if(S.id==='coast')continue;
  for(const side of [-1,1]){let prev=null;
    for(let t=S.a+8+(side>0?13:0);t<S.b-4;t+=26){
      if(nearAnyCross(S,t,2)){prev=null;continue;}
      const off=side*(S.w/2+S.sw+0.25),x=S.ax==='z'?S.c+off:t,z=S.ax==='z'?t:S.c+off;
      if(nearDoor(x,z)){prev=null;continue;}
      const y0=G(x,z);POLES.push({x,z,y0,ax:S.ax,tr:rnd()<0.45,side});collide(x-0.25,x+0.25,z-0.25,z+0.25,'pole');
      const ac=S.ax==='z'?[1,0]:[0,1];
      const tops=[-0.75,0,0.75].map(o=>[x+ac[0]*o,y0+9.6,z+ac[1]*o]);
      if(prev)tops.forEach((p,j)=>sag(prev[j],p,0.5+j*0.1));
      if(rnd()<0.4){const tx=S.ax==='z'?S.c-off:x,tz=S.ax==='z'?z:S.c-off;sag([x,y0+8.8,z],[tx,y0+6.6,tz],0.3);}
      prev=tops;}}}
inst(new THREE.CylinderGeometry(0.15,0.2,10.6,10),tm('#a3a19b'),POLES,(e,d)=>{d.position.set(e.x,e.y0+5.3,e.z);},{cast:true,ol:0.03});
inst(new THREE.BoxGeometry(1.9,0.1,0.1),tm('#6d6a64'),POLES,(e,d)=>{d.position.set(e.x,e.y0+9.6,e.z);d.rotation.y=e.ax==='z'?0:Math.PI/2;},{ol:0.02});
inst(new THREE.BoxGeometry(1.3,0.1,0.1),tm('#6d6a64'),POLES,(e,d)=>{d.position.set(e.x,e.y0+8.7,e.z);d.rotation.y=e.ax==='z'?0:Math.PI/2;});
inst(new THREE.CylinderGeometry(0.3,0.3,0.9,12),tm('#8c8f92'),POLES.filter(p=>p.tr),(e,d)=>{d.position.set(e.x+(e.ax==='x'?0:e.side*0.42),e.y0+7.6,e.z+(e.ax==='x'?e.side*0.42:0));},{ol:0.02});
inst(new THREE.BoxGeometry(0.26,0.5,0.06),tmap(canvasTex(32,64,(g,w,h)=>{g.fillStyle='#f2f2ee';g.fillRect(0,0,w,h);g.fillStyle='#24466e';g.font='bold 12px sans-serif';g.textAlign='center';
  ['海','街','一','丁','目'].forEach((c,k)=>g.fillText(c,w/2,12+k*11));})),POLES.filter((p,k)=>k%3===0),(e,d)=>{d.position.set(e.x,e.y0+2.4,e.z);d.rotation.y=e.ax==='z'?(e.side>0?-Math.PI/2:Math.PI/2):(e.side>0?Math.PI:0);d.translateZ(0.2);});
// coast road lamps and sea-front pines
const LAMPS=[];for(let x=-290;x<=290;x+=22){if(Math.abs(x)<9||Math.abs(x+80)<5||Math.abs(x-40)<5)continue;LAMPS.push({x,z:COAST_Z+4.5+2.2-0.3});}
inst(new THREE.CylinderGeometry(0.08,0.1,6,8),tm('#3a5a66'),LAMPS,(e,d)=>{d.position.set(e.x,3,e.z);},{ol:0.02});
inst(new THREE.BoxGeometry(0.1,0.1,1.4),tm('#3a5a66'),LAMPS,(e,d)=>{d.position.set(e.x,6,e.z-0.65);});
inst(new THREE.SphereGeometry(0.22,10,8,0,TAU,0,Math.PI/2),tm('#f2f2ee'),LAMPS,(e,d)=>{d.position.set(e.x,5.85,e.z-1.3);d.rotation.x=Math.PI;});
LAMPS.forEach(e=>collide(e.x-0.15,e.x+0.15,e.z-0.15,e.z+0.15,'pole'));
const PINES=[];for(let x=-290;x<=290;x+=13+rnd()*9){if(Math.abs(x+80)<6||Math.abs(x-40)<8||Math.abs(x)<10)continue;PINES.push({x,z:SHORE+3+rnd()*5,h:6+rnd()*4,lean:(rnd()-.5)*0.3});}
function pineLayers(list){inst(new THREE.CylinderGeometry(0.18,0.3,1,7).translate(0,0.5,0),tm('#6b4a36'),list,(e,d)=>{d.position.set(e.x,G(e.x,e.z),e.z);d.rotation.z=e.lean;d.scale.set(1,e.h,1);},{cast:true});
  for(let L=0;L<3;L++)inst(new THREE.SphereGeometry(1,10,6),tm(['#2f5d3a','#3a6b42','#457a4a'][L]),list.map(e=>({...e,col:null})),(e,d)=>{d.position.set(e.x+Math.sin(e.lean)*-e.h*(0.6+L*0.15),G(e.x,e.z)+e.h*(0.62+L*0.16),e.z);d.scale.set(2.4-L*0.5,0.55,2.0-L*0.4);},{cast:true});}
pineLayers(PINES);
// forest on the hills around the town
const TREES=[];for(let n=0;n<900;n++){const x=-330+rnd()*660,z=-258+rnd()*430;if(!(z<-182||Math.abs(x)>202))continue;if(x>-82&&x<-38&&z>-180&&z<-122)continue;if(Math.abs(x)<34&&z>-236)continue;if(inDeckView(x,z))continue;TREES.push({x,z,s:2.2+rnd()*2.6,col:C3(pick(['#3f7a45','#4f8a4a','#356a3c','#5a9450']))});}
for(let i=TREES.length-1;i>=0;i--)if(Math.hypot(TREES[i].x-228,TREES[i].z+60)<15)TREES.splice(i,1);   // the rock door's clearing
for(const k of [0,1])inst(CANOPY[k],LEAF,TREES.filter((e,i)=>i%2===k),(e,d)=>{d.position.set(e.x,G(e.x,e.z)+e.s*0.95,e.z);d.scale.set(e.s*0.8,e.s*0.92,e.s*0.8);d.rotation.y=e.x;},{cast:false});
// far mountains round the back and the sides of the town: the land the town sits in, so from the sea or the lighthouse
// the hills do not just stop. Hazy blue-green and far enough for the fog to soften them
{ const r=mulberry(4242),ML=[];
  for(let k=0;k<46;k++){const a=-Math.PI-0.42+(Math.PI+0.84)*(k+r()*0.6)/46,R=560+r()*260,s=150+r()*110;
    ML.push({x:Math.cos(a)*R*1.15,z:-60+Math.sin(a)*R,s,h:(80+r()*120)*(Math.abs(Math.cos(a))>0.8?0.8:1),y:r()*6,col:C3(['#6f8f86','#7a9a8e','#68867f','#809e94'][k%4])});}
  for(let k=0;k<26;k++){const a=-Math.PI-0.3+(Math.PI+0.6)*(k+0.5)/26,R=380+r()*60;ML.push({x:Math.cos(a)*R*1.1,z:-60+Math.sin(a)*R*0.9,s:90+r()*50,h:45+r()*40,y:r()*6,col:C3(['#4f7a5a','#5a8562','#486f52'][k%3])});}
  inst(new THREE.ConeGeometry(1,1,7,1),tm('#ffffff'),ML,(e,d)=>{d.position.set(e.x,e.h/2-4+(Math.abs(e.x)<550&&e.z>-450?Math.max(0,H(e.x,e.z))*0.85:0),e.z);d.scale.set(e.s,e.h,e.s*0.8);d.rotation.y=e.y;},{cast:false});}
// vending machines (two of them are open for business)
const vendTex=canvasTex(64,128,(g,w,h)=>{g.fillStyle='#f4f4f0';g.fillRect(0,0,w,h);g.fillStyle='#cfe7f2';g.fillRect(5,8,w-10,62);
  for(let r=0;r<3;r++)for(let c=0;c<5;c++){g.fillStyle=pick(['#3a7bd5','#e2584a','#4f9a5a','#f2c230','#8a5a3a','#ffffff']);g.fillRect(8+c*10.4,12+r*20,7,14);g.fillStyle='#e2584a';g.fillRect(9+c*10.4,28+r*20,5,2);}
  g.fillStyle='#2b2520';g.fillRect(8,96,w-16,18);g.fillStyle='#d23a2c';g.fillRect(40,76,14,10);});
const VEND=[];
function vend(x,z,yaw,open,col){const g=new THREE.Group();g.position.set(x,G(x,z),z);g.rotation.y=yaw;
  const b=M(new THREE.BoxGeometry(0.95,1.85,0.75),[tm(col),tm(col),tm(col),tm(col),tmap(vendTex,{emissive:new THREE.Color('#2a3a44')}),tm(col)],0.02);b.position.y=0.93;g.add(b);world.add(g);
  const c=Math.abs(Math.cos(yaw)),s=Math.abs(Math.sin(yaw));collide(x-(0.48*c+0.38*s),x+(0.48*c+0.38*s),z-(0.48*s+0.38*c),z+(0.48*s+0.38*c),'vend');
  if(open)VEND.push({x:x+Math.sin(yaw)*1.1,z:z+Math.cos(yaw)*1.1,g});return g;}
vend(-9.3,-27.4,Math.PI/2,true,'#2e5fa8');vend(-9.3,-26.3,Math.PI/2,false,'#d23a2c');
vend(-14.5,234.2,0,true,'#f4f4f0');vend(-13.4,234.2,0,false,'#2e7d4f');
vend(-44.5,-124.4,0,false,'#2e5fa8');vend(42.5,205,Math.PI/2,false,'#d23a2c');
// the red post box on the sea front (the letter quest)
const POSTBOX={x:-150,z:COAST_Z-4.5-1.0};{const p=postBox();p.position.set(POSTBOX.x,G(POSTBOX.x,POSTBOX.z)+0.12,POSTBOX.z);world.add(p);collide(POSTBOX.x-0.3,POSTBOX.x+0.3,POSTBOX.z-0.3,POSTBOX.z+0.3,'post');}
// curve mirrors and stop signs where the lanes meet
const mirrorM=tm('#e8722e'),glassMir=new THREE.MeshPhongMaterial({color:'#cfe3ee',shininess:140,specular:'#ffffff'});glassMir.userData={keep:true};
const stopTex=canvasTex(64,64,(g,w,h)=>{g.clearRect(0,0,w,h);g.fillStyle='#d23a2c';g.beginPath();g.moveTo(4,6);g.lineTo(w-4,6);g.lineTo(w/2,h-4);g.closePath();g.fill();
  g.strokeStyle='#fff';g.lineWidth=3;g.stroke();g.fillStyle='#fff';g.font='bold 13px sans-serif';g.textAlign='center';g.fillText('止まれ',w/2,24);});
const tomareTex=canvasTex(128,256,(g,w,h)=>{g.clearRect(0,0,w,h);g.fillStyle='rgba(245,245,240,.92)';g.font='900 64px "Zen Maru Gothic", sans-serif';g.textAlign='center';g.textBaseline='middle';
  g.save();g.scale(1,1.6);['止','ま','れ'].reverse().forEach((c,k)=>g.fillText(c,w/2,(30+k*52)));g.restore();});
const MARKS=[];
for(const S of STREETS){if(S.kind!=='narrow')continue;for(const o of crossings(S)){if(o.kind!=='wide')continue;
  for(const sd of [-1,1]){const t=o.c+sd*(o.w/2+o.sw+4.5);if(t<S.a||t>S.b)continue;
    const lane=S.w/4*(S.ax==='z'?(sd>0?1:-1):(sd>0?-1:1));
    const x=S.ax==='z'?S.c+lane:t,z=S.ax==='z'?t:S.c+lane;MARKS.push({x,z,yaw:S.ax==='z'?(sd>0?Math.PI:0):(sd>0?-Math.PI/2:Math.PI/2),w:S.w/2-0.4,h:3.2});
    const px=S.ax==='z'?S.c+(S.w/2+0.4)*(sd>0?-1:1):t-sd*0.6,pz=S.ax==='z'?t-sd*0.6:S.c+(S.w/2+0.4)*(sd>0?1:-1);
    const g=new THREE.Group();g.position.set(px,G(px,pz),pz);g.rotation.y=S.ax==='z'?(sd>0?Math.PI:0):(sd>0?-Math.PI/2:Math.PI/2);
    g.add(M(new THREE.CylinderGeometry(0.04,0.04,2.4,6),tm('#c9c9c4')).translateY(1.2));const sg=new THREE.Mesh(new THREE.PlaneGeometry(0.62,0.62),tmap(stopTex,{transparent:true,side:THREE.DoubleSide}));sg.position.set(0,2.2,0.05);g.add(sg);world.add(g);
    if(sd<0){const mx=S.ax==='z'?S.c-(S.w/2+0.5):t+1.5,mz=S.ax==='z'?t+1.5:S.c+(S.w/2+0.5);const m=new THREE.Group();m.position.set(mx,G(mx,mz),mz);m.rotation.y=Math.atan2(o.ax==='z'?o.c-mx:0,o.ax==='x'?o.c-mz:0)+Math.PI;
      m.add(M(new THREE.CylinderGeometry(0.05,0.05,3,8),mirrorM,0.012).translateY(1.5));const ring=M(new THREE.TorusGeometry(0.4,0.05,8,24),mirrorM,0);ring.position.y=3.1;m.add(ring);
      const gl=new THREE.Mesh(new THREE.CircleGeometry(0.4,24),glassMir);gl.position.set(0,3.1,0.01);m.add(gl);world.add(m);collide(mx-0.15,mx+0.15,mz-0.15,mz+0.15,'pole');}
  }}}
function decal(x,z,yaw,w,h,mat){const m=new THREE.Mesh(new THREE.PlaneGeometry(w,h).rotateX(-Math.PI/2),mat);m.position.set(x,G(x,z)+0.06,z);m.rotation.y=yaw;m.receiveShadow=true;world.add(m);return m;}
const decalM=t=>tmap(t,{transparent:true,polygonOffset:true,polygonOffsetFactor:-6,depthWrite:false});
const tomM=decalM(tomareTex);for(const m of MARKS)decal(m.x,m.z,m.yaw,m.w,m.h,tomM);
const zebra=canvasTex(512,64,(g,w,h)=>{g.clearRect(0,0,w,h);g.fillStyle='rgba(248,248,243,.95)';const n=12;for(let k=0;k<n;k++)g.fillRect((k+0.2)/n*w,0,w/n*0.6,h);});
const zebM=decalM(zebra);
for(const o of STREETS){if(o.ax!=='x')continue;const S=STREETS[0];if(o.c<S.a||o.c>S.b)continue;for(const sd of [-1,1])decal(0,o.c+sd*(o.w/2+S.sw+1.8),0,S.w-0.6,3,zebM);}
for(const sd of [-1,1])decal(sd*(4.5+2.2+1.8),COAST_Z,Math.PI/2,8.4,3,zebM);
// the shopping street: arches at both ends and bunting across
{ const S=STREETS.find(s=>s.id==='shop');for(const x of [-72,72]){const y=G(x,S.c),g=new THREE.Group();g.position.set(x,y,S.c);g.rotation.y=Math.PI/2;
    for(const sd of [-1,1])g.add(M(new THREE.CylinderGeometry(0.16,0.16,5.4,10),tm('#2f6b8a'),0.02).translateY(2.7).translateX(sd*4.6));
    const sign=M(new THREE.BoxGeometry(9.8,1.0,0.3),[tm('#2f6b8a'),tm('#2f6b8a'),tm('#2f6b8a'),tm('#2f6b8a'),tmap(canvasTex(512,64,(c,w,h)=>{c.fillStyle='#fffaf0';c.fillRect(0,0,w,h);c.fillStyle='#2f6b8a';c.fillRect(0,0,w,6);c.fillRect(0,h-6,w,6);
      c.font=signFont(34,true);c.textAlign='center';c.textBaseline='middle';c.fillText('しおかぜ商店街',w/2,h/2+1);})),tmap(canvasTex(512,64,(c,w,h)=>{c.fillStyle='#fffaf0';c.fillRect(0,0,w,h);c.fillStyle='#2f6b8a';c.font=signFont(30,true);c.textAlign='center';c.textBaseline='middle';c.fillText('SHIOKAZE SHOTENGAI',w/2,h/2);}))],0.03);
    sign.position.y=5.2;g.add(sign);world.add(g);
    for(const sd of [-1,1])collide(x-0.2,x+0.2,S.c+sd*4.6-0.2,S.c+sd*4.6+0.2,'pole');}
  const flags=[];for(let x=-64;x<=64;x+=9){if(Math.abs(x)<8)continue;for(let k=0;k<9;k++){const z=S.c-4+k;flags.push({x,z,y:G(x,z)+4.6-Math.sin(Math.PI*k/8)*0.5,col:C3(pick(['#e2584a','#f2c230','#3a7bd5','#4f9a5a','#ffffff']))});}
    sag([x,G(x,S.c-4.5)+4.75,S.c-4.5],[x,G(x,S.c+4.5)+4.75,S.c+4.5],0.5);}
  inst(new THREE.ConeGeometry(0.22,0.42,3).rotateX(Math.PI),tm('#ffffff',{side:THREE.DoubleSide}),flags,(e,d)=>{d.position.set(e.x,e.y-0.2,e.z);d.scale.set(1,1,0.15);d.rotation.y=Math.PI/2;});}
{const g=new THREE.BufferGeometry();g.setAttribute('position',new THREE.Float32BufferAttribute(WIRES,3));world.add(new THREE.LineSegments(g,new THREE.LineBasicMaterial({color:'#2b2724'})));}
{const g=new THREE.BufferGeometry();g.setAttribute('position',new THREE.Float32BufferAttribute(edges,3));world.add(new THREE.LineSegments(g,new THREE.LineBasicMaterial({color:'#5a4a3e',transparent:true,opacity:0.75})));}

/* ---------- the shrine, the lookout, the station ---------- */
const SHRINE={x:-60,z:-124.6};
{ const vermil=tm('#d8452f'),blk=tm('#2b2520'),x=SHRINE.x,z=SHRINE.z,y=G(x,z),g=new THREE.Group();g.position.set(x,y,z);world.add(g);
  for(const sd of [-1,1]){g.add(M(new THREE.CylinderGeometry(0.22,0.26,4.4,14),vermil,0.025).translateX(sd*1.9).translateY(2.2));collide(x+sd*1.9-0.3,x+sd*1.9+0.3,z-0.3,z+0.3,'pole');}
  const kasagi=M(new THREE.BoxGeometry(5.6,0.32,0.5),blk,0.025);kasagi.position.y=4.55;g.add(kasagi);
  const shimaki=M(new THREE.BoxGeometry(5.0,0.3,0.42),vermil,0.02);shimaki.position.y=4.25;g.add(shimaki);
  const nuki=M(new THREE.BoxGeometry(4.6,0.24,0.28),vermil,0.02);nuki.position.y=3.4;g.add(nuki);
  const gtx=canvasTex(48,64,(c,w,h)=>{c.fillStyle='#2b2520';c.fillRect(0,0,w,h);c.strokeStyle='#d9b44a';c.lineWidth=3;c.strokeRect(3,3,w-6,h-6);c.fillStyle='#d9b44a';c.font=signFont(18,true);c.textAlign='center';c.textBaseline='middle';c.fillText('海',w/2,h*0.3);c.fillText('見',w/2,h*0.7);});
  const gaku=new THREE.Mesh(new THREE.BoxGeometry(0.6,0.8,0.08),[blk,blk,blk,blk,tmap(gtx),tmap(gtx)]);outline(gaku,0.01);gaku.position.y=3.85;g.add(gaku);
  for(const sd of [-1,1]){g.add(M(new THREE.CylinderGeometry(0.34,0.38,0.32,14),blk,0.012).translateX(sd*1.9).translateY(0.16));
    const tip=M(new THREE.BoxGeometry(0.5,0.3,0.5),blk,0.012);tip.position.set(sd*2.75,4.66,0);tip.rotation.z=sd*0.28;g.add(tip);}
  { const rp=new THREE.CatmullRomCurve3([new THREE.Vector3(-1.75,3.05,0.18),new THREE.Vector3(0,2.85,0.2),new THREE.Vector3(1.75,3.05,0.18)]);
    g.add(M(new THREE.TubeGeometry(rp,16,0.07,6,false),tm('#d9c98f'),0.008));
    const sh=canvasTex(32,64,(c,w,h)=>{c.clearRect(0,0,w,h);c.fillStyle='#ffffff';for(let k=0;k<4;k++)c.fillRect(k%2?14:4,k*16,14,14);});
    for(const px of [-1,0,1]){const m=new THREE.Mesh(new THREE.PlaneGeometry(0.18,0.38),tmap(sh,{transparent:true,alphaTest:0.5,side:THREE.DoubleSide}));m.position.set(px,2.66+Math.abs(px)*0.12,0.2);g.add(m);}}
  // stone path climbing to the hall
  const path=[];for(let zz=z-1.5;zz>-160;zz-=1.6)path.push({x,z:zz});
  inst(new THREE.BoxGeometry(2.2,0.18,1.4),tm('#9d978b'),path,(e,d)=>{d.position.set(e.x,G(e.x,e.z)-0.06,e.z);d.rotation.x=Math.atan(HILL);},{recv:true});   // laid along the slope, just proud of the ground
  for(const [lx,lz] of [[x-2.6,z-6],[x+2.6,z-6],[x-2.6,z-24],[x+2.6,z-24]]){const l=new THREE.Group();l.position.set(lx,G(lx,lz),lz);const st=tm('#a9a397');
    l.add(M(new THREE.CylinderGeometry(0.28,0.36,0.3,8),st,0.015).translateY(0.15));l.add(M(new THREE.CylinderGeometry(0.12,0.12,0.9,8),st,0.012).translateY(0.75));
    l.add(M(new THREE.BoxGeometry(0.55,0.4,0.55),st,0.015).translateY(1.35));l.add(M(new THREE.ConeGeometry(0.55,0.4,4),st,0.015).translateY(1.75).rotateY(Math.PI/4));world.add(l);collide(lx-0.35,lx+0.35,lz-0.35,lz+0.35,'prop',G(lx,lz)+1.95);}
  // the hall: a raised wooden floor with a vermilion railing round it, white walls between vermilion pillars, latticed doors,
  // a hipped-and-gabled copper roof with crossed boards and logs on its ridge, and a porch over the steps with the bell and the offering box
  const hz=-162,hy=G(x,hz),hall=new THREE.Group();hall.position.set(x,hy,hz);world.add(hall);
  const stone=tm('#b8b2a6'),wood=tm('#6b4a2e'),dark=tm('#4a3326'),white=tm('#f1eadb'),cop=tm('#4f7a6c'),gold=tm('#d9b44a');
  const H=(geo,mat,ol,px,py,pz)=>{const m=M(geo,mat,ol);m.position.set(px||0,py||0,pz||0);hall.add(m);return m;};
  H(new THREE.BoxGeometry(7,0.7,6),stone,0.02,0,0.35,0);
  for(const px of [-2.9,-1,1,2.9])for(const pz of [-2.4,0,2.4])H(new THREE.CylinderGeometry(0.1,0.1,0.42,8),dark,0,px,0.91,pz);
  H(new THREE.BoxGeometry(6.4,0.14,5.4),wood,0.015,0,1.15,0);
  // the railing round the verandah, open in the middle of the front for the steps
  for(const [px,pz,w,d] of [[0,-2.65,6.3,0.08],[-3.15,0,0.08,5.3],[3.15,0,0.08,5.3],[-2.05,2.65,2.2,0.08],[2.05,2.65,2.2,0.08]]){
    H(new THREE.BoxGeometry(w,0.07,d),vermil,0.008,px,1.62,pz);H(new THREE.BoxGeometry(w,0.05,d),vermil,0,px,1.36,pz);}
  for(const [px,pz] of [[-3.15,-2.65],[3.15,-2.65],[-3.15,2.65],[3.15,2.65],[-0.95,2.65],[0.95,2.65],[-3.15,0],[3.15,0]])H(new THREE.BoxGeometry(0.1,0.5,0.1),vermil,0.008,px,1.43,pz);
  H(new THREE.BoxGeometry(4.6,2.3,3.8),white,0.02,0,2.37,0);
  for(const px of [-2.3,-0.78,0.78,2.3])for(const pz of [-1.9,1.9])H(new THREE.CylinderGeometry(0.12,0.12,2.5,10),vermil,0.012,px,2.47,pz);
  for(const px of [-2.3,2.3])H(new THREE.CylinderGeometry(0.12,0.12,2.5,10),vermil,0.012,px,2.47,0);
  for(const py of [1.5,3.38])H(new THREE.BoxGeometry(4.75,0.18,3.95),vermil,0.012,0,py,0);
  const lat=canvasTex(128,96,(g,w,h)=>{g.fillStyle='#f6efdf';g.fillRect(0,0,w,h);g.fillStyle='#c23a28';for(let k=0;k<=w;k+=8)g.fillRect(k,0,2,h);for(let k=0;k<=h;k+=8)g.fillRect(0,k,w,2);
    g.fillRect(0,0,w,5);g.fillRect(0,h-5,w,5);g.fillRect(w/2-3,0,6,h);});
  const door=new THREE.Mesh(new THREE.PlaneGeometry(1.5,1.75),tmap(lat));door.position.set(0,2.4,1.905);hall.add(door);
  for(const sd of [-1,1]){const dd=door.clone();dd.scale.set(0.9,1,1);dd.position.x=sd*1.54;hall.add(dd);}
  // brackets, then the roof: a hipped lower part with a gable on top
  H(new THREE.BoxGeometry(5.2,0.32,4.4),dark,0.012,0,3.62,0);
  H(new THREE.BoxGeometry(7.6,0.14,6.6),dark,0.015,0,3.86,0);
  const hip=H(new THREE.CylinderGeometry(0.46,1,1,4,1).rotateY(Math.PI/4),cop,0.02,0,4.42,0);hip.scale.set(3.75/0.707,1.0,3.25/0.707);
  const gab=H(prism,cop,0.02,0,5.4,0);gab.scale.set(3.6,1.05,1.52/1.732*1.15);
  for(const sd of [-1,1]){const tri=H(prism,white,0,sd*1.82,5.36,0);tri.scale.set(0.04,0.8,1.3/1.732*1.15);}
  H(new THREE.BoxGeometry(3.9,0.2,0.26),dark,0.012,0,6.47,0);
  for(const sd of [-1,1])for(const r of [-0.55,0.55]){const c=H(new THREE.BoxGeometry(0.08,1.1,0.16),dark,0.008,sd*1.95,6.75,0);c.rotation.z=r;}
  for(const px of [-1.1,-0.37,0.37,1.1]){H(new THREE.CylinderGeometry(0.1,0.1,0.62,10).rotateX(Math.PI/2),dark,0.008,px,6.66,0);
    for(const sd of [-1,1])H(new THREE.CylinderGeometry(0.105,0.105,0.04,10).rotateX(Math.PI/2),gold,0,px,6.66,sd*0.31);}
  // the porch: two pillars, a sloping roof, a beam with the sacred rope and its paper streamers
  for(const sd of [-1,1])H(new THREE.CylinderGeometry(0.11,0.11,3.55,10),vermil,0.012,sd*1.3,1.78,3.85);
  H(new THREE.BoxGeometry(2.9,0.2,0.24),vermil,0.01,0,3.45,3.85);
  const por=H(new THREE.BoxGeometry(3.4,0.12,2.6),cop,0.015,0,3.86,3.05);por.rotation.x=0.26;
  H(new THREE.BoxGeometry(3.4,0.1,0.1),dark,0,0,3.52,4.3);
  const rp=new THREE.CatmullRomCurve3([new THREE.Vector3(-1.25,3.28,3.95),new THREE.Vector3(0,2.98,4.0),new THREE.Vector3(1.25,3.28,3.95)]);
  H(new THREE.TubeGeometry(rp,20,0.11,8,false),tm('#d9c98f'),0.01);
  const shide=canvasTex(32,64,(g,w,h)=>{g.clearRect(0,0,w,h);g.fillStyle='#ffffff';for(let k=0;k<4;k++){const y=k*16;g.fillRect(k%2?14:4,y,14,14);}});
  const shM=tmap(shide,{transparent:true,alphaTest:0.5,side:THREE.DoubleSide});
  for(const px of [-0.8,0,0.8]){const m=new THREE.Mesh(new THREE.PlaneGeometry(0.22,0.45),shM);m.position.set(px,2.7+Math.abs(px)*0.18,4.02);hall.add(m);}
  // the bell on its red-and-white rope, the offering box at the foot of the steps
  const bellRope=canvasTex(8,64,(g,w,h)=>{for(let k=0;k<8;k++){g.fillStyle=['#c8372d','#f4efe2','#7a3a8a'][k%3];g.fillRect(0,k*8,w,8);}},true);
  H(new THREE.CylinderGeometry(0.05,0.05,2.1,8),tmap(bellRope),0,0,2.2,4.25);
  H(new THREE.SphereGeometry(0.2,14,10),gold,0.012,0,3.28,4.25);
  // the hall stands on a slope: six steps, the lower ones reaching down to the ground in front, each low enough to walk up
  for(let k=0;k<6;k++){const tt=1.15-0.29*k;H(new THREE.BoxGeometry(1.9,tt+0.8,0.3),k?stone:wood,0.012,0,(tt-0.8)/2,2.75+0.3*k);}
  const slat=canvasTex(128,64,(g,w,h)=>{g.fillStyle='#6b4a2e';g.fillRect(0,0,w,h);g.fillStyle='#4a3326';for(let k=4;k<w;k+=12)g.fillRect(k,14,6,h-14);g.fillStyle='#f4efe2';g.font=signFont(13,true);g.textAlign='center';g.fillText('奉　納',w/2,11);});
  const box=new THREE.Mesh(new THREE.BoxGeometry(1.6,0.75,0.6),[wood,wood,dark,wood,tmap(slat),wood]);box.castShadow=true;outline(box,0.015);box.position.set(0,G(x,hz+5.3)-hy+0.38,5.3);hall.add(box);collide(x-0.8,x+0.8,hz+5,hz+5.6,'prop',G(x,hz+5.3)+0.75);   // on the ground before the steps
  // hanging lanterns under the eaves
  for(const sd of [-1,1]){H(new THREE.CylinderGeometry(0.012,0.012,0.4,4),dark,0,sd*2.7,3.58,3.0);const lt=H(new THREE.CylinderGeometry(0.16,0.12,0.36,6),tm('#3d3a33'),0.008,sd*2.7,3.2,3.0);
    H(new THREE.ConeGeometry(0.24,0.16,6),tm('#3d3a33'),0,sd*2.7,3.44,3.0);}
  collide(x-3.5,x+3.5,hz-3,hz+2.6,'bld');for(let k=0;k<6;k++)collide(x-0.95,x+0.95,hz+2.6+0.3*k,hz+2.9+0.3*k,'step',hy+1.15-0.29*k);
  // the guardian dogs on their stones, one each side in front of the hall
  const kom=(sd)=>{const kx=x+sd*3.1,kz=hz+6.2,g2=new THREE.Group();g2.position.set(kx,G(kx,kz),kz);g2.rotation.y=-sd*0.55;world.add(g2);const st=tm('#a39d90'),ds=tm('#8f897d');
    const K=(geo,mat,px,py,pz)=>{const m=M(geo,mat,0.012);m.position.set(px,py,pz);g2.add(m);return m;};
    K(new THREE.BoxGeometry(0.8,0.75,0.9),ds,0,0.375,0);K(new THREE.BoxGeometry(0.9,0.12,1.0),ds,0,0.81,0);
    K(new THREE.BoxGeometry(0.42,0.36,0.6),st,0,1.05,-0.1).rotation.x=-0.1;K(new THREE.SphereGeometry(0.26,10,8),st,0,1.35,0.12).scale.set(0.9,1.15,0.8);
    for(const px of [-0.12,0.12])K(new THREE.CylinderGeometry(0.06,0.07,0.42,6),st,px,1.08,0.26);
    K(new THREE.SphereGeometry(0.27,10,8),ds,0,1.72,0.12).scale.set(1.05,1,0.85);K(new THREE.SphereGeometry(0.2,10,8),st,0,1.7,0.28);
    K(new THREE.BoxGeometry(0.2,0.12,0.12),st,0,1.63,0.45);for(const px of [-0.09,0.09])K(new THREE.SphereGeometry(0.035,6,4),tm('#2b2520'),px,1.78,0.44);
    const tail=K(new THREE.SphereGeometry(0.16,8,6),ds,0,1.38,-0.42);tail.scale.set(1,1.4,0.7);
    collide(kx-0.5,kx+0.5,kz-0.5,kz+0.5,'prop',G(kx,kz)+0.87);};
  kom(-1);kom(1);
  // the water basin by the gate, under its own little roof, with ladles across it
  { const tx=x-6.4,tz=z-2.9,ty=G(tx,tz),g2=new THREE.Group();g2.position.set(tx,ty,tz);world.add(g2);const T=(geo,mat,ol,px,py,pz)=>{const m=M(geo,mat,ol);m.position.set(px,py,pz);g2.add(m);return m;};
    for(const px of [-0.85,0.85])for(const pz of [-0.65,0.65])T(new THREE.CylinderGeometry(0.07,0.07,2.3,8),wood,0.01,px,1.15,pz);
    T(new THREE.BoxGeometry(1.9,0.12,1.5),dark,0.01,0,2.3,0);const rf=T(prism,cop,0.015,0,2.6,0);rf.scale.set(2.3,0.62,2.1/1.732);
    T(new THREE.BoxGeometry(1.25,0.55,0.75),tm('#9d978b'),0.015,0,0.28,0);const w=new THREE.Mesh(new THREE.PlaneGeometry(1.05,0.55).rotateX(-Math.PI/2),tm('#5aa3c8'));w.position.set(0,0.52,0);g2.add(w);
    for(const px of [-0.35,0,0.35]){T(new THREE.CylinderGeometry(0.012,0.012,0.7,4).rotateX(Math.PI/2),tm('#d9c08a'),0,px,0.6,0.02);T(new THREE.CylinderGeometry(0.06,0.06,0.09,8),tm('#d9c08a'),0,px,0.6,0.38);}
    collide(tx-0.95,tx+0.95,tz-0.75,tz+0.75,'prop',ty+0.55);}
  // the wishing-plaque rack beside the hall
  { const ex=x+7.4,ez=hz+1,ey=G(ex,ez),g2=new THREE.Group();g2.position.set(ex,ey,ez);g2.rotation.y=-Math.PI/2;world.add(g2);const E=(geo,mat,ol,px,py,pz)=>{const m=M(geo,mat,ol);m.position.set(px,py,pz);g2.add(m);return m;};
    for(const px of [-1.1,1.1])E(new THREE.CylinderGeometry(0.06,0.06,1.9,8),wood,0.01,px,0.95,0);
    const rf=E(prism,tm('#3a3d44'),0.01,0,2.05,0);rf.scale.set(2.6,0.36,0.7/1.732);for(const py of [1.05,1.45])E(new THREE.BoxGeometry(2.2,0.05,0.05),wood,0,0,py,0);
    const ema=canvasTex(32,24,(g,w,h)=>{g.fillStyle='#e2c48e';g.beginPath();g.moveTo(0,8);g.lineTo(16,0);g.lineTo(32,8);g.lineTo(32,24);g.lineTo(0,24);g.fill();g.fillStyle='#c8372d';g.fillRect(4,12,24,3);g.fillStyle='#4a3326';g.fillRect(6,17,20,2);});
    const eM=tmap(ema,{transparent:true,alphaTest:0.5,side:THREE.DoubleSide}),list=[];for(const py of [0.9,1.3])for(let k=0;k<9;k++)list.push({x:-0.96+k*0.24+(rnd()-0.5)*0.04,y:py,r:(rnd()-0.5)*0.25});
    inst(new THREE.PlaneGeometry(0.2,0.15),eM,list,(e,d)=>{d.position.set(e.x,e.y,0.04);d.rotation.z=e.r;});
    collide(ex-0.25,ex+0.25,ez-1.2,ez+1.2,'prop',ey+2);}
  // the sacred tree with a rope round it
  { const sx=x-8.2,sz=hz+2,sy=G(sx,sz);const tr=M(new THREE.CylinderGeometry(0.55,0.8,7,10),tm('#5a4232'),0.02);tr.position.set(sx,sy+3.5,sz);world.add(tr);
    const cn=M(new THREE.IcosahedronGeometry(3.6,1),tm('#2a5434'),0);cn.position.set(sx,sy+8.4,sz);cn.scale.set(1,0.85,1);world.add(cn);
    const rope2=M(new THREE.TorusGeometry(0.74,0.08,8,24),tm('#d9c98f'),0.008);rope2.rotation.x=Math.PI/2;rope2.position.set(sx,sy+1.7,sz);world.add(rope2);
    for(let k=0;k<5;k++){const a=k/5*TAU,m=new THREE.Mesh(new THREE.PlaneGeometry(0.16,0.34),shM);m.position.set(sx+Math.cos(a)*0.78,sy+1.45,sz+Math.sin(a)*0.78);m.rotation.y=-a+Math.PI/2;world.add(m);}
    collide(sx-0.8,sx+0.8,sz-0.8,sz+0.8,'prop',sy+7);}
  // the grove keeps clear of the stalls along the approach, the plaque rack and the sacred tree
  const big=[];for(let k=0;k<14;k++){const a=rnd()*TAU,r=7+rnd()*10;big.push({x:x+Math.cos(a)*r,z:-150+Math.sin(a)*14,s:3+rnd()*2});}
  const grove=big.filter(t=>Math.abs(t.x-x)>8.6&&Math.hypot(t.x-(x+7.4),t.z-(hz+1))>3.5&&Math.hypot(t.x-(x-8.2),t.z-(hz+2))>4);
  for(const k of [0,1])inst(CANOPY[k],LEAF,grove.filter((e,i)=>i%2===k).map(e=>({...e,col:C3(k?'#35663f':'#2f5d3a')})),(e,d)=>{d.position.set(e.x,G(e.x,e.z)+e.s*1.5,e.z);d.scale.set(e.s*0.82,e.s*1.2,e.s*0.82);d.rotation.y=e.x;},{cast:true});
  inst(new THREE.CylinderGeometry(0.25,0.35,1,7).translate(0,0.5,0),tm('#5a4232'),grove,(e,d)=>{d.position.set(e.x,G(e.x,e.z),e.z);d.scale.set(1,e.s*1.2,1);});
}
const LOOKOUT={x:0,z:-212};
{ const x=LOOKOUT.x,z=LOOKOUT.z,y=G(x,-206);const g=new THREE.Group();g.position.set(x,y,-206);world.add(g);
  g.add(M(new THREE.BoxGeometry(30,0.4,14),tm('#c9c2b4'),0).translateY(-0.1).translateZ(-7));
  const railM=tm('#5a6b72');for(const [rx,rz,rw,rd] of [[-15,-7,0.1,14],[15,-7,0.1,14]])g.add(M(new THREE.BoxGeometry(rw,1,rd),railM,0.01).translateX(rx).translateY(0.5).translateZ(rz));
  for(const sd of [-1,1]){const b=benchMesh();b.position.set(sd*8,0,-9);b.rotation.y=Math.PI;g.add(b);}
  const tel=new THREE.Group();tel.add(M(new THREE.CylinderGeometry(0.08,0.12,1.1,8),tm('#3a5a66'),0.01).translateY(0.55));const bin=M(new THREE.BoxGeometry(0.5,0.32,0.4),tm('#2f6b8a'),0.012);bin.position.y=1.25;tel.add(bin);
  for(const sd of [-1,1])tel.add(M(new THREE.CylinderGeometry(0.08,0.08,0.3,10).rotateX(Math.PI/2),tm('#2b2520')).translateX(sd*0.12).translateY(1.27).translateZ(0.3));
  tel.position.set(3,0,-3);g.add(tel);
  const sign=new THREE.Mesh(new THREE.PlaneGeometry(1.6,0.6),tmap(canvasTex(128,48,(c,w,h)=>{c.fillStyle='#6b4a2e';c.fillRect(0,0,w,h);c.fillStyle='#fffaf0';c.font=signFont(24,true);c.textAlign='center';c.textBaseline='middle';c.fillText('見晴らし台',w/2,h/2);})));
  sign.position.set(-4,1.6,-2);g.add(sign);g.add(M(new THREE.BoxGeometry(0.1,1.4,0.1),tm('#6b4a2e')).translateX(-4).translateY(0.7).translateZ(-2.05));
  collide(x-15,x+15,-221,-220.5,'wall');collide(x-15.2,x-14.8,-221,-206,'wall');collide(x+14.8,x+15.2,-221,-206,'wall');
}
const STATION={x0:46,x1:84,z0:203.2,z1:208.8};
{ const y=G(65,206);const plat=M(new THREE.BoxGeometry(38,0.85,5.6),tm('#c9c2b4'),0.02);plat.position.set(65,y+0.42,206);plat.receiveShadow=true;world.add(plat);
  const edge=new THREE.Mesh(new THREE.BoxGeometry(38,0.02,0.4),tm('#f2c230'));edge.position.set(65,y+0.86,208.4);world.add(edge);
  const roof=M(new THREE.BoxGeometry(14,0.15,3.4),tm('#2e7d4f'),0.025);roof.position.set(62,y+3.6,205.6);roof.castShadow=true;world.add(roof);
  for(const x of [56,62,68])world.add(M(new THREE.CylinderGeometry(0.08,0.08,2.8,8),tm('#ddd'),0.01).translateX(x).translateY(y+2.2).translateZ(204.4));
  const sg=new THREE.Mesh(new THREE.BoxGeometry(2.6,0.7,0.1),[tm('#fff'),tm('#fff'),tm('#fff'),tm('#fff'),tmap(canvasTex(256,64,(c,w,h)=>{c.fillStyle='#fffaf0';c.fillRect(0,0,w,h);c.fillStyle='#2e7d4f';c.fillRect(0,h-12,w,12);
    c.fillStyle='#2b2520';c.font=signFont(30,true);c.textAlign='center';c.fillText('うみまち',w/2,32);c.font=signFont(12);c.fillText('UMIMACHI',w/2,46);})),tm('#fff')]);
  sg.position.set(62,y+3.1,205.6);world.add(sg);
  const b=benchMesh();b.position.set(65,y+0.85,205);world.add(b);
  collide(46,84,203.2,208.8,'plat');
}
// a step up to the platform at both ends
{ const y=G(65,206);for(const [x0,x1] of [[42,46],[84,88]]){const m=M(new THREE.BoxGeometry(x1-x0,0.43,5.6),tm('#c9c2b4'),0.02);m.position.set((x0+x1)/2,y+0.215,206);m.receiveShadow=true;world.add(m);collide(x0,x1,203.2,208.8,'step',y+0.43);}}

/* the station square: the station building on the platform's town side, a roundabout with a clock tower, a bus stop and a taxi rank,
   bicycles, a phone box, vending machines, flower beds, lamps and a town map. Open from the street along the shore (浜手通り) */
const EKI={x0:47,x1:83,z0:173.4,z1:203.2,cx:65,cz:186},EKI_LAMPS=[];   // the lamps glow at night with the others (p5c_story.js)
{ const E=EKI,W=E.x1-E.x0,D=E.z1-E.z0;
  // paving that follows the slope: asphalt with the roundabout's lines, and a band of tiles before the building
  const pave=(x0,x1,z0,z1,tex,lift)=>{const g=new THREE.PlaneGeometry(x1-x0,z1-z0,Math.ceil((x1-x0)/2),Math.ceil((z1-z0)/2)).rotateX(-Math.PI/2),p=g.attributes.position;
    for(let i=0;i<p.count;i++){const x=p.getX(i)+(x0+x1)/2,z=p.getZ(i)+(z0+z1)/2;p.setY(i,G(x,z)+lift);}g.computeVertexNormals();
    const m=new THREE.Mesh(g,tmap(tex,{polygonOffset:true,polygonOffsetFactor:-2}));m.position.set((x0+x1)/2,0,(z0+z1)/2);m.receiveShadow=true;world.add(m);return m;};
  pave(E.x0,E.x1,E.z0,192,canvasTex(256,256,(g,w,h)=>{g.fillStyle='#6a6c70';g.fillRect(0,0,w,h);g.fillStyle='rgba(255,255,255,.05)';for(let k=0;k<400;k++)g.fillRect(Math.random()*w,Math.random()*h,2,2);
    const cx=(E.cx-E.x0)/W*w,cy=(E.cz-E.z0)/(192-E.z0)*h;g.strokeStyle='#e8e8e2';g.lineWidth=3;g.setLineDash([10,8]);g.beginPath();g.ellipse(cx,cy,12/W*w,12/(192-E.z0)*h,0,0,7);g.stroke();
    g.setLineDash([]);g.fillStyle='#e8e8e2';for(let k=0;k<4;k++)g.fillRect(8+k*14,h-20,8,16);g.font='900 14px sans-serif';g.fillText('TAXI',w-62,h-10);g.fillText('BUS',10,h-26);}),0.04);
  pave(E.x0,E.x1,192,E.z1,canvasTex(128,32,(g,w,h)=>{g.fillStyle='#d9d2c4';g.fillRect(0,0,w,h);g.strokeStyle='rgba(0,0,0,.12)';for(let x=0;x<w;x+=8){g.beginPath();g.moveTo(x,0);g.lineTo(x,h);g.stroke();}
    for(let y=0;y<h;y+=8){g.beginPath();g.moveTo(0,y);g.lineTo(w,y);g.stroke();}g.fillStyle='#e8c94a';g.fillRect(0,12,w,5);}),0.07);
  // the station building, facing the square
  const bx0=55,bx1=75,bz0=196,bz1=203.2,by=G(65,bz0),bw=bx1-bx0,bd=bz1-bz0,st=new THREE.Group();st.position.set(65,by,(bz0+bz1)/2);world.add(st);
  const S=(geo,mat,ol,x,y,z)=>{const m=M(geo,mat,ol);m.position.set(x,y,z);st.add(m);return m;};
  S(new THREE.BoxGeometry(bw,0.3,bd),tm('#bdb6a8'),0.02,0,0.15,0);
  S(new THREE.BoxGeometry(bw-0.4,3.4,bd-0.4),tm('#f1e9d8'),0.025,0,1.95,0);
  for(const x of [-bw/2+0.3,-3.2,3.2,bw/2-0.3])S(new THREE.BoxGeometry(0.45,3.6,0.45),tm('#6b4a2e'),0.012,x,1.95,-bd/2+0.25);
  const glass=new THREE.Mesh(new THREE.PlaneGeometry(5.6,2.6),tmap(canvasTex(128,64,(g,w,h)=>{g.fillStyle='#3a4a52';g.fillRect(0,0,w,h);g.fillStyle='#8fb8c8';for(let k=0;k<4;k++)g.fillRect(4+k*31,4,27,h-8);
      g.fillStyle='rgba(255,255,255,.35)';for(let k=0;k<4;k++)g.fillRect(8+k*31,8,4,h-16);}),{emissive:new THREE.Color('#1a2a30')}));glass.position.set(0,1.6,-bd/2+0.19);glass.rotation.y=Math.PI;st.add(glass);
  for(const sd of [-1,1])for(let k=0;k<2;k++){const w2=new THREE.Mesh(new THREE.PlaneGeometry(1.6,1.2),tm('#8fb8c8'));w2.position.set(sd*(5.4+k*2.6),2.0,-bd/2+0.19);w2.rotation.y=Math.PI;st.add(w2);}
  S(new THREE.BoxGeometry(bw+1.4,0.25,bd+1.6),tm('#3a4a5a'),0.02,0,3.75,0);
  const rf=S(prism,tm('#3a4a5a'),0.02,0,4.55,0);rf.scale.set(bw*0.92,1.3,(bd+0.8)/1.732);
  // the canopy over the entrance with the name board, and a clock in the gable
  S(new THREE.BoxGeometry(8,0.18,2.4),tm('#3a4a5a'),0.015,0,3.15,-bd/2-1);for(const sd of [-1,1])S(new THREE.CylinderGeometry(0.08,0.08,3.1,8),tm('#6b4a2e'),0.008,sd*3.7,1.6,-bd/2-2);
  const nb=new THREE.Mesh(new THREE.BoxGeometry(6,0.9,0.12),[tm('#fff'),tm('#fff'),tm('#fff'),tm('#fff'),tm('#fff'),tmap(canvasTex(384,64,(c,w,h)=>{c.fillStyle='#fffaf0';c.fillRect(0,0,w,h);c.fillStyle='#2e7d4f';c.fillRect(0,h-10,w,10);
    c.fillStyle='#2b2520';c.font=signFont(34,true);c.textAlign='center';c.fillText('う み ま ち 駅',w/2,38);c.font=signFont(11);c.fillText('UMIMACHI STATION',w/2,51);}))]);
  nb.position.set(0,3.6,-bd/2-0.05);   // the name is on the box's -z face, the one towards the square
  outline(nb,0.012);st.add(nb);
  const clk=new THREE.Mesh(new THREE.CircleGeometry(0.55,24),tmap(canvasTex(64,64,(c,w,h)=>{c.fillStyle='#fffaf0';c.beginPath();c.arc(32,32,31,0,7);c.fill();c.strokeStyle='#2b2520';c.lineWidth=3;c.stroke();
    for(let k=0;k<12;k++){const a=k/12*TAU;c.fillRect(32+Math.sin(a)*24-1,32-Math.cos(a)*24-1,3,3);}c.lineWidth=3;c.beginPath();c.moveTo(32,32);c.lineTo(32,14);c.moveTo(32,32);c.lineTo(44,36);c.stroke();})));
  clk.position.set(0,4.6,-bd/2-0.33);clk.rotation.y=Math.PI;st.add(clk);
  collide(bx0,bx1,bz0,bz1,'bld',by+3.8);
  // the roundabout: a raised ring of kerb and grass, a clock tower in the middle, flowers round it
  const ry=G(E.cx,E.cz),ring=new THREE.Group();ring.position.set(E.cx,ry,E.cz);world.add(ring);
  ring.add(M(new THREE.CylinderGeometry(4.2,4.3,0.3,32),tm('#c9c2b4'),0.02).translateY(0.15));ring.add(M(new THREE.CylinderGeometry(3.95,3.95,0.32,32),tm('#5a9a4a'),0).translateY(0.17));
  const fl=[];for(let k=0;k<90;k++){const a=k/90*TAU+(k%2)*0.03,r=3.15+(k%3)*0.3;fl.push({x:Math.cos(a)*r,z:Math.sin(a)*r,c:C3(['#e8452f','#f2c230','#f0a0b8','#ffffff','#a070d0'][k%5])});}
  { const im=new THREE.InstancedMesh(new THREE.SphereGeometry(0.075,6,5),tm('#ffffff'),fl.length);fl.forEach((f,k)=>{dummy.position.set(f.x,0.4,f.z);dummy.rotation.set(0,0,0);dummy.scale.set(1,0.8,1);dummy.updateMatrix();im.setMatrixAt(k,dummy.matrix);im.setColorAt(k,f.c);});ring.add(im);}
  ring.add(M(new THREE.BoxGeometry(0.9,0.6,0.9),tm('#a39d90'),0.012).translateY(0.6));ring.add(M(new THREE.CylinderGeometry(0.14,0.18,4.4,10),tm('#2e5a4a'),0.012).translateY(3));
  const ct=M(new THREE.BoxGeometry(1.1,1.1,1.1),tm('#2e5a4a'),0.015);ct.position.y=5.6;ring.add(ct);ring.add(M(new THREE.ConeGeometry(0.85,0.7,4),tm('#2e5a4a'),0.012).translateY(6.5).rotateY(Math.PI/4));
  const face=clk.material;for(let k=0;k<4;k++){const f=new THREE.Mesh(new THREE.CircleGeometry(0.42,20),face);const a=k*Math.PI/2;f.position.set(Math.sin(a)*0.56,5.6,Math.cos(a)*0.56);f.rotation.y=a;ring.add(f);}
  collide(E.cx-4.2,E.cx+4.2,E.cz-4.2,E.cz+4.2,'prop',ry+0.3);collide(E.cx-0.5,E.cx+0.5,E.cz-0.5,E.cz+0.5,'pole');
  // the bus stop with its shelter, the taxi rank with a taxi waiting
  { const x=51,z=188,y=G(x,z),g=new THREE.Group();g.position.set(x,y,z);world.add(g);
    g.add(M(new THREE.BoxGeometry(3.6,0.08,1.6),tm('#3a5a66'),0.012).translateY(2.4));for(const sx of [-1.6,1.6])g.add(M(new THREE.CylinderGeometry(0.05,0.05,2.4,6),tm('#3a5a66'),0).translateX(sx).translateY(1.2).translateZ(-0.6));
    g.add(M(new THREE.BoxGeometry(3.4,1.6,0.05),tm('#bcd6e0'),0.006).translateY(1.4).translateZ(-0.7));const b=benchMesh();b.position.set(0,0,-0.2);g.add(b);
    const pole=M(new THREE.CylinderGeometry(0.04,0.04,2.4,6),tm('#ddd'),0.006);pole.position.set(2.3,1.2,0.6);g.add(pole);
    const pl=new THREE.Mesh(new THREE.CircleGeometry(0.32,18),tmap(canvasTex(64,64,(c,w,h)=>{c.fillStyle='#2e7d4f';c.beginPath();c.arc(32,32,31,0,7);c.fill();c.fillStyle='#fff';c.font=signFont(14,true);c.textAlign='center';c.fillText('バス',32,30);c.font=signFont(9);c.fillText('のりば',32,44);}),{side:THREE.DoubleSide}));
    pl.position.set(2.3,2.5,0.6);g.add(pl);collide(x-1.8,x+1.8,z-0.8,z-0.5,'wall');collide(x+2.25,x+2.35,z+0.55,z+0.65,'pole');}
  { const x=76.5,z=180,y=G(x,z),car=new THREE.Group();car.position.set(x,y,z);car.rotation.y=Math.PI;world.add(car);const body=tm('#2b2b30');
    car.add(M(new THREE.BoxGeometry(1.7,0.7,4.2),body,0.02).translateY(0.6));const cab=M(new THREE.BoxGeometry(1.6,0.6,2.2),tm('#9cb4c0'),0.015);cab.position.set(0,1.2,-0.2);car.add(cab);
    car.add(M(new THREE.BoxGeometry(1.62,0.08,2.22),body,0).translateY(1.52).translateZ(-0.2));const lamp=M(new THREE.BoxGeometry(0.5,0.22,0.22),tm('#f2c230'),0.008);lamp.position.set(0,1.67,-0.2);car.add(lamp);
    for(const sx of [-0.86,0.86])for(const sz of [-1.35,1.35]){const w=M(new THREE.CylinderGeometry(0.3,0.3,0.22,12).rotateZ(Math.PI/2),tm('#1a1a1a'),0);w.position.set(sx,0.3,sz);car.add(w);}
    car.add(M(new THREE.BoxGeometry(1.72,0.1,4.22),tm('#e8a23a'),0).translateY(0.75));collide(x-0.9,x+0.9,z-2.1,z+2.1,'prop',y+1.5);}
  // bicycles in their rack, a phone box, vending machines, flower beds, lamps, the town map, benches
  { const rk=[];for(let k=0;k<7;k++)rk.push({x:48.6,z:191.5+k*0.75,c:pick(['#c8372d','#3a7bd5','#f2f2ee','#2b2b30','#4f9a5a','#f2c230'])});
    for(const b of rk){const g=new THREE.Group(),y=G(b.x,b.z);g.position.set(b.x,y,b.z);g.rotation.y=Math.PI/2;world.add(g);const fr=tm(b.c);
      for(const sx of [-0.5,0.5]){const w=M(new THREE.TorusGeometry(0.32,0.03,6,16),tm('#2b2b30'),0);w.position.set(sx,0.34,0);g.add(w);}
      const bar=M(new THREE.BoxGeometry(1.0,0.05,0.05),fr,0);bar.position.set(0,0.62,0);g.add(bar);const dn=M(new THREE.BoxGeometry(0.05,0.4,0.05),fr,0);dn.position.set(-0.1,0.45,0);g.add(dn);
      const sd=M(new THREE.BoxGeometry(0.22,0.05,0.1),tm('#2b2b30'),0);sd.position.set(-0.15,0.72,0);g.add(sd);const hb=M(new THREE.BoxGeometry(0.05,0.05,0.45),tm('#888'),0);hb.position.set(0.42,0.78,0);g.add(hb);}
    collide(48,49.3,191,196.6,'prop',G(48.6,194)+0.8);}
  { const x=81.2,z=199,y=G(x,z),g=new THREE.Group();g.position.set(x,y,z);g.rotation.y=-Math.PI/2;world.add(g);
    g.add(M(new THREE.BoxGeometry(0.9,2.3,0.9),tm('#4f9a5a'),0.015).translateY(1.15));const gl=new THREE.Mesh(new THREE.PlaneGeometry(0.7,1.5),tm('#cfe3ee'));gl.position.set(0,1.25,0.46);g.add(gl);
    const pt=new THREE.Mesh(new THREE.PlaneGeometry(0.7,0.18),tmap(canvasTex(64,16,(c,w,h)=>{c.fillStyle='#4f9a5a';c.fillRect(0,0,w,h);c.fillStyle='#fff';c.font=signFont(11,true);c.textAlign='center';c.fillText('公衆電話',w/2,12);})));pt.position.set(0,2.15,0.46);g.add(pt);
    collide(x-0.45,x+0.45,z-0.45,z+0.45,'prop',y+2.3);}
  vend(80.9,196.6,-Math.PI/2,true,'#d23a2c');vend(80.9,195.5,-Math.PI/2,false,'#2e5fa8');
  for(const x of [56.5,73.5]){const z=194.6,y=G(x,z),bed=M(new THREE.BoxGeometry(5,0.5,1.2),tm('#a39d90'),0.012);bed.position.set(x,y+0.25,z);world.add(bed);
    const s=M(new THREE.BoxGeometry(4.8,0.1,1.0),tm('#5a9a4a'),0);s.position.set(x,y+0.52,z);world.add(s);for(let k=0;k<8;k++){const f=new THREE.Mesh(new THREE.SphereGeometry(0.08,6,5),tm(['#e8452f','#f2c230','#f0a0b8','#a070d0'][k%4]));f.position.set(x-2.1+k*0.6,y+0.66,z+((k%2)-0.5)*0.4);world.add(f);}
    collide(x-2.5,x+2.5,z-0.6,z+0.6,'prop',y+0.5);}
  for(const [x,z] of [[49,176],[81,176],[49,198.5],[81,190]]){const y=G(x,z);world.add(M(new THREE.CylinderGeometry(0.07,0.09,4.6,8),tm('#3a5a66'),0.01).translateX(x).translateY(y+2.3).translateZ(z));
    const hd=M(new THREE.SphereGeometry(0.25,10,8),tm('#f2f2ee'),0.008);hd.position.set(x,y+4.7,z);world.add(hd);EKI_LAMPS.push({x,y:y+4.7,z});collide(x-0.12,x+0.12,z-0.12,z+0.12,'pole');}
  { const x=60,z=193.8,y=G(x,z),bd2=new THREE.Mesh(new THREE.PlaneGeometry(2.4,1.5),tmap(canvasTex(192,120,(c,w,h)=>{c.fillStyle='#24466e';c.fillRect(0,0,w,h);c.fillStyle='#fffaf0';c.fillRect(6,22,w-12,h-28);
      c.fillStyle='#fffaf0';c.font=signFont(14,true);c.textAlign='center';c.fillText('うみまち 観光案内',w/2,16);c.fillStyle='#8fc4e0';c.fillRect(6,h-30,w-12,24);c.fillStyle='#b8d8a8';c.fillRect(6,22,w-12,30);
      c.fillStyle='#c9c2b4';c.fillRect(w/2-3,22,6,h-52);c.fillRect(6,60,w-12,5);c.fillRect(6,82,w-12,4);c.fillStyle='#d8452f';c.fillRect(30,30,10,8);c.fillStyle='#2e7d4f';c.fillRect(120,84,24,6);
      c.fillStyle='#2b2520';c.font=signFont(9);c.textAlign='left';c.fillText('神社',42,38);c.fillText('商店街',110,58);c.fillText('駅',148,80);c.fillText('海',90,h-12);c.fillStyle='#d8452f';c.beginPath();c.arc(132,87,4,0,7);c.fill();})));
    bd2.position.set(x,y+1.55,z);bd2.rotation.y=Math.PI;world.add(bd2);for(const sx of [-1.1,1.1])world.add(M(new THREE.BoxGeometry(0.1,1.6,0.1),tm('#24466e'),0.006).translateX(x+sx).translateY(y+0.8).translateZ(z+0.05));
    collide(x-1.25,x+1.25,z-0.1,z+0.15,'wall');}
  for(const x of [69.5,72.5]){const b=benchMesh();b.position.set(x,G(x,193.2),193.2);b.rotation.y=Math.PI;world.add(b);collide(x-0.8,x+0.8,193,193.5,'prop',G(x,193.2)+0.5);}
}
/* ---------- the beach ---------- */
{ // sea wall with openings, steps down to the sand
  const gaps=[[-84,-75],[34,46],[-166,-154],[154,166],[-8,8]];let x0=-300;const segs=[];
  for(const [a,b] of gaps){segs.push([x0,a]);x0=b;}segs.push([x0,300]);
  const wallM=tmap(canvasTex(64,32,(g,w,h)=>{g.fillStyle='#d4cfc4';g.fillRect(0,0,w,h);g.fillStyle='rgba(0,0,0,.12)';g.fillRect(0,0,w,3);for(let x=0;x<w;x+=32)g.fillRect(x,0,1.5,h);},true));
  for(const [a,b] of segs){const m=M(new THREE.BoxGeometry(b-a,0.75,0.4),wallM,0.02);m.position.set((a+b)/2,0.37,SHORE-0.1);m.receiveShadow=true;world.add(m);collide(a,b,SHORE-0.3,SHORE+0.1,'wall',0.76);}
}
const PARASOLS=[];for(let k=0;k<16;k++){const x=-200+rnd()*400;if(Math.abs(x+80)<6)continue;PARASOLS.push({x,z:SHORE+9+rnd()*16,c:pick(['#e2584a','#3a7bd5','#f2c230','#4f9a5a','#f0a0b8'])});}
for(const p of PARASOLS){const g=new THREE.Group();g.position.set(p.x,G(p.x,p.z),p.z);g.rotation.set((rnd()-.5)*0.2,rnd()*6,(rnd()-.5)*0.2);
  g.add(M(new THREE.CylinderGeometry(0.03,0.03,2.3,6),tm('#f2f2ee')).translateY(1.15));
  const top=M(new THREE.ConeGeometry(1.25,0.5,10,1,true),tmap(canvasTex(128,32,(c,w,h)=>{for(let k=0;k<10;k++){c.fillStyle=k%2?'#fffaf0':p.c;c.fillRect(k*w/10,0,w/10,h);}}),{side:THREE.DoubleSide}),0);top.position.y=2.3;g.add(top);
  const towel=new THREE.Mesh(new THREE.PlaneGeometry(0.8,1.7).rotateX(-Math.PI/2),tm(pick(['#f2c9c4','#9cc3e6','#f5e07a','#c9e0b8'])));towel.position.set(0.9,0.03,0.4);g.add(towel);world.add(g);collide(p.x-0.1,p.x+0.1,p.z-0.1,p.z+0.1,'pole');}
const BEACHHOUSE={x:40,z:SHORE+10};
{ const x=BEACHHOUSE.x,z=BEACHHOUSE.z,y=G(x,z),g=new THREE.Group();g.position.set(x,y,z);world.add(g);const wood=tm('#b08a5e');
  g.add(M(new THREE.BoxGeometry(10,0.3,6),tm('#9a7a52'),0.02).translateY(0.15));
  for(const [px,pz] of [[-4.8,-2.8],[4.8,-2.8],[-4.8,2.8],[4.8,2.8],[0,-2.8],[0,2.8]])g.add(M(new THREE.BoxGeometry(0.16,3,0.16),wood,0.01).translateX(px).translateY(1.5).translateZ(pz));
  const rf=M(new THREE.BoxGeometry(10.6,0.16,6.6),tmap(canvasTex(128,64,(c,w,h)=>{for(let k=0;k<8;k++){c.fillStyle=k%2?'#e2584a':'#fffaf0';c.fillRect(k*w/8,0,w/8,h);}})),0.03);rf.position.y=3.1;rf.castShadow=true;g.add(rf);
  g.add(M(new THREE.BoxGeometry(9.6,2.4,0.1),tm('#c9a06a'),0.01).translateY(1.5).translateZ(-2.85));
  const ban=new THREE.Mesh(new THREE.PlaneGeometry(4,0.8),tmap(canvasTex(256,64,(c,w,h)=>{c.fillStyle='#24466e';c.fillRect(0,0,w,h);c.fillStyle='#fffaf0';c.font=signFont(34,true);c.textAlign='center';c.textBaseline='middle';c.fillText('海の家 なぎさ',w/2,h/2+1);}),{side:THREE.DoubleSide}));
  ban.position.set(0,2.7,3.32);g.add(ban);
  const kakigori=new THREE.Mesh(new THREE.PlaneGeometry(0.8,1.1),tmap(canvasTex(64,96,(c,w,h)=>{c.fillStyle='#fffaf0';c.fillRect(0,0,w,h);c.fillStyle='#d23a2c';c.font='900 56px "Zen Maru Gothic", serif';c.textAlign='center';c.textBaseline='middle';c.fillText('氷',w/2,h/2-6);
    c.fillStyle='#3a7bd5';for(let x=0;x<w;x+=12){c.beginPath();c.arc(x+6,h-8,6,Math.PI,0);c.fill();}}),{side:THREE.DoubleSide}));
  const fp=new THREE.Group();fp.add(M(new THREE.CylinderGeometry(0.03,0.03,2.6,6),tm('#ddd')).translateY(1.3));kakigori.position.set(0.42,2.0,0);fp.add(kakigori);fp.position.set(-5.6,0,3.2);g.add(fp);
  for(const u of [-2.5,0,2.5]){g.add(M(new THREE.BoxGeometry(1.4,0.06,0.7),wood,0.01).translateX(u).translateY(0.72).translateZ(0.6));}
  for(let k=0;k<3;k++){const sb=M(new THREE.CylinderGeometry(0.26,0.26,2.1,12),tm(['#f2c230','#3a7bd5','#e2584a'][k]),0.015);sb.scale.set(1,1,0.22);sb.position.set(5.4,1.05,-1.6+k*0.7);sb.rotation.z=0.18;g.add(sb);}
  collide(x-5,x+5,z-3,z-2.6,'wall');
}
{ // lifeguard chair and boats pulled up on the sand
  const x=-20,z=SHORE+20,g=new THREE.Group();g.position.set(x,G(x,z),z);world.add(g);const w=tm('#f2f2ee');
  for(const [a,b] of [[-0.6,-0.6],[0.6,-0.6],[-0.6,0.6],[0.6,0.6]])g.add(M(new THREE.BoxGeometry(0.1,2.4,0.1),w,0.01).translateX(a).translateY(1.2).translateZ(b));
  g.add(M(new THREE.BoxGeometry(1.4,0.1,1.4),w,0.015).translateY(2.4));g.add(M(new THREE.BoxGeometry(1.3,0.8,0.08),tm('#d23a2c'),0.01).translateY(2.85).translateZ(-0.62));
  collide(x-0.8,x+0.8,z-0.8,z+0.8,'prop',G(x,z)+2.45);
  for(let k=0;k<3;k++){const bx=-118+k*6,bz=SHORE+12+k*2,b=new THREE.Group();b.position.set(bx,G(bx,bz)+0.35,bz);b.rotation.set(0,0.5+k*0.3,0.08);
    const hull=M(new THREE.CylinderGeometry(0.9,0.5,6,10,1,false,0,Math.PI),tm(['#f4f2ec','#2e5fa8','#f2f2ee'][k]),0.03);hull.rotation.set(Math.PI/2,0,Math.PI);b.add(hull);
    b.add(new THREE.Mesh(new THREE.BoxGeometry(1.4,0.05,5.4),tm('#b08a5e')).translateY(0.05));world.add(b);collide(bx-2.5,bx+2.5,bz-1.2,bz+1.2,'prop');}
  const buoys=[];for(let k=0;k<14;k++)buoys.push({x:-200+k*30+rnd()*8,z:SHORE+58+rnd()*6});
  inst(new THREE.SphereGeometry(0.35,10,8),tm('#f29a2e'),buoys,(e,d)=>{d.position.set(e.x,SEA_Y+0.15,e.z);},{ol:0.02});
}
{ // the pier
  const deck=tmap(canvasTex(64,64,(g,w,h)=>{g.fillStyle='#a88a64';g.fillRect(0,0,w,h);g.fillStyle='rgba(60,40,20,.35)';for(let y=0;y<h;y+=8)g.fillRect(0,y,w,1.5);},true));
  const n=Math.ceil((PIER.z1-PIER.z0)/2)+1;
  grid(n,2,(r,c)=>{const z=PIER.z0+Math.min(r*2,PIER.z1-PIER.z0),x=c?PIER.x1:PIER.x0;return[x,G((PIER.x0+PIER.x1)/2,z)+0.02,z,c*2,z/4];},deck,{shadow:true});
  const posts=[];for(let z=PIER.z0+8;z<PIER.z1;z+=4)for(const x of [PIER.x0+0.2,PIER.x1-0.2])posts.push({x,z});
  inst(new THREE.CylinderGeometry(0.16,0.16,3,8),tm('#6b4a36'),posts,(e,d)=>{d.position.set(e.x,PIER.y-1.4,e.z);});
  const rl=[];for(let z=PIER.z0+8;z<PIER.z1;z+=2)for(const x of [PIER.x0+0.1,PIER.x1-0.1])rl.push({x,z});
  inst(new THREE.BoxGeometry(0.08,0.9,0.08),tm('#8a6a4c'),rl,(e,d)=>{d.position.set(e.x,PIER.y+0.45,e.z);});
  for(const x of [PIER.x0+0.1,PIER.x1-0.1]){const m=M(new THREE.BoxGeometry(0.1,0.08,PIER.z1-PIER.z0-8),tm('#8a6a4c'),0.01);m.position.set(x,PIER.y+0.9,(PIER.z0+8+PIER.z1)/2);world.add(m);}
  const lamp=new THREE.Group();lamp.add(M(new THREE.CylinderGeometry(0.07,0.07,3,8),tm('#f2f2ee'),0.01).translateY(1.5));lamp.add(M(new THREE.CylinderGeometry(0.25,0.25,0.5,10),tm('#d23a2c'),0.015).translateY(3.2));
  lamp.position.set(PIER.x0+0.6,PIER.y,PIER.z1-0.8);world.add(lamp);
}
{ // the cape to the west and east, mountains behind (the island with its lighthouse is p5m_shima.js)
  const cape=[[-760,420,260,70,180],[-620,560,220,50,140],[-900,300,240,90,200],[700,520,260,60,170],[860,380,220,80,200]];
  for(const [x,z,sx,sy,sz] of cape){const m=new THREE.Mesh(new THREE.SphereGeometry(1,24,12),tm('#4f8a4a'));m.scale.set(sx,sy,sz);m.position.set(x,SEA_Y-8,z);world.add(m);}
  for(let k=0;k<9;k++){const m=new THREE.Mesh(new THREE.ConeGeometry(1,1,10),tm(pick(['#5a8f6a','#6a9a78','#4f8460'])));const s=180+rnd()*200;m.scale.set(s,90+rnd()*90,s);m.position.set(-900+k*230+rnd()*80,40,-560-rnd()*300);world.add(m);}
}

/* ---------- the edges of the world: cuttings, tunnel portals, rocky ends of the beach, hill houses ---------- */
{ const PX=CUT_X,bz=z=>z<COAST_Z?(COAST_Z-z)*HILL:0;
  // retaining walls along the cuttings the tram and the coast road take through the hills
  const rw=[];for(const sg of [-1,1])for(let x=200;x<PX;x+=4){const xm=sg*(x+2),hh=hillY(x+2,TRAM_Z)+0.6;
    for(const z of [TRAM_Z-6.6,TRAM_Z+6.6,232.4])rw.push({x:xm,z,h:hh});}
  inst(boxG,tmap(stone,{color:'#c9c2b4'}),rw,(e,d)=>{d.position.set(e.x,bz(e.z)+e.h/2-0.3,e.z);d.scale.set(4.05,e.h+0.6,0.7);},{recv:true});
  for(const r of rw)collide(r.x-2,r.x+2,r.z-0.35,r.z+0.35,'wall');
  // concrete portals: the tram line and the coast road disappear into the hills
  const conc=tmap(canvasTex(64,64,(g,w,h)=>{g.fillStyle='#c4c0b8';g.fillRect(0,0,w,h);g.fillStyle='rgba(0,0,0,.08)';for(let y=0;y<h;y+=16)g.fillRect(0,y,w,1.5);g.fillStyle='rgba(80,70,60,.12)';g.fillRect(10,30,6,20);},true));
  const dark=new THREE.MeshBasicMaterial({color:'#0e0d0c'});
  for(const sg of [-1,1])for(const [zc,wd,ht,label] of [[TRAM_Z,8,6,'うみまち線'],[COAST_Z+1.1,14.4,7,'海岸トンネル']]){
    const g=new THREE.Group();g.position.set(sg*PX,bz(zc)-0.05,zc);g.rotation.y=sg>0?-Math.PI/2:Math.PI/2;world.add(g);
    const top=ht+3.2,side=3;
    for(const s of [-1,1]){const p=M(new THREE.BoxGeometry(side,top,1.6),conc,0.03);p.position.set(s*(wd/2+side/2),top/2,0);g.add(p);}
    const lin=M(new THREE.BoxGeometry(wd,top-ht,1.6),conc,0.03);lin.position.set(0,ht+(top-ht)/2,0);g.add(lin);
    for(const s of [-1,1]){const h=M(new THREE.BoxGeometry(0.9,0.9,1.7),conc,0.02);h.position.set(s*(wd/2-0.3),ht-0.3,0);h.rotation.z=Math.PI/4;g.add(h);}
    const hole=new THREE.Mesh(new THREE.PlaneGeometry(wd,ht+wd*0.15),dark);hole.position.set(0,(ht+wd*0.15)/2,-0.3);g.add(hole);
    const plate=new THREE.Mesh(new THREE.PlaneGeometry(3.2,0.7),tmap(canvasTex(256,56,(c,w,h)=>{c.fillStyle='#3a3a3a';c.fillRect(0,0,w,h);c.fillStyle='#f2f2ee';c.font=signFont(30,true);c.textAlign='center';c.textBaseline='middle';c.fillText(label,w/2,h/2+1);})));
    plate.position.set(0,ht+1.6,0.82);g.add(plate);
    const pc=sg*(PX+1.5);collide(pc-1.6,pc+1.6,zc-wd/2-1,zc+wd/2+1,'wall');}
  // the ends of the beach: rocks and wave-breaking blocks in the surf
  const rocks=[];for(let k=0;k<70;k++){const sg=rnd()<0.5?-1:1,x=sg*(196+rnd()*70),z=SHORE+2+rnd()*58;rocks.push({x,z,s:1.5+rnd()*4,col:C3(pick(['#8a8072','#9a9082','#7a7064']))});}
  inst(new THREE.DodecahedronGeometry(1,0),tm('#ffffff'),rocks,(e,d)=>{d.position.set(e.x,Math.max(G(e.x,e.z),SEA_Y)+e.s*0.25,e.z);d.rotation.set(rnd(),rnd()*6,rnd());d.scale.set(e.s,e.s*0.8,e.s);},{cast:true});
  // tetrapods: four cones from one centre, merged into one geometry
  const tetra=(()=>{const parts=[],dirs=[[0,1,0],[0.943,-0.333,0],[-0.471,-0.333,0.816],[-0.471,-0.333,-0.816]];
    for(const d of dirs){const c=new THREE.CylinderGeometry(0.18,0.42,1.3,8).translate(0,0.65,0).toNonIndexed();const q=new THREE.Quaternion().setFromUnitVectors(new THREE.Vector3(0,1,0),new THREE.Vector3(...d));c.applyMatrix4(new THREE.Matrix4().makeRotationFromQuaternion(q));parts.push(c);}
    const n=parts.reduce((a,p)=>a+p.attributes.position.count,0),pos=new Float32Array(n*3);let o=0;for(const p of parts){pos.set(p.attributes.position.array,o);o+=p.attributes.position.array.length;}
    const g=new THREE.BufferGeometry();g.setAttribute('position',new THREE.BufferAttribute(pos,3));g.computeVertexNormals();return g;})();
  const tps=[];for(const sg of [-1,1])for(let k=0;k<46;k++){const x=sg*(120+rnd()*95),z=SHORE+(0-SEA_Y)/0.035+4+rnd()*10;tps.push({x,z});}
  inst(tetra,tm('#bdb8ae'),tps,(e,d)=>{d.position.set(e.x,SEA_Y+0.3+rnd()*0.4,e.z);d.rotation.set(rnd()*6,rnd()*6,rnd()*6);d.scale.setScalar(1.1+rnd()*0.4);},{cast:true,ol:0.04});
  // lookout decks on the ridges, reached by riding up through the woods
  for(const d of RIDGE_DECKS){const y=G(d.x,d.z)+0.35,g=new THREE.Group();g.position.set(d.x,0,d.z);g.rotation.y=d.yaw;world.add(g);
    const pt=canvasTex(64,64,(c,w,h)=>{c.fillStyle='#a77b52';c.fillRect(0,0,w,h);c.fillStyle='rgba(60,35,15,.35)';for(let x=0;x<w;x+=10)c.fillRect(x,0,1.5,h);},true);pt.repeat.set(3,3);const plank=tmap(pt);
    const deck=M(new THREE.BoxGeometry(9,0.3,7),[tm('#8a6340'),tm('#8a6340'),plank,tm('#8a6340'),tm('#8a6340'),tm('#8a6340')],0.03);deck.position.y=y-0.15;g.add(deck);
    const legs=M(new THREE.BoxGeometry(8.6,4,6.6),tm('#6b4a30'),0);legs.position.y=y-2.3;g.add(legs);
    for(let k=0;k<7;k++){const p=M(new THREE.BoxGeometry(0.12,1,0.12),tm('#7a5638'),0.01);p.position.set(-4.4+k*1.47,y+0.5,3.4);g.add(p);}
    const rail=M(new THREE.BoxGeometry(9,0.1,0.14),tm('#7a5638'),0.01);rail.position.set(0,y+1.0,3.4);g.add(rail);
    const bench=benchMesh();bench.position.set(-1.6,y,1.8);bench.rotation.y=Math.PI;g.add(bench);
    const scope=new THREE.Group();scope.position.set(2.2,y,2.6);g.add(scope);scope.add(M(new THREE.CylinderGeometry(0.06,0.09,1.1,8),tm('#3a6e8a'),0.01).translateY(0.55));
    const eye=M(new THREE.CylinderGeometry(0.12,0.16,0.5,10),tm('#3a6e8a'),0.01);eye.rotation.x=Math.PI/2-0.25;eye.position.y=1.25;scope.add(eye);
    const sign=new THREE.Mesh(new THREE.PlaneGeometry(1.8,0.6),tmap(canvasTex(192,64,(c,w,h)=>{c.fillStyle='#f4efe2';c.fillRect(0,0,w,h);c.strokeStyle='#6b4a30';c.lineWidth=5;c.strokeRect(3,3,w-6,h-6);c.fillStyle='#4a3424';c.font=signFont(28,true);c.textAlign='center';c.textBaseline='middle';c.fillText(d.name,w/2,h/2+1);})));
    sign.position.set(3.6,y+1.4,-3.3);sign.rotation.y=Math.PI;g.add(sign);const sp=M(new THREE.BoxGeometry(0.1,1.4,0.1),tm('#6b4a30'),0.01);sp.position.set(3.6,y+0.7,-3.4);g.add(sp);
    const c=Math.abs(Math.cos(d.yaw)),s2=Math.abs(Math.sin(d.yaw)),hx=4.5*c+3.5*s2,hz=4.5*s2+3.5*c;collide(d.x-hx,d.x+hx,d.z-hz,d.z+hz,'deck',y);}
  // wooded hills either side of the town: round broadleaf crowns mixed with dark cedars, and a radio mast
  const woods=[];for(let k=0;k<460;k++){const sg=rnd()<0.5?-1:1,x=sg*(205+Math.pow(rnd(),0.8)*140),z=-205+rnd()*425;
    if(Math.abs(z-TRAM_Z)<8.5||(z>230&&z<250))continue;
    woods.push({x,z,y:H(x,z),s:2+rnd()*2.4,cedar:rnd()<0.33,lean:(rnd()-.5)*0.2,col:C3(pick(['#3f6e3c','#4b7d43','#5a8a4a','#365f36','#6a944f']))});}
  // keep the ridge decks and the rock door of 海街自警団 (228,-60; p5p_rescue.js) clear, and give every trunk a collider
  for(let i=woods.length-1;i>=0;i--){const e=woods[i];if(RIDGE_DECKS.some(d=>Math.hypot(e.x-d.x,e.z-d.z)<11)||inDeckView(e.x,e.z)||Math.hypot(e.x-228,e.z+60)<15)woods.splice(i,1);}
  for(const e of woods){const r=0.12*e.s;collide(e.x-r,e.x+r,e.z-r,e.z+r,'tree');HILL_TREES.push(e);}
  const broad=woods.filter(e=>!e.cedar),ced=woods.filter(e=>e.cedar);
  inst(new THREE.CylinderGeometry(0.16,0.26,1,6).translate(0,0.5,0),tm('#6b4a36'),woods.map(e=>({...e,col:null})),(e,d)=>{d.position.set(e.x,e.y-0.3,e.z);d.scale.set(e.s*0.5,e.s*1.2,e.s*0.5);});
  for(const k of [0,1])inst(CANOPY[k],LEAF,broad.filter((e,i)=>i%2===k),(e,d)=>{d.position.set(e.x,e.y+e.s*1.45,e.z);d.scale.set(e.s*0.85,e.s*0.78,e.s*0.85);d.rotation.set(e.lean,e.s*3,0);},{cast:true});
  inst(CEDAR,NEEDLE,ced.map(e=>({...e,col:e.col.clone().multiplyScalar(0.72)})),(e,d)=>{d.position.set(e.x,e.y+e.s*0.45,e.z);d.scale.set(e.s*0.85,e.s*2.7,e.s*0.85);d.rotation.set(0,e.s*5,e.lean*0.5);},{cast:true});
  const mx=-285,mz=-40,my=H(mx,mz),mast=new THREE.Group();mast.position.set(mx,my,mz);world.add(mast);
  for(let k=0;k<8;k++){const s=new THREE.Mesh(new THREE.CylinderGeometry(1.2-k*0.13,1.33-k*0.13,5,6,1,true),tm(k%2?'#f2f2ee':'#d8452f',{side:THREE.DoubleSide}));s.position.y=2.5+k*5;mast.add(s);}
  mast.add(new THREE.Mesh(new THREE.SphereGeometry(0.4,8,6),new THREE.MeshBasicMaterial({color:'#ff4030'})).translateY(41));
}

/* ---------- things to jump onto ---------- */
// a crate stack on the platform leads up onto the station shelter roof
{ const y=G(65,206)+0.86;const crate=tmap(canvasTex(64,64,(g,w,h)=>{g.fillStyle='#b08a5e';g.fillRect(0,0,w,h);g.fillStyle='rgba(60,40,20,.4)';for(let k=0;k<4;k++)g.fillRect(0,k*16,w,2);g.strokeStyle='rgba(60,40,20,.5)';g.lineWidth=3;g.strokeRect(2,2,w-4,h-4);}));
  const steps=[[49.6,0.7],[51.0,1.4],[52.4,2.1],[53.8,2.8]];
  for(const [x,h] of steps){const m=M(new THREE.BoxGeometry(1.3,h,1.3),crate,0.02);m.position.set(x,y+h/2,205.4);world.add(m);collide(x-0.65,x+0.65,205.4-0.65,205.4+0.65,'crate',y+h);}
  collide(55,69,203.9,207.3,'roof',y+2.74+0.075);
}
// a flat rooftop with a view, up a staircase of crates
const ROOF={x0:18,x1:30,z0:186,z1:196};
{ const base=Math.max(H(ROOF.x0,ROOF.z0),H(ROOF.x0,ROOF.z1))+0.1,top=base+3.2,cx=(ROOF.x0+ROOF.x1)/2,cz=(ROOF.z0+ROOF.z1)/2,W=ROOF.x1-ROOF.x0,D=ROOF.z1-ROOF.z0;
  const wall=nightMat(facadeTex('house1','',77)),side=SIDE[1];
  const b=new THREE.Mesh(boxG,[side,side,tm('#b9b4ab'),under,side,wall]);b.scale.set(W,3.2,D);b.position.set(cx,base+1.6,cz);b.receiveShadow=true;world.add(b);boxEdges(cx,base,cz,0,W,3.2,D);
  const lowY=Math.min(H(ROOF.x0,ROOF.z1),H(ROOF.x1,ROOF.z1))-0.4;const f=new THREE.Mesh(boxG,tmap(stone));f.scale.set(W,base-lowY,D);f.position.set(cx,(base+lowY)/2,cz);world.add(f);
  collide(ROOF.x0,ROOF.x1,ROOF.z0,ROOF.z1,'roof',top);
  const railM=tmap(railTex,{transparent:true,side:THREE.DoubleSide,alphaTest:0.4});
  for(const [x,z,w,yaw] of [[cx,ROOF.z1-0.05,W,0],[ROOF.x1-0.05,cz,D,Math.PI/2],[cx,ROOF.z0+0.05,W*0.55,0]]){const r=new THREE.Mesh(new THREE.PlaneGeometry(w,1),railM);r.position.set(x+(w<W&&yaw===0?W*0.22:0),top+0.5,z);r.rotation.y=yaw;world.add(r);}
  collide(ROOF.x0,ROOF.x1,ROOF.z1-0.15,ROOF.z1+0.05,'wall');collide(ROOF.x1-0.15,ROOF.x1+0.05,ROOF.z0,ROOF.z1,'wall');
  const bench=benchMesh();bench.position.set(cx+1.5,top,ROOF.z1-1.2);world.add(bench);
  for(const [x,z] of [[ROOF.x1-1,ROOF.z0+1],[ROOF.x1-1.8,ROOF.z0+1]]){const p=new THREE.Group();p.add(M(new THREE.CylinderGeometry(0.25,0.2,0.4,10),tm('#a5603e'),0.01).translateY(0.2));p.add(M(new THREE.SphereGeometry(0.38,10,8),tm('#4f8a3a'),0.012).translateY(0.65));p.position.set(x,top,z);world.add(p);}
  for(let k=0;k<4;k++){const l=new THREE.Mesh(new THREE.PlaneGeometry(0.5,0.6),tm(pick(['#ffffff','#9cc3e6','#f2c9c4','#f5e07a']),{side:THREE.DoubleSide}));l.position.set(ROOF.x0+2+k*0.7,top+1.4,cz-1.5);world.add(l);}
  const rod=new THREE.Mesh(new THREE.BoxGeometry(3.4,0.04,0.04),tm('#9a9aa2'));rod.position.set(ROOF.x0+3,top+1.72,cz-1.5);world.add(rod);
  const crate=tmap(canvasTex(64,64,(g,w,h)=>{g.fillStyle='#b08a5e';g.fillRect(0,0,w,h);g.fillStyle='rgba(60,40,20,.4)';for(let k=0;k<4;k++)g.fillRect(0,k*16,w,2);g.strokeStyle='rgba(60,40,20,.5)';g.lineWidth=3;g.strokeRect(2,2,w-4,h-4);}));
  const gz=ROOF.z0-0.2;let k=0;for(const [x,h] of [[ROOF.x0+1.0,0.75],[ROOF.x0+2.4,1.5],[ROOF.x0+3.8,2.25]]){const y0=G(x,gz-0.7),hh=h+(base-y0);
    const m=M(new THREE.BoxGeometry(1.35,hh,1.35),crate,0.02);m.position.set(x,y0+hh/2,gz-0.7);world.add(m);collide(x-0.68,x+0.68,gz-1.38,gz-0.02,'crate',y0+hh);k++;}
}
