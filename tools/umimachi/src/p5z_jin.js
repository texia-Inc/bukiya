/* ---------- a trial of another night out in 裏海街: 陣取り, taking the town back ground by ground. The town starts all
   shadow; round where she sets out is a patch of her own ground, warm and lit. Out of it she leaves a line of light, and
   back into it the line closes: everything it closes round becomes hers. The shadows cannot come onto her ground, and on it
   she is safe; out of it a touch costs a heart, and a red shadow on the line cuts it away (a heart too). Shadows caught
   inside new ground burn away. At dawn, how much of the town is hers. It shares the night out of p5x_run.js (the shadows,
   the hearts, the roofs, the second jump), RUN.mode 'jin'; the ground is a grid of 2 m cells. Here the town keeps its colours
   (no grey over the whole picture): the shadow's ground is darkened, hers is clear with a warm edge, and so on the little map. ---------- */
const JX0=-200,JZ0=-200,JS=2,JW=200,JH=224;
const JIN={own:null,land:null,total:0,mine:0,tex:null,mesh:null,map:null,lx:0,lz:0,cut:false,said:false,graze:null};
const jinCell=(x,z)=>{const cx=Math.floor((x-JX0)/JS),cz=Math.floor((z-JZ0)/JS);return cx<0||cz<0||cx>=JW||cz>=JH?-1:cz*JW+cx;};
const jinOwn=(x,z)=>{const i=jinCell(x,z);return i>=0&&JIN.own[i]===1;};
// the grid, the land in it (not the sea), and the shade over the ground: a mesh lying on the ground every 4 m
function jinBuild(){if(JIN.own)return;JIN.own=new Uint8Array(JW*JH);JIN.land=new Uint8Array(JW*JH);
  for(let cz=0;cz<JH;cz++)for(let cx=0;cx<JW;cx++){const x=JX0+(cx+0.5)*JS,z=JZ0+(cz+0.5)*JS;if(G(x,z)>SEA_Y+0.3){JIN.land[cz*JW+cx]=1;JIN.total++;}}
  const data=new Uint8Array(JW*JH*4);JIN.tex=new THREE.DataTexture(data,JW,JH,THREE.RGBAFormat);JIN.tex.magFilter=JIN.tex.minFilter=THREE.LinearFilter;
  const NX=JW/2,NZ=JH/2,pos=[],uv=[],idx=[];
  for(let j=0;j<=NZ;j++)for(let i=0;i<=NX;i++){const x=JX0+i*4,z=JZ0+j*4;pos.push(x,G(x,z)+paveY(x,z)+0.18,z);uv.push(i/NX,j/NZ);}
  for(let j=0;j<NZ;j++)for(let i=0;i<NX;i++){const a=j*(NX+1)+i,b=a+1,c=a+NX+1,d=c+1;idx.push(a,c,b,b,c,d);}
  const geo=new THREE.BufferGeometry();geo.setAttribute('position',new THREE.Float32BufferAttribute(pos,3));geo.setAttribute('uv',new THREE.Float32BufferAttribute(uv,2));geo.setIndex(idx);
  JIN.mesh=new THREE.Mesh(geo,new THREE.MeshBasicMaterial({map:JIN.tex,transparent:true,depthWrite:false,side:THREE.DoubleSide,fog:false,polygonOffset:true,polygonOffsetFactor:-4,polygonOffsetUnits:-4}));
  JIN.mesh.frustumCulled=false;JIN.mesh.visible=false;scene.add(JIN.mesh);
  JIN.map=document.createElement('canvas');JIN.map.width=JW;JIN.map.height=JH;}
// the shadow's ground dark, hers clear with a warm edge; on the little map hers is warm
function jinPaint(){const d=JIN.tex.image.data,o=JIN.own,m=JIN.map.getContext('2d'),img=m.createImageData(JW,JH);let n=0;
  for(let cz=0;cz<JH;cz++)for(let cx=0;cx<JW;cx++){const i=cz*JW+cx,j=i*4;
    if(!o[i]){d[j]=22;d[j+1]=18;d[j+2]=34;d[j+3]=150;img.data[j+3]=0;continue;}if(JIN.land[i])n++;
    const edge=cx&&cz&&cx<JW-1&&cz<JH-1&&!(o[i-1]&&o[i+1]&&o[i-JW]&&o[i+JW]);
    d[j]=255;d[j+1]=205;d[j+2]=120;d[j+3]=edge?170:0;img.data[j]=255;img.data[j+1]=200;img.data[j+2]=110;img.data[j+3]=edge?255:150;}
  m.putImageData(img,0,0);JIN.tex.needsUpdate=true;JIN.mine=n;}
