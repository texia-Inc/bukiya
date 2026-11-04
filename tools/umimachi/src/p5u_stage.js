/* ---------- 鏡の海のステージ: nights on the mirror in places of their own, picked on a map of islands from the command table
   (hqCommand in p5q_hq.js). Each has one goal, a time to reach it in, its own light and its own things to ride. Cleared, the
   light path runs on to the next island. Three stars each: cleared, half the hearts or more left, cleared quickly; every new
   star brings a garment. 夕やけの鏡: the drowned town at sunset, thirty shadows. 夜の港: the drowned harbour, its floating
   lanterns gone out; ring each one to light it (long piers to grind along). 霧の灯台: fog, the shadows seen only where the
   lighthouse beam passes (their red eyes always), a low rail all round the lighthouse to ride. Played through p5v_mirror.js
   with MIR.rule.stage. ---------- */
const STG=[
  {id:'dusk',name:'夕やけの鏡',place:'しずんだ町',lay:'town',hour:18.6,filter:'saturate(.9)',moon:false,fog:[50,260],goal:{k:'kills',n:30},dur:180,fast:120,col:'#e88a5a',at:[58,172],
    intro:['夕やけの鏡の海だよ。しずんだ町の屋根が、赤く光ってる。','影を30体、光の線で囲んで消しな。三分のうちにね。']},
  {id:'port',name:'夜の港',place:'しずんだ港',lay:'port',hour:22,filter:'saturate(.8) hue-rotate(8deg)',moon:true,fog:[40,260],goal:{k:'lamps',n:8},dur:240,fast:150,col:'#4a74c0',at:[156,116],
    intro:['ここは、しずんだ港。海に浮かぶ灯籠が、みんな消えてる。','灯籠のまわりを光の線で囲むと、火がともる。8つ全部ともしな。','長い桟橋のふちは、すべれるよ。すべって引いた線は金色になって、消えにくい。']},
  {id:'cape',name:'霧の灯台',place:'灯台の岬',lay:'cape',hour:5.6,filter:'saturate(.55)',moon:false,fog:[6,62],goal:{k:'kills',n:40},dur:240,fast:170,col:'#a8b4bc',at:[258,66],
    intro:['霧が深くて、影がよく見えないね。','灯台の光が当たったところだけ、影のすがたが見える。光っている赤い目をたよりにしな。','灯台のまわりの低い手すりは、ぐるっと一周すべれる。一周つなげば、灯台のまわりの影をまとめて消せるよ。影を40体だ。']}];
const STG_SOON=[[300,176],[196,206]];   // islands still in the mist
const STG_STARS=['クリア','ハートを半分以上のこす','time'];
const STGS={lit:0,last:0};
const stgSave=id=>{SAVE.stg=SAVE.stg||{};return SAVE.stg[id]||(SAVE.stg[id]={s:[0,0,0],best:0});};
const stgOpen=i=>i===0||!!stgSave(STG[i-1].id).s[0];
const stgTime=t=>`${t/60|0}:${String(t%60).padStart(2,'0')}`;
const stgStarText=(S,k)=>k===2?`${stgTime(S.fast)}以内にクリア`:STG_STARS[k];
const stgOn=()=>!!(MIR.rule&&MIR.rule.stage);
function stgRule(i){return Object.assign({stage:true,i,title:`ステージ${i+1}　${STG[i].name}`},STG[i]);}
/* ----- the places ----- */
MIR_LAYS.port={id:'port',roofs:[],torii:[],deckCol:'#5a4a3a',
  decks:[[-32,-4,0,74,7,1.3,1.6],[32,-4,0,74,7,1.3,1.6],[0,44,Math.PI/2,34,6,1.1,1.4]],
  boats:[[-14,-20,0.3,10,3.4,1.1],[14,4,-0.2,11,3.6,1.2],[-46,24,0.8,9,3.2,1],[46,-34,0.4,10,3.4,1.1],[0,-58,Math.PI/2,12,3.6,1.2]],
  ramps:[[0,-24,0,6,3,1.2],[0,18,Math.PI,6,3,1.2],[-44,-42,0.6,6,3,1.3],[44,30,-2.5,6,3,1.3]],
  lamps:[[0,0],[-16,-40],[16,-40],[-16,22],[16,24],[52,8],[-52,-12],[0,58]],extra:stgPort};
