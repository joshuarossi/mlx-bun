// The web panel as a browser would run it: pure renderers (escaping, empty states, the fit verdict), and the custom element over
// the module's routes. happy-dom stands in for the browser; fetch is a fake recording what the panel asks.
import { afterAll, afterEach, beforeAll, expect, test } from "bun:test";
import { GlobalWindow } from "happy-dom";
import type { AvailableAdapterRow, DownloadInfo, HubLocalRow, HubSearchRow, LibraryRow, MountedAdapterRow } from "../src/protocol";

let window: GlobalWindow;
const requests: { method: string; url: string; body?: unknown }[] = [];
let state: {
  local: HubLocalRow[]; library: Partial<LibraryRow>[]; results: HubSearchRow[]; offline: boolean; downloads: DownloadInfo[];
  available: AvailableAdapterRow[]; mounted: MountedAdapterRow[]; serve: { status: number; body: unknown }; mount: { status: number; body: unknown };
};
const local = (over: Partial<HubLocalRow> = {}): HubLocalRow => ({ repo_id: "mlx-community/gemma-4-e4b-it", model_type: "gemma4", size_bytes: 4 * 2 ** 30, quant_bits: 4, quant_group_size: 64,
  vision: false, supported: true, support_tier: "targeted", assessment: { fits: true, max_safe_context: 8192, predicted_decode_tps: 42 }, ...over });
const adapter = (over: Partial<AvailableAdapterRow> = {}): AvailableAdapterRow => ({ id: "tuned", path: "/adapters/tuned", rank: 8, scale: 1, base_model: "mlx-community/gemma-4-e4b-it", mounted: false, compatible: true, ...over });
const reset = () => { state = { local: [], library: [], results: [], offline: false, downloads: [], available: [], mounted: [],
  serve: { status: 200, body: { ok: true, model: "x" } }, mount: { status: 200, body: { id: "tuned" } } }; };
reset();

const fakeFetch = (async (url: string, init?: RequestInit) => {
  const method = init?.method ?? "GET", path = new URL(url, "http://host").pathname;
  requests.push({ method, url, ...(init?.body ? { body: JSON.parse(String(init.body)) } : {}) });
  const answer = (body: unknown, status = 200) => ({ ok: status < 400, status, text: async () => JSON.stringify(body), json: async () => body });
  if (path === "/api/hub/local") return answer({ ok: true, models: state.local });
  if (path === "/library") return answer({ models: state.library });
  if (path === "/api/hub/search") return answer({ ok: true, offline: state.offline, results: state.results });
  if (path === "/downloads") return answer({ downloads: state.downloads });
  if (path === "/api/hub/serve") return answer(state.serve.body, state.serve.status);
  if (path === "/api/hub/download") return answer({ ok: true, repo: "x", started: true });
  if (path === "/v1/adapters/available") return answer({ adapters: state.available });
  if (path === "/v1/adapters" && method === "GET") return answer({ adapters: state.mounted });
  if (path === "/v1/adapters" && method === "POST") return answer(state.mount.body, state.mount.status);
  if (path.startsWith("/v1/adapters/") && method === "DELETE") return answer({ id: "tuned", removed_layers: 2 });
  throw new Error(`unexpected ${method} ${url}`);
}) as unknown as typeof fetch;

type Panel = HTMLElement & { connection?: { apiBase: string; eventsUrl: string }; refresh(): Promise<void>; search(query: string): Promise<void>; pollDownloads(): Promise<void> };
let render: typeof import("../src/panel");
const GLOBALS = ["window", "document", "HTMLElement", "customElements", "fetch", "Node", "CustomEvent"] as const;
const saved = new Map<string, PropertyDescriptor | undefined>();
beforeAll(async () => {
  for (const name of GLOBALS) saved.set(name, Object.getOwnPropertyDescriptor(globalThis, name));
  window = new GlobalWindow({ url: "http://localhost/" });
  Object.assign(globalThis, { window, document: window.document, HTMLElement: window.HTMLElement, customElements: window.customElements, fetch: fakeFetch, Node: window.Node,
    CustomEvent: window.CustomEvent });
  render = await import("../src/panel");
});
afterAll(() => { for (const [name, descriptor] of saved) descriptor ? Object.defineProperty(globalThis, name, descriptor) : delete (globalThis as Record<string, unknown>)[name]; });
afterEach(() => { document.body.replaceChildren(); requests.length = 0; reset(); });

