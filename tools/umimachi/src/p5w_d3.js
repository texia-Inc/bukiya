/* ---------- the third extra story 「鏡の海」 (after d2_done): the end of the summer. The town's reflection in the sea has slipped,
   and Mio's voice says the sea of 裏海街 has gone to a mirror that is showing this side's summer back, and something like Nagi is
   being born in it. Four nights out on the mirror (p5v_mirror.js) from the command table, one a day:
     1. the mirror as it was; at dawn a dark skater rides by, Nagi's double (映し身), and copies her kickflip
     2. the double rides among the shadows, doing every trick she does a moment later, and its wheels wipe out her line
        where they cross it; a ring round it stops it for a while
     3. the mirror has gone cloudy: a ring closes only with gold in it (line drawn on a rail, in a manual, or in the air after a
        trick); at dawn a lighthouse shows deep in the mirror, the wrong way round
     4. the last night: three gold rings round the double, and it stops; it is her summer, the lighthouse behind the mirror
        lights, the water comes back. The last day of the holidays: goodbyes on the beach, the train out of the town.
   Between the nights, Sota (a dream of a dark Nagi on the night sea) and Natsumi (a mirror sea she saw with Mio) have a word.
   Flags: d3 (begun), d3n (story nights won), d3last (the day of the last one won), d3_done. ---------- */
const D3={echo:null,fig:null,rib:null,tower:null,lamp:null,said:false};
const d3n=()=>SAVE.flags.d3n||0;
// what each night asks: echo (the double rides), gold (a ring needs gold in it), final (the double takes three gold rings, no clock)
const D3_RULE=[null,{n:1,title:'鏡の海　1夜目'},{n:2,echo:true,title:'鏡の海　2夜目'},{n:3,echo:true,gold:true,title:'鏡の海　3夜目'},
  {n:4,echo:true,gold:false,final:true,title:'鏡の海　最後の夜'}];
const d3Label=()=>`鏡の海へ（${d3n()>=3?'最後の夜':`${d3n()+1}夜目`}）`;
const d3Tonight=()=>!!SAVE.flags.d3&&!SAVE.flags.d3_done&&SAVE.flags.d3last!==SAVE.day;

/* ----- the double: Nagi's own figure gone dark and glassy, a line of violet behind it ----- */
function echoBuild(){if(D3.fig)return D3.fig;const h=makeSkater(),ol=[];
  const mat=new THREE.MeshLambertMaterial({color:'#141a34',emissive:'#2a3a88',emissiveIntensity:0.8,side:THREE.DoubleSide});
  h.g.traverse(o=>{if(!o.isMesh)return;o.castShadow=false;for(const c of o.children)if(c.isMesh&&c.geometry===o.geometry)ol.push(c);});for(const o of ol)o.parent.remove(o);
  h.g.traverse(o=>{if(o.isMesh)o.material=mat;});
  h.aura=glow('#5a6cff',0,0,0,3.4);scene.remove(h.aura);h.aura.visible=true;h.g.add(h.aura);h.aura.position.set(0,1,0);
  // its line: the same ribbon as hers, in violet (it lives a couple of seconds)
  const rib=(w,col)=>{const geo=new THREE.BufferGeometry();geo.setAttribute('position',new THREE.BufferAttribute(new Float32Array(MIR_MAX*6),3));geo.setAttribute('color',new THREE.BufferAttribute(new Float32Array(MIR_MAX*6),3));
    const idx=[];for(let i=0;i<MIR_MAX-1;i++){const a=i*2;idx.push(a,a+1,a+2,a+1,a+3,a+2);}geo.setIndex(idx);
    const m=new THREE.Mesh(geo,new THREE.MeshBasicMaterial({vertexColors:true,transparent:true,blending:THREE.AdditiveBlending,depthWrite:false,side:THREE.DoubleSide,fog:false}));m.frustumCulled=false;m.userData={w,col:new THREE.Color(col)};return m;};
  D3.rib=[rib(1.2,'#2a1a5a'),rib(0.26,'#9a7cff')];D3.fig=h;return h;}
