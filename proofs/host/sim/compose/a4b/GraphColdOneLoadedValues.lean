import host.sim.compose.a4b.GraphColdOneValues
import host.sim.compose.a4b.GraphColdOneEos
import host.sim.compose.a4b.SetupD1Parameters
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false

namespace Host.Ts.Sim.Compose.ColdGraph.OneLoaded
open _root_.Host.Ts _root_.Host.Ts.Sim _root_.Host.Load _root_.Host.Load.Extract
open _root_.Host.Load.Program _root_.Host.Load.Run.Full _root_.Host.Load.Run.Tpl
open _root_.Host.Mlx _root_.Host.Mlx.GlueStep _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

noncomputable def Result {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey) (table : List F64)
    (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env table leaves typed))
    (input : Fin 248320) (Mp : Map) (t : St Full.FF.S) (Cs : CSrv) : Prop :=
  let after := (firstContext M K env table leaves typed parameters).run input 1 (by decide)
  ∃ hs', (∃ r, evalR M K env
      (ffiGraph (concrete Cs.val) SourceKernels.sources (Full.mlxOf t.ffi)) (Mp.node 17776) = some r ∧
      itemUint32 r = some after.token.val) ∧
    ChainHolds (firstPipeline M K env table leaves typed).graph.stages hs' after.cache ∧
    fullExpected.2.2.length = hs'.length ∧
    (∀ h ∈ hs', (handleVals h).isSome) ∧
    ∀ q ∈ cacheFacts fullExpected.2.2 hs',
      evalR M K env (ffiGraph (concrete Cs.val) SourceKernels.sources (Full.mlxOf t.ffi))
        (certAt (choice.cert.map Mp.node) q.1) = some q.2

variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C)

/-- Parameter evaluation is derived from the accepted input witness and actual
native growth, on the same target graph as the checked One endpoint. -/
theorem sample (env : FfiEval.Env InKey) (table : List F64)
    (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env table leaves typed))
    (input : Fin 248320) {T : Nat} {tk : Nat → Nat} {x : SegInst Full.FF}
    (h : (SetupD1Values.forwardValuesInputCut 15235 T tk).R x D1Call.s1 ⟨D1Call.S1.tab, []⟩)
    (P : LoadP) (NB : Nat) (Mp : Map) (n : Nat) (t : St Full.FF.S) (Cs : CSrv)
    (hg : Host.Mlx.Ffi.NGrow (Full.mlxOf x.t.ffi) (Full.mlxOf t.ffi))
    (hR : G.MR P NB Mp n One.native (Full.mlxOf t.ffi)) (hNB : 15235 ≤ NB)
    (hband : P.NL = P.N0) (ρ : Nat → F64) (hρ : ρ 9 = F64.ofNat 1)
    (hnum : ∀ i e, nth? D1PostOne.S10.tab i = some e → Cs.val (Mp.nv (.ref i)) = some (e.eval ρ))
    (hrope : Mp.big 5554869888 = 5554869888)
    (hinput : SetupD1Input.InputAt [input.val] (Mp.node tokenNode) t Cs) :
    Result M K env table leaves typed parameters input Mp t Cs :=
  One.sample M K env table leaves typed parameters input P NB Mp n t Cs hR hNB hband ρ hρ hnum hrope hinput
    (SetupD1Parameters.cold_parameters M K env table leaves h t Cs input.val hg)

/-- The EOS endpoint has the same checked native graph, while keeping its own
actual target relation and number server. -/
theorem sample_eos (env : FfiEval.Env InKey) (table : List F64)
    (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env table leaves typed))
    (input : Fin 248320) {T : Nat} {tk : Nat → Nat} {x : SegInst Full.FF}
    (h : (SetupD1Values.forwardValuesInputCut 15235 T tk).R x D1Call.s1 ⟨D1Call.S1.tab, []⟩)
    (P : LoadP) (NB : Nat) (Mp : Map) (n : Nat) (t : St Full.FF.S) (Cs : CSrv)
    (hg : Host.Mlx.Ffi.NGrow (Full.mlxOf x.t.ffi) (Full.mlxOf t.ffi))
    (hR : G.MR P NB Mp n OneEos.native (Full.mlxOf t.ffi)) (hNB : 15235 ≤ NB)
    (hband : P.NL = P.N0) (ρ : Nat → F64) (hρ : ρ 9 = F64.ofNat 1)
    (hnum : ∀ i e, nth? D1PostOneEos.S10.tab i = some e → Cs.val (Mp.nv (.ref i)) = some (e.eval ρ))
    (hrope : Mp.big 5554869888 = 5554869888)
    (hinput : SetupD1Input.InputAt [input.val] (Mp.node tokenNode) t Cs) :
    Result M K env table leaves typed parameters input Mp t Cs :=
  sample M K env table leaves typed parameters input h P NB Mp n t Cs hg
    (OneEos.native_relation P NB Mp n (Full.mlxOf t.ffi) hR) hNB hband ρ hρ
    (fun i e he => hnum i e (by rw [OneEos.table_same]; exact he)) hrope hinput

end Host.Ts.Sim.Compose.ColdGraph.OneLoaded