const settle = () => new Promise(resolve => setTimeout(resolve, 5));
const mount = async (apiBase = "/api/models") => {
  const panel = document.createElement("mlx-models-panel") as Panel;
  panel.connection = { apiBase, eventsUrl: "" };
  document.body.append(panel);
  await settle();
  return panel;
};
const part = (panel: HTMLElement, id: string) => panel.shadowRoot!.getElementById(id)!;
const click = (node: Element) => node.dispatchEvent(new window.Event("click") as unknown as Event);

// ---------------------------------------------------------------- renderers

test("fit verdict: none without an assessment, red when it does not fit, green at 10 tok/s and above, yellow below", () => {
  expect(render.fitVerdict(null)).toBeNull();
  expect(render.fitVerdict({ fits: false, max_safe_context: 8192, predicted_decode_tps: 0 })).toBe("red");
  expect(render.fitVerdict({ fits: true, max_safe_context: 8192, predicted_decode_tps: 10 })).toBe("green");
  expect(render.fitVerdict({ fits: true, max_safe_context: 8192, predicted_decode_tps: 9.9 })).toBe("yellow");
});

test("Model Hub: the downloaded list shows an empty state, escapes a malicious repo id everywhere, and offers Serve only for a supported model", () => {
  expect(render.renderHubLocalHtml([])).toContain("search Hugging Face");
  const html = render.renderHubLocalHtml([local({ repo_id: '"><script>alert(1)</script>/model' })]);
  expect(html).not.toContain("<script>alert(1)</script>");
  expect(html).toContain("&lt;script&gt;");
  expect(render.renderHubLocalHtml([local({ repo_id: "org/supported" })])).toContain("hub-serve-btn");
  const unsupported = render.renderHubLocalHtml([local({ repo_id: "org/unsupported", supported: false, assessment: null })]);
  expect(unsupported).not.toContain("hub-serve-btn");
  expect(unsupported).toContain("unsupported model family");
  expect(render.renderHubLocalHtml([local({ assessment: { fits: true, max_safe_context: 8192, predicted_decode_tps: 42 } })])).toContain("hub-fit-dot green");
  expect(render.renderHubLocalHtml([local({ assessment: { fits: false, max_safe_context: 8192, predicted_decode_tps: 0 } })])).toContain("hub-fit-dot red");
});

test("the served model comes first and is not offered Serve; a loaded one is tagged; the escaped repo id reaches the button's data attribute", () => {
  const running = new Map([["org/b", { serving: true, resident: true }], ["org/c", { serving: false, resident: true }]]);
  const html = render.renderHubLocalHtml([local({ repo_id: "org/a" }), local({ repo_id: "org/b" }), local({ repo_id: "org/c" })], running);
  expect(html.indexOf("org/b")).toBeLessThan(html.indexOf("org/a"));
  const servingRowEnd = html.indexOf("org/a"); // everything before the second row is the serving row
  expect(html.slice(0, servingRowEnd)).not.toContain("hub-serve-btn");
  expect(html.slice(0, servingRowEnd)).toContain("currently serving");
  expect(html.match(/class="hub-serve-btn"/g)).toHaveLength(2);
  // Only a model that is loaded but not served carries the loaded tag.
  expect(html.match(/○ loaded/g)).toHaveLength(1);
  expect(html.slice(html.indexOf("org/c"))).toContain("○ loaded");
  expect(render.renderHubLocalHtml([local({ repo_id: '"><script>alert(1)</script>/model' })])).toContain('class="hub-serve-btn" data-repo="&quot;&gt;&lt;script&gt;');
});

