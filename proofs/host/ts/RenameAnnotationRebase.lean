import host.ts.RenameAnnotations
namespace Host.Ts.Owned.Annotated

def nextValuation (θ : Nat → SymE) (ν : Nat → F64) : Nat → F64 := fun i => (θ i).eval ν

def Value.subst (θ : Nat → SymE) : Value → Value
  | .num e => .num (e.subst θ)
  | .literal e => .literal (e.subst θ)
  | .numericInteger e => .numericInteger (e.subst θ)
  | .exactInteger e => .exactInteger (e.subst θ)
  | v => v

def Cell.subst (θ : Nat → SymE) : Cell → Cell
  | .num e => .num (e.subst θ)
  | .literal e => .literal (e.subst θ)
  | .numericInteger e => .numericInteger (e.subst θ)
  | .exactInteger e => .exactInteger (e.subst θ)
  | v => v

def Byte.subst (θ : Nat → SymE) : Byte → Byte
  | .lit b => .lit b
  | .part k c i => .part k (c.subst θ) i

mutual
  def Tree.subst (θ : Nat → SymE) : Tree → Tree
    | .atom α x => .atom α x
    | .value role => .value (role.subst θ)
    | .cell role => .cell (role.subst θ)
    | .byte role => .byte (role.subst θ)
    | .address a => .address a
    | .symbol a => .symbol a
    | .region a => .region a
    | .number e => .number (e.subst θ)
    | .node tag fields => .node tag (substForest θ fields)
  def substForest (θ : Nat → SymE) : List Tree → List Tree
    | [] => []
    | role :: rest => role.subst θ :: substForest θ rest
end

private theorem denote_subst {ν : Nat → F64} {C : CSrv} (θ : Nat → SymE) (e : SymE) (n : NumV) :
    NumDenote ν C (e.subst θ) n ↔ NumDenote (nextValuation θ ν) C e n := by
  simp only [NumDenote,SymE.eval_subst]
  rfl

private theorem int_subst {ν : Nat → F64} (θ : Nat → SymE) (e : SymE) (i : Int) :
    F64.toInt? ((e.subst θ).eval ν) = some i ↔ F64.toInt? (e.eval (nextValuation θ ν)) = some i := by
  simp only [SymE.eval_subst]
  rfl

/-- Numeric annotations rebase by expression substitution at every occurrence.
The runtime values and concrete numeric table are unchanged by this theorem. -/
theorem Value.holds_subst {ν : Nat → F64} {C : CSrv} {R : Ren}
    (θ : Nat → SymE) (role : Value) (v : Val) :
    (role.subst θ).Holds ν C R v ↔ role.Holds (nextValuation θ ν) C R v := by
  cases role <;> simp only [Value.subst]
  all_goals constructor <;> intro h <;> cases h <;> constructor
  all_goals first
    | assumption
    | exact (denote_subst θ _ _).mp (by assumption)
    | exact (denote_subst θ _ _).mpr (by assumption)
    | exact (int_subst θ _ _).mp (by assumption)
    | exact (int_subst θ _ _).mpr (by assumption)

theorem Cell.holds_subst {ν : Nat → F64} {C : CSrv} {R : Ren}
    (θ : Nat → SymE) (role : Cell) (v : Host.Ts.Cell) :
    (role.subst θ).Holds ν C R v ↔ role.Holds (nextValuation θ ν) C R v := by
  cases role <;> simp only [Cell.subst]
  all_goals constructor <;> intro h <;> cases h <;> constructor
  all_goals first
    | assumption
    | exact (denote_subst θ _ _).mp (by assumption)
    | exact (denote_subst θ _ _).mpr (by assumption)
    | exact (int_subst θ _ _).mp (by assumption)
    | exact (int_subst θ _ _).mpr (by assumption)

