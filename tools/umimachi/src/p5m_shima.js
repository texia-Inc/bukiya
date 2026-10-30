
/* ---------- 灯台の島: the island out at sea in front of the town, and its lighthouse.
   The fisherman's boat moored at the end of the pier takes you across, and back from the jetty on the island. A path climbs
   from the jetty along the ridge to the lighthouse on the top. Its door opens with grandpa's key (the true route) and stays
   open once the lamp is lit; the stairs inside come out on the gallery round the lamp. Heights come from islH(); the jetty
   deck stands above the ground, and the gallery is a collider the size of the tower with its top at the gallery floor. ---------- */
const ISL={x:180,z:760,wait:null,map:document.createElement('canvas'),lamp:null,glass:null,dev:null,devLight:null};
function islRaw(u,w){const e=Math.hypot(u/100,w/44)+(vnoise(u/16+7,w/16+3)-0.5)*0.14;
  return lerp(SEA_Y-3,SEA_Y+1.5,smooth(clamp((1-e)/0.16,0,1)))+15*Math.exp(-(((u-18)/60)**2)-((w/26)**2))*smooth(clamp((1-e)/0.35,0,1));}
const ISL_TOP=islRaw(18,0)+0.4;
const ISL_JETTY={u0:-57,u1:-53,w0:-64,w1:-22,y:SEA_Y+1.45};
// the lighthouse: on the top of the ridge, its door facing the town; gy is the gallery floor
const LH={x:ISL.x+18,z:ISL.z,base:ISL_TOP,h:22};LH.gy=LH.base+LH.h+0.2;
function islH(u,w){const h=islRaw(u,w),d=Math.hypot(u-18,w);return d<12?lerp(ISL_TOP,h,smooth(clamp((d-7.5)/4.5,0,1))):h;}
function islG(x,z){const u=x-ISL.x,w=z-ISL.z,J=ISL_JETTY;let h=islH(u,w);if(u>J.u0&&u<J.u1&&w>J.w0&&w<J.w1)h=Math.max(h,J.y);return h;}
ISL_ON=true;
// the path from the jetty up the ridge to the lighthouse door (island coordinates)
const ISL_PATH=[[-55,-24],[-50,-16],[-40,-9],[-24,-3],[-6,-1],[8,-3],[18,-5.5]];
const islPathD=(u,w)=>{let best=1e9;for(let i=1;i<ISL_PATH.length;i++){const [ax,az]=ISL_PATH[i-1],[bx,bz]=ISL_PATH[i],dx=bx-ax,dz=bz-az,L2=dx*dx+dz*dz;
  const t=clamp(((u-ax)*dx+(w-az)*dz)/L2,0,1);best=Math.min(best,Math.hypot(u-ax-dx*t,w-az-dz*t));}return best;};
{ const add=(m,x,y,z)=>{m.position.set(x,y,z);world.add(m);return m;};
  const Mi=(geo,mat,ol)=>{const m=new THREE.Mesh(geo,mat);m.castShadow=true;if(ol)outline(m,ol);return m;};
  const itm=c=>new THREE.MeshToonMaterial({color:c,gradientMap:GRAD});
  // the ground: sand at the water's edge, rock on the steep sides, grass on the rest
  { const pos=[],col=[],idx=[],N=113,W=57,c=new THREE.Color(),sand=new THREE.Color('#e2d3a8'),wet=new THREE.Color('#b9a77e'),grass=new THREE.Color('#5f9a52'),rock=new THREE.Color('#9a8a70');
    for(let r=0;r<W;r++)for(let k=0;k<N;k++){const u=-112+k*2,w=-56+r*2,h=islH(u,w);pos.push(ISL.x+u,h,ISL.z+w);
      const sl=Math.hypot(islH(u+1,w)-islH(u-1,w),islH(u,w+1)-islH(u,w-1))/2,n=vnoise(u/9,w/9);
      if(h<SEA_Y+0.3)c.copy(wet);else if(h<SEA_Y+1.9)c.copy(sand);else if(sl>0.55)c.copy(rock);else c.copy(grass).multiplyScalar(0.85+n*0.3);
      if(islPathD(u,w)<1.6&&h>SEA_Y+1)c.set('#c8b48a');col.push(c.r,c.g,c.b);
      if(r&&k){const a=(r-1)*N+k-1;idx.push(a,a+N,a+1,a+1,a+N,a+N+1);}}
    const geo=new THREE.BufferGeometry();geo.setAttribute('position',new THREE.Float32BufferAttribute(pos,3));geo.setAttribute('color',new THREE.Float32BufferAttribute(col,3));geo.setIndex(idx);geo.computeVertexNormals();
    const m=new THREE.Mesh(geo,new THREE.MeshToonMaterial({vertexColors:true,gradientMap:GRAD}));m.receiveShadow=true;world.add(m);}
  // the jetty: a plank deck on posts, the boat ties up on its east side
  { const J=ISL_JETTY,deck=tmap(canvasTex(64,64,(g,w,h)=>{g.fillStyle='#a88a64';g.fillRect(0,0,w,h);g.fillStyle='rgba(60,40,20,.35)';for(let y=0;y<h;y+=8)g.fillRect(0,y,w,1.5);},true));
    const d=add(Mi(new THREE.BoxGeometry(J.u1-J.u0,0.3,J.w1-J.w0),deck,0.02),ISL.x+(J.u0+J.u1)/2,J.y-0.15,ISL.z+(J.w0+J.w1)/2);d.receiveShadow=true;
    const posts=[];for(let w=J.w0+1;w<J.w1-6;w+=4)for(const u of [J.u0+0.2,J.u1-0.2])posts.push({x:ISL.x+u,z:ISL.z+w});
    inst(new THREE.CylinderGeometry(0.16,0.16,4,8),itm('#6b4a36'),posts,(e,dm)=>{dm.position.set(e.x,J.y-2,e.z);});}
  // the lighthouse: a white tower with red bands, a door at the foot, the gallery and its railing, the lamp room and a red roof
  { const g=new THREE.Group();g.position.set(LH.x,LH.base,LH.z);world.add(g);const white=tm('#f4f2ec'),red=tm('#d23a2c'),dark=tm('#3a3d44');
    g.add(Mi(new THREE.CylinderGeometry(2.2,3,LH.h,20),white,0.06).translateY(LH.h/2));
    for(const y of [7,15]){const r0=3-(3-2.2)*y/LH.h;g.add(Mi(new THREE.CylinderGeometry(r0-0.12,r0+0.02,1.6,20),red).translateY(y));}
    g.add(Mi(new THREE.CylinderGeometry(3.3,3.3,0.25,6),tm('#b4b0a6')).translateY(0.12));
    const door=Mi(new THREE.BoxGeometry(1.3,2.1,0.25),tm('#5a3f2c'),0.02);door.position.set(0,1.05,-2.9);g.add(door);
    g.add(Mi(new THREE.BoxGeometry(1.6,0.2,0.35),white).translateY(2.2).translateZ(-2.9));
    const gy=LH.gy-LH.base;g.add(Mi(new THREE.CylinderGeometry(3.6,3.0,0.3,24),dark,0.03).translateY(gy-0.15));
    const posts=[];for(let k=0;k<24;k++){const a=k/24*TAU;posts.push({x:Math.sin(a)*3.5,z:Math.cos(a)*3.5});}
    for(const p of posts)g.add(new THREE.Mesh(new THREE.BoxGeometry(0.07,1.0,0.07),dark).translateX(p.x).translateY(gy+0.5).translateZ(p.z));
    const ring=new THREE.Mesh(new THREE.TorusGeometry(3.5,0.05,6,40),dark);ring.rotation.x=Math.PI/2;ring.position.y=gy+1.0;g.add(ring);
    ISL.glass=new THREE.Mesh(new THREE.CylinderGeometry(1.6,1.6,2.8,16),new THREE.MeshToonMaterial({color:'#8fa3b0',gradientMap:GRAD,transparent:true,opacity:0.75}));ISL.glass.position.y=gy+1.4;g.add(ISL.glass);
    ISL.lamp=new THREE.Mesh(new THREE.SphereGeometry(0.6,14,10),new THREE.MeshBasicMaterial({color:'#6b6a64'}));ISL.lamp.position.y=gy+1.3;g.add(ISL.lamp);
    g.add(Mi(new THREE.CylinderGeometry(1.75,1.75,0.3,16),dark).translateY(gy+2.95));g.add(Mi(new THREE.ConeGeometry(2,2.2,16),red,0.04).translateY(gy+4.2));
    g.add(Mi(new THREE.SphereGeometry(0.3,10,8),dark).translateY(gy+5.4));
    // the hatch the stairs come up through, on the town side of the gallery
    g.add(new THREE.Mesh(new THREE.BoxGeometry(0.9,0.06,0.9),tm('#5a3f2c')).translateY(gy+0.03).translateZ(-2.6));
    collide(LH.x-3.45,LH.x+3.45,LH.z-3.45,LH.z+3.45,'lh',LH.gy);
    NIGHT.house.position.set(LH.x,LH.gy+1.4,LH.z);NIGHT.beam.position.copy(NIGHT.house.position);}
  // Oceangate's machine under the lighthouse: blinks red in time with the radio mast until the mast goes quiet
  { const x=LH.x+6.5,z=LH.z-2,y=islG(x,z),g=new THREE.Group();g.position.set(x,y,z);g.rotation.y=-0.4;world.add(g);ISL.dev=g;
    g.add(Mi(new THREE.BoxGeometry(1.3,1.0,0.9),tm('#22252b'),0.03).translateY(0.5));g.add(Mi(new THREE.BoxGeometry(1.32,0.08,0.92),tm('#e0662a')).translateY(0.85));
    g.add(Mi(new THREE.CylinderGeometry(0.03,0.03,1.6,6),tm('#40444c')).translateY(1.8));
    ISL.devLight=glow('#ff4030',x,y+2.7,z,1.6);collide(x-0.9,x+0.9,z-0.9,z+0.9,'prop',y+1.05);}
  // pines on the slopes, a bench at the top looking back at the town
  { const R=mulberry(77),trees=[];
    for(let k=0;k<400&&trees.length<70;k++){const u=-95+R()*190,w=-40+R()*80,h=islH(u,w);
      if(h<SEA_Y+2.5||islPathD(u,w)<3.5||Math.hypot(u-18,w)<14||(u>-60&&u<-48&&w<-18))continue;if(trees.some(t=>Math.hypot(t.u-u,t.w-w)<4))continue;
      trees.push({u,w,x:ISL.x+u,z:ISL.z+w,y:h,s:0.8+R()*0.6,col:new THREE.Color(['#3f7a4e','#4a8656','#386f47'][trees.length%3])});}
    inst(new THREE.ConeGeometry(1.6,4.6,8),itm('#ffffff'),trees,(e,d)=>{d.position.set(e.x,e.y+2.6*e.s+1,e.z);d.scale.setScalar(e.s);},{cast:true});
    inst(new THREE.CylinderGeometry(0.16,0.22,1.6,6),itm('#6b4a36'),trees,(e,d)=>{d.position.set(e.x,e.y+0.7*e.s,e.z);d.scale.setScalar(e.s);});
    for(const t of trees)collide(t.x-0.35,t.x+0.35,t.z-0.35,t.z+0.35,'tree');
    const bx=LH.x-7,bz=LH.z-7,b=new THREE.Group();b.position.set(bx,islG(bx,bz),bz);b.rotation.y=Math.PI;world.add(b);
    b.add(Mi(new THREE.BoxGeometry(1.8,0.08,0.5),tm('#a88a64'),0.01).translateY(0.45));b.add(Mi(new THREE.BoxGeometry(1.8,0.4,0.06),tm('#a88a64'),0.01).translateY(0.75).translateZ(-0.24));
    for(const x of [-0.75,0.75])b.add(Mi(new THREE.BoxGeometry(0.08,0.45,0.45),tm('#6b4a36')).translateX(x).translateY(0.22));
    collide(bx-1,bx+1,bz-0.35,bz+0.35,'prop',islG(bx,bz)+0.5);}
  // the map of the island
  { const c=ISL.map;c.width=240;c.height=140;const g=c.getContext('2d');g.fillStyle='#7cc0e6';g.fillRect(0,0,240,140);
    for(let w=-56;w<56;w+=2)for(let u=-112;u<112;u+=2){const h=islH(u,w);if(h<SEA_Y+0.1)continue;g.fillStyle=h<SEA_Y+1.9?'#e9dcb5':'#9fcf8a';g.fillRect(u+120,w+70,2,2);}
    g.strokeStyle='#c8b48a';g.lineWidth=2.4;g.beginPath();ISL_PATH.forEach(([u,w],i)=>i?g.lineTo(u+120,w+70):g.moveTo(u+120,w+70));g.stroke();
    const J=ISL_JETTY;g.fillStyle='#a88a64';g.fillRect(J.u0+120,J.w0+70,J.u1-J.u0,J.w1-J.w0);
    g.fillStyle='#f4f2ec';g.beginPath();g.arc(18+120,70,3.5,0,7);g.fill();g.fillStyle='#d23a2c';g.beginPath();g.arc(18+120,70,1.8,0,7);g.fill();}
}

