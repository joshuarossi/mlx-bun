import host.ts.RenameParametricCallback
import host.ts.RenameParametricArrayBuffer
import host.ts.RenameParametricMapControl

set_option Elab.async false
namespace Host.Ts.Owned.Parametric

theorem step_callback_heap_below (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (f : Func) (env : Env) (hc₀ : s₀.ctl = .ev (.arrow f) env)
    (bound : s.next < 2^64) (run : interpC (step F s).run C = some (result,D)) :
    ∀ a, a < s.next → result.heap.get a = s.heap.get a := by
  rw [step_callback_eq F s f (R.env env) (h.control_view hc₀).ev_view] at run
  have he := congrArg Prod.fst (Option.some.inj run)
  dsimp only at he
  rw [← he]
  exact alloc_ret_heap_below s _ _ bound

theorem step_undefined_sne_heap (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret .undef) (hf₀ : s₀.stack = .e (.binR .sne .undef)::fs₀)
    (run : interpC (step F s).run C = some (result,D)) : result.heap = s.heap := by
  obtain ⟨v,hc,hv⟩ := (h.control_view hc₀).ret_view
  cases hv
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  obtain ⟨left,hfe,hl⟩ := hfr.binR_view
  cases hl
  rw [hfe] at hf
  rw [step_undefined_sne_eq F s fs hc hf] at run
  exact (congrArg St.heap (congrArg Prod.fst (Option.some.inj run))).symm

end Host.Ts.Owned.Parametric
