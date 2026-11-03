import host.sim.compose.PreCall
import host.sim.lin.Table
import host.sim.template.a4pre_fd_vw_r0.States
import host.sim.template.a4pre_fd_vw_r0.SiteL0
import host.sim.template.a4pre_fd_vw_r0.st0.Tpl
import host.sim.template.a4pre_fd_vw_r0.SiteL1
import host.sim.template.a4pre_fd_vw_r0.st1.Tpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_fd_vw_r0.map_start : List (Nat × Q) := [(9, Q.L), (10, Q.o), (11, Q.o), (16, Q.cap)]

noncomputable def PRE_fd_vw_r0.cut_start_i
    (FR : Map → Nat → FF.S → FF.S → Prop) (J : Disp.JSP FF) (W : Nat → Option WFrame)
    (book : Cls.Inst → SegInst FF → Prop) (i : Cls.Inst) : ICut FF :=
  { pbCut FR J W PRE_fd_vw_r0.map_start Host.Load.Run.Tpl.PRE_fd_vw_r0.s0 Host.Load.Run.Tpl.PRE_fd_vw_r0.S0 i with B := book i }

noncomputable def PRE_fd_vw_r0.cut_start_o
    (FR : Map → Nat → FF.S → FF.S → Prop) (J : Disp.JSP FF) (W : Nat → Option WFrame)
    (book : Cls.Inst → SegInst FF → Prop) (i : Cls.Inst) : ICut FF :=
  { pbCut FR J W PRE_fd_vw_r0.map_start Host.Load.Run.Tpl.PRE_fd_vw_r0.s0 Host.Load.Run.Tpl.PRE_fd_vw_r0.S0 i with B := book i }

kernel_rfl PRE_fd_vw_r0.chk_start : ([final_ord.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_fd_vw_r0.map_start) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_fd_vw_r0.O))) = true

def PRE_fd_vw_r0.map_site0 : List (Nat × Q) := [(9, Q.L), (10, Q.o), (11, Q.o), (16, Q.cap)]

kernel_rfl PRE_fd_vw_r0.chk_site0 : ([final_ord.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_fd_vw_r0.map_site0) Host.Load.Run.Tpl.PRE_fd_vw_r0.st0.S0.oracle) = true

noncomputable def PRE_fd_vw_r0.site0
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR Host.Load.Run.Tpl.PRE_fd_vw_r0.st0.okL Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W Host.Load.Run.Tpl.PRE_fd_vw_r0.st0.okL Host.Load.Run.Tpl.PRE_fd_vw_r0.s0 Host.Load.Run.Tpl.PRE_fd_vw_r0.s1 Host.Load.Run.Tpl.PRE_fd_vw_r0.S0 Host.Load.Run.Tpl.PRE_fd_vw_r0.ws0 where
  tpl := Host.Load.Run.Tpl.PRE_fd_vw_r0.st0.tpl
  wr := Host.Load.Run.Tpl.PRE_fd_vw_r0.st0.wr
  start := Host.Load.Run.Tpl.PRE_fd_vw_r0.iso0
  tab := Host.Load.Run.Tpl.PRE_fd_vw_r0.tab0_0
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_fd_vw_r0.st0.loc
  foot := Host.Load.Run.Tpl.PRE_fd_vw_r0.stFoot0
  nodup := Host.Load.Run.Tpl.PRE_fd_vw_r0.wrNodup0
  bound := Host.Load.Run.Tpl.PRE_fd_vw_r0.wrBound0
  trace := Host.Load.Run.Tpl.PRE_fd_vw_r0.trace0
  merged := Host.Load.Run.Tpl.PRE_fd_vw_r0.merged0
  len := by
    change Host.Load.Run.Tpl.PRE_fd_vw_r0.ws0.length = Host.Load.Run.Tpl.PRE_fd_vw_r0.st0.tpl.S2.tab.length - Host.Load.Run.Tpl.PRE_fd_vw_r0.S0.tab.length
    rw [← Host.Load.Run.Tpl.PRE_fd_vw_r0.tab0_0]
    exact Host.Load.Run.Tpl.PRE_fd_vw_r0.mergeLen0.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_fd_vw_r0.fresh0
    simp only [Bool.and_eq_true] at h
    exact h.1)

def PRE_fd_vw_r0.map_g1_FIN_tailed : List (Nat × Q) := [(9, Q.L), (10, Q.o), (11, Q.o), (16, Q.cap)]

noncomputable def PRE_fd_vw_r0.cut_g1_FIN_tailed_i
    (FR : Map → Nat → FF.S → FF.S → Prop) (J : Disp.JSP FF) (W : Nat → Option WFrame)
    (book : Cls.Inst → SegInst FF → Prop) (i : Cls.Inst) : ICut FF :=
  { pbCut FR J W PRE_fd_vw_r0.map_g1_FIN_tailed Host.Load.Run.Tpl.PRE_fd_vw_r0.s2 Host.Load.Run.Tpl.PRE_fd_vw_r0.S2 i with B := book i }

