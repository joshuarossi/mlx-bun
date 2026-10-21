import host.sim.template.Build
import host.load.run.full.H102
set_option Elab.async false
namespace Host.Load.Run.Tpl

/-! The loop template `Tpl.Base.s0` from the ordinary readback cut `P.s3272`
(collected and symbolized natively; see `host.sim.template.Build`). -/

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
tpl_template Base from Host.Load.Run.Full.P.s3272, Host.Load.Run.Full.P.S3272

end Host.Load.Run.Tpl
