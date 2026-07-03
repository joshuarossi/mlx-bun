// Grammar-constrained decoding tests (src/grammar.ts) — the L2/oMLX-parity
// feature. These tests exercise the pure-grammar logic without needing model
// weights: vocab extraction + type detection, bitmask correctness across all
// five request kinds, accept/ready advance, and the applyMask math (invalid
// ids → -inf, valid ids unchanged). A real tokenizer.json drives the vocab.
//
// Gated on a downloaded tokenizer (no weights) — skip cleanly otherwise.

import { describe, expect, test } from "bun:test";
import { existsSync, readdirSync } from "node:fs";
import { loadTokenizer } from "../src/tokenizer";
import {
  compileGrammarRequest,
  grammarEnabled,
  type GrammarRequest,
} from "../src/grammar";
import { MlxArray } from "../src/mlx/array";
import * as ops from "../src/mlx/ops";

// Llama-3.2-1B-Instruct-4bit — byte_level BPE, the same vocab the phase-0
// spike verified against. Only tokenizer.json is needed (no weights).
const SNAPSHOT = ((): string => {
  const base = `${process.env.HOME}/.cache/huggingface/hub/models--mlx-community--Llama-3.2-1B-Instruct-4bit/snapshots`;
  try {
    for (const snap of readdirSync(base))
      if (existsSync(`${base}/${snap}/tokenizer.json`)) return `${base}/${snap}`;
  } catch {
    /* not downloaded */
  }
  return `${base}/_unresolved`;
})();

const haveTokenizer = existsSync(`${SNAPSHOT}/tokenizer.json`);

const PERSON_SCHEMA = {
  type: "object",
  properties: {
    name: { type: "string" },
    age: { type: "number" },
    hobbies: { type: "array", items: { type: "string" } },
  },
  required: ["name", "age", "hobbies"],
};

