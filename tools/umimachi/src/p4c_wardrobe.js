
/* ---------- wardrobe: every garment is a part of the heroine model named W_<part> (see tools/umimachi/heroine_vrm.py).
   An outfit picks one item per slot and one colour set for it. An item lists the parts it shows and how each is coloured:
   0 / 1 = the item's first / second colour, '#rrggbb' = a fixed colour, 'dark0' = recolour the dark parts of the texture with
   the first colour. Parts exported white are tinted; parts with their own colour (the bunny charm, straps) keep it.
   The garments come from VRoid (tools/umimachi/heroine_vrm.py imports them): W_tops is the school shirt, W_hoodie and W_tee are
   white so any colour or pattern goes on them. An item can list slots it covers (the yukata): those show nothing while it is worn.
   Colours are only ever appended to an item: saves and owned prizes refer to them by index.
   To add clothes: add a part in the Blender script, then an item here. ---------- */
const CAMO={forest:['#5b6b3a','#3e4a2a','#8a7d52','#2a2a22'],desert:['#c9b07a','#a88a5a','#e0cfa0','#7a6448'],pink:['#f2a6c0','#d97a9e','#fbd6e2','#a85678'],urban:['#9aa0a8','#6a7078','#c8ccd2','#3a3e44']};
const WARDROBE=[
  {slot:'tops',label:'トップス',items:[
    {id:'uniform',name:'制服シャツ',parts:{W_tops:0},colors:[['#ffffff'],['#dde8f5'],['#f6efe0']]},
    {id:'hoodie',name:'パーカー',parts:{W_hoodie:0},
      colors:[['#33395e','#f6f5f1'],['#ece6dc','#3a3d52'],['#e48a9a','#ffffff'],['#5d8a64','#f6f5f1'],['#2b2b30','#f2d36b'],['#8fb8e0','#ffffff']]},
    {id:'camo',name:'迷彩パーカー',parts:{W_hoodie:{pat:'camo'}},
      colors:[CAMO.forest,CAMO.desert,CAMO.pink,CAMO.urban]},
    {id:'tee',name:'Tシャツ',parts:{W_tee:0},colors:[['#f6f5f1'],['#9cc3e6'],['#f2c9c4'],['#f5e07a'],['#b8d8a8'],['#2b2b30']]},
    {id:'tee_dots',name:'水玉Tシャツ',parts:{W_tee:{pat:'dots'}},colors:[['#f6f5f1','#e05a6a'],['#2b2b30','#f6f5f1'],['#9cc3e6','#ffffff']]},
    {id:'tee_stars',name:'星柄Tシャツ',parts:{W_tee:{pat:'stars'}},colors:[['#2d3a6a','#f5d86a'],['#f6f5f1','#e88fa8'],['#2b2b30','#9ad8f0']]},
    // the yukata reaches the ankles and comes with geta: while it is worn the other slots it covers show nothing
    {id:'yukata',name:'浴衣',parts:{W_yukata:'#ffffff',W_geta:'#ffffff'},covers:['neck','bottoms','legs','shoes'],colors:[['#ffffff']]}]},
  {slot:'neck',label:'えり元',items:[
    {id:'ribbon',name:'制服リボン',parts:{W_tie:0},colors:[['#8fb8e0'],['#c8323a'],['#2d3a6a'],['#3f7a5a']]},
    {id:'bow',name:'リボン',parts:{},extra:'bow',colors:[['#c8323a'],['#2d4f9a'],['#f0879c'],['#2b2b30']]},
    {id:'choker',name:'鈴のチョーカー',parts:{W_choker:0},colors:[['#2b2b30'],['#c8323a'],['#7a5a8f']]},
    {id:'dogtag',name:'ドッグタグ',parts:{},extra:'dogtag',colors:[['#9aa1ab']]},
    {id:'sailor',name:'セーラーえり',parts:{W_sailorcollar:0,W_sailorcollar_line:1},extra:'bow',extraCol:2,colors:[['#2d3a6a','#f6f5f1','#c8323a'],['#f6f5f1','#2d3a6a','#2d3a6a'],['#2b2b30','#f6f5f1','#e05a6a']]},
    {id:'none',name:'なし',parts:{}}]},
  {slot:'bottoms',label:'ボトムス',items:[
    {id:'skirt',name:'チェックスカート',parts:{W_skirt:0,W_shorts:'#2c2f44'},colors:[['#6f7488'],['#b0484f'],['#4d7a5f'],['#9a8a6a'],['#c98aa0'],['#3b4a78']]},
    {id:'zigzag',name:'ギザギザスカート',parts:{W_skirtzig:0,W_shorts:'#2c2f44'},colors:[['#2b2433'],['#5a3a7a'],['#e07a2a']]},
    {id:'shorts',name:'ショートパンツ',parts:{W_shorts:0},colors:[['#2c2f44'],['#d9cdb4'],['#6f8fb5'],['#f2f0ea']]},
    {id:'cargo',name:'カーゴショーツ',parts:{W_shorts:{pat:'camo'},W_cargo:{pat:'camo'}},colors:[CAMO.forest,CAMO.desert,CAMO.urban]}]},
  {slot:'legs',label:'くつ下',items:[
    {id:'socks',name:'クルーソックス',parts:{W_socks:0,W_sockband:1},colors:[['#2a2a30','#f0879c'],['#f6f5f1','#33395e'],['#f6f5f1','#f0879c'],['#33395e','#f6f5f1']]},
    {id:'knee',name:'ハイソックス',parts:{W_kneesocks:0},colors:[['#2a2a30'],['#f6f5f1'],['#33395e']]},
    {id:'kneestripe',name:'しましまハイソックス',parts:{W_kneesocks:{pat:'stripe'}},colors:[['#2d3a6a','#f6f5f1'],['#e05a6a','#f6f5f1'],['#2b2b30','#f0879c']]},
    {id:'tights',name:'タイツ',parts:{W_tights:0},colors:[['#2a2a30'],['#5a4a44'],['#e8d6c8']]},
    {id:'witchtights',name:'しましまタイツ',parts:{W_tights:{pat:'stripe'}},colors:[['#e07a2a','#4a2a6a'],['#2b2b30','#f6f5f1'],['#7a3a9a','#9ad860']]},
    {id:'none',name:'なし',parts:{}}]},
  {slot:'shoes',label:'くつ',items:[
    {id:'sneakers',name:'スニーカー',parts:{W_shoes:'upper0'},colors:[['#f07a93'],['#2b2b30'],['#f6f5f1'],['#4f8fd8'],['#f5c84a'],['#7cc39a'],['#f2994a']]}]},
  {slot:'hands',label:'手',items:[
    {id:'none',name:'なし',parts:{}},
    {id:'paws',name:'肉球てぶくろ',parts:{},extra:'paws',colors:[['#2b2b30'],['#f6f5f1'],['#e8b07a']]}]},
  {slot:'head',label:'あたま',items:[
    {id:'clip',name:'Xクリップ',parts:{W_clip:0},colors:[['#ef6f8a'],['#5fb0e8'],['#f5c84a'],['#f6f5f1']]},
    {id:'glasses',name:'まるメガネ',parts:{W_glasses:0},colors:[['#5a3a2a'],['#2b2b30'],['#d4a24a']]},
    {id:'sunglasses',name:'サングラス',parts:{W_sunglasses:0},colors:[['#2b2b30'],['#d4a24a'],['#e05a6a']]},
    {id:'witchhat',name:'魔女のとんがり帽子',parts:{W_witchhat:0,W_witchhat_crown:0,W_witchhat_band:1},colors:[['#2b2433','#e07a2a'],['#4a2a6a','#9ad860'],['#e07a2a','#2b2433']]},
    {id:'catears',name:'ねこ耳',parts:{W_catears:0},colors:[['#2b2b30'],['#f6f5f1'],['#e8b07a']]},
    {id:'horns',name:'小悪魔の角',parts:{W_horns:0},colors:[['#2b2b30'],['#c8323a'],['#7a3a9a']]},
    {id:'halo',name:'天使の輪',parts:{W_halo:0},colors:[['#f5d86a'],['#f6f5f1']]},
    {id:'beret',name:'ベレー帽',parts:{W_beret:0,W_beret_nub:0},colors:[['#4d5a34'],['#c8323a'],['#2b2b30'],['#d9cdb4']]},
    {id:'marine',name:'マリン帽',parts:{W_marinecap:0,W_marinecap_brim:0,W_marinecap_band:1},colors:[['#f6f5f1','#2d3a6a'],['#2d3a6a','#f6f5f1']]},
    {id:'none',name:'なし',parts:{}}]},
  {slot:'tie',label:'シュシュ',items:[
    {id:'scrunchie',name:'シュシュ',parts:{W_scrunchie:0},colors:[['#d8455a'],['#f6f5f1'],['#33395e'],['#f5c84a'],['#7cc39a'],['#9cc3e6']]}]},
  {slot:'back',label:'せなか',items:[
    {id:'pack',name:'リュック',parts:{W_pack:0},colors:[['#232327'],['#c9a36a'],['#ece6dc'],['#7a5a8f'],['#d86a7c']]},
    {id:'cape',name:'マント',parts:{},extra:'cape',colors:[['#2b2433'],['#4a2a6a'],['#8a1f2a']]},
    {id:'batwings',name:'コウモリの羽',parts:{W_batwings:0},colors:[['#2b2433'],['#4a2a6a'],['#8a1f2a']]},
    {id:'angelwings',name:'天使の羽',parts:{W_angelwings:0},colors:[['#ffffff'],['#f2d8e4']]},
    {id:'none',name:'なし',parts:{}}]},
  {slot:'waist',label:'こし',items:[
    {id:'none',name:'なし',parts:{}},
    {id:'cattail',name:'ねこのしっぽ',parts:{W_cattail:0},colors:[['#2b2b30'],['#f6f5f1'],['#e8b07a']]},
    {id:'deviltail',name:'小悪魔のしっぽ',parts:{W_deviltail:0},colors:[['#2b2b30'],['#c8323a']]},
    {id:'pumpkin',name:'かぼちゃポーチ',parts:{W_pumpkin:'#ffffff'},colors:[['#ffffff']]}]},
  {slot:'hair',label:'髪の色',items:[
    {id:'hair',name:'髪',parts:{},hair:true,colors:[[null],['#8a5530'],['#d9b06a'],['#e88fa8'],['#8a9fd0'],['#b9b9c2']]}]},
];
// Nagi's summer school uniform (tools/umimachi/design/06_turnaround_uniform_fixed.png)
const DEFAULT_OUTFIT={tops:['uniform',0],neck:['ribbon',0],bottoms:['skirt',5],legs:['knee',2],shoes:['sneakers',2],hands:['none',0],head:['none',0],tie:['scrunchie',5],back:['none',0],waist:['none',0],hair:['hair',0]};
// the everyday outfit she used to start in stays free
const OLD_STARTER=['tops:hoodie:0','tops:tee:0','neck:bow:0','bottoms:skirt:0','bottoms:shorts:0','legs:socks:0','shoes:sneakers:0','shoes:sneakers:6','head:clip:0','tie:scrunchie:0','back:pack:0'];
const _texCache={};
// recolour a texture on a canvas: 'hair' keeps the shading and replaces the hue, 'dark' paints only the dark areas
function recolorTex(map,hex,mode){const key=map.uuid+mode+hex;if(_texCache[key])return _texCache[key];
  const img=map.image,c=document.createElement('canvas');c.width=img.width;c.height=img.height;const g=c.getContext('2d');g.drawImage(img,0,0);
  const d=g.getImageData(0,0,c.width,c.height),p=d.data,col=new THREE.Color(hex);let ref=0.4;
  if(mode==='hair'){let s=0,n=0;for(let i=0;i<p.length;i+=64){s+=(0.3*p[i]+0.59*p[i+1]+0.11*p[i+2])/255;n++;}ref=Math.max(0.05,s/n);}
  for(let i=0;i<p.length;i+=4){const l=(0.3*p[i]+0.59*p[i+1]+0.11*p[i+2])/255;
    if(mode==='hair'){const k=Math.pow(l/ref,0.9)*0.85;p[i]=clamp(col.r*k*255,0,255);p[i+1]=clamp(col.g*k*255,0,255);p[i+2]=clamp(col.b*k*255,0,255);}
    else if(l<0.4){const k=0.78+l*0.9;p[i]=clamp(col.r*k*255,0,255);p[i+1]=clamp(col.g*k*255,0,255);p[i+2]=clamp(col.b*k*255,0,255);}}
  g.putImageData(d,0,0);const t=new THREE.CanvasTexture(c);t.flipY=map.flipY;t.wrapS=map.wrapS;t.wrapT=map.wrapT;return _texCache[key]=t;}
