// Qwen MTP speculative generation through the shared batch group at B2 with
// generated-prefix persistence: the Trellis target and its folded MTP draft
// through the public gateway binding (depth 2, plain KV, EOS disabled). Two
// requests with unequal prompts (32 and 25 tokens, rendered here from their
// text) run together; request 0 retires by an `onToken` stop at its 14th
// token, an abort or a consumer failure at its 16th, and request 1 runs to its
// 24-token budget, greedy. A seeded (temperature 0.7, seed 42) stop case stops
// request 0 at its 80th token and runs request 1 to 128: seeded, request 1
// accepted every proposal through its planets list, so both stay in B2 past it.
// Every target forward, projection, draft round and commit is observed, with
// each row's committed target state (extracted through its layout, attributed
// to its request through joins and filters) at entry and after every commit.
// Checked within this tree:
// - each commit closes one verify round whose forward is [pending, ...proposals]
//   on the same target layouts; every projection is finite and full width;
// - every committed row is the exact inventory from the model's config and the
//   artifact's activation dtype, at the offset its draft processed, advancing by
//   accepted + 1 while the request continues;
// - B2 then request 1 alone; per row, while B2, accepted and rejected proposals
//   and a later two-row round after a rejection;
// - callbacks equal the returned tokens and are accounted for round by round
//   (a consumer failure inside a verified burst retains none of its drafts);
//   retirement outcomes are exact;
// - a stopped or finished request publishes one generated checkpoint equal to
//   its terminal committed target and draft state; a cancelled or failed one
//   publishes none (prompt checkpoints are allowed);
// - both requests continue together from those checkpoints (12 tokens): twice
//   from RAM with identical records and unchanged snapshots, and once in a fresh
//   process from the flushed SSD store with records identical to RAM.
// Main/new equality is external evidence, not asserted here. Not covered: B>2,
// KV quantization, HTTP, performance, an external oracle.
// Opt in with both of
//   MLX_BUN_TEST_MTP_TARGET=/qwen3.8-trellis/snapshot
//   MLX_BUN_TEST_MTP_DRAFT=/qwen3.8-mtp-draft/snapshot
// None set skips; any other combination fails. The fresh-process phase is this
// file run with MLX_BUN_TEST_MTP_PHASE=child and MLX_BUN_TEST_MTP_DIR set; the
// parent starts it only after releasing its own model.
import { expect, spyOn, test } from "bun:test";
import { strict as assert } from "node:assert";
import { closeSync, existsSync, mkdtempSync, openSync, readdirSync, readFileSync, readSync, rmSync, statSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, relative } from "node:path";
import { optInAll, releaseAll, sha256 } from "./real-weight-inputs";

type A = any;
const OPT_IN = ["MLX_BUN_TEST_MTP_TARGET", "MLX_BUN_TEST_MTP_DRAFT"] as const;
const PHASE = Bun.env.MLX_BUN_TEST_MTP_PHASE ?? "parent", CHILD_DIR = Bun.env.MLX_BUN_TEST_MTP_DIR;
if (PHASE !== "parent" && PHASE !== "child") throw new Error("MLX_BUN_TEST_MTP_PHASE must be parent or child");
if (PHASE === "child" && !CHILD_DIR) throw new Error("the child phase needs MLX_BUN_TEST_MTP_DIR");
const DEPTH = 2, CONTINUATION = 12, SUFFIX = [11, 12, 13];
/** The fresh-process phase's own deadline, inside the parent test's timeout. */
const CHILD_DEADLINE_MS = 600_000;
const PROMPTS = ["Write a bash one-liner that counts lines in all .ts files, then explain it briefly.",
  "List the planets of the solar system in order from the Sun."];
const GREEDY = { temperature: 0 }, SEEDED = { temperature: 0.7, seed: 42 };
/** Request 0 retires at `at` by its action; request 1 runs to `budget`. */
const CASES = [
  { name: "g-stop", sampling: GREEDY, action: "stop", at: 14, budget: 24, continued: true },
  { name: "g-cancel", sampling: GREEDY, action: "cancel", at: 16, budget: 24, continued: false },
  { name: "g-fail", sampling: GREEDY, action: "fail", at: 16, budget: 24, continued: false },
  { name: "s-stop", sampling: SEEDED, action: "stop", at: 80, budget: 128, continued: true },
] as const;
type Case = typeof CASES[number];
const json = (value: unknown) => JSON.stringify(value);
const HEX = /^[0-9a-f]{64}$/;

function optIn(env: Record<string, string | undefined>) {
  const values = optInAll(env, OPT_IN, "Qwen MTP group prefix");
  if (!values) return null;
  for (const name of OPT_IN) if (!existsSync(join(values[name], "config.json"))) throw new Error(`${name}: no config.json at ${values[name]}`);
  return { target: values[OPT_IN[0]], draft: values[OPT_IN[1]] };
}

/** The activation dtype: the stored dtype of the quantized embedding's scales,
 * read from the owning shard's header only. */
function activationDtype(model: string): string {
  const index = JSON.parse(readFileSync(join(model, "model.safetensors.index.json"), "utf8")).weight_map as Record<string, string>;
  const name = Object.keys(index).find(k => /(^|\.)embed_tokens\.scales$/.test(k) && !k.includes("visual"));
  if (!name) throw new Error("no quantized embedding scales in the index");
  const fd = openSync(join(model, index[name]!), "r");
  try {
    const prefix = Buffer.alloc(8);
    assert.equal(readSync(fd, prefix, 0, 8, 0), 8, "no safetensors header");
    const length = Number(prefix.readBigUInt64LE(0));
    assert(Number.isSafeInteger(length) && length > 1 && length < (1 << 28), `header length ${length}`);
    const body = Buffer.alloc(length);
    assert.equal(readSync(fd, body, 0, length, 8), length, "truncated header");
    const dtype = ({ BF16: "bfloat16", F16: "float16", F32: "float32" } as Record<string, string>)[JSON.parse(body.toString("utf8"))[name]?.dtype];
    if (!dtype) throw new Error("embedding scales dtype unsupported");
    return dtype;
  } finally { closeSync(fd); }
}

/** One committed row's exact inventory, in layer order. */
interface Geometry { layers: ("kv" | "ssm")[]; kv: { heads: number; dim: number; dtype: string };
  conv: { shape: number[]; dtype: string }; recurrent: { shape: number[]; dtype: string } }
/** Attention layers keep K/V [1, kv heads, offset, head dim]; linear-attention
 * layers keep the conv tail [1, kernel - 1, 2 * key heads * key dim + value
 * heads * value dim] in the activation dtype and the recurrent state [1, value
 * heads, value dim, key dim] in float32 (gatedDeltaUpdate's state type). */
function geometryFor(config: A, activation: string): Geometry {
  const t = config.text_config ?? config;
  const layers = (t.layer_types ?? []).map((type: string) => type === "full_attention" ? "kv" : type === "linear_attention" ? "ssm" : `unsupported:${type}`);
  if (!layers.length || layers.some((l: string) => l.startsWith("unsupported")) || layers.length !== t.num_hidden_layers) throw new Error("unsupported layer types");
  const convDim = 2 * t.linear_num_key_heads * t.linear_key_head_dim + t.linear_num_value_heads * t.linear_value_head_dim;
  return { layers, kv: { heads: t.num_key_value_heads, dim: t.head_dim, dtype: activation },
    conv: { shape: [1, t.linear_conv_kernel_dim - 1, convDim], dtype: activation },
    recurrent: { shape: [1, t.linear_num_value_heads, t.linear_value_head_dim, t.linear_key_head_dim], dtype: "float32" } };
}

// ---- checks over recorded submissions (no native code; exercised on CPU below) ----------
type Fail = (message: string) => void;
function rowOffset(row: A, geometry: Geometry, where: string, fail: Fail): number | null {
  const layers = row?.layers;
  if (!Array.isArray(layers) || layers.length !== geometry.layers.length) { fail(`${where}: ${layers?.length} layers, expected ${geometry.layers.length}`); return null; }
  const offsets = new Set<number>();
  for (let i = 0; i < layers.length; i++) {
    const l = layers[i], kind = geometry.layers[i]!;
    if (!Array.isArray(l?.arrays) || l.arrays.length !== 2 || !l.arrays.every((a: A) => HEX.test(a?.sha256 ?? ""))) { fail(`${where} layer ${i}: malformed layer`); return null; }
    const want = kind === "kv"
      ? { signature: "kv:plain", arrays: [0, 1].map(() => ({ shape: [1, geometry.kv.heads, l.offset, geometry.kv.dim], dtype: geometry.kv.dtype })) }
      : { signature: "ssm", arrays: [geometry.conv, geometry.recurrent].map(g => ({ shape: g.shape, dtype: g.dtype })) };
    const got = { signature: l.signature, arrays: l.arrays.map((a: A) => ({ shape: a.shape, dtype: a.dtype })) };
    if (!Number.isSafeInteger(l.offset) || json(got) !== json(want)) { fail(`${where} layer ${i}: ${json(got)}, expected ${json(want)}`); return null; }
    if (kind === "kv") offsets.add(l.offset);
  }
  if (offsets.size !== 1) { fail(`${where}: attention offsets ${json([...offsets])}`); return null; }
  return [...offsets][0]!;
}
/** Verify rounds: each commit closes one draft, one armed verify forward whose
 * rows are [pending, ...proposals] on the same layouts, and one projection of
 * that width; finite full-width projections; qwen-mtp-v1 draft checkpoints. */
