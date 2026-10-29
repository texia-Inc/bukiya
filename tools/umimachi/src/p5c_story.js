
/* ---------- the story engine: the day and the hour, events written as data, choices in conversations, event cameras.
   An event is {id, on, when, script}. `on` says what starts it: talking to someone ({talk:'tome'}), coming near a place
   ({near:[x,z,r]}), or nothing, which starts it as soon as `when` holds. An event plays once unless it says once:false.
   The script is a list of steps such as ['say','tome','…'] — the steps are listed at `step` below. The events themselves
   live in p5d_events.js. ---------- */
const PHASE_NAME={morning:'朝',day:'昼',evening:'夕方',night:'夜'};
function phaseOf(h){h=((h%24)+24)%24;return h<5||h>=19?'night':h<10?'morning':h<16?'day':'evening';}
const DAY_START=8,DAY_CAP=15.5,TIME_RATE=1/75;   // a new day starts at 8:00; on its own the clock runs one hour every 75 s up to the cap
// the light through the day: sky tint, fog, hemisphere sky/ground/strength, sun colour/strength/height, and how much the night lights glow
const LIGHT=[[0,'#26315a','#141c34','#5a6ea0','#262430',0.34,'#a8bce8',0.3,0.9,1],[5,'#26315a','#141c34','#5a6ea0','#262430',0.34,'#a8bce8',0.3,0.9,1],
  [6.5,'#f6c8b0','#e6d6d0','#f0dcd0','#7a6a5a',0.5,'#ffc89a',0.7,0.25,0.3],[8.5,'#fff4e8','#e2eef2','#eef4ff','#8a7c66',0.58,'#fff0d8',0.9,0.7,0],
  [10,'#ffffff','#d6edf6','#e6f3ff','#8a7c66',0.62,'#fff3dc',0.95,0.95,0],[16,'#ffffff','#d6edf6','#e6f3ff','#8a7c66',0.62,'#fff3dc',0.95,0.95,0],
  [17.5,'#ffc49a','#f2c6a2','#ffd8b8','#7a5e4a',0.55,'#ffb070',0.9,0.35,0],[18.7,'#e88a78','#c88a86','#d8a0a0','#5a4448',0.45,'#ff7a48',0.6,0.1,0.4],
  [19.6,'#6a5c8c','#4a4a70','#7a78a8','#3a3440',0.38,'#c08ab0',0.25,0.15,0.85],[21,'#26315a','#141c34','#5a6ea0','#262430',0.34,'#a8bce8',0.3,0.9,1],
  [24,'#26315a','#141c34','#5a6ea0','#262430',0.34,'#a8bce8',0.3,0.9,1]].map(([h,...v])=>({h,v:v.map(x=>typeof x==='string'?new THREE.Color(x):x)}));
const SUN_H=new THREE.Vector2(-0.55,-0.4).normalize(),LC=[0,1,2,3,5].map(()=>new THREE.Color());
// night lights: glows on the coast-road lamps and the pier lamp, the lighthouse and its turning beam, the blinking light on the radio mast, stars
const GLOW_TEX=canvasTex(64,64,(c,w,h)=>{const g=c.createRadialGradient(32,32,0,32,32,32);g.addColorStop(0,'rgba(255,255,255,1)');g.addColorStop(0.25,'rgba(255,255,255,.55)');g.addColorStop(1,'rgba(255,255,255,0)');c.fillStyle=g;c.fillRect(0,0,w,h);});
function glow(col,x,y,z,s){const m=new THREE.Sprite(new THREE.SpriteMaterial({map:GLOW_TEX,color:col,transparent:true,depthWrite:false,blending:THREE.AdditiveBlending,fog:false}));
  m.position.set(x,y,z);m.scale.setScalar(s);m.visible=false;scene.add(m);return m;}
