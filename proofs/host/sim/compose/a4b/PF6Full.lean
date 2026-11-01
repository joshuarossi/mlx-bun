import host.sim.compose.a4b.PF6Nb
import host.sim.template.FullShiftGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF6.tokens : (Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_suffix.s8.ffi).tokens = (Host.Ts.Sim.Full.mlxOf PRE_pf_vw.s0.ffi).tokens.map PFW6.R.data.map.nv
kernel_rfl PF6.tokSupp : (Host.Ts.Sim.Full.mlxOf PRE_pf_vw.s0.ffi).tokens.all (bSN PRE_pf_vw.n) = true
kernel_rfl PF6.bridge : bridgeOf PRE_first_tail_x6_r0_suffix.s8.ffi = bridgeOf PRE_pf_vw.s0.ffi
kernel_rfl PF6.live : liveShiftB PFW6.R.data.map (Host.Ts.Sim.Full.mlxOf PRE_pf_vw.s0.ffi) (freedOf PRE_pf_vw.s0.ffi) (freedOf PRE_first_tail_x6_r0_suffix.s8.ffi) = true
kernel_rfl PF6.kern : kernShiftB PFW6.R.data.map PRE_pf_vw.n (Host.Ts.Sim.Full.mlxOf PRE_pf_vw.s0.ffi) (krecOf PRE_pf_vw.s0.ffi) (krecOf PRE_first_tail_x6_r0_suffix.s8.ffi) = true
kernel_rfl PF6.pendR : pendRegB PFW6.R.data.map (Host.Ts.Sim.Full.mlxOf PRE_pf_vw.s0.ffi) = true
kernel_rfl PF6.pendLe : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_pf_vw.s0.ffi).next (Host.Ts.Sim.Full.mlxOf PRE_first_tail_x6_r0_suffix.s8.ffi).next = true

theorem PF6.fullShift : Conv.FullShiftQ PF6.P0 PRE_pf_vw.n PFW6.R.data.map PRE_pf_vw.s0.ffi PRE_first_tail_x6_r0_suffix.s8.ffi :=
  ⟨PF6.nshift, PF6.tokens, fun t ht => bSN_sound (List.all_eq_true.mp PF6.tokSupp t ht), PF6.bridge,
    liveShift_of PF6.live, kernShift_of PF6.kern,
    pendReg_of rfl PF6.nnh0 PF6.nnh1 (Nat.le_of_ble_eq_true PF6.pendLe) PF6.pendR⟩

end Host.Load.Run.Tpl
