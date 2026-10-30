
/* ---------- trees and grass: canopies with some shape to them, the wind that sways them, and grass round where you are.
   WIND.t is the clock the shaders share (set every frame in p5_systems.js). Gusts are bands that roll across the town from
   the sea; where one passes, the grass bends further and catches the light, so bright waves seem to run over it. ---------- */
const WIND={t:{value:0}};
// gust: broad, slow swells of wind. windLine: the thin bright lines a breeze draws over a field, wavy, drifting inland from the sea
const WIND_GLSL=`uniform float uWindT;
float gust(vec2 p){return 0.5+0.5*sin(dot(p,vec2(0.02,0.032))-uWindT*0.42)*sin(dot(p,vec2(-0.011,0.017))-uWindT*0.21+1.7);}
float windLine(vec2 p){float ph=dot(p,vec2(0.15,-0.48))+sin(dot(p,vec2(0.07,0.025))+uWindT*0.15)*2.2+sin(dot(p,vec2(-0.21,0.08)))*0.7-uWindT*1.9;
  float l=pow(0.5+0.5*sin(ph),9.0);float br=smoothstep(0.25,0.75,0.5+0.5*sin(dot(p,vec2(0.017,0.009))-uWindT*0.12));return l*br;}`;
// leaves: the whole crown leans and shivers, more at the top, each tree on its own beat (its place sets the phase)
function windify(mat,amp){mat.onBeforeCompile=sh=>{sh.uniforms.uWindT=WIND.t;
  sh.vertexShader=WIND_GLSL+'\n'+sh.vertexShader.replace('#include <begin_vertex>',`#include <begin_vertex>
#ifdef USE_INSTANCING
  vec2 wp=instanceMatrix[3].xz;float ph=dot(wp,vec2(0.37,0.23));float g=gust(wp);
  float k=max(transformed.y+0.6,0.0)*${amp.toFixed(3)};
  transformed.x+=k*(sin(uWindT*0.55+ph)*0.35+g*0.8);transformed.z-=k*(sin(uWindT*0.41+ph*1.7)*0.25+g*0.5);
  transformed+=normal*sin(uWindT*1.8+ph*3.0+transformed.y*3.0)*0.004;
#endif`);};mat.customProgramCacheKey=()=>'wind'+amp;return mat;}
// a broadleaf crown: a few lumpy balls run together, darker underneath and brighter on top
function canopyGeo(seed){const r=mulberry(seed),parts=[[0,0,0,1],[0.55,0.25,0.2,0.7],[-0.5,0.2,-0.25,0.68],[0.1,0.55,-0.45,0.6],[-0.15,-0.3,0.5,0.62]];
  const pos=[],col=[];for(const [ox,oy,oz,s] of parts){const g=new THREE.IcosahedronGeometry(s,1),p=g.attributes.position;
    for(let i=0;i<p.count;i++){const x=p.getX(i),y=p.getY(i),z=p.getZ(i),n=0.82+0.3*vnoise(x*2.3+seed,z*2.3+y*1.7);pos.push(ox+x*n,oy+y*n*0.9,oz+z*n);}}
  for(let i=0;i<pos.length;i+=9){const cy=(pos[i+1]+pos[i+4]+pos[i+7])/3,k=clamp(0.62+(cy+0.9)*0.3,0.6,1.12)*(0.94+r()*0.1);for(let j=0;j<3;j++)col.push(k,k,k*0.96);}
  const geo=new THREE.BufferGeometry();geo.setAttribute('position',new THREE.Float32BufferAttribute(pos,3));geo.setAttribute('color',new THREE.Float32BufferAttribute(col,3));
  geo.computeVertexNormals();return geo;}
