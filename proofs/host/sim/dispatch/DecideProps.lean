import host.sim.dispatch.Base
namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim

/-! # Deciders for the property-access side conditions (steps/Props.lean)

`CellRead`, `TypedOK`, `OwnOK`, `ChainOK`, `LookupOK`, `PutOK`, `CellOK`,
`ElemsOK` and `StrictOK`. Keys that are neither indices nor `length` need nothing
along a prototype chain (`LookupOK.of_plain`), so the lookup decider tests that first. -/

def allB {α : Type} (f : α → Bool) : List α → Bool
  | [] => true
  | x :: xs => f x && allB f xs

theorem allB_sound {α : Type} {f : α → Bool} : ∀ {l : List α}, allB f l = true → ∀ x ∈ l, f x = true
  | [], _, _, hx => nomatch hx
  | y :: ys, h, x, hx => by
    simp only [allB, Bool.and_eq_true] at h
    rcases List.mem_cons.1 hx with rfl | hx
    · exact h.1
    · exact allB_sound h.2 x hx

def natAll (f : Nat → Bool) : Nat → Bool
  | 0 => true
  | m + 1 => f m && natAll f m

theorem natAll_sound {f : Nat → Bool} : ∀ {m : Nat}, natAll f m = true → ∀ j, j < m → f j = true
  | 0, _, j, hj => absurd hj (Nat.not_lt_zero j)
  | m + 1, h, j, hj => by
    simp only [natAll, Bool.and_eq_true] at h
    rcases Nat.lt_or_ge j m with hl | hl
    · exact natAll_sound h.2 j hl
    · have : j = m := by omega
      subst this; exact h.1

def intEqB : Int → Int → Bool
  | .ofNat a, .ofNat b => Nat.beq a b
  | .negSucc a, .negSucc b => Nat.beq a b
  | _, _ => false

theorem intEqB_sound {i j : Int} (h : intEqB i j = true) : i = j := by
  cases i <;> cases j <;> simp_all [intEqB]

section
variable {F : Ffi} (P : JSP F)

def byteFxB : Byte → Bool
  | .part _ (.big i) _ => bfB P i
  | _ => true

def cellBigB : Cell → Bool
  | .big i => bfB P i
  | _ => true

/-- `CellRead`. -/
def cellReadB (n : Nat) (k : EltK) (bs : List Byte) : Bool :=
  match readCell k bs with
  | none => true
  | some c => cellB n c && ((wholeCell k (bs.take k.size) k.size).isSome ||
      (allB (byteFxB P) (bs.take k.size) && cellBigB P c))

/-- A key that is neither an index nor `length`. -/
def plainKeyB (k : PKey) : Bool := (keyIndex k).isNone && !keyEq k kLength

/-- `TypedOK`. -/
def typedB (s : St F.S) (n : Nat) (o : Obj) (k : PKey) : Bool :=
  match o.kind with
  | .typed kk b off len => match keyIndex k with
    | some i => !(Nat.blt i len) || (match bufBytes F s b with
      | some bs => cellReadB P n kk (bs.drop (off + i * kk.size))
      | none => true)
    | none => true
  | _ => true

/-- `OwnOK`. -/
def ownB (s : St F.S) (n a : Nat) (o : Obj) (k : PKey) : Bool :=
  (frB P a || plainKeyB k) && typedB P s n o k

/-- `ChainOK`. -/
def chainB (s : St F.S) (n : Nat) (k : PKey) : Nat → Nat → Bool
  | 0, _ => true
  | f + 1, a => match s.obj? a with
    | some o => ownB P s n a o k && (match o.proto with
      | .obj b => chainB s n k f b
      | _ => true)
    | none => true

/-- `LookupOK`. -/
def lookupB (s : St F.S) (n : Nat) (recv : Val) (k : PKey) : Bool :=
  plainKeyB k || match recv with
    | .obj a => chainB P s n k 16 a
    | .str _ => chainB P s n k 16 aStringProto
    | v => match protoOf F s v with
      | some p => chainB P s n k 16 p
      | none => true

