// Build with timings from the existing machine gate's lease events, excluding queue waits.
// usage: bun timeBuild.ts --out <build-dir> <build.ts arguments ...>
import { existsSync, readFileSync, readdirSync, watch } from "node:fs";
import { resolve } from "node:path";

const args = process.argv.slice(2);
const outIndex = args.indexOf("--out");
if (outIndex < 0 || !args[outIndex + 1]) throw Error("--out is required");
const out = resolve(args[outIndex + 1]!);
const queue = "/tmp/leanslot.q";
const tickets = new Map<string, string>();
const active = new Map<number, { pid: string; file: string; start: number }>();
const timings: { file: string; pid: string; seconds: number }[] = [];
const retryStops: Promise<void>[] = [];
const pidAt = (slot: number) => {
  try { return readFileSync(`/tmp/leanslot.${slot}/pid`, "utf8").trim(); } catch { return ""; }
};
const finish = (slot: number) => {
  const a = active.get(slot);
  if (!a || pidAt(slot) === a.pid) return;
  const seconds = (performance.now() - a.start) / 1000;
  active.delete(slot);
  timings.push({ file: a.file, pid: a.pid, seconds });
  console.log(`slot ${seconds.toFixed(3)}s ${a.file}`);
};
const ticket = (filename: string) => {
  const pid = filename.slice(filename.lastIndexOf("-") + 1);
  if (existsSync(`${queue}/${filename}`)) {
    const command = Bun.spawnSync(["ps", "-p", pid, "-o", "command="]).stdout.toString();
    if (command.includes(`-o ${out}/`)) {
      // An exclusive retry hides the point that must be split and blocks the shared machine.
      if (command.includes("--exclusive")) {
        const parent = Number(Bun.spawnSync(["ps", "-p", pid, "-o", "ppid="]).stdout.toString().trim());
        try { process.kill(Number(pid), "SIGSTOP"); } catch {}
        const rows = Bun.spawnSync(["ps", "-Ao", "pid=,ppid="]).stdout.toString().trim().split("\n")
          .map(line => line.trim().split(/\s+/).map(Number));
        const children = rows.filter(([, p]) => p === Number(pid)).map(([p]) => p!);
        for (const p of [parent, ...children, Number(pid)]) if (p > 0) try { process.kill(p, "SIGTERM"); } catch {}
        try { process.kill(Number(pid), "SIGCONT"); } catch {}
        retryStops.push(new Promise(resolve => setTimeout(() => {
          for (const p of [...children, Number(pid)]) try { process.kill(p, "SIGKILL"); } catch {}
          resolve();
        }, 2500)));
        console.log(`stopped exclusive retry; split ${command.match(/\/proofs\/([^\s]+\.lean)(?:\s|$)/)?.[1] ?? pid}`);
        return;
      }
      const file = command.match(/\/proofs\/([^\s]+\.lean)(?:\s|$)/)?.[1];
      if (file) tickets.set(filename, file);
    }
    return;
  }
  const file = tickets.get(filename);
  tickets.delete(filename);
  if (!file) return;
  for (let slot = 1; slot <= 3; slot++) {
    finish(slot);
    if (pidAt(slot) === pid) active.set(slot, { pid, file, start: performance.now() });
  }
};
if (!existsSync(queue)) throw Error("machine gate queue is missing");
const queueWatch = watch(queue, (_, filename) => { if (filename) ticket(filename.toString()); });
const slotWatch = watch("/tmp", (_, filename) => {
  const m = /^leanslot\.([123])$/.exec(filename?.toString() ?? "");
  if (m) finish(Number(m[1]));
});
for (const filename of readdirSync(queue)) ticket(filename);
const child = Bun.spawn(["bun", "/Users/joshrossi/proofdev/tools/build.ts", ...args], {
  stdin: "inherit", stdout: "inherit", stderr: "inherit", env: process.env,
});
const code = await child.exited;
await Promise.all(retryStops);
for (let slot = 1; slot <= 3; slot++) finish(slot);
queueWatch.close(); slotWatch.close();
const groups = new Map<string, { attempts: Set<string>; seconds: number }>();
for (const s of timings) {
  const base = s.file.slice(s.file.lastIndexOf("/") + 1).replace(/\.lean$/, "");
  const kind = base.replace(/[0-9_]+$/, "");
  const g = groups.get(kind) ?? { attempts: new Set<string>(), seconds: 0 };
  g.attempts.add(s.pid); g.seconds += s.seconds; groups.set(kind, g);
}
for (const [kind, g] of groups) console.log(`${kind}: ${g.attempts.size} attempts, ${(g.seconds / 60).toFixed(3)} slot-min, ${(g.seconds / g.attempts.size).toFixed(3)} slot-s/attempt`);
console.log(`total: ${new Set(timings.map(s => s.pid)).size} attempts, ${(timings.reduce((n, s) => n + s.seconds, 0) / 60).toFixed(3)} slot-min`);
process.exit(code);
