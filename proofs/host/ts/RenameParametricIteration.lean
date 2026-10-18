import host.ts.RenameParametricArrayBinding

set_option Elab.async false

namespace Host.Ts.Owned.Parametric

theorem env_drop_support (live : Nat → Prop) (env : Env) (n : Nat)
    (h : treeSupport live (Encode.env env)) : treeSupport live (Encode.env (env.drop n)) := by
  induction env generalizing n with
  | nil => rw [List.drop_nil]; exact h
  | cons p env ih => cases n with
    | zero => exact h
    | succ n => exact ih n h.2

theorem nextIter_one_eq (F : Ffi) (s : St F.S) (name : Name) (env : Env) (a : Nat) (v : Val)
    (he : lookupEnv name env = some a) (hv : s.heap.get a = some (.cell (some v))) :
    nextIter F s [name] env = ((name,s.next)::env.drop 1,(s.alloc (.cell (some v))).2) := by
  simp only [nextIter,copyIter,cellVal?,he,St.cell?,hv,Option.bind_some,List.length_cons,
    id_eq,List.length_nil,Nat.zero_add,Nat.reduceMul,List.take_succ_cons,
    List.take_zero,List.drop_succ_cons,List.nil_append,List.cons_append,St.alloc]

/-- CreatePerIterationEnvironment copies the actual source variable into a
fresh cell. The target value and read are consequences of the initial heap
relation; dropping the shadowed binding keeps the environment bounded. -/
theorem nextIter_one_roles (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (name : Name) (env : Env) (a : Nat) (v₀ : Val)
    (hel : treeSupport live (Encode.env env)) (he₀ : lookupEnv name env = some a)
    (hv₀ : s₀.heap.get a = some (.cell (some v₀)))
    (hs : s₀.next < 2^64) (ht : s.next < 2^64) :
    StateR NR FR R (LiveAfter live s₀.next) framed before after old old'
      (nextIter F s₀ [name] env).2 (nextIter F s [name] (R.env env)).2 ∧
    (nextIter F s [name] (R.env env)).1 = R.env (nextIter F s₀ [name] env).1 ∧
    treeSupport (LiveAfter live s₀.next) (Encode.env (nextIter F s₀ [name] env).1) := by
  have ha := env_lookup_live name env a hel he₀
  obtain ⟨v,hv,hr,hvl⟩ := h.heap.readCell a v₀ ha hv₀
  have he : lookupEnv name (R.env env) = some (R.a a) := by rw [lookupEnv_map,he₀]; rfl
  rw [nextIter_one_eq F s₀ name env a v₀ he₀ hv₀,
    nextIter_one_eq F s name (R.env env) (R.a a) v he hv]
  have hh := h.alloc (.cell (some v₀)) (.cell (some v)) (.cell hr)
    ⟨valueSupport_mono (fun _ => Or.inl) _ hvl,True.intro⟩ hs ht
  have hn : R.a s₀.next = s.next := by simpa only [Nat.add_zero] using h.heap.fresh 0
  refine ⟨hh,?_,?_⟩
  · simp only [Ren.env,List.map_cons,List.map_drop,hn]
  · exact allocated_binding_support s₀ name (env.drop 1) (env_drop_support live env 1 hel)

end Host.Ts.Owned.Parametric
