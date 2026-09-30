import type { PanelConnection } from "../protocol";
import { createDatasetController } from "./controller";
import { HTML, STYLE } from "./view";
const Base = globalThis.HTMLElement ?? class {} as typeof HTMLElement;
export class DatasetsPanel extends Base {
  #connection: PanelConnection = { apiBase: "/api/datasets", eventsUrl: "" };
  #controller: ReturnType<typeof createDatasetController>;
  #initialized = false;
  constructor() {
    super();
    const root = this.attachShadow({ mode: "open" });
    root.innerHTML = `<style>${STYLE}</style>${HTML}`;
    this.#controller = createDatasetController(root, () => this.#connection);
  }
  get connection(): PanelConnection { return this.#connection; }
  set connection(value: PanelConnection) { this.#connection = value; }
  connectedCallback() { if (!this.#initialized) { this.#initialized = true; this.#controller.init(); } else this.#controller.enter(); }
  disconnectedCallback() { this.#controller.leave(); }
}
if (typeof customElements !== "undefined" && !customElements.get("mlx-datasets-panel")) customElements.define("mlx-datasets-panel", DatasetsPanel);