function checkRounds(sub: A, vocab: number, where: string, fail: Fail) {
  if (!Array.isArray(sub?.events)) return fail(`${where}: no events`);
  let last = -1;
  sub.events.forEach((e: A, i: number) => {
    if (e.event === "project") {
      const [B, P, W] = e.logits?.shape ?? [];
      if (e.logits?.finite !== true || W !== vocab || !HEX.test(e.logits?.sha256 ?? "") || e.argmax?.length !== B || e.argmax.some((r: A) => r.length !== P))
        fail(`${where} event ${i}: projection ${json(e.logits)}`);
    } else if (e.event === "commit") {
      const window = sub.events.slice(last + 1, i); last = i;
      const drafts = window.filter((w: A) => w.event === "draft");
      if (drafts.length !== 1) return fail(`${where} commit ${i}: ${drafts.length} drafts in its round`);
      const d = drafts[0], B = e.accepted?.length;
      if (!B || d.proposals?.length !== B || d.pending?.length !== B) return fail(`${where} commit ${i}: rows`);
      const verify = window.filter((w: A) => w.event === "forward" && w.ids?.length === B &&
        w.ids.every((r: number[], row: number) => json(r) === json([d.pending[row], ...d.proposals[row]])));
      if (verify.length !== 1) return fail(`${where} commit ${i}: ${verify.length} verify forwards of [pending, ...proposals]`);
      if (verify[0].verify !== true || verify[0].sameLayouts !== true || window.filter((w: A) => w.event === "forward" && w.verify).length !== 1)
        fail(`${where} commit ${i}: the verify forward was not the armed round on the target layouts`);
      const L = verify[0].ids[0].length;
      if (window.filter((w: A) => w.event === "project" && w.logits?.shape?.[0] === B && w.logits?.shape?.[1] === L).length !== 1)
        fail(`${where} commit ${i}: no single ${B}x${L} verify projection`);
      e.accepted.forEach((a: number, row: number) => { if (!Number.isSafeInteger(a) || a < 0 || a > d.proposals[row].length) fail(`${where} commit ${i}: accepted ${a}`); });
      for (const c of e.drafts ?? []) if (c.schema !== "qwen-mtp-v1" || c.metadata?.draftOffset !== c.processedTokens - 1 || !c.tensors?.every((t: A) => HEX.test(t.sha256 ?? "")))
        fail(`${where} commit ${i}: draft checkpoint`);
      if (e.drafts?.length !== B) fail(`${where} commit ${i}: ${e.drafts?.length} draft checkpoints`);
    }
  });
  if (!sub.events.some((e: A) => e.event === "commit")) fail(`${where}: no verify rounds`);
}
/** Which request published a checkpoint: the request whose submitted cache
 * session ID it carries (passed unchanged to prompt and generated captures; the
 * composed namespace is not used), and whether it extends that request's
 * submitted prompt. An unknown session is unattributed (-1); token content is
 * validated separately and never decides the request. */
function attributePut(tokens: readonly number[], sessionId: unknown, sessions: readonly string[], prompts: readonly (readonly number[])[]) {
  const row = typeof sessionId === "string" ? sessions.indexOf(sessionId) : -1;
  return { row, kind: row >= 0 && tokens.length > prompts[row]!.length ? "generated" as const : "prompt" as const };
}
const commitPairs = (events: A[]) => events.flatMap((e: A, i: number) =>
  e.event === "commit" && events[i + 1]?.event === "state" && events[i + 1].at === "commit" && Array.isArray(events[i + 1].rows) ? [{ commit: e, state: events[i + 1], index: i }] : []);
/** Committed target state, chronologically per request, and completeness against
 * what the submission returned. Rows join through recorded join events (each
 * request at its processed offset); the first armed round after a join is
 * preceded by exactly one entry state for every member: a newly joined row at
 * its join's processed offset, every existing row exactly equal to its preceding
 * committed state. Each commit is followed by its committed state; each row's
 * attention offset equals its draft processedTokens and advances from that
 * request's own baseline by accepted + 1 while it continues (1..accepted + 1 in
 * its final round). */
