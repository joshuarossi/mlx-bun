import type { ModelConfig } from "../config";
import {
  assertResolvedModelProfile,
  type GenerationLoop,
  type ModelGraph,
  type ModelLoader,
  type ResolvedModelProfile,
} from "./profile";

/** Engine code implements this port. Source and Model remain backend-specific;
 * selection introduces no tensor conversion or dispatch in the token loop.
 * create borrows source; a failed construction must release its own resources. */
export interface ModelImplementation<Source, Model> {
  readonly id: string;
  readonly graph: ModelGraph;
  readonly loader: ModelLoader;
  readonly loop: GenerationLoop;
  create(source: Source, config: ModelConfig, profile: ResolvedModelProfile): Model;
}

export interface ModelImplementationProvider<Source, Model> {
  /** Validate identity and composition, then return one compatible binding.
   * A declared implementation must never silently fall back to another. */
  select(config: ModelConfig, profile: ResolvedModelProfile): ModelImplementation<Source, Model>;
}

/** Immutable composition, with identity matching delegated to model profiles.
 * Exact declarations are requirements: absent/incompatible code is an error,
 * never an invitation to retry with a different numerical implementation. */
export class ModelImplementationRegistry<Source, Model> implements ModelImplementationProvider<Source, Model> {
  private readonly entries: ReadonlyMap<string, ModelImplementation<Source, Model>>;

  constructor(implementations: readonly ModelImplementation<Source, Model>[]) {
    const entries = new Map<string, ModelImplementation<Source, Model>>();
    for (const implementation of implementations) {
      if (!implementation.id.trim()) throw new Error("model implementation id must not be empty");
      if (entries.has(implementation.id))
        throw new Error(`duplicate model implementation ${implementation.id}`);
      entries.set(implementation.id, Object.freeze({
        id: implementation.id,
        graph: implementation.graph,
        loader: implementation.loader,
        loop: implementation.loop,
        create: implementation.create.bind(implementation),
      }));
    }
    this.entries = entries;
  }

  /** Return a new composition; active models retain their existing binding. */
  with(...implementations: readonly ModelImplementation<Source, Model>[]): ModelImplementationRegistry<Source, Model> {
    return new ModelImplementationRegistry([...this.entries.values(), ...implementations]);
  }

  select(config: ModelConfig, profile: ResolvedModelProfile): ModelImplementation<Source, Model> {
    assertResolvedModelProfile(config, profile);
    const execution = profile.profile.execution;
    // These default IDs preserve the existing dedicated/generated/family choice.
    const id = execution.implementation ?? (execution.specialization === "generated"
      ? `${execution.graph}-generated` : execution.graph);
    const implementation = this.entries.get(id);
    if (!implementation)
      throw new Error(`model profile ${profile.profile.id} requires unavailable implementation ${id}; refusing to fall back`);
    if (implementation.graph !== execution.graph || implementation.loader !== execution.loader ||
        implementation.loop !== execution.loop)
      throw new Error(`model implementation ${id} is incompatible with profile ${profile.profile.id}; refusing to fall back`);
    return implementation;
  }
}
