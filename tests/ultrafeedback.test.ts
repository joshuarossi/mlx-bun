// UltraFeedback (binarized) → preference-row transform. Pure logic, no dataset.

import { describe, expect, test } from "bun:test";
import { toPreferenceRow, curate, approxTokens } from "../src/eval/ultrafeedback";

const row = (prompt: unknown, chosen: unknown, rejected: unknown) => ({ prompt, chosen, rejected });
const msgs = (user: string, asst: string) => [
  { role: "user", content: user },
  { role: "assistant", content: asst },
];

describe("toPreferenceRow", () => {
  test("extracts prompt + last assistant turns", () => {
    const p = toPreferenceRow(row("Q?", msgs("Q?", "good"), msgs("Q?", "bad")));
    expect(p).toEqual({ prompt: "Q?", chosen: "good", rejected: "bad" });
  });
  test("drops rows missing fields", () => {
    expect(toPreferenceRow(row(123, msgs("q", "a"), msgs("q", "b")))).toBeNull();
    expect(toPreferenceRow(row("q", [], msgs("q", "b")))).toBeNull();
    expect(toPreferenceRow(row("q", msgs("q", "a"), "notalist"))).toBeNull();
  });
  test("drops rows with identical chosen/rejected (no signal)", () => {
    expect(toPreferenceRow(row("q", msgs("q", "same"), msgs("q", " same ")))).toBeNull();
  });
});

describe("curate + length filter", () => {
  test("keeps usable rows within the approx-token budget", () => {
    const good = row("short prompt", msgs("x", "a short chosen"), msgs("x", "a short rejected"));
    const tooLong = row("p", msgs("x", "z".repeat(20000)), msgs("x", "short"));
    const out = curate([good, tooLong, row(null, null, null)], 2048);
    expect(out.length).toBe(1);
    expect(out[0]!.prompt).toBe("short prompt");
  });
  test("approxTokens ~ chars/4", () => {
    expect(approxTokens("abcd")).toBe(1);
    expect(approxTokens("a".repeat(40))).toBe(10);
  });
});