function checkStates(sub: A, prompts: number[][], sessions: string[], geometry: Geometry, greedy: boolean, where: string, fail: Fail) {
  const events: A[] = sub?.events ?? [];
  const lastCommit = new Map<number, number>();
  events.forEach((e: A, i: number) => { if (e.event === "state" && e.at === "commit") for (const r of e.rows ?? []) lastCommit.set(r.request, i); });
  let members: number[] = [], pending: { commit: A; index: number } | null = null, joining: { requests: number[]; processed: number[] } | null = null, entries = 0;
  const baseline = new Map<number, number>(), lastRow = new Map<number, string>();
  events.forEach((e: A, i: number) => {
    if (e.event === "join") {
      if (!Array.isArray(e.requests) || !e.requests.length || !e.requests.every((q: A) => q === 0 || q === 1) ||
          e.processed?.length !== e.requests.length || !e.processed.every(Number.isSafeInteger)) return fail(`${where} event ${i}: join without an identified request`);
      if (e.requests.some((q: number) => members.includes(q) || baseline.has(q))) fail(`${where} event ${i}: a request joined twice`);
      members = [...members, ...e.requests];
      joining = { requests: [...(joining?.requests ?? []), ...e.requests], processed: [...(joining?.processed ?? []), ...e.processed] };
    } else if (e.event === "filter") {
      members = (e.keep ?? []).map((r: number) => members[r]);
      if (json(e.members) !== json(members)) fail(`${where} event ${i}: filter membership`);
    } else if (e.event === "commit") {
      if (pending) fail(`${where} event ${i}: the previous commit has no committed state`);
      if (joining) fail(`${where} event ${i}: a round before the joined rows' entry state`);
      if (e.accepted?.length !== members.length) fail(`${where} event ${i}: ${e.accepted?.length} rows committed, ${members.length} members`);
      pending = { commit: e, index: i };
    } else if (e.event === "state") {
      if (e.error || json(e.members) !== json(members) || e.rows?.length !== members.length || e.rows.some((r: A, k: number) => r.request !== members[k]))
        return fail(`${where} event ${i}: ${e.at} state (${e.error ?? `${e.rows?.length} rows`}) for members ${json(members)}`);
      if (e.at === "entry") {
        entries++;
        if (!joining || pending) return fail(`${where} event ${i}: an entry state without a pending join`);
        for (const r of e.rows) {
          const at = `${where} entry request ${r.request}`, o = rowOffset(r, geometry, at, fail), k = joining.requests.indexOf(r.request);
          if (k >= 0) { if (o !== null && o !== joining.processed[k]) fail(`${at}: joined at offset ${o}, processed ${joining.processed[k]}`); if (o !== null) baseline.set(r.request, o); }
          else if (json(r) !== lastRow.get(r.request)) fail(`${at}: an existing row's state changed at a join`);
          lastRow.set(r.request, json(r));
        }
        joining = null;
      } else {
        if (!pending || pending.index !== i - 1) return fail(`${where} event ${i}: commit state not right after its commit`);
        const { commit, index } = pending;
        pending = null;
        e.rows.forEach((r: A, k: number) => {
          const at = `${where} commit ${index} request ${r.request}`, o = rowOffset(r, geometry, at, fail), before = baseline.get(r.request);
          lastRow.set(r.request, json(r));
          if (o === null) return;
          if (o !== commit.drafts?.[k]?.processedTokens) fail(`${at}: target offset ${o}, draft processed ${commit.drafts?.[k]?.processedTokens}`);
          const continues = (lastCommit.get(r.request) ?? -1) > i;
          if (before === undefined) fail(`${at}: no baseline from a join`);
          else if (continues ? o - before !== commit.accepted[k] + 1 : o - before < 1 || o - before > commit.accepted[k] + 1) fail(`${at}: advanced ${o - before} with accepted ${commit.accepted[k]}`);
          baseline.set(r.request, o);
        });
      }
    }
  });
  if (pending) fail(`${where}: the last commit has no committed state`);
  if (joining) fail(`${where}: joined rows never entered a round`);
  if (!entries) fail(`${where}: no entry state`);
  const pairs = commitPairs(events);
  prompts.forEach((prompt, q) => {
    const tokens: number[] = sub?.tokens?.[q] ?? [], callbacks = events.filter((e: A) => e.event === "token" && e.row === q);
    if (json(callbacks.map((e: A) => e.token)) !== json(tokens) || callbacks.some((e: A, i: number) => e.index !== i + 1))
      fail(`${where}: request ${q} callbacks ${callbacks.length} do not match its ${tokens.length} returned tokens`);
    const outcome = sub?.outcomes?.[q]?.compared;
    if (outcome?.status === "fulfilled" && outcome.generatedTokens !== tokens.length) fail(`${where}: request ${q} generatedTokens ${outcome.generatedTokens}`);
    const mine = pairs.flatMap(p => { const k = p.state.rows.findIndex((r: A) => r.request === q); return k < 0 ? [] : [{ ...p, k, accepted: p.commit.accepted[k] as number }]; });
    if (!mine.length) return fail(`${where}: request ${q} has no committed rounds`);
    // Each callback belongs to the round it was delivered in (after the round's
    // draft, before its commit) or to none; a round's verify projection is the
    // last one before its draft. The recorded accepted count is what the round
    // retained: a consumer that fails (or is cancelled) inside a burst retains
    // no drafts, after the burst's tokens up to the failing one were delivered.
    const outside: A[] = [], rounds = new Map<number, { draft: A; project: A | null; tokens: A[] }>();
    let open: { draft: A; project: A | null; tokens: A[] } | null = null, project: A | null = null;
    events.forEach((e: A, i: number) => {
      if (e.event === "project") project = e;
      else if (e.event === "draft") { if (open) fail(`${where} event ${i}: a round began inside another`); open = { draft: e, project, tokens: [] }; }
      else if (e.event === "token" && e.row === q) (open ? open.tokens : outside).push(e);
      else if (e.event === "commit") {
        if (!open) return fail(`${where} event ${i}: a commit without its round's draft`);
        rounds.set(i, open); open = null; project = null;
      }
    });
    if (open) fail(`${where}: a round never committed`);
    if (outside.length !== 1 || outside[0]?.index !== 1) fail(`${where}: request ${q} delivered ${outside.length} tokens outside rounds; only its prefill token may be`);
    const member = new Set(mine.map(p => p.index));
    for (const [index, round] of rounds) if (round.tokens.length && !member.has(index))
      fail(`${where} event ${index}: request ${q} delivered ${round.tokens.length} tokens in a round it is not a member of`);
    const failed = outcome?.status === "rejected" && outcome.reason === "failed consumer";
    const cancelled = outcome?.status === "rejected" && outcome.reason === "cancelled consumer";
    let last = outside[0]?.token;
    mine.forEach((p, n) => {
      const round = rounds.get(p.index)!, final = n === mine.length - 1, a = p.accepted;
      const delivered: number[] = round.tokens.map((e: A) => e.token), e = delivered.length;
      const proposals: number[] = round.draft?.proposals?.[p.k] ?? [];
      const at = `${where} event ${p.index}: request ${q}`, said = `delivered ${json(delivered)} with accepted ${a} of ${json(proposals)}`;
      if (round.draft?.pending?.[p.k] !== last) fail(`${at}: pending ${round.draft?.pending?.[p.k]} is not its last delivered token ${last}`);
      if (e) last = delivered.at(-1);
      if (greedy) {
        // The verified burst: leading drafts equal to the verify argmax, then its correction (or bonus) token.
        const argmax: number[] | undefined = round.project?.argmax?.[p.k];
        if (!Array.isArray(argmax) || argmax.length !== proposals.length + 1) return fail(`${at}: no verify argmax for its row`);
        let v = 0;
        while (v < proposals.length && proposals[v] === argmax[v]) v++;
        const burst = [...proposals.slice(0, v), argmax[v]!];
        const prefix = e >= 1 && e <= burst.length && json(delivered) === json(burst.slice(0, e));
        if (!final) {
          if (!(prefix && e === burst.length && a === v)) fail(`${at}: continued past a round it ${said}; the verified burst is ${json(burst)}`);
        // Both trees check a request's abort before each callback: a consumer
        // that fails retains none; a cancellation retains none only when a
        // later token of the burst was attempted, and otherwise the normal count.
        } else if (!prefix || !(failed ? a === 0 : cancelled ? (e < burst.length ? a === 0 : a === Math.min(e, v)) : a === Math.min(e, v)))
          fail(`${at}: its final round ${said}; the verified burst is ${json(burst)} (${failed ? "failed" : cancelled ? "cancelled" : "finished"})`);
      } else {
        // Sampled: accepted drafts lead the burst and the retained count bounds the deliveries; no retention-free truncation.
        const drafted = (count: number) => json(delivered.slice(0, count)) === json(proposals.slice(0, count));
        if (!final ? !(e === a + 1 && drafted(a)) : !(e >= 1 && (e === a || e === a + 1) && drafted(Math.min(e, a))))
          fail(`${at}: ${final ? "its final round" : "a round it continued past"} ${said}`);
      }
    });
  });
  events.forEach((p: A, i: number) => {
    if (p.event !== "put") return;
    if (!(p.row >= 0 && p.row < prompts.length) || p.sessionId !== sessions[p.row]) return fail(`${where} event ${i}: unattributed put (session ${json(p.sessionId)})`);
    if (p.kind === "prompt") {
      const prompt = prompts[p.row]!;
      if (!(p.ids?.length >= 1 && p.ids.length <= prompt.length && json(p.ids) === json(prompt.slice(0, p.ids.length))))
        fail(`${where} event ${i}: prompt put is not a prefix of request ${p.row}'s prompt`);
      return;
    }
    if (p.kind !== "generated") return fail(`${where} event ${i}: put kind ${p.kind}`);
    const q = p.row, at = `${where} request ${q} generated put`;
    const transcript = [...prompts[q]!, ...(sub.tokens?.[q] ?? [])], missing = transcript.length - p.ids.length;
    if (json(p.ids) !== json(transcript.slice(0, p.ids.length)) || missing < 0 || missing > 1) fail(`${at}: not the transcript less at most its pending token`);
    if (json(p.digest?.attachments?.map((a: A) => a[0])) !== json(["qwen-mtp-v1"]) || p.digest.attachments[0][1]?.draftOffset !== p.ids.length - 1) fail(`${at}: attachment`);
    const terminal = commitPairs(events.slice(0, i)).filter(x => x.state.rows.some((r: A) => r.request === q)).at(-1);
    if (!terminal) return fail(`${at}: no committed state before it`);
    const k = terminal.state.rows.findIndex((r: A) => r.request === q), row = terminal.state.rows[k], draft = terminal.commit.drafts?.[k];
    const offset = rowOffset(row, geometry, `${at} terminal state`, fail);
    if (offset !== p.ids.length || draft?.processedTokens !== p.ids.length) fail(`${at}: ${p.ids.length} ids, terminal committed offset ${offset}`);
    if (json(p.digest?.offsets) !== json(row.layers.map((l: A) => l.offset)) ||
        json(p.digest?.arrays) !== json([...row.layers.flatMap((l: A) => l.arrays), ...(draft?.tensors ?? [])]))
      fail(`${at}: published planes are not the terminal committed target and draft state`);
  });
}
/** Compared form of a submission: namespaces out, outcomes through the deterministic whitelist. */
const SPEC = ["drafted", "accepted", "targetCalls", "draftedByPos", "acceptedByPos", "rejected", "rounds", "acceptanceLengths", "tokensPerForward", "forwardsSaved"];
function project(sub: A) {
  const whitelist = (v: A) => v && Object.fromEntries(["status", "reason", "promptTokens", "generatedTokens", "cachedTokens", "finishReason", "spec"]
    .filter(k => k in v).map(k => [k, k === "spec" && v.spec ? Object.fromEntries(SPEC.map(s => [s, v.spec[s] ?? null])) : v[k]]));
  return { events: (sub?.events ?? []).map((e: A) => { if (e.event !== "put") return e; const { namespace: _, ...rest } = e; return rest; }),
    tokens: sub?.tokens, outcomes: (sub?.outcomes ?? []).map((x: A) => whitelist(x.compared)) };
}
const puts = (sub: A, kind: string) => (sub?.events ?? []).filter((e: A) => e.event === "put" && e.kind === kind);
/** Everything this tree must hold for one case, its RAM continuations and, when given, its fresh-process restore. */
function checkCase(c: Case, rec: A, restore: A | undefined, prompts: number[][], vocab: number, geometry: Geometry, fail: Fail) {
  const at = c.name;
  if (!rec) return fail(`${at}: missing record`);
  if (rec.error) return fail(`${at}: error ${String(rec.error).split("\n")[0]}`);
  if (json(rec.prompts) !== json(prompts)) fail(`${at}: prompts`);
  const g = rec.generation;
  checkRounds(g, vocab, `${at} generation`, fail);
  const sessions = [0, 1].map(q => `${c.name}-${q}`);
  checkStates(g, prompts, sessions, geometry, c.sampling.temperature === 0, `${at} generation`, fail);
  const commits = (g?.events ?? []).filter((e: A) => e.event === "commit"), states = (g?.events ?? []).filter((e: A) => e.event === "state" && e.at === "commit");
  if (!commits.some((e: A) => e.accepted.length === 2) || !(g?.events ?? []).some((e: A) => e.event === "token" && e.activeRows === 2)) fail(`${at}: B2 was never active`);
  if (!states.some((e: A) => json([...(e.members ?? [])].sort()) === "[0,1]") || json(states.at(-1)?.members) !== "[1]") fail(`${at}: membership is not both requests, then request 1 alone`);
  const [t0, t1] = g?.tokens ?? [], o = (g?.outcomes ?? []).map((x: A) => x.compared);
  if (!(c.action === "cancel" ? t0?.length >= c.at && t0?.length <= c.at + DEPTH : t0?.length === c.at)) fail(`${at}: request 0 emitted ${t0?.length} tokens`);
  if (t1?.length !== c.budget) fail(`${at}: request 1 emitted ${t1?.length} tokens`);
  const want0 = c.action === "stop" ? { status: "fulfilled", finishReason: "stop", generatedTokens: c.at }
    : { status: "rejected", reason: c.action === "cancel" ? "cancelled consumer" : "failed consumer" };
  for (const [k, v] of Object.entries(want0)) if (o[0]?.[k] !== v) fail(`${at}: request 0 ${k} ${o[0]?.[k]}`);
  if (o[1]?.status !== "fulfilled" || o[1]?.finishReason !== "length" || o[1]?.generatedTokens !== c.budget) fail(`${at}: request 1 outcome`);
  const generated = puts(g, "generated");
  if (json(generated.map((p: A) => p.row).sort()) !== json(c.action === "stop" ? [0, 1] : [1])) fail(`${at}: generated puts for requests ${json(generated.map((p: A) => p.row))}`);
  if (!puts(g, "prompt").length) fail(`${at}: no prompt checkpoints`);
  const rounds: A[] = [];
  let draft: A = null;
  for (const e of g?.events ?? []) { if (e.event === "draft") draft = e; if (e.event === "commit" && e.accepted.length === 2 && draft) rounds.push({ proposals: draft.proposals, accepted: e.accepted }); }
  for (const row of [0, 1]) {
    const rejectedAt = rounds.findIndex(r => r.accepted[row] < r.proposals[row].length);
    if (!rounds.some(r => r.accepted[row] > 0) || rejectedAt < 0 || rejectedAt === rounds.length - 1)
      fail(`${at}: not qualified: row ${row} needs accepted and rejected proposals and a later two-row round while B2 (first rejection ${rejectedAt} of ${rounds.length})`);
  }
  if (rec.flush?.durable !== true || rec.flush?.pendingBytes !== 0) fail(`${at}: drain`);
  if (!c.continued) return;
  const byRow = [0, 1].map(q => generated.find((p: A) => p.row === q));
  const continuationPrompts = prompts.map((prompt, q) => [...prompt, ...(g.tokens?.[q] ?? []), ...SUFFIX]);
  const checkContinuation = (sub: A, where: string) => {
    checkRounds(sub, vocab, where, fail);
    checkStates(sub, continuationPrompts, sessions, geometry, c.sampling.temperature === 0, where, fail);
    if (json(puts(sub, "generated").map((p: A) => p.row).sort()) !== "[0,1]") fail(`${where}: generated puts`);
    if (sub?.outcomes?.length !== 2) fail(`${where}: rows`);
    (sub?.outcomes ?? []).forEach((x: A, q: number) => {
      const v = x.compared;
      if (v?.status !== "fulfilled" || v.finishReason !== "length" || v.generatedTokens !== CONTINUATION || v.cachedTokens !== byRow[q]?.ids?.length) fail(`${where}: request ${q} ${json(v)}`);
    });
  };
  if (!Array.isArray(rec.ram) || rec.ram.length !== 2) return fail(`${at}: ${rec.ram?.length} RAM continuations`);
  rec.ram.forEach((r: A, i: number) => {
    checkContinuation(r, `${at} RAM ${i}`);
    for (const [label, takes] of [["before", r.takeBefore], ["after", r.takeAfter]] as const) byRow.forEach((p: A, q: number) => {
      if (!p || json(takes?.[q]?.digest) !== json(p.digest) || takes?.[q]?.tokens !== p.ids.length) fail(`${at} RAM ${i}: take ${label} request ${q} differs from its put`);
    });
  });
  if (json(project(rec.ram[0])) !== json(project(rec.ram[1]))) fail(`${at}: the RAM continuations differ`);
  if (rec.continuationFlush?.durable !== true || rec.continuationFlush?.pendingBytes !== 0) fail(`${at}: continuation flush`);
  if (restore === undefined) return;
  const w = `${at} restore`;
  if (!restore || restore.error) return fail(`${w}: ${restore ? String(restore.error).split("\n")[0] : "missing"}`);
  if (restore.ssdUnchanged !== true) fail(`${w}: the SSD directory changed after the parent flushed it`);
  if (!(restore.scanned > 0)) fail(`${w}: scan found ${restore.scanned}`);
  byRow.forEach((p: A, q: number) => { if (!p || json(restore.take?.[q]?.digest) !== json(p.digest) || restore.take?.[q]?.tokens !== p.ids.length) fail(`${w}: take request ${q} differs from its put`); });
  checkContinuation(restore, w);
  if (json(project(restore)) !== json(project(rec.ram[0]))) fail(`${w}: the SSD continuation differs from the RAM continuation`);
}
const problems = (body: (fail: Fail) => void) => { const out: string[] = []; body(m => { if (out.length < 30) out.push(m); }); return out; };

