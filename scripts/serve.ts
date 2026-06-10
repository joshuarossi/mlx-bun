// Run the OpenAI-compatible server (Josh runs this, not agent sessions):
//
//   bun scripts/serve.ts [--model <dir>] [--port 8090]

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
const server = createServer(ctx, port);
console.log(`mlx-bun serving ${ctx.modelId} at http://localhost:${server.port}/v1 (ready in ${(performance.now() - t0).toFixed(0)} ms)`);
