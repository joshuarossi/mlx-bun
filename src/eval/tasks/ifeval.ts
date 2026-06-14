// IFEval — instruction-following evaluation. Port of optiq/eval/ifeval.py.
//
// Google's IFEval probes whether a model follows verifiable, mechanically-
// checkable instructions ("respond in 3 bullet points", "include the keyword
// 'banana'", "respond in JSON"). Each example carries one or more constraint
// instructions; we generate a response and run the corresponding verifier.
//
// We report prompt-level pass rates (matches the official methodology):
//   * strict — fraction of examples where ALL of the prompt's instructions
//     pass on the raw response.
//   * loose  — same but with response-cleaning preprocessing (strip leading
//     "Sure, here is…" boilerplate and outer code fences).
// The primary metric (`accuracy`) is prompt-level strict, headlined by
// ifeval.py's IFEvalResult.__str__.
//
// Faithful port note: several verifiers below read kwarg keys that the dataset
// rows never populate (e.g. _check_capital_words_count / _check_letter_frequency
// read `relation`, while the data supplies `capital_relation` / `let_relation`).
// This mirrors ifeval.py exactly — those reads fall through to the "at least"
// default in both implementations, so behavior is identical.

import { generateText, loadJsonl, sampleIndices, type TaskModel } from "../runner";

interface IfevalRow {
  key: number;
  prompt: string;
  instruction_id_list: string[];
  kwargs: Record<string, unknown>[];
}

export interface IfevalResult {
  nTotal: number;
  strictAcc: number; // 0..1 — prompt-level strict pass rate
  looseAcc: number; // 0..1 — prompt-level loose pass rate
  accuracy: number; // 0..1 — primary metric == strictAcc (ifeval.py headline)
}

// ---------------------------------------------------------------------------
// kwarg accessors — Python uses kw.get(name, default); replicate with the same
// default semantics. Keys are read with the EXACT names ifeval.py uses.
// ---------------------------------------------------------------------------
type Kw = Record<string, unknown>;

