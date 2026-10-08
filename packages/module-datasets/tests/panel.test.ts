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
 const panel = document.createElement("mlx-datasets-panel") as HTMLElement & { connection: unknown };
 panel.connection = { apiBase: "https://backend/tenant/api/datasets", eventsUrl: "", ui: { notify: (text: string) => notify.push(text), publish: (_container: HTMLElement, source: unknown) => published.push(source), modelId: () => "served-model", catalogChanged: () => changed++ } };
 document.body.append(panel); await settle(); return panel;
};
const part = (panel: HTMLElement, id: string) => panel.shadowRoot!.getElementById(id)! as HTMLElement;
const value = (panel: HTMLElement, id: string, text: string) => { (part(panel, id) as HTMLInputElement).value = text; };
const click = async (element: HTMLElement) => { element.click(); await settle(); };
test("dataset panel preserves template inputs, active model naming, stream rows and publishing", async () => {
 answers.set("/tenant/api/dataset/templates",{templates:[{id:"synthetic",label:"<b>Template</b>",needs_llm:true,fields:[{name:"count",type:"number",default:3},{name:"topic",type:"textarea",default:"testing"}]}]});
 answers.set("/tenant/api/dataset/submit",{ok:true,job_id:"dataset",output_dir:"/datasets/output"});
 const panel=await mount();expect(part(panel,"d-templates").innerHTML).toContain("&lt;b&gt;Template&lt;/b&gt;");
 await click(part(panel,"d-templates").querySelector("[data-tid]") as HTMLElement);await click(part(panel,"d-submit"));
 expect(requests.at(-1)).toEqual({url:"https://backend/tenant/api/dataset/submit",body:{template_id:"synthetic",inputs:{count:3,topic:"testing"},model_name:"served-model"}});
 const stream=Stream.all.at(-1)!;stream.emit({type:"stage",stage:"generating",n_train:8,n_valid:2,progress:0.5});expect(part(panel,"d-ntrain").textContent).toBe("8");expect(part(panel,"d-pct").textContent).toBe("50%");
 panel.remove();expect(stream.closed).toBe(true);document.body.append(panel);const resumed=Stream.all.at(-1)!;expect(resumed).not.toBe(stream);resumed.emit({type:"done",ts:1,n_train:9,n_valid:1});
 expect(part(panel,"d-ntrain").textContent).toBe("9");expect(part(panel,"d-nvalid").textContent).toBe("1");await click(part(panel,"d-push"));expect(published).toEqual([{kind:"dataset",job_id:"dataset"}]);
});
