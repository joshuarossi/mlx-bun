import host.sim.compose.a4b.PLVNa
import host.sim.template.a4pre_fd_vw_r0_body.m.B00
import host.load.boot.World
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLV.band : PLVW.R.data.checkBand 18151 = true
kernel_rfl PLV.nh0le : Nat.ble 18151 PLVW.R.data.nh0 = true
kernel_rfl PLV.intr : (List.range 40).all (fun a => Nat.beq (PLVW.R.data.a a) a) = true
theorem PLV.inactive : (bridgeOf PRE_plvw_entry.s0.ffi).active = false := Host.Load.Boot.replay_active _
kernel_rfl PLV.lo : Nat.ble 18151 (Host.Ts.Sim.Full.mlxOf PRE_plvw_entry.s0.ffi).next = true
kernel_rfl PLV.hi0 : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_plvw_entry.s0.ffi).next setupP.E = true
kernel_rfl PLV.nhi0 : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_plvw_entry.s0.ffi).nnext setupP.NE = true
kernel_rfl PLV.hi1 : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_fd_vw_r0_body.s900.ffi).next setupP.E = true
kernel_rfl PLV.nhi1 : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_fd_vw_r0_body.s900.ffi).nnext setupP.NE = true
kernel_rfl PLV.jsKeys : (PTrie.keys PLVW.R.data.heap).all (Nat.ble 2972768) = true
kernel_rfl PLV.jsLe : Nat.ble 2972768 PLVW.R.data.n0 = true

end Host.Load.Run.Tpl
