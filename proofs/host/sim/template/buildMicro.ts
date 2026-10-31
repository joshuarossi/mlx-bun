// Build bounded links, bisecting only checks rejected by the 8 GB memory gate.
import { readFileSync, writeFileSync } from "node:fs";

const [out, ...targets] = process.argv.slice(2);
if (!out || !targets.length || targets.some(t => !t.startsWith("host/sim/template/a4") || !t.endsWith(".lean")))
  throw Error("usage: bun buildMicro.ts <build-dir> <generated modules under proofs/>...");
for (let attempt = 0; attempt < 128; attempt++) {
  const child = Bun.spawn(["bun", "proofs/host/sim/template/timeBuild.ts", "--out", out,
    "--keep-going", "--jobs", "1", ...targets], { stdout: "pipe", stderr: "pipe" });
  const consume = async (stream: ReadableStream<Uint8Array>, error: boolean) => {
    let text = "";
    for await (const bytes of stream) {
      const part = new TextDecoder().decode(bytes);
      (error ? process.stderr : process.stdout).write(part);
      text += part;
    }
    return text;
  };
  const [output, errors, status] = await Promise.all([consume(child.stdout, false), consume(child.stderr, true), child.exited]);
  if (status === 0) process.exit(0);
  const failed = [...new Set([...output.matchAll(/FAIL [^\n]* (host\/sim\/template\/a4[^\s]+\.lean) \[/g)].map(m => m[1]!))];
  if (!failed.length) throw Error(`build failed without a refinable check: ${errors.slice(-1200)}`);
  for (const file of failed) {
    if (!/\/MicroK\d+_[\da-z]+\.lean$/.test(file) ||
        !output.includes(`stopped exclusive retry; split ${file}`))
      throw Error(`non-memory or non-micro rejection requires inspection: ${file}`);
    const refined = Bun.spawnSync(["bun", "proofs/host/sim/template/refineMicro.ts", `proofs/${file}`], { stdout: "inherit", stderr: "inherit" });
    if (refined.exitCode !== 0) throw Error(`cannot refine ${file}`);
  }
  const registry = "proofs/check.ts", source = readFileSync(registry, "utf8");
  const marker = "\n];\n\nconst discoveredProofs";
  if (!source.includes(marker)) throw Error("proof registry marker changed");
  const dirs = [...new Set(failed.map(f => f.slice(0, f.lastIndexOf("/"))))];
  const fresh = dirs.flatMap(dir => [...new Bun.Glob("*.lean").scanSync(`proofs/${dir}`)].map(f => `${dir}/${f}`))
    .filter(f => !source.includes(`"${f}"`)).sort();
  writeFileSync(registry, source.replace(marker, fresh.map(f => `\n  "${f}",`).join("") + marker));
  console.log(`registered ${fresh.length} refined proof modules; retrying original targets`);
}
throw Error("bounded-link refinement limit reached");
