
/* ---------- the extra story "オーシャンゲート" (free, after the true ending): the lighthouse is lit, and something has noticed
   the town. Odd things happen at night, the black vans come back, Sota goes missing, and everyone — Nagi too — thinks it is
   Oceangate. Only at the end of it does the truth come out (see PROGRESS.md, 追加ストーリーの設定).
   The flag ex1 is how far it has got:
     1  the morning after: the town's odd things to look into (errand x_odd)
     2  that evening the vans and drones are back; the drones fly at the lighthouse — or at the dark in front of it
     3  the next morning Sota is gone; the baker sends Nagi after the van
     4  she has followed it to the iron door by the west tunnel; at night Mio's voice comes through the marble
     5  the next morning the baker sends word: tonight they go in
     6  at night, into the base: past the guards to the monitoring room, the record of 1996, the alarm and the shutters (p5o_base.js)
     7  the rest is still being made ---------- */
// what the night left behind: a torn net on the pier, a scorched lamp on the coast road, black footprints at the crossing
const EX1={props:[],marble:null};
{ const lamp=LAMPS.reduce((b,e)=>Math.abs(e.x+30)<Math.abs(b.x+30)?e:b,LAMPS[0]);EX1.lamp=[lamp.x,lamp.z];
  const dark=new THREE.MeshBasicMaterial({color:'#121214',transparent:true,opacity:0.82,depthWrite:false,polygonOffset:true,polygonOffsetFactor:-2});
  const flat=(geo,x,z,y,r)=>{const m=new THREE.Mesh(geo,dark);m.rotation.set(-Math.PI/2,0,r||0);m.position.set(x,(y==null?G(x,z):y)+0.03,z);world.add(m);EX1.props.push(m);return m;};
  // the net: a heap of greenish mesh with a black, torn hole
  const nx=-78.2,nz=PIER.z1-7,net=new THREE.Mesh(new THREE.SphereGeometry(0.9,8,5,0,TAU,0,Math.PI/2),tm('#5f7a6a',{wireframe:true}));
  net.scale.set(1.3,0.35,1);net.position.set(nx,PIER.y+0.02,nz);world.add(net);EX1.props.push(net);
  const heap=net.clone();heap.material=tm('#3f5a4c');heap.scale.set(1.22,0.3,0.94);world.add(heap);EX1.props.push(heap);flat(new THREE.CircleGeometry(0.45,9),nx+0.2,nz,PIER.y+0.32);
  // the lamp: soot on the pavement round its foot
  flat(new THREE.CircleGeometry(1.5,12),lamp.x,lamp.z,null);flat(new THREE.CircleGeometry(0.9,9),lamp.x+1.1,lamp.z+0.6,null);
  // the footprints: bare feet, walking up to the crossing and stopping at the rails
  for(let k=0;k<9;k++){const x=-2+k*0.62+(k%2?0.18:-0.18),z=TRAM_Z-14+k*0.95;flat(new THREE.CircleGeometry(0.13,7).scale(1,1.9,1),x,z,null,0.55);}
  for(const m of EX1.props)m.visible=false;}
const ex1On=()=>{const s=SAVE.flags.ex1||0;return s>0&&!SAVE.flags.ex1_done;};
function updateEx1(){const on=ex1On()&&!URA.on;for(const m of EX1.props)m.visible=on;
  if(EX1.marble&&EX1.marble.visible){EX1.marble.position.set(P.x,P.y+1.0,P.z);EX1.marble.material.opacity=0.55+0.4*Math.sin(clock*4);}}
function ex1Marble(on){if(!EX1.marble)EX1.marble=glow('#7fd0ff',0,0,0,1.1);EX1.marble.visible=on;}
// Sota is gone from the beach while he is missing; Mio is no longer on the pier once she has gone into the light
{ const s0=NPCS.sota.show;NPCS.sota.show=()=>!((SAVE.flags.ex1||0)>=3&&!SAVE.flags.sota_back)&&(!s0||s0());
  const m0=NPCS.mio.show;NPCS.mio.show=()=>!SAVE.flags.ending_true&&m0();}
