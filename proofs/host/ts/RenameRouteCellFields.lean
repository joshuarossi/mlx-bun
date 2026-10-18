import host.ts.RenameRoutePrivateFields
set_option Elab.async false
namespace Host.Ts.Owned.Parametric

/-- The value being initialized is retained exactly in the mapped cell by
the real bounded store. It is not weakened to an existential value role. -/
theorem step_bind_init_cell_fields (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (name : Name) (v₀ v : Val) (env : Env) (kind : DeclKind) (a : Nat)
    (hc₀ : s₀.ctl = .bind (.id name) v₀ env .init kind)
    (hc : s.ctl = .bind (.id name) v (R.env env) .init kind)
    (he₀ : lookupEnv name env = some a) (bound : s.next ≤ 2^64)
    (run : interpC (step F s).run C = some (result,D)) :
    result.heap.get (R.a a) = some (.cell (some v)) := by
  have hl := h.controlLive
  rw [hc₀] at hl
  have ha := env_lookup_live name env a hl.2.2.1 he₀
  have hb : R.a a < 2^64 := Nat.lt_of_lt_of_le (h.heap.targetBound a ha) bound
  have he : lookupEnv name (R.env env) = some (R.a a) := by rw [lookupEnv_map,he₀]; rfl
  rw [step_bind_init_eq F s name v (R.env env) kind (R.a a) hc he] at run
  have heq := congrArg Prod.fst (Option.some.inj run)
  dsimp only at heq
  rw [← heq]
  simp only [St.setCell,St.ret,PTrie.get_set_u64 _ _ _ hb,ite_true]

/-- A fixed value established in the current mapped cell is retained by the
real identifier read. The target environment lookup is derived from StateR. -/
theorem step_variable_cell_fields (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (name : Name) (env : Env) (a : Nat) (v : Val)
    (hc₀ : s₀.ctl = .ev (.id name) env) (lookup : lookupEnv name env = some a)
    (cell : s.heap.get (R.a a) = some (.cell (some v)))
    (run : interpC (step F s).run C = some (result,D)) :
    result.ctl = .ret v ∧ result.heap = s.heap := by
  have hc := (h.control_view hc₀).ev_view
  have he : lookupEnv name (R.env env) = some (R.a a) := by rw [lookupEnv_map,lookup]; rfl
  rw [step_variable_eq F s name (R.env env) (R.a a) v hc he cell] at run
  have heq := congrArg Prod.fst (Option.some.inj run)
  dsimp only at heq
  exact ⟨(congrArg St.ctl heq).symm,(congrArg St.heap heq).symm⟩
end Host.Ts.Owned.Parametric
