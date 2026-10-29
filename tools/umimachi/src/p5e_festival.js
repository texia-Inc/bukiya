
/* ---------- the summer festival of the easy-going route: lanterns over the shrine approach and the shopping street,
   stalls at the shrine, fireworks over the sea, and the downhill race the kids call the skateboard contest ---------- */
const FEST={lanterns:new THREE.Group(),stalls:new THREE.Group(),bursts:[],fwUntil:0,fwT:0};
{ const red=new THREE.MeshToonMaterial({color:'#e8452f',gradientMap:GRAD,emissive:'#ffa060',emissiveIntensity:0}),
    white=new THREE.MeshToonMaterial({color:'#f4efe2',gradientMap:GRAD,emissive:'#ffe2b0',emissiveIntensity:0}),cap=tm('#2b2520'),rope=tm('#3a2f26');
  NIGHT_MATS.push(red,white);
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
  // three stalls along the approach, facing the path
  const awning=canvasTex(128,32,(g,w,h)=>{for(let k=0;k<8;k++){g.fillStyle=k%2?'#f4efe2':'#d8452f';g.fillRect(k*16,0,16,h);}});
  const signTex=t=>canvasTex(128,48,(g,w,h)=>{g.fillStyle='#fffaf0';g.fillRect(0,0,w,h);g.fillStyle='#c8372d';g.font='900 30px "Zen Maru Gothic", sans-serif';g.textAlign='center';g.textBaseline='middle';g.fillText(t,w/2,h/2+2);});
  for(const [sd,z,name,col] of [[-1,-134,'かき氷','#5aa3d8'],[1,-134,'やきそば','#e8a23a'],[-1,-145,'金魚すくい','#e8452f']]){
    const sx=x+sd*5.6,y=G(sx,z),g=new THREE.Group();g.position.set(sx,y,z);g.rotation.y=sd>0?-Math.PI/2:Math.PI/2;FEST.stalls.add(g);
    const Mk=(geo,mat,ol)=>{const m=new THREE.Mesh(geo,mat);m.castShadow=true;if(ol)outline(m,ol);g.add(m);return m;};
    Mk(new THREE.BoxGeometry(2.6,0.95,1.1),tm('#8a6a4c'),0.02).position.set(0,0.48,0);
    Mk(new THREE.BoxGeometry(2.6,0.05,1.1),tm(col),0).position.set(0,0.98,0);
    for(const px of [-1.25,1.25])for(const pz of [-0.5,0.5])Mk(new THREE.CylinderGeometry(0.04,0.04,2.3,6),tm('#6b4a2e'),0).position.set(px,1.15,pz);
    const aw=Mk(new THREE.BoxGeometry(2.9,0.06,1.6),tmap(awning),0.015);aw.position.set(0,2.35,0.15);aw.rotation.x=0.22;
    const sg=Mk(new THREE.BoxGeometry(1.4,0.5,0.04),tmap(signTex(name)),0.01);sg.position.set(0,1.95,0.62);
    const bulb=new THREE.Mesh(new THREE.SphereGeometry(0.08,8,6),white);bulb.position.set(0,2.15,0.5);g.add(bulb);
    const c=collide(sx-0.7,sx+0.7,z-1.4,z+1.4,'prop',y+1);c.on=false;g.userData.box=c;}
  FEST.stalls.visible=false;world.add(FEST.stalls);}
// fireworks: each burst is a shell of sparks that falls and fades, with a flash at its heart
function burst(p,col){const n=140,pos=new Float32Array(n*3),vel=[];const r=mulberry((Math.random()*1e6)|0);
  for(let k=0;k<n;k++){const u=r()*2-1,a=r()*TAU,s=Math.sqrt(1-u*u),sp=22+r()*4;vel.push(new THREE.Vector3(Math.cos(a)*s*sp,u*sp,Math.sin(a)*s*sp));pos.set([p.x,p.y,p.z],k*3);}
  const g=new THREE.BufferGeometry();g.setAttribute('position',new THREE.BufferAttribute(pos,3));
  const m=new THREE.Points(g,new THREE.PointsMaterial({color:col,size:4,sizeAttenuation:false,transparent:true,depthWrite:false,blending:THREE.AdditiveBlending,fog:false}));
  scene.add(m);const f=glow(col,p.x,p.y,p.z,60);f.visible=true;FEST.bursts.push({m,vel,t:0,f});}