// ---- recording (native) ----------------------------------------------------------------
async function record(inputs: { target: string; draft: string }, directory: string, phase: "parent" | "child") {
  const { loadModelConfig, Weights, createModel, loadTokenizer, ChatTemplate } = await import("@mlx-bun/inference");
  const { QwenMtpProvider } = await import("@mlx-bun/inference/generation/speculative");
  const { bindMlxGateway } = await import("@mlx-bun/inference/execution");
  const { PromptCache, SsdCacheStore, TieredPromptCache, cloneKvCaches, leaseCacheStates, disposeAttachments } = await import("@mlx-bun/inference/state");
  const { disposeResources } = await import("@mlx-bun/inference/execution");
  const ops = await import("@mlx-bun/mlx/ops");
  const { clearCache } = await import("@mlx-bun/mlx/ffi");
  const config = await loadModelConfig(inputs.target);
  const tokenizer = await loadTokenizer(inputs.target), template = await ChatTemplate.load(inputs.target);
  const prompts = PROMPTS.map(text => {
    const ids = tokenizer.encode(template.render([{ role: "user", content: text }], { enableThinking: false }));
    return ids[0] === ids[1] && ids[0] === tokenizer.bosTokenId ? ids.slice(1) : ids;
  });
  assert.notEqual(prompts[0]!.length, prompts[1]!.length, "requests are identified by their unequal prompt lengths");
  const geometry = geometryFor(JSON.parse(readFileSync(join(inputs.target, "config.json"), "utf8")), activationDtype(inputs.target));
  const weights = await Weights.open(inputs.target);
  const releases: (() => void)[] = [];
  const records: Record<string, A> = {};
  try {
    const model = createModel(weights, config) as A;
    const provider = await QwenMtpProvider.load(inputs.draft);
    releases.push(() => provider.dispose());
    const tensor = (value: A, finite = false) => {
      using compact = ops.contiguous(value);
      const out: A = { shape: [...compact.shape], dtype: compact.dtypeName, sha256: sha256(compact.rawBytesView()) };
      if (finite) out.finite = (compact.toFloat32() as Float32Array).every(Number.isFinite);
      return out;
    };
    const planes = (cache: A) => {
      const values = cache.state();
      try {
        return { signature: cache.signature(), offset: cache.offset, arrays: values.map((value: A) => {
          const s = value.shape;
          const view = cache.signature() !== "ssm" && s.length === 4 && s[2] > cache.offset ? value.slice([0, 0, 0, 0], [s[0], s[1], cache.offset, s[3]]) : null;
          try { return tensor(view ?? value); } finally { view?.dispose(); }
        }) };
      } finally { if (cache.stateNeedsDispose) for (const value of values) value.dispose(); }
    };
    const rowStates = (caches: A[], members: number[]) => members.map((request, row) => ({ request, layers: caches.map((layout: A) => {
      const solo = layout.extractRow(row);
      try { return planes(solo); } finally { solo.dispose(); }
    }) }));
    const digest = (entry: { caches: A[]; attachments?: A[] }) => {
      const clone = cloneKvCaches(entry.caches);
      try {
        const arrays: A[] = [], lease = leaseCacheStates(clone);
        try { for (const a of [...lease.borrow(), ...(entry.attachments ?? []).flatMap((x: A) => x.tensors)]) arrays.push(tensor(a)); }
        finally { lease.close(); }
        return { offsets: clone.map((c: A) => c.offset), attachments: (entry.attachments ?? []).map((a: A) => [a.schema, a.metadata]), arrays };
      } finally { disposeResources(clone); }
    };
    const checkpoint = (value: A) => ({ processedTokens: value.processedTokens, schema: value.attachment.schema,
      metadata: value.attachment.metadata, tensors: value.attachment.tensors.map((t: A) => tensor(t)) });
    let log: A[] | null = null;
    let context: { lengths: number[]; prompts: number[][]; sessions: string[]; members: number[]; targetCaches: A[] | null; joined: boolean;
      arm: { pending: number[]; depth: number; proposals: number[][] | null } | null; layouts: A[] | null } | null = null;
    const note = (event: A) => { log?.push(event); };
    const isVerify = (rows: number[][]) => {
      const arm = context?.arm;
      if (!arm || rows.length !== arm.pending.length) return false;
      const width = arm.proposals ? 1 + Math.max(0, ...arm.proposals.map(p => p.length)) : arm.depth + 1;
      return rows.every((row, r) => row.length === width && row[0] === arm.pending[r] &&
        (!arm.proposals || row.slice(1).every((t, i) => t === (i < arm.proposals![r]!.length ? arm.proposals![r]![i] : arm.pending[r]))));
    };
    // Observers, installed before the gateway binds projectLogits.
    const forwardHidden = model.forwardHidden.bind(model), logitsFromHidden = model.logitsFromHidden.bind(model);
    const forwardSpy = spyOn(model, "forwardHidden").mockImplementation((input: A, caches: A[], ...rest: A[]) => {
      const flat = input.toIntTokens() as number[], [B, L] = input.shape;
      const event: A = { event: "forward", ids: Array.from({ length: B }, (_, r) => flat.slice(r * L, (r + 1) * L)) };
      if (isVerify(event.ids)) {
        event.verify = true; context!.arm = null;
        if (context!.layouts === null) context!.layouts = caches;
        event.sameLayouts = context!.layouts === caches;
        if (context!.joined) { note({ event: "state", at: "entry", members: [...context!.members], rows: rowStates(caches, context!.members) }); context!.joined = false; }
        context!.targetCaches = caches;
      }
      const hidden = forwardHidden(input, caches, ...rest);
      try { event.hidden = tensor(hidden); note(event); } catch (error) { hidden.dispose(); throw error; }
      return hidden;
    });
    releases.push(() => forwardSpy.mockRestore());
    const logitsSpy = spyOn(model, "logitsFromHidden").mockImplementation((hidden: A, ...rest: A[]) => {
      const logits = logitsFromHidden(hidden, ...rest);
      try {
        using arg = ops.argmaxAxis(logits, -1);
        const [B, P] = logits.shape, flat = arg.toIntTokens() as number[];
        note({ event: "project", logits: tensor(logits, true), argmax: Array.from({ length: B }, (_, r) => flat.slice(r * P, (r + 1) * P)) });
      } catch (error) { logits.dispose(); throw error; }
      return logits;
    });
    releases.push(() => logitsSpy.mockRestore());
    const observeRows = (rows: A, kind: "decode" | "prefill") => {
      const draft = rows.draft.bind(rows), commit = rows.commit.bind(rows), capture = rows.capture.bind(rows);
      rows.draft = async (pending: number[], depth: number, steps: number[]) => {
        const proposals = await draft(pending, depth, steps);
        note({ event: "draft", pending: [...pending], depth, steps: [...steps], proposals });
        if (context && kind === "decode") context.arm = { pending: [...pending], depth, proposals: proposals.map((p: number[]) => [...p]) };
        return proposals;
      };
      if (rows.draftDevice) {
        const device = rows.draftDevice.bind(rows);
        rows.draftDevice = (pending: number[], depth: number, steps: number[]) => {
          const lazy = device(pending, depth, steps);
          if (!lazy) return lazy;
          if (context && kind === "decode") context.arm = { pending: [...pending], depth, proposals: null };
          return { tokens: lazy.tokens, resolve(read: readonly number[]) {
            const proposals = lazy.resolve(read);
            note({ event: "draft", pending: [...pending], depth, steps: [...steps], proposals, device: true });
            return proposals;
          } };
        };
      }
      rows.commit = async (accepted: number[], ctx: A) => {
        await commit(accepted, ctx);
        const drafts: A[] = [];
        for (let row = 0; row < rows.rowCount; row++) {
          const value = capture(row);
          try { drafts.push(checkpoint(value)); } finally { disposeAttachments([value.attachment]); }
        }
        note({ event: "commit", accepted: [...accepted], drafts });
        // The target transaction resolves before draft.commit: these are committed rows.
        const caches = context?.targetCaches;
        if (context) context.targetCaches = null;
        if (!caches || context!.members.length !== accepted.length) note({ event: "state", at: "commit", error: "no verify forward in this round" });
        else note({ event: "state", at: "commit", members: [...context!.members], rows: rowStates(caches, context!.members) });
      };
      rows.capture = (row: number) => {
        const value = capture(row);
        try { note({ event: "group-capture", kind, row, draft: checkpoint(value) }); } catch (error) { disposeAttachments([value.attachment]); throw error; }
        return value;
      };
      if (kind === "decode") {
        const requestFor = (processed: number) => {
          const matches = context!.lengths.flatMap((length, q) => length === processed ? [q] : []);
          return matches.length === 1 ? matches[0]! : -1;
        };
        const joined = (checkpoints: A[]) => {
          const requests = checkpoints.map((c: A) => requestFor(c.processedTokens));
          return () => { context!.members.push(...requests); context!.joined = true; note({ event: "join", requests, processed: checkpoints.map((c: A) => c.processedTokens) }); };
        };
        const prepareAppend = rows.prepareAppend.bind(rows), append = rows.append.bind(rows), filterRows = rows.filterRows.bind(rows);
        rows.prepareAppend = (checkpoints: A[]) => {
          const apply = joined(checkpoints), change = prepareAppend(checkpoints);
          return { commit() { change.commit(); apply(); }, dispose() { change.dispose(); } };
        };
        rows.append = (checkpoints: A[]) => { const apply = joined(checkpoints); append(checkpoints); apply(); };
        rows.filterRows = (keep: readonly number[]) => {
          filterRows(keep);
          context!.members = keep.map(row => context!.members[row]!);
          note({ event: "filter", keep: [...keep], members: [...context!.members] });
        };
      }
      return rows;
    };
    const open = provider.grouped.open.bind(provider.grouped), openPrefill = provider.grouped.openPrefill.bind(provider.grouped);
    const openSpy = spyOn(provider.grouped, "open").mockImplementation((options: A) => observeRows(open(options), "decode"));
    const prefillSpy = spyOn(provider.grouped, "openPrefill").mockImplementation((options: A) => observeRows(openPrefill(options), "prefill"));
    releases.push(() => openSpy.mockRestore(), () => prefillSpy.mockRestore());
    const binding = bindMlxGateway(model, { provider, numDraftTokens: DEPTH });
    const methodFor = (sampling: A, maxTokens: number) => {
      const options = { ...sampling, maxTokens };
      const plan = binding.plan({ hasVision: false, hasAdapters: false, hasRepetitionPenalty: false, userSeed: "seed" in sampling,
        kvQuant: false, turboQuant: false, hasLogitsExtras: false, hasGrammar: false, wantsLogprobs: false, hasDraft: true }, options,
      { continuous: true, quantizedBatch: false, checkpoints: false });
      assert.equal(plan.method, "speculative"); assert.equal(plan.mechanism, "continuous");
      const method = binding.methodRequest!(plan, options);
      assert(method, "the MTP method must bind");
      return method;
    };
    const storeOptions = (name: string) => ({ dir: join(directory, "ssd", name), maxBytes: 4 * 1024 ** 3, modelId: inputs.target,
      configFingerprint: "qwen-mtp-group-prefix", tokenizerHash: "qwen-mtp-group-prefix", verify: true, storage: { layout: "blocks" as const } });
    const cold = (ssd: A, async = false) => ({
      find(tokens: number[], ns: string) { const hit = ssd.find(tokens, ns); return hit ? { prefixLen: hit.prefixLen, handle: hit.entry } : null; },
      restore(handle: A) { const hit = ssd.restore(handle, model); return hit ? { ...hit, retain() {} } : null; },
      ...(async ? { async restoreAsync(handle: A) { const hit = await ssd.restoreAsync(handle, model); return hit ? { ...hit, retain() {} } : null; } } : {}),
      store: (tokens: number[], caches: A[], ns: string, attachments: A[]) => ssd.store(tokens, caches, ns, attachments),
    });
    const manifest = (dir: string) => {
      const files: Record<string, string> = {};
      const walk = (at: string) => { for (const name of readdirSync(at).sort()) { const path = join(at, name);
        if (statSync(path).isDirectory()) walk(path); else files[relative(dir, path)] = sha256(readFileSync(path)); } };
      walk(dir); return files;
    };
    const observePuts = (cache: A) => {
      const put = cache.put.bind(cache);
      return spyOn(cache, "put").mockImplementation((...args: A[]) => {
        const tokens: number[] = args[0], { row, kind } = attributePut(tokens, args[5], context?.sessions ?? [], context?.prompts ?? []);
        note({ event: "put", row, kind, ids: [...tokens], namespace: args[2], sessionId: args[5] ?? null, digest: digest({ caches: args[1], attachments: args[4] }) });
        return put(...args);
      });
    };
    const outcome = (settled: PromiseSettledResult<A>) => settled.status === "rejected"
      ? { compared: { status: "rejected", reason: String(settled.reason?.message ?? settled.reason) } }
      : { compared: { status: "fulfilled", promptTokens: settled.value.promptTokens, generatedTokens: settled.value.generatedTokens,
        cachedTokens: settled.value.cachedTokens, finishReason: settled.value.finishReason,
        spec: settled.value.spec ? Object.fromEntries(SPEC.map(k => [k, settled.value.spec[k] ?? null])) : null }, diagnostic: settled.value };
    const submit = async (cache: A, requests: { promptIds: number[]; method: A; name: string; maxTokens: number; snapshotAt?: number;
      signal?: AbortSignal; onToken?: (count: number) => boolean | void }[]) => {
      const events: A[] = [], tokens: number[][] = requests.map(() => []);
      log = events;
      context = { lengths: requests.map(r => r.promptIds.length), prompts: requests.map(r => [...r.promptIds]), sessions: requests.map((r, q) => `${r.name}-${q}`),
        members: [], targetCaches: null, joined: false, arm: null, layouts: null };
      const group = binding.createBatchGroup({ maxBatch: 2, promptCache: cache });
      let settled: PromiseSettledResult<A>[];
      try {
        settled = await Promise.allSettled(requests.map((request, q) => group.submit({ method: request.method, promptIds: request.promptIds,
          cacheNamespace: `${request.name}-${q}`, cacheSessionId: `${request.name}-${q}`, maxTokens: request.maxTokens,
          eosTokenIds: [], ...(request.snapshotAt !== undefined ? { snapshotAt: request.snapshotAt } : {}), ...(request.signal ? { signal: request.signal } : {}),
          onToken(token: number) { tokens[q]!.push(token); note({ event: "token", row: q, token, index: tokens[q]!.length, activeRows: group.activeRows }); return request.onToken?.(tokens[q]!.length); } })));
      } finally { await group.close(); log = null; context = null; }
      return { events, tokens, outcomes: settled.map(outcome) };
    };
    // As main's generated-prefix test and the external lane: no new prompt snapshot on continuation.
    const continuation = (c: Case, outputs: number[][]) => prompts.map((prompt, q) => ({ name: c.name, promptIds: [...prompt, ...outputs[q]!, ...SUFFIX],
      method: methodFor(c.sampling, CONTINUATION), maxTokens: CONTINUATION, snapshotAt: 1 }));
    const take = (cache: A, put: A) => {
      const hit = cache.take([...put.ids, 31], put.namespace);
      if (!hit) return null;
      try { return { tokens: hit.tokens.length, digest: digest(hit) }; }
      finally { disposeResources([...hit.caches, { dispose: () => disposeAttachments(hit.attachments) }, { dispose: () => hit.retain?.() }]); }
    };
    if (phase === "parent") {
      for (const c of CASES) {
        const ssd = new SsdCacheStore(storeOptions(c.name)), cache = new TieredPromptCache(4 * 1024 ** 3, ssd, cold(ssd));
        const putSpy = observePuts(cache), aborted = new AbortController();
        const rec: A = { case: c, prompts };
        let primary = false;
        try {
          rec.generation = await submit(cache, prompts.map((promptIds, q) => ({ name: c.name, promptIds, method: methodFor(c.sampling, c.budget), maxTokens: c.budget,
            ...(q === 0 && c.action === "cancel" ? { signal: aborted.signal } : {}),
            onToken: q !== 0 ? undefined : (count: number) => {
              if (count !== c.at) return;
              if (c.action === "stop") return false;
              if (c.action === "fail") throw new Error("failed consumer");
              aborted.abort(new Error("cancelled consumer"));
            } })));
          const drained = await cache.durability.flush();
          rec.flush = { durable: drained.durable, pendingBytes: cache.spillQueue.pendingBytes };
          if (c.continued) {
            const snapshots = puts(rec.generation, "generated").sort((a: A, b: A) => a.row - b.row);
            rec.ram = [];
            for (let repeat = 0; repeat < 2; repeat++) {
              const takeBefore = snapshots.map((p: A) => take(cache, p));
              const sub = await submit(cache, continuation(c, rec.generation.tokens));
              rec.ram.push({ takeBefore, ...sub, takeAfter: snapshots.map((p: A) => take(cache, p)) });
            }
            const flushed = await cache.durability.flush();
            rec.continuationFlush = { durable: flushed.durable, pendingBytes: cache.spillQueue.pendingBytes };
            rec.snapshots = { outputs: rec.generation.tokens, puts: snapshots.map((p: A) => ({ ids: p.ids, namespace: p.namespace, digest: p.digest })),
              ssd: manifest(storeOptions(c.name).dir) };
          }
        } catch (error) { primary = true; rec.error = String((error as Error)?.stack ?? error); }
        finally {
          try { await cache.durability.flush(); } catch (error) { if (!primary) throw error; }
          finally { putSpy.mockRestore(); cache.clear(); clearCache(); }
        }
        records[c.name] = rec;
      }
    } else {
      const expected = JSON.parse(readFileSync(join(directory, "expected.json"), "utf8"));
      for (const c of CASES.filter(c => c.continued)) {
        const snapshots = expected[c.name].snapshots, dir = storeOptions(c.name).dir;
        const rec: A = { ssdUnchanged: existsSync(dir) && json(manifest(dir)) === json(snapshots.ssd) };
        const restarted = new SsdCacheStore(storeOptions(c.name));
        rec.scanned = restarted.scan();
        const cache = new PromptCache(4 * 1024 ** 3, null, cold(restarted, true)), putSpy = observePuts(cache);
        try {
          rec.take = [];
          for (const p of snapshots.puts) {
            const release = await cache.prefetch([...p.ids, 31], p.namespace);
            try { rec.take.push(take(cache, p)); } finally { release(); }
          }
          Object.assign(rec, await submit(cache, continuation(c, snapshots.outputs)));
        } catch (error) { rec.error = String((error as Error)?.stack ?? error); }
        finally { putSpy.mockRestore(); cache.clear(); clearCache(); }
        records[c.name] = rec;
      }
    }
  } finally {
    try { releaseAll(releases.reverse()); }
    finally {
      try { weights.dispose(); }
      finally { releaseAll([...weights.shards.files.values()].map(file => () => file.mmap.unmap()).concat([() => clearCache()])); }
    }
  }
  return { records, prompts, geometry, vocab: config.text.vocabSize as number };
}

