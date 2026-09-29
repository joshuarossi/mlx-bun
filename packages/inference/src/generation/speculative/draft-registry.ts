// The draft providers a server can load, each owning how its artifact is
// recognized and how it is loaded. The registry is model-free: it never loads
// MLX itself, so callers detect kinds cheaply and pay for a provider only when
// they load one. Applications use the library's default registry
// (`defaultDraftProviders`), extend it, or hand a ready DraftProvider in
// instead; none names a provider class.
import { declaredGraph } from "../../models/capabilities";
import type { DraftProvider } from "./source";

/** A draft artifact directory, read lazily and at most once. */
export interface DraftArtifact {
  readonly dir: string;
  has(file: string): Promise<boolean>;
  /** config.json, or null when absent or unreadable. */
  config(): Promise<Record<string, unknown> | null>;
}

export function draftArtifact(dir: string): DraftArtifact {
  let config: Promise<Record<string, unknown> | null> | undefined;
  return {
    dir,
    has: file => Bun.file(`${dir}/${file}`).exists(),
    config: () => config ??= Bun.file(`${dir}/config.json`).json().then(
      value => value as Record<string, unknown>, () => null),
  };
}

/** What the target offers a draft that must agree with it. */
export interface DraftTarget {
  readonly vocabSize: number;
  readonly tokenizer: { encode(text: string): readonly number[] };
}

export interface DraftLoadRequest {
  /** The artifact directory; undefined for a kind with no artifact. */
  readonly dir: string | undefined;
  readonly target: DraftTarget;
  /** Requested draft tokens per round; each kind applies its own default and bound. */
  readonly numDraftTokens?: number;
  /** Prompt-lookup window, for the kind that has one. */
  readonly ngram?: { readonly max?: number; readonly min?: number };
}

export interface LoadedDraft {
  readonly provider: DraftProvider;
  readonly numDraftTokens: number;
}

export interface DraftProviderKind {
  readonly kind: string;
  /** False for a model-free kind: it takes no artifact and is chosen only by name. */
  readonly artifact: boolean;
  /** Subdirectory of a target artifact that bundles this kind's companion. */
  readonly bundledCompanion?: string;
  /** Whether the artifact is this kind's. Absent: the kind is chosen only by
   * name. Kinds are asked in registration order. */
  detect?(artifact: DraftArtifact): Promise<boolean>;
  /** A catch-all: asked only after every other kind declined, wherever it was
   * registered, so a kind added later is still detected ahead of it. */
  readonly fallback?: boolean;
  /** Load the provider and settle its round width; the provider is owned by the
   * caller on return and disposed here on failure. */
  load(request: DraftLoadRequest): Promise<LoadedDraft>;
}

/** A provider that binds to graphs declaring `GraphCapabilities.nativeDraft`
 * with this kind: the draft head the graph's own checkpoint carries. */
export interface NativeDraftKind {
  readonly kind: string;
  create(graph: object): Promise<DraftProvider>;
}

export class DraftProviderRegistry {
  readonly #kinds = new Map<string, DraftProviderKind>();
  readonly #native = new Map<string, NativeDraftKind>();

  register(kind: DraftProviderKind): this {
    if (this.#kinds.has(kind.kind)) throw new Error(`draft provider kind ${kind.kind} is already registered`);
    this.#kinds.set(kind.kind, kind);
    return this;
  }

  registerNative(kind: NativeDraftKind): this {
    if (this.#native.has(kind.kind)) throw new Error(`native draft kind ${kind.kind} is already registered`);
    this.#native.set(kind.kind, kind);
    return this;
  }

  kinds(): string[] { return [...this.#kinds.keys()]; }

  get(kind: string): DraftProviderKind | undefined { return this.#kinds.get(kind); }

  /** The first registered kind that recognizes the artifact. Reads files only. */
  async detect(dir: string): Promise<string> {
    const artifact = draftArtifact(dir);
    const asked = [...this.#kinds.values()].filter(kind => kind.detect);
    for (const kind of [...asked.filter(kind => !kind.fallback), ...asked.filter(kind => kind.fallback)])
      if (await kind.detect!(artifact)) return kind.kind;
    throw new Error(`${dir}: no registered draft provider recognizes this artifact`);
  }

  async load(kind: string, request: DraftLoadRequest): Promise<LoadedDraft> {
    const entry = this.#kinds.get(kind);
    if (!entry) throw new Error(`unknown draft provider kind ${kind} (registered: ${this.kinds().join(", ")})`);
    return entry.load(request);
  }

  /** The draft the graph declares it carries, or null when it declares none. */
  async native(graph: object): Promise<LoadedDraft | null> {
    const declared = declaredGraph(graph).graphCapabilities.nativeDraft;
    if (!declared) return null;
    const kind = this.#native.get(declared.kind);
    if (!kind) throw new Error(`the graph declares native draft ${declared.kind}, which no provider is registered for`);
    return { provider: await kind.create(graph), numDraftTokens: declared.numDraftTokens };
  }
}
