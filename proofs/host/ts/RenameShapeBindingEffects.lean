import host.ts.RenameRouteCellFields
import host.ts.RenameParametricArrayBinding
set_option Elab.async false
namespace Host.Ts.Owned.Parametric

theorem arrayBinding_heap {S : Type} (s : St S) (ps : List (Option Pat))
    (vs : List Val) (env : Env) (mode : BindMode) (kind : DeclKind) :
    (arrayBinding s ps vs env mode kind).heap = s.heap := by
  induction ps generalizing vs with
  | nil => rfl
  | cons p ps ih => cases p with
    | none => exact ih vs.tail
    | some p => rfl

theorem step_bind_array_fields (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (ps : List (Option Pat)) (a : Nat) (o : Obj) (vs : List Val)
    (env : Env) (mode : BindMode) (kind : DeclKind)
    (hc₀ : s₀.ctl = .bind (.array ps none) (.obj a) env mode kind)
    (heap : s.heap.get (R.a a) = some (.obj o)) (hk : o.kind = .array vs)
    (run : interpC (step F s).run C = some (result,D)) :
    result = arrayBinding s ps vs (R.env env) mode kind := by
  obtain ⟨v,hc,hv⟩ := (h.control_view hc₀).bind_view
  cases hv
  rw [step_bind_array_eq F s ps (R.a a) o vs (R.env env) mode kind hc heap hk] at run
  exact (congrArg Prod.fst (Option.some.inj run)).symm

theorem step_array_binding_next_heap (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ : Val) (ps : List (Option Pat)) (vs₀ : List Val) (env : Env)
    (mode : BindMode) (kind : DeclKind) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret v₀) (hf₀ : s₀.stack = .b (.arr ps none vs₀ env mode kind)::fs₀)
    (run : interpC (step F s).run C = some (result,D)) : result.heap = s.heap := by
  obtain ⟨v,hc,_⟩ := (h.control_view hc₀).ret_view
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  obtain ⟨vs,hfe,_⟩ := hfr.arrayBinding_view
  rw [hfe] at hf
  rw [step_array_binding_next_eq F s v ps vs (R.env env) mode kind fs hc hf] at run
  have he := congrArg Prod.fst (Option.some.inj run)
  dsimp only at he
  rw [←he,arrayBinding_heap]

theorem step_empty_declaration_next_heap (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ : Val) (env : Env) (kind : DeclKind) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret v₀) (hf₀ : s₀.stack = .s (.declNext kind [] env)::fs₀)
    (run : interpC (step F s).run C = some (result,D)) : result.heap = s.heap := by
  obtain ⟨v,hc,_⟩ := (h.control_view hc₀).ret_view
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  rw [hfr.declNext_view] at hf
  rw [step_declaration_next_eq F s v kind [] (R.env env) fs hc hf] at run
  have he := congrArg Prod.fst (Option.some.inj run)
  dsimp only at he
  exact (congrArg St.heap he).symm

end Host.Ts.Owned.Parametric