test("Model Hub: search shows an offline note distinct from no results, escapes ids, and marks a repo that is downloading", () => {
  const row = (over: Partial<HubSearchRow> = {}): HubSearchRow => ({ id: "mlx-community/gemma-3-1b-it-4bit", downloads: 5000, likes: 42, size_estimate: null, ...over });
  const offline = render.renderHubSearchHtml([], true, new Set()), empty = render.renderHubSearchHtml([], false, new Set());
  expect(offline).not.toBe(empty);
  expect(offline.toLowerCase()).toContain("hugging face");
  const escaped = render.renderHubSearchHtml([row({ id: '"><script>alert(1)</script>/model' })], false, new Set());
  expect(escaped).not.toContain("<script>alert(1)</script>");
  expect(escaped).toContain("&lt;script&gt;");
  const busy = render.renderHubSearchHtml([row({ id: "org/model" })], false, new Set(["org/model"]));
  expect(busy).toContain("downloading");
  expect(busy).not.toContain("hub-download-btn");
  expect(render.renderHubSearchHtml([row({ id: "org/model" })], false, new Set())).toContain("hub-download-btn");
});

test("adapters: every adapter on disk with what mounting costs, unmount for a mounted one, and the reason an incompatible one is grayed", () => {
  const info = new Map([["tuned", { id: "tuned", path: "/adapters/tuned", rank: 8, scale: 1, size_bytes: 3 * 2 ** 20, mounted_layers: 4, ram_bytes: 2 ** 20 }]]);
  const html = render.renderAdaptersHtml([adapter(), adapter({ id: "foreign", path: "/adapters/foreign", base_model: "org/Other", compatible: false }),
    adapter({ id: "fresh", path: "/adapters/fresh", base_model: null })], info);
  expect(html).toContain('class="ad-unmount" data-id="tuned"');
  expect(html).toContain("disk <b>3.0 MB</b>"); expect(html).toContain("RAM <b>1.0 MB</b>");
  expect(html).toContain("trained for org/Other, not the served model");
  expect(html).not.toContain('data-id="foreign"');
  expect(html).toContain('class="ad-mount" data-id="fresh" data-path="/adapters/fresh"');
  expect(render.renderAdaptersHtml([], new Map())).toContain("No adapters found on disk");
  expect(render.renderAdaptersHtml([adapter({ id: '"><img src=x onerror=1>' })], new Map())).not.toContain("<img");
});

// ---------------------------------------------------------------- the element

test("the element registers under the manifest's tag and loads the models, what is running and the adapters through its connection", async () => {
  expect(customElements.get("mlx-models-panel")).toBeDefined();
  state.local = [local({ repo_id: "org/a" }), local({ repo_id: "org/b" })];
  state.library = [{ repo_id: "org/a", serving: false, resident: false }, { repo_id: "org/b", serving: true, resident: true }];
  state.available = [adapter()]; state.mounted = [];
  const panel = await mount();
  expect(requests.map(request => request.url).sort()).toEqual(["/api/hub/local", "/library", "/v1/adapters", "/v1/adapters/available"]);
  expect(part(panel, "local").textContent).toContain("currently serving");
  expect(part(panel, "local").innerHTML.indexOf("org/b")).toBeLessThan(part(panel, "local").innerHTML.indexOf("org/a"));
  expect(part(panel, "adapters").querySelector(".ad-mount")).not.toBeNull();
});

test("a relative connection reaches the routes on this page's origin; an absolute one on its own", async () => {
  await mount("http://127.0.0.1:9/api/models");
  expect(requests.every(request => request.url.startsWith("http://127.0.0.1:9/"))).toBe(true);
  expect(requests.map(request => new URL(request.url).pathname).sort()).toEqual(["/api/hub/local", "/library", "/v1/adapters", "/v1/adapters/available"]);
});

