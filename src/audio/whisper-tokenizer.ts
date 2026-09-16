// Whisper tokenizer — mlx-whisper's tokenizer.py semantics over the stock
// HF tokenizer.json (openai/whisper-large-v3-turbo ships the multilingual
// tiktoken vocab in HF form; ids are identical, checked in
// tests/unit/whisper-tokenizer.test.ts against the oracle constants).
//
// Special-token layout (multilingual v3, n_vocab 51866): 50256 BPE ranks +
// "<|endoftext|>"(50257) "<|startoftranscript|>"(50258) + 100 language
// tokens + "<|translate|>" "<|transcribe|>" "<|startoflm|>" "<|startofprev|>"
// "<|nospeech|>" "<|notimestamps|>" + 1501 timestamp tokens "<|0.00|>" …
// "<|30.00|>". The mlx-community/whisper-* repos ship no tokenizer, so the
// loader resolves the openai/whisper-* tokenizer files (see
// resolveWhisperTokenizerDir).

import { existsSync, readdirSync } from "node:fs";
import { loadTokenizer, type LoadedTokenizer } from "../tokenizer";

export const WHISPER_LANGUAGES: Record<string, string> = {
  en: "english", zh: "chinese", de: "german", es: "spanish", ru: "russian", ko: "korean",
  fr: "french", ja: "japanese", pt: "portuguese", tr: "turkish", pl: "polish", ca: "catalan",
  nl: "dutch", ar: "arabic", sv: "swedish", it: "italian", id: "indonesian", hi: "hindi",
  fi: "finnish", vi: "vietnamese", he: "hebrew", uk: "ukrainian", el: "greek", ms: "malay",
  cs: "czech", ro: "romanian", da: "danish", hu: "hungarian", ta: "tamil", no: "norwegian",
  th: "thai", ur: "urdu", hr: "croatian", bg: "bulgarian", lt: "lithuanian", la: "latin",
  mi: "maori", ml: "malayalam", cy: "welsh", sk: "slovak", te: "telugu", fa: "persian",
  lv: "latvian", bn: "bengali", sr: "serbian", az: "azerbaijani", sl: "slovenian", kn: "kannada",
  et: "estonian", mk: "macedonian", br: "breton", eu: "basque", is: "icelandic", hy: "armenian",
  ne: "nepali", mn: "mongolian", bs: "bosnian", kk: "kazakh", sq: "albanian", sw: "swahili",
  gl: "galician", mr: "marathi", pa: "punjabi", si: "sinhala", km: "khmer", sn: "shona",
  yo: "yoruba", so: "somali", af: "afrikaans", oc: "occitan", ka: "georgian", be: "belarusian",
  tg: "tajik", sd: "sindhi", gu: "gujarati", am: "amharic", yi: "yiddish", lo: "lao",
  uz: "uzbek", fo: "faroese", ht: "haitian creole", ps: "pashto", tk: "turkmen", nn: "nynorsk",
  mt: "maltese", sa: "sanskrit", lb: "luxembourgish", my: "myanmar", bo: "tibetan", tl: "tagalog",
  mg: "malagasy", as: "assamese", tt: "tatar", haw: "hawaiian", ln: "lingala", ha: "hausa",
  ba: "bashkir", jw: "javanese", su: "sundanese", yue: "cantonese",
};

const TO_LANGUAGE_CODE: Record<string, string> = {
  ...Object.fromEntries(Object.entries(WHISPER_LANGUAGES).map(([c, n]) => [n, c])),
  burmese: "my", valencian: "ca", flemish: "nl", haitian: "ht", letzeburgesch: "lb",
  pushto: "ps", panjabi: "pa", moldavian: "ro", moldovan: "ro", sinhalese: "si", castilian: "es",
  mandarin: "zh",
};

/** "English" / "en" → "en"; throws on unknown. */
export function normalizeWhisperLanguage(language: string): string {
  const l = language.toLowerCase();
  if (l in WHISPER_LANGUAGES) return l;
  const code = TO_LANGUAGE_CODE[l];
  if (code) return code;
  throw new Error(`Unsupported language: ${language}`);
}

export type WhisperTask = "transcribe" | "translate";

const ASCII_PUNCTUATION = "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~";

