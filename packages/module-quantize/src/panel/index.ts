// `<mlx-quantize-panel>`: the quantize wizard as one self-contained custom element. It imports only its data protocol
// (types), its own controller and view and the web kit, draws into its own shadow root (the kit's base vocabulary, then
// the panel's rules) and reaches the backend only through `connection`, so any host mounts it the same way: create the
// element, set `connection`, append it. The shell mounts it unframed: the panel owns its page, heading and scroll.
import { BASE_CSS, shadowStyles } from "@mlx-bun/web-kit";
import type { PanelConnection } from "../protocol";
import { createQuantizeController, type PanelController } from "./controller";
import { MARKUP, STYLE, type WizardStep } from "./view";

// Importing the entry outside a browser (package verification, a server-side inventory) loads without defining the element.
const Base: typeof HTMLElement = (globalThis as { HTMLElement?: typeof HTMLElement }).HTMLElement ?? (class {} as unknown as typeof HTMLElement);

export class QuantizePanel extends Base {
  #connection: PanelConnection = { apiBase: "/api/quantize", eventsUrl: "" };
  readonly #controller: PanelController;
  #initialized = false;

  constructor() {
    super();
    const shadow = this.attachShadow({ mode: "open" });
    const page = document.createElement("div");
    page.className = "page";
    page.innerHTML = MARKUP;
    shadow.append(shadowStyles(STYLE, BASE_CSS), page);
    this.#controller = createQuantizeController(shadow, () => this.#connection);
  }

  get connection(): PanelConnection { return this.#connection; }
  set connection(value: PanelConnection) { this.#connection = value; }

  connectedCallback() {
    if (!this.#initialized) { this.#initialized = true; this.#controller.init(); }
    this.#controller.enter();
  }
  disconnectedCallback() { this.#controller.leave(); }

  /** Where the wizard is, read from its own step rail: the current step's index, the number of steps and its name, or
   * null before the first step shows. Every change raises the kit's `HOST_EVENTS.panelChanged` from the element. */
  currentStep(): WizardStep | null { return this.#controller.currentStep(); }
}

if (typeof customElements !== "undefined" && !customElements.get("mlx-quantize-panel")) customElements.define("mlx-quantize-panel", QuantizePanel);