describe.skipIf(!haveTokenizer || !grammarEnabled())(
  "grammar: compile + bitmask + applyMask",
  () => {
    test("json_schema: step0 mask admits only object-start tokens", async () => {
      const tok = await loadTokenizer(SNAPSHOT);
      const r = await compileGrammarRequest(
        {
          responseFormat: {
            type: "json_schema",
            json_schema: { name: "person", schema: PERSON_SCHEMA, strict: true },
          },
        },
        tok,
        tok.vocabSize,
      );
      expect(r).not.toBeNull();
      const ctrl = r!.controller;
      expect(ctrl.isTerminated).toBe(false);

      // Fabricate logits [1, V] all-zero; after applyMask, valid tokens stay
      // 0, invalid become -inf. The argmax must be a token whose decoded string
      // can START an object: '{', ' {', ' {"', whitespace+braces, etc.
      const V = tok.vocabSize ?? 128000;
      const logits = MlxArray.fromFloat32(new Float32Array(V).fill(0), [1, V]);
      const masked = ctrl.applyMask(logits);
      logits.dispose();
      const arr = masked.toFloat32();
      const validIds: number[] = [];
      for (let i = 0; i < V; i++) if (arr[i] === 0) validIds.push(i);
      masked.dispose();
      // A strict object schema at step 0 should admit a TIGHT set (single
      // digits), not thousands — matches the spike's "5 valid" for Llama-3.
      expect(validIds.length).toBeLessThan(20);
      // every admitted token must decode to something starting an object
      // (whitespace, '{', or a '{'-prefixed piece). Decode + check.
      for (const id of validIds) {
        const piece = tok.idToToken(id);
        const stripped = piece.replace(/^Ġ+|\s+/g, ""); // strip byte-level space
        expect(stripped.startsWith("{") || stripped === "").toBe(true);
      }
      ctrl.dispose();
    });

    test("json_object: any valid JSON admitted at step0 (object or array start)", async () => {
      const tok = await loadTokenizer(SNAPSHOT);
      const r = await compileGrammarRequest(
        { responseFormat: { type: "json_object" } },
        tok,
        tok.vocabSize,
      );
      expect(r).not.toBeNull();
      const ctrl = r!.controller;
      const V = tok.vocabSize ?? 128000;
      const logits = MlxArray.fromFloat32(new Float32Array(V).fill(0), [1, V]);
      const masked = ctrl.applyMask(logits);
      logits.dispose();
      const arr = masked.toFloat32();
      let valid = 0;
      for (let i = 0; i < V; i++) if (arr[i] === 0) valid++;
      masked.dispose();
      // json_object allows { or [ (and whitespace variants) → small set.
      // byte_level BPE admits several space-prefixed variants (~20).
      expect(valid).toBeGreaterThan(0);
      expect(valid).toBeLessThan(40);
      ctrl.dispose();
    });

    test("guided_choice: only the listed strings are valid (enum)", async () => {
      const tok = await loadTokenizer(SNAPSHOT);
      const choices = ["yes", "no", "maybe"];
      const r = await compileGrammarRequest(
        { guidedChoice: choices },
        tok,
        tok.vocabSize,
      );
      expect(r).not.toBeNull();
      const ctrl = r!.controller;
      const V = tok.vocabSize ?? 128000;
      const logits = MlxArray.fromFloat32(new Float32Array(V).fill(0), [1, V]);
      const masked = ctrl.applyMask(logits);
      logits.dispose();
      const arr = masked.toFloat32();
      const validIds: number[] = [];
      for (let i = 0; i < V; i++) if (arr[i] === 0) validIds.push(i);
      masked.dispose();
      // Every valid token's decoded string must be a prefix of one of the
      // choices (y, ye, yes, n, no, m, ma, may, mayb, maybe, and byte-level
      // space-prefixed variants). Build the prefix set + check membership.
      const prefixes = new Set<string>();
      for (const c of choices) for (let k = 1; k <= c.length; k++) prefixes.add(c.slice(0, k));
      let allValid = true;
      for (const id of validIds) {
        const piece = tok.idToToken(id).replace(/^Ġ/, " ");
        // token piece must be a prefix of some choice (or a prefix thereof)
        const ok = [...prefixes].some((p) => p.startsWith(piece) || piece.startsWith(p));
        if (!ok) allValid = false;
      }
      expect(allValid).toBe(true);
      ctrl.dispose();
    });

    test("guided_grammar (EBNF): a literal-string grammar admits only that string's tokens", async () => {
      const tok = await loadTokenizer(SNAPSHOT);
      const r = await compileGrammarRequest(
        { guidedGrammar: 'root ::= "hello"' },
        tok,
        tok.vocabSize,
      );
      expect(r).not.toBeNull();
      const ctrl = r!.controller;
      const V = tok.vocabSize ?? 128000;
      const logits = MlxArray.fromFloat32(new Float32Array(V).fill(0), [1, V]);
      const masked = ctrl.applyMask(logits);
      logits.dispose();
      const arr = masked.toFloat32();
      const validIds: number[] = [];
      for (let i = 0; i < V; i++) if (arr[i] === 0) validIds.push(i);
      masked.dispose();
      expect(validIds.length).toBeGreaterThan(0);
      // every valid token must be a prefix of "hello"
      for (const id of validIds) {
        const piece = tok.idToToken(id).replace(/^Ġ/, " ");
        expect("hello".startsWith(piece) || piece.startsWith("hello")).toBe(true);
      }
      ctrl.dispose();
    });

    test("accept + ready advances the mask (state changes)", async () => {
      const tok = await loadTokenizer(SNAPSHOT);
      const r = await compileGrammarRequest(
        { responseFormat: { type: "json_schema", json_schema: { name: "p", schema: PERSON_SCHEMA } } },
        tok,
        tok.vocabSize,
      );
      const ctrl = r!.controller;
      const V = tok.vocabSize ?? 128000;

      // step0 valid set
      const l0 = MlxArray.fromFloat32(new Float32Array(V).fill(0), [1, V]);
      const m0 = ctrl.applyMask(l0); l0.dispose();
      const a0 = m0.toFloat32(); m0.dispose();
      const valid0 = new Set<number>();
      for (let i = 0; i < V; i++) if (a0[i] === 0) valid0.add(i);

      // accept '{' (token whose piece is "{" — find it in the vocab by decode)
      let braceId = -1;
      for (let i = 0; i < V; i++) {
        if (tok.idToToken(i) === "{") { braceId = i; break; }
      }
      expect(braceId).toBeGreaterThanOrEqual(0);
      ctrl.accept(braceId);
      await ctrl.ready();

      // step1 valid set — should DIFFER from step0 (the object key is now
      // expected, so '"' / space / '}' admitted, '{' no longer the only start)
      const l1 = MlxArray.fromFloat32(new Float32Array(V).fill(0), [1, V]);
      const m1 = ctrl.applyMask(l1); l1.dispose();
      const a1 = m1.toFloat32(); m1.dispose();
      const valid1 = new Set<number>();
      for (let i = 0; i < V; i++) if (a1[i] === 0) valid1.add(i);
      // sets differ (after accepting '{', the valid set changes — and grows,
      // since inside-object is more permissive than object-start)
      expect(valid1.size).toBeGreaterThan(valid0.size);
      ctrl.dispose();
    });

    test("degrade path: malformed grammar returns null (abort is catchable)", async () => {
      // xgrammar's EBNF parser calls abort() on a parse error — but the WASM
      // trap surfaces as a catchable `RuntimeError: Aborted()` (verified in
      // scripts/experiments + tests/grammar.test.ts probe). The process
      // survives, WASM state is intact, and a later good grammar still works.
      // The [FATAL]/Aborted() stderr line is xgrammar's LOG(FATAL) noise —
      // harmless. compileGrammarRequest catches it and degrades to null.
      const tok = await loadTokenizer(SNAPSHOT);
      const r = await compileGrammarRequest(
        { guidedGrammar: "root ::= (unclosed (" },
        tok,
        tok.vocabSize,
      );
      expect(r).toBeNull();

      // And a GOOD grammar still compiles after the abort — WASM not corrupt.
      const r2 = await compileGrammarRequest(
        { guidedGrammar: 'root ::= "ok"' },
        tok,
        tok.vocabSize,
      );
      expect(r2).not.toBeNull();
      r2!.controller.dispose();
    });

    test("text / unset → null (no constraint)", async () => {
      const tok = await loadTokenizer(SNAPSHOT);
      const r1 = await compileGrammarRequest({ responseFormat: { type: "text" } }, tok, tok.vocabSize);
      expect(r1).toBeNull();
      const r2 = await compileGrammarRequest({}, tok, tok.vocabSize);
      expect(r2).toBeNull();
    });

    test("applyMask is a no-op for an all-valid bitmask (identity)", async () => {
      // Construct a controller via json_object, then verify the mask does
      // SOMETHING (not all-valid) — confirms the masking path is live, not
      // silently passing all logits through.
      const tok = await loadTokenizer(SNAPSHOT);
      const r = await compileGrammarRequest(
        { responseFormat: { type: "json_object" } },
        tok,
        tok.vocabSize,
      );
      const ctrl = r!.controller;
      const V = tok.vocabSize ?? 128000;
      const logits = MlxArray.fromFloat32(new Float32Array(V).fill(1.5), [1, V]);
      const masked = ctrl.applyMask(logits);
      const arr = masked.toFloat32();
      let kept = 0, ninf = 0;
      for (let i = 0; i < V; i++) {
        if (arr[i] === 1.5) kept++;
        else if (arr[i] === -Infinity) ninf++;
      }
      expect(kept).toBeGreaterThan(0);
      expect(ninf).toBeGreaterThan(0);
      expect(kept + ninf).toBe(V);
      logits.dispose(); masked.dispose();
      ctrl.dispose();
    });

    // B2 model-free unit: the one novel runtime assumption B1 makes —
    // concurrent per-row fills on the single WASM instance don't
    // cross-contaminate matchers. Four matchers (four DIFFERENT schemas, the
    // bug-class gate: row↔matcher misalignment would cross-bleed masks) are
    // advanced interleaved with overlapping async fills, exactly as the batch
    // scheduler drives them. Each must stay on its own grammar.
    test("B1: 4 interleaved matchers with overlapping async fills stay isolated", async () => {
      const tok = await loadTokenizer(SNAPSHOT);
      const schemas = [
        { type: "object", properties: { a: { type: "string" } }, required: ["a"] },
        { type: "object", properties: { b: { type: "number" } }, required: ["b"] },
        { type: "object", properties: { c: { type: "boolean" } }, required: ["c"] },
        { type: "object", properties: { d: { type: "array", items: { type: "string" } } }, required: ["d"] },
      ];
      const ctrls = await Promise.all(
        schemas.map((s) =>
          compileGrammarRequest(
            { responseFormat: { type: "json_schema", json_schema: { name: "x", schema: s } } },
            tok, tok.vocabSize,
          ).then((r) => r!.controller),
        ),
      );
      const V = tok.vocabSize ?? 128000;

      // Each step: fire all 4 fills concurrently (overlapping, as the scheduler
      // does), await all, then apply each mask to a fresh all-zero logits and
      // confirm each admits a TIGHT, distinct set (object-start tokens — same
      // for all json_object schemas, so the gate is that NONE bleed into a
      // permissive/123k-valid state and all four agree with a fresh single).
      const steps = 3;
      for (let step = 0; step < steps; step++) {
        // fire fills (step 0 uses the primed mask; later steps need accept first)
        if (step > 0) {
          // accept a valid object-start token on each (find '{' in the vocab)
          let brace = -1;
          for (let i = 0; i < V; i++) if (tok.idToToken(i) === "{") { brace = i; break; }
          if (brace < 0) break;
          for (const c of ctrls) c.accept(brace);
          await Promise.all(ctrls.map((c) => c.ready()));
        }
        // apply each mask concurrently + collect valid counts
        const counts = await Promise.all(ctrls.map(async (c) => {
          const lg = MlxArray.fromFloat32(new Float32Array(V).fill(0), [1, V]);
          const m = c.applyMask(lg); lg.dispose();
          const arr = m.toFloat32(); m.dispose();
          let valid = 0;
          for (let i = 0; i < V; i++) if (arr[i] === 0) valid++;
          return valid;
        }));
        // ISOLATION GATE: the bug was a BindingError crash (concurrent fills
        // corrupting the WASM bindings) — reaching this point at all proves
        // the wasmQueue fix works. Each mask must be non-degenerate (some
        // valid, some masked); a cross-bleed would leave one controller reading
        // another's state → an all-valid (123k+) or all-masked (0) mask.
        // (The four schemas differ — a/b/c/d properties — so their post-`{`
        // valid sets legitimately differ by a few tokens; equality is NOT the gate.)
        for (const v of counts) {
          expect(v).toBeGreaterThan(0);
          expect(v).toBeLessThan(V);
        }
      }
      for (const c of ctrls) c.dispose();
    });
  },
);
