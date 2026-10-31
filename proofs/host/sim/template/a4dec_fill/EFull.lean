import host.sim.template.a4dec_fill.ENb
import host.sim.template.FullShiftGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The full world's shift of chain `DEC_fill`'s end (`Full.FullShift`): the load world's, the bridge kept, the observers. -/

kernel_rfl DEC_fill.bridge_eq : Host.Ts.Sim.Full.bridgeOf DEC_fill.s11.ffi = Host.Ts.Sim.Full.bridgeOf DEC_fill.s0.ffi
kernel_rfl DEC_fill.live_check : liveShiftB DEC_fill.σ (Host.Ts.Sim.Full.mlxOf DEC_fill.s0.ffi) (Host.Ts.Sim.Full.freedOf DEC_fill.s0.ffi)
    (Host.Ts.Sim.Full.freedOf DEC_fill.s11.ffi) = true
kernel_rfl DEC_fill.kern_check : kernShiftB DEC_fill.σ DEC_fill.S0.tab.length (Host.Ts.Sim.Full.mlxOf DEC_fill.s0.ffi)
    (Host.Ts.Sim.Full.krecOf DEC_fill.s0.ffi) (Host.Ts.Sim.Full.krecOf DEC_fill.s11.ffi) = true
kernel_rfl DEC_fill.pend_check : pendRegB DEC_fill.σ (Host.Ts.Sim.Full.mlxOf DEC_fill.s0.ffi) = true
kernel_rfl DEC_fill.pend_le : Nat.ble DEC_fill.X0.next DEC_fill.X1.next = true

theorem DEC_fill.fullShift : Host.Ts.Sim.Full.FullShift DEC_fill.PE DEC_fill.S0.tab.length DEC_fill.σ DEC_fill.s0.ffi DEC_fill.s11.ffi :=
  fullShift_of DEC_fill.nshift DEC_fill.bridge_eq DEC_fill.live_check DEC_fill.kern_check
    (pendReg_of rfl DEC_fill.nnh0 DEC_fill.nnh1 (Nat.le_of_ble_eq_true DEC_fill.pend_le) DEC_fill.pend_check)

end Host.Load.Run.Tpl