function ex1Quests(){return[
  {id:'x_odd',title:'町の異変',giver:'tome',when:{test:()=>false},
   steps:[{type:'place',at:[-78.2,PIER.z1-7],label:'調べる　やぶれた網',verb:'調べる',hint:'桟橋の先、やぶれた網を調べる',text:['釣りのおじさんの網が、ずたずたに裂けている。','切り口が、黒くこげたように固まっている。……さわると、ひやりと冷たい。']},
          {type:'place',at:EX1.lamp,label:'調べる　すすけた街灯',verb:'調べる',hint:'海岸通りの、すすけた街灯を調べる',text:['海岸通りの街灯の根もとが、黒くすすけている。','見上げると、街灯のガラスが割れていた。……外からじゃない。内側から、はじけたみたいに。']},
          {type:'place',at:[1,TRAM_Z-10],label:'調べる　黒い足あと',verb:'調べる',hint:'海の見える踏切の手前、黒い足あとを調べる',text:['踏切の手前に、黒い足あとが続いている。','はだしの、大人の足あと。……線路の手前で、ふっと消えていた。']},
          {type:'talk',to:'tome',hint:'トメばあちゃんに知らせる',text:['……そうかい。網も、街灯も、足あとも。','30年前の夏にも、こんなことがあった気がするよ。……いや、気のせいだね。','ナギ、夕方からは、あんまり出歩くんじゃないよ。']}],reward:300}];}
// today's aim while the extra story runs (storyGoal in p5d_events.js asks here first)
function ex1Goal(f,eve,night,home){const s=f.ex1;
  if(s===1)return qs('x_odd').state<2?null:eve||night?null:'町の異変は、ばあちゃんに知らせた。夕方まで待つ（ばあちゃんに話すと夕方まで休める）';
  if(s===3)return 'こむぎ堂の主人に話す';
  if(s===4)return night?'夜の桟橋の先へ行ってみる':'夜になったら、桟橋の先へ行ってみる（ばあちゃんに話すと夕方まで休める）';
  if(s===5)return eve||night?home:null;
  if(s===6)return eve||night?'こむぎ堂の主人に話す':'日が暮れたら、こむぎ堂の主人に話す（ばあちゃんに話すと夕方まで休める）';
  if(s===7)return '（追加ストーリー「オーシャンゲート」のつづきは、ただいま制作中です）';
  return null;}
