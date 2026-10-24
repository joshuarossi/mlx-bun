import host.sim.extract.CacheFinal
import host.sim.template.eosx.Case
import host.sim.template.finale.Case
import host.sim.template.finalec0.Case
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Load.Run.Full Host.Ts.Sim.ExtractSim

/-! # The EOS cases' `cache` binding

Each EOS case's halt still holds the template start's caches (its tensor nodes are
`tplCaches`; no forward runs after the cut), with bigint tensor handles and an unframed array
(`final_cache` then gives the target's). -/

noncomputable def EOSX.cacheA : Nat := match bindingOf EOSX.s4 (entryEnv P.s0) chars!"cache" with
  | some (.obj a) => a
  | _ => 0
noncomputable def EOSX.cs : List Host.Load.Extract.Cache := (cachesT EOSX.s4 (entryEnv P.s0)).getD []
kernel_rfl EOSX.cachePresent : (EOSX.s4.heap.get cacheCell).isSome = true
kernel_rfl EOSX.cacheBind : bindingOf EOSX.s4 (entryEnv P.s0) chars!"cache" = some (.obj EOSX.cacheA)
kernel_rfl EOSX.cacheUnframed : [2673447, 12502, 3123589].contains EOSX.cacheA = false
kernel_rfl EOSX.cacheOk : cachesAllB EOSX.s4 (entryEnv P.s0) cacheOkB = true
kernel_rfl EOSX.caches : cachesT EOSX.s4 (entryEnv P.s0) = some EOSX.cs
kernel_rfl EOSX.cacheNodes : EOSX.cs.map nodePair = Host.Mlx.SimGraph.Iter.tplCaches

noncomputable def FINALE.cacheA : Nat := match bindingOf FINALE.s4 (entryEnv P.s0) chars!"cache" with
  | some (.obj a) => a
  | _ => 0
noncomputable def FINALE.cs : List Host.Load.Extract.Cache := (cachesT FINALE.s4 (entryEnv P.s0)).getD []
kernel_rfl FINALE.cachePresent : (FINALE.s4.heap.get cacheCell).isSome = true
kernel_rfl FINALE.cacheBind : bindingOf FINALE.s4 (entryEnv P.s0) chars!"cache" = some (.obj FINALE.cacheA)
kernel_rfl FINALE.cacheUnframed : [2673447, 12502, 3123626].contains FINALE.cacheA = false
kernel_rfl FINALE.cacheOk : cachesAllB FINALE.s4 (entryEnv P.s0) cacheOkB = true
kernel_rfl FINALE.caches : cachesT FINALE.s4 (entryEnv P.s0) = some FINALE.cs
kernel_rfl FINALE.cacheNodes : FINALE.cs.map nodePair = Host.Mlx.SimGraph.Iter.tplCaches

noncomputable def FINALEC0.cacheA : Nat := match bindingOf FINALEC0.s4 (entryEnv P.s0) chars!"cache" with
  | some (.obj a) => a
  | _ => 0
noncomputable def FINALEC0.cs : List Host.Load.Extract.Cache := (cachesT FINALEC0.s4 (entryEnv P.s0)).getD []
kernel_rfl FINALEC0.cachePresent : (FINALEC0.s4.heap.get cacheCell).isSome = true
kernel_rfl FINALEC0.cacheBind : bindingOf FINALEC0.s4 (entryEnv P.s0) chars!"cache" = some (.obj FINALEC0.cacheA)
kernel_rfl FINALEC0.cacheUnframed : [2673447, 12502, 3123627].contains FINALEC0.cacheA = false
kernel_rfl FINALEC0.cacheOk : cachesAllB FINALEC0.s4 (entryEnv P.s0) cacheOkB = true
kernel_rfl FINALEC0.caches : cachesT FINALEC0.s4 (entryEnv P.s0) = some FINALEC0.cs
kernel_rfl FINALEC0.cacheNodes : FINALEC0.cs.map nodePair = Host.Mlx.SimGraph.Iter.tplCaches

end Host.Load.Run.Tpl
