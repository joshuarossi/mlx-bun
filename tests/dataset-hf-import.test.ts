// Tests for the hf_dataset_import generator (a faithful port of optiq's
// `_gen_hf_dataset_import`, swapping the `datasets` library for the HF
// datasets-server REST API).
//
// FAST tier (default): unit-tests the pure row→example transform with synthetic
// datasets-server row envelopes — label filtering, min_chars, max_rows, and all
// three output formats. No network.
//
// LIVE tier (gated on MLX_BUN_TEST_NET=1): one tiny real fetch against a public
// dataset (stanfordnlp/imdb) to confirm rows come back end-to-end. Left gated so
// CI / no-network runs stay green.

import { describe, expect, test } from "bun:test";
import {
  applyHfRow,
  genHfDatasetImport,
  newHfTransformState,
  type HfImportOpts,
  type HfServerRow,
} from "../src/dataset/generators";

/** Build a datasets-server row envelope from a flat record. */
function env(row: Record<string, unknown>): HfServerRow {
  return { row_idx: 0, row };
}

/** Default opts; override per test. */
function opts(overrides: Partial<HfImportOpts> = {}): HfImportOpts {
  return {
    textColumn: "text",
    labelColumn: null,
    labelFilter: null,
    minChars: 0,
    maxRows: 0,
    outputFormat: "text",
    ...overrides,
  };
}

/** Drive the transform over a list of envelopes, return the final state. */
function run(rows: HfServerRow[], o: HfImportOpts) {
  const state = newHfTransformState();
  for (const r of rows) {
    if (!applyHfRow(r, o, state)) break; // max_rows cap hit
  }
  return state;
}

describe("applyHfRow — output formats", () => {
  const row = env({ text: "hello world" });

  test("text format → {text}", () => {
    const s = run([row], opts({ outputFormat: "text" }));
    expect(s.rows).toEqual([{ text: "hello world" }]);
  });

  test("messages_user_only → messages row with user turn", () => {
    const s = run([row], opts({ outputFormat: "messages_user_only" }));
    expect(s.rows).toEqual([{ messages: [{ role: "user", content: "hello world" }] }]);
  });

  test("prompt_completion → {prompt, completion:''}", () => {
    const s = run([row], opts({ outputFormat: "prompt_completion" }));
    expect(s.rows).toEqual([{ prompt: "hello world", completion: "" }]);
  });

  test("unknown format falls through to text (Python else branch)", () => {
    const s = run([row], opts({ outputFormat: "garbage" }));
    expect(s.rows).toEqual([{ text: "hello world" }]);
  });
});

describe("applyHfRow — text coercion + trimming", () => {
  test("strips surrounding whitespace", () => {
    const s = run([env({ text: "  padded  \n" })], opts());
    expect(s.rows).toEqual([{ text: "padded" }]);
  });

  test("non-string value is stringified (str() parity)", () => {
    const s = run([env({ text: 12345 })], opts({ minChars: 0 }));
    expect(s.rows).toEqual([{ text: "12345" }]);
  });

  test("falsy value (null/0/false) collapses to empty string", () => {
    // With min_chars 0 the empty string is still kept (matches optiq: only
    // `if min_chars and len < min_chars` drops; 0 disables the check).
    const sNull = run([env({ text: null })], opts());
    expect(sNull.rows).toEqual([{ text: "" }]);
    const sZero = run([env({ text: 0 })], opts());
    expect(sZero.rows).toEqual([{ text: "" }]);
  });

  test("missing text column collapses to empty string", () => {
    const s = run([env({ other: "x" })], opts());
    expect(s.rows).toEqual([{ text: "" }]);
  });
});

describe("applyHfRow — min_chars filter", () => {
  const rows = [
    env({ text: "short" }), // 5 chars
    env({ text: "a longer body of text" }), // 21 chars
  ];

  test("drops rows shorter than min_chars", () => {
    const s = run(rows, opts({ minChars: 10 }));
    expect(s.rows).toEqual([{ text: "a longer body of text" }]);
    expect(s.rejectedShort).toBe(1);
    expect(s.kept).toBe(1);
  });

  test("min_chars 0 disables the filter (keeps all, even empty)", () => {
    const s = run([env({ text: "" }), env({ text: "x" })], opts({ minChars: 0 }));
    expect(s.kept).toBe(2);
    expect(s.rejectedShort).toBe(0);
  });

  test("min_chars is applied to the TRIMMED length", () => {
    // "  hi  " trims to "hi" (2 chars) — dropped at min_chars 3.
    const s = run([env({ text: "  hi  " })], opts({ minChars: 3 }));
    expect(s.kept).toBe(0);
    expect(s.rejectedShort).toBe(1);
  });
});