noncomputable def PRE_fd_vw_r0.cut_g1_FIN_tailed_o
    (FR : Map → Nat → FF.S → FF.S → Prop) (J : Disp.JSP FF) (W : Nat → Option WFrame)
    (book : Cls.Inst → SegInst FF → Prop) (i : Cls.Inst) : ICut FF :=
  { pbCut FR J W PRE_fd_vw_r0.map_g1_FIN_tailed Host.Load.Run.Tpl.PRE_fd_vw_r0.s21 Host.Load.Run.Tpl.PRE_fd_vw_r0.S21 i with B := book i }

kernel_rfl PRE_fd_vw_r0.chk_g1_FIN_tailed : ([final_ord.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_fd_vw_r0.map_g1_FIN_tailed) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_fd_vw_r0.O))) = true

def PRE_fd_vw_r0.map_site1 : List (Nat × Q) := [(9, Q.L), (10, Q.o), (11, Q.o), (16, Q.cap)]

kernel_rfl PRE_fd_vw_r0.chk_site1 : ([final_ord.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_fd_vw_r0.map_site1) Host.Load.Run.Tpl.PRE_fd_vw_r0.st1.S0.oracle) = true

noncomputable def PRE_fd_vw_r0.site1
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR Host.Load.Run.Tpl.PRE_fd_vw_r0.st1.okL Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W Host.Load.Run.Tpl.PRE_fd_vw_r0.st1.okL Host.Load.Run.Tpl.PRE_fd_vw_r0.s21 Host.Load.Run.Tpl.PRE_fd_vw_r0.s22 Host.Load.Run.Tpl.PRE_fd_vw_r0.S21 Host.Load.Run.Tpl.PRE_fd_vw_r0.ws1 where
  tpl := Host.Load.Run.Tpl.PRE_fd_vw_r0.st1.tpl
  wr := Host.Load.Run.Tpl.PRE_fd_vw_r0.st1.wr
  start := Host.Load.Run.Tpl.PRE_fd_vw_r0.iso1
  tab := Host.Load.Run.Tpl.PRE_fd_vw_r0.tab0_1
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_fd_vw_r0.st1.loc
  foot := Host.Load.Run.Tpl.PRE_fd_vw_r0.stFoot1
  nodup := Host.Load.Run.Tpl.PRE_fd_vw_r0.wrNodup1
  bound := Host.Load.Run.Tpl.PRE_fd_vw_r0.wrBound1
  trace := Host.Load.Run.Tpl.PRE_fd_vw_r0.trace1
  merged := Host.Load.Run.Tpl.PRE_fd_vw_r0.merged1
  len := by
    change Host.Load.Run.Tpl.PRE_fd_vw_r0.ws1.length = Host.Load.Run.Tpl.PRE_fd_vw_r0.st1.tpl.S2.tab.length - Host.Load.Run.Tpl.PRE_fd_vw_r0.S21.tab.length
    rw [← Host.Load.Run.Tpl.PRE_fd_vw_r0.tab0_1]
    exact Host.Load.Run.Tpl.PRE_fd_vw_r0.mergeLen1.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_fd_vw_r0.fresh1
    simp only [Bool.and_eq_true] at h
    exact h.1)

def PRE_fd_vw_r0.map_g2_fin_tailed : List (Nat × Q) := [(9, Q.L), (10, Q.o), (11, Q.o), (16, Q.cap)]

noncomputable def PRE_fd_vw_r0.cut_g2_fin_tailed_i
    (FR : Map → Nat → FF.S → FF.S → Prop) (J : Disp.JSP FF) (W : Nat → Option WFrame)
    (book : Cls.Inst → SegInst FF → Prop) (i : Cls.Inst) : ICut FF :=
  { pbCut FR J W PRE_fd_vw_r0.map_g2_fin_tailed Host.Load.Run.Tpl.PRE_fd_vw_r0.s23 Host.Load.Run.Tpl.PRE_fd_vw_r0.S23 i with B := book i }

noncomputable def PRE_fd_vw_r0.cut_g2_fin_tailed_o
    (FR : Map → Nat → FF.S → FF.S → Prop) (J : Disp.JSP FF) (W : Nat → Option WFrame)
    (book : Cls.Inst → SegInst FF → Prop) (i : Cls.Inst) : ICut FF :=
  { pbCut FR J W PRE_fd_vw_r0.map_g2_fin_tailed Host.Load.Run.Tpl.PRE_fd_vw_r0.s24 Host.Load.Run.Tpl.PRE_fd_vw_r0.S24 i with B := book i }

kernel_rfl PRE_fd_vw_r0.chk_g2_fin_tailed : ([final_ord.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_fd_vw_r0.map_g2_fin_tailed) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_fd_vw_r0.O))) = true


end Host.Ts.Sim.Compose