// patterns: on a textured garment they are painted into a texture; on a plain part (the skin shells, accessories) they become
// vertex colours worked out from where each vertex sits on the body, so stripes run round the legs whatever the UVs are
const _patCache={};
function patternTex(kind,cols){const key=kind+cols.join();if(_patCache[key])return _patCache[key];
  const c=document.createElement('canvas');c.width=c.height=256;const g=c.getContext('2d'),r=mulberry(7+kind.length);g.fillStyle=cols[0];g.fillRect(0,0,256,256);
  if(kind==='camo'){for(let L=1;L<cols.length;L++){g.fillStyle=cols[L];for(let k=0;k<26;k++){const x=r()*256,y=r()*256;g.beginPath();for(let a=0;a<7;a++){const t=a/7*TAU,rr=10+r()*18;g.lineTo(x+Math.cos(t)*rr*1.4,y+Math.sin(t)*rr);}g.closePath();g.fill();}}}
  else if(kind==='stripe'){g.fillStyle=cols[1];for(let y=0;y<256;y+=32)g.fillRect(0,y,256,16);}
  else if(kind==='dots'){g.fillStyle=cols[1];for(let y=0;y<256;y+=32)for(let x=(y/32)%2*16;x<256;x+=32){g.beginPath();g.arc(x,y,6,0,TAU);g.fill();}}
  else if(kind==='stars'){g.fillStyle=cols[1];for(let k=0;k<40;k++){const x=r()*256,y=r()*256,s=5+r()*5;g.beginPath();for(let a=0;a<10;a++){const t=a/10*TAU-Math.PI/2,rr=a%2?s*0.45:s;g.lineTo(x+Math.cos(t)*rr,y+Math.sin(t)*rr);}g.closePath();g.fill();}}
  const t=new THREE.CanvasTexture(c);t.wrapS=t.wrapT=THREE.RepeatWrapping;t.repeat.set(2,2);return _patCache[key]=t;}
