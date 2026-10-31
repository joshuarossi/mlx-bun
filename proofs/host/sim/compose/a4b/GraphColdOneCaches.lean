import host.sim.compose.a4b.GraphColdOneCacheEosSource
import host.sim.compose.a4b.GraphColdOneLoadedValues
import host.sim.compose.a4b.SetupD1PostOne
import host.sim.compose.a4b.SetupD1PostOneEos
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false

namespace Host.Ts.Sim.Compose.ColdGraph.OneCache
open _root_.Host.Ts _root_.Host.Ts.Sim _root_.Host.Ts.Sim.Full
open _root_.Host.Load _root_.Host.Load.Extract _root_.Host.Load.Layers _root_.Host.Load.Run.Tpl
open _root_.Host.Load.Program _root_.Host.Load.Run.Full
open _root_.Host.Mlx _root_.Host.Mlx.FfiEval _root_.Host.Mlx.GlueStep _root_.Host.Mlx.SimGraph
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

theorem typed_support (bytes : List Byte) (a : Nat) (w : WFrame)
    (h : D1Frames.typedW bytes a = some w) : a ∈ wideDomain := by
  by_cases hv : a = D1Frames.view
  · subst a; decide
  · by_cases hb : a = D1Frames.buffer
    · subst a; decide
    · by_cases hm : a = 4910
      · subst a; decide
      · simp [D1Frames.typedW, Disp.wAt, Template.wideP, Template.beq_false hv,
          Template.beq_false hb, Template.beq_false hm] at h

kernel_rfl typed_cache_cell : (fun bytes : List Byte => D1Frames.typedW bytes 2586) = fun _ => none

kernel_rfl carrier_bounds : fullExpected.2.2.all
  (fun p => decide (p.1 < choice.cert.length ∧ p.2 < choice.cert.length)) = true

theorem mapped_carriers (Mp : Map) :
    (sourceCaches.map cacheNodePair).map (fun p => (p.1.map Mp.node, p.2.map Mp.node)) =
      fullExpected.2.2.map (fun p =>
        (some (certAt (choice.cert.map Mp.node) p.1), some (certAt (choice.cert.map Mp.node) p.2))) := by
  rw [source_nodes, List.map_map]
  apply List.map_congr_left
  intro p hp
  have hb := List.all_eq_true.mp carrier_bounds p hp
  have hb := of_decide_eq_true hb
  simp only [Function.comp_apply, certifiedCachePair, Option.map_some]
  rw [certAt_map Mp.node choice.cert p.1 hb.1, certAt_map Mp.node choice.cert p.2 hb.2]