const NIGHT={lamps:LAMPS.map(e=>glow('#ffd9a0',e.x,5.7,e.z-1.3,2.6)).concat([glow('#ffb0a0',PIER.x0+0.6,PIER.y+3.2,PIER.z1-0.8,2.2)]),
  house:glow('#fff0c0',198,SEA_Y+72.5,760,26),mast:glow('#ff4030',-285,H(-285,-40)+41,-40,7),beam:new THREE.Group(),stars:null};
{ const bm=new THREE.MeshBasicMaterial({color:'#fff3c4',transparent:true,opacity:0,depthWrite:false,blending:THREE.AdditiveBlending,fog:false,side:THREE.DoubleSide});
  for(const s of [1,-1]){const c=new THREE.Mesh(new THREE.ConeGeometry(14,420,16,1,true),bm);c.rotation.z=s*Math.PI/2;c.position.x=s*210;NIGHT.beam.add(c);}
  NIGHT.beam.position.copy(NIGHT.house.position);NIGHT.beam.visible=false;NIGHT.beam.userData.m=bm;scene.add(NIGHT.beam);
  const n=700,pos=new Float32Array(n*3),r=mulberry(31);for(let k=0;k<n;k++){const a=r()*TAU,e=0.08+Math.pow(r(),0.7)*1.4;pos.set([Math.cos(a)*Math.cos(e)*2800,Math.sin(e)*2800,Math.sin(a)*Math.cos(e)*2800],k*3);}
  const g=new THREE.BufferGeometry();g.setAttribute('position',new THREE.BufferAttribute(pos,3));
  NIGHT.stars=new THREE.Points(g,new THREE.PointsMaterial({color:'#ffffff',size:2,sizeAttenuation:false,transparent:true,opacity:0,depthWrite:false,fog:false}));NIGHT.stars.renderOrder=-9;dome.add(NIGHT.stars);}
function applyLight(h){h=((h%24)+24)%24;let k=0;while(k<LIGHT.length-2&&LIGHT[k+1].h<=h)k++;
  const A=LIGHT[k],B=LIGHT[k+1],t=smooth(clamp((h-A.h)/(B.h-A.h),0,1)),v=k2=>typeof A.v[k2]==='number'?lerp(A.v[k2],B.v[k2],t):null;
  [0,1,2,3,5].forEach((i,j)=>LC[j].copy(A.v[i]).lerp(B.v[i],t));
  dome.material.color.copy(LC[0]);scene.background.copy(LC[1]);scene.fog.color.copy(LC[1]);hemi.color.copy(LC[2]);hemi.groundColor.copy(LC[3]);hemi.intensity=v(4);
  sun.color.copy(LC[4]);sun.intensity=v(6);const el=v(7);sunDir.set(SUN_H.x*Math.cos(el),Math.sin(el),SUN_H.y*Math.cos(el));
  const g=v(8),on=g>0.01;for(const m of NIGHT_MATS)m.emissiveIntensity=g*0.85;for(const m of NIGHT.lamps){m.visible=on;m.material.opacity=g;}
  NIGHT.house.visible=NIGHT.beam.visible=on&&!!flag('lighthouse_lit');   // the lighthouse has been dark for thirty yearsNIGHT.house.material.opacity=g;NIGHT.beam.userData.m.opacity=0.3*g;NIGHT.beam.rotation.y=clock*0.6;
  NIGHT.mast.visible=on&&!flag('tower_quiet')&&(clock*1.2%1)<0.45;NIGHT.mast.material.opacity=g;NIGHT.stars.material.opacity=clamp(g*1.3-0.3,0,1);}

/* running events */
const ST={run:null,actor:null,cam:null,tween:null,scanT:0,marks:{},phase:null};
const storyBusy=()=>!!ST.run;
const storyFree=()=>RACE.on||!!URA.chase||ogBusy()||lightsBusy();   // events during which the board is yours
const flag=k=>SAVE.flags[k]||0;
function cond(w){if(!w)return true;if(typeof w==='function')return!!w();
  if(w.day!=null&&SAVE.day!==w.day)return false;if(w.minDay!=null&&SAVE.day<w.minDay)return false;
  if(w.phase&&![].concat(w.phase).includes(phaseOf(SAVE.hour)))return false;
  if(w.hour&&(SAVE.hour<w.hour[0]||SAVE.hour>=w.hour[1]))return false;
  for(const k in w.flags||{})if(flag(k)!==w.flags[k])return false;
  for(const k in w.min||{})if(flag(k)<w.min[k])return false;
  for(const k in w.max||{})if(flag(k)>w.max[k])return false;
  if(w.seen&&![].concat(w.seen).every(id=>SAVE.seen[id]))return false;
  if(w.unseen&&[].concat(w.unseen).some(id=>SAVE.seen[id]))return false;
  for(const k in w.quest||{})if(qs(k).state!==w.quest[k])return false;
  if(w.test&&!w.test())return false;return true;}
const ready=e=>!(e.once!==false&&SAVE.seen[e.id])&&cond(e.when);
function findEvent(kind,arg){return EVENTS.find(e=>{const o=e.on||{};
  if(kind==='talk')return o.talk===arg&&ready(e);
  if(kind==='near')return o.near&&Math.hypot(P.x-o.near[0],P.z-o.near[1])<o.near[2]&&ready(e);
  if(kind==='night')return o.night&&ready(e);
  if(kind==='auto')return!e.on&&ready(e);return false;});}
