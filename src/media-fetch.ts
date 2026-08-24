// Remote media (image_url / audio_url) fetching with an SSRF/resource-
// exhaustion policy. A chat request's URL is attacker-controlled input to
// a server that may hold credentials for its LAN (the classic target:
// cloud metadata at 169.254.169.254, router admin pages, other local
// services), so by default the destination of every hop — the original
// URL and each redirect — must be a public http(s) host, the whole fetch
// is wall-clock bounded, and the response is size-capped.
//
// Escape hatch: `mlx-bun serve --allow-private-media` (or
// MLX_BUN_ALLOW_PRIVATE_MEDIA=1) re-permits private/loopback/link-local
// destinations — this is a local single-user server and pointing it at a
// NAS or another LAN box is legitimate. Scheme/timeout/size limits still
// apply.
//
// DNS names are resolved and every resolved address is checked before the
// fetch. The request then dials one of those checked IP literals while
// preserving the logical Host header and HTTPS SNI, so the transport cannot
// re-resolve to a private address between validation and connect.
//
// This module must stay free of mlx imports so tests/unit/media-fetch.test.ts
// runs model-free.

import { lookup } from "node:dns/promises";
import { runtimeValue } from "./runtime-config";

export interface MediaFetchPolicy {
  /** Permit private/loopback/link-local destinations (LAN hosts). */
  allowPrivate: boolean;
  /** Optional caller-specific explanation when private destinations fail. */
  privateDestinationHint?: string;
  /** Wall-clock budget for the whole fetch — every redirect hop plus the
   *  body read share one AbortSignal.timeout. */
  timeoutMs: number;
  /** Response body cap in bytes (checked against Content-Length up front
   *  AND while streaming, since the header is optional/spoofable). */
  maxBytes: number;
  maxRedirects: number;
}

export type RestrictedFetch = (
  input: string | URL,
  init?: BunFetchRequestInit,
) => Promise<Response>;

export type ResolveHost = (
  hostname: string,
) => Promise<ReadonlyArray<{ address: string }>>;

export interface RestrictedFetchDependencies {
  fetch: RestrictedFetch;
  resolve: ResolveHost;
}

export interface RestrictedFetchOptions {
  /** Optional caller cancellation, combined with the policy timeout. */
  signal?: AbortSignal;
  /** Request headers applied on every validated redirect hop. */
  headers?: Record<string, string>;
  /** Test seam for deterministic DNS/redirect/body behavior. */
  dependencies?: Partial<RestrictedFetchDependencies>;
  /** Media callers reject non-2xx before reading; web_fetch returns the body. */
  rejectHttpErrors?: boolean;
}

export interface RestrictedFetchResult {
  ok: boolean;
  status: number;
  finalUrl: string;
  contentType: string;
  bytes: Uint8Array;
}

export function defaultMediaFetchPolicy(): MediaFetchPolicy {
  return {
    allowPrivate: runtimeValue("MLX_BUN_ALLOW_PRIVATE_MEDIA") === "1",
    // 10 s / 64 MB: well above what a 30 s audio clip (~5 MB of 16 kHz
    // WAV, less compressed) or any supported image needs.
    timeoutMs: 10_000,
    maxBytes: 64 * 1024 * 1024,
    maxRedirects: 5,
  };
}

const PRIVATE_HINT =
  "private/loopback hosts are blocked by default; start the server with " +
  "--allow-private-media (or MLX_BUN_ALLOW_PRIVATE_MEDIA=1) to fetch from LAN hosts";

function privateHint(policy: MediaFetchPolicy): string {
  return policy.privateDestinationHint ?? PRIVATE_HINT;
}

function parseIpv4(s: string): number[] | null {
  const parts = s.split(".");
  if (parts.length !== 4) return null;
  const out: number[] = [];
  for (const p of parts) {
    if (!/^\d{1,3}$/.test(p)) return null;
    const n = Number(p);
    if (n > 255) return null;
    out.push(n);
  }
  return out;
}

function blockedIpv4(o: number[]): boolean {
  const [a, b] = o as [number, number];
  if (a === 0 || a === 10 || a === 127) return true; // this-net, 10/8, loopback
  if (a === 100 && b >= 64 && b <= 127) return true; // CGNAT 100.64/10
  if (a === 169 && b === 254) return true; // link-local (cloud metadata lives here)
  if (a === 172 && b >= 16 && b <= 31) return true; // 172.16/12
  if (a === 192 && b === 168) return true; // 192.168/16
  if (a >= 224) return true; // multicast + reserved + broadcast
  return false;
}