function patternVerts(mesh,kind,cols){const geo=mesh.geometry,p=geo.attributes.position,C=cols.map(x=>new THREE.Color(x)),out=new Float32Array(p.count*3);
  for(let i=0;i<p.count;i++){const x=p.getX(i),y=p.getY(i),z=p.getZ(i);let k=0;
    if(kind==='stripe')k=Math.floor(y/0.032+100)%2;
    else{const n=vnoise(x*9+z*5,y*9+z*3);k=n<0.42?0:n<0.58?1:n<0.72?2:3;k=Math.min(k,C.length-1);}
    out[i*3]=C[k].r;out[i*3+1]=C[k].g;out[i*3+2]=C[k].b;}
  geo.setAttribute('color',new THREE.BufferAttribute(out,3));}
// the sneakers: the colour goes on everything above the sole, the sole stays white (the texture's shading and laces show through)
function upperVerts(mesh,hex){const geo=mesh.geometry,p=geo.attributes.position,c=new THREE.Color(hex),w=new THREE.Color('#f6f5f1'),out=new Float32Array(p.count*3);
  for(let i=0;i<p.count;i++){const k=p.getY(i)<0.024?w:c;out[i*3]=k.r;out[i*3+1]=k.g;out[i*3+2]=k.b;}geo.setAttribute('color',new THREE.BufferAttribute(out,3));}
