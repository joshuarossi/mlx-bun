import host.sim.compose.a4b.PLD1Full
import host.sim.compose.a4b.PLEntryFresh
import host.sim.template.a4pre_d1_body.D4
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLD1.band : PLWalkD1.R.data.checkBand 18151 = true
kernel_rfl PLD1.nh0le : Nat.ble 18151 PLWalkD1.R.data.nh0 = true
kernel_rfl PLD1.intr : (List.range 40).all (fun a => Nat.beq (PLWalkD1.R.data.a a) a) = true
kernel_rfl PLD1.inactive : (bridgeOf PRE_pl_entry.s0.ffi).active = false
kernel_rfl PLD1.lo : Nat.ble 18151 (Host.Ts.Sim.Full.mlxOf PRE_pl_entry.s0.ffi).next = true
kernel_rfl PLD1.hi0 : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_pl_entry.s0.ffi).next setupP.E = true
kernel_rfl PLD1.nhi0 : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_pl_entry.s0.ffi).nnext setupP.NE = true
kernel_rfl PLD1.hi1 : Nat.ble (Host.Ts.Sim.Full.mlxOf D1Body.s155.ffi).next setupP.E = true
kernel_rfl PLD1.nhi1 : Nat.ble (Host.Ts.Sim.Full.mlxOf D1Body.s155.ffi).nnext setupP.NE = true
kernel_rfl PLD1.jsKeys : (PTrie.keys PLWalkD1.R.data.heap).all (Nat.ble 2826779) = true
kernel_rfl PLD1.jsLe : Nat.ble 2826779 PLWalkD1.R.data.n0 = true

end Host.Load.Run.Tpl
