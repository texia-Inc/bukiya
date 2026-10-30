
/* ---------- people ---------- */
function limb(rTop,rBot,len,seg){const V=(a,b)=>new THREE.Vector2(a,b);
  return new THREE.LatheGeometry([V(0,-len-rBot*0.6),V(rBot*0.78,-len-rBot*0.38),V(rBot,-len),V(rTop,0),V(rTop*0.78,rTop*0.38),V(0,rTop*0.6)],seg||10);}
const V2=(a,b)=>new THREE.Vector2(a,b);
const THIGH=0.40,SHIN=0.40;
function makeHuman(o){
  const g=new THREE.Group(),root=new THREE.Group();g.add(root);if(o.scale)root.scale.setScalar(o.scale);
  const Mh=(geo,mat,parent,ol=0.015)=>{const m=new THREE.Mesh(geo,mat);m.castShadow=true;if(ol)outline(m,ol);parent.add(m);return m;};
  const skin=tm(o.skin||'#f1cdb0'),shirt=tm(o.shirt||'#f2f2ee'),bot=tm(o.bottomCol||'#2b2f36'),hairM=tm(o.hair||'#2a1d15',{side:THREE.DoubleSide}),
    sock=tm(o.socks||'#f3f3ef'),shoe=tm(o.shoe||'#2b2520'),sole=tm('#f2f0ea');
  const bt=o.bottom||'pants',legSkin=bt==='shorts'||bt==='skirt'||bt==='skort';
  const hips=new THREE.Group();hips.position.y=0.93;root.add(hips);
  Mh(new THREE.SphereGeometry(0.165,16,10),bt==='long'||bt==='skirt'?tm(o.bottomCol||'#2b2f36'):bot,hips).scale.set(1.08,0.78,0.92);
  if(bt==='skirt'||bt==='skort'||bt==='long'){const len=bt==='long'?0.62:0.24,rb=bt==='long'?0.27:0.265;
    const tex=canvasTex(128,32,(c,w,h)=>{c.fillStyle=o.bottomCol||'#2b2f36';c.fillRect(0,0,w,h);c.fillStyle='rgba(255,255,255,.08)';for(let x=0;x<w;x+=8)c.fillRect(x,0,3,h);c.fillStyle='rgba(0,0,0,.22)';for(let x=5;x<w;x+=8)c.fillRect(x,0,2,h);},true);
    const sk=Mh(new THREE.LatheGeometry([V2(rb,-len),V2(0.215,-len*0.4),V2(0.175,0.05)],28),tmap(tex,{side:THREE.DoubleSide}),hips,0);sk.scale.z=0.92;}
  const torso=new THREE.Group();torso.position.y=0.04;hips.add(torso);
  const chest=Mh(limb(0.178,0.152,0.42,16),o.vest?tm(o.vest):shirt,torso);chest.position.y=0.42;chest.scale.z=0.78;
  if(o.apron){const ap=new THREE.Mesh(new THREE.PlaneGeometry(0.34,0.62),tm(o.apron,{side:THREE.DoubleSide}));ap.position.set(0,0.12,0.135);torso.add(ap);
    const ap2=new THREE.Mesh(new THREE.PlaneGeometry(0.4,0.42),tm(o.apron,{side:THREE.DoubleSide}));ap2.position.set(0,-0.22,0.16);ap2.rotation.x=-0.08;hips.add(ap2);}
  Mh(new THREE.CylinderGeometry(0.042,0.048,0.09,10),skin,torso,0).position.y=0.47;
  const head=new THREE.Group();head.position.y=0.585;torso.add(head);
  Mh(new THREE.SphereGeometry(0.115,20,14),skin,head).scale.set(0.96,1.06,1.0);
  const eyeM=new THREE.MeshBasicMaterial({color:'#2a1e18'});
  for(const sx of [-1,1]){const e=new THREE.Mesh(new THREE.SphereGeometry(0.016,8,6),eyeM);e.position.set(sx*0.042,0.0,0.106);e.scale.set(0.8,1.3,0.5);head.add(e);}
  const st=o.style||'short';
  if(st!=='bald'){const cr=Mh(new THREE.SphereGeometry(0.126,20,12,0,TAU,0,Math.PI*(st==='bun'||st==='grey'?0.5:0.56)),hairM,head,0);cr.position.set(0,0.02,-0.012);cr.scale.z=1.06;}
  if(st==='bob'){Mh(new THREE.LatheGeometry([V2(0.12,-0.14),V2(0.142,-0.125),V2(0.145,-0.05),V2(0.138,0.02),V2(0.122,0.06)],22,0.95,TAU-1.9),hairM,head,0).position.z=-0.012;
    const fr=Mh(new THREE.SphereGeometry(0.1,16,8),hairM,head,0);fr.scale.set(1.18,0.42,0.55);fr.position.set(0,0.078,0.072);}
  else if(st==='pony'){const tl=Mh(limb(0.045,0.022,0.24,10),hairM,head,0);tl.position.set(0,0.03,-0.12);tl.rotation.x=0.55;
    const fr=Mh(new THREE.SphereGeometry(0.1,16,8),hairM,head,0);fr.scale.set(1.15,0.4,0.5);fr.position.set(0,0.08,0.075);}
  else if(st==='bun'||st==='grey'){const bn=Mh(new THREE.SphereGeometry(0.065,12,10),hairM,head,0);bn.position.set(0,0.09,-0.1);}
  if(o.cap){const cm=tm(o.cap);const c=Mh(new THREE.SphereGeometry(0.132,18,10,0,TAU,0,Math.PI*0.5),cm,head,0);c.position.y=0.035;
    const brim=Mh(new THREE.CylinderGeometry(0.085,0.085,0.014,16),cm,head,0);brim.scale.z=1.25;brim.position.set(0,0.045,0.125);}
  if(o.hat==='chef'){const w=tm('#fbfbf8');Mh(new THREE.CylinderGeometry(0.12,0.12,0.12,16),w,head,0.01).position.y=0.12;const pf=Mh(new THREE.SphereGeometry(0.15,14,10),w,head,0.01);pf.position.y=0.22;pf.scale.y=0.7;}
  if(o.hat==='straw'){const s=tm('#e6c97a');Mh(new THREE.CylinderGeometry(0.27,0.27,0.015,24),s,head,0.01).position.y=0.07;Mh(new THREE.CylinderGeometry(0.11,0.13,0.1,16),s,head,0.01).position.y=0.12;}
  if(o.scarf){const sc=Mh(new THREE.SphereGeometry(0.135,18,10,0,TAU,0,Math.PI*0.55),tm(o.scarf),head,0);sc.position.y=0.015;sc.scale.set(1,1,1.08);}
  if(o.glasses){const gm=tm('#3a2a1e');for(const sx of [-1,1]){const r=new THREE.Mesh(new THREE.TorusGeometry(0.03,0.006,6,14),gm);r.position.set(sx*0.043,0.002,0.112);head.add(r);}}
  if(o.mustache){const m=new THREE.Mesh(new THREE.BoxGeometry(0.07,0.015,0.02),tm('#3a2a1e'));m.position.set(0,-0.05,0.11);head.add(m);}
  const arms=[];
  for(const sx of [-1,1]){const sh=new THREE.Group();sh.position.set(sx*0.188,0.37,0);sh.rotation.order='ZXY';torso.add(sh);
    const longS=o.sleeves==='long';Mh(limb(0.068,0.062,longS?0.27:0.13,12),shirt,sh);
    if(!longS)Mh(limb(0.047,0.04,0.27,10),skin,sh,0.008);
    const el=new THREE.Group();el.position.y=-0.27;sh.add(el);
    Mh(limb(longS?0.05:0.04,longS?0.045:0.033,0.24,10),longS?shirt:skin,el,0.008);
    const hand=Mh(new THREE.SphereGeometry(0.038,10,8),skin,el,0.006);hand.position.y=-0.27;hand.scale.set(0.8,1.1,0.6);
    arms.push({sh,el,sx});}
  const legs=[];
  for(const sx of [-1,1]){const th=new THREE.Group();th.rotation.order='ZXY';root.add(th);
    if(bt==='shorts'||bt==='skort')Mh(limb(0.09,0.082,0.17,12),bot,th);
    Mh(limb(0.074,0.056,THIGH,12),legSkin||bt==='long'?skin:bot,th,0.009);
    const kn=new THREE.Group();kn.position.y=-THIGH;th.add(kn);
    Mh(limb(0.056,0.042,SHIN-0.02,12),legSkin||bt==='long'?skin:bot,kn,0.009);
    if(o.kneeSocks)Mh(limb(0.06,0.047,0.31,12),sock,kn,0).position.y=-0.06;else if(legSkin||bt==='long')Mh(limb(0.051,0.047,0.12,12),sock,kn,0).position.y=-0.27;
    const ft=new THREE.Group();ft.position.y=-SHIN;kn.add(ft);
    Mh(new THREE.BoxGeometry(0.1,0.03,0.27),sole,ft,0.006).position.set(0,-0.07,0.045);
    const up=Mh(new THREE.SphereGeometry(0.06,14,8),shoe,ft,0.006);up.scale.set(0.82,0.62,1.95);up.position.set(0,-0.035,0.05);
    legs.push({th,kn,ft,sx});}
  let cane=null;if(o.cane){cane=new THREE.Mesh(new THREE.CylinderGeometry(0.014,0.014,0.86,6),tm('#6b4a2e'));cane.castShadow=true;root.add(cane);}
  return{g,root,hips,torso,head,arms,legs,cane,o,t:rnd()*10,yawHead:0};
}
function legFK(L,hx,hy,hz,th,kn){L.th.position.set(hx,hy,hz);L.th.rotation.set(th,0,0);L.kn.rotation.x=kn;L.ft.rotation.set(-(th+kn),L.sx*0.1,0);}
function solveLeg(L,hx,hy,hz,fx,fy,fz){
  L.th.position.set(hx,hy,hz);
  const dx=fx-hx,dy=fy-hy,dz=fz-hz,d=clamp(Math.sqrt(dx*dx+dy*dy+dz*dz),0.2,THIGH+SHIN-0.002);
  const a=Math.acos(clamp((THIGH*THIGH+d*d-SHIN*SHIN)/(2*THIGH*d),-1,1)),kn=Math.acos(clamp((THIGH*THIGH+SHIN*SHIN-d*d)/(2*THIGH*SHIN),-1,1));
  const phi=Math.atan2(dz,-dy),side=Math.atan2(dx,Math.hypot(dy,dz));
  L.th.rotation.set(-(phi+a),0,side);L.kn.rotation.x=Math.PI-kn;L.ft.rotation.set(-(L.th.rotation.x+L.kn.rotation.x),L.sx*0.22,0);}
