import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
import {checkGateTailSourceBinding} from './GateTailSourceBinding';
const here=new URL('./',import.meta.url);
function fragment(text:string,name:string):string {const matches=[...text.matchAll(new RegExp('^def '+name+' : String := ("[^"\\n]*")','gm'))];if(matches.length!==1)throw Error('Expected one row fragment '+name);return JSON.parse(matches[0]![1]!);}
export async function checkGateRowSourceBinding(options:{repositoryRoot?:string;leanSource?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.repositoryRoot?pathToFileURL(resolve(options.repositoryRoot)+'/'):new URL('../../../',here);
 await checkGateTailSourceBinding({repositoryRoot:root.pathname,selfTest:options.selfTest});
 const lean=await Bun.file(options.leanSource?resolve(options.leanSource):new URL('GateRowSyntax.lean',here)).text();
 const source=await Bun.file(new URL('packages/inference/src/kernels/trellis/gate-up-codebook.ts',root)).text();
 const launch=await Bun.file(new URL('packages/inference/src/kernels/trellis/launch.ts',root)).text();
 for(const fragment of ['export const TRELLIS_CODEBOOK_ROW_THREADS = 1024;','export const TRELLIS_CODEBOOK_ROW_SG_PER_TG = 32;'])if(!launch.includes(fragment))throw Error('Selected row launch constants changed');
 for(const fragment of ['const THREADGROUPS = 160;','grid: [TRELLIS_CODEBOOK_ROW_THREADS, Math.min(THREADGROUPS, Math.ceil(g.rows / TRELLIS_CODEBOOK_ROW_SG_PER_TG)), 1]',
  'threadGroup: [TRELLIS_CODEBOOK_ROW_THREADS, 1, 1]','ROWS_TG: TRELLIS_CODEBOOK_ROW_SG_PER_TG'])if(!source.includes(fragment))throw Error('Selected row launch expression changed');
 let previous=-1;for(const name of ['laneSource','constantSource','loopSource','writerSource']){const selected=fragment(lean,name);const at=source.indexOf(selected);if(source.split(selected).length!==2||at<=previous)throw Error('Parsed row source/order changed '+name);previous=at;if((name==='loopSource'||name==='writerSource')&&source.slice(at+selected.length).trimStart()[0]!=='{')throw Error('Row/writer body missing');}
 if(options.selfTest){for(const [name,from,to] of [
 ['laneSource','thread_index_in_simdgroup','thread_position_in_threadgroup.x'],['constantSource','threadgroups_per_grid.y','threadgroups_per_grid.x'],
 ['loopSource','thread_position_in_grid.y','thread_position_in_grid.x'],['loopSource','row += rowStep','row += 1u'],['loopSource','(uint)R','(uint)C'],['writerSource','0u','1u']]){
 const selected=fragment(lean,name!);const mutated=selected.replace(from!,to!);if(mutated===selected||source.includes(mutated))throw Error('Row mutation test ineffective '+name);
 }}
}
if(import.meta.main){await checkGateRowSourceBinding({selfTest:process.argv.includes('--self-test')});console.log('Parsed row distribution/lane writer and selected launch constants match pinned source.');}
