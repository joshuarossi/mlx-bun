import host.sim.compose.a4b.x1.DispatchShift
import host.sim.conv.CompactJs
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Load.Run.Tpl Host.Ts.Sim.Compose.SetupChunk

def dispatchJsChanged : List Nat := PRE_first_tail_x1_r0.gjh2 ++ PRE_first_tail_x1_r0.cl2
kernel_rfl dispatchJsChangedOk : dispatchJsChanged.all
  (noBigAtP (jsShiftBadB PRE_first_tail_x1_r0.kappa2) PRE_first_tail_x1_r0.s40) = true
kernel_rfl dispatchJsRoots : noBigRootsP (jsShiftBadB PRE_first_tail_x1_r0.kappa2)
  PRE_first_tail_x1_r0.s40.trace PRE_first_tail_x1_r0.s40 = true
kernel_rfl dispatchJsNative : bigsOutB jsLoN jsHiN (mlxOf PRE_first_tail_x1_r0.s40.ffi) = true

theorem dispatchJsBad_sub {i : Int} (h : jsShiftBadB PRE_first_tail_x1_r0.kappa2 i = true) :
    jsShiftBadB PRE_first_tail_x15_r0.kappa1 i = true := by
  cases hp : jsPtrOf i with
  | none => simp only [jsShiftBadB, hp] at h; cases h
  | some p =>
    obtain ⟨b, off⟩ := p
    obtain ⟨he, hb, _⟩ := jsPtrOf_some hp
    have hlow : 2673488 ≤ b := by
      by_contra hn
      have ha : PRE_first_tail_x1_r0.kappa2.a b = b := by
        rw [PRE_first_tail_x1_r0.zkap2]
        exact Conv.Map.compact_lt (by change b < 2673488; omega)
      have hi : PRE_first_tail_x1_r0.kappa2.big i = i := by
        rw [PRE_first_tail_x1_r0.zkap2]
        exact Conv.rdata_big_js PRE_first_tail_x1_r0.kd2 i (by rw [hp]; exact Option.some_ne_none _)
      unfold jsShiftBadB at h
      simp only [hp] at h
      rw [ha, hi, he] at h
      simp only [decide_true, Nat.blt_eq.mpr hb, Bool.and_self, Bool.not_true] at h
      cases h
    have ha : PRE_first_tail_x15_r0.kappa1.a b = 2673472 + (b - 2673458) := by
      have eb : b = PRE_first_tail_x15_r0.s17.next + PRE_first_tail_x15_r0.pl1.length + (b - 2673458) := by
        change b = 2673457 + 1 + (b - 2673458)
        omega
      calc
        PRE_first_tail_x15_r0.kappa1.a b = PRE_first_tail_x15_r0.kappa1.a
            (PRE_first_tail_x15_r0.s17.next + PRE_first_tail_x15_r0.pl1.length + (b - 2673458)) :=
          congrArg PRE_first_tail_x15_r0.kappa1.a eb
        _ = 2673472 + (b - 2673458) := by
          rw [PRE_first_tail_x15_r0.zkap1]
          exact Conv.Map.compact_next (b - 2673458)
    have hbig : PRE_first_tail_x15_r0.kappa1.big i = i := by
      rw [PRE_first_tail_x15_r0.zkap1]
      exact Conv.rdata_big_js PRE_first_tail_x15_r0.kd1 i (by rw [hp]; exact Option.some_ne_none _)
    have hne : i ≠ ptrInt (.js (2673472 + (b - 2673458))) off := by
      rw [he]
      simp only [ptrInt_js, jsBase, jsOff]
      omega
    unfold jsShiftBadB
    simp only [hp, ha, hbig, hne, decide_false, Bool.false_and, Bool.not_false]

/-- Reuse the checked initial JS heap, checking only the two finite changed lists. -/
theorem dispatchJsFree {I : Int → Prop}
    (hp : ∀ i, I i → jsShiftBadB PRE_first_tail_x1_r0.kappa2 i = true) :
    NoBigSt I PRE_first_tail_x1_r0.s40.trace PRE_first_tail_x1_r0.s40 := by
  have hs := dispatchJsRoots
  simp only [noBigRootsP, Bool.and_eq_true, List.all_eq_true] at hs
  refine ⟨?_, noBigCtlP_sound hp hs.1.1.1.1,
    fun f hf => noBigFrameP_sound hp (hs.1.1.1.2 f hf),
    fun j hj => noBigJobP_sound hp (hs.1.1.2 j hj), noBigStoresP_sound hp hs.1.2,
    fun e he => noBigEventP_sound hp (hs.2 e he)⟩
  intro a o ho
  by_cases ha : a ∈ dispatchJsChanged
  · have hc := List.all_eq_true.mp dispatchJsChangedOk a ha
    unfold noBigAtP at hc
    rw [ho] at hc
    exact noBigHobjP_sound hp hc
  · have hcl : a ∉ PRE_first_tail_x1_r0.cl2 := fun h => ha (List.mem_append_right _ h)
    have hgl : a ∉ PRE_first_tail_x1_r0.gjh2 := fun h => ha (List.mem_append_left _ h)
    have h19 := Conv.heap_off_setAll PRE_first_tail_x1_r0.cheap2
      (fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x1_r0.zclbd2 b hb)) a hcl
    have h17 := Conv.heap_off_setAll PRE_first_tail_x1_r0.gjk2
      (fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x1_r0.gjbd2 b hb)) a hgl
    have h19 : PRE_first_tail_x15_r0.s19.heap.get a = some o := by
      rw [← s19Eq]
      exact h17.symm.trans (h19.symm.trans ho)
    exact (npsJsFree (fun i hi => dispatchJsBad_sub (hp i hi))).1 a o h19

end Host.Ts.Sim.Compose.VWFirst.X1
