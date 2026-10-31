// Split a capped typed run using native-chosen intermediate states and exact kernel checks.
import { readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";
const [dir, name, chunkText, fuelText, widthText = "3333"] = process.argv.slice(2);
if (!dir || !name || !/^\w+(?:\/\w+)*$/.test(dir) || !/^[\w.]+$/.test(name)) throw Error("usage: genTypedSplit.ts dir namespace chunk fuel [width]");
const chunk = Number(chunkText), fuel = Number(fuelText), width = Number(widthText);
if (![chunk,fuel,width].every(Number.isSafeInteger) || chunk < 0 || fuel < 1 || width < 1) throw Error("invalid run sizes");
const root = join(import.meta.dir,dir), mod = (x:string)=>`host.sim.template.${dir.replaceAll("/", ".")}.${x}`;
const pre = `${name}.typedSplitK${chunk}`, base = `TypedSplitK${chunk}`, ok = `${name}.bodyOkL`;
const count = Math.ceil(fuel/(width+1));
const sizes = Array.from({length:count},(_,i)=>i === count-1 ? fuel-width*i : width);
const src = (i:number)=>i===0 ? `${name}.s${chunk}` : `${pre}.p${i-1}.s1`;
const srv = (i:number)=>i===0 ? `${name}.S${chunk}` : `${pre}.originalS${i}`;
const head=(imports:string[])=>[...new Set(imports)].map(x=>`import ${x}\n`).join("")+"set_option Elab.async false\nset_option maxRecDepth 1000000\nset_option maxHeartbeats 0\nnamespace Host.Load.Run.Tpl\nopen Host.Ts Host.Ts.Sim\n\n";
const put=(f:string,t:string)=>writeFileSync(join(root,`${f}.lean`),t+"\nend Host.Load.Run.Tpl\n");
for(let i=0;i<sizes.length-1;i++) {
 const p=`${pre}.p${i}`, stem=`${base}States${i}`, data=`${base}Data${i}`;
 const plan={stop:`steps:${sizes[i]}`,cap:sizes[i]!+100,stuckStop:false,stages:[],compact:false,isolate:false,frames:[2665,2673467,2673472,2673473],wide:[[4910,".memo []"]],baseVals:[[9,125],[10,124]],vars:[[9,"L"],[10,"n"]],bridges:[],accept:"jsjxs",D0:131072,loadP:[18151,131072,1099511627776,15235,15235]};
 put(stem,head([i===0?mod(`H${Math.floor((chunk+1)/32)}`):mod(`${base}Data${i-1}`),"host.sim.template.ReturnLiteral"])+
  `bridge_empty ${p}.input from ${src(i)}\nserver_literal ${p}.inputSrv := (⟨${srv(i)}.tab, []⟩ : SSrv)\nset_option interpreter.prefer_native true in\n`+
  `tpl_chain ${p} from ${p}.input, ${p}.inputSrv : ${JSON.stringify(JSON.stringify(plan))} («world» := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.nativeWorld)\n`);
 const consumed = Array.from({length:i+1},(_,j)=>`${pre}.p${j}.O.length`).join(" + ");
 put(data,head([mod(stem)])+`host_stream_state ${p} 0\nhost_stream_state ${p} 1\n\n`+
  `noncomputable def ${pre}.originalS${i+1} : SSrv := ⟨${p}.S1.tab, ${name}.S${chunk}.oracle.drop (${consumed})⟩\n\n`);
}
for(let i=0;i<sizes.length;i++) {
 const last=i===sizes.length-1, dst=last?`${name}.s${chunk+1}`:`${pre}.p${i}.s1`, endSrv=last?`${name}.S${chunk+1}`:`${pre}.originalS${i+1}`;
 put(`${base}Part${i}`,head([mod(`${base}Data${Math.min(i,sizes.length-2)}`),mod("TypedOk"),"host.sim.template.BootAllEq","host.sim.Chunk"])+
  `boot_all_rfl ${pre}.part${i} from ${src(i)} to ${dst} :\n`+
  `  (fun (bytes : List Byte) (rows : Nat) => runOk ${name}.F (${ok} bytes rows) ${sizes[i]} ${src(i)} ${srv(i)}) =\n`+
  `    fun _ _ => some (${dst}, ${endSrv})\n`);
}
let sum=sizes[0]!,proof=`(congrFun (congrFun ${pre}.part0 bytes) rows)`;
for(let i=1;i<sizes.length;i++) {
 const dst=i===sizes.length-1?`${name}.s${chunk+1}`:`${pre}.p${i}.s1`, ds=i===sizes.length-1?`${name}.S${chunk+1}`:`${pre}.originalS${i+1}`;
 proof=`runOk_trans ${name}.F (${ok} bytes rows) ${sum} ${sizes[i]} ${src(0)} ${src(i)} ${dst} ${srv(0)} ${srv(i)} ${ds} (${proof}) (congrFun (congrFun ${pre}.part${i} bytes) rows)`;
 sum+=sizes[i]!;
}
put(`TypedK${chunk}`,head(sizes.map((_,i)=>mod(`${base}Part${i}`)))+
 `theorem ${name}.bodyK${chunk} :\n  (fun (bytes : List Byte) (rows : Nat) => runOk ${name}.F (${ok} bytes rows)\n    ((nth? ${name}.ks ${chunk}).getD 0) ${src(0)} ${srv(0)}) = fun _ _ => some (${name}.s${chunk+1}, ${name}.S${chunk+1}) := by\n`+
 `  funext bytes rows\n  change runOk ${name}.F (${ok} bytes rows) ${fuel} ${src(0)} ${srv(0)} = _\n  exact ${proof}\n`);
console.log(`${dir}: split ${fuel} into ${sizes.join("+")}; ${sizes.length-1} native intermediate cuts`);
