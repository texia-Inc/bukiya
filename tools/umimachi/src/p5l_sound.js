
/* ---------- sound: all of it made with Web Audio as it plays, no sound files ----------
   The board rolling (louder and brighter with speed, rougher on sand), the wind at speed, kicks, pops, landings and grinds,
   footsteps; the sea, cicadas by day and crickets at night, a low hum in 裏海街; the tram's bell, doors, motor and the
   clack of the rail joints, the level crossings; the racers' engines and tyres; the drone fight, fireworks, coins, the
   camera, the dialogue. Browsers allow no sound before the first tap or key, so it starts then; M (or the 音 button)
   turns it off and on, and that is remembered. Most of it watches the game's state each frame rather than being called. ---------- */
const SND={ctx:null,on:store.get('umimachi_sound')!=='0',L:{},prev:{},dist:{},nextX:0,nextCricket:0};
function sndInit(){const S=SND;if(S.ctx){if(S.ctx.state==='suspended')S.ctx.resume();return;}
  const AC=window.AudioContext||window.webkitAudioContext;if(!AC)return;const c=S.ctx=new AC();
  const comp=c.createDynamicsCompressor();comp.connect(c.destination);S.master=c.createGain();S.master.gain.value=S.on?0.9:0;S.master.connect(comp);
  const nb=c.createBuffer(1,c.sampleRate*2,c.sampleRate),d=nb.getChannelData(0);for(let i=0;i<d.length;i++)d[i]=Math.random()*2-1;S.noise=nb;
  // the loops: noise (or an oscillator) through a filter into a gain that the update turns up and down
  const loop=(type,f,q,osc)=>{let src;if(osc){src=c.createOscillator();src.type=osc;src.frequency.value=f;}else{src=c.createBufferSource();src.buffer=nb;src.loop=true;}
    const fl=c.createBiquadFilter();fl.type=type;fl.frequency.value=osc?f*4:f;fl.Q.value=q;const g=c.createGain();g.gain.value=0;src.connect(fl);fl.connect(g);g.connect(S.master);
    src.start(0,osc?0:Math.random()*1.5);return{src,fl,g};};
  S.L.roll=loop('bandpass',700,0.7);S.L.wind=loop('lowpass',500,0.5);S.L.grind=loop('bandpass',3200,5);S.L.sea=loop('lowpass',420,0.4);
  S.L.motor=loop('lowpass',70,1.2,'sawtooth');S.L.engine=loop('lowpass',90,2,'sawtooth');S.L.tyre=loop('bandpass',2300,4);S.L.ura=loop('lowpass',55,1,'triangle');
  // cicadas: a high band of noise, buzzing on and off thirty times a second
  { const L=S.L.cicada=loop('bandpass',4800,7),am=c.createGain(),lfo=c.createOscillator(),dep=c.createGain();
    L.g.disconnect();L.g.connect(am);am.connect(S.master);am.gain.value=0.5;lfo.frequency.value=31;dep.gain.value=0.5;lfo.connect(dep);dep.connect(am.gain);lfo.start();}}
function sndToggle(){const S=SND;S.on=!S.on;store.set('umimachi_sound',S.on?'1':'0');sndInit();if(S.master)S.master.gain.setTargetAtTime(S.on?0.9:0,S.ctx.currentTime,0.05);
  $('soundBtn').textContent=S.on?'音：オン':'音：オフ';toast(S.on?'音をオンにした':'音をオフにした');}
for(const ev of ['pointerdown','keydown','touchstart'])window.addEventListener(ev,sndInit,{passive:true});
$('soundBtn').textContent=SND.on?'音：オン':'音：オフ';$('soundBtn').addEventListener('click',sndToggle);
window.addEventListener('keydown',e=>{if(e.code==='KeyM'&&!e.repeat)sndToggle();});

