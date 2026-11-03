import host.sim.compose.a4b.fd_x4_L8.TypedBook
import host.sim.template.a4pre_fd_x4_L8_r0.SiteZ1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.FDX4L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Load.Run.Tpl Host.Route

kernel_rfl dispatchChunkGet : PRE_fd_x4_L8_r0.s23.heap.get FDX4L8Frames.chunk =
  some (.obj (Host.Ts.Sim.Template.objOf PRE_fd_x4_L8_r0.s23 FDX4L8Frames.chunk))
kernel_rfl dispatchChunkKind : (Host.Ts.Sim.Template.objOf PRE_fd_x4_L8_r0.s23 FDX4L8Frames.chunk).kind = .array []
kernel_rfl dispatchChunkImage : PRE_fd_x4_L8_r0.s22.heap.get FDX4L8Frames.chunk =
  some (.obj {PRE_fd_x4_L8_r0.kappa1.obj (Host.Ts.Sim.Template.objOf PRE_fd_x4_L8_r0.s23 FDX4L8Frames.chunk) with kind := .array []})
kernel_rfl dispatchFixBuffer : PRE_fd_x4_L8_r0.kappa1.a FDX4L8Frames.buffer = FDX4L8Frames.buffer

abbrev compactW (bs : List Byte) (n : Nat) : Nat → Option WFrame := FDX4L8Frames.typedW bs n

/-- A wide frame of the typed cut: the buffer, the view, the pre-final cut's. -/
theorem compactW_cases {bs : List Byte} {n a : Nat} {w : WFrame} (hw : compactW bs n a = some w) :
    (a = FDX4L8Frames.buffer ∧ w = .buf bs) ∨ (a = FDX4L8Frames.view ∧ w = .typed .i32 FDX4L8Frames.buffer 0 n) ∨ (a, w) ∈ wideListPf := by
  by_cases hv : a = FDX4L8Frames.view
  · subst hv
    have he : compactW bs n FDX4L8Frames.view = some (.typed .i32 FDX4L8Frames.buffer 0 n) := rfl
    rw [he] at hw
    cases hw
    exact .inr (.inl ⟨rfl, rfl⟩)
  · by_cases hb : a = FDX4L8Frames.buffer
    · subst hb
      have he : compactW bs n FDX4L8Frames.buffer = some (.buf bs) := rfl
      rw [he] at hw
      cases hw
      exact .inl ⟨rfl, rfl⟩
    · simp only [compactW, FDX4L8Frames.typedW, Disp.wAt, beq_false hv, beq_false hb, Bool.cond_false] at hw
      exact .inr (.inr (Pf.lookupW_mem hw))

theorem compactW_xs (bs : List Byte) (n a : Nat) :
    a ∈ [2665, FDX4L8Frames.chunk] ↔ a ∈ (2665 :: 4910 :: (ghostPf ++ [FDX4L8Frames.chunk, FDX4L8Frames.buffer, FDX4L8Frames.view])) ∧ compactW bs n a = none := by
  constructor
  · intro h
    simp only [List.mem_cons, List.not_mem_nil, or_false] at h
    rcases h with rfl | rfl
    · exact ⟨by simp, rfl⟩
    · exact ⟨by simp, rfl⟩
  · rintro ⟨hm, hw⟩
    simp only [ghostPf, List.cons_append, List.nil_append, List.mem_cons, List.not_mem_nil, or_false] at hm
    rcases hm with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
    · simp
    · cases hw
    · cases hw
    · cases hw
    · cases hw
    · cases hw
    · cases hw
    · simp
    · cases hw
    · cases hw

theorem compactW_framed (bs : List Byte) (n : Nat) :
    ∀ a w, compactW bs n a = some w → a ∈ (2665 :: 4910 :: (ghostPf ++ [FDX4L8Frames.chunk, FDX4L8Frames.buffer, FDX4L8Frames.view])) := by
  intro a w hw
  rcases compactW_cases hw with ⟨rfl, -⟩ | ⟨rfl, -⟩ | hm
  · simp
  · simp
  · simp only [wideListPf, wideListOf, ghostPf, List.map_cons, List.map_nil, List.mem_cons, List.not_mem_nil, or_false, Prod.mk.injEq] at hm
    rcases hm with ⟨rfl, -⟩ | ⟨rfl, -⟩ | ⟨rfl, -⟩ | ⟨rfl, -⟩ | ⟨rfl, -⟩ | ⟨rfl, -⟩ <;> simp [ghostPf]

kernel_rfl dispatchWidePresent : [FDX4L8Frames.buffer, FDX4L8Frames.view, 4910, 1824, 1834, 1852, 1993, 2001].all (presentB PRE_fd_x4_L8_r0.s23) = true

theorem compactW_present (bs : List Byte) (n : Nat) :
    ∀ a w, compactW bs n a = some w → Present PRE_fd_x4_L8_r0.s23 a := by
  intro a w hw
  have ha : a ∈ [FDX4L8Frames.buffer, FDX4L8Frames.view, 4910, 1824, 1834, 1852, 1993, 2001] := by
    rcases compactW_cases hw with ⟨rfl, -⟩ | ⟨rfl, -⟩ | hm
    · simp
    · simp
    · simp only [wideListPf, wideListOf, ghostPf, List.map_cons, List.map_nil, List.mem_cons, List.not_mem_nil, or_false, Prod.mk.injEq] at hm
      rcases hm with ⟨rfl, -⟩ | ⟨rfl, -⟩ | ⟨rfl, -⟩ | ⟨rfl, -⟩ | ⟨rfl, -⟩ | ⟨rfl, -⟩ <;> simp
  exact List.all_eq_true.mp dispatchWidePresent a ha

theorem compactW_fixed (bs : List Byte) (n : Nat) :
    ∀ a w, compactW bs n a = some w → WFix PRE_fd_x4_L8_r0.kappa1 (Present PRE_fd_x4_L8_r0.s23) w := by
  intro a w hw
  rcases compactW_cases hw with ⟨-, rfl⟩ | ⟨-, rfl⟩ | hm
  · trivial
  · exact dispatchFixBuffer
  · simp only [wideListPf, wideListOf, ghostPf, List.map_cons, List.map_nil, List.mem_cons, List.not_mem_nil, or_false, Prod.mk.injEq] at hm
    rcases hm with ⟨-, rfl⟩ | ⟨-, rfl⟩ | ⟨-, rfl⟩ | ⟨-, rfl⟩ | ⟨-, rfl⟩ | ⟨-, rfl⟩ <;> trivial

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

kernel_rfl dispatchFramesEmpty : (2665 :: 4910 :: (ghostPf ++ [FDX4L8Frames.chunk, FDX4L8Frames.buffer, FDX4L8Frames.view])).all
  (fun a => (arrOf PRE_fd_x4_L8_r0.s22 a).isEmpty) = true

theorem dispatchFramesNext {M : Map} {K : Ctx} {bs : List Byte} {n : Nat}
    (hk : Disp.Kp (FDX4L8Frames.typedJ bs n) K) : Shift.framedNext M K PRE_fd_x4_L8_r0.s22 = K.fr := by
  funext a
  by_cases hf : K.fr a = none
  · exact (framedNext_none_iff (M := M) (s1 := (PRE_fd_x4_L8_r0.s22 : St FF.S)) a).mpr hf |>.trans hf.symm
  · have ha := (hk.2.2 a).mp hf
    have he := List.all_eq_true.mp dispatchFramesEmpty a ha
    apply framedNext_empty
    exact List.isEmpty_iff.mp he

end Host.Ts.Sim.Compose.FDX4L8
