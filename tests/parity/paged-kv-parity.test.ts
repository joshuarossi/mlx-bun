// Paged KV cache end-to-end parity (slow tier, weights-gated).
//
// The v1 claim is BIT-EXACT equivalence with the plain KVCache path — the
// paged cache stores the same bytes in a different physical arrangement
// and the gather reconstructs exactly the contiguous tensor the plain
// fetch would have produced, so unlike quantized-KV parity there is no
// knife-edge tolerance here: tol 0, full-trajectory agreement (a partial
// match would signal a real bug, per docs/design/kv-cache.md).
// mlx-lm is not the oracle (it has no paged cache); mlx-bun's own plain
// path is. Storage-layout unit parity (per-step fetch bytes, block
// boundaries, trim) runs model-free in tests/paged-kv.test.ts.

import { describe, expect, test } from "bun:test";
import { SNAPSHOT, snapshotAvailable } from "../support/paths";

const haveWeights = await snapshotAvailable();

describe.skipIf(!haveWeights)("paged KV parity (12B)", async () => {
  if (!haveWeights) return;

  const { loadModelConfig } = await import("../../src/config");
  const { Weights } = await import("../../src/weights");
  const { Gemma4Model, KVCache, lastPositionLogits } = await import("../../src/model/gemma4");
  const { PagedKVCache } = await import("../../src/lab/paged-kv/paged-kv");
  const { generate, maybePageKv } = await import("../../src/generate");

  const config = await loadModelConfig(SNAPSHOT);
  const weights = await Weights.open(SNAPSHOT);
  const model = new Gemma4Model(weights, config);

  // A prompt long enough to cross block boundaries at blockSize 16 (the
  // small block forces multi-block writes in prefill AND a >1-block gather
  // on every decode step — the interesting paged codepaths).
  const promptIds = [2, 106, 1645, 107, 3689, 603, 573, 6996, 576, 1461,
    235336, 107, 106, 2516, 107, 651, 6996, 576, 1461, 603];
  const BLOCK = 16;

  test("paged B1/B3 execution preserves every sampled logit vector and isolates cache policy", async () => {
    const { MlxBatchExecutionGroup } = await import("../../src/backends/mlx/batch-group");
    const { bindPagedRequestState } = await import("../../src/backends/mlx/request-state-policy");
    const { PromptCache } = await import("../../src/prompt-cache");
    const { spyOn } = await import("bun:test");
    const ops = await import("../../src/mlx/ops");
    for (const blockSize of [16,256]) for (const batch of [1,3]) {
      const run = async (paged: boolean) => {
        const cache = new PromptCache(1024 * 1024);
        const take = spyOn(cache,"take"), put = spyOn(cache,"put");
        let held=true;
        const group = new MlxBatchExecutionGroup(model,{maxBatch:3,promptCache:cache,admissionHeld:()=>held});
        const tokens: number[][] = Array.from({length:batch},()=>[]);
        const hashes: string[][] = Array.from({length:batch},()=>[]);
        try {
          const pending = tokens.map((out,row) => {
            const prompt = [...promptIds,...Array((blockSize === 256 ? 280 : 0)+row*3).fill(603)];
            return group.submit({promptIds:prompt,maxTokens:12,eosTokenIds:[],compiledDecode:false,
              // Match numerical prefill geometry: cache snapshots introduce extra
              // query boundaries even when request membership is identical.
              snapshotAt:0,
              statePolicy:paged?bindPagedRequestState(model,{pagedKv:{blockSize}},prompt.length+12):undefined,
              sample(logits) {
                using exact=ops.contiguous(logits);
                hashes[row]!.push(new Bun.CryptoHasher("sha256").update(exact.rawBytes()).digest("hex"));
                return ops.argmaxAxis(logits,-1);
              },onToken(token){out.push(token);}});
          });
          held=false;group.kick();
          const stats=await Promise.all(pending);
          expect(stats.map(s=>s.generatedTokens)).toEqual(Array(batch).fill(12));
          if(paged) {expect(take).not.toHaveBeenCalled();expect(put).not.toHaveBeenCalled();}
          // Switching from a custom state policy must restore the default
          // cache interface after that cohort has retired.
          await group.submit({promptIds,maxTokens:1,eosTokenIds:[],compiledDecode:false,
            sample:logits=>ops.argmaxAxis(logits,-1),onToken(){}});
          expect(take).toHaveBeenCalled();
          return {tokens,hashes};
        } finally {await group.close();take.mockRestore();put.mockRestore();cache.clear();}
      };
      expect(await run(true)).toEqual(await run(false));
    }
  },240_000);

  test("paged HTTP batching composes seeded sampling, logprobs and grammar", async () => {
    const { createServer, shutdownServer } = await import("../../src/server");
    const { loadTokenizer } = await import("../../src/tokenizer");
    const { ChatTemplate } = await import("../../src/chat-template");
    const { AdapterManager } = await import("../../src/lora");
    const { resolveModelProfile } = await import("../../src/model/profile");
    const { GenerationGateway } = await import("../../src/serve/generation-gateway");
    const { spyOn } = await import("bun:test");
    const context = { model, tokenizer: await loadTokenizer(SNAPSHOT), template: await ChatTemplate.load(SNAPSHOT),
      profile: resolveModelProfile(model.config), modelId:"paged-test",adapters:new AdapterManager(model),
      kvConfig:null,genDefaults:{},vision:null,loadVision:null,
      visionTokenIds:{imageTokenId:0,boiTokenId:0,eoiTokenId:0},audio:null,loadAudio:null,audioTokenIds:null };
    const run = async (paged: boolean) => {
      const server=createServer(context,0,{batch:4,promptCacheBytes:1024*1024,kvQuant:"off",
        hostname:"127.0.0.1",defaultThinking:false,...(paged?{pagedKv:{blockSize:BLOCK}}:{})});
      const base=`http://127.0.0.1:${server.port}`;
      let count=0,maxRows=0;let release!:()=>void;
      const ready=new Promise<void>(resolve=>{release=resolve;});const timer=setTimeout(release,5000);
      const forward=model.forwardHidden.bind(model);
      const graph=spyOn(model,"forwardHidden").mockImplementation((ids,caches)=>{
        if(!paged||caches.some(c=>c.signature().startsWith("kv:paged"))) maxRows=Math.max(maxRows,ids.shape[0]!);
        return forward(ids,caches);
      });
      const original=GenerationGateway.prototype.run;
      const arrival=spyOn(GenerationGateway.prototype,"run").mockImplementation(async function(this:InstanceType<typeof GenerationGateway>,...args){
        if(++count===4)release();await ready;return original.apply(this,args);
      });
      try {
        const responses=await Promise.all(Array.from({length:4},async(_,row)=>{
          const grammar=row%2===1;
          const response=await fetch(`${base}/v1/${grammar?"chat/":""}completions`,{method:"POST",
            headers:{"content-type":"application/json"},body:JSON.stringify({temperature:0.7,seed:734,
              max_tokens:24,logprobs:true,top_logprobs:3,
              ...(grammar?{messages:[{role:"user",content:"Return an object with color red."}],
                response_format:{type:"json_schema",json_schema:{name:"color",any_whitespace:false,
                  schema:{type:"object",properties:{color:{type:"string",enum:["red","blue"]}},required:["color"],additionalProperties:false}}}}
                :{prompt:"Count upwards: 1, 2, 3,"})})});
          const body=await response.json() as any;
          expect(response.status,JSON.stringify(body)).toBe(200);
          expect(body.usage.lane).toBe("batched");
          expect(body.usage.completion_tokens).toBeGreaterThan(0);
          const info=body.choices[0].logprobs.content;
          expect(info.length).toBeGreaterThan(0);
          for(const token of info){expect(Number.isFinite(token.logprob)).toBe(true);expect(token.top_logprobs).toHaveLength(3);}
          if(grammar) expect(["red","blue"]).toContain(JSON.parse(body.choices[0].message.content).color);
          return body.choices;
        }));
        expect(maxRows).toBe(4);
        const stats=await(await fetch(`${base}/stats`)).json() as any;
        expect(stats.batch.active_rows+stats.batch.pending_rows).toBe(0);
        return responses;
      } finally {clearTimeout(timer);arrival.mockRestore();graph.mockRestore();await shutdownServer(server);}
    };
    expect(await run(true)).toEqual(await run(false));
  },240_000);

  test("maybePageKv swaps exactly the full-attention layers", () => {
    const caches = model.makeCache();
    maybePageKv(caches, { pagedKv: { blockSize: BLOCK } }, 128);
    const paged = caches.filter((c) => c instanceof PagedKVCache).length;
    const plain = caches.filter((c) => c instanceof KVCache).length;
    expect(paged).toBeGreaterThan(0); // 12B has full-attention donor layers
    expect(plain).toBe(0); // every plain full-attention cache converted
    for (const c of caches) c.dispose();
  }, 240_000);

  test("single-forward logits bit-exact vs plain caches", () => {
    const run = (pagedKv: boolean): Float32Array => {
      const caches = model.makeCache();
      if (pagedKv) maybePageKv(caches, { pagedKv: { blockSize: BLOCK } }, promptIds.length + 8);
      const logits = model.forward(promptIds, caches);
      const out = lastPositionLogits(logits);
      logits.dispose();
      for (const c of caches) c.dispose();
      return out;
    };
    const plain = run(false);
    const paged = run(true);
    expect(paged).toEqual(plain); // tol 0 — same bytes, different layout
  }, 240_000);

  test("greedy trajectory identical over 48 tokens (incl. trim-free decode)", async () => {
    const run = async (pagedKv: boolean): Promise<number[]> => {
      const tokens: number[] = [];
      const gen = generate(model, promptIds, {
        maxTokens: 48,
        temperature: 0,
        ...(pagedKv ? { pagedKv: { blockSize: BLOCK } } : {}),
      });
      for await (const t of gen) tokens.push(t.token);
      return tokens;
    };
    const plain = await run(false);
    const paged = await run(true);
    expect(paged).toEqual(plain); // FULL agreement — the v1 bit-exact claim
    expect(plain.length).toBeGreaterThan(0);
  }, 240_000);
});