// a cedar or pine: tiers of drooping cones on a base at y=0, one unit tall
function cedarGeo(){const pos=[],col=[];const tiers=[[0.0,0.5,1],[0.28,0.42,0.78],[0.52,0.34,0.56],[0.72,0.28,0.36]];
  for(const [y0,h,rad] of tiers){const g=new THREE.ConeGeometry(rad,h,8,1,true).toNonIndexed(),p=g.attributes.position;
    for(let i=0;i<p.count;i++){const y=p.getY(i)+h/2+y0,top=p.getY(i)>0;pos.push(p.getX(i)*(top?1:1.04),y-(top?0:0.04),p.getZ(i)*(top?1:1.04));const k=top?1.05:0.7+y0*0.3;col.push(k,k,k);}}
  const geo=new THREE.BufferGeometry();geo.setAttribute('position',new THREE.Float32BufferAttribute(pos,3));geo.setAttribute('color',new THREE.Float32BufferAttribute(col,3));
  geo.computeVertexNormals();return geo;}
const CANOPY=[canopyGeo(3),canopyGeo(11)],CEDAR=cedarGeo();
const LEAF=windify(new THREE.MeshToonMaterial({color:'#ffffff',gradientMap:GRAD,vertexColors:true}),0.025);
const NEEDLE=windify(new THREE.MeshToonMaterial({color:'#ffffff',gradientMap:GRAD,vertexColors:true,side:THREE.DoubleSide}),0.016);

/* grass: clumps of blades in 16 m squares, made when you come near and dropped when you are far away.
   Only on open ground: not on streets, lots, the tram line, the shore, the cuttings or the paved places */
const GRASS={chunks:new Map(),S:16,mesh:null,on:true};
function grassOK(x,z){if(x>INK_X-600)return false;
  if(z>ISL_Z0&&ISL_ON){const y=G(x,z),u=x-ISL.x,w=z-ISL.z;return y>SEA_Y+1.6&&Math.hypot(x-LH.x,z-LH.z)>9&&islPathD(u,w)>2.6&&!(u>-60&&u<-48&&w<-18);}   // not on the path up to the lighthouse or the jetty
  const y=H(x,z);if(z>SHORE-1)return Math.abs(x)>205&&y>7;if(z>COAST_Z-6.5||cutting(x,z))return false;
  const b={x0:x-0.6,x1:x+0.6,z0:z-0.6,z1:z+0.6};
  for(const S of STREETS){const sb=streetBox(S,0.6);if(S.ax==='z'){sb.z0-=3;sb.z1+=3;}else{sb.x0-=3;sb.x1+=3;}if(overlaps(b,sb,0))return false;}   // the street and a little past its ends
  if(Math.abs(z-TRAM_Z)<4.5&&Math.abs(x)<TRAM_X1+30)return false;
  for(const r of RES)if(overlaps(b,r,1))return false;for(const o of BLD)if(overlaps(b,o,0.8))return false;
  for(const c of COLL)if(c.tag!=='tree'&&overlaps(b,c,0.4))return false;
  for(const d of RIDGE_DECKS)if(Math.hypot(x-d.x,z-d.z)<9)return false;return true;}
// one clump: three bent blades, dark at the root and light at the tip (the tip height is kept in the colour's alpha slot via uv.y)
const GRASS_GEO=(()=>{const pos=[],uv=[],idx=[];let v=0;
  for(const [a,lean,h,o] of [[0,0.06,1,0],[1.3,0.1,0.8,0.09],[2.6,0.05,0.92,0.07],[3.9,0.12,0.72,0.1],[5.2,0.08,0.86,0.06]]){const cx=Math.cos(a),sx=Math.sin(a),ox=Math.cos(a+1.3)*o,oz=Math.sin(a+1.3)*o;
    for(let s=0;s<=2;s++){const t=s/2,w=0.06*(1-t*0.8),bend=lean*t*t;
      for(const side of [-1,1]){pos.push(ox+cx*w*side+bend*Math.cos(a+1.3),t*h*0.32,oz+sx*w*side+bend*Math.sin(a+1.3));uv.push(side>0?1:0,t);}}
    for(let s=0;s<2;s++){const b=v+s*2;idx.push(b,b+1,b+2,b+1,b+3,b+2);}v+=6;}
  const g=new THREE.BufferGeometry();g.setAttribute('position',new THREE.Float32BufferAttribute(pos,3));g.setAttribute('uv',new THREE.Float32BufferAttribute(uv,2));g.setIndex(idx);g.computeVertexNormals();return g;})();
