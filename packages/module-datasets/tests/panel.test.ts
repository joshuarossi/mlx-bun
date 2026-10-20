// The dataset panel under happy-dom, over a remote backend under a URL prefix: requests are recorded by a fake fetch
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
 const panel = document.createElement("mlx-datasets-panel") as Wizard & { connection: unknown };
 panel.connection = { apiBase: "https://backend/tenant/api/datasets", eventsUrl: "", ui: { notify: (text: string) => notify.push(text), publish: (_container: HTMLElement, source: unknown) => published.push(source), modelId: () => "served-model", catalogChanged: () => changed++ } };
 document.body.append(panel); await settle(); return panel;
};
const part = (panel: HTMLElement, id: string) => panel.shadowRoot!.getElementById(id)! as HTMLElement;
const value = (panel: HTMLElement, id: string, text: string) => { (part(panel, id) as HTMLInputElement).value = text; };
const click = async (element: HTMLElement) => { element.click(); await settle(); };
/** The step the rail marks current (as `currentStep()` reads it, from `.s.cur`), and whether it is marked failed. */
const rail = (panel: HTMLElement) => { const current = part(panel, "d-steps").querySelector(".s.cur")!; return { current: current.textContent!.replace(/^\d+/, ""), failed: current.classList.contains("failed") }; };
const shown = (panel: HTMLElement) => [...panel.shadowRoot!.querySelectorAll<HTMLElement>("[data-dstep]")].filter(card => !card.hidden).map(card => card.dataset.dstep);
const TEMPLATES = { templates: [
 { id: "synthetic", label: "Synthetic instructions", needs_llm: true, output_format: "messages", fields: [{ name: "topic", type: "text", label: "Topic", required: true }, { name: "count", type: "number", label: "Rows", default: 200 }] },
 { id: "qa", label: "SFT from QA pairs", needs_llm: false, fields: [{ name: "pairs_text", type: "textarea", label: "Pairs", hint: "Q: …\nA: …" }] },
] };
/** Templates load; submissions answer job ids d1, d2, … */
const jobs = () => { let n = 0; answers.set("/tenant/api/dataset/templates", TEMPLATES); answers.set("/tenant/api/dataset/submit", () => ({ ok: true, job_id: `d${++n}`, output_dir: `/datasets/job-${n}` })); };
/** Picks the offline template and continues to Inputs. */
const toInputs = async (panel: HTMLElement) => { await click(part(panel, "d-templates").querySelector('[data-tid="qa"]') as HTMLElement); value(panel, "d-field-0", "Q: a\nA: b"); };

test("dataset panel preserves template inputs, active model naming, stream rows and publishing", async () => {
 answers.set("/tenant/api/dataset/templates",{templates:[{id:"synthetic",label:"<b>Template</b>",needs_llm:true,fields:[{name:"count",type:"number",default:3},{name:"topic",type:"textarea",default:"testing"}]}]});
 answers.set("/tenant/api/dataset/submit",{ok:true,job_id:"dataset",output_dir:"/datasets/output"});
 const panel=await mount();expect(part(panel,"d-templates").innerHTML).toContain("&lt;b&gt;Template&lt;/b&gt;");
 await click(part(panel,"d-templates").querySelector("[data-tid]") as HTMLElement);await click(part(panel,"d-submit"));
 expect(requests.at(-1)).toEqual({url:"https://backend/tenant/api/dataset/submit",body:{template_id:"synthetic",inputs:{count:3,topic:"testing"},model_name:"served-model"}});
 const stream=FakeEventSource.last()!;stream.emit({type:"stage",stage:"generating",n_train:8,n_valid:2,progress:0.5});expect(part(panel,"d-ntrain").textContent).toBe("8");expect(part(panel,"d-pct").textContent).toBe("50%");
 panel.remove();expect(stream.closed).toBe(true);document.body.append(panel);const resumed=FakeEventSource.last()!;expect(resumed).not.toBe(stream);resumed.emit({type:"done",ts:1,n_train:9,n_valid:1});
 expect(part(panel,"d-ntrain").textContent).toBe("9");expect(part(panel,"d-nvalid").textContent).toBe("1");await click(part(panel,"d-push"));expect(published).toEqual([{kind:"dataset",job_id:"dataset"}]);
});

