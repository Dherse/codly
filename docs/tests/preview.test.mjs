import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import { runInNewContext } from 'node:vm';
import { exampleSource, validateWidgets, widgetDefaults } from '../runtime/widgets.mjs';

const source = await fs.readFile('runtime/docs.mjs', 'utf8');
const widgetSchema = [{type:'switch',name:'enabled',label:'Enabled',default:'false'}];

class Element {
  constructor(dataset = {}) { this.dataset=dataset; this.listeners={}; this.children=[]; this.classList={toggle(){},add(){},remove(){}}; this.attributes={}; this.value=''; this.textContent=''; this.open=false; }
  addEventListener(type, fn) { this.listeners[type]=fn; }
  setAttribute(name,value) { this.attributes[name]=String(value); }
  removeAttribute(name) { delete this.attributes[name]; if (name === 'data-live') delete this.dataset.live; }
  remove() { this.removed=true; }
  append(child) { this.children.push(child); }
  replaceChildren(...children) { this.children=children; }
  querySelector(selector) { return this.parts?.[selector] ?? null; }
  querySelectorAll(selector) { return this.groups?.[selector] ?? []; }
  closest() { return this; }
  contains() { return true; }
}

function boot() {
  const workers=[];
  const timers=new Map();
  const highlights=[];
  let timerId=0;
  const makeCard = name => {
    const card=new Element({example:name,widgets:JSON.stringify(widgetSchema)});
    const textarea=new Element(); textarea.value=`#${name}`;
    const preview=new Element(), status=new Element(), details=new Element(), controls=new Element();
    const staticPreview=new Element(); staticPreview.src=`/assets/previews/${name}.svg`;
    const widgetInput=new Element({widget:'enabled'});
    const widgetControl=new Element(); widgetControl.querySelector=selector=>selector==='output'?new Element():null;
    widgetInput.closest=selector=>selector==='[data-widget]'?widgetInput:widgetControl;
    card.parts={textarea, '.preview':preview, '.example-status':status, details, '.example-controls':controls,
      '[data-reset-widgets]':new Element(), '[data-run]':new Element(), '[data-reset]':new Element(),
      '.highlighted':new Element(), '.live-preview':null};
    card.groups={'.static-preview':[staticPreview], '[data-widget]':[widgetInput]};
    preview.append=child=>{
      card.parts['.live-preview']=child;
      child.remove=()=>{ card.parts['.live-preview']=null; };
    };
    card.parts.details=details;
    return {card,textarea,status,details,controls,staticPreview};
  };
  const first=makeCard('first'), second=makeCard('second');
  const elements=new Map();
  for (const selector of ['#theme','#code-font','#preferences','#menu-toggle','#sidebar','#page-toc','#search','#search-results','#docs-version']) elements.set(selector,new Element());
  elements.get('#theme').setAttribute('aria-checked','false');
  elements.get('#code-font').value='noto';
  const document={body:{dataset:{root:'./'}},documentElement:{dataset:{theme:'light',font:'noto'}},
    querySelector:selector=>elements.get(selector) ?? new Element(),
    querySelectorAll:selector=>selector==='.example'?[first.card,second.card]:[],
    addEventListener(){}};
  const context={document,location:{href:'https://example.test/guide.html',pathname:'/guide.html'},URL,URLSearchParams,
    history:{replaceState(){}}, Worker:class { constructor(){workers.push(this);this.messages=[];} postMessage(message){this.messages.push(message);} terminate(){this.terminated=true;} },
    setTimeout(fn,delay){const id=++timerId;timers.set(id,{fn,delay});return id;},clearTimeout(id){timers.delete(id);},
    Image:class extends Element {},Blob,console,matchMedia:()=>({matches:false}),
    initializeVersionSelector(){},initializeSidebar(){return {revealCurrent(){}}},
    validateWidgets,widgetDefaults,exampleSource,
    loadHighlighter:async()=>({highlight:async body=>{highlights.push(body);return body;}})};
  const executable=source.replace(/^import .*;\n/gm,'').replace("import('./highlight.mjs')",'loadHighlighter()');
  runInNewContext(executable,context);
  const flushEdits=()=>{
    for (const [id,timer] of [...timers]) if (timer.delay===450) {timers.delete(id);timer.fn();}
  };
  return {first,second,workers,timers,elements,document,highlights,flushEdits};
}

