/* ---------- the end of the second story: with the five children home, the gate under the sea opens and its master comes.
   The morning after the fifth child Kurosaki calls: Oceangate will mend the radio mast and raise the barrier again, but not
   before dawn. That night, from the command table, the last fight: the shadow drones and the shadows on the coast road, then
   the master rising in the bay, and round it Mio's ring of rails of light (the fight itself is in p5y_giant.js): ridden round,
   the ring of light wears it down, and the third time it reels the lighthouse's beam finishes it. Dawn: the mast lit red again, Mio and the children going home into the light, Natsumi meeting her
   at last (d2_done). Back home that morning, the third story begins at once (d3_open in p5w_d3.js). ---------- */
const BOSS_AT={x:-50,z:352},BOSS_S=30;
// the master as seen: its figure and its three red eyes (BOSS.y is where it is rising or sinking to)
const BOSS={g:null,eyes:[],y:0};
function bossBuild(){if(BOSS.g)return;const h=makeHuman(SHADE);h.g.scale.setScalar(BOSS_S);world.add(h.g);BOSS.g=h;
  BOSS.eyes=[[0,0,32],[-0.09,-0.06,10],[0.09,-0.06,10]].map(([dx,dy,s])=>{const e=glow('#ff3020',0,0,0,s);e.userData.d=[dx,dy];return e;});h.g.visible=false;
  for(const L of h.legs)for(const k of ['th','kn','ft'])if(L[k])L[k].visible=false;}   // only from the waist up: it stands in the sea
function bossShow(on,y){bossBuild();const g=BOSS.g.g;g.visible=on;for(const e of BOSS.eyes)e.visible=on;if(!on)return;g.position.set(BOSS_AT.x,y==null?SEA_Y-27:y,BOSS_AT.z);g.rotation.y=Math.PI;BOSS.y=g.position.y;}
function bossPose(dt){if(!BOSS.g||!BOSS.g.g.visible)return;const g=BOSS.g.g;poseHuman(BOSS.g,'stand',dt,{});g.position.y+=(BOSS.y-g.position.y)*Math.min(1,dt*1.5);
  const s=g.scale.x;BOSS.eyes.forEach((e,k)=>{const [dx,dy]=e.userData.d;e.position.set(g.position.x+dx*s,g.position.y+(1.62+dy)*s,g.position.z-0.3*s);e.material.opacity=k?0.6+0.3*Math.sin(clock*4+k):0.85+0.15*Math.sin(clock*6);});}
const bossEye=()=>BOSS.eyes[0].position.clone();
function updateBoss(dt){bossPose(dt);}
// the people on the beach at dawn: Mio (shown again, off the pier), Natsumi, grandma, the baker, Kurosaki
const D2END={mio:false};
{ const m0=NPCS.mio.show;NPCS.mio.show=()=>D2END.mio||m0(); }
function d2Gather(on){const at={tome:[-5,-1.5],natsumi:[-2.5,1.5],baker:[4.5,-1.5],mio:[1.6,3.4]};
  for(const id in at){const n=NPCS[id];
    if(on){if(!n.home)n.home={x:n.x,z:n.z,yaw:n.yaw,y:n.h.g.position.y,mode:n.mode};const x=BOSS_AT.x+at[id][0],z=SHORE+3+at[id][1];n.x=x;n.z=z;n.mode='stand';
      n.h.g.position.set(x,G(x,z),z);n.h.g.rotation.y=id==='mio'?Math.PI:Math.atan2(BOSS_AT.x-x,SHORE+7-z);}
    else if(n.home){const o=n.home;n.x=o.x;n.z=o.z;n.mode=o.mode;n.h.g.position.set(o.x,o.y,o.z);n.h.g.rotation.y=o.yaw;delete n.home;}
    Object.assign(n.box,{x0:n.x-n.rad,x1:n.x+n.rad,z0:n.z-n.rad,z1:n.z+n.rad});}
  D2END.mio=on;}
function d2Lights(on){if(!D2END.lights)D2END.lights=Array.from({length:14},()=>glow('#bfefff',0,0,0,0.8));
  D2END.lights.forEach((l,k)=>{l.visible=on;l.userData.t=k*0.4;});D2END.up=on;}
