import host.sim.template.a4dec_clear.ENb
import host.sim.template.FullShiftGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The full world's shift of chain `DEC_clear`'s end (`Full.FullShift`): the load world's, the bridge kept, the observers. -/

kernel_rfl DEC_clear.bridge_eq : Host.Ts.Sim.Full.bridgeOf DEC_clear.s11.ffi = Host.Ts.Sim.Full.bridgeOf DEC_clear.s0.ffi
kernel_rfl DEC_clear.live_check : liveShiftB DEC_clear.σ (Host.Ts.Sim.Full.mlxOf DEC_clear.s0.ffi) (Host.Ts.Sim.Full.freedOf DEC_clear.s0.ffi)
    (Host.Ts.Sim.Full.freedOf DEC_clear.s11.ffi) = true
kernel_rfl DEC_clear.kern_check : kernShiftB DEC_clear.σ DEC_clear.S0.tab.length (Host.Ts.Sim.Full.mlxOf DEC_clear.s0.ffi)
    (Host.Ts.Sim.Full.krecOf DEC_clear.s0.ffi) (Host.Ts.Sim.Full.krecOf DEC_clear.s11.ffi) = true
kernel_rfl DEC_clear.pend_check : pendRegB DEC_clear.σ (Host.Ts.Sim.Full.mlxOf DEC_clear.s0.ffi) = true
kernel_rfl DEC_clear.pend_le : Nat.ble DEC_clear.X0.next DEC_clear.X1.next = true

theorem DEC_clear.fullShift : Host.Ts.Sim.Full.FullShift DEC_clear.PE DEC_clear.S0.tab.length DEC_clear.σ DEC_clear.s0.ffi DEC_clear.s11.ffi :=
  fullShift_of DEC_clear.nshift DEC_clear.bridge_eq DEC_clear.live_check DEC_clear.kern_check
    (pendReg_of rfl DEC_clear.nnh0 DEC_clear.nnh1 (Nat.le_of_ble_eq_true DEC_clear.pend_le) DEC_clear.pend_check)

end Host.Load.Run.Tpl
