import host.sim.compose.a4b.PLTVNa
import host.sim.template.a4pre_plvw_common.H0
import host.load.boot.World
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLTV.band : PLTVW.R.data.checkBand 18151 = true
kernel_rfl PLTV.nh0le : Nat.ble 18151 PLTVW.R.data.nh0 = true
kernel_rfl PLTV.intr : (List.range 40).all (fun a => Nat.beq (PLTVW.R.data.a a) a) = true
theorem PLTV.inactive : (bridgeOf PRE_pl_tail.s0.ffi).active = false := Host.Load.Boot.replay_active _
kernel_rfl PLTV.lo : Nat.ble 18151 (Host.Ts.Sim.Full.mlxOf PRE_pl_tail.s0.ffi).next = true
kernel_rfl PLTV.hi0 : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_pl_tail.s0.ffi).next setupP.E = true
kernel_rfl PLTV.nhi0 : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_pl_tail.s0.ffi).nnext setupP.NE = true
kernel_rfl PLTV.hi1 : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_plvw_common.s1.ffi).next setupP.E = true
kernel_rfl PLTV.nhi1 : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_plvw_common.s1.ffi).nnext setupP.NE = true
kernel_rfl PLTV.jsKeys : (PTrie.keys PLTVW.R.data.heap).all (Nat.ble 2673649) = true
kernel_rfl PLTV.jsLe : Nat.ble 2673649 PLTVW.R.data.n0 = true

end Host.Load.Run.Tpl
