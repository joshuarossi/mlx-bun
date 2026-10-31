import host.sim.compose.PreCall
import host.sim.lin.Table
import host.sim.template.a4pre_first_tail_x15_r0.States
import host.sim.template.a4pre_first_tail_x15_r0.SiteL0
import host.sim.template.a4pre_first_tail_x15_r0.st0.Tpl
import host.sim.template.a4pre_first_tail_x15_r0.SiteL1
import host.sim.template.a4pre_first_tail_x15_r0.st1.Tpl
import host.sim.template.a4pre_first_tail_x15_r0.SiteL2
import host.sim.template.a4pre_first_tail_x15_r0.st2.Tpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_first_tail_x15_r0.map_g0a : List (Nat × Q) := [(9, Q.L)]

noncomputable def PRE_first_tail_x15_r0.cut_g0a_i
    (FR : Map → Nat → FF.S → FF.S → Prop) (J : Disp.JSP FF) (W : Nat → Option WFrame)
    (book : Cls.Inst → SegInst FF → Prop) (i : Cls.Inst) : ICut FF :=
  { pbCut FR J W PRE_first_tail_x15_r0.map_g0a Host.Load.Run.Tpl.PRE_first_tail_x15_r0.s0 Host.Load.Run.Tpl.PRE_first_tail_x15_r0.S0 i with B := book i }

noncomputable def PRE_first_tail_x15_r0.cut_g0a_o
    (FR : Map → Nat → FF.S → FF.S → Prop) (J : Disp.JSP FF) (W : Nat → Option WFrame)
    (book : Cls.Inst → SegInst FF → Prop) (i : Cls.Inst) : ICut FF :=
  { pbCut FR J W PRE_first_tail_x15_r0.map_g0a Host.Load.Run.Tpl.PRE_first_tail_x15_r0.s4 Host.Load.Run.Tpl.PRE_first_tail_x15_r0.S4 i with B := book i }

kernel_rfl PRE_first_tail_x15_r0.chk_g0a : ([setup_early.r0, setup_h0.r0, setup_h1.r0, setup_h2.r0, setup_h3.r0, setup_h4.r0, setup_h5.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0.map_g0a) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x15_r0.O))) = true

def PRE_first_tail_x15_r0.map_site0 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x15_r0.chk_site0 : ([setup_h0.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0.map_site0) Host.Load.Run.Tpl.PRE_first_tail_x15_r0.st0.S0.oracle) = true

noncomputable def PRE_first_tail_x15_r0.site0
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR Host.Load.Run.Tpl.PRE_first_tail_x15_r0.st0.okL Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W Host.Load.Run.Tpl.PRE_first_tail_x15_r0.st0.okL Host.Load.Run.Tpl.PRE_first_tail_x15_r0.s4 Host.Load.Run.Tpl.PRE_first_tail_x15_r0.s5 Host.Load.Run.Tpl.PRE_first_tail_x15_r0.S4 Host.Load.Run.Tpl.PRE_first_tail_x15_r0.ws0 where
  tpl := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.st0.tpl
  wr := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.st0.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.iso0
  tab := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.tab0_0
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.st0.loc
  foot := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.stFoot0
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.wrNodup0
  bound := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.wrBound0
  trace := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.trace0
  merged := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.merged0
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x15_r0.ws0.length = Host.Load.Run.Tpl.PRE_first_tail_x15_r0.st0.tpl.S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x15_r0.S4.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x15_r0.tab0_0]
    exact Host.Load.Run.Tpl.PRE_first_tail_x15_r0.mergeLen0.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.fresh0
    simp only [Bool.and_eq_true] at h
    exact h.1)

def PRE_first_tail_x15_r0.map_g0b : List (Nat × Q) := [(9, Q.L)]

