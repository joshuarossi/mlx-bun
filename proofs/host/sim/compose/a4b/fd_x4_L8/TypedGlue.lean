import host.sim.compose.a4b.fd_x4_L8.DispatchTpl
import host.sim.template.BootEq
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.FDX4L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl

kernel_rfl typedAccepted11 : (fun (bs : List Byte) (rows : Nat) => FDX4L8Frames.typedOk bs rows PRE_fd_x4_L8_r0.s11 PRE_fd_x4_L8_r0.S11) = fun _ _ => true
kernel_rfl top11 : noRetBlock PRE_fd_x4_L8_r0.s11 = true
kernel_rfl typedAccepted12 : (fun (bs : List Byte) (rows : Nat) => FDX4L8Frames.typedOk bs rows PRE_fd_x4_L8_r0.s12 PRE_fd_x4_L8_r0.S12) = fun _ _ => true
kernel_rfl top12 : noRetBlock PRE_fd_x4_L8_r0.s12 = true
boot_rfl typedRun11 from PRE_fd_x4_L8_r0.s11 to PRE_fd_x4_L8_r0.s12 :
  (fun (bs : List Byte) (rows : Nat) => runOk FF (FDX4L8Frames.typedOk bs rows) 57
    PRE_fd_x4_L8_r0.s11 PRE_fd_x4_L8_r0.S11) =
    fun _ _ => some (PRE_fd_x4_L8_r0.s12, PRE_fd_x4_L8_r0.S12)

kernel_rfl typedAccepted14 : (fun (bs : List Byte) (rows : Nat) => FDX4L8Frames.typedOk bs rows PRE_fd_x4_L8_r0.s14 PRE_fd_x4_L8_r0.S14) = fun _ _ => true
kernel_rfl top14 : noRetBlock PRE_fd_x4_L8_r0.s14 = true
kernel_rfl typedAccepted15 : (fun (bs : List Byte) (rows : Nat) => FDX4L8Frames.typedOk bs rows PRE_fd_x4_L8_r0.s15 PRE_fd_x4_L8_r0.S15) = fun _ _ => true
kernel_rfl top15 : noRetBlock PRE_fd_x4_L8_r0.s15 = true
boot_rfl typedRun14 from PRE_fd_x4_L8_r0.s14 to PRE_fd_x4_L8_r0.s15 :
  (fun (bs : List Byte) (rows : Nat) => runOk FF (FDX4L8Frames.typedOk bs rows) 15
    PRE_fd_x4_L8_r0.s14 PRE_fd_x4_L8_r0.S14) =
    fun _ _ => some (PRE_fd_x4_L8_r0.s15, PRE_fd_x4_L8_r0.S15)

kernel_rfl typedAccepted17 : (fun (bs : List Byte) (rows : Nat) => FDX4L8Frames.typedOk bs rows PRE_fd_x4_L8_r0.s17 PRE_fd_x4_L8_r0.S17) = fun _ _ => true
kernel_rfl top17 : noRetBlock PRE_fd_x4_L8_r0.s17 = true
kernel_rfl typedAccepted18 : (fun (bs : List Byte) (rows : Nat) => FDX4L8Frames.typedOk bs rows PRE_fd_x4_L8_r0.s18 PRE_fd_x4_L8_r0.S18) = fun _ _ => true
kernel_rfl top18 : noRetBlock PRE_fd_x4_L8_r0.s18 = true
boot_rfl typedRun17 from PRE_fd_x4_L8_r0.s17 to PRE_fd_x4_L8_r0.s18 :
  (fun (bs : List Byte) (rows : Nat) => runOk FF (FDX4L8Frames.typedOk bs rows) 71
    PRE_fd_x4_L8_r0.s17 PRE_fd_x4_L8_r0.S17) =
    fun _ _ => some (PRE_fd_x4_L8_r0.s18, PRE_fd_x4_L8_r0.S18)

kernel_rfl typedAccepted20 : (fun (bs : List Byte) (rows : Nat) => FDX4L8Frames.typedOk bs rows PRE_fd_x4_L8_r0.s20 PRE_fd_x4_L8_r0.S20) = fun _ _ => true
kernel_rfl top20 : noRetBlock PRE_fd_x4_L8_r0.s20 = true
kernel_rfl typedAccepted21 : (fun (bs : List Byte) (rows : Nat) => FDX4L8Frames.typedOk bs rows PRE_fd_x4_L8_r0.s21 PRE_fd_x4_L8_r0.S21) = fun _ _ => true
kernel_rfl top21 : noRetBlock PRE_fd_x4_L8_r0.s21 = true
boot_rfl typedRun20 from PRE_fd_x4_L8_r0.s20 to PRE_fd_x4_L8_r0.s21 :
  (fun (bs : List Byte) (rows : Nat) => runOk FF (FDX4L8Frames.typedOk bs rows) 1
    PRE_fd_x4_L8_r0.s20 PRE_fd_x4_L8_r0.S20) =
    fun _ _ => some (PRE_fd_x4_L8_r0.s21, PRE_fd_x4_L8_r0.S21)

kernel_rfl typedAccepted23 : (fun (bs : List Byte) (rows : Nat) => FDX4L8Frames.typedOk bs rows PRE_fd_x4_L8_r0.s23 PRE_fd_x4_L8_r0.S23) = fun _ _ => true
kernel_rfl top23 : noRetBlock PRE_fd_x4_L8_r0.s23 = true
kernel_rfl typedAccepted24 : (fun (bs : List Byte) (rows : Nat) => FDX4L8Frames.typedOk bs rows PRE_fd_x4_L8_r0.s24 PRE_fd_x4_L8_r0.S24) = fun _ _ => true
kernel_rfl top24 : noRetBlock PRE_fd_x4_L8_r0.s24 = true
boot_rfl typedRun23 from PRE_fd_x4_L8_r0.s23 to PRE_fd_x4_L8_r0.s24 :
  (fun (bs : List Byte) (rows : Nat) => runOk FF (FDX4L8Frames.typedOk bs rows) 7
    PRE_fd_x4_L8_r0.s23 PRE_fd_x4_L8_r0.S23) =
    fun _ _ => some (PRE_fd_x4_L8_r0.s24, PRE_fd_x4_L8_r0.S24)

end Host.Ts.Sim.Compose.FDX4L8
