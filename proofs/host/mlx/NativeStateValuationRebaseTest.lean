import host.mlx.NativeStateValuationRebase
import host.mlx.NativeCounterRebase
import host.ts.RenameAnnotatedLoop

set_option Elab.async false

namespace Host.Ts.Owned.Annotated.ValuationRebaseTest
open Parametric

def scalarState (x : F64) : St Unit :=
  ⟨default,0,.ret (.num (.lit x)),[],⟨[],(),[],[]⟩⟩

/-- Independent literal values and tables are allowed. The complete input
state relation is constructed here, rather than assumed after substitution. -/
theorem scalar_state (θ : Nat → SymE) (ν₀ ν : Nat → F64) (C₀ C : CSrv) :
    Parametric.StateR (NumberRoles ν₀ ν C₀ C) (fun _ _ _ => True) identity
      (fun _ => False) (fun _ => False) [] [] [] []
      (scalarState (nextValuation θ ν₀ 0)) (scalarState (nextValuation θ ν 0)) := by
  have current : Parametric.StateR
      (NumberRoles (nextValuation θ ν₀) (nextValuation θ ν) C₀ C)
      (fun _ (_ _ : Unit) => True) identity (fun _ => False) (fun _ => False) [] [] [] []
      (scalarState (nextValuation θ ν₀ 0)) (scalarState (nextValuation θ ν 0)) := by
    refine ⟨⟨fun _ impossible => False.elim impossible,
      fun _ impossible => False.elim impossible,fun _ impossible => False.elim impossible,
      fun _ impossible => False.elim impossible,fun _ _ impossible => False.elim impossible,fun _ => rfl⟩,
      .node _ (.cons (.value (.num ⟨.var 0,rfl,rfl⟩)) .nil),
      ⟨True.intro,True.intro⟩,.nil,True.intro,.nil,True.intro,
      .node _ .nil,True.intro,True.intro,⟨[],[],rfl,rfl,.nil⟩⟩
  exact current.substitute_valuation θ id

/-- Rebasing covers the symbolic table and pending comparison, including
the chosen answer, without changing the concrete server. -/
theorem comparison_server (θ : Nat → SymE) (ν : Nat → F64) :
    Inst ν
      ((⟨[.var 0],[⟨.lt,.var 0,.var 1,
        F64.test .lt (nextValuation θ ν 0) (nextValuation θ ν 1)⟩]⟩ : SSrv).substitute θ)
      ⟨[nextValuation θ ν 0]⟩ := by
  apply Inst.substitute_valuation θ
  refine ⟨rfl,?_⟩
  intro query member
  simp only [List.mem_singleton] at member
  subst query
  rfl

/-- Substitution cannot silently change an unrelated literal geometry. -/
theorem literal_geometry (growth : Bool) :
    Host.Mlx.Ffi.Annotated.Shape.subst (advanceRoles growth)
      [.literal (.lit (F64.ofNat 3))] = [.literal (.lit (F64.ofNat 3))] := rfl

/-- A retained literal occurrence cannot become a reference during rebasing. -/
theorem literal_rejects_reference (θ : Nat → SymE) (ν : Nat → F64) (C : CSrv) :
    ¬ ((Value.literal (.var 1)).subst θ).Holds ν C identity (.num (.ref 0)) := by
  intro held
  cases held

end Host.Ts.Owned.Annotated.ValuationRebaseTest

namespace Host.Mlx.Ffi.NativeRoles.CounterRebaseTest

theorem shifted (source delta : Nat) : CounterR (fun i => i+delta) source (source+delta) := by
  refine ⟨?_,?_,?_⟩
  · intro i bound; omega
  · intro i j _ _ same; omega
  · intro k; omega

/-- The counters may differ between source and target. Composition plus a
bounded allocation batch still pairs every subsequent fresh allocation. -/
theorem composed_batch : CounterR (fun i => (i+7)+11) (23+64) ((23+7+11)+64) :=
  ((shifted 23 7).compose (shifted (23+7) 11)).advance_by 64

/-- A different middle counter cannot be hidden in a composed map. -/
theorem wrong_middle : ¬ CounterR (fun i => i+7) 23 31 := by
  intro correspondence
  have wrong := correspondence.head
  change 30 = 31 at wrong
  contradiction

/-- Fresh offsets alone do not permit two allocated resources to alias. -/
theorem rejects_alias : ¬ CounterR (fun i => if i<2 then 0 else i) 2 2 := by
  intro correspondence
  have aliased := correspondence.injective 0 1 (by decide) (by decide) (by decide)
  contradiction

end Host.Mlx.Ffi.NativeRoles.CounterRebaseTest