noncomputable def PRE_first_tail_x15_r0.cut_g0b_i
    (FR : Map → Nat → FF.S → FF.S → Prop) (J : Disp.JSP FF) (W : Nat → Option WFrame)
    (book : Cls.Inst → SegInst FF → Prop) (i : Cls.Inst) : ICut FF :=
  { pbCut FR J W PRE_first_tail_x15_r0.map_g0b Host.Load.Run.Tpl.PRE_first_tail_x15_r0.s6 Host.Load.Run.Tpl.PRE_first_tail_x15_r0.S6 i with B := book i }

noncomputable def PRE_first_tail_x15_r0.cut_g0b_o
    (FR : Map → Nat → FF.S → FF.S → Prop) (J : Disp.JSP FF) (W : Nat → Option WFrame)
    (book : Cls.Inst → SegInst FF → Prop) (i : Cls.Inst) : ICut FF :=
  { pbCut FR J W PRE_first_tail_x15_r0.map_g0b Host.Load.Run.Tpl.PRE_first_tail_x15_r0.s17 Host.Load.Run.Tpl.PRE_first_tail_x15_r0.S17 i with B := book i }

kernel_rfl PRE_first_tail_x15_r0.chk_g0b : ([setup_early.r0, setup_h0.r0, setup_h1.r0, setup_h2.r0, setup_h3.r0, setup_h4.r0, setup_h5.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0.map_g0b) (List.take 1 (List.drop 0 Host.Load.Run.Tpl.PRE_first_tail_x15_r0.O))) = true

def PRE_first_tail_x15_r0.map_site1 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_first_tail_x15_r0.chk_site1 : ([first_tail_x1.r0, first_tail_x2.r0, first_tail_x3.r0, first_tail_x4.r0, first_tail_x5.r0, first_tail_x6.r0, first_tail_x7.r0, first_tail_x8.r0, first_tail_x9.r0, first_tail_x10.r0, first_tail_x11.r0, first_tail_x12.r0, first_tail_x13.r0, first_tail_x14.r0, first_tail_x15.r0, first_tail_x16.r0, first_tail_x17.r0, first_tail_x18.r0, first_tail_x19.r0, first_tail_x20.r0, first_tail_x21.r0, first_tail_x22.r0, first_tail_x22.r1, first_tail_x23.r0, first_tail_x24.r0, first_tail_x25.r0, first_tail_x26.r0, first_tail_x26.r1, first_tail_x27.r0, first_tail_x28.r0, first_tail_x29.r0, first_tail_x30.r0, first_tail_x30.r1, first_tail_x31.r0, first_tail_x32.r0, first_tail_x32.r1, first_tail_x33.r0, first_tail_x33.r1, first_tail_x34.r0, first_tail_x34.r1, first_tail_x35.r0, first_tail_x35.r1, first_tail_x36.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0.map_site1) Host.Load.Run.Tpl.PRE_first_tail_x15_r0.st1.S0.oracle) = true

noncomputable def PRE_first_tail_x15_r0.site1
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR Host.Load.Run.Tpl.PRE_first_tail_x15_r0.st1.okL Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W Host.Load.Run.Tpl.PRE_first_tail_x15_r0.st1.okL Host.Load.Run.Tpl.PRE_first_tail_x15_r0.s17 Host.Load.Run.Tpl.PRE_first_tail_x15_r0.s18 Host.Load.Run.Tpl.PRE_first_tail_x15_r0.S17 Host.Load.Run.Tpl.PRE_first_tail_x15_r0.ws1 where
  tpl := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.st1.tpl
  wr := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.st1.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.iso1
  tab := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.tab0_1
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.st1.loc
  foot := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.stFoot1
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.wrNodup1
  bound := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.wrBound1
  trace := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.trace1
  merged := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.merged1
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x15_r0.ws1.length = Host.Load.Run.Tpl.PRE_first_tail_x15_r0.st1.tpl.S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x15_r0.S17.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x15_r0.tab0_1]
    exact Host.Load.Run.Tpl.PRE_first_tail_x15_r0.mergeLen1.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.fresh1
    simp only [Bool.and_eq_true] at h
    exact h.1)

def PRE_first_tail_x15_r0.map_g1_DTtail_first : List (Nat × Q) := [(9, Q.L), (1087, Q.n)]

