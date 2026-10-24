import host.ts.Harness
import host.sim.dispatch.Call

/-! # Tests: `Map` memos (`set`, `has`, `get` by string key)

The interpreter's memo pattern (`packages/mlx/src/ops.ts`, `cstr`), and the acceptance of
`set`, `has` and `get` on an unframed `Map`, a `Map` by key and a memo
(`Disp.okMap`, `host/sim/steps/MapMemo.lean`); `set` of a number key on an unframed `Map` only. -/

namespace Host.Ts.Sim.Tests.MapMemo
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Disp

/- The memo pattern: a miss computes and stores, a hit returns the stored value. -/
namespace Memo
def source : String := "const cache = new Map(); function cstr(s) { let b = cache.get(s); if (!b) { b = [s]; cache.set(s, b); } return b; } const x = cstr(\"affine\"); const out = [x === cstr(\"affine\"), cache.has(\"affine\"), cache.has(\"other\"), cache.get(\"other\") === undefined];"
source_parse source
source_ast
kernel_rfl runs : ((snippetJ ast).map fun j => J.beq j (.arr [.bool true, .bool true, .bool false, .bool true])) =
  some true
end Memo

/-- A state with the given heap entries (`nullFfi`). -/
def st (hp : List (Nat × HObj)) (next : Nat) : St Unit :=
  ⟨hp.foldl (fun h p => h.set p.1 p.2) PTrie.nil, next, .ret .undef, [], ⟨[], (), [], []⟩⟩

/-- A map at 50 holding `"affine"`. -/
def memoSt : St Unit := st [(50, .obj ⟨.map [(.str (chars!"affine"), .num (.lit (F64.ofNat 1)))], .obj aMapProto, [], [], true⟩)] 51

/-- Acceptance parameters with the map at 50 under the frame `w` (or unframed). -/
def jsp (w : Option WFrame) : JSP nullFfi :=
  { okCall := fun _ _ _ => false, smallB := fun _ _ _ _ => false, lo := 0, hi := 0,
    framed := (w.map fun _ => [50]).getD [], isHandle := fun _ _ => false, isRegion := fun _ _ => false,
    wide := (w.map fun w => [(50, w)]).getD [] }

def key (cs : List Char) : List Val := [.str cs, .undef]

/- Unframed: `set` and `has` of every string key. -/
kernel_rfl set_unframed : okMap (jsp none) memoSt (.obj 50) (key (chars!"other")) .set = true
kernel_rfl has_unframed : okMap (jsp none) memoSt (.obj 50) (key (chars!"other")) .has = true
/- A `Map` by key: `set` of every key, `has` of a held key only. -/
kernel_rfl set_keys : okMap (jsp (some (.mapKeys []))) memoSt (.obj 50) (key (chars!"other")) .set = true
kernel_rfl has_keys_held : okMap (jsp (some (.mapKeys []))) memoSt (.obj 50) (key (chars!"affine")) .has = true
kernel_rfl has_keys_absent : okMap (jsp (some (.mapKeys []))) memoSt (.obj 50) (key (chars!"other")) .has = false
/- A memo: `get`, `has`, `set` of held and absent keys; a ghost key's `get` is rejected. -/
kernel_rfl get_memo_absent : mapGetMemoB (jsp (some (.memo []))) memoSt (.obj 50) (.str (chars!"other")) = true
kernel_rfl has_memo_absent : okMap (jsp (some (.memo []))) memoSt (.obj 50) (key (chars!"other")) .has = true
kernel_rfl set_memo : okMap (jsp (some (.memo []))) memoSt (.obj 50) (key (chars!"other")) .set = true
/- A number key (`compile.ts`'s `traceRegistry.set(id, …)`): unframed only. -/
kernel_rfl set_num_unframed : okMap (jsp none) memoSt (.obj 50) [.num (.lit (F64.ofNat 4)), .undef] .set = true
kernel_rfl set_num_keys : okMap (jsp (some (.mapKeys []))) memoSt (.obj 50) [.num (.lit (F64.ofNat 4)), .undef] .set = false
kernel_rfl get_memo_ghost :
  mapGetMemoB (jsp (some (.memo [pack (chars!"other")]))) memoSt (.obj 50) (.str (chars!"other")) = false

end Host.Ts.Sim.Tests.MapMemo
