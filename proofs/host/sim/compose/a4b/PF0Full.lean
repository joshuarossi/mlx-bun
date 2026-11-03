import host.sim.compose.a4b.PF0Nb
import host.sim.template.FullShiftGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF0.tokens : (Host.Ts.Sim.Full.mlxOf PRE_first_tail_x0_r0_suffix.s8.ffi).tokens = (Host.Ts.Sim.Full.mlxOf PRE_pf_x0.s0.ffi).tokens.map PFW0.R.data.map.nv
kernel_rfl PF0.tokSupp : (Host.Ts.Sim.Full.mlxOf PRE_pf_x0.s0.ffi).tokens.all (bSN PRE_pf_x0.n) = true
kernel_rfl PF0.bridge : bridgeOf PRE_first_tail_x0_r0_suffix.s8.ffi = bridgeOf PRE_pf_x0.s0.ffi
kernel_rfl PF0.live : liveShiftB PFW0.R.data.map (Host.Ts.Sim.Full.mlxOf PRE_pf_x0.s0.ffi) (freedOf PRE_pf_x0.s0.ffi) (freedOf PRE_first_tail_x0_r0_suffix.s8.ffi) = true
kernel_rfl PF0.kern : kernShiftB PFW0.R.data.map PRE_pf_x0.n (Host.Ts.Sim.Full.mlxOf PRE_pf_x0.s0.ffi) (krecOf PRE_pf_x0.s0.ffi) (krecOf PRE_first_tail_x0_r0_suffix.s8.ffi) = true
kernel_rfl PF0.pendR : pendRegB PFW0.R.data.map (Host.Ts.Sim.Full.mlxOf PRE_pf_x0.s0.ffi) = true
kernel_rfl PF0.pendLe : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_pf_x0.s0.ffi).next (Host.Ts.Sim.Full.mlxOf PRE_first_tail_x0_r0_suffix.s8.ffi).next = true

theorem PF0.fullShift : Conv.FullShiftQ PF0.P0 PRE_pf_x0.n PFW0.R.data.map PRE_pf_x0.s0.ffi PRE_first_tail_x0_r0_suffix.s8.ffi :=
  ⟨PF0.nshift, PF0.tokens, fun t ht => bSN_sound (List.all_eq_true.mp PF0.tokSupp t ht), PF0.bridge,
    liveShift_of PF0.live, kernShift_of PF0.kern,
    pendReg_of rfl PF0.nnh0 PF0.nnh1 (Nat.le_of_ble_eq_true PF0.pendLe) PF0.pendR⟩

end Host.Load.Run.Tpl
