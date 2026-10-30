
/* ---------- the events of the story, as data for the engine in p5c_story.js ----------
   {id, on:{talk:npcId} | on:{near:[x,z,radius]} | on:{night:true} | no on (starts as soon as `when` holds), when:{…}, mark:true (a "!" over the person), once:false, script:[steps]}
   when: day, minDay, phase ('morning'|'day'|'evening'|'night', or a list), hour:[from,to], flags:{k:v}, min:{k:n}, seen, unseen, quest:{id:state}, test:fn
   The first ready event in this list wins, so the specific ones come before the everyday ones at the end.

   Common route, days 1–3: the errands introduce the town, and three odd things show up a little at a time —
   the radio mast that blinks and hums at night, Mio who is on the pier only in the evening, and the black van.
   On the third night Nagi chooses: follow Omochi the cat to the west tunnel (horror), follow the van to the port (Oceangate),
   or go to sleep (the easy-going summer). Flags kept on the way: bond_<npc> (errands and kind answers), met_mio, met_mochi,
   saw_tower, saw_van, heard_og, heard_kurosaki, heard_lighthouse, promise_contest, mio_warn, route (1 horror, 2 Oceangate, 3 easy). */
const HOME=[-49.2,-123.6,-2.55];                    // where Nagi stands in the morning: in front of grandma's bench by the shrine
const leaveMio=()=>{SAVE.flags.mio_left=SAVE.day;};
// today's aim, shown in the tracker when no errand is being followed: the next step of the story in a line
function storyGoal(){const f=SAVE.flags,d=SAVE.day,ph=phaseOf(SAVE.hour),seen=id=>!!SAVE.seen[id],eve=ph==='evening',night=ph==='night';
  const home='ばあちゃん（神社の鳥居のそば）に話して、家に帰る';
  if(f.in_ura)return null;
  if(f.true_key)return eve||night?'夜、桟橋の釣りのおじさんに話して、船を出してもらう':'夜になったら、桟橋の釣りのおじさんに話す（ばあちゃんに話すと夕方まで休める）';
  if(endingsSeen()>=3&&!f.ending_true)return 'トメばあちゃんに話す';
  if(d===1){if(!SAVE.qs.melon)return '坂を下って、神社の鳥居のそばのばあちゃんに会う';if(qs('melon').state<2)return null;
    if(!seen('d1_mio'))return eve?'夕方の桟橋の先へ行ってみる':'ひと休みしたら、夕方の桟橋へ';return home;}
  if(d<=3){if(d===3&&!seen('d3_sota'))return '浜辺のソウタくんに会いに行く';
    if(eve||night)return seen('d'+d+'_mio')?home:'夕方の桟橋の先へ。それから'+home;
    // the daytime: what can still be found today, then errands, then resting until the evening
    const todo=[];
    if(!f.saw_van)todo.push('海岸通りを走る黒いバンを見に行く');
    else if(!seen('master_van'))todo.push('しおさいのマスターに、黒いバンのことを聞く');
    if(!f.met_mochi)todo.push('浜辺の西、干してあるボートのそばの白い猫に会う');
    if(d===3&&(f.saw_van||f.heard_og)&&!seen('d3_baker'))todo.push('こむぎ堂の主人に話す');
    if(QUESTS.some(available))todo.push('町の「！」の人を手伝う');
    const rest='ばあちゃんに話すと夕方まで休める。夕方は桟橋へ';
    return todo.length?todo.slice(0,2).join('、')+'。'+rest:'今日できることは終わった。'+rest;}
  if(f.route===3&&!f.ending_calm){if(d<6)return '夏祭りの準備：「！」の人を手伝う。ソウタくんと大会の練習もできる。夕方は'+home;
    return f.contest_done?null:'浜辺のソウタくんに話して、スケボー大会に出る';}
  if(f.route===2&&!f.ending_org){if(!seen('o4_baker'))return 'こむぎ堂の主人に、ゆうべのことを話す';
    const todo=[];if(!f.drones_cleared)todo.push('こむぎ堂の主人に話してドローン迎撃');if(qs('og_evidence').state<2)todo.push('ソウタくんの探偵団の聞き込み');
    if(todo.length)return todo.join('、')+(d>=5?'':'。夕方は'+home);return d>=5?'こむぎ堂の主人に話して、黒いバンを追う':'あしたの夜が勝負。夕方は'+home;}
  if(endingsSeen()>0&&endingsSeen()<3)return eve?'桟橋の先のミオに話すと、あの夜に戻れる':'夕方、桟橋の先のミオに話すと、あの夜（3日目）に戻れる';
  return eve||night?home:null;}
