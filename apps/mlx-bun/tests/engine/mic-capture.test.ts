// The sidecar seam without a microphone: resolution order, the sidecar
// protocol (float32 frames carried across chunk boundaries, control lines on
// stderr), and stop = end stdin, terminate, join (SIGKILL after the grace
// period). Shell scripts stand in for the Swift helper.
import { expect, test } from "bun:test";
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import { configureRuntime } from "@mlx-bun/inference/runtime/config";
import {
  defaultMicCaptureCandidates, MIC_CAPTURE_BINARY, MIC_CAPTURE_STAGED, resolveMicCapture, startMicCapture, type MicEvent,
} from "../../src/engine/mic-capture";

async function waitFor(predicate: () => boolean, timeoutMs = 5000): Promise<void> {
  const deadline = Date.now() + timeoutMs;
  while (!predicate()) { if (Date.now() > deadline) throw new Error("timed out waiting"); await Bun.sleep(1); }
}

test("resolution: the env override as given, then beside the executable, then the staged build, otherwise unavailable without compiling", async () => {
  const dir = mkdtempSync(join(tmpdir(), "mlx-mic-resolve-"));
  try {
    const sibling = join(dir, MIC_CAPTURE_BINARY), staged = join(dir, "staged", MIC_CAPTURE_BINARY);
    expect(await resolveMicCapture({ explicit: "/explicit/mic", sibling, staged })).toBe("/explicit/mic");
    expect(await resolveMicCapture({ sibling, staged })).toBeNull();
    mkdirSync(dirname(staged), { recursive: true }); writeFileSync(staged, "");
    expect(await resolveMicCapture({ sibling, staged })).toBe(staged);
    writeFileSync(sibling, "");
    expect(await resolveMicCapture({ sibling, staged })).toBe(sibling);
    expect(await resolveMicCapture({ sibling: null, staged })).toBe(staged);
    const restore = configureRuntime({ MLX_BUN_MIC_CAPTURE: "/from/env" });
    try { expect(defaultMicCaptureCandidates()).toMatchObject({ explicit: "/from/env", sibling: null, staged: MIC_CAPTURE_STAGED }); }
    finally { restore(); }
    await expect(startMicCapture({ resolve: async () => null })).rejects.toThrow("microphone capture needs the mlx-bun-mic-capture sidecar");
  } finally { rmSync(dir, { recursive: true, force: true }); }
});

test("the sidecar protocol yields float32 frames across chunk boundaries and control lines; stop ends stdin, terminates, and joins", async () => {
  const dir = mkdtempSync(join(tmpdir(), "mlx-mic-"));
  try {
    const pcm = join(dir, "pcm.bin");
    writeFileSync(pcm, new Uint8Array(Float32Array.from([0.25, -0.5, 1]).buffer));
    const script = join(dir, "fake-mic");
    writeFileSync(script, ["#!/bin/sh", 'echo "ready rate=16000 args=$*" >&2', `head -c 6 "${pcm}"`, "sleep 0.05", `tail -c +7 "${pcm}"`,
      'echo "hotkey down" >&2', 'echo "hotkey up" >&2', 'echo "error: boom" >&2', 'echo "noise" >&2', "cat >/dev/null", "exit 0", ""].join("\n"),
    { mode: 0o755 });
    const mic = await startMicCapture({ hotkey: 61, resolve: async () => script });
    const events: MicEvent[] = [];
    const drained = (async () => { for await (const event of mic.events) events.push(event); })();
    await waitFor(() => events.some(e => e.kind === "error"));
    await Promise.all([mic.stop(), mic.stop()]);
    await drained;
    expect(typeof await mic.exited).toBe("number");
    expect(events.filter(e => e.kind !== "pcm")).toEqual([{ kind: "ready", info: "rate=16000 args=--rate 16000 --hotkey 61" },
      { kind: "hotkey", down: true }, { kind: "hotkey", down: false }, { kind: "error", message: "boom" }]);
    expect(events.flatMap(e => (e.kind === "pcm" ? [...e.samples] : []))).toEqual([0.25, -0.5, 1]);
  } finally { rmSync(dir, { recursive: true, force: true }); }
});

test("a sidecar that ignores SIGTERM and stdin is killed after the grace period and still joined", async () => {
  const dir = mkdtempSync(join(tmpdir(), "mlx-mic-stubborn-"));
  try {
    const script = join(dir, "stubborn-mic");
    writeFileSync(script, ["#!/bin/sh", "trap '' TERM", 'echo "ready stubborn" >&2', "exec sleep 100", ""].join("\n"), { mode: 0o755 });
    const mic = await startMicCapture({ resolve: async () => script, killGraceMs: 50 });
    const events: MicEvent[] = [];
    const drained = (async () => { for await (const event of mic.events) events.push(event); })();
    await waitFor(() => events.length === 1);
    const started = Date.now();
    await mic.stop();
    await drained;
    expect(Date.now() - started).toBeLessThan(3000);
    expect(events).toEqual([{ kind: "ready", info: "stubborn" }]);
    expect(typeof await mic.exited).toBe("number");
  } finally { rmSync(dir, { recursive: true, force: true }); }
});
