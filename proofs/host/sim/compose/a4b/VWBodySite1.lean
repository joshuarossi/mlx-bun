import host.sim.compose.PreCall
import host.sim.lin.Table
import host.sim.template.a4pre_first_tail_x15_r0_body.States
import host.sim.template.a4pre_first_tail_x15_r0_body.SiteL1
import host.sim.template.a4pre_first_tail_x15_r0_body.st1.TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x15_r0_body.map_site1 : List (Nat × Q) := [(9, Q.L), (10, Q.n), (1031, Q.n), (1032, Q.n), (1033, Q.n), (1035, Q.n), (1036, Q.n), (1037, Q.n), (1038, Q.n), (1039, Q.n), (1042, Q.n), (1043, Q.n), (1045, Q.n), (1046, Q.n), (1047, Q.n), (1048, Q.n)]

kernel_rfl PRE_first_tail_x15_r0_body.chk_site1 : ([first_drain_128.r0, first_tail_x15.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0_body.map_site1) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st1.S0.oracle) = true

noncomputable def PRE_first_tail_x15_r0_body.site1
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st1.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st1.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.s21 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.s22 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.S21 Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.ws1 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st1.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st1.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.iso1
  tab := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.tab0_1
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st1.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.stFoot1
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.wrNodup1
  bound := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.wrBound1
  trace := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.trace1
  merged := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.merged1
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.ws1.length = (Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.st1.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.S21.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.tab0_1]
    exact Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.mergeLen1.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x15_r0_body.fresh1
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose
