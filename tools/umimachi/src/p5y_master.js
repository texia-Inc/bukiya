/* ---------- the master of the sea, fought out on 鏡の海 (a night of p5v_mirror.js with MIR.rule.master): the last fight of the
   second story, and a practice from the command table. It stands at the far edge of the mirror, from the waist up, and reaches
   in with its two hands. Round it Mio has hung rails of light: from the mirror on either side of it they climb and run round its
   back, high over the open sea behind the mirror, with a gap at the back to jump. Ridden round its back and brought back to her
   line on the mirror, the ring closes round the whole master: three of those and it falls forward with its head on the mirror,
   breathing out shadows; three rings round the head, and Mio's light comes down on it and it sinks. Its hands get in the way:
   one rises, hangs over where Nagi is going (its red shadow on the mirror) and slams down; then it lies on the mirror a while,
   and a ring closed round it burns it (gold line twice as hard, the armoury's third level one more), and a burnt hand is still. In the story her hearts come back when they are gone (Mio's voice); in
   practice that is the end of the night. ---------- */
const MST_AT=[30,-62],MST_S=20,MST_HAND=4,MST_HEAD=3,MST_BODY=10,MST_RINGS=3,MST_RR=14;   // …and the radius of the rails round it   // where it stands (from the middle of the mirror; clear of the roofs, so its head falls on open mirror), its size, the rings a hand and the head take, how near she can ride to it
const MST={on:false,g:null,body:null,eyes:[],hands:[],head:null,phase:0,t:0,turn:0,cd:0,breath:0,tilt:0,beam:null,res:null,rule:null};
function mstBuild(){if(MST.g)return;const g=new THREE.Group();MIR.g.add(g);MST.g=g;
  const h=makeHuman(SHADE);h.g.scale.setScalar(MST_S);g.add(h.g);MST.body=h;
  for(const L of h.legs)for(const k of ['th','kn','ft'])if(L[k])L[k].visible=false;   // only from the waist up: the rest is under the mirror
  const gl=(col,s)=>{const e=glow(col,0,0,0,s);scene.remove(e);e.visible=true;g.add(e);return e;};
  MST.eyes=[[0,0,22],[-0.09,-0.06,8],[0.09,-0.06,8]].map(([dx,dy,s])=>{const e=gl('#ff3020',s);e.userData.d=[dx,dy];e.userData.s=e.scale.x;return e;});
  const dark=tm('#16131c'),add=m=>{g.add(m);return m;};
  const flat=(geo,col,op)=>{const m=new THREE.Mesh(geo,new THREE.MeshBasicMaterial({color:col,transparent:true,opacity:op,blending:THREE.AdditiveBlending,depthWrite:false,side:THREE.DoubleSide,fog:false}));m.rotation.x=-Math.PI/2;g.add(m);return m;};
  const hand=sd=>{const hg=new THREE.Group(),palm=new THREE.Mesh(new THREE.SphereGeometry(1,14,10),dark);palm.scale.set(2.4,0.8,3);hg.add(palm);
    for(let k=0;k<4;k++){const f=new THREE.Mesh(new THREE.BoxGeometry(0.55,0.5,2.6),dark);f.position.set((k-1.5)*1.05,0,3.6);f.rotation.y=(k-1.5)*0.12;hg.add(f);}
    const th=new THREE.Mesh(new THREE.BoxGeometry(0.6,0.5,2),dark);th.position.set(sd*2.6,0,1);th.rotation.y=sd*0.7;hg.add(th);g.add(hg);
    const core=gl('#b070ff',3.4),arm=add(new THREE.Mesh(new THREE.CylinderGeometry(0.9,1.3,1,10),dark));
    return{g:hg,core,arm,mark:flat(new THREE.RingGeometry(3.4,3.9,40),'#b070ff',0.5),warn:flat(new THREE.CircleGeometry(5,40),'#ff3020',0),sd,x:0,z:0,y:0,tx:0,tz:0,st:'rest',t:0,hp:MST_HAND,dead:false,fade:0};};
  MST.hands=[hand(-1),hand(1)];
  MST.head={core:gl('#b070ff',7),mark:flat(new THREE.RingGeometry(5.6,6.2,48),'#b070ff',0),x:0,y:0,z:0,hp:MST_HEAD};
  mstRails(g);
  MST.beam=new THREE.Mesh(new THREE.CylinderGeometry(4,6,160,24,1,true),new THREE.MeshBasicMaterial({color:'#fff1c8',transparent:true,opacity:0,blending:THREE.AdditiveBlending,depthWrite:false,side:THREE.DoubleSide,fog:false}));g.add(MST.beam);}
