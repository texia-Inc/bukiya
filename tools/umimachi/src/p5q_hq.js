/* ---------- the second extra story "海街自警団" (after ex1_done): the old guard's base inside the east hill, through the rock door.
   Like Oceangate's base it lies far off the map (x around HQ_X, flat ground, the town hidden). Five people keep five rooms:
   the armory (the baker: the pistols hit harder), the training room (the fishmonger's okami: more hits before you go down),
   the lantern workshop (the old-book shop: more charges, a wider flash, quicker to fill), the radio room (the café master:
   Oceangate's drones come to help) and the command table (grandma: out to the night's defense). A room goes up a level for
   money and 影のかけら, the shards the shadows leave behind. Every night the shadows come again, a little stronger.
   Sorties into 裏海街 and the last fight are still to come. Local coordinates lx, lz are measured from (HQ_X, 0). ---------- */
const HQ_X=-6000;
const HQ={g:new THREE.Group(),map:document.createElement('canvas'),built:false,people:{},signs:{},allies:[],allyT:0};scene.add(HQ.g);HQ.g.visible=false;
// purchase: not in yet, so every build has the second story (StoreKit comes last)
const dlc2Owned=()=>true;
const HQ_IN=[3,0,Math.PI/2],HQ_EXIT=[1.2,0];
// the rooms: who keeps them, where they stand, and what a level does
const FAC={
  arm:{name:'武器庫',npc:'baker',at:[14,-9.6],yaw:0,what:lv=>`撃つ力 ×${[1,1.5,2,2.5,3][lv-1]}`},
  dojo:{name:'鍛錬場',npc:'okami',at:[26,-9.6],yaw:0,what:lv=>`耐えられる回数 ${[5,6,7,8,10][lv-1]}`},
  lamp:{name:'灯りの工房',npc:'neko',at:[14,9.6],yaw:Math.PI,what:lv=>`ランタン ${[3,4,4,5,6][lv-1]}回・光の広さ ${[13,14.5,16,17.5,19][lv-1]}m`},
  radio:{name:'通信室',npc:'master',at:[26,9.6],yaw:Math.PI,what:lv=>lv<2?'援護なし':`オーシャンゲートの援護ドローン ${lv>=4?2:1}機（${[0,0,4,3,3,2][lv]}秒ごと）`},
  cmd:{name:'作戦室',npc:'tome',at:[38.5,0],yaw:-Math.PI/2}};
const FAC_COST=[null,null,{m:500,s:5},{m:1500,s:15},{m:3000,s:30},{m:6000,s:50}];   // to reach level 2…5
const d2=()=>SAVE.d2||(SAVE.d2={lv:{arm:1,dojo:1,lamp:1,radio:1},night:0,last:0});
const hqLv=k=>d2().lv[k]||1;
const shards=()=>SAVE.shards||0;
// what the levels do, set whenever no fight is on (the story's own fights get them too)
const lanR=()=>[13,14.5,16,17.5,19][hqLv('lamp')-1];
const lanRe=def=>def?[1.6,1.4,1.2,1.0,0.8][hqLv('lamp')-1]:[16,14,12,10,8][hqLv('lamp')-1];
function applyD2(){if(DRONE.active)return;DRONE.maxHp=[5,6,7,8,10][hqLv('dojo')-1];DRONE.dmg=[1,1.5,2,2.5,3][hqLv('arm')-1];
  const m=[3,4,4,5,6][hqLv('lamp')-1];if(LAN.max!==m){LAN.max=m;LAN.n=Math.min(LAN.n,m);}}
