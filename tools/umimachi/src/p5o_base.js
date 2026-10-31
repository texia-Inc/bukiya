
/* ---------- the extra story: Oceangate's base inside the west hill, behind the iron door by the west tunnel. It lies far off to
   the west of the map, as the country lies to the east (x around BASE_X; G() is flat here and the town is hidden).
   Nagi slips past the guards to the monitoring room — a guard sees what is in front of him (the pale fan on the floor) but not
   round a corner or behind a crate, and hears the board close by — then, with the alarm going, she skates out along the east
   passage before the shutters come down. Local coordinates lx, lz are measured from (BASE_X, 0). ---------- */
const BASE={g:new THREE.Group(),map:document.createElement('canvas'),guards:[],shut:[],strips:[],sneak:null,run:null};scene.add(BASE.g);BASE.g.visible=false;
const BASE_H=6;
// the rooms as floor rectangles [lx0, lx1, lz0, lz1]: the entrance, corridor A with three alcoves, the warehouse, the monitoring
// room off its north side, and the long east passage with the shutters
const BASE_FLOOR=[[0,12,-6,6],[12,92,-3,3],[28,32,3,6],[48,52,-6,-3],[68,72,3,6],[92,132,-20,20],[117,123,-22,-20],[110,130,-34,-22],[132,238,12,18]];
const BASE_START=[8,0,Math.PI/2],BASE_WARE=[95,0,Math.PI/2],BASE_TERM=[120,-31],BASE_DOOR=[120,-17,0.35],BASE_END=236.5;
const BASE_SHUT=[{x:152,t:7},{x:177,t:9.2},{x:202,t:11.4},{x:227,t:13.6}];
const inBaseFloor=(x,z)=>BASE_FLOOR.some(r=>x>=r[0]&&x<r[1]&&z>=r[2]&&z<r[3]);
function baseG(){return 0;}
{ const X0=-2,X1=240,Z0=-36,Z1=20,W=X1-X0,N=Z1-Z0,fl=(i,j)=>i>=0&&j>=0&&i<W&&j<N&&inBaseFloor(X0+i+0.5,Z0+j+0.5),wall=new Uint8Array(W*N);
  for(let j=0;j<N;j++)for(let i=0;i<W;i++){if(fl(i,j))continue;let n=false;for(let dj=-1;dj<=1;dj++)for(let di=-1;di<=1;di++)if(fl(i+di,j+dj))n=true;if(n)wall[j*W+i]=1;}
  // the wall cells merged into boxes: runs along x in each row, carried on down while the next row has the same run
  const runs=[];let open=new Map();
  for(let j=0;j<N;j++){const next=new Map();
    for(let i=0;i<W;){if(!wall[j*W+i]){i++;continue;}let k=i;while(k<W&&wall[j*W+k])k++;const key=i+','+k,r=open.get(key);
      if(r){r.j1=j+1;next.set(key,r);}else{const o={a:i,b:k,j0:j,j1:j+1};runs.push(o);next.set(key,o);}i=k;}
    open=next;}
  const wm=new THREE.InstancedMesh(new THREE.BoxGeometry(1,1,1),new THREE.MeshToonMaterial({color:'#80868b',gradientMap:GRAD}),runs.length);
  runs.forEach((r,k)=>{const x0=BASE_X+X0+r.a,x1=BASE_X+X0+r.b,z0=Z0+r.j0,z1=Z0+r.j1;
    dummy.position.set((x0+x1)/2,BASE_H/2,(z0+z1)/2);dummy.rotation.set(0,0,0);dummy.scale.set(x1-x0,BASE_H,z1-z0);dummy.updateMatrix();wm.setMatrixAt(k,dummy.matrix);
    collide(x0,x1,z0,z1,'bld',BASE_H);});
  wm.frustumCulled=false;BASE.g.add(wm);
  // floor, ceiling, a yellow-and-black band along the foot of the walls
  const ft=canvasTex(128,128,(g,w,h)=>{g.fillStyle='#74797d';g.fillRect(0,0,w,h);g.strokeStyle='rgba(40,44,48,.35)';g.lineWidth=2;g.strokeRect(1,1,w-2,h-2);
    g.fillStyle='rgba(255,255,255,.05)';for(let k=0;k<40;k++)g.fillRect(Math.random()*w,Math.random()*h,3,3);},true);ft.repeat.set(W/4,N/4);
  const floor=new THREE.Mesh(new THREE.PlaneGeometry(W,N),tmap(ft));floor.rotation.x=-Math.PI/2;floor.position.set(BASE_X+X0+W/2,0.001,Z0+N/2);floor.receiveShadow=true;BASE.g.add(floor);
  const ceil=new THREE.Mesh(new THREE.PlaneGeometry(W,N),new THREE.MeshBasicMaterial({color:'#2a2d31'}));ceil.rotation.x=Math.PI/2;ceil.position.set(BASE_X+X0+W/2,BASE_H,Z0+N/2);BASE.g.add(ceil);
  // lights in the ceiling along the middle of each room
  const lm=new THREE.MeshBasicMaterial({color:'#fff6dc'});BASE.lightMat=lm;
  for(const [a,b,c,d] of BASE_FLOOR){if(b-a<6&&d-c<6)continue;const along=b-a>=d-c,n=Math.max(1,Math.floor((along?b-a:d-c)/8));
    for(let k=0;k<n;k++){const t=(k+0.5)/n,x=along?lerp(a,b,t):(a+b)/2,z=along?(c+d)/2:lerp(c,d,t),m=new THREE.Mesh(new THREE.BoxGeometry(along?2.4:0.5,0.08,along?0.5:2.4),lm);
      m.position.set(BASE_X+x,BASE_H-0.05,z);BASE.g.add(m);BASE.strips.push(m);}}
  // crates in the warehouse, clustered so that aisles run round and between them
  const cm=tm('#6b5a44'),cs=tm('#4e4132');
  for(const [x,z,s] of [[102,-12,2],[104,-9.6,2],[101.5,-6,2.2],[104,-2,2],[102,1,1.8],[103.5,4.5,2.2],[118,-12,2],[121,-11,2.2],[124,-12.5,2],[118,-6,2],[121.5,-5,2],[118.5,1,2.2],[122,2.5,2],[124.5,0.5,1.8],
    [96,15,2],[99,16,1.8],[129.5,-18,1.8],[95.5,-18,2]]){
    const b=new THREE.Mesh(new THREE.BoxGeometry(s,s,s),cm);b.position.set(BASE_X+x,s/2,z);b.rotation.y=(x*7%3)*0.1;b.castShadow=true;outline(b,0.03);BASE.g.add(b);
    const l=new THREE.Mesh(new THREE.BoxGeometry(s+0.04,0.14,s+0.04),cs);l.position.set(BASE_X+x,s*0.75,z);BASE.g.add(l);
    collide(BASE_X+x-s/2,BASE_X+x+s/2,z-s/2,z+s/2,'prop',s);}
  // the monitoring room: a desk, a wall of screens showing the town, and an old file
  const desk=new THREE.Mesh(new THREE.BoxGeometry(6,0.9,1.4),tm('#3a3d42'));desk.position.set(BASE_X+120,0.45,-32.4);BASE.g.add(desk);collide(BASE_X+117,BASE_X+123,-33.1,-31.7,'prop',0.9);
  const scr=['灯台','桟橋','神社','海岸通り','境界 B-7','境界 B-8'];
  scr.forEach((t,k)=>{const c=canvasTex(160,100,(g,w,h)=>{g.fillStyle=k>=4?'#0c1418':'#123040';g.fillRect(0,0,w,h);g.strokeStyle=k>=4?'#ff4030':'#7fd0ff';g.lineWidth=3;g.strokeRect(3,3,w-6,h-6);
      if(k>=4){g.fillStyle='rgba(255,64,48,.5)';g.beginPath();g.arc(w/2,h/2+6,18,0,7);g.fill();}
      g.fillStyle='#e8f6ff';g.font=signFont(16,true);g.fillText(t,10,22);g.font='12px monospace';g.fillText('CAM '+(k+1),w-58,h-10);});
    const m=new THREE.Mesh(new THREE.PlaneGeometry(1.8,1.12),new THREE.MeshBasicMaterial({map:c}));m.position.set(BASE_X+115+(k%3)*2+(k>=3?0:0),1.6+(k>=3?1.25:0)+0.3,-33.9);
    m.position.x=BASE_X+118+(k%3)*2-1;BASE.g.add(m);});
  const file=new THREE.Mesh(new THREE.BoxGeometry(0.45,0.05,0.6),tm('#c8b27a'));file.position.set(BASE_X+120,0.93,-32);file.rotation.y=0.3;BASE.g.add(file);
  BASE.glint=glow('#bfefff',BASE_X+120,1.4,-32,1.3);
  // the shutters of the east passage: up in the ceiling until the alarm, then down one after another
  const sm=tm('#6e7378'),stripe=tm('#d8b030');
  for(const s of BASE_SHUT){const g=new THREE.Group();g.position.set(BASE_X+s.x,BASE_H,15);BASE.g.add(g);
    const p=new THREE.Mesh(new THREE.BoxGeometry(0.3,BASE_H,6),sm);p.position.y=BASE_H/2;g.add(p);
    const e=new THREE.Mesh(new THREE.BoxGeometry(0.34,0.3,6),stripe);e.position.y=0.15;g.add(e);
    s.g=g;s.c=collide(BASE_X+s.x-0.2,BASE_X+s.x+0.2,12,18,'bld',BASE_H);s.c.on=false;BASE.shut.push(s);}
  // the way out at the end of the east passage: an emergency door standing open on the night, the green sign above it
  { const X=BASE_X+237.95,fm=tm('#4a4f55'),sky=canvasTex(128,160,(g,w,h)=>{const gr=g.createLinearGradient(0,0,0,h);gr.addColorStop(0,'#0c1530');gr.addColorStop(0.75,'#1d2f5a');gr.addColorStop(1,'#2a3a40');
      g.fillStyle=gr;g.fillRect(0,0,w,h);g.fillStyle='#fff';for(let k=0;k<26;k++)g.fillRect(Math.random()*w,Math.random()*h*0.7,1.5,1.5);g.fillStyle='#1a2a1e';g.beginPath();g.moveTo(0,h);
      for(let x=0;x<=w;x+=16)g.lineTo(x,h*0.8-Math.sin(x*0.07)*8-Math.random()*5);g.lineTo(w,h);g.fill();});
    const out=new THREE.Mesh(new THREE.PlaneGeometry(2.2,2.8),new THREE.MeshBasicMaterial({map:sky,fog:false}));out.position.set(X,1.4,15);out.rotation.y=-Math.PI/2;BASE.g.add(out);
    for(const [w,h,z,y] of [[0.18,3.1,13.8,1.55],[0.18,3.1,16.2,1.55],[2.6,0.2,15,2.9]]){const m=new THREE.Mesh(new THREE.BoxGeometry(0.25,h,w),fm);m.position.set(X-0.05,y,z);BASE.g.add(m);}
    const leaf=new THREE.Mesh(new THREE.BoxGeometry(2.2,2.75,0.08),tm('#6e757c'));leaf.position.set(X-1.15,1.4,12.15);leaf.castShadow=true;outline(leaf,0.02);BASE.g.add(leaf);   // swung open against the wall
    const bar=new THREE.Mesh(new THREE.BoxGeometry(1.4,0.08,0.1),tm('#c9ced3'));bar.position.set(X-1.0,1.05,12.22);BASE.g.add(bar);
    const sign=canvasTex(256,96,(g,w,h)=>{g.fillStyle='#1e9a52';g.fillRect(0,0,w,h);g.fillStyle='#fff';g.fillRect(10,10,76,76);g.fillStyle='#1e9a52';
      g.beginPath();g.arc(48,24,7,0,7);g.fill();g.fillRect(40,33,14,26);g.save();g.translate(47,58);g.rotate(0.5);g.fillRect(-4,0,8,22);g.restore();g.save();g.translate(47,58);g.rotate(-0.6);g.fillRect(-4,0,8,22);g.restore();
      g.fillStyle='#fff';g.font=signFont(40,true);g.textBaseline='middle';g.fillText('非常口',100,h/2+2);});
    const sm=new THREE.Mesh(new THREE.PlaneGeometry(1.4,0.52),new THREE.MeshBasicMaterial({map:sign}));sm.position.set(X-0.08,3.45,15);sm.rotation.y=-Math.PI/2;BASE.g.add(sm);
    BASE.exitGlow=glow('#2fd27a',X-0.3,3.45,15,2.2);}
  // the map: the rooms in grey on dark
  const mc=BASE.map;mc.width=W;mc.height=N;const g=mc.getContext('2d');g.fillStyle='#3a3d42';g.fillRect(0,0,W,N);g.fillStyle='#b8bcc0';
  for(const [a,b,c,d] of BASE_FLOOR)g.fillRect(a-X0,c-Z0,b-a,d-c);BASE.mapX0=BASE_X+X0;BASE.mapZ0=Z0;}
