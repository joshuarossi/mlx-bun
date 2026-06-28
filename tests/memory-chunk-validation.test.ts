// P5-T2 — SEGMENT anchor validation/repair (pure, no model).
//
// Locks the ported chunk-validation logic (and the chunk.ts prompt/format
// seams). The model-driven end-to-end path is exercised by
// scripts/memory/segment-smoke.ts against the real e4b chunk adapter.

import { describe, expect, it } from "bun:test";
import { validateChunks, ChunkValidationError } from "../src/memory/chunk-validation";
import { CHUNK_PROMPT, formatConversation } from "../src/memory/chunk";

const CONV = "cccccccc-0000-0000-0000-000000000000";
const M = [
  { uuid: "11111111-1111-1111-1111-111111111111" },
  { uuid: "22222222-2222-2222-2222-222222222222" },
  { uuid: "33333333-3333-3333-3333-333333333333" },
  { uuid: "44444444-4444-4444-4444-444444444444" },
];

describe("validateChunks", () => {
  it("passes exact, fully-covering anchors through unchanged", () => {
    const { chunks, repairs } = validateChunks(
      [
        { start_message_uuid: M[0]!.uuid, end_message_uuid: M[1]!.uuid, label: "a" },
        { start_message_uuid: M[2]!.uuid, end_message_uuid: M[3]!.uuid, label: "b" },
      ],
      M,
      CONV,
    );
    expect(repairs).toHaveLength(0);
    expect(chunks).toEqual([
      { start_message_uuid: M[0]!.uuid, end_message_uuid: M[1]!.uuid, label: "a" },
      { start_message_uuid: M[2]!.uuid, end_message_uuid: M[3]!.uuid, label: "b" },
    ]);
  });

  it("snaps a conversation-uuid anchor to first/last message", () => {
    const { chunks, repairs } = validateChunks(
      [{ start_message_uuid: CONV, end_message_uuid: CONV, label: "whole" }],
      M,
      CONV,
    );
    expect(chunks[0]!.start_message_uuid).toBe(M[0]!.uuid);
    expect(chunks[0]!.end_message_uuid).toBe(M[3]!.uuid);
    expect(repairs.length).toBe(2);
  });

  it("prefix-matches a chimera-spliced anchor (≥8 shared hex)", () => {
    // start anchor keeps M[2]'s leading group then diverges → unique prefix match.
    const chimera = "33333333-9999-0000-0000-000000000000";
    const { chunks, repairs } = validateChunks(
      [{ start_message_uuid: chimera, end_message_uuid: M[3]!.uuid, label: "b" }],
      M,
      CONV,
    );
    expect(chunks[0]!.start_message_uuid).toBe(M[2]!.uuid);
    expect(repairs.some((r) => r.includes("prefix-matched"))).toBe(true);
  });

  it("swaps an inverted range", () => {
    const { chunks, repairs } = validateChunks(
      [{ start_message_uuid: M[3]!.uuid, end_message_uuid: M[1]!.uuid, label: "c" }],
      M,
      CONV,
    );
    expect(chunks[0]!.start_message_uuid).toBe(M[1]!.uuid);
    expect(chunks[0]!.end_message_uuid).toBe(M[3]!.uuid);
    expect(repairs.some((r) => r.includes("swapped"))).toBe(true);
  });

  it("extends a trailing coverage gap to the last message", () => {
    const { chunks, repairs } = validateChunks(
      [{ start_message_uuid: M[0]!.uuid, end_message_uuid: M[1]!.uuid, label: "d" }],
      M,
      CONV,
    );
    expect(chunks[0]!.end_message_uuid).toBe(M[3]!.uuid);
    expect(repairs.some((r) => r.includes("trailing gap"))).toBe(true);
  });

  it("throws on an unresolvable anchor (retried next run)", () => {
    expect(() =>
      validateChunks(
        [{ start_message_uuid: "deadbeef-aaaa-bbbb-cccc-dddddddddddd", end_message_uuid: M[1]!.uuid, label: "e" }],
        M,
        CONV,
      ),
    ).toThrow(ChunkValidationError);
  });

  it("respects an empty chunk list", () => {
    expect(validateChunks([], M, CONV)).toEqual({ chunks: [], repairs: [] });
  });
});

describe("chunk prompt + format seams", () => {
  it("CHUNK_PROMPT carries the {{META_DOCS}} inline slot and JSON schema", () => {
    expect(CHUNK_PROMPT).toContain("{{META_DOCS}}");
    expect(CHUNK_PROMPT).toContain("start_message_uuid");
    expect(CHUNK_PROMPT).toContain('{"chunks":');
  });

  it("formatConversation renders [role] (uuid: …) text blocks", () => {
    const out = formatConversation("Lens chat", CONV, [
      { position: 0, role: "human", uuid: M[0]!.uuid, text: "hi" },
      { position: 1, role: "assistant", uuid: M[1]!.uuid, text: "hello" },
    ]);
    expect(out).toContain(`Conversation: Lens chat (uuid: ${CONV})`);
    expect(out).toContain(`[human] (uuid: ${M[0]!.uuid})`);
    expect(out).toContain(`[assistant] (uuid: ${M[1]!.uuid})`);
    expect(out).toContain("\n---\n");
  });
});