const whoName=w=>w==='nagi'?'ナギ':NPCS[w]?NPCS[w].name||'町の人':w;
const sleepP=s=>new Promise(r=>setTimeout(r,s*1000));
function sayP(who,lines){if(!ST.cam&&NPCS[who]&&Math.hypot(P.x-NPCS[who].x,P.z-NPCS[who].z)<8)ST.actor=NPCS[who];talkNpc=ST.actor;return new Promise(r=>say(whoName(who),lines,r));}
// a question with buttons under the dialog text; 1–4 on the keyboard pick too
function askP(who,text,labels){talkNpc=ST.actor;return new Promise(res=>{say(whoName(who),[text],null);DLG.choice=true;const box=$('dchoices');box.innerHTML='';$('dialog').classList.add('choosing');
  const pickIt=i=>{box.innerHTML='';$('dialog').classList.remove('choosing');DLG=null;$('dialog').hidden=true;res(i);};DLG.pick=pickIt;DLG.n=labels.length;
  labels.forEach((l,i)=>{const b=document.createElement('button');const k=document.createElement('kbd');k.textContent=i+1;b.append(k,document.createTextNode(l));
    b.addEventListener('click',e=>{e.stopPropagation();pickIt(i);});box.appendChild(b);});
  setTimeout(()=>box.firstChild&&box.firstChild.focus({preventScroll:true}),0);});}
function fadeP(out){$('fade').style.opacity=out?1:0;return sleepP(0.85);}
function hourP(to,sec){return new Promise(res=>{ST.tween={from:SAVE.hour,to,t:0,dur:sec==null?2.5:sec,res};});}
async function nextDay(h){await fadeP(true);SAVE.day++;SAVE.hour=h==null?DAY_START:h;SAVE.cap=DAY_CAP;renderClock();save();await sleepP(0.6);
  toast(`${SAVE.day}日目の朝`,true);await fadeP(false);}
function setCam(a){if(a[0]==='off'){ST.cam=null;document.body.classList.remove('cine');return;}
  document.body.classList.add('cine');
  if(a[0]==='npc'){const n=NPCS[a[1]],m=new THREE.Vector3((P.x+n.x)/2,P.y,(P.z+n.z)/2),d=new THREE.Vector3(n.x-P.x,0,n.z-P.z).normalize(),side=new THREE.Vector3(-d.z,0,d.x);
    ST.cam={pos:m.clone().addScaledVector(side,a[2]||3.4).setY(m.y+1.5),look:m.clone().setY(m.y+1.15),rate:3};return;}
  if(a[0]==='over'){const n=NPCS[a[1]],d=new THREE.Vector3(P.x-n.x,0,P.z-n.z).normalize(),side=new THREE.Vector3(-d.z,0,d.x);   // over Nagi's shoulder, looking at someone
    ST.cam={pos:new THREE.Vector3(P.x,P.y+1.65,P.z).addScaledVector(d,2.4).addScaledVector(side,0.9),look:new THREE.Vector3(n.x,n.h.g.position.y+1.05,n.z),rate:3};return;}
  const v=x=>new THREE.Vector3(...x);ST.cam={pos:v(a[0]),look:v(a[1]),rate:a[2]||2};if(a[3]==='cut')camInit=false;}
