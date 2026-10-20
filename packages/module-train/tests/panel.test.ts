// The fine-tune panel under happy-dom, over a remote backend under a URL prefix: requests are recorded by a fake fetch
// and job streams are the kit's FakeEventSource, so each test decides when an event arrives or the connection drops.
import { afterAll, afterEach, beforeAll, expect, test } from "bun:test";
import { UNREACHABLE } from "@mlx-bun/web-kit";
import { FakeEventSource } from "@mlx-bun/web-kit/testing";
import { GlobalWindow } from "happy-dom";
const window = new GlobalWindow({ url: "http://host/" });
const globals = ["window", "document", "location", "HTMLElement", "customElements", "EventSource", "fetch"] as const;
const saved = new Map(globals.map(name => [name, Object.getOwnPropertyDescriptor(globalThis, name)]));
const requests: { url: string; body?: Record<string, unknown> }[] = [];
let answers = new Map<string, unknown>();
const notify: string[] = [], published: unknown[] = [];
let changed = 0;
beforeAll(async () => {
 Object.assign(globalThis, { window, document: window.document, location: window.location, HTMLElement: window.HTMLElement, customElements: window.customElements, EventSource: FakeEventSource,
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
const mount = async () => {
 const panel = document.createElement("mlx-train-panel") as HTMLElement & { connection: unknown };
 panel.connection = { apiBase: "https://backend/tenant/api/train", eventsUrl: "", ui: { notify: (text: string) => notify.push(text), publish: (_container: HTMLElement, source: unknown) => published.push(source), modelId: () => "served-model", catalogChanged: () => changed++ } };
 document.body.append(panel); await settle(); return panel;
};
const part = (panel: HTMLElement, id: string) => panel.shadowRoot!.getElementById(id)! as HTMLElement;
const value = (panel: HTMLElement, id: string, text: string) => { (part(panel, id) as HTMLInputElement).value = text; };
const click = async (element: HTMLElement) => { element.click(); await settle(); };
/** The step the rail marks current (as the chat assistant reads it, from `.s.cur`), and whether it is marked failed. */
const rail = (panel: HTMLElement) => { const current = part(panel, "f-steps").querySelector(".s.cur")!; return { current: current.textContent!.replace(/^\d+/, ""), failed: current.classList.contains("failed") }; };
const shown = (panel: HTMLElement) => [...panel.shadowRoot!.querySelectorAll<HTMLElement>("[data-fstep]")].filter(card => !card.hidden).map(card => card.dataset.fstep);
/** Walks Base and Dataset to Hyperparameters; submissions answer job ids t1, t2, … */
const toConfigure = async (panel: HTMLElement) => {
 value(panel, "f-model", "org/model"); await click(part(panel, "f-next0"));
 value(panel, "f-data", "/datasets/chat"); await click(part(panel, "f-inspect")); await click(part(panel, "f-next1"));
};
const jobs = () => {
 let n = 0;
 answers.set("/tenant/api/finetune/inspect-dataset", { ok: true, n_train: 1840, n_valid: 204, format: "messages" });
 answers.set("/tenant/api/finetune/submit", () => ({ ok: true, job_id: `t${++n}`, adapter_path: `/adapters/run-${n}` }));
};

test("train panel preserves ORPO configuration, metrics, adapter actions and publishing", async () => {
 answers.set("/tenant/api/finetune/inspect-dataset",{ok:true,n_train:12,n_valid:2,format:"preferences"});answers.set("/tenant/api/finetune/submit",{ok:true,job_id:"train",adapter_path:"/adapters/trained"});
 answers.set("/tenant/api/finetune/merge",{ok:true,merged_path:"/adapters/merged"});answers.set("/tenant/api/finetune/export",{ok:true,export_path:"/exports/export"});
 const panel=await mount();value(panel,"f-model","org/model");await click(part(panel,"f-next0"));value(panel,"f-data","/datasets/pairs");await click(part(panel,"f-inspect"));await click(part(panel,"f-next1"));
 await click(part(panel,"f-method").querySelector('[data-v="orpo"]') as HTMLElement);expect((part(panel,"f-rank") as HTMLInputElement).value).toBe("16");expect((part(panel,"f-lr") as HTMLInputElement).value).toBe("0.00001");
 await click(part(panel,"f-submit"));expect(requests.at(-1)?.body).toMatchObject({model_dir:"org/model",data_dir:"/datasets/pairs",method:"orpo",rank:16,learning_rate:0.00001,sft_scope:"full"});
 const stream=FakeEventSource.last()!;stream.emit({type:"metric",kind:"train",step:1,loss:2.125,learning_rate:0.00001,tokens_per_sec:12,progress:0.5});expect(part(panel,"f-loss").textContent).toBe("2.1250");expect(part(panel,"f-chart").innerHTML).toContain("path");
 panel.remove();expect(stream.closed).toBe(true);document.body.append(panel);const resumed=FakeEventSource.last()!;expect(resumed).not.toBe(stream);resumed.emit({type:"done",ts:1});expect(changed).toBe(1);expect((part(panel,"f-merge-a") as HTMLInputElement).value).toBe("/adapters/trained");
 value(panel,"f-merge-b","/adapters/other");await click(part(panel,"f-merge-go"));expect(requests.at(-1)?.body).toEqual({adapter_a:"/adapters/trained",adapter_b:"/adapters/other"});
 await click(part(panel,"f-exp-go"));expect(requests.at(-1)?.url).toBe("https://backend/tenant/api/finetune/export");
 await click(part(panel,"f-push"));expect(published).toEqual([{kind:"finetune",source_path:"/adapters/trained"}]);
});

test("the loss chart draws training loss in the success colour and validation loss in the accent on the code surface", async () => {
 jobs(); const panel = await mount(); await toConfigure(panel); await click(part(panel, "f-submit"));
 expect(part(panel, "f-chart").innerHTML).toBe(""); expect(part(panel, "f-leg-val").hidden).toBe(true);
 const stream = FakeEventSource.last()!; stream.open();
 stream.emit({ type: "metric", kind: "train", step: 10, loss: 2.4 }); stream.emit({ type: "metric", kind: "train", step: 20, loss: 1.9 });
 stream.emit({ type: "metric", kind: "val", step: 20, loss: 2.0 });
 const chart = part(panel, "f-chart");
 expect(chart.querySelectorAll("path.line.train")).toHaveLength(1); expect(chart.querySelectorAll("path.line.val")).toHaveLength(1);
 expect(chart.querySelectorAll("line.rule")).toHaveLength(3); expect(part(panel, "f-leg-val").hidden).toBe(false);
 const css = panel.shadowRoot!.querySelector("style")!.textContent!;
 for (const rule of [".line.train{stroke:var(--ok)}", ".line.val{stroke:var(--accent)}", ".rule{stroke:var(--code-line)", "background:var(--code-bg)"]) expect(css).toContain(rule);
 expect(chart.innerHTML).not.toMatch(/#[0-9a-f]{6}/i);
});

test("an unreachable server on submit shows the kit's message and keeps the wizard on Hyperparameters", async () => {
 jobs(); answers.set("/tenant/api/finetune/submit", () => { throw new TypeError("connection refused"); });
 const panel = await mount(); await toConfigure(panel);
 await click(part(panel, "f-submit"));
 expect(part(panel, "f-submit-out").querySelector(".notice.bad")!.textContent).toContain(UNREACHABLE);
 expect(shown(panel)).toEqual(["2"]); expect(rail(panel).current).toBe("Hyperparameters");
 expect(part(panel, "f-submit").hasAttribute("disabled")).toBe(false); expect(FakeEventSource.instances).toHaveLength(0);
});

test("a job that fails mid-way leaves the wizard usable: the failure shows, the rail leaves Train, and a new job starts", async () => {
 jobs(); const panel = await mount(); await toConfigure(panel);
 await click(part(panel, "f-submit"));
 const stream = FakeEventSource.last()!; stream.open();
 stream.emit({ type: "metric", kind: "train", step: 10, loss: 2.3, progress: 0.02 });
 stream.emit({ type: "failed", error: "the worker exited with code 137 (out of memory)", ts: 2 });
 expect(stream.closed).toBe(true); expect(FakeEventSource.open).toEqual([]);
 expect(part(panel, "f-fail").hidden).toBe(false); expect(part(panel, "f-fail").textContent).toContain("code 137 (out of memory)");
 expect(rail(panel)).toEqual({ current: "Train", failed: true }); expect(changed).toBe(0);
 panel.remove(); document.body.append(panel); expect(FakeEventSource.instances).toHaveLength(1);
 await click(part(panel, "f-retry"));
 expect(shown(panel)).toEqual(["2"]); expect(rail(panel)).toEqual({ current: "Hyperparameters", failed: false });
 await click(part(panel, "f-submit"));
 expect(requests.filter(request => request.url.endsWith("/submit"))).toHaveLength(2);
 const next = FakeEventSource.last()!; expect(next).not.toBe(stream); expect(next.url).toBe("https://backend/tenant/api/jobs/t2/stream");
 expect(part(panel, "f-fail").hidden).toBe(true); expect(rail(panel)).toEqual({ current: "Train", failed: false });
 expect(part(panel, "f-chart").innerHTML).toBe(""); expect(part(panel, "f-loss").textContent).toBe("—");
});

test("leaving closes the stream without cancelling the job; returning reopens it and the replay rebuilds the log and chart", async () => {
 jobs(); const panel = await mount(); await toConfigure(panel);
 await click(part(panel, "f-submit"));
 const stream = FakeEventSource.last()!; stream.open();
 const replay = [{ type: "log", line: "loaded weights" }, { type: "metric", kind: "train", step: 10, loss: 2.3 }, { type: "metric", kind: "train", step: 20, loss: 2.1 }];
 for (const event of replay) stream.emit(event);
 const before = requests.length;
 panel.remove();
 expect(FakeEventSource.open).toEqual([]); expect(requests).toHaveLength(before);
 document.body.append(panel);
 expect(FakeEventSource.open).toHaveLength(1);
 const again = FakeEventSource.last()!; expect(again).not.toBe(stream); expect(again.url).toBe("https://backend/tenant/api/jobs/t1/stream");
 again.open();
 for (const event of [...replay, { type: "metric", kind: "train", step: 30, loss: 1.95 }]) again.emit(event);
 expect(part(panel, "f-log").textContent).toBe("loaded weights");
 expect(part(panel, "f-chart").querySelector("path.line.train")!.getAttribute("d")!.split("L")).toHaveLength(3);
 expect(part(panel, "f-step").textContent).toBe("30"); expect(rail(panel).current).toBe("Train");
});

test("the terminal end event closes the stream and the done step shows the adapter; an end with no result fails the run", async () => {
 jobs(); const panel = await mount(); await toConfigure(panel);
 await click(part(panel, "f-submit"));
 const stream = FakeEventSource.last()!; stream.open();
 stream.emit({ type: "stage", stage: "save", progress: 0.99, message: "Saving the adapter" });
 stream.emit({ type: "done", ts: 3, output_dir: "/adapters/run-1-final" }); stream.emit({}, "end");
 expect(stream.closed).toBe(true); expect(FakeEventSource.open).toEqual([]);
 expect(shown(panel)).toEqual(["4"]); expect(rail(panel).current).toBe("Done");
 expect(part(panel, "f-out").textContent).toBe("/adapters/run-1-final"); expect((part(panel, "f-exp-adapter") as HTMLInputElement).value).toBe("/adapters/run-1-final");
 expect((part(panel, "f-exp-base") as HTMLInputElement).value).toBe("org/model"); expect(changed).toBe(1);
 panel.remove(); document.body.append(panel); expect(FakeEventSource.open).toEqual([]);
 await click(part(panel, "f-again")); await toConfigure(panel); await click(part(panel, "f-submit"));
 const cut = FakeEventSource.last()!; cut.open(); cut.emit({ type: "log", line: "loaded weights" }); cut.emit({}, "end");
 expect(cut.closed).toBe(true); expect(part(panel, "f-fail").hidden).toBe(false);
 expect(part(panel, "f-fail-msg").textContent).toBe("The job's event stream ended before the job reported a result.");
 expect(rail(panel)).toEqual({ current: "Train", failed: true }); expect(changed).toBe(1);
});

test("a dropped connection shows a reconnecting note until the next event, and the reconnection's replay replaces the chart", async () => {
 jobs(); const panel = await mount(); await toConfigure(panel);
 await click(part(panel, "f-submit"));
 const stream = FakeEventSource.last()!; stream.open();
 stream.emit({ type: "metric", kind: "train", step: 10, loss: 2.3 });
 stream.fail();
 expect(part(panel, "f-reconnect").hidden).toBe(false); expect(part(panel, "f-reconnect").textContent).toBe("Reconnecting to the job…");
 stream.emit({ type: "metric", kind: "train", step: 20, loss: 2.2 });
 expect(part(panel, "f-reconnect").hidden).toBe(true); expect(part(panel, "f-step").textContent).toBe("20");
 stream.fail(); stream.open(); expect(part(panel, "f-reconnect").hidden).toBe(true);
 stream.emit({ type: "metric", kind: "train", step: 10, loss: 2.3 });
 expect(part(panel, "f-chart").querySelector("path.line.train")!.getAttribute("d")!.split("L")).toHaveLength(1);
 expect(FakeEventSource.instances).toHaveLength(1); expect(stream.closed).toBe(false);
});