const GRASS_MAT=(()=>{const m=new THREE.MeshToonMaterial({color:'#ffffff',gradientMap:GRAD,side:THREE.DoubleSide});   // toon: the same light as the ground, and three.js hands it cameraPosition (Lambert does not get it)
  m.onBeforeCompile=sh=>{sh.uniforms.uWindT=WIND.t;sh.uniforms.uFar={value:GRASS.R||40};GRASS.uFar=sh.uniforms.uFar;
    sh.vertexShader=WIND_GLSL+'\nuniform float uFar;varying float vTip;varying float vGlow;\n'+sh.vertexShader.replace('#include <begin_vertex>',`#include <begin_vertex>
  vec2 wp=instanceMatrix[3].xz;float t=uv.y;vTip=t;float g=gust(wp);float wl=windLine(wp);vGlow=wl;
  float fd=1.0-smoothstep(uFar*0.72,uFar,distance(wp,cameraPosition.xz));transformed.y*=fd;
  float ph=dot(wp,vec2(1.7,1.3));float bendA=(0.03+g*0.06+wl*0.1)*t*t;   // leaning with the wind, a little more as a line of wind passes
  transformed.x+=bendA*0.3+sin(uWindT*0.9+ph)*0.012*t;transformed.z-=bendA*0.95+cos(uWindT*0.7+ph)*0.01*t;transformed.y-=bendA*0.15;`);
    sh.fragmentShader='varying float vTip;varying float vGlow;\n'+sh.fragmentShader.replace('vec4 diffuseColor = vec4( diffuse, opacity );',
      'vec4 diffuseColor = vec4( diffuse*mix(0.62,1.1,vTip), opacity );')
      .replace('#include <emissivemap_fragment>','#include <emissivemap_fragment>\n  totalEmissiveRadiance+=diffuseColor.rgb*0.18*vGlow*vTip*vTip;   // the sheen on the bent tips');};
  m.customProgramCacheKey=()=>'grass';return m;})();
const GRASS_COLS=['#5f9c46','#6ea951','#558f42','#7bb15a','#4f8a3f'].map(c=>new THREE.Color(c));
/* wild flowers in the grass: little five-petalled heads on thin stems, in patches. The stems are green, the heads take the
   colour of the patch (white clover, yellow, pink, pale purple, sky blue) */
const FLOWER_GEO=(()=>{const mk=(head)=>{const pos=[],col=[];
    if(!head){for(const a of [0,Math.PI/2]){const cx=Math.cos(a)*0.012,cz=Math.sin(a)*0.012;for(const [x,y,z] of [[-cx,0,-cz],[cx,0,cz],[cx,0.44,cz],[-cx,0,-cz],[cx,0.44,cz],[-cx,0.44,-cz]]){pos.push(x,y,z);col.push(0.32,0.55,0.25);}}}
    else{const y=0.44,r=0.085;for(let k=0;k<5;k++){const a0=k/5*TAU,a1=a0+TAU/10,a2=a0+TAU/5;   // a petal is two triangles out to a rounded tip
        for(const [x,yy,z,c] of [[0,y,0,0.7],[Math.cos(a0)*r*0.55,y,Math.sin(a0)*r*0.55,1],[Math.cos(a1)*r,y+0.008,Math.sin(a1)*r,1],[0,y,0,0.7],[Math.cos(a1)*r,y+0.008,Math.sin(a1)*r,1],[Math.cos(a2)*r*0.55,y,Math.sin(a2)*r*0.55,1]]){pos.push(x,yy,z);col.push(c,c,c*0.97);}}
      for(let k=0;k<6;k++){const a0=k/6*TAU,a1=(k+1)/6*TAU,rc=0.024;for(const [x,z] of [[0,0],[Math.cos(a0)*rc,Math.sin(a0)*rc],[Math.cos(a1)*rc,Math.sin(a1)*rc]]){pos.push(x,y+0.012,z);col.push(1.0,0.82,0.25);}}}
    const g=new THREE.BufferGeometry();g.setAttribute('position',new THREE.Float32BufferAttribute(pos,3));g.setAttribute('color',new THREE.Float32BufferAttribute(col,3));
    if(head)g.translate(0,-0.44,0).rotateX(0.65).translate(0,0.44,0);   // the head nods to one side, so its face shows from the path
    g.computeVertexNormals();return g;};
  return{stem:mk(false),head:mk(true)};})();
