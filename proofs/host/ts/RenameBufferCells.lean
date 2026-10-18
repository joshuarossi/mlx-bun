import host.ts.RenameBufferInventory

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Ts.Owned.Annotated
open Parametric

def cellPartNotes (kind : EltK) (role : Cell) : Nat → Nat → List Byte
  | 0,_ => []
  | n+1,i => .part kind role i :: cellPartNotes kind role n (i+1)

theorem cellPartNotes_holds {ν : Nat → F64} {C : CSrv} {R : Ren} {role : Cell} {cell : Host.Ts.Cell}
    (held : role.Holds ν C R cell) (kind : EltK) (n i : Nat) :
    ListR (fun role byte => role.Holds ν C R byte) (cellPartNotes kind role n i) (cellParts kind cell n i) := by
  induction n generalizing i with
  | zero => exact .nil
  | succ n ih => exact .cons (.part kind role i cell held) (ih (i+1))

theorem cellPartNotes_handle_exact {ν : Nat → F64} {C : CSrv} {R : Ren}
    (kind : EltK) (handle n i : Nat) (bytes : List Host.Ts.Byte)
    (held : ListR (fun role byte => role.Holds ν C R byte) (cellPartNotes kind (.handle handle) n i) bytes) :
    bytes = cellParts kind (.big (Int.ofNat (R.handle handle))) n i := by
  induction n generalizing i bytes with
  | zero => cases held; rfl
  | succ n ih =>
    cases held with | cons head rest =>
      cases head with | part _ _ _ cell role =>
        cases role
        exact congrArg (Host.Ts.Byte.part kind (.big (Int.ofNat (R.handle handle))) i :: ·) (ih _ _ rest)

theorem cellPartNotes_partsFrom {ν : Nat → F64} {C : CSrv} {R : Ren}
    (kind : EltK) (role : Cell) (n i : Nat) (bytes : List Host.Ts.Byte)
    (held : ListR (fun role byte => role.Holds ν C R byte) (cellPartNotes kind role n i) bytes) :
    wholeCell.partsFrom kind bytes i (i+n) = true := by
  induction n generalizing i bytes with
  | zero => cases held; simp only [wholeCell.partsFrom,Nat.add_zero,Nat.beq_refl]
  | succ n ih =>
    cases held with | cons head rest =>
      cases head with | part _ _ _ cell annotation =>
        have tail := ih (i+1) _ rest
        have endIndex : i+1+n = i+(n+1) := by omega
        simpa only [wholeCell.partsFrom,kindEq,Nat.beq_refl,Bool.true_and,endIndex] using tail

/-- The original tagged-byte decoder returns the fixed cell role. General
numeric roles may use different equal-denoting refs in later byte parts;
the proof follows wholeCell's actual first-part selection. -/
theorem readCell_cellPartNotes {ν : Nat → F64} {C : CSrv} {R : Ren}
    (kind : EltK) (role : Cell) (bytes : List Host.Ts.Byte)
    (held : ListR (fun role byte => role.Holds ν C R byte)
      (cellPartNotes kind role kind.size 0) (bytes.take kind.size)) :
    ∃ cell, role.Holds ν C R cell ∧ readCell kind bytes = some cell := by
  have positive : 0 < kind.size := by cases kind <;> decide +kernel
  cases size : kind.size with
  | zero => omega
  | succ n =>
    rw [size] at held
    generalize taken : bytes.take (n+1) = parts at held
    cases held with | cons head rest =>
      cases head with | part _ _ _ cell annotation =>
        have suffix := cellPartNotes_partsFrom kind role n 1 _ rest
        have endIndex : 1+n = n+1 := by omega
        rw [endIndex] at suffix
        refine ⟨cell,annotation,?_⟩
        simp only [readCell,size,taken,wholeCell,kindEq,Nat.beq_refl,Bool.true_and,suffix,Bool.cond_true]

def Cell.valueRole : Cell → Value
  | .num e => .num e
  | .literal e => .literal e
  | .ordinaryBig i => .ordinaryBig i
  | .numericInteger e => .numericInteger e
  | .exactInteger e => .exactInteger e
  | .handle h => .handle h
  | .pointerInteger memory off => .pointerInteger memory off