// Omochi at Mio's feet on the beach (the cat of 裏海街's tunnel mouth); gone with her, the cat by the boats is gone too
function mochiShow(on){omochi.g.visible=on;if(!on)return;const x=BOSS_AT.x+2.6,z=SHORE+5.6;omochi.g.position.set(x,G(x,z)+0.02,z);omochi.g.rotation.y=Math.PI*0.8;}
const BEACH_CAT=CATS.find(c=>Math.abs(c.g.position.x+108.5)<0.1);
function updateD2End(dt){if(SAVE.flags.mochi_gone&&BEACH_CAT)BEACH_CAT.g.visible=false;if(omochi.g.visible&&!URA.on)poseCat(omochi,dt,false);if(!D2END.up)return;D2END.lights.forEach((l,k)=>{const t=(l.userData.t+=dt*0.35),x=BOSS_AT.x+Math.sin(k*2.3)*7,z=SHORE+8+Math.cos(k*1.7)*4;
  l.position.set(x+Math.sin(t*2+k)*0.6,G(x,Math.min(z,SHORE))+0.8+(t%6)*2.2,z);l.material.opacity=Math.max(0,1-(t%6)/6);});}
const FINAL_EVENTS=[
  {id:'d2_c1',when:{flags:{ex1_done:1,d2c:0},test:()=>(d2().nest||0)>=KIDS&&d2().last<SAVE.day&&!URA.on},script:[
    ['say','','朝。ポケットの無線が、ザザッと鳴った。'],
    ['say','黒崎','（無線の声）……聞こえるか、海街の。海の底で、門が開きかけている。','核をこわされた異界の者どもが、門の向こうの「主」を呼んでいる。……今夜、やつが来るぞ。'],
    ['say','黒崎','（無線の声）オーシャンゲートは、電波塔を直して結界を張りなおす。だが、それには夜明けまでかかる。'],
    ['say','tome','（無線の声）……それまで、わたしたちで町を守りきるってことだね。'],
    ['call',()=>ex1Marble(true)],
    ['say','ミオの声','（ナギ……あの主がいるかぎり、向こうの子たちは帰れない。わたしも）','（今夜、終わらせよう。わたしも、いっしょに戦う）'],
    ['call',()=>ex1Marble(false)],
    ['set','d2c'],['call',()=>toast('日が暮れたら、作戦室のばあちゃんに話して、最後の戦いへ',true)]]},
];
EVENTS.splice(EVENTS.findIndex(e=>e.id==='dusk'),0,...FINAL_EVENTS);
// the last night, from the command table
function finalScript(){const N=nightPlan(d2().night+4);return[
  ['fade','out'],['call',()=>{applyD2();EX1.still=true;D2_last();}],['time',21.5,0],['warp',TRUTH.x+4,TRUTH.z,0],['fade','in'],
  ['say','tome','（無線の声）みんな、配置についたね。','オーシャンゲートが電波塔を直すまで、なんとしても持ちこたえるよ！'],
  ['say','黒崎','（無線の声）こちら黒崎。全機、海街自警団を援護しろ。……今夜だけは、命令はひとつだ。町を守れ。'],
  ['drones',{total:Math.max(12,N.drones),boss:1,title:'最後の夜：影のドローン'}],
  ['say','baker','（無線の声）上は片づいた！ ナギちゃん、浜だ！'],
  ['call',()=>defendP({total:Math.max(24,N.shadows),alive:Math.max(7,N.alive),spd:Math.max(0.4,N.spd)})],
  ['fade','out'],['warp',(PIER.x0+PIER.x1)/2,PIER.z1-40,0],['call',rideNow],['call',()=>bossShow(true,SEA_Y-40)],['time',23.5,0],
  ['cam',[BOSS_AT.x+14,G(BOSS_AT.x,SHORE)+2.4,SHORE+1],[BOSS_AT.x,SEA_Y+22,BOSS_AT.z],1.2,'cut'],['fade','in'],
  ['call',()=>{BOSS.y=SEA_Y-27;}],['wait',3],
  ['say','','海が、まっぷたつに割れた。','山よりも大きな影が、ゆっくりと立ち上がる。……赤い目が、三つ。'],
  ['say','黒崎','（無線の声）主だ……！ 電波塔は、まだか！'],
  ['say','master','（無線の声）あと少しだ！ 夜明けまで、もたせてくれ！'],
  ['call',()=>ex1Marble(true)],
  ['say','ミオの声','（ナギ、見て。あいつのまわりに、光のレールをかけたよ。桟橋の先から跳び乗って）','（レールで、あいつのまわりをぐるっと回るの。光の輪でしめつけて、三回よろけさせたら、わたしが灯台の光をあいつに向ける）'],
  ['call',()=>ex1Marble(false)],
  ['cam','off'],
  ['call',giantP],
  // it sinks
  ['cam',[BOSS_AT.x+14,G(BOSS_AT.x,SHORE)+2.4,SHORE+1],[BOSS_AT.x,SEA_Y+18,BOSS_AT.z],1.2,'cut'],
  ['call',()=>{BOSS.y=SEA_Y-70;}],['wait',3.5],
  ['say','','三度目の光につらぬかれて、主は、声にならない声をあげた。','そして、門といっしょに、海の底へしずんでいった。'],
  ['set','mast_lit'],['say','','……そのとき、山の上の電波塔に、赤い灯りがともった。'],
  ['say','master','（無線の声）結界、張りなおした！ ……門が、閉じていく！'],
  ['call',()=>bossShow(false)],
  // dawn
  ['fade','out'],['call',()=>{d2Gather(true);ex1Kurosaki(false);EX1.still=true;d2Lights(true);}],['time',5.9,0],['warp',BOSS_AT.x-0.6,SHORE+1,0],
  ['cam',[BOSS_AT.x+1.5,G(BOSS_AT.x,SHORE)+2,SHORE-4.5],[BOSS_AT.x-0.5,G(BOSS_AT.x,SHORE)+1.1,SHORE+4],1.2,'cut'],['fade','in'],
  ['say','','夜が明けた。','波打ちぎわから、小さな光がいくつも、白みはじめた空へのぼっていく。'],
  ['say','mio','……ナギ。'],
  ['say','nagi','ミオ！ ……ほんとうに、ミオだ。'],
  ['say','mio','核にとじこめられてた子たち、みんな、光のほうへ帰っていくよ。……ナギの灯りのおかげ。'],
  ['say','natsumi','……ミオ？'],
  ['say','mio','ナツミちゃん。……おとなになったね。'],
  ['say','natsumi','ミオ……ごめんね。あの夜、いっしょに行ってあげられなくて。ずっと、ずっと……'],
  ['say','mio','ううん。ナツミちゃんが、ナギをこの町に連れてきてくれた。だから、わたしは帰れるの。'],
  ['say','mio','わたしも、みんなといっしょに行くね。……もう、迷子じゃないから。'],
  ['say','mio','ナギ。ビー玉、ずっと持っててね。……灯台の灯りが見えるところに、わたしはいるよ。'],
  ['call',()=>mochiShow(true)],
  ['cam',[BOSS_AT.x+4.1,G(BOSS_AT.x,SHORE)+1.3,SHORE+2.8],[BOSS_AT.x+1.8,G(BOSS_AT.x,SHORE)+0.8,SHORE+6.4],1.2,'cut'],
  ['say','','足もとで、ニャア、と声がした。白い猫が、ミオを見上げている。'],
  ['say','mio','おもち！ ……ずっと、ナギのそばにいてくれたんだね。','あの夜、わたしについてきて、それからずっと、こっちとあっちを行ったり来たりしてたの。……ナギを、わたしのところまで連れてきてくれた。'],
  ['say','natsumi','……やっぱり、あのときのおもちだったのね。'],
  ['ask','mio','おもちは、どうしたい？',[
    ['ミオといっしょに行く',[['set','mochi_gone'],['say','','おもちは、ミオの腕の中にぴょんと飛びこんだ。'],['say','mio','うん。いっしょに帰ろう、おもち。']]],
    ['ナギのそばに残る',[['set','mochi_stay'],['say','','おもちは、ナギの足にすりよって、ミオを見上げた。'],['say','mio','そっか。……ナギのこと、たのんだよ、おもち。']]]]],
  ['say','','ミオは、ふわりと笑って、朝の光の中にとけていった。'],
  ['call',()=>{D2END.mio=false;if(SAVE.flags.mochi_gone)mochiShow(false);}],
  ['cam',[BOSS_AT.x+1.5,G(BOSS_AT.x,SHORE)+2,SHORE-4.5],[BOSS_AT.x-0.5,G(BOSS_AT.x,SHORE)+1.1,SHORE+4],1.2,'cut'],['wait',1.5],
  ['say','tome','……行ったね。'],
  ['say','baker','黒崎のやつ、「借りは返した」だとさ。……素直じゃないね。'],
  ['say','tome','異界の門は閉じた。でも、灯台の灯りがあるかぎり、また何かが寄ってくるかもしれない。','海街自警団は、これからもこの町を守るよ。……ナギ、あんたもね。'],
  ['say','nagi','うん。……この町の夏を、守るよ。'],
  ['say','','――追加ストーリー2「海街自警団」　おしまい。'],
  ['credits'],
  ['set','d2_done'],
  ['fade','out'],['call',()=>{d2Gather(false);d2Lights(false);mochiShow(false);EX1.still=false;ex1Kurosaki(false);}],['cam','off'],['warp',...HOME],['day']];}
