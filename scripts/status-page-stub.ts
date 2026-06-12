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
    if (path === "/fit")
      return Response.json({
        machine: { ram_bytes: 24 * 2 ** 30, bandwidth_gbs: 273 },
        context_tokens: 65536,
        report: {
          fits: true, weights_bytes: 8_400_000_000, kv_bytes: 3_100_000_000,
          transient_bytes: 1_150_000_000, total_bytes: 12_650_000_000,
          usable_bytes: 18_000_000_000, max_safe_context: 65536,
          predicted_decode_tps: 25.3,
        },
        sku_matrix_ctx: 32768,
        sku_matrix: [
          { sku: "M2", ram_gb: 8, fits: false, max_context: 0, decode_tps: 0 },
          { sku: "M2", ram_gb: 16, fits: true, max_context: 9800, decode_tps: 9 },
          { sku: "M4", ram_gb: 16, fits: true, max_context: 10400, decode_tps: 11 },
          { sku: "M4 Pro", ram_gb: 24, fits: true, max_context: 70000, decode_tps: 25 },
          { sku: "M4 Pro", ram_gb: 48, fits: true, max_context: 131072, decode_tps: 26 },
          { sku: "M4 Max", ram_gb: 64, fits: true, max_context: 131072, decode_tps: 49 },
          { sku: "M3 Ultra", ram_gb: 96, fits: true, max_context: 131072, decode_tps: 74 },
        ],
      });
    if (path === "/downloads")
      return Response.json({
        downloads: [
          {
            repoId: "mlx-community/gemma-4-12B-it-OptiQ-4bit", state: "active",
            currentFile: "model-00002-of-00002.safetensors",
            receivedBytes: 3_600_000_000, totalBytes: 8_400_000_000,
            filesDone: 7, filesTotal: 12, bytesPerSec: 38_500_000,
            startedAt: Date.now() - 95_000, finishedAt: null,
          },
          {
            repoId: "mlx-community/gemma-4-e4b-it-OptiQ-4bit", state: "done",
            currentFile: null, receivedBytes: 6_550_000_000, totalBytes: 6_550_000_000,
            filesDone: 9, filesTotal: 9, startedAt: Date.now() - 600_000, finishedAt: Date.now() - 280_000,
          },
        ],
      });
    if (path === "/library")
      return Response.json({
        models: [
          { repo_id: "mlx-community/gemma-4-26B-A4B-it-OptiQ-4bit", model_type: "gemma4", size_bytes: 17.6e9, quant_bits: 4, vision: true, supported: true, serving: false, assessment: { fits: true, max_safe_context: 21000, predicted_decode_tps: 54 } },
          { repo_id: "mlx-community/gemma-4-12B-it-OptiQ-4bit", model_type: "gemma4_unified", size_bytes: 8.9e9, quant_bits: 4, vision: true, supported: true, serving: true, assessment: { fits: true, max_safe_context: 65536, predicted_decode_tps: 24 } },
          { repo_id: "mlx-community/Qwen3.6-27B-OptiQ-4bit", model_type: "qwen3_5", size_bytes: 18.8e9, quant_bits: 4, vision: false, supported: false, serving: false, assessment: null },
          { repo_id: "mlx-community/gemma-4-e4b-it-OptiQ-4bit", model_type: "gemma4", size_bytes: 6.6e9, quant_bits: 4, vision: true, supported: true, serving: false, assessment: { fits: true, max_safe_context: 131072, predicted_decode_tps: 33 } },
        ],
      });
    if (path === "/v1/models")
      return Response.json({ data: [{ id: "mlx-community/gemma-4-12B-it-OptiQ-4bit", context_window: 131072 }] });
    return new Response("not found", { status: 404 });
  },
});
console.log(`status-page stub on http://localhost:${port}/`);
