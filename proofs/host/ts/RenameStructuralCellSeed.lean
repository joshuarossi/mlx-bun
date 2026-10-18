import host.ts.RenameRoleInventory
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- Structural constructors have a fixed role under the original heap
relation. Numeric and bigint occurrences need their own provenance. -/
inductive StructuralValue : Val → Value → Prop where
  | undef : StructuralValue .undef .undef
  | null : StructuralValue .null .null
  | bool (b : Bool) : StructuralValue (.bool b) (.bool b)
  | str (s : Name) : StructuralValue (.str s) (.str s)
  | obj (a : Nat) : StructuralValue (.obj a) (.obj a)
  | sym (a : Nat) : StructuralValue (.sym a) (.sym a)
  | ptr (m : Mem) (off : Nat) : StructuralValue (.ptr m off) (.ptr m off)

def structuralRole : Val → Option Value
  | .undef => some .undef | .null => some .null | .bool b => some (.bool b)
  | .str s => some (.str s) | .obj a => some (.obj a) | .sym a => some (.sym a)
  | .ptr m off => some (.ptr m off) | .num _ | .big _ => none

theorem structuralRole_sound {v : Val} {role : Value} (selected : structuralRole v = some role) :
    StructuralValue v role := by
  cases v <;> simp only [structuralRole,Option.some.injEq] at selected
  all_goals first | contradiction | subst role; constructor

theorem StructuralValue.source {v : Val} {role : Value} (static : StructuralValue v role)
    (ν : Nat → F64) (C : CSrv) : role.Holds ν C identity v := by
  cases static
  all_goals try constructor
  case sym a => simpa only [identity_sym] using Value.Holds.sym (ν:=ν) (C:=C) (R:=identity) a
  case ptr m off => cases m <;> exact .ptr _ off

theorem StructuralValue.target {v w : Val} {role : Value} {NR : NumV → NumV → Prop} {R : Ren}
    (static : StructuralValue v role) (relation : Parametric.ValueR NR R v w)
    (ν : Nat → F64) (C : CSrv) : role.Holds ν C R w := by
  cases static <;> cases relation <;> constructor

/-- Seed all live structural cells once from initialization, including module
exports and model object references. Later source reads use these same notes. -/
noncomputable def structuralCells {S : Type} (live : Nat → Prop) (s : St S) : Notes := by
  classical
  exact ⟨fun a => if live a then match s.heap.get a with
    | some (.cell (some v)) => structuralRole v
    | _ => none
    else none⟩

theorem structuralCells.entry {S : Type} {live : Nat → Prop} {s : St S} {a : Nat} {v : Val} {role : Value}
    (alive : live a) (cell : s.heap.get a = some (.cell (some v))) (selected : structuralRole v = some role) :
    (structuralCells live s).cells a = some role := by simp only [structuralCells,ite_eq_left alive,cell,selected]

theorem structuralCells.uninitialized {S : Type} (live : Nat → Prop) {s : St S} {a : Nat}
    (cell : s.heap.get a = some (.cell none)) : (structuralCells live s).cells a = none := by
  classical
  by_cases alive : live a
  · simp only [structuralCells,ite_eq_left alive,cell]
  · simp only [structuralCells,ite_eq_right alive]

theorem CellInventory.structural_seed {S : Type} {NR : NumV → NumV → Prop}
    {FR : Ren → S → S → Prop} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St S}
    (h : Parametric.StateR NR FR R live framed before after old old' s₀ s)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) : CellInventory (structuralCells live s₀) ν₀ ν C₀ C R live s₀ s := by
  classical
  have select : ∀ a role, (structuralCells live s₀).cells a = some role →
      live a ∧ ∃ v, s₀.heap.get a = some (.cell (some v)) ∧ StructuralValue v role := by
    intro a role entry
    by_cases alive : live a
    · simp only [structuralCells,ite_eq_left alive] at entry
      cases read : s₀.heap.get a with
      | none => simp only [read] at entry; cases entry
      | some object => cases object with
        | obj _ => simp only [read] at entry; cases entry
        | cell value => cases value with
          | none => simp only [read] at entry; cases entry
          | some v => exact ⟨alive,v,rfl,structuralRole_sound (by simpa only [read] using entry)⟩
    · simp only [structuralCells,ite_eq_right alive] at entry
      cases entry
  refine ⟨fun a role entry => (select a role entry).1,?_,?_⟩
  · intro a role entry
    obtain ⟨_,v,read,static⟩ := select a role entry
    change role.Holds ν₀ C₀ identity (cellValueAt s₀ a)
    simpa only [cellValueAt,read] using static.source ν₀ C₀
  · intro a role entry
    obtain ⟨alive,v,read,static⟩ := select a role entry
    obtain ⟨w,targetRead,relation,_⟩ := h.heap.readCell a v alive read
    simpa only [cellValueAt,targetRead] using static.target relation ν C
end Host.Ts.Owned.Annotated
