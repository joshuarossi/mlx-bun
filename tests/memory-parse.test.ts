// Unit tests for the memory parse contracts (pure — no model needed).

import { describe, expect, test } from "bun:test";
import { parseBinary, parseLines } from "../src/memory/parse";

describe("parseBinary", () => {
  test("accepts a leading y/Y", () => {
    expect(parseBinary("Yes.")).toBe(true);
    expect(parseBinary("yes")).toBe(true);
    expect(parseBinary("  y")).toBe(true);
  });

  test("rejects anything not starting with y", () => {
    expect(parseBinary("no")).toBe(false);
    expect(parseBinary("maybe")).toBe(false);
    expect(parseBinary("")).toBe(false);
  });
});

describe("parseLines", () => {
  test("trims, drops empties and NONE sentinels", () => {
    expect(parseLines("A\n\nNONE\n B ")).toEqual(["A", "B"]);
  });

  test("NONE match is case-insensitive", () => {
    expect(parseLines("none\nKept\nNoNe")).toEqual(["Kept"]);
  });
});