/* ----- the hall: a cave in the hill, timber props, strings of bulbs, the five rooms round it ----- */
function hqBuild(){if(HQ.built)return;HQ.built=true;const g=HQ.g,X=HQ_X,W=44,D=28,H=6.5;
  const rockT=canvasTex(128,128,(c,w,h)=>{c.fillStyle='#6a5d50';c.fillRect(0,0,w,h);for(let k=0;k<160;k++){c.fillStyle=`rgba(${k%2?40:140},${k%2?32:120},${k%2?26:100},.18)`;c.fillRect(Math.random()*w,Math.random()*h,4+Math.random()*14,3+Math.random()*10);}
    c.strokeStyle='rgba(30,24,20,.45)';c.lineWidth=1.5;for(let k=0;k<7;k++){c.beginPath();let x=Math.random()*w,y=Math.random()*h;c.moveTo(x,y);for(let j=0;j<5;j++){x+=Math.random()*24-12;y+=Math.random()*20;c.lineTo(x,y);}c.stroke();}},true);rockT.repeat.set(6,2);
  const rock=tmap(rockT),rock2=tm('#574b40'),wood=tm('#7a5a3a'),dark=tm('#4a3828');
  // the floor: packed earth and gravel along the rock, a deck of planks in the middle edged with timber, stone flags inside the door
  const dirt=canvasTex(256,256,(c,w,h)=>{c.fillStyle='#6e6252';c.fillRect(0,0,w,h);for(let k=0;k<900;k++){const r=Math.random();c.fillStyle=r<0.5?'rgba(40,32,24,.25)':r<0.8?'rgba(150,135,110,.3)':'rgba(90,90,90,.35)';
      const s=1+Math.random()*3.5;c.beginPath();c.ellipse(Math.random()*w,Math.random()*h,s,s*0.7,Math.random()*3,0,7);c.fill();}},true);dirt.repeat.set(W/6,D/6);
  const ground=new THREE.Mesh(new THREE.PlaneGeometry(W,D),tmap(dirt));ground.rotation.x=-Math.PI/2;ground.position.set(X+W/2,0.0005,0);ground.receiveShadow=true;g.add(ground);
  // the planks: boards of differing tone with staggered ends, grain, a knot here and there, two nails at every join
  const ft=canvasTex(512,512,(c,w,h)=>{const bw=32;for(let x=0;x<w;x+=bw){let y=-((x/bw*137)%200);while(y<h){const L=120+((x*7+y*3)%140),t=0.85+((x*13+y)%27)/100;
        c.fillStyle=`rgb(${Math.round(150*t)},${Math.round(110*t)},${Math.round(72*t)})`;c.fillRect(x,y,bw,L);
        c.strokeStyle='rgba(70,45,25,.28)';c.lineWidth=1;for(let k=0;k<4;k++){c.beginPath();const gx=x+5+k*7+Math.random()*2;c.moveTo(gx,y);c.bezierCurveTo(gx+3,y+L*0.3,gx-3,y+L*0.6,gx+1,y+L);c.stroke();}
        if(Math.random()<0.3){c.fillStyle='rgba(70,40,20,.55)';c.beginPath();c.ellipse(x+bw/2,y+L*0.5,3,5,0,0,7);c.fill();}
        c.fillStyle='rgba(30,20,12,.7)';c.fillRect(x,y,bw,2);c.fillStyle='#3a3530';for(const nx of [7,bw-9]){c.fillRect(x+nx,y+5,2,2);}
        y+=L;}
      c.fillStyle='rgba(30,20,12,.65)';c.fillRect(x+bw-2,0,2,h);}
    for(let k=0;k<40;k++){c.fillStyle='rgba(60,40,25,.08)';c.beginPath();c.arc(Math.random()*w,Math.random()*h,10+Math.random()*30,0,7);c.fill();}},true);
  const DK=1.1;ft.repeat.set((W-2*DK)/8,(D-2*DK)/8);
  const floor=new THREE.Mesh(new THREE.PlaneGeometry(W-2*DK,D-2*DK),tmap(ft));floor.rotation.x=-Math.PI/2;floor.position.set(X+W/2,0.003,0);floor.receiveShadow=true;g.add(floor);
  for(const [w,d,x,z] of [[W-2*DK+0.24,0.24,W/2,-D/2+DK],[W-2*DK+0.24,0.24,W/2,D/2-DK],[0.24,D-2*DK,DK,0],[0.24,D-2*DK,W-DK,0]]){const e=new THREE.Mesh(new THREE.BoxGeometry(w,0.08,d),dark);e.position.set(X+x,0.04,z);e.receiveShadow=true;g.add(e);}
  const flags=canvasTex(128,128,(c,w,h)=>{c.fillStyle='#4e4a45';c.fillRect(0,0,w,h);for(const [x,y,a,b] of [[2,2,60,40],[64,2,62,56],[2,44,40,46],[44,60,82,30],[2,92,58,34],[62,92,64,34]]){
      c.fillStyle=`rgb(${120+Math.random()*30|0},${115+Math.random()*25|0},${105+Math.random()*25|0})`;c.fillRect(x,y,a-3,b-3);}});
  const genkan=new THREE.Mesh(new THREE.PlaneGeometry(2.6,3.8),tmap(flags));genkan.rotation.x=-Math.PI/2;genkan.position.set(X+1.3,0.006,0);g.add(genkan);
  // tatami at the tea corner
  const tat=canvasTex(64,128,(c,w,h)=>{c.fillStyle='#b9b27a';c.fillRect(0,0,w,h);c.strokeStyle='rgba(120,110,60,.5)';for(let x=0;x<w;x+=3){c.beginPath();c.moveTo(x,0);c.lineTo(x,h);c.stroke();}
    c.fillStyle='#2b3a4a';c.fillRect(0,0,5,h);c.fillRect(w-5,0,5,h);});
  for(const [x,z,r] of [[4.2,9.5,0],[5.8,9.5,0],[5,12.0,Math.PI/2]]){const t=new THREE.Mesh(new THREE.PlaneGeometry(0.9,1.8),tmap(tat));t.rotation.set(-Math.PI/2,0,r);t.position.set(X+x,0.008,z);g.add(t);}
  // left on the floor: a coil of rope, a toolbox, an oil can
  { const rope=new THREE.Mesh(new THREE.TorusGeometry(0.32,0.06,6,18),tm('#b89a62'));rope.rotation.x=-Math.PI/2;rope.position.set(X+11.2,0.07,-12.2);g.add(rope);
    const tb=new THREE.Mesh(new THREE.BoxGeometry(0.6,0.28,0.3),tm('#b8372d'));tb.position.set(X+17.3,0.14,-12.3);tb.rotation.y=0.3;outline(tb,0.015);g.add(tb);
    const can=new THREE.Mesh(new THREE.CylinderGeometry(0.14,0.15,0.4,10),tm('#3f6a4a'));can.position.set(X+30.2,0.2,12.4);outline(can,0.015);g.add(can);}
  const ceil=new THREE.Mesh(new THREE.PlaneGeometry(W,D),new THREE.MeshBasicMaterial({color:'#2e2620'}));ceil.rotation.x=Math.PI/2;ceil.position.set(X+W/2,H,0);g.add(ceil);
  // the walls: rough rock, a box each side and boulders along the foot
  for(const [x0,x1,z0,z1] of [[-1,0,-D/2,D/2],[W,W+1,-D/2,D/2],[-1,W+1,-D/2-1,-D/2],[-1,W+1,D/2,D/2+1]]){const m=new THREE.Mesh(new THREE.BoxGeometry(x1-x0,H,z1-z0),rock);m.position.set(X+(x0+x1)/2,H/2,(z0+z1)/2);g.add(m);collide(X+x0,X+x1,z0,z1,'bld',H);}
  // (none by the door and its notice board, nor in front of the rooms or the tea corner)
  for(let k=0;k<34;k++){const side=k%4,t=(k*0.137+0.05)%1,s=0.8+((k*7)%5)*0.25,b=new THREE.Mesh(new THREE.DodecahedronGeometry(s,0),k%3?rock:rock2);
    const x=side<2?(side?W-0.2:0.2):t*W,z=side<2?(t-0.5)*D:(side===2?-D/2+0.2:D/2-0.2);if(side===0&&(Math.abs(z)<2.5||z>-7.2&&z<-2.8)||side>=2&&x>9.5&&x<31||side===3&&x<8)continue;b.position.set(X+x,s*0.4,z);b.rotation.set(k,k*2,k*3);b.castShadow=true;g.add(b);}
  // timber props and beams across the ceiling
  for(let x=6;x<W;x+=9){for(const z of [-D/2+0.5,D/2-0.5]){const p=new THREE.Mesh(new THREE.BoxGeometry(0.45,H,0.45),wood);p.position.set(X+x,H/2,z);outline(p,0.02);g.add(p);}
    const b=new THREE.Mesh(new THREE.BoxGeometry(0.4,0.45,D),dark);b.position.set(X+x,H-0.3,0);g.add(b);}
  // strings of bulbs
  const bulb=new THREE.MeshBasicMaterial({color:'#ffd88a'});
  for(let x=2;x<W;x+=1.6)for(const z of [-6,6]){const m=new THREE.Mesh(new THREE.SphereGeometry(0.09,8,6),bulb);m.position.set(X+x,H-0.9-Math.sin((x%9)/9*Math.PI)*0.5,z);g.add(m);}
  for(const z of [-6,6]){const w=new THREE.Mesh(new THREE.BoxGeometry(W,0.02,0.02),dark);w.position.set(X+W/2,H-1.1,z);g.add(w);}
  // the door to the hillside
  const door=new THREE.Mesh(new THREE.PlaneGeometry(2.4,3.0),new THREE.MeshBasicMaterial({color:'#cfe6ff'}));door.position.set(X+0.02,1.5,0);door.rotation.y=Math.PI/2;g.add(door);
  // the rooms
  const box=(w,h,d,mat,x,y,z,ol)=>{const m=new THREE.Mesh(new THREE.BoxGeometry(w,h,d),mat);m.position.set(X+x,y,z);m.castShadow=true;if(ol!==0)outline(m,0.02);g.add(m);return m;};
  // armory: a rack of pistols and a crate of shells
  box(4.5,2.4,0.5,wood,14,1.2,-13.2);for(let k=0;k<5;k++){box(0.5,0.18,0.12,tm('#2a2d33'),12.3+k*0.85,1.5,-12.85,0);box(0.12,0.28,0.12,tm('#2a2d33'),12.15+k*0.85,1.38,-12.85,0);}
  box(1.4,0.8,1,tm('#5d6b3a'),16.6,0.4,-11.6);collide(X+11.7,X+17.4,-13.5,-11,'prop',2.4);
  // training room: sandbags, a straw target, mats
  for(let k=0;k<3;k++)box(1.6,0.45,0.8,tm('#b8a888'),24.5+k*1.7,0.25+0*k,-12.8);for(let k=0;k<2;k++)box(1.5,0.45,0.8,tm('#a89878'),25.3+k*1.7,0.7,-12.8);
  const tgt=new THREE.Mesh(new THREE.CylinderGeometry(0.6,0.6,0.25,18),tm('#d8c27a'));tgt.rotation.x=Math.PI/2;tgt.position.set(X+29,1.4,-13.2);g.add(tgt);box(0.15,1.4,0.15,wood,29,0.7,-13.3);
  const mat=new THREE.Mesh(new THREE.PlaneGeometry(5,3),tm('#4f7a9a'));mat.rotation.x=-Math.PI/2;mat.position.set(X+26,0.01,-10.6);g.add(mat);collide(X+23.5,X+30,-13.5,-12.3,'prop',1);
  // lantern workshop: a bench of lanterns, glowing
  box(5,0.9,1.2,wood,14,0.45,12.8);for(let k=0;k<4;k++){box(0.32,0.45,0.32,tm('#b08a3a'),12.2+k*1.2,1.13,12.8,0);const l=glow('#ffd27a',X+12.2+k*1.2,1.15,12.8,0.9);l.visible=true;HQ.g.add(l);}
  collide(X+11.5,X+16.5,12.2,13.5,'prop',0.9);
  // radio room: a desk, a big set with dials, two screens
  box(5,0.9,1.2,tm('#3a3d42'),26,0.45,12.8);box(1.6,1.1,0.7,tm('#5a5f66'),24.6,1.45,13.1);
  for(let k=0;k<2;k++){const c=canvasTex(160,100,(c2,w,h)=>{c2.fillStyle='#0f2a1a';c2.fillRect(0,0,w,h);c2.strokeStyle='#7fe0a0';c2.lineWidth=2;c2.beginPath();for(let x=0;x<w;x+=4)c2.lineTo(x,h/2+Math.sin(x/9+k*2)*18*(k?0.5:1));c2.stroke();
      c2.fillStyle='#bff5cf';c2.font='12px monospace';c2.fillText(k?'OG-LINK':'CH 07',8,16);});
    const m=new THREE.Mesh(new THREE.PlaneGeometry(1.4,0.9),new THREE.MeshBasicMaterial({map:c}));m.position.set(X+26.6+k*1.6,1.55,13.38);m.rotation.y=Math.PI;g.add(m);}
  collide(X+23.5,X+28.5,12.2,13.5,'prop',0.9);
  // command table: the town spread out on it
  const tbl=box(5,0.9,3.2,wood,40.5,0.45,0);
  const mp=canvasTex(256,160,(c,w,h)=>{c.fillStyle='#e9dfc6';c.fillRect(0,0,w,h);c.fillStyle='#7cb6d8';c.fillRect(0,h*0.62,w,h*0.38);c.fillStyle='#c9b48a';c.fillRect(0,h*0.56,w,h*0.07);
    c.strokeStyle='#8a6a4a';c.lineWidth=3;c.beginPath();c.moveTo(w*0.5,0);c.lineTo(w*0.5,h*0.58);c.moveTo(0,h*0.4);c.lineTo(w,h*0.4);c.stroke();
    c.fillStyle='#d24a3a';for(const [x,y] of [[0.3,0.8],[0.55,0.75],[0.7,0.85],[0.42,0.7]]){c.beginPath();c.arc(w*x,h*y,5,0,7);c.fill();}c.fillStyle='#2b2520';c.font='bold 16px sans-serif';c.fillText('海街',w*0.06,h*0.2);});
  const top=new THREE.Mesh(new THREE.PlaneGeometry(4.6,2.9),new THREE.MeshBasicMaterial({map:mp}));top.rotation.x=-Math.PI/2;top.rotation.z=Math.PI/2;top.position.set(X+40.5,0.91,0);g.add(top);
  collide(X+38,X+43,-1.6,1.6,'prop',0.9);
  // the keepers, and a sign over each room
  for(const k in FAC){const F=FAC[k],n=NPCS[F.npc],h=makeHuman(n.h.o);g.add(h.g);h.g.position.set(X+F.at[0],0,F.at[1]);h.g.rotation.y=F.yaw;HQ.people[k]=h;
    collide(X+F.at[0]-0.4,X+F.at[0]+0.4,F.at[1]-0.4,F.at[1]+0.4,'npc');
    const c=document.createElement('canvas');c.width=256;c.height=64;const t=new THREE.CanvasTexture(c);const s=new THREE.Mesh(new THREE.PlaneGeometry(2.6,0.65),new THREE.MeshBasicMaterial({map:t,transparent:true}));
    const sx=k==='cmd'?43.6:F.at[0],sz=k==='cmd'?0:F.at[1]+(F.at[1]<0?-3.9:3.9);s.position.set(X+sx,k==='cmd'?5.5:3.3,sz);s.rotation.y=k==='cmd'?-Math.PI/2:F.at[1]<0?0:Math.PI;g.add(s);HQ.signs[k]={c,t};hqSign(k);}
  // the things that make it theirs: plank panelling round the foot of the rock, the banner over the command table, bunting
  // along the bulbs, red lanterns, a notice board by the door (the summer of 1996), a tea corner, a blackboard, barrels and crates
  { const plank=canvasTex(128,64,(c,w,h)=>{c.fillStyle='#8a6440';c.fillRect(0,0,w,h);for(let x=0;x<w;x+=16){c.fillStyle=x%32?'#7d5a38':'#93693f';c.fillRect(x,0,15,h);c.fillStyle='rgba(40,25,15,.5)';c.fillRect(x+15,0,1,h);}
      for(let k=0;k<20;k++){c.fillStyle='rgba(50,30,15,.25)';c.fillRect(Math.random()*w,Math.random()*h,1,6+Math.random()*10);}},true);
    const panel=(x0,z0,x1,z1,ry)=>{const L=Math.hypot(x1-x0,z1-z0),t=plank.clone();t.needsUpdate=true;t.repeat.set(L/2,1);const m=new THREE.Mesh(new THREE.PlaneGeometry(L,2.2),tmap(t));
      m.position.set(X+(x0+x1)/2,1.1,(z0+z1)/2);m.rotation.y=ry;g.add(m);const rail=new THREE.Mesh(new THREE.BoxGeometry(L,0.12,0.1),dark);rail.position.set(X+(x0+x1)/2,2.22,(z0+z1)/2);rail.rotation.y=ry;g.add(rail);};
    panel(0,-D/2+0.03,W,-D/2+0.03,0);panel(0,D/2-0.03,W,D/2-0.03,Math.PI);panel(W-0.03,-D/2,W-0.03,D/2,-Math.PI/2);panel(0.03,-D/2,0.03,-1.6,Math.PI/2);panel(0.03,1.6,0.03,D/2,Math.PI/2);
    // the banner
    const ban=canvasTex(384,160,(c,w,h)=>{c.fillStyle='#f1e9d6';c.fillRect(0,0,w,h);c.fillStyle='#1d3f6e';c.fillRect(0,0,w,14);c.fillRect(0,h-14,w,14);
      c.fillStyle='#1d3f6e';c.beginPath();c.moveTo(48,128);c.lineTo(60,40);c.lineTo(72,128);c.fill();c.fillStyle='#f2c230';c.beginPath();c.arc(60,36,9,0,7);c.fill();c.fillStyle='rgba(242,194,48,.35)';c.beginPath();c.moveTo(60,36);c.lineTo(10,20);c.lineTo(10,52);c.fill();
      c.fillStyle='#1b1b1b';c.font=signFont(54,true);c.textAlign='center';c.textBaseline='middle';c.fillText('海街自警団',w/2+30,h/2+4);});
    const bn=new THREE.Mesh(new THREE.PlaneGeometry(6.4,2.7),new THREE.MeshToonMaterial({map:ban,gradientMap:GRAD,side:THREE.DoubleSide}));bn.position.set(X+W-0.08,3.6,0);bn.rotation.y=-Math.PI/2;g.add(bn);
    const pole=new THREE.Mesh(new THREE.CylinderGeometry(0.06,0.06,7,8),wood);pole.rotation.x=Math.PI/2;pole.position.set(X+W-0.12,5.0,0);g.add(pole);
    // bunting under the bulb strings
    const tri=new THREE.BufferGeometry();tri.setAttribute('position',new THREE.Float32BufferAttribute([-0.28,0,0,0.28,0,0,0,-0.5,0],3));tri.computeVertexNormals();
    const fl=[];for(let x=2.8;x<W-1;x+=1.6)for(const z of [-6,6])fl.push([x,z]);const fm=new THREE.InstancedMesh(tri,new THREE.MeshBasicMaterial({side:THREE.DoubleSide}),fl.length);
    const FC=['#d24a3a','#f2f2ee','#2e6fb8','#f2c230','#3a9a5a'].map(c=>new THREE.Color(c));
    fl.forEach(([x,z],k)=>{dummy.position.set(X+x,H-1.0-Math.sin((x%9)/9*Math.PI)*0.5,z);dummy.rotation.set(0,0,0);dummy.scale.set(1,1,1);dummy.updateMatrix();fm.setMatrixAt(k,dummy.matrix);fm.setColorAt(k,FC[k%5]);});
    fm.frustumCulled=false;g.add(fm);
    // red paper lanterns along the long walls
    const red=tm('#c8372d'),cap=tm('#1d1d1d');
    for(let x=6;x<W-2;x+=8)for(const z of [-D/2+0.6,D/2-0.6]){const l=new THREE.Group();l.position.set(X+x,4.0,z);g.add(l);
      const b=new THREE.Mesh(new THREE.SphereGeometry(0.32,12,8),red);b.scale.set(1,1.3,1);l.add(b);for(const y of [0.42,-0.42]){const c=new THREE.Mesh(new THREE.CylinderGeometry(0.17,0.17,0.08,10),cap);c.position.y=y;l.add(c);}
      const gl=glow('#ffb070',X+x,4.0,z,2.4);gl.visible=true;gl.material.opacity=0.5;scene.remove(gl);g.add(gl);}
    // the notice board by the door: the old guard in the summer of 1996, a missing-child poster gone yellow, notes
    const nb=canvasTex(256,160,(c,w,h)=>{c.fillStyle='#b48a5a';c.fillRect(0,0,w,h);c.strokeStyle='#5a3d22';c.lineWidth=8;c.strokeRect(4,4,w-8,h-8);
      c.save();c.translate(70,70);c.rotate(-0.06);c.fillStyle='#f4efe2';c.fillRect(-52,-40,104,80);c.fillStyle='#8a8070';c.fillRect(-46,-34,92,52);c.fillStyle='#4a4038';for(let k=0;k<6;k++){c.beginPath();c.arc(-36+k*14,-4,5,0,7);c.fill();c.fillRect(-40+k*14,1,9,14);}
      c.fillStyle='#2b2520';c.font='bold 11px sans-serif';c.textAlign='center';c.fillText('1996 夏　自警団',0,32);c.restore();
      c.save();c.translate(178,74);c.rotate(0.05);c.fillStyle='#efe2a8';c.fillRect(-46,-56,92,112);c.fillStyle='#2b2520';c.font=signFont(16,true);c.textAlign='center';c.fillText('さがしています',0,-36);
      c.fillStyle='#9a9080';c.fillRect(-22,-28,44,46);c.fillStyle='#2b2520';c.font='bold 12px sans-serif';c.fillText('ミオ（10さい）',0,34);c.font='10px sans-serif';c.fillText('白いワンピース',0,50);c.restore();
      c.fillStyle='#f2c230';c.fillRect(20,124,46,26);c.fillStyle='#8fd0ff';c.fillRect(110,128,40,22);});
    const nbm=new THREE.Mesh(new THREE.PlaneGeometry(3.2,2.0),new THREE.MeshToonMaterial({map:nb,gradientMap:GRAD}));nbm.position.set(X+0.06,2.4,-5);nbm.rotation.y=Math.PI/2;g.add(nbm);
    // the tea corner: a low table, a teapot and cups, cushions
    const tbl=new THREE.Mesh(new THREE.BoxGeometry(2.0,0.4,1.3),wood);tbl.position.set(X+5,0.2,9.5);tbl.castShadow=true;outline(tbl,0.02);g.add(tbl);collide(X+4,X+6,8.85,10.15,'prop',0.4);
    const pot=new THREE.Mesh(new THREE.SphereGeometry(0.17,12,8),tm('#3a5a4a'));pot.scale.y=0.8;pot.position.set(X+4.7,0.53,9.5);g.add(pot);
    for(const [dx,dz] of [[0.3,0.3],[0.55,-0.2],[-0.1,-0.3]]){const cu=new THREE.Mesh(new THREE.CylinderGeometry(0.06,0.05,0.1,10),tm('#efe6d8'));cu.position.set(X+5+dx,0.45,9.5+dz);g.add(cu);}
    for(const [dx,dz] of [[0,-1.1],[0,1.1],[-1.4,0]]){const zb=new THREE.Mesh(new THREE.BoxGeometry(0.75,0.1,0.75),tm('#7a3b4a'));zb.position.set(X+5+dx,0.05,9.5+dz);g.add(zb);}
    // the blackboard by the command table
    const bb=canvasTex(256,160,(c,w,h)=>{c.fillStyle='#2f4a3a';c.fillRect(0,0,w,h);c.strokeStyle='#8a6440';c.lineWidth=10;c.strokeRect(5,5,w-10,h-10);c.fillStyle='#eef2e8';c.font=signFont(22,true);c.fillText('今夜の配置',22,40);
      c.font=signFont(17,true);c.fillText('浜……自警団',30,74);c.fillText('空……オーシャンゲート',30,102);c.fillText('裏海街……ナギ',30,130);});
    const bbm=new THREE.Mesh(new THREE.PlaneGeometry(2.6,1.6),new THREE.MeshBasicMaterial({map:bb}));bbm.position.set(X+W-0.1,2.0,-8);bbm.rotation.y=-Math.PI/2;g.add(bbm);
    // barrels and crates in the corners
    const brl=tm('#6b4a2e'),hoop=tm('#3a3a3a');
    for(const [x,z] of [[41.5,-11.5],[40.2,-12.3],[3,-11.8],[41.6,11.6]]){const b=new THREE.Mesh(new THREE.CylinderGeometry(0.5,0.45,1.1,12),brl);b.position.set(X+x,0.55,z);b.castShadow=true;outline(b,0.02);g.add(b);
      for(const y of [0.25,0.85]){const h=new THREE.Mesh(new THREE.CylinderGeometry(0.51,0.51,0.06,12),hoop);h.position.set(X+x,y,z);g.add(h);}collide(X+x-0.5,X+x+0.5,z-0.5,z+0.5,'prop',1.1);}
    for(const [x,z,sz] of [[38.5,-12.4,1.2],[38.6,-12.4,0.8],[4.6,-12.2,1.1],[39.2,12.2,1.1]]){const b=new THREE.Mesh(new THREE.BoxGeometry(sz,sz,sz),tm('#8a6a44'));b.position.set(X+x,sz/2+(sz<1?1.2:0),z);b.castShadow=true;outline(b,0.02);g.add(b);if(sz>=1)collide(X+x-sz/2,X+x+sz/2,z-sz/2,z+sz/2,'prop',sz);}
    // a mat in front of each room
    for(const k in FAC){const F=FAC[k];const m=new THREE.Mesh(new THREE.PlaneGeometry(k==='cmd'?4:4.5,k==='cmd'?5:2.6),tm(['#7a3b3b','#3b5a7a','#5a6a3a','#6a4a7a','#7a6a3b'][Object.keys(FAC).indexOf(k)]));
      m.rotation.x=-Math.PI/2;m.position.set(X+F.at[0]+(k==='cmd'?-1:0),0.012,F.at[1]+(k==='cmd'?0:F.at[1]<0?-1.3:1.3));g.add(m);}}
  // the map
  const mc=HQ.map;mc.width=W+8;mc.height=D+8;const m2=mc.getContext('2d');m2.fillStyle='#3d342c';m2.fillRect(0,0,mc.width,mc.height);m2.fillStyle='#b8a890';m2.fillRect(4,4,W,D);
  m2.fillStyle='#e2a84a';for(const k in FAC){const F=FAC[k];m2.fillRect(4+F.at[0]-1.5,4+F.at[1]+D/2-1.5,3,3);}HQ.mapX0=X-4;HQ.mapZ0=-D/2-4;}
