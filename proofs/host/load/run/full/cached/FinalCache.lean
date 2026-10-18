import host.load.run.full.cached.Choice5
import host.load.stop.BudgetEnd
namespace Host.Load.Run.Full.Cached
open Host.Ts Host.Load.Extract
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
/-- The caller-owned cache bindings survive the real generator cleanup. -/
theorem final_cache_snapshot :
    ((bindingOf P.s3575 (entryEnv P.s0) chars!"cache").bind (elements P.s3575)).bind
      (List.mapM (cache P.s3575)) = some after5.cache := by rfl
end Host.Load.Run.Full.Cached
