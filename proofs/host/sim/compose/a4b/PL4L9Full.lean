import host.sim.compose.a4b.PL4L9Nb
import host.sim.template.FullShiftGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PL4L9.tokens : (Host.Ts.Sim.Full.mlxOf PRE_fd_x4_L9_r0_body.s451.ffi).tokens = (Host.Ts.Sim.Full.mlxOf PRE_plx4_L9_entry.s0.ffi).tokens.map PLW4L9.R.data.map.nv
kernel_rfl PL4L9.tokSupp : (Host.Ts.Sim.Full.mlxOf PRE_plx4_L9_entry.s0.ffi).tokens.all (bSN PRE_plx4_L9_entry.n) = true
kernel_rfl PL4L9.bridge : bridgeOf PRE_fd_x4_L9_r0_body.s451.ffi = bridgeOf PRE_plx4_L9_entry.s0.ffi
kernel_rfl PL4L9.live : liveShiftB PLW4L9.R.data.map (Host.Ts.Sim.Full.mlxOf PRE_plx4_L9_entry.s0.ffi) (freedOf PRE_plx4_L9_entry.s0.ffi) (freedOf PRE_fd_x4_L9_r0_body.s451.ffi) = true
kernel_rfl PL4L9.kern : kernShiftB PLW4L9.R.data.map PRE_plx4_L9_entry.n (Host.Ts.Sim.Full.mlxOf PRE_plx4_L9_entry.s0.ffi) (krecOf PRE_plx4_L9_entry.s0.ffi) (krecOf PRE_fd_x4_L9_r0_body.s451.ffi) = true
kernel_rfl PL4L9.pendR : pendRegB PLW4L9.R.data.map (Host.Ts.Sim.Full.mlxOf PRE_plx4_L9_entry.s0.ffi) = true
kernel_rfl PL4L9.pendLe : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_plx4_L9_entry.s0.ffi).next (Host.Ts.Sim.Full.mlxOf PRE_fd_x4_L9_r0_body.s451.ffi).next = true

theorem PL4L9.fullShift : Conv.FullShiftQ PL4L9.P0 PRE_plx4_L9_entry.n PLW4L9.R.data.map PRE_plx4_L9_entry.s0.ffi PRE_fd_x4_L9_r0_body.s451.ffi :=
  ⟨PL4L9.nshift, PL4L9.tokens, fun t ht => bSN_sound (List.all_eq_true.mp PL4L9.tokSupp t ht), PL4L9.bridge,
    liveShift_of PL4L9.live, kernShift_of PL4L9.kern,
    pendReg_of rfl PL4L9.nnh0 PL4L9.nnh1 (Nat.le_of_ble_eq_true PL4L9.pendLe) PL4L9.pendR⟩

end Host.Load.Run.Tpl
