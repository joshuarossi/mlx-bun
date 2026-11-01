import host.load.boot.World
import host.sim.compose.a4b.PF1Na
import host.sim.template.a4pre_first_tail_x1_r0_suffix.m.B0
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF1.band : PFW1.R.data.checkBand 18151 = true
kernel_rfl PF1.nh0le : Nat.ble 18151 PFW1.R.data.nh0 = true
kernel_rfl PF1.intr : (List.range 40).all (fun a => Nat.beq (PFW1.R.data.a a) a) = true
theorem PF1.inactive : (bridgeOf PRE_pf_vw.s0.ffi).active = false := Host.Load.Boot.replay_active _
kernel_rfl PF1.lo : Nat.ble 18151 (Host.Ts.Sim.Full.mlxOf PRE_pf_vw.s0.ffi).next = true
kernel_rfl PF1.hi0 : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_pf_vw.s0.ffi).next setupP.E = true
kernel_rfl PF1.nhi0 : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_pf_vw.s0.ffi).nnext setupP.NE = true
kernel_rfl PF1.hi1 : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_first_tail_x1_r0_suffix.s8.ffi).next setupP.E = true
kernel_rfl PF1.nhi1 : Nat.ble (Host.Ts.Sim.Full.mlxOf PRE_first_tail_x1_r0_suffix.s8.ffi).nnext setupP.NE = true
kernel_rfl PF1.jsKeys : (PTrie.keys PFW1.R.data.heap).all (Nat.ble 2825043) = true
kernel_rfl PF1.jsLe : Nat.ble 2825043 PFW1.R.data.n0 = true

end Host.Load.Run.Tpl