describe("applyHfRow — label filter", () => {
  const rows = [
    env({ text: "keep me", kind: "human_written" }),
    env({ text: "drop me", kind: "machine_written" }),
    env({ text: "keep me too", kind: "human_written" }),
  ];

  test("keeps only rows where label_column == label_filter", () => {
    const s = run(rows, opts({ labelColumn: "kind", labelFilter: "human_written" }));
    expect(s.rows).toEqual([{ text: "keep me" }, { text: "keep me too" }]);
    expect(s.rejectedFilter).toBe(1);
    expect(s.kept).toBe(2);
  });

  test("label values are compared as strings (str() parity)", () => {
    // ClassLabel columns come back as integers; filter value is a string.
    const r = [env({ text: "positive review here", label: 1 }), env({ text: "negative one here", label: 0 })];
    const s = run(r, opts({ labelColumn: "label", labelFilter: "1" }));
    expect(s.rows).toEqual([{ text: "positive review here" }]);
    expect(s.rejectedFilter).toBe(1);
  });

  test("missing label column value compares as empty string", () => {
    const r = [env({ text: "no label field here" })];
    const s = run(r, opts({ labelColumn: "kind", labelFilter: "human_written" }));
    expect(s.kept).toBe(0);
    expect(s.rejectedFilter).toBe(1);
  });

  test("filter is a no-op unless BOTH column and value are set", () => {
    const sColOnly = run(rows, opts({ labelColumn: "kind", labelFilter: null }));
    expect(sColOnly.kept).toBe(3); // no filtering
    const sValOnly = run(rows, opts({ labelColumn: null, labelFilter: "human_written" }));
    expect(sValOnly.kept).toBe(3); // no filtering
  });

  test("min_chars is applied BEFORE the label filter (optiq order)", () => {
    // "no" (2 chars) is rejected_short, never reaching the label check.
    const r = [env({ text: "no", kind: "human_written" })];
    const s = run(r, opts({ minChars: 5, labelColumn: "kind", labelFilter: "human_written" }));
    expect(s.rejectedShort).toBe(1);
    expect(s.rejectedFilter).toBe(0);
  });
});

describe("applyHfRow — max_rows cap", () => {
  const rows = Array.from({ length: 5 }, (_, i) => env({ text: `row body number ${i}` }));

  test("caps kept rows at max_rows and signals stop", () => {
    const state = newHfTransformState();
    let stopped = false;
    for (const r of rows) {
      if (!applyHfRow(r, opts({ maxRows: 3 }), state)) {
        stopped = true;
        break;
      }
    }
    expect(stopped).toBe(true);
    expect(state.kept).toBe(3);
    expect(state.rows).toHaveLength(3);
  });

  test("max_rows 0 means no cap", () => {
    const s = run(rows, opts({ maxRows: 0 }));
    expect(s.kept).toBe(5);
  });

  test("rejected rows do NOT count toward the cap", () => {
    // 4 short rows interleaved; only the long ones count toward max_rows=2.
    const mixed = [
      env({ text: "x" }),
      env({ text: "first long body of text" }),
      env({ text: "y" }),
      env({ text: "second long body of text" }),
      env({ text: "third long body of text" }),
    ];
    const s = run(mixed, opts({ minChars: 5, maxRows: 2 }));
    expect(s.kept).toBe(2);
    expect(s.rows).toEqual([
      { text: "first long body of text" },
      { text: "second long body of text" },
    ]);
  });
});

describe("genHfDatasetImport — guards", () => {
  test("empty hf_id returns [] (no network)", async () => {
    const out = await genHfDatasetImport({ hf_id: "" });
    expect(out).toEqual([]);
  });

  test("missing hf_id returns [] (no network)", async () => {
    const out = await genHfDatasetImport({});
    expect(out).toEqual([]);
  });
});

// ---------------------------------------------------------------------------
// LIVE test — gated on MLX_BUN_TEST_NET=1. Hits a tiny public dataset.
// ---------------------------------------------------------------------------
const LIVE = process.env.MLX_BUN_TEST_NET === "1";
describe.if(LIVE)("genHfDatasetImport — live (network)", () => {
  test(
    "fetches rows from stanfordnlp/imdb test split",
    async () => {
      const out = await genHfDatasetImport({
        hf_id: "stanfordnlp/imdb",
        split: "test",
        text_column: "text",
        max_rows: 5,
        min_chars: 1,
        output_format: "text",
      });
      expect(out.length).toBeGreaterThan(0);
      expect(out.length).toBeLessThanOrEqual(5);
      for (const r of out) {
        expect(typeof (r as { text: unknown }).text).toBe("string");
        expect(((r as { text: string }).text).length).toBeGreaterThan(0);
      }
    },
    30_000,
  );
});
