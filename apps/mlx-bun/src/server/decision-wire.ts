import type { LoadedTokenizer } from "@mlx-bun/inference/input";
import type { ChatRequestParams } from "./chat-request";

type Messages = ChatRequestParams["messages"];
export interface DecisionOption { value: string | boolean | number; label: string; description: string; legend?: unknown }
export interface DecisionQuestion {
  type: "predicate" | "choice" | "score";
  name: string | null;
  instructions: string;
  options: DecisionOption[];
  images?: { reference: string; url: string }[];
}
export interface DecisionRequest {
  model: string;
  input: Messages;
  questions: DecisionQuestion[];
}

/** Carries a field location for both OpenAI errors and Jev's 422 details. */
export class DecisionValidationError extends Error {
  constructor(readonly field: string, message: string) { super(`${field}: ${message}`); }
}
const fail = (field: string, message: string): never => { throw new DecisionValidationError(field, message); };
function record(value: unknown, field: string): Record<string, unknown> {
  if (!value || typeof value !== "object" || Array.isArray(value)) return fail(field, "must be an object");
  return value as Record<string, unknown>;
}
function string(value: unknown, field: string): string {
  if (typeof value !== "string") return fail(field, "must be a string");
  return value;
}
function list(value: unknown, field: string, minimum: number, maximum: number): unknown[] {
  if (!Array.isArray(value) || value.length < minimum || value.length > maximum)
    return fail(field, `must contain ${minimum}–${maximum} entries`);
  return value;
}
function text(value: unknown, field: string, nullable = false): string {
  if (value === null && nullable) return "";
  if (typeof value !== "string" && (!value || typeof value !== "object")) return fail(field, "must be text, an object, or an array");
  finiteJson(value, field);
  return typeof value === "string" ? value : JSON.stringify(value);
}
function finiteJson(value: unknown, field: string, depth = 0): void {
  if (depth > 64) return fail(field, "exceeds 64 nested levels");
  if (typeof value === "number" && !Number.isFinite(value)) return fail(field, "numbers must be finite");
  if (value && typeof value === "object") for (const child of Object.values(value)) finiteJson(child, field, depth + 1);
}
const predicateOptions = (): DecisionOption[] => [
  { value: false, label: "false", description: "The answer is no; the condition is false." },
  { value: true, label: "true", description: "The answer is yes; the condition is true." },
];

/** OpenAI Decisions request contract: https://developers.openai.com/api/reference/resources/decisions/methods/create */
export function parseOpenAiDecision(value: unknown): DecisionRequest {
  const body = record(value, "body");
  const model = string(body.model, "model");
  let imageCount = 0;
  const input: Messages = typeof body.input === "string" ? [{ role: "user", content: body.input }]
    : list(body.input, "input", 1, Number.MAX_SAFE_INTEGER).map((entry, i) => {
      const at = `input.${i}`, message = record(entry, at);
      if (message.role !== "user" || (message.type !== undefined && message.type !== "message"))
        return fail(at, "must be a user message");
      const content = typeof message.content === "string" ? message.content
        : list(message.content, `${at}.content`, 1, Number.MAX_SAFE_INTEGER).map((entry, j) => {
          const part = record(entry, `${at}.content.${j}`);
          if (part.type === "input_text") return { type: "text", text: string(part.text, `${at}.content.${j}.text`) };
          if (part.type === "input_image") {
            imageCount++;
            if (imageCount > 128) return fail("input", "supports at most 128 images");
            const detail = part.detail;
            if (detail != null && !["auto", "low", "high", "original"].includes(String(detail)))
              return fail(`${at}.content.${j}.detail`, "invalid image detail");
            return { type: "image_url", image_url: { url: string(part.image_url, `${at}.content.${j}.image_url`), ...(detail ? { detail } : {}) } };
          }
          return fail(`${at}.content.${j}.type`, "expected input_text or input_image");
        });
      return { role: "user", content };
    });
  const questions = list(body.questions, "questions", 1, 200).map((entry, i): DecisionQuestion => {
    const at = `questions.${i}`, q = record(entry, at), instructions = string(q.instructions, `${at}.instructions`);
    const name = q.name === undefined ? null : string(q.name, `${at}.name`);
    if (q.type === "predicate") return { type: "predicate", name, instructions, options: predicateOptions() };
    if (q.type === "choice") {
      const options = list(q.choices, `${at}.choices`, 2, 255).map((entry, j) => {
        const choice = record(entry, `${at}.choices.${j}`), value = choice.value;
        if (typeof value !== "string" && typeof value !== "boolean") return fail(`${at}.choices.${j}.value`, "must be a string or boolean");
        return { value, label: JSON.stringify(value), description: choice.description === undefined ? "" : string(choice.description, `${at}.choices.${j}.description`) };
      });
      if (new Set(options.map(option => JSON.stringify(option.value))).size !== options.length)
        return fail(`${at}.choices`, "values must be unique (strings and booleans are distinct)");
      return { type: "choice", name, instructions, options };
    }
    if (q.type === "score") {
      const options = list(q.levels, `${at}.levels`, 2, 255).map((entry, j) => {
        const level = record(entry, `${at}.levels.${j}`);
        return { value: j, label: string(level.label, `${at}.levels.${j}.label`),
          description: level.description === undefined ? "" : string(level.description, `${at}.levels.${j}.description`) };
      });
      return { type: "score", name, instructions, options };
    }
    return fail(`${at}.type`, "expected predicate, choice, or score");
  });
  return { model, input, questions };
}

