import host.ts.RenameRetainedRebase

set_option Elab.async false

namespace Host.Ts
open Owned.Annotated

/-- Rebase expressions and pending comparisons, retaining every number
reference index and every already chosen comparison answer. -/
def SSrv.substitute (θ : Nat → SymE) (server : SSrv) : SSrv :=
  ⟨server.tab.map (SymE.subst θ),server.oracle.map (Ans.subst θ)⟩

/-- Table instantiation and oracle correctness use the same substitution as
the runtime roles. No new oracle answer is assumed during rebasing. -/
theorem Inst.substitute_valuation {ν : Nat → F64} {server : SSrv} {concrete : CSrv}
    (θ : Nat → SymE) (current : Inst (nextValuation θ ν) server concrete) :
    Inst ν (server.substitute θ) concrete := by
  refine ⟨?_,(good_subst θ ν server.oracle).mpr current.2⟩
  rw [current.1]
  simp only [SSrv.substitute,List.map_map,Function.comp_def,SymE.eval_subst]
  rfl

theorem SSrv.substitute_length (θ : Nat → SymE) (server : SSrv) :
    (server.substitute θ).tab.length = server.tab.length := by
  simp only [SSrv.substitute,List.length_map]

end Host.Ts

namespace Host.Ts.Owned.Parametric
open Annotated

/-- Substitute the existing witness at each numeric occurrence. The two
concrete number servers, references, and runtime values stay unchanged. -/
theorem NumberRoles.substitute {ν₀ ν : Nat → F64} {C₀ C : CSrv}
    (θ : Nat → SymE) {a₀ a : NumV}
    (held : NumberRoles (nextValuation θ ν₀) (nextValuation θ ν) C₀ C a₀ a) :
    NumberRoles ν₀ ν C₀ C a₀ a := by
  obtain ⟨meaning,left,right⟩ := held
  refine ⟨meaning.subst θ,?_,?_⟩
  · change C₀.val a₀ = some (meaning.eval (fun i => (θ i).eval ν₀)) at left
    simpa only [NumDenote,SymE.eval_subst] using left
  · change C.val a = some (meaning.eval (fun i => (θ i).eval ν)) at right
    simpa only [NumDenote,SymE.eval_subst] using right

/-- Re-express a complete current runtime relation by substitution. This
preserves every heap, control, stack, job, store, and trace occurrence and
the original address/freshness relation. A changed native policy must be
derived from the current native fact; it is not another target-state premise.

Both states and both tables are inputs to this theorem. In particular this
does not relate an earlier template heap to a later reached heap. -/
theorem StateR.substitute_valuation {S : Type} {ν₀ ν : Nat → F64} {C₀ C : CSrv}
    {FR GR : Ren → S → S → Prop} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {source target : St S}
    (θ : Nat → SymE)
    (current : Parametric.StateR (NumberRoles (nextValuation θ ν₀) (nextValuation θ ν) C₀ C)
      FR R live framed before after old old' source target)
    (native : FR R source.ffi target.ffi → GR R source.ffi target.ffi) :
    Parametric.StateR (NumberRoles ν₀ ν C₀ C) GR R live framed before after old old' source target :=
  current.mono (fun _ _ held => held.substitute θ) native

end Host.Ts.Owned.Parametric

namespace Host.Ts.Owned.Annotated
open Parametric

/-- The same substitution updates the whole runtime relation and all six
retained families. It neither chooses new numeric meanings nor discards the
buffer/public/private/capture inventories while changing valuations. -/
theorem RetainedInventory.substitute_state {S : Type} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {FR GR : Ren → S → S → Prop} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event}
    {source target : St S} (θ : Nat → SymE)
    (current : Parametric.StateR (NumberRoles (nextValuation θ ν₀) (nextValuation θ ν) C₀ C)
      FR R live framed before after old old' source target)
    (inventory : RetainedInventory notes (nextValuation θ ν₀) (nextValuation θ ν)
      C₀ C R live source target)
    (native : FR R source.ffi target.ffi → GR R source.ffi target.ffi) :
    Parametric.StateR (NumberRoles ν₀ ν C₀ C) GR R live framed before after old old' source target ∧
    RetainedInventory (notes.subst θ) ν₀ ν C₀ C R live source target :=
  ⟨current.substitute_valuation θ native,inventory.subst θ⟩

end Host.Ts.Owned.Annotated