function hqSign(k){const S=HQ.signs[k];if(!S)return;const c=S.c.getContext('2d');c.clearRect(0,0,256,64);c.fillStyle='rgba(60,42,28,.9)';c.fillRect(4,4,248,56);c.strokeStyle='#d8b878';c.lineWidth=3;c.strokeRect(6,6,244,52);
  c.fillStyle='#fff1d6';c.font=signFont(28,true);c.textAlign='center';c.textBaseline='middle';c.fillText(FAC[k].name+(k==='cmd'?'':`  Lv${hqLv(k)}`),128,34);S.t.needsUpdate=true;}
/* ----- in and out through the rock door ----- */
function rockFront(){const D=rockDoor(),p=D.g.position,a=D.g.rotation.y;return[p.x+Math.sin(a)*3.4,p.z+Math.cos(a)*3.4,a];}
function hqNear(){if(AREA==='town'){if(!SAVE.flags.ex1_done||SAVE.flags.x_door!==2||URA.on)return null;const [x,z]=rockFront(),d=Math.hypot(P.x-x,P.z-z);return d<3.2?{kind:'hq',enter:true,d,label:'入る　岩の扉（海街自警団の基地）',verb:'入る'}:null;}
  if(AREA!=='hq')return null;let best=null;const add=o=>{if(!best||o.d<best.d)best=o;};
  const dx=Math.hypot(P.x-(HQ_X+HQ_EXIT[0]),P.z-HQ_EXIT[1]);if(dx<2.6)add({kind:'hq',exit:true,d:dx,label:'出る　岩の扉',verb:'出る'});
  for(const k in FAC){const F=FAC[k],d=Math.hypot(P.x-(HQ_X+F.at[0]),P.z-F.at[1]);if(d<2.8)add({kind:'hq',k,d,label:`話す　${whoName(F.npc)}（${F.name}）`,verb:'話す'});}
  return best;}
