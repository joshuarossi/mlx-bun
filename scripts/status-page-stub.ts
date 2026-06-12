// Dev stub for the status page: serves src/status-page.html with a
// /stats + /v1/models payload shaped like the real server, so the page
// can be styled and verified without loading a model.
import statusPageHtml from "../src/status-page.html" with { type: "text" };

const port = Number(process.argv[2] ?? 8099);
Bun.serve({
  port,
  fetch(req) {
    const path = new URL(req.url).pathname;
    if (path === "/" || path === "/status")
      return new Response(statusPageHtml as unknown as string, { headers: { "content-type": "text/html; charset=utf-8" } });
    if (path === "/stats")
      return Response.json({
        prompt_cache: { entries: 3, bytes: 412_000_000, max_bytes: 2_000_000_000, hits: 17, misses: 5 },
        response_store: { entries: 2, bytes: 1_400_000, max_bytes: 33_554_432, ttl_ms: 3_600_000 },
        kv_quant: { mode: "mixed (kv_config.json)", layers: { kv4: 8, kv8: 4, bf16: 36 } },
        admission: {
          max_safe_context: 65536, memory_budget_bytes: null,
          usable_bytes: 18_000_000_000, weights_bytes: 8_400_000_000,
        },
      });
    if (path === "/v1/models")
      return Response.json({ data: [{ id: "mlx-community/gemma-4-12B-it-OptiQ-4bit", context_window: 131072 }] });
    return new Response("not found", { status: 404 });
  },
});
console.log(`status-page stub on http://localhost:${port}/`);