const _v=new THREE.Vector3(),_e=new THREE.Euler();
function lookAtTarget(h,target,dt,max){let want=0;if(target){h.g.getWorldPosition(_v);const yaw=Math.atan2(target.x-_v.x,target.z-_v.z);
    let d=yaw-h.g.rotation.y;while(d>Math.PI)d-=TAU;while(d<-Math.PI)d+=TAU;want=Math.abs(d)<2.2?clamp(d,-(max||1),max||1):0;}
  h.yawHead+=(want-h.yawHead)*Math.min(1,4*dt);h.head.rotation.y=h.yawHead*0.75;h.torso.rotation.y=h.yawHead*0.25;}
function poseHuman(h,mode,dt,opt){opt=opt||{};h.t+=dt;const t=h.t,bend=h.o.bend||0;
  if(mode==='walk'){const ph=t*(opt.rate||6.2),s=Math.sin(ph);
    h.hips.position.set(0,0.92+Math.abs(Math.cos(ph))*0.022,0);h.torso.rotation.set(0.05+bend,s*0.06,0);h.head.rotation.x=-bend*0.6;
    for(const L of h.legs){const k=L.sx<0?1:-1;const th=-s*0.42*k;legFK(L,L.sx*0.09,h.hips.position.y-0.07,0,th,0.08+Math.max(0,-Math.cos(ph)*k)*0.65);}
    for(const a of h.arms){const k=a.sx<0?-1:1;a.sh.rotation.set(-s*0.38*k*-1,0,a.sx*0.1);a.el.rotation.x=-0.25;}}
  else if(mode==='sit'){h.hips.position.set(0,0.47,0.02);h.torso.rotation.x=0.1+bend;h.head.rotation.x=-0.05-bend*0.5;
    for(const L of h.legs)legFK(L,L.sx*0.1,0.43,0.02,-1.5,1.45);
    for(const a of h.arms){a.sh.rotation.set(-0.55,0,a.sx*0.18);a.el.rotation.x=-0.7;}}
  else{const br=Math.sin(t*1.7)*0.012;h.hips.position.set(Math.sin(t*0.4)*0.01,0.93,0);h.torso.rotation.x=0.03+bend+br;h.head.rotation.x=-bend*0.7;
    for(const L of h.legs)legFK(L,L.sx*0.09,h.hips.position.y-0.07,0,0.02,0.05);
    for(const a of h.arms){a.sh.rotation.set(0.05+(h.o.apron?0.25:0),0,a.sx*(0.12+(h.o.cane&&a.sx>0?0.15:0)));a.el.rotation.x=h.o.apron?-0.55:-0.18;}}
  if(opt.wave){const a=h.arms[1];a.sh.rotation.set(-0.25,0,2.45);a.el.rotation.x=-0.5+Math.sin(t*9)*0.45;}
  if(h.cane){if(mode==='sit'){h.cane.position.set(0.38,0.42,0.28);h.cane.rotation.set(0.25,0,-0.15);}else{h.cane.position.set(0.32,0.43,0.12);h.cane.rotation.set(0.1,0,0.08);}}
  lookAtTarget(h,opt.look,dt);
}

/* the player: a skater with a board, feet locked to the deck */
/* the player: a skater girl after the concept sheet — messy brown ponytail with a pink X clip, navy hoodie jacket over a white shirt and red bow,
   plaid pleated skirt over shorts, black crew socks, chunky pink sneakers, black backpack with a bunny charm, a worn pink deck with a bunny */
const ANKLE_Y=0.222;
function faceTex(expr){return canvasTex(256,256,(g,w,h)=>{g.clearRect(0,0,w,h);
  const eye=(cx,sgn)=>{const ey=h*0.5;g.save();g.translate(cx,ey);g.scale(1.28,1.28);g.translate(-cx,-ey);
    if(expr==='happy'){g.strokeStyle='#3a2216';g.lineWidth=7;g.lineCap='round';g.beginPath();g.arc(cx,ey+8,20,Math.PI*1.12,Math.PI*1.88);g.stroke();g.restore();return;}
    if(expr==='blink'){g.strokeStyle='#3a2216';g.lineWidth=6;g.lineCap='round';g.beginPath();g.arc(cx,ey-14,22,Math.PI*0.2,Math.PI*0.8);g.stroke();g.restore();return;}
    g.fillStyle='#ffffff';g.beginPath();g.ellipse(cx,ey,19,25,0,0,7);g.fill();
    const gr=g.createLinearGradient(0,ey-24,0,ey+24);gr.addColorStop(0,'#5a3212');gr.addColorStop(0.45,'#9a5a1c');gr.addColorStop(1,'#f0b040');
    g.fillStyle=gr;g.beginPath();g.ellipse(cx+sgn*1,ey+2,16,22,0,0,7);g.fill();
    g.fillStyle='#2a160c';g.beginPath();g.ellipse(cx+sgn*1,ey+2,8,12,0,0,7);g.fill();
    g.fillStyle='rgba(255,220,150,.7)';g.beginPath();g.ellipse(cx+sgn*1,ey+14,9,5,0,0,7);g.fill();
    g.fillStyle='#ffffff';g.beginPath();g.ellipse(cx-sgn*6,ey-9,6,7,0,0,7);g.fill();g.beginPath();g.arc(cx+sgn*7,ey+9,3,0,7);g.fill();
    g.strokeStyle='#2a160c';g.lineWidth=6;g.lineCap='round';g.beginPath();g.ellipse(cx,ey+2,21,27,0,Math.PI*1.08,Math.PI*1.92);g.stroke();
    g.lineWidth=4;g.beginPath();g.moveTo(cx+sgn*19,ey-14);g.lineTo(cx+sgn*29,ey-20);g.stroke();
    g.strokeStyle='rgba(60,30,15,.45)';g.lineWidth=2;g.beginPath();g.ellipse(cx,ey+2,19,25,0,Math.PI*0.25,Math.PI*0.75);g.stroke();g.restore();};
  eye(w*0.5-44,-1);eye(w*0.5+44,1);
  g.strokeStyle='rgba(90,50,25,.85)';g.lineWidth=3;g.lineCap='round';for(const s of [-1,1]){g.beginPath();g.moveTo(w/2+s*22,h*0.3);g.quadraticCurveTo(w/2+s*40,h*0.27,w/2+s*58,h*0.3);g.stroke();}
  g.fillStyle='rgba(255,120,130,.38)';for(const s of [-1,1]){g.beginPath();g.ellipse(w/2+s*62,h*0.64,18,9,0,0,7);g.fill();}
  g.strokeStyle='rgba(255,90,100,.55)';g.lineWidth=1.5;for(const s of [-1,1])for(let k=0;k<3;k++){g.beginPath();g.moveTo(w/2+s*(54+k*7),h*0.62);g.lineTo(w/2+s*(50+k*7),h*0.67);g.stroke();}
  const my=h*0.74;
  if(expr==='neutral'){g.strokeStyle='#6a2a22';g.lineWidth=3.5;g.beginPath();g.moveTo(w/2-9,my);g.quadraticCurveTo(w/2,my+7,w/2+9,my);g.stroke();}
  else{g.fillStyle='#7a2222';g.beginPath();g.moveTo(w/2-15,my-3);g.quadraticCurveTo(w/2,my-6,w/2+15,my-3);g.quadraticCurveTo(w/2+10,my+18,w/2,my+19);g.quadraticCurveTo(w/2-10,my+18,w/2-15,my-3);g.fill();
    g.fillStyle='#ef8a8a';g.beginPath();g.ellipse(w/2,my+12,8,5,0,0,7);g.fill();g.fillStyle='#ffffff';g.fillRect(w/2-10,my-4,20,3);}
  g.fillStyle='rgba(120,60,40,.35)';g.beginPath();g.arc(w/2+2,h*0.62,2,0,7);g.fill();});}
