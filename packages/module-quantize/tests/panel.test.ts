// The quantize panel under happy-dom, over a remote backend under a URL prefix: requests are recorded by a fake fetch
// and job streams are the kit's FakeEventSource, so each test decides when an event arrives or the connection drops.
import { afterAll, afterEach, beforeAll, expect, test } from "bun:test";
import { HOST_EVENTS, UNREACHABLE } from "@mlx-bun/web-kit";
import { FakeEventSource } from "@mlx-bun/web-kit/testing";
import { GlobalWindow } from "happy-dom";
const window = new GlobalWindow({ url: "http://host/" });
const globals = ["window", "document", "location", "HTMLElement", "customElements", "CustomEvent", "EventSource", "fetch"] as const;
const saved = new Map(globals.map(name => [name, Object.getOwnPropertyDescriptor(globalThis, name)]));
const requests: { url: string; body?: Record<string, unknown> }[] = [];
let answers = new Map<string, unknown>();
const notify: string[] = [], published: unknown[] = [];
let changed = 0;
beforeAll(async () => {
 Object.assign(globalThis, { window, document: window.document, location: window.location, HTMLElement: window.HTMLElement, customElements: window.customElements, CustomEvent: window.CustomEvent, EventSource: FakeEventSource,
  fetch: async (url: string, init?: RequestInit) => {
   const body = init?.body ? JSON.parse(String(init.body)) : undefined;
   requests.push({ url, body });
   const answer = answers.get(new URL(url).pathname);
   return Response.json(typeof answer === "function" ? await answer() : answer ?? {});
  } });
 await import("../src/panel");
});
afterAll(() => { for (const [name, descriptor] of saved) descriptor ? Object.defineProperty(globalThis, name, descriptor) : delete (globalThis as Record<string, unknown>)[name]; });
afterEach(() => { document.body.replaceChildren(); requests.length = notify.length = published.length = 0; FakeEventSource.reset(); answers.clear(); changed = 0; });
const settle = () => new Promise(resolve => setTimeout(resolve, 5));
type Wizard = HTMLElement & { currentStep(): { index: number; count: number; label: string } | null };
const mount = async () => {
 const panel = document.createElement("mlx-quantize-panel") as Wizard & { connection: unknown };
 panel.connection = { apiBase: "https://backend/tenant/api/quantize", eventsUrl: "", ui: { notify: (text: string) => notify.push(text), publish: (_container: HTMLElement, source: unknown) => published.push(source), modelId: () => "served-model", catalogChanged: () => changed++ } };
 document.body.append(panel); await settle(); return panel;
};
const part = (panel: HTMLElement, id: string) => panel.shadowRoot!.getElementById(id)! as HTMLElement;
const value = (panel: HTMLElement, id: string, text: string) => { (part(panel, id) as HTMLInputElement).value = text; };
const click = async (element: HTMLElement) => { element.click(); await settle(); };
/** The step the rail marks current (as `currentStep()` reads it, from `.s.cur`), and whether it is marked failed. */
const rail = (panel: HTMLElement) => { const current = part(panel, "q-steps").querySelector(".s.cur")!; return { current: current.textContent!.replace(/^\d+/, ""), failed: current.classList.contains("failed") }; };
const shown = (panel: HTMLElement) => [...panel.shadowRoot!.querySelectorAll<HTMLElement>("[data-qstep]")].filter(card => !card.hidden).map(card => card.dataset.qstep);
/** Inspects a supported model and continues to Configure; submissions answer job ids q1, q2, … */
const toConfigure = async (panel: HTMLElement) => { value(panel, "q-model", "org/source"); await click(part(panel, "q-inspect")); await click(part(panel, "q-continue")); };
const jobs = () => { let n = 0; answers.set("/tenant/api/quantize/inspect", { ok: true, support: true, arch: "qwen3", size_gb: 2 }); answers.set("/tenant/api/quantize/submit", () => ({ ok: true, job_id: `q${++n}`, output_dir: "/models/source-4bit" })); };

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
 const first = FakeEventSource.last()!; expect(first.url).toBe("https://backend/tenant/api/jobs/q%2Fa/stream");
 first.emit({ type: "log", line: "packing" }); first.emit({ type: "stage", stage: "quantize", progress: 0.4, message: "Working" });
 expect(part(panel,"q-log").textContent).toBe("packing"); expect(part(panel,"q-pct").textContent).toBe("40%");
 panel.remove(); expect(first.closed).toBe(true); document.body.append(panel); const resumed = FakeEventSource.last()!;
 expect(resumed).not.toBe(first); resumed.emit({ type: "log", line: "packing" }); expect(part(panel,"q-log").textContent).toBe("packing");
 resumed.emit({ type: "done", ts: 1 }); expect(changed).toBe(1); expect(resumed.closed).toBe(true);
 await click(part(panel,"q-push")); expect(published).toEqual([{kind:"quantize",job_id:"q/a"}]);
 panel.remove(); const n = FakeEventSource.instances.length; document.body.append(panel); expect(FakeEventSource.instances).toHaveLength(n);
});
test("quantize inspection failure preserves the wizard and displays the server error", async () => {
 answers.set("/tenant/api/quantize/inspect", { ok:false, error:"bad checkpoint" }); const panel=await mount();value(panel,"q-model","bad");await click(part(panel,"q-inspect"));
 expect(part(panel,"q-inspect-out").textContent).toContain("bad checkpoint");expect(part(panel,"q-inspect").hasAttribute("disabled")).toBe(false);
});

