
/* ---------- the summer festival of the easy-going route: lanterns over the shrine approach and the shopping street,
   stalls at the shrine, fireworks over the sea, and the downhill race the kids call the skateboard contest ---------- */
const FEST={lanterns:new THREE.Group(),stalls:new THREE.Group(),bursts:[],fwUntil:0,fwT:0};
// the stalls: four that sell something to eat on the spot, the goldfish pool and the cork-gun stall
const YATAI=[
  {id:'kakigori',sd:-1,z:-132,name:'かき氷',col:'#5aa3d8',price:200,food:true,say:['いらっしゃい！ いちご、メロン、ブルーハワイ！'],eat:['ガリガリの氷に、赤いシロップ。','……つめたーい！ 頭がキーンとする。'],
   keeper:{skin:'#efc9aa',hair:'#2b2520',style:'short',shirt:'#3a7bd5',bottom:'pants',bottomCol:'#22242a',apron:'#f4efe2'},
   ware:Mk=>{Mk(new THREE.BoxGeometry(0.5,0.5,0.45),tm('#d8d2c6'),0.01).position.set(-0.8,1.25,-0.15);Mk(new THREE.CylinderGeometry(0.16,0.16,0.04,14).rotateZ(Math.PI/2),tm('#c8372d'),0).position.set(-0.53,1.3,-0.15);
     [['#e8452f',-0.2],['#4fbf6a',0.15],['#3a7bd5',0.5],['#f2c230',0.85]].forEach(([c,px])=>{Mk(new THREE.CylinderGeometry(0.08,0.06,0.14,10),tm('#ffffff'),0.006).position.set(px,1.08,0.2);
       Mk(new THREE.SphereGeometry(0.1,10,6,0,TAU,0,Math.PI/2),tm(c),0).position.set(px,1.14,0.2);});}},
  {id:'yakisoba',sd:1,z:-132,name:'やきそば',col:'#e8a23a',price:400,food:true,say:['へい、らっしゃい！ ソースたっぷりだよ！'],eat:['鉄板でジュウジュウ焼いた、ソースのやきそば。','青のりと紅しょうがが、いいにおい。'],
   keeper:{skin:'#e3b088',hair:'#1c1a1a',style:'short',shirt:'#e85a2a',bottom:'pants',bottomCol:'#2b2f36',scarf:'#f4efe2'},
   ware:Mk=>{Mk(new THREE.BoxGeometry(1.5,0.08,0.7),tm('#2b2724'),0.01).position.set(-0.2,1.05,-0.05);for(let k=0;k<6;k++){const m=Mk(new THREE.SphereGeometry(0.16,8,5),tm('#9a5a2a'),0);m.position.set(-0.75+k*0.22,1.1,-0.05+(k%2)*0.12);m.scale.set(1,0.3,1);}
     for(let k=0;k<3;k++)Mk(new THREE.BoxGeometry(0.28,0.07,0.18),tm('#f4efe2'),0.005).position.set(0.8,1.05+k*0.075,0.2);}},
  {id:'kingyo',sd:-1,z:-142,name:'金魚すくい',col:'#e8452f',price:300,game:'kingyo',say:['金魚すくい、1回300円だよ。ポイが破れるまで、何匹すくえるかな？'],
   keeper:{skin:'#efc9aa',hair:'#d9d6d0',style:'grey',shirt:'#2e5fa8',sleeves:'long',bottom:'pants',bottomCol:'#3a3a3a',bend:0.15},
   ware:Mk=>{Mk(new THREE.BoxGeometry(2.4,0.45,1.3),tm('#3a7bd5'),0.015).position.set(0,0.23,0.2);
     const w=Mk(new THREE.PlaneGeometry(2.2,1.1).rotateX(-Math.PI/2),tmap(canvasTex(128,64,(g,W,H)=>{g.fillStyle='#7cc4e8';g.fillRect(0,0,W,H);const r=mulberry(7);
       for(let k=0;k<16;k++){const fx=r()*W,fy=r()*H,a=r()*6;g.save();g.translate(fx,fy);g.rotate(a);g.fillStyle=k%6?'#f2582a':'#2b2520';g.beginPath();g.ellipse(0,0,5,3,0,0,7);g.fill();g.beginPath();g.moveTo(-4,0);g.lineTo(-9,-3);g.lineTo(-9,3);g.fill();g.restore();}})),0);
     w.position.set(0,0.43,0.2);Mk(new THREE.BoxGeometry(0.6,0.7,0.5),tm('#8a6a4c'),0.01).position.set(0,0.35,-0.75);}},
  {id:'shateki',sd:1,z:-142,name:'射的',col:'#8a5cf0',price:300,game:'shateki',say:['射的だよ！ コルク5発で300円。落とした景品は持って帰っていいよ！'],
   keeper:{skin:'#f1cdb0',hair:'#3a2a1e',style:'bun',shirt:'#c8372d',bottom:'pants',bottomCol:'#22242a',apron:'#22242a'},
   ware:Mk=>{for(const py of [1.45,1.85])Mk(new THREE.BoxGeometry(2.3,0.05,0.3),tm('#6b4a2e'),0.008).position.set(0,py,-0.35);
     [['#f2c230',-0.8,1.55],['#3a7bd5',-0.3,1.6],['#e2584a',0.3,1.53],['#4fbf6a',0.8,1.58],['#f0a0b8',-0.5,1.98],['#ffffff',0.4,1.95]].forEach(([c,px,py])=>Mk(new THREE.BoxGeometry(0.2,0.2+((px*7)%3+3)%3*0.05,0.16),tm(c),0.006).position.set(px,py,-0.35));
     for(const px of [-0.6,0.5]){const gun=Mk(new THREE.BoxGeometry(0.06,0.06,0.7),tm('#4a3326'),0.005);gun.position.set(px,1.05,0.15);gun.rotation.y=0.3;}}},
  {id:'ringo',sd:-1,z:-152,name:'りんご飴',col:'#c8372d',price:250,food:true,say:['りんご飴、つやつやだよ！'],eat:['まっかな飴の中から、すっぱいりんご。','カリッ……かたい！ でも、あまい。'],
   keeper:{skin:'#f3d0b5',hair:'#3a2a1e',style:'pony',shirt:'#f0a0b8',bottom:'skirt',bottomCol:'#6b7a8a',apron:'#f4efe2'},
   ware:Mk=>{Mk(new THREE.BoxGeometry(1.6,0.12,0.4),tm('#d8d2c6'),0.008).position.set(0,1.06,0.05);for(let k=0;k<7;k++){const px=-0.66+k*0.22;
     Mk(new THREE.CylinderGeometry(0.01,0.01,0.3,4),tm('#e9dcb0'),0).position.set(px,1.25,0.05);Mk(new THREE.SphereGeometry(0.085,10,8),tm('#d0201a'),0.005).position.set(px,1.42,0.05);}}},
  {id:'takoyaki',sd:1,z:-152,name:'たこ焼き',col:'#e8a23a',price:400,food:true,say:['あつあつのたこ焼き、8個入りだよ！'],eat:['ふうふう……あふっ、あつい！','中はとろとろ。大きなたこが入っていた。'],
   keeper:{skin:'#e6bb95',hair:'#2b2520',style:'short',shirt:'#f4efe2',bottom:'pants',bottomCol:'#3b4a66',apron:'#2e5fa8',scarf:'#c8372d'},
   ware:Mk=>{Mk(new THREE.BoxGeometry(1.2,0.12,0.6),tm('#2b2724'),0.01).position.set(-0.3,1.06,-0.05);for(let a=0;a<4;a++)for(let b=0;b<3;b++)Mk(new THREE.SphereGeometry(0.07,8,6),tm('#c98a3a'),0).position.set(-0.68+a*0.25,1.14,-0.25+b*0.2);
     for(let k=0;k<2;k++)Mk(new THREE.BoxGeometry(0.3,0.06,0.2),tm('#e9dcb0'),0.005).position.set(0.75,1.04+k*0.07,0.2);}},
];
{ const red=new THREE.MeshToonMaterial({color:'#e8452f',gradientMap:GRAD,emissive:'#ffa060',emissiveIntensity:0}),
    white=new THREE.MeshToonMaterial({color:'#f4efe2',gradientMap:GRAD,emissive:'#ffe2b0',emissiveIntensity:0}),cap=tm('#2b2520'),rope=tm('#3a2f26');
  NIGHT_MATS.push(red,white);FEST.red=red;
  const lg=new THREE.CylinderGeometry(0.2,0.2,0.42,10),cg=new THREE.CylinderGeometry(0.12,0.12,0.06,8);
  const lantern=(x,y,z,k)=>{const m=new THREE.Mesh(lg,k%3===2?white:red);m.position.set(x,y,z);outline(m,0.012);FEST.lanterns.add(m);
    for(const s of [1,-1]){const c=new THREE.Mesh(cg,cap);c.position.set(x,y+s*0.23,z);FEST.lanterns.add(c);}};
  const line=(a,b,n,sag)=>{const A=new THREE.Vector3(...a),B=new THREE.Vector3(...b);   // a rope with lanterns hanging along it
    for(let k=0;k<n;k++){const t=(k+0.5)/n,p=A.clone().lerp(B,t);p.y-=Math.sin(t*Math.PI)*sag;lantern(p.x,p.y-0.32,p.z,k);}
    const r=new THREE.Mesh(new THREE.CylinderGeometry(0.015,0.015,A.distanceTo(B),4),rope);r.position.copy(A).add(B).multiplyScalar(0.5);r.position.y-=sag*0.6;r.lookAt(B);r.rotateX(Math.PI/2);FEST.lanterns.add(r);};
  // the shrine approach: posts on both sides with a rope of lanterns between them
  const x=SHRINE.x;for(const sd of [-1,1]){const pts=[];for(let z=-127.5;z>=-157.5;z-=6){const y=G(x+sd*3.6,z);pts.push([x+sd*3.6,y+2.6,z]);
      const p=new THREE.Mesh(new THREE.CylinderGeometry(0.06,0.06,2.6,6),rope);p.position.set(x+sd*3.6,y+1.3,z);FEST.lanterns.add(p);}
    for(let k=0;k+1<pts.length;k++)line(pts[k],pts[k+1],3,0.25);}
  // across the shopping street and the top of the main street
  for(let sx=-60;sx<=60;sx+=10)if(Math.abs(sx)>6){const y=G(sx,-20)+4.6;line([sx,y,-24.6],[sx,y,-15.4],4,0.5);}
  for(let z=-190;z<=-120;z+=14){const y=G(0,z)+4.8;line([-5.4,y,z],[5.4,y,z],5,0.55);}
  FEST.lanterns.visible=false;world.add(FEST.lanterns);
  // six stalls along the approach, facing the path, each with its keeper behind the counter and its wares on it
  const awning=canvasTex(128,32,(g,w,h)=>{for(let k=0;k<8;k++){g.fillStyle=k%2?'#f4efe2':'#d8452f';g.fillRect(k*16,0,16,h);}});
  const signTex=(t,col)=>canvasTex(160,48,(g,w,h)=>{g.fillStyle='#fffaf0';g.fillRect(0,0,w,h);g.fillStyle=col;g.fillRect(0,h-6,w,6);g.fillStyle='#c8372d';g.font='900 28px "Zen Maru Gothic", sans-serif';g.textAlign='center';g.textBaseline='middle';g.fillText(t,w/2,h/2);});
  const nobori=(t,col)=>canvasTex(32,128,(g,w,h)=>{g.fillStyle=col;g.fillRect(0,0,w,h);g.fillStyle='#fffaf0';g.font='900 22px "Zen Maru Gothic", sans-serif';g.textAlign='center';g.textBaseline='middle';[...t].slice(0,4).forEach((c,k)=>g.fillText(c,w/2,18+k*28));});
  for(const S of YATAI){const sd=S.sd,z=S.z,sx=x+sd*5.6,y=G(sx,z),g=new THREE.Group();g.position.set(sx,y,z);g.rotation.y=sd>0?-Math.PI/2:Math.PI/2;FEST.stalls.add(g);S.g=g;
    const Mk=(geo,mat,ol)=>{const m=new THREE.Mesh(geo,mat);m.castShadow=true;if(ol)outline(m,ol);g.add(m);return m;};
    if(S.id!=='kingyo'){Mk(new THREE.BoxGeometry(2.6,0.95,1.1),tm('#8a6a4c'),0.02).position.set(0,0.48,0);Mk(new THREE.BoxGeometry(2.6,0.05,1.1),tm(S.col),0).position.set(0,0.98,0);}
    for(const px of [-1.25,1.25])for(const pz of [-0.5,0.5])Mk(new THREE.CylinderGeometry(0.04,0.04,2.3,6),tm('#6b4a2e'),0).position.set(px,1.15,pz);
    const aw=Mk(new THREE.BoxGeometry(2.9,0.06,1.6),tmap(awning),0.015);aw.position.set(0,2.35,0.15);aw.rotation.x=0.22;
    const sg=Mk(new THREE.BoxGeometry(1.6,0.48,0.04),tmap(signTex(S.name,S.col)),0.01);sg.position.set(0,1.95,0.62);
    const bulb=new THREE.Mesh(new THREE.SphereGeometry(0.08,8,6),white);bulb.position.set(0,2.15,0.5);g.add(bulb);
    const nb=Mk(new THREE.PlaneGeometry(0.34,1.36),tmap(nobori(S.name,S.col),{side:THREE.DoubleSide}),0);nb.position.set(1.5,1.65,0.7);nb.rotation.y=0.3;
    Mk(new THREE.CylinderGeometry(0.02,0.02,2.5,5),tm('#6b4a2e'),0).position.set(1.68,1.25,0.66);
    S.ware(Mk,g);
    const k=makeHuman(S.keeper);k.g.position.set(0,0,-0.85);g.add(k.g);S.k=k;
    const c=collide(sx-0.75,sx+0.75,z-1.4,z+1.4,'prop',y+1);c.on=false;g.userData.box=c;
    S.fx=sx-sd*1.75;S.fz=z;}   // in front of the counter, on the path side
  FEST.stalls.visible=false;world.add(FEST.stalls);
  // at night the grounds are lit warm by the lanterns and the stalls: a few lights along the approach and a glow at every stall's bulb
  FEST.lights=[-129,-141,-153].map(z=>{const l=new THREE.PointLight('#ffc68a',0,26,1.2);l.position.set(x,G(x,z)+4.2,z);scene.add(l);return l;});
  FEST.glows=YATAI.map(S=>{const bx=x+S.sd*(5.6-0.5),bz=S.z;return glow('#ffd9a0',bx,G(bx,bz)+2.15,bz,2.4);});
  FEST.lglows=[];for(const sd of [-1,1])for(let z=-130.5;z>=-154.5;z-=6)FEST.lglows.push(glow('#ffb070',x+sd*3.6,G(x+sd*3.6,z)+2.2,z,1.8));}