function ex1Dark(f){if(f.ex1===4)return '暗くなってきた。桟橋の先へ行ってみよう';if(f.ex1===6)return '暗くなってきた。こむぎ堂の主人のところへ行こう';return null;}
const EX1_EVENTS=[
  {id:'x1_morning',when:{minDay:8,flags:{ending_true:1,ex1:0}},script:[
    ['if',{test:()=>Math.hypot(P.x-HOME[0],P.z-HOME[1])>12},[['fade','out'],['warp',...HOME],['fade','in']]],
    ['cam','npc','tome',3.4],
    ['say','tome','おはよう、ナギ。……ゆうべは、町じゅう停電してねえ。真っ暗だったよ。'],
    ['say','natsumi','夜中に、外で犬がずっと吠えてたの。……灯台の光だけは、ちゃんと回ってたけど。'],
    ['say','tome','釣りのおじさんも、網がずたずたにされたって、朝からさわいでてね。'],
    ['say','natsumi','ナギ、これ。'],['say','','お母さんは、青いビー玉をナギの手にのせた。'],
    ['say','natsumi','ミオのビー玉。……なんだか、ナギが持っていたほうがいい気がするの。'],
    ['set','x_marble'],
    ['say','tome','なんだか、いやな感じがするねえ。ナギ、町の様子を見てきてくれるかい。'],
    ['set','ex1',1],['cam','off'],['quest','x_odd']]},
  {id:'x1_evening',when:{flags:{ex1:1},quest:{x_odd:2},phase:['evening','night']},script:[
    ['ogscene',true],
    ['cam',[188,G(188,COAST_Z)+2.2,COAST_Z-6],[200,G(200,COAST_Z)+1.2,COAST_Z+1.2],1.2,'cut'],
    ['say','','夕方。海岸トンネルの前に、黒いバンが止まっていた。','黒いスーツの男たち。……町から消えたはずの、オーシャンゲートだ。'],
    ['say','','ブウウン……。頭の上を、監視ドローンが何機も飛んでいく。','町のスピーカーから、低い声が流れた。'],
    ['say','黒崎','（スピーカーの声）海街のみなさん。今夜から当分のあいだ、日が暮れたら外に出ないでください。','……くり返します。夜は、外に出ないでください。'],
    ['say','nagi','（黒崎……！ また、灯台をねらってるんだ）'],
    ['cam','off'],['ogscene',false],
    ['fade','out'],['time',20.4,0],['warp',-40,COAST_Z+2.2,Math.PI/2],['fade','in'],
    ['say','','夜。ドローンの群れが、海の上を島のほうへ飛んでいく。'],
    ['say','baker','（無線の声）ナギちゃん、聞こえるか。やつら、灯台に向かってる。','おれの古い道具を持っていけ。……撃ち落とすぞ！'],
    ['drones',{total:8,boss:1,title:'灯台へ向かうドローンを落とせ'}],
    ['cam',[-46,G(-46,COAST_Z)+3.2,COAST_Z+5],[160,30,700],1.2,'cut'],
    ['say','','最後の一機が落ちる、ほんの少し前――ナギは、見てしまった。','ドローンが撃っていたのは、灯台じゃなかった。','灯台の手前の、何もない海の暗がりだった。'],
    ['say','nagi','（……いま、暗がりが、動いた？）','（……気のせい、だよね）'],
    ['set','x_saw_dark'],['set','ex1',2],
    ['wait',0.5],['fade','out'],['cam','off'],['warp',...HOME],['day']]},
  {id:'x2_morning',when:{flags:{ex1:2}},script:[
    ['cam','npc','tome',3.4],
    ['say','','朝。坂の下のほうから、大きな声が聞こえてきた。'],
    ['say','ソウタの母','トメさん！ ソウタが……ソウタがいないの！ 朝起きたら、布団がからっぽで……！'],
    ['say','ソウタの母','ゆうべ、家の前に黒いバンが止まってたって、近所の人が……！'],
    ['say','tome','……落ち着いて。町のみんなで探そう。'],
    ['say','nagi','（黒いバン……オーシャンゲートだ。ソウタくんを、どうして……）'],
    ['set','ex1',3],['cam','off'],['toast','こむぎ堂の主人に話そう',true]]},
  {id:'x2_baker',on:{talk:'baker'},mark:true,when:{flags:{ex1:3}},script:[
    ['say','baker','……ソウタが？ 黒いバンが、家の前に？','（主人は、エプロンをはずして、きちんとたたんだ）','もう黙っていられん。黒崎を止める。'],
    ['say','baker','さっき、なか通りの東に、黒いバンが止まってるのを見た。','ナギちゃん、あれのあとをつけて、やつらの巣を見つけてくれ。'],
    ['say','baker','いいか。近づきすぎるな。バンが止まると、男がひとり降りて、うしろを見る。','そのときは、家や車のかげに隠れろ。スケボーの音は、近くだと気づかれるぞ。'],
    ['ask','nagi','（どうする？）',[['あとをつける',[]],['……行ってくる',[]]]],
    ['fade','out'],['cam','off'],['trail'],
    ['cam',[OG_DOOR.x+9,OG_DOOR.y+2.4,OG_DOOR.z+9],[OG_DOOR.x,OG_DOOR.y+1.3,OG_DOOR.z],1.2,'cut'],
    ['say','','バンは、海岸トンネルの手前で止まった。','男たちは、トンネルの横の石垣にある、さびた鉄の扉の中へ消えていった。'],
    ['say','nagi','（あんなところに、扉……？ 「関係者以外立入禁止」……）','（この上は、電波塔の山だ）'],
    ['say','baker','（無線の声）よくやった、ナギちゃん。そこが、やつらの巣だ。','今日は動くな。乗りこむのは、準備をしてからだ。'],
    ['call',trailDone],
    ['say','nagi','（ソウタくん……。ミオなら、なにか知ってるかな）','（夜になったら、桟橋の先へ行ってみよう）'],
    ['set','ex1',4],['cam','off']]},
  {id:'x2_mio',on:{near:[-80,331,7]},when:{flags:{ex1:4},phase:'night'},script:[
    ['warp',-80,331,0.55],['cam',[-83.5,PIER.y+2.2,326.5],[-62,PIER.y+2,362],1.5,'cut'],
    ['say','','夜の桟橋の先。灯台の光が、ゆっくり海をなでていく。'],
    ['call',()=>ex1Marble(true)],
    ['say','','ポケットの中で、ビー玉がかすかに光った。青く、心臓の音みたいに。'],
    ['say','ミオの声','（……ナギ……きこえる……？）'],
    ['say','nagi','ミオ!? どこにいるの？'],
    ['say','ミオの声','（ソウタくんは……向こう側に……）','（黒い服の人たちじゃ、な……ザザッ……）'],
    ['say','','ザザザ……。声は、波の音にまぎれて消えた。ビー玉の光も、しずかに消えた。'],
    ['call',()=>ex1Marble(false)],
    ['say','nagi','向こう側……？ ソウタくんは、オーシャンゲートに連れていかれたんじゃ……ないの？'],
    ['set','ex1',5],['call',()=>{SAVE.flags.x_d=SAVE.day;}],['cam','off'],['toast','ばあちゃんに話して、家に帰ろう',true]]},
  {id:'x3_morning',when:{flags:{ex1:5},test:()=>SAVE.day>(SAVE.flags.x_d||0)},script:[
    ['cam','npc','tome',3.4],
    ['say','tome','おはよう、ナギ。……ソウタは、まだ見つからないよ。町の男の人たちが、夜通し浜を探してくれたんだけどねえ。'],
    ['say','natsumi','ナギ、こむぎ堂のおじさんから伝言よ。「今夜、迎えに行く。日が暮れたら、店に来てくれ」って。','……ナギ、何をしようとしてるの？'],
    ['ask','nagi','（どうする？）',[
      ['ソウタくんを、探しに行く',[['say','natsumi','……そう。お母さんも30年前、きっと同じ顔をしてたのね。','気をつけて。ぜったい、帰ってくるのよ。']]],
      ['……なんでもない',[['say','natsumi','うそ。顔に書いてある。……気をつけてね。']]]]],
    ['set','ex1',6],['cam','off'],['toast','日が暮れたら、こむぎ堂の主人に話そう',true]]},
  {id:'x3_baker',on:{talk:'baker'},mark:true,when:{flags:{ex1:6},phase:['evening','night']},script:[
    ['say','baker','来たか。……ソウタは、まだ見つからん。','今夜、やつらの巣に乗りこむ。おれは入口で見張って、無線で中を案内する。'],
    ['say','baker','中には見張りがいる。やつらに見えるのは、前のほうだけだ。床に落ちてる、うすい明かりの中だな。','かどの向こうや、箱のかげは見えん。ただし、スケボーの音は近いと聞こえるぞ。'],
    ['ask','nagi','（行く？）',[['行こう',[]],['……うん',[]]]],
    ['fade','out'],['time',21,0],['cam','off'],['warp',OG_DOOR.x+2,OG_DOOR.z+3,Math.PI],
    ['cam',[OG_DOOR.x+7,OG_DOOR.y+2.4,OG_DOOR.z+8],[OG_DOOR.x,OG_DOOR.y+1.3,OG_DOOR.z],1.2,'cut'],['fade','in'],
    ['say','','夜の海岸トンネル。主人が細い針金を鍵穴に差しこむと、鉄の扉がカチリと開いた。'],
    ['fade','out'],['cam','off'],['warp',BASE_X+BASE_START[0],BASE_START[1],BASE_START[2]],['fade','in'],
    ['say','','扉の向こうは、山の中をくりぬいた、長い通路だった。','ブウン……と、どこかで機械がうなっている。'],
    ['say','baker','（無線の声）いいか、いちばん奥の監視室をめざせ。やつらが何を見張ってるのか、たしかめるんだ。'],
    ['basesneak'],
    ['cam',[BASE_X+117.5,1.9,-28],[BASE_X+120.5,1.5,-33.5],1.2,'cut'],
    ['say','','監視室。壁いっぱいのモニターに、町が映っていた。','灯台、桟橋、神社……そして、海の上の、何もない暗がり。'],
    ['say','','机の上に、古いファイルが一冊。表紙に「境界監視記録」とある。'],
    ['say','','「1996年8月15日 23時04分　境界侵入を確認。」','「海街在住の少女一名、行方不明。」','「同夜、灯台の灯り消失。結界塔の建設を急ぐこと。」'],
    ['say','nagi','1996年……30年前の、あの夜……。少女って、ミオのこと？','（どうして、オーシャンゲートがミオのことを……）'],
    ['say','','そのとき――ウウウウウウ！ 基地じゅうに、警報が鳴りひびいた。'],
    ['say','黒崎','（スピーカーの声）侵入者だ。全隔壁、閉鎖。','……また、あのパン屋の差し金か。'],
    ['say','baker','（無線の声）ナギちゃん、見つかった！ シャッターが下りる前に、東の通路から外へ出ろ！'],
    ['cam','off'],
    ['baserun'],
    ['cam',[BASE_X+BASE_END-6,2.2,10],[BASE_X+BASE_END+6,1.6,15],1.2,'cut'],
    ['say','','最後のシャッターの下をすべりぬけると、夜の山の風が顔に当たった。','電波塔の真下。赤い光は消えたまま、鉄骨だけが夜空にそびえている。'],
    ['say','','バラバラバラ……！ 頭の上で、大きなプロペラの音がした。'],
    ['say','黒崎','（スピーカーの声）……逃がすと思うか。'],
    ['set','ex1',7],['toast','追加ストーリー「オーシャンゲート」のつづきは、ただいま制作中です',true],
    ['fade','out'],['cam','off'],['warp',...HOME],['day']]},
];
EVENTS.splice(EVENTS.findIndex(e=>e.id==='dusk'),0,...EX1_EVENTS);
