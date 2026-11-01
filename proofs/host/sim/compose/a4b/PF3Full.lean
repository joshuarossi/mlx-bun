import host.sim.compose.a4b.PF3Nb
import host.sim.template.FullShiftGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF3.tokens : (Host.Ts.Sim.Full.mlxOf PRE_first_tail_x3_r0_suffix.s8.ffi).tokens = (Host.Ts.Sim.Full.mlxOf PRE_pf_vw.s0.ffi).tokens.map PFW3.R.data.map.nv
kernel_rfl PF3.tokSupp : (Host.Ts.Sim.Full.mlxOf PRE_pf_vw.s0.ffi).tokens.all (bSN PRE_pf_vw.n) = true
kernel_rfl PF3.bridge : bridgeOf PRE_first_tail_x3_r0_suffix.s8.ffi = bridgeOf PRE_pf_vw.s0.ffi
kernel_rfl PF3.live : liveShiftB PFW3.R.data.map (Host.Ts.Sim.Full.mlxOf PRE_pf_vw.s0.ffi) (freedOf PRE_pf_vw.s0.ffi) (freedOf PRE_first_tail_x3_r0_suffix.s8.ffi) = true
kernel_rfl PF3.kern : kernShiftB PFW3.R.data.map PRE_pf_vw.n (Host.Ts.Sim.Full.mlxOf PRE_pf_vw.s0.ffi) (krecOf PRE_pf_vw.s0.ffi) (krecOf PRE_first_tail_x3_r0_suffix.s8.ffi) = true
kernel_rfl PF3.pendR : pendRegB PFW3.R.data.map (Host.Ts.Sim.Full.mlxOf PRE_pf_vw.s0.ffi) = true
kernel_rfl PF3.pendLe : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_pf_vw.s0.ffi).next (Host.Ts.Sim.Full.mlxOf PRE_first_tail_x3_r0_suffix.s8.ffi).next = true

theorem PF3.fullShift : Conv.FullShiftQ PF3.P0 PRE_pf_vw.n PFW3.R.data.map PRE_pf_vw.s0.ffi PRE_first_tail_x3_r0_suffix.s8.ffi :=
  ⟨PF3.nshift, PF3.tokens, fun t ht => bSN_sound (List.all_eq_true.mp PF3.tokSupp t ht), PF3.bridge,
    liveShift_of PF3.live, kernShift_of PF3.kern,
    pendReg_of rfl PF3.nnh0 PF3.nnh1 (Nat.le_of_ble_eq_true PF3.pendLe) PF3.pendR⟩

end Host.Load.Run.Tpl
