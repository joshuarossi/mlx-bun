import host.sim.extract.CacheEnd
import host.sim.extract.CacheFix
import host.sim.template.final.Case
import host.sim.template.finalc0.Case
import host.sim.template.finalc1.Case
import host.simgraph.iter.Inputs
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Load.Run.Full Host.Ts.Sim.ExtractSim

/-! # The final cases' `cache` binding

Each final case's halt still holds the template start's caches (its tensor nodes are
`tplCaches`), with bigint tensor handles and an unframed array. Under the end relation,
with the `cache` cell fixed, the target's `cache` binding extracts to the caches at the
nodes' images (`final_cache`). -/

/-- **The target's `cache` binding at the end of a final case.** -/
theorem final_cache {LP : LoadP} {r : List NumV} {MF : Map} {ν : Nat → F64} {KF : Ctx} {sF tF : St LSt}
    {SF : SSrv} {CF : CSrv} {aN aC : Nat} (hend : Rel Host.Load.ffi (LR LP r) MF ν KF sF SF tF CF)
    (hfix : MF.a cacheCell = cacheCell) (hKF : ∀ a, KF.fr a ≠ none ↔ a ∈ [2673447, 12502, aN])
    (hpres : (sF.heap.get cacheCell).isSome = true)
    (hbind : bindingOf sF (entryEnv P.s0) chars!"cache" = some (.obj aC))
    (hne : [2673447, 12502, aN].contains aC = false)
    (hok : cachesAllB sF (entryEnv P.s0) cacheOkB = true) {cs : List Host.Load.Extract.Cache}
    (hcs : cachesT sF (entryEnv P.s0) = some cs) (hn : cs.map nodePair = Host.Mlx.SimGraph.Iter.tplCaches) :
    ∃ cs', cachesT tF (entryEnv P.s0) = some cs' ∧
      cs'.map nodePair = Host.Mlx.SimGraph.Iter.tplCaches.map fun p => (p.1.map MF.node, p.2.map MF.node) := by
  refine cachesT_end_nodes hend cache_cell hpres hfix (fun a ha => ?_) hok hcs hn
  rw [hbind] at ha
  cases ha
  by_contra hfr
  have hm := (hKF aC).1 hfr
  have : [2673447, 12502, aN].contains aC = true := List.contains_iff_mem.mpr hm
  rw [hne] at this
  cases this

/-! ## The three final cases -/

noncomputable def FINAL.cacheA : Nat := match bindingOf FINAL.s3 (entryEnv P.s0) chars!"cache" with
  | some (.obj a) => a
  | _ => 0
noncomputable def FINAL.cs : List Host.Load.Extract.Cache := (cachesT FINAL.s3 (entryEnv P.s0)).getD []
kernel_rfl FINAL.cachePresent : (FINAL.s3.heap.get cacheCell).isSome = true
kernel_rfl FINAL.cacheBind : bindingOf FINAL.s3 (entryEnv P.s0) chars!"cache" = some (.obj FINAL.cacheA)
kernel_rfl FINAL.cacheUnframed : [2673447, 12502, 3123641].contains FINAL.cacheA = false
kernel_rfl FINAL.cacheOk : cachesAllB FINAL.s3 (entryEnv P.s0) cacheOkB = true
kernel_rfl FINAL.caches : cachesT FINAL.s3 (entryEnv P.s0) = some FINAL.cs
kernel_rfl FINAL.cacheNodes : FINAL.cs.map nodePair = Host.Mlx.SimGraph.Iter.tplCaches

noncomputable def FINALC0.cacheA : Nat := match bindingOf FINALC0.s3 (entryEnv P.s0) chars!"cache" with
  | some (.obj a) => a
  | _ => 0
noncomputable def FINALC0.cs : List Host.Load.Extract.Cache := (cachesT FINALC0.s3 (entryEnv P.s0)).getD []
kernel_rfl FINALC0.cachePresent : (FINALC0.s3.heap.get cacheCell).isSome = true
kernel_rfl FINALC0.cacheBind : bindingOf FINALC0.s3 (entryEnv P.s0) chars!"cache" = some (.obj FINALC0.cacheA)
kernel_rfl FINALC0.cacheUnframed : [2673447, 12502, 3123642].contains FINALC0.cacheA = false
kernel_rfl FINALC0.cacheOk : cachesAllB FINALC0.s3 (entryEnv P.s0) cacheOkB = true
kernel_rfl FINALC0.caches : cachesT FINALC0.s3 (entryEnv P.s0) = some FINALC0.cs
kernel_rfl FINALC0.cacheNodes : FINALC0.cs.map nodePair = Host.Mlx.SimGraph.Iter.tplCaches

noncomputable def FINALC1.cacheA : Nat := match bindingOf FINALC1.s3 (entryEnv P.s0) chars!"cache" with
  | some (.obj a) => a
  | _ => 0
noncomputable def FINALC1.cs : List Host.Load.Extract.Cache := (cachesT FINALC1.s3 (entryEnv P.s0)).getD []
kernel_rfl FINALC1.cachePresent : (FINALC1.s3.heap.get cacheCell).isSome = true
kernel_rfl FINALC1.cacheBind : bindingOf FINALC1.s3 (entryEnv P.s0) chars!"cache" = some (.obj FINALC1.cacheA)
kernel_rfl FINALC1.cacheUnframed : [2673447, 12502, 3123642].contains FINALC1.cacheA = false
kernel_rfl FINALC1.cacheOk : cachesAllB FINALC1.s3 (entryEnv P.s0) cacheOkB = true
kernel_rfl FINALC1.caches : cachesT FINALC1.s3 (entryEnv P.s0) = some FINALC1.cs
kernel_rfl FINALC1.cacheNodes : FINALC1.cs.map nodePair = Host.Mlx.SimGraph.Iter.tplCaches

end Host.Load.Run.Tpl