const endingsSeen=()=>['ending_calm','ending_horror','ending_org'].filter(k=>SAVE.flags[k]).length;
// back to the third evening: the route and what happened on it are undone; endings, friendships and finished errands stay
function rewindTo3(){SAVE.day=3;SAVE.hour=18.2;SAVE.cap=18.9;SAVE.flags.mio_left=3;
  for(const k of ['route','in_ura','clues','clue_photo','clue_marble','clue_diary','fest_day','contest_done','contest_t','og_saw','dark_day','true_key'])delete SAVE.flags[k];
  for(const id in SAVE.seen)if(id==='d3_night'||/^(c\d|c_|o\d|ura_)/.test(id))delete SAVE.seen[id];
  for(const q of ['fest_lantern','fest_yatai','fest_yukata','og_evidence'])if(SAVE.qs[q]&&SAVE.qs[q].state===1)delete SAVE.qs[q];
  if(URA.on)uraExit();renderClock();save();}
NPCS.mio.show=()=>SAVE.flags.mio_here||phaseOf(SAVE.hour)==='evening'&&SAVE.flags.mio_left!==SAVE.day;
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
  {id:'d2_mochi',on:{near:[-108.5,SHORE+11,3.2]},when:{minDay:2},script:[
    ['cam',[-105.6,G(-108.5,SHORE+11)+1.5,SHORE+8.4],[-108.5,G(-108.5,SHORE+11)+0.4,SHORE+11],2.5],
    ['say','','浜に干してあるボートのそばで、白い猫が丸くなっている。首輪の小さな札に「おもち」と書いてある。'],
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
    ['if',{flags:{route:1}},[['say','','ナギは、そっと家を抜け出した。','海岸通りを西へ。トンネルの入り口で、白い猫がこちらをふり返り、闇の中へ消えた。'],
      ['say','nagi','待って、おもち……！'],['fade','out'],['ura',true],['time',23.3,0],['cam','off'],['warp',...URA_START],
      ['cam',[URA_START[0]+9,G(URA_START[0],URA_START[1])+3,URA_START[1]-4],[URA_START[0]-2,G(URA_START[0],URA_START[1])+1.2,URA_START[1]],1.2,'cut'],['fade','in'],
      ['say','','トンネルを抜けると、そこはまた海街だった。','……でも、ちがう。色がない。霧が濃い。灯りのついた窓が、ひとつもない。'],
      ['say','','遠くで、だれも乗っていない電車が走っていく音がした。'],
      ['say','nagi','ここ……海街、だよね？ ばあちゃん……？'],
      ['say','','おもちが、ニャア、と小さく鳴いた。その目が、町の三つの方角を順に見る。駅、商店街、そして坂の上の神社。'],
      ['cam','off'],['toast','L でライト。影の住人に見つからずに、3つの手がかりを探そう',true],['stop']]],
    ['if',{flags:{route:2}},[['say','','ナギはスケボーをかかえて、そっと坂を下りた。'],
      ['fade','out'],['ogscene',true],['time',23,0],['warp',186,COAST_Z-2.6,Math.PI/2],
      ['cam',[188,G(188,COAST_Z)+2.2,COAST_Z-6],[200,G(200,COAST_Z)+1.2,COAST_Z+1.2],1.2,'cut'],['fade','in'],
      ['say','','海岸トンネルの手前に、ライトを消した黒いバンが止まっている。','黒いスーツの男たちが、荷台から重そうな箱を下ろしていた。'],
      ['say','黒崎','電波塔の出力は、明日の夜に最大まで上げる。町の連中は、何も気づかん。','島の灯台は、あさっての夜に片づける。あれさえなくなれば、リゾートの工事はすぐに始められる。'],
      ['say','nagi','（灯台を……片づける？ 壊すってこと……？）'],
      ['say','','ガタン。足もとのスケボーが、音を立てた。'],
      ['say','黒崎','――だれだ！ つかまえろ！'],
      ['say','nagi','やばっ……！ 坂の下まで逃げなきゃ！'],
      ['cam','off'],
      ['pursuit',{from:[186,COAST_Z-2.6,-Math.PI/2],to:[0,COAST_Z-1,6],hint:'海岸通りを西へ。海へつづく坂の下まで逃げる'}],
      ['ogscene',false],
      ['say','','坂の下の路地に飛びこんで、息をひそめた。','革靴の足音が、遠ざかっていく……。'],
      ['say','nagi','（オーシャンゲート……灯台を壊すつもりなんだ。明日、こむぎ堂のおじさんに話してみよう）'],
      ['set','og_saw']]],
    ['if',{flags:{route:3}},[['say','nagi','……明日、ばあちゃんに聞いてみよう。','おやすみなさい。']]],
    ['wait',0.6],['fade','out']]},

  /* ----- the easy-going route "なつやすみ帳" (route 3), days 4–6: getting the town ready for the summer festival,
     the skateboard contest (a race from the lookout down to the end of the pier) and fireworks over the sea ----- */
  {id:'c4_morning',when:{day:4,flags:{route:3}},script:[
    ['cam','npc','tome',3.4],
    ['say','tome','おはよう、ナギ。ゆうべは、ぐっすりだったねえ。','あさっては夏祭りだよ。神社に屋台が出て、夜は海の上に花火が上がるんだ。','町のみんなが準備でてんてこまいでね。手伝っておやり。'],
    ['if',{flags:{promise_contest:1}},[['say','tome','ソウタとスケボー大会の約束もしたんだろう？ 練習しておかないとね。']]],
    ['cam','off'],['toast','「！」の人を手伝って、夏祭りの準備をしよう']]},
  {id:'c_practice',on:{talk:'sota'},once:false,when:{flags:{route:3},test:()=>SAVE.day>=4&&SAVE.day<=5&&!available(QBY('ramune'))},script:[
    ['say','sota','おねえちゃん！ 大会のコースはね、坂の上の見晴らし台から、桟橋の先までなんだ。'],
    ['ask','sota','練習してみる？',[
      ['練習する！',[['fade','out'],['warp',3,-196,0],['fade','in'],['race',{from:[3,-196,0],to:[-80,331,4],limit:150},'practice_t'],
        ['call',()=>{const t=SAVE.flags.practice_t;if(t<0){toast('時間切れ…');return;}toast(`タイム ${(t/10).toFixed(1)} 秒`,true);
          if(!SAVE.flags.best_t||t<SAVE.flags.best_t){SAVE.flags.best_t=t;toast('自己ベスト！');}}],
        ['say','nagi','ふう……。本番は、ハヤトくんが55秒くらいで来るって言ってたっけ。']]],
      ['また今度',[['say','sota','うん、いつでも言ってね！']]]]]]},
  {id:'c5_morning',when:{day:5,flags:{route:3}},script:[
    ['cam','npc','tome',3.4],
    ['say','tome','明日はいよいよお祭りだねえ。'],
    ['if',{quest:{fest_yukata:2}},[['say','tome','浴衣、似合うといいねえ。お母さんも、あれを着て花火を見たんだよ。']],[['say','tome','そうそう、はなもりの花江さんが、ナギに話があるって言ってたよ。']]],
    ['cam','off']]},
  {id:'c6_morning',when:{day:6,flags:{route:3}},script:[
    ['set','fest_day'],['cap',18.9],
    ['cam',[SHRINE.x+4,G(SHRINE.x,-126)+3,-122],[SHRINE.x,G(SHRINE.x,-140)+1.5,-142],1.5,'cut'],
    ['say','','夏祭りの朝。参道には提灯がゆれて、屋台の準備をする音が聞こえる。'],
    ['cam','npc','tome',3.4],
    ['say','tome','さあ、今日は夏祭りだよ！','スケボー大会は夕方からだって。ソウタが浜で待ってるよ。'],
    ['cam','off'],['toast','浜辺のソウタくんに話しかけると、スケボー大会が始まる']]},
  {id:'c6_contest',on:{talk:'sota'},mark:true,once:false,when:{day:6,flags:{route:3,contest_done:0}},script:[
    ['say','sota','おねえちゃん！ いよいよ大会だよ！','コースは見晴らし台から桟橋の先まで。町の人もみんな見に来てるんだ！'],
    ['if',{flags:{promise_contest:0}},[['ask','nagi','（大会に出る？）',[['出る！',[]],['もう少しあとで',[['say','sota','えー！ 待ってるからね！'],['stop']]]]]]],
    ['fade','out'],['time',17.3,0],['warp',3,-196,0],
    ['cam',[-6,G(0,-203)+2.6,-188],[2,G(0,-200)+1.2,-200],2,'cut'],['fade','in'],
    ['say','','見晴らし台に、町の子どもたちと大人が集まっている。','高校生のハヤト、郵便屋さんのコウジさん、そしてソウタ。'],
    ['say','sota','ハヤトにいちゃんは去年の優勝なんだ。55秒で下りたんだって！'],
    ['cam','off'],
    ['race',{from:[3,-196,0],to:[-80,331,4],limit:150},'contest_t'],
    ['cam',[-77.5,PIER.y+2,322],[-80.5,PIER.y+1,331],2.5],
    ['call',()=>{const t=SAVE.flags.contest_t;toast(t<0?'時間切れ…':`タイム ${(t/10).toFixed(1)} 秒`,true);}],
    ['if',{min:{contest_t:0},max:{contest_t:550}},
      [['say','','ゴール！ ハヤトより先に、桟橋の先へ飛びこんだ！'],['say','sota','おねえちゃん、優勝だ！ すっげー！'],['set','contest_rank',1],['money',1000]],
      [['if',{min:{contest_t:0},max:{contest_t:680}},
        [['say','','ゴール！ ハヤトにはわずかに届かなかったけど、2位だ！'],['say','sota','2位！ 来年はぜったい優勝だね！'],['set','contest_rank',2],['money',600]],
        [['if',{min:{contest_t:0},max:{contest_t:800}},
          [['say','','ゴール！ 3位。コウジさんと、ほとんど同時だった。'],['say','sota','3位だって！ やったね、おねえちゃん！'],['set','contest_rank',3],['money',400]],
          [['if',{min:{contest_t:0}},[['say','','ゴール……！ 結果はびりだったけど、桟橋のみんなが大きな拍手をくれた。']],[['say','','時間切れ……。でも、桟橋のみんなが大きな拍手をくれた。']]],
           ['say','sota','すっごくかっこよかったよ！'],['set','contest_rank',4],['money',200]]]]]]],
    ['set','contest_done'],
    ['fade','out'],['time',20.2,0],['warp',-79.5,326,0],
    ['cam',[-78.5,PIER.y+1.6,318],[-40,62,480],1.5,'cut'],['fade','in'],
    ['fireworks',60],
    ['say','','日が暮れて、海の上に最初の花火が上がった。','ドン、と胸に響く音。桟橋も、浜も、坂の上も、みんなが空を見上げている。'],
    ['wait',3],
    ['say','','そのとき――花火の光の向こうに、黒い影がいくつも浮かんだ。','ブウウン……。オーシャンゲートの監視ドローンだ。花火の上を、町を見張るように飛び回っている。'],
    ['say','baker','ナギちゃん！ やつら、祭りの夜をねらってきたか。','これを使え。昔の仕事道具だ。スケボーに乗ったまま、クリックか J キーで撃てる。','花火が終わる前に、片づけるぞ！'],
    ['fade','out'],['cam','off'],['warp',-40,COAST_Z+2.2,Math.PI/2],['fade','in'],
    ['drones',{total:10,boss:1,title:'夏祭りの夜空を守れ'}],
    ['fade','out'],['warp',-79.5,326,0],['cam',[-78.5,PIER.y+1.6,318],[-40,62,480],1.5,'cut'],['fade','in'],['fireworks',60],
    ['say','','最後のドローンが海に落ちると、浜のほうから歓声が上がった。','花火は、なにごともなかったように、また夜空に咲きはじめた。'],
    ['say','baker','……いい腕だ。このことは、町のみんなには内緒だぞ。'],
    ['wait',3],
    ['if',{flags:{met_mio:1}},[['say','','ふと隣を見ると、白いワンピースの女の子が、花火を見上げていた。'],['say','mio','……きれいだね、ナギ。'],
      ['say','','次の花火が上がって、もう一度見たときには、ミオはいなかった。']]],
    ['wait',3],
    ['say','tome','ナギ。ここにいたのかい。'],
    ['say','tome','この夏、ナギが町じゅうを走り回ってくれたおかげで、みんな助かったって言ってたよ。','それでね、町内会からのお願いなんだけど……','夏休みのあいだ、「海街の配達係」をやってくれないかい？ スケボーで、町のみんなに届けものをするのさ。'],
    ['ask','nagi','（どうする？）',[
      ['やる！',[['say','nagi','まかせて、ばあちゃん！'],['set','delivery_job']]],
      ['……考えておくね',[['say','tome','ふふ。ゆっくりでいいさ。']]]]],
    ['wait',2],['set','ending_calm'],['call',()=>{SAVE.flags.dark_day=SAVE.day;}],
    ['toast','のほほんルート「なつやすみ帳」 おしまい',true],
    ['say','','――のほほんルート「なつやすみ帳」 おしまい。','このあとも、夏休みは続く。夜の町を、花火の下で散歩してみよう。'],
    ['cam','off']]},

  /* ----- the Oceangate route "シーサイド・コンスピラシー" (route 2), days 4–5: the baker's past, the drones, the kids' detective work,
     and the chase after the black van ----- */
  {id:'o4_morning',when:{day:4,flags:{route:2}},script:[
    ['cam','npc','tome',3.4],
    ['say','tome','おはよう、ナギ。……おや、目の下にくまができてるよ。ゆうべは、どこへ行ってたんだい？'],
    ['ask','nagi','（どうする？）',[
      ['正直に話す',[['say','tome','……オーシャンゲートの人たちが、灯台を？','こむぎ堂の主人に相談してごらん。あの人は昔、そういう仕事をしてたって、町のうわさだよ。']]],
      ['なんでもない',[['say','tome','そうかい……。無理はおしでないよ。困ったら、こむぎ堂の主人を頼るといい。']]]]],
    ['cam','off'],['toast','こむぎ堂の主人に、ゆうべのことを話そう']]},
  {id:'o4_baker',on:{talk:'baker'},mark:true,when:{minDay:4,flags:{route:2}},script:[
    ['say','baker','……黒崎たちが、灯台を？','ナギちゃん、ちょっと店の奥へ来てくれ。'],
    ['say','baker','昔、おれは「こむぎ」って呼ばれてた。ある組織の……まあ、エージェントってやつだ。','黒崎は、昔の仕事相手さ。あいつらは電波塔とドローンで、この町を見張ってる。'],
    ['if',{min:{drones_cleared:1}},[['say','baker','このあいだのドローン退治で、やつらの目は半分つぶれた。いい腕だったよ。']],
      [['say','baker','まずは、やつらの目をつぶそう。町の上を飛んでる監視ドローンだ。','昔の仕事道具を貸してやる。スケボーに乗ったまま、クリックか J キーで撃てる。','気をつけろ、向こうも撃ってくる。目が赤く光ったら、曲がってよけるんだ。']]],
    ['say','baker','それから、ソウタたちにも声をかけておいた。あの子たちは町じゅうに友だちがいる。証拠を集めてもらおう。'],
    ['if',{min:{drones_cleared:1}},[],[['call',()=>startDrones()]]]]},
  {id:'o5_morning',when:{day:5,flags:{route:2}},script:[
    ['cam','npc','tome',3.4],
    ['say','tome','今日は、なんだか町が静かだねえ。電波塔の音も、ゆうべはひどかった。','ナギ、気をつけるんだよ。'],
    ['cam','off'],['toast','ドローンを撃ち落とし、探偵団の証拠を集めたら、こむぎ堂の主人に話そう']]},
  {id:'o5_boss',on:{talk:'baker'},mark:true,when:{minDay:5,flags:{route:2},min:{drones_cleared:1},quest:{og_evidence:2}},script:[
    ['say','baker','ドローンは落とした。証拠もそろった。','今夜、黒崎はバンで港へ向かう。灯台をふき飛ばす起爆装置は、バンの中だ。','警察には知らせたが、間に合わん。……あのバンに追いつけるのは、町でいちばん速い、ナギちゃんのスケボーだけだ。'],
    ['ask','nagi','（どうする？）',[['まかせて！',[]],['……やるしかないよね',[]]]],
    ['fade','out'],['time',20.6,0],['cam','off'],['warp',120,COAST_Z+2.2,Math.PI/2],['fade','in'],
    ['say','','夜の海岸通り。港へ急ぐと、頭の上でプロペラの音がした。'],
    ['say','黒崎','（スピーカーの声）しつこいガキだ。ガーディアンを出せ。……二度と、じゃまはさせん。'],
    ['say','baker','（無線の声）ナギちゃん、大型ドローンだ！ バンを追う前に、そいつを落とせ！'],
    ['drones',{total:6,boss:1,title:'ガーディアンを撃ち落とせ'}],
    ['say','nagi','落とした……！ バンは、まだこの先だ！'],
    ['fade','out'],['vanchase'],
    ['call',ogEndCam],
    ['say','','バンのうしろにぴたりとつけて、荷台の扉に手をのばした――','キキーッ！ バンが急ブレーキをかけて止まった。'],
    ['say','baker','そこまでだ、黒崎。'],
    ['say','黒崎','……パン屋だと？ まさか、お前……「こむぎ」か。引退したと聞いていたが。'],
    ['say','baker','今は、ただのパン屋さ。この町のな。'],
    ['say','','こむぎ堂の主人は、バンの中から黒い箱――起爆装置を取り出した。遠くで、パトカーのサイレンが聞こえる。'],
    ['say','nagi','灯台……守れたんだ。'],
    ['if',{flags:{met_mio:1}},[['say','','桟橋の先で、白いワンピースの女の子が、こちらに小さく手をふった気がした。']]],
    ['say','baker','いい腕だ、ナギちゃん。……このことは、町のみんなには内緒だぞ。'],
    ['ogscene',false],['set','ending_org'],['money',1500],
    ['toast','悪の組織ルート「シーサイド・コンスピラシー」 おしまい',true],
    ['say','','――悪の組織ルート「シーサイド・コンスピラシー」 おしまい。','灯台は守られた。けれど、その灯りがともらない理由は、まだだれも知らない。'],
    ['fade','out'],['cam','off'],['warp',...HOME],['day']]},

  /* ----- the horror route "トンネルの向こう" (route 1), the third night: 裏海街. Three things Mio left behind, then the chase ----- */
  {id:'ura_photo',on:{near:[62,TRAM_Z-1.5,2.4]},when:{flags:{in_ura:1,clue_photo:0}},script:[
    ['say','','駅のベンチに、色あせた写真が一枚、置いてあった。','浜辺で笑う、ふたりの女の子。ひとりは白いワンピース。もうひとりは……'],
    ['say','nagi','……お母さん？ 若いころの、お母さんだ。','裏に何か書いてある。「ミオと、ナツミ。1996年 夏」'],
    ['set','clue_photo'],['add','clues'],['call',()=>renderHUD()]]},
  {id:'ura_marble',on:{near:[SHOPS.dagashi.door[0],SHOPS.dagashi.door[1],2.4]},when:{flags:{in_ura:1,clue_marble:0}},script:[
    ['say','','まるやの店先。ラムネの空きびんの中に、青いビー玉がひとつ。','手にとると、遠くで子どもの笑い声がした気がした。'],
    ['say','','「ナツミちゃん、ビー玉とれた！ ……ずっと、いっしょに遊ぼうね」'],
    ['say','nagi','いまの声……ミオ？'],
    ['set','clue_marble'],['add','clues'],['call',()=>renderHUD()]]},
  {id:'ura_diary',on:{near:[SHRINE.x,-157.5,2.6]},when:{flags:{in_ura:1,clue_diary:0}},script:[
    ['say','','本殿の石段に、雨にぬれた日記の切れはしが落ちていた。'],
    ['say','','「8月15日。今夜、電波塔が鳴ったら、トンネルの向こうへ行ってみる。」','「灯台の灯りが消えたのは、きっと向こう側にだれかがいるから。わたしが、たしかめてくる。」','「ナツミには、ないしょ。――ミオ」'],
    ['say','nagi','30年前の、あの夜……ミオは、ここに来たんだ。'],
    ['set','clue_diary'],['add','clues'],['call',()=>renderHUD()]]},
  {id:'ura_chase',when:{flags:{in_ura:1},min:{clues:3}},script:[
    ['say','','手がかりが、そろった。そのとき――','ブウウン……。霧の向こうから、色のない羽音が近づいてくる。目だけが赤く光る、影のドローンだ。'],
    ['say','','足もとに、だれかの古い二丁拳銃が落ちていた。持ち手に、小さく「こむぎ」と彫ってある。'],
    ['say','nagi','……使えってこと？ やるしかない！'],
    ['drones',{total:8,boss:1,title:'影のドローン'}],
    ['say','','大きな影のドローンが、霧の中に落ちて消えた。','……町じゅうの影の住人が、いっせいにこちらを向いた。'],
    ['say','','背後で、地面がきしむ音。ふり返ると、家よりも大きな影が、赤い目でナギを見下ろしていた。'],
    ['say','nagi','……っ！ 逃げなきゃ！ 西のトンネルへ！'],
    ['chase'],
    ['fade','out'],['ura',false],['set','mio_here'],['time',5.9,0],['warp',-79.5,333,0],
    ['cam',[-77.2,PIER.y+1.7,330],[-81.2,PIER.y+1.1,336.6],1.2,'cut'],['fade','in'],
    ['say','','トンネルを転がり出ると、空が白みはじめていた。','気がつくと、ナギは桟橋の先に立っていた。となりに、ミオがいる。'],
    ['say','mio','……帰ってこられたね、ナギ。'],
    ['say','nagi','ミオ。この写真……ミオと、わたしのお母さんだよね。'],
    ['say','mio','うん。30年前の夏、わたしとナツミは、いつもいっしょだった。','あの夜、電波塔が鳴って、トンネルの向こうの扉が開いた。わたしは向こう側に入ったまま、帰れなくなったの。','灯台の灯りが消えたのも、あの夜。……灯りがもう一度ともったら、わたしも帰れるのかもしれない。'],
    ['ask','nagi','（なんて言う？）',[
      ['わたしが、灯りをともしてみせる',[['say','mio','……ありがとう。ナツミも、きっと同じことを言ったね。'],['set','promise_mio'],['add','bond_mio',2]]],
      ['……ずっと、ひとりだったの？',[['say','mio','ううん。ときどき、ナツミの娘が遊びに来るのを見てた。……ずっと前から、知ってたよ。'],['add','bond_mio']]]]],
    ['say','','朝日が海から顔を出した。まぶしさに目を細めて、もう一度見たとき、ミオはもういなかった。','手の中に、青いビー玉と、色あせた写真だけが残っていた。'],
    ['set','mio_here',0],['set','ending_horror'],
    ['toast','ホラールート「トンネルの向こう」 おしまい',true],
    ['say','','――ホラールート「トンネルの向こう」 おしまい。','灯台の灯りと、30年前の夜の本当のことは、まだ海街のどこかに眠っている。'],
    ['fade','out'],['cam','off'],['warp',...HOME],['day']]},

  /* ----- after an ending: Mio offers to take Nagi back to the third evening, to choose another way. All three endings open the true route ----- */
  {id:'rewind',on:{talk:'mio'},once:false,when:{phase:'evening',test:()=>endingsSeen()>0&&endingsSeen()<3},script:[
    ['say','mio','ナギ。……あの夜のこと、覚えてる？'],
    ['ask','mio','もう一度、あの夜に戻ってみる？ 選ばなかった道の先にも、灯台につながる何かがあるはずだよ。',[
      ['戻る',[['fade','out'],['call',rewindTo3],['cam','off'],['warp',...HOME],['fade','in'],['toast','3日目の夕方に戻った。ばあちゃんと家に帰ると、あの夜の分かれ道',true]]],
      ['やめておく',[['say','mio','……うん。わたしは、いつでもここにいるよ。']]]]]]},

  /* ----- the true route "灯台": all three endings seen ----- */
  {id:'t_tome',on:{talk:'tome'},mark:true,when:{test:()=>endingsSeen()>=3},script:[
    ['cam','npc','tome',3.4],
    ['say','tome','ナギ。……この夏、いろんなことがあったみたいだね。顔つきが、来たときとちがうよ。'],
    ['say','nagi','ばあちゃん。お母さんから預かってたもの、まだ渡してなかった。'],
    ['say','','ナギは、カバンの底にしまっていた手紙を、ばあちゃんにわたした。'],
    ['say','tome','……ナツミからかい。','（ばあちゃんは、しばらく黙って手紙を読んでいた）','あの子、30年ずっと、自分を責めてたんだねえ。ミオちゃんがいなくなった夜のことを。'],
    ['say','tome','ナギには話してなかったね。あの島の灯台の灯り守りは、ナギのじいちゃんだったんだよ。','30年前のあの夜、じいちゃんはミオちゃんを探しに出て、灯りをともせなかった。それっきり、灯台に上れなくなってねえ。'],
    ['say','tome','灯台の灯りはね、昔はお盆の夜に、町の五つの灯りから火を分けてもらってともしたんだ。','見晴らし台、神社の鳥居、海の見える踏切、駅のホーム、それから桟橋の先。'],
    ['say','','ばあちゃんは、古い鍵をナギの手にのせた。'],
    ['say','tome','じいちゃんの形見の、灯台の鍵だよ。……ナギに、たのめるかい？'],
    ['ask','nagi','（どうする？）',[['わたしが、灯りをともす',[]],['……うん。やってみる',[]]]],
    ['say','tome','夜になったら、桟橋の釣りのおじさんに船を出してもらいな。あの人は、じいちゃんの古い友だちさ。'],
    ['set','true_key'],['call',()=>{if(SAVE.cap<18.9)SAVE.cap=18.9;}],['cam','off'],['toast','夜、桟橋の釣りのおじさんに話そう',true]]},
  {id:'t_fisher',on:{talk:'fisher'},mark:true,when:{flags:{true_key:1},phase:['evening','night']},script:[
    ['say','fisher','灯台へ？ ……そうか、あのじいさんの孫か。','よし、船を出してやる。ただし、灯りがなきゃ灯台はともらんぞ。町の五つの灯りを、もらってきな。'],
    ['fade','out'],['time',20.6,0],['fade','in'],
    ['say','','ジジジジジ……！','電波塔が、これまででいちばん大きく鳴りはじめた。町の灯りが、ちらちらとふるえている。'],
    ['say','mio','（ナギ、急いで。あの音が鳴りやんだら、今夜の扉は閉じてしまう）'],
    ['say','nagi','ミオの声……！ よし、行こう！'],
    ['lights',{limit:300,pts:[{name:'桟橋の先',x:-80,z:334},{name:'駅のホーム',x:62,z:TRAM_Z-1.5},{name:'海の見える踏切',x:3,z:TRAM_Z-7},{name:'神社の鳥居',x:-60,z:-119.5},{name:'見晴らし台',x:0,z:-205}]}],
    ['say','','五つの灯りが、ナギの胸のあたりで、あたたかくまたたいている。'],
    ['say','baker','ナギちゃん！ 間に合ったか。','島の灯台の下に、黒崎の残した機械がある。灯りをともそうとすれば、きっとじゃましてくる。','これを持っていけ。昔の仕事道具だ。'],
    ['say','fisher','さあ、乗りな。桟橋の先の船だ。島まで、ひとっ走りだ。'],
    ['cam','off'],['fade','out'],['warp',-80,331,Math.PI],['fade','in'],['boat','island'],
    ['say','','島の桟橋に着いた。見上げると、灯台の下で、黒い機械が赤く光っている。'],
    ['say','','ジジジジ……！ 機械のふたが開いて、大きなドローンが飛び立った。'],
    ['drones',{total:6,boss:1,title:'灯台を守れ'}],
    ['say','nagi','いまのうちに……灯台へ！'],
    ['toast','道をのぼって灯台へ。じいちゃんの鍵で扉を開けて、てっぺんで灯りをともそう',true],
    ['lamp'],
    ['say','','じいちゃんの鍵で開けたさびた扉。らせん階段をのぼりきると、夜の海と、町の灯りが見えた。'],
    ['say','nagi','じいちゃん、ミオ、お母さん。……ともすよ。'],
    ['set','lighthouse_lit'],['wait',1.5],
    ['call',()=>setCam([[LH.x-26,LH.gy+5,LH.z-38],[LH.x,LH.gy+1.5,LH.z],0.8])],
    ['say','','30年ぶりに、灯台に灯りがともった。','光の帯が海をわたって、町の坂を、屋根を、やさしくなでていく。'],
    ['set','tower_quiet'],
    ['say','','西の山で、電波塔の赤い光が、ふっと消えた。あのいやな音も、もう聞こえない。'],
    ['if',{min:{bond_mio:1}},[['say','mio','……ありがとう、ナギ。'],['say','','光の中に、白いワンピースの女の子が立っていた。']],[['say','','光の中に、白いワンピースの女の子が立っていた。']]],
    ['say','mio','やっと、帰れる。','ナツミに伝えて。……あの夜のこと、ナツミのせいじゃないよって。ずっと、友だちだよって。'],
    ['say','','ミオは笑って、光の帯の中へ歩いていった。'],
    ['wait',1],['fade','out'],['cam','off'],
    ['set','mom_here'],['warp',...HOME],['day',7],
    ['cam','npc','natsumi',3.6],
    ['say','','次の朝。坂の下から、聞きなれた声がした。'],
    ['say','natsumi','ナギ！ ……お母さん！'],
    ['say','tome','ナツミ。……おかえり。'],
    ['say','natsumi','ゆうべ、夢を見たの。ミオが、灯台の光の中で手をふってた。','……ナギ、あなたが？'],
    ['say','nagi','うん。ミオがね、伝えてって。「ナツミのせいじゃないよ。ずっと、友だちだよ」って。'],
    ['say','','ナギは、色あせた写真と、青いビー玉をお母さんにわたした。お母さんは写真を胸に当てて、小さく泣いた。'],
    ['say','tome','さあさあ、朝ごはんにしようかね。今夜も、灯台がよく見えるよ。'],
    ['set','ending_true'],['cam','off'],
    ['credits'],
    ['toast','真ルート「灯台」 おわり',true],
    ['say','','――真ルート「灯台」 おわり。','これからも夏休みは続く。夜になったら、灯台の光を見に行こう。']]},

  /* ----- every day ----- */
  // from the second day on, the afternoon turns to evening on its own once the clock reaches the day's cap
  {id:'dusk',once:false,when:{minDay:2,test:()=>SAVE.cap<18&&SAVE.hour>=SAVE.cap-0.02},script:[
    ['toast','日が傾いてきた'],['cap',18.9],['time',16.6,5]]},
  // after the true ending the evening runs on into the night (until grandma takes you home), to see the lighthouse
  {id:'dark',once:false,when:{test:()=>SAVE.hour>=18.85&&SAVE.flags.dark_day!==SAVE.day&&!SAVE.flags.in_ura},script:[
    ['call',()=>{SAVE.flags.dark_day=SAVE.day;}],
    ['if',{flags:{ending_true:1}},[['call',()=>{SAVE.cap=23.9;}],['toast','日が暮れていく。夜の町と、灯台の光を見に行こう']],[['toast','暗くなってきた。トメばあちゃんのところへ帰ろう']]]]},
  // in the daytime from the second day, grandma lets you rest until the evening
  {id:'rest',on:{talk:'tome'},once:false,when:{minDay:2,phase:['morning','day'],test:()=>!SAVE.flags.in_ura},script:[
    ['ask','tome','どうする？ ちょっと休んでいくかい？',[
      ['夕方まで、ひと休みする',[['fade','out'],['time',16.6,0],['cap',18.9],['wait',0.4],['fade','in'],['toast','夕方になった'],['say','tome','よく休めたかい。夕方の海は、きれいだよ。']]],
      ['まだ町を回る',[['say','tome','気をつけて行っておいで。']]]]]]},
  // grandma takes you home in the evening: the night's event, then the next morning
  {id:'home',on:{talk:'tome'},once:false,when:{phase:['evening','night']},script:[
    ['ask','tome','そろそろ、家に帰ろうか？',[
      ['うん、帰る',[['fade','out'],['cam','off'],['time',21.5,0],['warp',...HOME],['night'],['cam','off'],['warp',...HOME],['day']]],
      ['もう少し遊んでくる',[['say','tome','暗くなる前に、帰っておいでね。']]]]]]},
];
