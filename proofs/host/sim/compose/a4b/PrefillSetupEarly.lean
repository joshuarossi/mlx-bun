import host.sim.compose.PreCall
import host.sim.lin.Table
import host.sim.template.a4pre_setup_early_r0.States
import host.sim.template.a4pre_setup_early_r0.SiteL0
import host.sim.template.a4pre_setup_early_r0.st0.Tpl
import host.sim.compose.a4b.FillSetupEarly
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_setup_early_r0.map_g0a : List (Nat × Q) := [(9, Q.L)]

noncomputable def PRE_setup_early_r0.cut_g0a_i
    (FR : Map → Nat → FF.S → FF.S → Prop) (J : Disp.JSP FF) (W : Nat → Option WFrame)
    (book : Cls.Inst → SegInst FF → Prop) (i : Cls.Inst) : ICut FF :=
  { pbCut FR J W PRE_setup_early_r0.map_g0a Host.Load.Run.Tpl.PRE_setup_early_r0.s0 Host.Load.Run.Tpl.PRE_setup_early_r0.S0 i with B := book i }

noncomputable def PRE_setup_early_r0.cut_g0a_o
    (FR : Map → Nat → FF.S → FF.S → Prop) (J : Disp.JSP FF) (W : Nat → Option WFrame)
    (book : Cls.Inst → SegInst FF → Prop) (i : Cls.Inst) : ICut FF :=
  { pbCut FR J W PRE_setup_early_r0.map_g0a Host.Load.Run.Tpl.PRE_setup_early_r0.s4 Host.Load.Run.Tpl.PRE_setup_early_r0.S4 i with B := book i }

kernel_rfl PRE_setup_early_r0.chk_g0a : ([setup_early.r0, setup_h0.r0, setup_h1.r0, setup_h2.r0, setup_h3.r0, setup_h4.r0, setup_h5.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_setup_early_r0.map_g0a) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_setup_early_r0.O))) = true

def PRE_setup_early_r0.map_site0 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_setup_early_r0.chk_site0 : ([setup_early.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_setup_early_r0.map_site0) Host.Load.Run.Tpl.PRE_setup_early_r0.st0.S0.oracle) = true

noncomputable def PRE_setup_early_r0.site0
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR Host.Load.Run.Tpl.PRE_setup_early_r0.st0.okL Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W Host.Load.Run.Tpl.PRE_setup_early_r0.st0.okL Host.Load.Run.Tpl.PRE_setup_early_r0.s4 Host.Load.Run.Tpl.PRE_setup_early_r0.s5 Host.Load.Run.Tpl.PRE_setup_early_r0.S4 Host.Load.Run.Tpl.PRE_setup_early_r0.ws0 where
  tpl := Host.Load.Run.Tpl.PRE_setup_early_r0.st0.tpl
  wr := Host.Load.Run.Tpl.PRE_setup_early_r0.st0.wr
  start := Host.Load.Run.Tpl.PRE_setup_early_r0.iso0
  tab := Host.Load.Run.Tpl.PRE_setup_early_r0.tab0_0
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_setup_early_r0.st0.loc
  foot := Host.Load.Run.Tpl.PRE_setup_early_r0.stFoot0
  nodup := Host.Load.Run.Tpl.PRE_setup_early_r0.wrNodup0
  bound := Host.Load.Run.Tpl.PRE_setup_early_r0.wrBound0
  trace := Host.Load.Run.Tpl.PRE_setup_early_r0.trace0
  merged := Host.Load.Run.Tpl.PRE_setup_early_r0.merged0
  len := by
    change Host.Load.Run.Tpl.PRE_setup_early_r0.ws0.length = Host.Load.Run.Tpl.PRE_setup_early_r0.st0.S2.tab.length - Host.Load.Run.Tpl.PRE_setup_early_r0.S4.tab.length
    rw [← Host.Load.Run.Tpl.PRE_setup_early_r0.tab0_0, Host.Load.Run.Tpl.PRE_setup_early_r0.mergeLen0]
    rfl
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_setup_early_r0.fresh0
    simp only [Bool.and_eq_true] at h
    exact h.1)

def PRE_setup_early_r0.map_g0b : List (Nat × Q) := [(9, Q.L)]

noncomputable def PRE_setup_early_r0.cut_g0b_i
    (FR : Map → Nat → FF.S → FF.S → Prop) (J : Disp.JSP FF) (W : Nat → Option WFrame)
    (book : Cls.Inst → SegInst FF → Prop) (i : Cls.Inst) : ICut FF :=
  { pbCut FR J W PRE_setup_early_r0.map_g0b Host.Load.Run.Tpl.PRE_setup_early_r0.s6 Host.Load.Run.Tpl.PRE_setup_early_r0.S6 i with B := book i }

noncomputable def PRE_setup_early_r0.cut_g0b_o
    (FR : Map → Nat → FF.S → FF.S → Prop) (J : Disp.JSP FF) (W : Nat → Option WFrame)
    (book : Cls.Inst → SegInst FF → Prop) (i : Cls.Inst) : ICut FF :=
  { pbCut FR J W PRE_setup_early_r0.map_g0b Host.Load.Run.Tpl.PRE_setup_early_r0.s16 Host.Load.Run.Tpl.PRE_setup_early_r0.S16 i with B := book i }

kernel_rfl PRE_setup_early_r0.chk_g0b : ([setup_early.r0, setup_h0.r0, setup_h1.r0, setup_h2.r0, setup_h3.r0, setup_h4.r0, setup_h5.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_setup_early_r0.map_g0b) (List.take 1 (List.drop 0 Host.Load.Run.Tpl.PRE_setup_early_r0.O))) = true

/-- The bundle uses the shared PRE_g0b template after the zero-step C seam. -/
noncomputable def PRE_setup_early_r0.b_g0a_o (NB T : Nat) (tk : Nat → Nat) (i : Cls.Inst) : ICut FF :=
  withSetupInputs T tk (SetupChunk.chunkCallFixedCut NB T tk i.L)
noncomputable def PRE_setup_early_r0.b_g0b_i (NB T : Nat) (tk : Nat → Nat) : Cls.Inst → ICut FF :=
  SetupCommon.cut NB T tk Host.Load.Run.Tpl.PRE_g0b.s0 Host.Load.Run.Tpl.PRE_g0b.S0
noncomputable def PRE_setup_early_r0.pc0 := SetupCommon.nextCut

noncomputable def PRE_setup_early_r0.g0a := FillSetupEarly.g0a
noncomputable def PRE_setup_early_r0.chunk_K8__g0a__g0b := FillSetupEarly.chunk_K8__g0a__g0b
noncomputable def PRE_setup_early_r0.g0b := FillSetupEarly.g0b

end Host.Ts.Sim.Compose
