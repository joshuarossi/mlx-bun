// Run the OpenAI-compatible server (Josh runs this, not agent sessions):
//
//   bun scripts/serve.ts [--model <dir>] [--port 8090]
//                        [--adapter id=dir]...   (mount LoRA adapters)

import { SNAPSHOT } from "../tests/paths";
import { createServer, loadContext } from "../src/server";

const arg = (name: string, dflt: string) => {
  const i = process.argv.indexOf(`--${name}`);
  return i > -1 ? process.argv[i + 1]! : dflt;
};

const modelDir = arg("model", SNAPSHOT);
const port = Number(arg("port", "8090"));

console.log(`loading ${modelDir} ...`);
const t0 = performance.now();
const ctx = await loadContext(modelDir);

for (let i = 0; i < process.argv.length; i++) {
  if (process.argv[i] !== "--adapter") continue;
  const spec = process.argv[i + 1] ?? "";
  const eq = spec.indexOf("=");
  if (eq < 1) throw new Error(`--adapter expects id=dir, got ${JSON.stringify(spec)}`);
  const info = await ctx.adapters.mount(spec.slice(0, eq), spec.slice(eq + 1));
  console.log(`mounted adapter ${info.id} (${info.mountedLayers} layers, rank ${info.rank}, scale ${info.scale})`);
}

const server = createServer(ctx, port);
console.log(`mlx-bun serving ${ctx.modelId} at http://localhost:${server.port}/v1 (ready in ${(performance.now() - t0).toFixed(0)} ms)`);
