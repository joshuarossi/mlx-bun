import type { ModelCatalog } from "./services/catalog";
import type { EventBus } from "./services/events";
import type { JobRunner, JobService } from "./services/jobs";
import type { ModelHost } from "./services/model-host";
import type { ExtensionPointId, Registry } from "./services/registry";
import type { StorageEntrySpec, StorageService } from "./services/storage";

/** Every core service. A host implements them once; modules borrow them. */
export interface CoreServices {
  readonly modelHost: ModelHost;
  readonly jobs: JobService;
  readonly catalog: ModelCatalog;
  readonly storage: StorageService;
  readonly events: EventBus;
  readonly registry: Registry;
}
export type CoreServiceName = keyof CoreServices;

/** What a module receives: only the services it declared in `requires`, scoped to it. */
export interface ModuleContext<R extends CoreServiceName = CoreServiceName> {
  readonly moduleId: string;
  readonly services: Pick<CoreServices, R>;
  /** Aborts when the host stops the module. */
  readonly signal: AbortSignal;
}

export type HttpMethod = "GET" | "POST" | "PUT" | "PATCH" | "DELETE";

export interface RouteSpec {
  /** Unique within the module; keys `ModuleRuntime.routes`. */
  readonly id: string;
  readonly method: HttpMethod;
  /** Starts with `/`; mounted under `/api/<module id>`, or at the root for `mount: "root"`. */
  readonly path: string;
  readonly summary: string;
  readonly response: "json" | "sse" | "binary";
  /** `root` is for wire-compatible or previously shipped paths (`/v1/audio/transcriptions`); the host rejects collisions. */
  readonly mount?: "module" | "root";
}

export type RouteHandler = (request: Request) => Response | Promise<Response>;

export interface SocketSpec {
  readonly id: string;
  /** Starts with `/`; a WebSocket upgrade is a `GET`, mounted under `/api/<module id>`, or at the root for `mount: "root"`. */
  readonly path: string;
  readonly summary: string;
  /** `root` is for previously shipped paths (`/ws/chat`); the host rejects collisions, as for routes. */
  readonly mount?: "module" | "root";
}
/** One open connection. The host hands the handler the same peer for every call about that connection. */
export interface SocketPeer {
  send(data: string): void;
  /** Closes the connection; the code and reason are the WebSocket close frame's (default 1000). */
  close(code?: number, reason?: string): void;
}
export interface SocketHandler {
  open?(peer: SocketPeer, request: Request): void | Promise<void>;
  message(peer: SocketPeer, data: string): void | Promise<void>;
  close?(peer: SocketPeer): void | Promise<void>;
}

export interface CliOptionSpec {
  readonly name: string;
  readonly type: "string" | "number" | "boolean";
  readonly summary: string;
  readonly default?: string | number | boolean;
  readonly repeatable?: boolean;
  /** A one-letter spelling (`-q`). */
  readonly short?: string;
  /** The flag may appear without a value, which then takes `default` (`--hotkey`). */
  readonly optionalValue?: boolean;
  /** The message when the flag is given without a value (default: the parser's). */
  readonly missingValue?: string;
}

export interface CliVerbSpec {
  readonly name: string;
  readonly summary: string;
  readonly positional?: readonly { readonly name: string; readonly summary: string; readonly required?: boolean; readonly repeatable?: boolean }[];
  readonly options: readonly CliOptionSpec[];
  /** The line printed when the verb is invoked wrongly; default `usage: <program> <name> <positionals>`. */
  readonly usage?: string;
  /** Display usage when the existing help spelling differs from the parser's error usage. */
  readonly helpUsage?: string;
  /** A paragraph `--help` prints between the usage line and the options (subcommands, ordering rules). */
  readonly details?: string;
}

/** One line of progress the host draws (a spinner on a terminal, plain lines elsewhere). */
export interface CliStep {
  update(text: string): void;
  done(text?: string): void;
  fail(text?: string): void;
}

export interface CliColumn {
  readonly header: string;
  readonly align?: "left" | "right";
  readonly paint?: (cell: string, row: number) => string;
}

/** How a verb presents itself: the host owns the look, so a verb stays the same in a terminal, a script or a native app's console. */
export interface CliTerminal {
  step(text: string): CliStep;
  /** A bordered block, one output line per entry. */
  box(lines: readonly string[]): void;
  /** A section header on its own lines. */
  heading(text: string): void;
  /** An aligned table with headers; `paint` styles a padded cell. */
  table(columns: readonly CliColumn[], rows: readonly (readonly string[])[]): void;
  readonly style: {
    dim(text: string): string;
    bold(text: string): string;
    green(text: string): string;
    accent(text: string): string;
    url(text: string): string;
    gradient(text: string): string;
  };
}

