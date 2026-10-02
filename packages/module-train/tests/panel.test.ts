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
 const panel = document.createElement("mlx-train-panel") as HTMLElement & { connection: unknown };
 panel.connection = { apiBase: "https://backend/tenant/api/train", eventsUrl: "", ui: { notify: (text: string) => notify.push(text), publish: (_container: HTMLElement, source: unknown) => published.push(source), modelId: () => "served-model", catalogChanged: () => changed++ } };
 document.body.append(panel); await settle(); return panel;
};
const part = (panel: HTMLElement, id: string) => panel.shadowRoot!.getElementById(id)! as HTMLElement;
const value = (panel: HTMLElement, id: string, text: string) => { (part(panel, id) as HTMLInputElement).value = text; };
const click = async (element: HTMLElement) => { element.click(); await settle(); };
test("train panel preserves ORPO configuration, metrics, adapter actions and publishing", async () => {
 answers.set("/tenant/api/finetune/inspect-dataset",{ok:true,n_train:12,n_valid:2,format:"preferences"});answers.set("/tenant/api/finetune/submit",{ok:true,job_id:"train",adapter_path:"/adapters/trained"});
 answers.set("/tenant/api/finetune/merge",{ok:true,merged_path:"/adapters/merged"});answers.set("/tenant/api/finetune/export",{ok:true,export_path:"/exports/export"});
 const panel=await mount();value(panel,"f-model","org/model");await click(part(panel,"f-next0"));value(panel,"f-data","/datasets/pairs");await click(part(panel,"f-inspect"));await click(part(panel,"f-next1"));
 await click(part(panel,"f-method").querySelector('[data-v="orpo"]') as HTMLElement);expect((part(panel,"f-rank") as HTMLInputElement).value).toBe("16");expect((part(panel,"f-lr") as HTMLInputElement).value).toBe("0.00001");
 await click(part(panel,"f-submit"));expect(requests.at(-1)?.body).toMatchObject({model_dir:"org/model",data_dir:"/datasets/pairs",method:"orpo",rank:16,learning_rate:0.00001,sft_scope:"full"});
 const stream=Stream.all.at(-1)!;stream.emit({type:"metric",kind:"train",step:1,loss:2.125,learning_rate:0.00001,tokens_per_sec:12,progress:0.5});expect(part(panel,"f-loss").textContent).toBe("2.1250");expect(part(panel,"f-chart").innerHTML).toContain("path");
 panel.remove();expect(stream.closed).toBe(true);document.body.append(panel);const resumed=Stream.all.at(-1)!;expect(resumed).not.toBe(stream);resumed.emit({type:"done",ts:1});expect(changed).toBe(1);expect((part(panel,"f-merge-a") as HTMLInputElement).value).toBe("/adapters/trained");
 value(panel,"f-merge-b","/adapters/other");await click(part(panel,"f-merge-go"));expect(requests.at(-1)?.body).toEqual({adapter_a:"/adapters/trained",adapter_b:"/adapters/other"});
 await click(part(panel,"f-exp-go"));expect(requests.at(-1)?.url).toBe("https://backend/tenant/api/finetune/export");
 await click(part(panel,"f-push"));expect(published).toEqual([{kind:"finetune",source_path:"/adapters/trained"}]);
});