export class WhisperTokenizer {
  readonly eot: number;
  readonly sot: number;
  readonly translate: number;
  readonly transcribe: number;
  readonly sotLm: number;
  readonly sotPrev: number;
  readonly noSpeech: number;
  readonly noTimestamps: number;
  readonly timestampBegin: number;
  readonly numLanguages: number;
  /** Language token ids in id order (sot+1 …). */
  readonly allLanguageTokens: number[];
  readonly allLanguageCodes: string[];
  readonly #tok: LoadedTokenizer;
  readonly #encodeCache = new Map<string, number[]>();

  constructor(tok: LoadedTokenizer, numLanguages: number) {
    this.#tok = tok;
    this.numLanguages = numLanguages;
    const one = (text: string): number => {
      const ids = tok.encode(text, false);
      if (ids.length !== 1) throw new Error(`whisper tokenizer: ${text} is not a single token`);
      return ids[0]!;
    };
    this.eot = one("<|endoftext|>");
    this.sot = one("<|startoftranscript|>");
    this.translate = one("<|translate|>");
    this.transcribe = one("<|transcribe|>");
    this.sotLm = one("<|startoflm|>");
    this.sotPrev = one("<|startofprev|>");
    this.noSpeech = one("<|nospeech|>");
    this.noTimestamps = one("<|notimestamps|>");
    this.timestampBegin = one("<|0.00|>");
    // language tokens: the oracle's order is by (insertion) special-token
    // order == ascending id, capped at num_languages
    const codes = Object.keys(WHISPER_LANGUAGES).slice(0, numLanguages);
    this.allLanguageTokens = codes.map((c) => one(`<|${c}|>`));
    this.allLanguageCodes = codes;
  }

  encode(text: string): number[] {
    let ids = this.#encodeCache.get(text);
    if (!ids) {
      ids = this.#tok.encode(text, false);
      if (this.#encodeCache.size < 4096) this.#encodeCache.set(text, ids);
    }
    return ids;
  }

  /** decode() drops timestamp tokens (ids ≥ timestampBegin) like the oracle. */
  decode(ids: number[]): string {
    return this.#tok.decode(ids.filter((t) => t < this.timestampBegin), false);
  }

  /** Text tokens only (id < eot). */
  decodeText(ids: number[]): string {
    return this.#tok.decode(ids.filter((t) => t < this.eot), false);
  }

  decodeWithTimestamps(ids: number[]): string {
    return this.#tok.decode(ids, false);
  }

  languageToken(language: string): number {
    const i = this.allLanguageCodes.indexOf(language);
    if (i < 0) throw new Error(`Language ${language} not found in tokenizer.`);
    return this.allLanguageTokens[i]!;
  }

  /** [sot, <|lang|>, <|task|>] */
  sotSequence(language: string | null, task: WhisperTask): number[] {
    const seq = [this.sot];
    if (language !== null) seq.push(this.languageToken(language));
    seq.push(task === "transcribe" ? this.transcribe : this.translate);
    return seq;
  }

  /** tokenizer.non_speech_tokens — punctuation/symbol tokens suppressed at
   *  every step (mlx-whisper tokenizer.py). */
  get nonSpeechTokens(): number[] {
    const symbols = "\"#()*+/:;<=>@[\\]^_`{|}~「」『』".split("");
    symbols.push(...["<<", ">>", "<<<", ">>>", "--", "---", "-(", "-[", "('", "(\"", "((", "))", "(((", ")))", "[[", "]]", "{{", "}}", "♪♪", "♪♪♪"]);
    const miscellaneous = new Set("♩♪♫♬♭♮♯".split(""));
    const result = new Set<number>([this.encode(" -")[0]!, this.encode(" '")[0]!]);
    for (const symbol of [...symbols, ...miscellaneous]) {
      for (const tokens of [this.encode(symbol), this.encode(" " + symbol)]) {
        if (tokens.length === 1 || miscellaneous.has(symbol)) result.add(tokens[0]!);
      }
    }
    return [...result].sort((a, b) => a - b);
  }

  /** Split text tokens into words (split_to_word_tokens): unicode-boundary
   *  split for CJK/Thai/Lao/Myanmar, space split otherwise. */
  splitToWordTokens(tokens: number[], language: string): { words: string[]; wordTokens: number[][] } {
    if (["zh", "ja", "th", "lo", "my", "yue"].includes(language)) return this.#splitOnUnicode(tokens);
    return this.#splitOnSpaces(tokens);
  }

  #splitOnUnicode(tokens: number[]): { words: string[]; wordTokens: number[][] } {
    const decodedFull = this.decodeWithTimestamps(tokens);
    const replacement = "�";
    const words: string[] = [];
    const wordTokens: number[][] = [];
    let current: number[] = [];
    let unicodeOffset = 0;
    for (const token of tokens) {
      current.push(token);
      const decoded = this.decodeWithTimestamps(current);
      const idx = decoded.indexOf(replacement);
      if (idx < 0 || decodedFull[unicodeOffset + idx] === replacement) {
        words.push(decoded);
        wordTokens.push(current);
        current = [];
        unicodeOffset += decoded.length;
      }
    }
    return { words, wordTokens };
  }

