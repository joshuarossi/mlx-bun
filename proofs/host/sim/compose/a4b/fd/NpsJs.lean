import host.sim.compose.a4b.fd.NpsShift
import host.sim.conv.CompactJs
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.FDVW
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Load.Run.Tpl Host.Ts.Sim.Compose.SetupChunk

def npsJsChanged : List Nat := PRE_fd_vw_r0.gjh0 ++ PRE_fd_vw_r0.cl0
kernel_rfl npsJsChangedOk : npsJsChanged.all
  (noBigAtP (jsShiftBadB PRE_fd_vw_r0.kappa0) PRE_fd_vw_r0.s2) = true
kernel_rfl npsJsRoots : noBigRootsP (jsShiftBadB PRE_fd_vw_r0.kappa0)
  PRE_fd_vw_r0.s2.trace PRE_fd_vw_r0.s2 = true
kernel_rfl npsJsNative : bigsOutB jsLoN jsHiN (mlxOf PRE_fd_vw_r0.s2.ffi) = true

theorem npsJsBad_sub {i : Int} (h : jsShiftBadB PRE_fd_vw_r0.kappa0 i = true) :
    jsShiftBadB PRE_setup_early_r0.kappa0 i = true := by
  cases hp : jsPtrOf i with
  | none => simp only [jsShiftBadB, hp] at h; cases h
  | some p =>
    obtain ⟨b, off⟩ := p
    obtain ⟨he, hb, _⟩ := jsPtrOf_some hp
    have hlow : 2673457 ≤ b := by
      by_contra hn
      have ha : PRE_fd_vw_r0.kappa0.a b = b := by
        rw [PRE_fd_vw_r0.zkap0]
        exact Conv.Map.compact_lt (by change b < 2673457; omega)
      have hi : PRE_fd_vw_r0.kappa0.big i = i := by
        rw [PRE_fd_vw_r0.zkap0]
        exact Conv.rdata_big_js PRE_fd_vw_r0.kd0 i (by rw [hp]; exact Option.some_ne_none _)
      unfold jsShiftBadB at h
      simp only [hp] at h
      rw [ha, hi, he] at h
      simp only [decide_true, Nat.blt_eq.mpr hb, Bool.and_self, Bool.not_true] at h
      cases h
    rw [PRE_setup_early_r0.zkap0]
    change jsShiftBadB (Conv.Map.compact PRE_setup_early_r0.s4.next 2673349
      PRE_setup_early_r0.S4.tab.length [] (PRE_setup_early_r0.nr0.map NumV.ref)
      PRE_setup_early_r0.kd0.big PRE_setup_early_r0.kd0.region PRE_setup_early_r0.kd0.nodeF) i = true
    rw [Conv.jsShiftBadB_compact_nil (by decide) (Conv.rdata_big_js PRE_setup_early_r0.kd0), hp]
    apply decide_eq_true_eq.mpr
    change 2673336 ≤ b
    omega

/-- Reuse the checked initial JS heap, checking only the two finite changed lists. -/
theorem npsJsFree {I : Int → Prop}
    (hp : ∀ i, I i → jsShiftBadB PRE_fd_vw_r0.kappa0 i = true) :
    NoBigSt I PRE_fd_vw_r0.s2.trace PRE_fd_vw_r0.s2 := by
  have hs := npsJsRoots
  simp only [noBigRootsP, Bool.and_eq_true, List.all_eq_true] at hs
  refine ⟨?_, noBigCtlP_sound hp hs.1.1.1.1,
    fun f hf => noBigFrameP_sound hp (hs.1.1.1.2 f hf),
    fun j hj => noBigJobP_sound hp (hs.1.1.2 j hj), noBigStoresP_sound hp hs.1.2,
    fun e he => noBigEventP_sound hp (hs.2 e he)⟩
  intro a o ho
  by_cases ha : a ∈ npsJsChanged
  · have hc := List.all_eq_true.mp npsJsChangedOk a ha
    unfold noBigAtP at hc
    rw [ho] at hc
    exact noBigHobjP_sound hp hc
  · have hcl : a ∉ PRE_fd_vw_r0.cl0 := fun h => ha (List.mem_append_right _ h)
    have hgl : a ∉ PRE_fd_vw_r0.gjh0 := fun h => ha (List.mem_append_left _ h)
    have h19 := Conv.heap_off_setAll PRE_fd_vw_r0.cheap0
      (fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_fd_vw_r0.zclbd0 b hb)) a hcl
    have h17 := Conv.heap_off_setAll PRE_fd_vw_r0.gjk0
      (fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_fd_vw_r0.gjbd0 b hb)) a hgl
    have h6 : PRE_setup_early_r0.s6.heap.get a = some o := by
      rw [← PRE_fd_vw_r0.chunk-1_eq]
      exact h17.symm.trans (h19.symm.trans ho)
    have hc := SetupChunk.canonicalJsHeap a (by unfold Present; rw [h6]; rfl)
    unfold noBigAtP at hc
    rw [h6] at hc
    exact noBigHobjP_sound (fun i hi => npsJsBad_sub (hp i hi)) hc
end Host.Ts.Sim.Compose.FDVW
