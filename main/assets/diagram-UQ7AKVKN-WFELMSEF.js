import{a as F}from"./chunk-CDENLQJG.js";import{a as E}from"./chunk-BMQDWVSG.js";import{a as D}from"./chunk-PCGVPVRQ.js";import"./chunk-QNBXOM7U.js";import"./chunk-ZFFKTRVX.js";import"./chunk-DKYAF235.js";import"./chunk-X7BLBFFS.js";import"./chunk-KVFXNR4L.js";import"./chunk-YMFA7VWU.js";import"./chunk-C7GWRE6Z.js";import"./chunk-4DL6P2YZ.js";import"./chunk-KCWUFFIE.js";import"./chunk-RDO2S4TE.js";import"./chunk-XCFPDLUP.js";import"./chunk-RMEGOE55.js";import"./chunk-NMQHKCXS.js";import"./chunk-SEHHQ34Z.js";import"./chunk-K6AAXKM5.js";import"./chunk-RVPSGR2P.js";import{o as y}from"./chunk-MNCGMG7K.js";import"./chunk-VLJCJ4DM.js";import{O as L,T,U as S,V as k,W as O,X as R,Y as I,Z as _,i as A,k as M,u as b}from"./chunk-H6HJX7CE.js";import{b as C}from"./chunk-BG5BKATX.js";import{a as i}from"./chunk-YUSHYV7C.js";import"./chunk-OOJM4CTU.js";var x={showLegend:!0,ticks:5,max:null,min:0,graticule:"circle"},w=32,P={axes:[],curves:[],options:x},g=structuredClone(P),U=M.radar,X=i(()=>y({...U,...b().radar}),"getConfig"),z=i(()=>g.axes,"getAxes"),K=i(()=>g.curves,"getCurves"),N=i(()=>g.options,"getOptions"),Y=i(a=>{g.axes=a.map(t=>({name:t.name,label:t.label??t.name}))},"setAxes"),Z=i(a=>{g.curves=a.map(t=>({name:t.name,label:t.label??t.name,entries:q(t.entries)}))},"setCurves"),q=i(a=>{if(a[0].axis==null)return a.map(e=>e.value);let t=z();if(t.length===0)throw new Error("Axes must be populated before curves for reference entries");return t.map(e=>{let r=a.find(n=>n.axis?.$refText===e.name);if(r===void 0)throw new Error("Missing entry for axis "+e.label);return r.value})},"computeCurveEntries"),J=i(a=>{let t=a.reduce((e,r)=>(e[r.name]=r,e),{});g.options={showLegend:t.showLegend?.value??x.showLegend,ticks:t.ticks?.value??x.ticks,max:t.max?.value??x.max,min:t.min?.value??x.min,graticule:t.graticule?.value??x.graticule},g.options.ticks>w&&(C.warn(`Radar diagram ticks (${g.options.ticks}) exceeds maximum allowed (${w}). Using ${w} instead.`),g.options.ticks=w)},"setOptions"),Q=i(()=>{T(),g=structuredClone(P)},"clear"),$={getAxes:z,getCurves:K,getOptions:N,setAxes:Y,setCurves:Z,setOptions:J,getConfig:X,clear:Q,setAccTitle:S,getAccTitle:k,setDiagramTitle:I,getDiagramTitle:_,getAccDescription:R,setAccDescription:O},tt=i(a=>{F(a,$);let{axes:t,curves:e,options:r}=a;$.setAxes(t),$.setCurves(e),$.setOptions(r)},"populate"),et={parse:i(async a=>{let t=await D("radar",a);C.debug(t),tt(t)},"parse")},at=i((a,t,e,r)=>{let n=r.db,l=n.getAxes(),c=n.getCurves(),s=n.getOptions(),o=n.getConfig(),d=n.getDiagramTitle(),p=E(t),u=rt(p,o),m=s.max??Math.max(...c.map(f=>Math.max(...f.entries))),h=s.min,v=Math.min(o.width,o.height)/2;nt(u,l,v,s.ticks,s.graticule),st(u,l,v,o),G(u,l,c,h,m,s.graticule,o),V(u,c,s.showLegend,o),u.append("text").attr("class","radarTitle").text(d).attr("x",0).attr("y",-o.height/2-o.marginTop)},"draw"),rt=i((a,t)=>{let e=t.width+t.marginLeft+t.marginRight,r=t.height+t.marginTop+t.marginBottom,n={x:t.marginLeft+t.width/2,y:t.marginTop+t.height/2};return L(a,r,e,t.useMaxWidth??!0),a.attr("viewBox",`0 0 ${e} ${r}`).attr("overflow","visible"),a.append("g").attr("transform",`translate(${n.x}, ${n.y})`)},"drawFrame"),nt=i((a,t,e,r,n)=>{if(n==="circle")for(let l=0;l<r;l++){let c=e*(l+1)/r;a.append("circle").attr("r",c).attr("class","radarGraticule")}else if(n==="polygon"){let l=t.length;for(let c=0;c<r;c++){let s=e*(c+1)/r,o=t.map((d,p)=>{let u=2*p*Math.PI/l-Math.PI/2,m=s*Math.cos(u),h=s*Math.sin(u);return`${m},${h}`}).join(" ");a.append("polygon").attr("points",o).attr("class","radarGraticule")}}},"drawGraticule"),st=i((a,t,e,r)=>{let n=t.length;for(let l=0;l<n;l++){let c=t[l].label,s=2*l*Math.PI/n-Math.PI/2,o=Math.cos(s),d=Math.sin(s);a.append("line").attr("x1",0).attr("y1",0).attr("x2",e*r.axisScaleFactor*o).attr("y2",e*r.axisScaleFactor*d).attr("class","radarAxisLine");let p=o>.01?"start":o<-.01?"end":"middle",u=d>.01?"hanging":d<-.01?"auto":"central",m=4;a.append("text").text(c).attr("x",e*r.axisLabelFactor*o+m*o).attr("y",e*r.axisLabelFactor*d+m*d).attr("text-anchor",p).attr("dominant-baseline",u).attr("class","radarAxisLabel")}},"drawAxes");function G(a,t,e,r,n,l,c){let s=t.length,o=Math.min(c.width,c.height)/2;e.forEach((d,p)=>{if(d.entries.length!==s)return;let u=d.entries.map((m,h)=>{let v=2*Math.PI*h/s-Math.PI/2,f=B(m,r,n,o),H=f*Math.cos(v),j=f*Math.sin(v);return{x:H,y:j}});l==="circle"?a.append("path").attr("d",W(u,c.curveTension)).attr("class",`radarCurve-${p}`):l==="polygon"&&a.append("polygon").attr("points",u.map(m=>`${m.x},${m.y}`).join(" ")).attr("class",`radarCurve-${p}`)})}i(G,"drawCurves");function B(a,t,e,r){let n=Math.min(Math.max(a,t),e);return r*(n-t)/(e-t)}i(B,"relativeRadius");function W(a,t){let e=a.length,r=`M${a[0].x},${a[0].y}`;for(let n=0;n<e;n++){let l=a[(n-1+e)%e],c=a[n],s=a[(n+1)%e],o=a[(n+2)%e],d={x:c.x+(s.x-l.x)*t,y:c.y+(s.y-l.y)*t},p={x:s.x-(o.x-c.x)*t,y:s.y-(o.y-c.y)*t};r+=` C${d.x},${d.y} ${p.x},${p.y} ${s.x},${s.y}`}return`${r} Z`}i(W,"closedRoundCurve");function V(a,t,e,r){if(!e)return;let n=(r.width/2+r.marginRight)*3/4,l=-(r.height/2+r.marginTop)*3/4,c=20;t.forEach((s,o)=>{let d=a.append("g").attr("transform",`translate(${n}, ${l+o*c})`);d.append("rect").attr("width",12).attr("height",12).attr("class",`radarLegendBox-${o}`),d.append("text").attr("x",16).attr("y",0).attr("class","radarLegendText").text(s.label)})}i(V,"drawLegend");var ot={draw:at},it=i((a,t)=>{let e="";for(let r=0;r<a.THEME_COLOR_LIMIT;r++){let n=a[`cScale${r}`];e+=`
		.radarCurve-${r} {
			color: ${n};
			fill: ${n};
			fill-opacity: ${t.curveOpacity};
			stroke: ${n};
			stroke-width: ${t.curveStrokeWidth};
		}
		.radarLegendBox-${r} {
			fill: ${n};
			fill-opacity: ${t.curveOpacity};
			stroke: ${n};
		}
		`}return e},"genIndexStyles"),lt=i(a=>{let t=A(),e=b(),r=y(t,e.themeVariables),n=y(r.radar,a);return{themeVariables:r,radarOptions:n}},"buildRadarStyleOptions"),ct=i(({radar:a}={})=>{let{themeVariables:t,radarOptions:e}=lt(a);return`
	.radarTitle {
		font-size: ${t.fontSize};
		color: ${t.titleColor};
		dominant-baseline: hanging;
		text-anchor: middle;
	}
	.radarAxisLine {
		stroke: ${e.axisColor};
		stroke-width: ${e.axisStrokeWidth};
	}
	.radarAxisLabel {
		font-size: ${e.axisLabelFontSize}px;
		color: ${e.axisColor};
	}
	.radarGraticule {
		fill: ${e.graticuleColor};
		fill-opacity: ${e.graticuleOpacity};
		stroke: ${e.graticuleColor};
		stroke-width: ${e.graticuleStrokeWidth};
	}
	.radarLegendText {
		text-anchor: start;
		font-size: ${e.legendFontSize}px;
		dominant-baseline: hanging;
	}
	${it(t,e)}
	`},"styles"),vt={parser:et,db:$,renderer:ot,styles:ct};export{vt as diagram};
