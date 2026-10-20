// The host's Status page: a library refresh asked for from elsewhere (a quantize or training job finished) before the
// page was ever shown has no markup to draw into and must do nothing, not reject; after the first visit it reloads the
// table at once. Model-free: happy-dom and the kit's fake fetch.
import "./dom-setup";
import { expect, test } from "bun:test";
import { fakeFetch, installFakes } from "@mlx-bun/web-kit/testing";
import { createStatusController } from "../../src/web/browser/status";

const settle = () => new Promise((resolve) => setTimeout(resolve, 0));

test("a library refresh before the Status page's first visit is a no-op; after it, the table loads at once", async () => {
  document.body.innerHTML = '<section data-route="status" id="s-status"></section>';
  const fetchImpl = fakeFetch({ "/library": { ok: true, models: [
    { repo_id: "mlx-community/Qwen2.5-0.5B-Instruct-4bit", size_bytes: 3e8, serving: true, supported: true, model_type: "qwen2", assessment: { fits: true, max_safe_context: 4096 } },
  ] } });
  const restore = installFakes({ fetch: fetchImpl });
  try {
    const status = createStatusController();
    status.refreshLibrary(); // a job finished while the page was never shown
    await settle();
    expect(fetchImpl.calls).toEqual([]); // nothing to draw into: nothing fetched, nothing thrown
    expect(document.getElementById("st-lib-body")).toBeNull();
    status.init();
    status.refreshLibrary();
    await settle();
    expect(fetchImpl.calls.map((call) => call.url)).toEqual(["/library"]);
    expect(document.getElementById("st-lib-body")!.textContent).toContain("Qwen2.5-0.5B-Instruct-4bit");
  } finally {
    restore();
  }
});
