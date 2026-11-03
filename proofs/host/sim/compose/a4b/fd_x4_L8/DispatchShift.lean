import host.sim.compose.a4b.fd_x4_L8.DispatchMerged
import host.sim.compose.a4b.fd_x4_L8.DispatchFrames
import host.sim.template.a4pre_fd_x4_L8_r0.GlueN1
import host.sim.template.a4pre_fd_x4_L8_r0.SiteD1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.FDX4L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk
noncomputable def θZ2 : Nat → SymE := Conv.compactθZ PRE_fd_x4_L8_r0.cws1
  PRE_fd_x4_L8_r0.crs1 PRE_fd_x4_L8_r0.ws1

theorem dispatchCallClean : Conv.JClean (⟨22175, 19266, 2834448, 112⟩ : Conv.Cnt) PRE_fd_x4_L8_r0.s21 :=
  PRE_fd_x4_L8_r0.gjcl1 (PRE_fd_x4_L8_r0.cjcl0 PRE_fd_x4_L8_r0.jcl0)

theorem dispatchShift {K : Ctx} {bs : List Byte} {n : Nat} {π γ : List Nat}
    (hk : Disp.Kp (FDX4L8Frames.typedJ bs n) K)
    (hframe : K.fr 2665 = some ([], π.map natV))
    (hchunk : K.fr FDX4L8Frames.chunk = some ([], γ.map natV))
    (hcall : Conv.CallFacts PRE_fd_x4_L8_r0.s21 PRE_fd_x4_L8_r0.S21.tab.length)
    (hnative : Conv.FullShiftQ PRE_fd_x4_L8_r0.P1 112 PRE_fd_x4_L8_r0.kappa1
      PRE_fd_x4_L8_r0.s23.ffi PRE_fd_x4_L8_r0.s22.ffi) :
    ShiftD FF (fun σ x y => x = PRE_fd_x4_L8_r0.s23.ffi ∧
      Conv.FullShiftQX PRE_fd_x4_L8_r0.P1 PRE_fd_x4_L8_r0.S23.tab.length σ x y)
      PRE_fd_x4_L8_r0.kappa1 θZ2 (kpOf K (compactW bs n)) (compactW bs n) K
      PRE_fd_x4_L8_r0.s23 ⟨PRE_fd_x4_L8_r0.S23.tab, []⟩
      PRE_fd_x4_L8_r0.s22 ⟨PRE_fd_x4_L8_r0.S22.tab, []⟩ := by
  have hroots := checkRootsSupp_sound (s := (PRE_fd_x4_L8_r0.s23 : St FF.S)) PRE_fd_x4_L8_r0.zroots1
  have hs := Conv.compact_shift (F := FF) (W := (compactW bs n)) (K1 := K)
    PRE_fd_x4_L8_r0.zkap1 hcall dispatchCallClean PRE_fd_x4_L8_r0.cfix1
    (fun p hp => Nat.le_of_ble_eq_true (List.all_eq_true.mp PRE_fd_x4_L8_r0.zpl1 p hp))
    (nodupT_sound PRE_fd_x4_L8_r0.zplnd1).2 (Nat.le_of_ble_eq_true PRE_fd_x4_L8_r0.zn11)
    (Nat.le_of_ble_eq_true PRE_fd_x4_L8_r0.zfirst1) PRE_fd_x4_L8_r0.zscn1 PRE_fd_x4_L8_r0.zsmn1
    (Nat.le_of_ble_eq_true PRE_fd_x4_L8_r0.zgrow1) PRE_fd_x4_L8_r0.mergeTab1
    (noVar_of_all PRE_fd_x4_L8_r0.zfresh1) (nodupT_sound PRE_fd_x4_L8_r0.zcnd1).2
    (by rfl : PRE_fd_x4_L8_r0.cws1.length = PRE_fd_x4_L8_r0.nr1.length)
    (fun r hr => Nat.blt_eq.mp (List.all_eq_true.mp PRE_fd_x4_L8_r0.znrHi1 r hr))
    hk.2.2 (by
      intro a ha
      change a < 2834448
      change a ∈ (2665 :: 4910 :: (ghostPf ++ [FDX4L8Frames.chunk, FDX4L8Frames.buffer, FDX4L8Frames.view])) at ha
      simp only [ghostPf, List.cons_append, List.nil_append, List.mem_cons, List.not_mem_nil, or_false] at ha
      rcases ha with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;> decide)
    (Xs := [2665, FDX4L8Frames.chunk]) (compactW_xs bs n) (compactW_framed bs n)
    (by
      intro a pre pre' hka hw
      have ha := (hk.2.2 a).mp (by rw [hka]; exact Option.some_ne_none _)
      have hx := (compactW_xs bs n a).mpr ⟨ha, hw⟩
      simp only [List.mem_cons, List.not_mem_nil, or_false] at hx
      rcases hx with rfl | rfl
      · rw [hframe] at hka
        cases hka
        refine ⟨_, [], PRE_fd_x4_L8_r0.zg1_2665, ?_, ?_⟩
        · simpa only [promptEmpty] using PRE_fd_x4_L8_r0.zk1_2665
        · simpa only [PRE_fd_x4_L8_r0.arrE1_2665, promptEmpty, List.length_nil, List.drop_zero, List.nil_append,
            PRE_fd_x4_L8_r0.arrEl1_2665] using PRE_fd_x4_L8_r0.zm1_2665
      · rw [hchunk] at hka
        cases hka
        exact ⟨_, [], dispatchChunkGet, dispatchChunkKind, dispatchChunkImage⟩)
    (compactW_present bs n) (compactW_fixed bs n)
    (Conv.heap_off_setAll PRE_fd_x4_L8_r0.cheap1
      (fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_fd_x4_L8_r0.zclbd1 a ha)))
    (hoff_of PRE_fd_x4_L8_r0.mheap1 PRE_fd_x4_L8_r0.stFoot1 PRE_fd_x4_L8_r0.iso1 PRE_fd_x4_L8_r0.zwr1)
    PRE_fd_x4_L8_r0.ckeepP1 PRE_fd_x4_L8_r0.csupp1 PRE_fd_x4_L8_r0.cbound1 (by
      have hx : (PRE_fd_x4_L8_r0.cl1.filter fun a => !([2665, FDX4L8Frames.chunk].contains a)) =
          PRE_fd_x4_L8_r0.zl1 := rfl
      rw [hx]
      exact PRE_fd_x4_L8_r0.zimg1)
    PRE_fd_x4_L8_r0.zctl1 PRE_fd_x4_L8_r0.zstack1 PRE_fd_x4_L8_r0.zjobs1 PRE_fd_x4_L8_r0.zstores1
    (by rw [PRE_fd_x4_L8_r0.znC1]; exact hroots.1)
    (by rw [PRE_fd_x4_L8_r0.znC1]; exact hroots.2.1)
    (by rw [PRE_fd_x4_L8_r0.znC1]; exact hroots.2.2.1)
    (by rw [PRE_fd_x4_L8_r0.znC1]; exact hroots.2.2.2)
    (Conv.bigFixed_of_mshift hnative.load.mlx hk.1 hk.2.1)
  have hs' : ShiftD FF (fun _ _ _ => True) PRE_fd_x4_L8_r0.kappa1 PRE_fd_x4_L8_r0.ctheta1
      (kpOf K (compactW bs n)) (compactW bs n) K PRE_fd_x4_L8_r0.s23 ⟨PRE_fd_x4_L8_r0.S23.tab, []⟩
      PRE_fd_x4_L8_r0.s22 ⟨PRE_fd_x4_L8_r0.S22.tab, []⟩ := by
    rw [PRE_fd_x4_L8_r0.ctab1]
    exact hs
  have hθ := hs'.retheta (θ' := θZ2) (by
    rw [PRE_fd_x4_L8_r0.ctab1]
    exact Conv.compactθZ_tab
      (noVar_of_all (by have h := PRE_fd_x4_L8_r0.fresh1; simp only [Bool.and_eq_true] at h; exact h.1))
      (disj_of_all PRE_fd_x4_L8_r0.cwsDisj1))
  exact { hθ with ffi := ⟨rfl, by
    rw [PRE_fd_x4_L8_r0.ctab1]
    change Conv.FullShiftQX PRE_fd_x4_L8_r0.P1 112 PRE_fd_x4_L8_r0.kappa1 _ _
    exact hnative.toX PRE_fd_x4_L8_r0.zbin1⟩ }


end Host.Ts.Sim.Compose.FDX4L8
