// Dataset-template registry: the 13 TemplateDefs ported field-for-field from
// optiq lab's dataset_templates.py. This file is pure metadata (the UI renders
// forms from it) plus the generate() dispatcher that does the 90/10 split and
// JSONL writing exactly like the Python reference.

import type { Emit } from "../jobs/types";
import type { LlmClient } from "./llm";
import {
  genCodeCompletion,
  genCotSynthesis,
  genDpoPairs,
  genFormatConversion,
  genHfDatasetImport,
  genMultiTurnChat,
  genPromptReconstruction,
  genRagQa,
  genSelfInstruct,
  genSftQa,
  genStyleTransfer,
  genToolUseTraces,
  genVerifiedCode,
  type Row,
} from "./generators";

/** A single user-facing form field. UI forms are built from these. */
export interface TemplateField {
  name: string;
  type: "text" | "textarea" | "number";
  label: string;
  hint?: string;
  required?: boolean;
  default?: string | number;
}

/** Metadata for one dataset-building template. */
export interface TemplateDef {
  id: string;
  label: string;
  description: string;
  output_format: "messages" | "prompt_completion" | "dpo" | "text";
  needs_llm: boolean;
  fields: TemplateField[];
}

export const TEMPLATES: TemplateDef[] = [
  // ---- non-LLM templates (fast, local) ----
  {
    id: "sft_qa_pairs",
    label: "SFT from QA pairs",
    description:
      "Paste Q/A pairs or upload a .txt with `Q: …\\nA: …` blocks. Produces chat-format JSONL.",
    output_format: "messages",
    needs_llm: false,
    fields: [
      {
        name: "pairs_text",
        type: "textarea",
        label: "Pairs (Q: / A: blocks)",
        hint: "Q: What is OptIQ?\\nA: A mixed-precision quantizer …",
        required: true,
      },
    ],
  },
  {
    id: "dpo_pref_pairs",
    label: "DPO from preference pairs",
    description: "Upload CSV with columns `prompt,chosen,rejected`. Emits DPO JSONL.",
    output_format: "dpo",
    needs_llm: false,
    fields: [
      {
        name: "csv_text",
        type: "textarea",
        label: "CSV (header `prompt,chosen,rejected`)",
        required: true,
      },
    ],
  },
  {
    id: "code_completion",
    label: "Code completion",
    description:
      "Walks a directory's .py files, splits each function at a random midpoint into prompt/completion pairs.",
    output_format: "prompt_completion",
    needs_llm: false,
    fields: [
      {
        name: "src_dir",
        type: "text",
        label: "Source directory (containing .py files)",
        required: true,
      },
      {
        name: "max_pairs",
        type: "number",
        label: "Max pairs to produce",
        default: 500,
      },
    ],
  },
  {
    id: "hf_dataset_import",
    label: "Hugging Face dataset import",
    description:
      "Pull a public dataset from the Hugging Face Hub by id, optionally " +
      "filter rows by a column value, slice to a row cap, and emit the " +
      "chosen output format. Stand-alone (no LLM call) and idempotent — " +
      "use it as the first step of any pipeline that starts from a " +
      "published corpus (EditLens, no_robots, dolly, your own dataset).",
    output_format: "text",
    needs_llm: false,
    fields: [
      {
        name: "hf_id",
        type: "text",
        label: "Dataset id",
        hint: "e.g. pangram/editlens_iclr or HuggingFaceH4/no_robots",
        required: true,
      },
      {
        name: "config",
        type: "text",
        label: "Config / subset (optional)",
        hint: "Some datasets have multiple configs (e.g. wikitext-2-raw-v1).",
      },
      {
        name: "split",
        type: "text",
        label: "Split",
        default: "train",
      },
      {
        name: "text_column",
        type: "text",
        label: "Text column",
        hint: "Field on each row that holds the body text.",
        default: "text",
      },
      {
        name: "label_column",
        type: "text",
        label: "Filter column (optional)",
        hint: "e.g. text_type for EditLens. Leave blank for no filter.",
      },
      {
        name: "label_filter",
        type: "text",
        label: "Filter value (optional)",
        hint: "Keep only rows where filter-column == this value. e.g. human_written.",
      },
      {
        name: "max_rows",
        type: "number",
        label: "Row cap (0 = no cap)",
        default: 1000,
      },
      {
        name: "min_chars",
        type: "number",
        label: "Drop rows shorter than this many chars",
        default: 200,
      },
      {
        name: "output_format",
        type: "text",
        label: "Output format",
        hint:
          "One of: text | messages_user_only | prompt_completion. " +
          "'text' writes {\"text\": ...}; 'messages_user_only' writes a " +
          "messages row with the text as the user turn (downstream " +
          "templates can read either).",
        default: "text",
      },
    ],
  },
  {
    id: "format_conversion",
    label: "Format conversion",
    description:
      "Upload existing JSONL in any shape + a key mapping. Emits OptIQ-expected JSONL.",
    output_format: "messages",
    needs_llm: false,
    fields: [
      {
        name: "input_jsonl",
        type: "textarea",
        label: "Existing JSONL",
        required: true,
      },
      { name: "user_key", type: "text", label: "user field", default: "input" },
      { name: "assistant_key", type: "text", label: "assistant field", default: "output" },
    ],
  },
  // ---- LLM-driven templates (need a served model) ----
  {
    id: "style_transfer",
    label: "Style transfer",
    description:
      "Provide reference samples and raw text. Uses the served model to rewrite in the reference style.",
    output_format: "prompt_completion",
    needs_llm: true,
    fields: [
      {
        name: "reference_samples",
        type: "textarea",
        label: "Reference style samples (separated by ---)",
        required: true,
      },
      {
        name: "raw_text",
        type: "textarea",
        label: "Raw text to rewrite (one paragraph per row)",
        required: true,
      },
    ],
  },
  {
    id: "self_instruct",
    label: "Self-instruct expansion",
    description:
      "Upload seed instructions; uses the served model (via data-designer when available) to generate K variants per seed.",
    output_format: "messages",
    needs_llm: true,
    fields: [
      {
        name: "seeds",
        type: "textarea",
        label: "Seed instructions (one per line)",
        required: true,
      },
      {
        name: "variants_per_seed",
        type: "number",
        label: "Variants per seed",
        default: 5,
      },
    ],
  },
  {
    id: "prompt_reconstruction",
    label: "Prompt reconstruction",
    description:
      "Build (AI draft → target) training pairs by working backwards: " +
      "for each target paragraph the served model infers a likely prompt " +
      "and writes a generic AI draft. The assistant target is the original " +
      "paragraph verbatim, so facts and formatting are preserved by construction.",
    output_format: "messages",
    needs_llm: true,
    fields: [
      {
        name: "target_text",
        type: "textarea",
        label: "Target paragraphs (separated by blank lines)",
        hint:
          "Paste the text you want the model to learn to produce. " +
          "Posts, memos, brand-voice samples, edited drafts, etc.",
        required: true,
      },
      {
        name: "style",
        type: "text",
        label: "Style label",
        hint: "Free text, surfaced in the system prompt.",
        default: "direct technical blog",
      },
      {
        name: "tone",
        type: "text",
        label: "Tone",
        default: "analytical, clear, non-corporate",
      },
      {
        name: "preserve",
        type: "text",
        label: "Things to preserve (comma-separated)",
        default: "facts, names, numbers, URLs, citations, code blocks, quotes",
      },
      {
        name: "avoid",
        type: "text",
        label: "Things to avoid (comma-separated)",
        default: "em dashes, generic transitions, marketing language",
      },
    ],
  },
  {
    id: "multi_turn_chat",
    label: "Multi-turn chat synthesis",
    description:
      "Take seed user prompts and a persona; expand each into an " +
      "N-turn synthetic user/assistant conversation by alternating " +
      "model-as-assistant and model-as-followup-user calls.",
    output_format: "messages",
    needs_llm: true,
    fields: [
      {
        name: "seeds",
        type: "textarea",
        label: "Seed user prompts (one per line)",
        required: true,
      },
      {
        name: "turns",
        type: "number",
        label: "Total turns per conversation (user + assistant pairs)",
        default: 4,
      },
      {
        name: "persona",
        type: "text",
        label: "Assistant persona (system prompt)",
        default: "You are a helpful, concise assistant.",
      },
      {
        name: "user_persona",
        type: "text",
        label: "Followup-user persona",
        hint: "How follow-up questions should sound.",
        default: "a curious developer probing for specifics",
      },
    ],
  },
  {
    id: "tool_use_traces",
    label: "Tool-use traces",
    description:
      "Generate (user, tool_call, tool_result, final) training traces " +
      "in OpenAI tool-call shape. Provide a list of tool schemas plus " +
      "scenario prompts; the model picks a tool, you supply a mocked " +
      "result, the model writes the final answer.",
    output_format: "messages",
    needs_llm: true,
    fields: [
      {
        name: "tools_json",
        type: "textarea",
        label: "Tool schemas (OpenAI tools format, JSON array)",
        hint: "Paste a JSON array of {type, function:{name,description,parameters}}.",
        required: true,
      },
      {
        name: "scenarios",
        type: "textarea",
        label: "User scenarios (one per line)",
        required: true,
      },
      {
        name: "mock_results",
        type: "textarea",
        label: "Mocked tool results (one per line, matches scenarios order)",
        hint: "Free text; gets passed back as the tool_result content.",
        required: true,
      },
    ],
  },
  {
    id: "rag_qa",
    label: "RAG Q/A from documents",
    description:
      "Chunk pasted text into passages; for each passage the model " +
      "writes a question whose answer is grounded in that passage and " +
      "then writes the grounded answer. Outputs messages-format rows " +
      "where the passage is in a system message and the question/answer " +
      "in user/assistant turns.",
    output_format: "messages",
    needs_llm: true,
    fields: [
      {
        name: "documents",
        type: "textarea",
        label: "Source documents (paragraphs separated by blank lines)",
        required: true,
      },
      {
        name: "questions_per_chunk",
        type: "number",
        label: "Questions per chunk",
        default: 2,
      },
      {
        name: "min_chunk_chars",
        type: "number",
        label: "Min chunk size (chars)",
        default: 200,
      },
    ],
  },
  {
    id: "cot_synthesis",
    label: "Reasoning trace (CoT) synthesis",
    description:
      "For each question, the served model emits a step-by-step " +
      "<think> trace followed by the final answer. Output is messages-" +
      "format with the reasoning preserved inside the assistant content " +
      "as a `<think>...</think>` block, matching the Qwen3 / GPT-OSS " +
      "reasoning convention.",
    output_format: "messages",
    needs_llm: true,
    fields: [
      {
        name: "questions",
        type: "textarea",
        label: "Questions (one per line)",
        required: true,
      },
      {
        name: "category",
        type: "text",
        label: "Domain hint",
        default: "math, logic, planning, technical analysis",
      },
    ],
  },
  {
    id: "verified_code",
    label: "Verified code generation",
    description:
      "For each natural-language spec, the served model writes Python " +
      "code AND a set of `assert` checks. We run the assertions in the " +
      "sandbox and keep only the pairs that pass. Output is messages-" +
      "format; failed pairs are dropped before writing the JSONL.",
    output_format: "messages",
    needs_llm: true,
    fields: [
      {
        name: "specs",
        type: "textarea",
        label: "Natural-language specs (one per line)",
        hint: "e.g. `write a function that returns the n-th Fibonacci number`",
        required: true,
      },
      {
        name: "language",
        type: "text",
        label: "Language",
        default: "python",
      },
    ],
  },
];