// dressing the walls: wherever a room's edge has rock behind it, a darker lower panel with a hazard band at its foot, panel seams,
// pipes and a cable tray under the ceiling, a lamp now and then, closed doors along the corridors and signs at the turns
{ const X=BASE_X,segs=[],O=0.5;
  for(const [a,b,c,d] of BASE_FLOOR)for(const [x0,z0,x1,z1,nx,nz] of [[a,c,b,c,0,1],[a,d,b,d,0,-1],[a,c,a,d,1,0],[b,c,b,d,-1,0]]){
    const L=Math.hypot(x1-x0,z1-z0);let run=null;
    for(let u=0.5;u<L;u+=1){const x=x0+(x1-x0)*u/L,z=z0+(z1-z0)*u/L,wall=!inBaseFloor(x-nx*O,z-nz*O);
      if(wall){if(!run)run={u0:u-0.5};run.u1=u+0.5;}if((!wall||u+1>=L)&&run){if(run.u1-run.u0>=2)segs.push({x0:x0+(x1-x0)*run.u0/L,z0:z0+(z1-z0)*run.u0/L,x1:x0+(x1-x0)*run.u1/L,z1:z0+(z1-z0)*run.u1/L,nx,nz});run=null;}}}
  const band=canvasTex(64,16,(g,w,h)=>{for(let x=-16;x<w;x+=16){g.fillStyle='#e0b42a';g.fillRect(0,0,w,h);}g.fillStyle='#1d1e20';for(let x=-16;x<w+16;x+=16){g.beginPath();g.moveTo(x,h);g.lineTo(x+8,h);g.lineTo(x+16,0);g.lineTo(x+8,0);g.fill();}},true);
  const lowM=new THREE.MeshToonMaterial({color:'#5e656b',gradientMap:GRAD}),pipeA=tm('#5d6a73'),pipeB=tm('#8a6b3f'),tray=tm('#3e4348'),lampM=new THREE.MeshBasicMaterial({color:'#fff1c8'});
  const seamG=new THREE.BoxGeometry(0.07,BASE_H,0.05),seams=[],doors=[],lamps=[];
  for(const S of segs){const L=Math.hypot(S.x1-S.x0,S.z1-S.z0),mx=(S.x0+S.x1)/2,mz=(S.z0+S.z1)/2,ry=Math.atan2(S.nx,S.nz),off=(k)=>[mx+S.nx*k,mz+S.nz*k];
    const plane=(w,h,mat,y,k)=>{const m=new THREE.Mesh(new THREE.PlaneGeometry(w,h),mat);const [x,z]=off(k);m.position.set(X+x,y,z);m.rotation.y=ry;BASE.g.add(m);return m;};
    plane(L,2.3,lowM,1.15,0.012);
    const bt=band.clone();bt.needsUpdate=true;bt.repeat.set(L/1.2,1);plane(L,0.32,new THREE.MeshBasicMaterial({map:bt}),0.16,0.018);
    const along=new THREE.Vector3(S.x1-S.x0,0,S.z1-S.z0).normalize();
    for(const [r,y,k,mat] of [[0.13,4.7,0.3,pipeA],[0.08,5.05,0.5,pipeB]]){const m=new THREE.Mesh(new THREE.CylinderGeometry(r,r,L,8),mat);const [x,z]=off(k);m.position.set(X+x,y,z);
      m.quaternion.setFromUnitVectors(new THREE.Vector3(0,1,0),along);BASE.g.add(m);}
    { const m=new THREE.Mesh(new THREE.BoxGeometry(L,0.08,0.45),tray);const [x,z]=off(0.25);m.position.set(X+x,5.5,z);m.rotation.y=ry;BASE.g.add(m);}
    for(let u=1.5;u<L-0.5;u+=3)seams.push([S.x0+(S.x1-S.x0)*u/L+S.nx*0.02,S.z0+(S.z1-S.z0)*u/L+S.nz*0.02,ry]);
    for(let u=5;u<L-2;u+=10)lamps.push([S.x0+(S.x1-S.x0)*u/L+S.nx*0.12,S.z0+(S.z1-S.z0)*u/L+S.nz*0.12,ry]);
    if(L>=8)for(let u=7;u<L-3;u+=17)doors.push([S.x0+(S.x1-S.x0)*u/L+S.nx*0.03,S.z0+(S.z1-S.z0)*u/L+S.nz*0.03,ry]);}
  const im=new THREE.InstancedMesh(seamG,tm('#5a6066'),seams.length);seams.forEach(([x,z,r],k)=>{dummy.position.set(X+x,BASE_H/2,z);dummy.rotation.set(0,r,0);dummy.scale.set(1,1,1);dummy.updateMatrix();im.setMatrixAt(k,dummy.matrix);});
  im.frustumCulled=false;BASE.g.add(im);
  for(const [x,z,r] of lamps){const m=new THREE.Mesh(new THREE.BoxGeometry(0.5,0.18,0.12),lampM);m.position.set(X+x,3.4,z);m.rotation.y=r;BASE.g.add(m);
    const gl=glow('#ffe7b0',X+x,3.4,z,1.6);gl.visible=true;gl.material.opacity=0.45;scene.remove(gl);BASE.g.add(gl);}
  const doorTex=n=>canvasTex(96,160,(g,w,h)=>{g.fillStyle='#6e757c';g.fillRect(0,0,w,h);g.strokeStyle='#4a4f55';g.lineWidth=4;g.strokeRect(2,2,w-4,h-4);
    g.fillStyle='#22282e';g.fillRect(30,24,36,26);g.fillStyle='#c9ced3';g.fillRect(70,82,14,5);g.fillStyle='#e8e8e8';g.font='bold 14px monospace';g.fillText(n,30,120);});
  doors.forEach(([x,z,r],k)=>{const m=new THREE.Mesh(new THREE.PlaneGeometry(1.3,2.4),new THREE.MeshBasicMaterial({map:doorTex('B-'+(k+1))}));m.position.set(X+x,1.2,z);m.rotation.y=r;BASE.g.add(m);});
  // signs at the turns (each on the wall nearest its spot)
  const signTex=(t,bg,fg)=>canvasTex(256,64,(g,w,h)=>{g.fillStyle=bg;g.fillRect(0,0,w,h);g.fillStyle=fg;g.font=signFont(30,true);g.textAlign='center';g.textBaseline='middle';g.fillText(t,w/2,h/2+2);});
  for(const [t,lx,lz,bg,fg] of [['通路A',14,0,'#2b3a4a','#dfe8ef'],['第2倉庫',94,10,'#2b3a4a','#dfe8ef'],['監視室 →',112,-18,'#7a1e1e','#ffe8e0'],['立入禁止',60,0,'#e0b42a','#1d1e20'],['東通路　非常口 →',140,14,'#1e6a3a','#e8fff0']]){
    let best=null,bd=1e9;for(const S of segs){const L=Math.hypot(S.x1-S.x0,S.z1-S.z0),ax=S.x1-S.x0,az=S.z1-S.z0,u=clamp(((lx-S.x0)*ax+(lz-S.z0)*az)/(L*L),0.1,0.9),px=S.x0+ax*u,pz=S.z0+az*u,d=Math.hypot(px-lx,pz-lz);if(d<bd){bd=d;best=[px+S.nx*0.04,pz+S.nz*0.04,Math.atan2(S.nx,S.nz)];}}
    if(!best)continue;const m=new THREE.Mesh(new THREE.PlaneGeometry(1.8,0.45),new THREE.MeshBasicMaterial({map:signTex(t,bg,fg)}));m.position.set(X+best[0],2.95,best[1]);m.rotation.y=best[2];BASE.g.add(m);}}
