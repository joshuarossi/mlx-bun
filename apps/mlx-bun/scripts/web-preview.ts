// Serve the browser app over a fake, model-free backend, for UI development and screenshots on any machine.
//
//   bun apps/mlx-bun/scripts/web-preview.ts [--port 8090] [--scenario default|empty|failing] [--pace 24]
//
// The page, bundle and assets are the real ones (`src/web/assets.ts`, built from source when `dist/web/app.js`
// is missing); every API route, the chat socket and the event streams come from `tests/web/fake-backend.ts`
// and its fixtures. Nothing here loads a model or MLX. In the chat, a prompt containing `/slow` streams a long
// reply (to try Stop), `/fail` ends the reply with the protocol's error frame, and `approve` asks for a tool approval.
import { createWebHandler } from "../src/web/assets";
import { startFakeBackend, type Scenario } from "../tests/web/fake-backend";

function parse(argv: readonly string[]): { port: number; scenario: Scenario; paceMs: number } {
  const options = { port: 8090, scenario: "default" as Scenario, paceMs: 24 };
  for (let i = 0; i < argv.length; i++) {
    const flag = argv[i]!;
    const value = () => { const next = argv[++i]; if (next === undefined) throw new Error(`${flag} needs a value`); return next; };
    if (flag === "--help" || flag === "-h") {
      console.log("Usage: bun apps/mlx-bun/scripts/web-preview.ts [--port 8090] [--scenario default|empty|failing] [--pace 24]\n\n" +
        "Serves the real browser app over a fake backend with fixtures (tests/web/fake-backend.ts). No model loads.\n" +
        "  --scenario  default: a served model, a download in flight, saved chats, a memory vault\n" +
        "              empty: a fresh install with nothing downloaded\n" +
        "              failing: the Hub is offline, jobs fail, the chat errors mid-reply\n" +
        "  --pace      milliseconds between streamed chat deltas and job events (0 streams at once)");
      process.exit(0);
    }
    if (flag === "--port") options.port = Number(value());
    else if (flag === "--scenario") {
      const scenario = value();
      if (scenario !== "default" && scenario !== "empty" && scenario !== "failing") throw new Error(`Unknown scenario ${scenario}`);
      options.scenario = scenario;
    } else if (flag === "--pace") options.paceMs = Number(value());
    else throw new Error(`Unknown option ${flag}; see --help`);
  }
  return options;
}

if (import.meta.main) {
  const options = parse(process.argv.slice(2));
  const web = await createWebHandler();
  const backend = startFakeBackend({ ...options, web });
  console.log(`mlx-bun web preview (${backend.scenario} scenario, no model) at ${backend.url}/`);
}
