import host.ts.RenameParametricHeap
namespace Host.Ts.Owned.Parametric

/-- Environments map addresses without changing identifier resolution. -/
theorem lookupEnv_map (R : Ren) (name : Name) (env : Env) :
    lookupEnv name (R.env env) = (lookupEnv name env).map R.a := by
  induction env with
  | nil => rfl
  | cons p env ih =>
    obtain ⟨n,a⟩ := p
    change brec (Nat.beq (pack name) (pack n)) (some (R.a a)) (lookupEnv name (R.env env)) =
      (brec (Nat.beq (pack name) (pack n)) (some a) (lookupEnv name env)).map R.a
    cases Nat.beq (pack name) (pack n) <;> simp only [brec,Option.map_some,ih]

/-- A selected initialized source cell determines the related target value;
the target read equation is derived from live heap support. -/
theorem HeapR.readCell {S : Type} {NR : NumV → NumV → Prop} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {s s' : St S}
    (h : HeapR NR R live framed before after s s') (a : Nat) (v : Val)
    (ha : live a) (hv : s.heap.get a = some (.cell (some v))) :
    ∃ v', s'.heap.get (R.a a) = some (.cell (some v')) ∧ ValueR NR R v v' ∧ valueSupport live v := by
  have hr := h.lookup a ha
  rw [hv] at hr
  generalize hh : s'.heap.get (R.a a) = target at hr
  cases hr with
  | regular hf hr hl =>
    cases hr with
    | cell hval => exact ⟨_,rfl,hval,hl.1⟩

/-- The actual local-variable interpreter read. -/
theorem step_variable_eq (F : Ffi) (s : St F.S) (name : Name) (env : Env) (a : Nat) (v : Val)
    (hc : s.ctl = .ev (.id name) env) (he : lookupEnv name env = some a)
    (hv : s.heap.get a = some (.cell (some v))) : step F s = M.pure (s.ret v) := by
  have hcell : s.cell? a = some (some v) := by simp only [St.cell?,hv]
  simp only [step,hc,evStep,readVar,he,hcell,retS]

/-- Source local resolution, heap closure and the whole runtime relation prove
an actual target variable read. There is no target-read simulation premise. -/
theorem step_variable_roles (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (name : Name) (env : Env) (a : Nat) (v₀ : Val)
    (hc₀ : s₀.ctl = .ev (.id name) env) (hc : s.ctl = .ev (.id name) (R.env env))
    (he : lookupEnv name env = some a) (hl : live a)
    (hv : s₀.heap.get a = some (.cell (some v₀))) :
    ∃ v, interpC (step F s₀).run C₀ = some (s₀.ret v₀,C₀) ∧
      interpC (step F s).run C = some (s.ret v,C) ∧
      StateR NR FR R live framed before after old old' (s₀.ret v₀) (s.ret v) ∧ ValueR NR R v₀ v := by
  obtain ⟨v,hv',hr,hs⟩ := h.heap.readCell a v₀ hl hv
  have he' : lookupEnv name (R.env env) = some (R.a a) := by rw [lookupEnv_map,he]; rfl
  refine ⟨v,?_,?_,h.go (.node _ (.cons (.value hr) .nil)) ⟨hs,True.intro⟩,hr⟩
  · rw [step_variable_eq F s₀ name env a v₀ hc₀ he hv]; rfl
  · rw [step_variable_eq F s name (R.env env) (R.a a) v hc he' hv']; rfl

end Host.Ts.Owned.Parametric