/* the boat: the fisherman's, moored at the end of the pier or at the island's jetty; the crossing takes a quarter of a minute */
const BOAT={on:false,at:'town',t:0,dur:16,pts:null,yaw:0,res:null,look:0,
  moor:{town:{x:PIER.x1+1.9,z:331,yaw:0},island:{x:ISL.x-50.6,z:ISL.z-58,yaw:0}},g:new THREE.Group()};
{ const g=BOAT.g,Mi=(geo,mat,ol)=>{const m=new THREE.Mesh(geo,mat);m.castShadow=true;if(ol)outline(m,ol);return m;};world.add(g);
  const hull=Mi(new THREE.CylinderGeometry(0.8,1.3,7,12,1,false,-Math.PI/2,Math.PI),tm('#f4f2ec'),0.04);hull.rotation.x=Math.PI/2;g.add(hull);   // the lower half of a cone, narrow at the bow
  g.add(Mi(new THREE.BoxGeometry(2.62,0.16,6.2),tm('#2e5fa8')).translateY(-0.06));
  g.add(new THREE.Mesh(new THREE.BoxGeometry(2.3,0.08,6.6),tm('#b08a5e')).translateY(0.02));
  const cab=Mi(new THREE.BoxGeometry(1.7,1.4,1.8),tm('#f4f2ec'),0.03);cab.position.set(0,0.72,1.6);g.add(cab);
  g.add(Mi(new THREE.BoxGeometry(1.9,0.12,2.0),tm('#2e5fa8')).translateY(1.48).translateZ(1.6));
  g.add(new THREE.Mesh(new THREE.BoxGeometry(1.5,0.5,0.05),tm('#9fc4d8')).translateY(1.0).translateZ(0.69));
  g.add(Mi(new THREE.CylinderGeometry(0.04,0.04,2.4,6),tm('#6b4a36')).translateY(2.2).translateZ(1.6));
  g.add(Mi(new THREE.BoxGeometry(1.4,0.35,0.4),tm('#a88a64')).translateY(0.2).translateZ(-1.2));   // the bench Nagi sits on
  const m=BOAT.moor.town;g.position.set(m.x,SEA_Y+0.25,m.z);g.rotation.y=m.yaw;}