function pleatGeo(rTop,rBot,h,n){const geo=new THREE.CylinderGeometry(rTop,rBot,h,n*2,3,true),p=geo.attributes.position;
  for(let i=0;i<p.count;i++){const y=p.getY(i),x=p.getX(i),z=p.getZ(i),a=Math.atan2(z,x),k=Math.round(a/(Math.PI/n)),zig=(Math.abs(k)%2?1:-1),t=(h/2-y)/h,r=Math.hypot(x,z)+zig*0.012*t;
    p.setXYZ(i,Math.cos(a)*r,y,Math.sin(a)*r);}geo.computeVertexNormals();return geo;}
function makeSkater(){
  const g=new THREE.Group(),root=new THREE.Group();g.add(root);root.scale.setScalar(0.96);
  const H=(geo,mat,parent,ol=0.014)=>{const m=new THREE.Mesh(geo,mat);m.castShadow=true;if(ol)outline(m,ol);parent.add(m);return m;};
  const skin=tm('#f8d9c2'),hair=tm('#6b4328',{side:THREE.DoubleSide}),hairLite=tm('#8c5a36',{side:THREE.DoubleSide}),navy=tm('#2a2d45',{side:THREE.DoubleSide}),navyD=tm('#22243a'),
    white=tm('#f7f6f2'),red=tm('#c8323a'),pink=tm('#ef6f8a'),black=tm('#232327'),grey=tm('#9a9aa2'),sole=tm('#f4f2ee');
  const plaid=canvasTex(256,64,(c,w,h)=>{c.fillStyle='#4a4c5a';c.fillRect(0,0,w,h);c.fillStyle='rgba(30,30,40,.55)';for(let x=0;x<w;x+=32)c.fillRect(x,0,14,h);for(let y=0;y<h;y+=32)c.fillRect(0,y,w,14);
    c.fillStyle='rgba(220,220,230,.5)';for(let x=8;x<w;x+=32)c.fillRect(x,0,2,h);for(let y=8;y<h;y+=32)c.fillRect(0,y,w,2);c.fillStyle='rgba(200,60,70,.5)';for(let x=24;x<w;x+=64)c.fillRect(x,0,1.5,h);},true);
  plaid.repeat.set(3,1);
  // hips, skirt over shorts
  const hips=new THREE.Group();hips.position.y=0.93;root.add(hips);
  H(new THREE.SphereGeometry(0.155,16,10),navyD,hips).scale.set(1.06,0.76,0.92);
  const skirt=H(pleatGeo(0.165,0.255,0.27,14),tmap(plaid,{side:THREE.DoubleSide}),hips,0);skirt.position.y=-0.085;skirt.scale.z=0.9;
  // torso: shirt, open hoodie jacket, hood, collar and bow
  const torso=new THREE.Group();torso.position.y=0.04;hips.add(torso);
  const shirt=H(limb(0.158,0.142,0.4,16),white,torso);shirt.position.y=0.4;shirt.scale.z=0.76;
  const V=(a,b)=>new THREE.Vector2(a,b);
  const jacket=H(new THREE.LatheGeometry([V(0.205,-0.07),V(0.19,0.06),V(0.178,0.2),V(0.2,0.34),V(0.17,0.42),V(0.115,0.465)],28,0.42,TAU-0.84),navy,torso,0.012);jacket.scale.z=0.82;
  for(const s of [-1,1]){const z=H(new THREE.BoxGeometry(0.014,0.5,0.012),grey,torso,0);z.position.set(s*0.085,0.19,0.158);z.rotation.z=s*0.06;}
  const hood=H(new THREE.SphereGeometry(0.13,16,10),navy,torso);hood.scale.set(1.25,0.62,0.85);hood.position.set(0,0.44,-0.11);
  for(const s of [-1,1]){const c=H(new THREE.BoxGeometry(0.075,0.012,0.06),white,torso,0.005);c.position.set(s*0.04,0.445,0.105);c.rotation.set(0.5,s*0.5,s*0.5);}
  const bow=new THREE.Group();bow.position.set(0,0.405,0.128);torso.add(bow);
  for(const s of [-1,1]){const l=H(new THREE.SphereGeometry(0.036,12,8),red,bow,0.006);l.scale.set(1.5,0.85,0.5);l.position.x=s*0.045;
    const t=H(new THREE.BoxGeometry(0.022,0.07,0.01),red,bow,0.004);t.position.set(s*0.02,-0.045,0);t.rotation.z=s*0.35;}
  H(new THREE.SphereGeometry(0.018,10,8),red,bow,0.004);
  // backpack with a bunny charm
  const pack=new THREE.Group();pack.position.set(0,0.24,-0.165);torso.add(pack);
  H(new THREE.BoxGeometry(0.27,0.28,0.12),black,pack,0.01).position.y=-0.02;const ptop=H(new THREE.CylinderGeometry(0.06,0.06,0.27,14,1,false,0,Math.PI).rotateZ(Math.PI/2),black,pack,0.01);ptop.position.y=0.12;ptop.scale.set(1,1,1);ptop.rotation.y=0;
  H(new THREE.BoxGeometry(0.2,0.14,0.05),tm('#2e2e33'),pack,0.008).position.set(0,-0.06,-0.07);
  for(const s of [-1,1]){const st=H(new THREE.BoxGeometry(0.035,0.012,0.32),tm('#1c1c20'),torso,0);st.position.set(s*0.12,0.43,-0.02);st.rotation.x=-0.15;}
  const charm=new THREE.Group();charm.position.set(0.13,0.05,-0.04);pack.add(charm);
  H(new THREE.CylinderGeometry(0.003,0.003,0.06,4),tm('#d9d9d9'),charm,0).position.y=-0.03;
  const bun=new THREE.Group();bun.position.y=-0.085;charm.add(bun);
  H(new THREE.SphereGeometry(0.035,12,10),tm('#f7a6bd'),bun,0.005);
  for(const s of [-1,1]){const e=H(limb(0.012,0.008,0.045,6),tm('#f7a6bd'),bun,0.004);e.position.set(s*0.017,0.05,0);e.rotation.set(Math.PI,0,s*0.25);}
  for(const s of [-1,1]){const d=new THREE.Mesh(new THREE.SphereGeometry(0.005,6,4),tm('#3a2216'));d.position.set(s*0.012,0.004,0.032);bun.add(d);}
  // neck and head
  H(new THREE.CylinderGeometry(0.038,0.044,0.07,10),skin,torso,0).position.y=0.475;
  const head=new THREE.Group();head.position.y=0.6;torso.add(head);
  // head, face and hair modelled in Blender: the face texture is projected from the front, so expressions are drawn on a canvas and swapped
  const faces={neutral:faceTex2('neutral'),smile:faceTex2('smile'),happy:faceTex2('happy'),blink:faceTex2('blink')};
  const faceM=new THREE.MeshBasicMaterial({map:faces.smile,color:'#fbf6f4'});   // anime faces stay flat and bright
  H(meshFromData(HEROINE_HEAD.head),faceM,head,0.0035);
  const hairV=new THREE.MeshToonMaterial({color:'#6b4328',vertexColors:true,gradientMap:GRAD,side:THREE.DoubleSide});
  H(meshFromData(HEROINE_HEAD.cap),tm('#5e3a22',{side:THREE.DoubleSide}),head,0.003);
  H(meshFromData(HEROINE_HEAD.hair),hairV,head,0.0025);
  const tie=new THREE.Group();tie.position.set(0,0.1,-0.115);head.add(tie);
  H(new THREE.TorusGeometry(0.035,0.018,8,16),tm('#d8455a'),tie,0.005).rotation.x=1.1;
  const tail=[];let par=tie;
  for(const [rt,rb,len,rx] of [[0.04,0.052,0.08,1.75],[0.052,0.062,0.17,-0.95],[0.062,0.034,0.2,-0.45],[0.034,0.006,0.15,-0.2]]){const seg=new THREE.Group();seg.rotation.x=rx;par.add(seg);
    if(par!==tie)seg.position.y=-par.userData.len;seg.userData.len=len;seg.userData.rx=rx;
    H(meshFromData(HEROINE_HEAD['tail'+tail.length]),hairV,seg,0.0025);
    tail.push(seg);par=seg;}
  const clip=new THREE.Group();clip.position.set(-0.078,0.088,0.108);clip.rotation.set(-0.4,-0.5,0);head.add(clip);
  for(const s of [-1,1]){const b=H(new THREE.BoxGeometry(0.045,0.01,0.008),pink,clip,0.003);b.rotation.z=s*0.785;}
  // arms in oversized sleeves
  const arms=[];
  for(const sx of [-1,1]){const sh=new THREE.Group();sh.position.set(sx*0.18,0.37,0);sh.rotation.order='ZXY';torso.add(sh);
    H(new THREE.SphereGeometry(0.075,12,10),navy,sh,0.01);
    H(limb(0.072,0.066,0.26,12),navy,sh,0.01);
    const el=new THREE.Group();el.position.y=-0.25;sh.add(el);
    H(limb(0.066,0.074,0.22,12),navy,el,0.01);
    const cuff=H(new THREE.TorusGeometry(0.066,0.014,8,16),navyD,el,0);cuff.rotation.x=Math.PI/2;cuff.position.y=-0.22;
    const hand=H(new THREE.SphereGeometry(0.034,10,8),skin,el,0.006);hand.position.y=-0.255;hand.scale.set(0.85,1.15,0.6);
    const th=H(new THREE.SphereGeometry(0.014,8,6),skin,el,0);th.position.set(-sx*0.025,-0.24,0.018);
    arms.push({sh,el,sx});}
  // legs: shorts under the skirt, black crew socks with a pink band, chunky sneakers
  const legs=[];
  for(const sx of [-1,1]){const th=new THREE.Group();th.rotation.order='ZXY';root.add(th);
    H(limb(0.088,0.082,0.15,12),navyD,th);
    H(limb(0.074,0.058,THIGH,12),skin,th,0.009);
    const kn=new THREE.Group();kn.position.y=-THIGH;th.add(kn);
    H(limb(0.058,0.043,SHIN-0.02,12),skin,kn,0.009);
    H(limb(0.052,0.047,0.2,12),black,kn,0).position.y=-0.19;
    const band=H(new THREE.TorusGeometry(0.051,0.007,6,16),pink,kn,0);band.rotation.x=Math.PI/2;band.position.y=-0.215;
    const ft=new THREE.Group();ft.position.y=-SHIN;kn.add(ft);
    H(new THREE.BoxGeometry(0.11,0.048,0.29),sole,ft,0.006).position.set(0,-0.074,0.045);
    H(new THREE.BoxGeometry(0.112,0.012,0.292),tm('#e8607a'),ft,0).position.set(0,-0.052,0.045);
    const up=H(new THREE.SphereGeometry(0.062,14,10),white,ft,0.007);up.scale.set(0.88,0.7,2.0);up.position.set(0,-0.03,0.05);
    for(const s of [-1,1]){const pn=H(new THREE.BoxGeometry(0.006,0.035,0.12),pink,ft,0);pn.position.set(s*0.053,-0.03,0.03);pn.rotation.x=-0.25;}
    const toe=H(new THREE.SphereGeometry(0.045,10,8),grey,ft,0);toe.scale.set(1.1,0.6,1);toe.position.set(0,-0.045,0.135);
    for(let k=0;k<3;k++){const l=new THREE.Mesh(new THREE.BoxGeometry(0.06,0.006,0.012),white);l.position.set(0,0.0+k*-0.004,0.06+k*0.025);ft.add(l);}
    H(new THREE.BoxGeometry(0.05,0.05,0.02),pink,ft,0).position.set(0,0.0,-0.08);
    legs.push({th,kn,ft,sx});}
  // the board: black grip on top, a worn pink deck with a grey bunny underneath, pink wheels
  const deckTex=canvasTex(128,512,(c,w,h)=>{c.fillStyle='#d8607a';c.fillRect(0,0,w,h);const r=mulberry(21);
    for(let k=0;k<160;k++){c.fillStyle=`rgba(30,20,25,${0.25+r()*0.5})`;c.beginPath();c.ellipse(r()*w,r()*h,4+r()*26,2+r()*12,r()*3,0,7);c.fill();}
    c.fillStyle='#b8b4bc';c.beginPath();c.ellipse(w/2,h*0.62,34,28,0,0,7);c.fill();for(const s of [-1,1]){c.beginPath();c.ellipse(w/2+s*16,h*0.62-40,9,26,s*0.2,0,7);c.fill();}
    c.fillStyle='#3a2a30';for(const s of [-1,1]){c.beginPath();c.arc(w/2+s*12,h*0.615,3.5,0,7);c.fill();}c.beginPath();c.arc(w/2,h*0.635,2,0,7);c.fill();
    c.strokeStyle='#3a2a30';c.lineWidth=2;c.beginPath();c.arc(w/2-4,h*0.645,4,0,Math.PI);c.arc(w/2+4,h*0.645,4,0,Math.PI);c.stroke();});
  const gripM=tm('#1d1d20'),edgeM=tm('#e3c79a'),deckM=tmap(deckTex),metal=tm('#c2c6cc'),wheelM=tm('#ef6f8a'),board=new THREE.Group();root.add(board);
  const Mb=(geo,mat,ol=0.01)=>{const m=new THREE.Mesh(geo,mat);m.castShadow=true;if(ol)outline(m,ol);board.add(m);return m;};
  Mb(new THREE.BoxGeometry(0.22,0.025,0.62),[edgeM,edgeM,gripM,deckM,edgeM,edgeM]).position.y=0.112;
  for(const sz of [-1,1]){const t=Mb(new THREE.BoxGeometry(0.22,0.025,0.17),[edgeM,edgeM,gripM,tm('#c8506a'),edgeM,edgeM]);t.position.set(0,0.131,sz*0.385);t.rotation.x=-sz*0.32;}
  const wheelG=new THREE.CylinderGeometry(0.034,0.034,0.038,16).rotateZ(Math.PI/2),wheels=[];
  for(const sz of [-1,1]){Mb(new THREE.BoxGeometry(0.17,0.03,0.045),metal,0.006).position.set(0,0.078,sz*0.24);Mb(new THREE.BoxGeometry(0.05,0.04,0.06),metal,0).position.set(0,0.095,sz*0.24);
    for(const sx of [-1,1]){const w=Mb(wheelG,wheelM,0.006);w.position.set(sx*0.1,0.034,sz*0.24);wheels.push(w);}}
  return{g,root,hips,torso,head,arms,legs,board,wheels,tail,charm,bun,faceM,faces,o:{},t:0,yawHead:0,pose:{c:0.3,st:0,push:0},blink:2,happyT:0,tailV:0,prevV:0};
}
function animHeroine(h,dt,s){
  h.blink-=dt;let expr=s.v>2.5&&s.v<5.5&&!s.air?'neutral':'smile';if(h.happyT>0){h.happyT-=dt;expr='happy';}if(s.talk)expr=Math.floor(h.t*7)%2?'smile':'neutral';
  if(h.blink<0){expr=expr==='happy'?'happy':'blink';if(h.blink<-0.12)h.blink=2.2+Math.random()*3;}
  if(h.faceM.map!==h.faces[expr]){h.faceM.map=h.faces[expr];h.faceM.needsUpdate=true;}
  const acc=(s.v-h.prevV)/Math.max(dt,1e-3);h.prevV=s.v;
  h.tailV+=((-acc*0.04+(s.air?-0.4:0))-h.tailV)*Math.min(1,dt*6);
  const sw=Math.sin(h.t*2.3)*0.06,turn=clamp(s.turn,-1,1);
  h.tail.forEach((seg,k)=>{seg.rotation.x=seg.userData.rx+(k?h.tailV*0.6+s.v*0.025*(k===1?1:0.5):0)+Math.sin(h.t*3+k)*0.03;seg.rotation.z=sw*(k+1)*0.6+turn*0.18*k;});
  h.charm.rotation.z=Math.sin(h.t*4.2)*0.25+turn*0.3;h.charm.rotation.x=Math.sin(h.t*3.1)*0.15-acc*0.01;
}
function poseSkater(h,dt,s){const P=h.pose;h.t+=dt;h.hold=null;h.kneeOut=0.18;
  let crouch=s.brake?0.2:s.v>6?0.55:0.28;if(s.air)crouch=0.8;if(s.grind)crouch=0.62;P.c+=(crouch-P.c)*Math.min(1,6*dt);
  P.st+=(clamp(s.turn,-1,1)-P.st)*Math.min(1,5*dt);P.push+=((s.push?1:0)-P.push)*Math.min(1,6*dt);
  // stance (LEAD = the leg on the nose, +1 = left foot forward, facing the right of the board seen from behind): riding, the body
  // turns side-on across the deck and the head looks
  // down the line; pushing, the hips square up to face forward. On the title screen she stands half turned to the camera.
  const LEAD=1,M=-LEAD;const sideT=P.push>0.25?0:(typeof state!=='undefined'&&state==='title')?0.5:1;if(P.sd==null)P.sd=sideT;P.sd+=(sideT-P.sd)*Math.min(1,5*dt);
  const c=P.c,sd=P.sd,yaw=1.25*sd*M;
  // pushing: stand tall on a nearly straight front leg, drop the pelvis a little on the pushing side and sink slightly through the stroke
  const kp=s.kick!=null&&s.kick>=0?s.kick:(h.t*1.0)%1,stroke=kp<0.3?0:kp<0.65?(kp-0.3)/0.35:1-(kp-0.65)/0.35;
  const hipY=lerp(0.93+0.045*sd-0.24*c*(1-0.55*sd),1.0-0.035*stroke,P.push);
  // jumps: the ollie pop (tail down, nose up) on take-off, knees and board pulled up in the air, and an indy grab
  // (back hand on the toe edge between the feet) while she is still rising or near the top
  if(s.air&&!P.airT)P.pop=(s.vy||0)>3;   // a real jump (not rolling off a kerb) pops and grabs
  P.airT=s.air?(P.airT||0)+dt:0;P.tk=(P.tk||0)+((s.air?1:0)-(P.tk||0))*Math.min(1,(s.air?10:16)*dt);
  P.gr=(P.gr||0)+((s.air&&P.pop&&P.airT>0.16&&(s.vy==null||s.vy>-4.2)?1:0)-(P.gr||0))*Math.min(1,(s.air?9:18)*dt);
  const tk=P.tk,gr=P.gr,lift=0.3*tk+0.08*gr;
  // tricks: the board turns under her feet — about its long axis for a kickflip, flat round for a shove-it — while the feet
  // lift off it and come back down when it has gone round
  const fp=s.flip||0,spn=s.spin||0,trk=Math.sin(Math.PI*Math.max(fp,spn));
  h.board.position.set(0,lift+0.12*trk,0.02);   // x, z too: put straight on the board (a race start), it may still be where she carried it
  h.board.rotation.set(s.air&&P.pop?-0.42*Math.sin(Math.PI*Math.min(1,P.airT/0.3))*(1-trk):0,0,M*0.3*gr*(1-trk));
  _e.copy(h.board.rotation);h.board.rotation.y+=TAU*spn;h.board.rotation.z+=TAU*fp;
  h.hips.position.set(0,lerp(hipY,lerp(0.71,0.47,gr)+lift,tk),-0.03*c*(1-sd)*(1-P.push));h.hips.rotation.set(0,yaw,LEAD*0.12*P.push);
  h.torso.rotation.set((0.1+0.6*c)*(1-0.6*sd)*(1-0.6*P.push)+P.push*0.22+0.3*tk+0.8*gr,-yaw*0.2,-P.st*0.16-LEAD*0.12*P.push);
  h.head.rotation.order='YXZ';h.head.rotation.set(-(0.06+0.5*c)*(1-0.6*sd)-P.push*0.2-0.25*tk-0.55*gr,-yaw*0.8+P.st*0.25,P.st*0.08);
  // arms stay loose with bent elbows: the lead arm a little forward, the back arm behind, a little wider with speed and in the air,
  // the outside arm lifts in a turn and both counter-swing the kicking leg
  const sp=clamp(s.v/12,0,1),air=s.air?1:0,kk=s.kick!=null&&s.kick>=0?s.kick:(h.t*1.0)%1,swing=Math.sin(kk*Math.PI*2)*0.38*P.push;
  for(const a of h.arms){const lead=a.sx===LEAD;
    const out=0.16+0.26*sp+0.55*air+(a.sx*P.st>0?-0.1:0.28)*Math.abs(P.st)+(lead?0.6*gr:0);
    const fw=(lead?-0.3-0.12*sp-0.5*gr:0.25+0.08*sp)+0.35*c+(lead?-swing:swing)+Math.sin(h.t*1.7+(lead?0:1.4))*0.04;
    a.sh.rotation.set(fw,0,a.sx*out);a.el.rotation.x=-(0.5+0.35*sp+0.2*P.push-0.15*air);}
  const hy=h.hips.position.y-0.07,hz=h.hips.position.z,cy=Math.cos(yaw),sy=Math.sin(yaw);
  for(const L of h.legs){const front=L.sx===LEAD;let fx=((front?0.03:-0.03)*(1-sd)+0.01*sd)*M,fy=ANKLE_Y,fz=front?0.2+0.02*sd:-0.21-0.03*sd;
    if(!front&&P.push>0.03){const k=s.kick!=null&&s.kick>=0?s.kick:(h.t*1.0)%1;
      // reach forward and down, plant beside the deck, sweep back hard, lift and return
      const fwdZ=-0.02,backZ=-0.45,ph=k<0.3?k/0.3:k<0.65?(k-0.3)/0.35:(k-0.65)/0.35;
      let z,y;if(k<0.3){z=lerp(-0.21,fwdZ,smooth(ph));y=lerp(ANKLE_Y,0.095,smooth(ph));}
      else if(k<0.65){z=lerp(fwdZ,backZ,ph);y=0.095+0.05*smooth(clamp((ph-0.6)/0.4,0,1));}else{z=lerp(backZ,-0.21,smooth(ph));y=0.145+Math.sin(Math.PI*ph)*0.12+(ANKLE_Y-0.145)*smooth(ph);}
      fz=lerp(fz,z,P.push);fy=lerp(fy,y,P.push);fx=lerp(fx,0.16*M,P.push);}
    // feet stay on the deck as it pops, tilts and rises
    _v.set(fx,fy+0.2*trk,fz).applyEuler(_e);_v.y+=lift;
    solveLeg(L,L.sx*0.09*cy,hy,hz-L.sx*0.09*sy,_v.x,_v.y,_v.z);
    // feet lie across the deck when riding; the front foot points ahead and the pushing foot runs along the ground when kicking
    L.ft.rotation.y=(front?lerp(0.15,1.2,sd):lerp(0.05,1.45,sd)*(1-P.push))*M;}
  for(const w of h.wheels)w.rotation.x+=s.v*dt/0.034;
  if(h.faceM)animHeroine(h,dt,s);
  if(h.vrm)driveVRM(h,dt,s);
}