const jinPct=()=>JIN.total?JIN.mine/JIN.total*100:0;
function jinEnter(){jinBuild();JIN.own.fill(0);const [sx,sz]=RUN_START;
  for(let cz=0;cz<JH;cz++)for(let cx=0;cx<JW;cx++){const x=JX0+(cx+0.5)*JS,z=JZ0+(cz+0.5)*JS;if(Math.hypot(x-sx,z-sz)<12)JIN.own[cz*JW+cx]=1;}
  JIN.lx=sx;JIN.lz=sz;JIN.cut=false;RUN.life=1e6;jinPaint();JIN.mesh.visible=true;canvas.style.filter='saturate(.8)';}
function jinExit(){if(JIN.mesh)JIN.mesh.visible=false;}
// out of her ground the line runs from where she left it; back onto it, what it closes round is hers
function jinStep(dt){const T=RUN.trail;
  if(jinOwn(P.x,P.z)){if(T.length>1)jinTake();T.length=0;JIN.lx=P.x;JIN.lz=P.z;JIN.cut=false;return;}
  if(!T.length&&!JIN.cut)T.push({x:JIN.lx,y:P.y+0.08,z:JIN.lz,t:RUN.t,g:0});
  const l=T[T.length-1];if(T.length<RUN_MAX&&(!l||Math.hypot(P.x-l.x,P.z-l.z)>RUN_STEP))T.push({x:P.x,y:P.y+0.08,z:P.z,t:RUN.t,g:P.grind||P.man||P.air?1:0});}
function jinTake(){const o=JIN.own,before=JIN.mine,pts=[...RUN.trail,{x:P.x,z:P.z}];
  // the line onto the grid, without diagonal gaps (the fill must not leak through them)
  let pc=jinCell(pts[0].x,pts[0].z);
  for(let k=1;k<pts.length;k++){const a=pts[k-1],b=pts[k],L=Math.hypot(b.x-a.x,b.z-a.z),n=Math.max(1,Math.ceil(L/0.4));
    for(let s=1;s<=n;s++){const x=lerp(a.x,b.x,s/n),z=lerp(a.z,b.z,s/n),c=jinCell(x,z);if(c<0||c===pc)continue;
      if(pc>=0&&c%JW!==pc%JW&&(c/JW|0)!==(pc/JW|0))o[(pc/JW|0)*JW+c%JW]=1;o[c]=1;pc=c;}}
  if(pc>=0)o[pc]=1;
  // everything the shadow can no longer reach from the edge of the map is hers
  const seen=new Uint8Array(JW*JH),q=new Int32Array(JW*JH);let h=0,t=0;
  const push=i=>{if(!o[i]&&!seen[i]){seen[i]=1;q[t++]=i;}};
  for(let cx=0;cx<JW;cx++){push(cx);push((JH-1)*JW+cx);}for(let cz=0;cz<JH;cz++){push(cz*JW);push(cz*JW+JW-1);}
  while(h<t){const i=q[h++],cx=i%JW;if(cx>0)push(i-1);if(cx<JW-1)push(i+1);if(i>=JW)push(i-JW);if(i<JW*(JH-1))push(i+JW);}
  for(let i=0;i<o.length;i++)if(!o[i]&&!seen[i])o[i]=1;
  jinPaint();const got=(JIN.mine-before)/JIN.total*100;let burnt=0;
  for(const f of RUN.foes)if(!f.gone&&jinOwn(f.g.position.x,f.g.position.z)){runKill(f);burnt++;}
  if(got>=0.05){runPop(`町を取り戻した +${got.toFixed(1)}%`,`ぜんぶで ${jinPct().toFixed(1)}%${burnt?`　影 ${burnt}体 浄化`:''}`);sfx.boom(got>2?0.7:0.4);buzz(got>2?'heavy':'light',true);
    sparks(new THREE.Vector3(P.x,P.y+1,P.z),Math.min(40,10+got*4|0),'#ffe2a0',8,0.14);}
  renderHUD();}
// a red shadow on the line: the line is gone, and a heart with it; she starts a new line from where she is
function jinCut(){RUN.trail.length=0;JIN.cut=true;sparks(new THREE.Vector3(P.x,P.y+0.5,P.z),14,'#ff6a5a',5,0.1);
  if(RUN.inv>0)return;RUN.inv=1.3;RUN.hearts--;buzz('heavy',true);renderHUD();if(RUN.hearts<=0){runFinish(false);return;}toast('赤い影に、線を切られた！');}
function jinHUD(tr){tr.hidden=false;tr.innerHTML='';const b=document.createElement('b');b.textContent='裏海街の陣取り（試作）';const s=document.createElement('span');s.className='step';
  s.textContent=!RUN.go?'……':jinOwn(P.x,P.z)?'ここはナギの土地（安全）。外へ出て、ぐるっと回ってもどれば広がる':'線をのばしている。自分の土地にもどれば囲める。赤い影に線を切られるな';
  const m=document.createElement('span');m.className='meter';const tl=Math.max(0,Math.ceil(RUN_DUR-RUN.t));
  m.textContent=`のこり ${tl/60|0}:${String(tl%60).padStart(2,'0')}　${'♥'.repeat(Math.max(0,RUN.hearts))}${'♡'.repeat(Math.max(0,RUN.hmax-RUN.hearts))}　取り戻した町 ${jinPct().toFixed(1)}%`;tr.append(b,s,m);}