function boatPoint(t){const [a,b,c,d]=BOAT.pts,u=1-t;return[u*u*u*a[0]+3*u*u*t*b[0]+3*u*t*t*c[0]+t*t*t*d[0],u*u*u*a[1]+3*u*u*t*b[1]+3*u*t*t*c[1]+t*t*t*d[1]];}
function boatP(dest){return new Promise(res=>{if(BOAT.at===dest){res();return;}const A=BOAT.moor[BOAT.at],C=BOAT.moor[dest],s=dest==='island'?1:-1;
  BOAT.pts=[[A.x,A.z],[A.x,A.z+s*90],[C.x,C.z-s*90],[C.x,C.z]];Object.assign(BOAT,{on:true,t:0,res,dest,look:0});
  ST.actor=null;talkNpc=null;P.foot=true;P.carry='hand';P.tr=null;P.v=0;P.air=false;P.grind=null;
  document.body.classList.add('riding');releaseInputs();camInit=false;$('fade').style.opacity=0;
  toast(dest==='island'?'釣りのおじさんの船で、島へ':'釣りのおじさんの船で、町へ帰る');});}
function boatStep(dt){jumpQ=kickQ=footQ=trickQ=false;const B=BOAT,I=DLG||modal?{turn:0}:inputs();B.look=clamp(B.look+I.turn*dt*1.6,-1.3,1.3);
  B.t+=dt;const k=smooth(clamp(B.t/B.dur,0,1)),[x,z]=boatPoint(k),[x2,z2]=boatPoint(Math.min(1,k+0.01));
  if(k<0.999){const want=Math.atan2(x2-x,z2-z);let da=want-B.yaw;da=Math.atan2(Math.sin(da),Math.cos(da));B.yaw+=da*Math.min(1,dt*2.5);}
  const g=B.g;g.position.set(x,SEA_Y+0.25+Math.sin(clock*1.7)*0.08,z);g.rotation.set(Math.sin(clock*1.3)*0.025,B.yaw,Math.sin(clock*1.1)*0.03);
  const p=g.localToWorld(new THREE.Vector3(0,0.05,-1.0));P.x=p.x;P.z=p.z;P.y=p.y;P.yaw=B.yaw;P.v=0;
  player.g.position.copy(p);player.g.rotation.set(0,P.yaw,0);player.root.rotation.set(0,0,0);poseSitter(player,dt,B.look);
  if(B.t>=B.dur+0.6)boatArrive();}