/** Jev System One contract: https://docs.typesafe.ai/api */
export function parseJevDecision(value: unknown): DecisionRequest {
  const body = record(value, "body"), model = string(body.model, "model");
  const state = text(body.state, "state");
  const assets = new Map<string, string>(), used = new Set<string>();
  for (const [reference, value] of Object.entries(body.assets == null ? {} : record(body.assets, "assets"))) {
    if (!reference.trim() || Buffer.byteLength(reference) > 1024) return fail("assets", "invalid image reference");
    const asset = record(value, `assets.${reference}`);
    if (asset.type !== undefined && asset.type !== "image") return fail(`assets.${reference}.type`, "expected image");
    if (!["png", "jpg", "jpeg"].includes(String(asset.format))) return fail(`assets.${reference}.format`, "expected png, jpg, or jpeg");
    const data = string(asset.data_base64, `assets.${reference}.data_base64`);
    if (!/^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$/.test(data) || !data.length)
      return fail(`assets.${reference}.data_base64`, "invalid base64 image");
    assets.set(reference, `data:image/${asset.format === "png" ? "png" : "jpeg"};base64,${data}`);
  }
  // Only values may refer to images. IDs and option keys stay text. Matching is
  // left-to-right, with whole-value matches taking precedence over substrings.
  const imagesIn = (value: unknown): { reference: string; url: string }[] => {
    if (value && typeof value === "object") return Object.values(value).flatMap(imagesIn);
    if (typeof value !== "string") return [];
    if (assets.has(value)) { used.add(value); return [{ reference: value, url: assets.get(value)! }]; }
    const found: { reference: string; url: string }[] = [];
    for (let position = 0; position < value.length;) {
      const matches = [...assets.keys()].map(reference => ({ reference, at: value.indexOf(reference, position) }))
        .filter(match => match.at >= 0).sort((a, b) => a.at - b.at || b.reference.length - a.reference.length);
      const match = matches[0];
      if (!match) break;
      found.push({ reference: match.reference, url: assets.get(match.reference)! }); used.add(match.reference);
      position = match.at + match.reference.length;
    }
    return found;
  };
  const stateImages = imagesIn(body.state);
  const entries = Object.entries(record(body.questions, "questions"));
  if (!entries.length) return fail("questions", "must contain at least one question");
  const questions = entries.map(([name, entry]): DecisionQuestion => {
    const at = `questions.${name}`, q = record(entry, at), instructions = text(q.instructions ?? null, `${at}.instructions`, true);
    if (q.type === "noul") {
      const options = predicateOptions();
      if (q.criteria != null) {
        const criteria = record(q.criteria, `${at}.criteria`);
        for (const option of options) if (Object.hasOwn(criteria, String(option.value)))
          option.description = text(criteria[String(option.value)], `${at}.criteria.${option.value}`, true);
      }
      return { type: "predicate", name, instructions, options, images: [...imagesIn(q.instructions), ...imagesIn(q.criteria)] };
    }
    if (q.type === "choice") {
      const choices = Object.entries(record(q.criteria, `${at}.criteria`));
      if (choices.length < 1 || choices.length > 255) return fail(`${at}.criteria`, "requires 1–255 options");
      return { type: "choice", name, instructions, images: [...imagesIn(q.instructions), ...imagesIn(q.criteria)], options: choices.map(([value, description]) => ({
        value, label: JSON.stringify(value), description: text(description, `${at}.criteria.${value}`, true),
      })) };
    }
    if (q.type === "score") return { type: "score", name, instructions, images: [...imagesIn(q.instructions), ...imagesIn(q.criteria)],
      options: list(q.criteria, `${at}.criteria`, 2, 10).map((entry, index) => ({
        value: index, label: text(entry, `${at}.criteria.${index}`, true) || String(index), description: "", legend: entry,
      })) };
    return fail(`${at}.type`, "expected noul, choice, or score");
  });
  if (used.size !== assets.size) return fail("assets", "every image asset must be referenced");
  return { model, input: [{ role: "user", content: stateImages.length ? [
    { type: "text", text: state }, ...imageParts(stateImages),
  ] : state }], questions };
}

