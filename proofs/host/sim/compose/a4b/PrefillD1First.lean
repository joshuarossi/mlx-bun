import host.sim.compose.PreCall
import host.sim.lin.Table
import host.sim.template.a4pre_d1_stage_split.States
import host.sim.template.a4pre_d1_stage_split.SiteL0
import host.sim.template.a4pre_d1_stage_split.st0.Tpl
import host.sim.template.a4pre_d1_stage_split.SiteL1
import host.sim.template.a4pre_d1_stage_split.st1.Tpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def D1StageSplit.map_start : List (Nat × Q) := [(9, Q.L)]

noncomputable def D1StageSplit.cut_start_i
    (FR : Map → Nat → FF.S → FF.S → Prop) (J : Disp.JSP FF) (W : Nat → Option WFrame)
    (book : Cls.Inst → SegInst FF → Prop) (i : Cls.Inst) : ICut FF :=
  { pbCut FR J W D1StageSplit.map_start Host.Load.Run.Tpl.D1StageSplit.s0 Host.Load.Run.Tpl.D1StageSplit.S0 i with B := book i }

noncomputable def D1StageSplit.cut_start_o
    (FR : Map → Nat → FF.S → FF.S → Prop) (J : Disp.JSP FF) (W : Nat → Option WFrame)
    (book : Cls.Inst → SegInst FF → Prop) (i : Cls.Inst) : ICut FF :=
  { pbCut FR J W D1StageSplit.map_start Host.Load.Run.Tpl.D1StageSplit.s0 Host.Load.Run.Tpl.D1StageSplit.S0 i with B := book i }

kernel_rfl D1StageSplit.chk_start : ([final_cold.r0].all fun r =>
  goodLin r.ps (varsOf r.V D1StageSplit.map_start) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.D1StageSplit.O))) = true

def D1StageSplit.map_site0 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl D1StageSplit.chk_site0 : ([final_cold.r0].all fun r =>
  goodLin r.ps (varsOf r.V D1StageSplit.map_site0) Host.Load.Run.Tpl.D1StageSplit.st0.S0.oracle) = true

noncomputable def D1StageSplit.site0
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR Host.Load.Run.Tpl.D1StageSplit.st0.okL Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W Host.Load.Run.Tpl.D1StageSplit.st0.okL Host.Load.Run.Tpl.D1StageSplit.s0 Host.Load.Run.Tpl.D1StageSplit.s1 Host.Load.Run.Tpl.D1StageSplit.S0 Host.Load.Run.Tpl.D1StageSplit.ws0 where
  tpl := Host.Load.Run.Tpl.D1StageSplit.st0.tpl
  wr := Host.Load.Run.Tpl.D1StageSplit.st0.wr
  start := Host.Load.Run.Tpl.D1StageSplit.iso0
  tab := Host.Load.Run.Tpl.D1StageSplit.tab0_0
  sim := hsim
  localOk := Host.Load.Run.Tpl.D1StageSplit.st0.loc
  foot := Host.Load.Run.Tpl.D1StageSplit.stFoot0
  nodup := Host.Load.Run.Tpl.D1StageSplit.wrNodup0
  bound := Host.Load.Run.Tpl.D1StageSplit.wrBound0
  trace := Host.Load.Run.Tpl.D1StageSplit.trace0
  merged := Host.Load.Run.Tpl.D1StageSplit.merged0
  len := by
    change Host.Load.Run.Tpl.D1StageSplit.ws0.length = Host.Load.Run.Tpl.D1StageSplit.st0.tpl.S2.tab.length - Host.Load.Run.Tpl.D1StageSplit.S0.tab.length
    rw [← Host.Load.Run.Tpl.D1StageSplit.tab0_0]
    exact Host.Load.Run.Tpl.D1StageSplit.mergeLen0.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.D1StageSplit.fresh0
    simp only [Bool.and_eq_true] at h
    exact h.1)

def D1StageSplit.map_g1_FIN_first : List (Nat × Q) := [(9, Q.L), (1000, Q.L), (1001, Q.L), (1002, Q.L)]

noncomputable def D1StageSplit.cut_g1_FIN_first_i
    (FR : Map → Nat → FF.S → FF.S → Prop) (J : Disp.JSP FF) (W : Nat → Option WFrame)
    (book : Cls.Inst → SegInst FF → Prop) (i : Cls.Inst) : ICut FF :=
  { pbCut FR J W D1StageSplit.map_g1_FIN_first Host.Load.Run.Tpl.D1StageSplit.s1 Host.Load.Run.Tpl.D1StageSplit.S1 i with B := book i }