MIR_LAYS.cape={id:'cape',roofCol:'#4c5258',
  roofs:[[-34,-24,0.4,10,7,1.8],[36,-18,1.1,9,6,1.5],[-28,36,-0.6,12,7,2],[30,38,0.9,10,6,1.6],[0,-50,0.2,14,8,2.2],[-55,8,1.4,9,6,1.4],[54,4,-0.3,9,6,1.5]],
  boats:[],torii:[],decks:[],ramps:[[-40,-44,0.7,6,3,1.3],[42,-44,-0.7,6,3,1.3],[-44,50,2.4,6,3,1.3],[0,46,Math.PI,6,3,1.2]],tower:3.4,ringR:17,extra:stgCape};
const stgAdd=(g,col,x,y,z,s)=>{const l=glow(col,0,0,0,s);scene.remove(l);l.position.set(x,y,z);l.visible=true;g.add(l);return l;};
// the harbour: a lantern on a float at each of its points (a ring round it on the mirror while it is out), cranes far off,
// a red light and a green one at the ends of the piers
function stgPort(g,Y){
  Y.lampObjs=Y.lamps.map(([x,z])=>{const o=new THREE.Group();o.position.set(MIR_X+x,0,z);g.add(o);
    const base=new THREE.Mesh(new THREE.CylinderGeometry(0.7,0.8,0.25,10),tm('#4a3a2a'));base.position.y=0.12;o.add(base);
    const body=new THREE.Mesh(new THREE.BoxGeometry(0.8,1.1,0.8),new THREE.MeshBasicMaterial({color:'#4a5060'}));body.position.y=0.85;outline(body,0.02);o.add(body);
    const cap=new THREE.Mesh(new THREE.ConeGeometry(0.75,0.45,4),tm('#2a2224'));cap.position.y=1.62;cap.rotation.y=Math.PI/4;o.add(cap);
    const gl=stgAdd(o,'#ffcf70',0,0.9,0,5);gl.visible=false;
    const ring=new THREE.Mesh(new THREE.RingGeometry(2.6,3,40),new THREE.MeshBasicMaterial({color:'#ffcf70',transparent:true,opacity:0.4,blending:THREE.AdditiveBlending,depthWrite:false,side:THREE.DoubleSide,fog:false}));
    ring.rotation.x=-Math.PI/2;ring.position.y=0.05;o.add(ring);return{x:MIR_X+x,z,body,gl,ring,lit:false};});
  const dk=tm('#0e1118');
  for(let k=0;k<4;k++){const a=Math.PI+(k-1.5)*0.32,r=135+(k%2)*18,x=MIR_X+Math.sin(a)*r,z=Math.cos(a)*r,h=26+(k%2)*6,c=new THREE.Group();c.position.set(x,0,z);c.rotation.y=a+0.6*(k%2?1:-1);g.add(c);
    for(const sx of [-3,3]){const l=new THREE.Mesh(new THREE.BoxGeometry(1,h,1),dk);l.position.set(sx,h/2,0);c.add(l);}
    const arm=new THREE.Mesh(new THREE.BoxGeometry(1.2,1.2,44),dk);arm.position.set(0,h,8);c.add(arm);stgAdd(c,'#ff4030',0,h+1,28,4);}
  stgAdd(g,'#ff5a4a',MIR_X-32,2.6,33,3);stgAdd(g,'#5aff8a',MIR_X+32,2.6,33,3);}
