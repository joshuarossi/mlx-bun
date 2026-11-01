import host.sim.compose.a4b.PF2Nb
import host.sim.template.FullShiftGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF2.tokens : (Host.Ts.Sim.Full.mlxOf PRE_first_tail_x2_r0_suffix.s8.ffi).tokens = (Host.Ts.Sim.Full.mlxOf PRE_pf_vw.s0.ffi).tokens.map PFW2.R.data.map.nv
kernel_rfl PF2.tokSupp : (Host.Ts.Sim.Full.mlxOf PRE_pf_vw.s0.ffi).tokens.all (bSN PRE_pf_vw.n) = true
kernel_rfl PF2.bridge : bridgeOf PRE_first_tail_x2_r0_suffix.s8.ffi = bridgeOf PRE_pf_vw.s0.ffi
kernel_rfl PF2.live : liveShiftB PFW2.R.data.map (Host.Ts.Sim.Full.mlxOf PRE_pf_vw.s0.ffi) (freedOf PRE_pf_vw.s0.ffi) (freedOf PRE_first_tail_x2_r0_suffix.s8.ffi) = true
kernel_rfl PF2.kern : kernShiftB PFW2.R.data.map PRE_pf_vw.n (Host.Ts.Sim.Full.mlxOf PRE_pf_vw.s0.ffi) (krecOf PRE_pf_vw.s0.ffi) (krecOf PRE_first_tail_x2_r0_suffix.s8.ffi) = true
kernel_rfl PF2.pendR : pendRegB PFW2.R.data.map (Host.Ts.Sim.Full.mlxOf PRE_pf_vw.s0.ffi) = true
kernel_rfl PF2.pendLe : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_pf_vw.s0.ffi).next (Host.Ts.Sim.Full.mlxOf PRE_first_tail_x2_r0_suffix.s8.ffi).next = true

theorem PF2.fullShift : Conv.FullShiftQ PF2.P0 PRE_pf_vw.n PFW2.R.data.map PRE_pf_vw.s0.ffi PRE_first_tail_x2_r0_suffix.s8.ffi :=
  ⟨PF2.nshift, PF2.tokens, fun t ht => bSN_sound (List.all_eq_true.mp PF2.tokSupp t ht), PF2.bridge,
    liveShift_of PF2.live, kernShift_of PF2.kern,
    pendReg_of rfl PF2.nnh0 PF2.nnh1 (Nat.le_of_ble_eq_true PF2.pendLe) PF2.pendR⟩

end Host.Load.Run.Tpl
