
/* ---------- the events of the story, as data for the engine in p5c_story.js ----------
   {id, on:{talk:npcId} | on:{near:[x,z,radius]} | no on (starts as soon as `when` holds), when:{…}, mark:true (a "!" over the person), once:false, script:[steps]}
   when: day, minDay, phase ('morning'|'day'|'evening'|'night', or a list), hour:[from,to], flags:{k:v}, min:{k:n}, seen, unseen, quest:{id:state}, test:fn */
const EVENTS=[
  // a check of every kind of step; only index.html#storytest starts it
  {id:'storytest',once:false,when:{test:()=>location.hash==='#storytest'&&!SAVE.flags.storytest_done},script:[
    ['cam',[0,G(0,-209)+6,-200],[0,4,-40],1.2],
    ['say','','夏休み。うみまち線の終点、坂の町。'],
    ['time',18.4,3],
    ['say','nagi','うわあ、海がオレンジ色だ…'],
    ['ask','nagi','これからどうしよう？',[['もう少しここにいる',[['add','test_stay'],['time',20.5,3],['say','nagi','島の灯台が光りはじめた。']]],['先に進む',[['say','nagi','よし、行こう。']]]],'test_choice'],
    ['if',{flags:{test_choice:1}},[['say','','（ここにいることにした）']],[['say','','（先に進むことにした）']]],
    ['cam','off'],
    ['set','storytest_done'],
    ['toast','テストの出来事が終わった',true]]},
];