function imageParts(images: { reference: string; url: string }[]): { type: string; [key: string]: unknown }[] {
  return images.flatMap(image => [{ type: "text", text: `Image reference: ${image.reference}` },
    { type: "image_url", image_url: { url: image.url } }]);
}

/** Exact wire values encoded as JSON keep string "true" distinct from boolean
 * true, preserve whitespace and empty strings, and never shorten multi-token
 * answers. Score questions use their supplied labels as the answer text. */
export function decisionCandidates(tokenizer: Pick<LoadedTokenizer, "encode">, question: DecisionQuestion, ending: string): number[][] {
  return question.options.map(option => tokenizer.encode(
    JSON.stringify(question.type === "score" ? option.label : option.value) + ending, false));
}

export function decisionMessages(input: Messages, question: DecisionQuestion): Messages {
  const menu = question.options.map(option => `${question.type === "score" ? JSON.stringify(option.label) : JSON.stringify(option.value)}${option.description ? ` — ${option.description}` : ""}`).join("\n");
  const questionText = `Evaluate the preceding input.\nQuestion: ${question.instructions}\nAllowed answers${question.type === "score" ? " (ordered from lowest to highest)" : ""}:\n${menu}\nAnswer with exactly one of the JSON values above. Do not explain.`;
  // Both protocols supply user input. Keep it in one turn so templates that
  // enforce user/assistant alternation accept it, retaining media order.
  const content = input.flatMap((message, i) => [
    ...(i ? [{ type: "text" as const, text: "\n\n" }] : []),
    ...(typeof message.content === "string" ? [{ type: "text" as const, text: message.content }] : message.content ?? []),
  ]);
  content.push({ type: "text", text: `\n\n${questionText}` }, ...imageParts(question.images ?? []));
  return [{ role: "user", content: content.every(part => part.type === "text")
    ? content.map(part => (part as { text: string }).text).join("") : content }];
}

function winner(probabilities: readonly number[]): number {
  return probabilities.reduce((best, p, i) => p > probabilities[best]! ? i : best, 0);
}
/** Jev's documented distribution-derived confidence, including ordered levels.
 * OpenAI does not publish a confidence formula; the local adapter uses this
 * same statistic. This is a statistic of the likelihoods, with no learned
 * calibration stage. */
export function decisionConfidence(probabilities: readonly number[], ordered: boolean): number {
  const n = probabilities.length, best = winner(probabilities);
  if (n === 1) return 1;
  if (!ordered) return Math.max(0, Math.min(1, (probabilities[best]! * n - 1) / (n - 1)));
  const spread = probabilities.reduce((sum, p, i) => sum + p * Math.abs(i - best), 0);
  const uniform = probabilities.reduce((sum, _, i) => sum + Math.abs(i - (n - 1) / 2) / n, 0);
  return Math.max(0, Math.min(1, 1 - spread / uniform));
}
export function decisionAnswer(question: DecisionQuestion, probabilities: number[], jev: boolean): Record<string, unknown> {
  const { type, name, options } = question;
  if (type === "predicate") return jev ? { type: "noul", noul: probabilities[1] }
    : { type, name, probability: probabilities[1] };
  const confidence = decisionConfidence(probabilities, type === "score");
  if (type === "choice") {
    const choice = options[winner(probabilities)]!.value;
    return jev ? { type, choice, confidence, probabilities: Object.fromEntries(options.map((option, i) => [option.value, probabilities[i]])) }
      : { type, name, choice, confidence, probabilities: options.map((option, i) => ({ value: option.value, probability: probabilities[i] })) };
  }
  const score = probabilities.reduce((sum, p, i) => sum + p * i, 0);
  return jev ? { type, score, confidence,
    legend: Object.fromEntries(options.map((option, i) => [i, Object.hasOwn(option, "legend") ? option.legend : option.label])),
    probabilities: Object.fromEntries(probabilities.map((p, i) => [i, p])) }
    : { type, name, score, confidence, probabilities: options.map((option, i) => ({ value: i, label: option.label, probability: probabilities[i] })) };
}