/** Run a child process with a deadline; stdout and stderr drain while it runs.
 * A child still running at the deadline, or when waiting fails, is sent TERM and,
 * after `graceMs` (or if TERM or the grace wait fails), KILL, then joined. Complete
 * outputs are always collected; a failure while waiting, stopping or collecting is
 * rethrown (the first one) with the status and both outputs attached. */
async function runBounded(command: string[], env: Record<string, string | undefined>, timeoutMs: number, graceMs = 10_000) {
  const child = Bun.spawn(command, { env, stdout: "pipe", stderr: "pipe" });
  const outputs = Promise.all([new Response(child.stdout).text(), new Response(child.stderr).text()]);
  const within = (ms: number) => new Promise<boolean>((resolve, reject) => {
    const timer = setTimeout(() => resolve(false), ms);
    child.exited.then(() => { clearTimeout(timer); resolve(true); }, error => { clearTimeout(timer); reject(error); });
  });
  let failure: unknown, timedOut = false;
  try { timedOut = !(await within(timeoutMs)); } catch (error) { failure = error; }
  if (child.exitCode === null && child.signalCode === null) {
    // Independent steps: a failed TERM or grace wait still falls through to KILL and the join.
    let stopped = false;
    try { child.kill("SIGTERM"); stopped = await within(graceMs); } catch (error) { failure ??= error; }
    if (!stopped) try { child.kill("SIGKILL"); } catch (error) { failure ??= error; }
    try { await child.exited; } catch (error) { failure ??= error; }
  }
  let stdout = "", stderr = "";
  try { [stdout, stderr] = await outputs; } catch (error) { failure ??= error; }
  const result = { exitCode: child.exitCode, signalCode: child.signalCode, timedOut, stdout, stderr };
  if (failure !== undefined) throw Object.assign(new Error(`child process failed: ${String(failure)} (${json({ ...result, stdout: undefined, stderr: undefined })})\n` +
    `--- child stdout ---\n${stdout}\n--- child stderr ---\n${stderr}`), { cause: failure, result });
  return result;
}

