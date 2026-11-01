import host.sim.compose.a4b.PLTNb
import host.sim.template.FullShiftGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLT.tokens : (Host.Ts.Sim.Full.mlxOf PRE_pl_common.s4.ffi).tokens = (Host.Ts.Sim.Full.mlxOf PRE_pl_tail.s0.ffi).tokens.map PLTP.R.data.map.nv
kernel_rfl PLT.tokSupp : (Host.Ts.Sim.Full.mlxOf PRE_pl_tail.s0.ffi).tokens.all (bSN PRE_pl_tail.n) = true
kernel_rfl PLT.bridge : bridgeOf PRE_pl_common.s4.ffi = bridgeOf PRE_pl_tail.s0.ffi
kernel_rfl PLT.live : liveShiftB PLTP.R.data.map (Host.Ts.Sim.Full.mlxOf PRE_pl_tail.s0.ffi) (freedOf PRE_pl_tail.s0.ffi) (freedOf PRE_pl_common.s4.ffi) = true
kernel_rfl PLT.kern : kernShiftB PLTP.R.data.map PRE_pl_tail.n (Host.Ts.Sim.Full.mlxOf PRE_pl_tail.s0.ffi) (krecOf PRE_pl_tail.s0.ffi) (krecOf PRE_pl_common.s4.ffi) = true
kernel_rfl PLT.pendR : pendRegB PLTP.R.data.map (Host.Ts.Sim.Full.mlxOf PRE_pl_tail.s0.ffi) = true
kernel_rfl PLT.pendLe : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_pl_tail.s0.ffi).next (Host.Ts.Sim.Full.mlxOf PRE_pl_common.s4.ffi).next = true

theorem PLT.fullShift : Conv.FullShiftQ PLT.P0 PRE_pl_tail.n PLTP.R.data.map PRE_pl_tail.s0.ffi PRE_pl_common.s4.ffi :=
  ⟨PLT.nshift, PLT.tokens, fun t ht => bSN_sound (List.all_eq_true.mp PLT.tokSupp t ht), PLT.bridge,
    liveShift_of PLT.live, kernShift_of PLT.kern,
    pendReg_of rfl PLT.nnh0 PLT.nnh1 (Nat.le_of_ble_eq_true PLT.pendLe) PLT.pendR⟩

end Host.Load.Run.Tpl