/* one-shots */
const sndT=()=>SND.ctx.currentTime;
function tone(f,dur,type,vol,f2,at){const S=SND;if(!S.ctx||!S.on)return;const c=S.ctx,t=sndT()+(at||0),o=c.createOscillator(),g=c.createGain();
  o.type=type||'sine';o.frequency.setValueAtTime(f,t);if(f2)o.frequency.exponentialRampToValueAtTime(f2,t+dur);
  g.gain.setValueAtTime(0,t);g.gain.linearRampToValueAtTime(vol,t+0.005);g.gain.exponentialRampToValueAtTime(0.0008,t+dur);o.connect(g);g.connect(S.master);o.start(t);o.stop(t+dur+0.05);}
function hiss(dur,type,f,vol,q,f2,at){const S=SND;if(!S.ctx||!S.on)return;const c=S.ctx,t=sndT()+(at||0),s=c.createBufferSource(),fl=c.createBiquadFilter(),g=c.createGain();
  s.buffer=S.noise;fl.type=type;fl.frequency.setValueAtTime(f,t);if(f2)fl.frequency.exponentialRampToValueAtTime(f2,t+dur);fl.Q.value=q||0.7;
  g.gain.setValueAtTime(0,t);g.gain.linearRampToValueAtTime(vol,t+0.004);g.gain.exponentialRampToValueAtTime(0.0008,t+dur);s.connect(fl);fl.connect(g);g.connect(S.master);s.start(t,Math.random()*1.5);s.stop(t+dur+0.05);}
function bell(f,vol,at){for(const [k,v] of [[1,1],[2.76,0.45],[5.4,0.25]])tone(f*k,1.1/k+0.2,'sine',vol*v,null,at);}
const att=(d,r)=>clamp(1-d/r,0,1)**2;
const sfx={
  kick:()=>hiss(0.13,'lowpass',900,0.22),
  pop:()=>{tone(170,0.08,'triangle',0.32,90);hiss(0.05,'highpass',2600,0.22);},
  land:h=>{hiss(0.14,'lowpass',520,0.18+h*0.25);tone(110,0.1,'sine',0.25+h*0.2,55);hiss(0.04,'bandpass',1800,0.15,3,null,0.02);},
  clack:()=>{hiss(0.06,'bandpass',1800,0.28,3);tone(240,0.05,'square',0.06);},
  whoosh:()=>hiss(0.35,'bandpass',500,0.2,1.5,2600),
  step:()=>hiss(0.05,'lowpass',650,0.07),
  bump:()=>{tone(90,0.14,'sine',0.35,45);hiss(0.12,'lowpass',700,0.25);},
  blip:()=>tone(900,0.05,'sine',0.06),
  coin:()=>{tone(1320,0.08,'square',0.06);tone(1760,0.3,'square',0.06,null,0.08);},
  pay:()=>{tone(1046,0.12,'triangle',0.12);tone(784,0.18,'triangle',0.12,null,0.1);},
  shutter:()=>{hiss(0.03,'highpass',3000,0.35);hiss(0.05,'highpass',2200,0.3,0.7,null,0.08);},
  tramBell:v=>{bell(1250,0.22*v);bell(1250,0.22*v,0.28);},
  doors:v=>hiss(0.7,'lowpass',2600,0.16*v,0.7,450),
  joint:v=>{tone(70,0.09,'sine',0.25*v,50);hiss(0.05,'lowpass',420,0.18*v);tone(70,0.09,'sine',0.22*v,50,0.13);hiss(0.05,'lowpass',420,0.15*v,0.7,null,0.13);},
  xing:(v,hi)=>tone(hi?820:700,0.35,'triangle',0.16*v),
  beep:()=>tone(880,0.16,'square',0.07),
  go:()=>tone(1760,0.45,'square',0.07),
  shot:()=>{hiss(0.08,'highpass',1200,0.3);tone(210,0.06,'square',0.12,80);},
  boom:v=>{hiss(0.9,'lowpass',500,0.55*v,0.7,70);tone(62,0.6,'sine',0.45*v,28);},
  firework:()=>{tone(500,0.9,'sine',0.05,1300);setTimeout(()=>{sfx.boom(0.6);for(let i=0;i<7;i++)hiss(0.04,'highpass',3500,0.12,0.7,null,0.25+Math.random()*0.7);},900);},
  win:()=>[523,659,784,1046].forEach((f,i)=>tone(f,0.35,'triangle',0.13,null,i*0.12)),
  lose:()=>[392,330,262].forEach((f,i)=>tone(f,0.4,'triangle',0.11,null,i*0.16)),
  cricket:()=>{for(let i=0;i<3;i++)tone(4300,0.035,'sine',0.025,null,i*0.06);}};
