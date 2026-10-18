import host.ts.RenameParametricViews
import host.ts.RenameAnnotations

namespace Host.Ts.Owned.Parametric

/-- Each accepted source literal is decoded by the actual interpreter's parser.
Regular expressions allocate objects and belong to a separate dispatch case. -/
inductive LiteralValue : Lit → Val → Type where
  | number (raw : List Char) (x : F64) : F64.ofLit raw = some x →
      LiteralValue (.num raw) (.num (.lit x))
  | bigint (raw : List Char) (i : Nat) : F64.parseIntLit raw = some i →
      LiteralValue (.big raw) (.big (Int.ofNat i))
  | string (raw text : List Char) : cook raw = some text → LiteralValue (.str raw) (.str text)
  | bool (b : Bool) : LiteralValue (.bool b) (.bool b)
  | null : LiteralValue .null .null

def LiteralValue.role {l : Lit} {v : Val} (h : LiteralValue l v) : Annotated.Value :=
  match h with
  | .number _ x _ => .literal (.lit x)
  | .bigint _ i _ => .ordinaryBig (Int.ofNat i)
  | .string _ text _ => .str text
  | .bool b => .bool b
  | .null => .null

theorem LiteralValue.holds {l : Lit} {v : Val} (h : LiteralValue l v)
    (ν : Nat → F64) (C : CSrv) (R : Ren) : h.role.Holds ν C R v := by
  cases h with
  | number raw x hx => exact .literal (.lit x) x rfl
  | bigint raw i hi => exact .ordinaryBig (Int.ofNat i)
  | string raw text ht => exact .str text
  | bool b => exact .bool b
  | null => exact .null

theorem LiteralValue.roles {l : Lit} {v : Val} (h : LiteralValue l v)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren) :
    ValueR (NumberRoles ν₀ ν C₀ C) R v v :=
  Annotated.Value.paired (h.holds ν₀ C₀ Annotated.identity) (h.holds ν C R)

theorem LiteralValue.live {l : Lit} {v : Val} (h : LiteralValue l v)
    (live : Nat → Prop) : valueSupport live v := by cases h <;> exact True.intro

theorem step_literal_eq (F : Ffi) (s : St F.S) (l : Lit) (v : Val) (env : Env)
    (h : LiteralValue l v) (hc : s.ctl = .ev (.lit l) env) : step F s = M.pure (s.ret v) := by
  cases h <;> simp_all only [step,evStep,evLit,retS]
  all_goals rfl

/-- Source syntax fixes literal meaning in both valuations. Actual parsing and
both interpreter runs are derived, and the fixed output role is retained. -/
theorem step_literal_from_source (F : Ffi) (FR : Ren → F.S → F.S → Prop) (R : Ren)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (l : Lit) (v : Val) (env : Env) (hv : LiteralValue l v)
    (hc₀ : s₀.ctl = .ev (.lit l) env) :
    interpC (step F s₀).run C₀ = some (s₀.ret v,C₀) ∧
    interpC (step F s).run C = some (s.ret v,C) ∧
    StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' (s₀.ret v) (s.ret v) ∧
    hv.role.Holds ν₀ C₀ Annotated.identity v ∧ hv.role.Holds ν C R v := by
  have hc := (h.control_view hc₀).ev_view
  refine ⟨?_,?_,h.go (.node _ (.cons (.value (hv.roles ν₀ ν C₀ C R)) .nil)) ⟨hv.live live,True.intro⟩,
    hv.holds ν₀ C₀ Annotated.identity,hv.holds ν C R⟩
  · rw [step_literal_eq F s₀ l v env hv hc₀]; rfl
  · rw [step_literal_eq F s l v (R.env env) hv hc]; rfl

end Host.Ts.Owned.Parametric