// fireworks: each burst is a shell of sparks that falls and fades, with a flash at its heart
function burst(p,col){const n=140,pos=new Float32Array(n*3),vel=[];const r=mulberry((Math.random()*1e6)|0);
  for(let k=0;k<n;k++){const u=r()*2-1,a=r()*TAU,s=Math.sqrt(1-u*u),sp=22+r()*4;vel.push(new THREE.Vector3(Math.cos(a)*s*sp,u*sp,Math.sin(a)*s*sp));pos.set([p.x,p.y,p.z],k*3);}
  const g=new THREE.BufferGeometry();g.setAttribute('position',new THREE.BufferAttribute(pos,3));
  const m=new THREE.Points(g,new THREE.PointsMaterial({color:col,size:4,sizeAttenuation:false,transparent:true,depthWrite:false,blending:THREE.AdditiveBlending,fog:false}));
  scene.add(m);const f=glow(col,p.x,p.y,p.z,60);f.visible=true;FEST.bursts.push({m,vel,t:0,f});}
function fireworks(sec){FEST.fwUntil=clock+sec;FEST.fwT=0;}
const FW_COL=['#ff5a4a','#ffd24a','#7ad8ff','#b78cff','#7dff9a','#ffffff','#ff9ad0'];
function updateFestival(dt){const fest=SAVE.flags.fest_day;
  // the decorations go up as the errands are done and come down after the festival; the stall keepers are only there on the day
  const season=!URA.on&&SAVE.flags.route===3&&SAVE.day<=6;
  FEST.lanterns.visible=season&&(fest||qs('fest_lantern').state===2);const st=season&&(fest||qs('fest_yatai').state===2);
  for(const S of YATAI)S.k.g.visible=festOn();
  if(FEST.stalls.visible!==st){FEST.stalls.visible=st;for(const g of FEST.stalls.children)g.userData.box.on=st;}
  updateCrowd(dt);
  const ng=FEST.red.emissiveIntensity/0.85,lit=FEST.lanterns.visible&&ng>0.02&&Math.abs(P.x-SHRINE.x)+Math.abs(P.z+141)<120;
  for(const l of FEST.lights)l.intensity=lit?ng*(festOn()?0.45:0.22):0;
  for(const g of FEST.glows){g.visible=lit&&st;g.material.opacity=ng;}for(const g of FEST.lglows){g.visible=lit;g.material.opacity=ng*0.8;}
  if(clock<FEST.fwUntil){FEST.fwT-=dt;if(FEST.fwT<=0){FEST.fwT=0.35+Math.random()*0.7;
      burst(new THREE.Vector3(-150+Math.random()*230,80+Math.random()*60,440+Math.random()*90),pick(FW_COL));}}
  for(const b of FEST.bursts.slice()){b.t+=dt;const a=b.m.geometry.attributes.position;
    for(let k=0;k<b.vel.length;k++){const v=b.vel[k];v.multiplyScalar(Math.exp(-dt*1.6));v.y-=6*dt;a.array[k*3]+=v.x*dt;a.array[k*3+1]+=v.y*dt;a.array[k*3+2]+=v.z*dt;}
    a.needsUpdate=true;b.m.material.opacity=clamp(2.2-b.t,0,1);b.f.material.opacity=clamp(1-b.t*3,0,1);
    if(b.t>2.4){scene.remove(b.m);scene.remove(b.f);b.m.geometry.dispose();b.m.material.dispose();b.f.material.dispose();FEST.bursts.splice(FEST.bursts.indexOf(b),1);}}}