noncomputable def D1StageSplit.cut_g1_FIN_first_o
    (FR : Map → Nat → FF.S → FF.S → Prop) (J : Disp.JSP FF) (W : Nat → Option WFrame)
    (book : Cls.Inst → SegInst FF → Prop) (i : Cls.Inst) : ICut FF :=
  { pbCut FR J W D1StageSplit.map_g1_FIN_first Host.Load.Run.Tpl.D1StageSplit.s20 Host.Load.Run.Tpl.D1StageSplit.S20 i with B := book i }

kernel_rfl D1StageSplit.chk_g1_FIN_first : ([final_cold.r0].all fun r =>
  goodLin r.ps (varsOf r.V D1StageSplit.map_g1_FIN_first) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.D1StageSplit.O))) = true

def D1StageSplit.map_site1 : List (Nat × Q) := [(9, Q.L), (1000, Q.L), (1001, Q.L), (1002, Q.L)]

kernel_rfl D1StageSplit.chk_site1 : ([final_cold.r0].all fun r =>
  goodLin r.ps (varsOf r.V D1StageSplit.map_site1) Host.Load.Run.Tpl.D1StageSplit.st1.S0.oracle) = true

noncomputable def D1StageSplit.site1
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR Host.Load.Run.Tpl.D1StageSplit.st1.okL Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W Host.Load.Run.Tpl.D1StageSplit.st1.okL Host.Load.Run.Tpl.D1StageSplit.s20 Host.Load.Run.Tpl.D1StageSplit.s21 Host.Load.Run.Tpl.D1StageSplit.S20 Host.Load.Run.Tpl.D1StageSplit.ws1 where
  tpl := Host.Load.Run.Tpl.D1StageSplit.st1.tpl
  wr := Host.Load.Run.Tpl.D1StageSplit.st1.wr
  start := Host.Load.Run.Tpl.D1StageSplit.iso1
  tab := Host.Load.Run.Tpl.D1StageSplit.tab0_1
  sim := hsim
  localOk := Host.Load.Run.Tpl.D1StageSplit.st1.loc
  foot := Host.Load.Run.Tpl.D1StageSplit.stFoot1
  nodup := Host.Load.Run.Tpl.D1StageSplit.wrNodup1
  bound := Host.Load.Run.Tpl.D1StageSplit.wrBound1
  trace := Host.Load.Run.Tpl.D1StageSplit.trace1
  merged := Host.Load.Run.Tpl.D1StageSplit.merged1
  len := by
    change Host.Load.Run.Tpl.D1StageSplit.ws1.length = Host.Load.Run.Tpl.D1StageSplit.st1.tpl.S2.tab.length - Host.Load.Run.Tpl.D1StageSplit.S20.tab.length
    rw [← Host.Load.Run.Tpl.D1StageSplit.tab0_1]
    exact Host.Load.Run.Tpl.D1StageSplit.mergeLen1.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.D1StageSplit.fresh1
    simp only [Bool.and_eq_true] at h
    exact h.1)

def D1StageSplit.map_g2_fin_first : List (Nat × Q) := [(9, Q.L), (1000, Q.L), (1001, Q.L), (1002, Q.L)]

noncomputable def D1StageSplit.cut_g2_fin_first_i
    (FR : Map → Nat → FF.S → FF.S → Prop) (J : Disp.JSP FF) (W : Nat → Option WFrame)
    (book : Cls.Inst → SegInst FF → Prop) (i : Cls.Inst) : ICut FF :=
  { pbCut FR J W D1StageSplit.map_g2_fin_first Host.Load.Run.Tpl.D1StageSplit.s21 Host.Load.Run.Tpl.D1StageSplit.S21 i with B := book i }

noncomputable def D1StageSplit.cut_g2_fin_first_o
    (FR : Map → Nat → FF.S → FF.S → Prop) (J : Disp.JSP FF) (W : Nat → Option WFrame)
    (book : Cls.Inst → SegInst FF → Prop) (i : Cls.Inst) : ICut FF :=
  { pbCut FR J W D1StageSplit.map_g2_fin_first Host.Load.Run.Tpl.D1StageSplit.s22 Host.Load.Run.Tpl.D1StageSplit.S22 i with B := book i }

kernel_rfl D1StageSplit.chk_g2_fin_first : ([final_cold.r0].all fun r =>
  goodLin r.ps (varsOf r.V D1StageSplit.map_g2_fin_first) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.D1StageSplit.O))) = true


end Host.Ts.Sim.Compose