function boatArrive(){const B=BOAT,m=B.moor[B.dest];B.on=false;B.at=B.dest;B.moor[B.dest].yaw=B.yaw;document.body.classList.remove('riding');releaseInputs();
  if(B.dest==='island'){P.x=ISL.x-55;P.z=ISL.z-58;P.yaw=0;}else{P.x=-80;P.z=331;P.yaw=Math.PI;}
  P.y=G(P.x,P.z);P.v=0;camInit=false;toast(B.dest==='island'?'灯台の島に着いた。道をのぼると灯台':'桟橋に戻ってきた');const r=B.res;B.res=null;if(r)r();}
function boatCam(want,look){const g=BOAT.g,F=new THREE.Vector3(Math.sin(BOAT.yaw+BOAT.look),0,Math.cos(BOAT.yaw+BOAT.look));
  want.copy(g.position).addScaledVector(F,-9.5).add(new THREE.Vector3(0,4.2,0));look.copy(g.position).addScaledVector(F,18).add(new THREE.Vector3(0,1.2,0));}

/* the lighthouse: in through the door, out on the gallery; the lamp is lit in the true route */
const onGallery=()=>P.z>ISL_Z0&&P.y>LH.gy-1.2&&Math.hypot(P.x-LH.x,P.z-LH.z)<6;
// on the gallery she walks round between the lamp room and the railing
function islClamp(){P.x=clamp(P.x,ISL.x-125,ISL.x+125);P.z=clamp(P.z,ISL_Z0+10,ISL.z+70);if(!onGallery())return;
  const dx=P.x-LH.x,dz=P.z-LH.z,r=Math.hypot(dx,dz)||1,rc=clamp(r,1.95,3.3);if(rc!==r){P.x=LH.x+dx/r*rc;P.z=LH.z+dz/r*rc;}}
