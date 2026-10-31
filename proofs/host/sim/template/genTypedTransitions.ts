// Recheck acceptance-independent bridge steps without importing the old run proofs.
import { readFileSync, writeFileSync, readdirSync } from "node:fs";
import { join } from "node:path";
const [dir,name,widthArg="8"]=process.argv.slice(2), width=Number(widthArg);
if(!dir||!name||!/^\w+(?:\/\w+)*$/.test(dir)||!/^[\w.]+$/.test(name)||!Number.isSafeInteger(width)||width<1)throw Error("usage: genTypedTransitions.ts dir namespace [checks-per-module]");
const root=join(import.meta.dir,dir),mod=(s:string)=>`host.sim.template.${dir.replaceAll("/", ".")}.${s}`;
const steps=new Map<string,{line:string,a:number,b:number}>();
for(const f of readdirSync(root).filter(f=>/^K\d+(?:_\d+)?\.lean$/.test(f)))for(const line of readFileSync(join(root,f),"utf8").split("\n")) {
 const m=/^boot_rfl (\S+) from (\S+)\.s(\d+) to (\S+)\.s(\d+) :/.exec(line);
 if(!m||m[2]!==name||m[4]!==name)continue;
 const suffix=m[1]!.slice(name.length+1);
 if(!/^(stepA|stepB|patchB)\d*$/.test(suffix))continue;
 steps.set(suffix,{line:line.replace(`${name}.${suffix} `,`${name}.body${suffix[0]!.toUpperCase()+suffix.slice(1)} `),a:Number(m[3]),b:Number(m[5])});
}
const all=[...steps.values()].sort((x,y)=>x.a-y.a), count=Math.ceil(all.length/width);
for(let j=0;j<count;j++) {
 const group=all.slice(j*width,(j+1)*width);
 const imports=[...new Set([...group.flatMap(x=>[mod(`H${Math.floor(x.a/32)}`),mod(`H${Math.floor(x.b/32)}`)]),"host.sim.template.BootEq","host.sim.template.Bridges","host.sim.Chunk"])];
 writeFileSync(join(root,`TypedSteps${j}.lean`),imports.map(x=>`import ${x}\n`).join("")+"set_option Elab.async false\nset_option maxRecDepth 1000000\nset_option maxHeartbeats 0\nnamespace Host.Load.Run.Tpl\nopen Host.Ts Host.Ts.Sim\n"+group.map(x=>x.line).join("\n")+"\nend Host.Load.Run.Tpl\n");
}
writeFileSync(join(root,"TypedBridges.lean"),Array.from({length:count},(_,i)=>`import ${mod(`TypedSteps${i}`)}\n`).join(""));
console.log(`${dir}: ${all.length} pure bridge checks in ${count} modules`);