// the lighthouse behind the mirror: past the edge of the open water, seen from the third night on; lit at the very end
function d3Tower(){if(D3.tower)return D3.tower;const g=new THREE.Group(),white=tm('#e8e6e0'),red=tm('#a83a34'),dark=tm('#2a2e36');
  for(let k=0;k<6;k++){const r0=2.2-k*0.22,r1=2.2-(k+1)*0.22,m=new THREE.Mesh(new THREE.CylinderGeometry(r1,r0,2.6,16),k%2?red:white);m.position.y=1.3+k*2.6;g.add(m);}
  const room=new THREE.Mesh(new THREE.CylinderGeometry(1.2,1.2,1.6,12),tm('#cfe6ff',{transparent:true,opacity:0.5}));room.position.y=16.4;g.add(room);
  const cap=new THREE.Mesh(new THREE.ConeGeometry(1.5,1.4,12),dark);cap.position.y=17.9;g.add(cap);
  D3.lamp=glow('#fff2c0',0,0,0,16);scene.remove(D3.lamp);D3.lamp.position.set(0,16.4,0);g.add(D3.lamp);D3.lamp.visible=false;
  g.scale.setScalar(1.6);g.position.set(MIR_X,0,-(MIR_R+16));D3.tower=g;return g;}
function echoStart(rule){const h=echoBuild();MIR.g.add(h.g);for(const r of D3.rib)MIR.g.add(r);h.g.visible=true;h.aura.material.opacity=0.5;
  const x=MIR_X,z=-24;
  D3.echo={x,z,y:mirG(x,z),yaw:0,v:0,vy:0,air:false,turn:0,trick:null,copy:[],stun:0,hp:rule.final?3:0,line:[],wp:null,wpT:0,down:false};}
function echoStop(){if(D3.fig&&MIR.g){MIR.g.remove(D3.fig.g);for(const r of D3.rib)MIR.g.remove(r);}D3.echo=null;}
// Nagi's tricks, a moment later
function echoCopy(kind){const E=D3.echo;if(!E||E.down||!TRICK_KIND[kind]||kind==='grab')return;E.copy.push({kind,at:clock+1.4});
  if(!D3.said){D3.said=true;setTimeout(()=>toast('映し身が、ナギの技をまねしている……',true),1500);}}
