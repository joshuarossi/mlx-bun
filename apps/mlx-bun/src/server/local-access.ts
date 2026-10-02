// Who may use the TCP listener. The API is unauthenticated, so a browser on the
// same machine must not become an attacker's client: a page on another site can
// send simple requests (form posts, text/plain fetches, navigations, image loads)
// without a CORS preflight, and DNS rebinding can point an attacker's name at
// loopback. The server sends no CORS headers, so no cross-origin page can read a
// response; refusing cross-site requests outright removes only their side effects.
// Clients that are not browsers (curl, SDKs) send no Origin or Sec-Fetch-* and are
// unaffected. The per-model worker's Unix socket is not checked: only its parent connects.
import { hostname as machineHostname } from "node:os";

const LOOPBACK_V4 = /^127(?:\.\d{1,3}){3}$/;
const IPV4 = /^\d{1,3}(?:\.\d{1,3}){3}$/;

/** The hostname of a Host header (or a bound address) as the URL parser normalizes it:
 * lowercase names, canonical IPv4, bracketed IPv6. Undefined when it is not a bare host[:port]. */
function hostnameOf(authority: string): string | undefined {
  try {
    const url = new URL(`http://${authority}`);
    return url.username || url.password || url.pathname !== "/" || url.search || url.hash ? undefined : url.hostname;
  } catch { return undefined; }
}

const isLoopback = (name: string): boolean => name === "localhost" || LOOPBACK_V4.test(name) || name === "[::1]";
/** Docker Desktop's name for this machine, how a containerized client reaches a loopback bind; `.internal` is reserved, so no site can own it. */
const CONTAINER_HOST = "host.docker.internal";

/** The page that sent the request was served by this Host (over http, or https through a proxy that keeps the Host). */
function sameOrigin(origin: string, host: string): boolean {
  try {
    const page = new URL(origin);
    return (page.protocol === "http:" || page.protocol === "https:") && page.origin === `${page.protocol}//${new URL(`${page.protocol}//${host}`).host}`;
  } catch { return false; }
}

export interface LocalAccess {
  /** The bind reaches beyond this machine (a non-loopback `--host`, or every interface). */
  readonly exposed: boolean;
  /** A 403 for a request the listener must refuse, else null. `page` says whether the web app serves the request (a navigation target). */
  check(request: Request, page: (request: Request) => boolean): Response | null;
}

/**
 * The listener's access policy, for a bind address as `startServer` takes it
 * (omitted: 127.0.0.1; null: every interface).
 *
 * - Host: a loopback name or address, `host.docker.internal`, or the bound host. A bind to every
 *   interface also accepts IP literals and this machine's name (`<name>`,
 *   `<name>.local`): a DNS-rebound name is neither. A request without Host
 *   (not a browser) passes.
 * - Origin, on any request that carries one: the origin the request was sent
 *   to (`http://<Host>`, or `https://<Host>` behind a TLS proxy that keeps the
 *   Host). Browsers send it on every cross-origin POST and on WebSocket handshakes.
 * - Sec-Fetch-Site, when sent: `same-origin` or `none` (typed URL, bookmark,
 *   `open`). Another site may still navigate to a page of the web app, never
 *   to an API path, so a GET with side effects cannot be triggered cross-site.
 */
export function createLocalAccess(bound: string | null | undefined): LocalAccess {
  const address = bound === undefined ? "127.0.0.1" : bound;
  const name = address === null ? undefined
    : hostnameOf(address.includes(":") && !address.startsWith("[") ? `[${address}]` : address);
  const wildcard = address === null || name === "0.0.0.0" || name === "[::]";
  const machine = wildcard ? (() => {
    const base = machineHostname().toLowerCase().replace(/\.local$/, "");
    return new Set([base, `${base}.local`]);
  })() : new Set<string>();
  const allowed = (host: string) => isLoopback(host) || host === CONTAINER_HOST || host === name ||
    (wildcard && (IPV4.test(host) || host.startsWith("[") || machine.has(host)));
  const forbidden = (message: string, code: string) =>
    Response.json({ error: { message, type: "forbidden", code } }, { status: 403 });
  return {
    exposed: wildcard || name === undefined || !isLoopback(name),
    check(request, page) {
      const host = request.headers.get("host");
      if (host !== null) {
        const requested = hostnameOf(host);
        if (requested === undefined || !allowed(requested))
          return forbidden(`Host ${JSON.stringify(host)} is not served here; use localhost or the address mlx-bun is bound to`, "invalid_host");
      }
      const origin = request.headers.get("origin");
      if (origin !== null && (host === null || !sameOrigin(origin, host)))
        return forbidden(`cross-origin request from ${origin} refused`, "cross_origin");
      const site = request.headers.get("sec-fetch-site");
      if (site !== null && site !== "same-origin" && site !== "none" &&
        !(["GET", "HEAD"].includes(request.method) && request.headers.get("sec-fetch-mode") === "navigate" && page(request)))
        return forbidden(`${site} request refused`, "cross_site");
      return null;
    },
  };
}
