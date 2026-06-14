// Public barrel for the native dataset-building engine: a TypeScript port of
// optiq lab's 13 dataset templates. Wizards/server routes import from here.

export { TEMPLATES, getTemplate, generate } from "./registry";
export type { TemplateDef, TemplateField, GenerateResult } from "./registry";

export { datasetRunner, registerDatasetRunner } from "./job";

export { makeLlmClient } from "./llm";
export type { LlmClient, ChatMessage, ChatOpts } from "./llm";

export type { Row } from "./generators";