function echoStep(dt,busy){const E=D3.echo;if(!E)return;const h=D3.fig;
  if(E.cut||!busy&&!MIR.end&&MIR.go){
    if(E.stun>0){E.stun-=dt;E.v=Math.max(0,E.v-14*dt);}
    else if(!E.cut){// rides round near her: a new point to make for every few seconds, faster on the last night
      E.wpT-=dt;if(!E.wp||E.wpT<=0||Math.hypot(E.wp.x-E.x,E.wp.z-E.z)<6){const a=rnd()*TAU,r=8+rnd()*16;let x=P.x+Math.sin(a)*r,z=P.z+Math.cos(a)*r;
        const l=Math.hypot(x-MIR_X,z);if(l>MIR_R-8){x=MIR_X+(x-MIR_X)/l*(MIR_R-8);z=z/l*(MIR_R-8);}E.wp={x,z};E.wpT=4+rnd()*2;}
      let d=Math.atan2(E.wp.x-E.x,E.wp.z-E.z)-E.yaw;d=Math.atan2(Math.sin(d),Math.cos(d));const st=clamp(d,-1.8*dt,1.8*dt);E.yaw+=st;E.turn+=(clamp(-d,-1,1)-E.turn)*Math.min(1,5*dt);
      E.v+=((MIR.rule&&MIR.rule.final?9.5:8)-E.v)*Math.min(1,dt);}
    E.x+=Math.sin(E.yaw)*E.v*dt;E.z+=Math.cos(E.yaw)*E.v*dt;const l=Math.hypot(E.x-MIR_X,E.z);if(l>MIR_R-2){E.x=MIR_X+(E.x-MIR_X)/l*(MIR_R-2);E.z=E.z/l*(MIR_R-2);E.wp=null;}
    // her tricks, copied: up it goes, and the board turns the same way hers did
    if(!E.air&&!E.stun&&E.copy.length&&clock>=E.copy[0].at){E.air=true;E.vy=7.6;}
    const gy=mirG(E.x,E.z);
    if(E.air){if(!E.trick&&E.copy.length&&clock>=E.copy[0].at)E.trick={type:E.copy.shift().kind,t:0};
      if(E.trick){E.trick.t+=dt/TRICK_KIND[E.trick.type].d;if(E.trick.t>=1)E.trick=null;}
      E.vy-=13.5*dt;E.y+=E.vy*dt;if(E.y<=gy){E.y=gy;E.air=false;E.vy=0;E.trick=null;}}
    else{E.y=gy;
      // its wheels wipe out her line where they run over it: everything older than that point is gone
      const T=MIR.trail;if(E.v>1)for(let j=T.length-1;j>=0;j--)if(Math.hypot(T[j].x-E.x,T[j].z-E.z)<1){T.splice(0,j+1);sparks(new THREE.Vector3(E.x,gy+0.2,E.z),10,'#9a7cff',4,0.08);break;}}
    const q=E.line[E.line.length-1];if(!E.air&&E.v>1&&(!q||Math.hypot(E.x-q.x,E.z-q.z)>MIR_STEP))E.line.push({x:E.x,y:gy+0.05,z:E.z,t:MIR.t-(MIR_LIFE-2.5)});
  }
  if(E.cut&&ST.cam)ST.cam.look.set(E.x,E.y+1,E.z);   // the first dawn: the camera follows it past
  while(E.line.length&&MIR.t-E.line[0].t>MIR_LIFE)E.line.shift();for(const r of D3.rib)mirRibbon(r,E.line);
  const tk=E.trick,body=tk&&tk.type==='body';
  h.g.position.set(E.x,E.y,E.z);h.g.rotation.set(0,E.yaw+(body?TAU*tk.t:0),0);h.root.rotation.set(0,0,clamp(E.turn*E.v*0.03,-0.25,0.25));
  poseSkater(h,dt,{v:E.v,turn:E.turn,push:false,brake:false,air:E.air,vy:E.vy,flip:tk?tk.t*TRICK_KIND[tk.type].z:0,spin:tk?(body?-tk.t:tk.t*TRICK_KIND[tk.type].y):0,tkp:tk?tk.t:0});
  h.aura.material.opacity=E.stun>0?0.25+0.2*Math.sin(clock*20):0.45+0.12*Math.sin(clock*3);}
// a ring closed round it: on the last night a gold ring wounds it (a plain one only makes it stagger); before that it stops a while
function echoRing(inside,gold){const E=D3.echo;if(!E||E.down||!inside(E.x,E.z))return'';const p=new THREE.Vector3(E.x,E.y+1,E.z);sparks(p,20,'#c8b8ff',7,0.12);
  if(!(MIR.rule&&MIR.rule.final)){E.stun=3;MIR.score+=50;return'映し身を止めた！ ＋50';}
  if(!gold){E.stun=1.2;return'金の線で囲まないと、映し身には届かない！';}
  E.hp--;E.stun=2.5;MIR.score+=200;buzz('heavy',true);
  if(E.hp>0)return`映し身がよろめいた！　のこり ${E.hp}回`;
  E.down=true;E.stun=999;MIR.bossDown=true;setTimeout(()=>mirFinish(true),1600);return'映し身が、止まった……';}

/* ----- out from the command table: what grandma says before each night ----- */
const D3_INTRO={
  1:['ゆうべから、この海に何かが映りこんでる。……今夜は、ようすを見るだけでいい。三分、もちこたえな。'],
  2:['あの影――映し身は、ナギの技をまねる。それに、あの子の車輪がふれた光の線は、消えてしまうよ。','線で囲めば、少しのあいだ止められる。……三分、もちこたえな。'],
  3:['今夜は、鏡がにごってる。ふつうの線じゃ、囲んでも閉じないよ。','技を出して飛びながら、手すりや屋根をすべりながら、マニュアルで走りながら引いた線は、金色になる。','金の線をまぜて囲むんだ。……三分、もちこたえな。'],
  4:['最後の夜だ。映し身を、金の線で三回囲んでおやり。ふつうの線じゃ、あの子には届かない。','あの子は、ナギの技をまねる。……だったら、ナギにしか引けない線を引くんだよ。']};
