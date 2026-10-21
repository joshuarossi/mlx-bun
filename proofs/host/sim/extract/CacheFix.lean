import host.load.run.full.Boot
import host.sim.template.ordinary.Restart
import host.sim.template.clear.Restart
import host.sim.template.growth.Restart
import host.sim.template.fill.Restart
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Load.Run.Full

/-! # The `cache` cell is fixed by every loop case

The entry environment's `cache` binding lives at cell `cacheCell`; each loop case's
restart map keeps it (so `loopFix ++ [cacheCell]` is a fix list of all four cases). -/

/-- The entry environment's `cache` cell. -/
def cacheCell : Nat := 2586

kernel_rfl cache_cell : lookupEnv chars!"cache" (entryEnv P.s0) = some cacheCell

kernel_rfl ORDINARY.fixCache : ORDINARY.σ.a cacheCell = cacheCell
kernel_rfl CLEAR.fixCache : CLEAR.σ.a cacheCell = cacheCell
kernel_rfl GROWTH.fixCache : GROWTH.σ.a cacheCell = cacheCell
kernel_rfl FILL.fixCache : FILL.σ.a cacheCell = cacheCell

end Host.Load.Run.Tpl
