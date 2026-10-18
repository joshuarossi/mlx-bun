import host.load.growth.H0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full
host_growth_entry_checked Growth256.entry_geometry : Growth256.entry using Growth256.roots
theorem Growth256.entry_specialization :
    Growth256.entry = Host.Load.Growth.atOffset Growth256.template Growth256.roots.cache 256 := by rfl
host_growth_outcome_checked Growth256.outcome : Growth256.s5, Growth256.roots.cache
end Host.Load.Run.Full
