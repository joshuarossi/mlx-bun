import host.ts.RenameParametricRegistry
set_option Elab.async false
namespace Host.Ts.Owned.Parametric

/-- Transport the original unregister builtin. Its false result does not alter either heap or native state. -/
theorem step_finalization_unregister_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (a : Nat) (o₀ : Obj) (data₀ : List Val) (this₀ : Val) (args₀ : List Val)
    (hc₀ : s₀.ctl = .call (.obj a) this₀ args₀)
    (ho₀ : s₀.heap.get a = some (.obj o₀)) (hk₀ : o₀.kind = .fn (.native (.fn .finUnregister) data₀)) :
    interpC (step F s₀).run C₀ = some (s₀.ret (.bool false),C₀) ∧
      interpC (step F s).run C = some (s.ret (.bool false),C) ∧
      StateR NR FR R live framed before after old old' (s₀.ret (.bool false)) (s.ret (.bool false)) := by
  obtain ⟨o,data,this,args,hc,ho,hk,_,_,_⟩ := h.native_call_view a o₀ (.fn .finUnregister) data₀ this₀ args₀ hc₀ ho₀ hk₀
  refine ⟨?_,?_,h.go (.node _ (.cons (.value (.bool false)) .nil)) ⟨True.intro,True.intro⟩⟩
  · rw [step_native_eq F s₀ a o₀ (.fn .finUnregister) data₀ this₀ args₀ hc₀ ho₀ hk₀]; rfl
  · rw [step_native_eq F s (R.a a) o (.fn .finUnregister) data this args hc ho hk]; rfl

end Host.Ts.Owned.Parametric
