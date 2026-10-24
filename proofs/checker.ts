/** What decides whether one proof module passes: the text Lean checks, how Lean
 * runs and the acceptance test. Cached results are keyed by this file's text, so
 * any change here rechecks every module. */
import { delimiter, join } from "node:path";

// Definition-only and import-only modules are allowed. Reject custom axiom
// declarations even when unused, and audit every theorem's transitive dependencies,
// including private helpers and newly added theorems.
export const audit = `
namespace MlxProofAxiomAudit
open Lean Elab Command

-- Each local declaration is traversed once across all theorem roots. Imported
-- declarations retain Lean's own precomputed transitive axiom collection.
private partial def visit (env : Environment) (root name : Name) : StateRefT NameSet CommandElabM Unit := do
  if (← get).contains name then return
  modify fun seen => seen.insert name
  if (env.getModuleIdxFor? name).isSome then
    for axiomName in (← collectAxioms name) do
      unless #[\`propext, \`Classical.choice, \`Quot.sound].contains axiomName do
        throwError "Forbidden axiom {axiomName} in {root}"
    return
  let expression (value : Expr) := value.getUsedConstants.forM (visit env root)
  -- Match Lean.Util.CollectAxioms, including types, opaque bodies, recursors
  -- and inductive constructors. Consult the checked kernel environment.
  match env.checked.get.find? name with
  | some (.axiomInfo value) =>
    unless #[\`propext, \`Classical.choice, \`Quot.sound].contains name do
      throwError "Forbidden axiom {name} in {root}"
    expression value.type
  | some (.defnInfo value) => expression value.type *> expression value.value
  | some (.thmInfo value) => expression value.type *> expression value.value
  | some (.opaqueInfo value) => expression value.type *> expression value.value
  | some (.ctorInfo value) => expression value.type
  | some (.recInfo value) => expression value.type
  | some (.inductInfo value) => expression value.type *> value.ctors.forM (visit env root)
  | some (.quotInfo _) | none => pure ()

end MlxProofAxiomAudit
open Lean Elab Command in
run_cmd do
  let env ← getEnv
  let declaredAxioms := env.constants.foldStage2 (fun ns name info =>
    if info.isAxiom then ns.push name else ns) (#[] : Array Name)
  for name in declaredAxioms do
    unless #[\`propext, \`Classical.choice, \`Quot.sound].contains name do
      throwError "Forbidden axiom declaration {name}"
  let names := env.constants.foldStage2 (fun ns name info =>
    if info.isTheorem then ns.push name else ns) (#[] : Array Name)
  (names.forM fun name => MlxProofAxiomAudit.visit env name name).run' ({} : NameSet)
  logInfo m!"Axiom audit passed: {names.size} theorems"
`;

export function auditedText(text: string): string {
  return `import Lean\n${text}\n${audit}`;
}

export function leanArgs(dir: string, path: string, build: boolean, library?: string): string[] {
  return [...(library ? ["--load-dynlib", library] : []),
    "-R", dir, ...(build ? ["-o", path.replace(/\.lean$/, ".olean")] : []), path];
}

export function leanEnv(leanPath: string, dependencyPath: string): Record<string, string> {
  return {
    LEAN_PATH: [leanPath, dependencyPath].filter(Boolean).join(delimiter),
    HOST_STREAM_DIR: join(leanPath, ".host-stream"),
  };
}

// Native evaluation chooses explicit states only. Every generated equality
// is checked by the kernel, under the same axiom audit as other proofs.
export function isLoadChooser(file: string, source: string): boolean {
  return (file.startsWith("host/load/") &&
    /^(?:host_stream|link_chain|run_segment|load_replay_summary|load_state_summary|host_cache_boundary|load_boundary_carriers)\s/m.test(source)) ||
    /^(?:host_micro_chunk|host_micro_states|host_micro_states_group|host_micro_stream|host_micro_group|boot_w_micro|boot_ane_bridge|host_sha256_step|host_growth_fragment|host_stop_fragment)\s/m.test(source);
}

export function accepted(output: string, code: number): boolean {
  return code === 0 && !output.includes("sorryAx") && output.includes("Axiom audit passed:");
}

const sha256 = (parts: string[]) => {
  const hasher = new Bun.CryptoHasher("sha256");
  for (const part of parts) hasher.update(`${part.length}:${part}`);
  return hasher.digest("hex");
};

/** Key of every module: `base` (checker, toolchain and dependencies), its path and
 * text, its local imports' keys, and for state choosers the native chooser's key. */
export function moduleKeys(sources: ReadonlyMap<string, string>, imports: ReadonlyMap<string, string[]>,
    base: string): Map<string, string> {
  const keys = new Map<string, string>();
  const visiting = new Set<string>();
  const key = (file: string): string => {
    const known = keys.get(file);
    if (known) return known;
    if (visiting.has(file)) throw new Error(`Local proof import cycle at ${file}`);
    visiting.add(file);
    const source = sources.get(file)!;
    const native = isLoadChooser(file, source) && sources.has("host/load/Native.lean")
      ? [key("host/load/Native.lean")] : [];
    const result = sha256([base, file, source, ...imports.get(file)!.map(key), ...native]);
    visiting.delete(file);
    keys.set(file, result);
    return result;
  };
  for (const file of sources.keys()) key(file);
  return keys;
}

export function cacheBase(inputs: string[]): string {
  return sha256(inputs);
}
