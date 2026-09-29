import type { Unsubscribe } from "./events";

/** A chat tool a module offers the chat module. */
export interface ChatToolContribution {
  readonly name: string;
  readonly description: string;
  /** JSON Schema of the arguments object. */
  readonly parameters: Readonly<Record<string, unknown>>;
  run(args: Readonly<Record<string, unknown>>, signal: AbortSignal): Promise<string>;
}

/** A setting a module adds to the shell's settings page. */
export interface SettingContribution {
  /** Unique within the contributing module. */
  readonly key: string;
  readonly label: string;
  readonly summary: string;
  readonly type: "string" | "number" | "boolean";
  readonly default?: string | number | boolean;
}

/** A link a module adds to the shell's navigation beyond its own panel. */
export interface NavContribution {
  readonly label: string;
  /** A shell route. */
  readonly path: string;
}

/**
 * The declared extension points: point id to the contribution it takes. A point
 * exists here first, with its consumer; a module then lists it in its manifest's
 * `contributes` before registering to it. Shapes widen with their consumers.
 */
export interface ExtensionPoints {
  "chat.tool": ChatToolContribution;
  "shell.setting": SettingContribution;
  "shell.nav": NavContribution;
}
export type ExtensionPointId = keyof ExtensionPoints;

/** One registered contribution and the module that registered it. */
export interface Registration<P extends ExtensionPointId = ExtensionPointId> {
  readonly point: P;
  /** Id of the contributing module; identifies the source and never gates use. */
  readonly source: string;
  readonly contribution: ExtensionPoints[P];
}

/**
 * Cross-module contributions. A contributor registers to a point it declared in
 * its manifest; a consumer lists what is registered under a point. Neither names
 * the other, so a module's tools appear in chat with no import between them.
 * `list` is a live view: a consumer lists on demand or follows `onChange`, since
 * a contributor may activate after it.
 */
export interface Registry {
  /** Rejects a point the module's manifest did not list in `contributes`. The registration ends with `Unsubscribe` or when the module stops. */
  register<P extends ExtensionPointId>(point: P, contribution: ExtensionPoints[P]): Unsubscribe;
  /** In registration order. */
  list<P extends ExtensionPointId>(point: P): readonly Registration<P>[];
  /** Called after a registration to `point` is added or removed. Never throws into the registrant. */
  onChange(point: ExtensionPointId, handler: () => void): Unsubscribe;
}
