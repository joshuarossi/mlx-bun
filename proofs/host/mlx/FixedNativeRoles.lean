import host.mlx.NativeSymbol

set_option Elab.async false

namespace Host.Ts.Owned.Annotated
open Host.Ts.Owned.Parametric

/-- Fixed argument occurrences distinguish resource handles from integer data. -/
inductive FixedArgument where
  | pointer (address off : Nat)
  | handle (handle : Nat)
  | integer (value : Int)
  | literal (value : F64)

def FixedArgument.role : FixedArgument → Value
  | .pointer b off => .ptr (.js b) off
  | .handle h => .handle h
  | .integer i => .ordinaryBig i
  | .literal x => .literal (.lit x)

def FixedArgument.value (R : Ren) : FixedArgument → Val
  | .pointer b off => .ptr (.js (R.a b)) off
  | .handle h => .big (Int.ofNat (R.handle h))
  | .integer i => .big i
  | .literal x => .num (.lit x)

theorem FixedArgument.exact {ν : Nat → F64} {C : CSrv} {R : Ren} {r : FixedArgument} {v : Val}
    (h : r.role.Holds ν C R v) : v = r.value R := by
  cases r <;> cases h
  all_goals try rfl
  case literal.literal x y hy =>
    have he : y = x := Option.some.inj hy
    rw [he]
    rfl

theorem FixedArgument.list_exact {ν : Nat → F64} {C : CSrv} {R : Ren}
    (roles : List FixedArgument) {values : List Val}
    (h : ListR (fun r v => r.role.Holds ν C R v) roles values) : values = roles.map (·.value R) := by
  induction roles generalizing values with
  | nil => cases h; rfl
  | cons r rs ih => cases h with
    | cons hv ht => rw [FixedArgument.exact hv,ih ht]; rfl

inductive FixedCell where
  | literal (value : F64)
  | integer (value : Int)

def FixedCell.role : FixedCell → Cell
  | .literal x => .literal (.lit x)
  | .integer i => .ordinaryBig i

def FixedCell.value : FixedCell → Host.Ts.Cell
  | .literal x => .num (.lit x)
  | .integer i => .big i

theorem FixedCell.exact {ν : Nat → F64} {C : CSrv} {R : Ren} {r : FixedCell} {v : Host.Ts.Cell}
    (h : r.role.Holds ν C R v) : v = r.value := by
  cases r <;> cases h
  case literal.literal x y hy =>
    have he : y = x := Option.some.inj hy
    rw [he]
    rfl
  case integer.ordinaryBig i => rfl

theorem FixedCell.holds (ν : Nat → F64) (C : CSrv) (R : Ren) (r : FixedCell) :
    r.role.Holds ν C R r.value := by
  cases r with
  | literal x => exact .literal _ _ rfl
  | integer i => exact .ordinaryBig i

inductive FixedByte where
  | literal (value : Nat)
  | part (kind : EltK) (cell : FixedCell) (index : Nat)

def FixedByte.role : FixedByte → Byte
  | .literal n => .lit n
  | .part k c i => .part k c.role i

def FixedByte.value : FixedByte → Host.Ts.Byte
  | .literal n => .lit n
  | .part k c i => .part k c.value i

theorem FixedByte.exact {ν : Nat → F64} {C : CSrv} {R : Ren} {r : FixedByte} {v : Host.Ts.Byte}
    (h : r.role.Holds ν C R v) : v = r.value := by
  cases r <;> cases h
  case literal.lit n => rfl
  case part.part k c i v hv => rw [FixedCell.exact hv]; rfl

theorem FixedByte.holds (ν : Nat → F64) (C : CSrv) (R : Ren) (r : FixedByte) :
    r.role.Holds ν C R r.value := by
  cases r with
  | literal n => exact .lit n
  | part k c i => exact .part _ _ _ _ (c.holds ν C R)

def fixedBufferRole (bytes : List FixedByte) : Tree :=
  .node "Kind.buf" [.node "List" (bytes.map (.byte ∘ FixedByte.role))]