// the guards: men in black on their beats; each carries the pale fan of what he can see
const BASE_BEATS=[[[24,0],[86,0]],[[98,-16],[127,-16],[127,9],[98,9]],[[111,10],[111,-15]],[[96,12],[128,12]]];
const FAN=(()=>{const R=13,A=0.62,n=12,pos=[0,0,0];for(let k=0;k<=n;k++){const a=-A+2*A*k/n;pos.push(Math.sin(a)*R,0,Math.cos(a)*R);}const idx=[];for(let k=1;k<=n;k++)idx.push(0,k,k+1);
  const g=new THREE.BufferGeometry();g.setAttribute('position',new THREE.Float32BufferAttribute(pos,3));g.setIndex(idx);return g;})();
function baseGuards(){if(BASE.guards.length)return;
  BASE_BEATS.forEach((pts,k)=>{const h=makeHuman(Object.assign({},SUIT,{shirt:'#2a2d33'}));BASE.g.add(h.g);
    const fan=new THREE.Mesh(FAN,new THREE.MeshBasicMaterial({color:'#fff2a8',transparent:true,opacity:0.16,depthWrite:false,side:THREE.DoubleSide}));fan.renderOrder=2;BASE.g.add(fan);
    const eye=glow('#ff3020',0,0,0,0.8);BASE.guards.push({h,fan,eye,pts:pts.map(p=>[BASE_X+p[0],p[1]]),loop:pts.length>2,i:0,dir:1,wait:0,sus:0,x:0,z:0,yaw:0});});}
