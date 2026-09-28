// Standalone runner for the Docker Python verifier that the verified_code
// dataset template uses (src/dataset/python-verifier.ts).
import { readFileSync } from "node:fs";
import { parseArgs } from "node:util";
import { createPythonVerifier } from "../src/dataset/python-verifier";

const USAGE = `Verify one Python program in the Docker verifier used by verified_code.

  bun apps/mlx-bun/scripts/verify-python.ts [--image <repo@sha256:digest>] [file | -]

Reads the program from the file, or from stdin without one. Prints the result
as JSON and exits 0 (verified), 1 (failed) or 2 (unverified); 64 on a usage error.
--image replaces PYTHON_VERIFIER_IMAGE; it must be pinned by digest and already
present for linux/arm64, because nothing is pulled. DOCKER_HOST, when set,
selects the daemon; no other environment reaches docker. SIGINT or SIGTERM
stops and removes the container. Provisioning the image is described in the app
README's Dataset jobs section.`;

if (import.meta.main) {
  let parsed;
  try {
    parsed = parseArgs({ args: Bun.argv.slice(2), allowPositionals: true, strict: true,
      options: { image: { type: "string" }, help: { type: "boolean", short: "h" } } });
    if (parsed.positionals.length > 1) throw new Error("expected at most one file");
  } catch (error) {
    console.error(`${error instanceof Error ? error.message : String(error)}\n\n${USAGE}`);
    process.exit(64);
  }
  if (parsed.values.help) {
    console.log(USAGE);
    process.exit(0);
  }
  const file = parsed.positionals[0];
  const source = !file || file === "-" ? await Bun.stdin.text() : readFileSync(file, "utf8");
  const cancellation = new AbortController();
  const stop = () => cancellation.abort();
  process.on("SIGINT", stop);
  process.on("SIGTERM", stop);
  const verify = createPythonVerifier({ image: parsed.values.image, dockerHost: process.env.DOCKER_HOST });
  const result = await verify(source, cancellation.signal);
  console.log(JSON.stringify(result));
  process.exitCode = result.status === "verified" ? 0 : result.status === "failed" ? 1 : 2;
  process.off("SIGINT", stop);
  process.off("SIGTERM", stop);
}
