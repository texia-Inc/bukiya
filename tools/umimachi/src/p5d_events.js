
/* ---------- the events of the story, as data for the engine in p5c_story.js ----------
   {id, on:{talk:npcId} | on:{near:[x,z,radius]} | on:{night:true} | no on (starts as soon as `when` holds), when:{…}, mark:true (a "!" over the person), once:false, script:[steps]}
   when: day, minDay, phase ('morning'|'day'|'evening'|'night', or a list), hour:[from,to], flags:{k:v}, min:{k:n}, seen, unseen, quest:{id:state}, test:fn
   The first ready event in this list wins, so the specific ones come before the everyday ones at the end.

   Common route, days 1–3: the errands introduce the town, and three odd things show up a little at a time —
   the radio mast that blinks and hums at night, Mio who is on the pier only in the evening, and the black van.
   On the third night Nagi chooses: follow Omochi the cat to the west tunnel (horror), follow the van to the port (Oceangate),
   or go to sleep (the easy-going summer). Flags kept on the way: bond_<npc> (errands and kind answers), met_mio, met_mochi,
   saw_tower, saw_van, heard_og, heard_kurosaki, heard_lighthouse, promise_contest, mio_warn, route (1 horror, 2 Oceangate, 3 easy). */
const HOME=[-50.5,-122.6,Math.PI];                    // where Nagi stands in the morning: in front of grandma's bench by the shrine
const leaveMio=()=>{SAVE.flags.mio_left=SAVE.day;};
NPCS.mio.show=()=>phaseOf(SAVE.hour)==='evening'&&SAVE.flags.mio_left!==SAVE.day;
const nightView=[[-58,G(-58,-118)+15,-112],[-285,H(-285,-40)+34,-40]];   // from grandma's house: the town below and the radio mast on the west hill
const EVENTS=[
  // a check of every kind of step; only index.html#storytest starts it
  {id:'storytest',once:false,when:{test:()=>location.hash==='#storytest'&&!SAVE.flags.storytest_done},script:[
    ['cam',[0,G(0,-209)+6,-200],[0,4,-40],1.2],
    ['say','','夏休み。うみまち線の終点、坂の町。'],
    ['time',18.4,3],
    ['say','nagi','うわあ、海がオレンジ色だ…'],
    ['ask','nagi','これからどうしよう？',[['もう少しここにいる',[['add','test_stay'],['time',20.5,3],['say','nagi','島の灯台は、真っ暗なままだ。']]],['先に進む',[['say','nagi','よし、行こう。']]]],'test_choice'],
    ['if',{flags:{test_choice:1}},[['say','','（ここにいることにした）']],[['say','','（先に進むことにした）']]],
    ['cam','off'],
    ['set','storytest_done'],
    ['toast','テストの出来事が終わった',true]]},

  /* ----- day 1: arriving ----- */
  {id:'d1_open',when:{day:1,quest:{melon:0},test:()=>location.hash!=='#storytest'},script:[
    ['cam',[0,G(0,-209)+5,-213],[0,6,90],1.5,'cut'],
    ['say','','夏休み。','汐見ナギは うみまち線の終点で電車を降りて、坂の上から海を見下ろした。','この町には、ばあちゃん――トメばあちゃんが住んでいる。'],
    ['say','nagi','ひさしぶりだな、この坂。','ばあちゃん、神社の鳥居のそばで待ってるって言ってたっけ。'],
    ['cam','off'],
    ['toast','坂を下って、神社の鳥居のそばへ']]},
  {id:'d1_tome',on:{talk:'tome'},mark:true,when:{day:1,quest:{melon:0}},script:[
    ['say','tome','おや、ナギ！ まあまあ、大きくなって。','電車、長かったろう。お母さんは元気かい？'],
    ['say','nagi','うん、元気。夏休みのあいだ、よろしくね、ばあちゃん。'],
    ['say','tome','ゆっくりしておいき。この町は何もないけど、海と坂だけはたくさんあるからね。','そうだ、さっそくだけど、ひとつ頼まれてくれるかい。','商店街の「こむぎ堂」のメロンパンが食べたくてね。ふたつ買ってきておくれ。'],
    ['quest','melon']]},
  {id:'d1_dusk',when:{day:1,quest:{melon:2}},script:[
    ['wait',1.2],['toast','日が傾いてきた'],['cap',18.9],['time',16.6,5],
    ['say','nagi','…もう夕方か。桟橋の夕日、見に行ってみようかな。']]},
  {id:'d1_mio',on:{near:[-80,PIER.z1-5,7]},when:{day:1,phase:'evening'},script:[
    ['cam','over','mio'],
    ['say','','桟橋の先に、白いワンピースの女の子がひとり、海を見て立っている。'],
    ['say','mio','……今日も、灯台は光らないのかな。'],
    ['ask','nagi','（声をかけてみる？）',[
      ['こんにちは！',[['say','mio','……あなた、この町の子じゃないね。','風のにおいが、ちがうもの。'],['add','bond_mio']]],
      ['そっとしておく',[['say','','女の子は、島の方をじっと見つめている。']]]]],
    ['set','met_mio'],['fade','out'],['call',leaveMio],['wait',0.4],['fade','in'],
    ['say','','強い風が吹いて、目をつぶった。','目を開けると、女の子はもういなかった。'],
    ['say','nagi','……え？ いま、そこにいたよね？']]},
  {id:'fisher_mio',on:{talk:'fisher'},when:{seen:'d1_mio'},script:[
    ['say','fisher','女の子？ いや、今日は誰も来とらんぞ。','この桟橋の先にいたのは、おれとカモメだけだ。']]},
  {id:'d1_night',on:{night:true},when:{day:1},script:[
    ['cam',...nightView,1,'cut'],['fade','in'],
    ['say','','その夜。ばあちゃんの家の窓から、町の灯りが見えた。'],
    ['say','','ジジ……ジジジ……','西の山の電波塔が、赤く点滅している。耳の奥で、ラジオの雑音のような音がする。'],
    ['say','nagi','……なんだろう、あの音。'],
    ['set','saw_tower'],['wait',0.6],['fade','out']]},

  /* ----- day 2: the town and its people ----- */
  {id:'d2_morning',when:{day:2},script:[
    ['cam','npc','tome',3.4],
    ['say','tome','おはよう、ナギ。よく眠れたかい？'],
    ['ask','nagi','（ゆうべのことを話す？）',[
      ['電波塔が光って、変な音がしてた',[['say','tome','……あの塔かい。','昔はなかったんだよ。会社が建ててから、なんだか町を見張られてるようで好かんねえ。']]],
      ['ぐっすり眠れた！',[['say','tome','そりゃあよかった。海の町はよく眠れるんだよ。']]]]],
    ['if',{flags:{met_mio:1}},[['ask','nagi','（桟橋の女の子のことを聞く？）',[
      ['白いワンピースの子、知ってる？',[['say','tome','白いワンピース……？','……いいや。この町の子は、みんな日焼けしてるからねえ。'],['say','','ばあちゃんは、少しだけ遠くを見るような目をした。']]],
      ['やめておく',[]]]]]],
    ['say','tome','今日は町の人の手伝いをしておやり。困ってる人は、手を振ってるからすぐわかるよ。'],
    ['cam','off'],['toast','町の人の「！」を探して、おつかいをしよう']]},
  {id:'d2_van',when:{minDay:2,test:()=>Math.hypot(P.x-VAN.x,P.z-VAN.z)<11},script:[
    ['say','nagi','……また黒いバンだ。','窓が真っ黒で、中がぜんぜん見えない。会社の名前も書いてない。'],
    ['set','saw_van']]},
  {id:'master_van',on:{talk:'master'},when:{flags:{saw_van:1}},script:[
    ['say','master','黒いバン？ ああ、オーシャンゲートって会社の車だよ。','島のあたりに、大きなリゾートを建てたいんだそうだ。','あの電波塔も、あそこの会社が建てたものさ。'],
    ['say','nagi','ふうん……。'],
    ['set','heard_og']]},
  {id:'d2_mochi',on:{near:[-114,SHORE+12.6,3.2]},when:{minDay:2},script:[
    ['cam',[-111.2,G(-114,SHORE+12.6)+1.5,SHORE+10],[-114,G(-114,SHORE+12.6)+0.4,SHORE+12.6],2.5],
    ['say','','浜の流木のかげで、白い猫が丸くなっている。首輪の小さな札に「おもち」と書いてある。'],
    ['ask','nagi','（どうする？）',[
      ['そっとなでる',[['say','','おもちは目を細めて、ナギの手に頭をこすりつけた。'],['add','bond_mochi']]],
      ['見ているだけにする',[['say','','おもちは片目だけ開けて、またすぐに閉じた。']]]]],
    ['say','','……と思ったら、おもちは急に顔を上げ、西のトンネルの方をじっと見つめた。'],
    ['say','nagi','どうしたの？ なにかいるの？'],
    ['set','met_mochi']]},
  {id:'d2_mio',on:{near:[-80,PIER.z1-5,7]},when:{day:2,phase:'evening'},script:[
    ['cam','over','mio'],
    ['if',{seen:'d1_mio'},[['say','mio','……また来たんだ。']],[['say','','桟橋の先に、白いワンピースの女の子が立っている。'],['say','mio','……あなた、この町の子じゃないね。']]],
    ['say','nagi','わたし、ナギ。夏休みのあいだ、ばあちゃんの家にいるんだ。','あなたは？'],
    ['say','mio','ミオ。……ずっと前から、ここにいるの。'],
    ['say','mio','ねえ、知ってる？ 30年前の夏の夜、あの灯台の灯りが消えたの。','それから、この町の時間は、少しだけずれてる。'],
    ['ask','nagi','（なんて答える？）',[
      ['それって、どういう意味？',[['say','mio','……まだ、言えない。']]],
      ['また明日も来るね',[['say','mio','……うん。待ってる。'],['add','bond_mio']]]]],
    ['set','met_mio'],['fade','out'],['call',leaveMio],['wait',0.4],['fade','in'],
    ['say','','また風が吹いて、ミオの姿は消えていた。']]},
  {id:'d2_night',on:{night:true},when:{day:2},script:[
    ['cam',...nightView,1,'cut'],['fade','in'],
    ['say','','夕ごはんのあと、ばあちゃんがお茶をいれながら話してくれた。'],
    ['say','tome','あの島の灯台はね、30年前の夏に消えたきり、一度も光ってないんだよ。','あの夜は、町の子がひとり、いなくなってねえ。町じゅうで探したけど、とうとう見つからなかった。'],
    ['if',{flags:{met_mio:1}},[['say','nagi','（30年前……ミオが言ってたのと同じだ）']]],
    ['say','tome','ナギのお母さんも、あのころはこの町の子だったんだよ。','……さあ、もうお休み。'],
    ['set','heard_lighthouse'],['wait',0.6],['fade','out']]},

  /* ----- day 3: the town is a little restless ----- */
  {id:'d3_morning',when:{day:3},script:[
    ['cam','npc','tome',3.4],
    ['say','tome','おはよう。今日は浜でソウタたちが、ナギを探してたよ。','あの子たち、すっかりナギのスケボーにあこがれちゃってねえ。'],
    ['cam','off'],['toast','浜辺のソウタくんに会いに行こう']]},
  {id:'d3_sota',on:{talk:'sota'},mark:true,when:{day:3},script:[
    ['say','sota','おねえちゃん！ 待ってたんだ！','あのね、夏祭りの日に、桟橋でスケボー大会があるんだよ。おねえちゃんも出てよ！'],
    ['ask','nagi','（大会に出る？）',[
      ['出る！',[['say','sota','やったー！ みんなに言っとく！'],['set','promise_contest'],['add','bond_sota']]],
      ['考えとくね',[['say','sota','えー。出てくれたら、ぜったい盛り上がるのになあ。']]]]],
    ['say','sota','あとね、最近、黒いバンのおじさんが浜で写真を撮ってるんだ。','灯台の方ばっかり。なんか、こわいよね。'],
    ['set','saw_van']]},
  {id:'d3_baker',on:{talk:'baker'},when:{minDay:3,test:()=>SAVE.flags.saw_van||SAVE.flags.heard_og},script:[
    ['say','baker','……ナギちゃん、だったな。黒いバンを見たか。','オーシャンゲートの黒崎って男が、この前うちにパンを買いに来た。','ああいう目をした男は、昔の仕事でよく見た。……あいつらには近づくなよ。'],
    ['say','nagi','昔の仕事……？'],
    ['say','baker','おっと、しゃべりすぎた。メロンパン、焼きたてだよ。'],
    ['set','heard_kurosaki']]},
  {id:'d3_mio',on:{near:[-80,PIER.z1-5,7]},when:{day:3,phase:'evening'},script:[
    ['cam','over','mio'],
    ['say','mio','ナギ。……今夜、また電波塔が鳴るよ。','そのとき、町のどこかで「扉」が開くの。'],
    ['say','nagi','扉？'],
    ['say','mio','行くか、行かないかは、ナギが決めて。','……でも、どこへ行っても、最後はきっとあの灯台につながってる。'],
    ['set','mio_warn'],['set','met_mio'],['fade','out'],['call',leaveMio],['wait',0.4],['fade','in'],
    ['say','','ミオの立っていた場所に、古いビー玉がひとつ転がっていた。']]},
  {id:'d3_night',on:{night:true},when:{day:3},script:[
    ['cam',...nightView,1,'cut'],['fade','in'],
    ['say','','その夜。眠れずに、窓の外を見ていた。'],
    ['say','','ジジジジ……！','電波塔が、いつもより強く赤く光っている。'],
    ['say','','坂の下を、ライトを消した黒いバンが、港の方へすべるように走っていく。'],
    ['if',{flags:{met_mochi:1}},[['say','','庭の塀の上を、白い影が走った。おもちだ。西のトンネルの方へ駆けていく。']],
      [['say','','庭の塀の上を、白い猫が走った。西のトンネルの方へ駆けていく。']]],
    ['if',{flags:{mio_warn:1}},[['say','nagi','（ミオが言ってた「扉」って、これのこと……？）']]],
    ['ask','nagi','どうする？',[
      ['おもちを追って、西のトンネルへ',[['set','route',1]],{flags:{met_mochi:1}}],
      ['白い猫を追って、西のトンネルへ',[['set','route',1]],{flags:{met_mochi:0}}],
      ['黒いバンを追って、港へ',[['set','route',2]],{test:()=>SAVE.flags.saw_van||SAVE.flags.heard_og}],
      ['外の物音を確かめに、坂の下へ',[['set','route',2]],{test:()=>!SAVE.flags.saw_van&&!SAVE.flags.heard_og}],
      ['……そのまま寝る',[['set','route',3]]]]],
    ['if',{flags:{route:1}},[['say','','ナギは、そっと家を抜け出した。夜のトンネルの奥から、冷たい風が吹いてくる……。'],['toast','ホラールート「トンネルの向こう」は準備中。いまは次の朝になる',true]]],
    ['if',{flags:{route:2}},[['say','','ナギはスケボーをかかえて、坂を下りはじめた。港の倉庫街に、小さな灯りがともっている……。'],['toast','悪の組織ルート「シーサイド・コンスピラシー」は準備中。いまは次の朝になる',true]]],
    ['if',{flags:{route:3}},[['say','nagi','……明日、ばあちゃんに聞いてみよう。','おやすみなさい。']]],
    ['wait',0.6],['fade','out']]},

  /* ----- every day ----- */
  // from the second day on, the afternoon turns to evening on its own once the clock reaches the day's cap
  {id:'dusk',once:false,when:{minDay:2,test:()=>SAVE.cap<18&&SAVE.hour>=SAVE.cap-0.02},script:[
    ['toast','日が傾いてきた'],['cap',18.9],['time',16.6,5]]},
  {id:'dark',once:false,when:{test:()=>SAVE.hour>=18.85&&SAVE.flags.dark_day!==SAVE.day},script:[
    ['call',()=>{SAVE.flags.dark_day=SAVE.day;}],['toast','暗くなってきた。トメばあちゃんのところへ帰ろう']]},
  // grandma takes you home in the evening: the night's event, then the next morning
  {id:'home',on:{talk:'tome'},once:false,when:{phase:['evening','night']},script:[
    ['ask','tome','そろそろ、家に帰ろうか？',[
      ['うん、帰る',[['fade','out'],['cam','off'],['time',21.5,0],['warp',...HOME],['night'],['cam','off'],['warp',...HOME],['day']]],
      ['もう少し遊んでくる',[['say','tome','暗くなる前に、帰っておいでね。']]]]]]},
];
