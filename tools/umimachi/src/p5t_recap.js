/* ---------- 「これまでの物語」 in the menu: the story so far, a short page for every part the player has been through, in the
   order of the story (only what has been seen, so nothing ahead is given away). Each part: the heading of its section, a
   title, when it shows, and the text. ---------- */
const RECAP=[
  {sec:'本編',t:'1日目　坂の町',on:f=>SAVE.seen.d1_open||SAVE.seen.d1_tome,text:[
    '夏休み。ナギは、うみまち線の終点の坂の町に住む、トメばあちゃんの家にやってきた。',
    '夕方の桟橋の先で、白いワンピースの女の子に出会う。強い風が吹いて目をつぶると、女の子はもういなかった。',
    'その夜、西の山の電波塔が赤く点滅して、ラジオの雑音のような音が聞こえた。']},
  {sec:'本編',t:'2日目　30年前の夏',on:f=>SAVE.seen.d2_mio,text:[
    '桟橋の女の子は、ミオと名のった。「30年前の夏の夜、あの灯台の灯りが消えたの」',
    'ばあちゃんの話では、その夜、町の子がひとりいなくなって、とうとう見つからなかった。ナギのお母さんも、あのころはこの町の子だった。',
    f=>f.saw_van||f.heard_og?'町には、窓の真っ黒なバンが走っている。リゾートを建てたいという会社「オーシャンゲート」の車らしい。':null,
    f=>f.met_mochi?'浜のボートのそばで、白い猫の「おもち」に会った。おもちは、西のトンネルのほうをじっと見つめていた。':null]},
  {sec:'本編',t:'3日目　扉の夜',on:f=>SAVE.seen.d3_mio||f.route||f.ending_calm||f.ending_horror||f.ending_org,text:[
    '浜のソウタくんに、夏祭りのスケボー大会にさそわれた。こむぎ堂の主人は「黒崎って男には近づくな」と言う。',
    'ミオ「今夜、また電波塔が鳴るよ。そのとき、町のどこかで扉が開くの。……どこへ行っても、最後はきっとあの灯台につながってる」',
    'その夜、ナギは三つの道の前に立った。']},
  {sec:'三つの道',t:'のほほんルート「なつやすみ帳」',on:f=>f.ending_calm,text:[
    'ナギはそのまま眠り、町の夏祭りの準備を手伝った。スケボー大会では、見晴らし台から桟橋の先まで坂を下った。',
    '花火の夜、空に現れたオーシャンゲートの監視ドローンを、こむぎ堂の主人の「昔の仕事道具」で撃ち落とした。',
    '花火を見上げるミオが、となりにいた。ばあちゃんにたのまれて、ナギは「海街の配達係」になった。']},
  {sec:'三つの道',t:'ホラールート「トンネルの向こう」',on:f=>f.ending_horror,text:[
    'おもちを追って西のトンネルを抜けると、色のない、霧の海街――裏海街だった。',
    '顔のない影の住人をかわして、ミオの残したものを見つけた。若いころのお母さんとミオの写真、青いビー玉、そして日記。「今夜、電波塔が鳴ったら、トンネルの向こうへ行ってみる」',
    '大きな影に追われて、トンネルへ逃げ帰った。夜明けの桟橋で、ミオは言った。「灯りがもう一度ともったら、わたしも帰れるのかもしれない」']},
  {sec:'三つの道',t:'悪の組織ルート「シーサイド・コンスピラシー」',on:f=>f.ending_org,text:[
    '黒いバンを追って、オーシャンゲートが灯台をふき飛ばそうとしていることを知った。',
    'こむぎ堂の主人は、昔ある組織のエージェントだった。監視ドローンを落とし、ソウタくんたちの探偵団と証拠を集めた。',
    '起爆装置を積んだバンを、スケボーで追いつめた。灯台は守られた。けれど、その灯りがともらない理由は、まだだれも知らない。']},
  {sec:'真ルート',t:'真ルート「灯台」',on:f=>f.ending_true,text:[
    'ナギは、お母さんから預かっていた手紙をばあちゃんにわたした。お母さんは30年、ミオがいなくなった夜のことで、自分を責めていた。',
    '灯台の灯り守りは、ナギのじいちゃんだった。あの夜、ミオを探しに出て、灯りをともせなかった。ばあちゃんは、じいちゃんの形見の鍵をナギにたくした。',
    '町の五つの灯りを集め、釣りのおじさんの船で島へ。30年ぶりに、灯台に灯りがともった。',
    'ミオは光の中で言った。「ナツミに伝えて。ナツミのせいじゃないよって」「向こうには、まだ帰れない子たちがいるの。わたしは、もう少しだけ、あっちに残る」',
    '次の朝、お母さんが町に帰ってきた。']},
  {sec:'追加ストーリー1「オーシャンゲート」',t:'町の異変',on:f=>(f.ex1||0)>=2,text:[
    '灯台がともってしばらくたったある夜、町じゅうが停電した。次の朝、お母さんは、ミオの青いビー玉をナギにわたした。',
    'やぶれた網、内側からはじけた街灯、踏切で消える黒い足あと。夕方、黒いバンが戻ってきて、黒崎のスピーカーが「夜は外に出ないで」と流れた。',
    '灯台へ向かうドローンを撃ち落とした。……ドローンが撃っていたのは、灯台の手前の、何もない暗がりだった。']},
  {sec:'追加ストーリー1「オーシャンゲート」',t:'ソウタくんが消えた',on:f=>(f.ex1||0)>=3,text:[
    '朝、ソウタくんがいなくなった。家の前に黒いバンが止まっていたという。',
    f=>(f.ex1||0)>=4?'こむぎ堂の主人にたのまれてバンのあとをつけると、西のトンネルの横の、鉄の扉にたどりついた。':null,
    f=>(f.ex1||0)>=5?'夜の桟橋で、ビー玉が光った。ミオの声「ソウタくんは、向こう側に……黒い服の人たちじゃ、な……」':null]},
  {sec:'追加ストーリー1「オーシャンゲート」',t:'基地への潜入',on:f=>(f.ex1||0)>=7,text:[
    'こむぎ堂の主人の案内で、電波塔の山の中のオーシャンゲートの基地へしのびこんだ。',
    '監視室には、1996年8月15日の「境界監視記録」があった。少女一名、行方不明。同じ夜、灯台の灯りが消えた。',
    '警報の中、シャッターの下りる通路をぬけて外へ。見晴らし台から、黒崎の大型ドローンを撃ち落とした。']},
  {sec:'追加ストーリー1「オーシャンゲート」',t:'本当のこと',on:f=>(f.ex1||0)>=8,text:[
    '黒崎「子どもなど、さらっておらん」。霧の中から、赤い目の影――異界の者が現れた。',
    '30年前にミオを連れていったのは、異界の者だった。電波塔は町を隠す結界。ナギのともした灯台の灯りが、向こうとこちらをつなぐ道を開いた。オーシャンゲートが灯台を壊そうとしたのは、道を開かせないためだった。',
    'ばあちゃんと商店街の人たちは、30年前に町を守っていた「海街自警団」。こむぎ堂の主人は元オーシャンゲートで、灯台を守るために組織を抜けていた。',
    'ミオの声「ナギのせいじゃないよ。ソウタくんは裏海街にいる。わたしが道を教える」']},
  {sec:'追加ストーリー1「オーシャンゲート」',t:'裏海街と長い夜',on:f=>f.ex1_done,text:[
    'ばあちゃんから、灯台の灯りを分けた自警団のランタンをもらった。',
    'ミオの青い光を追って裏海街の浜へ。ソウタくんを見つけ、大きな影に追われながら、トンネルまで手を引いて走った。',
    '海岸通りで、町のみんなと影を追い返した。海から立ち上がった巨大な影は、灯台の光につらぬかれて沈んだ。',
    '夜明け。黒崎「次は、もっと大きなものが来る」。ばあちゃんは、東の山の岩の扉を開けた。「山の中に、わたしたちの基地がある」']},
  {sec:'追加ストーリー2「海街自警団」',t:'自警団の基地',on:f=>f.d2,text:[
    '岩の扉の奥は、山をくりぬいた洞窟の基地だった。武器庫、鍛錬場、灯りの工房、通信室、作戦室。',
    '夜ごとに裏海街へ出撃して、影の核をこわす日々が始まった。',
    f=>(SAVE.d2&&SAVE.d2.nest)?`スケボーで裏海街に出撃して、光の線で影の核をこわした。閉じこめられていた子どもが、${SAVE.d2.nest}人、光のほうへ帰っていった。`:null]},
  {sec:'追加ストーリー2「海街自警団」',t:'異界の主',on:f=>f.d2c,text:[
    '子どもたちがみんな帰ってくると、海の底の門が開きかけた。黒崎「今夜、主が来る。結界を張りなおすまで、夜明けまでかかる」',
    f=>f.d2_done?'最後の夜。湾に立ち上がった異界の主を、灯台の光で三度つらぬいた。電波塔に赤い灯りがともり、門は閉じた。':null]},
  {sec:'追加ストーリー2「海街自警団」',t:'夜明け',on:f=>f.d2_done,text:[
    '夜明けの浜で、閉じこめられていた子どもたちの光が空へのぼっていった。',
    'ミオとお母さんは、30年ぶりに会えた。おもちは、30年前からミオの猫だった。',
    f=>f.mochi_gone?'ミオは「もう、迷子じゃないから」と笑って、おもちといっしょに朝の光の中へ帰っていった。':'ミオは「もう、迷子じゃないから」と笑って、朝の光の中へ帰っていった。おもちは、ナギのそばに残った。',
    '海街自警団は、これからもこの町を守る。']},
  {sec:'追加ストーリー3「鏡の海」',t:'鏡に映る夏',on:f=>f.d3,text:[
    '夏休みも終わりが近づいたころ、海に映った町が、少しずれて見えた。ミオの声「裏海街の海が鏡になって、こっちの夏を映しはじめてる」',
    f=>f.d3n>=1?'鏡の海の夜明け、ナギそっくりの黒い影が、スケボーで走っていった。ナギのキックフリップを、そっくりまねして。':null,
    f=>f.d3n>=2?'映し身は、ナギの技をまねして、光の線を消していく。まるで、いっしょに遊びたがっているみたいに。':null]},
  {sec:'追加ストーリー3「鏡の海」',t:'裏の灯台',on:f=>f.d3n>=3,text:[
    '夜明けの鏡の奥に、しまもようがさかさまの灯台が映っていた。黒崎「あれに灯りがともれば、鏡は閉じる」']},
  {sec:'追加ストーリー3「鏡の海」',t:'夏の終わり',on:f=>f.d3_done,text:[
    '最後の夜、金の線で囲まれた映し身は、ナギの前で板を止めた。それは、ナギの「夏」だった。',
    'ナギと映し身が手をあげると、裏の灯台に灯りがともり、鏡の海に水が満ちた。',
    '夏休みの最後の日。ソウタくんと来年の大会の約束をして、ナギはうみまち線の電車に乗った。']},
];
// 「物語の進み具合」 on top: every part in order, done / going / not yet; a part not reached shows only how it begins
const PARTS=[
  {t:'本編「三つの道」',done:f=>endingsSeen()>=3,go:f=>true,n:f=>`エンディング ${endingsSeen()}/3`},
  {t:'真ルート「灯台」',done:f=>!!f.ending_true,go:f=>endingsSeen()>=3,how:'三つの道のエンディングを、ぜんぶ見ると始まる'},
  {t:'追加ストーリー1「オーシャンゲート」',done:f=>!!f.ex1_done,go:f=>!!f.ex1,how:'真ルートのあと、何日かたつと始まる'},
  {t:'追加ストーリー2「海街自警団」',done:f=>!!f.d2_done,go:f=>!!f.ex1_done,how:'追加ストーリー1を終えると、東の山の岩の扉が開く',n:f=>f.d2?`帰ってきた子 ${(SAVE.d2&&SAVE.d2.nest)||0}/${KIDS}`:''},
  {t:'追加ストーリー3「鏡の海」',done:f=>!!f.d3_done,go:f=>!!f.d3,how:'追加ストーリー2を終えると、次の朝に始まる',n:f=>`${Math.min(d3n(),3)}/4 夜`}];
