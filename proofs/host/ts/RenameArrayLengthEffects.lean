import host.ts.RenameParametricArrayLength

set_option Elab.async false
namespace Host.Ts.Owned.Parametric

theorem step_array_length_heap (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (a : Nat) (o₀ : Obj) (vs₀ : List Val) (opt : Bool) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret (.obj a)) (hf₀ : s₀.stack = .e (.member kLength opt)::fs₀)
    (ho₀ : s₀.heap.get a = some (.obj o₀)) (hk₀ : o₀.kind = .array vs₀)
    (notFramed : ¬ framed a) (run : interpC (step F s).run C = some (result,D)) :
    result.heap = s.heap := by
  obtain ⟨v,hc,hv⟩ := (h.control_view hc₀).ret_view
  cases hv
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  rw [hfr.arrayLengthMember_view] at hf
  have ha : live a := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.1
  obtain ⟨o,vs,ho,hk,_,_⟩ := h.heap.read_array a o₀ vs₀ ha notFramed ho₀ hk₀
  rw [step_array_length_eq F s (R.a a) o vs opt fs hc hf ho hk] at run
  exact (congrArg St.heap (congrArg Prod.fst (Option.some.inj run))).symm

end Host.Ts.Owned.Parametric