/* the downhill race: start on the hilltop, finish at the end of the pier. The board is yours during it; the clock shows in the tracker */
const RACE={on:false,t:0,goal:null,res:null,mark:null,beam:null};
function raceP(o){return new Promise(res=>{ST.actor=null;talkNpc=null;P.x=o.from[0];P.z=o.from[1];P.yaw=o.from[2];P.v=0;P.y=G(P.x,P.z);rideNow();camInit=false;
  const lim=/racelimit=(\d+)/.exec(location.hash);   // test entry: #racelimit=5 ends the race after 5 s
  Object.assign(RACE,{on:false,t:0,goal:o.to,limit:lim?+lim[1]:o.limit||150,res,count:3.2});});}
function updateRace(dt){if(!RACE.res)return;const tr=$('tracker'),g=RACE.goal;
  if(!RACE.mark){RACE.mark=marker(MK.target);RACE.mark.scale.set(1.6,1.6,1);}
  RACE.mark.visible=true;RACE.mark.position.set(g[0],G(g[0],g[1])+3.2+Math.sin(clock*3)*0.12,g[1]);
  tr.hidden=false;
  if(!RACE.on){RACE.count-=dt;tr.innerHTML=`<b>坂下りレース</b><span class="step">${devText('桟橋の先がゴール。W で蹴って、A D で曲がる')}</span><span class="meter">${RACE.count>0.2?Math.ceil(RACE.count-0.2):'スタート！'}</span>`;
    if(RACE.count<=0.2){RACE.on=true;toast('スタート！',true);}return;}
  RACE.t+=dt;tr.innerHTML=`<b>坂下りレース</b><span class="step">桟橋の先がゴール</span><span class="meter">${RACE.t.toFixed(1)} 秒</span>`;
  const done=Math.hypot(P.x-g[0],P.z-g[1])<g[2],over=RACE.t>RACE.limit;
  if(done||over){const r=RACE.res,t=RACE.t;RACE.on=false;RACE.res=null;RACE.mark.visible=false;tr.hidden=true;r(done?t:-1);}}