function findItem(slot,id){const S=WARDROBE.find(s=>s.slot===slot);return S&&(S.items.find(i=>i.id===id)||S.items[0]);}
function applyOutfit(h,outfit){const V=h.vrm;if(!V||!V.parts)return;outfit=Object.assign({},DEFAULT_OUTFIT,outfit||{});
  h.backBusy=['cape','batwings','angelwings'].includes((outfit.back||[])[0]);   // then the board is carried in the hand, not on the back
  const show={},extras={};   // part name -> colour spec; extra -> its colours
  const covered=new Set();for(const S of WARDROBE){const it=findItem(S.slot,(outfit[S.slot]||[])[0]);if(it&&it.covers)it.covers.forEach(c=>covered.add(c));}
  for(const S of WARDROBE){if(covered.has(S.slot))continue;const [id,ci]=outfit[S.slot]||[];const it=findItem(S.slot,id);if(!it)continue;const cs=(it.colors&&it.colors[ci||0])||(it.colors&&it.colors[0])||[];
    for(const k in it.parts){const v=it.parts[k];show[k]=typeof v==='number'?cs[v]:v==='dark0'?{dark:cs[0]}:v==='upper0'?{upper:cs[0]}:v&&v.pat?{pat:v.pat,cols:cs}:v;}
    if(it.extra)extras[it.extra]=it.extraCol?[cs[it.extraCol]]:cs;
    if(it.hair)for(const m of V.hair){m.material.map=cs[0]?recolorTex(m.userData.map0,cs[0],'hair'):m.userData.map0;m.material.needsUpdate=true;}}
  for(const P of V.parts){const key=Object.keys(show).filter(k=>P.name===k||P.name.startsWith(k+'_')).sort((a,b)=>b.length-a.length)[0];const on=!!key;
    P.mesh.visible=on;if(P.mesh.userData.ol)P.mesh.userData.ol.visible=on;if(!on)continue;const spec=show[key];
    const m=P.mesh.material,was=m.vertexColors,wasMap=m.map;
    if(spec&&spec.pat){const cols=spec.cols;if(P.map0){m.map=patternTex(spec.pat,cols);m.vertexColors=false;}else{patternVerts(P.mesh,spec.pat,cols);m.vertexColors=true;}m.color.set('#ffffff');}
    else{m.vertexColors=false;m.map=P.map0;
      if(spec&&spec.dark){m.map=recolorTex(P.map0,spec.dark,'dark');m.color.set('#ffffff');}
      else if(spec&&spec.upper){upperVerts(P.mesh,spec.upper);m.vertexColors=true;m.color.set('#ffffff');}
      else if(typeof spec==='string'&&P.tintable)m.color.set(spec);
      else if(P.tintable)m.color.copy(P.base);}
    if(m.vertexColors!==was||m.map!==wasMap)m.needsUpdate=true;}
  // the legs under the yukata (ankles to hips), or the thighs under a skirt (from the shorts' hem up)
  wearExtras(h,extras);legsUnder(V,covered.has('bottoms')?[0.15,0.88]:show.W_skirt||show.W_skirtzig?[0.705,0.88]:null);}
