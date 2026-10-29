
/* ---------- the true route "灯台": once all three endings are seen. The old custom of the town: on a summer night the lighthouse
   was lit with fire shared from five lights of the town. While the radio mast howls, Nagi skates round the five places and
   brings the light across to the island. Then the ending, and the credits. ---------- */
const LIGHTS={run:null,marks:[]};
// collect the five lights in any order before the time runs out; out of time, they go out and you start again where you are
function lightsP(o){return new Promise(res=>{ST.actor=null;talkNpc=null;LIGHTS.run={o,res,t:0,got:[]};
  if(!LIGHTS.marks.length)LIGHTS.marks=o.pts.map(()=>{const m=marker(MK.target);m.scale.set(1.5,1.5,1);return m;});$('fade').style.opacity=0;renderHUD();});}
const lightsBusy=()=>!!LIGHTS.run;
function lightsHUD(tr){const L=LIGHTS.run;tr.hidden=false;tr.innerHTML='';const b=document.createElement('b'),s=document.createElement('span'),m=document.createElement('span');s.className='step';m.className='meter';
  b.textContent='五つの灯り';s.textContent='電波塔が鳴りやむ前に、町の5か所で灯りをもらう：'+L.o.pts.filter((p,k)=>!L.got.includes(k)).map(p=>p.name).join('・');
  m.textContent=`灯り ${L.got.length} / ${L.o.pts.length}　のこり ${Math.max(0,Math.ceil(L.o.limit-L.t))} 秒`;tr.append(b,s,m);}
function updateLights(dt){const L=LIGHTS.run;if(!L)return;L.t+=dt;
  L.o.pts.forEach((p,k)=>{const m=LIGHTS.marks[k];m.visible=!L.got.includes(k);m.position.set(p.x,G(p.x,p.z)+3.2+Math.sin(clock*3+k)*0.12,p.z);
    if(m.visible&&Math.hypot(P.x-p.x,P.z-p.z)<4.5){L.got.push(k);toast(`${p.name}の灯りをもらった（${L.got.length}/${L.o.pts.length}）`,true);
      const g=glow('#ffd98a',p.x,G(p.x,p.z)+1.6,p.z,3);g.visible=true;fx(g,1.2,(f,k2)=>{g.material.opacity=1-k2;g.scale.setScalar(3+k2*6);});}});
  lightsHUD($('tracker'));$('hurt').style.opacity=0.12+0.08*Math.sin(clock*7);   // the mast's howl at the edge of the screen
  if(L.got.length>=L.o.pts.length){LIGHTS.run=null;for(const m of LIGHTS.marks)m.visible=false;$('hurt').style.opacity=0;renderHUD();L.res();}
  else if(L.t>L.o.limit){L.t=0;L.got=[];toast('電波塔の音に、灯りがかき消された……。もう一度！',true);}}
// the credits: a quiet card over the last morning
function creditsP(){return new Promise(res=>{const c=$('credits');c.hidden=false;c.style.opacity=0;requestAnimationFrame(()=>{c.style.opacity=1;});
  const done=()=>{c.removeEventListener('click',done);c.style.opacity=0;setTimeout(()=>{c.hidden=true;res();},800);};
  setTimeout(()=>c.addEventListener('click',done),1500);setTimeout(done,16000);});}
