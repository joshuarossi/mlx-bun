import host.sim.compose.a4b.SetupD1Input
import host.mlx.ReadbackValues
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Ts.Sim.Compose.ColdGraph
open _root_.Host.Ts _root_.Host.Ts.Sim _root_.Host.Ts.Sim.Full
open _root_.Host.Mlx _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph _root_.Host.Mlx.GlueStep
open Inference.Contracts.Mlx

/-- The actual host-data obligation supplies ordinary graph evaluation. -/
theorem inputAt_evalR {Cx : M1Max.Contract} (M : MlxContract Cx) (K : KernelContract Cx)
    {κ : Type} [DecidableEq κ] (env : Host.Mlx.FfiEval.Env κ) (sources : KernelSources)
    {π : List Nat} {j : Nat} {t : St Host.Ts.Sim.Full.FF.S} {C : CSrv}
    (h : SetupD1Input.InputAt π j t C) :
    evalR M K env (ffiGraph (concrete C.val) sources (mlxOf t.ffi)) j =
      cellsValue (π.map Int.ofNat) [1,1] := by
  obtain ⟨bytes, shape, hn, hb, hs⟩ := h.2
  have hg : ffiGraph (κ := κ) (concrete C.val) sources (mlxOf t.ffi) j =
      some ⟨.data (cellsBytes (π.map Int.ofNat)) [1,1] Ffi.dtInt32, []⟩ := by
    simp only [ffiGraph, hn, Option.bind_some, resolveNode, resolvePrim, Option.bind_eq_bind,
      hb, hs, Option.bind_some, Option.pure_def, Option.map_some]
  rw [evalR_eq, hg, cgLeaves_none _ _ _ hg rfl]
  rfl

def coldIds (token : Nat) : Value := ⟨.int32, [1,1], fun _ => token⟩

theorem cellsValue_singleton (token : Nat) (ht : token < 2 ^ 31) :
    cellsValue [Int.ofNat token] [1,1] = some (coldIds token) := by
  have hm : F64.modNat (Int.ofNat token) (2 ^ 32) = token := by
    change token % (2 ^ 32) = token
    exact Nat.mod_eq_of_lt (by omega)
  change some (⟨.int32, [1,1], fun i => leWord (leBytes 4 (F64.modNat (Int.ofNat token) (2 ^ 32))) 4 (i % 1)⟩ : Value) = _
  simp only [hm, Nat.mod_one, leWord_u32 token (by omega)]
  rfl

theorem coldIds_buffer (token : Nat) (ht : token < 2 ^ 31) : TokenBuffer (coldIds token) token :=
  ⟨.inr rfl, rfl, rfl, ht⟩

/-- No candidate token value is used: the produced singleton is arbitrary. -/
theorem inputAt_singleton {Cx : M1Max.Contract} (M : MlxContract Cx) (K : KernelContract Cx)
    {κ : Type} [DecidableEq κ] (env : Host.Mlx.FfiEval.Env κ) (sources : KernelSources)
    {token j : Nat} {t : St Host.Ts.Sim.Full.FF.S} {C : CSrv} (ht : token < 248320)
    (h : SetupD1Input.InputAt [token] j t C) :
    evalR M K env (ffiGraph (concrete C.val) sources (mlxOf t.ffi)) j = some (coldIds token) ∧
      TokenBuffer (coldIds token) token := by
  constructor
  · rw [inputAt_evalR M K env sources h]
    exact cellsValue_singleton token (by omega)
  · exact coldIds_buffer token (by omega)
end Host.Ts.Sim.Compose.ColdGraph