// legs under the yukata or a skirt are not drawn: on the board her knees bend and spread wider than the cloth can follow,
// and the skin came through it. The body's outline gets its own material that leaves out the same part
function legsUnder(V,range){if(!V.body){V.model.traverse(o=>{if(o.isSkinnedMesh&&o.name==='Body_(merged)')V.body=o;});if(!V.body)return;
    const m=V.body.material,u={value:new THREE.Vector2(9,9)};m.userData.hide=u;
    m.onBeforeCompile=sh=>{sh.uniforms.uHide=u;sh.vertexShader='varying float vBy;\n'+sh.vertexShader.replace('#include <begin_vertex>','#include <begin_vertex>\nvBy=position.y;');
      sh.fragmentShader='uniform vec2 uHide;\nvarying float vBy;\n'+sh.fragmentShader.replace('void main() {','void main() {\nif(vBy>uHide.x&&vBy<uHide.y)discard;');};
    m.customProgramCacheKey=()=>'bodylegs';m.needsUpdate=true;
    const ol=V.body.userData.ol;if(ol){const om=new THREE.MeshBasicMaterial({color:'#2d241d',side:THREE.BackSide,skinning:true,morphTargets:!!V.body.morphTargetInfluences});
      om.onBeforeCompile=sh=>{sh.uniforms.uHide=u;sh.vertexShader='varying float vBy;\n'+sh.vertexShader.replace('#include <begin_vertex>','vec3 transformed = position + normal * 0.0026;\nvBy=position.y;');
        sh.fragmentShader='uniform vec2 uHide;\nvarying float vBy;\n'+sh.fragmentShader.replace('void main() {','void main() {\nif(vBy>uHide.x&&vBy<uHide.y)discard;');};
      om.customProgramCacheKey=()=>'olbodylegs';ol.material=om;}}
  V.body.material.userData.hide.value.set(range?range[0]:9,range?range[1]:9);}

/* extras: garments built here rather than in the model, fixed to a bone: the big cat-paw mittens and the dog tags on their chain.
   Each is made in the model's own axes (+z forward, +x her left) at rest and carried by the bone from then on */
