import host.sim.compose.a4b.PLTVNb
import host.sim.template.FullShiftGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLTV.tokens : (Host.Ts.Sim.Full.mlxOf PRE_plvw_common.s4.ffi).tokens = (Host.Ts.Sim.Full.mlxOf PRE_pl_tail.s0.ffi).tokens.map PLTailVW.R.data.map.nv
kernel_rfl PLTV.tokSupp : (Host.Ts.Sim.Full.mlxOf PRE_pl_tail.s0.ffi).tokens.all (bSN PRE_pl_tail.n) = true
kernel_rfl PLTV.bridge : bridgeOf PRE_plvw_common.s4.ffi = bridgeOf PRE_pl_tail.s0.ffi
kernel_rfl PLTV.live : liveShiftB PLTailVW.R.data.map (Host.Ts.Sim.Full.mlxOf PRE_pl_tail.s0.ffi) (freedOf PRE_pl_tail.s0.ffi) (freedOf PRE_plvw_common.s4.ffi) = true
kernel_rfl PLTV.kern : kernShiftB PLTailVW.R.data.map PRE_pl_tail.n (Host.Ts.Sim.Full.mlxOf PRE_pl_tail.s0.ffi) (krecOf PRE_pl_tail.s0.ffi) (krecOf PRE_plvw_common.s4.ffi) = true
kernel_rfl PLTV.pendR : pendRegB PLTailVW.R.data.map (Host.Ts.Sim.Full.mlxOf PRE_pl_tail.s0.ffi) = true
kernel_rfl PLTV.pendLe : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_pl_tail.s0.ffi).next (Host.Ts.Sim.Full.mlxOf PRE_plvw_common.s4.ffi).next = true

theorem PLTV.fullShift : Conv.FullShiftQ PLTV.P0 PRE_pl_tail.n PLTailVW.R.data.map PRE_pl_tail.s0.ffi PRE_plvw_common.s4.ffi :=
  ⟨PLTV.nshift, PLTV.tokens, fun t ht => bSN_sound (List.all_eq_true.mp PLTV.tokSupp t ht), PLTV.bridge,
    liveShift_of PLTV.live, kernShift_of PLTV.kern,
    pendReg_of rfl PLTV.nnh0 PLTV.nnh1 (Nat.le_of_ble_eq_true PLTV.pendLe) PLTV.pendR⟩

end Host.Load.Run.Tpl
