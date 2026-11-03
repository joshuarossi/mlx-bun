import host.sim.compose.PreCall
import host.sim.lin.Table
import host.sim.template.a4pre_first_tail_x0_r0.States
import host.sim.template.a4pre_first_tail_x0_r0.SiteL1
import host.sim.template.a4pre_first_tail_x0_r0.st1.Tpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x0_r0.map_site1 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x0_r0.chk_site1 : ([first_tail_x0.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x0_r0.map_site1) Host.Load.Run.Tpl.PRE_first_tail_x0_r0.st1.S0.oracle) = true

noncomputable def PRE_first_tail_x0_r0.site1
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR Host.Load.Run.Tpl.PRE_first_tail_x0_r0.st1.okL Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W Host.Load.Run.Tpl.PRE_first_tail_x0_r0.st1.okL Host.Load.Run.Tpl.PRE_first_tail_x0_r0.s17 Host.Load.Run.Tpl.PRE_first_tail_x0_r0.s18 Host.Load.Run.Tpl.PRE_first_tail_x0_r0.S17 Host.Load.Run.Tpl.PRE_first_tail_x0_r0.ws1 where
  tpl := Host.Load.Run.Tpl.PRE_first_tail_x0_r0.st1.tpl
  wr := Host.Load.Run.Tpl.PRE_first_tail_x0_r0.st1.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x0_r0.iso1
  tab := Host.Load.Run.Tpl.PRE_first_tail_x0_r0.tab0_1
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x0_r0.st1.loc
  foot := Host.Load.Run.Tpl.PRE_first_tail_x0_r0.stFoot1
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x0_r0.wrNodup1
  bound := Host.Load.Run.Tpl.PRE_first_tail_x0_r0.wrBound1
  trace := Host.Load.Run.Tpl.PRE_first_tail_x0_r0.trace1
  merged := Host.Load.Run.Tpl.PRE_first_tail_x0_r0.merged1
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x0_r0.ws1.length = Host.Load.Run.Tpl.PRE_first_tail_x0_r0.st1.tpl.S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x0_r0.S17.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x0_r0.tab0_1]
    exact Host.Load.Run.Tpl.PRE_first_tail_x0_r0.mergeLen1.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x0_r0.fresh1
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose
