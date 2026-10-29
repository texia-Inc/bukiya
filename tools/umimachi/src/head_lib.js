/* the heroine's head, hair and ponytail were modelled in Blender (blender/heroine_head.py) and are stored as quantised buffers */
function meshFromData(d){const b=s=>Uint8Array.from(atob(s),c=>c.charCodeAt(0)).buffer,g=new THREE.BufferGeometry();
  const q=new Int16Array(b(d.pos)),p=new Float32Array(q.length);for(let i=0;i<q.length;i++)p[i]=q[i]/32767*d.lim;g.setAttribute('position',new THREE.BufferAttribute(p,3));
  const qn=new Int8Array(b(d.nor)),n=new Float32Array(qn.length);for(let i=0;i<qn.length;i++)n[i]=qn[i]/127;g.setAttribute('normal',new THREE.BufferAttribute(n,3));
  if(d.uv){const u=new Uint16Array(b(d.uv)),f=new Float32Array(u.length);for(let i=0;i<u.length;i++)f[i]=u[i]/65535;g.setAttribute('uv',new THREE.BufferAttribute(f,2));}
  if(d.col){const c=new Uint8Array(b(d.col)),f=new Float32Array(c.length*3);for(let i=0;i<c.length;i++)f[i*3]=f[i*3+1]=f[i*3+2]=c[i]/255*1.2;g.setAttribute('color',new THREE.BufferAttribute(f,3));}
  g.setIndex(new THREE.BufferAttribute(d.i32?new Uint32Array(b(d.idx)):new Uint16Array(b(d.idx)),1));g.computeBoundingSphere();return g;}