  #splitOnSpaces(tokens: number[]): { words: string[]; wordTokens: number[][] } {
    const sub = this.#splitOnUnicode(tokens);
    const words: string[] = [];
    const wordTokens: number[][] = [];
    for (let i = 0; i < sub.words.length; i++) {
      const subword = sub.words[i]!;
      const subwordTokens = sub.wordTokens[i]!;
      const special = subwordTokens[0]! >= this.eot;
      const withSpace = subword.startsWith(" ");
      // python: `subword.strip() in string.punctuation` — a SUBSTRING test.
      const punctuation = ASCII_PUNCTUATION.includes(subword.trim());
      if (special || withSpace || punctuation || words.length === 0) {
        words.push(subword);
        wordTokens.push(subwordTokens);
      } else {
        words[words.length - 1] += subword;
        wordTokens[wordTokens.length - 1]!.push(...subwordTokens);
      }
    }
    return { words, wordTokens };
  }
}

/** Tokenizer directory for a Whisper checkpoint: the model dir itself when
 *  it ships tokenizer.json, else the matching openai/whisper-* HF snapshot
 *  (multilingual v3 vocab → large-v3-turbo; v2 → large-v2; english-only →
 *  base.en). Returns null when nothing is on disk. */
export function resolveWhisperTokenizerDir(modelDir: string, nVocab: number): string | null {
  if (existsSync(`${modelDir}/tokenizer.json`) && existsSync(`${modelDir}/tokenizer_config.json`))
    return modelDir;
  const home = process.env.HOME ?? "";
  const hub = `${home}/.cache/huggingface/hub`;
  for (const repo of whisperTokenizerRepos(nVocab)) {
    const base = `${hub}/models--${repo.replace("/", "--")}/snapshots`;
    try {
      for (const snap of readdirSync(base)) {
        const dir = `${base}/${snap}`;
        if (existsSync(`${dir}/tokenizer.json`) && existsSync(`${dir}/tokenizer_config.json`)) return dir;
      }
    } catch { /* not downloaded */ }
  }
  return null;
}

/** Candidate HF repos whose tokenizer matches an n_vocab. */
export function whisperTokenizerRepos(nVocab: number): string[] {
  if (nVocab === 51866) return ["openai/whisper-large-v3-turbo", "openai/whisper-large-v3"];
  if (nVocab === 51865) return ["openai/whisper-large-v2", "openai/whisper-small", "openai/whisper-tiny"];
  return ["openai/whisper-tiny.en", "openai/whisper-base.en", "openai/whisper-small.en", "openai/whisper-medium.en"];
}

export async function loadWhisperTokenizer(modelDir: string, nVocab: number): Promise<WhisperTokenizer> {
  const dir = resolveWhisperTokenizerDir(modelDir, nVocab);
  if (!dir)
    throw new Error(
      `no Whisper tokenizer for ${modelDir}: place tokenizer.json + tokenizer_config.json ` +
      `beside the weights or download ${whisperTokenizerRepos(nVocab)[0]} (tokenizer files only)`,
    );
  const isMultilingual = nVocab >= 51865;
  const numLanguages = nVocab - 51765 - (isMultilingual ? 1 : 0);
  return new WhisperTokenizer(await loadTokenizer(dir), numLanguages);
}
