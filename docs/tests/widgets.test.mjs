import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import { spawnSync } from 'node:child_process';
import { validateWidgets, widgetDefaults, exampleSource } from '../runtime/widgets.mjs';
import { parseWidgets, renderWidgets } from '../scripts/widgets.mjs';
import { stringify } from 'yaml';

const controls = () => [
  {type:'slider',name:'radius',label:'Radius',min:0,max:12,step:0.5,unit:'pt',default:'6pt'},
  {type:'slider',name:'fade',label:'Fade',min:0,max:100,unit:'%',default:'25%'},
  {type:'switch',name:'numbered',label:'Line numbers',default:'true'},
  {type:'select',name:'fill',label:'Fill',default:'none',options:[{label:'None',value:'none'},{label:'Color',value:'rgb("abcdef")'}]},
];

test('controls preserve Typst expressions and independent example values', () => {
  const widgets=validateWidgets(controls());
  const left=widgetDefaults(widgets), right=widgetDefaults(widgets);
  left.radius='2.5pt';left.numbered='false';left.fill='rgb("abcdef")';
  const source=exampleSource('#fill',widgets,left);
  assert.match(source,/#let radius = 2\.5pt\n/);
  assert.match(source,/#let fade = 25%\n/);
  assert.match(source,/#let numbered = false\n/);
  assert.match(source,/#let fill = rgb\("abcdef"\)\n/);
  assert.equal(right.radius,'6pt');
  assert.equal(exampleSource('plain'), 'plain');
});

test('invalid schemas and values fail before rendering controls', () => {
  for (const change of [
    w=>{w[0].name='let'}, w=>{w[0].name='x)\n#panic("bad")'}, w=>{w[1].name='radius'},
    w=>{w[0].step=0}, w=>{w[0].min=12}, w=>{w[0].default='13pt'},
    w=>{w[0].default='1.2pt'}, w=>{w[0].unit='px'}, w=>{w[0].default='6%'},
    w=>{w[2].default=true}, w=>{w[2].default='none'}, w=>{w[3].default='red'},
    w=>{w[3].options=[]}, w=>{w[3].options.push(w[3].options[0])}, w=>{w[0].type='unknown'},
  ]) {
    const widgets=controls();change(widgets);
    assert.throws(()=>validateWidgets(widgets), /Widgets:/);
  }
  const widgets=validateWidgets(controls());
  for (const values of [{radius:'9.2pt'},{radius:'Infinitypt'},{numbered:'"true"'},{fill:'red'}]) {
    assert.throws(()=>exampleSource('body',widgets,{...widgetDefaults(widgets),...values}), /Widgets:/);
  }
});

test('unitless, negative, and decimal slider values retain their numeric meaning', () => {
  const widgets=validateWidgets([{type:'slider',name:'offset',label:'Offset',min:-1,max:1,step:0.1,default:'-0.3'}]);
  assert.match(exampleSource('#offset',widgets), /#let offset = -0\.3/);
  assert.match(exampleSource('#offset',widgets,{offset:'0.3'}), /#let offset = 0\.3/);
});

test('widget labels and expression values are escaped in HTML', () => {
  const hostile='"</option><script>alert(1)</script>"';
  const widgets=validateWidgets([{type:'select',name:'label',label:'<img onerror="bad">',default:hostile,options:[{label:'<b>Pick</b>',value:hostile}]}]);
  const html=renderWidgets(widgets,'example');
  assert(!html.includes('<script>') && !html.includes('<img') && !html.includes('<b>'));
  assert(html.includes('&lt;script&gt;'));
  assert(html.includes('disabled'));
});

test('widget fences bind only the adjacent preview, preserve nested code, and reject orphan configs', async () => {
  const temp=await fs.mkdtemp('/tmp/codly-widgets-');
  const body='#radius\n```rust\nlet answer = 42;\n```';
  const config='```yaml widgets\n'+stringify(controls())+'```\n\n';
  const preview='````typst preview\n'+body+'\n````\n';
  const run=content=>spawnSync(process.execPath,['scripts/preprocessor.mjs'],{
    input:JSON.stringify([{root:temp},{items:[{Chapter:{name:'Widgets',path:'widgets.md',content,sub_items:[]}}]}]),encoding:'utf8',timeout:30000,
  });
  try {
    const result=run(config+preview+'\n'+preview);
    assert.equal(result.status,0,result.stderr);
    const examples=JSON.parse(await fs.readFile(temp+'/src/assets/examples.json','utf8'));
    assert.equal(examples.length,2);
    const configured=examples.find(example=>example.widgets.length);
    const plain=examples.find(example=>!example.widgets.length);
    assert.equal(configured.source,exampleSource(body,validateWidgets(controls())));
    assert.equal(plain.source,body);
    assert.notEqual(configured.id,plain.id);
    const html=JSON.parse(result.stdout).items[0].Chapter.content;
    assert.equal((html.match(/class="example-controls"/g)||[]).length,1);
    assert(html.includes('```rust'));
    const invalid=run(config+'Not adjacent.\n\n'+preview);
    assert.notEqual(invalid.status,0);
    assert.match(invalid.stderr,/widgets.md:.*immediately precede/);
  } finally { await fs.rm(temp,{recursive:true,force:true}); }
});

test('YAML preserves Typst scalars, quoted strings, comments, and multiline expressions', () => {
  const widgets=parseWidgets(`
- type: slider
  name: amount
  label: Amount
  min: 0
  max: 1
  step: 0.1
  default: 0.3
- type: switch
  name: enabled
  label: Enabled
  default: true # This is Typst code, not a JavaScript boolean.
- type: select
  name: value
  label: Value
  default: none
  options:
    - label: Nothing
      value: none
    - label: String
      value: '"hello"'
    - label: Compound
      value: |-
        (length: 6pt,
         fill: rgb("abcdef"))
`);
  assert.equal(widgets[0].default,'0.3');
  assert.equal(widgets[0].step,0.1);
  assert.equal(widgets[1].default,'true');
  assert.equal(widgets[2].options[1].value,'"hello"');
  assert.equal(widgets[2].options[2].value,'(length: 6pt,\n fill: rgb("abcdef"))');
  assert.throws(()=>parseWidgets('- type: switch\n  type: slider'),/unique/i);
  assert.throws(()=>parseWidgets('- type: switch\n  default: [true, false]'),/Widgets:/);
  assert.throws(()=>parseWidgets('- type: ['));
});