/* the festival crowd: people in yukata walking up and down the approach and the main street, standing at the stalls, children with balloons.
   One set of instanced shapes, only on the festival day */
const festOn=()=>!!SAVE.flags.fest_day&&SAVE.day===6&&!URA.on;
const FCROWD=[];
{ const r=mulberry(606),P2=a=>a[Math.floor(r()*a.length)],x=SHRINE.x;
  const yk=['#2e3f6e','#f4efe2','#e8a0b4','#3a7bd5','#2b2520','#7a5aa8','#e8c94a','#4f8a6a','#c8372d','#9cc3e6'],obi=['#c8372d','#f2c230','#f4efe2','#e85a2a','#2e5fa8','#f0a0b8'];
  const add=o=>FCROWD.push(Object.assign({ph:r()*6,yk:C3(P2(yk)),obi:C3(P2(obi)),hair:C3(P2(['#1c1a1a','#2a1d15','#3a2a1e','#5a3a24'])),k:o.kid?0.7+r()*0.08:0.92+r()*0.14,bal:o.kid&&r()<0.7?C3(P2(['#e8452f','#3a7bd5','#f2c230','#4fbf6a','#f0a0b8'])):null},o));
  for(let n=0;n<26;n++){const kid=r()<0.3;add({kind:'walk',ax:'z',c:x+(r()<0.5?-1:1)*(1.2+r()*1.2),a:-155,b:-126,t:-155+r()*29,v:(0.6+r()*0.5)*(r()<0.5?1:-1),kid});}
  for(let n=0;n<18;n++){const kid=r()<0.25;add({kind:'walk',ax:'z',c:(r()<0.5?-1:1)*(4.4+r()*1.4),a:-190,b:-30,t:-190+r()*160,v:(0.7+r()*0.5)*(r()<0.5?1:-1),kid});}
  for(let n=0;n<10;n++){const kid=r()<0.3;add({kind:'walk',ax:'x',c:-20+(r()<0.5?-1:1)*(1.2+r()*1.6),a:-60,b:-8,t:-60+r()*52,v:(0.6+r()*0.5)*(r()<0.5?1:-1),kid});}
  // at the stalls: one to three in front of each, facing the counter
  for(const S of YATAI){const n=1+Math.floor(r()*2.6);for(let k=0;k<n;k++){const off=[-1.05,1.05,-1.7][k],kid=r()<0.35;
    add({kind:'stand',x:x+S.sd*(3.1+r()*0.4),z:S.z+off,yaw:S.sd>0?Math.PI/2:-Math.PI/2,kid});}}
  // little groups chatting by the gate and the lanterns
  for(const [gx,gz,n] of [[x+2.4,-126.2,3],[x-2.4,-137.5,2],[x+2.2,-147,3],[-6.5,-60,3],[6.5,-110,2]]){for(let k=0;k<n;k++){const a=k/n*TAU+r();add({kind:'stand',x:gx+Math.cos(a)*0.6,z:gz+Math.sin(a)*0.6,yaw:Math.atan2(-Math.cos(a),-Math.sin(a)),kid:r()<0.25});}}}
