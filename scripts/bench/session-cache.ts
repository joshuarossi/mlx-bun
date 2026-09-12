/** CPU cache-index comparison. Native KV ownership is checked separately.
 * Optional saved HTTP requests supply token histories, not model KV values. */
import { cpus, hostname } from "node:os";
import { readFileSync, readdirSync, mkdirSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { PromptCache } from "../../src/prompt-cache";
import type { Cache } from "../../src/model/gemma4";
const arg = (key: string, fallback = "") => process.argv.includes(key) ? process.argv[process.argv.indexOf(key) + 1]! : fallback;
const requests = arg("--requests"), model = arg("--model");
const state = (): Cache => ({ offset: 0, signature: () => "bench:session", state: () => [{ nbytes: 100 } as never],
  isTrimmable: () => false, trim() {}, dispose() {}, makeMask: () => ({ mode: "", arr: null }),
  updateAndFetch() { throw new Error("not a model benchmark"); } });
const create = (bytes = Infinity) => new PromptCache(bytes, null, null, caches => caches.map(state), () => {});
const release = (hit: ReturnType<PromptCache["take"]>) => { for (const c of hit?.caches ?? []) c.dispose(); hit?.retain?.(); };
let histories: number[][];
if (requests) {
  const { loadTokenizer } = await import("../../src/tokenizer");
  const { ChatTemplate } = await import("../../src/chat-template");
  const { normalizeMessages } = await import("../../src/serve/chat-request");
  const tokenizer = await loadTokenizer(model), template = await ChatTemplate.load(model);
  const files = readdirSync(requests).filter(f => /^request-\d+\.json$/.test(f)).sort((a,b) => Number(a.match(/\d+/)![0]) - Number(b.match(/\d+/)![0]));
  histories = files.map(file => {
    const body = JSON.parse(readFileSync(join(requests, file), "utf8"));
    return tokenizer.encode(template.render(normalizeMessages(body.messages), { tools: body.tools, enableThinking: body.chat_template_kwargs?.enable_thinking, preserveThinking: body.chat_template_kwargs?.preserve_thinking, reasoningEffort: body.reasoning_effort })).slice(0, -1);
  });
} else {
  const length = Number(arg("--tokens", "50000")), count = Number(arg("--checkpoints", "64"));
  const history = Array.from({ length }, (_, i) => i % 30000);
  histories = Array.from({ length: count }, (_, i) => history.slice(0, Math.floor(length * (i + 1) / count)));
}
const samples: object[] = [];
for (let sample = 0; sample < 8; sample++) for (const session of sample % 2 ? [true, false] : [false, true]) {
  const cache = create();
  try {
    let elapsedMs = 0;
    for (const ids of histories) {
      cache.put(ids, [state()], "", undefined, undefined, session ? "agent" : undefined);
      const prompt = [...ids, 42];
      // Warm the same code path, excluding it from the timed loop.
      release(cache.take(prompt, "", session ? "agent" : undefined));
      const start = performance.now();
      for (let repeat = 0; repeat < 20; repeat++) {
        const hit = cache.take(prompt, "", session ? "agent" : undefined);
        if (hit?.tokens.length !== ids.length) throw new Error("checkpoint selection differs");
        release(hit);
      }
      elapsedMs += (performance.now() - start) / 20;
    }
    samples.push({ sample, session, elapsedMs, lookups: histories.length, entries: cache.size,
      sessionHits: cache.sessionHits, prefixScans: cache.prefixScans });
  } finally { cache.clear(); }
}
const retention = [false, true].map(session => {
  const cache = create(300); let hits = 0;
  try {
    let ids = [1,2];
    for (let turn = 0; turn < 26; turn++) {
      cache.put(ids, [state()], "", undefined, undefined, session ? "agent" : undefined);
      for (let noise = 0; noise < 4; noise++) cache.put([100 + turn * 4 + noise], [state()]);
      const hit = cache.take([...ids, 42], "", session ? "agent" : undefined);
      if (hit) hits++; release(hit); ids = [...ids, 42];
    }
    return { session, hits, turns: 26, residentEntries: cache.size };
  } finally { cache.clear(); }
});
const report = { machine: hostname(), cpu: cpus()[0]?.model, bun: Bun.version, requests: requests || null,
  workload: requests ? "saved request renderings; immutable checkpoint at each prompt minus one token; CPU metadata only" : "nested immutable token checkpoints; CPU metadata only",
  tokenLengths: histories.map(h => h.length), samples, retention,
  retentionWorkload: "three equal-size RAM entries; four unrelated publications between each of 26 agent turns; misses would require SSD restore if durable" };
const output = arg("--output"); if (output) { mkdirSync(dirname(output), { recursive: true }); writeFileSync(output, JSON.stringify(report, null, 2)); }
console.log(JSON.stringify(report, null, 2));
