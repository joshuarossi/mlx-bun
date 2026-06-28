// The Dreaming — P9-T1 deterministic silent-violation detector.
//
// The cloud-judge correctness pass needs ANTHROPIC_API_KEY and is exercised by
// the RunJudge stage / a sub-agent, not here. This file covers the KEY-FREE half
// of judge-answer.ts: the regex that flags a broken silent contract (announcing
// the source — "per the wiki" / "according to your notes" — or greeting with
// "welcome back") and the 5 labeled self-test fixtures on that one dimension.
//
//   bun test tests/memory-judge-answer.test.ts

import { describe, expect, test } from "bun:test";
import {
  detectSilentViolation,
  gradeFixturesSilent,
  SELF_TEST_FIXTURES,
} from "../scripts/memory/judge-answer";

describe("detectSilentViolation — named tells flagged", () => {
  const violating: Array<[string, string]> = [
    ["per the wiki", "Per the wiki, the Sigma 150-600 is the long-reach pick."],
    ["according to your notes", "According to your notes, you chose the L-Mount body."],
    ["welcome back", "Welcome back! Here's what you settled on."],
    ["your notes say", "Your notes say the 75-300 is owned."],
    ["based on your notes", "Based on your notes, anamorphic is the use case."],
    ["recorded in the wiki", "As recorded in the wiki, M42 is adaptable."],
    ["from your records", "From your records, the body was acquired in 2024."],
    ["in your notes", "It's in your notes that the mount is L-Mount."],
  ];
  for (const [label, answer] of violating) {
    test(`flags "${label}"`, () => {
      expect(detectSilentViolation(answer).violation).toBe(true);
    });
  }
});

describe("detectSilentViolation — clean continuations pass", () => {
  const clean: string[] = [
    "Since you already shoot the 75-300, the Sigma 150-600 is the sane long-reach pick.",
    "You don't have a recorded position on astrophotography.",
    "The L-Mount body was chosen for its native lenses and adaptability.",
    // mentioning a note-taking topic without ANNOUNCING the source is fine
    "You noted the price felt steep, so you waited for a used copy.",
  ];
  for (const answer of clean) {
    test(`no violation: ${answer.slice(0, 32)}…`, () => {
      expect(detectSilentViolation(answer).violation).toBe(false);
    });
  }
});

describe("detectSilentViolation — returns the matched phrase", () => {
  test("phrase is non-null on a hit and null on a miss", () => {
    expect(detectSilentViolation("Per the wiki, yes.").phrase).not.toBeNull();
    expect(detectSilentViolation("Yes, the Sigma 150-600.").phrase).toBeNull();
  });
});

describe("self-test fixtures — silent dimension", () => {
  test("there are exactly 5 labeled fixtures", () => {
    expect(SELF_TEST_FIXTURES.length).toBe(5);
  });

  test("the regex reproduces every fixture's silentViolation label", () => {
    const { graded, matched } = gradeFixturesSilent();
    expect(graded).toBe(5);
    expect(matched).toBe(5);
  });
});