theorem Cell.Holds.valueRole {ν : Nat → F64} {C : CSrv} {R : Ren} {role : Cell} {cell : Host.Ts.Cell}
    (held : role.Holds ν C R cell) : role.valueRole.Holds ν C R (cellVal cell) := by
  cases held with
  | num e n h => exact .num e n h
  | literal e x h => exact .literal e x h
  | ordinaryBig i => exact .ordinaryBig i
  | numericInteger e i h => exact .numericInteger e i h
  | exactInteger e i h exact => exact .exactInteger e i h exact
  | handle h => exact .handle h
  | pointerInteger memory off => exact .pointerInteger memory off

/-- Distinguished null is assigned its handle meaning at initialization, with
the explicit resource law fixing handle zero. -/
theorem null_handle_cellPartNotes (ν : Nat → F64) (C : CSrv) (R : Ren) (zero : R.handle 0 = 0) (n i : Nat) :
    ListR (fun role byte => role.Holds ν C R byte) (cellPartNotes .u64 (.handle 0) n i)
      (cellParts .u64 (.big 0) n i) := by
  have held : Cell.Holds ν C R (.handle 0) (.big 0) := by simpa [zero] using Cell.Holds.handle (ν := ν) (C := C) (R := R) 0
  exact cellPartNotes_holds held .u64 n i

/-- A selected byte layout determines the original typed read and its return
meaning. Only the fixed note layout is inspected; actual target bytes are
obtained from the retained inventory. -/
theorem BufferContents.typedGet (F : Ffi) {roles : List Byte} {ν : Nat → F64} {C : CSrv} {R : Ren}
    {owner : Nat} {s : St F.S} (contents : BufferContents roles ν C R owner s)
    (kind : EltK) (role : Cell) (off count i : Nat) (inside : Nat.blt i count = true)
    (layout : (roles.drop (off + i * kind.size)).take kind.size = cellPartNotes kind role kind.size 0) :
    ∃ cell, role.Holds ν C R cell ∧
      typedGet F s kind (R.a owner) off count i = M.pure (some (.data (cellVal cell) true true)) ∧
      role.valueRole.Holds ν C R (cellVal cell) := by
  obtain ⟨object,bytes,read,kindOf,held⟩ := contents
  have parts := (held.drop (off + i * kind.size)).take kind.size
  rw [layout] at parts
  obtain ⟨cell,annotation,decoded⟩ := readCell_cellPartNotes kind role _ parts
  have buffer : bufBytes F s (R.a owner) = some bytes :=
    bufBytes_of_obj F s (R.a owner) object bytes (by simp only [St.obj?,read]) kindOf
  refine ⟨cell,annotation,?_,annotation.valueRole⟩
  funext β continuation
  simp only [Host.Ts.typedGet,inside,Bool.cond_true,buffer,decoded]

theorem BufferInventory.typedGet (F : Ffi) {notes : BufferNotes} {ν₀ ν : Nat → F64}
    {C₀ C : CSrv} {R : Ren} {live : Nat → Prop} {s₀ s : St F.S}
    (inventory : BufferInventory notes ν₀ ν C₀ C R live s₀ s)
    (owner : Nat) (roles : List Byte) (selected : notes.owners owner = some roles)
    (kind : EltK) (role : Cell) (off count i : Nat) (inside : Nat.blt i count = true)
    (layout : (roles.drop (off + i * kind.size)).take kind.size = cellPartNotes kind role kind.size 0) :
    ∃ source target, typedGet F s₀ kind owner off count i = M.pure (some (.data (cellVal source) true true)) ∧
      typedGet F s kind (R.a owner) off count i = M.pure (some (.data (cellVal target) true true)) ∧
      role.valueRole.Holds ν₀ C₀ identity (cellVal source) ∧ role.valueRole.Holds ν C R (cellVal target) ∧
      Parametric.ValueR (NumberRoles ν₀ ν C₀ C) R (cellVal source) (cellVal target) := by
  obtain ⟨source,_,sourceRead,sourceRole⟩ := (inventory.source owner roles selected).typedGet F kind role off count i inside layout
  obtain ⟨target,_,targetRead,targetRole⟩ := (inventory.target owner roles selected).typedGet F kind role off count i inside layout
  exact ⟨source,target,sourceRead,targetRead,sourceRole,targetRole,Value.paired sourceRole targetRole⟩

end Host.Ts.Owned.Annotated