function baseGuardsReset(){for(const s of BASE.guards){s.i=0;s.dir=1;s.wait=0;s.sus=0;[s.x,s.z]=s.pts[0];}}
const baseL=()=>[P.x-BASE_X,P.z];
function baseHUD(tr){tr.hidden=false;tr.innerHTML='';const b=document.createElement('b'),s=document.createElement('span'),m=document.createElement('span');s.className='step';m.className='meter';
  if(BASE.run){const R=BASE.run,next=BASE_SHUT.find(o=>P.x<BASE_X+o.x);b.textContent='シャッターが下りる前に！';s.textContent='東の通路を抜けて、外へ。スケボーで一気に';
    m.textContent=next?`次のシャッターまで ${Math.max(0,Math.round(next.x-baseL()[0]))} m　あと ${Math.max(0,next.t+2.4-R.t).toFixed(1)} 秒`:'出口はすぐそこ！';}
  else{const top=Math.max(0,...BASE.guards.map(g=>g.sus)),n=Math.round(top*5),[lx]=baseL();b.textContent='基地にしのびこむ';
    s.textContent=lx<92?'見張りの前の明るいところに入らない。くぼみに隠れてやり過ごす':'倉庫を抜けて、北の監視室へ。木箱のかげを伝って進む';m.textContent=`見つかりそう ${'■'.repeat(n)}${'□'.repeat(5-n)}`;}
  tr.append(b,s,m);}
