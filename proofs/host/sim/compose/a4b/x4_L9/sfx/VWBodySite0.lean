import host.sim.compose.PreCall
import host.sim.lin.Table
import host.sim.template.a4pre_first_tail_x4_L9_r0_suffix.States
import host.sim.template.a4pre_first_tail_x4_L9_r0_suffix.m.B2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x4_L9_r0_suffix.map_site0 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x4_L9_r0_suffix.chk_site0 : ([first_tail_x4.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x4_L9_r0_suffix.map_site0) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.st0.S0.oracle) = true

noncomputable def PRE_first_tail_x4_L9_r0_suffix.site0
    (bytes : List Byte) (rows : Nat)
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.st0.bodyOkL bytes rows) Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.st0.bodyOkL bytes rows) Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.s2 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.s3 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.S2 Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.ws0 where
  tpl := (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.st0.bodyTpl bytes rows)
  wr := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.st0.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.iso0
  tab := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.tab0_0
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.st0.bodyLocal bytes rows
  foot := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.stFoot0
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.wrNodup0
  bound := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.wrBound0
  trace := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.trace0
  merged := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.merged0
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.ws0.length = (Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.st0.bodyTpl bytes rows).S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.S2.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.tab0_0]
    exact Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.mergeLen0.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x4_L9_r0_suffix.fresh0
    simp only [Bool.and_eq_true] at h
    exact h.1)


end Host.Ts.Sim.Compose