const FLOWER_MAT=windify(new THREE.MeshToonMaterial({color:'#ffffff',gradientMap:GRAD,vertexColors:true,side:THREE.DoubleSide}),0.06);
const FLOWER_COLS=['#ffffff','#f6f2e4','#f4d23c','#f2a6c4','#c3aef0','#9cc2f2'].map(c=>new THREE.Color(c));
function flowerPatch(cx,cz,r,ok){const list=[];const n=Math.round(GRASS.per/3.5);for(let i=0;i<n;i++){const x=cx*GRASS.S+r()*GRASS.S,z=cz*GRASS.S+r()*GRASS.S;
    const p=vnoise(x/11+40,z/11-20);if(p<0.5||r()>(p-0.5)*2.6||!ok(x,z))continue;const y=G(x,z);if(y<SEA_Y+0.3)continue;
    list.push({x,y,z,s:0.85+r()*0.5,a:r()*TAU,c:FLOWER_COLS[Math.floor(vnoise(x/23-7,z/23+3)*7.99)%FLOWER_COLS.length]});}
  if(!list.length)return null;const g=new THREE.Group(),d=new THREE.Object3D();
  for(const part of ['stem','head']){const im=new THREE.InstancedMesh(FLOWER_GEO[part],FLOWER_MAT,list.length);
    list.forEach((e,i)=>{d.position.set(e.x,e.y-0.02,e.z);d.rotation.set(0,e.a,0);d.scale.setScalar(e.s);d.updateMatrix();im.setMatrixAt(i,d.matrix);im.setColorAt(i,part==='head'?e.c:WHITE3);});
    im.frustumCulled=false;g.add(im);}
  return g;}
const WHITE3=new THREE.Color('#ffffff');
function grassChunk(cx,cz){const S=GRASS.S,x0=cx*S,z0=cz*S,r=mulberry((cx*7919+cz*104729)&0x7fffffff),list=[];
  const cells=new Map(),ok=(x,z)=>{const k=Math.floor(x/2)+','+Math.floor(z/2);if(!cells.has(k))cells.set(k,grassOK(Math.floor(x/2)*2+1,Math.floor(z/2)*2+1));return cells.get(k);};
  for(let n=0;n<GRASS.per;n++){const x=x0+r()*S,z=z0+r()*S;if(!ok(x,z))continue;const y=G(x,z);if(y<SEA_Y+0.3)continue;list.push({x,y,z,s:0.75+r()*0.55,a:r()*TAU,c:GRASS_COLS[Math.floor(r()*5)]});}
  if(!list.length)return null;const im=new THREE.InstancedMesh(GRASS_GEO,GRASS_MAT,list.length),d=new THREE.Object3D();
  list.forEach((e,i)=>{d.position.set(e.x,e.y-0.03,e.z);d.scale.set(e.s,e.s*(0.75+0.45*vnoise(e.x/9,e.z/9)),e.s);d.updateMatrix();im.setMatrixAt(i,d.matrix);im.setColorAt(i,e.c);});
  im.frustumCulled=false;im.matrixAutoUpdate=false;const fl=flowerPatch(cx,cz,r,ok);if(fl)im.add(fl);scene.add(im);return im;}
// keep the squares round the player made, a couple per frame, and let go of the far ones
function updateGrass(){if(GRASS.per==null){const touch=('ontouchstart' in window)||navigator.maxTouchPoints>0;GRASS.per=touch?420:900;GRASS.R=touch?30:42;}if(GRASS.uFar)GRASS.uFar.value=GRASS.R;
  const S=GRASS.S,R=GRASS.R,px=P.x,pz=P.z,on=GRASS.on&&!(typeof URA!=='undefined'&&URA.on)&&px<INK_X-600,c0x=Math.floor((px-R)/S),c1x=Math.floor((px+R)/S),c0z=Math.floor((pz-R)/S),c1z=Math.floor((pz+R)/S);
  let made=0;for(const [k,c] of GRASS.chunks){const dx=Math.max(0,Math.abs((c.cx+0.5)*S-px)-S/2),dz=Math.max(0,Math.abs((c.cz+0.5)*S-pz)-S/2),d=Math.hypot(dx,dz);
    if(c.m)c.m.visible=on&&d<R;if(d>R+S*2){if(c.m){scene.remove(c.m);c.m.dispose();}GRASS.chunks.delete(k);}}
  if(!on)return;for(let cx=c0x;cx<=c1x;cx++)for(let cz=c0z;cz<=c1z;cz++){const k=cx+','+cz;if(GRASS.chunks.has(k))continue;
    const dx=Math.max(0,Math.abs((cx+0.5)*S-px)-S/2),dz=Math.max(0,Math.abs((cz+0.5)*S-pz)-S/2);if(Math.hypot(dx,dz)>R)continue;
    if(made++>=2)return;GRASS.chunks.set(k,{cx,cz,m:grassChunk(cx,cz)});}}
// the same lines of wind run over the green ground itself, so between the blades and beyond the grass the field shines in waves too
{ let ground=null;world.traverse(o=>{if(!ground&&o.isMesh&&o.material&&o.material.vertexColors&&o.geometry.attributes.position.count>60000)ground=o;});
  if(ground){const m=ground.material;m.onBeforeCompile=sh=>{sh.uniforms.uWindT=WIND.t;
    sh.vertexShader='varying vec3 vWP;\n'+sh.vertexShader.replace('#include <begin_vertex>','#include <begin_vertex>\n  vWP=(modelMatrix*vec4(transformed,1.0)).xyz;');
    sh.fragmentShader=WIND_GLSL+'\nvarying vec3 vWP;\n'+sh.fragmentShader.replace('#include <emissivemap_fragment>',`#include <emissivemap_fragment>
  { float grassy=smoothstep(0.06,0.14,vColor.g-vColor.r);float fd=1.0-smoothstep(70.0,170.0,distance(vWP.xz,cameraPosition.xz));
    totalEmissiveRadiance+=diffuseColor.rgb*0.08*windLine(vWP.xz)*grassy*fd; }`);};
    m.customProgramCacheKey=()=>'ground-wind';m.needsUpdate=true;}}

/* wind lines: thin white strokes in the air over the grass, the way a breeze is drawn in a picture. Each one is the trail of a
   point that drifts inland with the wind, bobbing a little, now and then turning a loop; it grows, runs and fades in 2–3 s */
const WL={list:[],t:0,dir:new THREE.Vector3(0.3,0,-1).normalize(),N:24};
const WL_MAT=new THREE.ShaderMaterial({transparent:true,depthWrite:false,uniforms:{uOp:{value:1}},
  vertexShader:'attribute float a;varying float vA;void main(){vA=a;gl_Position=projectionMatrix*modelViewMatrix*vec4(position,1.0);}',
  fragmentShader:'uniform float uOp;varying float vA;void main(){gl_FragColor=vec4(1.0,1.0,0.97,vA*uOp);}'});
function wlMake(){const n=WL.N,g=new THREE.BufferGeometry();g.setAttribute('position',new THREE.BufferAttribute(new Float32Array(n*2*3),3));
  g.setAttribute('a',new THREE.BufferAttribute(new Float32Array(n*2),1));const idx=[];for(let i=0;i<n-1;i++){const a=i*2;idx.push(a,a+1,a+2,a+1,a+3,a+2);}g.setIndex(idx);
  const m=new THREE.Mesh(g,WL_MAT);m.frustumCulled=false;m.visible=false;m.renderOrder=3;scene.add(m);return{m,pts:[],alive:false};}
