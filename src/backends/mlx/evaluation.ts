import type { TaskModel, GenOpts } from "../../eval/runner";
import type { CompletionClient } from "../../contracts/completion";
import { generate } from "../../generate";
import { clearCache } from "../../mlx/ffi";
import * as ops from "../../mlx/ops";
import { runtimeValue } from "../../runtime-config";
import { DiffusionGemmaModel } from "../../model/diffusion-gemma";

/** Bit-exact greedy decode: raw `model.forward` + argmax loop, which matches mlx-lm
 *  token-for-token (gen8k: 8000/8000). The product `generate()` decode wrapper
 *  (forwardHidden/logitsFromHidden + pipelined sampler) diverges from the raw forward
 *  on near-ties past ~32 tokens, so the EVAL decodes bit-exactly itself rather than
 *  alter the serving path. Greedy + full-precision KV only. */
export function greedyDecodeBitExact(tm: TaskModel, ids: number[], maxTokens: number): string {
  if (tm.activeAdapters) tm.model.loraState.active = tm.activeAdapters; // apply the mounted adapter
  const cache = tm.model.makeCache();
  try {
    // Chunked, LM-head-free prefill. The old single-shot `forward(prompt)`
    // materialized [1, L, vocab] logits just to discard them — at a 248k
    // vocab that's ~1 GB per 1k prompt tokens, and with no allocator-cache
    // clears the Metal buffer cache retained every giant freed tensor
    // (the 27B capability-suite 73 GB swap-thrash). Prefill only needs the
    // cache state, which forwardHidden advances identically (the LM head
    // never touches the cache) — bit-exact by construction. Chunk size and
    // clear cadence mirror mlx-lm generate_step / our generate().
    const PREFILL_CHUNK = 2048;
    const prompt = ids.slice(0, -1);
    for (let s = 0; s < prompt.length; s += PREFILL_CHUNK) {
      const chunk = prompt.slice(s, s + PREFILL_CHUNK);
      const cIds = ops.fromInt32(chunk, [1, chunk.length]);
      tm.model.forwardHidden(cIds, cache).dispose();
      cIds.dispose();
      clearCache();
    }
    let last = ids[ids.length - 1]!;
    const eos = new Set(tm.config.eosTokenIds);
    const out: number[] = [];
    for (let i = 0; i < maxTokens; i++) {
      const lg = tm.model.forward([last], cache);
      const am = ops.argmaxAxis(lg, -1); // GPU argmax (mlx-lm greedy: lowest-index tie-break)
      lg.dispose();
      const best = ops.itemUint32(am);
      am.dispose();
      if (i % 256 === 0) clearCache(); // mlx-lm decode cadence
      if (eos.has(best)) break; // mlx-lm halts on EOS and excludes it from the output
      out.push(best);
      last = best;
    }
    return tm.tokenizer.decode(out, true);
  } finally {
    for (const c of cache) c.dispose();
  }
}

/** Complete `body` via the model's real quantized-KV path. Greedy by default;
 *  pass `opts.sampler` to drive temperature/HLG/etc. */
async function generateTextNative(tm: TaskModel, body: string, opts: GenOpts = {}): Promise<string> {
  const maxTokens = opts.maxTokens ?? 256;
  const enableThinking = opts.enableThinking ?? runtimeValue("MLX_BUN_EVAL_THINK") === "1";
  const templated = opts.useChat !== false && tm.template !== null;
  const text = templated
    ? tm.template!.render([{ role: "user", content: body }], { addGenerationPrompt: true, enableThinking })
    : body;
  // The chat template ALREADY emits the BOS; encoding it with add_special_tokens on
  // would prepend a SECOND BOS (<s><s>…), corrupting generation. Raw bodies (no
  // template) get the BOS added as normal.
  const ids = tm.tokenizer.encode(text, /* addSpecialTokens */ !templated);

  // optiq's PUBLISHED eval generates with a FULL-PRECISION KV cache — its eval calls
  // plain mlx_lm.generate (kv-quant lives in the serving runtime, not the eval). So
  // for like-for-like parity we default the eval to UNQUANTIZED KV; MMLU's argmax
  // path was already unquantized, which is why it matched while generation didn't.
  // MLX_BUN_EVAL_KV_QUANT=1 generates through the model's quantized KV (serving
  // config); an explicit opts.kvScheme (cli generate's resolved tier route) wins.
  const envKv: GenOpts["kvScheme"] | undefined =
    (runtimeValue("MLX_BUN_EVAL_KV_QUANT") === "1" && tm.config.kvQuant?.length)
      ? { kvConfig: tm.config.kvQuant, quantizedKvStart: 0 } : undefined;
  const kvScheme = opts.kvScheme ?? envKv;
  const kvActive = !!(kvScheme && (kvScheme.kvBits || kvScheme.kvConfig?.length || kvScheme.turboQuant));

  // Parity default — greedy + full-precision KV + no sampler arm: decode bit-exactly
  // via the raw forward (matches mlx-lm token-for-token). Sampler arms / kv-quant fall
  // through to the product generate(). DiffusionGemma is non-autoregressive (no AR
  // forward) — always go through generate(), which routes it to the denoising engine.
  const isDiffusion = tm.model instanceof DiffusionGemmaModel;
  if (!isDiffusion && !kvActive && !opts.sampler && !tm.samplerOverride) {
    return greedyDecodeBitExact(tm, ids, maxTokens);
  }
  const gen = generate(tm.model, ids, {
    maxTokens,
    temperature: 0, // greedy default — deterministic head-to-head arms
    adapters: tm.activeAdapters ?? [], // per-request activation of the mounted eval-adapter
    ...(kvActive ? kvScheme : {}),
    ...(opts.sampler ?? {}), // overrides temperature when provided
    ...(tm.samplerOverride ?? {}), // arm override wins over the task's own sampler
  });

  const out: number[] = [];
  for await (const { token } of gen) out.push(token);
  return tm.tokenizer.decode(out, true);
}

export function createEvalCompletionClient(tm: TaskModel): CompletionClient<{ body: string; options?: GenOpts }, string> {
  return { complete: ({ body, options }) => generateTextNative(tm, body, options) };
}