// after a night: in the mirror at dawn (pre) and back at the base (post); the last night has an ending of its own
function d3End(won){const n=MIR.rule.n;
  if(!won)return{post:[['say','tome','だいじょうぶかい。……あわてなくていい。日が暮れているうちなら、また行けるよ。']]};
  if(n===4)return{replace:d3Ending()};
  const pre={1:[['call',()=>d3EchoCut(true)],['wait',0.6],['say','','鏡の上を、だれかがスケボーで走っていく。','……ナギと同じ板。同じフォーム。'],
      ['say','','黒い影は、ナギがゆうべ決めたキックフリップを、そっくりそのまままねして、朝もやの中に消えた。'],['call',()=>d3EchoCut(false)]],
    2:[['say','','映し身は、遠くからじっとナギを見ていた。','……それから、ナギと同じしぐさで、首をかしげた。']],
    3:[['call',()=>{D3.tower.visible=true;setCam([[P.x,3,P.z+6],[MIR_X,20,-(MIR_R+16)],1.2,'cut']);}],['wait',0.8],
      ['say','','夜明けの鏡の奥に、白い塔が映っていた。','……灯台だ。けれど、島の灯台とは、しまもようの向きがさかさまだった。'],['cam','off']]}[n];
  const post={1:['おかえり。……ナギそっくりの影、か。','鏡の海は、いちばん強いものを映すっていう。……何を映したんだろうね。'],
    2:['あの子、ナギの技を、ぜんぶまねしてたね。','……まるで、ナギといっしょに遊びたがってるみたいだったよ。'],
    3:['さかさまの灯台……。','あすの夜で、きっと終わりにできる。今夜は、ゆっくりお休み。']}[n];
  return{pre,post:[['say','tome',...post],['call',()=>{SAVE.flags.d3n=n;SAVE.flags.d3last=SAVE.day;save();}],['fade','out'],['warp',...HOME],['day']]};}
// the first dawn: the double riding past her, a kickflip, gone
function d3EchoCut(on){if(!on){echoStop();return;}echoStart({});const E=D3.echo,a=P.yaw+0.9;E.x=P.x+Math.sin(a)*9;E.z=P.z+Math.cos(a)*9;E.yaw=P.yaw-Math.PI/2;E.v=7;E.cut=true;E.copy=[{kind:'flip',at:clock+1.2}];
  setCam([[P.x-Math.sin(P.yaw)*4,P.y+2.2,P.z-Math.cos(P.yaw)*4],[E.x,E.y+1,E.z],2,'cut']);}