function hqAct(o){runEvent({id:'hq_act',once:false,script:[['call',()=>hqTalk(o)]]});}
async function hqTalk(o){
  if(o.enter){if(!dlc2Owned()){await sayP('',['追加ストーリー2「海街自警団」を手に入れると、ここから基地に入れます。']);return;}
    await steps([['fade','out'],['warp',HQ_X+HQ_IN[0],HQ_IN[1],HQ_IN[2]],['fade','in']]);return;}
  if(o.exit){const [x,z,a]=rockFront();await steps([['fade','out'],['warp',x,z,a],['fade','in']]);return;}
  const F=FAC[o.k];ST.actor=null;
  if(o.k==='cmd')return hqCommand();
  for(;;){const lv=hqLv(o.k),c=FAC_COST[lv+1];
    const opts=[...(c?[`レベル${lv+1}にする（${c.m}円・かけら${c.s}）`]:[]),'いまの強さを聞く','やめる'];
    const i=await askP(F.npc,`${F.name} Lv${lv}　（さいふ ${SAVE.money}円・影のかけら ${shards()}）`,opts),pick=opts[i];
    if(pick==='やめる')return;
    if(pick==='いまの強さを聞く'){await sayP(F.npc,[`いまは ${F.what(lv)}。`+(c?`次のレベルで ${F.what(lv+1)} になる。`:'これ以上は、上げようがないね。')]);continue;}
    if(SAVE.money<c.m||shards()<c.s){await sayP(F.npc,[SAVE.money<c.m?'お金が足りないね。おつかいや、夜の防衛でかせいでおいで。':'影のかけらが足りない。夜の防衛で、影を追いはらうと手に入るよ。']);continue;}
    SAVE.money-=c.m;SAVE.shards=shards()-c.s;d2().lv[o.k]=lv+1;hqSign(o.k);applyD2();save();renderHUD();buzz('medium');
    toast(`${F.name}が Lv${lv+1} になった！ ${F.what(lv+1)}`,true);await sayP(F.npc,[HQ_UP[o.k]]);}}
