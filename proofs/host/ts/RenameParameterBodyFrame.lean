import host.ts.RenameParameterEffects
set_option Elab.async false
namespace Host.Ts.Owned.Parametric

/-- Finishing the original parameter scheduler allocates only fresh lexical
cells when the source body has no initialized function declarations. -/
theorem step_parameter_body_heap_below (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (initial : Val) (name : Option Name) (params : List Pat) (ss : List Stmt) (args : List Val) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret initial)
    (hf₀ : s₀.stack = .k (.params (.mk name params none (.block ss) false false []) [] args env)::fs₀)
    (inert : noInitFunctions ss = true) (bound : s.next+(blockNames ss).length ≤ 2^64)
    (run : interpC (step F s).run C = some (result,D)) :
    ∀ a, a < s.next → result.heap.get a = s.heap.get a := by
  obtain ⟨v,hc,_⟩ := (h.control_view hc₀).ret_view
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  obtain ⟨values,hfe,_⟩ := hfr.params_view
  rw [hfe] at hf
  rw [step_parameter_body_eq F s v name params ss values (R.env env) fs hc hf] at run
  have he := congrArg Prod.fst (Option.some.inj run)
  dsimp only at he
  rw [←he]
  intro a below
  exact enterBlock_heap_below {s with stack := fs} ss (R.env env) a below bound inert
end Host.Ts.Owned.Parametric