// the last dawn: the double stops in front of her; it is her summer. The lighthouse lights, and then the last day
function d3Ending(){const front=()=>{const E=D3.echo,F=[Math.sin(P.yaw),Math.cos(P.yaw)];E.x=P.x+F[0]*4.5;E.z=P.z+F[1]*4.5;E.y=mirG(E.x,E.z);E.yaw=P.yaw+Math.PI;E.v=0;E.trick=null;E.air=false;E.line.length=0;
    const sx=-F[1],sz=F[0];setCam([[P.x+F[0]*2.2+sx*5,P.y+2,P.z+F[1]*2.2+sz*5],[P.x+F[0]*2.2,P.y+1.1,P.z+F[1]*2.2],2,'cut']);};
  const at=(dx,dz)=>[BOSS_AT.x+dx,SHORE+dz];
  return[['call',front],['wait',1],
    ['say','','映し身が、ゆっくりと板を止めた。'],
    ['call',()=>ex1Marble(true)],
    ['say','ミオの声','（ナギ。……その子はね、ナギの「夏」だよ）','（鏡の海は、いちばん強い思い出を映すの。……この夏、ナギがいちばん夢中になったもの）'],
    ['say','nagi','……スケボー、か。','毎日、坂を下って、桟橋まで走って、屋根から飛んで……。'],
    ['say','ミオの声','（その子、ナギと遊びたかったんだと思う。……夏が終わっちゃう前に）'],
    ['call',()=>ex1Marble(false)],
    ['say','','映し身は、ナギに向かって右手をあげた。','ナギも、右手をあげた。……鏡みたいに、ぴったり同じに。'],
    ['call',()=>{const E=D3.echo;sparks(new THREE.Vector3(E.x,E.y+1,E.z),40,'#c8b8ff',8,0.2);mirOrb(new THREE.Vector3(E.x,E.y+1,E.z),6);echoStop();
      D3.tower.visible=true;D3.lamp.visible=true;setCam([[P.x,4,P.z+8],[MIR_X,20,-(MIR_R+16)],1.2,'cut']);}],['wait',1.2],
    ['say','','鏡の奥の灯台に、灯りがともった。','光が鏡の海いちめんに広がって、水が、静かに満ちてくる。'],
    ['call',()=>ex1Marble(true)],
    ['say','ミオの声','（ありがとう、ナギ。……これで、向こうの海も、ちゃんと朝になる）','（来年の夏も、灯台の見えるところで、待ってるね）'],
    ['call',()=>ex1Marble(false)],
    ['fade','out'],['call',()=>{mirExit();D3.lamp.visible=false;P.foot=true;P.carry='back';padLabels();}],['cam','off'],['warp',...HOME],['day'],
    // the last day of the holidays: everyone on the beach
    ['fade','out'],['call',()=>{d3Gather(true);if(SAVE.flags.mochi_stay)mochiShow(true);}],['warp',...at(-0.6,1),0],
    ['cam',[BOSS_AT.x-0.5,G(BOSS_AT.x,SHORE+3)+1.8,SHORE+10],[BOSS_AT.x-0.5,G(BOSS_AT.x,SHORE+3)+1.1,SHORE+2],1.2,'cut'],['fade','in'],
    ['say','','そして、夏休みの最後の日。'],
    ['say','sota','ナギねえちゃん、ほんとに帰っちゃうの？','……じゃあ、来年の夏の大会で勝負だからね！ おれ、それまでにキックフリップできるようになっとく！'],
    ['say','nagi','うん。マニュアルも練習しときなよ。'],
    ['say','baker','ほら、こむぎ堂のメロンパンだ。電車の中で食べな。'],
    ['say','natsumi','ナギ、そろそろ電車の時間よ。'],
    ['say','tome','……また来年も、おいで。海街自警団は、ナギの席をあけて待ってるからね。'],
    ['if',{flags:{mochi_stay:1}},[['say','','おもちが、ナギのリュックに鼻をくっつけて、ニャア、と鳴いた。']],[]],
    ['say','nagi','みんな、ありがとう。……この町の夏、ぜんぶ忘れないよ。'],
    ['cam',[BOSS_AT.x,G(BOSS_AT.x,SHORE)+3,SHORE-2],[LH.x,LH.gy,LH.z],0.6],['wait',1.2],
    ['say','','うみまち線の電車が、坂の町を出ていく。','窓の外で、島の灯台が、昼間なのに一度だけ、きらりと光った。'],
    ['say','','――追加ストーリー3「鏡の海」　おしまい。'],
    ['credits'],
    ['set','d3_done'],
    ['fade','out'],['call',()=>{d3Gather(false);mochiShow(false);}],['cam','off'],['warp',...HOME],['fade','in'],
    ['call',()=>toast('ナギの夏は、思い出の中でまだ続いている。鏡の海へは、作戦室からいつでも行ける',true)]];}
// the goodbye on the beach: like the dawn after the last fight (d2Gather), with Sota
function d3Gather(on){const at={tome:[-5,-1.5],natsumi:[-2.5,1.5],baker:[4.5,-1.5],sota:[2,2.6]};
  for(const id in at){const n=NPCS[id];if(!n)continue;
    if(on){if(!n.home)n.home={x:n.x,z:n.z,yaw:n.yaw,y:n.h.g.position.y,mode:n.mode};const x=BOSS_AT.x+at[id][0],z=SHORE+3+at[id][1];n.x=x;n.z=z;n.mode='stand';
      n.h.g.position.set(x,G(x,z),z);n.h.g.rotation.y=Math.atan2(BOSS_AT.x-0.6-x,SHORE+1-z);n.h.g.visible=true;}
    else if(n.home){const o=n.home;n.x=o.x;n.z=o.z;n.mode=o.mode;n.h.g.position.set(o.x,o.y,o.z);n.h.g.rotation.y=o.yaw;delete n.home;}
    Object.assign(n.box,{x0:n.x-n.rad,x1:n.x+n.rad,z0:n.z-n.rad,z1:n.z+n.rad});}}