test("the template grid shows placeholders while loading, offline templates first, and typed fields for the chosen one", async () => {
 let answer!: (value: unknown) => void;
 answers.set("/tenant/api/dataset/templates", () => new Promise(resolve => { answer = resolve; }));
 const panel = await mount();
 expect(part(panel, "d-templates").querySelectorAll(".tpl.loading .skeleton").length).toBeGreaterThan(0); expect(part(panel, "d-templates").getAttribute("aria-busy")).toBe("true");
 answer(TEMPLATES); await settle();
 expect([...part(panel, "d-templates").querySelectorAll<HTMLElement>("[data-tid]")].map(tile => tile.dataset.tid)).toEqual(["qa", "synthetic"]);
 expect(part(panel, "d-templates").querySelector('[data-tid="synthetic"] .tag.accent')!.textContent).toBe("Uses the served model");
 await click(part(panel, "d-templates").querySelector('[data-tid="synthetic"]') as HTMLElement);
 expect(rail(panel).current).toBe("Inputs"); expect(part(panel, "d-form-title").textContent).toBe("Synthetic instructions");
 expect(part(panel, "d-model-note").hidden).toBe(false); expect(part(panel, "d-model-note").textContent).toContain("served-model");
 expect((part(panel, "d-field-0") as HTMLInputElement).type).toBe("text"); expect(part(panel, "d-field-0").closest(".field")!.querySelector(".req")!.textContent).toBe("Required");
 expect((part(panel, "d-field-1") as HTMLInputElement).type).toBe("number"); expect((part(panel, "d-field-1") as HTMLInputElement).value).toBe("200");
 await click(panel.shadowRoot!.querySelector("[data-dback]") as HTMLElement);
 await click(part(panel, "d-templates").querySelector('[data-tid="qa"]') as HTMLElement);
 expect(part(panel, "d-field-0").tagName).toBe("TEXTAREA"); expect(part(panel, "d-model-note").hidden).toBe(true);
});

test("no templates shows an empty state that says what to do, and a failed load can be retried", async () => {
 answers.set("/tenant/api/dataset/templates", { templates: [] });
 const panel = await mount();
 expect(part(panel, "d-templates").querySelector(".empty h3")!.textContent).toBe("No dataset templates");
 answers.set("/tenant/api/dataset/templates", () => { throw new TypeError("connection refused"); });
 await click(part(panel, "d-templates").querySelector("[data-reload]") as HTMLElement);
 expect(part(panel, "d-templates").querySelector(".notice.bad")!.textContent).toContain(UNREACHABLE);
 answers.set("/tenant/api/dataset/templates", TEMPLATES);
 await click(part(panel, "d-templates").querySelector("[data-reload]") as HTMLElement);
 expect(part(panel, "d-templates").querySelectorAll("[data-tid]")).toHaveLength(2);
});

test("an unreachable server on submit shows the kit's message and keeps the wizard on Inputs", async () => {
 jobs(); answers.set("/tenant/api/dataset/submit", () => { throw new TypeError("connection refused"); });
 const panel = await mount(); await toInputs(panel);
 await click(part(panel, "d-submit"));
 expect(part(panel, "d-submit-out").querySelector(".notice.bad")!.textContent).toContain(UNREACHABLE);
 expect(shown(panel)).toEqual(["1"]); expect(rail(panel).current).toBe("Inputs");
 expect(part(panel, "d-submit").hasAttribute("disabled")).toBe(false); expect(FakeEventSource.instances).toHaveLength(0);
});

test("a job that fails mid-way leaves the wizard usable: the failure shows, the rail leaves Generate, and a new job starts", async () => {
 jobs(); const panel = await mount(); await toInputs(panel);
 await click(part(panel, "d-submit"));
 expect(requests.at(-1)!.body).toEqual({ template_id: "qa", inputs: { pairs_text: "Q: a\nA: b" } });
 const stream = FakeEventSource.last()!; stream.open();
 stream.emit({ type: "stage", stage: "generate", progress: 0.3, message: "Writing rows" });
 stream.emit({ type: "failed", error: "the served model stopped answering", ts: 2 });
 expect(stream.closed).toBe(true); expect(FakeEventSource.open).toEqual([]);
 expect(part(panel, "d-fail").hidden).toBe(false); expect(part(panel, "d-fail").textContent).toContain("the served model stopped answering");
 expect(rail(panel)).toEqual({ current: "Generate", failed: true });
 panel.remove(); document.body.append(panel); expect(FakeEventSource.instances).toHaveLength(1);
 await click(part(panel, "d-retry"));
 expect(shown(panel)).toEqual(["1"]); expect(rail(panel)).toEqual({ current: "Inputs", failed: false });
 expect((part(panel, "d-field-0") as HTMLTextAreaElement).value).toBe("Q: a\nA: b");
 await click(part(panel, "d-submit"));
 expect(requests.filter(request => request.url.endsWith("/submit"))).toHaveLength(2);
 const next = FakeEventSource.last()!; expect(next).not.toBe(stream); expect(next.url).toBe("https://backend/tenant/api/jobs/d2/stream");
 expect(part(panel, "d-fail").hidden).toBe(true); expect(rail(panel)).toEqual({ current: "Generate", failed: false });
});