theorem cache_metadata {Mp : Map} : ∀ {cs cs' : List Cache},
    ExtractSim.LRel (CacheRW Mp) cs cs' →
      cs'.length = cs.length ∧ cs'.map Cache.operation = cs.map Cache.operation
  | [], [], _ => ⟨rfl, rfl⟩
  | _ :: _, [], h => h.elim
  | [], _ :: _, h => h.elim
  | c :: cs, c' :: cs', h => by
      obtain ⟨hl, ho⟩ := cache_metadata h.2
      exact ⟨congrArg Nat.succ hl, congrArg₂ List.cons h.1.1 ho⟩

/-- Actual extraction on the same full-world witness, retaining class and tensor
correspondence. The offset field of this extraction is the existing placeholder. -/
def Extracted (x : SegInst FF) (je : Env) : Prop :=
  ∃ cs, ExtractSim.cachesT (x.t.reFfi (toLoad x.t.ffi)) je = some cs ∧
    ExtractSim.LRel (CacheRW x.M) sourceCaches cs

theorem extracted_carriers {x : SegInst FF} {je : Env} (h : Extracted x je) :
    ∃ cs, ExtractSim.cachesT (x.t.reFfi (toLoad x.t.ffi)) je = some cs ∧
      cs.length = 64 ∧ cs.map Cache.operation = cacheOperations ∧
      cs.map cacheNodePair = fullExpected.2.2.map (fun p =>
        (some (certAt (choice.cert.map x.M.node) p.1), some (certAt (choice.cert.map x.M.node) p.2))) := by
  obtain ⟨cs, hc, hr⟩ := h
  obtain ⟨hl, ho⟩ := cache_metadata hr
  have hn := cacheRW_nodes hr
  change cs.map cacheNodePair =
    (sourceCaches.map cacheNodePair).map (fun p => (p.1.map x.M.node, p.2.map x.M.node)) at hn
  exact ⟨cs, hc, hl.trans source_count, ho.trans source_operations, hn.trans (mapped_carriers x.M)⟩

theorem one_extract {NB : Nat} {tk : Nat → Nat} {bytes : List Byte} {q : List Val}
    {ν : Nat → F64} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St}
    {x : SegInst FF} {je : Env}
    (hr : (SetupD1PostOne.endCut NB tk bytes q ν K0 M0 y0 D1PostOne.s10 D1PostOne.S10).R
      x D1PostOne.s10 ⟨D1PostOne.S10.tab, []⟩)
    (hb : (SetupD1PostOne.endCut NB tk bytes q ν K0 M0 y0 D1PostOne.s10 D1PostOne.S10).B x)
    (hlookup : lookupEnv chars!"cache" je = some 2586) : Extracted x je := by
  obtain ⟨hrel, hbook⟩ := hr
  obtain ⟨_, hanchor, _⟩ := hb
  obtain ⟨P', _, hn⟩ := hrel.ffi.1.1
  have hfr : x.K.fr 2672295 = none := by
    by_contra h
    have hm := (hbook.context.1.2.2 2672295).mp h
    exact (by decide : 2672295 ∉ [2665, 2673479, 2673484, 2673485] ++
      [2673435, D1PostOne.cacheArray]) hm
  obtain ⟨cs, hc, he⟩ := hrel.cachesTW_end (typed_support bytes) hn.load.mlx.toMRw hlookup
    hanchor.1 (congrFun typed_cache_cell bytes) cache_cell hfr
    ((ok_env D1PostOne.s10 hlookup).trans source_ok)
    ((extraction_env mlxOf D1PostOne.s10 hlookup).trans source_extraction)
  refine ⟨cs, ?_, he⟩
  rw [← cachesTW_lf, cachesTW_reFfi]
  exact hc

theorem eos_extract {NB : Nat} {tk : Nat → Nat} {bytes : List Byte} {q : List Val}
    {ν : Nat → F64} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St}
    {x : SegInst FF} {je : Env}
    (hr : (SetupD1PostOneEos.endCut NB tk bytes q ν K0 M0 y0 D1PostOneEos.s10 D1PostOneEos.S10).R
      x D1PostOneEos.s10 ⟨D1PostOneEos.S10.tab, []⟩)
    (hb : (SetupD1PostOneEos.endCut NB tk bytes q ν K0 M0 y0 D1PostOneEos.s10 D1PostOneEos.S10).B x)
    (hlookup : lookupEnv chars!"cache" je = some 2586) : Extracted x je := by
  obtain ⟨hrel, hbook⟩ := hr
  obtain ⟨_, hanchor, _⟩ := hb
  obtain ⟨P', _, hn⟩ := hrel.ffi.1.1
  have hfr : x.K.fr 2672295 = none := by
    by_contra h
    have hm := (hbook.context.1.2.2 2672295).mp h
    exact (by decide : 2672295 ∉ [2665, 2673479, 2673484, 2673485] ++
      [2673435, D1PostOneEos.cacheArray]) hm
  obtain ⟨cs, hc, he⟩ := hrel.cachesTW_end (typed_support bytes) hn.load.mlx.toMRw hlookup
    hanchor.1 (congrFun typed_cache_cell bytes) D1PostOneEos.cacheCell hfr
    ((ok_env D1PostOneEos.s10 hlookup).trans eos_ok)
    ((extraction_env mlxOf D1PostOneEos.s10 hlookup).trans eos_extraction)
  refine ⟨cs, ?_, he⟩
  rw [← cachesTW_lf, cachesTW_reFfi]
  exact hc

