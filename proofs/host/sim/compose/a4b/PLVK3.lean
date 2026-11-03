import host.sim.compose.a4b.PLVNa
import host.sim.template.a4pre_fd_vw_r0_body.m.B00
import host.load.boot.World
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLV.ctl : PRE_fd_vw_r0_body.s900.ctl = PLVW.R.data.map.ctl PRE_plvw_entry.s0.ctl
kernel_rfl PLV.stack : PRE_fd_vw_r0_body.s900.stack = PRE_plvw_entry.s0.stack.map PLVW.R.data.map.frame
kernel_rfl PLV.jobs : PRE_fd_vw_r0_body.s900.jobs = PRE_plvw_entry.s0.jobs.map PLVW.R.data.map.job
kernel_rfl PLV.stores : PRE_fd_vw_r0_body.s900.stores = PLVW.R.data.map.stores PRE_plvw_entry.s0.stores

end Host.Load.Run.Tpl
