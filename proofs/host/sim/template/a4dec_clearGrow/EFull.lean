import host.sim.template.a4dec_clearGrow.ENb
import host.sim.template.FullShiftGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The full world's shift of chain `DEC_clearGrow`'s end (`Full.FullShift`): the load world's, the bridge kept, the observers. -/

kernel_rfl DEC_clearGrow.bridge_eq : Host.Ts.Sim.Full.bridgeOf DEC_clearGrow.s11.ffi = Host.Ts.Sim.Full.bridgeOf DEC_clearGrow.s0.ffi
kernel_rfl DEC_clearGrow.live_check : liveShiftB DEC_clearGrow.σ (Host.Ts.Sim.Full.mlxOf DEC_clearGrow.s0.ffi) (Host.Ts.Sim.Full.freedOf DEC_clearGrow.s0.ffi)
    (Host.Ts.Sim.Full.freedOf DEC_clearGrow.s11.ffi) = true
kernel_rfl DEC_clearGrow.kern_check : kernShiftB DEC_clearGrow.σ DEC_clearGrow.S0.tab.length (Host.Ts.Sim.Full.mlxOf DEC_clearGrow.s0.ffi)
    (Host.Ts.Sim.Full.krecOf DEC_clearGrow.s0.ffi) (Host.Ts.Sim.Full.krecOf DEC_clearGrow.s11.ffi) = true
kernel_rfl DEC_clearGrow.pend_check : pendRegB DEC_clearGrow.σ (Host.Ts.Sim.Full.mlxOf DEC_clearGrow.s0.ffi) = true
kernel_rfl DEC_clearGrow.pend_le : Nat.ble DEC_clearGrow.X0.next DEC_clearGrow.X1.next = true

theorem DEC_clearGrow.fullShift : Host.Ts.Sim.Full.FullShift DEC_clearGrow.PE DEC_clearGrow.S0.tab.length DEC_clearGrow.σ DEC_clearGrow.s0.ffi DEC_clearGrow.s11.ffi :=
  fullShift_of DEC_clearGrow.nshift DEC_clearGrow.bridge_eq DEC_clearGrow.live_check DEC_clearGrow.kern_check
    (pendReg_of rfl DEC_clearGrow.nnh0 DEC_clearGrow.nnh1 (Nat.le_of_ble_eq_true DEC_clearGrow.pend_le) DEC_clearGrow.pend_check)

end Host.Load.Run.Tpl