/* cats */
function makeCat(o){const g=new THREE.Group(),base=tm(o.col||'#f2f2ee'),Mc=(geo,mat,ol=0.008)=>{const m=new THREE.Mesh(geo,mat);m.castShadow=true;if(ol)outline(m,ol);g.add(m);return m;};
  const fur=o.calico?tmap(canvasTex(64,64,(c,w,h)=>{c.fillStyle='#f6f2ea';c.fillRect(0,0,w,h);c.fillStyle='#e8913a';c.beginPath();c.ellipse(18,20,14,10,0.4,0,7);c.fill();c.fillStyle='#2b2520';c.beginPath();c.ellipse(44,40,12,9,-0.3,0,7);c.fill();})):base;
  const body=Mc(new THREE.SphereGeometry(0.16,14,10),fur);body.scale.set(0.8,0.75,1.4);body.position.y=0.18;
  const head=new THREE.Group();head.position.set(0,0.32,0.2);g.add(head);
  const hm=new THREE.Mesh(new THREE.SphereGeometry(0.1,14,10),fur);hm.castShadow=true;outline(hm,0.007);head.add(hm);
  for(const sx of [-1,1]){const e=new THREE.Mesh(new THREE.ConeGeometry(0.04,0.08,4),fur);e.position.set(sx*0.055,0.085,0);e.rotation.z=-sx*0.25;head.add(e);
    const ey=new THREE.Mesh(new THREE.SphereGeometry(0.012,6,4),new THREE.MeshBasicMaterial({color:'#2b2520'}));ey.position.set(sx*0.035,0.01,0.088);head.add(ey);}
  for(const [x,z] of [[-0.07,0.13],[0.07,0.13],[-0.07,-0.13],[0.07,-0.13]])Mc(new THREE.CylinderGeometry(0.03,0.025,0.14,6),fur,0).position.set(x,0.07,z);
  const tail=new THREE.Group();tail.position.set(0,0.22,-0.2);g.add(tail);const tm1=new THREE.Mesh(limb(0.025,0.02,0.24,6),o.calico?tm('#e8913a'):base);tm1.rotation.x=-2.3;tail.add(tm1);
  return{g,head,tail,t:rnd()*10,sleep:!!o.sleep,body};}
