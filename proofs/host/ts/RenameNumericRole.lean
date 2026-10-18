import host.ts.RenameMaterialize

namespace Host.Ts

/-- Meaning of one numeric occurrence under a symbolic valuation. The same
literal can play different roles at different program positions. -/
def NumDenote (ν : Nat → F64) (C : CSrv) (e : SymE) (n : NumV) : Prop :=
  C.val n = some (e.eval ν)

/-- Two executions share a symbolic role, while their literal values,
reference indices, and numeric-table sizes may differ. -/
structure NumRole (ν₀ ν : Nat → F64) (C₀ C : CSrv) (e : SymE) (n₀ n : NumV) : Prop where
  left : NumDenote ν₀ C₀ e n₀
  right : NumDenote ν C e n

namespace NumDenote

theorem literal (ν : Nat → F64) (C : CSrv) (x : F64) : NumDenote ν C (.lit x) (.lit x) := rfl

theorem ofVar (ν : Nat → F64) (C : CSrv) (i : Nat) : NumDenote ν C (.var i) (.lit (ν i)) := rfl

theorem mono {ν : Nat → F64} {C D : CSrv} {e : SymE} {n : NumV}
    (h : NumDenote ν C e n) (hc : TableExtends C D) : NumDenote ν D e n :=
  hc.val h

theorem numBin {ν : Nat → F64} {C : CSrv} {a b : NumV} {ea eb : SymE}
    (ha : NumDenote ν C ea a) (hb : NumDenote ν C eb b) (op : NBin) :
    ∃ v D, interpC (Host.Ts.numBin op a b).run C = some (v, D) ∧
      NumDenote ν D (.bin op ea eb) v ∧ TableExtends C D := by
  obtain ⟨v, D, hr, hv, he, _⟩ := numBin_specialize C op a b _ _ ha hb
  exact ⟨v, D, hr, hv, he⟩

theorem numUn {ν : Nat → F64} {C : CSrv} {a : NumV} {e : SymE}
    (ha : NumDenote ν C e a) (op : NUn) :
    ∃ v D, interpC (Host.Ts.numUn op a).run C = some (v, D) ∧
      NumDenote ν D (.un op e) v ∧ TableExtends C D := by
  obtain ⟨v, D, hr, hv, he, _⟩ := numUn_specialize C op a _ ha
  exact ⟨v, D, hr, hv, he⟩

theorem numTest {ν : Nat → F64} {C : CSrv} {a b : NumV} {ea eb : SymE}
    (ha : NumDenote ν C ea a) (hb : NumDenote ν C eb b) (op : NTest) :
    interpC (Host.Ts.numTest op a b).run C =
      some (F64.test op (ea.eval ν) (eb.eval ν), C) :=
  (numTest_specialize C op a b _ _ ha hb).1

theorem numConc {ν : Nat → F64} {C : CSrv} {a : NumV} {e : SymE}
    (ha : NumDenote ν C e a) :
    interpC (Host.Ts.numConc a).run C = some (e.eval ν, C) :=
  (numConc_specialize C a _ ha).1

end NumDenote

namespace NumRole
variable {ν₀ ν : Nat → F64} {C₀ C : CSrv} {a₀ a b₀ b : NumV} {ea eb : SymE}

theorem literal (ν₀ ν : Nat → F64) (C₀ C : CSrv) (x : F64) :
    NumRole ν₀ ν C₀ C (.lit x) (.lit x) (.lit x) := ⟨rfl, rfl⟩

/-- Loop-index occurrences can contain different concrete literals without
renaming unrelated occurrences of those literals. -/
theorem ofVar (ν₀ ν : Nat → F64) (C₀ C : CSrv) (i : Nat) :
    NumRole ν₀ ν C₀ C (.var i) (.lit (ν₀ i)) (.lit (ν i)) := ⟨rfl, rfl⟩

theorem mono (ha : NumRole ν₀ ν C₀ C ea a₀ a) {D₀ D : CSrv}
    (h₀ : TableExtends C₀ D₀) (h : TableExtends C D) :
    NumRole ν₀ ν D₀ D ea a₀ a := ⟨ha.left.mono h₀, ha.right.mono h⟩

/-- Actual arithmetic on each side may fold literals or allocate a fresh
reference independently. Both results denote the same symbolic operation. -/
theorem numBin (ha : NumRole ν₀ ν C₀ C ea a₀ a) (hb : NumRole ν₀ ν C₀ C eb b₀ b)
    (op : NBin) :
    ∃ v₀ D₀ v D,
      interpC (Host.Ts.numBin op a₀ b₀).run C₀ = some (v₀, D₀) ∧
      interpC (Host.Ts.numBin op a b).run C = some (v, D) ∧
      NumRole ν₀ ν D₀ D (.bin op ea eb) v₀ v ∧ TableExtends C₀ D₀ ∧ TableExtends C D := by
  obtain ⟨v₀, D₀, hr₀, hv₀, he₀⟩ := ha.left.numBin hb.left op
  obtain ⟨v, D, hr, hv, he⟩ := ha.right.numBin hb.right op
  exact ⟨v₀, D₀, v, D, hr₀, hr, ⟨hv₀, hv⟩, he₀, he⟩