// sneaking: done when she reaches the desk in the monitoring room. Seen for too long, back to the last checkpoint
function baseSneakP(){return new Promise(res=>{ST.actor=null;talkNpc=null;baseGuards();baseGuardsReset();BASE.sneak={res,cp:BASE_START,caught:0,hudT:0};
  for(const s of BASE.guards){s.h.g.visible=s.fan.visible=true;}if(!BASE.mark){BASE.mark=marker(MK.target);BASE.mark.scale.set(1.6,1.6,1);}renderHUD();});}
function baseCaught(){const S=BASE.sneak;S.caught++;S.pause=true;sfx.caught();$('fade').style.opacity=1;toast('見つかった……！ もう一度',true);
  setTimeout(()=>{if(BASE.sneak!==S)return;P.x=BASE_X+S.cp[0];P.z=S.cp[1];P.yaw=S.cp[2];P.v=0;P.y=0;camInit=false;baseGuardsReset();$('fade').style.opacity=0;$('hurt').style.opacity=0;S.pause=false;
    if(S.caught%3===0)baseRetire(S);},800);}
async function baseRetire(S){S.pause=true;const i=await askP('',`${S.caught}回見つかってしまった……。どうする？`,['もう少しがんばる','先に進む（リタイア）']);S.pause=false;
  if(BASE.sneak!==S||i===0)return;P.x=BASE_X+BASE_TERM[0];P.z=BASE_TERM[1]+1.2;P.y=0;camInit=false;}