theorem Byte.holds_subst {ν : Nat → F64} {C : CSrv} {R : Ren}
    (θ : Nat → SymE) (role : Byte) (v : Host.Ts.Byte) :
    (role.subst θ).Holds ν C R v ↔ role.Holds (nextValuation θ ν) C R v := by
  cases role <;> simp only [Byte.subst]
  all_goals constructor <;> intro h <;> cases h
  case lit.mp b => exact .lit b
  case lit.mpr b => exact .lit b
  case part.mp k role i c h => exact .part k role i c ((Cell.holds_subst θ role c).mp h)
  case part.mpr k role i c h => exact .part k (role.subst θ) i c ((Cell.holds_subst θ role c).mpr h)

mutual
  theorem Tree.subst_holds {ν : Nat → F64} {C : CSrv} {R : Ren}
      (θ : Nat → SymE) (role : Tree) (v : Owned.Tree)
      (h : (role.subst θ).Holds ν C R v) : role.Holds (nextValuation θ ν) C R v := by
    cases role <;> simp only [Tree.subst] at h <;> cases h
    case atom α x => exact .atom α x
    case value role v h => exact .value ((Value.holds_subst θ role v).mp h)
    case cell role c h => exact .cell ((Cell.holds_subst θ role c).mp h)
    case byte role b h => exact .byte ((Byte.holds_subst θ role b).mp h)
    case address a => exact .address a
    case symbol a => exact .symbol a
    case region a => exact .region a
    case number e n h => exact .number e n ((denote_subst θ e n).mp h)
    case node tag fields values h => exact .node tag (substForest_holds θ fields values h)
  theorem substForest_holds {ν : Nat → F64} {C : CSrv} {R : Ren}
      (θ : Nat → SymE) (roles : List Tree) (values : List Owned.Tree)
      (h : ForestHolds ν C R (substForest θ roles) values) :
      ForestHolds (nextValuation θ ν) C R roles values := by
    cases roles <;> simp only [substForest] at h <;> cases h
    case nil => exact .nil
    case cons role roles value values h hs => exact .cons (Tree.subst_holds θ role value h) (substForest_holds θ roles values hs)
end

mutual
  theorem Tree.holds_subst_of {ν : Nat → F64} {C : CSrv} {R : Ren}
      (θ : Nat → SymE) (role : Tree) (v : Owned.Tree)
      (h : role.Holds (nextValuation θ ν) C R v) : (role.subst θ).Holds ν C R v := by
    cases h
    case atom α x => exact .atom α x
    case value role v h => exact .value ((Value.holds_subst θ role v).mpr h)
    case cell role c h => exact .cell ((Cell.holds_subst θ role c).mpr h)
    case byte role b h => exact .byte ((Byte.holds_subst θ role b).mpr h)
    case address a => exact .address a
    case symbol a => exact .symbol a
    case region a => exact .region a
    case number e n h => exact .number (e.subst θ) n ((denote_subst θ e n).mpr h)
    case node tag fields values h => exact .node tag (holds_substForest_of θ fields values h)
  theorem holds_substForest_of {ν : Nat → F64} {C : CSrv} {R : Ren}
      (θ : Nat → SymE) (roles : List Tree) (values : List Owned.Tree)
      (h : ForestHolds (nextValuation θ ν) C R roles values) :
      ForestHolds ν C R (substForest θ roles) values := by
    cases h
    case nil => exact .nil
    case cons role value roles values h hs => exact .cons (Tree.holds_subst_of θ role value h) (holds_substForest_of θ roles values hs)
end

theorem Tree.holds_subst {ν : Nat → F64} {C : CSrv} {R : Ren}
    (θ : Nat → SymE) (role : Tree) (v : Owned.Tree) :
    (role.subst θ).Holds ν C R v ↔ role.Holds (nextValuation θ ν) C R v :=
  ⟨Tree.subst_holds θ role v,Tree.holds_subst_of θ role v⟩

end Host.Ts.Owned.Annotated
