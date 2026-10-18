import host.ts.RenameRouteReadFields
import host.ts.RenameParametricExpressionEntry
namespace Host.Ts.Owned.Parametric

/-- A fixed private data occurrence. This records the value's role in its
owning object's descriptor, independently of ordinary bigint values elsewhere. -/
def PrivateData {S : Type} (s : St S) (a brand : Nat) (name : Name) (v : Val) : Prop :=
  ∃ o w e, s.heap.get a = some (.obj o) ∧ findPriv brand name o.priv = some (.data v w e)

theorem PrivateData.heap_eq {S : Type} {s t : St S} {a brand : Nat} {name : Name} {v : Val}
    (h : PrivateData s a brand name v) (hh : t.heap = s.heap) : PrivateData t a brand name v := by
  obtain ⟨o,w,e,ho,hp⟩ := h
  exact ⟨o,w,e,hh ▸ ho,hp⟩

theorem PrivateData.heap_at {S : Type} {s t : St S} {a brand : Nat} {name : Name} {v : Val}
    (h : PrivateData s a brand name v) (hh : t.heap.get a = s.heap.get a) : PrivateData t a brand name v := by
  obtain ⟨o,w,e,ho,hp⟩ := h
  exact ⟨o,w,e,hh.trans ho,hp⟩

theorem step_private_data_eq (F : Ffi) (s : St F.S) (a brand : Nat) (name : Name)
    (v : Val) (fs : List Frame) (hc : s.ctl = .ret (.obj a))
    (hf : s.stack = .e (.priv brand name false)::fs) (field : PrivateData s a brand name v) :
    step F s = M.pure ({s with stack := fs}.ret v) := by
  obtain ⟨o,w,e,ho,hp⟩ := field
  funext β k
  simp only [step,hc,stepRet,hf,retStep,retE,Bool.false_and,Bool.cond_false,
    privGetV,St.obj?,ho,hp,Host.Ts.readProp,M.pure]

theorem step_private_data_fields (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (a brand : Nat) (name : Name) (v : Val) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret (.obj a)) (hf₀ : s₀.stack = .e (.priv brand name false)::fs₀)
    (field : PrivateData s (R.a a) (R.a brand) name v)
    (run : interpC (step F s).run C = some (result,D)) : result.ctl = .ret v ∧ result.heap = s.heap := by
  obtain ⟨value,hc,hv⟩ := (h.control_view hc₀).ret_view
  cases hv
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  rw [hfr.private_view] at hf
  rw [step_private_data_eq F s (R.a a) (R.a brand) name v fs hc hf field] at run
  have he := congrArg Prod.fst (Option.some.inj run)
  exact ⟨(congrArg St.ctl he).symm,(congrArg St.heap he).symm⟩

theorem step_private_descent_heap (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C₀ C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (obj : Expr) (name : Name) (opt : Bool) (env : Env) (brand : Nat)
    (hc₀ : s₀.ctl = .ev (.priv obj name opt) env) (hb₀ : lookupEnv (privName name) env = some brand)
    (run : interpC (step F s).run C = some (result,D)) : result.heap = s.heap := by
  obtain ⟨_,hr,_⟩ := step_private_descent_from_source F NR FR R C₀ C live framed before after old old' s₀ s h
    obj name opt env brand hc₀ hb₀
  have hh := congrArg St.heap (congrArg Prod.fst (Option.some.inj (run.symm.trans hr)))
  exact hh

theorem step_return_exit_heap (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ : Val) (exit : ReturnExit) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret v₀) (hf₀ : s₀.stack = exit.frame env::fs₀)
    (run : interpC (step F s).run C = some (result,D)) : result.heap = s.heap := by
  obtain ⟨v,hc,_⟩ := (h.control_view hc₀).ret_view
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  rw [hfr.returnExit_view] at hf
  rw [step_return_exit_eq F s v (R.env env) exit fs hc hf] at run
  exact (congrArg St.heap (congrArg Prod.fst (Option.some.inj run))).symm

