import { expect, test } from "bun:test";
import { mkdirSync, mkdtempSync, readdirSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { configureRuntime } from "@mlx-bun/inference/runtime/config";
import type { RunningApp } from "../../src/cli/serve";
import { tone, wavBytes } from "../support/media";

// Opt-in with real weights: the model host keeps models resident by memory fit
// and resumes saved state on a swap. MLX_BUN_TEST_NATIVE=1 with two cached chat
// snapshots (MLX_BUN_APP_TEST_MODEL, MLX_BUN_APP_TEST_MODEL_2; e.g. Qwen2.5-0.5B
// and MiniCPM5-1B, 4-bit) and, for the companion phase, a Whisper checkpoint
// (MLX_BUN_APP_TEST_WHISPER). The same scenario runs in the default isolated mode
// (one worker process per resident model, held by the parent; MLX_BUN_HOME travels
// to the workers in the environment) and with --in-process (the models load in this
// process); the isolated run adds a crash phase. Nothing is downloaded.
const native = process.env.MLX_BUN_TEST_NATIVE === "1";
const dirA = process.env.MLX_BUN_APP_TEST_MODEL, dirB = process.env.MLX_BUN_APP_TEST_MODEL_2, dirW = process.env.MLX_BUN_APP_TEST_WHISPER;

interface Chat { choices: { message: { content: string } }[]; usage: { prompt_tokens: number; prompt_tokens_details: { cached_tokens: number } }; model: string }
interface Stats { models: { current: string; budget_bytes: number; resident_bytes: number; resident: { id: string; bytes: number; state: string; pinned: boolean }[] } }

async function scenario(isolated: boolean) {
  const { startModelServer, parseServeOptions } = await import("../../src/cli/serve");
  const { parseCommand } = await import("../../src/cli/args");
  const { openRegistry } = await import("../../src/storage/paths");
  const { activeMemory, peakMemory, resetPeakMemory } = await import("@mlx-bun/mlx/ffi");
  const root = mkdtempSync(join(tmpdir(), "mlx-model-host-"));
  const restore = configureRuntime({ MLX_BUN_HOME: join(root, "home") });
  // A worker is another process: it inherits the environment, not this process's runtime overrides.
  const previousHome = process.env.MLX_BUN_HOME;
  process.env.MLX_BUN_HOME = join(root, "home");
  mkdirSync(join(root, "project"), { recursive: true });
  const registry = openRegistry();
  await registry.scan();
  const models = registry.listCanonical();
  registry.close();
  const find = (path: string) => models.find(model => model.path === path) ?? (() => { throw new Error(`${path} is not in the registry`); })();
  const a = find(dirA!), b = find(dirB!), whisper = dirW ? find(dirW) : undefined;
  const serve = (flags: string[]) => {
    const options = parseServeOptions(parseCommand("serve", ["--port", "0", "--max-tokens", "24", "--no-open", ...(isolated ? [] : ["--in-process"]), ...flags]));
    options.chatPaths = { cwd: join(root, "project"), agentDir: join(root, "agent"), sessionDir: join(root, "sessions"), toolApprovalsFile: join(root, "approvals.json") };
    options.memoryPaths = { vault: join(root, "vault"), skills: join(root, "skills") };
    options.storagePaths = { jobsDb: join(root, `jobs-${Math.random()}.sqlite`), credentialsFile: join(root, "hf.json"), artifactRoot: join(root, "artifacts") };
    // `runServe` resolves `--whisper-model` into its directory and id before composition.
    if (options.whisper?.model && whisper) options.whisper = { ...options.whisper, modelDir: whisper.path, modelId: whisper.repoId };
    return startModelServer(a, options);
  };
  const chat = async (app: RunningApp, model: string, messages: { role: string; content: string }[]) => {
    const response = await fetch(`http://127.0.0.1:${app.port}/v1/chat/completions`, { method: "POST", headers: { "content-type": "application/json" },
      body: JSON.stringify({ model, max_tokens: 24, temperature: 0, messages }) });
    expect(response.status).toBe(200);
    return await response.json() as Chat;
  };
  const stats = async (app: RunningApp) => await (await fetch(`http://127.0.0.1:${app.port}/stats`)).json() as Stats;
  // The isolated host also lists its Whisper worker as a resident unit (it holds the weights); the in-process host keeps its Whisper companion beside the chat models.
  const ids = (s: Stats) => s.models.resident.map(model => model.id).filter(id => id !== whisper?.repoId).sort();
  const story = "The lighthouse keeper logged the weather every hour: fog at midnight, drizzle by two, a gale at four, and clear skies by dawn. ".repeat(10);
  // A marker first, so a prefix saved by an earlier phase (or the other model) cannot answer this phase's first turn.
  const talk = (id: string, phase = 0) => [{ role: "user", content: `[${id} ${phase}] ${story}\nIn one sentence, what was the weather at four?` }];
  const follow = (history: { role: string; content: string }[], reply: Chat) => [...history, { role: "assistant", content: reply.choices[0]!.message.content }, { role: "user", content: "And by dawn?" }];
  // The follow-up re-renders the assistant turn's opening, so the last few prompt tokens of turn 1 differ from turn 2's.
  const reopened = 8;
  const log: string[] = [`mode: ${isolated ? "isolated workers (default)" : "--in-process"}`];
  let app: RunningApp | undefined;
  try {
    // Phase 1: the budget fits both, so both are resident and serve at the same time.
    app = await serve([]);
    const both = await Promise.all([chat(app, a.repoId, talk("a")), chat(app, b.repoId, talk("b"))]);
    expect([both[0].model, both[1].model]).toEqual([a.repoId, b.repoId]);
    const together = await stats(app);
    expect(ids(together)).toEqual([a.repoId, b.repoId].sort());
    const bytes = new Map(together.models.resident.map(model => [model.id, model.bytes]));
    expect(together.models.resident_bytes).toBeLessThanOrEqual(together.models.budget_bytes);
    const listed = await (await fetch(`http://127.0.0.1:${app.port}/v1/models`)).json() as { data: { id: string; resident?: boolean; current?: boolean }[] };
    expect(listed.data.find(entry => entry.id === a.repoId)).toMatchObject({ resident: true, current: true });
    expect(listed.data.find(entry => entry.id === b.repoId)).toMatchObject({ resident: true, current: false });
    log.push(`phase 1: ${a.repoId} + ${b.repoId} resident together (${((bytes.get(a.repoId)! + bytes.get(b.repoId)!) / 2 ** 30).toFixed(2)} GiB of a ${(together.models.budget_bytes / 2 ** 30).toFixed(1)} GiB budget)`);
    await app.close(); app = undefined;

    // Phase 2: a budget that fits one of them: the other's request drains it, its state is saved, and returning resumes it.
    const budget = Math.max(bytes.get(a.repoId)!, bytes.get(b.repoId)!) * 1.3 / 1e9;
    app = await serve(["--model-budget", String(budget)]);
    const oneA = talk("a", 2), oneB = talk("b", 2);
    const firstA = await chat(app, a.repoId, oneA);
    // Only the chat template's shared header can be cached for a conversation this phase has not had.
    expect(firstA.usage.prompt_tokens_details.cached_tokens).toBeLessThan(firstA.usage.prompt_tokens / 4);
    const firstB = await chat(app, b.repoId, oneB);
    const afterB = await stats(app);
    expect(ids(afterB)).toEqual([b.repoId]);
    expect(afterB.models.resident_bytes).toBeLessThanOrEqual(afterB.models.budget_bytes);
    const backA = await chat(app, a.repoId, follow(oneA, firstA));
    expect(ids(await stats(app))).toEqual([a.repoId]);
    expect(backA.usage.prompt_tokens_details.cached_tokens).toBeGreaterThanOrEqual(firstA.usage.prompt_tokens - reopened);
    const backB = await chat(app, b.repoId, follow(oneB, firstB));
    expect(backB.usage.prompt_tokens_details.cached_tokens).toBeGreaterThanOrEqual(firstB.usage.prompt_tokens - reopened);
    log.push(`phase 2 (budget ${budget.toFixed(2)} GB): A turn 1 prompt ${firstA.usage.prompt_tokens}; after B and back, turn 2 prompt ${backA.usage.prompt_tokens} cached ${backA.usage.prompt_tokens_details.cached_tokens}; ` +
      `B turn 1 prompt ${firstB.usage.prompt_tokens}; after A and back, turn 2 prompt ${backB.usage.prompt_tokens} cached ${backB.usage.prompt_tokens_details.cached_tokens}`);
    log.push(`saved state directories: ${readdirSync(join(root, "home", "kv")).length}`);
    // The hub's serve action switches the current model live, and `local` (Pi's id) follows it.
    const switched = await (await fetch(`http://127.0.0.1:${app.port}/api/hub/serve`, { method: "POST", body: JSON.stringify({ model: a.repoId }) })).json();
    expect(switched).toEqual({ ok: true, model: a.repoId });
    expect((await chat(app, "local", talk("local"))).model).toBe(a.repoId);
    const missing = await fetch(`http://127.0.0.1:${app.port}/api/hub/serve`, { method: "POST", body: JSON.stringify({ model: "org/not-local" }) });
    expect(missing.status).toBe(404);
    await app.close(); app = undefined;

    // Phase 3: a pinned Whisper companion counts against the budget, is never drained, and makes room by draining a chat model.
    if (whisper) {
      if (!isolated) resetPeakMemory();
      app = await serve(["--whisper-model", whisper.path, "--whisper-resident", "--model-budget", String(budget + whisper.sizeBytes / 1e9 + 0.5)]);
      const base = `http://127.0.0.1:${app.port}`;
      const transcribe = async () => {
        const form = new FormData();
        form.set("file", new File([wavBytes(tone(2, 440))], "tone.wav", { type: "audio/wav" }));
        form.set("model", whisper.repoId);
        const response = await fetch(`${base}/v1/audio/transcriptions`, { method: "POST", body: form });
        expect(response.status).toBe(200);
      };
      await chat(app, a.repoId, talk("a", 3));
      await transcribe();
      const stt = async () => ((await (await fetch(`${base}/v1/models`)).json()) as { data: { id: string; resident?: boolean; transcription?: boolean }[] }).data.find(entry => entry.id === whisper.repoId);
      expect(await stt()).toMatchObject({ transcription: true, resident: true });
      if (isolated) expect((await stats(app)).models.resident.find(model => model.id === whisper.repoId)).toMatchObject({ pinned: true, state: "ready" });
      await chat(app, b.repoId, talk("b", 3));
      expect(ids(await stats(app))).toEqual([b.repoId]);
      expect(await stt()).toMatchObject({ resident: true });
      await transcribe();
      await chat(app, a.repoId, follow(oneA, firstA));
      expect(await stt()).toMatchObject({ resident: true });
      log.push(`phase 3: Whisper resident through ${a.repoId} -> ${b.repoId} -> ${a.repoId}` + (isolated ? "" : `; peak active ${(peakMemory() / 2 ** 30).toFixed(2)} GiB, active now ${(activeMemory() / 2 ** 30).toFixed(2)} GiB`));
      await app.close(); app = undefined;
    }

    // Phase 4 (isolated only): the workers are processes. A hub switch through the parent and a request naming the other model
    // swap them, and the saved state resumes; killing a worker mid-request answers that request 502, leaves the other worker and
    // the host up, and the model reloads and resumes.
    if (isolated) {
      app = await serve(["--model-budget", String(budget)]);
      const base = `http://127.0.0.1:${app.port}`;
      interface Report { state: string; workers: { id: string; role: string; pid: number; state: string; restarts: number }[] }
      const engine = async () => await (await fetch(`${base}/engine`)).json() as Report;
      const pidOf = (report: Report, id: string) => report.workers.find(worker => worker.id === id)?.pid;
      const isoA = talk("a", 4), isoB = talk("b", 4);
      const turnA = await chat(app, a.repoId, isoA);
      const pidA = pidOf(await engine(), a.repoId)!;
      const switched = await (await fetch(`${base}/api/hub/serve`, { method: "POST", body: JSON.stringify({ model: b.repoId }) })).json();
      expect(switched).toEqual({ ok: true, model: b.repoId });
      expect((await chat(app, "local", isoB)).model).toBe(b.repoId);
      const drained = await engine();
      expect(drained.workers.map(worker => worker.id)).toEqual([b.repoId]);
      const resumed = await chat(app, a.repoId, follow(isoA, turnA));
      expect(resumed.usage.prompt_tokens_details.cached_tokens).toBeGreaterThanOrEqual(turnA.usage.prompt_tokens - reopened);
      const pidA2 = pidOf(await engine(), a.repoId)!;
      expect(pidA2).not.toBe(pidA);
      log.push(`phase 4a (worker pids A ${pidA} -> ${pidA2}): A turn 1 prompt ${turnA.usage.prompt_tokens}; after a hub switch to B and back, turn 2 prompt ${resumed.usage.prompt_tokens} cached ${resumed.usage.prompt_tokens_details.cached_tokens}`);
      await app.close(); app = undefined;

      // Both fit: kill A's worker mid-request; B's worker and the host are untouched.
      app = await serve([]);
      const url = `http://127.0.0.1:${app.port}`;
      const crashA = talk("a", 5);
      const done = await chat(app, a.repoId, crashA);
      await chat(app, b.repoId, talk("b", 5));
      const before = await (await fetch(`${url}/engine`)).json() as Report;
      const [victim, bystander] = [pidOf(before, a.repoId)!, pidOf(before, b.repoId)!];
      // A long prompt keeps the worker prefilling (about a second) when the kill lands; the answer never begins.
      const bulk = Array.from({ length: 600 }, (_, i) => `Entry ${i}: the keeper logged fog, drizzle, a gale and clear skies at hour ${i}.`).join("\n");
      const hurt = fetch(`${url}/v1/chat/completions`, { method: "POST", headers: { "content-type": "application/json" },
        body: JSON.stringify({ model: a.repoId, max_tokens: 24, temperature: 0, messages: [{ role: "user", content: `[crash ${Math.random()}]\n${bulk}\nSummarize the log.` }] }) });
      await Bun.sleep(300);
      const killedAt = performance.now();
      process.kill(victim, "SIGKILL");
      const failed = await hurt;
      const failure = await failed.text();
      expect(failed.status).toBe(502);
      expect((JSON.parse(failure) as { error: { type: string } }).error.type).toBe("engine_unavailable");
      expect((await fetch(`${url}/health`)).status).toBe(200);
      // The other model keeps answering while A's worker respawns.
      const bystanderAnswer = chat(app, b.repoId, talk("b", 6));
      let recoveredMs = 0;
      for (;;) {
        const report = await (await fetch(`${url}/engine`)).json() as Report;
        if (pidOf(report, a.repoId) !== victim && report.workers.find(worker => worker.id === a.repoId)?.state === "ready") { recoveredMs = performance.now() - killedAt; break; }
        if (performance.now() - killedAt > 120_000) throw new Error("the worker did not respawn");
        await Bun.sleep(50);
      }
      expect((await bystanderAnswer).model).toBe(b.repoId);
      const after = await (await fetch(`${url}/engine`)).json() as Report;
      expect(pidOf(after, b.repoId)).toBe(bystander);
      const again = await chat(app, a.repoId, follow(crashA, done));
      log.push(`phase 4b (SIGKILL A's worker ${victim} mid-request): that request answered 502, B's worker ${bystander} and the host stayed up, A's worker respawned as ${pidOf(after, a.repoId)} `
        + `(${recoveredMs.toFixed(0)} ms from the kill to ready); the follow-up prompt ${again.usage.prompt_tokens} cached ${again.usage.prompt_tokens_details.cached_tokens}`);
      await app.close(); app = undefined;
    }
  } finally {
    await app?.close();
    if (previousHome === undefined) delete process.env.MLX_BUN_HOME; else process.env.MLX_BUN_HOME = previousHome;
    restore();
    rmSync(root, { recursive: true, force: true });
    console.log(log.join("\n"));
  }
}

for (const isolated of [true, false])
  test.skipIf(!native || !dirA || !dirB)(`models stay resident by memory fit, swap through saved state, and a pinned Whisper companion survives the swaps (${isolated ? "isolated workers, the default" : "--in-process"})`,
    () => scenario(isolated), 30 * 60_000);
