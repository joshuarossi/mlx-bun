import host.sim.compose.a4b.fd.DispatchShift
import host.sim.conv.CompactJs
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.FDVW
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Load.Run.Tpl Host.Ts.Sim.Compose.SetupChunk

kernel_rfl jsList21 : PRE_fd_vw_r0.gjh1.all (noBigAtP (jsAboveB 2674370) PRE_fd_vw_r0.s21) = true
kernel_rfl jsList23 : PRE_fd_vw_r0.cl1.all (noBigAtP (jsAboveB 2674370) PRE_fd_vw_r0.s23) = true
kernel_rfl jsRoots23 : noBigRootsP (jsAboveB 2674370) PRE_fd_vw_r0.s23.trace PRE_fd_vw_r0.s23 = true
kernel_rfl dispatchJsNative : bigsOutB jsLoN jsHiN (mlxOf PRE_fd_vw_r0.s23.ffi) = true

theorem jsHeap21 : JsHeapAbove 2674370 PRE_fd_vw_r0.s21 :=
  jsHeap2.step (Nat.le_refl _) (Conv.heap_off_setAll PRE_fd_vw_r0.gjk1
    (fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_fd_vw_r0.gjbd1 a ha))) jsList21

theorem jsHeap23 : JsHeapAbove 2674370 PRE_fd_vw_r0.s23 :=
  jsHeap21.step (Nat.le_refl _) (Conv.heap_off_setAll PRE_fd_vw_r0.cheap1
    (fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_fd_vw_r0.zclbd1 a ha))) jsList23

theorem jsBad_above1 {i : Int} (h : jsShiftBadB PRE_fd_vw_r0.kappa1 i = true) : jsAboveB 2674370 i = true := by
  cases hp : jsPtrOf i with
  | none => simp only [jsShiftBadB, hp] at h; cases h
  | some p =>
    obtain ⟨b, off⟩ := p
    obtain ⟨he, hb, _⟩ := jsPtrOf_some hp
    simp only [jsAboveB, hp]
    apply Nat.ble_eq_true_of_le
    refine Nat.le_of_not_lt fun hn => ?_
    have ha : PRE_fd_vw_r0.kappa1.a b = b := by
      rw [PRE_fd_vw_r0.zkap1]
      exact Conv.Map.compact_lt (by change b < 2823922; omega)
    have hi : PRE_fd_vw_r0.kappa1.big i = i := by
      rw [PRE_fd_vw_r0.zkap1]
      exact Conv.rdata_big_js PRE_fd_vw_r0.kd1 i (by rw [hp]; exact Option.some_ne_none _)
    unfold jsShiftBadB at h
    simp only [hp] at h
    rw [ha, hi, he] at h
    simp only [decide_true, Nat.blt_eq.mpr hb, Bool.and_self, Bool.not_true] at h
    cases h

end Host.Ts.Sim.Compose.FDVW
