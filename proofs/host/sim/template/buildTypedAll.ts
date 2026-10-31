// Check typed targets to a fixed point: compile, split whatever hit the 8 GB cap, repeat.
// usage: bun buildTypedAll.ts <out> <chain dir under template/> <Lean namespace> [jobs] [pre-split stage...] -- <targets...>
import { existsSync, readFileSync, readdirSync, rmSync, writeFileSync } from "node:fs";
import { join } from "node:path";
const argv = process.argv.slice(2), sep = argv.indexOf("--");
if (sep < 3) throw Error("usage: buildTypedAll.ts out chain namespace [jobs] [stage...] -- targets...");
const [out, chain, ns, jobs = "3", ...pre] = argv.slice(0, sep), targets = argv.slice(sep + 1);
if (!process.env.HOST_STREAM_DIR || !process.env.LEAN_DYNLIB) throw Error("HOST_STREAM_DIR and LEAN_DYNLIB are required");
const template = import.meta.dir, registry = join(template, "../../../check.ts");
const fuelOf = (stage: string, chunk: number) => {
  const dir = join(process.env.HOST_STREAM_DIR!, `Host.Load.Run.Tpl.${ns}.st${stage}`);
  const meta = JSON.parse(readFileSync(join(dir, "stage.json"), "utf8")), seg = JSON.parse(readFileSync(join(dir, "seg.json"), "utf8"));
  const T1 = Number(seg.T1), total = Number(meta.steps) - 1;
  return chunk < T1 - 2 ? 10000 : total - (T1 - 2) * 10000;
};
const widthTried = new Map<string, number>();
const split = async (stage: string, chunk: number) => {
  const key = `${stage}/${chunk}`, fuel = fuelOf(stage, chunk);
  const prior = widthTried.get(key), width = prior ? Math.floor(prior / 2) : Math.max(Math.floor(fuel / 3), 200);
  if (width < 100) throw Error(`stage ${stage} chunk ${chunk} still capped at width ${prior}`);
  widthTried.set(key, width);
  const root = join(template, chain, `st${stage}`);
  for (const f of readdirSync(root)) if (new RegExp(`^TypedSplitK${chunk}\\D.*\\.lean$`).test(f)) rmSync(join(root, f));
  const gen = Bun.spawn(["bun", join(template, "genTypedSplit.ts"), `${chain}/st${stage}`, `${ns}.st${stage}`, String(chunk), String(fuel), String(width)],
    { stdout: "inherit", stderr: "inherit" });
  if (await gen.exited) throw Error(`split generation failed at ${key}`);
  const files = readdirSync(root).filter(f => new RegExp(`^TypedSplitK${chunk}\\D.*\\.lean$`).test(f)).map(f => `host/sim/template/${chain}/st${stage}/${f}`);
  let source = readFileSync(registry, "utf8");
  const added = files.filter(f => !source.includes(JSON.stringify(f))), at = source.indexOf("\n];\n\nconst discoveredProofs");
  if (at < 0) throw Error("proof registry end not found");
  writeFileSync(registry, source.slice(0, at) + added.map(f => `\n  ${JSON.stringify(f)},`).join("") + source.slice(at));
};
for (const stage of pre) if (!existsSync(join(template, chain, `st${stage}`, "TypedSplitK0Part0.lean"))) await split(stage, 0);
for (let round = 0; ; round++) {
  console.log(`round ${round}`);
  const p = Bun.spawn(["bun", join(template, "timeBuild.ts"), "--out", out, "--keep-going", "--jobs", jobs, ...targets], { stdout: "pipe", stderr: "inherit", env: process.env });
  const capped = new Set<string>(); let failed = 0, tail = "";
  for await (const chunk of p.stdout as any) {
    const text = tail + new TextDecoder().decode(chunk), lines = text.split("\n"); tail = lines.pop()!;
    for (const line of lines) {
      console.log(line);
      const m = /stopped exclusive retry; split (\S+)/.exec(line); if (m) capped.add(m[1]!);
      if (/^\d\d:\d\d:\d\d FAIL /.test(line)) failed++;
    }
  }
  await p.exited;
  if (!capped.size && !failed) { console.log("all targets checked"); break; }
  let progress = 0;
  for (const file of capped) {
    const m = new RegExp(`${chain}/st(\\d+)/Typed(?:K|SplitK)(\\d+)`).exec(file);
    if (!m) { console.log(`capped outside typed runs: ${file}`); continue; }
    await split(m[1]!, Number(m[2])); progress++;
  }
  if (!progress) { console.log(`stopped: ${failed} failures with no split to apply`); process.exit(1); }
}