function lampP(){return new Promise(res=>{ISL.wait=res;ST.actor=null;talkNpc=null;$('fade').style.opacity=0;renderHUD();});}
function islHUD(tr){tr.hidden=false;tr.innerHTML='';const b=document.createElement('b'),s=document.createElement('span');s.className='step';
  b.textContent='灯台の灯り';s.textContent=onGallery()?'灯台のてっぺん。まん中の灯りに近づいて、灯りをともす':P.z>ISL_Z0?'道をのぼって灯台へ。じいちゃんの鍵で扉を開けて、てっぺんへ':'桟橋の先の船で、島へ';tr.append(b,s);}
function islNear(){if(BOAT.on||URA.on)return null;let best=null;const add=(d,o)=>{if(!best||d<best.d){o.d=d;best=o;}};
  const m=BOAT.moor[BOAT.at],bd=BOAT.at==='town'?Math.hypot(P.x-(m.x-1.6),P.z-m.z):Math.hypot(P.x-(ISL.x-55),P.z-m.z);
  if(bd<3&&!ISL.wait)add(bd,{kind:'boat',label:BOAT.at==='town'?'乗る　島への船（釣りのおじさん）':'乗る　町へ帰る船',verb:'乗る'});
  if(P.z>ISL_Z0){
    if(!onGallery()){const d=Math.hypot(P.x-LH.x,P.z-(LH.z-3.6));if(d<2.4)add(d,{kind:'lhdoor',label:'入る　灯台',verb:'入る'});}
    else{const d=Math.hypot(P.x-LH.x,P.z-(LH.z-2.6));if(d<1.3)add(d,{kind:'lhdown',label:'降りる　らせん階段',verb:'降りる'});
      if(ISL.wait){const dl=Math.max(0,Math.hypot(P.x-LH.x,P.z-LH.z)-1.6);if(dl<1.6)add(dl-2,{kind:'lamp',label:'ともす　灯台の灯り',verb:'ともす'});}}}
  return best;}