// the rails of light: two arcs round the master at MST_RR, each low on the mirror at the front and high (8 m) round its back,
// a gap between them at the back to jump; each arc is a chain of short straight lengths (3°, so the board turns smoothly round it),
// drawn as one smooth tube (r.mst: only there to catch in this fight)
function mstRails(g){const bx=MIR_X+MST_AT[0],bz=MST_AT[1],at=a=>[bx+MST_RR*Math.sin(a),bz+MST_RR*Math.cos(a)],D=Math.PI/180;
  const hi=8,lo=0.35,sm=u=>u*u*(3-2*u),mat=new THREE.MeshBasicMaterial({color:'#ffe6a0',fog:false}),
    halo=new THREE.MeshBasicMaterial({color:'#ffcf70',transparent:true,opacity:0.25,blending:THREE.AdditiveBlending,depthWrite:false,fog:false});
  const arc=(a0,a1,yAt)=>{let prev=null;const n=Math.round(Math.abs(a1-a0)/3),pts=[];
    for(let k=0;k<=n;k++){const u=a0+(a1-a0)*k/n,[x,z]=at(u*D);pts.push(new THREE.Vector3(x,yAt(u),z));}
    for(let k=0;k<n;k++){const p=pts[k],q=pts[k+1],r={x0:p.x,z0:p.z,x1:q.x,z1:q.z,y0:p.y,y1:q.y,mst:true,keep:9};if(prev){prev.nx=r;r.pv=prev;}prev=r;RAILS.push(r);}
    const cv=new THREE.CatmullRomCurve3(pts);for(const [m,w] of [[mat,0.09],[halo,0.32]])g.add(new THREE.Mesh(new THREE.TubeGeometry(cv,n*3,w,8,false),m));};
  arc(20,180,a=>a<100?lo+(hi-lo)*sm((a-20)/80):hi);arc(192,340,a=>a>260?lo+(hi-lo)*sm((340-a)/80):hi);
  // where to jump on: a soft ring of light on the mirror under each low end
  for(const a of [20,340]){const [x,z]=at(a*D),m=new THREE.Mesh(new THREE.RingGeometry(1.2,1.6,32),halo);m.rotation.x=-Math.PI/2;m.position.set(x,0.05,z);g.add(m);}}
// out onto the mirror (from mirScript): the master up at the edge, a hand to either side of it
function mstStart(rule){mstBuild();Object.assign(MST,{on:true,rule,phase:0,t:0,turn:0,cd:5,breath:6,tilt:0,hp:MST_RINGS});MST.g.visible=true;
  const b=MST.body.g;b.position.set(MIR_X+MST_AT[0],-0.92*MST_S,MST_AT[1]);b.rotation.set(0,0,0);b.scale.setScalar(MST_S);
  MST.hands.forEach((H,k)=>{Object.assign(H,{x:MIR_X+MST_AT[0]+H.sd*12,z:MST_AT[1]+22,y:0,st:'rest',t:0,hp:MST_HAND,dead:false,fade:0});H.g.visible=H.arm.visible=H.core.visible=true;H.g.scale.setScalar(1);H.warn.material.opacity=0;});
  MST.head.hp=MST_HEAD;MST.head.core.visible=false;MST.head.mark.material.opacity=0;MST.beam.material.opacity=0;for(const e of MST.eyes)e.visible=true;}
function mstStop(){MST.on=false;MST.res=null;if(MST.g)MST.g.visible=false;}
const mstDmg=gold=>(gold?2:1)+(hqLv('arm')>=3?1:0);
// a hand slams down where she is heading: away from the master, inside the open water
function mstAim(H){const v=Math.min(P.v,12);let x=P.x+Math.sin(P.yaw)*v,z=P.z+Math.cos(P.yaw)*v;const l=Math.hypot(x-MIR_X,z);
  if(l>MIR_R-6){x=MIR_X+(x-MIR_X)/l*(MIR_R-6);z=z/l*(MIR_R-6);}
  const bx=MIR_X+MST_AT[0],bz=MST_AT[1],d=Math.hypot(x-bx,z-bz),m=MST_BODY+6;if(d<m){x=bx+(x-bx)/(d||1)*m;z=bz+(z-bz)/(d||1)*m;}H.tx=x;H.tz=z;H.ox=H.x;H.oz=H.z;}
