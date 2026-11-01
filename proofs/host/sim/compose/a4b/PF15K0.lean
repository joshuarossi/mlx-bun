import host.sim.compose.a4b.PF15Full
import host.sim.compose.a4b.PF15EFresh
import host.sim.template.a4pre_first_tail_x15_r0_suffix.m.B0
import host.sim.compose.a4b.PF15Kn_0
import host.sim.compose.a4b.PF15Kn_1
import host.sim.compose.a4b.PF15Kn_2
import host.sim.compose.a4b.PF15Kn_3
import host.sim.compose.a4b.PF15Kn_4
import host.sim.compose.a4b.PF15Kn_5
import host.sim.compose.a4b.PF15Kn_6
import host.sim.compose.a4b.PF15Kn_7
import host.sim.compose.a4b.PF15Kn_8
import host.sim.compose.a4b.PF15Kn_9
import host.sim.compose.a4b.PF15Kn_10
import host.sim.compose.a4b.PF15Kn_11
import host.sim.compose.a4b.PF15Kn_12
import host.sim.compose.a4b.PF15Kn_13
import host.sim.compose.a4b.PF15Kn_14
import host.sim.compose.a4b.PF15Kn_15
import host.sim.compose.a4b.PF15Kn_16
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF15.nnum_end : (((((((((((((((((List.range PRE_pf_vw.S0.tab.length).drop 500).drop 500).drop 500).drop 500).drop 500).drop 500).drop 500).drop 500).drop 500).drop 500).drop 500).drop 500).drop 500).drop 500).drop 500).drop 500).drop 500 = []
theorem PF15.nnum : (List.range PRE_pf_vw.S0.tab.length).all PF15.numAt = true :=
  all_take_drop 500 PF15.nnum_0 (all_take_drop 500 PF15.nnum_1 (all_take_drop 500 PF15.nnum_2 (all_take_drop 500 PF15.nnum_3 (all_take_drop 500 PF15.nnum_4 (all_take_drop 500 PF15.nnum_5 (all_take_drop 500 PF15.nnum_6 (all_take_drop 500 PF15.nnum_7 (all_take_drop 500 PF15.nnum_8 (all_take_drop 500 PF15.nnum_9 (all_take_drop 500 PF15.nnum_10 (all_take_drop 500 PF15.nnum_11 (all_take_drop 500 PF15.nnum_12 (all_take_drop 500 PF15.nnum_13 (all_take_drop 500 PF15.nnum_14 (all_take_drop 500 PF15.nnum_15 (all_take_drop 500 PF15.nnum_16 (all_of_nil PF15.nnum_end)))))))))))))))))
theorem PF15.num : checkNum PFW15.R.data.map PF15.θ ⟨PRE_pf_vw.S0.tab, []⟩ ⟨PRE_first_tail_x15_r0_suffix.S8.tab, []⟩ = true := PF15.nnum
kernel_rfl PF15.fixP : PFW15.R.data.a 2665 = 2665

end Host.Load.Run.Tpl
