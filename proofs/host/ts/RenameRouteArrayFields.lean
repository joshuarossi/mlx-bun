import host.ts.RenameParametricTypedArray
import host.ts.RenameParametricArrayLiteral
namespace Host.Ts.Owned.Parametric

/-- A one-element array literal retains the exact returned value, records its
fresh object contents, and preserves every earlier heap field. -/
theorem step_singleton_array_fields (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v : Val) (env : Env) (fs₀ : List Frame)
    (hf₀ : s₀.stack = .l (.array [] [] env)::fs₀) (hc : s.ctl = .ret v)
    (bound : s.next < 2^64) (run : interpC (step F s).run C = some (result,D)) :
    result.ctl = .ret (.obj s.next) ∧ ArrayData result s.next [v] ∧
      (∀ a, a < s.next → result.heap.get a = s.heap.get a) := by
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  obtain ⟨acc,hft,ha⟩ := hfr.arrayLiteral_view
  cases ha
  rw [hft] at hf
  rw [step_array_final_eq F s v [] (R.env env) fs hc hf] at run
  have he := congrArg Prod.fst (Option.some.inj run)
  dsimp only at he
  have he' : result = (({s with stack := fs}.alloc (valueArray [v])).2.ret (.obj s.next)) := he.symm
  rw [he']
  refine ⟨rfl,?_,?_⟩
  · refine ⟨⟨.array [v],.obj aArrayProto,[],[],true⟩,?_,rfl⟩
    simp only [St.ret,St.alloc,PTrie.get_set_u64 _ _ _ bound,ite_true]
    rfl
  · intro a ha
    simp only [St.ret,St.alloc,PTrie.get_set_u64 _ _ _ bound,ite_eq_right (Nat.ne_of_lt ha)]
end Host.Ts.Owned.Parametric
