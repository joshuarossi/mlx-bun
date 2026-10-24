/** Modules of the boot of `RoutePrompt`'s route for every prompt (`host/load/run/prompt`).
 *   bun proofs/host/load/run/prompt/gen.ts
 * Writes the stream (`States`, `H<j>`: 32 boundaries each), the link chain for every prompt
 * (`link/`), the boot join (`Boot`), the load facts (`ChoiceStates`, `Load`), the frame at loadDone
 * (`Frame`) and the route's boot theorem (`Prompt`); prints their `proofFiles` entries in dependency
 * order. The run to loadDone (`Run`, `P.absRun`) is the observer world's chain projected
 * (`host/load/boot`, `~/proofdev/tools/bootw-gen.ts`), not written here. */
import { mkdir } from "node:fs/promises";
import { join, relative, resolve } from "node:path";

const proofs = resolve(import.meta.dir, "../../../..");
const dir = join(proofs, "host/load/run/prompt");
const ns = "Host.Load.Run.Prompt";
const N = 2818; // chunks to loadDone (`Full.P`'s chunks 0 … 2817)
const ks = [...Array.from({ length: N - 1 }, () => 10000), 2201];
const total = ks.reduce((a, b) => a + b, 0);
if (total !== 28172201) throw new Error(`chunk sizes sum to ${total}`);
const addr = 2665; // the prompt array (`RoutePrompt.inputV`'s allocation)
const linkSteps = 840;
const statesPer = 32;
const linkPer = 4;
const scanned = [43, 44]; // link steps through checked reference scans (`Full.Link.Step43`, `Step44`)

const files: string[] = [];
const mod = (f: string) => relative(proofs, join(dir, f)).replace(/\.lean$/, "").replaceAll("/", ".");
const write = async (f: string, text: string) => {
  await mkdir(join(dir, f, ".."), { recursive: true });
  await Bun.write(join(dir, f), text);
  files.push(relative(proofs, join(dir, f)));
};
const imports = (ms: string[]) => ms.map(m => `import ${m}`).join("\n");
const hOf = (boundary: number) => Math.floor(boundary / statesPer);

// The stream: the prompt array abstracted at every boundary.
await write("States.lean", `import host.load.Native
import host.load.Decode
import host.load.RoutePrompt
set_option Elab.async false
namespace ${ns}
open Host.Ts Host.Load

/-! The boot of \`RoutePrompt\`'s route to \`loadDone\` (the chunks of \`Full.P\` 0 … ${N - 1}), the prompt
array abstracted at every boundary (\`P.a<k> fw\`: \`PROMPT\`'s elements \`fw\`). -/

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
set_option interpreter.prefer_native true in
host_stream P : Host.Load.ffi, bootL (RoutePrompt.cx [9707]) Decode.world 2000, Decode.tab, Decode.valuation, 10000, ${N} chunks [${ks.join(", ")}] abs 0, ${N}, "PROMPT"

end ${ns}
`);

const nH = hOf(N) + 1;
for (let j = 0; j < nH; j++) {
  const ids = Array.from({ length: statesPer }, (_, t) => j * statesPer + t).filter(k => k <= N);
  await write(`H${j}.lean`, `${imports([mod(j ? `H${j - 1}.lean` : "States.lean")])}
set_option Elab.async false
namespace ${ns}
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
${ids.map(k => `host_stream_state P ${k}`).join("\n")}
end ${ns}
`);
}

