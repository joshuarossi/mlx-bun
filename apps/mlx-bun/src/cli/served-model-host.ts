// The `modelHost` core service for the persistent services (serve-state.ts):
// the model the attached serving host runs, reached over its own HTTP surface.
// The serving host owns residency (it is loaded before it serves and released
// when it closes), so this host reports that one model as resident and pinned,
// never evicts it, and leases it for `generate`: a wire request (OpenAI, Anthropic or
// Responses) sent to the host's listener, over its Unix socket when it has one. A serving
// host whose residency can evict supplies `hold`, and each lease holds the model resident
// through it until released. Whisper and other companions are the model composition's.
import type { AcquireOptions, AdapterOperation, ModelHost, ModelId, ModelLease, ModelOperation, ModelOperations, ModelStats, ResidentModel } from "@mlx-bun/app-core";
import { ModelHostFailure } from "@mlx-bun/app-services/portable";

const OPERATIONS: readonly ModelOperation[] = ["generate"];

/** What a serving host lends: its model and where its listener is (`ModelHostLink` adds the rest). */
export interface ServedHostLink {
  /** The served model: what modules lease for `generate` (its id and weight bytes). */
  readonly model: { readonly id: string; readonly bytes: number };
  /** Holds the model resident until released; a leased model is never evicted under its holder. Absent on a host that never evicts it. */
  hold?(model: string, signal?: AbortSignal): Promise<{ release(): void }>;
  /** The public port modules leasing the served model target. */
  readonly port: number;
  /** Internal (worker app form): the Unix socket the host listens on instead of TCP; the URL's port is then a placeholder. */
  readonly unix?: string;
  /** Makes a local model the served one (`POST /api/hub/serve`): loaded beside the resident ones when it fits, else in place of the least recently used. Rejects with a coded `ModelHostError`; absent on a host that serves one model. */
  serve?(model: string, signal: AbortSignal): Promise<void>;
  /** Every model the host holds resident, for the library's "loaded" marks and cache cleanup's protection; absent on a host that holds only its served model. */
  resident?(): readonly ResidentModel[];
  /** The served model's adapter operation: each call holds the model resident and runs under its execution lease, in the process that holds it. */
  readonly adapters?: AdapterOperation;
}

export interface ServedModelHostOptions<Link extends ServedHostLink> {
  /** The attached serving host; none before one attaches and after it detaches. */
  link(): Link | undefined;
  /** Sends a request to a host's listener, over its socket when it has one. */
  fetch(request: Request, link: Link): Promise<Response>;
}

export function createServedModelHost<Link extends ServedHostLink>(options: ServedModelHostOptions<Link>): ModelHost {
  const attached = () => options.link() ?? (() => { throw new ModelHostFailure("closed", "no model host is attached"); })();
  let leases = 0, lastUsedAt = 0;
  const resident = (link: Link): ResidentModel => ({ id: link.model.id, role: "primary", state: "ready", operations: OPERATIONS,
    bytes: link.model.bytes, pinned: true, leases, lastUsedAt });
  return {
    get policy() {
      const link = options.link();
      return { budgetBytes: link?.model.bytes ?? 0, pinned: link ? [link.model.id] : [], idleUnloadSec: 0 };
    },
    async acquire(id: ModelId, acquire: AcquireOptions = {}): Promise<ModelLease> {
      acquire.signal?.throwIfAborted();
      const link = attached();
      if (id !== link.model.id) throw new ModelHostFailure("does-not-fit", `model ${id} is not the served model (${link.model.id})`);
      const missing = (acquire.need ?? []).filter(operation => !OPERATIONS.includes(operation));
      if (missing.length) throw new ModelHostFailure("does-not-fit", `model ${id} does not declare ${missing.join(", ")}`);
      // The host's own lease pins the model for as long as this one is held (it may load it again if it was evicted since).
      const held = await link.hold?.(id, acquire.signal);
      leases++; lastUsedAt = Date.now();
      let released = false;
      const operations: Partial<ModelOperations> = { generate: request => {
        const url = new URL(request.url);
        return options.fetch(new Request(`http://127.0.0.1:${link.port}${url.pathname}${url.search}`, request), link);
      }, ...(link.adapters ? { adapters: link.adapters } : {}) };
      return { model: resident(link), loadMs: 0, operations,
        release() { if (!released) { released = true; leases--; lastUsedAt = Date.now(); held?.release(); } } };
    },
    async defaultFor(operation) { const link = options.link(); return link && OPERATIONS.includes(operation) ? link.model.id : undefined; },
    async plan(id) { return { fits: id === options.link()?.model.id, requiredBytes: 0, freeBytes: 0, evict: [] }; },
    async serve(id, serveOptions = {}) {
      const link = attached();
      if (!link.serve) throw new ModelHostFailure("not-switchable", "this host serves one model; switching needs a restart");
      await link.serve(id, serveOptions.signal ?? new AbortController().signal);
    },
    async unload() { throw new ModelHostFailure("in-use", "the serving host releases its model when it closes"); },
    pin() {},
    unpin() {},
    resident() { const link = options.link(); return link ? link.resident?.() ?? [resident(link)] : []; },
    stats(id): ModelStats { return { resident: id === options.link()?.model.id, loads: 1, unloads: 0, lastLoadMs: 0, idleUnloadSec: null }; },
  };
}
