import host.sim.template.a4pre_first_tail_x15_r0.K0
import host.sim.template.a4pre_first_tail_x15_r0.K1
import host.sim.template.a4pre_first_tail_x15_r0.K2
import host.sim.template.a4pre_first_tail_x15_r0.K3
import host.sim.template.a4pre_first_tail_x15_r0.K4
import host.sim.template.a4pre_first_tail_x15_r0.K5
import host.sim.template.a4pre_first_tail_x15_r0.K6
import host.sim.template.a4pre_first_tail_x15_r0.K7
import host.sim.template.a4pre_first_tail_x15_r0.K8
import host.sim.template.a4pre_first_tail_x15_r0.K9
import host.sim.template.a4pre_first_tail_x15_r0.K10
import host.sim.template.ChainRange
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts.Sim Host.Ts.Sim.Template
sim_chain_range PRE_first_tail_x15_r0 PRE_first_tail_x15_r0.okB2 6 7 runSeg2
sim_chain_range PRE_first_tail_x15_r0 PRE_first_tail_x15_r0.okB3 9 10 runSeg3
sim_chain_range PRE_first_tail_x15_r0 PRE_first_tail_x15_r0.okB4 12 13 runSeg4
sim_chain_range PRE_first_tail_x15_r0 PRE_first_tail_x15_r0.okB5 15 16 runSeg5
sim_chain_range PRE_first_tail_x15_r0 PRE_first_tail_x15_r0.okB6 19 20 runSeg6
sim_chain_range PRE_first_tail_x15_r0 PRE_first_tail_x15_r0.okB7 22 23 runSeg7
sim_chain_range PRE_first_tail_x15_r0 PRE_first_tail_x15_r0.okB8 25 26 runSeg8
sim_chain_range PRE_first_tail_x15_r0 PRE_first_tail_x15_r0.okB9 28 29 runSeg9
sim_chain_range PRE_first_tail_x15_r0 PRE_first_tail_x15_r0.okB10 31 32 runSeg10
sim_chain_range PRE_first_tail_x15_r0 PRE_first_tail_x15_r0.okB11 34 35 runSeg11
sim_chain_range PRE_first_tail_x15_r0 PRE_first_tail_x15_r0.okB13 40 41 runSeg13
end Host.Load.Run.Tpl