async function steps(list){for(const s of list||[])if(await step(s)==='stop')return'stop';}
async function step(s){const [op,...a]=s;switch(op){
  case 'say':await sayP(a[0],a.slice(1));break;                         // ['say', who, line, line…]  who: an NPC id, 'nagi', '' for narration, or any name
  case 'ask':{const opts=a[2].filter(o=>cond(o[2])),i=await askP(a[0],a[1],opts.map(o=>o[0]));   // ['ask', who, question, [[label, [steps…], condition?], …]]
    if(a[3])SAVE.flags[a[3]]=a[2].indexOf(opts[i])+1;                    //   an optional 4th item names a flag that records the answer (1, 2, … in the written order)
    return steps(opts[i][1]);}
  case 'set':SAVE.flags[a[0]]=a[1]===undefined?1:a[1];break;           // ['set', flag, value]
  case 'add':SAVE.flags[a[0]]=flag(a[0])+(a[1]==null?1:a[1]);break;    // ['add', flag, n]  e.g. friendship points
  case 'if':return steps(cond(a[0])?a[1]:a[2]);                         // ['if', condition, [then…], [else…]]  condition as in `when`
  case 'time':await hourP(a[0],a[1]);break;                             // ['time', hour, seconds]  move the clock (and the light) to that hour
  case 'cap':SAVE.cap=a[0];break;                                       // ['cap', hour]  how far the clock may run on its own today
  case 'day':await nextDay(a[0]);break;                                 // ['day', hour?]  fade out, next morning
  case 'fade':await fadeP(a[0]==='out');break;                          // ['fade', 'out'|'in']
  case 'cam':setCam(a);break;                                           // ['cam', [x,y,z], [lookX,lookY,lookZ], rate?, 'cut'?] / ['cam','npc',id] (from the side) / ['cam','over',id] (over Nagi's shoulder) / ['cam','off']
  case 'wait':await sleepP(a[0]);break;                                 // ['wait', seconds]
  case 'warp':P.x=a[0];P.z=a[1];if(a[2]!=null)P.yaw=a[2];P.v=0;P.vy=0;P.air=false;P.y=G(P.x,P.z);camInit=false;break;   // ['warp', x, z, yaw?]
  case 'money':SAVE.money+=a[0];toast(`${a[0]>0?'+':''}${a[0]}円`,true);renderHUD();break;
  case 'item':addItem(a[0],a[1]==null?1:a[1]);toast(`${ITEMS[a[0]].name}をもらった`);break;
  case 'quest':accept(QBY(a[0]));break;                                 // ['quest', id]  take on an errand
  case 'toast':toast(a[0],a[1]);break;
  case 'call':await a[0]();break;
  case 'night':{const e=findEvent('night');if(e){SAVE.seen[e.id]=1;return steps(e.script);}break;}   // ['night']  the first ready event marked on:{night:true}                                       // ['call', fn]  anything the data cannot say
  case 'race':{const t=await raceP(a[0]);SAVE.flags[a[1]]=t<0?-1:Math.round(t*10);break;}   // ['race', {from:[x,z,yaw], to:[x,z,r], limit}, flag]  the time in tenths of a second, -1 if over the limit
  case 'fireworks':fireworks(a[0]);break;
  case 'chase':await chaseP();break;                                     // ['chase']  in 裏海街: the big shadow chases you to the west tunnel
  case 'ura':if(a[0])uraEnter();else uraExit();break;
  case 'ogscene':ogScene(a[0]);break;                                   // ['ogscene', true|false]  the black van parked by the east tunnel, Kurosaki and his men round it
  case 'pursuit':await pursuitP(a[0]);break;                            // ['pursuit', {from:[x,z,yaw], to:[x,z,r], hint}]  the men run after you
  case 'vanchase':await vanChaseP();break;
  case 'lights':await lightsP(a[0]);break;                               // ['lights', {pts:[{name,x,z}…], limit}]  gather the five lights before time runs out
  case 'credits':await creditsP();break;                              // ['vanchase']  catch the black van on the coast road                   // ['ura', true|false]  enter or leave 裏海街                               // ['fireworks', seconds]
  case 'stop':return'stop';}}
async function runEvent(e,npc){ST.run=e;ST.actor=npc||null;talkNpc=ST.actor;$('prompt').hidden=true;
  try{await steps(e.script);}catch(err){console.error('event',e.id,err);}
  SAVE.seen[e.id]=1;ST.run=null;ST.actor=null;talkNpc=null;setCam(['off']);if($('fade').style.opacity==='1')fadeP(false);save();renderHUD();}
function renderClock(){$('clock').textContent=`${SAVE.day}日目・${PHASE_NAME[phaseOf(SAVE.hour)]}`;}
// every frame: the clock and the light, the event markers, and the events that start by place or by time
function updateStory(dt){const tw=ST.tween;updateRace(dt);updateFestival(dt);updateOG(dt);updateLights(dt);
  if(tw){tw.t+=dt;SAVE.hour=lerp(tw.from,tw.to,smooth(clamp(tw.t/tw.dur,0,1)));if(tw.t>=tw.dur){ST.tween=null;SAVE.hour=tw.to;tw.res();}}
  else if(state==='play'&&!ST.run&&!DLG&&!modal&&SAVE.hour<SAVE.cap)SAVE.hour=Math.min(SAVE.cap,SAVE.hour+dt*TIME_RATE);
  applyLight(SAVE.hour);updateUra(dt);const ph=phaseOf(SAVE.hour);if(ph!==ST.phase){ST.phase=ph;renderClock();}
  const calm=!!(DLG||modal||ST.run)||state!=='play';
  for(const e of EVENTS){const id=e.on&&e.on.talk;if(!id||!e.mark)continue;const n=NPCS[id];const m=ST.marks[e.id]||(ST.marks[e.id]=marker(MK.quest));
    m.visible=!calm&&!URA.on&&ready(e);if(m.visible)m.position.set(n.x,n.h.g.position.y+(n.mode==='sit'?1.75:2.25)+Math.sin(clock*3)*0.08,n.z);}
  if(calm||DRONE.active)return;ST.scanT-=dt;if(ST.scanT>0)return;ST.scanT=0.25;
  const e=findEvent('near')||findEvent('auto');if(e)runEvent(e);}
