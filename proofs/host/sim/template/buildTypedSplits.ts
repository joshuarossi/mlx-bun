// Generate and immediately check one capped typed stage at a time.
import { readFileSync, writeFileSync, readdirSync } from "node:fs";
import { join } from "node:path";
const [out, ...indices] = process.argv.slice(2);
if (!out || !indices.length || indices.some(i=>!/^\d+$/.test(i))) throw Error("usage: buildTypedSplits.ts output-dir stage-index...");
if (!process.env.HOST_STREAM_DIR || !process.env.LEAN_DYNLIB) throw Error("HOST_STREAM_DIR and LEAN_DYNLIB are required");
const proofRoot = join(import.meta.dir,"../../.."), registry=join(proofRoot,"check.ts");
for (const index of indices) {
 const dir=`a4pre_first_tail_x15_r0_body/st${index}`, name=`PRE_first_tail_x15_r0_body.st${index}`;
 console.log(`split stage ${index}: generate`);
 const gen=Bun.spawn(["bun",join(import.meta.dir,"genTypedSplit.ts"),dir,name,"0","10000"],{stdout:"inherit",stderr:"inherit"});
 if(await gen.exited) process.exit(1);
 const files=readdirSync(join(import.meta.dir,dir)).filter(f=>/^TypedSplitK0.*\.lean$/.test(f)).map(f=>`host/sim/template/${dir}/${f}`);
 let source=readFileSync(registry,"utf8");
 const added=files.filter(f=>!source.includes(JSON.stringify(f)));
 const at=source.indexOf("\n];\n\nconst discoveredProofs");
 if(at<0)throw Error("proof registry end not found");
 source=source.slice(0,at)+added.map(f=>`\n  ${JSON.stringify(f)},`).join("")+source.slice(at);
 writeFileSync(registry,source);
 const build=Bun.spawn(["bun",join(import.meta.dir,"timeBuild.ts"),"--out",out,"--keep-going","--jobs","1",`host/sim/template/${dir}/TypedTpl.lean`],{stdout:"inherit",stderr:"inherit",env:process.env});
 const code=await build.exited;
 if(code) {console.error(`split stage ${index}: stopped at first failed closure`);process.exit(code);}
 console.log(`split stage ${index}: checked`);
}