const HQ_UP={arm:'よし、手入れは終わった。これで一発の重みがちがうぞ。',dojo:'いい汗かいたね！ これで、ちょっとやそっとじゃ倒れないよ。',
  lamp:'ランタンのガラスを、灯台のレンズのかけらで張りかえた。前より、ずっと遠くまで光が届く。',radio:'黒崎の連中と、回線をつないだ。夜は、やつらのドローンが手を貸してくれる。'};
/* ----- the command table: out to tonight's defense ----- */
function nightPlan(n){return{drones:Math.min(4+2*n,16),boss:n%3===0,shadows:Math.min(10+3*n,36),alive:Math.min(4+(n>>1),9),spd:0.06*n};}
async function hqCommand(){const D=d2(),ph=phaseOf(SAVE.hour),dark=ph==='evening'||ph==='night',done=D.last===SAVE.day,n=D.night+1;
  const nests=D.nest||0,last=!!SAVE.flags.d2c&&!SAVE.flags.d2_done,opts=[...(dark&&!done&&last?['最後の戦いに出る']:[]),...(dark&&!done&&!last?['今夜の防衛に出る']:[]),...(dark&&!done&&!last&&D.night>=1&&nests<NESTS.length?[`裏海街へ出撃する（のこりの巣 ${NESTS.length-nests}）`]:[]),...(!dark?['日が暮れるまで休む']:[]),'話を聞く','やめる'];
  const i=await askP('tome',done?'今夜の町は守った。……ゆっくりお休み。':dark?`${n}日目の夜。……今夜も、来るよ。`:'やつらが来るのは、日が暮れてからだよ。',opts),pick=opts[i];
  if(pick==='日が暮れるまで休む'){await steps([['fade','out'],['time',18.6,0],['fade','in']]);return;}
  if(pick==='話を聞く'){await sayP('tome',[...(n<=1?['施設は、お金と影のかけらで強くなる。かけらは、夜の防衛で影を追いはらうと手に入るよ。']:[]),
    nightPlan(n).boss?'今夜は、大きいのが混じってる。気をつけな。':'夜ごとに、やつらの数は増えていく。施設をきたえておくんだよ。',
    D.night<1?'まずは一晩、町を守ってごらん。そうしたら、裏海街の巣を焼きに行けるようになる。':nests<NESTS.length?`裏海街には、影の巣がのこり${NESTS.length-nests}つ。巣を焼けば、向こうに残された子たちが帰れるんだよ。`:'巣はぜんぶ焼けた。……あとは、海の底の、あの大きな気配だ。']);return;}
  if(pick==='最後の戦いに出る'){await steps(finalScript());return;}
  if(pick&&pick.startsWith('裏海街へ出撃')){await steps(sortieScript(nests));return;}
  if(pick!=='今夜の防衛に出る')return;
  const N=nightPlan(n),got={sh:0,dr:0};
  await steps([['fade','out'],['call',()=>{applyD2();EX1.still=true;}],['time',21,0],['warp',TRUTH.x+4,TRUTH.z,0],['fade','in'],
    ['say','tome','（無線の声）来たよ、ナギ。まずは空のドローン、それから浜の影だ。','町に、一匹も入れるんじゃないよ！'],
    ['drones',{total:N.drones,boss:N.boss?1:0,title:`${n}日目の夜：影のドローン`}],['call',()=>{got.dr=DRONE.killed+(N.boss?10:0);}],
    ['say','baker','（無線の声）上は片づいた！ 浜だ！'],
    ['call',()=>defendP({total:N.shadows,alive:N.alive,spd:N.spd})],['call',()=>{got.sh=DEF.killed;}],
    ['call',()=>{const s=got.sh+got.dr;SAVE.shards=shards()+s;SAVE.money+=200+n*50;D.night=n;D.last=SAVE.day;save();renderHUD();
      toast(`影のかけら +${s}　お礼 +${200+n*50}円`,true);}],
    ['say','tome','（無線の声）よくやったね。今夜も、町の灯りは守られた。','かけらは、基地に持って帰っておいで。'],
    ['fade','out'],['call',()=>ex1Kurosaki(false)],['warp',...HOME],['day']]);}