/** Expand an IPv6 literal (with `::` compression, an optional zone index,
 *  and an optional dotted-quad tail like ::ffff:127.0.0.1) into its 8
 *  16-bit groups. null = not valid IPv6. */
function parseIpv6(addr: string): number[] | null {
  let s = addr;
  const pct = s.indexOf("%");
  if (pct !== -1) s = s.slice(0, pct);
  if (s.includes(".")) {
    // rewrite the dotted-quad tail as two hex groups
    const i = s.lastIndexOf(":");
    const v4 = parseIpv4(s.slice(i + 1));
    if (!v4) return null;
    s =
      s.slice(0, i + 1) +
      (((v4[0]! << 8) | v4[1]!).toString(16)) + ":" +
      (((v4[2]! << 8) | v4[3]!).toString(16));
  }
  const halves = s.split("::");
  if (halves.length > 2) return null;
  const toGroups = (part: string): number[] | null => {
    if (part === "") return [];
    const out: number[] = [];
    for (const g of part.split(":")) {
      if (!/^[0-9a-fA-F]{1,4}$/.test(g)) return null;
      out.push(parseInt(g, 16));
    }
    return out;
  };
  const head = toGroups(halves[0]!);
  if (head === null) return null;
  if (halves.length === 1) return head.length === 8 ? head : null;
  const tail = toGroups(halves[1]!);
  if (tail === null) return null;
  if (head.length + tail.length > 7) return null;
  return [...head, ...new Array(8 - head.length - tail.length).fill(0), ...tail];
}

function blockedIpv6(g: number[]): boolean {
  if (g.every((x) => x === 0)) return true; // :: unspecified
  if (g.slice(0, 7).every((x) => x === 0) && g[7] === 1) return true; // ::1
  if ((g[0]! & 0xffc0) === 0xfe80) return true; // link-local fe80::/10
  if ((g[0]! & 0xfe00) === 0xfc00) return true; // ULA fc00::/7
  if ((g[0]! & 0xff00) === 0xff00) return true; // multicast ff00::/8
  // v4-mapped (::ffff:0:0/96) and NAT64 (64:ff9b::/96) embed an IPv4
  // address in the low 32 bits — judge the embedded address.
  const v4Embedded =
    (g.slice(0, 5).every((x) => x === 0) && g[5] === 0xffff) ||
    (g[0] === 0x64 && g[1] === 0xff9b && g.slice(2, 6).every((x) => x === 0));
  if (v4Embedded)
    return blockedIpv4([g[6]! >> 8, g[6]! & 0xff, g[7]! >> 8, g[7]! & 0xff]);
  return false;
}

/** True when `addr` is a private/loopback/link-local/reserved IP literal
 *  — or unparseable as an IP at all (fail closed; callers only pass
 *  things believed to be addresses). Accepts bracketed IPv6. */
export function isBlockedAddress(addr: string): boolean {
  let s = addr;
  if (s.startsWith("[") && s.endsWith("]")) s = s.slice(1, -1);
  const v4 = parseIpv4(s);
  if (v4) return blockedIpv4(v4);
  const v6 = parseIpv6(s);
  if (v6) return blockedIpv6(v6);
  return true;
}

/** Sync per-hop destination check: scheme + hostname-literal policy.
 *  Returns a rejection reason or null. DNS names pass here and get their
 *  resolved addresses checked in fetchMediaBytes (async). Exported pure
 *  so the policy is testable without any network. */
export function checkMediaUrl(u: URL, policy: MediaFetchPolicy): string | null {
  if (u.protocol !== "http:" && u.protocol !== "https:")
    return `unsupported url scheme "${u.protocol.replace(/:$/, "")}" (only http/https)`;
  const host =
    u.hostname.startsWith("[") && u.hostname.endsWith("]")
      ? u.hostname.slice(1, -1)
      : u.hostname;
  if (!host) return "missing host";
  if (policy.allowPrivate) return null;
  const lower = host.toLowerCase();
  if (lower === "localhost" || lower.endsWith(".localhost"))
    return `destination "${host}" — ${privateHint(policy)}`;
  // WHATWG URL parsing already canonicalized numeric IPv4 forms
  // (http://2130706433/, http://0x7f000001/ → 127.0.0.1).
  if (parseIpv4(lower) || parseIpv6(lower)) {
    if (isBlockedAddress(lower))
      return `destination "${host}" — ${privateHint(policy)}`;
  }
  return null;
}

