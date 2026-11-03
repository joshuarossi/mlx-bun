import host.sim.compose.a4b.fd_x4_L7.G1Run
import host.sim.compose.a4b.fd_x4_L7.NewDataInput
import host.sim.conv.CallPieces

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.FDX4L7
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Load.Run.Tpl Host.Route

theorem g1Run_input {NB T : Nat} {tk : Nat → Nat} {M : Map} {ν : Nat → F64}
    {K : Ctx} {t : St FF.S} {C : CSrv} {π : List Nat}
    (hr : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      wideGPf [] M ν K PRE_fd_x4_L7_r0.s2 ⟨PRE_fd_x4_L7_r0.S2.tab, []⟩ t C)
    (hk : Disp.KpJ FDX4L7Frames.startJ 131072 K) (hvb : VBOkF loopVB ν) (hg : G1Good ν)
    (hfr : K.fr 2665 = some ([], π.map natV)) (h1 : 1 ≤ π.length)
    (h53 : π.length < 2 ^ 53) (hv9 : ν 9 = F64.ofNat π.length) (hv10 : ν 10 = F64.ofNat (π.length - 1))
    (hi : (bridgeOf PRE_fd_x4_L7_r0.s16.ffi).active = false)
    (hvc : ∀ k ∈ π, k < 248320) :
    ∃ M' t' C' K', runC FF 261 t C = some (t', C') ∧ Ext M M' PRE_fd_x4_L7_r0.S2.tab.length ∧
      RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
        (FDX4L7Frames.typedW (tokenBytes (lastRows π)) (lastRows π).length) [] M' ν K' PRE_fd_x4_L7_r0.s21
        ⟨PRE_fd_x4_L7_r0.S21.tab, []⟩ t' C' ∧
      Disp.KpJ (FDX4L7Frames.typedJ (tokenBytes (lastRows π)) (lastRows π).length) 131072 K' ∧
      K'.fr = (g1Framed K π).fr ∧ K'.D = K.D ∧ K'.lo = K.lo ∧ K'.hi = K.hi ∧
      (∃ asR ret tr, K'.base' =
        ⟨chars!"mlx_array_new_data", .jsPtr (M'.a FDX4L7Frames.buffer) 0 (tokenBytes (lastRows π)) :: asR, ret⟩ :: tr) ∧ InputAt (lastRows π) (M'.node 19265) t' C' ∧
      Host.Mlx.Ffi.NGrow (mlxOf t.ffi) (mlxOf t'.ffi) := by
  have hlenN : (lastRows π).length = 1 := lastRows_length h1
  have rr1 : runOk FF PRE_fd_x4_L7_r0.okB1 72 PRE_fd_x4_L7_r0.s2 PRE_fd_x4_L7_r0.S2 =
      some (PRE_fd_x4_L7_r0.s3, PRE_fd_x4_L7_r0.S3) := PRE_fd_x4_L7_r0.k2
  obtain ⟨M3, t3, C3, r13, e13, h3⟩ := D1Advance.call (startSim NB T tk []) hk hvb hg.s19 accepted2 rr1
    (runOk_ok_end 71 rr1 live3) live3 PRE_fd_x4_L7_r0.stepA2 top4 hr
  let K1 := Disp.Ctx.frameAt K FDX4L7Frames.chunk ([], (lastRows π).map natV)
  have hk1 : Disp.KpJ FDX4L7Frames.chunkJ 131072 K1 :=
    FDX4L7Frames.kp_frame (J := FDX4L7Frames.startJ) (J' := FDX4L7Frames.chunkJ) rfl rfl rfl hk ([], (lastRows π).map natV)
  have hf1 : K1.fr FDX4L7Frames.chunk = some ([], (lastRows π).map natV) := Disp.Ctx.frameAt_eq K _ _
  have ng13 := glueCall_ngrow (fun y0 => startGrowSim NB T tk [] y0) accepted2 rr1
    (runOk_ok_end 71 rr1 live3) live3 PRE_fd_x4_L7_r0.stepA2 hvb hk (hr.withOracle hg.s19) r13
  obtain ⟨r34, h4⟩ := slice h3 hfr h1 h53 hv9 hv10
  have rr4 : runOk FF PRE_fd_x4_L7_r0.okB2 15 PRE_fd_x4_L7_r0.s5 PRE_fd_x4_L7_r0.S5 =
      some (PRE_fd_x4_L7_r0.s6, PRE_fd_x4_L7_r0.S6) := PRE_fd_x4_L7_r0.k5
  obtain ⟨M6, t6, C6, r46, e46, h6⟩ := D1Advance.call (chunkSim NB T tk []) hk1 hvb hg.s22
    accepted5 rr4 accepted6 live6 PRE_fd_x4_L7_r0.stepA3 top7 h4
  have ng46 := glueCall_ngrow (fun y0 => chunkGrowSim NB T tk [] y0) accepted5 rr4 accepted6 live6
    PRE_fd_x4_L7_r0.stepA3 hvb hk1 (h4.withOracle hg.s22) r46
  obtain ⟨M7, t7, r67, e67, h7, ffi7⟩ := length7 h6 hf1 hlenN
  have rr7 : runOk FF PRE_fd_x4_L7_r0.okB3 18 PRE_fd_x4_L7_r0.s8 PRE_fd_x4_L7_r0.S8 =
      some (PRE_fd_x4_L7_r0.s9, PRE_fd_x4_L7_r0.S9) := PRE_fd_x4_L7_r0.k8
  obtain ⟨M9, t9, C9, r79, e79, h9⟩ := D1Advance.call (chunkSim NB T tk []) hk1 hvb hg.s25
    accepted8 rr7 accepted9 live9 PRE_fd_x4_L7_r0.stepA4 top10 h7
  have ng79 := glueCall_ngrow (fun y0 => chunkGrowSim NB T tk [] y0) accepted8 rr7 accepted9 live9
    PRE_fd_x4_L7_r0.stepA4 hvb hk1 (h7.withOracle hg.s25) r79
  obtain ⟨r910, h10⟩ := typed h9 hf1
  let K2 := Disp.typedK K1 FDX4L7Frames.buffer
  have hk2 := typedContext (tokenBytes (lastRows π)) (lastRows π).length hk1
  have hfb : K2.fr FDX4L7Frames.buffer = some ([], []) :=
    (Disp.Ctx.frameAt_ne _ _ (by decide)).trans (Disp.Ctx.frameAt_eq _ _ _)
  have hfv : K2.fr FDX4L7Frames.view = some ([], []) := Disp.Ctx.frameAt_eq _ _ _
  have hfc : K2.fr FDX4L7Frames.chunk = some ([], (lastRows π).map natV) :=
    (Disp.Ctx.frameAt_ne _ _ (by decide)).trans ((Disp.Ctx.frameAt_ne _ _ (by decide)).trans hf1)
  obtain ⟨M12, t12, C12, r1012, e1012, h12⟩ :=
    D1Advance.call (typedSim NB T tk (tokenBytes (lastRows π)) (lastRows π).length []) hk2 hvb hg.s28
      (congrFun (congrFun typedAccepted11 _) _) (congrFun (congrFun typedRun11 _) _) (congrFun (congrFun typedAccepted12 _) _) live12
      PRE_fd_x4_L7_r0.stepA5 top13 h10
  have ng1012 := glueCall_ngrow (typedGrowSimAt NB T tk (tokenBytes (lastRows π)) (lastRows π).length 131072 [])
    (congrFun (congrFun typedAccepted11 _) _) (congrFun (congrFun typedRun11 _) _) (congrFun (congrFun typedAccepted12 _) _) live12
    PRE_fd_x4_L7_r0.stepA5 hvb hk2 (h10.withOracle hg.s28) r1012
  obtain ⟨r1213, h13⟩ := ptr h12 hfv hfb (by rw [hlenN]; decide)
  obtain ⟨M15, t15, C15, r1315, e1315, h15⟩ :=
    D1Advance.call (typedSim NB T tk (tokenBytes (lastRows π)) (lastRows π).length []) hk2 hvb hg.s31
      (congrFun (congrFun typedAccepted14 _) _) (congrFun (congrFun typedRun14 _) _) (congrFun (congrFun typedAccepted15 _) _) live15
      PRE_fd_x4_L7_r0.stepA6 top16 h13
  have ng1315 := glueCall_ngrow (typedGrowSimAt NB T tk (tokenBytes (lastRows π)) (lastRows π).length 131072 [])
    (congrFun (congrFun typedAccepted14 _) _) (congrFun (congrFun typedRun14 _) _) (congrFun (congrFun typedAccepted15 _) _) live15
    PRE_fd_x4_L7_r0.stepA6 hvb hk2 (h13.withOracle hg.s31) r1315
  obtain ⟨M16, t16, C16, r1516, e1516, h16, hev, ip16, ng1516⟩ := ND.step_input h15 hk2 hvb hg.s33 hi hfb
    (fun k hk => hvc k (List.mem_of_mem_drop hk)) hlenN
  let K3 : Ctx := ⟨K2.fr, PRE_fd_x4_L7_r0.s17.trace, t16.trace, K2.D, K2.lo, K2.hi⟩
  have hk3 : Disp.KpJ (FDX4L7Frames.typedJ (tokenBytes (lastRows π)) (lastRows π).length) 131072 K3 := hk2
  obtain ⟨M18, t18, C18, r1618, e1618, h18⟩ :=
    D1Advance.call (typedSim NB T tk (tokenBytes (lastRows π)) (lastRows π).length []) hk3 hvb hg.s34
      (congrFun (congrFun typedAccepted17 _) _) (congrFun (congrFun typedRun17 _) _) (congrFun (congrFun typedAccepted18 _) _) live18
      PRE_fd_x4_L7_r0.stepA7 top19 h16
  have ng1618 := glueCall_ngrow (typedGrowSimAt NB T tk (tokenBytes (lastRows π)) (lastRows π).length 131072 [])
    (congrFun (congrFun typedAccepted17 _) _) (congrFun (congrFun typedRun17 _) _)
    (congrFun (congrFun typedAccepted18 _) _) live18 PRE_fd_x4_L7_r0.stepA7 hvb hk3
    (h16.withOracle hg.s34) r1618
  have ip18 := ip16.grow ng1618 (runC_le _ _ _ _ _ r1618)
  obtain ⟨M19, t19, r1819, e1819, h19, ffi19⟩ := length19 h18 hfc hlenN
  obtain ⟨M20, t20, C20, r1920, e1920, h20⟩ :=
    D1Advance.run (typedSim NB T tk (tokenBytes (lastRows π)) (lastRows π).length []) hk3 hvb hg.s37
      (congrFun (congrFun typedAccepted20 _) _) (congrFun (congrFun typedRun20 _) _) top21 h19
  have ng1920 := glue_ngrow (typedGrowSimAt NB T tk (tokenBytes (lastRows π)) (lastRows π).length 131072 [])
    (congrFun (congrFun typedAccepted20 _) _) (congrFun (congrFun typedRun20 _) _) hvb hk3
    (h19.withOracle hg.s37) r1920
  have ip19 : InputAt (lastRows π) (M19.node 19265) t19 C18 := by
    rw [e1819.node]
    unfold InputAt
    rw [ffi19, e1618.node]
    exact ip18
  have ip20 : InputAt (lastRows π) (M20.node 19265) t20 C20 := by
    rw [e1920.node]
    exact ip19.grow ng1920 (runC_le _ _ _ _ _ r1920)
  have he := (((((((((e13.trans e46 (by decide)).trans e67 (by decide)).trans e79 (by decide)).trans
    e1012 (by decide)).trans e1315 (by decide)).trans e1516 (by decide)).trans e1618 (by decide)).trans
    e1819 (by decide)).trans e1920 (by decide))
  have rr := runC_trans (runC_trans (runC_trans (runC_trans (runC_trans (runC_trans
    (runC_trans (runC_trans (runC_trans (runC_trans (runC_trans (runC_trans r13 r34) r46) r67) r79) r910)
      r1012) r1213) r1315) r1516) r1618) r1819) r1920
  have ng67 : Host.Mlx.Ffi.NGrow (mlxOf t6.ffi) (mlxOf t7.ffi) := by
    rw [ffi7]
    exact Host.Mlx.Ffi.NGrow.refl _
  have ng1819 : Host.Mlx.Ffi.NGrow (mlxOf t18.ffi) (mlxOf t19.ffi) := by
    rw [ffi19]
    exact Host.Mlx.Ffi.NGrow.refl _
  have ng : Host.Mlx.Ffi.NGrow (mlxOf t.ffi) (mlxOf t20.ffi) :=
    ng13.trans (ng46.trans (ng67.trans (ng79.trans (ng1012.trans (ng1315.trans (ng1516.trans
      (ng1618.trans (ng1819.trans ng1920))))))))
  refine ⟨M20, t20, C20, K3, rr, he, h20, hk3, rfl, rfl, rfl, rfl, ?_, ip20, ng⟩
  obtain ⟨asR, ret, hev⟩ := hev
  refine ⟨asR, ret, t15.trace, ?_⟩
  change t16.trace = _
  rw [e1920.a, e1819.a, e1618.a, e1516.a]
  exact hev

end Host.Ts.Sim.Compose.FDX4L7