test("Serve switches through the route, tells the page, and refreshes what is running; a refusal is shown, and a one-model host gets the restart command", async () => {
  state.local = [local({ repo_id: "org/a" })];
  const panel = await mount();
  const changed: string[] = [];
  document.addEventListener(render.MODELS_CHANGED, () => changed.push("changed"));
  state.serve = { status: 400, body: { ok: false, error: "org/a does not fit" } };
  click(part(panel, "local").querySelector(".hub-serve-btn")!);
  await settle();
  expect(requests.filter(request => request.url === "/api/hub/serve").map(request => request.body)).toEqual([{ model: "org/a" }]);
  expect(part(panel, "status").textContent).toBe("Couldn't switch models: org/a does not fit");
  expect(changed).toEqual([]);
  state.serve = { status: 200, body: { ok: false, restart_required: true, command: "mlx-bun serve org/a" } };
  click(part(panel, "local").querySelector(".hub-serve-btn")!);
  await settle();
  expect(part(panel, "restart").className).toContain("show");
  expect(part(panel, "restart").textContent).toContain("mlx-bun serve org/a");
  state.serve = { status: 200, body: { ok: true, model: "org/a" } };
  state.library = [{ repo_id: "org/a", serving: true, resident: true }];
  click(part(panel, "local").querySelector(".hub-serve-btn")!);
  await settle();
  expect(changed).toEqual(["changed"]);
  expect(part(panel, "status").textContent).toBe("Now serving org/a");
  expect(part(panel, "restart").className).toBe("restart");
  expect(part(panel, "local").textContent).toContain("currently serving");
});

test("search is superseded by a newer query, offline is a note not an error, and Download starts a transfer that polling then follows", async () => {
  const panel = await mount();
  state.results = [{ id: "org/tiny", downloads: 3, likes: 1, size_estimate: null }];
  await panel.search("tiny");
  expect(requests.at(-1)!.url).toBe("/api/hub/search?q=tiny");
  click(part(panel, "results").querySelector(".hub-download-btn")!);
  await settle();
  expect(requests.at(-1)).toMatchObject({ method: "POST", url: "/api/hub/download", body: { repo: "org/tiny" } });
  expect(part(panel, "results").querySelector(".hub-row-actions")!.textContent).toBe("downloading…");
  state.downloads = [{ repoId: "org/tiny", state: "active", currentFile: "model.safetensors", receivedBytes: 1, totalBytes: 4 }];
  await panel.pollDownloads();
  expect(part(panel, "results").querySelector(".hub-row-actions")!.textContent).toBe("25%");
  state.downloads = [{ repoId: "org/tiny", state: "error", currentFile: null, receivedBytes: 0, totalBytes: 0, error: "HF API 404" }];
  await panel.pollDownloads();
  expect(part(panel, "results").querySelector(".hub-row-actions")!.textContent).toBe("HF API 404");
  state.offline = true; state.results = [];
  await panel.search("again");
  expect(part(panel, "offline").style.display).toBe("");
  await panel.search("");
  expect(part(panel, "results").textContent).toContain("Type to search");
});

test("mounting and unmounting an adapter go through the routes and the list follows", async () => {
  state.available = [adapter()];
  const panel = await mount();
  click(part(panel, "adapters").querySelector(".ad-mount")!);
  await settle();
  expect(requests.find(request => request.method === "POST" && request.url === "/v1/adapters")!.body).toEqual({ id: "tuned", path: "/adapters/tuned" });
  state.mounted = [{ id: "tuned", path: "/adapters/tuned", rank: 8, scale: 1, size_bytes: 10, mounted_layers: 2, ram_bytes: 5 }];
  await panel.refresh();
  click(part(panel, "adapters").querySelector(".ad-unmount")!);
  await settle();
  expect(requests.at(-3)!).toMatchObject({ method: "DELETE", url: "/v1/adapters/tuned" });
  state.mount = { status: 400, body: { error: { message: "layers do not match" } } };
  state.mounted = [];
  await panel.refresh();
  click(part(panel, "adapters").querySelector(".ad-mount")!);
  await settle();
  expect(part(panel, "status").textContent).toBe("adapter: layers do not match");
});