/-- `CellOK`. -/
def cellOKB : EltK → Val → Bool
  | .i64, .big i => bfB P i && bfB P (signed 64 (modInt i (2 ^ 64)))
  | .u64, .big i => bfB P i && bfB P ((modInt i (2 ^ 64) : Nat) : Int)
  | _, _ => true

/-- `PutOK`. -/
def putB (s : St F.S) (n : Nat) (recv : Val) (k : PKey) (v : Val) : Bool :=
  match recv with
  | .obj a => frB P a && (match s.obj? a with
    | some o => (match o.proto with
        | .obj p => plainKeyB k || chainB P s n k 16 p
        | _ => true) &&
      (match o.kind with
        | .typed kk _ _ _ => cellOKB P kk v
        | _ => true)
    | none => true)
  | _ => true

/-- `ElemsReadOK … 0` over a buffer's bytes. -/
def elemsReadB (n : Nat) (k : EltK) (off len : Nat) (bs : List Byte) : Bool :=
  natAll (fun j => cellReadB P n k (bs.drop (off + (0 + j) * k.size))) len

/-- `ElemsOK`. -/
def elemsB (s : St F.S) (n : Nat) (v : Val) : Bool :=
  match v with
  | .obj a => frB P a && (match s.obj? a with
    | some o => match o.kind with
      | .typed k b off len => match bufBytes F s b with
        | some bs => elemsReadB P n k off len bs
        | none => true
      | _ => true
    | none => true)
  | _ => true

