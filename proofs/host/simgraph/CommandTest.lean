import host.simgraph.Command
import host.simgraph.Classify
namespace Host.Mlx.SimGraph.CommandTest
open Host.Ts Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Mlx.Ffi (Dim Prim Node)

/-! A synthetic template: an old checkpoint load (node 1, before the
template's start 2) and two fresh nodes whose dimensions are the offset
numbers `int32(var 9 + 1)` (table entry 1) and `int32(var 9)` (entry 0). -/

def table : SSrv := ⟨[.un .int32 (.var 9), .un .int32 (.bin .add (.var 9) (.lit (F64.ofNat 1)))], []⟩

def state : Ffi.St :=
  let s := Ffi.init [] [] [] []
  let s := (s.addNode ⟨.load ['f'] ['w'], [], [.lit 1, .lit 4, .lit 1, .lit 256], 12⟩).2
  let s := (s.addNode ⟨.reshape [.lit 1, .lit 4, .sym (.ref 1), .lit 256], [1], [], 12⟩).2
  (s.addNode ⟨.rope 64 false (.big 7) (.lit (F64.ofNat 1)) (.ref 0), [2], [], 12⟩).2

def sources : KernelSources := ⟨fun _ => [], fun _ => []⟩

def graph : Nat → Option (RNode SDim InKey) := fresh 2 (symGraph (clsOf table 9) sources state)

def expected : List (RNode SDim InKey) :=
  [⟨.input .tokenIds, []⟩, ⟨.reshape [.lit 1, .lit 4, .pos1, .lit 256], [0]⟩,
   ⟨.rope 64 false 7 (F64.f32Bits (F64.toF32 (F64.ofNat 1))) .pos, [1]⟩]

def cert : List Nat := [1, 2, 3]

def inputs : InKey → Option Nat
  | .tokenIds => some 1
  | _ => none

simgraph_check_template synthetic : graph, expected, cert, inputs choosing expected

/-- One check covers every offset. -/
theorem every_offset (n : Nat) :
    Matches (mapG (SDim.eval n) graph) (expected.map (mapN (SDim.eval n))) cert = true :=
  matchesD_map (SDim.eval n) graph expected cert synthetic.matches

theorem carriers : inputCarriersMatchD expected cert inputs = true := synthetic.inputs

/-- A wrong offset dimension is rejected. -/
theorem rejects_wrong_offset :
    MatchesD graph [⟨.input .tokenIds, []⟩, ⟨.reshape [.lit 1, .lit 4, .pos, .lit 256], [0]⟩] [1, 2] = false := by
  decide +kernel

/-- The old load node is not part of the fresh template graph. -/
theorem old_absent : graph 1 = none := by decide +kernel

end Host.Mlx.SimGraph.CommandTest