function poseCat(c,dt,near){c.t+=dt;c.tail.rotation.z=Math.sin(c.t*(near?4:1.5))*0.5;if(c.sleep||c.nap&&phaseOf(SAVE.hour)==='night'){c.body.scale.y=0.62+Math.sin(c.t*1.6)*0.02;c.head.position.set(0,0.16,0.18);c.head.rotation.set(0.5,0,0.3);}
  else{c.body.scale.y=0.75;c.head.position.set(0,0.32,0.2);c.head.rotation.set(0,Math.sin(c.t*0.6)*0.5,0);}}

/* townsfolk and the people you run errands for */
const NPCS={};
function placeNPC(id,o,x,z,yaw,mode,name,idle){const h=makeHuman(o);const y=o.y!=null?o.y:G(x,z)+paveY(x,z);h.g.position.set(x,y,z);h.g.rotation.y=yaw;world.add(h.g);
  const n={id,h,x,z,yaw,mode,name,idle:idle||[],rad:o.rad||0.45};NPCS[id]=n;n.box=collide(x-n.rad,x+n.rad,z-n.rad,z+n.rad,'npc');return n;}
// someone who is only there at certain times has n.show(); hidden people neither stand in the way nor talk
const present=n=>!URA.on&&(!n.show||n.show());   // nobody you know is in 裏海街
function shopFront(id,u,v){const b=SHOPS[id],p=b.local(u,0,v);return[p.x,p.z,b.yaw];}
{ const B=SHRINE;const bench=benchMesh();bench.position.set(-50.5,G(-50.5,-125.6),-125.6);world.add(bench);collide(-51.3,-49.7,-125.9,-125.3,'prop',G(-50.5,-125.6)+0.5);
  placeNPC('tome',{skin:'#efc9aa',hair:'#d9d6d0',style:'grey',shirt:'#8a6a8a',sleeves:'long',bottom:'long',bottomCol:'#5a5a6a',shoe:'#4a3a2e',bend:0.32,cane:true,y:G(-50.5,-125.6)},
    -50.5,-125.55,0,'sit','トメばあちゃん',['この坂からの海がいちばん好きでねえ。','神社の鳥居の向こう、夕方はきれいだよ。']);}
{ const [x,z,yaw]=shopFront('flower',1.6,1.7);placeNPC('hana',{skin:'#f3d0b5',hair:'#3a2a1e',style:'pony',shirt:'#f2e8d6',bottom:'pants',bottomCol:'#3b4a66',apron:'#3f8a4f'},x,z,yaw,'stand','はなもりの花江さん',['今日はひまわりが入ったのよ。','お花は朝いちばんがいちばん元気。']);}
{ const [x,z,yaw]=shopFront('cafe',3.4,1.4);placeNPC('master',{skin:'#e6bb95',hair:'#2b2520',style:'short',shirt:'#f7f7f3',sleeves:'long',vest:'#3a2a20',bottom:'pants',bottomCol:'#2b2520',mustache:true},x,z,yaw,'stand','しおさいのマスター',['うちのナポリタンは昔ながらの味さ。','海の色が変わると、コーヒーの味も変わる気がするよ。']);}
{ const [x,z,yaw]=shopFront('bakery',2.2,1.5);placeNPC('baker',{skin:'#f1cdb0',hair:'#2a1d15',style:'short',shirt:'#fbfbf8',sleeves:'long',bottom:'pants',bottomCol:'#e9e2d4',apron:'#c8722e',hat:'chef'},x,z,yaw,'stand','こむぎ堂の主人',['いらっしゃい！ メロンパン、焼きたてだよ。']);}
{ const [x,z,yaw]=shopFront('dagashi',-1.8,1.6);const stool=new THREE.Mesh(new THREE.CylinderGeometry(0.2,0.2,0.45,12),tm('#c8372d'));stool.position.set(x,G(x,z)+0.22,z-0.05);world.add(stool);
  placeNPC('maru',{skin:'#efc9aa',hair:'#e2ded8',style:'grey',shirt:'#e9e2d4',sleeves:'long',bottom:'long',bottomCol:'#6b5a4a',apron:'#e2584a',bend:0.2},x,z,yaw,'sit','まるやのおばあちゃん',['当たりが出たら、もう一本だよ。']);}
{ const [x,z,yaw]=shopFront('fish',2.6,1.9);placeNPC('okami',{skin:'#e9bf9b',hair:'#2b2520',style:'bun',shirt:'#f2f2ee',sleeves:'long',bottom:'pants',bottomCol:'#24466e',apron:'#2e5fa8',scarf:'#f2c230'},x,z,yaw,'stand','魚松のおかみさん',['今朝はあじがよく揚がったよ！']);}
{ const [x,z,yaw]=shopFront('books',-2.8,1.6);placeNPC('neko',{skin:'#f1cdb0',hair:'#6b6560',style:'short',shirt:'#7a8a6a',sleeves:'long',bottom:'pants',bottomCol:'#4a4038',glasses:true,bend:0.1},x,z,yaw,'stand','古書うみねこの店主',['古い写真集をめくると、この町は昔からあまり変わらないんだ。']);}
{ placeNPC('sota',{skin:'#e3b088',hair:'#1c1a1a',style:'short',cap:'#3a7bd5',shirt:'#f2c230',bottom:'shorts',bottomCol:'#3a6b8a',shoe:'#3a7bd5',scale:0.78},-72,SHORE+13,Math.PI*0.85,'stand','ソウタくん',['波が高い日はサーフィンの人がいっぱい来るんだ。']);}
{ placeNPC('fisher',{skin:'#d9a987',hair:'#2b2520',style:'short',hat:'straw',shirt:'#5a7a8a',sleeves:'long',bottom:'pants',bottomCol:'#4a4a4a',y:PIER.y+0.02},-79.8,PIER.z1-3.2,0,'sit','釣りのおじさん',['ここで釣れるのは、だいたいあじかサバだな。','島の灯台、昔は夜になると光ったんだがなあ。']);
  // Natsumi, Nagi's mother: she comes up the hill on the last morning of the true route
  placeNPC('natsumi',{skin:'#efc9aa',hair:'#2a211c',style:'bob',shirt:'#efe6d8',sleeves:'long',bottom:'skirt',bottomCol:'#5a6a8a',shoe:'#6b4330'},-52.6,-123.6,0.6,'stand','お母さん',['ナギ、ばあちゃんの言うこと、ちゃんと聞いてた？']);
  NPCS.natsumi.show=()=>!!SAVE.flags.mom_here;
  // Mio: the girl in white who stands at the end of the pier, only in the evening
  placeNPC('mio',{skin:'#f3dcc8',hair:'#1c1a1a',style:'bob',shirt:'#f7f6f1',bottom:'skirt',bottomCol:'#f7f6f1',socks:'#f7f6f1',shoe:'#e8e4dc',scale:0.93,y:PIER.y+0.02},-78.6,PIER.z1-1.2,0,'stand','ミオ',['……海、きれいだね。','灯台、今日も光らないね。']);
  const rod=new THREE.Mesh(new THREE.CylinderGeometry(0.01,0.015,2.6,5),tm('#3a2a1e'));rod.position.set(-79.6,PIER.y+1.4,PIER.z1-1.9);rod.rotation.x=0.9;world.add(rod);}
{ placeNPC('lady1',{skin:'#f1cdb0',hair:'#3a2a1e',style:'bob',shirt:'#e8c9b8',bottom:'skirt',bottomCol:'#6b7a8a'},5.6,30,-Math.PI/2+0.4,'stand','',['今日はいい風ねえ。']);
  placeNPC('lady2',{skin:'#efc9aa',hair:'#1c1a1a',style:'bun',shirt:'#cfe0d2',sleeves:'long',bottom:'pants',bottomCol:'#5a4a3a'},5.6,31.1,-Math.PI/2-0.6,'stand','',['商店街のコロッケ、食べた？']);
  placeNPC('kid1',{skin:'#f3d0b5',hair:'#2a1d15',style:'pony',shirt:'#f0a0b8',bottom:'skirt',bottomCol:'#3a7bd5',scale:0.72},-30.5,-16.5,Math.PI,'stand','',['当たりが出たんだよ！']);
  placeNPC('kid2',{skin:'#e3b088',hair:'#1c1a1a',style:'short',shirt:'#4f9a5a',bottom:'shorts',bottomCol:'#2b2f36',scale:0.74},-31.4,-16.6,Math.PI-0.5,'stand','',['ラムネのビー玉、取れないんだよなあ。']);}
