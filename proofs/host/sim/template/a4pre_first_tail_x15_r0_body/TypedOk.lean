import host.sim.compose.a4b.VWFramesDefs
import host.sim.template.FastOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.bodyOkB (bytes : List Byte) (rows : Nat) : St Host.Load.Layers.full.S → SSrv → Bool :=
  Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows

end Host.Load.Run.Tpl