export async function assertResolvesPublic(
  hostname: string,
  kind: string,
  policy: MediaFetchPolicy,
  resolve: ResolveHost = async (host) =>
    await lookup(host, { all: true, verbatim: true }),
): Promise<void> {
  if (policy.allowPrivate) return;
  const host =
    hostname.startsWith("[") && hostname.endsWith("]")
      ? hostname.slice(1, -1)
      : hostname;
  if (parseIpv4(host) || parseIpv6(host)) return; // literal — checked sync
  let addrs: { address: string }[];
  try {
    addrs = [...await resolve(host)];
  } catch {
    throw new Error(`${kind} fetch failed: could not resolve host "${host}"`);
  }
  for (const a of addrs) {
    if (isBlockedAddress(a.address))
      throw new Error(
        `${kind} url rejected: host "${host}" resolves to ${a.address} — ${privateHint(policy)}`,
      );
  }
}

async function resolveFetchAddresses(
  hostname: string,
  kind: string,
  policy: MediaFetchPolicy,
  resolve: ResolveHost,
): Promise<string[]> {
  const host =
    hostname.startsWith("[") && hostname.endsWith("]")
      ? hostname.slice(1, -1)
      : hostname;
  if (parseIpv4(host) || parseIpv6(host)) return [host];
  if (policy.allowPrivate) return [];
  let addrs: { address: string }[];
  try {
    addrs = [...await resolve(host)];
  } catch {
    throw new Error(`${kind} fetch failed: could not resolve host "${host}"`);
  }
  if (addrs.length === 0)
    throw new Error(`${kind} fetch failed: host "${host}" resolved to no addresses`);
  for (const a of addrs) {
    if (isBlockedAddress(a.address))
      throw new Error(
        `${kind} url rejected: host "${host}" resolves to ${a.address} — ${privateHint(policy)}`,
      );
  }
  return addrs.map((a) => a.address);
}

/**
 * Fetch an http(s) response through the shared public-destination policy.
 * Every redirect is handled manually and revalidated, caller cancellation
 * shares one signal with the wall-clock timeout, and the body is streamed
 * into a byte-capped buffer.
 */