function onBone(V,bone,p){const r=V.rest[bone],iq=r.q.clone().invert(),g=new THREE.Group();g.position.copy(p.clone().sub(r.p).applyQuaternion(iq));g.quaternion.copy(iq);V.B[bone].add(g);return g;}
const EXTRAS={
  paws(V){const fur=new THREE.MeshToonMaterial({color:'#2b2b30',gradientMap:GRAD}),cuff=new THREE.MeshToonMaterial({color:'#44444a',gradientMap:GRAD}),pad=tm('#f4a0b4'),gs=[];
    const S=(g,mat,x,y,z,sx,sy,sz,ol)=>{const m=new THREE.Mesh(new THREE.SphereGeometry(1,16,12),mat);m.position.set(x,y,z);m.scale.set(sx,sy,sz);m.castShadow=true;if(ol)outline(m,ol/Math.max(sx,sy,sz));g.add(m);return m;};
    for(const [n,sx] of [['L',1],['R',-1]]){const g=onBone(V,'J_Bip_'+n+'_Hand',V.rest['J_Bip_'+n+'_Hand'].p);
      S(g,fur,sx*0.065,0,-0.02,0.1,0.062,0.07,0.004);   // the paw
      for(const z of [-0.075,-0.045,0.005,0.035].map(v=>v+0.005))S(g,fur,sx*0.14,0.012,z-0.0,0.032,0.034,0.026,0.003);   // the four toes on top of its end
      const c=new THREE.Mesh(new THREE.CylinderGeometry(0.06,0.064,0.05,16).rotateZ(Math.PI/2),cuff);c.position.set(sx*0.0,0,-0.02);outline(c,0.003);g.add(c);
      S(g,pad,sx*0.065,-0.058,-0.02,0.034,0.01,0.036);for(const [x,z] of [[0.125,-0.062],[0.138,-0.034],[0.138,-0.006],[0.125,0.022]])S(g,pad,sx*x,-0.046,z,0.014,0.007,0.013);
      gs.push(g);}
    return{objs:gs,tint(cs){const c=new THREE.Color(cs[0]);fur.color.copy(c);cuff.color.copy(c).lerp(new THREE.Color('#ffffff'),0.25);}};},
  dogtag(V){const metal=new THREE.MeshToonMaterial({color:'#9aa1ab',gradientMap:GRAD}),g=onBone(V,'J_Bip_C_UpperChest',V.rest.J_Bip_C_UpperChest.p);
    const pts=[[0,1.342,-0.076],[0.056,1.33,-0.048],[0.074,1.29,0.032],[0.06,1.25,0.104],[0.03,1.218,0.136],[0,1.208,0.144],[-0.03,1.218,0.136],[-0.06,1.25,0.104],[-0.074,1.29,0.032],[-0.056,1.33,-0.048]]
      .map(([x,y,z])=>new THREE.Vector3(x,y,z).sub(V.rest.J_Bip_C_UpperChest.p));
    const ch=new THREE.Mesh(new THREE.TubeGeometry(new THREE.CatmullRomCurve3(pts,true),60,0.0042,5,true),metal);outline(ch,0.0018);g.add(ch);
    const tex=canvasTex(64,96,(c,w,h)=>{c.fillStyle='#b9bec6';c.fillRect(0,0,w,h);c.fillStyle='#5a6068';c.font='900 13px monospace';c.textAlign='center';['NAGI','UMI','MACHI','0607'].forEach((t,k)=>c.fillText(t,w/2,30+k*17));
      c.fillStyle='#ffffff';c.beginPath();c.arc(w/2,11,5,0,7);c.fill();});
    const tm2=[metal,metal,metal,metal,new THREE.MeshToonMaterial({map:tex,gradientMap:GRAD}),metal];const top=V.rest.J_Bip_C_UpperChest.p;
    for(const [dx,dy,dz,rz] of [[0.007,0,0.003,0.12],[-0.008,-0.012,-0.001,-0.18]]){const t=new THREE.Mesh(new THREE.BoxGeometry(0.044,0.07,0.005),tm2);outline(t,0.003);
      t.position.set(dx,1.208-0.037+dy-top.y,0.153+dz-top.z);t.rotation.set(-0.12,0,rz);t.castShadow=true;g.add(t);}
    return{objs:[g],tint(cs){metal.color.set(cs[0]);}};}};
