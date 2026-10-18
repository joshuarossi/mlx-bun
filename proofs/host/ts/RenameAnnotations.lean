import host.ts.RenameParametricLoop
namespace Host.Ts.Owned.Annotated
open Parametric

/-- Ghost data fixes each occurrence's meaning. Equal numeric or bigint bits
can have different roles at different paths, but one path has one fixed role. -/
inductive Value where
  | undef | null | bool (b : Bool) | str (s : Name)
  | num (meaning : SymE)
  | literal (meaning : SymE)
  | ordinaryBig (i : Int)
  | numericInteger (meaning : SymE)
  | exactInteger (meaning : SymE)
  | handle (h : Nat)
  | pointerInteger (m : Mem) (off : Nat)
  | obj (a : Nat) | sym (a : Nat) | ptr (m : Mem) (off : Nat)

inductive Value.Holds (ν : Nat → F64) (C : CSrv) (R : Ren) : Value → Val → Prop where
  | undef : Holds ν C R .undef .undef
  | null : Holds ν C R .null .null
  | bool (b : Bool) : Holds ν C R (.bool b) (.bool b)
  | str (s : Name) : Holds ν C R (.str s) (.str s)
  | num (e : SymE) (n : NumV) : NumDenote ν C e n → Holds ν C R (.num e) (.num n)
  | literal (e : SymE) (x : F64) : NumDenote ν C e (.lit x) → Holds ν C R (.literal e) (.num (.lit x))
  | ordinaryBig (i : Int) : Holds ν C R (.ordinaryBig i) (.big i)
  | numericInteger (e : SymE) (i : Int) : NumDenote ν C e (.lit (F64.ofInt i)) →
      Holds ν C R (.numericInteger e) (.big i)
  | exactInteger (e : SymE) (i : Int) : NumDenote ν C e (.lit (F64.ofInt i)) →
      F64.toInt? (e.eval ν) = some i → Holds ν C R (.exactInteger e) (.big i)
  | handle (h : Nat) : Holds ν C R (.handle h) (.big (Int.ofNat (R.handle h)))
  | pointerInteger (m : Mem) (off : Nat) :
      Holds ν C R (.pointerInteger m off) (.big (ptrInt (R.mem m) off))
  | obj (a : Nat) : Holds ν C R (.obj a) (.obj (R.a a))
  | sym (a : Nat) : Holds ν C R (.sym a) (.sym (R.sym a))
  | ptr (m : Mem) (off : Nat) : Holds ν C R (.ptr m off) (.ptr (R.mem m) off)

def identity : Ren := ⟨id,id,id,id,id⟩

theorem identity_sym (a : Nat) : identity.sym a = a := by
  unfold Ren.sym NameMap.sym identity
  cases hb : Nat.blt a 16
  · have ha : 16 ≤ a := by
      have hn : ¬ a < 16 := by
        intro hl
        have ht : Nat.blt a 16 = true := Nat.blt_eq.mpr hl
        rw [hb] at ht
        cases ht
      omega
    simp only [Bool.cond_false,id_eq]
    omega
  · simp only [Bool.cond_true]


