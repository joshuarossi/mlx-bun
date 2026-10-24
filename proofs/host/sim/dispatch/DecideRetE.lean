import host.sim.dispatch.DecideExpr
namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim

/-! # Deciders for the side conditions of steps/RetE.lean

`BinOK` (with `BinBigOK`/`BigResOK`), `UnBigOK`, `ElemAtOK`, `GetIndexOK`, and the
map hypothesis `BinMapOK`/`EqMapOK` of equality operators, which follows from
`NativeFacts` when every compared bigint is fixed or a present handle and every
compared native region is equal or accepted by `isRegion`. -/

section
variable {F : Ffi} (P : JSP F)

def bigResB (op : BinOp) : Val → Val → Bool
  | .big x, .big y => match bigOpRes op x y with
    | some r => bfB P r
    | none => true
  | _, _ => true

/-- `BinOK`. -/
def binB (s : St F.S) (n : Nat) (op : BinOp) (a b : Val) : Bool :=
  match op with
  | .seq | .sne | .eq | .ne => true
  | .inst => lookupB P s n b kPrototype && (match a with
    | .obj x => noWideB P || chainNoWB P s 64 x
    | _ => true)
  | .in_ => litVB a && bfVB P a && (match keyOfVal a with
    | some key => lookupB P s n b key
    | none => true)
  | _ => bfVB P a && bfVB P b && bigResB P op a b

/-- A bigint below the handle band: negative or in `[0, lo)`. -/
def lowB (i : Int) : Bool :=
  match i with
  | .ofNat m => Nat.blt m P.lo
  | .negSucc _ => true

/-- A bigint the image of a present handle is kept apart from (`NativeFacts.inj`): a bigint below
the band or a present handle. -/
def apartB (s : St F.S) (i : Int) : Bool := lowB P i || P.isHandle s.ffi i

