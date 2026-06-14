// Headless smoke for the embedded pi paths, run UNDER the compiled
// mlx-bun bundle (build-binary.sh compiles this into a sibling binary so
// process.execPath -> the bundle dir, exactly as pi's by-path asset
// resolvers expect). It proves the bundled pi SDK and its by-path assets
// resolve without a missing-asset crash: the web chat's photon_rs_bg.wasm
// AND the terminal embed's theme/*.json + pi-tui native modifier helper.
// It needs NO model and NO server: a provider/model error is the success
// signal, since we test asset resolution, not a real turn.
//
// Mirrors src/pi-web.ts: same provider id/key/api, same DefaultResourceLoader
// headless flags, same ALL_TOOLS, in-memory auth/registry/sessions.
//
// Exit 0 = SDK + assets loaded. Exit 1 = a real load failure (missing
// asset, unresolved import). The photon check is best-effort: pi degrades
// to null when the wasm is absent, so a null result warns but does not fail.

import { createRequire } from "node:module";
import { existsSync } from "node:fs";
import { homedir } from "node:os";
import { dirname, join } from "node:path";
import {
  AuthStorage,
  createAgentSession,
  DefaultResourceLoader,
  ModelRegistry,
  SessionManager,
  initTheme,
  resizeImage,
} from "@earendil-works/pi-coding-agent";

const PI_PROVIDER_ID = "mlx-bun";
const PI_LOCAL_MODEL_ID = "local";
const PI_API_KEY = "sk-mlx-bun-local";
const PI_API = "openai-completions" as const;
const ALL_TOOLS = ["read", "bash", "edit", "write", "grep", "find", "ls"];

// 1x1 transparent PNG — exercises pi's photon wasm decode/resize path.
const TINY_PNG = Buffer.from(
  "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAC0lEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==",
  "base64",
);

function fail(stage: string, err: unknown): never {
  const msg = err instanceof Error ? err.message : String(err);
  console.error(`[pi-smoke] FAIL at ${stage}: ${msg}`);
  process.exit(1);
}

async function main(): Promise<void> {
  console.error(`[pi-smoke] execPath=${process.execPath}`);

  // ---- Check 1: SDK + resource-loader assets resolve (headless) -------
  // This builds the exact session pi-web.ts builds. Any missing bundled
  // module or by-path asset the headless path touches surfaces here.
  let session;
  try {
    const authStorage = AuthStorage.inMemory();
    authStorage.setRuntimeApiKey(PI_PROVIDER_ID, PI_API_KEY);

    const modelRegistry = ModelRegistry.inMemory(authStorage);
    modelRegistry.registerProvider(PI_PROVIDER_ID, {
      baseUrl: "http://127.0.0.1:1/v1", // deliberately unreachable; never called
      apiKey: PI_API_KEY,
      api: PI_API,
      models: [
        {
          id: PI_LOCAL_MODEL_ID,
          name: "mlx-bun (local)",
          api: PI_API,
          reasoning: false,
          input: ["text"],
          cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
          contextWindow: 32_768,
          maxTokens: 8_192,
        },
      ],
    });

    const model = modelRegistry.find(PI_PROVIDER_ID, PI_LOCAL_MODEL_ID);
    if (!model) throw new Error("model registration failed");

    const cwd = process.cwd();
    const agentDir = join(homedir(), ".mlx-bun", "pi-sessions");

    const resourceLoader = new DefaultResourceLoader({
      cwd,
      agentDir,
      noExtensions: true,
      noSkills: true,
      noPromptTemplates: true,
      noThemes: true,
      noContextFiles: true,
    });
    await resourceLoader.reload();

    const created = await createAgentSession({
      cwd,
      agentDir,
      model,
      modelRegistry,
      authStorage,
      resourceLoader,
      tools: ALL_TOOLS,
      sessionManager: SessionManager.inMemory(cwd),
    });
    session = created.session;
  } catch (err) {
    fail("createAgentSession", err);
  }

  console.error("[pi-smoke] OK: pi SDK + headless resource loader assets resolved");
  try {
    session.dispose();
  } catch {
    /* ignore */
  }

  // ---- Check 2: photon image path (best-effort) -----------------------
  // resizeImage -> worker/in-process -> loadPhoton, which resolves
  // photon_rs_bg.wasm next to process.execPath. A non-null result proves
  // the wasm both resolved AND decoded. A null result is NON-FATAL: pi's
  // `read` tool degrades to a text "[Image omitted]" note, and the web
  // chat provider is text-only anyway. NOTE: @silvia-odwyer/photon-node's
  // wasm-bindgen glue currently fails to decode under Bun (compiled OR
  // plain) with "Unreachable code should not be executed" — a Bun wasm
  // limitation, not an asset-placement problem (the wasm bytes are valid
  // and found). We still ship the wasm: it's pi's documented sidecar and
  // will work once Bun's wasm-bindgen support lands.
  try {
    const result = await resizeImage(new Uint8Array(TINY_PNG), "image/png", {
      maxWidth: 64,
      maxHeight: 64,
    });
    if (result) {
      console.error(
        `[pi-smoke] OK: photon image path live (decoded ${result.originalWidth}x${result.originalHeight})`,
      );
    } else {
      console.error(
        "[pi-smoke] INFO: photon decode unavailable under Bun (known wasm-bindgen" +
          " limitation); read-image degrades gracefully, web chat unaffected",
      );
    }
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    console.error(`[pi-smoke] INFO: photon path errored (non-fatal): ${msg}`);
  }

  // ---- Check 3: terminal (TUI) theme assets resolve -------------------
  // The embedded terminal (src/pi-terminal.ts) calls initTheme() before the
  // TUI; it reads theme/dark.json (+ light.json) from dirname(execPath)/theme.
  // A throw here means the bundled theme assets are missing/broken — that IS
  // load-bearing for `mlx-bun pi`, so fail the build.
  try {
    initTheme("dark", false); // false: no file watcher (must let the process exit)
    console.error("[pi-smoke] OK: pi terminal theme assets resolved (initTheme)");
  } catch (err) {
    fail("initTheme (terminal theme assets)", err);
  }

  // ---- Check 4: pi-tui native modifier helper (best-effort) -----------
  // pi-tui resolves darwin-modifiers.node at dirname(execPath)/native/...
  // (its 3rd candidate). Missing → native modifier detection degrades to
  // false; NON-FATAL, but warn so a dropped asset is visible in the build.
  try {
    const arch = process.arch === "x64" ? "darwin-x64" : `darwin-${process.arch}`;
    const nativePath = join(
      dirname(process.execPath),
      "native", "darwin", "prebuilds", arch, "darwin-modifiers.node",
    );
    if (!existsSync(nativePath)) {
      console.error(`[pi-smoke] INFO: darwin-modifiers.node absent (${nativePath}); modifier keys degrade`);
    } else {
      const req = createRequire(import.meta.url);
      const helper = req(nativePath) as { isModifierPressed?: unknown };
      if (typeof helper?.isModifierPressed === "function") {
        console.error("[pi-smoke] OK: pi-tui native modifier helper loaded");
      } else {
        console.error("[pi-smoke] INFO: darwin-modifiers.node loaded but lacks isModifierPressed");
      }
    }
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    console.error(`[pi-smoke] INFO: native modifier helper load errored (non-fatal): ${msg}`);
  }

  process.exit(0);
}

main().catch((err) => fail("main", err));