const inputs = optIn(Bun.env);

test.skipIf(!inputs || PHASE !== "parent")("Qwen MTP B2: retirement, committed row state and generated prefixes from RAM and a fresh process", async () => {
  const directory = mkdtempSync(join(tmpdir(), "qwen-mtp-group-prefix-"));
  try {
    const { records, prompts, geometry, vocab } = await record(inputs!, directory, "parent");
    writeFileSync(join(directory, "expected.json"), json(Object.fromEntries(CASES.filter(c => c.continued).map(c => [c.name, { snapshots: records[c.name].snapshots }]))));
    // The parent has released its model and weights; the child loads its own.
    const child = await runBounded([process.execPath, "--no-env-file", "test", import.meta.path, "--test-name-pattern", "fresh-process SSD continuation"],
      { ...Bun.env, MLX_BUN_TEST_MTP_PHASE: "child", MLX_BUN_TEST_MTP_DIR: directory }, CHILD_DEADLINE_MS);
    const restoreFile = join(directory, "restore.json");
    const ok = child.exitCode === 0 && !child.timedOut && existsSync(restoreFile);
    assert(ok, `fresh-process phase failed (exit ${child.exitCode}, signal ${child.signalCode}, timed out ${child.timedOut})\n` +
      `--- child stdout ---\n${child.stdout}\n--- child stderr ---\n${child.stderr}`);
    // The child's own test report, once, so a supervisor can require its named test to pass.
    process.stdout.write(`--- fresh-process child stdout ---\n${child.stdout}\n--- end fresh-process child stdout ---\n`);
    process.stderr.write(`--- fresh-process child stderr ---\n${child.stderr}\n--- end fresh-process child stderr ---\n`);
    const restored = JSON.parse(readFileSync(restoreFile, "utf8"));
    const found = problems(fail => { for (const c of CASES) checkCase(c, records[c.name], c.continued ? restored[c.name] ?? null : undefined, prompts, vocab, geometry, fail); });
    expect(found).toEqual([]);
    const summary = CASES.map(c => {
      const g = records[c.name].generation, rounds = g.events.filter((e: A) => e.event === "commit");
      return { case: c.name, tokens: g.tokens.map((t: number[]) => t.length), rounds: rounds.length, twoRowRounds: rounds.filter((e: A) => e.accepted.length === 2).length,
        generatedPuts: puts(g, "generated").map((p: A) => [p.row, p.ids.length]), promptPuts: puts(g, "prompt").length };
    });
    console.log(json({ status: "pass", scope: "B2 depth 2 plain KV; within-tree contract; main parity is external", prompts: prompts.map(p => p.length), summary }));
  } finally { rmSync(directory, { recursive: true, force: true }); }
}, 1_800_000);

test.skipIf(!inputs || PHASE !== "child")("Qwen MTP B2 fresh-process SSD continuation (child phase)", async () => {
  const { records } = await record(inputs!, CHILD_DIR!, "child");
  writeFileSync(join(CHILD_DIR!, "restore.json"), json(records));
}, CHILD_DEADLINE_MS - 60_000);

// ---- CPU-only validation (synthetic records; no native libraries) ------------------------
const V = 248320;
const GEOMETRY = geometryFor({ num_hidden_layers: 8, num_key_value_heads: 4, head_dim: 256, linear_num_key_heads: 16, linear_key_head_dim: 128,
  linear_num_value_heads: 48, linear_value_head_dim: 128, linear_conv_kernel_dim: 4,
  layer_types: Array.from({ length: 8 }, (_, i) => (i + 1) % 4 === 0 ? "full_attention" : "linear_attention") }, "bfloat16");
const P = [Array.from({ length: 32 }, (_, i) => 1000 + i), Array.from({ length: 25 }, (_, i) => 2000 + i)];
const clone = <T>(x: T): T => JSON.parse(JSON.stringify(x));
const fake = (key: string, shape: number[], dtype = "bfloat16") => ({ shape, dtype, sha256: sha256(key) });
/** A round's entry for one member: `a` (a verified burst of a accepted drafts
 * plus its correction, all delivered and retained) or an explicit truncation:
 * `v` verified drafts, `deliver` burst tokens delivered, `retain` drafts kept. */
type Member = number | { v: number; deliver: number; retain: number };
/** A submission as observed on real weights: request 0 prefills, joins and runs
 * `pre` rounds alone; request 1 then joins, and its entry state repeats request
 * 0's last committed row (with no `pre` rounds, both joins precede one entry).
 * Each round is its verify forward and projection, its draft, the deliveries
 * (a prefix of the verified burst), then its commit of the retained drafts. */
function synthetic(key: string, prompts: number[][], pre: Member[][], twoRow: Member[][], oneRow: Member[][], publish: boolean[], name = "g-stop") {
  const offsets = prompts.map(p => p.length), tokens: number[][] = [[], []], events: A[] = [], lastRows = new Map<number, A>();
  let members: number[] = [], last: A = null, entryDue = false, round = 0;
  const layers = (tag: string, offset: number) => GEOMETRY.layers.map((kind, i) => kind === "kv"
    ? { signature: "kv:plain", offset, arrays: ["k", "v"].map(p => fake(`${tag}:${i}:${p}:${offset}`, [1, 4, offset, 256])) }
    : { signature: "ssm", offset, arrays: [fake(`${tag}:${i}:c:${offset}`, GEOMETRY.conv.shape), fake(`${tag}:${i}:r:${offset}`, GEOMETRY.recurrent.shape, "float32")] });
  const emit = (q: number, token = 10_000 * (q + 1) + tokens[q]!.length) => { tokens[q]!.push(token); events.push({ event: "token", row: q, token, index: tokens[q]!.length, activeRows: members.length }); };
  const prefill = (q: number) => {
    if (key.startsWith("gen")) events.push({ event: "put", row: q, kind: "prompt", ids: prompts[q]!.slice(0, -1), sessionId: `${name}-${q}`, digest: {} });
    emit(q);
    events.push({ event: "join", requests: [q], processed: [offsets[q]] });
    members.push(q); entryDue = true;
  };
  const put = (q: number) => {
    const k = last.state.rows.findIndex((r: A) => r.request === q), row = last.state.rows[k], draft = last.commit.drafts[k];
    const ids = [...prompts[q]!, ...tokens[q]!].slice(0, offsets[q]);
    events.push({ event: "put", row: q, kind: "generated", ids, namespace: `ns-${q}`, sessionId: `${name}-${q}`, digest: { offsets: row.layers.map((l: A) => l.offset),
      attachments: [["qwen-mtp-v1", { draftOffset: ids.length - 1 }]], arrays: [...row.layers.flatMap((l: A) => l.arrays), ...draft.tensors] } });
  };
  const play = (entries: Member[]) => {
    const i = round++, pending = members.map(q => tokens[q]!.at(-1)!), proposals = members.map((_, r) => [300 + i, 400 + r]);
    const m = entries.map(x => typeof x === "number" ? { v: x, deliver: x + 1, retain: x } : x);
    const bursts = members.map((q, k) => [...proposals[k]!.slice(0, m[k]!.v), 10_000 * (q + 1) + 1_000 + i]);
    if (entryDue) {
      events.push({ event: "state", at: "entry", members: [...members], rows: members.map(q => lastRows.get(q) ? clone(lastRows.get(q)) : { request: q, layers: layers(`${key}:e${q}`, offsets[q]!) }) });
      entryDue = false;
    }
    events.push({ event: "forward", ids: pending.map((p, r) => [p, ...proposals[r]!]), verify: true, sameLayouts: true, hidden: fake(`${key}:h${i}`, [1]) });
    events.push({ event: "project", logits: { shape: [members.length, 3, V], sha256: sha256(`${key}:l${i}`), finite: true }, argmax: bursts.map(b => [...b, 7, 7].slice(0, 3)) });
    events.push({ event: "draft", pending, depth: 2, proposals });
    members.forEach((q, k) => { for (const token of bursts[k]!.slice(0, m[k]!.deliver)) emit(q, token); offsets[q]! += m[k]!.retain + 1; });
    const commit = { event: "commit", accepted: m.map(x => x.retain), drafts: members.map(q => ({ processedTokens: offsets[q], schema: "qwen-mtp-v1",
      metadata: { draftOffset: offsets[q]! - 1 }, tensors: [fake(`${key}:d${i}:${q}`, [1, 1, 5120])] })) };
    const state = { event: "state", at: "commit", members: [...members], rows: members.map(q => ({ request: q, layers: layers(`${key}:c${i}:${q}`, offsets[q]!) })) };
    events.push(commit, state);
    for (const r of state.rows) lastRows.set(r.request, r);
    last = { commit, state };
  };
  prefill(0);
  for (const a of pre) play(a);
  prefill(1);
  for (const a of twoRow) play(a);
  if (oneRow.length) { if (publish[0]) put(0); members = [1]; events.push({ event: "filter", keep: [1], members: [1] }); for (const a of oneRow) play(a); if (publish[1]) put(1); }
  else { if (publish[0]) put(0); if (publish[1]) put(1); }
  return { events, tokens };
}
const done = (reason: string, n: number, cached = 0) => ({ compared: { status: "fulfilled", generatedTokens: n, cachedTokens: cached, finishReason: reason, spec: {} } });
const rep = (n: number, a: Member[]) => Array.from({ length: n }, () => [...a]);
/** Request 0 alone for two rounds, then to `at` (its last round truncated) and request 1 to `budget`;
 * seeded: run 1's rounds, then request 1 accepting through its list, rejecting once, and two more two-row rounds.
 * Failed at 16 as on real weights: the consumer throws on its burst's third token, and none is retained. */
