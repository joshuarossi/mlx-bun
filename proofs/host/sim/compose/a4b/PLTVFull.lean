import host.sim.compose.a4b.PLTVNb
import host.sim.template.FullShiftGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLTV.tokens : (Host.Ts.Sim.Full.mlxOf PRE_plvw_common.s1.ffi).tokens = (Host.Ts.Sim.Full.mlxOf PRE_pl_tail.s0.ffi).tokens.map PLTVW.R.data.map.nv
kernel_rfl PLTV.tokSupp : (Host.Ts.Sim.Full.mlxOf PRE_pl_tail.s0.ffi).tokens.all (bSN PRE_pl_tail.n) = true
kernel_rfl PLTV.bridge : bridgeOf PRE_plvw_common.s1.ffi = bridgeOf PRE_pl_tail.s0.ffi
kernel_rfl PLTV.live : liveShiftB PLTVW.R.data.map (Host.Ts.Sim.Full.mlxOf PRE_pl_tail.s0.ffi) (freedOf PRE_pl_tail.s0.ffi) (freedOf PRE_plvw_common.s1.ffi) = true
kernel_rfl PLTV.kern : kernShiftB PLTVW.R.data.map PRE_pl_tail.n (Host.Ts.Sim.Full.mlxOf PRE_pl_tail.s0.ffi) (krecOf PRE_pl_tail.s0.ffi) (krecOf PRE_plvw_common.s1.ffi) = true
kernel_rfl PLTV.pendR : pendRegB PLTVW.R.data.map (Host.Ts.Sim.Full.mlxOf PRE_pl_tail.s0.ffi) = true
kernel_rfl PLTV.pendLe : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_pl_tail.s0.ffi).next (Host.Ts.Sim.Full.mlxOf PRE_plvw_common.s1.ffi).next = true

theorem PLTV.fullShift : Conv.FullShiftTB (fun _ x y => bridgeOf y = bridgeOf x) PLTV.P0 15235 PRE_pl_tail.n PLTVW.R.data.map PRE_pl_tail.s0.ffi PRE_plvw_common.s1.ffi :=
  ⟨PLTV.nshift, PLTV.tokens, fun t ht => bSN_sound (List.all_eq_true.mp PLTV.tokSupp t ht), PLTV.bridge,
    liveShift_of PLTV.live, kernShift_of PLTV.kern,
    pendReg_of rfl PLTV.nnh0 PLTV.nnh1 (Nat.le_of_ble_eq_true PLTV.pendLe) PLTV.pendR⟩

end Host.Load.Run.Tpl