function islFade(fn){$('fade').style.opacity=1;setTimeout(()=>{fn();camInit=false;$('fade').style.opacity=0;},700);}
function islAct(o){
  if(o.kind==='boat'){if(BOAT.at==='town')say('釣りのおじさん',['島へ行くのかい？ よし、乗りな。','灯台の下まで、道が一本のびてる。帰りたくなったら、島の桟橋の船に乗りな。'],()=>boatP('island'));else boatP('town');}
  else if(o.kind==='lhdoor'){if(!flag('true_key')&&!flag('lighthouse_lit')){say('',['さびた鉄の扉には、大きな錠前がかかっている。','……かぎがないと、入れそうにない。']);return;}
    islFade(()=>{P.x=LH.x;P.z=LH.z-2.6;P.y=LH.gy;P.yaw=Math.PI;P.v=0;P.air=false;toast('らせん階段をのぼって、灯台のてっぺんに出た');});}
  else if(o.kind==='lhdown')islFade(()=>{P.x=LH.x;P.z=LH.z-4.4;P.y=G(P.x,P.z);P.yaw=Math.PI;P.v=0;P.air=false;});
  else if(o.kind==='lamp'){const r=ISL.wait;ISL.wait=null;renderHUD();r();}}
function islPlace(){if(BOAT.on)return'釣り船の上';if(onGallery())return'灯台のてっぺん';const u=P.x-ISL.x,w=P.z-ISL.z;if(u<-45&&w<-15)return'島の桟橋';return'灯台の島';}
// every frame: the boat at its mooring (it goes back to the side Nagi is on), the lamp, the machine's red light
function updateIsland(dt){const B=BOAT;
  if(!B.on){const side=P.z>ISL_Z0?'island':'town';if(B.at!==side){B.at=side;}const m=B.moor[B.at];
    B.g.position.set(m.x,SEA_Y+0.25+Math.sin(clock*1.7)*0.08,m.z);B.g.rotation.set(Math.sin(clock*1.3)*0.02,m.yaw,Math.sin(clock*1.1)*0.025);}
  const lit=!!flag('lighthouse_lit');ISL.lamp.material.color.set(lit?'#fff3c4':'#6b6a64');ISL.glass.material.opacity=lit?0.35:0.75;
  ISL.devLight.visible=!flag('tower_quiet')&&(clock*1.2%1)<0.45;ISL.dev.visible=!flag('tower_quiet');
  if(ISL.wait&&!DLG&&!modal)islHUD($('tracker'));}