function mstSlam(H){H.warn.material.opacity=0;const p=new THREE.Vector3(H.x,mirG(H.x,H.z)+0.3,H.z);sparks(p,24,'#b070ff',8,0.12);sfx.boom&&sfx.boom(0.7);
  const w=new THREE.Mesh(new THREE.RingGeometry(0.8,1,48),new THREE.MeshBasicMaterial({color:'#c090ff',transparent:true,opacity:0.6,blending:THREE.AdditiveBlending,depthWrite:false,side:THREE.DoubleSide,fog:false}));
  w.rotation.x=-Math.PI/2;w.position.copy(p);MIR.g.add(w);MIR.fx.push({m:w,t:0,dur:0.6,kind:'wave'});
  const dx=P.x-H.x,dz=P.z-H.z,d=Math.hypot(dx,dz);P.bump=Math.max(P.bump,d<14?0.5:0.2);
  if(d<5&&MIR.inv<=0&&!mirSafe()){MIR.inv=1.3;MIR.hearts--;buzz('heavy',true);P.v*=0.3;const l=d||1;P.x=H.x+dx/l*5.5;P.z=H.z+dz/l*5.5;renderHUD();
    if(MIR.hearts<=0){mirFinish(false);return;}toast('主の手に、たたかれた！');}
  else buzz('light',true);}
