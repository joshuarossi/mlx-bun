import host.sim.compose.a4b.fd.TypedBook
import host.sim.template.a4pre_fd_vw_r0.SiteZ1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.FDVW
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Load.Run.Tpl Host.Route

kernel_rfl dispatchChunkGet : PRE_fd_vw_r0.s23.heap.get FDFrames.chunk =
  some (.obj (Host.Ts.Sim.Template.objOf PRE_fd_vw_r0.s23 FDFrames.chunk))
kernel_rfl dispatchChunkKind : (Host.Ts.Sim.Template.objOf PRE_fd_vw_r0.s23 FDFrames.chunk).kind = .array []
kernel_rfl dispatchChunkImage : PRE_fd_vw_r0.s22.heap.get FDFrames.chunk =
  some (.obj {PRE_fd_vw_r0.kappa1.obj (Host.Ts.Sim.Template.objOf PRE_fd_vw_r0.s23 FDFrames.chunk) with kind := .array []})
kernel_rfl dispatchWidePresent : [FDFrames.buffer, FDFrames.view].all (presentB PRE_fd_vw_r0.s23) = true
kernel_rfl dispatchFixBuffer : PRE_fd_vw_r0.kappa1.a FDFrames.buffer = FDFrames.buffer

theorem compactW_xs (bs : List Byte) (n a : Nat) :
    a ∈ [2665, FDFrames.chunk] ↔ a ∈ [2665, FDFrames.chunk, FDFrames.buffer, FDFrames.view] ∧ compactW bs n a = none := by
  by_cases hv : a = FDFrames.view
  · subst hv; simp [compactW, Disp.wAt, FDFrames.view, FDFrames.buffer, FDFrames.chunk]
  · by_cases hb : a = FDFrames.buffer
    · subst hb; simp [compactW, Disp.wAt, FDFrames.view, FDFrames.buffer, FDFrames.chunk]
    · rw [compactW_none hb hv]
      simp only [and_true, List.mem_cons, List.not_mem_nil, or_false, hv, hb, or_false]

theorem compactW_framed (bs : List Byte) (n : Nat) :
    ∀ a w, compactW bs n a = some w → a ∈ [2665, FDFrames.chunk, FDFrames.buffer, FDFrames.view] := by
  intro a w hw
  rcases compactW_domain hw with rfl | rfl <;> simp

theorem compactW_present (bs : List Byte) (n : Nat) :
    ∀ a w, compactW bs n a = some w → Present PRE_fd_vw_r0.s23 a := by
  intro a w hw
  have ha : a ∈ [FDFrames.buffer, FDFrames.view] := by
    rcases compactW_domain hw with rfl | rfl <;> simp
  exact List.all_eq_true.mp dispatchWidePresent a ha

theorem compactW_fixed (bs : List Byte) (n : Nat) :
    ∀ a w, compactW bs n a = some w → WFix PRE_fd_vw_r0.kappa1 (Present PRE_fd_vw_r0.s23) w := by
  intro a w hw
  rcases compactW_domain hw with rfl | rfl
  · have he : compactW bs n FDFrames.buffer = some (.buf bs) := rfl
    rw [he] at hw
    cases hw
    trivial
  · have he : compactW bs n FDFrames.view = some (.typed .i32 FDFrames.buffer 0 n) := rfl
    rw [he] at hw
    cases hw
    exact dispatchFixBuffer

private theorem framedNext_empty {F : Ffi} {s : St F.S} {a : Nat} (M : Map) (K : Ctx)
    (he : arrOf s a = []) : Shift.framedNext M K s a = K.fr a := by
  unfold Shift.framedNext
  cases hf : K.fr a with
  | none => rfl
  | some p =>
    obtain ⟨pre, pre'⟩ := p
    cases hg : s.heap.get a with
    | none => rfl
    | some obj =>
      cases obj with
      | cell v => rfl
      | obj o =>
        cases hk : o.kind <;>
          simp_all only [arrOf, hg, hk, List.drop_nil, Map.vals, List.map_nil, List.append_nil]

kernel_rfl dispatchFramesEmpty : [2665, FDFrames.chunk, FDFrames.buffer, FDFrames.view].all
  (fun a => (arrOf PRE_fd_vw_r0.s22 a).isEmpty) = true

theorem dispatchFramesNext {M : Map} {K : Ctx} {bs : List Byte} {n : Nat}
    (hk : Disp.Kp (FDFrames.typedJ bs n) K) : Shift.framedNext M K PRE_fd_vw_r0.s22 = K.fr := by
  funext a
  by_cases hf : K.fr a = none
  · exact (framedNext_none_iff (M := M) (s1 := (PRE_fd_vw_r0.s22 : St FF.S)) a).mpr hf |>.trans hf.symm
  · have ha := (hk.2.2 a).mp hf
    have he := List.all_eq_true.mp dispatchFramesEmpty a ha
    apply framedNext_empty
    exact List.isEmpty_iff.mp he

end Host.Ts.Sim.Compose.FDVW
