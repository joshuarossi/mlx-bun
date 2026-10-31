import host.sim.template.a4dec_clearFill.ENb
import host.sim.template.FullShiftGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The full world's shift of chain `DEC_clearFill`'s end (`Full.FullShift`): the load world's, the bridge kept, the observers. -/

kernel_rfl DEC_clearFill.bridge_eq : Host.Ts.Sim.Full.bridgeOf DEC_clearFill.s11.ffi = Host.Ts.Sim.Full.bridgeOf DEC_clearFill.s0.ffi
kernel_rfl DEC_clearFill.live_check : liveShiftB DEC_clearFill.σ (Host.Ts.Sim.Full.mlxOf DEC_clearFill.s0.ffi) (Host.Ts.Sim.Full.freedOf DEC_clearFill.s0.ffi)
    (Host.Ts.Sim.Full.freedOf DEC_clearFill.s11.ffi) = true
kernel_rfl DEC_clearFill.kern_check : kernShiftB DEC_clearFill.σ DEC_clearFill.S0.tab.length (Host.Ts.Sim.Full.mlxOf DEC_clearFill.s0.ffi)
    (Host.Ts.Sim.Full.krecOf DEC_clearFill.s0.ffi) (Host.Ts.Sim.Full.krecOf DEC_clearFill.s11.ffi) = true
kernel_rfl DEC_clearFill.pend_check : pendRegB DEC_clearFill.σ (Host.Ts.Sim.Full.mlxOf DEC_clearFill.s0.ffi) = true
kernel_rfl DEC_clearFill.pend_le : Nat.ble DEC_clearFill.X0.next DEC_clearFill.X1.next = true

theorem DEC_clearFill.fullShift : Host.Ts.Sim.Full.FullShift DEC_clearFill.PE DEC_clearFill.S0.tab.length DEC_clearFill.σ DEC_clearFill.s0.ffi DEC_clearFill.s11.ffi :=
  fullShift_of DEC_clearFill.nshift DEC_clearFill.bridge_eq DEC_clearFill.live_check DEC_clearFill.kern_check
    (pendReg_of rfl DEC_clearFill.nnh0 DEC_clearFill.nnh1 (Nat.le_of_ble_eq_true DEC_clearFill.pend_le) DEC_clearFill.pend_check)

end Host.Load.Run.Tpl
