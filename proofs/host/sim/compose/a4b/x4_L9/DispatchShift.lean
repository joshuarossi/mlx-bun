import host.sim.compose.a4b.x4_L9.DispatchMerged
import host.sim.compose.a4b.x4_L9.DispatchFrames
import host.sim.template.a4pre_first_tail_x4_L9_r0.GlueN2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk
noncomputable def θZ2 : Nat → SymE := Conv.compactθZ PRE_first_tail_x4_L9_r0.cws2
  PRE_first_tail_x4_L9_r0.crs2 PRE_first_tail_x4_L9_r0.ws2

kernel_rfl s17Eq : PRE_first_tail_x4_L9_r0.s17 = PRE_first_tail_x15_r0.s17

theorem dispatchCallClean : Conv.JClean (⟨18156, 15236, 2673488, 15⟩ : Conv.Cnt) PRE_first_tail_x4_L9_r0.s38 :=
  PRE_first_tail_x4_L9_r0.gjcl2 (PRE_first_tail_x4_L9_r0.cjcl1 (by rw [s17Eq]; exact VWFirst.npsCallClean))

theorem dispatchShift {K : Ctx} {bs : List Byte} {n : Nat} {π γ : List Nat}
    (hk : Disp.Kp (VWFrames.typedJ bs n) K)
    (hframe : K.fr 2665 = some ([], π.map natV))
    (hchunk : K.fr VWFrames.chunk = some ([], γ.map natV))
    (hcall : Conv.CallFacts PRE_first_tail_x4_L9_r0.s38 PRE_first_tail_x4_L9_r0.S38.tab.length)
    (hnative : Conv.FullShiftQ PRE_first_tail_x4_L9_r0.P2 15 PRE_first_tail_x4_L9_r0.kappa2
      PRE_first_tail_x4_L9_r0.s40.ffi PRE_first_tail_x4_L9_r0.s39.ffi) :
    ShiftD FF (fun σ x y => x = PRE_first_tail_x4_L9_r0.s40.ffi ∧
      Conv.FullShiftQX PRE_first_tail_x4_L9_r0.P2 PRE_first_tail_x4_L9_r0.S40.tab.length σ x y)
      PRE_first_tail_x4_L9_r0.kappa2 θZ2 (kpOf K (compactW bs n)) (compactW bs n) K
      PRE_first_tail_x4_L9_r0.s40 ⟨PRE_first_tail_x4_L9_r0.S40.tab, []⟩
      PRE_first_tail_x4_L9_r0.s39 ⟨PRE_first_tail_x4_L9_r0.S39.tab, []⟩ := by
  have hroots := checkRootsSupp_sound (s := (PRE_first_tail_x4_L9_r0.s40 : St FF.S)) PRE_first_tail_x4_L9_r0.zroots2
  have hs := Conv.compact_shift (F := FF) (W := (compactW bs n)) (K1 := K)
    PRE_first_tail_x4_L9_r0.zkap2 hcall dispatchCallClean PRE_first_tail_x4_L9_r0.cfix2
    (fun p hp => Nat.le_of_ble_eq_true (List.all_eq_true.mp PRE_first_tail_x4_L9_r0.zpl2 p hp))
    (nodupT_sound PRE_first_tail_x4_L9_r0.zplnd2).2 (Nat.le_of_ble_eq_true PRE_first_tail_x4_L9_r0.zn12)
    (Nat.le_of_ble_eq_true PRE_first_tail_x4_L9_r0.zfirst2) PRE_first_tail_x4_L9_r0.zscn2 PRE_first_tail_x4_L9_r0.zsmn2
    (Nat.le_of_ble_eq_true PRE_first_tail_x4_L9_r0.zgrow2) PRE_first_tail_x4_L9_r0.mergeTab2
    (noVar_of_all PRE_first_tail_x4_L9_r0.zfresh2) (nodupT_sound PRE_first_tail_x4_L9_r0.zcnd2).2
    (by rfl : PRE_first_tail_x4_L9_r0.cws2.length = PRE_first_tail_x4_L9_r0.nr2.length)
    (fun r hr => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x4_L9_r0.znrHi2 r hr))
    hk.2.2 (by
      intro a ha
      change a < 2673488
      change a ∈ [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view] at ha
      simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
      rcases ha with rfl | rfl | rfl | rfl <;> decide)
    (Xs := [2665, VWFrames.chunk]) (compactW_xs bs n) (compactW_framed bs n)
    (by
      intro a pre pre' hka hw
      have ha := (hk.2.2 a).mp (by rw [hka]; exact Option.some_ne_none _)
      have hx := (compactW_xs bs n a).mpr ⟨ha, hw⟩
      simp only [List.mem_cons, List.not_mem_nil, or_false] at hx
      rcases hx with rfl | rfl
      · rw [hframe] at hka
        cases hka
        refine ⟨_, [], PRE_first_tail_x4_L9_r0.zg2_2665, ?_, ?_⟩
        · simpa only [npsPromptEmpty] using PRE_first_tail_x4_L9_r0.zk2_2665
        · simpa only [PRE_first_tail_x4_L9_r0.arrE2_2665, npsPromptEmpty, List.length_nil, List.drop_zero, List.nil_append,
            PRE_first_tail_x4_L9_r0.arrEl2_2665] using PRE_first_tail_x4_L9_r0.zm2_2665
      · rw [hchunk] at hka
        cases hka
        exact ⟨_, [], dispatchChunkGet, dispatchChunkKind, dispatchChunkImage⟩)
    (compactW_present bs n) (compactW_fixed bs n)
    (Conv.heap_off_setAll PRE_first_tail_x4_L9_r0.cheap2
      (fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x4_L9_r0.zclbd2 a ha)))
    (hoff_of PRE_first_tail_x4_L9_r0.mheap2 PRE_first_tail_x4_L9_r0.stFoot2 PRE_first_tail_x4_L9_r0.iso2 PRE_first_tail_x4_L9_r0.zwr2)
    PRE_first_tail_x4_L9_r0.ckeepP2 PRE_first_tail_x4_L9_r0.csupp2 PRE_first_tail_x4_L9_r0.cbound2 (by
      have hx : (PRE_first_tail_x4_L9_r0.cl2.filter fun a => !([2665, VWFrames.chunk].contains a)) =
          PRE_first_tail_x4_L9_r0.zl2 := rfl
      rw [hx]
      exact PRE_first_tail_x4_L9_r0.zimg2)
    PRE_first_tail_x4_L9_r0.zctl2 PRE_first_tail_x4_L9_r0.zstack2 PRE_first_tail_x4_L9_r0.zjobs2 PRE_first_tail_x4_L9_r0.zstores2
    (by rw [PRE_first_tail_x4_L9_r0.znC2]; exact hroots.1)
    (by rw [PRE_first_tail_x4_L9_r0.znC2]; exact hroots.2.1)
    (by rw [PRE_first_tail_x4_L9_r0.znC2]; exact hroots.2.2.1)
    (by rw [PRE_first_tail_x4_L9_r0.znC2]; exact hroots.2.2.2)
    (Conv.bigFixed_of_mshift hnative.load.mlx hk.1 hk.2.1)
  have hs' : ShiftD FF (fun _ _ _ => True) PRE_first_tail_x4_L9_r0.kappa2 PRE_first_tail_x4_L9_r0.ctheta2
      (kpOf K (compactW bs n)) (compactW bs n) K PRE_first_tail_x4_L9_r0.s40 ⟨PRE_first_tail_x4_L9_r0.S40.tab, []⟩
      PRE_first_tail_x4_L9_r0.s39 ⟨PRE_first_tail_x4_L9_r0.S39.tab, []⟩ := by
    rw [PRE_first_tail_x4_L9_r0.ctab2]
    exact hs
  have hθ := hs'.retheta (θ' := θZ2) (by
    rw [PRE_first_tail_x4_L9_r0.ctab2]
    exact Conv.compactθZ_tab
      (noVar_of_all (by have h := PRE_first_tail_x4_L9_r0.fresh2; simp only [Bool.and_eq_true] at h; exact h.1))
      (disj_of_all (by decide : PRE_first_tail_x4_L9_r0.cws2.all
        (fun c => !PRE_first_tail_x4_L9_r0.ws2.contains c) = true)))
  exact { hθ with ffi := ⟨rfl, by
    rw [PRE_first_tail_x4_L9_r0.ctab2]
    change Conv.FullShiftQX PRE_first_tail_x4_L9_r0.P2 15 PRE_first_tail_x4_L9_r0.kappa2 _ _
    exact hnative.toX PRE_first_tail_x4_L9_r0.zbin2⟩ }


end Host.Ts.Sim.Compose.VWFirst.X4_L9