export function getTemplate(id: string): TemplateDef | undefined {
  return TEMPLATES.find((t) => t.id === id);
}

/** Result of a successful generate() run. */
export interface GenerateResult {
  n_train: number;
  n_valid: number;
  output_dir: string;
}

type Inputs = Record<string, unknown>;

/** Dispatch table: template id → generator function. */
const GENERATORS: Record<
  string,
  (inputs: Inputs, emit: Emit, llm?: LlmClient) => Promise<Row[]>
> = {
  sft_qa_pairs: genSftQa,
  dpo_pref_pairs: genDpoPairs,
  code_completion: genCodeCompletion,
  format_conversion: genFormatConversion,
  hf_dataset_import: genHfDatasetImport,
  style_transfer: genStyleTransfer,
  self_instruct: genSelfInstruct,
  prompt_reconstruction: genPromptReconstruction,
  multi_turn_chat: genMultiTurnChat,
  tool_use_traces: genToolUseTraces,
  rag_qa: genRagQa,
  cot_synthesis: genCotSynthesis,
  verified_code: genVerifiedCode,
};

/**
 * Run the named template with `inputs`, write `train.jsonl` + `valid.jsonl`
 * into `outputDir`, and emit progress events. Mirrors the Python reference:
 * 90/10 split with `split_idx = max(1, floor(n * 0.9))`, valid = remainder
 * (or the last row if the remainder is empty).
 */