export async function fetchRestrictedHttpBytes(
  url: string,
  kind: string,
  policy: MediaFetchPolicy,
  options: RestrictedFetchOptions = {},
): Promise<RestrictedFetchResult> {
  let current: URL;
  try {
    current = new URL(url);
  } catch {
    throw new Error(`unsupported ${kind} url scheme: ${url.slice(0, 16)}`);
  }

  const fetchImpl = options.dependencies?.fetch ??
    ((input: string | URL, init?: BunFetchRequestInit) => fetch(input, init));
  const resolve = options.dependencies?.resolve ??
    (async (host: string) => await lookup(host, { all: true, verbatim: true }));
  const timeout = AbortSignal.timeout(policy.timeoutMs);
  const signal = options.signal
    ? AbortSignal.any([options.signal, timeout])
    : timeout;
  const capMb = Math.round(policy.maxBytes / (1024 * 1024));
  let overCap = false;

  try {
    for (let hop = 0; ; hop++) {
      const reason = checkMediaUrl(current, policy);
      if (reason) throw new Error(`${kind} url rejected: ${reason}`);
      const addresses = await resolveFetchAddresses(
        current.hostname,
        kind,
        policy,
        resolve,
      );
      const logicalHostname = current.hostname.replace(/^\[|\]$/g, "");
      const connectUrl = new URL(current);
      if (!policy.allowPrivate && addresses.length > 0) {
        const address = addresses[0]!;
        connectUrl.hostname = address.includes(":") ? `[${address}]` : address;
      }
      const headers = new Headers(options.headers);
      if (connectUrl.hostname !== current.hostname && !headers.has("host"))
        headers.set("host", current.host);
      const init: BunFetchRequestInit = {
        redirect: "manual",
        signal,
        headers,
      };
      if (current.protocol === "https:" && connectUrl.hostname !== current.hostname) {
        init.tls = { serverName: logicalHostname };
      }
      const res = await fetchImpl(connectUrl, init);
      if (res.status >= 300 && res.status < 400) {
        const loc = res.headers.get("location");
        if (!loc)
          throw new Error(`${kind} fetch failed: ${res.status} redirect without location`);
        if (hop >= policy.maxRedirects)
          throw new Error(`${kind} fetch failed: more than ${policy.maxRedirects} redirects`);
        try {
          await res.body?.cancel();
        } catch {}
        try {
          current = new URL(loc, current);
        } catch {
          throw new Error(`${kind} fetch failed: malformed redirect location`);
        }
        continue;
      }

      if (options.rejectHttpErrors && !res.ok) {
        try {
          await res.body?.cancel();
        } catch {}
        throw new Error(`${kind} fetch failed: ${res.status} ${current}`);
      }

      const declared = Number(res.headers.get("content-length") ?? "0");
      if (Number.isFinite(declared) && declared > policy.maxBytes) {
        overCap = true;
        try {
          await res.body?.cancel();
        } catch {}
        throw new Error(`${kind} response exceeds the ${capMb} MB limit`);
      }

      let bytes: Uint8Array;
      if (!res.body) {
        bytes = new Uint8Array(await res.arrayBuffer());
        if (bytes.byteLength > policy.maxBytes) {
          overCap = true;
          throw new Error(`${kind} response exceeds the ${capMb} MB limit`);
        }
      } else {
        const reader = res.body.getReader();
        const chunks: Uint8Array[] = [];
        let total = 0;
        for (;;) {
          const { done, value } = await reader.read();
          if (done) break;
          total += value.byteLength;
          if (total > policy.maxBytes) {
            overCap = true;
            try {
              await reader.cancel();
            } catch {}
            throw new Error(`${kind} response exceeds the ${capMb} MB limit`);
          }
          chunks.push(value);
        }
        bytes = new Uint8Array(total);
        let offset = 0;
        for (const chunk of chunks) {
          bytes.set(chunk, offset);
          offset += chunk.byteLength;
        }
      }

      return {
        ok: res.ok,
        status: res.status,
        finalUrl: current.href,
        contentType: res.headers.get("content-type") ?? "",
        bytes,
      };
    }
  } catch (error) {
    if (timeout.aborted && !options.signal?.aborted && !overCap)
      throw new Error(
        `${kind} fetch timed out after ${policy.timeoutMs} ms: ${url.slice(0, 200)}`,
      );
    throw error;
  }
}

/** Fetch image/audio bytes for an OpenAI-style image_url/audio_url part.
 *  data: URLs decode locally (no policy — the bytes came in the request);
 *  http(s) URLs go through the destination policy above, with every
 *  redirect hop re-validated, one wall-clock timeout, and a streaming
 *  size cap. Throws Error with a client-presentable message — callers
 *  surface it as a 400 (the prompt-build catch in server.ts). */
/** Video clips are legitimately larger than images/audio: same SSRF guard
 *  and timeout discipline, quadruple the body cap (a 30 s 1080p H.264 clip
 *  runs tens of MB; frame sampling truncates long clips server-side). */
export function videoMediaFetchPolicy(): MediaFetchPolicy {
  return { ...defaultMediaFetchPolicy(), maxBytes: 256 * 1024 * 1024 };
}

export async function fetchMediaBytes(
  url: string,
  kind: "image" | "audio" | "video",
  policy: MediaFetchPolicy = kind === "video"
    ? videoMediaFetchPolicy()
    : defaultMediaFetchPolicy(),
): Promise<Uint8Array> {
  if (url.startsWith("data:")) {
    const comma = url.indexOf(",");
    if (comma === -1) throw new Error("malformed data: URL");
    const meta = url.slice(0, comma);
    const body = url.slice(comma + 1);
    if (!meta.includes("base64")) throw new Error("data: URL must be base64");
    // The same body cap as the HTTP path — inline payloads must not become
    // the uncapped route (base64 inflates 4/3, so check pre-decode too).
    if (body.length * 0.75 > policy.maxBytes)
      throw new Error(
        `${kind} data: URL exceeds the ${Math.round(policy.maxBytes / 1024 / 1024)} MB cap`,
      );
    return Uint8Array.from(Buffer.from(body, "base64"));
  }
  return (
    await fetchRestrictedHttpBytes(url, kind, policy, {
      rejectHttpErrors: true,
    })
  ).bytes;
}
