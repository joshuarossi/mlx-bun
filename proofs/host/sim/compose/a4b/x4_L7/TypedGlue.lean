import host.sim.compose.a4b.x4_L7.DispatchTpl
import host.sim.template.BootEq
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L7
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl

kernel_rfl typedAccepted28 : (fun (bs : List Byte) (rows : Nat) => VWFrames.typedOk bs rows PRE_first_tail_x4_L7_r0.s28 PRE_first_tail_x4_L7_r0.S28) = fun _ _ => true
kernel_rfl top28 : noRetBlock PRE_first_tail_x4_L7_r0.s28 = true
kernel_rfl typedAccepted29 : (fun (bs : List Byte) (rows : Nat) => VWFrames.typedOk bs rows PRE_first_tail_x4_L7_r0.s29 PRE_first_tail_x4_L7_r0.S29) = fun _ _ => true
kernel_rfl top29 : noRetBlock PRE_first_tail_x4_L7_r0.s29 = true
boot_rfl typedRun28 from PRE_first_tail_x4_L7_r0.s28 to PRE_first_tail_x4_L7_r0.s29 :
  (fun (bs : List Byte) (rows : Nat) => runOk FF (VWFrames.typedOk bs rows) 57
    PRE_first_tail_x4_L7_r0.s28 PRE_first_tail_x4_L7_r0.S28) =
    fun _ _ => some (PRE_first_tail_x4_L7_r0.s29, PRE_first_tail_x4_L7_r0.S29)

kernel_rfl typedAccepted31 : (fun (bs : List Byte) (rows : Nat) => VWFrames.typedOk bs rows PRE_first_tail_x4_L7_r0.s31 PRE_first_tail_x4_L7_r0.S31) = fun _ _ => true
kernel_rfl top31 : noRetBlock PRE_first_tail_x4_L7_r0.s31 = true
kernel_rfl typedAccepted32 : (fun (bs : List Byte) (rows : Nat) => VWFrames.typedOk bs rows PRE_first_tail_x4_L7_r0.s32 PRE_first_tail_x4_L7_r0.S32) = fun _ _ => true
kernel_rfl top32 : noRetBlock PRE_first_tail_x4_L7_r0.s32 = true
boot_rfl typedRun31 from PRE_first_tail_x4_L7_r0.s31 to PRE_first_tail_x4_L7_r0.s32 :
  (fun (bs : List Byte) (rows : Nat) => runOk FF (VWFrames.typedOk bs rows) 15
    PRE_first_tail_x4_L7_r0.s31 PRE_first_tail_x4_L7_r0.S31) =
    fun _ _ => some (PRE_first_tail_x4_L7_r0.s32, PRE_first_tail_x4_L7_r0.S32)

kernel_rfl typedAccepted34 : (fun (bs : List Byte) (rows : Nat) => VWFrames.typedOk bs rows PRE_first_tail_x4_L7_r0.s34 PRE_first_tail_x4_L7_r0.S34) = fun _ _ => true
kernel_rfl top34 : noRetBlock PRE_first_tail_x4_L7_r0.s34 = true
kernel_rfl typedAccepted35 : (fun (bs : List Byte) (rows : Nat) => VWFrames.typedOk bs rows PRE_first_tail_x4_L7_r0.s35 PRE_first_tail_x4_L7_r0.S35) = fun _ _ => true
kernel_rfl top35 : noRetBlock PRE_first_tail_x4_L7_r0.s35 = true
boot_rfl typedRun34 from PRE_first_tail_x4_L7_r0.s34 to PRE_first_tail_x4_L7_r0.s35 :
  (fun (bs : List Byte) (rows : Nat) => runOk FF (VWFrames.typedOk bs rows) 71
    PRE_first_tail_x4_L7_r0.s34 PRE_first_tail_x4_L7_r0.S34) =
    fun _ _ => some (PRE_first_tail_x4_L7_r0.s35, PRE_first_tail_x4_L7_r0.S35)

kernel_rfl typedAccepted37 : (fun (bs : List Byte) (rows : Nat) => VWFrames.typedOk bs rows PRE_first_tail_x4_L7_r0.s37 PRE_first_tail_x4_L7_r0.S37) = fun _ _ => true
kernel_rfl top37 : noRetBlock PRE_first_tail_x4_L7_r0.s37 = true
kernel_rfl typedAccepted38 : (fun (bs : List Byte) (rows : Nat) => VWFrames.typedOk bs rows PRE_first_tail_x4_L7_r0.s38 PRE_first_tail_x4_L7_r0.S38) = fun _ _ => true
kernel_rfl top38 : noRetBlock PRE_first_tail_x4_L7_r0.s38 = true
boot_rfl typedRun37 from PRE_first_tail_x4_L7_r0.s37 to PRE_first_tail_x4_L7_r0.s38 :
  (fun (bs : List Byte) (rows : Nat) => runOk FF (VWFrames.typedOk bs rows) 1
    PRE_first_tail_x4_L7_r0.s37 PRE_first_tail_x4_L7_r0.S37) =
    fun _ _ => some (PRE_first_tail_x4_L7_r0.s38, PRE_first_tail_x4_L7_r0.S38)

kernel_rfl typedAccepted40 : (fun (bs : List Byte) (rows : Nat) => VWFrames.typedOk bs rows PRE_first_tail_x4_L7_r0.s40 PRE_first_tail_x4_L7_r0.S40) = fun _ _ => true
kernel_rfl top40 : noRetBlock PRE_first_tail_x4_L7_r0.s40 = true
kernel_rfl typedAccepted41 : (fun (bs : List Byte) (rows : Nat) => VWFrames.typedOk bs rows PRE_first_tail_x4_L7_r0.s41 PRE_first_tail_x4_L7_r0.S41) = fun _ _ => true
kernel_rfl top41 : noRetBlock PRE_first_tail_x4_L7_r0.s41 = true
boot_rfl typedRun40 from PRE_first_tail_x4_L7_r0.s40 to PRE_first_tail_x4_L7_r0.s41 :
  (fun (bs : List Byte) (rows : Nat) => runOk FF (VWFrames.typedOk bs rows) 7
    PRE_first_tail_x4_L7_r0.s40 PRE_first_tail_x4_L7_r0.S40) =
    fun _ _ => some (PRE_first_tail_x4_L7_r0.s41, PRE_first_tail_x4_L7_r0.S41)

end Host.Ts.Sim.Compose.VWFirst.X4_L7