theorem step_return_unwind_heap (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ : Val) (unwind : ReturnUnwind) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .abr (.ret v₀)) (hf₀ : s₀.stack = unwind.frame env::fs₀)
    (run : interpC (step F s).run C = some (result,D)) : result.heap = s.heap := by
  obtain ⟨v,hc,_⟩ := (h.control_view hc₀).returnAbrupt_view
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  rw [hfr.returnUnwind_view] at hf
  rw [step_return_unwind_eq F s v (R.env env) unwind fs hc hf] at run
  exact (congrArg St.heap (congrArg Prod.fst (Option.some.inj run))).symm
theorem step_identifier_call_heap (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C₀ C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (name : Name) (args : List Elem) (opt : Bool) (env : Env)
    (hc₀ : s₀.ctl = .ev (.call (.id name) args opt) env)
    (run : interpC (step F s).run C = some (result,D)) : result.heap = s.heap := by
  obtain ⟨_,hr,_⟩ := step_identifier_call_descent_from_source F NR FR R C₀ C live framed before after old old' s₀ s h
    name args opt env hc₀
  have hh := congrArg St.heap (congrArg Prod.fst (Option.some.inj (run.symm.trans hr)))
  exact hh

theorem step_array_spread_entry_heap (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C₀ C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (e : Expr) (rest : List Elem) (env : Env)
    (hc₀ : s₀.ctl = .ev (.array (.spread e::rest)) env)
    (run : interpC (step F s).run C = some (result,D)) : result.heap = s.heap := by
  obtain ⟨_,hr,_⟩ := step_array_spread_entry_from_source F NR FR R C₀ C live framed before after old old' s₀ s h
    e rest env hc₀
  have hh := congrArg St.heap (congrArg Prod.fst (Option.some.inj (run.symm.trans hr)))
  exact hh

theorem step_declaration_value_heap (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ : Val) (kind : DeclKind) (p : Pat) (rest : List (Pat × Option Expr)) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret v₀) (hf₀ : s₀.stack = .s (.decl kind p rest env)::fs₀)
    (hk : isUsing kind = false) (run : interpC (step F s).run C = some (result,D)) : result.heap = s.heap := by
  obtain ⟨v,hc,_⟩ := (h.control_view hc₀).ret_view
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  rw [hfr.decl_view] at hf
  rw [step_declaration_value_eq F s v kind p rest (R.env env) fs hc hf hk] at run
  exact (congrArg St.heap (congrArg Prod.fst (Option.some.inj run))).symm

theorem step_bind_init_heap_other (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (name : Name) (v₀ : Val) (env : Env) (kind : DeclKind) (a : Nat)
    (hc₀ : s₀.ctl = .bind (.id name) v₀ env .init kind) (he₀ : lookupEnv name env = some a)
    (bound : s.next ≤ 2^64) (run : interpC (step F s).run C = some (result,D)) :
    ∀ b, b ≠ R.a a → result.heap.get b = s.heap.get b := by
  obtain ⟨v,hc,_⟩ := (h.control_view hc₀).bind_view
  have hl := h.controlLive
  rw [hc₀] at hl
  have ha := env_lookup_live name env a hl.2.2.1 he₀
  have hab : R.a a < 2^64 := Nat.lt_of_lt_of_le (h.heap.targetBound a ha) bound
  have he : lookupEnv name (R.env env) = some (R.a a) := by rw [lookupEnv_map,he₀]; rfl
  rw [step_bind_init_eq F s name v (R.env env) kind (R.a a) hc he] at run
  have heq := congrArg Prod.fst (Option.some.inj run)
  dsimp only at heq
  intro b hb
  rw [← heq]
  simp only [St.ret,St.setCell,PTrie.get_set_u64 _ _ _ hab,ite_eq_right hb]
end Host.Ts.Owned.Parametric
