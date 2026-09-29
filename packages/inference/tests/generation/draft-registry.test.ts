import { describe, expect, test } from "bun:test";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { DraftProviderRegistry, type DraftLoadRequest, type DraftProviderKind } from "../../src/generation/speculative/draft-registry";
import { defaultDraftProviders, DRAFT_KINDS } from "../../src/generation/speculative/draft-kind";
import type { DraftProvider } from "../../src/generation/speculative/source";
import { declareGraph } from "../../src/models/capabilities";
import { Glm52Model } from "../../src/models/glm52/model";
import { NATIVE_MTP_DRAFT } from "../../src/models/drafters";

const provider = (id: string) => ({ id, weightsBytes: 0, open() { throw new Error("unused"); }, dispose() {} }) as DraftProvider;
const kind = (name: string, detects: boolean | undefined, extra: Partial<DraftProviderKind> = {}): DraftProviderKind => ({
  kind: name, artifact: true,
  ...(detects === undefined ? {} : { detect: async () => detects }),
  load: async () => ({ provider: provider(name), numDraftTokens: 2 }), ...extra,
});
const request: DraftLoadRequest = { dir: "/d", target: { vocabSize: 8, tokenizer: { encode: () => [] } } };

function withDirectory<T>(files: Record<string, unknown>, run: (dir: string) => Promise<T>): Promise<T> {
  const dir = mkdtempSync(join(tmpdir(), "mlx-draft-registry-"));
  for (const [name, content] of Object.entries(files)) writeFileSync(join(dir, name), JSON.stringify(content));
  return run(dir).finally(() => rmSync(dir, { recursive: true, force: true }));
}

describe("draft provider registry", () => {
  test("the default registry registers every built-in kind, and prompt lookup is chosen only by name", () => {
    const registry = defaultDraftProviders();
    expect(registry.kinds()).toEqual([...DRAFT_KINDS]);
    expect(registry.get("ngram")).toMatchObject({ artifact: false });
    expect(registry.get("ngram")!.detect).toBeUndefined();
    expect(registry.get("mtp")!.bundledCompanion).toBe("mtp");
    // Registries are independent: extending one leaves the library's default alone.
    defaultDraftProviders().register(kind("custom", true));
    expect(defaultDraftProviders().kinds()).toEqual([...DRAFT_KINDS]);
  });

  test("a kind registered after the defaults is detected ahead of the two-model catch-all", async () => {
    const registry = defaultDraftProviders().register(kind("custom", true, { detect: async artifact => (await artifact.config())?.model_type === "custom_drafter" }));
    await withDirectory({ "config.json": { model_type: "custom_drafter" } }, async dir => expect(await registry.detect(dir)).toBe("custom"));
    await withDirectory({ "config.json": { model_type: "qwen3" } }, async dir => expect(await registry.detect(dir)).toBe("two-model"));
    // Built-in conventions still win where they match.
    await withDirectory({ "config.json": { model_type: "gemma4_assistant" } }, async dir => expect(await registry.detect(dir)).toBe("assistant"));
  });

  test("kinds are asked in registration order and an unrecognized artifact is refused", async () => {
    const registry = new DraftProviderRegistry().register(kind("a", false)).register(kind("b", true)).register(kind("c", true)).register(kind("named", undefined));
    expect(await registry.detect("/anywhere")).toBe("b");
    // A catch-all answers last however early it was registered.
    const fallback = new DraftProviderRegistry().register(kind("any", true, { fallback: true })).register(kind("late", true));
    expect(await fallback.detect("/anywhere")).toBe("late");
    await expect(new DraftProviderRegistry().register(kind("only", false)).detect("/anywhere")).rejects.toThrow("no registered draft provider recognizes");
  });

  test("duplicate kinds and unknown names are refused; load hands the request to the named kind", async () => {
    const registry = new DraftProviderRegistry().register(kind("a", true));
    expect(() => registry.register(kind("a", true))).toThrow("already registered");
    await expect(registry.load("missing", request)).rejects.toThrow("unknown draft provider kind missing");
    const loaded = await registry.load("a", request);
    expect(loaded.numDraftTokens).toBe(2);
    expect((loaded.provider as DraftProvider).id).toBe("a");
  });

  test("a graph's declared native draft binds through the registry, and only when declared", async () => {
    const graph = (nativeDraft: { kind: string; numDraftTokens: number } | null) => ({ graphCapabilities: declareGraph({ nativeDraft }) });
    const registry = new DraftProviderRegistry().registerNative({ kind: "native-x", create: async () => provider("native") });
    expect(await registry.native(graph(null))).toBeNull();
    const declared = await registry.native(graph({ kind: "native-x", numDraftTokens: 4 }));
    expect([declared!.provider.id, declared!.numDraftTokens]).toEqual(["native", 4]);
    await expect(registry.native(graph({ kind: "elsewhere", numDraftTokens: 4 }))).rejects.toThrow("no provider is registered");
    await expect(registry.native({})).rejects.toThrow("must declare its capabilities");
    expect(() => registry.registerNative({ kind: "native-x", create: async () => provider("again") })).toThrow("already registered");
  });

  test("the GLM graph declares its native MTP head and width only while the MTP tier is loaded", () => {
    const glm = (capabilities: object) => Object.create(Glm52Model.prototype, { capabilities: { value: capabilities } }) as Glm52Model;
    expect(glm({ dsa: true, mtpMetadata: true, mtpEnabled: true, mtpDraftTokens: 4 }).graphCapabilities.nativeDraft)
      .toEqual({ kind: NATIVE_MTP_DRAFT, numDraftTokens: 4 });
    expect(glm({ dsa: true, mtpMetadata: true, mtpEnabled: true }).graphCapabilities.nativeDraft?.numDraftTokens).toBe(3);
    expect(glm({ dsa: true, mtpMetadata: true, mtpEnabled: false, mtpDraftTokens: 4 }).graphCapabilities.nativeDraft).toBeNull();
    expect(glm({ dsa: true, mtpMetadata: true }).graphCapabilities.nativeDraft).toBeNull();
  });

  test("the native MTP provider binds only to the graph that declares it", async () => {
    const other = { graphCapabilities: declareGraph({ nativeDraft: { kind: NATIVE_MTP_DRAFT, numDraftTokens: 3 } }) };
    await expect(defaultDraftProviders().native(other)).rejects.toThrow("binds only to the GLM-5.2 graph");
  });

  test("a model-free kind loads without an artifact and applies its own default width", async () => {
    const loaded = await defaultDraftProviders().load("ngram", request);
    try { expect(loaded.numDraftTokens).toBe(10); } finally { loaded.provider.dispose(); }
    const narrow = await defaultDraftProviders().load("ngram", { ...request, dir: undefined, numDraftTokens: 4 });
    try { expect(narrow.numDraftTokens).toBe(4); } finally { narrow.provider.dispose(); }
  });
});