/* ----- Oceangate's help: one or two of their drones ahead of Nagi to either side (out of the camera's way), picking off a drone or a shadow now and then ----- */
function allyStep(dt){const lv=hqLv('radio'),want=(DRONE.active||DEF.on||NEST.fight||BOSS.on)&&lv>=2?(lv>=4?2:1):0;
  while(HQ.allies.length<want){const d=makeDrone();d.g.scale.setScalar(1.1);HQ.allies.push(d);toast('オーシャンゲートの援護ドローンが来た！');}
  HQ.allies.forEach((d,k)=>{d.g.visible=k<want;if(!d.g.visible)return;const sd=k?-1:1,a=P.yaw+sd*(0.55+Math.sin(clock*0.7+k)*0.15),w=new THREE.Vector3(P.x+Math.sin(a)*7,P.y+6+Math.sin(clock*2+k)*0.3,P.z+Math.cos(a)*7);
    d.g.position.lerp(w,Math.min(1,dt*3));d.g.rotation.y=a;for(const r of d.rotors)r.rotation.y+=dt*40;});
  if(!want)return;HQ.allyT-=dt;if(HQ.allyT>0||DLG||modal)return;HQ.allyT=[0,0,4,3,3,2][lv];
  const from=HQ.allies[(clock*10|0)%want].g.position.clone();
  if(DRONE.active){const t=DRONE.list.filter(d=>!d.dead&&d.g.position.distanceTo(from)<55).sort((a,b)=>a.g.position.distanceTo(from)-b.g.position.distanceTo(from))[0];
    if(t){const p=t.g.position.clone();tracer(from,p);damage(t,p);if(!t.dead)damage(t,p);}}
  else if(DEF.on){const t=DEF.list.filter(s=>!s.gone&&s.up>=1).sort((a,b)=>a.g.position.z-b.g.position.z)[0];
    if(t){tracer(from,t.g.position.clone().setY(t.g.position.y+1));t.gone=1;DEF.killed++;}}
  else if(BOSS.on){const t=BOSS.list.filter(s=>!s.gone&&s.up>=1).sort((a,b)=>a.g.position.distanceTo(player.g.position)-b.g.position.distanceTo(player.g.position))[0];
    if(t&&!BOSS.striking){tracer(from,t.g.position.clone().setY(t.g.position.y+1));t.gone=1;bossGain();}}
  else if(NEST.fight){const t=NEST.list.filter(s=>!s.gone&&s.up>=1).sort((a,b)=>a.g.position.distanceTo(player.g.position)-b.g.position.distanceTo(player.g.position))[0];
    if(t){tracer(from,t.g.position.clone().setY(t.g.position.y+1));t.gone=1;NEST.killed++;}}}