function jinMap(toM){const [ax,ay]=toM(JX0,JZ0),[bx,by]=toM(JX0+JW*JS,JZ0+JH*JS);mg.save();mg.globalAlpha=0.6;mg.imageSmoothingEnabled=false;mg.drawImage(JIN.map,ax,ay,bx-ax,by-ay);mg.restore();}
// dawn, or the hearts gone: how much of the town came back; the best kept on this phone
function jinFinish(){RUN.end=true;for(const f of RUN.foes)f.gone=1;RUN.trail.length=0;
  const pct=jinPct(),R=SAVE.jinRec||(SAVE.jinRec={}),best=pct>(R.best||0)&&R.best!=null,got=Math.floor(pct/2)+Math.floor(RUN.kills/3);
  R.best=Math.max(R.best||0,Math.round(pct*10)/10);R.nights=(R.nights||0)+1;SAVE.shards=shards()+got;save();
  runEvent({id:'jin_end',once:false,script:[['wait',1.2],
    ['say','',RUN.hearts>0?'東の空が白んできた。':'影の手に、のみこまれた……。',`取り戻した町 ${pct.toFixed(1)}%　浄化した影 ${RUN.kills}体`,`影のかけら +${got}${best?'　新記録！':''}　（いちばん広かった夜 ${R.best}%）`],
    ['fade','out'],['call',runExit],['ura',false],['warp',HQ_X+HQ_IN[0],HQ_IN[1],HQ_IN[2]],['call',()=>{P.foot=true;P.carry='back';padLabels();}],['fade','in']]});}
// riding in 陣取り: the board keeps its speed, the small things in the street let her through (a spark as she brushes them),
// and a building turns her along its wall instead of stopping her
const JIN_CRUISE=8,JIN_SOFT=new Set(['prop','pole','vend','tree','stop','npc','car','post','kei','van','truck']);
const jinRide=()=>RUN.on&&RUN.mode==='jin'&&RUN.go&&!RUN.end;
function jinAlong(to,dt){const d=Math.atan2(Math.sin(to-P.yaw),Math.cos(to-P.yaw));P.yaw+=clamp(d,-6*dt,6*dt);}
function jinSlide(hx,hz,nx,nz,F,dt){
  const al=!hx?Math.abs(F[0]):!hz?Math.abs(F[1]):0;if(al<0.5&&P.v>6&&P.bump<0.1)P.bump=0.2;
  if(!hx){P.x=nx;jinAlong(F[0]>=0?Math.PI/2:-Math.PI/2,dt);}
  else if(!hz){P.z=nz;jinAlong(F[1]>=0?0:Math.PI,dt);}
  else{let best=null;for(const sd of [1,-1]){const y=P.yaw+sd*Math.PI/2;if(!hits(P.x+Math.sin(y)*0.8,P.z+Math.cos(y)*0.8,0.3,P.y,JIN_SOFT)){best=y;break;}}
    jinAlong(best==null?P.yaw+Math.PI:best,dt*1.5);}
  P.v*=1-Math.min(0.5,dt*1.4*(1-al));}
function jinGraze(R){let hit=null;for(const c of COLL)if(c.on&&JIN_SOFT.has(c.tag)&&c.top>P.y+STEP&&P.x+R>c.x0&&P.x-R<c.x1&&P.z+R>c.z0&&P.z-R<c.z1){hit=c;break;}
  if(hit&&hit!==JIN.graze){sparks(new THREE.Vector3(P.x,P.y+0.6,P.z),6,'#ffe2a0',3,0.06);P.bump=Math.max(P.bump,0.12);buzz('light');}JIN.graze=hit;}
// out from the command table
function jinScript(){return[
  ['fade','out'],['call',()=>{applyD2();}],['ura',true],['call',()=>runEnter('jin')],['time',23.2,0],['warp',...RUN_START],['call',rideNow],['fade','in'],
  ['say','tome','（無線の声）……聞こえるかい、ナギ。今夜は、町を取りもどす夜だよ。','足もとの、あったかい光のところが、あんたの土地だ。そこには影は入ってこられない。',
    '土地から出ると、光の線がのびる。ぐるっと回って土地にもどれば、線で囲んだところが、ぜんぶあんたの土地になる。','大きく回るほど、たくさん取りもどせる。でも、外にいるあいだに赤い影に線を切られたら、やりなおしだ。',
    '今夜のボードは止まらずにすべりつづける。小さな物はすりぬけて、建物にあたっても壁にそって曲がるよ。止まりたいときは、うしろだ。',
    '屋根の上も、二段ジャンプも使えるよ。夜明けまでに、どれだけ取りもどせるかね。'],
  ['call',()=>{RUN.go=true;toast('土地から出て、ぐるっと回ってもどれ！',true);}]];}
