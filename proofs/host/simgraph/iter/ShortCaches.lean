import host.sim.extract.CacheEnd
import host.load.run.tail.Short1
import host.load.run.tail.Short2
import host.load.run.full.cached.Choice2
import host.load.run.full.FirstChoice
import host.load.CacheCarriersCommand
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Mlx.SimGraph.Iter
open Host.Ts Host.Load Host.Load.Extract Host.Load.Run.Full Host.Load.Run.Full.Cached Host.Load.Run.Tail
open Host.Ts.Sim.ExtractSim (cachesT nodePair)

/-! The short budgets' halted states: the program's `cache` binding extracts to caches at
the nodes of the last forward's caches (time 1: `firstChoice.cache`, time 2: `after2.cache`). -/

noncomputable def short1Caches : List Cache := (cachesT Short1.s4 (entryEnv P.s0)).getD []
noncomputable def short2Caches : List Cache := (cachesT Short2.s2 (entryEnv P.s0)).getD []

kernel_rfl short1_caches : cachesT Short1.s4 (entryEnv P.s0) = some short1Caches
kernel_rfl short1_cacheNodes : short1Caches.map nodePair = firstChoice.cache.map cacheNodePair
kernel_rfl short2_caches : cachesT Short2.s2 (entryEnv P.s0) = some short2Caches
kernel_rfl short2_cacheNodes : short2Caches.map nodePair = after2.cache.map cacheNodePair

end Host.Mlx.SimGraph.Iter
