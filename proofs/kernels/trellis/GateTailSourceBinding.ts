import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
import {checkGateProjectionSourceBinding} from './GateProjectionSourceBinding';
const here=new URL('./',import.meta.url);
function fragment(text:string):string {
 const matches=[...text.matchAll(/^def source : String := ("[^"\n]*")/gm)];
 if(matches.length!==1)throw Error('Expected one gate tail source fragment');return JSON.parse(matches[0]![1]!);
}
export async function checkGateTailSourceBinding(options:{repositoryRoot?:string;leanSource?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.repositoryRoot?pathToFileURL(resolve(options.repositoryRoot)+'/'):new URL('../../../',here);
 await checkGateProjectionSourceBinding({repositoryRoot:root.pathname,selfTest:options.selfTest});
 const lean=await Bun.file(options.leanSource?resolve(options.leanSource):new URL('GateTailSyntax.lean',here)).text();
 const source=await Bun.file(new URL('packages/inference/src/kernels/trellis/gate-up-codebook.ts',root)).text();
 const selected=fragment(lean);const at=source.indexOf(selected);if(source.split(selected).length!==2)throw Error('Gate tail source changed');
 const writer='if (lane == 0u) {';const before=source.slice(0,at).trimEnd();if(!before.endsWith(writer))throw Error('Gate tail writer guard moved');
 if(options.selfTest){for(const [from,to] of [
  ['T(gate)','T(up)'],['(TAIL) == 1','(TAIL) == 0'],['metal::abs(gateT)','metal::abs(upT)'],
  ['(gateT < 0)','(gateT < 1)'],['sigY : 1 - sigY','sigY : 1 + sigY'],
  ['-float(gateT)','float(gateT)'],['T(float(gateT) * float(sigmoidT))','T(gateT * sigmoidT)'],
  ['T(float(siluT) * float(upT))','T(float(upT) * float(siluT))'],['mid[row]','mid[row + 1u]']]){
   const mutated=selected.replace(from!,to!);if(mutated===selected||source.includes(mutated))throw Error('Gate tail negative test ineffective');
  }
 }
}
if(import.meta.main){await checkGateTailSourceBinding({selfTest:process.argv.includes('--self-test')});console.log('Parsed BF16 casts, TAIL branches, native/precise exp calls and output expressions match pinned source.');}
