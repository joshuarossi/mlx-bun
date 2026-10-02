import type { PanelConnection } from "../protocol";
import { createFinetuneController } from "./controller";
import { HTML, STYLE } from "./view";
const Base = globalThis.HTMLElement ?? class {} as typeof HTMLElement;
export class TrainPanel extends Base {
  #connection: PanelConnection = { apiBase: "/api/train", eventsUrl: "" };
  #controller: ReturnType<typeof createFinetuneController>;
  #initialized = false;
  constructor() {
    super();
    const root = this.attachShadow({ mode: "open" });
    root.innerHTML = `<style>${STYLE}</style>${HTML}`;
    this.#controller = createFinetuneController(root, () => this.#connection);
  }
  get connection(): PanelConnection { return this.#connection; }
  set connection(value: PanelConnection) { this.#connection = value; }
  connectedCallback() { if (!this.#initialized) { this.#initialized = true; this.#controller.init(); } else this.#controller.enter(); }
  disconnectedCallback() { this.#controller.leave(); }
}
if (typeof customElements !== "undefined" && !customElements.get("mlx-train-panel")) customElements.define("mlx-train-panel", TrainPanel);
