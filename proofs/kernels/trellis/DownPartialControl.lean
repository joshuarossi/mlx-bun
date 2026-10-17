import kernels.trellis.DownPartialSum
namespace Inference.Kernels.Trellis.DownPartialControl
open Contracts.Mlx PackedArraySemantics DownPartialSyntax
set_option maxRecDepth 10000

def integer (cols : BitVec 32) (expression : PackedArraySyntax.Expr) : Option (BitVec 32) :=
  (evaluate 16 ⟨[("SG_COLS",.unsigned cols),("THREADS",.signed 256)],[],[]⟩ expression).bind asUInt

def iterations (thread : Nat) (cols : BitVec 32) (code : OutputLoop) : Option (List Nat) :=
  if code.counter="c" ∧ code.counter=code.test ∧ code.counter=code.increment ∧ code.builtin="thread_position_in_threadgroup.x" then
    (integer cols code.bound).bind (fun bound => (integer cols code.step).bind (fun step =>
      GateLoopSource.iterations 6 (BitVec.ofNat 32 thread) bound step))
  else none

theorem iterations_selected : ∀ thread : Fin 256,
    iterations thread.val 512 output=some ((List.range 4).map (fun iteration => thread.val+256*iteration)) := by decide +kernel

def guardEnvironment (col : BitVec 32) : DownControlSource.Environment := fun name =>
  if name="col" then some (.unsigned col)
  else if name="C" then some (.signed 5120) else none

def skip (col : BitVec 32) : Option Bool :=
  (parse guardTokens guardSource).bind (fun code =>
    (DownControlSource.evaluate (guardEnvironment col) code).bind DownControlSource.boolean)

theorem skip_selected (col : Nat) (bound : col<5120) : skip (BitVec.ofNat 32 col)=some false := by
  rw [skip,parsed_guard,Option.bind_some]
  change some (decide (5120≤(BitVec.ofNat 32 col).toNat))=some false
  rw [BitVec.toNat_ofNat,Nat.mod_eq_of_lt (show col<2^32 by omega)]
  simp only [show ¬5120≤col by omega,decide_false]

def y (ty : Nat) : Option (BitVec 32) :=
  DownDispatchSource.run DownDispatchSource.ySource [("ty",ty)] "y"

theorem y_selected (ty : Nat) (bound : ty<160) : y ty=some (BitVec.ofNat 32 (ty%32)) :=
  DownDispatchSource.y_selected ⟨ty,bound⟩

def outputColumns (k thread : Nat) : Option (List Nat) :=
  (DownPartialIndex.columns k (thread%32)).bind (fun cols =>
    (parse outputTokens outputSource).bind (iterations thread cols))

theorem columns_selected (k thread : Nat) (valid : k=2 ∨ k=3 ∨ k=4) (threadBound : thread<256) :
    outputColumns k thread=some ((List.range 4).map (fun iteration => thread+256*iteration)) := by
  rw [outputColumns,DownPartialIndex.columns_selected k (thread%32) valid (Nat.mod_lt _ (by decide)),Option.bind_some,
    parsed_output,Option.bind_some]
  exact iterations_selected ⟨thread,threadBound⟩
end Inference.Kernels.Trellis.DownPartialControl
