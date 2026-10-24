import host.simgraph.Command
import host.simgraph.prompt.NativeD
namespace Host.Mlx.SimGraph.PromptTest
open Host.Ts Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Mlx.Ffi (Dim Prim Node)

/-! A synthetic multi-row template: position 9 is the cache offset `o`,
position 17 the rows `n`. The table holds the numbers the TypeScript computes:
`int32(o + n)` (the KV view), `Math.floor((256 + n - 1) / 256) * 256` (the KV
growth, kv.ts), `Math.ceil(n / 8)` (a grid) and `int32(o)` (the RoPE offset).
The kernel checks the template graph, read with the normalizing classifier,
against an expected graph whose dimensions are built with `Aff`. -/

deriving instance Lean.ToExpr for PDim

def one : SymE := .lit (F64.ofNat 1)

def table : SSrv :=
  ⟨[.un .int32 (.bin .add (.var 9) (.var 17)),
    .bin .mul (.un .floor (.bin .div (.bin .sub (.bin .add (.lit (F64.ofNat 256)) (.var 17)) one)
      (.lit (F64.ofNat 256)))) (.lit (F64.ofNat 256)),
    .un .ceil (.bin .div (.var 17) (.lit (F64.ofNat 8))),
    .un .int32 (.var 9)], []⟩

/-- `0 ≤ o ≤ 262144`, `1 ≤ n ≤ 2048`. -/
def box : Box := [(9, 0, 262144), (17, 1, 2048)]

def state : Ffi.St :=
  let s := Ffi.init [] [] [] []
  let s := (s.addNode ⟨.load ['f'] ['w'], [], [.lit 1, .lit 4, .lit 1, .lit 256], 12⟩).2
  let s := (s.addNode ⟨.zeros, [], [.lit 1, .lit 4, .sym (.ref 1), .lit 256], 12⟩).2
  let s := (s.addNode ⟨.slice [.lit 0, .lit 0, .lit 0, .lit 0] [.lit 1, .lit 4, .sym (.ref 0), .lit 256]
    [.lit 1, .lit 1, .lit 1, .lit 1], [2], [], 12⟩).2
  let s := (s.addNode ⟨.rope 64 false (.big 7) (.lit (F64.ofNat 1)) (.ref 3), [3], [], 12⟩).2
  (s.addNode ⟨.reshape [.lit 1, .sym (.ref 2)], [4], [], 12⟩).2

def sources : KernelSources := ⟨fun _ => [], fun _ => []⟩

def graph : Nat → Option (RNode PDim InKey) := fresh 2 (symGraphD (clsOfP table box) PDim.lit sources state)

def oA : Aff := .var 9
def nA : Aff := .var 17

def expected : List (RNode PDim InKey) :=
  [⟨.input .tokenIds, []⟩,
   ⟨.zeros [.lit 1, .lit 4, PDim.ceil256 nA.toP, .lit 256] 12, []⟩,
   ⟨.slice [.lit 0, .lit 0, .lit 0, .lit 0] [.lit 1, .lit 4, (oA.add nA).toP, .lit 256] [.lit 1, .lit 1, .lit 1, .lit 1],
     [1]⟩,
   ⟨.rope 64 false 7 (F64.f32Bits (F64.toF32 (F64.ofNat 1))) oA.toP, [2]⟩,
   ⟨.reshape [.lit 1, .cdiv nA.toP 8], [3]⟩]

def cert : List Nat := [1, 2, 3, 4, 5]

def inputs : InKey → Option Nat
  | .tokenIds => some 1
  | _ => none

simgraph_check_template synthetic : graph, expected, cert, inputs choosing expected

/-- One check covers every offset and row count. -/
theorem every_valuation (ν : Nat → Int) :
    Matches (mapG (PDim.eval ν) graph) (expected.map (mapN (PDim.eval ν))) cert = true :=
  matchesD_map (PDim.eval ν) graph expected cert synthetic.matches

/-- The classifier reads the table correctly at every valuation in the box. -/
theorem classified (ν : Nat → Int) (ρ : Nat → F64) (hB : InBox box ν)
    (hρ : ∀ x l h, box.get x = some (l, h) → ρ x = F64.ofInt (ν x)) :
    ClsSoundD (clsOfP table box) (νsOf table ρ) (PDim.eval ν) :=
  clsOfP_sound table box ν ρ hB hρ

/-- At `o = 4096`, `n = 101`: growth 256, view `4197`, grid `13`. -/
theorem dims_at :
    (PDim.ceil256 nA.toP).eval (fun x => if x = 17 then 101 else 4096) = 256 ∧
    (oA.add nA).toP.eval (fun x => if x = 17 then 101 else 4096) = 4197 ∧
    (PDim.cdiv nA.toP 8).eval (fun x => if x = 17 then 101 else 4096) = 13 := by
  decide

/-- A wrong growth dimension is rejected. -/
theorem rejects_wrong_growth :
    MatchesD graph [⟨.input .tokenIds, []⟩, ⟨.zeros [.lit 1, .lit 4, nA.toP, .lit 256] 12, []⟩] [1, 2] = false := by
  decide +kernel

/-- A product with a symbolic factor is not a dimension: the node does not resolve. -/
theorem unbounded_absent : normP box (.bin .mul (.var 9) (.var 17)) = none := by decide +kernel

end Host.Mlx.SimGraph.PromptTest