export async function generate(
  id: string,
  inputs: Inputs,
  outputDir: string,
  emit: Emit,
  llm?: LlmClient,
): Promise<GenerateResult> {
  const gen = GENERATORS[id];
  if (!gen) throw new Error(`unknown template ${JSON.stringify(id)}`);

  // mkdir -p
  const { mkdir } = await import("node:fs/promises");
  await mkdir(outputDir, { recursive: true });

  const rows = await gen(inputs, emit, llm);
  const n = rows.length;
  if (n === 0) {
    throw new Error("generator produced 0 rows — check your inputs");
  }

  // 90/10 split (matches dataset_templates.py exactly).
  const splitIdx = Math.max(1, Math.floor(n * 0.9));
  const trainRows = rows.slice(0, splitIdx);
  let validRows = rows.slice(splitIdx);
  if (validRows.length === 0) validRows = rows.slice(-1); // last row fallback

  const sep = outputDir.endsWith("/") ? "" : "/";
  const trainPath = `${outputDir}${sep}train.jsonl`;
  const validPath = `${outputDir}${sep}valid.jsonl`;

  await Bun.write(trainPath, trainRows.map((r) => JSON.stringify(r)).join("\n") + "\n");
  await Bun.write(validPath, validRows.map((r) => JSON.stringify(r)).join("\n") + "\n");

  const nTrain = splitIdx;
  const nValid = Math.max(1, n - splitIdx);

  emit({
    type: "stage",
    stage: "done",
    progress: 1.0,
    message: `Wrote ${n} rows.`,
    output_dir: outputDir,
    n_train: nTrain,
    n_valid: nValid,
  });

  return { n_train: nTrain, n_valid: nValid, output_dir: outputDir };
}