test("leaving while submit is pending defers its job stream until the panel returns", async () => {
 answers.set("/tenant/api/quantize/inspect", {ok:true,support:true});
 let submitted!: (result: unknown) => void;
 answers.set("/tenant/api/quantize/submit", () => new Promise(resolve => { submitted = resolve; }));
 const panel = await mount();value(panel,"q-model","org/model");await click(part(panel,"q-inspect"));await click(part(panel,"q-continue"));
 part(panel,"q-submit").click();await settle();panel.remove();submitted({ok:true,job_id:"pending",output_dir:"/models/output"});await settle();
 expect(FakeEventSource.instances).toHaveLength(0);document.body.append(panel);expect(FakeEventSource.instances).toHaveLength(1);
 expect(FakeEventSource.instances[0]!.url).toBe("https://backend/tenant/api/jobs/pending/stream");
});
test("a backend-only embedding can show errors without a host toast", async () => {
 const panel = document.createElement("mlx-quantize-panel") as HTMLElement & {connection:unknown};
 panel.connection = {apiBase:"https://backend/tenant/api/quantize",eventsUrl:""};document.body.append(panel);
 await click(part(panel,"q-inspect"));expect(part(panel,"panel-message").textContent).toBe("Enter a model id or path first.");
});

test("an unsupported model offers no Continue, and a supported one does", async () => {
 answers.set("/tenant/api/quantize/inspect", { ok: true, support: false, arch: "clip" });
 const panel = await mount(); value(panel, "q-model", "org/vision");
 await click(part(panel, "q-inspect"));
 expect(part(panel, "q-inspect-out").querySelector(".notice.bad")!.textContent).toContain("clip cannot be quantized");
 expect(part(panel, "q-continue").hidden).toBe(true);
 answers.set("/tenant/api/quantize/inspect", { ok: true, support: true, arch: "qwen3", size_gb: 16.25 });
 await click(part(panel, "q-inspect"));
 expect(part(panel, "q-inspect-out").querySelector(".notice.ok")!.textContent).toBe("qwen3 can be quantized. It is 16.3 GB on disk.");
 expect(part(panel, "q-continue").hidden).toBe(false);
});

test("an unreachable server on submit shows the kit's message and keeps the wizard on Configure", async () => {
 jobs(); answers.set("/tenant/api/quantize/submit", () => { throw new TypeError("connection refused"); });
 const panel = await mount(); await toConfigure(panel);
 await click(part(panel, "q-submit"));
 expect(part(panel, "q-submit-out").querySelector(".notice.bad")!.textContent).toContain(UNREACHABLE);
 expect(shown(panel)).toEqual(["1"]); expect(rail(panel).current).toBe("Configure");
 expect(part(panel, "q-submit").hasAttribute("disabled")).toBe(false); expect(FakeEventSource.instances).toHaveLength(0);
});

test("a job that fails mid-way leaves the wizard usable: the failure shows, the rail leaves Run, and a new job starts", async () => {
 jobs(); const panel = await mount(); await toConfigure(panel);
 await click(part(panel, "q-submit"));
 const stream = FakeEventSource.last()!; stream.open();
 stream.emit({ type: "stage", stage: "quantize", progress: 0.3, message: "Quantizing 64 layers" });
 stream.emit({ type: "failed", error: "the worker exited with code 137 (out of memory)", ts: 2 });
 expect(stream.closed).toBe(true); expect(FakeEventSource.open).toEqual([]);
 expect(part(panel, "q-fail").hidden).toBe(false); expect(part(panel, "q-fail").textContent).toContain("code 137 (out of memory)");
 expect(rail(panel)).toEqual({ current: "Run", failed: true }); expect(changed).toBe(0);
 // Returning to the page does not reopen a failed job.
 panel.remove(); document.body.append(panel); expect(FakeEventSource.instances).toHaveLength(1);
 await click(part(panel, "q-retry"));
 expect(shown(panel)).toEqual(["1"]); expect(rail(panel)).toEqual({ current: "Configure", failed: false });
 await click(part(panel, "q-submit"));
 expect(requests.filter(request => request.url.endsWith("/submit"))).toHaveLength(2);
 const next = FakeEventSource.last()!; expect(next).not.toBe(stream); expect(next.url).toBe("https://backend/tenant/api/jobs/q2/stream");
 expect(part(panel, "q-fail").hidden).toBe(true); expect(rail(panel)).toEqual({ current: "Run", failed: false });
 expect(part(panel, "q-log").textContent).toBe(""); expect(part(panel, "q-pct").textContent).toBe("0%");
});