test("leaving closes the stream without cancelling the job; returning reopens it and the replay rebuilds the log", async () => {
 jobs(); const panel = await mount(); await toInputs(panel);
 await click(part(panel, "d-submit"));
 const stream = FakeEventSource.last()!; stream.open();
 stream.emit({ type: "log", line: "[parse] parsing the input" }); stream.emit({ type: "log", line: "[generate] 33% done" });
 const before = requests.length;
 panel.remove();
 expect(FakeEventSource.open).toEqual([]); expect(requests).toHaveLength(before);
 document.body.append(panel);
 expect(FakeEventSource.open).toHaveLength(1);
 const replay = FakeEventSource.last()!; expect(replay).not.toBe(stream); expect(replay.url).toBe("https://backend/tenant/api/jobs/d1/stream");
 replay.open();
 for (const line of ["[parse] parsing the input", "[generate] 33% done", "[generate] 66% done"]) replay.emit({ type: "log", line });
 expect(part(panel, "d-log").textContent).toBe("[parse] parsing the input\n[generate] 33% done\n[generate] 66% done");
 expect(rail(panel).current).toBe("Generate");
});

test("the terminal end event closes the stream and the done step shows the output; an end with no result fails the run", async () => {
 jobs(); const panel = await mount(); await toInputs(panel);
 await click(part(panel, "d-submit"));
 const stream = FakeEventSource.last()!; stream.open();
 stream.emit({ type: "stage", stage: "write", progress: 0.9, message: "Writing JSONL", n_train: 170 });
 stream.emit({ type: "done", ts: 3, output_dir: "/datasets/job-1-final", n_train: 180, n_valid: 20 }); stream.emit({}, "end");
 expect(stream.closed).toBe(true); expect(FakeEventSource.open).toEqual([]);
 expect(shown(panel)).toEqual(["3"]); expect(rail(panel).current).toBe("Done");
 expect(part(panel, "d-out").textContent).toBe("/datasets/job-1-final");
 expect(part(panel, "d-ntrain").textContent).toBe("180"); expect(part(panel, "d-nvalid").textContent).toBe("20");
 panel.remove(); document.body.append(panel); expect(FakeEventSource.open).toEqual([]);
 await click(part(panel, "d-again")); await toInputs(panel); await click(part(panel, "d-submit"));
 const cut = FakeEventSource.last()!; cut.open(); cut.emit({ type: "log", line: "[parse] parsing the input" }); cut.emit({}, "end");
 expect(cut.closed).toBe(true); expect(part(panel, "d-fail").hidden).toBe(false);
 expect(part(panel, "d-fail-msg").textContent).toBe("The job's event stream ended before the job reported a result.");
 expect(rail(panel)).toEqual({ current: "Generate", failed: true });
});

test("a dropped connection shows a reconnecting note until the next event, and the reconnection's replay replaces the log", async () => {
 jobs(); const panel = await mount(); await toInputs(panel);
 await click(part(panel, "d-submit"));
 const stream = FakeEventSource.last()!; stream.open();
 stream.emit({ type: "log", line: "[parse] parsing the input" });
 stream.fail();
 expect(part(panel, "d-reconnect").hidden).toBe(false); expect(part(panel, "d-reconnect").textContent).toBe("Reconnecting to the job…");
 stream.emit({ type: "stage", stage: "generate", progress: 0.4, message: "Writing rows" });
 expect(part(panel, "d-reconnect").hidden).toBe(true); expect(part(panel, "d-pct").textContent).toBe("40%");
 stream.fail(); stream.open(); expect(part(panel, "d-reconnect").hidden).toBe(true);
 stream.emit({ type: "log", line: "[parse] parsing the input" });
 expect(part(panel, "d-log").textContent).toBe("[parse] parsing the input");
 expect(FakeEventSource.instances).toHaveLength(1); expect(stream.closed).toBe(false);
});

test("currentStep() reads the element's own rail, and each step it shows raises the host's panel-changed event", async () => {
 jobs(); const seen: unknown[] = [];
 const record = (event: Event) => seen.push((event.target as Wizard).currentStep()?.label);
 document.addEventListener(HOST_EVENTS.panelChanged, record);
 try {
  expect((document.createElement("mlx-datasets-panel") as Wizard).currentStep()).toBeNull(); // no rail before it attaches
  const panel = await mount();
  expect(panel.currentStep()).toEqual({ index: 0, count: 4, label: "Template" });
  await toInputs(panel);
  expect(panel.currentStep()).toEqual({ index: 1, count: 4, label: "Inputs" });
  expect(seen).toEqual(["Template", "Inputs"]);
 } finally { document.removeEventListener(HOST_EVENTS.panelChanged, record); }
});