// the cape: the lighthouse in the middle (white, two red bands, its lamp and two beams turning), and a low rail on posts all
// round it, one ring of short lengths that run on into each other
function stgCape(g,Y){const X=MIR_X,r=y=>3.4-y/15,wh=tm('#e8e4dc'),red=tm('#b8442e');
  const t=new THREE.Mesh(new THREE.CylinderGeometry(r(15),r(0),15,20),wh);t.position.set(X,7.5,0);outline(t,0.03);g.add(t);
  for(const c of [4,10]){const b=new THREE.Mesh(new THREE.CylinderGeometry(r(c+0.8)+0.03,r(c-0.8)+0.03,1.6,20),red);b.position.set(X,c,0);g.add(b);}
  const gal=new THREE.Mesh(new THREE.CylinderGeometry(3.1,3.1,0.3,20),tm('#2a2224'));gal.position.set(X,15.2,0);g.add(gal);
  const lamp=new THREE.Mesh(new THREE.CylinderGeometry(1.8,1.8,2.2,16),new THREE.MeshBasicMaterial({color:'#fff1c8'}));lamp.position.set(X,16.5,0);g.add(lamp);
  const roof=new THREE.Mesh(new THREE.ConeGeometry(2.3,1.7,16),red);roof.position.set(X,18.45,0);g.add(roof);stgAdd(g,'#fff1c8',X,16.5,0,12);
  const bm=new THREE.MeshBasicMaterial({color:'#fff3c4',transparent:true,opacity:0.2,depthWrite:false,blending:THREE.AdditiveBlending,fog:false,side:THREE.DoubleSide});
  const beam=new THREE.Group();beam.position.set(X,16.5,0);g.add(beam);Y.beam=beam;
  for(const s of [1,-1]){const c=new THREE.Mesh(new THREE.ConeGeometry(7,90,16,1,true),bm);c.rotation.z=s*Math.PI/2;c.position.x=s*45;beam.add(c);}
  const R=Y.ringR,D=Math.PI/180,stone=tm('#c8c0b0'),segs=[];
  const top=new THREE.Mesh(new THREE.TorusGeometry(R,0.08,6,180),stone);top.rotation.x=Math.PI/2;top.position.set(X,0.72,0);g.add(top);
  for(let a=0;a<360;a+=10){const p=new THREE.Mesh(new THREE.CylinderGeometry(0.09,0.11,0.72,6),tm('#5a5650'));p.position.set(X+R*Math.sin(a*D),0.36,R*Math.cos(a*D));g.add(p);}
  for(let k=0;k<120;k++){const a0=k*3*D,a1=(k+1)*3*D,q={x0:X+R*Math.sin(a0),z0:R*Math.cos(a0),x1:X+R*Math.sin(a1),z1:R*Math.cos(a1),y0:0.8,y1:0.8,keep:11};
    if(segs.length){segs[segs.length-1].nx=q;q.pv=segs[segs.length-1];}segs.push(q);RAILS.push(q);}
  segs[segs.length-1].nx=segs[0];segs[0].pv=segs[segs.length-1];}
/* ----- a stage on the mirror ----- */
function stgStart(R){mirLay(R.lay);const Y=MIR.lay;scene.fog.near=R.fog[0];scene.fog.far=R.fog[1];canvas.style.filter=R.filter;if(MIR.moon)MIR.moon.visible=R.moon;
  STGS.lit=0;for(const L of Y.lampObjs||[]){L.lit=false;L.gl.visible=false;L.ring.visible=true;L.body.material.color.set('#4a5060');}}
function stgStop(){if(MIR.moon)MIR.moon.visible=true;}
// (each frame: the base's own light and fog stay on until the warp out of it)
function stgSky(){const R=MIR.rule;applyLight(R.hour);scene.fog.near=R.fog[0];scene.fog.far=R.fog[1];if(canvas.style.filter!==R.filter)canvas.style.filter=R.filter;}
const stgProg=()=>MIR.rule.goal.k==='lamps'?STGS.lit:MIR.kills;
function stgStep(dt,busy){if(!stgOn())return;const R=MIR.rule,Y=MIR.lay;
  for(const L of Y.lampObjs||[]){if(L.lit){L.gl.material.opacity=0.8+0.2*Math.sin(clock*5+L.z);continue;}L.ring.material.opacity=0.3+0.2*Math.sin(clock*3+L.x);}
  if(Y.tower){if(!busy)Y.beam.rotation.y+=dt*0.7;
    // she cannot ride into the lighthouse
    const dx=P.x-MIR_X,dz=P.z,d=Math.hypot(dx,dz),m=Y.tower+0.5;if(d<m&&!P.grind&&P.y<16){const l=d||1;P.x=MIR_X+dx/l*m;P.z=dz/l*m;}
    // in the fog a shadow shows only in the beam or close by; its eyes show always, dimly
    const b=Y.beam.rotation.y;
    for(const f of MIR.foes){if(f.gone)continue;const p=f.g.position,a=Math.atan2(-p.z,p.x-MIR_X),e=Math.abs(Math.atan2(Math.sin(a-b),Math.cos(a-b))),
      lit=Math.min(e,Math.PI-e)<0.3||Math.hypot(p.x-P.x,p.z-P.z)<9;f.g.visible=lit;if(!lit)f.eye.material.opacity*=0.5;if(f.aura)f.aura.visible=lit&&(f.kind==='red'||f.kind==='boss');}}
  if(MIR.go&&!MIR.end&&stgProg()>=R.goal.n)mirFinish(true);}
