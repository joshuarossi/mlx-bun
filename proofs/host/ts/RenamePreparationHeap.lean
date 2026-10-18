import host.ts.RenameRouteReadFields
import host.ts.RenameParametricNamespace
import host.ts.RenameParametricArrayLiteral
set_option Elab.async false
namespace Host.Ts.Owned.Parametric

theorem step_namespace_method_heap (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (a : Nat) (o₀ : Obj) (exports : Env) (name : Name) (args : List Elem) (env : Env)
    (oo oc : Bool) (cell : Nat) (v₀ : Val) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret (.obj a)) (hf₀ : s₀.stack = .c (.member (.str name) args env oo oc)::fs₀)
    (ho₀ : s₀.heap.get a = some (.obj o₀)) (hk₀ : o₀.kind = .ns exports)
    (he₀ : findExport name exports = some cell) (hv₀ : s₀.heap.get cell = some (.cell (some v₀)))
    (run : interpC (step F s).run C = some (result,D)) : result.heap = s.heap := by
  obtain ⟨v,hc,hv⟩ := (h.control_view hc₀).ret_view
  cases hv
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  rw [hfr.callMember_view] at hf
  have ha : live a := by have hl := h.controlLive; rw [hc₀] at hl; exact hl.1
  obtain ⟨o,ho,hk,helive⟩ := h.heap.read_namespace a o₀ exports ha ho₀ hk₀
  have hcell := env_lookup_live name exports cell helive (by rw [←findExport_eq_lookupEnv]; exact he₀)
  obtain ⟨value,hcell',_,_⟩ := h.heap.readCell cell v₀ hcell hv₀
  have he : findExport name (R.env exports) = some (R.a cell) := by
    rw [findExport_eq_lookupEnv,lookupEnv_map,←findExport_eq_lookupEnv,he₀]; rfl
  rw [step_namespace_method_eq F s (R.a a) o (R.env exports) name args (R.env env) oo oc
    (R.a cell) value fs hc hf ho hk he hcell'] at run
  exact (congrArg St.heap (congrArg Prod.fst (Option.some.inj run))).symm

theorem step_array_entry_heap (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (e : Expr) (rest : List Elem) (env : Env) (hc₀ : s₀.ctl = .ev (.array (.expr e::rest)) env)
    (run : interpC (step F s).run C = some (result,D)) : result.heap = s.heap := by
  rw [step_array_entry_eq F s e rest (R.env env) (h.control_view hc₀).ev_view] at run
  exact (congrArg St.heap (congrArg Prod.fst (Option.some.inj run))).symm

theorem step_array_next_heap (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ : Val) (acc₀ : List Val) (e : Expr) (rest : List Elem) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret v₀) (hf₀ : s₀.stack = .l (.array acc₀ (.expr e::rest) env)::fs₀)
    (run : interpC (step F s).run C = some (result,D)) : result.heap = s.heap := by
  obtain ⟨v,hc,_⟩ := (h.control_view hc₀).ret_view
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  obtain ⟨acc,hfe,_⟩ := hfr.arrayLiteral_view
  rw [hfe] at hf
  rw [step_array_next_eq F s v acc e rest (R.env env) fs hc hf] at run
  exact (congrArg St.heap (congrArg Prod.fst (Option.some.inj run))).symm

theorem step_array_final_heap_below (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s result : St F.S) (C D : CSrv)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (v₀ : Val) (acc₀ : List Val) (env : Env) (fs₀ : List Frame)
    (hc₀ : s₀.ctl = .ret v₀) (hf₀ : s₀.stack = .l (.array acc₀ [] env)::fs₀)
    (bound : s.next < 2^64) (run : interpC (step F s).run C = some (result,D)) :
    ∀ a, a < s.next → result.heap.get a = s.heap.get a := by
  obtain ⟨v,hc,_⟩ := (h.control_view hc₀).ret_view
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view hf₀
  obtain ⟨acc,hfe,_⟩ := hfr.arrayLiteral_view
  rw [hfe] at hf
  rw [step_array_final_eq F s v acc (R.env env) fs hc hf] at run
  have he := congrArg Prod.fst (Option.some.inj run)
  dsimp only at he
  rw [←he]
  intro a ha
  simp only [St.alloc,St.ret,PTrie.get_set_u64 _ _ _ bound,ite_eq_right (Nat.ne_of_lt ha)]
end Host.Ts.Owned.Parametric