test('reading and changing UI preferences keep the single static preview unchanged',()=>{
  const app=boot();
  const original=app.first.staticPreview.src;
  app.first.details.open=true;
  app.first.details.listeners.toggle?.({target:app.first.details});
  assert.equal(app.workers.length,0);
  app.elements.get('#theme').listeners.click();
  assert.equal(app.workers.length,0);
  app.elements.get('#code-font').listeners.change();
  assert.equal(app.workers.length,0);
  assert.equal(app.first.staticPreview.src,original);
});

test('editing starts compilation, while default Run and reset restore the static preview',()=>{
  const app=boot();
  const {card,textarea}=app.first;
  textarea.value += '\nchanged';
  textarea.listeners.input();
  app.flushEdits();
  assert.equal(app.workers.length,1);
  const worker=app.workers[0], message=worker.messages[0];
  assert.deepEqual(Object.keys(message).sort(),['id','source']);
  card.parts['[data-reset]'].listeners.click();
  assert.equal(app.first.staticPreview.src,'/assets/previews/first.svg');
  worker.onmessage({data:{id:message.id,svg:'<svg/>'}});
  assert.equal(card.dataset.live,undefined);

  const defaultApp=boot();
  defaultApp.first.card.parts['[data-run]'].listeners.click();
  assert.equal(defaultApp.workers.length,0);
});

test('changing a widget renders, and resetting a rendered example restores the image',async()=>{
  const app=boot();
  const input=app.first.card.groups['[data-widget]'][0];
  input.checked=true;
  app.first.controls.listeners.input({target:input});
  app.flushEdits();
  assert.equal(app.workers.length,1);
  const worker=app.workers[0], message=worker.messages[0];
  assert(message.source.startsWith('#let enabled = true\n'));
  worker.onmessage({data:{id:message.id,svg:'<svg/>'}});
  assert.equal(app.first.card.dataset.live,'true');
  app.first.card.parts['[data-reset-widgets]'].listeners.click();
  assert.equal(app.first.card.dataset.live,undefined);
  assert.equal(app.first.card.parts['.live-preview'],null);
  assert.equal(app.first.status.textContent,'Pre-rendered default');
  app.flushEdits();
  assert.equal(worker.messages.length,1);
  await Promise.resolve();
  assert.equal(app.highlights.length,0,'Changing controls should reuse the existing highlighted source');
});

test('preferences during active and rendered edits update the UI without recompiling',()=>{
  const app=boot();
  app.second.textarea.value += '\nchanged';
  app.second.textarea.listeners.input();
  app.flushEdits();
  assert.equal(app.workers.length,1);
  assert.equal(app.first.card.dataset.live,undefined);
  assert.equal(app.first.staticPreview.src,'/assets/previews/first.svg');
  const originalSrc=app.second.staticPreview.src;
  const worker=app.workers[0];
  app.elements.get('#theme').listeners.click();
  app.elements.get('#code-font').value='dejavu';
  app.elements.get('#code-font').listeners.change();
  assert.equal(app.document.documentElement.dataset.theme,'dark');
  assert.equal(app.document.documentElement.dataset.font,'dejavu');
  assert.equal(worker.messages.length,1,'Preference changes during compilation must not queue more work');
  assert.equal(app.second.staticPreview.src,originalSrc);
  worker.onmessage({data:{id:worker.messages[0].id,svg:'<svg/>'}});
  assert.equal(worker.messages.length,1);
  const liveSrc=app.second.card.parts['.live-preview'].src;
  app.elements.get('#code-font').value='noto';
  app.elements.get('#theme').listeners.click();
  app.elements.get('#code-font').listeners.change();
  assert.equal(app.document.documentElement.dataset.theme,'light');
  assert.equal(app.document.documentElement.dataset.font,'noto');
  assert.equal(worker.messages.length,1,'Preference changes after rendering must not recompile');
  assert.equal(app.second.card.parts['.live-preview'].src,liveSrc);
  assert.equal(app.second.staticPreview.src,originalSrc);
  assert.equal(app.second.card.dataset.live,'true');
  assert.equal(app.elements.get('#code-font').value,'noto','The UI preference control remains interactive');
});

test('resetting while compilation is pending ignores stale errors and cancels queued defaults',()=>{
  const app=boot();
  for (const example of [app.first,app.second]) {
    example.textarea.value+='\nchanged';
    example.textarea.listeners.input();
    app.flushEdits();
    example.card.parts['[data-reset]'].listeners.click();
  }
  const worker=app.workers[0];
  worker.onerror();
  assert.equal(app.first.status.textContent,'Pre-rendered default');
  assert.equal(app.second.status.textContent,'Pre-rendered default');
  assert.equal(worker.messages.length,1,'Reset should remove queued rendering work');
});
