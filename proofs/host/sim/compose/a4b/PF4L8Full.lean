import host.sim.compose.a4b.PF4L8Nb
import host.sim.template.FullShiftGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF4L8.tokens : (Host.Ts.Sim.Full.mlxOf PRE_first_tail_x4_L8_r0_suffix.s8.ffi).tokens = (Host.Ts.Sim.Full.mlxOf PRE_pf_x4_L8.s0.ffi).tokens.map PFW4L8.R.data.map.nv
kernel_rfl PF4L8.tokSupp : (Host.Ts.Sim.Full.mlxOf PRE_pf_x4_L8.s0.ffi).tokens.all (bSN PRE_pf_x4_L8.n) = true
kernel_rfl PF4L8.bridge : bridgeOf PRE_first_tail_x4_L8_r0_suffix.s8.ffi = bridgeOf PRE_pf_x4_L8.s0.ffi
kernel_rfl PF4L8.live : liveShiftB PFW4L8.R.data.map (Host.Ts.Sim.Full.mlxOf PRE_pf_x4_L8.s0.ffi) (freedOf PRE_pf_x4_L8.s0.ffi) (freedOf PRE_first_tail_x4_L8_r0_suffix.s8.ffi) = true
kernel_rfl PF4L8.kern : kernShiftB PFW4L8.R.data.map PRE_pf_x4_L8.n (Host.Ts.Sim.Full.mlxOf PRE_pf_x4_L8.s0.ffi) (krecOf PRE_pf_x4_L8.s0.ffi) (krecOf PRE_first_tail_x4_L8_r0_suffix.s8.ffi) = true
kernel_rfl PF4L8.pendR : pendRegB PFW4L8.R.data.map (Host.Ts.Sim.Full.mlxOf PRE_pf_x4_L8.s0.ffi) = true
kernel_rfl PF4L8.pendLe : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_pf_x4_L8.s0.ffi).next (Host.Ts.Sim.Full.mlxOf PRE_first_tail_x4_L8_r0_suffix.s8.ffi).next = true

theorem PF4L8.fullShift : Conv.FullShiftQ PF4L8.P0 PRE_pf_x4_L8.n PFW4L8.R.data.map PRE_pf_x4_L8.s0.ffi PRE_first_tail_x4_L8_r0_suffix.s8.ffi :=
  ⟨PF4L8.nshift, PF4L8.tokens, fun t ht => bSN_sound (List.all_eq_true.mp PF4L8.tokSupp t ht), PF4L8.bridge,
    liveShift_of PF4L8.live, kernShift_of PF4L8.kern,
    pendReg_of rfl PF4L8.nnh0 PF4L8.nnh1 (Nat.le_of_ble_eq_true PF4L8.pendLe) PF4L8.pendR⟩

end Host.Load.Run.Tpl