function sneakStep(dt){const S=BASE.sneak;if(S.pause)return;const [lx,lz]=baseL();
  if(lx>93&&S.cp===BASE_START)S.cp=BASE_WARE;
  const loud=!P.foot&&P.v>3;let top=0;
  for(const s of BASE.guards){const p=s.pts,T=p[s.loop?(s.i+1)%p.length:s.i+s.dir]||p[s.i];
    const dx=P.x-s.x,dz=P.z-s.z,d=Math.hypot(dx,dz)||1,face=(Math.sin(s.yaw)*dx+Math.cos(s.yaw)*dz)/d;
    const sees=d<13&&face>Math.cos(0.62)&&ogSight(s.x,s.z,1.6,P.x,P.z,P.foot?1.2:1.0),hears=(loud&&d<9)||d<2.2;
    s.sus=clamp(s.sus+(sees?dt*(d<6?1.4:0.75):hears?dt*0.9:-dt*0.35),0,1);
    if(s.sus>0.05){s.yaw+=Math.atan2(Math.sin(Math.atan2(dx,dz)-s.yaw),Math.cos(Math.atan2(dx,dz)-s.yaw))*Math.min(1,dt*(sees?2:3));poseHuman(s.h,'stand',dt,{});}
    else if(s.wait>0){s.wait-=dt;s.yaw+=Math.sin(clock*1.3+s.i)*dt*0.9;poseHuman(s.h,'stand',dt,{});}
    else{const tx=T[0]-s.x,tz=T[1]-s.z,td=Math.hypot(tx,tz);
      if(td<0.2){if(s.loop)s.i=(s.i+1)%p.length;else{s.i+=s.dir;if(s.i<=0||s.i>=p.length-1)s.dir*=-1;}s.wait=1.4;}
      else{const v=Math.min(td,1.7*dt);s.x+=tx/td*v;s.z+=tz/td*v;const want=Math.atan2(tx,tz);s.yaw+=Math.atan2(Math.sin(want-s.yaw),Math.cos(want-s.yaw))*Math.min(1,dt*5);poseHuman(s.h,'walk',dt,{rate:4.4});}}
    s.h.g.position.set(s.x,0,s.z);s.h.g.rotation.y=s.yaw;s.fan.position.set(s.x,0.04,s.z);s.fan.rotation.y=s.yaw;s.fan.material.color.set(s.sus>0.05?'#ff8a70':'#fff2a8');
    s.eye.visible=s.sus>0.02;s.eye.position.set(s.x,1.75,s.z);s.eye.material.opacity=s.sus;top=Math.max(top,s.sus);}
  $('hurt').style.opacity=top*0.6;
  const goal=lx<92?[BASE_X+95,0]:[BASE_X+BASE_TERM[0],BASE_TERM[1]];BASE.mark.visible=true;BASE.mark.position.set(goal[0],2.6+Math.sin(clock*3)*0.12,goal[1]);
  S.hudT-=dt;if(S.hudT<=0){S.hudT=0.2;baseHUD($('tracker'));}
  if(top>=1){baseCaught();return;}
  if(Math.hypot(lx-BASE_TERM[0],lz-BASE_TERM[1])<2.4){BASE.sneak=null;BASE.mark.visible=false;$('hurt').style.opacity=0;for(const s of BASE.guards){s.h.g.visible=s.fan.visible=s.eye.visible=false;}S.res();}}
