import fs from 'node:fs';
import { spawn, spawnSync } from 'node:child_process';
const build = () => { const r = spawnSync(process.execPath,['scripts/build.mjs'],{stdio:'inherit'}); return r.status === 0; };
if (!build()) process.exit(1);
const server = spawn('python3',['-m','http.server','8001','--bind','127.0.0.1','--directory','book'],{stdio:'inherit'});
let timer;
function watch(dir) { for (const f of fs.readdirSync(dir,{withFileTypes:true})) if(f.isDirectory() && f.name !== 'assets') watch(`${dir}/${f.name}`); fs.watch(dir,(event,name) => { if (!name || name==='assets') return; clearTimeout(timer); timer=setTimeout(()=>{ console.log('Source changed. Rebuilding…'); build(); },300); }); }
for(const dir of ['src','theme','runtime','typst','../src']) watch(dir);
fs.watch('..', (event, name) => {
  if (!['codly.typ', 'typst.toml'].includes(name)) return;
  clearTimeout(timer);
  timer = setTimeout(build, 300);
});
console.log('Docs: http://127.0.0.1:8001 — refresh after a rebuild. Ctrl+C stops.');
process.on('SIGINT',()=>{server.kill();process.exit();});