// a ring round a lantern lights it
function stgRing(inside){if(!stgOn())return'';let n=0;
  for(const L of MIR.lay.lampObjs||[]){if(L.lit||!inside(L.x,L.z))continue;L.lit=true;n++;STGS.lit++;MIR.score+=100;L.gl.visible=true;L.ring.visible=false;L.body.material.color.set('#ffe2a0');
    sparks(new THREE.Vector3(L.x,1.2,L.z),30,'#ffcf70',8,0.12);}
  return n?`灯籠をともした！ ${STGS.lit}/${MIR.rule.goal.n}`:'';}
function stgHUD(){if(!stgOn())return null;const R=MIR.rule,G=R.goal;
  return{step:G.k==='lamps'?`海に浮かぶ灯籠を光の線で囲んで、${G.n}つともせ`:`影を${G.n}体、光の線で囲んで消せ`+(MIR.lay.tower?'（灯台の光が当たると、影のすがたが見える）':''),
    meter:`${G.k==='lamps'?'灯籠':'目標'} ${stgProg()}/${G.n}`};}
function stgMap(toM){if(!stgOn())return;const Y=MIR.lay,S=mapc.width/150;
  for(const L of Y.lampObjs||[]){const [x,y]=toM(L.x,L.z);mg.fillStyle=L.lit?'#ffcf70':'#3a3f50';mg.strokeStyle='#ffcf70';mg.lineWidth=1.5;mg.beginPath();mg.arc(x,y,3.4,0,TAU);mg.fill();mg.stroke();}
  if(Y.tower){const [x,y]=toM(MIR_X,0);mg.strokeStyle='#8a8478';mg.lineWidth=1.5;mg.beginPath();mg.arc(x,y,Y.ringR*S,0,TAU);mg.stroke();mg.fillStyle='#f2eee6';mg.beginPath();mg.arc(x,y,3,0,TAU);mg.fill();}}
// a garment not had yet (not the rarest), for a new star; with all of them had, kakera for the capsule toys
function stgPrize(){SAVE.owned=SAVE.owned||{};const no=PRIZES.filter(p=>!SAVE.owned[p.key]),pool=no.filter(p=>p.r!=='SR');const L=pool.length?pool:no;
  if(!L.length){SAVE.kakera=(SAVE.kakera||0)+5;return null;}const p=L[Math.floor(rnd()*L.length)];SAVE.owned[p.key]=1;return p;}
function stgEnd(won){const R=MIR.rule,S=stgSave(R.id);STGS.last=R.i;const first=won&&!S.s[0],got=[won,won&&MIR.hearts>=Math.ceil(DRONE.maxHp/2),won&&MIR.t<=R.fast],msgs=[];
  got.forEach((g,k)=>{if(!g||S.s[k])return;S.s[k]=1;const p=stgPrize();msgs.push(p?`★ ごほうび：${p.name}（着がえで着られる）`:'★ ごほうび：カプセルトイのかけら +5');});
  if(first){SAVE.money+=500*(R.i+1);msgs.unshift(`はじめてのクリア！ お礼 +${500*(R.i+1)}円`);if(STG[R.i+1])msgs.push(`つぎの島「${STG[R.i+1].name}」への光の道がのびた！`);}
  const best=MIR.score>(S.best||0);if(best)S.best=MIR.score;save();renderHUD();
  return{line:`${got.map((g,k)=>`${g?'★':'☆'} ${stgStarText(R,k)}`).join('　')}　スコア ${MIR.score}${best?'（ベスト！）':`（ベスト ${S.best}）`}`,
    pre:msgs.length?[['say','',...msgs]]:[],post:[['say','tome',won?'おかえり。いい滑りだったね。':'おかえり。……もう一度、行ってみるかい？'],['call',stgNext]]};}
// back at the command table: on to the next island, the same again, or the map
async function stgNext(){const k=STGS.last,nx=STG[k+1]&&stgOpen(k+1)?k+1:null;
  const opts=[...(nx!=null?[`つぎのステージ「${STG[nx].name}」へ`]:[]),`もう一度「${STG[k].name}」へ`,'島の地図を見る','やめる'],pick=opts[await askP('tome','つづけて行くかい？',opts)];
  const go=pick==='やめる'?null:pick==='島の地図を見る'?await stgPick():pick.startsWith('もう一度')?k:nx;if(go!=null)await steps(mirScript(stgRule(go)));}