// the station square: someone waiting for the bus, and the taxi driver by his car
{ placeNPC('eki_bus',{skin:'#efc9aa',hair:'#2b2520',style:'short',shirt:'#f2f2ee',sleeves:'long',bottom:'pants',bottomCol:'#3b4a66',glasses:true},53.4,189.6,Math.PI,'stand','',['バス、まだかなあ。','この町のバスは、のんびりしてるんだよ。']);
  placeNPC('eki_taxi',{skin:'#d9a987',hair:'#8a8580',style:'short',cap:'#2b2b30',shirt:'#f4f4f0',sleeves:'long',vest:'#2b2b30',bottom:'pants',bottomCol:'#2b2b30'},74.3,181.5,-Math.PI/2,'stand','タクシーの運転手',['どちらまで？ ……なんてね。','夏は海水浴のお客さんで、駅前もにぎやかになるんだ。']);}
const CATS=[];
// the shrine's calico sits on the corner of the hall's stone base (its top is 0.7 above the ground at the hall); she naps at night
const MIKE={x:-57.3,z:-159.5};
{ const m=makeCat({calico:true});m.nap=true;m.g.position.set(MIKE.x,G(SHRINE.x,-162)+0.7,MIKE.z);m.g.rotation.y=0.6;world.add(m.g);CATS.push(m);MIKE.cat=m;
  for(const [x,z,col,sl] of [[11.5,-15.8,'#3a3a3a',true],[66,205.3,'#e8913a',true],[-108.5,SHORE+11,'#f2f2ee',false],[118.6,90,'#9a8a7a',true]]){
    const c=makeCat({col,sleep:sl});c.g.position.set(x,(x===66?G(65,206)+0.85:G(x,z)),z);c.g.rotation.y=rnd()*6;world.add(c.g);CATS.push(c);}}

