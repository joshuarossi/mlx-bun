import host.sim.compose.a4b.PF1Nb
import host.sim.template.FullShiftGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF1.tokens : (Host.Ts.Sim.Full.mlxOf PRE_first_tail_x1_r0_suffix.s8.ffi).tokens = (Host.Ts.Sim.Full.mlxOf PRE_pf_vw.s0.ffi).tokens.map PFW1.R.data.map.nv
kernel_rfl PF1.tokSupp : (Host.Ts.Sim.Full.mlxOf PRE_pf_vw.s0.ffi).tokens.all (bSN PRE_pf_vw.n) = true
kernel_rfl PF1.bridge : bridgeOf PRE_first_tail_x1_r0_suffix.s8.ffi = bridgeOf PRE_pf_vw.s0.ffi
kernel_rfl PF1.live : liveShiftB PFW1.R.data.map (Host.Ts.Sim.Full.mlxOf PRE_pf_vw.s0.ffi) (freedOf PRE_pf_vw.s0.ffi) (freedOf PRE_first_tail_x1_r0_suffix.s8.ffi) = true
kernel_rfl PF1.kern : kernShiftB PFW1.R.data.map PRE_pf_vw.n (Host.Ts.Sim.Full.mlxOf PRE_pf_vw.s0.ffi) (krecOf PRE_pf_vw.s0.ffi) (krecOf PRE_first_tail_x1_r0_suffix.s8.ffi) = true
kernel_rfl PF1.pendR : pendRegB PFW1.R.data.map (Host.Ts.Sim.Full.mlxOf PRE_pf_vw.s0.ffi) = true
kernel_rfl PF1.pendLe : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_pf_vw.s0.ffi).next (Host.Ts.Sim.Full.mlxOf PRE_first_tail_x1_r0_suffix.s8.ffi).next = true

theorem PF1.fullShift : Conv.FullShiftQ PF1.P0 PRE_pf_vw.n PFW1.R.data.map PRE_pf_vw.s0.ffi PRE_first_tail_x1_r0_suffix.s8.ffi :=
  ⟨PF1.nshift, PF1.tokens, fun t ht => bSN_sound (List.all_eq_true.mp PF1.tokSupp t ht), PF1.bridge,
    liveShift_of PF1.live, kernShift_of PF1.kern,
    pendReg_of rfl PF1.nnh0 PF1.nnh1 (Nat.le_of_ble_eq_true PF1.pendLe) PF1.pendR⟩

end Host.Load.Run.Tpl