// The link chain, computed for the sentinel prompt and abstracted.
const lns = `${ns}.Link`;
const L = `${lns}.L`;
await write("link/States.lean", `import host.load.Native
import host.load.Decode
import host.load.RoutePrompt
set_option Elab.async false
namespace ${lns}
open Host.Ts Host.Load

/-! The link of \`RoutePrompt.cxV [absSentinel]\` (the prompt a sentinel no run makes), one step
per state; \`Abs\` replaces the sentinel prompt by any prompt. -/

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
set_option interpreter.prefer_native true in
link_chain L : RoutePrompt.cxV [absSentinel], Decode.world, [${Array.from({ length: linkSteps }, () => 1).join(", ")}]

end ${lns}
`);
await write("link/Abs.lean", `${imports([mod("link/States.lean"), "host.load.PromptStream"])}
set_option Elab.async false
namespace ${lns}
set_option maxRecDepth 1000000
link_abs Lp from ${L}
end ${lns}
`);
const lmods: string[] = [];
for (let j = 0; j * linkPer < linkSteps; j++) {
  const ids = Array.from({ length: linkPer }, (_, t) => j * linkPer + t).filter(k => k < linkSteps && !scanned.includes(k));
  if (!ids.length) continue;
  await write(`link/L${j}.lean`, `${imports([mod("link/Abs.lean")])}
set_option Elab.async false
namespace ${lns}
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
${ids.map(k => `link_chunk_abs_eager Lp from ${L} using RoutePrompt.cxV ${k}`).join("\n")}
end ${lns}
`);
  lmods.push(`link/L${j}.lean`);
}
await write("link/Step.lean", `${imports([mod("link/Abs.lean"), "host.load.run.full.link.Step43", "host.load.run.full.link.Step44"])}
set_option Elab.async false
namespace ${lns}
open Host.Ts
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/- Link steps 43 and 44 add the two model modules through their checked reference scans
(\`Full.Link.Scan43\`, \`Scan44\`: the modules are \`Route\`'s). -/
${scanned.map(k => `link_step_abs_eager Lp from ${L} using RoutePrompt.cxV ${k} := fun (fw : List Val) =>
  RefScan.linkRun_one_user_scanned (RoutePrompt.cxV fw) ${k} (Lp.x${k} fw) Host.Load.Run.Full.Link.user${k}
    Host.Load.Run.Full.Link.Scan${k}.refs rfl rfl rfl Host.Load.Run.Full.Link.Scan${k}.checked`).join("\n")}

end ${lns}
`);
await write("link/Run.lean", `${imports([...lmods.map(mod), mod("link/Step.lean")])}
set_option Elab.async false
namespace ${lns}
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! \`Lp.booted : ∀ fw m, ${linkSteps} ≤ m → bootL (RoutePrompt.cxV fw) Decode.world m = some (Lp.x${linkSteps} fw).st\`. -/
link_abs_run Lp from ${L} using RoutePrompt.cxV world Host.Load.Decode.world

end ${lns}
`);

await write("Boot.lean", `${imports([mod("link/Run.lean"), mod("H0.lean"), "host.load.run.tail.Command"])}
set_option Elab.async false
namespace ${ns}
open Host.Ts Host.Load
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/- The finished link is the stream's boundary 0, for every prompt. -/
kernel_rfl_eager link_join : ∀ fw : List Val, (Link.Lp.x${linkSteps} fw).st = P.a0 fw

/-- Booting the route with the prompt elements \`fw\` reaches boundary 0. -/
theorem boot (fw : List Val) : bootL (RoutePrompt.cxV fw) Decode.world 2000 = some (P.a0 fw) :=
  (Link.Lp.booted fw 2000 (by decide)).trans (congrArg some (link_join fw))

end ${ns}
`);

await write("ChoiceStates.lean", `import host.load.Native
import host.load.Decode
import host.load.Choice
import host.load.RoutePrompt
namespace ${ns}
open Host.Ts Host.Load
set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
set_option interpreter.prefer_native true in
load_replay_summary parameterChoice : bootL (RoutePrompt.cx [9707]) Decode.world 2000, Decode.tab, Decode.valuation, ${total}
end ${ns}
`);

await write("Load.lean", `${imports([mod(`H${hOf(N)}.lean`), mod("ChoiceStates.lean"), "host.load.Choice", "host.load.run.tail.Command"])}
set_option Elab.async false
namespace ${ns}
open Host.Ts Host.Load

/-! The load facts of \`Full.Load\` at this route's \`loadDone\` (boundary ${N}), for every prompt. -/

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
load_summary_checked parameters : P.s${N}, entryEnv P.s0 using parameterChoice

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
kernel_rfl_eager parameters_all : ∀ fw : List Val, Extract.loaded (P.a${N} fw) (entryEnv P.s0) = some parameters

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
kernel_rfl_eager graph_matches : ∀ fw : List Val, (P.a${N} fw).ffi.mlx = parameterChoice.graph

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
kernel_rfl_eager loaded_marker : ∀ fw : List Val, Decode.loadDone (entryEnv P.s0) (P.a${N} fw) = true

set_option maxRecDepth 1000000 in
theorem stages_64 : parameters.model.stages.length = 64 := by rfl

set_option maxRecDepth 1000000 in
theorem caches_64 : parameters.cache.length = 64 := by rfl

end ${ns}
`);