// the alarm: the shutters come down one after another; behind one when it shuts, and it is back to the monitoring-room door
function baseRunP(){return new Promise(res=>{ST.actor=null;talkNpc=null;BASE.run={res,t:0,caught:0,hudT:0};baseRunPlace();renderHUD();});}
function baseRunPlace(){const R=BASE.run;R.t=0;R.pause=false;P.x=BASE_X+BASE_DOOR[0];P.z=BASE_DOOR[1];P.yaw=BASE_DOOR[2];P.v=0;P.y=0;rideNow();camInit=false;
  for(const s of BASE.shut){s.g.position.y=BASE_H;s.c.on=false;}}
function runStep(dt){const R=BASE.run;if(R.pause)return;R.t+=dt;
  for(const s of BASE.shut){const k=clamp((R.t-s.t)/2.4,0,1);s.g.position.y=BASE_H*(1-k);s.c.on=k>0.8;
    if(k>=1&&P.x<BASE_X+s.x-0.2&&!R.pause){R.caught++;R.pause=true;$('fade').style.opacity=1;toast('シャッターに閉じこめられた……！ もう一度',true);
      setTimeout(async()=>{if(BASE.run!==R)return;baseRunPlace();$('fade').style.opacity=0;
        if(R.caught%3===0){R.pause=true;const i=await askP('',`${R.caught}回閉じこめられた……。どうする？`,['もう少しがんばる','先に進む（リタイア）']);R.pause=false;
          if(i===1&&BASE.run===R){BASE.run=null;R.res();}}},800);return;}}
  for(const m of BASE.strips)m.visible=(clock*2.2%1)<0.6;BASE.lightMat.color.set('#ff4a3a');$('hurt').style.opacity=0.25+0.15*Math.sin(clock*9);
  R.hudT-=dt;if(R.hudT<=0){R.hudT=0.2;baseHUD($('tracker'));}
  if(P.x>BASE_X+BASE_END){BASE.run=null;$('hurt').style.opacity=0;R.res();}}
const baseBusy=()=>!!(BASE.sneak||BASE.run);
// every frame in the base: the light of a place underground, the guards, the shutters
function updateBase(dt){if(AREA!=='base')return;
  scene.fog.color.set('#1c1f23');scene.background.set('#1c1f23');scene.fog.near=8;scene.fog.far=70;hemi.color.set('#dfe6ee');hemi.groundColor.set('#4a4e54');hemi.intensity=0.8;sun.intensity=0.2;
  for(const m of NIGHT_MATS)m.emissiveIntensity=0;NIGHT.stars.material.opacity=0;
  if(!BASE.run){for(const m of BASE.strips)m.visible=true;BASE.lightMat.color.set('#fff6dc');}
  BASE.glint.visible=!!BASE.sneak;BASE.exitGlow.visible=true;BASE.exitGlow.material.opacity=0.35+0.15*Math.sin(clock*4);BASE.glint.material.opacity=0.5+0.4*Math.sin(clock*3);
  if(BASE.sneak)sneakStep(dt);if(BASE.run)runStep(dt);}