theorem one_saved_extract {NB : Nat} {tk : Nat → Nat} {bytes : List Byte} {q : List Val}
    {ν : Nat → F64} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St}
    {x : SegInst FF} (fw : List Val) (tail : List NumV)
    (hr : (SetupD1PostOne.endCut NB tk bytes q ν K0 M0 y0 D1PostOne.s10 D1PostOne.S10).R
      x D1PostOne.s10 ⟨D1PostOne.S10.tab, []⟩)
    (hb : (SetupD1PostOne.endCut NB tk bytes q ν K0 M0 y0 D1PostOne.s10 D1PostOne.S10).B x) :
    Extracted x (entryEnv (_root_.Host.Load.Run.Prompt.P.at0 fw tail)) :=
  one_extract hr hb (saved_lookup fw tail)

theorem eos_saved_extract {NB : Nat} {tk : Nat → Nat} {bytes : List Byte} {q : List Val}
    {ν : Nat → F64} {K0 : Host.Ts.Sim.Ctx} {M0 : Map} {y0 : Host.Mlx.Ffi.St}
    {x : SegInst FF} (fw : List Val) (tail : List NumV)
    (hr : (SetupD1PostOneEos.endCut NB tk bytes q ν K0 M0 y0 D1PostOneEos.s10 D1PostOneEos.S10).R
      x D1PostOneEos.s10 ⟨D1PostOneEos.S10.tab, []⟩)
    (hb : (SetupD1PostOneEos.endCut NB tk bytes q ν K0 M0 y0 D1PostOneEos.s10 D1PostOneEos.S10).B x) :
    Extracted x (entryEnv (_root_.Host.Load.Run.Prompt.P.at0 fw tail)) :=
  eos_extract hr hb (saved_lookup fw tail)

variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C)

/-- Internal consumer of the accepted `OneLoaded.sample` / `sample_eos`
semantic interface, at the identical map, native state and concrete server. -/
theorem values_of_result (env : FfiEval.Env InKey) (table : List F64)
    (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env table leaves typed))
    (input : Fin 248320) {x : SegInst FF} {je : Env} (hex : Extracted x je)
    (hsem : OneLoaded.Result M K env table leaves typed parameters input x.M x.t x.C) :
    let after := (firstContext M K env table leaves typed parameters).run input 1 (by decide)
    ∃ cs hs, ExtractSim.cachesT (x.t.reFfi (toLoad x.t.ffi)) je = some cs ∧
      cs.length = 64 ∧ cs.map Cache.operation = cacheOperations ∧
      (∃ r, evalR M K env
        (ffiGraph (concrete x.C.val) SourceKernels.sources (mlxOf x.t.ffi)) (x.M.node 17776) = some r ∧
        itemUint32 r = some after.token.val) ∧
      ChainHolds (firstPipeline M K env table leaves typed).graph.stages hs after.cache ∧
      CacheValues M K env (ffiGraph (concrete x.C.val) SourceKernels.sources (mlxOf x.t.ffi)) cs hs := by
  obtain ⟨cs, hc, hl, ho, hn⟩ := extracted_carriers hex
  obtain ⟨hs, ht, hchain, hlen, hsome, hev⟩ := hsem
  exact ⟨cs, hs, hc, hl, ho, ht, hchain,
    cacheValues_of_facts M K env _ cs fullExpected.2.2 hs
      (certAt (choice.cert.map x.M.node)) hn hlen hsome hev⟩

end Host.Ts.Sim.Compose.ColdGraph.OneCache
