import host.ts.RenameParametricArrayPush
import host.ts.RenameRouteArgumentFields
import host.ts.RenameParametricTypedArray

set_option Elab.async false
namespace Host.Ts.Owned.Parametric

theorem ArrayData.heap_at {S : Type} {s t : St S} {a : Nat} {values : List Val}
    (h : ArrayData s a values) (heap : t.heap.get a = s.heap.get a) : ArrayData t a values := by
  obtain ⟨o,ho,hk⟩ := h
  exact ⟨o,heap.trans ho,hk⟩

/-- Array.push preserves the exact supplied occurrence and previous elements.
The target callee, receiver, argument list and extensibility are derived from
the source relation and the incoming owning-array/argument annotations. -/
theorem step_array_push_owned_fields (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (f a : Nat) (fo₀ o₀ : Obj) (data₀ : List Val) (v₀ v : Val) (values : List Val)
    (hc₀ : s₀.ctl = .call (.obj f) (.obj a) [v₀])
    (hf₀ : s₀.heap.get f = some (.obj fo₀))
    (hfk₀ : fo₀.kind = .fn (.native (.arr .push) data₀))
    (ho₀ : s₀.heap.get a = some (.obj o₀)) (extensible : o₀.extensible = true)
    (notFramed : ¬ framed a) (bound : s.next ≤ 2^64)
    (array : ArrayData s (R.a a) values) (argument : callArgument s.ctl 0 = v)
    (run : interpC (step F s).run C = some (result,D)) :
    ArrayData result (R.a a) (values++[v]) ∧
      (∀ b, b ≠ R.a a → result.heap.get b = s.heap.get b) := by
  obtain ⟨fo,data,this,args,hc,hf,hfk,_,hthis,hargs⟩ := h.native_call_view f fo₀ (.arr .push)
    data₀ (.obj a) [v₀] hc₀ hf₀ hfk₀
  cases hthis
  cases hargs with
  | cons hv hnil =>
    cases hnil
    have exactArgument := argument
    simp only [hc,callArgument,Host.Ts.arg,nthD] at exactArgument
    rw [exactArgument] at hc
    have ha : live a := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.2.1
    obtain ⟨o',ho',hor,_⟩ := h.heap.readObject a o₀ ha notFramed ho₀
    obtain ⟨o,ho,hk⟩ := array
    have same : o' = o := HObj.obj.inj (Option.some.inj (ho'.symm.trans ho))
    subst o'
    have he : o.extensible = true := hor.extensible_eq.trans extensible
    have word : R.a a < 2^64 := Nat.lt_of_lt_of_le (h.heap.targetBound a ha) bound
    rw [step_array_push_eq F s (R.a f) (R.a a) fo o data [v] values hc hf hfk ho hk he] at run
    have resultEq := (congrArg Prod.fst (Option.some.inj run)).symm
    dsimp only at resultEq
    rw [resultEq]
    refine ⟨⟨{o with kind := .array (values++[v])},?_,rfl⟩,?_⟩
    · simp only [St.ret,St.setObj,PTrie.get_set_u64 _ _ _ word,ite_true]
    · intro b hb
      simp only [St.ret,St.setObj,PTrie.get_set_u64 _ _ _ word,ite_eq_right hb]

end Host.Ts.Owned.Parametric