function renderProgress(box,f){const h=document.createElement('h3');h.className='rsec';h.textContent='物語の進み具合';box.appendChild(h);
  const ul=document.createElement('ul');ul.className='rprog';let cur=false;
  PARTS.forEach((c,k)=>{const done=c.done(f),go=!done&&c.go(f),seen=done||go||k===0||PARTS[k-1].done(f)||PARTS[k-1].go(f);if(!seen)return;
    const li=document.createElement('li');li.className=done?'done':go?'go':'not';
    const st=document.createElement('b');st.textContent=done?'済み':go?'進行中':'まだ';const t=document.createElement('span');t.textContent=c.t+(go&&c.n&&c.n(f)?`（${c.n(f)}）`:'');li.append(st,t);
    if(!done&&!go&&c.how){const s=document.createElement('small');s.textContent=c.how;li.appendChild(s);}
    if(go&&!cur){cur=true;const g=storyGoal();if(g){const s=document.createElement('small');s.textContent='次は：'+g;li.appendChild(s);}}
    ul.appendChild(li);});
  box.appendChild(ul);}
function renderRecap(){const box=$('recapBody'),f=SAVE.flags;box.innerHTML='';let sec=null,n=0;
  renderProgress(box,f);
  for(const c of RECAP){if(!c.on(f))continue;n++;
    if(c.sec!==sec){sec=c.sec;const h=document.createElement('h3');h.className='rsec';h.textContent=sec;box.appendChild(h);}
    const d=document.createElement('details');d.className='rpart';const s=document.createElement('summary');s.textContent=c.t;d.appendChild(s);
    for(const p of c.text){const t=typeof p==='function'?p(f):p;if(!t)continue;const e=document.createElement('p');e.textContent=t;d.appendChild(e);}box.appendChild(d);}
  // the newest part opens by itself
  const last=box.querySelectorAll('details');if(last.length)last[last.length-1].open=true;
  if(!n){const p=document.createElement('p');p.className='sub';p.textContent='物語は、まだ始まったばかり。';box.appendChild(p);}}
$('recapBtn').addEventListener('click',()=>{renderRecap();openModal('recapM');});$('recapClose').addEventListener('click',closeModal);
