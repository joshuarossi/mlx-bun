import host.ts.RenameParameterEffects
namespace Host.Ts.Owned.Parametric

theorem alloc_heap_below {S : Type} (s : St S) (o : HObj) (a : Nat)
    (ha : a < s.next) (bound : s.next < 2^64) : (s.alloc o).2.heap.get a = s.heap.get a := by
  simp only [St.alloc,PTrie.get_set_u64 _ _ _ bound,ite_eq_right (Nat.ne_of_lt ha)]

/-- The actual closure entry allocates only at fresh addresses. Existing
property/cell annotations survive parameter, receiver and home allocation. -/
theorem enterClosure_heap_below (F : Ffi) (s result : St F.S) (C D : CSrv)
    (f : Func) (env : Env) (arrow : Bool) (home this : Val) (args : List Val) (b : Boundary)
    (bound : s.next + 2 + (paramNames f).length ≤ 2^64)
    (run : interpC (enterClosure F s f env arrow home this args b).run C = some (result,D)) :
    ∀ a, a < s.next → result.heap.get a = s.heap.get a := by
  intro a ha
  have pureEntry (t : St F.S) (e : Env)
      (bound : t.next + (paramNames f).length ≤ 2^64)
      (ht : a < t.next)
      (run : interpC (enterClosure F t f e true .undef this args b).run C = some (result,D)) :
      result.heap.get a = t.heap.get a := by
    change some (parameterContinuation (allocCells t (paramNames f) e).2 f b args
      (allocCells t (paramNames f) e).1,C) = some (result,D) at run
    have he := congrArg Prod.fst (Option.some.inj run)
    dsimp only at he
    rw [← he]
    exact allocCells_heap_below t (paramNames f) e a ht bound
  cases arrow with
  | true =>
    have run' : interpC (enterClosure F s f env true .undef this args b).run C = some (result,D) := run
    exact pureEntry s env (by omega) ha run'
  | false =>
    have b₀ : s.next < 2^64 := by omega
    let s₁ := (s.alloc (.cell (some this))).2
    have next₁ : s₁.next = s.next+1 := rfl
    by_cases hu : home = .undef
    · subst home
      have run' : interpC (enterClosure F s₁ f ((nThis,s.next)::env) true .undef this args b).run C = some (result,D) := run
      have hh := pureEntry s₁ ((nThis,s.next)::env) (by rw [next₁]; omega) (by rw [next₁]; omega) run'
      exact hh.trans (alloc_heap_below s (.cell (some this)) a ha b₀)
    · rw [enterClosure_home_eq F s f env home this args b hu] at run
      let s₂ := (s₁.alloc (.cell (some home))).2
      have next₂ : s₂.next = s.next+2 := by change s.next+1+1 = s.next+2; omega
      have run' : interpC (enterClosure F s₂ f ((nHome,s₁.next)::(nThis,s.next)::env)
          true .undef this args b).run C = some (result,D) := run
      have hh := pureEntry s₂ ((nHome,s₁.next)::(nThis,s.next)::env)
        (by rw [next₂]; omega) (by rw [next₂]; omega) run'
      have hh₁ := alloc_heap_below s₁ (.cell (some home)) a (by rw [next₁]; omega) (by rw [next₁]; omega)
      exact hh.trans (hh₁.trans (alloc_heap_below s (.cell (some this)) a ha b₀))
theorem step_closure_heap_below (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (a : Nat) (o₀ : Obj) (f : Func) (env : Env) (arrow : Bool) (home₀ this₀ : Val) (args₀ : List Val)
    (hc₀ : s₀.ctl = .call (.obj a) this₀ args₀) (ho₀ : s₀.heap.get a = some (.obj o₀))
    (hk₀ : o₀.kind = .fn (.closure f env arrow home₀))
    (bound : s.next + 2 + (paramNames f).length ≤ 2^64)
    (run : interpC (step F s).run C = some (result,D)) :
    ∀ b, b < s.next → result.heap.get b = s.heap.get b := by
  obtain ⟨callee,this,args,hc,hcallee,_,_⟩ := (h.control_view hc₀).call_view
  cases hcallee
  have ha : live a := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.1
  obtain ⟨o,ho,hor,_⟩ := h.heap.readObject a o₀ ha (h.heap.function_notFramed a o₀ _ ha ho₀ hk₀) ho₀
  have hk := hor.kind
  rw [hk₀] at hk
  obtain ⟨home,hk,_⟩ := kind_closure hk
  rw [step_closure_eq F s (R.a a) o f (R.env env) arrow home this args hc ho hk] at run
  exact enterClosure_heap_below F s result C D f (R.env env) arrow home this args .call bound run
end Host.Ts.Owned.Parametric