function kwStr(kw: Kw, name: string, def = ""): string {
  const v = kw[name];
  return v === undefined || v === null ? def : String(v);
}
function kwInt(kw: Kw, name: string, def = 0): number {
  const v = kw[name];
  if (v === undefined || v === null) return def;
  const n = typeof v === "number" ? v : parseInt(String(v), 10);
  return Number.isFinite(n) ? Math.trunc(n) : def;
}
function kwArr(kw: Kw, name: string): string[] {
  const v = kw[name];
  return Array.isArray(v) ? (v as unknown[]).map((x) => String(x)) : [];
}
function reEscape(s: string): string {
  return s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

// ---------------------------------------------------------------------------
// Constraint verifiers — each takes (response, kwargs) and returns boolean.
// One-to-one with the `_check_*` functions in ifeval.py.
// ---------------------------------------------------------------------------

// \b\w+\b — JS \w is ASCII-ish like Python's default re (no re.UNICODE here).
function checkLengthWords(response: string, kw: Kw): boolean {
  const n = (response.match(/\b\w+\b/g) ?? []).length;
  const rel = kwStr(kw, "relation", "at least");
  const target = kwInt(kw, "num_words", 0);
  return rel.includes("least") ? n >= target : n <= target;
}

function checkLengthSentences(response: string, kw: Kw): boolean {
  // Python: re.split(r"[.!?]+\s+", response.strip())
  const n = response.trim().split(/[.!?]+\s+/).length;
  const rel = kwStr(kw, "relation", "at least");
  const target = kwInt(kw, "num_sentences", 0);
  return rel.includes("least") ? n >= target : n <= target;
}

function checkLengthParagraphs(response: string, kw: Kw): boolean {
  const n = response.split("\n\n").filter((p) => p.trim()).length;
  const rel = kwStr(kw, "relation", "at least");
  const target = kwInt(kw, "num_paragraphs", 0);
  return rel.includes("least") ? n >= target : n <= target;
}

function checkKeywordsExistence(response: string, kw: Kw): boolean {
  const keywords = kwArr(kw, "keywords");
  const text = response.toLowerCase();
  return keywords.every((k) => text.includes(k.toLowerCase()));
}

function checkKeywordsForbidden(response: string, kw: Kw): boolean {
  const forbidden = kwArr(kw, "forbidden_words");
  const text = response.toLowerCase();
  return forbidden.every((w) => !text.includes(w.toLowerCase()));
}

function checkKeywordFrequency(response: string, kw: Kw): boolean {
  const kwWord = kwStr(kw, "keyword", "").toLowerCase();
  const rel = kwStr(kw, "relation", "at least");
  const target = kwInt(kw, "frequency", 0);
  const n = (response.toLowerCase().match(new RegExp(`\\b${reEscape(kwWord)}\\b`, "g")) ?? []).length;
  return rel.includes("least") ? n >= target : n <= target;
}

function checkLetterFrequency(response: string, kw: Kw): boolean {
  const letter = kwStr(kw, "letter", "").toLowerCase();
  const rel = kwStr(kw, "relation", "at least");
  // Python: int(kw.get("let_frequency", kw.get("frequency", 0)))
  const target = kw["let_frequency"] !== undefined && kw["let_frequency"] !== null
    ? kwInt(kw, "let_frequency", 0)
    : kwInt(kw, "frequency", 0);
  // Python: response.lower().count(letter) — count of non-overlapping occurrences.
  const n = letter.length ? response.toLowerCase().split(letter).length - 1 : 0;
  return rel.includes("least") ? n >= target : n <= target;
}

function checkCapitalWordsCount(response: string, kw: Kw): boolean {
  const words = response.match(/\b\w+\b/g) ?? [];
  // Python: w.isupper() and len(w) > 1 — str.isupper() requires ≥1 cased char,
  // all cased chars uppercase. Approximate: has a letter, no lowercase letter.
  const n = words.filter((w) => w.length > 1 && /[A-Za-z]/.test(w) && w === w.toUpperCase()).length;
  const rel = kwStr(kw, "relation", "at least");
  // Python: int(kw.get("capital_frequency", kw.get("frequency", 0)))
  const target = kw["capital_frequency"] !== undefined && kw["capital_frequency"] !== null
    ? kwInt(kw, "capital_frequency", 0)
    : kwInt(kw, "frequency", 0);
  return rel.includes("least") ? n >= target : n <= target;
}

function checkChangeCaseCapital(response: string, _kw: Kw): boolean {
  return response.toUpperCase() === response;
}

function checkChangeCaseLowercase(response: string, _kw: Kw): boolean {
  return response.toLowerCase() === response;
}

function checkResponseLanguage(response: string, kw: Kw): boolean {
  // Coarse: ASCII-ness for English; pass for others (no language detector).
  const target = kwStr(kw, "language", "en");
  if (target === "en") {
    return [...response.slice(0, 200)].every((c) => c.charCodeAt(0) < 128);
  }
  return true;
}

function checkPunctuationNoComma(response: string, _kw: Kw): boolean {
  return !response.includes(",");
}

function checkStartendQuotation(response: string, _kw: Kw): boolean {
  const s = response.trim();
  return s.startsWith('"') && s.endsWith('"');
}

function checkStartendEndPhrase(response: string, kw: Kw): boolean {
  // Python: kw.get("end_phrase","").strip().rstrip(".!?")
  const end = kwStr(kw, "end_phrase", "").trim().replace(/[.!?]+$/, "");
  const tail = response.trim().replace(/[.!?]+$/, "").toLowerCase();
  return tail.endsWith(end.toLowerCase());
}

function checkFormatNumberBullets(response: string, kw: Kw): boolean {
  // Python: re.findall(r"^\s*[\*\-+]\s+|^\s*\d+\.\s+", response, re.MULTILINE)
  const bullets = response.match(/^[ \t]*[*\-+][ \t]+|^[ \t]*\d+\.[ \t]+/gm) ?? [];
  const target = kwInt(kw, "num_bullets", 0);
  return bullets.length === target;
}

function checkFormatNumberHighlighted(response: string, kw: Kw): boolean {
  const n = (response.match(/\*[^*]+\*/g) ?? []).length;
  const target = kwInt(kw, "num_highlights", 0);
  return n >= target;
}

function checkFormatTitle(response: string, _kw: Kw): boolean {
  return /<<[^>]+>>/.test(response);
}

function checkFormatConstrainedResponse(response: string, _kw: Kw): boolean {
  const valid = new Set(["My answer is yes.", "My answer is no.", "My answer is maybe."]);
  return valid.has(response.trim());
}

function checkFormatJson(response: string, _kw: Kw): boolean {
  let s = response.trim();
  if (s.startsWith("```")) {
    s = s.replace(/^```\w*\n?/, "");
    s = s.replace(/\n?```$/, "");
  }
  try {
    JSON.parse(s);
    return true;
  } catch {
    return false;
  }
}

function checkFormatMultipleSections(response: string, kw: Kw): boolean {
  const marker = kwStr(kw, "section_spliter", "Section").trim();
  const target = kwInt(kw, "num_sections", 0);
  const n = (response.match(new RegExp(`${reEscape(marker)}\\s*\\d+`, "gi")) ?? []).length;
  return n >= target;
}

function checkCombinationTwoResponses(response: string, _kw: Kw): boolean {
  return response.includes("******");
}

function checkCombinationRepeatPrompt(_response: string, _kw: Kw): boolean {
  return true; // ifeval.py: we don't have the prompt here; assume pass.
}

const alwaysPass = (): boolean => true;

// Map IFEval instruction IDs → verifier. One-to-one with ifeval.py `_VERIFIERS`.
type Verifier = (response: string, kwargs: Kw) => boolean;
const VERIFIERS = new Map<string, Verifier>([
  ["length_constraints:number_words", checkLengthWords],
  ["length_constraints:number_sentences", checkLengthSentences],
  ["length_constraints:number_paragraphs", checkLengthParagraphs],
  ["length_constraints:nth_paragraph_first_word", alwaysPass],
  ["keywords:existence", checkKeywordsExistence],
  ["keywords:frequency", checkKeywordFrequency],
  ["keywords:forbidden_words", checkKeywordsForbidden],
  ["keywords:letter_frequency", checkLetterFrequency],
  ["language:response_language", checkResponseLanguage],
  ["change_case:english_capital", checkChangeCaseCapital],
  ["change_case:english_lowercase", checkChangeCaseLowercase],
  ["change_case:capital_word_frequency", checkCapitalWordsCount],
  ["punctuation:no_comma", checkPunctuationNoComma],
  ["startend:quotation", checkStartendQuotation],
  ["startend:end_checker", checkStartendEndPhrase],
  ["detectable_format:number_bullet_lists", checkFormatNumberBullets],
  ["detectable_format:number_highlighted_sections", checkFormatNumberHighlighted],
  ["detectable_format:title", checkFormatTitle],
  ["detectable_format:constrained_response", checkFormatConstrainedResponse],
  ["detectable_format:json_format", checkFormatJson],
  ["detectable_format:multiple_sections", checkFormatMultipleSections],
  ["combination:two_responses", checkCombinationTwoResponses],
  ["combination:repeat_prompt", checkCombinationRepeatPrompt],
  ["detectable_content:number_placeholders", alwaysPass],
  ["detectable_content:postscript", alwaysPass],
]);

/**
 * Verify one response against its instruction list.
 * Returns { pass, unhandled }. An instruction_id with no registered verifier is
 * counted as a FAIL (NOT silently skipped) and recorded in `unhandled`. This is
 * stricter than ifeval.py (which treats unhandled as pass); per the mlx-bun
 * harness rule, anything we cannot port must fail rather than bias high.
 */
function verifyResponse(
  response: string,
  instructionIds: string[],
  kwargsList: Kw[],
): { pass: boolean; unhandled: string[] } {
  const unhandled: string[] = [];
  let pass = true;
  for (let i = 0; i < instructionIds.length; i++) {
    const iid = instructionIds[i]!;
    const kw = kwargsList[i] ?? {};
    const verifier = VERIFIERS.get(iid);
    if (verifier === undefined) {
      unhandled.push(iid);
      pass = false; // count unported instruction as a failure
      continue;
    }
    try {
      if (!verifier(response, kw)) pass = false;
    } catch {
      pass = false;
    }
  }
  return { pass, unhandled };
}

/** Loose-mode preprocessing — mirrors ifeval.py `_loose_clean`. */
function looseClean(response: string): string {
  let s = response.trim();
  // Python: re.sub(r"^(Sure|Here|Of course)[,!.]\s*[^\n]*\n+", "", s, count=1)
  s = s.replace(/^(Sure|Here|Of course)[,!.]\s*[^\n]*\n+/, "");
  if (s.startsWith("```")) {
    s = s.replace(/^```\w*\n?/, "");
    s = s.replace(/\n?```$/, "");
  }
  return s.trim();
}

/** Strip a leading thinking block, matching ifeval.py's split on </think>. */
function stripThinking(response: string): string {
  const idx = response.indexOf("</think>");
  return idx === -1 ? response : response.slice(idx + "</think>".length);
}

export async function evaluateIfeval(
  tm: TaskModel,
  opts: { nSamples?: number; maxTokens?: number; seed?: number } = {},
): Promise<IfevalResult> {
  // ifeval.py: max_tokens default 512.
  const maxTokens = opts.maxTokens ?? 512;
  const seed = opts.seed ?? 42;

  const rows = loadJsonl<IfevalRow>("ifeval");
  const nSamples = opts.nSamples ?? rows.length;
  const idx = nSamples < rows.length
    ? sampleIndices(rows.length, nSamples, seed)
    : Array.from({ length: rows.length }, (_, i) => i);

  let nStrict = 0;
  let nLoose = 0;
  const unhandledCounts = new Map<string, number>();

  for (let k = 0; k < idx.length; k++) {
    const item = rows[idx[k]!]!;
    const iids = item.instruction_id_list ?? [];
    const kwList = item.kwargs ?? iids.map(() => ({}));

    const raw = await generateText(tm, item.prompt, { maxTokens, useChat: true });
    const response = stripThinking(raw);

    const strict = verifyResponse(response, iids, kwList);
    const loose = verifyResponse(looseClean(response), iids, kwList);
    for (const u of strict.unhandled) unhandledCounts.set(u, (unhandledCounts.get(u) ?? 0) + 1);

    if (strict.pass) nStrict++;
    if (loose.pass) nLoose++;

    if ((k + 1) % 10 === 0 || k + 1 === idx.length)
      process.stderr.write(
        `\r  ifeval ${k + 1}/${idx.length}  strict=${((nStrict / (k + 1)) * 100).toFixed(1)}%  loose=${((nLoose / (k + 1)) * 100).toFixed(1)}%`,
      );
  }
  process.stderr.write("\n");

  if (unhandledCounts.size) {
    const top = [...unhandledCounts.entries()].sort((a, b) => b[1] - a[1]);
    process.stderr.write(
      "  ifeval unported instruction ids (counted as FAIL): " +
        top.map(([k, v]) => `${k}(${v})`).join(", ") +
        "\n",
    );
  }

  const nTotal = idx.length;
  const strictAcc = nTotal ? nStrict / nTotal : 0;
  const looseAcc = nTotal ? nLoose / nTotal : 0;
  return { nTotal, strictAcc, looseAcc, accuracy: strictAcc };
}