function mstStep(dt,busy){if(!MST.on)return;const b=MST.body.g,S=MST_S,run=MIR.go&&!busy&&!MIR.end;MST.t+=dt;
  poseHuman(MST.body,'stand',dt,{});
  // she cannot ride into it
  {const bx=b.position.x,bz=MST_AT[1],dx=P.x-bx,dz=P.z-bz,d=Math.hypot(dx,dz);if(d<MST_BODY){const l=d||1;P.x=bx+dx/l*MST_BODY;P.z=bz+dz/l*MST_BODY;}}
  // its body: upright and breathing, then fallen forward onto the mirror, then sinking under Mio's light
  const want=MST.phase>=1?0.85:0;MST.tilt+=(want-MST.tilt)*Math.min(1,dt*1.2);b.rotation.x=MST.tilt;
  if(MST.phase<2)b.position.y=-0.92*S+Math.sin(MST.t*0.8)*0.3;
  const hy=b.position.y+1.62*S*Math.cos(MST.tilt),hz=b.position.z+1.62*S*Math.sin(MST.tilt),hx=b.position.x;
  MST.eyes.forEach((e,k)=>{const [dx,dy]=e.userData.d;e.position.set(hx+dx*S,hy+dy*S-0.12*S*Math.sin(MST.tilt),hz+0.12*S*Math.cos(MST.tilt));e.scale.setScalar(e.userData.s*(1-0.6*MST.tilt));e.material.opacity=MST.phase>=2?Math.max(0,e.material.opacity-dt):k?0.6+0.3*Math.sin(clock*4+k):0.85+0.15*Math.sin(clock*6);});
  // the hands, one at a time with a breath between (long enough to ride round the one lying down): resting on the mirror, rising, hanging over her way with a red shadow under them, slamming down
  if(run)MST.cd-=dt;
  MST.hands.forEach((H,k)=>{const sx=hx+H.sd*0.26*S,sy=b.position.y+1.42*S,sz=b.position.z,gy=mirG(H.x,H.z);
    if(H.dead){H.fade+=dt;H.g.position.y-=dt*2;H.g.scale.setScalar(Math.max(0.01,1-H.fade*0.5));H.core.visible=H.mark.visible=H.warn.visible=false;H.arm.visible=false;if(H.fade>2)H.g.visible=false;return;}
    if(run){H.t-=dt;
      if(H.st==='rest'){H.y=gy;if(MST.cd<=0&&(MST.turn===k||MST.hands[1-k].dead)&&MST.phase===0){H.st='lift';H.t=0.7;mstAim(H);}}
      else if(H.st==='lift'){const u=1-H.t/0.7;H.x=lerp(H.ox,H.tx,u);H.z=lerp(H.oz,H.tz,u);H.y=lerp(gy,9,Math.min(1,u*1.4));if(H.t<=0){H.st='aim';H.t=1.3;}}
      else if(H.st==='aim'){H.x=H.tx;H.z=H.tz;H.y=9+Math.sin(MST.t*9)*0.2;H.warn.material.opacity=0.2+0.4*(1-H.t/1.3)+0.1*Math.sin(MST.t*20);if(H.t<=0){H.st='slam';H.t=0.16;}}
      else if(H.st==='slam'){H.y=lerp(gy,9,Math.max(0,H.t/0.16));if(H.t<=0){H.y=gy;H.st='rest';MST.cd=3.2;MST.turn=1-k;mstSlam(H);}}}
    H.g.position.set(H.x,H.y+0.5,H.z);H.g.rotation.y=Math.atan2(H.x-sx,H.z-sz);
    H.warn.visible=H.st==='aim';H.warn.position.set(H.tx,mirG(H.tx,H.tz)+0.07,H.tz);
    H.mark.visible=H.st==='rest';H.mark.position.set(H.x,gy+0.06,H.z);H.mark.material.opacity=0.35+0.25*Math.sin(MST.t*4+k);
    H.core.position.set(H.x,H.y+1.6,H.z);H.core.material.opacity=0.6+0.3*Math.sin(MST.t*5+k);
    // the arm: from the shoulder to the wrist
    const wx=H.x-Math.sin(H.g.rotation.y)*2.5,wz=H.z-Math.cos(H.g.rotation.y)*2.5,wy=H.y+0.8,d=new THREE.Vector3(wx-sx,wy-sy,wz-sz),L=d.length();
    H.arm.position.set((sx+wx)/2,(sy+wy)/2,(sz+wz)/2);H.arm.scale.set(1,L,1);H.arm.quaternion.setFromUnitVectors(new THREE.Vector3(0,1,0),d.normalize());});
  // ringed three times: it falls forward, its head on the mirror, breathing out shadows (a hand still up goes down with it)
  if(MST.phase===0&&MST.hp<=0){MST.phase=1;MST.breath=4;for(const H of MST.hands)H.dead=true;toast('主が、くずれおちる！ 頭のまわりを、光の線で囲め',true);buzz('heavy',true);}
  const Hd=MST.head;Hd.x=hx;Hd.z=hz;Hd.y=hy;
  if(MST.phase===1){Hd.core.visible=MST.tilt>0.6;Hd.core.position.set(hx,Math.max(hy,mirG(hx,hz)+1.5),hz);Hd.core.material.opacity=0.6+0.3*Math.sin(MST.t*3);
    Hd.mark.position.set(hx,mirG(hx,hz)+0.06,hz);Hd.mark.material.opacity=MST.tilt>0.6?0.35+0.25*Math.sin(MST.t*4):0;
    if(run){MST.breath-=dt;if(MST.breath<=0){MST.breath=8;mirSwarm(6);mirAdd('red',...mirWhere(1.6,14,22));}}}
  else Hd.mark.material.opacity=0;
  // the end: Mio's light down on it, and it sinks into the mirror
  if(MST.phase===2){MST.t2+=dt;Hd.core.visible=false;MST.beam.position.set(hx,80,hz);MST.beam.material.opacity=Math.min(0.75,MST.t2*0.8)*(MST.t2>3?Math.max(0,1-(MST.t2-3)):1);
    b.position.y-=dt*Math.min(6,MST.t2*3);if(MST.t2>4&&!MIR.end)mirFinish(true);}}
