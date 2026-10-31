import host.sim.template.a4pre_first_tail_x15_r0_suffix.st0.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_suffix.st0.H0
import host.sim.template.BootEq
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_suffix.st0.bodyK3 from PRE_first_tail_x15_r0_suffix.st0.s3 to PRE_first_tail_x15_r0_suffix.st0.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_suffix.st0.F (PRE_first_tail_x15_r0_suffix.st0.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_suffix.st0.ks 3).getD 0) PRE_first_tail_x15_r0_suffix.st0.s3 PRE_first_tail_x15_r0_suffix.st0.S3) = fun _ _ => some (PRE_first_tail_x15_r0_suffix.st0.s4, PRE_first_tail_x15_r0_suffix.st0.S4)
end Host.Load.Run.Tpl