const fcMesh={};
{ const n=FCROWD.length,mk=(geo,key,col,cnt)=>{const im=new THREE.InstancedMesh(geo,tm('#ffffff'),cnt||n);im.instanceMatrix.setUsage(THREE.DynamicDrawUsage);im.castShadow=true;
    if(!cnt)FCROWD.forEach((p,k)=>im.setColorAt(k,key?p[key]:col));im.visible=false;im.frustumCulled=false;world.add(im);olInst(im,0.012);return im;};
  const V=(a,b)=>new THREE.Vector2(a,b);
  fcMesh.body=mk(new THREE.LatheGeometry([V(0.001,0.04),V(0.2,0.05),V(0.19,0.5),V(0.165,0.95),V(0.18,1.22),V(0.165,1.4),V(0.08,1.47),V(0.001,1.47)],14),'yk');
  fcMesh.obi=mk(new THREE.CylinderGeometry(0.178,0.172,0.16,14).translate(0,0.98,0),'obi');
  fcMesh.head=mk(new THREE.SphereGeometry(0.115,14,10).translate(0,1.58,0),null,C3('#efc7a6'));
  fcMesh.hair=mk(new THREE.SphereGeometry(0.124,14,10,0,TAU,0,Math.PI*0.56).translate(0,1.605,-0.012),'hair');
  fcMesh.bun=mk(new THREE.SphereGeometry(0.07,8,6).translate(0,1.66,-0.1),'hair');
  fcMesh.slL=mk(new THREE.BoxGeometry(0.1,0.4,0.24).translate(0,-0.2,0),'yk');fcMesh.slR=mk(new THREE.BoxGeometry(0.1,0.4,0.24).translate(0,-0.2,0),'yk');
  const kids=FCROWD.filter(p=>p.bal);fcMesh.bal=mk(new THREE.SphereGeometry(0.17,12,10).scale(1,1.15,1).translate(0,2.05,0.28),null,null,kids.length);kids.forEach((p,k)=>{p.bi=k;fcMesh.bal.setColorAt(k,p.bal);});
  fcMesh.str=mk(new THREE.CylinderGeometry(0.006,0.006,0.95,3).translate(0,1.42,0.24),null,null,kids.length);kids.forEach((p,k)=>fcMesh.str.setColorAt(k,C3('#f4efe2')));}
