import host.load.boundary.fill.H12
import host.load.BoundaryChoice
import host.load.run.full.ChoiceStates
namespace Host.Load.Run.Full.Fill64
open Host.Ts Host.Load.Extract Host.Load.CacheBoundary
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

load_boundary_summary before : entry, entryEnv P.s0
load_summary_checked before_checked : entry, entryEnv P.s0 using before
load_boundary_summary after : s1491, entryEnv P.s0
load_summary_checked after_checked : s1491, entryEnv P.s0 using after

theorem specialization : entry = atOffsets template roots.caches 255 := by rfl

theorem entry_geometry : EntryAt entry roots 255 256 := by
  refine ⟨rfl,rfl,rfl,rfl,rfl,rfl,⟨rfl,rfl⟩,before.cache,rfl,rfl,rfl⟩

theorem model_preserved : before.model = parameterChoice.model ∧ after.model = before.model := ⟨rfl,rfl⟩
theorem cache_count : after.cache.length = 64 := rfl
theorem cache_geometry : after.cache.all (cacheGeometry 256 256) = true := rfl
end Host.Load.Run.Full.Fill64
