import host.sim.compose.a4b.x0.NpsMerged
import host.sim.template.a4pre_first_tail_x0_r0.GlueN1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk
noncomputable def θZ1 : Nat → SymE := Conv.compactθZ PRE_first_tail_x0_r0.cws1
  PRE_first_tail_x0_r0.crs1 PRE_first_tail_x0_r0.ws1

theorem npsCallClean : Conv.JClean (⟨18155, 15235, 2673457, 14⟩ : Conv.Cnt) PRE_first_tail_x0_r0.s17 := by
  apply PRE_first_tail_x0_r0.gjcl1
  rw [chunk0_eq]
  exact PRE_setup_early_r0.cjcl0 SetupChunk.callClean

theorem npsShift {K : Ctx} (hk : Disp.Kp setupJ K) {π : List Nat}
    (hframe : K.fr 2665 = some ([], π.map natV))
    (hcall : Conv.CallFacts PRE_first_tail_x0_r0.s17 PRE_first_tail_x0_r0.S17.tab.length)
    (hnative : Conv.FullShiftQ PRE_first_tail_x0_r0.P1 15 PRE_first_tail_x0_r0.kappa1
      PRE_first_tail_x0_r0.s19.ffi PRE_first_tail_x0_r0.s18.ffi) :
    ShiftD FF (fun σ x y => x = PRE_first_tail_x0_r0.s19.ffi ∧
      Conv.FullShiftQX PRE_first_tail_x0_r0.P1 PRE_first_tail_x0_r0.S19.tab.length σ x y)
      PRE_first_tail_x0_r0.kappa1 θZ1 (kpOf K noFrames) noFrames K
      PRE_first_tail_x0_r0.s19 ⟨PRE_first_tail_x0_r0.S19.tab, []⟩
      PRE_first_tail_x0_r0.s18 ⟨PRE_first_tail_x0_r0.S18.tab, []⟩ := by
  have hroots := checkRootsSupp_sound (s := (PRE_first_tail_x0_r0.s19 : St FF.S)) PRE_first_tail_x0_r0.zroots1
  have hs := Conv.compact_shift (F := FF) (W := noFrames) (K1 := K)
    PRE_first_tail_x0_r0.zkap1 hcall npsCallClean PRE_first_tail_x0_r0.cfix1
    (fun p hp => Nat.le_of_ble_eq_true (List.all_eq_true.mp PRE_first_tail_x0_r0.zpl1 p hp))
    (nodupT_sound PRE_first_tail_x0_r0.zplnd1).2 (Nat.le_of_ble_eq_true PRE_first_tail_x0_r0.zn11)
    (Nat.le_of_ble_eq_true PRE_first_tail_x0_r0.zfirst1) PRE_first_tail_x0_r0.zscn1 PRE_first_tail_x0_r0.zsmn1
    (Nat.le_of_ble_eq_true PRE_first_tail_x0_r0.zgrow1) PRE_first_tail_x0_r0.mergeTab1
    (noVar_of_all PRE_first_tail_x0_r0.zfresh1) (nodupT_sound PRE_first_tail_x0_r0.zcnd1).2
    (by rfl : PRE_first_tail_x0_r0.cws1.length = PRE_first_tail_x0_r0.nr1.length)
    (fun r hr => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x0_r0.znrHi1 r hr))
    hk.2.2 (fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x0_r0.zfrlt1 a ha))
    (Xs := [2665]) (by intro a; simp [noFrames]) (by intro a w hw; cases hw)
    (by
      intro a pre pre' hka _
      have ha := (hk.2.2 a).mp (by rw [hka]; exact Option.some_ne_none _)
      change a ∈ [2665] at ha
      simp only [List.mem_singleton] at ha
      subst ha
      rw [hframe] at hka
      cases hka
      refine ⟨_, arrOf PRE_first_tail_x0_r0.s18 2665, PRE_first_tail_x0_r0.zg1_2665, ?_, ?_⟩
      · rw [PRE_first_tail_x0_r0.zk1_2665, npsPromptEmpty]
      · simpa only [npsPromptEmpty, List.length_nil, List.drop_zero, List.nil_append] using
          PRE_first_tail_x0_r0.zm1_2665)
    (by intro a w hw; cases hw) (by intro a w hw; cases hw)
    (Conv.heap_off_setAll PRE_first_tail_x0_r0.cheap1
      (fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x0_r0.zclbd1 a ha)))
    (hoff_of PRE_first_tail_x0_r0.mheap1 PRE_first_tail_x0_r0.stFoot1 PRE_first_tail_x0_r0.iso1 PRE_first_tail_x0_r0.zwr1)
    PRE_first_tail_x0_r0.ckeepP1 PRE_first_tail_x0_r0.csupp1 PRE_first_tail_x0_r0.cbound1 PRE_first_tail_x0_r0.zimg1
    PRE_first_tail_x0_r0.zctl1 PRE_first_tail_x0_r0.zstack1 PRE_first_tail_x0_r0.zjobs1 PRE_first_tail_x0_r0.zstores1
    (by rw [PRE_first_tail_x0_r0.znC1]; exact hroots.1)
    (by rw [PRE_first_tail_x0_r0.znC1]; exact hroots.2.1)
    (by rw [PRE_first_tail_x0_r0.znC1]; exact hroots.2.2.1)
    (by rw [PRE_first_tail_x0_r0.znC1]; exact hroots.2.2.2)
    (Conv.bigFixed_of_mshift hnative.load.mlx hk.1 hk.2.1)
  have hs' : ShiftD FF (fun _ _ _ => True) PRE_first_tail_x0_r0.kappa1 PRE_first_tail_x0_r0.ctheta1
      (kpOf K noFrames) noFrames K PRE_first_tail_x0_r0.s19 ⟨PRE_first_tail_x0_r0.S19.tab, []⟩
      PRE_first_tail_x0_r0.s18 ⟨PRE_first_tail_x0_r0.S18.tab, []⟩ := by
    rw [PRE_first_tail_x0_r0.ctab1]
    exact hs
  have hθ := hs'.retheta (θ' := θZ1) (by
    rw [PRE_first_tail_x0_r0.ctab1]
    exact Conv.compactθZ_tab
      (noVar_of_all (by have h := PRE_first_tail_x0_r0.fresh1; simp only [Bool.and_eq_true] at h; exact h.1))
      (disj_of_all npsCwsDisjoint))
  exact { hθ with ffi := ⟨rfl, by
    rw [PRE_first_tail_x0_r0.ctab1]
    change Conv.FullShiftQX PRE_first_tail_x0_r0.P1 15 PRE_first_tail_x0_r0.kappa1 _ _
    exact hnative.toX PRE_first_tail_x0_r0.zbin1⟩ }


end Host.Ts.Sim.Compose.VWFirst.X0