const ROUNDS: Record<string, Member[][][]> = {
  "g-stop": [[[2], [1]], [[2, 2], [2, 2], [0, 1], [0, 2]], rep(4, [2])],
  "g-cancel": [[[2], [1]], [[2, 2], [2, 2], [0, 1], [2, 2]], rep(4, [2])],
  "g-fail": [[[2], [1]], [[2, 2], [2, 2], [0, 1], [{ v: 2, deliver: 3, retain: 0 }, 2]], rep(4, [2])],
  "s-stop": [[[2], [1]], [[2, 2], [2, 2], [0, 2], [1, 2], ...rep(19, [2, 2]), [2, 0], [2, 2], [1, 2]], rep(17, [2])],
};
function fixture(c: Case, [pre, twoRow, oneRow] = ROUNDS[c.name]!) {
  const g: A = synthetic(`gen-${c.name}`, P, pre!, twoRow!, oneRow!, [c.action === "stop", true], c.name);
  g.outcomes = [c.action === "stop" ? done("stop", g.tokens[0].length)
    : { compared: { status: "rejected", reason: c.action === "cancel" ? "cancelled consumer" : "failed consumer" } }, done("length", g.tokens[1].length)];
  const rec: A = { prompts: P, generation: g, flush: { durable: true, pendingBytes: 0 } };
  if (!c.continued) return { rec, restore: undefined };
  const snap = (q: number) => g.events.find((e: A) => e.kind === "generated" && e.row === q);
  const takes = [0, 1].map(q => ({ tokens: snap(q).ids.length, digest: clone(snap(q).digest) }));
  const cont = () => { const s: A = synthetic(`cont-${c.name}`, P.map((p, q) => [...p, ...g.tokens[q], ...SUFFIX]), [], [[2, 2], [2, 1], [2, 2], [1, 2]], [], [true, true], c.name);
    s.outcomes = [0, 1].map(q => done("length", CONTINUATION, snap(q).ids.length)); return s; };
  rec.ram = [0, 1].map(() => ({ takeBefore: clone(takes), ...cont(), takeAfter: clone(takes) }));
  rec.continuationFlush = { durable: true, pendingBytes: 0 };
  return { rec, restore: { ssdUnchanged: true, scanned: 2, take: clone(takes), ...cont() } };
}
const STOP = CASES[0], SEEDED_STOP = CASES[3];
// Records are plain data, as the lane writes them: no shared references between a put and its state.
const check = (mutate: (f: A) => void = () => {}, c: Case = STOP) => { const f = clone(fixture(c)); mutate(f); return problems(fail => checkCase(c, f.rec, f.restore, P, V, GEOMETRY, fail)); };
const ev = (sub: A, kind: string) => sub.events.filter((e: A) => e.event === kind);
const twoRow = (sub: A, kind: string) => ev(sub, kind).filter((e: A) => (kind === "state" ? e.at === "commit" && e.rows?.length :
  kind === "commit" ? e.accepted?.length : e.verify && e.ids?.length) === 2);
const entries = (sub: A) => ev(sub, "state").filter((e: A) => e.at === "entry");

test("opt-in is all or nothing (CPU only)", () => {
  expect(optIn({})).toBeNull();
  expect(() => optIn({ [OPT_IN[0]]: "/t" })).toThrow("missing or blank");
  expect(() => optIn({ [OPT_IN[0]]: "/nonexistent-target", [OPT_IN[1]]: "/nonexistent-draft" })).toThrow("no config.json");
});

test("a complete, consistent B2 record passes the within-tree checks (CPU only)", () => {
  expect(check()).toEqual([]);
  expect(fixture(STOP).rec.generation.tokens.map((t: number[]) => t.length)).toEqual([14, 24]);
  expect(entries(fixture(STOP).rec.generation)).toHaveLength(2);
  expect(check(() => {}, SEEDED_STOP)).toEqual([]);
  expect(fixture(SEEDED_STOP).rec.generation.tokens.map((t: number[]) => t.length)).toEqual([80, 128]);
  expect(check(f => { f.rec.generation.tokens[1].pop(); }, SEEDED_STOP).join("\n")).toMatch(/request 1 emitted 127/);
});

test("missing or inconsistent observations fail (CPU only)", () => {
  const fails = (mutate: (f: A) => void, pattern: RegExp) => expect(check(mutate).join("\n")).toMatch(pattern);
  fails(f => { const s = f.rec.generation; s.events = s.events.filter((e: A) => !(e.event === "token" && e.activeRows === 1)); }, /callbacks/);
  fails(f => { const e = f.rec.generation.events, c = e.map((z: A) => z.event).lastIndexOf("commit"), d = e.map((z: A) => z.event).lastIndexOf("draft");
    f.rec.generation.events = [...e.slice(0, d), ...e.slice(d).filter((z: A, j: number) => !["draft", "forward", "project", "commit", "state"].includes(z.event) || d + j > c + 1)]; },
  /outside rounds|terminal|published/);
  fails(f => { for (const s of ev(f.rec.generation, "state")) for (const r of s.rows) r.layers = r.layers.filter((l: A) => l.signature !== "ssm"); }, /layers, expected 8/);
  fails(f => { twoRow(f.rec.generation, "state")[1].rows[0].layers[3].arrays.pop(); }, /malformed layer/);
  fails(f => { twoRow(f.rec.generation, "state")[0].rows[1].layers[0].arrays[1].dtype = "bfloat16"; }, /layer 0/);
  fails(f => { const s = f.rec.generation; s.events.splice(s.events.indexOf(twoRow(s, "state")[1]), 1); }, /committed state/);
  fails(f => { twoRow(f.rec.generation, "state")[1].error = "no verify forward in this round"; }, /no verify forward/);
  fails(f => { delete twoRow(f.rec.generation, "forward")[1].verify; }, /armed round/);
  fails(f => { twoRow(f.rec.generation, "forward")[1].ids[1][1] = 5; }, /verify forwards/);
  fails(f => { ev(f.rec.generation, "project")[0].logits.finite = false; }, /projection/);
  fails(f => { for (const e of f.rec.generation.events) { if (e.event === "filter") { e.keep = [0]; e.members = [0]; } if (e.event === "state" && e.at === "commit" && e.members.length === 1 && e.rows[0].request === 1) { e.members = [0]; e.rows[0].request = 0; } } },
    /membership|advanced|request 0/);
  fails(f => { twoRow(f.rec.generation, "commit")[1].drafts[0].processedTokens += 1; }, /draft processed/);
  fails(f => { f.rec.generation.events.find((e: A) => e.kind === "generated" && e.row === 0).digest.arrays[3].sha256 = sha256("x"); }, /published planes/);
  fails(f => { f.rec.generation.events.push({ ...clone(f.rec.generation.events.find((e: A) => e.kind === "generated" && e.row === 1)) }); }, /generated puts/);
  fails(f => { f.rec.generation.outcomes[0].compared.finishReason = "length"; }, /request 0 finishReason/);
  fails(f => { f.rec.ram[1].tokens[0][3] = 1; }, /RAM continuations differ|callbacks/);
  fails(f => { f.rec.ram[1].takeAfter[1].digest.arrays[0].sha256 = sha256("x"); }, /take after request 1/);
  fails(f => { f.restore.ssdUnchanged = false; }, /SSD directory changed/);
  fails(f => { ev(f.restore, "project")[2].logits.sha256 = sha256("x"); }, /SSD continuation differs/);
  fails(f => { delete f.rec.flush; }, /drain/);
  fails(f => { f.rec.error = "boom"; }, /error boom/);
});

