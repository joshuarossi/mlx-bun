import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
import {checkGateRowSourceBinding} from './GateRowSourceBinding';
const here=new URL('./',import.meta.url);
function fragment(text:string,name:string):string {const matches=[...text.matchAll(new RegExp('^def '+name+' : String := ("[^"\\n]*")','gm'))];if(matches.length!==1)throw Error('Expected one gate pointer fragment '+name);return JSON.parse(matches[0]![1]!);}
export async function checkGatePointerSourceBinding(options:{repositoryRoot?:string;leanSource?:string;selfTest?:boolean}={}):Promise<void>{
 const root=options.repositoryRoot?pathToFileURL(resolve(options.repositoryRoot)+'/'):new URL('../../../',here);
 await checkGateRowSourceBinding({repositoryRoot:root.pathname,selfTest:options.selfTest});
 const lean=await Bun.file(options.leanSource?resolve(options.leanSource):new URL('GatePointerSyntax.lean',here)).text();
 const source=await Bun.file(new URL('packages/inference/src/kernels/trellis/gate-up-codebook.ts',root)).text();
 let previous=-1;for(const name of ['gateBlockSource','upBlockSource','runsSource','gateRowSource','upRowSource','blockSource','offsetSource','basesSource','gateFirstSource','upFirstSource']){
  const selected=fragment(lean,name);const at=source.indexOf(selected);if(source.split(selected).length!==2||at<=previous)throw Error('Gate pointer source/order changed '+name);previous=at;
 }
 const run=source.indexOf('for (uint run = lane; run < N_RUNS; run += 32u) {');
 if(!(source.indexOf(fragment(lean,'upRowSource'))<run&&run<source.indexOf(fragment(lean,'blockSource'))&&previous<source.indexOf('uint g[KG + 1], gv[KG + 1];')))throw Error('Gate pointer setup phase changed');
 if(options.selfTest){for(const [name,from,to] of [
 ['gateBlockSource','BT * KG / 32','BT * KU / 32'],['upBlockSource','/ 32','/ 16'],['runsSource','(uint)BT','(uint)C'],
 ['gateRowSource','C / BT','BT / C'],['blockSource','run / runsPerBlock','run % runsPerBlock'],
 ['offsetSource','run - blk * runsPerBlock','blk * runsPerBlock - run'],
 ['basesSource','gRow + blk * gWpb','uRow + blk * gWpb'],['basesSource','uw = uRow','uw = gRow'],
 ['gateFirstSource','- 32u - t0','- t0 - 32u'],['upFirstSource','/ 32u','/ 16u']]){
  const selected=fragment(lean,name!);const mutated=selected.replace(from!,to!);if(selected===mutated||source.includes(mutated))throw Error('Gate pointer mutation ineffective '+name);
 }}
}
if(import.meta.main){await checkGatePointerSourceBinding({selfTest:process.argv.includes('--self-test')});console.log('Parsed gate/up block, row, run and first-word pointer setup matches pinned source.');}