noncomputable def PRE_first_tail_x15_r0.cut_g1_DTtail_first_i
    (FR : Map → Nat → FF.S → FF.S → Prop) (J : Disp.JSP FF) (W : Nat → Option WFrame)
    (book : Cls.Inst → SegInst FF → Prop) (i : Cls.Inst) : ICut FF :=
  { pbCut FR J W PRE_first_tail_x15_r0.map_g1_DTtail_first Host.Load.Run.Tpl.PRE_first_tail_x15_r0.s19 Host.Load.Run.Tpl.PRE_first_tail_x15_r0.S19 i with B := book i }

noncomputable def PRE_first_tail_x15_r0.cut_g1_DTtail_first_o
    (FR : Map → Nat → FF.S → FF.S → Prop) (J : Disp.JSP FF) (W : Nat → Option WFrame)
    (book : Cls.Inst → SegInst FF → Prop) (i : Cls.Inst) : ICut FF :=
  { pbCut FR J W PRE_first_tail_x15_r0.map_g1_DTtail_first Host.Load.Run.Tpl.PRE_first_tail_x15_r0.s38 Host.Load.Run.Tpl.PRE_first_tail_x15_r0.S38 i with B := book i }

kernel_rfl PRE_first_tail_x15_r0.chk_g1_DTtail_first : ([first_tail_x1.r0, first_tail_x2.r0, first_tail_x3.r0, first_tail_x4.r0, first_tail_x5.r0, first_tail_x6.r0, first_tail_x7.r0, first_tail_x8.r0, first_tail_x9.r0, first_tail_x10.r0, first_tail_x11.r0, first_tail_x12.r0, first_tail_x13.r0, first_tail_x14.r0, first_tail_x15.r0, first_tail_x16.r0, first_tail_x17.r0, first_tail_x18.r0, first_tail_x19.r0, first_tail_x20.r0, first_tail_x21.r0, first_tail_x22.r0, first_tail_x22.r1, first_tail_x23.r0, first_tail_x24.r0, first_tail_x25.r0, first_tail_x26.r0, first_tail_x26.r1, first_tail_x27.r0, first_tail_x28.r0, first_tail_x29.r0, first_tail_x30.r0, first_tail_x30.r1, first_tail_x31.r0, first_tail_x32.r0, first_tail_x32.r1, first_tail_x33.r0, first_tail_x33.r1, first_tail_x34.r0, first_tail_x34.r1, first_tail_x35.r0, first_tail_x35.r1, first_tail_x36.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0.map_g1_DTtail_first) (List.take 0 (List.drop 1 Host.Load.Run.Tpl.PRE_first_tail_x15_r0.O))) = true

def PRE_first_tail_x15_r0.map_site2 : List (Nat × Q) := [(9, Q.L), (1087, Q.n)]

kernel_rfl PRE_first_tail_x15_r0.chk_site2 : ([first_tail_x5.r0, first_tail_x6.r0, first_tail_x7.r0, first_tail_x8.r0, first_tail_x9.r0, first_tail_x10.r0, first_tail_x11.r0, first_tail_x12.r0, first_tail_x13.r0, first_tail_x14.r0, first_tail_x15.r0, first_tail_x16.r0, first_tail_x17.r0, first_tail_x18.r0, first_tail_x19.r0, first_tail_x20.r0, first_tail_x21.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0.map_site2) Host.Load.Run.Tpl.PRE_first_tail_x15_r0.st2.S0.oracle) = true