function hqHUD(){const D=d2();return `影のかけら ${shards()}　防衛 ${D.night}夜　焼いた巣 ${D.nest||0}/${NESTS.length}`;}
function d2Goal(f,eve,night){const D=d2();
  if(!f.d2)return '町の東の山の岩の扉から、海街自警団の基地へ';
  if(AREA==='hq')return (eve||night)&&D.last!==SAVE.day?`作戦室のばあちゃんに話して、今夜の防衛か出撃に出る（${hqHUD()}）`:`施設の人に話して、基地を強くする（${hqHUD()}）`;
  if(f.d2c&&!f.d2_done)return eve||night?'基地の作戦室で、ばあちゃんに話して最後の戦いへ':'日が暮れたら、基地の作戦室で、ばあちゃんに話して最後の戦いへ';
  return (eve||night)&&D.last!==SAVE.day?'基地の作戦室で、ばあちゃんに話して防衛か出撃に出る':`基地で施設を強くする。夜は防衛（${hqHUD()}）`;}
// every frame: the hall's warm light, the keepers looking round, the levels, the allies
function updateHQ(dt){if(SAVE.flags.ex1_done)applyD2();allyStep(dt);if(AREA!=='hq')return;hqBuild();
  scene.fog.color.set('#2a221c');scene.background.set('#2a221c');scene.fog.near=10;scene.fog.far=80;hemi.color.set('#ffe6c4');hemi.groundColor.set('#5a4a3a');hemi.intensity=0.95;sun.intensity=0.15;
  for(const m of NIGHT_MATS)m.emissiveIntensity=0;NIGHT.stars.material.opacity=0;
  for(const k in HQ.people){const h=HQ.people[k],p=h.g.position,near=Math.hypot(P.x-p.x,P.z-p.z)<9;poseHuman(h,'stand',dt,{look:near?player.g.position:null});}}
