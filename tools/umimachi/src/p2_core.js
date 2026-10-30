<script>
function main(){
"use strict";
const $=id=>document.getElementById(id);
if(!window.THREE){$('loading').textContent='3Dライブラリを読み込めませんでした。再読み込みしてください。';return;}

/* ---------- utils ---------- */
function mulberry(a){return function(){a|=0;a=a+0x6D2B79F5|0;let t=Math.imul(a^a>>>15,1|a);t=t+Math.imul(t^t>>>7,61|t)^t;return((t^t>>>14)>>>0)/4294967296;}}
function hash(i,j){let h=(Math.imul(i|0,374761393)+Math.imul(j|0,668265263))|0;h=Math.imul(h^(h>>>13),1274126177);h^=h>>>16;return(h>>>0)/4294967296;}
function vnoise(x,y){const xi=Math.floor(x),yi=Math.floor(y),xf=x-xi,yf=y-yi,u=xf*xf*(3-2*xf),v=yf*yf*(3-2*yf);
  const a=hash(xi,yi),b=hash(xi+1,yi),c=hash(xi,yi+1),d=hash(xi+1,yi+1);return a+(b-a)*u+(c-a)*v+(a-b-c+d)*u*v;}
const clamp=(v,a,b)=>v<a?a:v>b?b:v,lerp=(a,b,t)=>a+(b-a)*t,smooth=t=>t*t*(3-2*t);
const TAU=Math.PI*2;
const store={get(k){try{return localStorage.getItem(k);}catch(e){return null;}},set(k,v){try{localStorage.setItem(k,v);return true;}catch(e){return false;}}};
const rnd=mulberry(7310);
const pick=a=>a[Math.floor(rnd()*a.length)];

/* ---------- renderer & look ---------- */
const canvas=$('c');
const renderer=new THREE.WebGLRenderer({canvas,antialias:true});
renderer.setPixelRatio(Math.min(window.devicePixelRatio||1,1.75));
renderer.shadowMap.enabled=true;renderer.shadowMap.type=THREE.PCFSoftShadowMap;
const scene=new THREE.Scene();
scene.background=new THREE.Color('#d6edf6');
scene.fog=new THREE.Fog('#d6edf6',260,2600);
const camera=new THREE.PerspectiveCamera(60,1,0.15,4200);
function resize(){const w=window.innerWidth,h=window.innerHeight;renderer.setSize(w,h,false);camera.aspect=w/h;camera.updateProjectionMatrix();}
window.addEventListener('resize',resize);resize();
const hemi=new THREE.HemisphereLight('#e6f3ff','#8a7c66',0.62);scene.add(hemi);
const sun=new THREE.DirectionalLight('#fff3dc',0.95);scene.add(sun);scene.add(sun.target);
hemi.layers.enable(1);sun.layers.enable(1);   // layer 1: the heroine drawn on top while dressing
sun.castShadow=true;sun.shadow.mapSize.set(2048,2048);
{const sc=sun.shadow.camera;sc.left=-16;sc.right=16;sc.top=16;sc.bottom=-16;sc.near=1;sc.far=140;}
sun.shadow.bias=-0.0005;
const sunDir=new THREE.Vector3(-0.55,0.95,-0.4).normalize();
function canvasTex(w,h,draw,repeat){const c=document.createElement('canvas');c.width=w;c.height=h;draw(c.getContext('2d'),w,h);
  const t=new THREE.CanvasTexture(c);if(repeat){t.wrapS=t.wrapT=THREE.RepeatWrapping;}t.anisotropy=Math.min(8,renderer.capabilities.getMaxAnisotropy());return t;}
const GRAD=(()=>{const d=new Uint8Array([125,125,125,255,195,195,195,255,255,255,255,255]);const t=new THREE.DataTexture(d,3,1,THREE.RGBAFormat);
  t.minFilter=t.magFilter=THREE.NearestFilter;t.generateMipmaps=false;t.needsUpdate=true;return t;})();
const TM={};
function tm(c,opt){const key=c+(opt?JSON.stringify(Object.keys(opt).map(k=>k+':'+(opt[k]&&opt[k].uuid||opt[k]))):'');if(TM[key])return TM[key];
  return TM[key]=new THREE.MeshToonMaterial(Object.assign({color:c,gradientMap:GRAD},opt||{}));}
function tmap(map,opt){return new THREE.MeshToonMaterial(Object.assign({color:'#ffffff',map,gradientMap:GRAD},opt||{}));}
const OL={};
function olMat(w){const key=w.toFixed(4);if(OL[key])return OL[key];
  const m=new THREE.MeshBasicMaterial({color:'#2d241d',side:THREE.BackSide});
  m.onBeforeCompile=sh=>{sh.vertexShader=sh.vertexShader.replace('#include <begin_vertex>','vec3 transformed = position + normal * '+key+';');};
  m.customProgramCacheKey=()=>'ol'+key;return OL[key]=m;}
function outline(mesh,w){const o=new THREE.Mesh(mesh.geometry,olMat(w));o.castShadow=false;mesh.add(o);return mesh;}
// r128 shares one shader between instanced meshes with and without colours, so every instanced mesh gets a colour buffer
const WHITE=new THREE.Color(1,1,1);
function ensureColor(im){if(!im.instanceColor)for(let k=0;k<im.count;k++)im.setColorAt(k,WHITE);return im;}
function olInst(im,w){const o=new THREE.InstancedMesh(im.geometry,olMat(w),im.count);o.instanceMatrix=im.instanceMatrix;ensureColor(o);o.frustumCulled=false;im.add(o);o.matrixAutoUpdate=false;return im;}

/* sky: painted summer cumulus on a dome that follows the camera */
const dome=new THREE.Mesh(new THREE.SphereGeometry(3000,48,24),new THREE.MeshBasicMaterial({side:THREE.BackSide,fog:false,depthWrite:false}));
dome.renderOrder=-10;scene.add(dome);
function paintCloud(g,cx,base,size,cols,r){
  // a cumulus: a heap of soft round puffs, tallest in the middle, cut flat at the bottom; the underside is a shaded blue-grey
  // and the sunlit tops are drawn over it a little up and to the left, every puff fading out at its edge so the outline stays soft
  const puffs=[],n=12+Math.floor(r()*10);
  for(let k=0;k<n;k++){const t=r()*2-1,hump=1-t*t,rad=size*(0.26+r()*0.3)*(0.55+0.65*hump);puffs.push([cx+t*size*1.7,base-rad*0.35-r()*hump*size*0.7,rad]);}
  for(let k=0;k<3;k++)puffs.push([cx+(r()-0.5)*size*0.9,base-size*(0.6+r()*0.45),size*(0.48+r()*0.25)]);
  g.save();g.beginPath();g.rect(cx-size*4,0,size*8,base);g.clip();
  for(const [x,y,rr] of puffs){const yy=y+rr*0.28,gr=g.createRadialGradient(x,yy,rr*0.15,x,yy,rr*1.05);
    gr.addColorStop(0,'rgba(190,205,226,.95)');gr.addColorStop(0.72,'rgba(196,210,230,.85)');gr.addColorStop(1,'rgba(200,214,232,0)');g.fillStyle=gr;g.beginPath();g.arc(x,yy,rr*1.05,0,7);g.fill();}
  for(const [x,y,rr] of puffs){const ox=x-rr*0.14,oy=y-rr*0.2,gr=g.createRadialGradient(ox-rr*0.25,oy-rr*0.3,rr*0.05,ox,oy,rr*0.95);
    gr.addColorStop(0,'rgba(255,255,255,1)');gr.addColorStop(0.6,'rgba(250,252,255,.96)');gr.addColorStop(1,'rgba(238,244,252,0)');g.fillStyle=gr;g.beginPath();g.arc(ox,oy,rr*0.95,0,7);g.fill();}
  const bg=g.createLinearGradient(0,base-size*0.35,0,base);bg.addColorStop(0,'rgba(180,196,220,0)');bg.addColorStop(1,'rgba(180,196,220,.55)');   // the flat, darker base
  g.fillStyle=bg;g.fillRect(cx-size*2.2,base-size*0.35,size*4.4,size*0.35);
  g.restore();
}
dome.material.map=canvasTex(2048,1024,(g,w,h)=>{const gr=g.createLinearGradient(0,0,0,h);
  gr.addColorStop(0,'#2b7fd8');gr.addColorStop(0.3,'#74bcee');gr.addColorStop(0.495,'#d8eef8');gr.addColorStop(0.52,'#cfe6ee');gr.addColorStop(1,'#cfe6ee');
  g.fillStyle=gr;g.fillRect(0,0,w,h);const r=mulberry(99),cols=['#ffffff','#c5d6e8','#ffffff'];
  g.globalAlpha=0.5;g.fillStyle='#fff';for(let k=0;k<16;k++){const x=r()*w,y=h*(0.16+r()*0.22),l=60+r()*180;g.beginPath();g.ellipse(x,y,l,3+r()*4,0,0,7);g.fill();}
  g.globalAlpha=1;
  for(let k=0;k<26;k++){const el=1.5+Math.pow(r(),1.6)*26,base=h*(0.5-el/180),size=(7+el*1.8)*(0.7+r()*0.6),x=r()*w;
    for(const off of [-w,0,w])paintCloud(g,x+off,base,size,cols,mulberry(500+k));}});
dome.material.map.wrapS=THREE.RepeatWrapping;

/* ---------- terrain ----------
   x runs west to east, z runs from the hilltop (-z) down to the sea (+z). Streets are axis-aligned:
   streets along z climb the hill, streets along x follow the contour and stay level. */
const SEA_Y=-1.2,HILL=0.115,COAST_Z=240,SHORE=247,TRAM_Z=212,CUT_X=232;
// the tram line and the coast road run through level cuttings into the hills on both sides
function cutting(x,z){return Math.abs(x)<CUT_X+2&&(Math.abs(z-TRAM_Z)<6.6||(z>232.4&&z<SHORE+0.5));}
// the hills either side of town: a slope that eases into a broad ridge about 40 m up, then a gentle rise to the edge of the map
function hillY(ax,z){if(ax<=200)return 0;const t=smooth(clamp((ax-200)/115,0,1));return(40*t+Math.max(0,ax-315)*0.12)*(z<SHORE?1:0.7);}
function H(x,z){let y=z<COAST_Z?(COAST_Z-z)*HILL:z<SHORE?0:-(z-SHORE)*0.035;const ax=Math.abs(x);if(ax>200&&!cutting(x,z))y+=hillY(ax,z);return y;}
// the country at the end of the tram line lies far to the east (p5k_inaka.js); its heights come from a baked grid
const INK_X=3000;
const PIER={x0:-82.5,x1:-77.5,z0:250,z1:338,y:0.45};
const RIDGE_DECKS=[{x:318,z:60,yaw:-Math.PI/2,name:'東の峠 見晴らし'},{x:-318,z:-10,yaw:Math.PI/2,name:'西の峠 見晴らし'}];
// the slope between a ridge deck and the town is kept clear of trees so the view stays open
function inDeckView(x,z){for(const d of RIDGE_DECKS){if(Math.sign(x)!==Math.sign(d.x))continue;const ax=Math.abs(x),dx=Math.abs(d.x)-ax;
  if(dx<-6||ax<190)continue;if(Math.abs(z-d.z)<12+dx*0.6)return true;}return false;}
const HILL_TREES=[];   // hill trees, so the camera can keep out of them
function onPier(x,z){return x>PIER.x0&&x<PIER.x1&&z>PIER.z0&&z<PIER.z1;}
// the island out at sea (p5m_shima.js) has heights of its own once it is built
const ISL_Z0=640;let ISL_ON=false;
function G(x,z){if(x>INK_X-600)return inkG(x,z);if(z>ISL_Z0&&ISL_ON)return islG(x,z);let y=H(x,z);if(onPier(x,z)){const t=smooth(clamp((z-PIER.z0)/7,0,1));y=Math.max(y,lerp(H(x,PIER.z0),PIER.y,t));}return y;}

const world=new THREE.Group();scene.add(world);
const COLL=[];   // axis-aligned boxes the board bumps into: {x0,x1,z0,z1,on}
// top: the height you can stand on; anything taller than a hop blocks you, anything lower you can jump onto
const TOPH={vend:1.85,post:1.25,car:1.5,plat:0.86,prop:0.8};
function collide(x0,x1,z0,z1,tag,top){const c={x0:Math.min(x0,x1),x1:Math.max(x0,x1),z0:Math.min(z0,z1),z1:Math.max(z0,z1),on:true,tag};
  c.top=top!==undefined?top:TOPH[tag]!=null?G((c.x0+c.x1)/2,(c.z0+c.z1)/2)+TOPH[tag]:1e9;COLL.push(c);return c;}
function grid(nr,nc,fn,mat,opt){
  const n=nr*nc,pos=new Float32Array(n*3),uv=new Float32Array(n*2),col=opt&&opt.color?new Float32Array(n*3):null;let k=0;
  for(let r=0;r<nr;r++)for(let c=0;c<nc;c++){const p=fn(r,c);pos[k*3]=p[0];pos[k*3+1]=p[1];pos[k*3+2]=p[2];uv[k*2]=p[3]||0;uv[k*2+1]=p[4]||0;
    if(col){col[k*3]=p[5];col[k*3+1]=p[6];col[k*3+2]=p[7];}k++;}
  const idx=[];for(let r=0;r<nr-1;r++)for(let c=0;c<nc-1;c++){const a=r*nc+c,b=a+nc;if(opt&&opt.flip)idx.push(a,a+1,b,a+1,b+1,b);else idx.push(a,b,a+1,a+1,b,b+1);}
  const geo=new THREE.BufferGeometry();geo.setAttribute('position',new THREE.BufferAttribute(pos,3));geo.setAttribute('uv',new THREE.BufferAttribute(uv,2));
  if(col)geo.setAttribute('color',new THREE.BufferAttribute(col,3));geo.setIndex(idx);geo.computeVertexNormals();
  const m=new THREE.Mesh(geo,mat);if(opt&&opt.shadow)m.receiveShadow=true;world.add(m);return m;
}
const dummy=new THREE.Object3D();
function inst(geo,mat,list,place,opt){if(!list.length)return null;const im=new THREE.InstancedMesh(geo,mat,list.length);
  list.forEach((e,k)=>{dummy.position.set(0,0,0);dummy.rotation.set(0,0,0);dummy.scale.set(1,1,1);place(e,dummy);dummy.updateMatrix();im.setMatrixAt(k,dummy.matrix);if(e.col)im.setColorAt(k,e.col);});
  ensureColor(im);if(opt&&opt.cast)im.castShadow=true;if(opt&&opt.recv)im.receiveShadow=true;if(opt&&opt.ol)olInst(im,opt.ol);world.add(im);return im;}
const C3=c=>new THREE.Color(c);

/* ground: gardens and hills, sand, sea floor */
{
  const X0=-340,X1=340,Z0=-260,Z1=440,S=4,nx=(X1-X0)/S+1,nz=(Z1-Z0)/S+1;
  grid(nz,nx,(r,c)=>{const x=X0+c*S,z=Z0+r*S,y=H(x,z),n=vnoise(x/14,z/14),n2=vnoise(x/40+9,z/40);let col;
    if(z>SHORE-1&&Math.abs(x)>203&&y>SEA_Y+0.6){const k=0.8+n*0.3;col=[0.52*k,0.48*k,0.42*k];}
    else if(z>SHORE-1){const wet=clamp((y-SEA_Y)/0.6,0,1);col=y<SEA_Y?[0.62,0.7,0.62]:[lerp(0.78,0.93,wet),lerp(0.72,0.86,wet),lerp(0.55,0.66,wet)];}
    else if(z>COAST_Z-6){col=[0.7,0.68,0.62];}
    else{const k=0.8+n*0.3;col=n2>0.62?[0.3*k,0.45*k,0.24*k]:[0.42*k,0.55*k,0.33*k];if(Math.abs(x)>200||z<-170)col=[0.26*k,0.42*k,0.22*k];}
    return[x,y,z,0,0,...col];},tmap(null,{vertexColors:true}),{color:true,shadow:true});
}
/* the sea, with a moving foam line at the shore */
const waveTex=canvasTex(128,128,(g,w,h)=>{g.fillStyle='#fff';g.fillRect(0,0,w,h);const r=mulberry(3);
  for(let n=0;n<240;n++){g.fillStyle=`rgba(${r()<.5?'185,212,235':'255,255,255'},${0.3+r()*0.5})`;g.fillRect(r()*w,r()*h,6+r()*14,1.5);}},true);
waveTex.repeat.set(260,260);
{const sea=new THREE.Mesh(new THREE.PlaneGeometry(9000,9000).rotateX(-Math.PI/2),new THREE.MeshPhongMaterial({color:'#2a8fcf',map:waveTex,shininess:110,specular:'#ffffff'}));
  sea.position.set(0,SEA_Y,600);world.add(sea);}
const foamTex=canvasTex(256,32,(g,w,h)=>{g.clearRect(0,0,w,h);const r=mulberry(4);for(let n=0;n<70;n++){g.fillStyle=`rgba(255,255,255,${0.35+r()*0.55})`;g.beginPath();g.ellipse(r()*w,h*0.35+r()*h*0.4,6+r()*22,2+r()*3,0,0,7);g.fill();}
  g.fillStyle='rgba(255,255,255,.75)';g.fillRect(0,h*0.42,w,3);},true);
foamTex.repeat.set(40,1);
{const zS=SHORE+(0-SEA_Y)/0.035;
  grid(2,2,(r,c)=>[c?360:-360,SEA_Y+0.03,zS-2+r*5,c?40:0,r],new THREE.MeshBasicMaterial({map:foamTex,transparent:true,depthWrite:false}));}

/* ---------- streets ---------- */
const STREETS=[
  {id:'main',ax:'z',c:0,a:-206,b:247,w:9,sw:2.2,kind:'wide',name:'海へつづく坂'},
  {id:'west',ax:'z',c:-120,a:-150,b:236,w:6,sw:0,kind:'narrow',name:'西の坂道'},
  {id:'east',ax:'z',c:115,a:-110,b:236,w:6.5,sw:0,kind:'narrow',name:'東の坂道'},
  {id:'top',ax:'x',c:-120,a:-165,b:150,w:6,sw:0,kind:'narrow',name:'山手通り'},
  {id:'shop',ax:'x',c:-20,a:-170,b:175,w:8,sw:0,kind:'shop',name:'しおかぜ商店街'},
  {id:'mid',ax:'x',c:90,a:-160,b:160,w:6,sw:0,kind:'narrow',name:'なか通り'},
  {id:'low',ax:'x',c:170,a:-150,b:150,w:6,sw:0,kind:'narrow',name:'浜手通り'},
  {id:'coast',ax:'x',c:COAST_Z,a:-CUT_X,b:CUT_X,w:9,sw:2.2,kind:'wide',name:'海岸通り'},
];
const TRAM_X0=-275,TRAM_X1=275;
function streetBox(S,pad){const h=S.w/2+S.sw+(pad||0);return S.ax==='z'?{x0:S.c-h,x1:S.c+h,z0:S.a,z1:S.b}:{x0:S.a,x1:S.b,z0:S.c-h,z1:S.c+h};}
const roadTex={
  wide:canvasTex(256,512,(g,w,h)=>{g.fillStyle='#5a5b60';g.fillRect(0,0,w,h);const r=mulberry(4);
    for(let n=0;n<9000;n++){g.fillStyle=`rgba(${r()<.5?'255,255,255':'0,0,0'},${r()*0.07})`;g.fillRect(r()*w,r()*h,2,2);}
    g.fillStyle='rgba(0,0,0,.08)';[0.26,0.38,0.62,0.74].forEach(u=>g.fillRect(u*w-7,0,14,h));
    g.fillStyle='rgba(0,0,0,.1)';g.fillRect(w*0.64,h*0.6,w*0.15,h*0.1);
    g.fillStyle='#d6a83e';g.fillRect(w/2-3,0,6,h);g.fillStyle='#ecebe6';g.fillRect(w*0.05,0,5,h);g.fillRect(w*0.95-5,0,5,h);},true),
  narrow:canvasTex(256,512,(g,w,h)=>{g.fillStyle='#626368';g.fillRect(0,0,w,h);const r=mulberry(5);
    for(let n=0;n<9000;n++){g.fillStyle=`rgba(${r()<.5?'255,255,255':'0,0,0'},${r()*0.07})`;g.fillRect(r()*w,r()*h,2,2);}
    g.fillStyle='rgba(0,0,0,.12)';g.fillRect(w*0.2,h*0.3,w*0.3,h*0.05);g.strokeStyle='rgba(30,30,30,.3)';g.lineWidth=2;g.beginPath();g.moveTo(w*0.7,0);g.lineTo(w*0.66,h*0.4);g.lineTo(w*0.72,h);g.stroke();
    g.fillStyle='#ecebe6';g.fillRect(w*0.07,0,6,h);g.fillRect(w*0.93-6,0,6,h);},true),
  shop:canvasTex(256,256,(g,w,h)=>{const r=mulberry(6);for(let y=0;y<h;y+=16)for(let x=0;x<w;x+=32){const o=(y/16)%2?16:0;
      const t=r();g.fillStyle=t<0.1?'#b7987a':t<0.4?'#c7bba8':t<0.7?'#cfc4b2':'#d6ccbc';g.fillRect(x+o-32,y,31,15);g.fillRect(x+o,y,31,15);}
    g.fillStyle='rgba(0,0,0,.12)';for(let y=0;y<h;y+=16)g.fillRect(0,y+15,w,1);},true),
};
const pave=canvasTex(128,128,(g,w,h)=>{g.fillStyle='#d4cbbd';g.fillRect(0,0,w,h);g.fillStyle='rgba(100,88,74,.4)';for(let k=0;k<=4;k++){g.fillRect(0,k*32,w,2);g.fillRect(k*32,0,2,h);}
  const r=mulberry(8);for(let n=0;n<14;n++){g.fillStyle='rgba(190,120,90,.35)';g.fillRect(Math.floor(r()*4)*32+2,Math.floor(r()*4)*32+2,30,30);}},true);
const roadM={wide:tmap(roadTex.wide,{polygonOffset:true,polygonOffsetFactor:-1}),narrow:tmap(roadTex.narrow,{polygonOffset:true,polygonOffsetFactor:-2}),
  shop:tmap(roadTex.shop,{polygonOffset:true,polygonOffsetFactor:-2})};
const paveM=tmap(pave,{polygonOffset:true,polygonOffsetFactor:-3});
const curbM=tm('#e9e4da');
function crossings(S){return STREETS.filter(o=>o.ax!==S.ax&&o.c>S.a-1&&o.c<S.b+1&&S.c>o.a-1&&S.c<o.b+1);}
for(const S of STREETS){
  const len=S.b-S.a,step=S.ax==='z'?2:6,nr=Math.ceil(len/step)+1,flip=S.ax==='x';
  const P=(t,off,y)=>S.ax==='z'?[S.c+off,y,t]:[t,y,S.c+off];
  const yo=S.kind==='wide'?0.03:0.035;
  grid(nr,3,(r,c)=>{const t=S.a+Math.min(r*step,len),off=(c-1)*S.w/2,p=P(t,off,0);p[1]=G(p[0],p[2])+yo;return[...p,c/2,t/(S.kind==='shop'?4:9)];},roadM[S.kind],{flip,shadow:true});
  if(S.sw){ // pavements broken at side streets, with a curb face
    const cuts=crossings(S).map(o=>[o.c-o.w/2-0.2,o.c+o.w/2+0.2]);
    const runs=[];let t0=S.a;for(const [c0,c1] of cuts.sort((a,b)=>a[0]-b[0])){if(c0>t0+1)runs.push([t0,c0]);t0=Math.max(t0,c1);}if(S.b>t0+1)runs.push([t0,S.b]);
    for(const [r0,r1] of runs)for(const sd of [-1,1]){
      const n=Math.ceil((r1-r0)/step)+1,e0=S.w/2,e1=S.w/2+S.sw;
      grid(n,2,(r,c)=>{const t=r0+Math.min(r*step,r1-r0),p=P(t,sd*(c?e1:e0),0);p[1]=G(p[0],p[2])+0.12;return[...p,c*S.sw/2,t/2];},paveM,{flip:flip!==(sd<0),shadow:true});
      grid(n,2,(r,c)=>{const t=r0+Math.min(r*step,r1-r0),p=P(t,sd*e0,0);p[1]=G(p[0],p[2])+(c?0.12:-0.02);return[...p,0,0];},curbM,{flip:flip===(sd<0)});
    }
  }
}
/* the tram track: ballast, sleepers, rails */
{
  grid(Math.round(2*CUT_X/8)+1,2,(r,c)=>{const x=-CUT_X+r*8,z=TRAM_Z-1.7+c*3.4;return[x,G(x,z)+0.05,z,r,c];},tmap(canvasTex(64,64,(g,w,h)=>{g.fillStyle='#8a8276';g.fillRect(0,0,w,h);
    const r=mulberry(10);for(let n=0;n<500;n++){g.fillStyle=`rgba(${r()<.5?'60,55,50':'200,195,185'},.5)`;g.fillRect(r()*w,r()*h,2,2);}},true),{polygonOffset:true,polygonOffsetFactor:-4,side:THREE.DoubleSide}),{flip:true,shadow:true});
  const sl=[];for(let x=-CUT_X;x<=CUT_X;x+=0.9)sl.push(x);
  inst(new THREE.BoxGeometry(0.22,0.12,2.2),tm('#5b4636'),sl,(x,d)=>{d.position.set(x,G(x,TRAM_Z)+0.1,TRAM_Z);});
  for(const o of [-0.53,0.53]){const m=new THREE.Mesh(new THREE.BoxGeometry(2*CUT_X,0.12,0.08),tm('#a9aeb4'));m.position.set(0,G(0,TRAM_Z)+0.2,TRAM_Z+o);world.add(m);}
}

/* ---------- buildings ---------- */
const BLD=[],RES=[];
function overlaps(a,b,m){return a.x0<b.x1+m&&a.x1>b.x0-m&&a.z0<b.z1+m&&a.z1>b.z0-m;}
function freeBox(b,m){for(const S of STREETS)if(overlaps(b,streetBox(S,0.25),0))return false;
  if(overlaps(b,{x0:TRAM_X0,x1:TRAM_X1,z0:TRAM_Z-3.2,z1:TRAM_Z+3.2},0))return false;
  for(const r of RES)if(overlaps(b,r,0))return false;for(const o of BLD)if(overlaps(b,o,m||0.25))return false;
  if(b.z1>COAST_Z-4.6-0.01&&b.z0<COAST_Z+20)return false;return true;}
function reserve(x0,x1,z0,z1){RES.push({x0,x1,z0,z1});}
reserve(-80,-40,-178,-123.2);   // shrine grounds
reserve(-16,16,-222,-206);      // lookout at the top of the hill
reserve(44,86,203,208.9);       // station platform
reserve(16,32,183.6,197.5);     // the rooftop you can climb
// a building is a box whose front faces the street: face = +z, -z, +x or -x
function bAt(frontS,side,t,w,d,o){const S=frontS,off=S.w/2+S.sw+(o&&o.set||0.45);
  let b;if(S.ax==='z'){const fx=S.c+side*off;b={x0:Math.min(fx,fx+side*d),x1:Math.max(fx,fx+side*d),z0:t-w/2,z1:t+w/2,face:side>0?'-x':'+x'};}
  else{const fz=S.c+side*off;b={x0:t-w/2,x1:t+w/2,z0:Math.min(fz,fz+side*d),z1:Math.max(fz,fz+side*d),face:side>0?'-z':'+z'};}
  return Object.assign(b,{w,d,street:S},o||{});}
function finish(b){
  b.cx=(b.x0+b.x1)/2;b.cz=(b.z0+b.z1)/2;
  const fp={'+z':[b.cx,b.z1],'-z':[b.cx,b.z0],'+x':[b.x1,b.cz],'-x':[b.x0,b.cz]}[b.face];b.fx=fp[0];b.fz=fp[1];
  b.yaw={'+z':0,'-z':Math.PI,'+x':Math.PI/2,'-x':-Math.PI/2}[b.face];
  b.base=G(b.fx,b.fz)+0.12;let lo=1e9;for(const [x,z] of [[b.x0,b.z0],[b.x1,b.z0],[b.x0,b.z1],[b.x1,b.z1]])lo=Math.min(lo,H(x,z));b.low=lo-0.4;
  b.h=b.floors*3.05+0.35;b.top=b.base+b.h;BLD.push(b);collide(b.x0,b.x1,b.z0,b.z1,'bld',b.top);return b;}
// width of the face along the street and depth behind it, in the building's own axes
const along=b=>b.face==='+z'||b.face==='-z'?b.x1-b.x0:b.z1-b.z0,deep=b=>b.face==='+z'||b.face==='-z'?b.z1-b.z0:b.x1-b.x0;

/* the named shops of the shopping street, the post office, the shops on the sea front */
const SHOPS={};
function shopSlot(id,streetId,side,t,w,d,floors,o){const S=STREETS.find(s=>s.id===streetId);const b=bAt(S,side,t,w,d,Object.assign({floors,kind:'named',id},o||{}));
  if(!freeBox(b,0.1))console.warn('shop slot blocked',id);finish(b);SHOPS[id]=b;return b;}
shopSlot('bakery','shop',-1,-37.5,9,9,2,{sign:'こむぎ堂',sub:'BAKERY',wall:'#f6ead6',accent:'#b86b35',awn:'#c8722e'});
shopSlot('flower','shop',-1,-27,7.5,8,2,{sign:'花のはなもり',sub:'FLOWER',wall:'#eef3e6',accent:'#3f8a4f',awn:'#4f9a5a'});
shopSlot('books','shop',-1,18,7.5,9,2,{sign:'古書うみねこ',sub:'BOOKS',wall:'#e9e1d0',accent:'#5a4532',awn:'#6b4a2e'});
shopSlot('cafe','shop',-1,28.5,10,10,2,{sign:'喫茶 しおさい',sub:'COFFEE',wall:'#f3e3cf',accent:'#7a3f2a',awn:'#2f6b8a'});
shopSlot('dagashi','shop',1,-37,8,8,1,{sign:'駄菓子 まるや',sub:'DAGASHI',wall:'#efe3c6',accent:'#c8372d',awn:'#e2584a'});
shopSlot('yaoya','shop',1,-27.5,8,8,2,{sign:'八百吉',sub:'YAOYA',wall:'#f1ecdf',accent:'#4a7a2e',awn:'#e8b51c'});
shopSlot('fish','shop',1,20,9,9,2,{sign:'魚松',sub:'SAKANA',wall:'#e6eef2',accent:'#24466e',awn:'#2e5fa8'});
shopSlot('post','main',1,60,11,10,2,{sign:'〒 海街郵便局',sub:'POST OFFICE',wall:'#f4f4f0',accent:'#c8372d',awn:'#c8372d'});
shopSlot('umi','coast',-1,-40,10,9,2,{sign:'食堂 なぎさ',sub:'SHOKUDO',wall:'#f2e8d8',accent:'#2e5fa8',awn:'#2e7fb8'});
shopSlot('hotel','coast',-1,28,16,10,3,{sign:'潮騒ホテル',sub:'HOTEL',wall:'#f6f1e6',accent:'#1f6f8b',awn:'#1f6f8b'});

/* frontage along every street, then the gaps behind */
const KINDS={shop:['shopA','shopB','shopC','shopD','shop3','shopA'],wide:['house2','shopB','apt3','house2b','shopC','shop3'],narrow:['house2','house2b','house1','house2','apt3','house2b']};
for(const S of STREETS){
  if(S.id==='coast'){ // the sea front: shops and inns on the land side only
    for(let t=-190;t<190;){const w=7+rnd()*7,b=bAt(S,-1,t+w/2,w,8+rnd()*2,{floors:2+Math.floor(rnd()*2),kind:pick(['shopB','shopC','shop3','apt3','shopD'])});
      if(freeBox(b))finish(b);t+=w+0.6+rnd()*1.5;}continue;}
  for(const side of [-1,1]){
    for(let t=S.a+3;t<S.b-3;){
      const w=S.kind==='shop'?6+rnd()*4:5.5+rnd()*4.5,d=S.kind==='shop'?8+rnd()*3:7+rnd()*4,kind=pick(KINDS[S.kind]);
      const floors=kind==='house1'?1:kind==='apt3'||kind==='shop3'?3:2;
      const set=S.kind==='narrow'&&kind!=='apt3'&&rnd()<0.55?1.5:0.45;
      const b=bAt(S,side,t+w/2,w,d,{floors,kind,set,wall:S.kind==='narrow'&&set>1});
      if(freeBox(b))finish(b);
      t+=w+(S.kind==='shop'?0.15:0.6+rnd()*1.6);
    }}
}
for(let gx=-190;gx<=190;gx+=8.5)for(let gz=-176;gz<=COAST_Z-12;gz+=8.5){ // houses filling the blocks behind
  if(rnd()<0.18)continue;const w=6+rnd()*3,d=6+rnd()*3,x=gx+(rnd()-.5)*2,z=gz+(rnd()-.5)*2;
  let best=null,bd=1e9;for(const S of STREETS){const dd=S.ax==='z'?Math.abs(x-S.c):Math.abs(z-S.c);if(dd<bd){bd=dd;best=S;}}
  const face=best.ax==='z'?(x<best.c?'+x':'-x'):(z<best.c?'+z':'-z');
  const b={x0:x-w/2,x1:x+w/2,z0:z-d/2,z1:z+d/2,face,floors:rnd()<0.25?1:2,kind:pick(['house2','house2b','house1','house2']),back:true};
  if(freeBox(b,0.6))finish(b);
}

/* facades drawn on canvas: every face is white so the instance colour tints it. Each window drawn is also noted, so a second
   canvas can light some of them for the night (the emissive map that the story's clock turns up after dark). */
let WINLOG=null;const NIGHT_MATS=[];
function litTex(w,h,rects,seed){const r=mulberry(seed);return canvasTex(w,h,(g)=>{g.fillStyle='#000';g.fillRect(0,0,w,h);
  for(const [x,y,ww,hh] of rects){if(r()>0.62)continue;const gr=g.createLinearGradient(x,y,x,y+hh);gr.addColorStop(0,'#ffd99a');gr.addColorStop(1,'#e8a85a');g.fillStyle=gr;g.fillRect(x,y,ww,hh);}});}
function nightMat(tex,opt){const m=tmap(tex,Object.assign({emissive:'#ffffff',emissiveMap:tex.lit,emissiveIntensity:0},opt||{}));NIGHT_MATS.push(m);return m;}
function logged(w,h,seed,draw){WINLOG=[];const t=canvasTex(w,h,draw);t.lit=litTex(w,h,WINLOG,seed);WINLOG=null;return t;}
function win(g,x,y,w,h,o){o=o||{};if(WINLOG)WINLOG.push([x,y,w,h]);g.fillStyle='#f7f4ee';g.fillRect(x-3,y-3,w+6,h+6);
  const gr=g.createLinearGradient(x,y,x+w,y+h);gr.addColorStop(0,'#5f7b8c');gr.addColorStop(1,'#3d5260');g.fillStyle=gr;g.fillRect(x,y,w,h);
  g.fillStyle='rgba(255,255,255,.28)';g.beginPath();g.moveTo(x+w*0.15,y+h);g.lineTo(x+w*0.45,y);g.lineTo(x+w*0.6,y);g.lineTo(x+w*0.3,y+h);g.fill();
  if(o.curtain){g.fillStyle=o.curtain;g.fillRect(x,y,w*0.32,h);g.fillRect(x+w*0.7,y,w*0.3,h);}
  if(o.lattice){g.fillStyle='rgba(240,236,228,.9)';for(let k=1;k<4;k++)g.fillRect(x+w*k/4-1,y,2,h);g.fillRect(x,y+h/2-1,w,2);}
  else{g.fillStyle='#e9e5dd';g.fillRect(x+w/2-1.5,y,3,h);}
  g.fillStyle='#d9d3c8';g.fillRect(x-5,y+h+2,w+10,5);}
function doorWood(g,x,y,w,h){g.fillStyle='#7a5638';g.fillRect(x,y,w,h);g.fillStyle='#5f4029';for(let k=1;k<4;k++)g.fillRect(x+k*w/4,y,2,h);g.fillStyle='#e7c46a';g.fillRect(x+w-10,y+h*0.5,5,5);}
function slider(g,x,y,w,h){g.fillStyle='#8b6a4c';g.fillRect(x,y,w,h);for(let k=0;k<2;k++){const xx=x+4+k*(w/2-2);g.fillStyle='#c9d6dc';g.fillRect(xx,y+4,w/2-6,h-8);
  g.fillStyle='rgba(139,106,76,.95)';for(let j=1;j<5;j++)g.fillRect(xx,y+4+j*(h-8)/5,w/2-6,2);g.fillRect(xx+(w/2-6)/2-1,y+4,2,h-8);}}
const CURT=['#e8c9b8','#cfe0d2','#f2e2a8','#d6dcef','#f0d0d8','#ffffff'];
function facadeTex(kind,txt,seed){const fl=kind==='house1'?1:kind==='apt3'||kind==='shop3'?3:2;const r=mulberry(seed||kind.length*31);
  return logged(256,128*fl,seed||7,(g,w,h)=>{g.fillStyle='#ffffff';g.fillRect(0,0,w,h);
    g.fillStyle='rgba(0,0,0,.05)';for(let y=0;y<h;y+=8)g.fillRect(0,y,w,1);
    const shopFloor=kind.startsWith('shop');
    for(let f=0;f<fl;f++){const y0=h-(f+1)*128;
      if(f===0&&shopFloor){g.fillStyle='#3a4552';g.fillRect(10,y0+34,w-20,94);
        g.fillStyle='rgba(255,236,196,.55)';for(let x=18;x<w-30;x+=44){g.fillRect(x,y0+46,34,40);if(kind!=='shopD')WINLOG.push([x,y0+46,34,40],[x,y0+46,34,40]);}
        g.fillStyle='rgba(255,255,255,.18)';g.beginPath();g.moveTo(40,y0+128);g.lineTo(90,y0+34);g.lineTo(110,y0+34);g.lineTo(60,y0+128);g.fill();
        const colors=['#c8372d','#2f6b8a','#4f8a3a','#e8a23a','#6b4a8a','#2e3036'];g.fillStyle=colors[Math.floor(r()*colors.length)];g.fillRect(6,y0+4,w-12,28);
        g.fillStyle='#fffaf0';g.font='bold 22px "Zen Maru Gothic", sans-serif';g.textAlign='center';g.textBaseline='middle';g.fillText(txt||'',w/2,y0+19);
        if(kind==='shopD'){g.fillStyle='#9aa1a6';g.fillRect(10,y0+34,w-20,52);g.fillStyle='rgba(0,0,0,.18)';for(let y=y0+38;y<y0+86;y+=5)g.fillRect(10,y,w-20,1.5);}
      }else if(f===0&&kind!=='apt3'){
        if(kind==='house2b'){g.fillStyle='#8a6a4c';g.fillRect(0,y0,w,128);g.fillStyle='rgba(0,0,0,.18)';for(let x=0;x<w;x+=12)g.fillRect(x,y0,2,128);}
        slider(g,24,y0+40,70,88);win(g,140,y0+44,80,46,{lattice:true});
        g.fillStyle='rgba(60,50,40,.4)';g.fillRect(0,y0+24,w,6);
      }else{
        const n=kind==='apt3'?2:2;for(let k=0;k<n;k++){const ww=kind==='apt3'?84:78,x=kind==='apt3'?22+k*126:26+k*124;win(g,x,y0+30,ww,58,{curtain:r()<0.6?CURT[Math.floor(r()*CURT.length)]:null,lattice:kind==='house2b'});}
        if(kind==='apt3'){g.fillStyle='rgba(120,120,120,.55)';g.fillRect(0,y0+92,w,4);for(let x=0;x<w;x+=10)g.fillRect(x,y0+96,2,28);g.fillRect(0,y0+122,w,4);doorWood(g,w/2-14,y0+40,28,48);}
      }
      g.fillStyle='rgba(0,0,0,.07)';g.fillRect(0,y0,w,3);}
    g.fillStyle='rgba(0,0,0,.08)';g.fillRect(0,h-6,w,6);});}
function sideTex(fl){return logged(128,128*fl,fl*13,(g,w,h)=>{g.fillStyle='#ffffff';g.fillRect(0,0,w,h);g.fillStyle='rgba(0,0,0,.05)';for(let y=0;y<h;y+=8)g.fillRect(0,y,w,1);
  for(let f=0;f<fl;f++){const y0=h-(f+1)*128;win(g,44,y0+36,40,34,{});g.fillStyle='rgba(0,0,0,.07)';g.fillRect(0,y0,w,3);}});}
const SIDE={1:nightMat(sideTex(1)),2:nightMat(sideTex(2)),3:nightMat(sideTex(3))};
const roofTop=tm('#8f8b84'),under=tm('#6d6a64');
const SHOP_TXT={shopA:['クリーニング','たばこ','美容室 ルナ','米・酒','田中電器'],shopB:['金物 マルニ','ふとん店','時計・メガネ','文房具'],shopC:['和菓子 つる屋','写真館','薬 ミナト'],shopD:['ガレージ'],shop3:['ホテル みさき','歯科クリニック','不動産']};
const WALLS=['#f6f2ea','#f1e7d6','#efe2cf','#e9ede8','#f2dfd2','#e3e8ee','#f4ecd0','#e8e0d4','#dfe6dc','#f0e6e0'];
const variantMat={};
function matFor(b){let key=b.kind,txt='';if(SHOP_TXT[b.kind]){const list=SHOP_TXT[b.kind];txt=list[Math.floor(hash(b.cx*7,b.cz*3)*list.length)];key+='|'+txt;}
  if(!variantMat[key]){const fl=b.floors,f=nightMat(facadeTex(b.kind,txt,key.length*97+(txt.charCodeAt(0)||0)));variantMat[key]={mats:[SIDE[fl],SIDE[fl],roofTop,under,f,SIDE[fl]],list:[]};}
  return variantMat[key];}
const edges=[];
function boxEdges(cx,y0,cz,yaw,wx,hh,dz){const X=[Math.cos(yaw),-Math.sin(yaw)],Z=[Math.sin(yaw),Math.cos(yaw)],P=[];
  for(const yy of [y0,y0+hh])for(const sx of [-1,1])for(const sz of [-1,1])P.push([cx+X[0]*sx*wx/2+Z[0]*sz*dz/2,yy,cz+X[1]*sx*wx/2+Z[1]*sz*dz/2]);
  for(const [a,c] of [[0,1],[1,3],[3,2],[2,0],[4,5],[5,7],[7,6],[6,4],[0,4],[1,5],[2,6],[3,7]])edges.push(...P[a],...P[c]);}
const found=[],gables=[],hips=[],parapets=[],awnings=[],balcony=[],rails=[],laundry=[],acs=[],eaves=[],tanks=[],walls=[],pots=[];
for(const b of BLD){
  const W=along(b),D=deep(b);b.col=C3(b.wall&&typeof b.wall==='string'?b.wall:pick(WALLS));
  found.push({b});
  if(b.kind==='named')continue;
  matFor(b).list.push(b);
  if(!b.back)boxEdges(b.cx,b.base,b.cz,b.yaw,W,b.h,D);
  const X=[Math.cos(b.yaw),-Math.sin(b.yaw)],F=[Math.sin(b.yaw),Math.cos(b.yaw)];
  const at=(u,y,v)=>[b.cx+X[0]*u+F[0]*v,y,b.cz+X[1]*u+F[1]*v];
  if(b.floors<=2&&b.kind!=='shop3'){const r=rnd();const col=C3(pick(['#5d6470','#46505e','#a9493a','#6b4a2e','#3a3d44','#7d5a3c','#4a5f78']));
    if(r<0.72)gables.push({b,col,W,D});else hips.push({b,col,W,D});}
  else{parapets.push({b,W,D});if(rnd()<0.5)tanks.push({p:at((rnd()-.5)*W*0.5,b.top+0.6,(rnd()-.5)*D*0.4)});}
  if(b.back)continue;
  if(b.kind.startsWith('shop')&&b.kind!=='shopD'&&rnd()<0.8)awnings.push({p:at(0,b.base+2.95,D/2+0.62),yaw:b.yaw,w:W*0.84,col:C3(pick(['#c8372d','#2f7d5c','#24466e','#e8b51c','#e85a2a','#6b4a8a','#3a6b8a']))});
  if(!b.kind.startsWith('shop')&&b.kind!=='apt3')eaves.push({p:at(-W*0.22,b.base+2.55,D/2+0.35),yaw:b.yaw,w:W*0.5});
  if(b.floors>=2&&(b.kind==='house2'||b.kind==='apt3')&&rnd()<0.55){const by=b.base+3.15,bw=W*(b.kind==='apt3'?0.95:0.6);
    balcony.push({p:at(0,by,D/2+0.48),yaw:b.yaw,w:bw});rails.push({p:at(0,by+0.55,D/2+0.92),yaw:b.yaw,w:bw});
    if(rnd()<0.6)for(let k=0;k<3+Math.floor(rnd()*3);k++)laundry.push({p:at(-bw/2+0.5+k*0.62,by+1.55,D/2+0.6),yaw:b.yaw,col:C3(pick(['#ffffff','#f2c9c4','#9cc3e6','#f5e07a','#c9e0b8','#ffffff']))});}
  if(rnd()<0.6)acs.push({p:at(W/2-0.7,b.base+0.35,D/2+0.25),yaw:b.yaw});
  if(rnd()<0.5)pots.push({p:at(-W/2+0.5,b.base,D/2+0.3)},{p:at(-W/2+1.1,b.base,D/2+0.3)});
  if(b.wall){const sd=1.45;walls.push({p:at(-W/4-0.35,b.base-0.12+0.55,D/2+sd),yaw:b.yaw,w:W/2-0.7},{p:at(W/4+0.35,b.base-0.12+0.55,D/2+sd),yaw:b.yaw,w:W/2-0.7});}
}
const boxG=new THREE.BoxGeometry(1,1,1);
for(const k in variantMat){const v=variantMat[k];inst(boxG,v.mats,v.list,(b,d)=>{d.position.set(b.cx,b.base+b.h/2,b.cz);d.rotation.y=b.yaw;d.scale.set(along(b),b.h,deep(b));},{recv:true});}
const stone=canvasTex(128,64,(g,w,h)=>{g.fillStyle='#9a958c';g.fillRect(0,0,w,h);const r=mulberry(12);
  for(let y=0;y<h;y+=16)for(let x=-((y/16)%2)*12;x<w;x+=24){g.fillStyle=`rgb(${150+r()*40|0},${145+r()*35|0},${135+r()*30|0})`;g.beginPath();g.ellipse(x+12,y+8,11,7,0,0,7);g.fill();
    g.strokeStyle='rgba(60,55,50,.5)';g.lineWidth=1.2;g.stroke();}},true);
inst(boxG,tmap(stone),found.filter(f=>f.b.base-f.b.low>0.05),(f,d)=>{const b=f.b;d.position.set(b.cx,(b.base+b.low)/2,b.cz);d.scale.set(b.x1-b.x0-0.02,b.base-b.low,b.z1-b.z0-0.02);},{recv:true});
const prism=new THREE.CylinderGeometry(1,1,1,3).rotateX(-Math.PI/2).rotateY(Math.PI/2);
const kawara=canvasTex(256,32,(g,w,h)=>{g.fillStyle='#ffffff';g.fillRect(0,0,w,h);g.fillStyle='rgba(0,0,0,.22)';for(let x=0;x<w;x+=10)g.fillRect(x,0,2,h);
  g.fillStyle='rgba(255,255,255,.25)';for(let x=4;x<w;x+=10)g.fillRect(x,0,2,h);},true);
kawara.repeat.set(3,1);
inst(prism,tmap(kawara),gables.map(e=>({...e,col:e.col})),(e,d)=>{const b=e.b,rh=1.3+e.D*0.12,sy=rh/1.5;d.position.set(b.cx,b.top+sy*0.5,b.cz);d.rotation.y=b.yaw;d.scale.set(e.W*1.1,sy,(e.D*1.12)/1.732);},{cast:true});
inst(new THREE.ConeGeometry(1,1,4).rotateY(Math.PI/4),tm('#ffffff'),hips,(e,d)=>{const b=e.b;d.position.set(b.cx,b.top+0.8,b.cz);d.rotation.y=b.yaw;d.scale.set(e.W*0.78,1.6,e.D*0.78);});
inst(boxG,tm('#d9d4cb'),parapets,(e,d)=>{const b=e.b;d.position.set(b.cx,b.top+0.2,b.cz);d.rotation.y=b.yaw;d.scale.set(e.W+0.25,0.4,e.D+0.25);});
inst(new THREE.CylinderGeometry(0.7,0.7,1.2,12),tm('#c9cfd4'),tanks,(e,d)=>{d.position.set(...e.p);},{ol:0.03});
const awnTex=canvasTex(64,64,(g,w,h)=>{for(let k=0;k<8;k++){g.fillStyle=k%2?'#ffffff':'#dedede';g.fillRect(0,k*8,w,8);}});
const awnG=new THREE.BoxGeometry(1,0.06,1.3).translate(0,0,0);
inst(awnG,tmap(awnTex),awnings,(e,d)=>{d.position.set(...e.p);d.rotation.set(0.32,e.yaw,0,'YXZ');d.scale.set(e.w,1,1);},{cast:true});
inst(new THREE.BoxGeometry(1,0.08,0.75),tm('#7d7a74'),eaves,(e,d)=>{d.position.set(...e.p);d.rotation.set(0.12,e.yaw,0,'YXZ');d.scale.set(e.w,1,1);},{cast:true});
inst(new THREE.BoxGeometry(1,0.14,0.95),tm('#d4d0c8'),balcony,(e,d)=>{d.position.set(...e.p);d.rotation.y=e.yaw;d.scale.set(e.w,1,1);},{cast:true});
const railTex=canvasTex(64,32,(g,w,h)=>{g.clearRect(0,0,w,h);g.fillStyle='#8c8f92';g.fillRect(0,0,w,4);g.fillRect(0,h-3,w,3);for(let x=2;x<w;x+=8)g.fillRect(x,0,2,h);});railTex.wrapS=THREE.RepeatWrapping;railTex.repeat.set(6,1);
inst(new THREE.PlaneGeometry(1,1),tmap(railTex,{transparent:true,side:THREE.DoubleSide,alphaTest:0.4}),rails,(e,d)=>{d.position.set(...e.p);d.rotation.y=e.yaw;d.scale.set(e.w,1.0,1);});
inst(new THREE.PlaneGeometry(0.5,0.62),tm('#ffffff',{side:THREE.DoubleSide}),laundry,(e,d)=>{d.position.set(...e.p);d.rotation.set(0.06,e.yaw,0);});
const acTex=canvasTex(64,48,(g,w,h)=>{g.fillStyle='#e8e8e4';g.fillRect(0,0,w,h);g.fillStyle='#9a9a96';g.beginPath();g.arc(24,24,16,0,7);g.fill();g.fillStyle='#e8e8e4';g.beginPath();g.arc(24,24,4,0,7);g.fill();
  g.strokeStyle='#e8e8e4';g.lineWidth=2;for(let a=0;a<6;a++){g.beginPath();g.moveTo(24,24);g.lineTo(24+Math.cos(a)*16,24+Math.sin(a)*16);g.stroke();}g.fillStyle='#bdbdb8';for(let y=8;y<40;y+=5)g.fillRect(46,y,14,2);});
inst(new THREE.BoxGeometry(0.8,0.6,0.3),[tm('#e8e8e4'),tm('#e8e8e4'),tm('#e8e8e4'),tm('#e8e8e4'),tmap(acTex),tm('#e8e8e4')],acs,(e,d)=>{d.position.set(...e.p);d.rotation.y=e.yaw;},{ol:0.02});
const blockTex=canvasTex(64,32,(g,w,h)=>{g.fillStyle='#c9c4ba';g.fillRect(0,0,w,h);g.fillStyle='rgba(90,85,78,.45)';for(let y=0;y<h;y+=10){g.fillRect(0,y,w,1.5);for(let x=(y/10)%2?0:16;x<w;x+=32)g.fillRect(x,y,1.5,10);}},true);
blockTex.repeat.set(3,1);
inst(new THREE.BoxGeometry(1,1.1,0.15),tmap(blockTex),walls,(e,d)=>{d.position.set(...e.p);d.rotation.y=e.yaw;d.scale.set(e.w,1,1);},{cast:true});
inst(new THREE.CylinderGeometry(0.2,0.15,0.36,10).translate(0,0.18,0),tm('#a5603e'),pots,(e,d)=>{d.position.set(...e.p);});
inst(new THREE.SphereGeometry(0.3,10,8).translate(0,0.55,0),tm('#4f8a3a'),pots,(e,d)=>{d.position.set(...e.p);d.scale.set(1,0.9+hash(e.p[0]*9,e.p[2])*0.5,1);});
for(const w of walls){const yaw=w.yaw,c=Math.abs(Math.cos(yaw)),s=Math.abs(Math.sin(yaw)),hx=(w.w/2)*c+0.08*s,hz=(w.w/2)*s+0.08*c;collide(w.p[0]-hx,w.p[0]+hx,w.p[2]-hz,w.p[2]+hz,'wall',w.p[1]+0.55);}