export interface CliInvocation {
  /** Parsed by the host from the verb's declared options: absent flags are undefined, `number` options arrive as numbers. */
  readonly values: Readonly<Record<string, string | number | boolean | readonly string[] | undefined>>;
  /** The verb's positional arguments in order, checked against its declared positionals. */
  readonly positionals: readonly string[];
  readonly stdout: (text: string) => void;
  readonly stderr: (text: string) => void;
  readonly terminal: CliTerminal;
  readonly signal: AbortSignal;
}
/** Resolves to the process exit code. */
export type CliVerbHandler = (invocation: CliInvocation) => Promise<number>;

export interface JobRunnerSpec {
  /** Unique across installed modules. */
  readonly kind: string;
  /** `task` runs in the host process; `process` runs a child that stops with its parent. */
  readonly isolation: "task" | "process";
  /** `exclusive` jobs hold the GPU: models drain first and none generates meanwhile. */
  readonly gpu: "exclusive" | "shared" | "none";
}

/** A self-contained web component the host mounts, in its own shell or a
 * Tauri, Electron or Swift webview. It imports only its module's panel files
 * and data protocol, and reaches the backend only through its connection. */
export interface PanelSpec {
  /** Custom element tag, `mlx-<module id>-panel`. */
  readonly tag: string;
  /** Package export that defines the element when imported, e.g. `@mlx-bun/module-transcription/panel`. */
  readonly entry: string;
  readonly title: string;
  /** Shell route, `/<module id>`. */
  readonly path: string;
  /** A workspace panel is the product's own page: it fills the shell's page instead of sitting in a titled card, is listed
   * first and stays outside the Developer switch. Default false. */
  readonly workspace?: boolean;
  /** Persistent companion overlay, mounted without a route or navigation tab. */
  readonly overlay?: boolean;
  /** Listed among developer tools by default; false for a panel every user needs. */
  readonly developer?: boolean;
}

/** Set on the element's `connection` property before it connects. */
export interface PanelConnection {
  /** Absolute or origin-relative base of `/api/<module id>`. */
  readonly apiBase: string;
  /** Server-sent stream of `AppEvent`s. */
  readonly eventsUrl: string;
}

/** Live parts of a module, created by `activate`. Each key names a declared spec. */
export interface ModuleRuntime {
  readonly routes?: Readonly<Record<string, RouteHandler>>;
  readonly sockets?: Readonly<Record<string, SocketHandler>>;
  readonly verbs?: Readonly<Record<string, CliVerbHandler>>;
  readonly jobs?: Readonly<Record<string, JobRunner>>;
  /** Live counters for the host's health and stats surfaces. Never loads a model. */
  status?(): Readonly<Record<string, number | string | boolean | null>>;
  /** Called once when the host stops the module, after its in-flight work drains. */
  dispose?(): void | Promise<void>;
}

/**
 * A module's static manifest plus its factory. The manifest is plain data, so
 * documentation generators and hosts read it without loading a model or
 * native code; `activate` builds the live parts. Modules import only this
 * package, the domain libraries they use, and their own files, never another
 * module, an app or a core-service implementation.
 */
export interface AppModule<R extends CoreServiceName = CoreServiceName> {
  /** Lowercase kebab-case; the route prefix, panel path and event prefix. */
  readonly id: string;
  readonly title: string;
  readonly summary: string;
  readonly requires: readonly R[];
  /** Where a host that keeps its persistent services apart from its model host activates the module: `app` beside the jobs, the
   * served model's wire and the serving host's residency, `model` with the model host. Default `app` for a module that requires `jobs`, else `model`. */
  readonly placement?: "app" | "model";
  readonly routes?: readonly RouteSpec[];
  readonly sockets?: readonly SocketSpec[];
  readonly verbs?: readonly CliVerbSpec[];
  readonly jobs?: readonly JobRunnerSpec[];
  readonly storage?: readonly StorageEntrySpec[];
  /** Extension points the module registers to (needs `registry` in `requires`). */
  readonly contributes?: readonly ExtensionPointId[];
  readonly panel?: PanelSpec;
  activate(context: ModuleContext<R>): ModuleRuntime | Promise<ModuleRuntime>;
}
