import host.sim.compose.a4b.PL0Na
import host.sim.template.a4pre_fd_x0_r0_body.m.B00
import host.load.boot.World
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PL0.band : PLW0.R.data.checkBand 18151 = true
kernel_rfl PL0.nh0le : Nat.ble 18151 PLW0.R.data.nh0 = true
kernel_rfl PL0.intr : (List.range 40).all (fun a => Nat.beq (PLW0.R.data.a a) a) = true
theorem PL0.inactive : (bridgeOf PRE_plx0_entry.s0.ffi).active = false := Host.Load.Boot.replay_active _
kernel_rfl PL0.lo : Nat.ble 18151 (Host.Ts.Sim.Full.mlxOf PRE_plx0_entry.s0.ffi).next = true
kernel_rfl PL0.hi0 : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_plx0_entry.s0.ffi).next setupP.E = true
kernel_rfl PL0.nhi0 : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_plx0_entry.s0.ffi).nnext setupP.NE = true
kernel_rfl PL0.hi1 : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_fd_x0_r0_body.s447.ffi).next setupP.E = true
kernel_rfl PL0.nhi1 : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_fd_x0_r0_body.s447.ffi).nnext setupP.NE = true
kernel_rfl PL0.jsKeys : (PTrie.keys PLW0.R.data.heap).all (Nat.ble 2974263) = true
kernel_rfl PL0.jsLe : Nat.ble 2974263 PLW0.R.data.n0 = true

end Host.Load.Run.Tpl
