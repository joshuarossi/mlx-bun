// The one JSON client. Every `/api/*` and `/v1/*` route answers with an envelope: `ok` and an `error` message on
// failure, the endpoint's own fields on success. OpenAI-style `{error:{message}}` bodies are unwrapped to a plain
// string so callers never print "[object Object]". A panel reaches its module's routes and the root ones it may
// read through `createApi(connection.apiBase)`, which resolves both against the origin the connection names, so
// the same panel works on this page's origin and in a native webview pointed at a remote server.

export interface ApiEnvelope {
  ok?: boolean;
  error?: string;
  message?: string;
  [key: string]: unknown;
}

export interface ApiRequest {
  method?: string;
  /** Sent as JSON unless it is already a string. */
  body?: unknown;
  headers?: Record<string, string>;
  signal?: AbortSignal;
}

/** What a transport failure (no server, a dropped connection) reads as. */
export const UNREACHABLE = "Could not reach the server.";

/** Fetch JSON into an envelope. Throws only on transport failure; an HTTP failure is reflected in the envelope. */
export async function requestJson<T extends ApiEnvelope = ApiEnvelope>(url: string, request: ApiRequest = {}, fetchImpl: typeof fetch = fetch): Promise<T> {
  const { body, headers, method, signal } = request;
  const init: RequestInit = {
    method: method ?? (body === undefined ? "GET" : "POST"),
    headers: { "content-type": "application/json", ...headers },
    ...(signal ? { signal } : {}),
    ...(body !== undefined ? { body: typeof body === "string" ? body : JSON.stringify(body) } : {}),
  };
  const response = await fetchImpl(url, init);
  const text = await response.text();
  let data: ApiEnvelope;
  try { data = text ? JSON.parse(text) : {}; } catch { data = { ok: false, error: text.slice(0, 400) || `HTTP ${response.status}` }; }
  if (data && typeof data === "object" && data.error && typeof data.error === "object") {
    const nested = data.error as { message?: string };
    data.error = nested.message || JSON.stringify(nested).slice(0, 400);
  }
  if (!response.ok && data.ok === undefined) data = { ...data, ok: false, error: (data.error as string | undefined) || data.message || `HTTP ${response.status}` };
  return data as T;
}

export interface Api {
  /** The absolute or origin-relative URL a path resolves to: `/library` is a root path on the connection's origin,
   * `history` a path under the module's base. */
  url(path: string): string;
  /** GET; a transport failure answers `{ ok: false, error: UNREACHABLE }` instead of throwing. */
  get<T extends ApiEnvelope = ApiEnvelope>(path: string, request?: Omit<ApiRequest, "method" | "body">): Promise<T>;
  post<T extends ApiEnvelope = ApiEnvelope>(path: string, body?: unknown, request?: Omit<ApiRequest, "method" | "body">): Promise<T>;
  del<T extends ApiEnvelope = ApiEnvelope>(path: string, body?: unknown, request?: Omit<ApiRequest, "method" | "body">): Promise<T>;
  request<T extends ApiEnvelope = ApiEnvelope>(path: string, request?: ApiRequest): Promise<T>;
}

/** The client over a module's `apiBase` (`/api/<id>`, or an absolute URL in a native webview). */
export function createApi(apiBase: string, options: { fetch?: typeof fetch } = {}): Api {
  const base = apiBase.replace(/\/+$/, "");
  let origin = "";
  try { origin = new URL(base).origin; } catch { /* a relative base: this page's own origin */ }
  const url = (path: string): string => path.startsWith("/") ? origin + path : `${base}/${path}`;
  async function request<T extends ApiEnvelope>(path: string, init: ApiRequest = {}): Promise<T> {
    try { return await requestJson<T>(url(path), init, options.fetch ?? fetch); }
    catch (failure) {
      if (init.signal?.aborted) return { ok: false, error: "cancelled" } as unknown as T;
      return { ok: false, error: UNREACHABLE, cause: failure instanceof Error ? failure.message : String(failure) } as unknown as T;
    }
  }
  return {
    url,
    request,
    get: (path, init) => request(path, { ...init, method: "GET" }),
    post: (path, body, init) => request(path, { ...init, method: "POST", body: body ?? {} }),
    del: (path, body, init) => request(path, { ...init, method: "DELETE", ...(body !== undefined ? { body } : {}) }),
  };
}

/** The message of a failed envelope, with a fallback for a success-shaped body a caller still treats as failure. */
export function errorOf(envelope: ApiEnvelope, fallback = "something went wrong"): string {
  return (typeof envelope.error === "string" && envelope.error) || (typeof envelope.message === "string" && envelope.message) || fallback;
}