// the bow at the collar: two loops, the knot, and two tails with notched ends
EXTRAS.bow=V=>{const mat=new THREE.MeshToonMaterial({color:'#c8323a',gradientMap:GRAD,side:THREE.DoubleSide}),c=new THREE.Vector3(0,1.263,0.098),g=onBone(V,'J_Bip_C_UpperChest',c);
  const A=(m,x,y,z)=>{m.position.set(x,y,z);m.castShadow=true;outline(m,0.0016);g.add(m);return m;};
  // each wing is drawn on its own side (not mirrored by a negative scale, which would turn its outline inside out)
  const wingGeo=sd=>{const w=new THREE.Shape();w.moveTo(0,0.007);w.quadraticCurveTo(sd*0.026,0.036,sd*0.046,0.022);w.quadraticCurveTo(sd*0.054,0,sd*0.046,-0.022);w.quadraticCurveTo(sd*0.026,-0.036,0,-0.007);w.closePath();
    return new THREE.ExtrudeGeometry(w,{depth:0.006,bevelEnabled:true,bevelThickness:0.004,bevelSize:0.003,bevelSegments:3,curveSegments:10});};
  for(const sd of [-1,1]){const l=A(new THREE.Mesh(wingGeo(sd),mat),0,0.002,-0.006);l.rotation.set(0,sd*0.3,sd*0.12);
    const sh=new THREE.Shape();sh.moveTo(-0.009,0);sh.lineTo(0.009,0);sh.lineTo(0.011,-0.058);sh.lineTo(0,-0.05);sh.lineTo(-0.011,-0.058);sh.closePath();
    const t=A(new THREE.Mesh(new THREE.ExtrudeGeometry(sh,{depth:0.003,bevelEnabled:false}),mat),sd*0.005,-0.004,-0.004);t.rotation.set(-0.15,0,sd*0.38);}
  A(new THREE.Mesh(new THREE.SphereGeometry(0.012,10,8),mat),0,0,0.002).scale.set(1,1.15,0.8);
  return{objs:[g],tint(cs){mat.color.set(cs[0]);}};};
// the cape: a cloth hung from the shoulders down to the knees, lined in another colour, with a standing collar and a clasp.
// It hangs from a point behind the neck and keeps hanging down whichever way she leans; with speed and in the air it streams back
EXTRAS.cape=V=>{const out=new THREE.MeshToonMaterial({color:'#2b2433',gradientMap:GRAD,side:THREE.FrontSide}),lin=new THREE.MeshToonMaterial({color:'#8a1f2a',gradientMap:GRAD,side:THREE.BackSide});
  const top=new THREE.Vector3(0,1.36,-0.05),pivot=onBone(V,'J_Bip_C_UpperChest',top),hang=new THREE.Group();pivot.add(hang);
  const geo=new THREE.CylinderGeometry(1,1,1,28,10,true,Math.PI/2-0.45,Math.PI+0.9),p=geo.attributes.position;
  for(let i=0;i<p.count;i++){const t=0.5-p.getY(i),a=Math.atan2(p.getX(i),p.getZ(i)),fold=1+0.07*Math.sin(a*7)*t;   // t: 0 at the shoulders, 1 at the hem
    const rx=(0.17+0.2*t)*fold,rz=(0.12+0.19*t)*fold;p.setXYZ(i,Math.sin(a)*rx,-t*0.74+Math.sin(a*7)*0.012*t,Math.cos(a)*rz+0.05);}
  geo.computeVertexNormals();
  for(const m of [out,lin]){const c=new THREE.Mesh(geo,m);c.castShadow=true;hang.add(c);}outline(hang.children[0],0.003);
  const col=new THREE.Mesh(new THREE.CylinderGeometry(0.095,0.085,0.07,20,1,true,Math.PI/2-0.2,Math.PI+0.4),lin);col.position.set(0,0.03,0.035);hang.add(col);
  const cl=new THREE.Mesh(new THREE.SphereGeometry(0.011,10,8),tm('#d4a24a'));outline(cl,0.0015);pivot.add(cl);cl.position.set(0,-0.045,0.135);
  const cord=new THREE.Mesh(new THREE.TubeGeometry(new THREE.CatmullRomCurve3([new THREE.Vector3(-0.13,-0.025,0.07),new THREE.Vector3(-0.05,-0.042,0.125),new THREE.Vector3(0,-0.045,0.135),new THREE.Vector3(0.05,-0.042,0.125),new THREE.Vector3(0.13,-0.025,0.07)]),20,0.0035,5,false),tm('#d4a24a'));pivot.add(cord);
  const _p=new THREE.Quaternion(),_w=new THREE.Quaternion(),_f=new THREE.Vector3(),_r=V.rest.J_Bip_C_Hips.q.clone().invert();let sw=0;   // _r: from the hip bone's axes back to the model's
  return{objs:[pivot],tint(cs){out.color.set(cs[0]);lin.color.set(cs[0].toLowerCase()==='#8a1f2a'?'#2b2433':'#8a1f2a');},
    update(dt,s){const hip=V.B.J_Bip_C_Hips;hip.getWorldQuaternion(_w).multiply(_r);_f.set(0,0,1).applyQuaternion(_w);const yaw=Math.atan2(_f.x,_f.z);
      const want=clamp((s.v||0)*0.05+(s.air?0.35:0),0,0.85)+Math.sin(V.t*3.1)*0.03*(0.3+Math.min(1,(s.v||0)/6));sw+=(want-sw)*Math.min(1,dt*4);
      pivot.parent.getWorldQuaternion(_p).invert();_w.setFromEuler(new THREE.Euler(sw,yaw,0,'YXZ'));hang.quaternion.copy(_p.multiply(_w));
      hang.quaternion.premultiply(pivot.quaternion.clone().invert());}};};