/-- Forgetting annotations recovers the previous numeric/runtime relation. The
common symbolic expression is supplied by data, not selected after composition. -/
theorem Value.paired {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {role : Value} {v₀ v : Val}
    (h₀ : role.Holds ν₀ C₀ identity v₀) (h : role.Holds ν C R v) :
    Parametric.ValueR (NumberRoles ν₀ ν C₀ C) R v₀ v := by
  cases h₀ <;> cases h
  case undef => exact .undef
  case null => exact .null
  case bool b => exact .bool b
  case str s => exact .str s
  case num e n₀ h₀ n h => exact .num ⟨e,⟨h₀,h⟩⟩
  case literal e x₀ h₀ x h => exact .num ⟨e,⟨h₀,h⟩⟩
  case ordinaryBig i => exact .ordinaryBig i
  case numericInteger e i₀ h₀ i h => exact .numericInteger ⟨e,⟨h₀,h⟩⟩
  case exactInteger e i₀ h₀ hi₀ i h hi => exact .numericInteger ⟨e,⟨h₀,h⟩⟩
  case handle h => exact .handle h
  case pointerInteger m off => cases m <;> exact .pointerInteger _ off
  case obj a => exact .obj a
  case sym a =>
    have hi := identity_sym a
    simpa only [hi] using (Parametric.ValueR.sym (NR := NumberRoles ν₀ ν C₀ C) (R := R) a)
  case ptr m off => cases m <;> exact .ptr _ off

inductive Cell where
  | num (meaning : SymE) | literal (meaning : SymE)
  | ordinaryBig (i : Int) | numericInteger (meaning : SymE) | exactInteger (meaning : SymE)
  | handle (h : Nat) | pointerInteger (m : Mem) (off : Nat)

inductive Cell.Holds (ν : Nat → F64) (C : CSrv) (R : Ren) : Cell → Host.Ts.Cell → Prop where
  | num (e : SymE) (n : NumV) : NumDenote ν C e n → Holds ν C R (.num e) (.num n)
  | literal (e : SymE) (x : F64) : NumDenote ν C e (.lit x) → Holds ν C R (.literal e) (.num (.lit x))
  | ordinaryBig (i : Int) : Holds ν C R (.ordinaryBig i) (.big i)
  | numericInteger (e : SymE) (i : Int) : NumDenote ν C e (.lit (F64.ofInt i)) →
      Holds ν C R (.numericInteger e) (.big i)
  | exactInteger (e : SymE) (i : Int) : NumDenote ν C e (.lit (F64.ofInt i)) →
      F64.toInt? (e.eval ν) = some i → Holds ν C R (.exactInteger e) (.big i)
  | handle (h : Nat) : Holds ν C R (.handle h) (.big (Int.ofNat (R.handle h)))
  | pointerInteger (m : Mem) (off : Nat) :
      Holds ν C R (.pointerInteger m off) (.big (ptrInt (R.mem m) off))

theorem Cell.paired {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {role : Cell} {c₀ c : Host.Ts.Cell}
    (h₀ : role.Holds ν₀ C₀ identity c₀) (h : role.Holds ν C R c) :
    Parametric.CellR (NumberRoles ν₀ ν C₀ C) R c₀ c := by
  cases h₀ <;> cases h
  case num e n₀ h₀ n h => exact .num ⟨e,⟨h₀,h⟩⟩
  case literal e x₀ h₀ x h => exact .num ⟨e,⟨h₀,h⟩⟩
  case ordinaryBig i => exact .ordinaryBig i
  case numericInteger e i₀ h₀ i h => exact .numericInteger ⟨e,⟨h₀,h⟩⟩
  case exactInteger e i₀ h₀ hi₀ i h hi => exact .numericInteger ⟨e,⟨h₀,h⟩⟩
  case handle h => exact .handle h
  case pointerInteger m off => cases m <;> exact .pointerInteger _ off

inductive Byte where
  | lit (b : Nat) | part (k : EltK) (value : Cell) (i : Nat)

inductive Byte.Holds (ν : Nat → F64) (C : CSrv) (R : Ren) : Byte → Host.Ts.Byte → Prop where
  | lit (b : Nat) : Holds ν C R (.lit b) (.lit b)
  | part (k : EltK) (role : Cell) (i : Nat) (c : Host.Ts.Cell) : role.Holds ν C R c →
      Holds ν C R (.part k role i) (.part k c i)

theorem Byte.paired {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {role : Byte} {b₀ b : Host.Ts.Byte}
    (h₀ : role.Holds ν₀ C₀ identity b₀) (h : role.Holds ν C R b) :
    Parametric.ByteR (NumberRoles ν₀ ν C₀ C) R b₀ b := by
  cases h₀ <;> cases h
  case lit b => exact .lit b
  case part k role i c₀ h₀ c h => exact .part k i (Cell.paired h₀ h)

inductive Tree : Type 1 where
  | atom (α : Type) (x : α)
  | value (role : Value) | cell (role : Cell) | byte (role : Byte)
  | address (a : Nat) | symbol (a : Nat) | region (a : Nat) | number (meaning : SymE)
  | node (tag : String) (fields : List Tree)

mutual
  inductive Tree.Holds (ν : Nat → F64) (C : CSrv) (R : Ren) : Tree → Owned.Tree → Prop where
    | atom (α : Type) (x : α) : Tree.Holds ν C R (.atom α x) (.atom α x)
    | value {role : Value} {v : Val} : role.Holds ν C R v → Tree.Holds ν C R (.value role) (.value v)
    | cell {role : Cell} {c : Host.Ts.Cell} : role.Holds ν C R c → Tree.Holds ν C R (.cell role) (.cell c)
    | byte {role : Byte} {b : Host.Ts.Byte} : role.Holds ν C R b → Tree.Holds ν C R (.byte role) (.byte b)
    | address (a : Nat) : Tree.Holds ν C R (.address a) (.address (R.a a))
    | symbol (a : Nat) : Tree.Holds ν C R (.symbol a) (.symbol (R.sym a))
    | region (a : Nat) : Tree.Holds ν C R (.region a) (.region (R.region a))
    | number (e : SymE) (n : NumV) : NumDenote ν C e n → Tree.Holds ν C R (.number e) (.number n)
    | node (tag : String) {roles : List Tree} {values : List Owned.Tree} : ForestHolds ν C R roles values →
        Tree.Holds ν C R (.node tag roles) (.node tag values)
  inductive ForestHolds (ν : Nat → F64) (C : CSrv) (R : Ren) : List Tree → List Owned.Tree → Prop where
    | nil : ForestHolds ν C R [] []
    | cons {role : Tree} {value : Owned.Tree} {roles : List Tree} {values : List Owned.Tree} :
        role.Holds ν C R value → ForestHolds ν C R roles values → ForestHolds ν C R (role::roles) (value::values)
end


mutual
  theorem Tree.paired {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
      {role : Tree} {t₀ t : Owned.Tree}
      (h₀ : role.Holds ν₀ C₀ identity t₀) (h : role.Holds ν C R t) :
      Parametric.TreeR (NumberRoles ν₀ ν C₀ C) R t₀ t :=
    match h₀,h with
    | .atom α x,.atom _ _ => .atom α x
    | .value h₀,.value h => .value (Value.paired h₀ h)
    | .cell h₀,.cell h => .cell (Cell.paired h₀ h)
    | .byte h₀,.byte h => .byte (Byte.paired h₀ h)
    | .address a,.address _ => .address a
    | .symbol a,.symbol _ => by
      simpa only [identity_sym] using (Parametric.TreeR.symbol (NR := NumberRoles ν₀ ν C₀ C) (R := R) a)
    | .region a,.region _ => .region a
    | .number e n₀ h₀,.number _ n h => .number ⟨e,⟨h₀,h⟩⟩
    | .node tag h₀,.node _ h => .node tag (ForestHolds.paired h₀ h)
  theorem ForestHolds.paired {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
      {roles : List Tree} {ts₀ ts : List Owned.Tree}
      (h₀ : ForestHolds ν₀ C₀ identity roles ts₀) (h : ForestHolds ν C R roles ts) :
      Parametric.ForestR (NumberRoles ν₀ ν C₀ C) R ts₀ ts :=
    match h₀,h with
    | .nil,.nil => .nil
    | .cons h₀ hs₀,.cons h hs => .cons (Tree.paired h₀ h) (ForestHolds.paired hs₀ hs)
end

section TableExtension
variable {ν : Nat → F64} {C D : CSrv} {R : Ren} (he : TableExtends C D)
include he

theorem Value.Holds.mono {role : Value} {v : Val} (h : role.Holds ν C R v) : role.Holds ν D R v := by
  cases h with
  | num e n h => exact .num e n (h.mono he)
  | literal e x h => exact .literal e x (h.mono he)
  | numericInteger e i h => exact .numericInteger e i (h.mono he)
  | exactInteger e i h hi => exact .exactInteger e i (h.mono he) hi
  | undef => exact .undef
  | null => exact .null
  | bool b => exact .bool b
  | str s => exact .str s
  | ordinaryBig i => exact .ordinaryBig i
  | handle h => exact .handle h
  | pointerInteger m off => exact .pointerInteger m off
  | obj a => exact .obj a
  | sym a => exact .sym a
  | ptr m off => exact .ptr m off

theorem Cell.Holds.mono {role : Cell} {v : Host.Ts.Cell} (h : role.Holds ν C R v) : role.Holds ν D R v := by
  cases h with
  | num e n h => exact .num e n (h.mono he)
  | literal e x h => exact .literal e x (h.mono he)
  | numericInteger e i h => exact .numericInteger e i (h.mono he)
  | exactInteger e i h hi => exact .exactInteger e i (h.mono he) hi
  | ordinaryBig i => exact .ordinaryBig i
  | handle h => exact .handle h
  | pointerInteger m off => exact .pointerInteger m off

theorem Byte.Holds.mono {role : Byte} {v : Host.Ts.Byte} (h : role.Holds ν C R v) : role.Holds ν D R v := by
  cases h with
  | lit b => exact .lit b
  | part k role i c h => exact .part k role i c (h.mono he)

omit he in
mutual
  theorem Tree.Holds.mono {ν : Nat → F64} {C D : CSrv} {R : Ren} (he : TableExtends C D)
      {role : Tree} {v : Owned.Tree} (h : role.Holds ν C R v) : role.Holds ν D R v :=
    match h with
    | .atom α x => .atom α x
    | .value h => .value (h.mono he)
    | .cell h => .cell (h.mono he)
    | .byte h => .byte (h.mono he)
    | .address a => .address a
    | .symbol a => .symbol a
    | .region a => .region a
    | .number e n h => .number e n (h.mono he)
    | .node tag h => .node tag (ForestHolds.mono he h)
  theorem ForestHolds.mono {ν : Nat → F64} {C D : CSrv} {R : Ren} (he : TableExtends C D)
      {roles : List Tree} {vs : List Owned.Tree} (h : ForestHolds ν C R roles vs) : ForestHolds ν D R roles vs :=
    match h with
    | .nil => .nil
    | .cons h hs => .cons (Tree.Holds.mono he h) (ForestHolds.mono he hs)
end
end TableExtension

end Host.Ts.Owned.Annotated
