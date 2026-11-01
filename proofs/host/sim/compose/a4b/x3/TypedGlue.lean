import host.sim.compose.a4b.x3.DispatchTpl
import host.sim.template.BootEq
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X3
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl

kernel_rfl typedAccepted40 : (fun (bs : List Byte) (rows : Nat) => VWFrames.typedOk bs rows PRE_first_tail_x3_r0.s40 PRE_first_tail_x3_r0.S40) = fun _ _ => true
kernel_rfl top40 : noRetBlock PRE_first_tail_x3_r0.s40 = true
kernel_rfl typedAccepted41 : (fun (bs : List Byte) (rows : Nat) => VWFrames.typedOk bs rows PRE_first_tail_x3_r0.s41 PRE_first_tail_x3_r0.S41) = fun _ _ => true
kernel_rfl top41 : noRetBlock PRE_first_tail_x3_r0.s41 = true
boot_rfl typedRun40 from PRE_first_tail_x3_r0.s40 to PRE_first_tail_x3_r0.s41 :
  (fun (bs : List Byte) (rows : Nat) => runOk FF (VWFrames.typedOk bs rows) 7
    PRE_first_tail_x3_r0.s40 PRE_first_tail_x3_r0.S40) =
    fun _ _ => some (PRE_first_tail_x3_r0.s41, PRE_first_tail_x3_r0.S41)

end Host.Ts.Sim.Compose.VWFirst.X3