// a ring closed: a hand lying inside it, or the head, burns
function mstRing(inside,gold){if(!MST.on||MST.phase===2)return null;const n=mstDmg(gold);
  if(MST.phase===0){let msg=null;
    if(inside(MIR_X+MST_AT[0],MST_AT[1])){MST.hp--;sparks(new THREE.Vector3(MIR_X+MST_AT[0],12,MST_AT[1]),60,'#ffe6a0',14,0.2);buzz('heavy',true);
      msg=MST.hp>0?`主をまるごと囲んだ！　のこり ${MST.hp}`:'主をしめつけた！';}
    for(const H of MST.hands){if(H.dead||H.st!=='rest'||!inside(H.x,H.z))continue;H.hp-=n;sparks(new THREE.Vector3(H.x,H.y+1.5,H.z),30,'#d8c0ff',9,0.16);
      if(H.hp<=0){H.dead=true;msg=msg||`主の${H.sd<0?'右':'左'}手を焼いた！`;}else msg=msg||`主の手が焼ける！　のこり ${H.hp}`;}
    return msg;}
  const Hd=MST.head;if(MST.tilt<0.6||!inside(Hd.x,Hd.z))return null;Hd.hp-=n;sparks(new THREE.Vector3(Hd.x,Hd.y+2,Hd.z),40,'#d8c0ff',10,0.18);
  if(Hd.hp>0)return`主の頭を焼いた！　のこり ${Hd.hp}`;
  MST.phase=2;MST.t2=0;for(const f of MIR.foes)f.gone=1;buzz('heavy',true);return'ミオの光が、主をつらぬく！';}
function mstHUD(){if(!MST.on)return null;
  return{step:MST.phase===0?'低いはしからレールに跳び乗って主のうしろを回り、主をまるごと囲め。たたいたあとの手も、囲めば焼ける':'くずれた主の頭のまわりを、線で囲め',
    meter:MST.phase===0?`主 ${'■'.repeat(Math.max(0,MST.hp))}　手 ${MST.hands.map(H=>H.dead?'×':'■'.repeat(Math.max(0,Math.ceil(H.hp)))).join(' / ')}`:`頭 ${'■'.repeat(Math.max(0,MST.head.hp))}`};}
function mstMap(toM){if(!MST.on)return;const [cx,cy]=toM(MIR_X+MST_AT[0],MST_AT[1]),[ex]=toM(MIR_X+MST_AT[0]+MST_RR,MST_AT[1]);
  if(MST.phase===0){mg.strokeStyle='#ffe6a0';mg.lineWidth=2;mg.beginPath();mg.arc(cx,cy,ex-cx,0,TAU);mg.stroke();}
  mg.fillStyle='#b070ff';
  for(const H of MST.hands){if(H.dead)continue;const [x,y]=toM(H.x,H.z);mg.beginPath();mg.arc(x,y,H.st==='rest'?5:3,0,TAU);mg.fill();}
  if(MST.phase===1){const [x,y]=toM(MST.head.x,MST.head.z);mg.beginPath();mg.arc(x,y,7,0,TAU);mg.fill();}
  const [x,y]=toM(MIR_X+MST_AT[0],MST_AT[1]);mg.fillStyle='#3a1c52';mg.beginPath();mg.arc(x,y,6,0,TAU);mg.fill();}
// the night's end: in the story it goes on from the dawn (finalScript waits on masterP); in practice back to the base
function mstEnd(won){if(MST.rule&&!MST.rule.practice)return null;
  return{post:[['say','tome',won?'……あの主を、たおしちまうとはね。本番も、その調子でいきな。':'……手が落ちてきたら、すぐに曲がって逃げるんだよ。たたいたあとの手は、しばらく動かない。そこを囲むのさ。']]};}
// the last fight of the story: out onto the mirror, and back (on a black screen) once the master has sunk
function masterP(){return new Promise(res=>{MST.res=res;steps(mirScript(MST_RULE.story));});}
async function mstStoryEnd(){const r=MST.res;await fadeP(true);mirExit();if(r)r();}
const MST_RULE={
  story:{master:true,practice:false,title:'最後の戦い：海の主',intro:[]},
  practice:{master:true,practice:true,title:'海の主（練習）',intro:['あれが、海の主さ。……練習だから、やられても物語は進まないよ。',
    '主のまわりに、ミオちゃんが光のレールをかけてくれた。鏡の上の低いはしに向かって跳べば、乗れるよ。レールは主の背中を回って、反対がわへおりてくる。うしろのすき間は、跳びこえな。',
    'レールで背中を回って、鏡の上の線とつなげば、主をまるごと囲める。三回囲めば、主はくずれおちる。最後は、頭のまわりを三回囲むんだ。',
    '主の手が上がったら、鏡に赤い影が落ちる。そこから逃げな。たたいたあとの手も、囲めば焼ける。焼いた手は、もう動かないよ。']}};