const FCB=new THREE.Object3D(),FCL=new THREE.Object3D();FCB.add(FCL);
function updateCrowd(dt){const on=festOn()&&Math.abs(P.x-SHRINE.x)+Math.abs(P.z+110)<260;
  for(const k in fcMesh)fcMesh[k].visible=on;if(!on)return;
  FCROWD.forEach((p,k)=>{let x,z,yaw,walking=false;
    if(p.kind==='walk'){[x,z]=p.ax==='z'?[p.c,p.t]:[p.t,p.c];const d=Math.hypot(x-P.x,z-P.z);p.stop=d<1.5?0.6:Math.max(0,(p.stop||0)-dt);
      if(p.stop<=0){p.t+=p.v*dt;walking=true;if(p.t<p.a||p.t>p.b){p.v=-p.v;p.t=clamp(p.t,p.a,p.b);}}
      [x,z]=p.ax==='z'?[p.c,p.t]:[p.t,p.c];yaw=p.ax==='z'?(p.v>0?0:Math.PI):(p.v>0?Math.PI/2:-Math.PI/2);}
    else{x=p.x;z=p.z;yaw=p.yaw;}
    p.ph+=dt*(walking?5.4:1.2);
    FCB.position.set(x,G(x,z)+(walking?Math.abs(Math.cos(p.ph))*0.02:0),z);FCB.rotation.set(0,yaw+(walking?0:Math.sin(p.ph*0.7)*0.15),0);FCB.scale.setScalar(p.k);FCB.updateMatrixWorld(true);
    for(const m of ['body','obi','head','hair','bun'])fcMesh[m].setMatrixAt(k,FCB.matrixWorld);
    const s=walking?Math.sin(p.ph):Math.sin(p.ph)*0.15;
    for(const [m,sx,sg] of [[fcMesh.slL,-1,-1],[fcMesh.slR,1,1]]){FCL.position.set(sx*0.2,1.4,0);FCL.rotation.set(-s*0.3*sg,0,sx*0.12);FCL.updateMatrixWorld(true);m.setMatrixAt(k,FCL.matrixWorld);}
    if(p.bal){FCL.position.set(0,0,0);FCL.rotation.set(Math.sin(p.ph*0.5)*0.08,0,Math.sin(p.ph*0.4)*0.1);FCL.updateMatrixWorld(true);fcMesh.bal.setMatrixAt(p.bi,FCL.matrixWorld);fcMesh.str.setMatrixAt(p.bi,FCL.matrixWorld);}});
  for(const k in fcMesh)fcMesh[k].instanceMatrix.needsUpdate=true;
  for(const S of YATAI)if(S.g.visible!==false&&Math.hypot(P.x-S.fx,P.z-S.fz)<60)poseHuman(S.k,'stand',dt,{look:Math.hypot(P.x-S.fx,P.z-S.fz)<6?player.g.position:null});}

/* buying at the stalls: food is eaten on the spot; the goldfish pool and the cork guns open a little game */
function festNear(){if(!FEST.stalls.visible||!festOn())return null;   // before the day the stalls stand empty
  let best=null;
  for(const S of YATAI){const d=Math.hypot(P.x-S.fx,P.z-S.fz);if(d<2.3&&(!best||d<best.d))best={kind:'yatai',S,d,label:`${S.game?'あそぶ':'買う'}　${S.name}（${S.price}円）`,verb:S.game?'あそぶ':'買う'};}
  return best;}
const FOODS=['kakigori','yakisoba','ringo','takoyaki'];
function yataiAct(o){const S=o.S,who=S.name+'の屋台';
  if(!festOn()){say(who,['お祭りの日においで！ いま準備しているところだよ。']);return;}
  if(S.game){say(who,S.say,()=>openYatai(S));return;}
  if(SAVE.money<S.price){say(who,S.say.concat(['……あれ、お金が足りないみたい。']));return;}
  say(who,S.say,()=>{SAVE.money-=S.price;sfx.pay&&sfx.pay();renderHUD();player.happyT=2.4;
    say('',S.eat,()=>{SAVE.flags['ate_'+S.id]=1;toast(`${S.name}を食べた（-${S.price}円）`);
      if(FOODS.every(id=>SAVE.flags['ate_'+id])&&!SAVE.flags.ate_all){SAVE.flags.ate_all=1;toast('屋台の食べ物を、ぜんぶ食べた！',true);}save();});});}

// the little games, drawn on a canvas in their own sheet
const YG={S:null,on:false,raf:0};
function openYatai(S){YG.S=S;$('yName').textContent=S.name;$('ySub').textContent=S.game==='kingyo'?'水の中に指（マウス）を入れて、金魚の下へ。はなすと すくう。動かしすぎるとポイが破れる。':'景品をねらって、タップ（クリック）でコルクを撃つ。照準は少しゆれる。上のほうに当てると倒れやすい。';
  YG.on=false;yDrawIdle();yButtons();openModal('yatai');cancelAnimationFrame(YG.raf);let last=performance.now();
  const tick=now=>{if(modal!=='yatai')return;const dt=Math.min(0.05,(now-last)/1000);last=now;if(YG.on){(S.game==='kingyo'?kingyoStep:shatekiStep)(dt);}(S.game==='kingyo'?kingyoDraw:shatekiDraw)();YG.raf=requestAnimationFrame(tick);};YG.raf=requestAnimationFrame(tick);}
function yButtons(){const b=$('yPlay'),S=YG.S;b.textContent=`${YG.played?'もう1回':'あそぶ'}（${S.price}円）`;b.disabled=YG.on||SAVE.money<S.price;}
function yStart(){const S=YG.S;if(YG.on||SAVE.money<S.price)return;SAVE.money-=S.price;renderHUD();YG.played=true;YG.on=true;YG.t=0;
  if(S.game==='kingyo')kingyoInit();else shatekiInit();yButtons();$('yInfo').textContent='';}
function yEnd(text,items){YG.on=false;$('yInfo').textContent=text;for(const id of items||[]){addItem(id,1);}if(items&&items.length)toast(items.map(id=>ITEMS[id].name).join('・')+'をもらった');save();yButtons();}
function yDrawIdle(){YG.fish=null;YG.prizes=null;$('yInfo').textContent=SAVE.money<YG.S.price?'お金が足りない':'';}
const yCv=()=>$('yCv'),yPt=e=>{const c=yCv(),r=c.getBoundingClientRect();return[(e.clientX-r.left)*c.width/r.width,(e.clientY-r.top)*c.height/r.height];};