function wearExtras(h,want){const V=h.vrm;V.extras=V.extras||{};
  for(const k in EXTRAS){let e=V.extras[k];if(want[k]&&!e)e=V.extras[k]=EXTRAS[k](V);if(!e)continue;for(const o of e.objs)o.visible=!!want[k];if(want[k])e.tint(want[k]);}}

/* ---------- gacha: every item and colour (except "none") is a prize; you start with the everyday outfit ---------- */
const RARITY={yukata:'SR',camo:'R',tee_dots:'R',tee_stars:'R',choker:'R',dogtag:'R',sailor:'R',zigzag:'R',cargo:'R',kneestripe:'R',witchtights:'R',
  glasses:'R',sunglasses:'R',beret:'R',marine:'R',pumpkin:'R',hair:'R',
  witchhat:'SR',cape:'SR',catears:'SR',cattail:'SR',paws:'SR',horns:'SR',batwings:'SR',deviltail:'SR',halo:'SR',angelwings:'SR'};
const RATES={N:0.7,R:0.25,SR:0.05},KAKERA_DUP={N:1,R:3,SR:10},KAKERA_COST={N:5,R:15,SR:40};
const COSTUME_SETS=[
  {name:'ハロウィン魔女',icon:'🎃',keys:['head:witchhat','back:cape','bottoms:zigzag','legs:witchtights','waist:pumpkin']},
  {name:'黒ねこ',icon:'🐈‍⬛',keys:['head:catears','waist:cattail','hands:paws','neck:choker']},
  {name:'ミリタリー',icon:'🪖',keys:['tops:camo','bottoms:cargo','head:beret','neck:dogtag','head:sunglasses']},
  {name:'小悪魔',icon:'😈',keys:['head:horns','back:batwings','waist:deviltail']},
  {name:'天使',icon:'😇',keys:['head:halo','back:angelwings']},
  {name:'セーラー',icon:'⚓',keys:['neck:sailor','head:marine','legs:kneestripe']}];
const STARTER=new Set([...Object.entries(DEFAULT_OUTFIT).map(([s,[id,ci]])=>s+':'+id+':'+ci),...OLD_STARTER]);
function prizeList(){const L=[];for(const S of WARDROBE)for(const it of S.items){if(it.id==='none')continue;
    (it.colors||[[]]).forEach((c,ci)=>{const key=S.slot+':'+it.id+':'+ci;if(STARTER.has(key))return;L.push({key,slot:S.slot,id:it.id,ci,name:it.name,r:RARITY[it.id]||'N',col:c});});}
  return L;}
const PRIZES=prizeList();
function ownsKey(save,key){return STARTER.has(key)||!!(save.owned&&save.owned[key]);}
function ownsItem(save,slot,it){return it.id==='none'||(it.colors||[[]]).some((c,ci)=>ownsKey(save,slot+':'+it.id+':'+ci));}
function drawPrize(){const x=Math.random();const r=x<RATES.SR?'SR':x<RATES.SR+RATES.R?'R':'N';const pool=PRIZES.filter(p=>p.r===r);return pool[Math.floor(Math.random()*pool.length)];}