/* ----- the map of islands ----- */
function stgPick(){return new Promise(res=>{const cv=$('stgCv'),c=cv.getContext('2d'),info=$('stgInfo'),go=$('stgGo');let sel=0,done=false;
  for(let i=0;i<STG.length;i++)if(stgOpen(i)&&(!stgSave(STG[i].id).s[0]||i===0))sel=i;
  const draw=()=>{const W=cv.width,H=cv.height,g=c.createLinearGradient(0,0,0,H);g.addColorStop(0,'#16304e');g.addColorStop(1,'#0a1626');c.fillStyle=g;c.fillRect(0,0,W,H);
    c.strokeStyle='rgba(140,190,230,.12)';c.lineWidth=1;for(let k=0;k<14;k++){const y=12+k*16,x=(k*53)%W;c.beginPath();c.moveTo(x,y);c.quadraticCurveTo(x+9,y-4,x+18,y);c.stroke();}
    const pts=STG.map(s=>s.at).concat(STG_SOON);
    for(let i=0;i<pts.length-1;i++){const a=pts[i],b=pts[i+1],lit=i<STG.length-1&&stgOpen(i+1);c.save();c.setLineDash(lit?[]:[3,6]);c.lineWidth=lit?3:1.5;
      c.strokeStyle=lit?'#ffe6a0':'rgba(160,180,200,.35)';if(lit){c.shadowColor='#ffcf70';c.shadowBlur=10;}c.beginPath();c.moveTo(a[0],a[1]);c.lineTo(b[0],b[1]);c.stroke();c.restore();}
    c.textAlign='center';c.textBaseline='middle';
    STG_SOON.forEach(([x,y])=>{c.fillStyle='rgba(120,130,150,.35)';c.beginPath();c.arc(x,y,16,0,TAU);c.fill();c.fillStyle='rgba(220,230,240,.5)';c.font='bold 14px sans-serif';c.fillText('？',x,y);});
    STG.forEach((s,i)=>{const [x,y]=s.at,op=stgOpen(i),S=stgSave(s.id);
      if(i===sel){c.strokeStyle='#ffffff';c.lineWidth=3;c.beginPath();c.arc(x,y,27,0,TAU);c.stroke();}
      c.fillStyle=op?s.col:'#3a4250';c.beginPath();c.arc(x,y,22,0,TAU);c.fill();c.strokeStyle='rgba(0,0,0,.35)';c.lineWidth=2;c.stroke();
      c.fillStyle='#fff';c.font='bold 15px sans-serif';c.fillText(op?String(i+1):'？',x,y+1);
      c.font='bold 12px sans-serif';c.fillStyle=op?'#ffffff':'rgba(220,230,240,.55)';c.fillText(op?s.name:'まだ行けない',x,y+36);
      if(op){c.fillStyle='#ffd84a';c.font='12px sans-serif';c.fillText(S.s.map(v=>v?'★':'☆').join(''),x,y-33);}});
    const s=STG[sel],S=stgSave(s.id),op=stgOpen(sel),G=s.goal;
    info.innerHTML=`<b>ステージ${sel+1}　${s.name}</b>（${s.place}）<br>`+(op?`目標：${G.k==='lamps'?`灯籠を${G.n}つともす`:`影を${G.n}体消す`}（${stgTime(s.dur)}まで）<br>`+
      STG_STARS.map((_,k)=>`${S.s[k]?'★':'☆'} ${stgStarText(s,k)}`).join('　')+(S.best?`<br>ベスト ${S.best}`:''):'ひとつ前の島をクリアすると、光の道がのびて行けるようになる。');
    go.disabled=!op;go.style.opacity=op?1:0.5;};
  const end=v=>{if(done)return;done=true;cv.onpointerdown=go.onclick=$('stgClose').onclick=null;closeModal();res(v);};
  cv.onpointerdown=e=>{const r=cv.getBoundingClientRect(),x=(e.clientX-r.left)*cv.width/r.width,y=(e.clientY-r.top)*cv.height/r.height;
    STG.forEach((s,i)=>{if(Math.hypot(x-s.at[0],y-s.at[1])<30){sel=i;draw();}});};
  go.onclick=()=>{if(stgOpen(sel))end(sel);};$('stgClose').onclick=()=>end(null);
  draw();openModal('stgM');
  // closed some other way (Escape)
  const watch=()=>{if(done)return;if(modal!=='stgM'){done=true;res(null);return;}requestAnimationFrame(watch);};requestAnimationFrame(watch);});}