// goldfish: they wander; the paper weakens while it is in the water and faster when it moves; lifting it out under a fish scoops it
function kingyoInit(){const r=Math.random;YG.fish=[];for(let k=0;k<11;k++){const big=k<2;YG.fish.push({x:40+r()*260,y:40+r()*170,a:r()*TAU,v:30+r()*30,big,col:big?'#2b2520':pick(['#f2582a','#f2582a','#e8452f','#f4efe2']),gone:false});}
  YG.poi={x:170,y:125,down:false,hp:100};YG.caught=0;}
function kingyoStep(dt){const W=340,H=250;for(const f of YG.fish){if(f.gone)continue;const p=YG.poi,d=Math.hypot(f.x-p.x,f.y-p.y);
    if(p.down&&d<60)f.a+=Math.sign(Math.sin(Math.atan2(f.y-p.y,f.x-p.x)-f.a))*dt*2;f.a+=(Math.random()-0.5)*dt*4;
    const sp=f.v*(p.down&&d<45?1.8:1);f.x+=Math.cos(f.a)*sp*dt;f.y+=Math.sin(f.a)*sp*dt;
    if(f.x<20||f.x>W-20){f.a=Math.PI-f.a;f.x=clamp(f.x,20,W-20);}if(f.y<20||f.y>H-20){f.a=-f.a;f.y=clamp(f.y,20,H-20);}}
  if(YG.poi.down){YG.poi.hp-=dt*9;if(YG.poi.hp<=0)kingyoBreak();}}
function kingyoBreak(){const p=YG.poi;p.hp=0;p.down=false;const n=YG.caught;
  yEnd(n?`ポイが破れた！ ${n}匹すくった。おじさんが1匹、袋に入れてくれた。`:'ポイが破れた！ 1匹もすくえなかった……。',n?['kingyo']:[]);if(n>(SAVE.flags.kingyo_best||0)){SAVE.flags.kingyo_best=n;save();}}
function kingyoDraw(){const c=yCv(),g=c.getContext('2d'),W=c.width,H=c.height;const gr=g.createLinearGradient(0,0,0,H);gr.addColorStop(0,'#8fd0f0');gr.addColorStop(1,'#4f9ac8');g.fillStyle=gr;g.fillRect(0,0,W,H);
  g.strokeStyle='rgba(255,255,255,.25)';g.lineWidth=2;const t=performance.now()/1000;for(let k=0;k<6;k++){g.beginPath();g.arc((k*67+t*9)%W,(k*41)%H,14+((t*20+k*13)%30),0,7);g.stroke();}
  for(const f of YG.fish||[]){if(f.gone)continue;g.save();g.translate(f.x,f.y);g.rotate(f.a);const s=f.big?1.5:1;g.fillStyle=f.col;g.beginPath();g.ellipse(0,0,11*s,6*s,0,0,7);g.fill();
    g.beginPath();g.moveTo(-8*s,0);g.lineTo(-18*s,-7*s+Math.sin(t*12+f.x)*2);g.lineTo(-18*s,7*s+Math.sin(t*12+f.x)*2);g.fill();g.fillStyle='#111';g.beginPath();g.arc(6*s,-2.5*s,1.5*s,0,7);g.arc(6*s,2.5*s,1.5*s,0,7);g.fill();g.restore();}
  const p=YG.poi;if(p){g.save();g.translate(p.x,p.y);g.globalAlpha=p.down?0.75:1;g.fillStyle=`rgba(255,255,255,${0.15+0.6*p.hp/100})`;g.beginPath();g.arc(0,0,26,0,7);g.fill();
    if(p.hp<=0){g.fillStyle='rgba(79,154,200,1)';g.beginPath();g.arc(4,3,18,0,7);g.fill();}
    g.strokeStyle='#e8452f';g.lineWidth=4;g.beginPath();g.arc(0,0,26,0,7);g.stroke();g.fillStyle='#e8452f';g.fillRect(20,14,34,7);g.restore();}
  g.fillStyle='rgba(255,250,240,.9)';g.fillRect(8,8,150,26);g.fillStyle='#2b2520';g.font='900 14px "Zen Maru Gothic", sans-serif';
  g.fillText(YG.fish?`すくった ${YG.caught||0}匹　ポイ ${Math.max(0,Math.ceil(p?p.hp:0))}`:'「あそぶ」で始める',16,26);}
function kingyoPtr(e,type){if(!YG.on||YG.S.game!=='kingyo')return;const [x,y]=yPt(e),p=YG.poi;
  if(type==='down'){p.down=true;p.x=x;p.y=y;}
  else if(type==='move'){if(p.down)p.hp-=Math.hypot(x-p.x,y-p.y)*0.09;p.x=x;p.y=y;if(p.down&&p.hp<=0)kingyoBreak();}
  else if(type==='up'&&p.down){p.down=false;let best=null,bd=1e9;for(const f of YG.fish){if(f.gone)continue;const d=Math.hypot(f.x-p.x,f.y-p.y);if(d<(f.big?30:24)&&d<bd){bd=d;best=f;}}
    if(best){const cost=best.big?32:13;if(p.hp>cost){p.hp-=cost;best.gone=true;YG.caught++;sfx.blip&&sfx.blip();if(YG.fish.every(f=>f.gone))yEnd(`ぜんぶすくった！ ${YG.caught}匹。お店の人もびっくり。`,['kingyo']);}else kingyoBreak();}}}

