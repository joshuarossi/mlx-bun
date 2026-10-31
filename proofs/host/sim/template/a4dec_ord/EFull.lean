import host.sim.template.a4dec_ord.ENb
import host.sim.template.FullShiftGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The full world's shift of chain `DEC_ord`'s end (`Full.FullShift`): the load world's, the bridge kept, the observers. -/

kernel_rfl DEC_ord.bridge_eq : Host.Ts.Sim.Full.bridgeOf DEC_ord.s11.ffi = Host.Ts.Sim.Full.bridgeOf DEC_ord.s0.ffi
kernel_rfl DEC_ord.live_check : liveShiftB DEC_ord.σ (Host.Ts.Sim.Full.mlxOf DEC_ord.s0.ffi) (Host.Ts.Sim.Full.freedOf DEC_ord.s0.ffi)
    (Host.Ts.Sim.Full.freedOf DEC_ord.s11.ffi) = true
kernel_rfl DEC_ord.kern_check : kernShiftB DEC_ord.σ DEC_ord.S0.tab.length (Host.Ts.Sim.Full.mlxOf DEC_ord.s0.ffi)
    (Host.Ts.Sim.Full.krecOf DEC_ord.s0.ffi) (Host.Ts.Sim.Full.krecOf DEC_ord.s11.ffi) = true
kernel_rfl DEC_ord.pend_check : pendRegB DEC_ord.σ (Host.Ts.Sim.Full.mlxOf DEC_ord.s0.ffi) = true
kernel_rfl DEC_ord.pend_le : Nat.ble DEC_ord.X0.next DEC_ord.X1.next = true

theorem DEC_ord.fullShift : Host.Ts.Sim.Full.FullShift DEC_ord.PE DEC_ord.S0.tab.length DEC_ord.σ DEC_ord.s0.ffi DEC_ord.s11.ffi :=
  fullShift_of DEC_ord.nshift DEC_ord.bridge_eq DEC_ord.live_check DEC_ord.kern_check
    (pendReg_of rfl DEC_ord.nnh0 DEC_ord.nnh1 (Nat.le_of_ble_eq_true DEC_ord.pend_le) DEC_ord.pend_check)

end Host.Load.Run.Tpl
