import host.sim.compose.a4b.PF15Nb
import host.sim.template.FullShiftGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF15.tokens : (Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_suffix.s8.ffi).tokens = (Host.Ts.Sim.Full.mlxOf PRE_pf_vw.s0.ffi).tokens.map PFW15.R.data.map.nv
kernel_rfl PF15.tokSupp : (Host.Ts.Sim.Full.mlxOf PRE_pf_vw.s0.ffi).tokens.all (bSN PRE_pf_vw.n) = true
kernel_rfl PF15.bridge : bridgeOf PRE_first_tail_x15_r0_suffix.s8.ffi = bridgeOf PRE_pf_vw.s0.ffi
kernel_rfl PF15.live : liveShiftB PFW15.R.data.map (Host.Ts.Sim.Full.mlxOf PRE_pf_vw.s0.ffi) (freedOf PRE_pf_vw.s0.ffi) (freedOf PRE_first_tail_x15_r0_suffix.s8.ffi) = true
kernel_rfl PF15.kern : kernShiftB PFW15.R.data.map PRE_pf_vw.n (Host.Ts.Sim.Full.mlxOf PRE_pf_vw.s0.ffi) (krecOf PRE_pf_vw.s0.ffi) (krecOf PRE_first_tail_x15_r0_suffix.s8.ffi) = true
kernel_rfl PF15.pendR : pendRegB PFW15.R.data.map (Host.Ts.Sim.Full.mlxOf PRE_pf_vw.s0.ffi) = true
kernel_rfl PF15.pendLe : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_pf_vw.s0.ffi).next (Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_suffix.s8.ffi).next = true

theorem PF15.fullShift : Conv.FullShiftQ PF15.P0 PRE_pf_vw.n PFW15.R.data.map PRE_pf_vw.s0.ffi PRE_first_tail_x15_r0_suffix.s8.ffi :=
  ⟨PF15.nshift, PF15.tokens, fun t ht => bSN_sound (List.all_eq_true.mp PF15.tokSupp t ht), PF15.bridge,
    liveShift_of PF15.live, kernShift_of PF15.kern,
    pendReg_of rfl PF15.nnh0 PF15.nnh1 (Nat.le_of_ble_eq_true PF15.pendLe) PF15.pendR⟩

end Host.Load.Run.Tpl
