import host.sim.compose.a4b.PLD1Nb
import host.sim.template.FullShiftGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLD1.tokens : (Host.Ts.Sim.Full.mlxOf D1Body.s155.ffi).tokens = (Host.Ts.Sim.Full.mlxOf PRE_pl_entry.s0.ffi).tokens.map PLWalkD1.R.data.map.nv
kernel_rfl PLD1.tokSupp : (Host.Ts.Sim.Full.mlxOf PRE_pl_entry.s0.ffi).tokens.all (bSN PRE_pl_entry.n) = true
kernel_rfl PLD1.bridge : bridgeOf D1Body.s155.ffi = bridgeOf PRE_pl_entry.s0.ffi
kernel_rfl PLD1.live : liveShiftB PLWalkD1.R.data.map (Host.Ts.Sim.Full.mlxOf PRE_pl_entry.s0.ffi) (freedOf PRE_pl_entry.s0.ffi) (freedOf D1Body.s155.ffi) = true
kernel_rfl PLD1.kern : kernShiftB PLWalkD1.R.data.map PRE_pl_entry.n (Host.Ts.Sim.Full.mlxOf PRE_pl_entry.s0.ffi) (krecOf PRE_pl_entry.s0.ffi) (krecOf D1Body.s155.ffi) = true
kernel_rfl PLD1.pendR : pendRegB PLWalkD1.R.data.map (Host.Ts.Sim.Full.mlxOf PRE_pl_entry.s0.ffi) = true
kernel_rfl PLD1.pendLe : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_pl_entry.s0.ffi).next (Host.Ts.Sim.Full.mlxOf D1Body.s155.ffi).next = true

theorem PLD1.fullShift : Conv.FullShiftQ PLD1.P0 PRE_pl_entry.n PLWalkD1.R.data.map PRE_pl_entry.s0.ffi D1Body.s155.ffi :=
  ⟨PLD1.nshift, PLD1.tokens, fun t ht => bSN_sound (List.all_eq_true.mp PLD1.tokSupp t ht), PLD1.bridge,
    liveShift_of PLD1.live, kernShift_of PLD1.kern,
    pendReg_of rfl PLD1.nnh0 PLD1.nnh1 (Nat.le_of_ble_eq_true PLD1.pendLe) PLD1.pendR⟩

end Host.Load.Run.Tpl
