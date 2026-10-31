import host.sim.compose.PreCall
import host.sim.lin.Table
import host.sim.template.a4pre_first_tail_x15_r0_body.States
import host.sim.template.a4pre_first_tail_x15_r0_body.st0.H0
import host.sim.template.a4pre_first_tail_x15_r0_body.st1.H0
import host.sim.template.a4pre_first_tail_x15_r0_body.st2.H0
import host.sim.template.a4pre_first_tail_x15_r0_body.st3.H0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Oracles
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x15_r0_body.map_g0 : List (Nat × Q) := [(9, Q.L), (10, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_g0 : ([first_drain_128.r0, first_tail_x15.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_g0) (List.take 13 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.OR))) = true

def PRE_first_tail_x15_r0_body.map_site0 : List (Nat × Q) := [(9, Q.L), (10, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_site0 : ([first_drain_128.r0, first_tail_x15.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_site0) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st0.S0.oracle) = true

def PRE_first_tail_x15_r0_body.map_g1 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_g1 : ([first_drain_128.r0, first_tail_x15.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_g1) (List.take 8 (List.drop 13 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.OR))) = true

def PRE_first_tail_x15_r0_body.map_site1 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_site1 : ([first_drain_128.r0, first_tail_x15.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_site1) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st1.S0.oracle) = true

def PRE_first_tail_x15_r0_body.map_g2 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_g2 : ([first_drain_128.r0, first_tail_x15.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_g2) (List.take 3 (List.drop 21 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.OR))) = true

noncomputable def PRE_first_tail_x15_r0_body.map_site2 : List (Nat × Q) := ([(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n)]).filter (fun p => Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st2.S0.oracle.any (fun q => !(q.a.noVar p.1 && q.b.noVar p.1)))

kernel_rfl PRE_first_tail_x15_r0_body.chk_site2 : ([first_drain_128.r0, first_tail_x15.r0].all fun r =>
  goodEnum r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_site2) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st2.S0.oracle) = true

def PRE_first_tail_x15_r0_body.map_g3 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_g3 : ([first_drain_128.r0, first_tail_x15.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_g3) (List.take 16 (List.drop 24 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.OR))) = true

def PRE_first_tail_x15_r0_body.map_site3 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_site3 : ([first_drain_128.r0, first_tail_x15.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_site3) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st3.S0.oracle) = true


end Host.Ts.Sim.Compose.Oracles
