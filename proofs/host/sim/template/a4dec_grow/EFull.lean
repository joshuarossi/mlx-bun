import host.sim.template.a4dec_grow.ENb
import host.sim.template.FullShiftGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The full world's shift of chain `DEC_grow`'s end (`Full.FullShift`): the load world's, the bridge kept, the observers. -/

kernel_rfl DEC_grow.bridge_eq : Host.Ts.Sim.Full.bridgeOf DEC_grow.s11.ffi = Host.Ts.Sim.Full.bridgeOf DEC_grow.s0.ffi
kernel_rfl DEC_grow.live_check : liveShiftB DEC_grow.σ (Host.Ts.Sim.Full.mlxOf DEC_grow.s0.ffi) (Host.Ts.Sim.Full.freedOf DEC_grow.s0.ffi)
    (Host.Ts.Sim.Full.freedOf DEC_grow.s11.ffi) = true
kernel_rfl DEC_grow.kern_check : kernShiftB DEC_grow.σ DEC_grow.S0.tab.length (Host.Ts.Sim.Full.mlxOf DEC_grow.s0.ffi)
    (Host.Ts.Sim.Full.krecOf DEC_grow.s0.ffi) (Host.Ts.Sim.Full.krecOf DEC_grow.s11.ffi) = true
kernel_rfl DEC_grow.pend_check : pendRegB DEC_grow.σ (Host.Ts.Sim.Full.mlxOf DEC_grow.s0.ffi) = true
kernel_rfl DEC_grow.pend_le : Nat.ble DEC_grow.X0.next DEC_grow.X1.next = true

theorem DEC_grow.fullShift : Host.Ts.Sim.Full.FullShift DEC_grow.PE DEC_grow.S0.tab.length DEC_grow.σ DEC_grow.s0.ffi DEC_grow.s11.ffi :=
  fullShift_of DEC_grow.nshift DEC_grow.bridge_eq DEC_grow.live_check DEC_grow.kern_check
    (pendReg_of rfl DEC_grow.nnh0 DEC_grow.nnh1 (Nat.le_of_ble_eq_true DEC_grow.pend_le) DEC_grow.pend_check)

end Host.Load.Run.Tpl
