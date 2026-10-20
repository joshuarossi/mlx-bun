// The host contract's browser half: the events a host page raises on `window` for every panel, with their names and
// payloads in one place. A panel listens through `onHostEvent` and never names the event itself; a host (the app's
// status poller, a native shell) emits through `emitHostEvent`. A panel that raises one of these for its host, such as
// the Models panel after a serve, emits it on itself with `bubbles` and `composed`, so it reaches the document whatever
// the panel's shadow boundary.

/** The served model and the server's reachability, as the host's status poll last saw them. */
export interface ServerStatusDetail {
  readonly model: string | null;
  readonly online: boolean;
  readonly download: { readonly repoId: string; readonly percent: number } | null;
}

export interface HostEventMap {
  /** Every status poll's summary. */
  "mlx-server-status": ServerStatusDetail;
  /** The served model switched; the detail is the new model id. */
  "mlx-model-changed": string | null;
  /** The server answered again after being unreachable. */
  "mlx-server-recovered": undefined;
  /** The served model or the mounted adapters changed in a panel; the host re-reads the server's identity. */
  "mlx-models-changed": undefined;
  /** A panel's visible state changed (a wizard moved to another step); a host that describes the page re-reads it. */
  "mlx-panel-changed": undefined;
}

export const HOST_EVENTS = {
  serverStatus: "mlx-server-status",
  modelChanged: "mlx-model-changed",
  serverRecovered: "mlx-server-recovered",
  modelsChanged: "mlx-models-changed",
  panelChanged: "mlx-panel-changed",
} as const satisfies Record<string, keyof HostEventMap>;

export function emitHostEvent<K extends keyof HostEventMap>(name: K, detail?: HostEventMap[K], target: EventTarget = window, init: EventInit = {}): void {
  target.dispatchEvent(new CustomEvent(name, { detail, ...init }));
}

/** Listens on `window` (or the given target); returns the remover, for a panel's disposer. */
export function onHostEvent<K extends keyof HostEventMap>(name: K, handler: (detail: HostEventMap[K]) => void, target: EventTarget = window): () => void {
  const listener = (event: Event) => handler((event as CustomEvent<HostEventMap[K]>).detail);
  target.addEventListener(name, listener);
  return () => target.removeEventListener(name, listener);
}

/** What a panel may take from the host that embeds it, beyond its connection: every hook is optional, and a panel
 * without one keeps working with its own fallback (an inline status line instead of a toast, no publishing). */
export interface PanelUi {
  notify?(message: string, kind?: "ok" | "err"): void;
  publish?(container: HTMLElement, source: { kind: "quantize" | "finetune" | "dataset"; job_id?: string; source_path?: string }): void | Promise<void>;
  modelId?(): string | undefined;
  catalogChanged?(): void;
}
