import host.sim.compose.FixedGhost
import host.sim.compose.Glue
import host.sim.compose.CallLink

namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame}
  {ok : St F.S → SSrv → Bool} {Kp : Ctx → Prop} {VBOk : (Nat → F64) → Prop}

/-- Retain tracking on the exact map chosen by the checked glue execution. -/
theorem cut_glue_track {extra : List Nat} {x0 : SegInst F} (hsim : Disp.StepSimXLB F FR ok Kp W [] VBOk) {sa sb : St F.S} {Sa Sb : SSrv} {n : Nat}
    (hok : ok sa Sa = true) (hrun : runOk F ok n sa Sa = some (sb, Sb))
    (htop : noRetBlock sb = true) {Q B : SegInst F → Prop} {J : ICut F}
    (hKν : ∀ c, Q c → B c → Kp c.K ∧ VBOk c.ν) (hg : ∀ c, Q c → B c → Good c.ν Sa.oracle)
    (hQ : ∀ (c : SegInst F) (M' : Map) (t' : St F.S) (C' : CSrv), Q c → B c → RelB F FR W [] c.M c.ν c.K sa Sa c.t c.C →
      Ext c.M M' Sa.tab.length → runC F n c.t c.C = some (t', C') → RelB F FR W [] M' c.ν c.K sb Sb t' C' →
      J.R ⟨M', c.ν, c.K, t', C'⟩ J.s0 ⟨J.tab0, []⟩ ∧ J.B ⟨M', c.ν, c.K, t', C'⟩) :
    CutStep (((Cut.mk sa Sa.tab (Conv.relB F FR W [] Q)).with B).withTrack extra x0) (J.withTrack extra x0) n := by
  exact cut_glue hsim hok hrun htop
    (fun c hq hb => hKν c hq hb.1) (fun c hq hb => hg c hq hb.1)
    (fun c M' t' C' hq hb h0 he hr h1 => by
      obtain ⟨hR, hB⟩ := hQ c M' t' C' hq hb.1 h0 he hr h1
      exact ⟨hR, hB, hb.2.ext he⟩)

/-- Retain tracking on the exact map chosen by glue and its call step. -/
theorem cut_glueCall_track {extra : List Nat} {x0 : SegInst F} (hsim : Disp.StepSimXLB F FR ok Kp W [] VBOk) {sa sb sc : St F.S} {Sa Sb Sc : SSrv}
    {n : Nat} (hok : ok sa Sa = true) (hrun : runOk F ok n sa Sa = some (sb, Sb)) (hokb : ok sb Sb = true)
    (hhalt : isHalt sb.ctl = false) (hstep : interpS (step F sb).run Sb = some (sc, Sc))
    (htop : noRetBlock sc = true) {Q B : SegInst F → Prop} {J : ICut F}
    (hKν : ∀ c, Q c → B c → Kp c.K ∧ VBOk c.ν) (hg : ∀ c, Q c → B c → Good c.ν Sa.oracle)
    (hQ : ∀ (c : SegInst F) (M' : Map) (t' : St F.S) (C' : CSrv), Q c → B c → RelB F FR W [] c.M c.ν c.K sa Sa c.t c.C →
      Ext c.M M' Sa.tab.length → runC F (n + 1) c.t c.C = some (t', C') → RelB F FR W [] M' c.ν c.K sc Sc t' C' →
      J.R ⟨M', c.ν, c.K, t', C'⟩ J.s0 ⟨J.tab0, []⟩ ∧ J.B ⟨M', c.ν, c.K, t', C'⟩) :
    CutStep (((Cut.mk sa Sa.tab (Conv.relB F FR W [] Q)).with B).withTrack extra x0) (J.withTrack extra x0) (n + 1) := by
  exact cut_glueCall hsim hok hrun hokb hhalt hstep htop
    (fun c hq hb => hKν c hq hb.1) (fun c hq hb => hg c hq hb.1)
    (fun c M' t' C' hq hb h0 he hr h1 => by
      obtain ⟨hR, hB⟩ := hQ c M' t' C' hq hb.1 h0 he hr h1
      exact ⟨hR, hB, hb.2.ext he⟩)

/-- Retain tracking through the actual site run and merge, including its result valuation. -/
theorem cut_siteMerge_track {extra : List Nat} {x0 : SegInst F} {ok : St F.S → SSrv → Bool} {Kp : Ctx → Prop} {VBOk : (Nat → F64) → Prop}
    (T : Stage.StageTpl F ok) {sa sm : St F.S} {tab : List SymE} {wr ws : List Nat}
    {Q B Q' B' : SegInst F → Prop}
    (hs0 : T.s0 = { sa with stack := [] }) (htab : T.S0.tab = tab)
    (hsim : ∀ r, Disp.StepSimXLB F FR ok Kp W r VBOk) (hloc : ∀ s S, ok s S = true → Disp.localB s = true)
    (hfoot : Conv.StageFoot wr T.s0 T.s2) (hnd : wr.Nodup) (hbd : ∀ b ∈ wr, b / 4096 < 4 ^ 31)
    (htr : ∃ fr, T.s2.trace = fr ++ T.s0.trace)
    (hmer : ∀ {M : Map} {ν : Nat → F64} {K : Ctx} {S : SSrv} {t : St F.S} {C : CSrv},
      RelB F FR W [] M ν K (Conv.mergeSt Map.id (Map.id.res tab.length tab.length) sa.stack wr sa T.s2 T.s0 T.s2.ffi) S t C →
      RelB F FR W [] M ν K sm S t C)
    (hwsl : ws.length = T.S2.tab.length - tab.length) (hwsnd : ws.Nodup)
    (hfresh : ∀ e ∈ tab, ∀ w ∈ ws, e.noVar w = true)
    (hKν : ∀ c, Q c → B c → Kp c.K ∧ VBOk c.ν) (hg : ∀ c, Q c → B c → Good c.ν T.S0.oracle)
    (hQ : ∀ (c : SegInst F) (M' : Map) (t' : St F.S) (C' : CSrv), Q c → B c →
      RelB F FR W [] c.M c.ν c.K sa T.S0 c.t c.C → Ext c.M M' tab.length →
      runC F (T.n + 1) c.t c.C = some (t', C') →
      RelB F FR W [] M' (Conv.resVal c.ν ws (Conv.resF SymE.var T.S2.tab tab.length c.ν)) c.K sm
        ⟨tab ++ Conv.resTab ws, []⟩ t' C' →
      Q' ⟨M', Conv.resVal c.ν ws (Conv.resF SymE.var T.S2.tab tab.length c.ν), c.K, t', C'⟩ ∧
        B' ⟨M', Conv.resVal c.ν ws (Conv.resF SymE.var T.S2.tab tab.length c.ν), c.K, t', C'⟩) :
    CutStep (((Cut.mk sa tab (Conv.relB F FR W [] Q)).with B).withTrack extra x0)
      (((Cut.mk sm (tab ++ Conv.resTab ws) (Conv.relB F FR W [] Q')).with B').withTrack extra x0) (T.n + 1) := by
  exact cut_siteMerge T hs0 htab hsim hloc hfoot hnd hbd htr hmer hwsl hwsnd hfresh
    (fun c hq hb => hKν c hq hb.1) (fun c hq hb => hg c hq hb.1)
    (fun c M' t' C' hq hb h0 he hr h1 => by
      obtain ⟨hQ', hB'⟩ := hQ c M' t' C' hq hb.1 h0 he hr h1
      exact ⟨hQ', hB', hb.2.ext he⟩)

end
end Host.Ts.Sim.Compose