/-- `EqMapOK` by `NativeFacts`. -/
def eqMapB (s : St F.S) : Val → Val → Bool
  | .big i, .big j => intEqB i j || (bfB P i && bfB P j) || (P.isHandle s.ffi i && apartB P s j) ||
      (P.isHandle s.ffi j && apartB P s i)
  | .ptr (.ext r) _, .ptr (.ext r') _ => Nat.beq r r' || (P.isRegion s.ffi r && P.isRegion s.ffi r')
  | _, _ => true

/-- `BinMapOK` by `NativeFacts`. -/
def binMapB (s : St F.S) (op : BinOp) (a b : Val) : Bool :=
  match op with
  | .seq | .sne | .eq | .ne => eqMapB P s a b
  | _ => true

/-- `UnBigOK`. -/
def unB : UnOp → Val → Bool
  | .neg, .big i => bfB P i && bfB P (-i)
  | .bnot, .big i => bfB P i && bfB P (-(i + 1))
  | .not, v => bfVB P v
  | _, _ => true

/-- `ElemAtOK`. -/
def elemAtB (s : St F.S) (n : Nat) (o : Val) (i : Nat) : Bool :=
  match o with
  | .obj a => match s.obj? a with
    | some ob => match ob.kind with
      | .array _ => frB P a
      | .typed kk b off len => !(Nat.blt i len) || (match bufBytes F s b with
        | some bs => cellReadB P n kk (bs.drop (off + i * kk.size))
        | none => true)
      | k => !wideableB k || frB P a
    | none => true
  | _ => true

/-- `PrivOK`. -/
def privB (s : St F.S) (o : Val) (nm : Name) : Bool :=
  match o with
  | .obj a => nwoB P s a || (match wideAt P a with
    | some (.fields _ ps) => allB (fun p => !nameEq nm p.2) ps
    | _ => false)
  | _ => true

/-- `typeof` of an object: `NoW` at it. -/
def tyB (s : St F.S) : UnOp → Val → Bool
  | .typeof, .obj a => nwoB P s a
  | _, _ => true

/-- `GetIndexOK`. -/
def getIndexB (s : St F.S) (n : Nat) (o k : Val) : Bool :=
  litVB k && bfVB P k && (match numIndex k with
    | some i => elemAtB P s n o i && lookupB P s n o (.str (F64.natStr i))
    | none => match keyOfVal k with
      | some key => lookupB P s n o key
      | none => true)

end

section
variable {F : Ffi} {P : JSP F} {K : Ctx} {W : Nat → Option WFrame} {stk : List Frame}

theorem Kp.bigRes (hK : Kp P K) {op : BinOp} {a b : Val} (h : bigResB P op a b = true) : BigResOK K op a b := by
  rcases a with _ | _ | _ | _ | x | _ | _ | _ | _ <;> rcases b with _ | _ | _ | _ | y | _ | _ | _ | _ <;>
    simp only [BigResOK] <;> try trivial
  simp only [bigResB] at h
  revert h
  cases bigOpRes op x y with
  | none => intro _; trivial
  | some r => intro h; exact hK.bf h

theorem Kp.bin (hK : Kp P K) (hW : Wp P W) {s : St F.S} {S : SSrv} {op : BinOp} {a b : Val}
    (h : binB P s S.tab.length op a b = true) : BinOK F K W s S op a b := by
  cases op <;> simp only [binB, Bool.and_eq_true] at h <;> simp only [BinOK, BinBigOK] <;>
    first
    | trivial
    | exact ⟨hK.bfV h.1.1, hK.bfV h.1.2, hK.bigRes h.2⟩
    | skip
  -- `instanceof`
  · refine ⟨hK.lookup hW h.1, fun x hx => ?_⟩
    have h2 := h.2
    subst hx
    simp only [Bool.or_eq_true] at h2
    rcases h2 with h2 | h2
    · exact ChainNoW.of_none (hW.noWide h2) 64 x
    · exact hK.chainNoW hW h2
  -- `in`
  · refine ⟨litVB_sound h.1.1, hK.bfV h.1.2, fun key hk => ?_⟩
    have h2 := h.2
    simp only [hk] at h2
    exact hK.lookup hW h2

theorem apartB_sound {s : St F.S} {i : Int} (h : apartB P s i = true) :
    (i < 0 ∨ (0 ≤ i ∧ i < P.lo)) ∨ P.isHandle s.ffi i = true := by
  simp only [apartB, Bool.or_eq_true] at h
  rcases h with h | h
  · refine .inl ?_
    cases i with
    | ofNat m =>
      simp only [lowB, Nat.blt_eq] at h
      simp only [Int.ofNat_eq_natCast]
      omega
    | negSucc m => exact .inl (Int.negSucc_lt_zero m)
  · exact .inr h

theorem eqMapB_sound {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {s t : St F.S}
    {S : SSrv} {C : CSrv} (hK : Kp P K) (hN : NativeFacts F FR P) (h : RelB F FR W stk M ν K s S t C)
    {a b : Val} (hb : eqMapB P s a b = true) : EqMapOK M a b := by
  constructor
  · rintro i j rfl rfl hij
    simp only [eqMapB, Bool.or_eq_true, Bool.and_eq_true] at hb
    rcases hb with ((hb | ⟨hi, hj⟩) | ⟨hi, hj⟩) | ⟨hj, hi⟩
    · exact intEqB_sound hb
    · rw [h.bigFixed i (hK.bf hi), h.bigFixed j (hK.bf hj)] at hij; exact hij
    · exact hN.inj M _ _ _ h.ffi i j hi (apartB_sound hj) hij
    · exact (hN.inj M _ _ _ h.ffi j i hj (apartB_sound hi) hij.symm).symm
  · rintro r o r' o' rfl rfl hr
    simp only [eqMapB, Bool.or_eq_true, Bool.and_eq_true] at hb
    rcases hb with hb | ⟨h1, h2⟩
    · exact Nat.eq_of_beq_eq_true hb
    · exact hN.region M _ _ _ h.ffi r r' h1 h2 hr

theorem binMapB_sound {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {s t : St F.S}
    {S : SSrv} {C : CSrv} (hK : Kp P K) (hN : NativeFacts F FR P) (h : RelB F FR W stk M ν K s S t C)
    {op : BinOp} {a b : Val} (hb : binMapB P s op a b = true) : BinMapOK M op a b := by
  cases op <;> simp only [binMapB] at hb <;> simp only [BinMapOK] <;>
    first | trivial | exact eqMapB_sound hK hN h hb

theorem Kp.un (hK : Kp P K) {op : UnOp} {v : Val} (h : unB P op v = true) : UnBigOK K op v := by
  rcases op with _ | _ | _ | _ | _ | _ | _ <;> rcases v with _ | _ | _ | _ | i | _ | _ | _ | _ <;>
    simp only [UnBigOK] <;> first
    | trivial
    | (simp only [unB, Bool.and_eq_true] at h; exact ⟨hK.bf h.1, hK.bf h.2⟩)
    | (simp only [unB] at h; exact hK.bfV h)

theorem Kp.elemAt (hK : Kp P K) {s : St F.S} {S : SSrv} {o : Val} {i : Nat}
    (h : elemAtB P s S.tab.length o i = true) : ElemAtOK F K s S o i := by
  rintro a rfl ob hob
  simp only [elemAtB, hob] at h
  refine ⟨?_, ?_, ?_⟩
  · intro es hk
    simp only [hk] at h
    exact hK.fr_none h
  · intro hw
    revert h hw
    cases ob.kind <;> intro h hw <;> first | exact hw.elim | (simp [wideableB] at h; exact hK.fr_none h)
  · intro kk b off n hk hi bs hb
    simp only [hk] at h
    have hl : Nat.blt i n = true := by rw [Nat.blt_eq]; exact hi
    simp only [hl, Bool.not_true, Bool.false_or, hb] at h
    exact hK.cellRead h

theorem Kp.priv (hK : Kp P K) (hW : Wp P W) {s : St F.S} {o : Val} {nm : Name} (h : privB P s o nm = true) :
    PrivOK K W s o nm := by
  rintro a rfl
  simp only [privB, Bool.or_eq_true] at h
  rcases h with h | h
  · exact .inl (hK.noW hW h)
  · cases hwa : W a with
    | none => exact .inl (.inl hwa)
    | some w =>
      cases hp : wideAt P a with
      | none => rw [hW.none_of hp] at hwa; cases hwa
      | some w0 =>
        rw [hp] at h
        have e := hW.some_of hp hwa
        subst e
        cases w with
        | fields ks ps =>
          exact .inr ⟨ks, ps, rfl, fun b0 n0 hm => by simpa using allB_sound h (b0, n0) hm⟩
        | _ => cases h

theorem Kp.ty (hK : Kp P K) (hW : Wp P W) {s : St F.S} {op : UnOp} {v : Val} (h : tyB P s op v = true) :
    op = .typeof → ∀ a, v = .obj a → NoW K W s a := by
  rintro rfl a rfl
  exact hK.noW hW h

theorem Kp.getIndex (hK : Kp P K) (hW : Wp P W) {s : St F.S} {S : SSrv} {o k : Val}
    (h : getIndexB P s S.tab.length o k = true) : GetIndexOK F K W s S o k := by
  simp only [getIndexB, Bool.and_eq_true] at h
  refine ⟨litVB_sound h.1.1, hK.bfV h.1.2, ?_⟩
  have h2 := h.2
  cases hi : numIndex k with
  | some i =>
    simp only [hi, Bool.and_eq_true] at h2
    exact ⟨hK.elemAt h2.1, hK.lookup hW h2.2⟩
  | none =>
    simp only [hi] at h2
    intro key hk
    simp only [hk] at h2
    exact hK.lookup hW h2

end
end Host.Ts.Sim.Disp