/* face texture laid out for the head's front projection: x,y in [-0.85,0.85] of the unit skull, skin everywhere else */
const FACE_SKIN='#fddccb';
function faceTex2(expr){return canvasTex(512,512,(g,w,h)=>{const U=x=>w*(0.5+x*0.5/0.85),V=y=>h*(0.5-y*0.5/0.85),S=w*0.5/0.85;
  g.fillStyle=FACE_SKIN;g.fillRect(0,0,w,h);
  // soft blush and a hint of shade under the bangs
  const gr=g.createLinearGradient(0,V(0.55),0,V(0.25));gr.addColorStop(0,'rgba(200,130,110,.28)');gr.addColorStop(1,'rgba(200,130,110,0)');g.fillStyle=gr;g.fillRect(0,V(0.6),w,V(0.25)-V(0.6));
  for(const s of [-1,1]){const rg=g.createRadialGradient(U(s*0.47),V(-0.27),2,U(s*0.47),V(-0.27),S*0.2);rg.addColorStop(0,'rgba(255,120,130,.5)');rg.addColorStop(1,'rgba(255,120,130,0)');
    g.fillStyle=rg;g.beginPath();g.ellipse(U(s*0.47),V(-0.27),S*0.22,S*0.13,0,0,7);g.fill();
    g.strokeStyle='rgba(240,90,100,.5)';g.lineWidth=2;for(let k=0;k<3;k++){g.beginPath();g.moveTo(U(s*(0.38+k*0.07)),V(-0.22));g.lineTo(U(s*(0.35+k*0.07)),V(-0.31));g.stroke();}}
  const eye=(s)=>{const cx=U(s*0.3),cy=V(0.0),ew=S*0.17,eh=S*0.2;g.lineCap='round';g.lineJoin='round';
    if(expr==='happy'){g.strokeStyle='#3a1e12';g.lineWidth=S*0.045;g.beginPath();g.moveTo(cx-ew,cy+eh*0.15);g.quadraticCurveTo(cx,cy-eh*0.9,cx+ew,cy+eh*0.15);g.stroke();return;}
    if(expr==='blink'){g.strokeStyle='#3a1e12';g.lineWidth=S*0.04;g.beginPath();g.moveTo(cx-ew*1.05,cy+eh*0.05);g.quadraticCurveTo(cx,cy+eh*0.55,cx+ew*1.05,cy+eh*0.05);g.stroke();
      g.lineWidth=S*0.02;g.beginPath();g.moveTo(cx+s*ew*1.0,cy+eh*0.05);g.lineTo(cx+s*ew*1.25,cy-eh*0.12);g.stroke();return;}
    // white of the eye, clipped to the eye shape
    g.save();g.beginPath();g.moveTo(cx-ew,cy-eh*0.55);g.quadraticCurveTo(cx,cy-eh*1.25,cx+ew,cy-eh*0.55);g.quadraticCurveTo(cx+ew*1.12,cy+eh*0.4,cx+ew*0.55,cy+eh*0.92);
    g.quadraticCurveTo(cx,cy+eh*1.08,cx-ew*0.55,cy+eh*0.92);g.quadraticCurveTo(cx-ew*1.12,cy+eh*0.4,cx-ew,cy-eh*0.55);g.closePath();g.fillStyle='#ffffff';g.fill();g.clip();
    const ix=cx+s*ew*0.08,iy=cy+eh*0.1,iw=ew*0.78,ih=eh*0.95;
    const ig=g.createLinearGradient(0,iy-ih,0,iy+ih);ig.addColorStop(0,'#3e1c0a');ig.addColorStop(0.4,'#8a4a16');ig.addColorStop(0.8,'#e09a34');ig.addColorStop(1,'#f6cb6a');
    g.fillStyle=ig;g.beginPath();g.ellipse(ix,iy,iw,ih,0,0,7);g.fill();
    g.strokeStyle='rgba(60,25,8,.8)';g.lineWidth=S*0.012;g.stroke();
    g.fillStyle='#24100a';g.beginPath();g.ellipse(ix,iy-ih*0.05,iw*0.42,ih*0.5,0,0,7);g.fill();
    g.fillStyle='rgba(255,230,160,.75)';g.beginPath();g.ellipse(ix,iy+ih*0.55,iw*0.55,ih*0.22,0,0,7);g.fill();
    g.fillStyle='rgba(40,20,10,.25)';g.fillRect(cx-ew*1.2,cy-eh*1.3,ew*2.4,eh*0.75);   // shadow of the upper lid
    g.fillStyle='#ffffff';g.beginPath();g.ellipse(ix-s*iw*0.35,iy-ih*0.4,iw*0.3,ih*0.22,-0.3*s,0,7);g.fill();g.beginPath();g.arc(ix+s*iw*0.38,iy+ih*0.3,iw*0.13,0,7);g.fill();
    g.restore();
    // thick upper lash line with a flick at the outer corner, thin lower lash
    g.strokeStyle='#2a140b';g.fillStyle='#2a140b';g.lineWidth=S*0.05;g.beginPath();g.moveTo(cx-s*ew*1.0,cy-eh*0.45);g.quadraticCurveTo(cx-s*ew*0.1,cy-eh*1.28,cx+s*ew*1.0,cy-eh*0.6);g.stroke();
    g.beginPath();g.moveTo(cx+s*ew*0.9,cy-eh*0.68);g.lineTo(cx+s*ew*1.38,cy-eh*0.85);g.lineTo(cx+s*ew*1.05,cy-eh*0.4);g.closePath();g.fill();
    g.lineWidth=S*0.014;g.strokeStyle='rgba(60,28,14,.8)';g.beginPath();g.moveTo(cx-s*ew*0.45,cy+eh*0.98);g.quadraticCurveTo(cx+s*ew*0.2,cy+eh*1.05,cx+s*ew*0.7,cy+eh*0.82);g.stroke();};
  eye(-1);eye(1);
  // brows, nose, mouth
  g.strokeStyle='rgba(90,48,25,.9)';g.lineCap='round';g.lineWidth=S*0.025;
  for(const s of [-1,1]){g.beginPath();g.moveTo(U(s*0.14),V(0.33));g.quadraticCurveTo(U(s*0.28),V(0.39),U(s*0.44),V(0.33));g.stroke();}
  g.strokeStyle='rgba(170,95,70,.6)';g.lineWidth=S*0.018;g.beginPath();g.moveTo(U(0.01),V(-0.2));g.lineTo(U(-0.015),V(-0.24));g.stroke();
  const my=V(-0.46),mx=U(0);
  if(expr==='neutral'||expr==='blink'){g.strokeStyle='#7a3026';g.lineWidth=S*0.022;g.beginPath();g.moveTo(mx-S*0.065,my-S*0.005);g.quadraticCurveTo(mx,my+S*0.035,mx+S*0.065,my-S*0.005);g.stroke();}
  else{g.fillStyle='#8a2a26';g.beginPath();g.moveTo(mx-S*0.1,my-S*0.025);g.quadraticCurveTo(mx,my-S*0.04,mx+S*0.1,my-S*0.025);g.quadraticCurveTo(mx+S*0.07,my+S*0.11,mx,my+S*0.115);g.quadraticCurveTo(mx-S*0.07,my+S*0.11,mx-S*0.1,my-S*0.025);g.fill();
    g.fillStyle='#f08a8a';g.beginPath();g.ellipse(mx,my+S*0.07,S*0.055,S*0.03,0,0,7);g.fill();g.fillStyle='#ffffff';g.fillRect(mx-S*0.07,my-S*0.03,S*0.14,S*0.02);}
});}
const FACE_GRAD=(()=>{const d=new Uint8Array([168,168,168,255,182,182,182,255]);const t=new THREE.DataTexture(d,2,1,THREE.RGBAFormat);t.minFilter=t.magFilter=THREE.NearestFilter;t.generateMipmaps=false;t.needsUpdate=true;return t;})();
