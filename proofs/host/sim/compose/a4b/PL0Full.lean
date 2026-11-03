import host.sim.compose.a4b.PL0Nb
import host.sim.template.FullShiftGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PL0.tokens : (Host.Ts.Sim.Full.mlxOf PRE_fd_x0_r0_body.s447.ffi).tokens = (Host.Ts.Sim.Full.mlxOf PRE_plx0_entry.s0.ffi).tokens.map PLW0.R.data.map.nv
kernel_rfl PL0.tokSupp : (Host.Ts.Sim.Full.mlxOf PRE_plx0_entry.s0.ffi).tokens.all (bSN PRE_plx0_entry.n) = true
kernel_rfl PL0.bridge : bridgeOf PRE_fd_x0_r0_body.s447.ffi = bridgeOf PRE_plx0_entry.s0.ffi
kernel_rfl PL0.live : liveShiftB PLW0.R.data.map (Host.Ts.Sim.Full.mlxOf PRE_plx0_entry.s0.ffi) (freedOf PRE_plx0_entry.s0.ffi) (freedOf PRE_fd_x0_r0_body.s447.ffi) = true
kernel_rfl PL0.kern : kernShiftB PLW0.R.data.map PRE_plx0_entry.n (Host.Ts.Sim.Full.mlxOf PRE_plx0_entry.s0.ffi) (krecOf PRE_plx0_entry.s0.ffi) (krecOf PRE_fd_x0_r0_body.s447.ffi) = true
kernel_rfl PL0.pendR : pendRegB PLW0.R.data.map (Host.Ts.Sim.Full.mlxOf PRE_plx0_entry.s0.ffi) = true
kernel_rfl PL0.pendLe : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_plx0_entry.s0.ffi).next (Host.Ts.Sim.Full.mlxOf PRE_fd_x0_r0_body.s447.ffi).next = true

theorem PL0.fullShift : Conv.FullShiftQ PL0.P0 PRE_plx0_entry.n PLW0.R.data.map PRE_plx0_entry.s0.ffi PRE_fd_x0_r0_body.s447.ffi :=
  ⟨PL0.nshift, PL0.tokens, fun t ht => bSN_sound (List.all_eq_true.mp PL0.tokSupp t ht), PL0.bridge,
    liveShift_of PL0.live, kernShift_of PL0.kern,
    pendReg_of rfl PL0.nnh0 PL0.nnh1 (Nat.le_of_ble_eq_true PL0.pendLe) PL0.pendR⟩

end Host.Load.Run.Tpl
