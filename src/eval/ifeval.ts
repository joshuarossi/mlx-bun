// IFEval — programmatically-verifiable instruction-following scoring (Zhou et
// al. 2023, "Instruction-Following Evaluation for Large Language Models"). Each
// instance pairs a prompt with one or more *verifiable* instructions; a response
// is scored by deterministic checks (no LLM judge), so before/after ORPO
// comparisons are exact and reproducible.
//
// This implements the high-frequency instruction families (a working subset of
// the ~25 in the reference suite, extensible via INSTRUCTIONS). Strict scoring:
// an instance passes (strict) iff every instruction passes; we also report the
// per-instruction pass rate. The official metrics are prompt-level and
// instruction-level accuracy — both derived from `scoreInstance`.

export interface IFEvalInstance {
  /** The prompt text (used by instructions that reference it, e.g. "repeat the request"). */
  prompt: string;
  /** Instruction ids, e.g. "keywords:existence". */
  instruction_id_list: string[];
  /** Per-instruction kwargs, aligned with instruction_id_list. */
  kwargs: Array<Record<string, unknown>>;
}

export interface InstanceResult {
  /** One pass/fail per instruction (aligned with instruction_id_list). */
  perInstruction: boolean[];
  /** Strict: all instructions passed. */
  followedAll: boolean;
}

type Checker = (response: string, kw: Record<string, unknown>, inst: IFEvalInstance) => boolean;

const words = (s: string): string[] => s.trim().split(/\s+/).filter(Boolean);
const sentences = (s: string): string[] =>
  s.split(/(?<=[.!?])\s+/).map((x) => x.trim()).filter(Boolean);
const paragraphs = (s: string): string[] =>
  s.split(/\n\s*\n/).map((x) => x.trim()).filter(Boolean);
const norm = (s: string): string => s.toLowerCase();

const cmp = (n: number, rel: string | undefined, target: number): boolean => {
  switch (rel) {
    case "at least": return n >= target;
    case "at most": return n <= target;
    case "less than": return n < target;
    case "exactly": return n === target;
    default: return n >= target; // IFEval default for "around"/unspecified is lenient ≥
  }
};

/** The verifiable-instruction registry. Keyed by IFEval instruction_id. */
export const INSTRUCTIONS: Record<string, Checker> = {
  // ---- keywords ----
  "keywords:existence": (r, kw) =>
    (kw.keywords as string[]).every((k) => norm(r).includes(norm(k))),
  "keywords:frequency": (r, kw) => {
    const k = norm(kw.keyword as string);
    const count = norm(r).split(k).length - 1;
    return cmp(count, kw.relation as string, kw.frequency as number);
  },
  "keywords:forbidden_words": (r, kw) =>
    !(kw.forbidden_words as string[]).some((k) => norm(r).includes(norm(k))),

  // ---- length constraints ----
  "length_constraints:number_words": (r, kw) =>
    cmp(words(r).length, kw.relation as string, kw.num_words as number),
  "length_constraints:number_sentences": (r, kw) =>
    cmp(sentences(r).length, kw.relation as string, kw.num_sentences as number),
  "length_constraints:number_paragraphs": (r, kw) =>
    cmp(paragraphs(r).length, kw.relation as string, kw.num_paragraphs as number),

  // ---- detectable format ----
  "detectable_format:number_bullet_lists": (r, kw) => {
    const bullets = r.split("\n").filter((l) => /^\s*[*\-]\s+/.test(l)).length;
    return cmp(bullets, kw.relation as string, kw.num_bullets as number);
  },
  "detectable_format:number_highlighted_sections": (r, kw) => {
    const hi = (r.match(/\*[^*\n]+\*/g) ?? []).length;
    return cmp(hi, kw.relation as string, kw.num_highlights as number);
  },
  "detectable_format:title": (r) => /<<[^>\n]+>>/.test(r),
  "detectable_format:json_format": (r) => {
    const t = r.trim().replace(/^```(?:json)?\s*|\s*```$/g, "").trim();
    try { JSON.parse(t); return true; } catch { return false; }
  },

  // ---- case ----
  "change_case:english_lowercase": (r) => r === r.toLowerCase(),
  "change_case:english_capital": (r) => r === r.toUpperCase(),

  // ---- start / end ----
  "startend:end_checker": (r, kw) =>
    norm(r.trimEnd()).endsWith(norm((kw.end_phrase as string).trim())),
  "startend:quotation": (r) => {
    const t = r.trim();
    return t.startsWith('"') && t.endsWith('"') && t.length >= 2;
  },

  // ---- punctuation ----
  "punctuation:no_comma": (r) => !r.includes(","),
};

/** Score one IFEval instance (strict). Unknown instruction ids count as failed
 *  (so coverage gaps never inflate the score) — filter the dataset to the
 *  supported ids, or extend INSTRUCTIONS, to avoid that. */
export function scoreInstance(instance: IFEvalInstance, response: string): InstanceResult {
  const perInstruction = instance.instruction_id_list.map((id, i) => {
    const check = INSTRUCTIONS[id];
    if (!check) return false;
    try { return check(response, instance.kwargs[i] ?? {}, instance); } catch { return false; }
  });
  return { perInstruction, followedAll: perInstruction.every(Boolean) };
}

export interface IFEvalReport {
  n: number;
  /** Fraction of instances where ALL instructions were followed. */
  promptAccuracy: number;
  /** Fraction of individual instructions followed. */
  instructionAccuracy: number;
}

/** Aggregate the official prompt-level + instruction-level accuracies over a set
 *  of (instance, response) pairs. */
export function aggregate(pairs: Array<{ instance: IFEvalInstance; response: string }>): IFEvalReport {
  let prompts = 0, instrFollowed = 0, instrTotal = 0;
  for (const { instance, response } of pairs) {
    const r = scoreInstance(instance, response);
    if (r.followedAll) prompts++;
    instrFollowed += r.perInstruction.filter(Boolean).length;
    instrTotal += r.perInstruction.length;
  }
  return {
    n: pairs.length,
    promptAccuracy: pairs.length ? prompts / pairs.length : 0,
    instructionAccuracy: instrTotal ? instrFollowed / instrTotal : 0,
  };
}

/** Instruction ids this implementation supports (filter datasets to these). */
export const SUPPORTED_INSTRUCTIONS = new Set(Object.keys(INSTRUCTIONS));