// the drone fight and the fireworks call their own effects
{ const s0=shoot;shoot=function(...a){sfx.shot();return s0.apply(this,a);};
  const b0=boom;boom=function(p){sfx.boom(att(Math.hypot(p.x-P.x,p.z-P.z),160)+0.15);return b0(p);};
  const f0=burst;burst=function(p,col){setTimeout(()=>sfx.boom(0.35),Math.min(1500,Math.hypot(p.x-P.x,p.z-P.z)*3));for(let i=0;i<6;i++)hiss(0.04,'highpass',3500,0.06,0.7,null,0.4+Math.random()*0.8);return f0(p,col);};}

function updateSound(dt){const S=SND,c=S.ctx;if(!c)return;const t=c.currentTime,L=S.L,pv=S.prev,set=(n,v,tc)=>n.setTargetAtTime(v,t,tc||0.08);
  const play=state==='play',ride=RIDE.on,board=play&&!P.foot&&!ride,sand=P.z>SHORE+0.5&&AREA==='town';
  // the board and the wind
  set(L.roll.g.gain,board&&!P.air&&!P.grind?clamp(P.v/11,0,1)*0.32*(sand?1.3:1):0);set(L.roll.fl.frequency,sand?260+P.v*30:320+P.v*95);
  set(L.wind.g.gain,play&&!ride?clamp((P.v-5)/10,0,1)**2*0.22+(P.air?clamp(-P.vy/14,0,1)*0.15:0):0);
  set(L.grind.g.gain,play&&P.grind?0.2:0);
  // footsteps
  if(play&&P.foot&&!ride&&!P.air&&P.v>0.6){S.dist.step=(S.dist.step||0)+P.v*dt;if(S.dist.step>(P.v>4?1.1:0.75)){S.dist.step=0;sfx.step();}}
  // moments: pop, landing, kick, on and off the board, a trick, a bump
  if(play&&!ride){
    if(P.air&&!pv.air&&!P.foot&&P.vy>3)sfx.pop();
    if(!P.air&&pv.air){const h=clamp(-(pv.vy||0)/14,0,1);if(!P.foot)sfx.land(h);else if(h>0.2)sfx.step();}
    if(P.kicked&&!pv.kicked&&!P.foot)sfx.kick();
    if(P.foot!==pv.foot&&pv.foot!==undefined)sfx.clack();
    if(P.trick&&!pv.trick)sfx.whoosh();
    if(P.bump>(pv.bump||0)+0.15)sfx.bump();}
  pv.air=P.air;pv.vy=P.vy;pv.kicked=P.kicked;pv.foot=P.foot;pv.trick=!!P.trick;pv.bump=P.bump;
  // money, dialogue, the camera
  if(play&&pv.money!=null&&SAVE.money!==pv.money)(SAVE.money>pv.money?sfx.coin:sfx.pay)();pv.money=play?SAVE.money:null;
  const dl=$('dialog'),tx=dl.hidden?'':$('dtext').textContent;if(tx&&tx!==pv.text)sfx.blip();pv.text=tx;
  if(photoReq&&!pv.photo)sfx.shutter();pv.photo=photoReq;
  // the world around: the sea, cicadas or crickets, 裏海街's hum
  const town=AREA==='town',hr=SAVE.hour||12,day=hr>=8&&hr<17.5,night=hr>=19||hr<5,inside=ride?0.45:1;
  set(L.sea.g.gain,play&&town&&!URA.on?att(Math.max(0,Math.abs(P.z-SHORE)-8),110)*(0.16+0.07*Math.sin(clock*0.5))*inside:0,0.3);
  set(L.cicada.g.gain,play&&day&&!URA.on?(town?0.035:0.07)*inside:0,0.5);
  if(play&&night&&!URA.on&&clock>S.nextCricket){S.nextCricket=clock+0.5+Math.random()*1.2;sfx.cricket();}
  set(L.ura.g.gain,play&&URA.on?0.12:0,0.5);
  // the trams: motor, rail joints, the bell as they leave, the doors
  for(const T of [TRAM,INKT]){const here=(T===INKT)===(AREA==='inaka'),k=T===TRAM?'t':'i';if(!here)continue;
    let d=1e9;for(const g of T.cars)d=Math.min(d,Math.hypot(g.position.x-P.x,g.position.z-P.z));if(ride&&RIDE.train===T)d=0;const v=att(d,90);
    if(T===(AREA==='inaka'?INKT:TRAM)){set(L.motor.g.gain,play?(T.v>0.2?0.06+0.07*T.v/7:0.015)*v:0);set(L.motor.src.frequency,55+T.v*11);set(L.motor.fl.frequency,180+T.v*40);}
    S.dist[k]=(S.dist[k]||0)+T.v*dt;if(S.dist[k]>12.6){S.dist[k]=0;if(play&&v>0.02)sfx.joint(v*(ride&&RIDE.train===T?1:0.7));}
    const moving=T.v>0.3;if(moving&&!pv[k+'mv']&&play&&v>0.02)sfx.tramBell(v);pv[k+'mv']=moving;
    const open=T.door>0.5;if(open!==pv[k+'door']&&pv[k+'door']!==undefined&&play&&v>0.02)sfx.doors(v);pv[k+'door']=open;}
  // level crossings ring while the gates are down
  if(play&&town&&clock>S.nextX){let best=0;for(const X of XINGS)if(X.down>0.1)best=Math.max(best,att(Math.hypot(X.x-P.x,TRAM_Z-P.z),130));
    if(best>0.01){S.nextX=clock+0.42;S.xhi=!S.xhi;sfx.xing(best,S.xhi);}}
  // the racer's car: an engine that climbs through the gears, tyres that squeal in the hairpins
  const TG=TOUGE;let eng=0,ty=0;
  if(play&&TG.res&&TG.car){const d=TG.car.position.distanceTo(_tq.set(P.x,P.y,P.z)),v=att(d,160),gear=Math.floor(TG.cv/5.5),fr=(TG.cv%5.5)/5.5;
    eng=(0.08+0.06*fr)*v;set(L.engine.src.frequency,TG.on?70+fr*95+gear*10:62+Math.sin(clock*9)*6,0.04);set(L.engine.fl.frequency,TG.on?300+TG.cv*40:240);
    ty=Math.abs(TG.drift)>0.2&&TG.cv>5?0.13*v:0;
    const cnt=TG.on?-1:Math.ceil(TG.count-0.2);if(cnt!==pv.tcount){if(cnt>0&&cnt<4)sfx.beep();else if(cnt<=0&&pv.tcount>0)sfx.go();}pv.tcount=cnt;}
  set(L.engine.g.gain,eng);set(L.tyre.g.gain,ty);
  if(RACE.res){const cnt=RACE.on?-1:Math.ceil(RACE.count-0.2);if(cnt!==pv.rcount){if(cnt>0&&cnt<4)sfx.beep();else if(cnt<=0&&pv.rcount>0)sfx.go();}pv.rcount=cnt;}}
