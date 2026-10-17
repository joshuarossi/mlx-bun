import {createHash} from 'node:crypto';
import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
const here=new URL('./',import.meta.url);
const entries=[
 ['layers/compiled-normalization.ts','4a649678daf44c73e8528b519a57bace1a735178e29710711a5067c5e5e7d9cc',[
  'export class CompiledGatedRMSNorm',
  'operation = new CompiledFunction(inputs => [gatedRmsNorm(inputs[0]!, inputs[1]!, inputs[2]!, eps)], false);',
  'return this.#operation.apply([x, gate, this.weight])[0]!;',
 ]],
 ['layers/delta-heads.ts','3d44375dd8bf8be8ea6ebf9772a4c3f1321fa22f567e9e9c7e7da11301a87a6d',[
  'export class CompiledSiluRMSHeads',
  'operation = new CompiledFunction(inputs => siluRmsHeads(inputs[0]!, inputs[1]!, inputs[2]!, keyHeads, valueHeads, valueWidth), false);',
  'return this.#operation.apply([x, qScale, kScale]) as [MlxArray, MlxArray, MlxArray];',
 ]],
 ['models/qwen/blocks.ts','2fa644511dbafc027cf4f191be69e932abda7d8c6a92ebe45f7d76332324645f',[
  'const out = recurFor[phase](cache, qkv, a, b, this.recurrence);',
  'const gated = this.rmsNormGated(out, z);',
  'const merged = ops.reshape(gated, [B, S, this.valueDim]);',
  'const result = this.outProj.forward(merged, rowsApart);',
  'export class QwenFusedGatedDeltaNet',
  'this.#gatedNorm = new CompiledGatedRMSNorm(this.normWeight, this.eps);',
  'return this.#gatedNorm.forward(hidden, gate);',
  'export class QwenFusedHeadsDeltaNet',
  'this.#headOperation = new CompiledSiluRMSHeads(this.numKHeads, this.numVHeads, this.headVDim);',
  'const [q, k, v] = this.#headOperation.forward(convolved, this.qkScale.q, this.qkScale.k);',
 ]],
] as const;
const norm=(text:string)=>text.replace(/\/\*[\s\S]*?\*\//g,'').replace(/\/\/[^\n]*/g,'').replace(/\s+/g,'');
function ordered(source:string,stages:readonly string[]):void{
 const text=norm(source);let cursor=0;
 for(const stage of stages){const needle=norm(stage),at=text.indexOf(needle,cursor);
  if(at<0)throw Error('Delta fused caller stage changed');cursor=at+needle.length;}
}
function reject(action:()=>void):void{let rejected=false;try{action();}catch{rejected=true;}if(!rejected)throw Error('Delta caller mutation escaped');}
// Reviewed caller/argument binding. Compilation and native array attachment
// are not established by finding these production statements.
export async function checkDeltaFusedCallerSourceBinding(options:{repositoryRoot?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.repositoryRoot?pathToFileURL(resolve(options.repositoryRoot)+'/'):new URL('../../../',here);
 for(const [path,pin,stages] of entries){
  const source=await Bun.file(new URL('packages/inference/src/'+path,root)).text();
  if(createHash('sha256').update(source).digest('hex')!==pin)throw Error('Delta fused caller source changed '+path);
  ordered(source,stages);
  if(options.selfTest){
   for(const stage of stages){if(!source.includes(stage))throw Error('Ineffective caller mutation');reject(()=>ordered(source.replace(stage,''),stages));}
   const first=stages[0],last=stages.at(-1)!;
   reject(()=>ordered(source.replace(first,'__SWAP_STAGE__').replace(last,first).replace('__SWAP_STAGE__',last),stages));
  }
 }
}
if(import.meta.main){await checkDeltaFusedCallerSourceBinding({selfTest:process.argv.includes('--self-test')});console.log('Reviewed fused Delta caller order and arguments match pinned source.');}
