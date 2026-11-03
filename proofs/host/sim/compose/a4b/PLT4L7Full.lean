import host.sim.compose.a4b.PLT4L7Nb
import host.sim.template.FullShiftGen
import host.sim.conv.TraceCompact
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLT4L7.tokens : (Host.Ts.Sim.Full.mlxOf PRE_plx4_L7_common.s1.ffi).tokens = (Host.Ts.Sim.Full.mlxOf PRE_pl_tail.s0.ffi).tokens.map PLTW4L7.R.data.map.nv
kernel_rfl PLT4L7.tokSupp : (Host.Ts.Sim.Full.mlxOf PRE_pl_tail.s0.ffi).tokens.all (bSN PRE_pl_tail.n) = true
kernel_rfl PLT4L7.bridge : bridgeOf PRE_plx4_L7_common.s1.ffi = bridgeOf PRE_pl_tail.s0.ffi
kernel_rfl PLT4L7.live : liveShiftB PLTW4L7.R.data.map (Host.Ts.Sim.Full.mlxOf PRE_pl_tail.s0.ffi) (freedOf PRE_pl_tail.s0.ffi) (freedOf PRE_plx4_L7_common.s1.ffi) = true
kernel_rfl PLT4L7.kern : kernShiftB PLTW4L7.R.data.map PRE_pl_tail.n (Host.Ts.Sim.Full.mlxOf PRE_pl_tail.s0.ffi) (krecOf PRE_pl_tail.s0.ffi) (krecOf PRE_plx4_L7_common.s1.ffi) = true
kernel_rfl PLT4L7.pendR : pendRegB PLTW4L7.R.data.map (Host.Ts.Sim.Full.mlxOf PRE_pl_tail.s0.ffi) = true
kernel_rfl PLT4L7.pendLe : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_pl_tail.s0.ffi).next (Host.Ts.Sim.Full.mlxOf PRE_plx4_L7_common.s1.ffi).next = true

theorem PLT4L7.fullShift : Conv.FullShiftTB (fun _ x y => bridgeOf y = bridgeOf x) PLT4L7.P0 15235 PRE_pl_tail.n PLTW4L7.R.data.map PRE_pl_tail.s0.ffi PRE_plx4_L7_common.s1.ffi :=
  ⟨PLT4L7.nshift, PLT4L7.tokens, fun t ht => bSN_sound (List.all_eq_true.mp PLT4L7.tokSupp t ht), PLT4L7.bridge,
    liveShift_of PLT4L7.live, kernShift_of PLT4L7.kern,
    pendReg_of rfl PLT4L7.nnh0 PLT4L7.nnh1 (Nat.le_of_ble_eq_true PLT4L7.pendLe) PLT4L7.pendR⟩

end Host.Load.Run.Tpl