/* passers-by: simple instanced folk walking their routes */
const ROUTES=[
  {ax:'x',c:-20,a:-66,b:66,lanes:[-2.8,-1.2,1.2,2.8],n:26},
  {ax:'z',c:0,a:-196,b:232,lanes:[-5.6,5.6],n:34},
  {ax:'x',c:SHORE-1.2,a:-280,b:280,lanes:[0,0.8],n:22},
  {ax:'x',c:90,a:-150,b:150,lanes:[-2.2,2.2],n:8},
  {ax:'x',c:170,a:-140,b:140,lanes:[-2.2,2.2],n:8},
];
const FOLK=[];
for(const R of ROUTES)for(let k=0;k<R.n;k++){const t=R.a+rnd()*(R.b-R.a),lane=pick(R.lanes);
  FOLK.push({R,t,lane,v:(0.9+rnd()*0.5)*(rnd()<0.5?1:-1),ph:rnd()*6,k:0.88+rnd()*0.2,stop:0,
    shirt:C3(pick(['#f2f2ee','#e85a2a','#3a7bd5','#f5b700','#2bb673','#8a5cf0','#d8d2c6','#c8372d','#f0a0b8','#9cc3e6'])),
    pants:C3(pick(['#22242a','#3b4a66','#5a4a3a','#d9d3c7','#2f3a2f','#6b7a8a'])),hair:C3(pick(['#1c1a1a','#3a2a1e','#5a3a24','#8a8580','#d9d6d0']))});}
for(let k=0;k<14;k++){const x=-190+rnd()*380;if(Math.abs(x+80)<6)continue;FOLK.push({R:null,x,z:SHORE+8+rnd()*22,yaw:rnd()*6,k:0.85+rnd()*0.25,ph:rnd()*6,
  shirt:C3(pick(['#f2f2ee','#e2584a','#3a7bd5','#f2c230'])),pants:C3(pick(['#3a6b8a','#22242a','#d9d3c7'])),hair:C3(pick(['#1c1a1a','#3a2a1e','#5a3a24']))});}
const folkMesh={};
{ const mk=(geo,key,col)=>{const im=new THREE.InstancedMesh(geo,tm('#ffffff'),FOLK.length);im.instanceMatrix.setUsage(THREE.DynamicDrawUsage);im.castShadow=true;
    FOLK.forEach((p,k)=>im.setColorAt(k,key?p[key]:col));world.add(im);olInst(im,0.012);return im;};
  const skinC=C3('#efc7a6');
  folkMesh.torso=mk(limb(0.17,0.15,0.6,10).translate(0,1.42,0),'shirt');
  folkMesh.head=mk(new THREE.SphereGeometry(0.115,14,10).translate(0,1.56,0),null,skinC);
  folkMesh.hair=mk(new THREE.SphereGeometry(0.124,14,10,0,TAU,0,Math.PI*0.56).translate(0,1.585,-0.012),'hair');
  folkMesh.legL=mk(limb(0.075,0.055,0.8,8),'pants');folkMesh.legR=mk(limb(0.075,0.055,0.8,8),'pants');
  folkMesh.armL=mk(limb(0.05,0.04,0.55,8),'shirt');folkMesh.armR=mk(limb(0.05,0.04,0.55,8),'shirt');}
const FB=new THREE.Object3D(),FL=new THREE.Object3D();FB.add(FL);
function folkPos(p){if(!p.R)return[p.x,p.z];return p.R.ax==='x'?[p.t,p.R.c+p.lane]:[p.R.c+p.lane,p.t];}
function updateFolk(dt,px,pz,init){
  for(let k=0;k<FOLK.length;k++){const p=FOLK[k];let [x,z]=folkPos(p);
    if(!init&&Math.abs(x-px)+Math.abs(z-pz)>170)continue;
    let walking=false,yaw=p.yaw||0;
    if(p.R){const d=Math.hypot(x-px,z-pz);p.stop=d<1.6?0.6:Math.max(0,p.stop-dt);
      if(p.stop<=0){p.t+=p.v*dt;walking=true;}if(p.t<p.R.a||p.t>p.R.b){p.v=-p.v;p.t=clamp(p.t,p.R.a,p.R.b);}
      [x,z]=folkPos(p);yaw=p.R.ax==='x'?(p.v>0?Math.PI/2:-Math.PI/2):(p.v>0?0:Math.PI);}
    p.ph+=dt*6.2;const s=walking?Math.sin(p.ph):0;
    FB.position.set(x,G(x,z)+paveY(x,z)+(walking?Math.abs(Math.cos(p.ph))*0.02:0),z);FB.rotation.set(0,yaw,0);FB.scale.setScalar(p.k);FB.updateMatrixWorld(true);
    folkMesh.torso.setMatrixAt(k,FB.matrixWorld);folkMesh.head.setMatrixAt(k,FB.matrixWorld);folkMesh.hair.setMatrixAt(k,FB.matrixWorld);
    for(const [m,sx,sg] of [[folkMesh.legL,-1,1],[folkMesh.legR,1,-1]]){FL.position.set(sx*0.09,0.86,0);FL.rotation.set(-s*0.42*sg,0,0);FL.updateMatrixWorld(true);m.setMatrixAt(k,FL.matrixWorld);}
    for(const [m,sx,sg] of [[folkMesh.armL,-1,-1],[folkMesh.armR,1,1]]){FL.position.set(sx*0.2,1.4,0);FL.rotation.set(-s*0.35*sg,0,sx*0.08);FL.updateMatrixWorld(true);m.setMatrixAt(k,FL.matrixWorld);}
  }
  for(const key in folkMesh)folkMesh[key].instanceMatrix.needsUpdate=true;
}

/* ---------- on foot: stepping off and standing the board on its tail, carrying it across the back, running, and hopping back on ---------- */
const ANK_G=0.095;
const _bq=new THREE.Quaternion(),_bq2=new THREE.Quaternion(),_bm=new THREE.Matrix4(),_bp=new THREE.Vector3(),_bs=new THREE.Vector3();
// the board stood up on its tail at her left (lead) side, nose in her hand
function boardUpright(out){const th=-Math.PI/2;out.q.setFromEuler(new THREE.Euler(th,-0.35,0,'YXZ'));out.p.set(0.3,0,0.14).sub(new THREE.Vector3(0,0.03,-0.42).applyQuaternion(out.q));out.p.y=Math.max(out.p.y,0);return out;}
// strapped across the back over the backpack: long side horizontal, wheels out
const BACK_Q=new THREE.Quaternion().setFromAxisAngle(new THREE.Vector3(0,0,1),Math.PI/2).multiply(new THREE.Quaternion().setFromAxisAngle(new THREE.Vector3(1,0,0),Math.PI/2));
function boardOnBack(h,out){h.root.updateMatrixWorld(true);_bm.copy(h.root.matrixWorld).invert().multiply(h.torso.matrixWorld);
  const m=new THREE.Matrix4().compose(new THREE.Vector3(0,0.15,-0.34),BACK_Q,new THREE.Vector3(1,1,1));_bm.multiply(m);_bm.decompose(out.p,out.q,_bs);return out;}
