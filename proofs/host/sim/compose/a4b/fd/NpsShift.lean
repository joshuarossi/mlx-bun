import host.sim.compose.a4b.fd.NpsMerged
import host.sim.template.a4pre_fd_vw_r0.GlueN0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.FDVW
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk
noncomputable def θZ1 : Nat → SymE := Conv.compactθZ PRE_fd_vw_r0.cws0
  PRE_fd_vw_r0.crs0 PRE_fd_vw_r0.ws0

theorem npsCallClean : Conv.JClean (⟨18155, 15235, 2673457, 14⟩ : Conv.Cnt) PRE_fd_vw_r0.s0 := by
  apply PRE_fd_vw_r0.gjcl0
  rw [PRE_fd_vw_r0.chunk-1_eq]
  exact PRE_setup_early_r0.cjcl0 SetupChunk.callClean

theorem npsShift {K : Ctx} (hk : Disp.Kp setupJ K) {π : List Nat}
    (hframe : K.fr 2665 = some ([], π.map natV))
    (hcall : Conv.CallFacts PRE_fd_vw_r0.s0 PRE_fd_vw_r0.S0.tab.length)
    (hnative : Conv.FullShiftQ PRE_fd_vw_r0.P0 15 PRE_fd_vw_r0.kappa0
      PRE_fd_vw_r0.s2.ffi PRE_fd_vw_r0.s1.ffi) :
    ShiftD FF (fun σ x y => x = PRE_fd_vw_r0.s2.ffi ∧
      Conv.FullShiftQX PRE_fd_vw_r0.P0 PRE_fd_vw_r0.S2.tab.length σ x y)
      PRE_fd_vw_r0.kappa0 θZ1 (kpOf K noFrames) noFrames K
      PRE_fd_vw_r0.s2 ⟨PRE_fd_vw_r0.S2.tab, []⟩
      PRE_fd_vw_r0.s1 ⟨PRE_fd_vw_r0.S1.tab, []⟩ := by
  have hroots := checkRootsSupp_sound (s := (PRE_fd_vw_r0.s2 : St FF.S)) PRE_fd_vw_r0.zroots0
  have hs := Conv.compact_shift (F := FF) (W := noFrames) (K1 := K)
    PRE_fd_vw_r0.zkap0 hcall npsCallClean PRE_fd_vw_r0.cfix0
    (fun p hp => Nat.le_of_ble_eq_true (List.all_eq_true.mp PRE_fd_vw_r0.zpl0 p hp))
    (nodupT_sound PRE_fd_vw_r0.zplnd0).2 (Nat.le_of_ble_eq_true PRE_fd_vw_r0.zn10)
    (Nat.le_of_ble_eq_true PRE_fd_vw_r0.zfirst0) PRE_fd_vw_r0.zscn0 PRE_fd_vw_r0.zsmn0
    (Nat.le_of_ble_eq_true PRE_fd_vw_r0.zgrow0) PRE_fd_vw_r0.mergeTab0
    (noVar_of_all PRE_fd_vw_r0.zfresh0) (nodupT_sound PRE_fd_vw_r0.zcnd0).2
    (by rfl : PRE_fd_vw_r0.cws0.length = PRE_fd_vw_r0.nr0.length)
    (fun r hr => Nat.blt_eq.mp (List.all_eq_true.mp PRE_fd_vw_r0.znrHi0 r hr))
    hk.2.2 (fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_fd_vw_r0.zfrlt0 a ha))
    (Xs := [2665]) (by intro a; simp [noFrames]) (by intro a w hw; cases hw)
    (by
      intro a pre pre' hka _
      have ha := (hk.2.2 a).mp (by rw [hka]; exact Option.some_ne_none _)
      change a ∈ [2665] at ha
      simp only [List.mem_singleton] at ha
      subst ha
      rw [hframe] at hka
      cases hka
      refine ⟨_, arrOf PRE_fd_vw_r0.s1 2665, PRE_fd_vw_r0.zg1_2665, ?_, ?_⟩
      · rw [PRE_fd_vw_r0.zk1_2665, npsPromptEmpty]
      · simpa only [npsPromptEmpty, List.length_nil, List.drop_zero, List.nil_append] using
          PRE_fd_vw_r0.zm1_2665)
    (by intro a w hw; cases hw) (by intro a w hw; cases hw)
    (Conv.heap_off_setAll PRE_fd_vw_r0.cheap0
      (fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_fd_vw_r0.zclbd0 a ha)))
    (hoff_of PRE_fd_vw_r0.mheap0 PRE_fd_vw_r0.stFoot0 PRE_fd_vw_r0.iso0 PRE_fd_vw_r0.zwr0)
    PRE_fd_vw_r0.ckeepP0 PRE_fd_vw_r0.csupp0 PRE_fd_vw_r0.cbound0 PRE_fd_vw_r0.zimg0
    PRE_fd_vw_r0.zctl0 PRE_fd_vw_r0.zstack0 PRE_fd_vw_r0.zjobs0 PRE_fd_vw_r0.zstores0
    (by rw [PRE_fd_vw_r0.znC0]; exact hroots.1)
    (by rw [PRE_fd_vw_r0.znC0]; exact hroots.2.1)
    (by rw [PRE_fd_vw_r0.znC0]; exact hroots.2.2.1)
    (by rw [PRE_fd_vw_r0.znC0]; exact hroots.2.2.2)
    (Conv.bigFixed_of_mshift hnative.load.mlx hk.1 hk.2.1)
  have hs' : ShiftD FF (fun _ _ _ => True) PRE_fd_vw_r0.kappa0 PRE_fd_vw_r0.ctheta0
      (kpOf K noFrames) noFrames K PRE_fd_vw_r0.s2 ⟨PRE_fd_vw_r0.S2.tab, []⟩
      PRE_fd_vw_r0.s1 ⟨PRE_fd_vw_r0.S1.tab, []⟩ := by
    rw [PRE_fd_vw_r0.ctab0]
    exact hs
  have hθ := hs'.retheta (θ' := θZ1) (by
    rw [PRE_fd_vw_r0.ctab0]
    exact Conv.compactθZ_tab
      (noVar_of_all (by have h := PRE_fd_vw_r0.fresh0; simp only [Bool.and_eq_true] at h; exact h.1))
      (disj_of_all npsCwsDisjoint))
  exact { hθ with ffi := ⟨rfl, by
    rw [PRE_fd_vw_r0.ctab0]
    change Conv.FullShiftQX PRE_fd_vw_r0.P0 15 PRE_fd_vw_r0.kappa0 _ _
    exact hnative.toX PRE_fd_vw_r0.zbin0⟩ }


end Host.Ts.Sim.Compose.FDVW
