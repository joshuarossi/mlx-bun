import host.sim.compose.a4b.PLTNa
import host.sim.template.a4pre_pl_common.H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLT.band : PLTail.R.data.checkBand 18151 = true
kernel_rfl PLT.nh0le : Nat.ble 18151 PLTail.R.data.nh0 = true
kernel_rfl PLT.intr : (List.range 40).all (fun a => Nat.beq (PLTail.R.data.a a) a) = true
kernel_rfl PLT.inactive : (bridgeOf PRE_pl_tail.s0.ffi).active = false
kernel_rfl PLT.lo : Nat.ble 18151 (Host.Ts.Sim.Full.mlxOf PRE_pl_tail.s0.ffi).next = true
kernel_rfl PLT.hi0 : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_pl_tail.s0.ffi).next setupP.E = true
kernel_rfl PLT.nhi0 : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_pl_tail.s0.ffi).nnext setupP.NE = true
kernel_rfl PLT.hi1 : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_pl_common.s4.ffi).next setupP.E = true
kernel_rfl PLT.nhi1 : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_pl_common.s4.ffi).nnext setupP.NE = true
kernel_rfl PLT.jsKeys : (PTrie.keys PLTail.R.data.heap).all (Nat.ble 2827718) = true
kernel_rfl PLT.jsLe : Nat.ble 2827718 PLTail.R.data.n0 = true

end Host.Load.Run.Tpl
