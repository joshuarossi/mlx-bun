import host.sim.compose.a4b.PLT4L7Na
import host.sim.template.a4pre_plx4_L7_common.H0
import host.load.boot.World
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLT4L7.band : PLTW4L7.R.data.checkBand 18151 = true
kernel_rfl PLT4L7.nh0le : Nat.ble 18151 PLTW4L7.R.data.nh0 = true
kernel_rfl PLT4L7.intr : (List.range 40).all (fun a => Nat.beq (PLTW4L7.R.data.a a) a) = true
theorem PLT4L7.inactive : (bridgeOf PRE_pl_tail.s0.ffi).active = false := Host.Load.Boot.replay_active _
kernel_rfl PLT4L7.lo : Nat.ble 18151 (Host.Ts.Sim.Full.mlxOf PRE_pl_tail.s0.ffi).next = true
kernel_rfl PLT4L7.hi0 : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_pl_tail.s0.ffi).next setupP.E = true
kernel_rfl PLT4L7.nhi0 : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_pl_tail.s0.ffi).nnext setupP.NE = true
kernel_rfl PLT4L7.hi1 : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_plx4_L7_common.s1.ffi).next setupP.E = true
kernel_rfl PLT4L7.nhi1 : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_plx4_L7_common.s1.ffi).nnext setupP.NE = true
kernel_rfl PLT4L7.jsKeys : (PTrie.keys PLTW4L7.R.data.heap).all (Nat.ble 2673649) = true
kernel_rfl PLT4L7.jsLe : Nat.ble 2673649 PLTW4L7.R.data.n0 = true

end Host.Load.Run.Tpl
