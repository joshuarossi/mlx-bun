import host.sim.tests.ActiveRelationData
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Ts.Sim.Full.ActiveRelation

-- The boot's nodes at `loadDone` are present from 1 up to the counter.
kernel_rfl dense_view : denseB V.load.mlx = true

end Host.Ts.Sim.Full.ActiveRelation