const HQ_EVENTS=[
  {id:'d2_intro',when:{flags:{ex1_done:1,d2:0},test:()=>AREA==='hq'},script:[
    ['cam',[HQ_X+8,3.2,-4],[HQ_X+30,1.4,0],1.2,'cut'],
    ['say','','岩の扉の奥は、山をくりぬいた広い洞窟だった。','太い木の柱に、はだか電球がずらりとつるされている。'],
    ['say','tome','ようこそ、海街自警団の基地へ。30年ぶりに、灯りを入れたよ。'],
    ['cam',[HQ_X+14,2.4,-4],[HQ_X+14,1.3,-12],1.2,'cut'],
    ['say','baker','武器庫だ。おれの古い道具を、ここで手入れしておく。','お金と影のかけらがあれば、もっと強くしてやれるぞ。'],
    ['cam',[HQ_X+26,2.4,-4],[HQ_X+26,1.3,-12],1.2,'cut'],
    ['say','okami','鍛錬場だよ。体をきたえりゃ、ちょっとやそっとじゃ倒れなくなるさ。'],
    ['cam',[HQ_X+14,2.4,4],[HQ_X+14,1.3,12],1.2,'cut'],
    ['say','neko','灯りの工房。灯台の灯りを、ランタンにたくさんためられるようにする。光も、もっと遠くまで届くようになるよ。'],
    ['cam',[HQ_X+26,2.4,4],[HQ_X+26,1.3,12],1.2,'cut'],
    ['say','master','通信室だ。黒崎の連中と、ここでつながってる。','設備をよくすれば、夜にはオーシャンゲートのドローンが援護に来てくれる。'],
    ['cam',[HQ_X+34,2.6,3],[HQ_X+40,1.3,0],1.2,'cut'],
    ['say','tome','そして、ここが作戦室。','異界の者は、これから夜ごとに来る。倒した影は「影のかけら」を落とす。それを集めて、基地を強くするんだよ。'],
    ['say','tome','日が暮れたら、わたしに声をかけな。いっしょに町を守ろう。','……いずれは、こっちから裏海街に攻めこむ。ミオちゃんが言ってた、向こうに残された子たちのためにもね。'],
    ['set','d2'],['cam','off'],['call',()=>toast('施設の人に話すと、お金と影のかけらで強くできる',true)]]},
];
EVENTS.splice(EVENTS.findIndex(e=>e.id==='dusk'),0,...HQ_EVENTS);
