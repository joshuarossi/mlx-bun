import host.sim.compose.a4b.PL4L7Na
import host.sim.template.a4pre_fd_x4_L7_r0_body.m.B00
import host.load.boot.World
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PL4L7.band : PLW4L7.R.data.checkBand 18151 = true
kernel_rfl PL4L7.nh0le : Nat.ble 18151 PLW4L7.R.data.nh0 = true
kernel_rfl PL4L7.intr : (List.range 40).all (fun a => Nat.beq (PLW4L7.R.data.a a) a) = true
theorem PL4L7.inactive : (bridgeOf PRE_plx4_L7_entry.s0.ffi).active = false := Host.Load.Boot.replay_active _
kernel_rfl PL4L7.lo : Nat.ble 18151 (Host.Ts.Sim.Full.mlxOf PRE_plx4_L7_entry.s0.ffi).next = true
kernel_rfl PL4L7.hi0 : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_plx4_L7_entry.s0.ffi).next setupP.E = true
kernel_rfl PL4L7.nhi0 : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_plx4_L7_entry.s0.ffi).nnext setupP.NE = true
kernel_rfl PL4L7.hi1 : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_fd_x4_L7_r0_body.s451.ffi).next setupP.E = true
kernel_rfl PL4L7.nhi1 : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_fd_x4_L7_r0_body.s451.ffi).nnext setupP.NE = true
kernel_rfl PL4L7.jsKeys : (PTrie.keys PLW4L7.R.data.heap).all (Nat.ble 2982990) = true
kernel_rfl PL4L7.jsLe : Nat.ble 2982990 PLW4L7.R.data.n0 = true

end Host.Load.Run.Tpl
