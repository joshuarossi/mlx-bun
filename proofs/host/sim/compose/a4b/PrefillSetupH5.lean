import host.sim.compose.PreCall
import host.sim.lin.Table
import host.sim.template.a4pre_setup_h5_chunk.States
import host.sim.template.a4pre_setup_h5_chunk.SiteL0
import host.sim.template.a4pre_setup_h5_chunk.st0.Tpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

def PRE_setup_h5_chunk.map_start : List (Nat × Q) := [(9, Q.L)]

noncomputable def PRE_setup_h5_chunk.cut_start_i
    (FR : Map → Nat → FF.S → FF.S → Prop) (J : Disp.JSP FF) (W : Nat → Option WFrame)
    (book : Cls.Inst → SegInst FF → Prop) (i : Cls.Inst) : ICut FF :=
  { pbCut FR J W PRE_setup_h5_chunk.map_start Host.Load.Run.Tpl.PRE_setup_h5_chunk.s0 Host.Load.Run.Tpl.PRE_setup_h5_chunk.S0 i with B := book i }

noncomputable def PRE_setup_h5_chunk.cut_start_o
    (FR : Map → Nat → FF.S → FF.S → Prop) (J : Disp.JSP FF) (W : Nat → Option WFrame)
    (book : Cls.Inst → SegInst FF → Prop) (i : Cls.Inst) : ICut FF :=
  { pbCut FR J W PRE_setup_h5_chunk.map_start Host.Load.Run.Tpl.PRE_setup_h5_chunk.s0 Host.Load.Run.Tpl.PRE_setup_h5_chunk.S0 i with B := book i }

kernel_rfl PRE_setup_h5_chunk.chk_start : ([setup_h5.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_setup_h5_chunk.map_start) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_setup_h5_chunk.O))) = true

def PRE_setup_h5_chunk.map_site0 : List (Nat × Q) := [(9, Q.L)]

kernel_rfl PRE_setup_h5_chunk.chk_site0 : ([setup_h5.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_setup_h5_chunk.map_site0) Host.Load.Run.Tpl.PRE_setup_h5_chunk.st0.S0.oracle) = true

noncomputable def PRE_setup_h5_chunk.site0
    {FR : Map → Nat → FF.S → FF.S → Prop} {Kp : Ctx → Prop} {W : Nat → Option WFrame}
    (hsim : ∀ stk, Disp.StepSimXLB FF FR Host.Load.Run.Tpl.PRE_setup_h5_chunk.st0.okL Kp W stk (VBOkF loopVB)) :
    PrefillSite FR Kp W Host.Load.Run.Tpl.PRE_setup_h5_chunk.st0.okL Host.Load.Run.Tpl.PRE_setup_h5_chunk.s0 Host.Load.Run.Tpl.PRE_setup_h5_chunk.s1 Host.Load.Run.Tpl.PRE_setup_h5_chunk.S0 Host.Load.Run.Tpl.PRE_setup_h5_chunk.ws0 where
  tpl := Host.Load.Run.Tpl.PRE_setup_h5_chunk.st0.tpl
  wr := Host.Load.Run.Tpl.PRE_setup_h5_chunk.st0.wr
  start := Host.Load.Run.Tpl.PRE_setup_h5_chunk.iso0
  tab := Host.Load.Run.Tpl.PRE_setup_h5_chunk.tab0_0
  sim := hsim
  localOk := Host.Load.Run.Tpl.PRE_setup_h5_chunk.st0.loc
  foot := Host.Load.Run.Tpl.PRE_setup_h5_chunk.stFoot0
  nodup := Host.Load.Run.Tpl.PRE_setup_h5_chunk.wrNodup0
  bound := Host.Load.Run.Tpl.PRE_setup_h5_chunk.wrBound0
  trace := Host.Load.Run.Tpl.PRE_setup_h5_chunk.trace0
  merged := Host.Load.Run.Tpl.PRE_setup_h5_chunk.merged0
  len := by
    change Host.Load.Run.Tpl.PRE_setup_h5_chunk.ws0.length = Host.Load.Run.Tpl.PRE_setup_h5_chunk.st0.tpl.S2.tab.length - Host.Load.Run.Tpl.PRE_setup_h5_chunk.S0.tab.length
    rw [← Host.Load.Run.Tpl.PRE_setup_h5_chunk.tab0_0]
    exact Host.Load.Run.Tpl.PRE_setup_h5_chunk.mergeLen0.symm
  freshNodup := by decide +kernel
  fresh := noVar_of_all (by
    have h := Host.Load.Run.Tpl.PRE_setup_h5_chunk.fresh0
    simp only [Bool.and_eq_true] at h
    exact h.1)

def PRE_setup_h5_chunk.map_g1 : List (Nat × Q) := [(9, Q.L)]

noncomputable def PRE_setup_h5_chunk.cut_g1_i
    (FR : Map → Nat → FF.S → FF.S → Prop) (J : Disp.JSP FF) (W : Nat → Option WFrame)
    (book : Cls.Inst → SegInst FF → Prop) (i : Cls.Inst) : ICut FF :=
  { pbCut FR J W PRE_setup_h5_chunk.map_g1 Host.Load.Run.Tpl.PRE_setup_h5_chunk.s2 Host.Load.Run.Tpl.PRE_setup_h5_chunk.S2 i with B := book i }

noncomputable def PRE_setup_h5_chunk.cut_g1_o
    (FR : Map → Nat → FF.S → FF.S → Prop) (J : Disp.JSP FF) (W : Nat → Option WFrame)
    (book : Cls.Inst → SegInst FF → Prop) (i : Cls.Inst) : ICut FF :=
  { pbCut FR J W PRE_setup_h5_chunk.map_g1 Host.Load.Run.Tpl.PRE_setup_h5_chunk.s3 Host.Load.Run.Tpl.PRE_setup_h5_chunk.S3 i with B := book i }

kernel_rfl PRE_setup_h5_chunk.chk_g1 : ([setup_h5.r0].all fun r =>
  goodLin r.ps (varsOf r.V PRE_setup_h5_chunk.map_g1) (List.take 0 (List.drop 0 Host.Load.Run.Tpl.PRE_setup_h5_chunk.O))) = true


end Host.Ts.Sim.Compose
