import host.sim.template.a4pre_first_tail_x8_r0_suffix.States
import host.sim.compose.a4b.VWFramesDefs
import host.sim.template.FastOk

section -- H0
-- Serialized lookahead: [1,2]
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x8_r0_suffix 0
host_stream_state PRE_first_tail_x8_r0_suffix 1
host_stream_state PRE_first_tail_x8_r0_suffix 2
host_stream_state PRE_first_tail_x8_r0_suffix 3
host_stream_state PRE_first_tail_x8_r0_suffix 4
host_stream_state PRE_first_tail_x8_r0_suffix 5
host_stream_state PRE_first_tail_x8_r0_suffix 6
host_stream_state PRE_first_tail_x8_r0_suffix 7
host_stream_state PRE_first_tail_x8_r0_suffix 8
end Host.Load.Run.Tpl
end

section -- TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x8_r0_suffix.bodyOkB (bytes : List Byte) (rows : Nat) : St Host.Load.Layers.full.S → SSrv → Bool :=
  Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows

end Host.Load.Run.Tpl
end