private theorem fixedBuffer_fields_exact {ν : Nat → F64} {C : CSrv} {R : Ren}
    (roles : List FixedByte) (bytes : List Host.Ts.Byte)
    (h : ForestHolds ν C R (roles.map (.byte ∘ FixedByte.role)) (bytes.map Encode.byte)) :
    bytes = roles.map FixedByte.value := by
  induction roles generalizing bytes with
  | nil => cases bytes <;> cases h; rfl
  | cons r rs ih =>
    cases bytes with
    | nil => cases h
    | cons b bs => cases h with
      | cons hb ht => cases hb with
        | byte hb => rw [FixedByte.exact hb,ih bs ht]; rfl

theorem fixedBuffer_exact {ν : Nat → F64} {C : CSrv} {R : Ren} {roles : List FixedByte} {bytes : List Host.Ts.Byte}
    (h : (fixedBufferRole roles).Holds ν C R (Encode.kind (.buf bytes))) : bytes = roles.map FixedByte.value := by
  cases h with | node tag fs =>
    cases fs with | cons hb fs =>
      cases hb with | node tag hbs => exact fixedBuffer_fields_exact roles bytes hbs

theorem fixedBuffer_holds (ν : Nat → F64) (C : CSrv) (R : Ren) (roles : List FixedByte) :
    (fixedBufferRole roles).Holds ν C R (Encode.kind (.buf (roles.map FixedByte.value))) := by
  refine .node _ (.cons (.node _ ?_) .nil)
  induction roles with
  | nil => exact .nil
  | cons r rs ih => exact .cons (.byte (r.holds ν C R)) ih

def fixedI32Parts (value : Int) (n : Nat) (start : Nat) : List FixedByte :=
  match n with
  | 0 => []
  | n+1 => .part .i32 (.literal (F64.ofInt value)) start :: fixedI32Parts value n (start+1)

def fixedI32 (values : List Int) : List FixedByte := values.flatMap (fun i => fixedI32Parts i 4 0)

theorem fixedI32Parts_value (value : Int) (n start : Nat) :
    (fixedI32Parts value n start).map FixedByte.value =
      cellParts .i32 (.num (.lit (F64.ofInt value))) n start := by
  induction n generalizing start with
  | zero => rfl
  | succ n ih => exact congrArg (_ :: ·) (ih (start+1))

end Host.Ts.Owned.Annotated

namespace Host.Ts.Owned.Parametric

def callArguments (c : Ctl) : List Val := match c with | .call _ _ args => args | _ => []

theorem string_values_exact {NR : NumV → NumV → Prop} {R : Ren} (names : List Name) {values : List Val}
    (h : ListR (ValueR NR R) (names.map Val.str) values) : values = names.map Val.str := by
  induction names generalizing values with
  | nil => cases h; rfl
  | cons n ns ih => cases h with
    | cons hv ht => cases hv; rw [ih ht]; rfl

theorem StateR.read_fixed_buffer {S : Type} {ν₀ ν : Nat → F64} {C₀ C : CSrv}
    {FR : Ren → S → S → Prop} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St S}
    (h : StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (a : Nat) (o₀ : Obj) (bytes : List Byte) (roles : List Annotated.FixedByte)
    (hl : live a) (ho : s₀.heap.get a = some (.obj o₀)) (hk : o₀.kind = .buf bytes)
    (role : (Annotated.fixedBufferRole roles).Holds ν C R (objectKindAt s (R.a a))) :
    ∃ o, s.heap.get (R.a a) = some (.obj o) ∧ o.kind = .buf (roles.map Annotated.FixedByte.value) ∧
      ObjectR (NumberRoles ν₀ ν C₀ C) R o₀ o ∧ treeSupport live (Encode.obj o₀) ∧
      ListR (ByteR (NumberRoles ν₀ ν C₀ C) R) bytes (roles.map Annotated.FixedByte.value) := by
  obtain ⟨o,ho',hr,hs⟩ := h.heap.readObject a o₀ hl (h.heap.buffer_notFramed a o₀ bytes hl ho hk) ho
  have hkind := hr.kind
  rw [hk] at hkind
  obtain ⟨bs,hkind,hbytes⟩ := kind_buffer hkind
  have hh : (Annotated.fixedBufferRole roles).Holds ν C R (Encode.kind (.buf bs)) := by
    simpa only [objectKindAt,St.obj?,ho',hkind] using role
  have he := Annotated.fixedBuffer_exact hh
  subst bs
  exact ⟨o,ho',hkind,hr,hs,hbytes⟩

end Host.Ts.Owned.Parametric