function fireworks(sec){FEST.fwUntil=clock+sec;FEST.fwT=0;}
const FW_COL=['#ff5a4a','#ffd24a','#7ad8ff','#b78cff','#7dff9a','#ffffff','#ff9ad0'];
function updateFestival(dt){const fest=SAVE.flags.fest_day;
  FEST.lanterns.visible=!URA.on&&(fest||qs('fest_lantern').state===2);const st=!URA.on&&(fest||qs('fest_yatai').state===2);
  if(FEST.stalls.visible!==st){FEST.stalls.visible=st;for(const g of FEST.stalls.children)g.userData.box.on=st;}
  if(clock<FEST.fwUntil){FEST.fwT-=dt;if(FEST.fwT<=0){FEST.fwT=0.35+Math.random()*0.7;
      burst(new THREE.Vector3(-150+Math.random()*230,80+Math.random()*60,440+Math.random()*90),pick(FW_COL));}}
  for(const b of FEST.bursts.slice()){b.t+=dt;const a=b.m.geometry.attributes.position;
    for(let k=0;k<b.vel.length;k++){const v=b.vel[k];v.multiplyScalar(Math.exp(-dt*1.6));v.y-=6*dt;a.array[k*3]+=v.x*dt;a.array[k*3+1]+=v.y*dt;a.array[k*3+2]+=v.z*dt;}
    a.needsUpdate=true;b.m.material.opacity=clamp(2.2-b.t,0,1);b.f.material.opacity=clamp(1-b.t*3,0,1);
    if(b.t>2.4){scene.remove(b.m);scene.remove(b.f);b.m.geometry.dispose();b.m.material.dispose();b.f.material.dispose();FEST.bursts.splice(FEST.bursts.indexOf(b),1);}}}

/* the downhill race: start on the hilltop, finish at the end of the pier. The board is yours during it; the clock shows in the tracker */
const RACE={on:false,t:0,goal:null,res:null,mark:null,beam:null};
function raceP(o){return new Promise(res=>{ST.actor=null;talkNpc=null;P.x=o.from[0];P.z=o.from[1];P.yaw=o.from[2];P.v=0;P.y=G(P.x,P.z);P.foot=false;P.carry='deck';P.tr=null;camInit=false;
  const lim=/racelimit=(\d+)/.exec(location.hash);   // test entry: #racelimit=5 ends the race after 5 s
  Object.assign(RACE,{on:false,t:0,goal:o.to,limit:lim?+lim[1]:o.limit||150,res,count:3.2});});}
function updateRace(dt){if(!RACE.res)return;const tr=$('tracker'),g=RACE.goal;
  if(!RACE.mark){RACE.mark=marker(MK.target);RACE.mark.scale.set(1.6,1.6,1);}
  RACE.mark.visible=true;RACE.mark.position.set(g[0],G(g[0],g[1])+3.2+Math.sin(clock*3)*0.12,g[1]);
  tr.hidden=false;
  if(!RACE.on){RACE.count-=dt;tr.innerHTML=`<b>坂下りレース</b><span class="step">桟橋の先がゴール。W で蹴って、A D で曲がる</span><span class="meter">${RACE.count>0.2?Math.ceil(RACE.count-0.2):'スタート！'}</span>`;
    if(RACE.count<=0.2){RACE.on=true;toast('スタート！',true);}return;}
  RACE.t+=dt;tr.innerHTML=`<b>坂下りレース</b><span class="step">桟橋の先がゴール</span><span class="meter">${RACE.t.toFixed(1)} 秒</span>`;
  const done=Math.hypot(P.x-g[0],P.z-g[1])<g[2],over=RACE.t>RACE.limit;
  if(done||over){const r=RACE.res,t=RACE.t;RACE.on=false;RACE.res=null;RACE.mark.visible=false;tr.hidden=true;r(done?t:-1);}}
