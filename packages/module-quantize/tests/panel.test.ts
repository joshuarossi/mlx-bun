import { afterAll, afterEach, beforeAll, expect, test } from "bun:test";
import { GlobalWindow } from "happy-dom";
const window = new GlobalWindow({ url: "http://host/" });
const globals = ["window", "document", "location", "HTMLElement", "customElements", "EventSource", "fetch"] as const;
const saved = new Map(globals.map(name => [name, Object.getOwnPropertyDescriptor(globalThis, name)]));
const requests: { url: string; body?: Record<string, unknown> }[] = [];
let answers = new Map<string, unknown>();
class Stream {
 static all: Stream[] = [];
 onmessage?: (event: { data: string }) => void;
 onerror?: () => void;
 closed = false;
 constructor(readonly url: string) { Stream.all.push(this); }
 addEventListener() {}
 close() { this.closed = true; }
 emit(data: unknown) { this.onmessage?.({ data: JSON.stringify(data) }); }
}
const notify: string[] = [], published: unknown[] = [];
let changed = 0;
beforeAll(async () => {
 Object.assign(globalThis, { window, document: window.document, location: window.location, HTMLElement: window.HTMLElement, customElements: window.customElements, EventSource: Stream,
  fetch: async (url: string, init?: RequestInit) => {
   const body = init?.body ? JSON.parse(String(init.body)) : undefined;
   requests.push({ url, body });
   return Response.json(answers.get(new URL(url).pathname) ?? {});
  } });
 await import("../src/panel");
});
afterAll(() => { for (const [name, descriptor] of saved) descriptor ? Object.defineProperty(globalThis, name, descriptor) : delete (globalThis as Record<string, unknown>)[name]; });
afterEach(() => { document.body.replaceChildren(); requests.length = Stream.all.length = notify.length = published.length = 0; answers.clear(); changed = 0; });
const settle = () => new Promise(resolve => setTimeout(resolve, 5));
const mount = async () => {
 const panel = document.createElement("mlx-quantize-panel") as HTMLElement & { connection: unknown };
 panel.connection = { apiBase: "https://backend/tenant/api/quantize", eventsUrl: "", ui: { notify: (text: string) => notify.push(text), publish: (_container: HTMLElement, source: unknown) => published.push(source), modelId: () => "served-model", catalogChanged: () => changed++ } };
 document.body.append(panel); await settle(); return panel;
};
const part = (panel: HTMLElement, id: string) => panel.shadowRoot!.getElementById(id)! as HTMLElement;
const value = (panel: HTMLElement, id: string, text: string) => { (part(panel, id) as HTMLInputElement).value = text; };
const click = async (element: HTMLElement) => { element.click(); await settle(); };
test("quantize panel owns inspect, mixed configuration, stream progress and publishing on its backend", async () => {
 answers.set("/tenant/api/quantize/inspect", { ok: true, support: true, arch: "<b>Qwen</b>", size_gb: 2 });
 answers.set("/tenant/api/quantize/submit", { ok: true, job_id: "q/a", output_dir: "/models/quantized" });
 const panel = await mount(); value(panel, "q-model", "org/source");
 await click(part(panel, "q-inspect"));
 expect(part(panel,"q-inspect-out").innerHTML).toContain("&lt;b&gt;Qwen&lt;/b&gt;");
 await click(part(panel,"q-continue"));
 await click(part(panel,"q-mode").querySelector('[data-v="mixed"]') as HTMLElement);
 await click(part(panel,"q-submit"));
 expect(requests.at(-1)).toEqual({ url: "https://backend/tenant/api/quantize/submit", body: { model_id: "org/source", bits: 4, group_size: 64, target_bpw: 5, candidate_bits: [4,8] } });
 const first = Stream.all.at(-1)!; expect(first.url).toBe("https://backend/tenant/api/jobs/q%2Fa/stream");
 first.emit({ type: "log", line: "packing" }); first.emit({ type: "stage", stage: "quantize", progress: 0.4, message: "Working" });
 expect(part(panel,"q-log").textContent).toBe("packing"); expect(part(panel,"q-pct").textContent).toBe("40%");
 panel.remove(); expect(first.closed).toBe(true); document.body.append(panel); const resumed = Stream.all.at(-1)!;
 expect(resumed).not.toBe(first); resumed.emit({ type: "log", line: "packing" }); expect(part(panel,"q-log").textContent).toBe("packing");
 resumed.emit({ type: "done", ts: 1 }); expect(changed).toBe(1); expect(resumed.closed).toBe(true);
 await click(part(panel,"q-push")); expect(published).toEqual([{kind:"quantize",job_id:"q/a"}]);
 panel.remove(); const n = Stream.all.length; document.body.append(panel); expect(Stream.all).toHaveLength(n);
});
test("quantize inspection failure preserves the wizard and displays the server error", async () => {
 answers.set("/tenant/api/quantize/inspect", { ok:false, error:"bad checkpoint" }); const panel=await mount();value(panel,"q-model","bad");await click(part(panel,"q-inspect"));
 expect(part(panel,"q-inspect-out").textContent).toContain("bad checkpoint");expect(part(panel,"q-inspect").hasAttribute("disabled")).toBe(false);
});