/* ----- the days between ----- */
const D3_EVENTS=[
  {id:'d3_open',when:{flags:{d2_done:1,d3:0},phase:['day','evening'],test:()=>AREA==='town'&&!URA.on&&!MIR.on},script:[
    ['say','','海を見ていて、ナギは気がついた。','海に映った町が、ほんの少しだけ、ずれている。……映った島の灯台のとなりに、ないはずの灯りが、もうひとつ。'],
    ['call',()=>ex1Marble(true)],
    ['say','ミオの声','（……ナギ。聞こえる？）','（裏海街の海が、鏡になってる。向こうの鏡が、こっちの夏を映しはじめてるの）','（鏡の中に、何かが生まれかけてる。……ナギに、よく似た何か）'],
    ['call',()=>ex1Marble(false)],
    ['say','tome','（無線の声）ナギ、いまのが聞こえたかい。……鏡の海が、さわがしいね。','日が暮れたら、基地の作戦室においで。','……夏休みも、あと少しだね。'],
    ['set','d3'],['call',()=>toast('日が暮れたら、基地の作戦室のばあちゃんに話して、鏡の海へ',true)]]},
  {id:'d3_sota',on:{talk:'sota'},mark:true,when:{min:{d3n:1},flags:{d3_done:0}},script:[['cam','npc','sota',3.4],
    ['say','sota','ねえ、ナギねえちゃん。ゆうべ、夢を見たんだ。','夜の海の上を、ナギねえちゃんがスケボーで走ってた。……でも、顔がまっ黒で、なんだかさみしそうだった。'],
    ['say','sota','……ナギねえちゃん、夏休みが終わったら、帰っちゃうんでしょ？'],
    ['say','nagi','うん。……あと少し。'],
    ['say','sota','そっか。……じゃあ、帰るまでに、マニュアル教えてよ！ 地面で「技」を押すんでしょ？']]},
  {id:'d3_natsumi',on:{talk:'natsumi'},mark:true,when:{min:{d3n:2},flags:{d3_done:0}},script:[['cam','npc','natsumi',3.4],
    ['say','natsumi','ナギ、ずいぶん日に焼けたわね。','……お母さんもね、子どものころ、鏡みたいな夜の海を見たことがあるの。ミオといっしょに。'],
    ['say','natsumi','海に映ったわたしたちは、わたしたちより、ずっと楽しそうに笑ってた。','……思い出って、きっとそういうものなのね。ほんとうより、少しだけまぶしいの。'],
    ['say','nagi','……思い出の、影。']]},
  {id:'d3_kuro',when:{min:{d3n:3},flags:{d3_done:0},test:()=>SAVE.flags.d3last<SAVE.day&&AREA!=='mir'&&!URA.on},script:[
    ['say','','ポケットの無線が、ザザッと鳴った。'],
    ['say','黒崎','（無線の声）海街の。鏡の海の奥に、灯台が映っている。……「裏の灯台」だ。','あれに灯りがともれば、鏡は閉じるはずだ。……今夜が最後になるだろう。'],
    ['say','tome','（無線の声）……最後の夜だね。日が暮れたら、作戦室においで。']]},
];
EVENTS.splice(EVENTS.findIndex(e=>e.id==='dusk'),0,...D3_EVENTS);
// today's aim while the story runs
function d3Goal(f,eve,night){const lab=d3Label().replace('鏡の海へ','鏡の海'),dark=eve||night,hq=AREA==='hq'?'作戦室のばあちゃん':'基地の作戦室のばあちゃん';
  if(!d3Tonight())return '今夜の鏡の海は終わった。ゆっくり休もう';
  const side=d3n()>=1&&!SAVE.seen.d3_sota?'浜辺のソウタくんに話す。':d3n()>=2&&!SAVE.seen.d3_natsumi?'お母さんに話す。':'';
  return dark?`${hq}に話して、${lab}へ`:`${side}日が暮れたら、${hq}に話して${lab}へ`;}
