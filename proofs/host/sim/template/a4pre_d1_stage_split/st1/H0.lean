import host.sim.template.a4pre_d1_stage_split.States
import host.sim.template.a4pre_d1_stage_split.H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state D1StageSplit.st1 0
host_stream_state D1StageSplit.st1 1
host_stream_state D1StageSplit.st1 2
end Host.Load.Run.Tpl