function wlSpawn(L){const cd=camera.getWorldDirection(new THREE.Vector3()),a=Math.atan2(cd.x,cd.z)+(rnd()-0.5)*1.4,r=6+rnd()*14,x=camera.position.x+Math.sin(a)*r-WL.dir.x*5,z=camera.position.z+Math.cos(a)*r-WL.dir.z*5;   // in front of the cameraif(!grassOK(x,z))return false;
  Object.assign(L,{alive:true,t:0,life:2.2+rnd()*1.2,x,z,y:G(x,z)+0.7+rnd()*1.6,sp:4+rnd()*2.5,ph:rnd()*TAU,loopAt:rnd()<0.65?0.6+rnd()*0.8:-1,pts:[],acc:0});
  L.y0=L.y;return true;}
function updateWindLines(dt){WL.t+=dt;if(!WL.list.length)for(let k=0;k<7;k++)WL.list.push(wlMake());
  const on=GRASS.on&&!(typeof URA!=='undefined'&&URA.on)&&P.x<INK_X-600&&state==='play',day=clamp((sun.intensity-0.15)/0.6,0,1);WL_MAT.uniforms.uOp.value=0.95*day;
  const want=(typeof hasTouch!=='undefined'&&hasTouch)?4:7,d=WL.dir,side=new THREE.Vector3(-d.z,0,d.x),cam=camera.position;
  WL.list.forEach((L,k)=>{if(!L.alive){L.m.visible=false;if(on&&k<want&&day>0.05&&rnd()<dt*0.9)wlSpawn(L);return;}
    L.t+=dt;const u=L.t;let hx=L.x+d.x*L.sp*u+side.x*Math.sin(u*2.4+L.ph)*1.1,hz=L.z+d.z*L.sp*u+side.z*Math.sin(u*2.4+L.ph)*1.1,hy=L.y0+Math.sin(u*3.1+L.ph)*0.35;
    if(L.loopAt>0&&u>L.loopAt&&u<L.loopAt+0.7){const q=(u-L.loopAt)/0.7*TAU,R=0.55;hx-=d.x*Math.sin(q)*R*1.6;hz-=d.z*Math.sin(q)*R*1.6;hy+=(1-Math.cos(q))*R;}   // a loop, up and over
    L.acc+=dt;if(L.acc>0.045||!L.pts.length){L.acc=0;L.pts.unshift([hx,hy,hz]);if(L.pts.length>WL.N)L.pts.pop();}else L.pts[0]=[hx,hy,hz];
    if(u>L.life){L.alive=false;L.m.visible=false;return;}
    const pos=L.m.geometry.attributes.position,al=L.m.geometry.attributes.a,n=L.pts.length,life=Math.min(1,u/0.4)*Math.min(1,(L.life-u)/0.6);
    for(let i=0;i<WL.N;i++){const p=L.pts[Math.min(i,n-1)],q=L.pts[Math.min(i+1,n-1)]||p,tx=p[0]-q[0],ty=p[1]-q[1],tz=p[2]-q[2];
      const vx=cam.x-p[0],vy=cam.y-p[1],vz=cam.z-p[2];let sx=ty*vz-tz*vy,sy=tz*vx-tx*vz,sz=tx*vy-ty*vx;const sl=Math.hypot(sx,sy,sz)||1,f=i/(WL.N-1),w=0.085*Math.sin(Math.PI*Math.min(1,f*1.15));
      sx*=w/sl;sy*=w/sl;sz*=w/sl;pos.setXYZ(i*2,p[0]+sx,p[1]+sy,p[2]+sz);pos.setXYZ(i*2+1,p[0]-sx,p[1]-sy,p[2]-sz);
      const aa=(i<n?1:0)*Math.sin(Math.PI*Math.min(1,f*1.05))*life;al.setX(i*2,aa);al.setX(i*2+1,aa);}
    pos.needsUpdate=true;al.needsUpdate=true;L.m.visible=on;});}