theorem numUn (ha : NumRole ν₀ ν C₀ C ea a₀ a) (op : NUn) :
    ∃ v₀ D₀ v D,
      interpC (Host.Ts.numUn op a₀).run C₀ = some (v₀, D₀) ∧
      interpC (Host.Ts.numUn op a).run C = some (v, D) ∧
      NumRole ν₀ ν D₀ D (.un op ea) v₀ v ∧ TableExtends C₀ D₀ ∧ TableExtends C D := by
  obtain ⟨v₀, D₀, hr₀, hv₀, he₀⟩ := ha.left.numUn op
  obtain ⟨v, D, hr, hv, he⟩ := ha.right.numUn op
  exact ⟨v₀, D₀, v, D, hr₀, hr, ⟨hv₀, hv⟩, he₀, he⟩

/-- Transport an already checked source arithmetic transition. The target
table need not have the source table's size or fresh-reference index. -/
theorem numBin_of_run (ha : NumRole ν₀ ν C₀ C ea a₀ a) (hb : NumRole ν₀ ν C₀ C eb b₀ b)
    (op : NBin) {v₀ : NumV} {D₀ : CSrv}
    (hr₀ : interpC (Host.Ts.numBin op a₀ b₀).run C₀ = some (v₀, D₀)) :
    ∃ v D, interpC (Host.Ts.numBin op a b).run C = some (v, D) ∧
      NumRole ν₀ ν D₀ D (.bin op ea eb) v₀ v ∧ TableExtends C₀ D₀ ∧ TableExtends C D := by
  obtain ⟨u₀, E₀, v, D, hu₀, hr, hrole, he₀, he⟩ := ha.numBin hb op
  obtain ⟨rfl, rfl⟩ := Option.some.inj (hu₀.symm.trans hr₀)
  exact ⟨v, D, hr, hrole, he₀, he⟩

theorem numUn_of_run (ha : NumRole ν₀ ν C₀ C ea a₀ a) (op : NUn) {v₀ : NumV} {D₀ : CSrv}
    (hr₀ : interpC (Host.Ts.numUn op a₀).run C₀ = some (v₀, D₀)) :
    ∃ v D, interpC (Host.Ts.numUn op a).run C = some (v, D) ∧
      NumRole ν₀ ν D₀ D (.un op ea) v₀ v ∧ TableExtends C₀ D₀ ∧ TableExtends C D := by
  obtain ⟨u₀, E₀, v, D, hu₀, hr, hrole, he₀, he⟩ := ha.numUn op
  obtain ⟨rfl, rfl⟩ := Option.some.inj (hu₀.symm.trans hr₀)
  exact ⟨v, D, hr, hrole, he₀, he⟩

/-- A shared control branch follows only after both valuations' guards have
been proved. Symbolic-role agreement alone does not identify comparisons. -/
theorem numTest (ha : NumRole ν₀ ν C₀ C ea a₀ a) (hb : NumRole ν₀ ν C₀ C eb b₀ b)
    (op : NTest) (r : Bool)
    (h₀ : F64.test op (ea.eval ν₀) (eb.eval ν₀) = r)
    (h : F64.test op (ea.eval ν) (eb.eval ν) = r) :
    interpC (Host.Ts.numTest op a₀ b₀).run C₀ = some (r, C₀) ∧
      interpC (Host.Ts.numTest op a b).run C = some (r, C) := by
  rw [ha.left.numTest hb.left op, ha.right.numTest hb.right op, h₀, h]
  exact ⟨rfl, rfl⟩

theorem numConc (ha : NumRole ν₀ ν C₀ C ea a₀ a) :
    interpC (Host.Ts.numConc a₀).run C₀ = some (ea.eval ν₀, C₀) ∧
      interpC (Host.Ts.numConc a).run C = some (ea.eval ν, C) :=
  ⟨ha.left.numConc, ha.right.numConc⟩

theorem numConc_equal (ha : NumRole ν₀ ν C₀ C ea a₀ a) (x : F64)
    (h₀ : ea.eval ν₀ = x) (h : ea.eval ν = x) :
    interpC (Host.Ts.numConc a₀).run C₀ = some (x, C₀) ∧
      interpC (Host.Ts.numConc a).run C = some (x, C) := by
  simpa only [h₀, h] using ha.numConc

end NumRole
end Host.Ts
