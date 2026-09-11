import { expect, test } from "bun:test";

const enabled = Bun.env.MLX_BUN_TEST_DRAFT_WRAP === "1";
test.skipIf(!enabled)("shared drafting crosses the real target window and preserves late joins", async () => {
  const { Weights } = await import("../../src/weights");
  const { loadModelConfig } = await import("../../src/config");
  const { createModel } = await import("../../src/model/factory");
  const { AssistantProvider } = await import("../../src/spec/assistant-source");
  const { DeepspecProvider } = await import("../../src/spec/deepspec-source");
  const { specServeRun } = await import("../../src/spec/serve-loop");
  const { MlxBatchExecutionGroup } = await import("../../src/backends/mlx/batch-group");
  const { bindSpeculativeGroupRequests } = await import("../../src/backends/mlx/speculative-group");
  const target=Bun.env.MLX_BUN_TEST_MTP_TARGET!, draft=Bun.env.MLX_BUN_TEST_MTP_DRAFT!;
  using resources=new DisposableStack();
  const weights=await Weights.open(target); resources.defer(()=>weights.dispose());
  const model=createModel(weights,await loadModelConfig(target));
  const provider=Bun.env.MLX_BUN_TEST_GROUP_DEEPSPEC === "1" ? await DeepspecProvider.load(draft) : await AssistantProvider.load(draft);
  resources.defer(()=>provider.dispose());
  const depth=Number(Bun.env.MLX_BUN_TEST_MTP_DEPTH ?? 3);
  const window=model.config.text.slidingWindow!;
  expect(window).toBeGreaterThan(0);
  const prompt=Array.from({length:window-2},(_,i)=>1+i%89);
  const bits=Number(Bun.env.MLX_BUN_TEST_MTP_KV_BITS ?? 0);
  const turboQuant=Bun.env.MLX_BUN_TEST_MTP_TURBO === "1" ? {kBits:8,vBits:3} : undefined;
  const options={temperature:0,maxTokens:16,eosTokenIds:[], ...(turboQuant ? {turboQuant,quantizedKvStart:0} : bits ? {kvBits:bits,kvGroupSize:64,quantizedKvStart:0}: {})};
  const reference:number[]=[];
  const referenceStats=await specServeRun(model,provider,depth,prompt,options,token=>{reference.push(token);});
  const bind=bindSpeculativeGroupRequests(model,provider,depth);
  const run=async(join:boolean) => {
    const group=new MlxBatchExecutionGroup(model,{maxBatch:4});
    const outputs:number[][]=join ? [[],[]] : [[]]; let second:Promise<unknown>|undefined,maxRows=0;
    try {
      const stats = await group.submit({method:bind(options),promptIds:prompt,maxTokens:16,eosTokenIds:[],onToken(token){
        outputs[0]!.push(token);maxRows=Math.max(maxRows,group.activeRows);
        if(join&&outputs[0]!.length===2)second=group.submit({method:bind(options),promptIds:[...prompt,90,91,92,93,94],maxTokens:11,eosTokenIds:[],onToken(token){
          outputs[1]!.push(token);maxRows=Math.max(maxRows,group.activeRows);
        }});
      }});
      await second;
      expect(stats.spec!.rounds).toBeGreaterThan(0);
      expect(stats.spec!.drafted).toBeGreaterThan(0);
      expect(outputs.map(row=>row.length)).toEqual(join?[16,11]:[16]);
      expect(maxRows).toBe(join?2:1);
      expect(group.activeRows+group.pendingRows).toBe(0);
      return outputs;
    } finally {await group.close();}
  };
  const solo=(await run(false))[0]!;
  if ((bits || turboQuant) && referenceStats.spec!.drafted === 0) {
    // The old executor disables speculation at this boundary. Quantized KV
    // forward numerics depend on verification width, so this is a different
    // graph, not an exact numerical oracle. Same-width target controls and
    // transaction checks cover identity; this gate covers live continuation.
    console.error(JSON.stringify({bits,turboQuant,depth,serialDrafted:referenceStats.spec!.drafted,
      serialTokens:reference,sharedTokens:solo,serialMatches:JSON.stringify(solo)===JSON.stringify(reference)}));
    expect((await run(false))[0]).toEqual(solo);
  } else expect(solo).toEqual(reference);
  expect(await run(true)).toEqual(await run(true));
},240000);
