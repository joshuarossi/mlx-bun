import host.sim.compose.a4b.GraphColdOneEosSource
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Ts.Sim.Compose.ColdGraph.OneEos
open _root_.Host.Ts _root_.Host.Ts.Sim _root_.Host.Load _root_.Host.Load.Run.Tpl
open _root_.Host.Load.Extract _root_.Host.Load.Run.Full
open _root_.Host.Mlx _root_.Host.Mlx.GlueStep _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph
open _root_.Host.Mlx.SimGraph.Iter
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

theorem native_image (P : LoadP) (NB : Nat) (Mp : Map) (n : Nat) (y : Ffi.St)
    (hR : G.MR P NB Mp n native y) (hband : P.NL = P.N0) :
    NativeImage Mp.node (numImg Mp.nv Mp.big Mp.arg Mp.handle) One.prefixDom endLoad.ffi.mlx y :=
  One.native_image P NB Mp n y (native_relation P NB Mp n y hR) hband

/-- The frozen One prefix template is embedded from the actual EOS native relation. -/
theorem embedding_prefix (table : List F64) (P : LoadP) (NB : Nat) (Mp : Map) (n : Nat) (y : Ffi.St)
    (hR : G.MR P NB Mp n native y) (hband : P.NL = P.N0)
    (ρ : Nat → F64) (hρ : ρ 9 = F64.ofNat 1)
    (hnum : ∀ i e, nth? D1PostOneEos.S10.tab i = some e →
      CSrv.val ⟨table⟩ (Mp.nv (.ref i)) = some (e.eval ρ))
    (hrope : Mp.big 5554869888 = 5554869888) (ν : Nat → Int) :
    Embeds Mp.node Mp.handle (mapG (PDim.eval ν) One.prefixGs)
      (ffiGraph (κ := InKey) (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources y) :=
  One.embedding_prefix table P NB Mp n y (native_relation P NB Mp n y hR) hband ρ hρ
    (fun i e he => hnum i e (by rw [table_same]; exact he)) hrope ν

theorem «matches» (table : List F64) (P : LoadP) (NB : Nat) (Mp : Map) (n : Nat) (y : Ffi.St)
    (hR : G.MR P NB Mp n native y) (hband : P.NL = P.N0)
    (ρ : Nat → F64) (hρ : ρ 9 = F64.ofNat 1)
    (hnum : ∀ i e, nth? D1PostOneEos.S10.tab i = some e →
      CSrv.val ⟨table⟩ (Mp.nv (.ref i)) = some (e.eval ρ))
    (hrope : Mp.big 5554869888 = 5554869888) (ν : Nat → Int) :
    Matches (ffiGraph (κ := InKey) (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources y)
      (fullExpected.1.map (Host.Mlx.SimGraph.mapN (PDim.eval ν))) (choice.cert.map Mp.node) = true :=
  One.matches table P NB Mp n y (native_relation P NB Mp n y hR) hband ρ hρ
    (fun i e he => hnum i e (by rw [table_same]; exact he)) hrope ν

theorem native_inputs (P : LoadP) (NB : Nat) (Mp : Map) (n : Nat) (y : Ffi.St)
    (hR : G.MR P NB Mp n native y) (hNB : 15235 ≤ NB) (ν : Nat → Int) :
    inputCarriersMatch (fullExpected.1.map (Host.Mlx.SimGraph.mapN (PDim.eval ν))) (choice.cert.map Mp.node)
      (inputNode (loadedAt Mp.node cacheInputs) (tensorAt (Mp.node tokenNode))) = true :=
  One.native_inputs P NB Mp n y (native_relation P NB Mp n y hR) hNB ν

variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C)

theorem input_values_of_inputAt (value : TensorValues)
    (weightsEnv : List Char → List Char → Option Value)
    (P : LoadP) (NB : Nat) (Mp : Map) (n : Nat) (t : St Full.FF.S) (Cs : CSrv)
    (hR : G.MR P NB Mp n native (Full.mlxOf t.ffi)) (hNB : 15235 ≤ NB)
    (token : Nat) (hvocab : token < 248320)
    (hinput : SetupD1Input.InputAt [token] (Mp.node tokenNode) t Cs)
    (hp : ∀ u, u ∈ parameterTensors parameterChoice →
      evalR M K (stepEnvWithIds weightsEnv (weights value) (coldIds token) initialHandles)
        (ffiGraph (concrete Cs.val) SourceKernels.sources (Full.mlxOf t.ffi)) u.node = some (value u))
    (ν : Nat → Int) :
    InputsHeld M K (stepEnvWithIds weightsEnv (weights value) (coldIds token) initialHandles)
      (ffiGraph (concrete Cs.val) SourceKernels.sources (Full.mlxOf t.ffi))
      (fullExpected.1.map (Host.Mlx.SimGraph.mapN (PDim.eval ν))) (choice.cert.map Mp.node) ∧
      TokenBuffer (coldIds token) token :=
  One.input_values_of_inputAt M K value weightsEnv P NB Mp n t Cs
    (native_relation P NB Mp n (Full.mlxOf t.ffi) hR) hNB token hvocab hinput hp ν

end Host.Ts.Sim.Compose.ColdGraph.OneEos