function setBoard(h,p,q){h.board.position.copy(p);h.board.quaternion.copy(q);}
// one leg's foot path through a stride, u in [0,1): a short stance where the foot sweeps back under the hips at ground speed,
// then the swing: heel kicks up behind, the knee drives through high, the shin reaches forward and the foot lands
function strideFoot(u,sf,r,L){if(u<sf){const t=u/sf;return{z:lerp(L,-L,t),y:ANK_G,st:Math.sin(Math.PI*t),toe:0};}
  const t=(u-sf)/(1-sf),hh=lerp(0.12,1,r);
  const K=[[-L,0],[-L-0.08*r,0.34*hh],[0.02,0.36*hh],[L*0.95,0.13*hh],[L,0]],n=K.length-1,x=t*n,k=Math.min(n-1,Math.floor(x)),f=x-k;
  const P=i=>K[Math.max(0,Math.min(n,i))];const cr=(a,b,c,d,f)=>0.5*(2*b+(-a+c)*f+(2*a-5*b+4*c-d)*f*f+(-a+3*b-3*c+d)*f*f*f);
  const z=cr(P(k-1)[0],P(k)[0],P(k+1)[0],P(k+2)[0],f),y=cr(P(k-1)[1],P(k)[1],P(k+1)[1],P(k+2)[1],f);
  return{z,y:ANK_G+Math.max(0,y),st:0,toe:t<0.35?0.7*Math.sin(Math.PI*t/0.35):t>0.75?-0.25*Math.sin(Math.PI*(t-0.75)/0.25):0};}
function poseRunner(h,dt,s){const P=h.pose;h.t+=dt;const tr=s.tr,v=s.v||0,r=clamp((v-1.5)/4.5,0,1),moving=clamp(v/0.8,0,1);
  const f=lerp(0.85,1.45,r),sf=lerp(0.6,clamp(0.8*f/Math.max(v,0.1),0.17,0.45),r),L=lerp(0.28,0.34,r)*moving;
  P.ph=((P.ph||0)+dt*f*moving)%1;const ph=P.ph;
  const LEAD=1;h.kneeOut=-0.03;
  const feet={};let comp=0;
  for(const L2 of h.legs){const u=(ph+(L2.sx>0?0:0.5))%1,F=strideFoot(u,sf,r,L);F.y=lerp(ANK_G,F.y,moving);F.x=L2.sx*lerp(0.085,0.055,r);feet[L2.sx]=F;comp=Math.max(comp,F.st);}
  // hips dip as the weight lands and float in the flight phase; pelvis and shoulders twist against each other
  let hipY=lerp(0.93,0.875,r)-comp*0.04*r+(1-comp)*0.02*r,yaw=-0.3*feet[1].z*moving,lean=0.05+0.38*r;
  if(s.air){for(const k in feet){feet[k].y+=0.2;feet[k].z*=0.4;}hipY-=0.04;lean+=0.08;}
  let hold=0,boardP=null;
  if(tr&&tr.type==='off'){   // step off the back, press the tail, catch the nose
    const t=tr.t,sk=1-smooth(clamp(t/0.6,0,1));yaw=lerp(yaw,-1.25,sk);hipY=lerp(hipY,0.975,sk);lean=lerp(lean,0.1,sk);
    const fb=smooth(clamp(t/0.3,0,1)),ff=smooth(clamp((t-0.35)/0.3,0,1));
    const deckF={x:0.01*-1,y:ANKLE_Y,z:0.22},deckB={x:0.01*-1,y:ANKLE_Y,z:-0.24};
    const gB=feet[-1],gF=feet[1];
    feet[-1]={x:lerp(deckB.x,gB.x,fb),y:lerp(deckB.y,gB.y,fb)+Math.sin(Math.PI*fb)*0.1,z:lerp(deckB.z,gB.z-0.05,fb)};
    feet[1]={x:lerp(deckF.x,gF.x,ff),y:lerp(deckF.y,gF.y,ff)+Math.sin(Math.PI*ff)*0.12,z:lerp(deckF.z,gF.z,ff)};
    const a=smooth(clamp((t-0.12)/0.45,0,1)),q=new THREE.Quaternion().setFromEuler(new THREE.Euler(-Math.PI/2*a,-0.35*a,0,'YXZ'));
    const tail=new THREE.Vector3(0,0.03,-0.42).lerp(new THREE.Vector3(0.3,0,0.14),a);
    boardP={p:tail.sub(new THREE.Vector3(0,0.03,-0.42).applyQuaternion(q)),q};hold=smooth(clamp((t-0.5)/0.3,0,1));}
  // pose the rig
  h.hips.position.set(0,hipY,0);h.hips.rotation.set(0,yaw,0);
  h.torso.rotation.set(lean,-yaw*1.7,0);h.head.rotation.order='YXZ';h.head.rotation.set(-lean*0.8,yaw*0.7,0);
  // arms bent at the elbow and pumping front to back, each with the opposite leg
  for(const a of h.arms){const sw=clamp(feet[-a.sx].z/Math.max(L,0.01),-1,1)*moving,amp=lerp(0.3,1.05,r);
    a.sh.rotation.set(-sw*amp+0.12*r,0,a.sx*lerp(0.1,0.14,r));a.el.rotation.x=-(lerp(0.2,1.45,r)+Math.max(0,sw)*0.15*r-Math.max(0,-sw)*0.25*r);}
  const hy=h.hips.position.y-0.07,cy=Math.cos(yaw),sy=Math.sin(yaw);
  for(const L of h.legs){const f=feet[L.sx];solveLeg(L,L.sx*0.09*cy,hy,-L.sx*0.09*sy,f.x,f.y,f.z);L.ft.rotation.y=0;L.ft.rotation.x+=f.toe||0;}
  h.root.updateMatrixWorld(true);
  // the board
  const up=boardUpright({p:new THREE.Vector3(),q:new THREE.Quaternion()});
  if(boardP){setBoard(h,boardP.p,boardP.q);}
  else if(tr&&tr.type==='stow'){const t=smooth(tr.t),bk=boardOnBack(h,{p:new THREE.Vector3(),q:new THREE.Quaternion()});
    const p=up.p.clone().lerp(bk.p,t);p.y+=Math.sin(Math.PI*t)*0.35;setBoard(h,p,up.q.clone().slerp(bk.q,t));hold=1-smooth(clamp(tr.t*1.6,0,1));}
  else if(tr&&tr.type==='on'){const t=tr.t,a=smooth(clamp(t/0.5,0,1)),from=s.carry==='hand'?up:boardOnBack(h,{p:new THREE.Vector3(),q:new THREE.Quaternion()});
    const p=from.p.clone().lerp(new THREE.Vector3(0,0,0.02),a);p.y+=Math.sin(Math.PI*a)*0.25;setBoard(h,p,from.q.clone().slerp(_bq.identity(),a));
    // hop on: feet from the ground onto the deck, hips turn side-on
    const b=smooth(clamp((t-0.45)/0.55,0,1));for(const L of h.legs){const f=feet[L.sx],front=L.sx===LEAD;
      const tx=0.01*-1,tz=front?0.22:-0.24;_v.set(lerp(f.x,tx,b),lerp(f.y,ANKLE_Y,b)+Math.sin(Math.PI*b)*0.15,lerp(f.z,tz,b));
      solveLeg(L,L.sx*0.09*cy,hy,-L.sx*0.09*sy,_v.x,_v.y,_v.z);}
    h.hips.rotation.y=lerp(yaw,-1.25,b);hold=s.carry==='hand'?1-a:0;}
  else if(s.carry==='hand')setBoard(h,up.p,up.q),hold=1;
  else{const bk=boardOnBack(h,{p:new THREE.Vector3(),q:new THREE.Quaternion()});setBoard(h,bk.p,bk.q);}
  // the left hand on the nose
  h.hold=hold>0.01?{sx:LEAD,w:hold,T:h.board.localToWorld(new THREE.Vector3(0.0,0.06,0.4))}:null;
  for(const w of h.wheels)w.rotation.x+=0;
  if(h.faceM)animHeroine(h,dt,{v:Math.min(v,4),turn:s.turn||0,air:s.air});
  if(h.vrm)driveVRM(h,dt,{v:Math.min(v,3),turn:s.turn||0,air:s.air,vy:s.vy});
}
