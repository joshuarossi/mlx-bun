import host.load.Route
namespace Host.Load.RoutePrompt
open Host.Ts Host.Load
set_option maxRecDepth 100000

/-! # The load route with the prompt from the host module

`Route` with one change, in the driver: `generateAutoregressive` receives `PROMPT`,
an array the host module `%proof/decode-input` exports with `MAX_TOKENS`, instead of
the literal `[9707]`. Every other module is `Route`'s (`mods_dropLast`,
`hosts_dropLast`), and the driver agrees with `Route.Driver` everywhere else
(`own_names`, `import_sources`, `items_agree`, `main_agree`).

The driver's code up to `loadDone = true` is `Route.Driver`'s, including the
capacity `1 + 300` it pages with. That call returns at once (`binding.pagedKv` is
null, state/request-policy.ts:25), and `generateAutoregressive` pages again with
`promptTokens.length + maxTokens` (generation/autoregressive.ts:194), as
`generate()` does. Reading `PROMPT` before `loadDone` would make the load depend on
the prompt.

The host module allocates the array, then the export cells (`PROMPT` first). Every
address `Route`'s link gives at or after its `MAX_TOKENS` cell is therefore two
higher here, and nothing below moves. -/

namespace Driver
/-- The harness: `Route.Driver` with the prompt from the host module. -/
def source : String := r#"import "%host/globals";
import { openModel } from "./index";
import { bindMlxAutoregressiveGraph } from "./generation/bindings/autoregressive";
import { maybePageKv } from "./state/request-policy";
import { BF16_KV } from "./contracts/portable/composition";
import { SSMCache } from "./state/ssm";
import { KVCache } from "./state/kv";
import { generateAutoregressive } from "./generation/autoregressive";
import { MAX_TOKENS, PROMPT } from "%proof/decode-input";
const DIR = "/Users/joshrossi/.cache/huggingface/hub/models--mlx-bun--Qwen3.8-27B-Trellis-3.2bpw/snapshots/cbb7a58a7222a19a3d02d36540c9cab5d9aadf0d";
export let model = null;
export let binding = null;
export let cache = null;
export let out = null;
export let loadDone = false;
export let generation = null;
export let emitted = [];
export let yieldCount = 0;
export let lastYield = null;
export let completed = false;
async function main() {
  model = await openModel(DIR);
  binding = bindMlxAutoregressiveGraph(model);
  cache = binding.makeCache();
  maybePageKv(cache, binding.kv ?? BF16_KV, binding.pagedKv ?? null, 1 + 300);
  out = [cache.length, cache.filter(c => c instanceof SSMCache).length, cache.filter(c => c instanceof KVCache).length];
  loadDone = true;
  generation = generateAutoregressive(binding, PROMPT, { cache, maxTokens: MAX_TOKENS });
  for await (const t of generation) {
    emitted.push(t.token);
    lastYield = t;
    yieldCount = t.index + 1;
  }
  out = [emitted, generation.stats.generatedTokens, cache[3].offset, cache[3].keys.shape, cache[0].offset];
  completed = true;
}
main().catch(e => { out = ["error", String(e && e.message)]; });
"#
source_parse source
source_ast
end Driver

/-- `Route`'s modules with this driver as the entry. -/
def mods : List UMod := Route.mods.dropLast ++ [⟨Route.entry, Driver.ast⟩]

/-- `%proof/decode-input` with the prompt's elements `fw`: the array (allocated as an
array literal is, `newArray`), then `PROMPT` and `MAX_TOKENS` (the symbolic budget, as in
`Route`). -/
def inputV (fw : List Val) : HMod LSt := ⟨chars!"%proof/decode-input", do
  let a ← modifyGet fun s => newArray s fw
  pure [(chars!"PROMPT", .obj a), (chars!"MAX_TOKENS", .num (.ref 0))]⟩

def hostsV (fw : List Val) : List (HMod LSt) := Route.hosts.dropLast ++ [inputV fw]

def cxV (fw : List Val) : LinkCx LSt := ⟨mods, hostsV fw, Route.entry, chars!"/tmp/tscov/inst"⟩

/-- The route for the prompt `π` (token ids). -/
abbrev cx (π : List Nat) : LinkCx LSt := cxV (π.map natV)

abbrev hosts (π : List Nat) : List (HMod LSt) := hostsV (π.map natV)

/-! ## Agreement with `Route` -/

theorem mods_dropLast : Route.mods = Route.mods.dropLast ++ [⟨Route.entry, Route.Driver.ast⟩] := rfl

theorem hosts_dropLast :
    Route.hosts = Route.hosts.dropLast ++ [⟨chars!"%proof/decode-input", pure [(chars!"MAX_TOKENS", .num (.ref 0))]⟩] := rfl

theorem mods_length : mods.length = Route.mods.length := by
  rw [mods_dropLast]; simp [mods]

theorem hosts_length (fw : List Val) : (hostsV fw).length = Route.hosts.length := by
  rw [hosts_dropLast]; simp [hostsV]

/-- The module-level names, hence the driver's own cells. -/
theorem own_names : Driver.ast.flatMap itemNames = Route.Driver.ast.flatMap itemNames := rfl

/-- The imported modules, in order (the evaluation order of the link). -/
theorem import_sources : Driver.ast.filterMap (fun | .import_ _ src => some src | _ => none) =
    Route.Driver.ast.filterMap (fun | .import_ _ src => some src | _ => none) := rfl

/-- The drivers differ in two of their 22 items: the import from `%proof/decode-input`
(item 8, which adds `PROMPT`) and `main` (item 20). -/
theorem items_agree : Driver.ast.length = 22 ∧ Route.Driver.ast.length = 22 ∧
    Driver.ast.take 8 = Route.Driver.ast.take 8 ∧
    (Driver.ast.drop 9).take 11 = (Route.Driver.ast.drop 9).take 11 ∧
    Driver.ast.drop 21 = Route.Driver.ast.drop 21 := ⟨rfl, rfl, rfl, rfl, rfl⟩

theorem import_agree :
    Driver.ast[8]? = some (.import_ [.named chars!"MAX_TOKENS" chars!"MAX_TOKENS", .named chars!"PROMPT" chars!"PROMPT"]
      chars!"%proof/decode-input") ∧
    Route.Driver.ast[8]? = some (.import_ [.named chars!"MAX_TOKENS" chars!"MAX_TOKENS"] chars!"%proof/decode-input") :=
  ⟨rfl, rfl⟩

def mainOf : Option Item → Option Func
  | some (.stmt (.func f)) => some f
  | _ => none

def bodyOf : Func → List Stmt
  | .mk _ _ _ (.block ss) _ _ _ => ss
  | _ => []

/-- `f` with its body replaced. -/
def withBody : Func → List Stmt → Func
  | .mk n ps r _ a g p, ss => .mk n ps r (.block ss) a g p

/-- `main` agrees with `Route`'s except in statement 6 of its ten, the call of
`generateAutoregressive` right after `loadDone = true` (statement 5). -/
theorem main_agree : ∃ f g, mainOf Driver.ast[20]? = some f ∧ mainOf Route.Driver.ast[20]? = some g ∧
    withBody f [] = withBody g [] ∧ (bodyOf f).length = 10 ∧ (bodyOf g).length = 10 ∧
    (bodyOf f).take 6 = (bodyOf g).take 6 ∧ (bodyOf f).drop 7 = (bodyOf g).drop 7 :=
  ⟨_, _, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

end Host.Load.RoutePrompt
