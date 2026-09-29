// The `modelHost` core service for the persistent services (serve-state.ts):
// the model the attached serving host runs, reached over its own HTTP surface.
// The serving host owns residency (it is loaded before it serves and released
// when it closes), so this host reports that one model as resident and pinned,
// never evicts it, and leases it for `generate`: a wire request (OpenAI,
// Anthropic or Responses) sent to the host's listener, over its Unix socket
// when it has one. Whisper and other companions are the model composition's.
import type { AcquireOptions, ModelHost, ModelId, ModelLease, ModelOperation, ModelStats, ResidentModel } from "@mlx-bun/app-core";
import { ModelHostFailure } from "@mlx-bun/app-services/portable";

const OPERATIONS: readonly ModelOperation[] = ["generate"];

/** What a serving host lends: its model and where its listener is (`ModelHostLink` adds the rest). */
export interface ServedHostLink {
  /** The served model: what modules lease for `generate` (its id and weight bytes). */
  readonly model: { readonly id: string; readonly bytes: number };
  /** The public port modules leasing the served model target. */
  readonly port: number;
  /** Internal (worker app form): the Unix socket the host listens on instead of TCP; the URL's port is then a placeholder. */
  readonly unix?: string;
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
      leases++; lastUsedAt = Date.now();
      let released = false;
      return { model: resident(link), loadMs: 0,
        operations: { generate: request => {
          const url = new URL(request.url);
          return options.fetch(new Request(`http://127.0.0.1:${link.port}${url.pathname}${url.search}`, request), link);
        } },
        release() { if (!released) { released = true; leases--; lastUsedAt = Date.now(); } } };
    },
    async defaultFor(operation) { const link = options.link(); return link && OPERATIONS.includes(operation) ? link.model.id : undefined; },
    async plan(id) { return { fits: id === options.link()?.model.id, requiredBytes: 0, freeBytes: 0, evict: [] }; },
    async unload() { throw new ModelHostFailure("in-use", "the serving host releases its model when it closes"); },
    pin() {},
    unpin() {},
    resident() { const link = options.link(); return link ? [resident(link)] : []; },
    stats(id): ModelStats { return { resident: id === options.link()?.model.id, loads: 1, unloads: 0, lastLoadMs: 0, idleUnloadSec: null }; },
  };
}
