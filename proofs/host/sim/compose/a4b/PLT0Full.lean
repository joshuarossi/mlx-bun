import host.sim.compose.a4b.PLT0Nb
import host.sim.template.FullShiftGen
import host.sim.conv.TraceCompact
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLT0.tokens : (Host.Ts.Sim.Full.mlxOf PRE_plx0_common.s1.ffi).tokens = (Host.Ts.Sim.Full.mlxOf PRE_pl_tail.s0.ffi).tokens.map PLTW0.R.data.map.nv
kernel_rfl PLT0.tokSupp : (Host.Ts.Sim.Full.mlxOf PRE_pl_tail.s0.ffi).tokens.all (bSN PRE_pl_tail.n) = true
kernel_rfl PLT0.bridge : bridgeOf PRE_plx0_common.s1.ffi = bridgeOf PRE_pl_tail.s0.ffi
kernel_rfl PLT0.live : liveShiftB PLTW0.R.data.map (Host.Ts.Sim.Full.mlxOf PRE_pl_tail.s0.ffi) (freedOf PRE_pl_tail.s0.ffi) (freedOf PRE_plx0_common.s1.ffi) = true
kernel_rfl PLT0.kern : kernShiftB PLTW0.R.data.map PRE_pl_tail.n (Host.Ts.Sim.Full.mlxOf PRE_pl_tail.s0.ffi) (krecOf PRE_pl_tail.s0.ffi) (krecOf PRE_plx0_common.s1.ffi) = true
kernel_rfl PLT0.pendR : pendRegB PLTW0.R.data.map (Host.Ts.Sim.Full.mlxOf PRE_pl_tail.s0.ffi) = true
kernel_rfl PLT0.pendLe : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_pl_tail.s0.ffi).next (Host.Ts.Sim.Full.mlxOf PRE_plx0_common.s1.ffi).next = true

theorem PLT0.fullShift : Conv.FullShiftTB (fun _ x y => bridgeOf y = bridgeOf x) PLT0.P0 15235 PRE_pl_tail.n PLTW0.R.data.map PRE_pl_tail.s0.ffi PRE_plx0_common.s1.ffi :=
  ⟨PLT0.nshift, PLT0.tokens, fun t ht => bSN_sound (List.all_eq_true.mp PLT0.tokSupp t ht), PLT0.bridge,
    liveShift_of PLT0.live, kernShift_of PLT0.kern,
    pendReg_of rfl PLT0.nnh0 PLT0.nnh1 (Nat.le_of_ble_eq_true PLT0.pendLe) PLT0.pendR⟩

end Host.Load.Run.Tpl