noncomputable def PRE_first_tail_x15_r0.site2
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR Host.Load.Run.Tpl.PRE_first_tail_x15_r0.st2.okL Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W Host.Load.Run.Tpl.PRE_first_tail_x15_r0.st2.okL Host.Load.Run.Tpl.PRE_first_tail_x15_r0.s38 Host.Load.Run.Tpl.PRE_first_tail_x15_r0.s39 Host.Load.Run.Tpl.PRE_first_tail_x15_r0.S38 Host.Load.Run.Tpl.PRE_first_tail_x15_r0.ws2 where
  tpl := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.st2.tpl
  wr := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.st2.wr
  start := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.iso2
  tab := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.tab0_2
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.st2.loc
  foot := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.stFoot2
  nodup := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.wrNodup2
  bound := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.wrBound2
  trace := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.trace2
  merged := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.merged2
  len := by
    change Host.Load.Run.Tpl.PRE_first_tail_x15_r0.ws2.length = Host.Load.Run.Tpl.PRE_first_tail_x15_r0.st2.tpl.S2.tab.length - Host.Load.Run.Tpl.PRE_first_tail_x15_r0.S38.tab.length
    rw [← Host.Load.Run.Tpl.PRE_first_tail_x15_r0.tab0_2]
    exact Host.Load.Run.Tpl.PRE_first_tail_x15_r0.mergeLen2.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_first_tail_x15_r0.fresh2
    simp only [Bool.and_eq_true] at h
    exact h.1)

def PRE_first_tail_x15_r0.map_g2_first : List (Nat × Q) := [(9, Q.L), (1087, Q.n)]

noncomputable def PRE_first_tail_x15_r0.cut_g2_first_i
    (FR : Map → Nat → FF.S → FF.S → Prop) (J : Disp.JSP FF) (W : Nat → Option WFrame)
    (book : Cls.Inst → SegInst FF → Prop) (i : Cls.Inst) : ICut FF :=
  { pbCut FR J W PRE_first_tail_x15_r0.map_g2_first Host.Load.Run.Tpl.PRE_first_tail_x15_r0.s40 Host.Load.Run.Tpl.PRE_first_tail_x15_r0.S40 i with B := book i }

noncomputable def PRE_first_tail_x15_r0.cut_g2_first_o
    (FR : Map → Nat → FF.S → FF.S → Prop) (J : Disp.JSP FF) (W : Nat → Option WFrame)
    (book : Cls.Inst → SegInst FF → Prop) (i : Cls.Inst) : ICut FF :=
  { pbCut FR J W PRE_first_tail_x15_r0.map_g2_first Host.Load.Run.Tpl.PRE_first_tail_x15_r0.s41 Host.Load.Run.Tpl.PRE_first_tail_x15_r0.S41 i with B := book i }

kernel_rfl PRE_first_tail_x15_r0.chk_g2_first : ([first_drain_2048.r0, first_drain_2048.r1, first_drain_1024.r0, first_drain_512.r0, first_drain_256.r0, first_drain_128.r0, first_drain_64.r0, first_tail_x0.r0, first_tail_x1.r0, first_tail_x2.r0, first_tail_x3.r0, first_tail_x4.r0, first_tail_x5.r0, first_tail_x6.r0, first_tail_x7.r0, first_tail_x8.r0, first_tail_x9.r0, first_tail_x10.r0, first_tail_x11.r0, first_tail_x12.r0, first_tail_x13.r0, first_tail_x14.r0, first_tail_x15.r0, first_tail_x16.r0, first_tail_x17.r0, first_tail_x18.r0, first_tail_x19.r0, first_tail_x20.r0, first_tail_x21.r0, first_tail_x22.r0, first_tail_x22.r1, first_tail_x23.r0, first_tail_x24.r0, first_tail_x25.r0, first_tail_x26.r0, first_tail_x26.r1, first_tail_x27.r0, first_tail_x28.r0, first_tail_x29.r0, first_tail_x30.r0, first_tail_x30.r1, first_tail_x31.r0, first_tail_x32.r0, first_tail_x32.r1, first_tail_x33.r0, first_tail_x33.r1, first_tail_x34.r0, first_tail_x34.r1, first_tail_x35.r0, first_tail_x35.r1, first_tail_x36.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_first_tail_x15_r0.map_g2_first) (List.take 0 (List.drop 1 Host.Load.Run.Tpl.PRE_first_tail_x15_r0.O))) = true


end Host.Ts.Sim.Compose