/-- `StrictOK`. -/
def strictB : Val → Val → Bool
  | .big i, .big j => (bfB P i && bfB P j) || intEqB i j
  | .ptr (.ext r) _, .ptr (.ext r') _ => Nat.beq r r'
  | _, _ => true

end

/-! ## Soundness -/

section
variable {F : Ffi} {P : JSP F} {K : Ctx}

theorem Kp.byteFx (hK : Kp P K) {b : Byte} (h : byteFxB P b = true) : ByteFixed K b := by
  rcases b with _ | ⟨_, _ | i, _⟩ <;> simp only [ByteFixed] <;> first | trivial | exact hK.bf h

theorem Kp.cellBig (hK : Kp P K) {c : Cell} (h : cellBigB P c = true) : ∀ i, c = .big i → BigFixed K.lo K.hi i := by
  rintro i rfl; exact hK.bf h

theorem Kp.cellRead (hK : Kp P K) {A : Nat → Prop} {n : Nat} {k : EltK} {bs : List Byte} (h : cellReadB P n k bs = true) :
    CellRead K A n k bs := by
  intro c hc
  simp only [cellReadB, hc, Bool.and_eq_true, Bool.or_eq_true] at h
  refine ⟨cellB_sound h.1, ?_⟩
  rcases h.2 with h2 | ⟨h2, h3⟩
  · exact .inl h2
  · exact .inr ⟨fun b hb => hK.byteFx (allB_sound h2 b hb), hK.cellBig h3⟩

theorem plainKeyB_sound {k : PKey} (h : plainKeyB k = true) : keyIndex k = none ∧ keyEq k kLength = false := by
  simp only [plainKeyB, Bool.and_eq_true, Option.isNone_iff_eq_none, Bool.not_eq_true'] at h
  exact h

theorem Kp.typed (hK : Kp P K) {s : St F.S} {S : SSrv} {o : Obj} {k : PKey} (h : typedB P s S.tab.length o k = true) :
    TypedOK F K s S o k := by
  intro kk b off len i hk hi hil bs hb
  simp only [typedB, hk, hi] at h
  have hl : Nat.blt i len = true := by rw [Nat.blt_eq]; exact hil
  simp only [hl, Bool.not_true, Bool.false_or, hb] at h
  exact hK.cellRead h

theorem Kp.own (hK : Kp P K) {s : St F.S} {S : SSrv} {a : Nat} {o : Obj} {k : PKey} (h : ownB P s S.tab.length a o k = true) :
    OwnOK F K s S a o k := by
  simp only [ownB, Bool.and_eq_true, Bool.or_eq_true] at h
  refine ⟨?_, hK.typed h.2⟩
  rcases h.1 with h1 | h1
  · exact .inl (hK.fr_none h1)
  · exact .inr (plainKeyB_sound h1)

theorem Kp.chain (hK : Kp P K) {s : St F.S} {S : SSrv} {k : PKey} :
    ∀ {f a : Nat}, chainB P s S.tab.length k f a = true → ChainOK F K s S k f a
  | 0, _, _ => trivial
  | f + 1, a, h => by
    intro o ho
    simp only [chainB, ho, Bool.and_eq_true] at h
    refine ⟨hK.own h.1, fun b hb => ?_⟩
    simp only [hb] at h
    exact hK.chain h.2

theorem Kp.lookup (hK : Kp P K) {s : St F.S} {S : SSrv} {recv : Val} {k : PKey} (h : lookupB P s S.tab.length recv k = true) :
    LookupOK F K s S recv k := by
  cases hp : plainKeyB k
  · simp only [lookupB, hp, Bool.false_or] at h
    cases recv with
    | obj a => exact hK.chain h
    | str _ => exact hK.chain h
    | _ =>
      intro p hpp
      simp only [hpp] at h
      exact hK.chain h
  · have := plainKeyB_sound hp
    exact LookupOK.of_plain this.1 this.2 recv

theorem Kp.cellOK (hK : Kp P K) {kk : EltK} {v : Val} (h : cellOKB P kk v = true) : CellOK K kk v := by
  rcases kk with _ | _ | _ | _ | _ | _ | _ | _ | _ | _ <;>
    rcases v with _ | _ | _ | _ | i | _ | _ | _ | _ <;> simp only [CellOK] <;> try trivial
  all_goals simp only [cellOKB, Bool.and_eq_true] at h; exact ⟨hK.bf h.1, hK.bf h.2⟩

theorem Kp.put (hK : Kp P K) {s : St F.S} {S : SSrv} {recv : Val} {k : PKey} {v : Val}
    (h : putB P s S.tab.length recv k v = true) : PutOK F K s S recv k v := by
  rintro a rfl
  simp only [putB, Bool.and_eq_true] at h
  refine ⟨hK.fr_none h.1, fun o ho => ?_⟩
  simp only [ho, Bool.and_eq_true] at h
  refine ⟨fun p hp => ?_, fun kk b off n hk => ?_⟩
  · have h1 := h.2.1
    simp only [hp, Bool.or_eq_true] at h1
    rcases h1 with h1 | h1
    · have := plainKeyB_sound h1
      exact ChainOK.of_plain this.1 this.2 16 p
    · exact hK.chain h1
  · have h2 := h.2.2
    simp only [hk] at h2
    exact hK.cellOK h2

theorem Kp.elems (hK : Kp P K) {s : St F.S} {S : SSrv} {v : Val} (h : elemsB P s S.tab.length v = true) :
    ElemsOK F K s S v := by
  rintro a rfl
  simp only [elemsB, Bool.and_eq_true] at h
  refine ⟨hK.fr_none h.1, fun o ho k b off n hk j hj bs hb => ?_⟩
  simp only [ho, hk, hb] at h
  exact hK.cellRead (natAll_sound h.2 j hj)

theorem Kp.strict (hK : Kp P K) {x y : Val} (h : strictB P x y = true) : StrictOK K x y := by
  constructor
  · rintro i j rfl rfl
    simp only [strictB, Bool.or_eq_true, Bool.and_eq_true] at h
    rcases h with ⟨h1, h2⟩ | h
    · exact .inl ⟨hK.bf h1, hK.bf h2⟩
    · exact .inr (intEqB_sound h)
  · rintro r o r' o' rfl rfl
    simp only [strictB] at h
    exact Nat.eq_of_beq_eq_true h

end
end Host.Ts.Sim.Disp
