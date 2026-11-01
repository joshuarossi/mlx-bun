import host.sim.compose.a4b.fd.G1Data

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.FDVW
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Load.Run.Tpl Host.Route

def g1Framed (K : Ctx) (π : List Nat) (n : Nat) : Ctx :=
  Disp.typedK (Disp.Ctx.frameAt K FDFrames.chunk ([], (lastRows π).map natV)) FDFrames.buffer

theorem g1Run {NB T : Nat} {tk : Nat → Nat} {M : Map} {ν : Nat → F64}
    {K : Ctx} {t : St FF.S} {C : CSrv} {π : List Nat} {n : Nat}
    (hr : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      wideP [] M ν K PRE_fd_vw_r0.s2 ⟨PRE_fd_vw_r0.S2.tab, []⟩ t C)
    (hk : Disp.KpJ setupJ 4096 K) (hvb : VBOkF loopVB ν) (hg : G1Good ν)
    (hfr : K.fr 2665 = some ([], π.map natV)) (hn : n ≤ π.length)
    (h53 : π.length < 2 ^ 53) (hn0 : n ≠ 0) (hv : ν 12 = F64.ofNat n)
    (hi : (bridgeOf PRE_fd_vw_r0.s16.ffi).active = false) :
    ∃ M' t' C' K', runC FF 260 t C = some (t', C') ∧ Ext M M' PRE_fd_vw_r0.S2.tab.length ∧
      RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
        (FDFrames.typedW (tokenBytes (lastRows π)) (lastRows π).length) [] M' ν K' PRE_fd_vw_r0.s21
        ⟨PRE_fd_vw_r0.S21.tab, []⟩ t' C' ∧
      Disp.KpJ (FDFrames.typedJ (tokenBytes (lastRows π)) (lastRows π).length) 4096 K' ∧
      K'.fr = (g1Framed K π n).fr ∧ K'.D = K.D ∧ K'.lo = K.lo ∧ K'.hi = K.hi ∧
      ∃ asR ret tr, K'.base' =
        ⟨chars!"mlx_array_new_data", .jsPtr (M'.a FDFrames.buffer) 0 (tokenBytes (lastRows π)) :: asR, ret⟩ :: tr := by
  have hlen : (lastRows π).length = n := by rw [List.length_take, Nat.min_eq_left hn]
  have hvlen : ν 12 = F64.ofNat (lastRows π).length := by rw [hlen]; exact hv
  have rr1 : runOk FF PRE_fd_vw_r0.okB1 71 PRE_fd_vw_r0.s2 PRE_fd_vw_r0.S2 =
      some (PRE_fd_vw_r0.s3, PRE_fd_vw_r0.S3) := PRE_fd_vw_r0.k2
  obtain ⟨M3, t3, C3, r13, e13, h3⟩ := D1Advance.call (SetupCommon.sim NB T tk) hk hvb hg.s19 accepted2 rr1
    (runOk_ok_end 70 rr1 live3) live3 PRE_fd_vw_r0.stepA2 top4 hr
  let K1 := Disp.Ctx.frameAt K FDFrames.chunk ([], (lastRows π).map natV)
  have hk1 : Disp.KpJ FDFrames.chunkJ 4096 K1 :=
    FDFrames.kp_frame (J := setupJ) (J' := FDFrames.chunkJ) rfl rfl rfl hk ([], (lastRows π).map natV)
  have hf1 : K1.fr FDFrames.chunk = some ([], (lastRows π).map natV) := Disp.Ctx.frameAt_eq K _ _
  obtain ⟨r34, h4⟩ := slice h3 hfr hn h53 hv
  have rr4 : runOk FF PRE_fd_vw_r0.okB2 15 PRE_fd_vw_r0.s5 PRE_fd_vw_r0.S5 =
      some (PRE_fd_vw_r0.s6, PRE_fd_vw_r0.S6) := PRE_fd_vw_r0.k5
  obtain ⟨M6, t6, C6, r46, e46, h6⟩ := D1Advance.call (chunkSim NB T tk []) hk1 hvb hg.s22
    accepted5 rr4 accepted6 live6 PRE_fd_vw_r0.stepA3 top7 h4
  obtain ⟨M7, t7, r67, e67, h7, _⟩ := length7 h6 (D1Data.laws _ NB) hf1 hvlen
  have rr7 : runOk FF PRE_fd_vw_r0.okB3 18 PRE_fd_vw_r0.s8 PRE_fd_vw_r0.S8 =
      some (PRE_fd_vw_r0.s9, PRE_fd_vw_r0.S9) := PRE_fd_vw_r0.k8
  obtain ⟨M9, t9, C9, r79, e79, h9⟩ := D1Advance.call (chunkSim NB T tk []) hk1 hvb hg.s25
    accepted8 rr7 accepted9 live9 PRE_fd_vw_r0.stepA4 top10 h7
  obtain ⟨r910, h10⟩ := typed h9 hf1
  let K2 := Disp.typedK K1 FDFrames.buffer
  have hk2 := typedContext (tokenBytes (lastRows π)) (lastRows π).length hk1
  have hfb : K2.fr FDFrames.buffer = some ([], []) :=
    (Disp.Ctx.frameAt_ne _ _ (by decide)).trans (Disp.Ctx.frameAt_eq _ _ _)
  have hfv : K2.fr FDFrames.view = some ([], []) := Disp.Ctx.frameAt_eq _ _ _
  have hfc : K2.fr FDFrames.chunk = some ([], (lastRows π).map natV) :=
    (Disp.Ctx.frameAt_ne _ _ (by decide)).trans ((Disp.Ctx.frameAt_ne _ _ (by decide)).trans hf1)
  obtain ⟨M12, t12, C12, r1012, e1012, h12⟩ :=
    D1Advance.call (typedSim NB T tk (tokenBytes (lastRows π)) (lastRows π).length []) hk2 hvb hg.s28
      (congrFun (congrFun typedAccepted11 _) _) (congrFun (congrFun typedRun11 _) _) (congrFun (congrFun typedAccepted12 _) _) live12
      PRE_fd_vw_r0.stepA5 top13 h10
  obtain ⟨r1213, h13⟩ := ptr h12 hfv hfb (by rw [hlen]; exact hn0)
  obtain ⟨M15, t15, C15, r1315, e1315, h15⟩ :=
    D1Advance.call (typedSim NB T tk (tokenBytes (lastRows π)) (lastRows π).length []) hk2 hvb hg.s31
      (congrFun (congrFun typedAccepted14 _) _) (congrFun (congrFun typedRun14 _) _) (congrFun (congrFun typedAccepted15 _) _) live15
      PRE_fd_vw_r0.stepA6 top16 h13
  obtain ⟨M16, t16, C16, r1516, e1516, h16, hev⟩ := ND.step h15 hk2 hvb hg.s33 hi hfb
  let K3 : Ctx := ⟨K2.fr, PRE_fd_vw_r0.s17.trace, t16.trace, K2.D, K2.lo, K2.hi⟩
  have hk3 : Disp.KpJ (FDFrames.typedJ (tokenBytes (lastRows π)) (lastRows π).length) 4096 K3 := hk2
  obtain ⟨M18, t18, C18, r1618, e1618, h18⟩ :=
    D1Advance.call (typedSim NB T tk (tokenBytes (lastRows π)) (lastRows π).length []) hk3 hvb hg.s34
      (congrFun (congrFun typedAccepted17 _) _) (congrFun (congrFun typedRun17 _) _) (congrFun (congrFun typedAccepted18 _) _) live18
      PRE_fd_vw_r0.stepA7 top19 h16
  obtain ⟨M19, t19, r1819, e1819, h19, _⟩ := length19 h18 (D1Data.laws _ NB) hfc hvlen
  obtain ⟨M20, t20, C20, r1920, e1920, h20⟩ :=
    D1Advance.run (typedSim NB T tk (tokenBytes (lastRows π)) (lastRows π).length []) hk3 hvb hg.s37
      (congrFun (congrFun typedAccepted20 _) _) (congrFun (congrFun typedRun20 _) _) top21 h19
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

end Host.Ts.Sim.Compose.FDVW
