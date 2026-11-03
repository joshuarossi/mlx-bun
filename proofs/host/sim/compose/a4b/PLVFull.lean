import host.sim.compose.a4b.PLVNb
import host.sim.template.FullShiftGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLV.tokens : (Host.Ts.Sim.Full.mlxOf PRE_fd_vw_r0_body.s900.ffi).tokens = (Host.Ts.Sim.Full.mlxOf PRE_plvw_entry.s0.ffi).tokens.map PLVW.R.data.map.nv
kernel_rfl PLV.tokSupp : (Host.Ts.Sim.Full.mlxOf PRE_plvw_entry.s0.ffi).tokens.all (bSN PRE_plvw_entry.n) = true
kernel_rfl PLV.bridge : bridgeOf PRE_fd_vw_r0_body.s900.ffi = bridgeOf PRE_plvw_entry.s0.ffi
kernel_rfl PLV.live : liveShiftB PLVW.R.data.map (Host.Ts.Sim.Full.mlxOf PRE_plvw_entry.s0.ffi) (freedOf PRE_plvw_entry.s0.ffi) (freedOf PRE_fd_vw_r0_body.s900.ffi) = true
kernel_rfl PLV.kern : kernShiftB PLVW.R.data.map PRE_plvw_entry.n (Host.Ts.Sim.Full.mlxOf PRE_plvw_entry.s0.ffi) (krecOf PRE_plvw_entry.s0.ffi) (krecOf PRE_fd_vw_r0_body.s900.ffi) = true
kernel_rfl PLV.pendR : pendRegB PLVW.R.data.map (Host.Ts.Sim.Full.mlxOf PRE_plvw_entry.s0.ffi) = true
kernel_rfl PLV.pendLe : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_plvw_entry.s0.ffi).next (Host.Ts.Sim.Full.mlxOf PRE_fd_vw_r0_body.s900.ffi).next = true

theorem PLV.fullShift : Conv.FullShiftQ PLV.P0 PRE_plvw_entry.n PLVW.R.data.map PRE_plvw_entry.s0.ffi PRE_fd_vw_r0_body.s900.ffi :=
  ⟨PLV.nshift, PLV.tokens, fun t ht => bSN_sound (List.all_eq_true.mp PLV.tokSupp t ht), PLV.bridge,
    liveShift_of PLV.live, kernShift_of PLV.kern,
    pendReg_of rfl PLV.nnh0 PLV.nnh1 (Nat.le_of_ble_eq_true PLV.pendLe) PLV.pendR⟩

end Host.Load.Run.Tpl