await write("Frame.lean", `${imports([mod(`H${hOf(N)}.lean`), "host.load.run.prompt.FrameRel", "host.load.run.tail.Command", "host.ts.Harness"])}
set_option Elab.async false
namespace ${ns}
open Host.Ts Host.Ts.Sim Host.Load

/-! The prompt at \`loadDone\`: the states for two prompts differ only in the array at ${addr}
(\`PROMPT\`'s cell ${addr + 1} holds it), so the empty prompt's state frames every prompt's
(\`FrameRel.relF_frame\`: identity map, frame at ${addr} \`([], fw)\`). -/

def promptObj (fw : List Val) : Obj := ⟨.array fw, .obj aArrayProto, [], [], true⟩

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
kernel_rfl_eager frame : ∀ fw : List Val, P.a${N} fw = (P.a${N} []).setObj ${addr} (promptObj fw)

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
kernel_rfl_eager prompt_obj : ∀ fw : List Val, (P.a${N} fw).heap.get ${addr} = some (.obj (promptObj fw))

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
kernel_rfl_eager prompt_cell : ∀ fw : List Val, (P.a${N} fw).heap.get ${addr + 1} = some (.cell (some (.obj ${addr})))

set_option maxRecDepth 1000000 in
kernel_rfl prompt_binding : lookupEnv chars!"PROMPT" (entryEnv P.s0) = some ${addr + 1}

/-- **The relation at \`loadDone\`**: under the identity map, with the prompt array framed
(template prefix \`[]\`, target prefix \`fw\`), the empty prompt's state is related to the state
for \`fw\`, given the empty prompt's closedness, native relation and server facts. -/
theorem rel_loadDone {FR : Map → Nat → LSt → LSt → Prop} {ν : Nat → F64} {S : SSrv} {C : CSrv}
    (lo hi : Nat) (fw : List Val) (h : FrameRel.Hyps Host.Load.ffi FR ν S C lo hi (P.a${N} [])) :
    Rel Host.Load.ffi FR Map.id ν (FrameRel.ctx (P.a${N} []) ${addr} fw lo hi)
      (P.a${N} []) S (P.a${N} fw) C := by
  rw [frame fw]
  exact FrameRel.relF_frame h (prompt_obj []) rfl (by decide)

end ${ns}
`);

await write("Prompt.lean", `${imports([mod("Run.lean"), mod("Boot.lean")])}
set_option Elab.async false
namespace ${ns}
open Host.Ts Host.Load

set_option maxRecDepth 1000000 in
/-- **The boot of the route for every prompt**: booting \`RoutePrompt.cx π\` and running the
${total} load steps reaches \`loadDone\` with the prompt array holding \`π\`. -/
theorem boot_prompt (π : List Nat) :
    (bootL (RoutePrompt.cx π) Decode.world 2000).bind (fun s => runS P.F ${total} s P.S0) =
      some (P.a${N} (π.map natV), P.S${N}) := by
  rw [show RoutePrompt.cx π = RoutePrompt.cxV (π.map natV) from rfl, boot]
  exact (Option.bind_some _ _).trans (P.absRun (π.map natV))

end ${ns}
`);

const order = ["host/load/PromptStream.lean", "host/load/run/prompt/FrameRel.lean",
  ...files.filter(f => !/(Run|Boot|Prompt|Load|Frame|ChoiceStates)\.lean$/.test(f) || f.includes("/link/")),
  ...["Run.lean", "Boot.lean", "ChoiceStates.lean", "Load.lean", "Frame.lean", "Prompt.lean"].map(f => `host/load/run/prompt/${f}`)];
for (const f of order) console.log(`  "${f}",`);
