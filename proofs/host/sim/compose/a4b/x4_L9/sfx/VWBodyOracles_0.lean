import host.sim.compose.PreCall
import host.sim.lin.Table
import host.sim.template.a4pre_first_tail_x4_L9_r0_suffix.States
import host.sim.template.a4pre_first_tail_x4_L9_r0_suffix.m.B2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Oracles
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L9_r0_suffix.map_g3d_first : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_suffix.chk_g3d_first : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_suffix.map_g3d_first) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.O))) = true

def PRE_first_tail_x4_L9_r0_suffix.map_site0 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_suffix.chk_site0 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_suffix.map_site0) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.st0.S0.oracle) = true

def PRE_first_tail_x4_L9_r0_suffix.map_g4_pf_first : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_suffix.chk_g4_pf_first : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_suffix.map_g4_pf_first) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.O))) = true


end Host.Ts.Sim.Compose.Oracles
