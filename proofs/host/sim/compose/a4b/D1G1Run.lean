import host.sim.compose.a4b.D1G1Data
import host.sim.compose.a4b.D1PreSlice

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.D1Split
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Load.Run.Tpl Host.Route

def g1Framed (K : Ctx) (π : List Nat) : Ctx :=
  Disp.typedK (Disp.Ctx.frameAt K D1Frames.chunk ([], π.map natV)) D1Frames.buffer

theorem g1Run {NB T : Nat} {tk : Nat → Nat} {M : Map} {ν : Nat → F64}
    {K : Ctx} {t : St FF.S} {C : CSrv} {π : List Nat}
    (hr : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      wideP [] M ν K D1StageSplit.s1 ⟨D1StageSplit.S1.tab, []⟩ t C)
    (hk : Disp.KpJ setupJ 4096 K) (hvb : VBOkF loopVB ν) (hg : G1Good ν)
    (hfr : K.fr 2665 = some ([], π.map natV)) (hlen : π.length = 1) (hv : ν 9 = F64.ofNat 1)
    (hi : (bridgeOf D1StageSplit.s15.ffi).active = false) :
    ∃ M' t' C' K', runC FF 261 t C = some (t', C') ∧ Ext M M' D1StageSplit.S1.tab.length ∧
      RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
        (D1Frames.typedW (D1Typed.bytes π)) [] M' ν K' D1StageSplit.s20
        ⟨D1StageSplit.S20.tab, []⟩ t' C' ∧
      Disp.KpJ (D1Frames.typedJ (D1Typed.bytes π)) 4096 K' ∧
      K'.fr = (g1Framed K π).fr ∧ K'.D = K.D ∧ K'.lo = K.lo ∧ K'.hi = K.hi ∧
      ∃ asR ret tr, K'.base' =
        ⟨chars!"mlx_array_new_data", .jsPtr (M'.a D1Frames.buffer) 0 (D1Typed.bytes π) :: asR, ret⟩ :: tr := by
  have rr1 : runOk FF D1StageSplit.okB1 72 D1StageSplit.s1 D1StageSplit.S1 =
      some (D1StageSplit.s2, D1StageSplit.S2) := D1StageSplit.k1
  obtain ⟨M3, t3, C3, r13, e13, h3⟩ := D1Advance.call (sim1 NB T tk) hk hvb hg.s1 accepted1 rr1
    (runOk_ok_end 71 rr1 live2) live2 D1StageSplit.stepA2 top3 hr
  let K1 := Disp.Ctx.frameAt K D1Frames.chunk ([], π.map natV)
  have hk1 : Disp.KpJ D1Frames.chunkJ 4096 K1 :=
    D1Frames.kp_frame (J := setupJ) (J' := D1Frames.chunkJ) rfl rfl rfl hk ([], π.map natV)
  have hf1 : K1.fr D1Frames.chunk = some ([], π.map natV) := Disp.Ctx.frameAt_eq K _ _
  obtain ⟨r34, h4⟩ := slice h3 hfr hlen hv
  have rr4 : runOk FF D1StageSplit.okB2 15 D1StageSplit.s4 D1StageSplit.S4 =
      some (D1StageSplit.s5, D1StageSplit.S5) := D1StageSplit.k4
  obtain ⟨M6, t6, C6, r46, e46, h6⟩ := D1Advance.call (D1Sim.chunk NB T tk) hk1 hvb hg.s4
    accepted4 rr4 accepted5 live5 D1StageSplit.stepA3 top6 h4
  obtain ⟨M7, t7, r67, e67, h7⟩ := length6 h6 (D1Data.laws _ NB) hf1 hlen hv
  have rr7 : runOk FF D1StageSplit.okB3 18 D1StageSplit.s7 D1StageSplit.S7 =
      some (D1StageSplit.s8, D1StageSplit.S8) := D1StageSplit.k7
  obtain ⟨M9, t9, C9, r79, e79, h9⟩ := D1Advance.call (D1Sim.chunk NB T tk) hk1 hvb hg.s7
    accepted7 rr7 accepted8 live8 D1StageSplit.stepA4 top9 h7
  obtain ⟨r910, h10⟩ := typed h9 hf1 hlen
  let K2 := Disp.typedK K1 D1Frames.buffer
  have hk2 := D1Typed.context (D1Typed.bytes π) hk1
  have hfb : K2.fr D1Frames.buffer = some ([], []) :=
    (Disp.Ctx.frameAt_ne _ _ (by decide)).trans (Disp.Ctx.frameAt_eq _ _ _)
  have hfv : K2.fr D1Frames.view = some ([], []) := Disp.Ctx.frameAt_eq _ _ _
  have hfc : K2.fr D1Frames.chunk = some ([], π.map natV) :=
    (Disp.Ctx.frameAt_ne _ _ (by decide)).trans ((Disp.Ctx.frameAt_ne _ _ (by decide)).trans hf1)
  obtain ⟨M12, t12, C12, r1012, e1012, h12⟩ :=
    D1Advance.call (D1Sim.typed NB T tk (D1Typed.bytes π)) hk2 hvb hg.s10
      (congrFun typedAccepted10 _) (congrFun typedRun10 _) (congrFun typedAccepted11 _) live11
      D1StageSplit.stepA5 top12 h10
  obtain ⟨r1213, h13⟩ := ptr h12 hfv hfb
  obtain ⟨M15, t15, C15, r1315, e1315, h15⟩ :=
    D1Advance.call (D1Sim.typed NB T tk (D1Typed.bytes π)) hk2 hvb hg.s13
      (congrFun typedAccepted13 _) (congrFun typedRun13 _) (congrFun typedAccepted14 _) live14
      D1StageSplit.stepA6 top15 h13
  obtain ⟨M16, t16, C16, r1516, e1516, h16, hev⟩ := ND.step h15 hk2 hvb hg.s15 hi hfb
  let K3 : Ctx := ⟨K2.fr, D1StageSplit.s16.trace, t16.trace, K2.D, K2.lo, K2.hi⟩
  have hk3 : Disp.KpJ (D1Frames.typedJ (D1Typed.bytes π)) 4096 K3 := hk2
  obtain ⟨M18, t18, C18, r1618, e1618, h18⟩ :=
    D1Advance.call (D1Sim.typed NB T tk (D1Typed.bytes π)) hk3 hvb hg.s16
      (congrFun typedAccepted16 _) (congrFun typedRun16 _) (congrFun typedAccepted17 _) live17
      D1StageSplit.stepA7 top18 h16
  obtain ⟨M19, t19, r1819, e1819, h19⟩ := length18 h18 (D1Data.laws _ NB) hfc hlen hv
  obtain ⟨M20, t20, C20, r1920, e1920, h20⟩ :=
    D1Advance.run (D1Sim.typed NB T tk (D1Typed.bytes π)) hk3 hvb hg.s19
      (congrFun typedAccepted19 _) (congrFun typedRun19 _) top20 h19
  have he := (((((((((e13.trans e46 (by decide)).trans e67 (by decide)).trans e79 (by decide)).trans
    e1012 (by decide)).trans e1315 (by decide)).trans e1516 (by decide)).trans e1618 (by decide)).trans
    e1819 (by decide)).trans e1920 (by decide))
  have rr := runC_trans (runC_trans (runC_trans (runC_trans (runC_trans (runC_trans
    (runC_trans (runC_trans (runC_trans (runC_trans (runC_trans (runC_trans r13 r34) r46) r67) r79) r910)
      r1012) r1213) r1315) r1516) r1618) r1819) r1920
  refine ⟨M20, t20, C20, K3, rr, he, h20, hk3, rfl, rfl, rfl, rfl, ?_⟩
  obtain ⟨asR, ret, hev⟩ := hev
  refine ⟨asR, ret, t15.trace, ?_⟩
  change t16.trace = _
  rw [e1920.a, e1819.a, e1618.a, e1516.a]
  exact hev

end Host.Ts.Sim.Compose.D1Split