test("rows join chronologically: an entry per join, existing rows unchanged, new rows at their processed offset (CPU only)", () => {
  const fails = (mutate: (f: A) => void, pattern: RegExp) => expect(check(mutate).join("\n")).toMatch(pattern);
  const g = (f: A) => f.rec.generation;
  fails(f => { const s = g(f), st = ev(s, "state").filter((e: A) => e.at === "commit")[3]; s.events.splice(s.events.indexOf(st) + 1, 0, { ...clone(st), at: "entry" }); },
    /entry state without a pending join/);
  fails(f => { const s = g(f), late = entries(s)[1]; s.events.splice(s.events.indexOf(late) + 1, 0, clone(late)); }, /entry state without a pending join/);
  fails(f => { entries(g(f))[1].rows[0].layers[5].arrays[1].sha256 = sha256("changed"); }, /existing row's state changed/);
  fails(f => { ev(g(f), "join")[1].processed = [26]; }, /joined at offset 25, processed 26/);
  fails(f => { const s = g(f); s.events.splice(s.events.indexOf(entries(s)[1]), 1); }, /round before the joined rows' entry/);
  fails(f => { const s = g(f), st = twoRow(s, "state")[1], c = s.events[s.events.indexOf(st) - 1], k = st.rows.findIndex((r: A) => r.request === 0);
    const o = st.rows[k].layers[3].offset - 4;
    for (const l of st.rows[k].layers) { l.offset = o; for (const a of l.arrays) if (a.shape.length === 4 && l.signature !== "ssm") a.shape[2] = o; }
    c.drafts[k].processedTokens = o; c.drafts[k].metadata.draftOffset = o - 1; }, /advanced -/);
});

test("checkpoints are attributed by their session, and their tokens validated separately (CPU only)", () => {
  const sessions = ["g-stop-0", "g-stop-1"];
  expect(attributePut(P[0]!.slice(0, -1), "g-stop-0", sessions, P)).toEqual({ row: 0, kind: "prompt" });
  expect(attributePut(P[1]!.slice(0, -1), "g-stop-1", sessions, P)).toEqual({ row: 1, kind: "prompt" });
  expect(attributePut([...P[0]!, 5, 6], "g-stop-0", sessions, P)).toEqual({ row: 0, kind: "generated" });
  expect(attributePut(P[0]!.slice(0, 20), "g-stop-1", sessions, P)).toEqual({ row: 1, kind: "prompt" });
  expect(attributePut(P[0]!.slice(0, -1), "other-0", sessions, P).row).toBe(-1);
  expect(attributePut(P[0]!.slice(0, -1), undefined, sessions, P).row).toBe(-1);
  const fails = (mutate: (f: A) => void, pattern: RegExp) => expect(check(mutate).join("\n")).toMatch(pattern);
  fails(f => { f.rec.generation.events.find((e: A) => e.kind === "prompt" && e.row === 1).ids[7] += 1; }, /not a prefix of request 1/);
  fails(f => { f.rec.generation.events.find((e: A) => e.kind === "prompt" && e.row === 1).ids = P[0]!.slice(0, 24); }, /not a prefix of request 1/);
  fails(f => { const p = f.rec.generation.events.find((e: A) => e.kind === "prompt" && e.row === 0); p.row = -1; p.sessionId = "other-0"; }, /unattributed put/);
  fails(f => { f.rec.generation.events.find((e: A) => e.kind === "prompt" && e.row === 0).sessionId = "g-stop-1"; }, /unattributed put/);
  fails(f => { f.rec.generation.events = f.rec.generation.events.filter((e: A) => e.kind !== "prompt"); }, /no prompt checkpoints/);
});

test("a run without rejections while both rows are active is not qualified (CPU only)", () => {
  // Request 0's only rejection is before request 1 joined; request 1 rejects in the final two-row round only.
  const f = fixture(STOP, [[[2], [1]], [[2, 2], [2, 1], [1, 2]], rep(5, [2])]);
  expect(problems(fail => checkCase(STOP, f.rec, f.restore, P, V, GEOMETRY, fail))).toEqual([expect.stringMatching(/not qualified: row 0/)]);
  // Run 1's seeded shape at the longer window: request 1 accepts every proposal while both rows are active.
  const s = fixture(SEEDED_STOP, [[[2], [1]], [[2, 2], [2, 2], [0, 2], [1, 2], ...rep(21, [2, 2]), [1, 2]], [...rep(16, [2]), [0]]]);
  expect(problems(fail => checkCase(SEEDED_STOP, s.rec, s.restore, P, V, GEOMETRY, fail))).toEqual([expect.stringMatching(/not qualified: row 1/)]);
});

test("callbacks are accounted round by round; a consumer failure inside a burst retains none, and extra deliveries fail (CPU only)", () => {
  const FAIL = CASES[2], CANCEL = CASES[1];
  const roundAt = (s: A, commit: A) => {
    const i = s.events.indexOf(commit), back = (kind: string) => { let j = i; while (s.events[j].event !== kind) j--; return s.events[j]; };
    return { project: back("project"), draft: back("draft"), tokens: s.events.slice(s.events.indexOf(back("draft")), i).filter((e: A) => e.event === "token") };
  };
  const lastTwo = (s: A) => twoRow(s, "commit").at(-1);
  // Run 3's g-fail: the consumer threw on the third token of a fully verified burst; the round retained no drafts.
  const g = fixture(FAIL).rec.generation, r = roundAt(g, lastTwo(g));
  expect([lastTwo(g).accepted[0], r.tokens.filter((e: A) => e.row === 0).length, g.tokens[0].length]).toEqual([0, 3, 16]);
  expect(check(() => {}, FAIL)).toEqual([]);
  expect(check(() => {}, CANCEL)).toEqual([]);
  // An abort inside a burst's second callback: the next publish throws, and none is retained.
  const cutShort = fixture(CANCEL, [[[2], [1]], [[2, 2], [2, 2], [1, 1], [{ v: 2, deliver: 2, retain: 0 }, 2]], rep(4, [2])]);
  expect(problems(fail => checkCase(CANCEL, cutShort.rec, undefined, P, V, GEOMETRY, fail))).toEqual([]);
  // An abort in the burst's last callback publishes nothing more: the round keeps its drafts.
  const wholeBurst = fixture(CANCEL, [[[2], [1]], [[2, 2], [2, 2], [0, 1], [{ v: 2, deliver: 3, retain: 0 }, 2]], rep(4, [2])]);
  expect(problems(fail => checkCase(CANCEL, wholeBurst.rec, undefined, P, V, GEOMETRY, fail)).join("\n")).toMatch(/final round delivered .*\(cancelled\)/);
  const fails = (c: Case, mutate: (s: A) => void, pattern: RegExp) => expect(check(f => mutate(f.rec.generation), c).join("\n")).toMatch(pattern);
  fails(FAIL, s => { const x = roundAt(s, lastTwo(s)); x.project.argmax[0] = [x.draft.proposals[0][0], 5, 7]; }, /final round delivered .* the verified burst is .*\(failed\)/);
  fails(FAIL, s => { const t = roundAt(s, lastTwo(s)).tokens.filter((e: A) => e.row === 0).at(-1);
    s.events.splice(s.events.indexOf(t) + 1, 0, { ...t, token: 99, index: t.index + 1 }); s.tokens[0].push(99); }, /final round delivered .*\(failed\)/);
  fails(FAIL, s => { lastTwo(s).accepted[0] = 2; }, /\(failed\)/);
  fails(CANCEL, s => { const x = roundAt(s, lastTwo(s)); x.project.argmax[0] = [x.draft.proposals[0][0], 5, 7]; }, /final round delivered .*\(cancelled\)/);
  fails(STOP, s => { roundAt(s, twoRow(s, "commit")[1]).project.argmax[1] = [5, 6, 7]; }, /continued past a round it delivered/);
  // A wrong interior (draft) token, replaced in the callback and the returned tokens: counts, callback equality and pending still agree.
  fails(FAIL, s => { const c = twoRow(s, "commit")[0], t = roundAt(s, c).tokens.filter((e: A) => e.row === 0)[0];
    expect(t.index < s.tokens[0].length && c.accepted[0] >= 1).toBe(true);
    t.token = 94; s.tokens[0][t.index - 1] = 94; }, /continued past a round it delivered \[94,.*the verified burst is/);
  fails(STOP, s => { const t = roundAt(s, twoRow(s, "commit")[0]).tokens.filter((e: A) => e.row === 1).at(-1);
    s.events.splice(s.events.indexOf(t) + 1, 0, { ...t, token: 98 }); }, /continued past a round it delivered/);
  fails(STOP, s => { const c = twoRow(s, "commit")[0], t = roundAt(s, c).tokens.find((e: A) => e.row === 1);
    s.events.splice(s.events.indexOf(c) + 2, 0, { ...t, token: 97 }); }, /tokens outside rounds/);
  fails(STOP, s => { const c = ev(s, "commit").at(-1), t = roundAt(s, c).tokens[0];
    s.events.splice(s.events.indexOf(t) + 1, 0, { ...t, row: 0, token: 96 }); }, /not a member of/);
  fails(STOP, s => { roundAt(s, twoRow(s, "commit")[2]).draft.pending[1] = 95; }, /pending 95 is not its last delivered token/);
  fails(SEEDED_STOP, s => { s.outcomes[0] = { compared: { status: "rejected", reason: "failed consumer" } }; lastTwo(s).accepted[0] = 0; },
    /request 0: its final round delivered/);
});

test("the fresh-process runner returns complete outputs and stops and joins a child past its deadline (CPU only)", async () => {
  const done = await runBounded(["/bin/sh", "-c", "echo out; echo err 1>&2; exit 3"], {}, 10_000);
  expect(done).toMatchObject({ exitCode: 3, signalCode: null, timedOut: false, stdout: "out\n", stderr: "err\n" });
  const long = await runBounded(["/bin/sh", "-c", "i=0; while [ $i -lt 2000 ]; do echo line $i; i=$((i+1)); done"], {}, 10_000);
  expect(long.stdout.split("\n").filter(Boolean)).toHaveLength(2000);
  let started = Date.now();
  const late = await runBounded(["/bin/sh", "-c", "echo started; exec sleep 30"], {}, 300, 5_000);
  expect(late).toMatchObject({ timedOut: true, signalCode: "SIGTERM", stdout: "started\n" });
  expect(Date.now() - started).toBeLessThan(5_000);
  started = Date.now();
  const stubborn = await runBounded(["/bin/sh", "-c", "trap '' TERM; echo started; while :; do sleep 0.05; done"], {}, 300, 200);
  expect(stubborn).toMatchObject({ timedOut: true, signalCode: "SIGKILL", stdout: "started\n" });
  expect(Date.now() - started).toBeLessThan(5_000);
});

test("timings are not compared; whitelisted counters are (CPU only)", () => {
  const a = fixture(STOP).rec.ram[0], b = clone(a);
  b.outcomes[0].diagnostic = { decodeMs: 1, spec: { phaseMs: { verify: 3 } } };
  expect(json(project(a))).toEqual(json(project(b)));
  b.outcomes[0].compared.spec.accepted = 99;
  expect(json(project(a))).not.toEqual(json(project(b)));
});
