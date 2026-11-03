import host.sim.compose.a4b.PF4L7Nb
import host.sim.template.FullShiftGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF4L7.tokens : (Host.Ts.Sim.Full.mlxOf PRE_first_tail_x4_L7_r0_suffix.s8.ffi).tokens = (Host.Ts.Sim.Full.mlxOf PRE_pf_x4_L7.s0.ffi).tokens.map PFW4L7.R.data.map.nv
kernel_rfl PF4L7.tokSupp : (Host.Ts.Sim.Full.mlxOf PRE_pf_x4_L7.s0.ffi).tokens.all (bSN PRE_pf_x4_L7.n) = true
kernel_rfl PF4L7.bridge : bridgeOf PRE_first_tail_x4_L7_r0_suffix.s8.ffi = bridgeOf PRE_pf_x4_L7.s0.ffi
kernel_rfl PF4L7.live : liveShiftB PFW4L7.R.data.map (Host.Ts.Sim.Full.mlxOf PRE_pf_x4_L7.s0.ffi) (freedOf PRE_pf_x4_L7.s0.ffi) (freedOf PRE_first_tail_x4_L7_r0_suffix.s8.ffi) = true
kernel_rfl PF4L7.kern : kernShiftB PFW4L7.R.data.map PRE_pf_x4_L7.n (Host.Ts.Sim.Full.mlxOf PRE_pf_x4_L7.s0.ffi) (krecOf PRE_pf_x4_L7.s0.ffi) (krecOf PRE_first_tail_x4_L7_r0_suffix.s8.ffi) = true
kernel_rfl PF4L7.pendR : pendRegB PFW4L7.R.data.map (Host.Ts.Sim.Full.mlxOf PRE_pf_x4_L7.s0.ffi) = true
kernel_rfl PF4L7.pendLe : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_pf_x4_L7.s0.ffi).next (Host.Ts.Sim.Full.mlxOf PRE_first_tail_x4_L7_r0_suffix.s8.ffi).next = true

theorem PF4L7.fullShift : Conv.FullShiftQ PF4L7.P0 PRE_pf_x4_L7.n PFW4L7.R.data.map PRE_pf_x4_L7.s0.ffi PRE_first_tail_x4_L7_r0_suffix.s8.ffi :=
  ⟨PF4L7.nshift, PF4L7.tokens, fun t ht => bSN_sound (List.all_eq_true.mp PF4L7.tokSupp t ht), PF4L7.bridge,
    liveShift_of PF4L7.live, kernShift_of PF4L7.kern,
    pendReg_of rfl PF4L7.nnh0 PF4L7.nnh1 (Nat.le_of_ble_eq_true PF4L7.pendLe) PF4L7.pendR⟩

end Host.Load.Run.Tpl
