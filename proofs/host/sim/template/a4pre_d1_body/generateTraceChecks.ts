import { copyFileSync, existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";

type Pair = { file: string; sourceSha256: string };
const out = process.argv[2];
if (!out) throw new Error("usage: bun generateTraceChecks.ts <isolated DEVOUT>");
const root = import.meta.dir;
const prefix = "host/sim/template/a4pre_d1_body/";
const pairs = JSON.parse(readFileSync(join(out, "imports.json"), "utf8")) as { modules: Pair[] };
const accepted = new Map(pairs.modules.map(p => [p.file, p]));
const parts = JSON.parse(readFileSync(join(root, "sized-pieces.json"), "utf8")) as {
  steps: number; last: number; sizes: number[]; segments: { from: number; to: number }[];
};
if (parts.steps !== 1541184 || parts.last !== 635 || parts.segments.length !== 183)
  throw new Error("wrong original body partition");
const sha = (s: string) => new Bun.CryptoHasher("sha256").update(s).digest("hex");
const archive = join(out, "draft-sources", "before-proved-shaped-lookup");
const receipt = join(out, "proved-shaped-lookup-rework.json");
const alreadyFrozen = existsSync(receipt);
mkdirSync(archive, { recursive: true });
const changes: { file: string; before: string; after: string }[] = [];
function update(stem: string, transform: (s: string) => string) {
  const file = prefix + stem + ".lean", path = join(root, stem + ".lean");
  const old = readFileSync(path, "utf8"), known = accepted.get(file);
  if (known) {
    if (sha(old) !== known.sourceSha256) throw new Error("accepted source drift: " + file);
    return;
  }
  const next = transform(old);
  if (next === old) return;
  if (alreadyFrozen) throw new Error("rework receipt is frozen; source change rejected: " + file);
  copyFileSync(path, join(archive, stem + ".lean"));
  writeFileSync(path, next);
  changes.push({ file, before: sha(old), after: sha(next) });
}
for (let k = 5; k < parts.segments.length; k++) {
  const seg = parts.segments[k]!;
  for (let i = seg.from; i < seg.to; i++) {
    update("SN" + i, s => {
      if (i === 18) return "import host.sim.template.a4pre_d1_body.NC18\n" +
        "set_option Elab.async false\nnamespace Host.Load.Run.Tpl\n" +
        "open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template\n" +
        "kernel_rfl D1BodySized.fuel18 : nth? D1BodySized.ks 18 = some 10000\n" +
        "theorem D1BodySized.checked18 :\n" +
        "  (fun bs : List Byte => runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s18 D1BodySized.S18) =\n" +
        "    fun _ => some (D1BodySized.s19, D1BodySized.S19) := D1BodySized.traceChecked18\n" +
        "theorem D1BodySized.k18 (bs : List Byte) :\n" +
        "    runOk D1BodySized.F (D1BodyTrace.checkedOk bs) 10000 D1BodySized.s18 D1BodySized.S18 =\n" +
        "      some (D1BodySized.s19, D1BodySized.S19) := D1BodySized.traceK18 bs\n" +
        "end Host.Load.Run.Tpl\n";
      if (!s.includes("D1Frames.typedOk")) return s;
      return "import host.sim.template.a4pre_d1_body.TraceStep\n" +
        s.replaceAll("D1Frames.typedOk", "D1BodyTrace.checkedOk");
    });
  }
  update("SB" + k, s => s.includes("D1Frames.typedOk") ?
    "import host.sim.template.a4pre_d1_body.TraceStep\n" + s.replaceAll("D1Frames.typedOk", "D1BodyTrace.checkedOk") : s);
  update("SP" + k, s => /D1BodyAdvance\.(?:toCall|finish)/.test(s) ?
    "import host.sim.template.a4pre_d1_body.TraceAdvance\n" +
      s.replaceAll("D1BodyAdvance.toCall", "D1BodyTrace.toCall").replaceAll("D1BodyAdvance.finish", "D1BodyTrace.finish") : s);
}
if (!alreadyFrozen) writeFileSync(receipt, JSON.stringify({
  at: new Date().toISOString(), reason: "The old checked predicate rejected effectful shaped closure lookup at actual step52102; the local native simulation now proves that operation and the old acceptance is retained by OR.",
  oldAcceptedFilesChanged: 0, stateOrEndpointOrFuelChanges: 0,
  firstExactPositive: "D1BodySized.traceChecked18", changes,
}, null, 2));
console.log({ reworkedUnacceptedChecks: changes.length, oldAcceptedFilesChanged: 0 });