test("leaving closes the stream without cancelling the job; returning reopens it and the replay rebuilds the log", async () => {
 jobs(); const panel = await mount(); await toConfigure(panel);
 await click(part(panel, "q-submit"));
 const stream = FakeEventSource.last()!; stream.open();
 stream.emit({ type: "log", line: "[load] loading weights" }); stream.emit({ type: "log", line: "[quantize] 33% done" });
 const before = requests.length;
 panel.remove();
 expect(FakeEventSource.open).toEqual([]); expect(requests).toHaveLength(before);
 document.body.append(panel);
 expect(FakeEventSource.open).toHaveLength(1);
 const replay = FakeEventSource.last()!; expect(replay).not.toBe(stream); expect(replay.url).toBe(stream.url);
 replay.open();
 for (const line of ["[load] loading weights", "[quantize] 33% done", "[quantize] 66% done"]) replay.emit({ type: "log", line });
 expect(part(panel, "q-log").textContent).toBe("[load] loading weights\n[quantize] 33% done\n[quantize] 66% done");
 expect(rail(panel).current).toBe("Run");
});

test("the terminal end event closes the stream and the done step shows the output; an end with no result fails the run", async () => {
 jobs(); const panel = await mount(); await toConfigure(panel);
 await click(part(panel, "q-submit"));
 const stream = FakeEventSource.last()!; stream.open();
 stream.emit({ type: "stage", stage: "write", progress: 0.9, message: "Writing safetensors" });
 stream.emit({ type: "done", ts: 3, output_dir: "/models/source-4bit-g64" }); stream.emit({}, "end");
 expect(stream.closed).toBe(true); expect(FakeEventSource.open).toEqual([]);
 expect(shown(panel)).toEqual(["3"]); expect(rail(panel).current).toBe("Done");
 expect(part(panel, "q-out").textContent).toBe("/models/source-4bit-g64"); expect(part(panel, "q-pct").textContent).toBe("100%"); expect(changed).toBe(1);
 panel.remove(); document.body.append(panel); expect(FakeEventSource.open).toEqual([]);
 await click(part(panel, "q-again")); await toConfigure(panel); await click(part(panel, "q-submit"));
 const cut = FakeEventSource.last()!; cut.open(); cut.emit({ type: "log", line: "[load] loading weights" }); cut.emit({}, "end");
 expect(cut.closed).toBe(true); expect(part(panel, "q-fail").hidden).toBe(false);
 expect(part(panel, "q-fail-msg").textContent).toBe("The job's event stream ended before the job reported a result.");
 expect(rail(panel)).toEqual({ current: "Run", failed: true }); expect(changed).toBe(1);
});

test("a dropped connection shows a reconnecting note until the next event, and the reconnection's replay replaces the log", async () => {
 jobs(); const panel = await mount(); await toConfigure(panel);
 await click(part(panel, "q-submit"));
 const stream = FakeEventSource.last()!; stream.open();
 stream.emit({ type: "log", line: "[load] loading weights" });
 expect(part(panel, "q-reconnect").hidden).toBe(true);
 stream.fail();
 expect(part(panel, "q-reconnect").hidden).toBe(false); expect(part(panel, "q-reconnect").textContent).toBe("Reconnecting to the job…");
 stream.emit({ type: "stage", stage: "load", progress: 0.1, message: "Loading weights" });
 expect(part(panel, "q-reconnect").hidden).toBe(true); expect(part(panel, "q-msg").textContent).toBe("Loading weights");
 // The browser's own retry reopens the same stream and the server replays the job from its first event.
 stream.fail(); expect(part(panel, "q-reconnect").hidden).toBe(false);
 stream.open(); expect(part(panel, "q-reconnect").hidden).toBe(true);
 stream.emit({ type: "log", line: "[load] loading weights" }); stream.emit({ type: "log", line: "[calibrate] measuring" });
 expect(part(panel, "q-log").textContent).toBe("[load] loading weights\n[calibrate] measuring");
 expect(FakeEventSource.instances).toHaveLength(1); expect(stream.closed).toBe(false);
});

test("currentStep() reads the element's own rail, and each step it shows raises the host's panel-changed event", async () => {
 jobs(); const seen: unknown[] = [];
 const record = (event: Event) => seen.push((event.target as Wizard).currentStep()?.label);
 document.addEventListener(HOST_EVENTS.panelChanged, record);
 try {
  expect((document.createElement("mlx-quantize-panel") as Wizard).currentStep()).toBeNull(); // no rail before it attaches
  const panel = await mount();
  expect(panel.currentStep()).toEqual({ index: 0, count: 4, label: "Source" });
  await toConfigure(panel);
  expect(panel.currentStep()).toEqual({ index: 1, count: 4, label: "Configure" });
  await click(part(panel, "q-submit"));
  const stream = FakeEventSource.last()!; stream.open(); stream.emit({ type: "done", ts: 1, output_dir: "/models/out" });
  expect(panel.currentStep()).toEqual({ index: 3, count: 4, label: "Done" });
  expect(seen).toEqual(["Source", "Configure", "Run", "Done"]);
 } finally { document.removeEventListener(HOST_EVENTS.panelChanged, record); }
});
