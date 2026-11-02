import host.sim.compose.a4b.x4_L8.G1Data

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Load.Run.Tpl Host.Route

def g1Framed (K : Ctx) (π : List Nat) (n : Nat) : Ctx :=
  Disp.typedK (Disp.Ctx.frameAt K VWFrames.chunk ([], (π.take n).map natV)) VWFrames.buffer

theorem g1Run {NB T : Nat} {tk : Nat → Nat} {M : Map} {ν : Nat → F64}
    {K : Ctx} {t : St FF.S} {C : CSrv} {π : List Nat} {n : Nat}
    (hr : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      wideP [] M ν K PRE_first_tail_x4_L8_r0.s19 ⟨PRE_first_tail_x4_L8_r0.S19.tab, []⟩ t C)
    (hk : Disp.KpJ setupJ 4096 K) (hvb : VBOkF loopVB ν) (hg : G1Good ν)
    (hfr : K.fr 2665 = some ([], π.map natV)) (hn : n ≤ π.length)
    (h53 : π.length < 2 ^ 53) (hn0 : n ≠ 0) (hv : ν 1008 = F64.ofNat n) (hn6 : n = 7)
    (hi : (bridgeOf PRE_first_tail_x4_L8_r0.s33.ffi).active = false) :
    ∃ M' t' C' K', runC FF 260 t C = some (t', C') ∧ Ext M M' PRE_first_tail_x4_L8_r0.S19.tab.length ∧
      RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
        (VWFrames.typedW (tokenBytes (π.take n)) (π.take n).length) [] M' ν K' PRE_first_tail_x4_L8_r0.s38
        ⟨PRE_first_tail_x4_L8_r0.S38.tab, []⟩ t' C' ∧
      Disp.KpJ (VWFrames.typedJ (tokenBytes (π.take n)) (π.take n).length) 4096 K' ∧
      K'.fr = (g1Framed K π n).fr ∧ K'.D = K.D ∧ K'.lo = K.lo ∧ K'.hi = K.hi ∧
      ∃ asR ret tr, K'.base' =
        ⟨chars!"mlx_array_new_data", .jsPtr (M'.a VWFrames.buffer) 0 (tokenBytes (π.take n)) :: asR, ret⟩ :: tr := by
  have hlen : (π.take n).length = n := by rw [List.length_take, Nat.min_eq_left hn]
  have hvlen : ν 1008 = F64.ofNat (π.take n).length := by rw [hlen]; exact hv
  have hlenN : (π.take n).length = 7 := hlen.trans hn6
  have rr1 : runOk FF PRE_first_tail_x4_L8_r0.okB6 71 PRE_first_tail_x4_L8_r0.s19 PRE_first_tail_x4_L8_r0.S19 =
      some (PRE_first_tail_x4_L8_r0.s20, PRE_first_tail_x4_L8_r0.S20) := PRE_first_tail_x4_L8_r0.k19
  obtain ⟨M3, t3, C3, r13, e13, h3⟩ := D1Advance.call (SetupCommon.sim NB T tk) hk hvb hg.s19 accepted19 rr1
    (runOk_ok_end 70 rr1 live20) live20 PRE_first_tail_x4_L8_r0.stepA7 top21 hr
  let K1 := Disp.Ctx.frameAt K VWFrames.chunk ([], (π.take n).map natV)
  have hk1 : Disp.KpJ VWFrames.chunkJ 4096 K1 :=
    VWFrames.kp_frame (J := setupJ) (J' := VWFrames.chunkJ) rfl rfl rfl hk ([], (π.take n).map natV)
  have hf1 : K1.fr VWFrames.chunk = some ([], (π.take n).map natV) := Disp.Ctx.frameAt_eq K _ _
  obtain ⟨r34, h4⟩ := slice h3 hfr hn h53 hv
  have rr4 : runOk FF PRE_first_tail_x4_L8_r0.okB7 15 PRE_first_tail_x4_L8_r0.s22 PRE_first_tail_x4_L8_r0.S22 =
      some (PRE_first_tail_x4_L8_r0.s23, PRE_first_tail_x4_L8_r0.S23) := PRE_first_tail_x4_L8_r0.k22
  obtain ⟨M6, t6, C6, r46, e46, h6⟩ := D1Advance.call (chunkSim NB T tk []) hk1 hvb hg.s22
    accepted22 rr4 accepted23 live23 PRE_first_tail_x4_L8_r0.stepA8 top24 h4
  obtain ⟨M7, t7, r67, e67, h7, _⟩ := length24 h6 hf1 hlenN
  have rr7 : runOk FF PRE_first_tail_x4_L8_r0.okB8 18 PRE_first_tail_x4_L8_r0.s25 PRE_first_tail_x4_L8_r0.S25 =
      some (PRE_first_tail_x4_L8_r0.s26, PRE_first_tail_x4_L8_r0.S26) := PRE_first_tail_x4_L8_r0.k25
  obtain ⟨M9, t9, C9, r79, e79, h9⟩ := D1Advance.call (chunkSim NB T tk []) hk1 hvb hg.s25
    accepted25 rr7 accepted26 live26 PRE_first_tail_x4_L8_r0.stepA9 top27 h7
  obtain ⟨r910, h10⟩ := typed h9 hf1
  let K2 := Disp.typedK K1 VWFrames.buffer
  have hk2 := typedContext (tokenBytes (π.take n)) (π.take n).length hk1
  have hfb : K2.fr VWFrames.buffer = some ([], []) :=
    (Disp.Ctx.frameAt_ne _ _ (by decide)).trans (Disp.Ctx.frameAt_eq _ _ _)
  have hfv : K2.fr VWFrames.view = some ([], []) := Disp.Ctx.frameAt_eq _ _ _
  have hfc : K2.fr VWFrames.chunk = some ([], (π.take n).map natV) :=
    (Disp.Ctx.frameAt_ne _ _ (by decide)).trans ((Disp.Ctx.frameAt_ne _ _ (by decide)).trans hf1)
  obtain ⟨M12, t12, C12, r1012, e1012, h12⟩ :=
    D1Advance.call (typedSim NB T tk (tokenBytes (π.take n)) (π.take n).length []) hk2 hvb hg.s28
      (congrFun (congrFun typedAccepted28 _) _) (congrFun (congrFun typedRun28 _) _) (congrFun (congrFun typedAccepted29 _) _) live29
      PRE_first_tail_x4_L8_r0.stepA10 top30 h10
  obtain ⟨r1213, h13⟩ := ptr h12 hfv hfb (by rw [hlen]; exact hn0)
  obtain ⟨M15, t15, C15, r1315, e1315, h15⟩ :=
    D1Advance.call (typedSim NB T tk (tokenBytes (π.take n)) (π.take n).length []) hk2 hvb hg.s31
      (congrFun (congrFun typedAccepted31 _) _) (congrFun (congrFun typedRun31 _) _) (congrFun (congrFun typedAccepted32 _) _) live32
      PRE_first_tail_x4_L8_r0.stepA11 top33 h13
  obtain ⟨M16, t16, C16, r1516, e1516, h16, hev⟩ := ND.step h15 hk2 hvb hg.s33 hi hfb
  let K3 : Ctx := ⟨K2.fr, PRE_first_tail_x4_L8_r0.s34.trace, t16.trace, K2.D, K2.lo, K2.hi⟩
  have hk3 : Disp.KpJ (VWFrames.typedJ (tokenBytes (π.take n)) (π.take n).length) 4096 K3 := hk2
  obtain ⟨M18, t18, C18, r1618, e1618, h18⟩ :=
    D1Advance.call (typedSim NB T tk (tokenBytes (π.take n)) (π.take n).length []) hk3 hvb hg.s34
      (congrFun (congrFun typedAccepted34 _) _) (congrFun (congrFun typedRun34 _) _) (congrFun (congrFun typedAccepted35 _) _) live35
      PRE_first_tail_x4_L8_r0.stepA12 top36 h16
  obtain ⟨M19, t19, r1819, e1819, h19, _⟩ := length36 h18 hfc hlenN
  obtain ⟨M20, t20, C20, r1920, e1920, h20⟩ :=
    D1Advance.run (typedSim NB T tk (tokenBytes (π.take n)) (π.take n).length []) hk3 hvb hg.s37
      (congrFun (congrFun typedAccepted37 _) _) (congrFun (congrFun typedRun37 _) _) top38 h19
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

end Host.Ts.Sim.Compose.VWFirst.X4_L8