// the cork guns: five shots at a shelf of prizes; the sight sways a little; a prize falls after enough hits, sooner when hit near its top
function shatekiInit(){YG.corks=5;YG.fly=null;YG.aim={x:170,y:120};YG.won=[];
  YG.prizes=[{n:'キャラメル',it:'caramel',x:52,y:62,w:30,h:22,hp:1,col:'#f2c230'},{n:'けん玉',it:'kendama',x:160,y:62,w:26,h:36,hp:2,col:'#c8372d'},{n:'キャラメル',it:'caramel',x:268,y:62,w:30,h:22,hp:1,col:'#f2c230'},
    {n:'ラムネ',it:'ramune',x:95,y:126,w:18,h:42,hp:2,col:'#8fd0f0'},{n:'ラムネ',it:'ramune',x:235,y:126,w:18,h:42,hp:2,col:'#8fd0f0'},
    {n:'ぬいぐるみ',it:'nuigurumi',x:150,y:170,w:66,h:56,hp:4,col:'#e8b48a'},{n:'キャラメル',it:'caramel',x:270,y:170,w:30,h:22,hp:1,col:'#f2c230'}].map(p=>Object.assign(p,{hits:0,fall:0,wob:0}));}
function shatekiStep(dt){YG.t+=dt;for(const p of YG.prizes){p.wob=Math.max(0,p.wob-dt*3);if(p.fall>0)p.fall+=dt;}
  if(YG.fly){YG.fly.t+=dt;if(YG.fly.t>=0.22){const f=YG.fly;YG.fly=null;let hit=null;for(const p of YG.prizes){if(p.fall)continue;if(f.x>p.x-p.w/2-3&&f.x<p.x+p.w/2+3&&f.y>p.y-p.h-3&&f.y<p.y+3){hit=p;break;}}
      if(hit){hit.hits+=f.y<hit.y-hit.h*0.65?2:1;hit.wob=1;sfx.blip&&sfx.blip();if(hit.hits>=hit.hp){hit.fall=0.001;YG.won.push(hit.it);}}
      if(YG.corks<=0)setTimeout(()=>{if(!YG.on)return;const w=YG.won;yEnd(w.length?`${w.length}つ落とした！`:'ひとつも落ちなかった……。',w);},500);}}}
function shatekiSway(){const t=YG.t||0;return[Math.sin(t*2.3)*13+Math.sin(t*5.1)*5,Math.cos(t*1.7)*9+Math.sin(t*4.3)*3];}
function shatekiDraw(){const c=yCv(),g=c.getContext('2d'),W=c.width,H=c.height;g.fillStyle='#8a2a22';g.fillRect(0,0,W,H);g.fillStyle='rgba(0,0,0,.18)';for(let x=0;x<W;x+=18)g.fillRect(x,0,8,H);
  g.fillStyle='#6b4a2e';g.fillRect(20,62,300,10);g.fillRect(20,126,300,10);g.fillRect(20,170,300,10);
  for(const p of YG.prizes||[{n:'',x:0,y:0,w:0,h:0}]){if(!p.col)continue;g.save();const fy=p.fall?p.fall*p.fall*600:0;g.translate(p.x,p.y+fy);g.rotate(p.fall?p.fall*3:Math.sin(p.wob*20)*0.12*p.wob);g.globalAlpha=p.fall?Math.max(0,1-p.fall*2):1;
    g.fillStyle=p.col;if(p.it==='nuigurumi'){g.beginPath();g.arc(0,-p.h*0.35,p.h*0.36,0,7);g.fill();g.beginPath();g.arc(-p.w*0.3,-p.h*0.75,9,0,7);g.arc(p.w*0.3,-p.h*0.75,9,0,7);g.fill();g.fillStyle='#2b2520';g.beginPath();g.arc(-7,-p.h*0.4,2.5,0,7);g.arc(7,-p.h*0.4,2.5,0,7);g.fill();}
    else{g.fillRect(-p.w/2,-p.h,p.w,p.h);g.strokeStyle='rgba(0,0,0,.3)';g.strokeRect(-p.w/2,-p.h,p.w,p.h);}g.restore();}
  if(!YG.prizes){g.fillStyle='rgba(255,250,240,.9)';g.font='900 16px "Zen Maru Gothic", sans-serif';g.fillText('「あそぶ」で始める',100,230);return;}
  if(YG.fly){const f=YG.fly,k=f.t/0.22;g.fillStyle='#d9b26a';g.beginPath();g.arc(f.x,f.y+(1-k)*80,10-k*6,0,7);g.fill();}
  if(YG.on){const [sx,sy]=shatekiSway(),ax=YG.aim.x+sx,ay=YG.aim.y+sy;g.strokeStyle='#fffaf0';g.lineWidth=2;g.beginPath();g.arc(ax,ay,12,0,7);g.moveTo(ax-18,ay);g.lineTo(ax+18,ay);g.moveTo(ax,ay-18);g.lineTo(ax,ay+18);g.stroke();}
  g.fillStyle='rgba(255,250,240,.92)';g.fillRect(8,H-30,190,24);g.fillStyle='#2b2520';g.font='900 13px "Zen Maru Gothic", sans-serif';g.fillText(`コルク ${'●'.repeat(YG.corks)}${'○'.repeat(5-YG.corks)}　落とした ${YG.won.length}`,14,H-13);}
function shatekiPtr(e,type){if(!YG.on||YG.S.game!=='shateki')return;const [x,y]=yPt(e);YG.aim.x=x;YG.aim.y=y-(e.pointerType==='touch'?40:0);
  if(type==='up'&&YG.corks>0&&!YG.fly){const [sx,sy]=shatekiSway();YG.corks--;YG.fly={x:YG.aim.x+sx,y:YG.aim.y+sy,t:0};sfx.pop&&sfx.pop();}}
