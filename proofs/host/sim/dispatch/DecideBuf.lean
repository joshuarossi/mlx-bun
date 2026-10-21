import host.sim.dispatch.DecideProps
namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim Host.Ts.Sim.BufSim

/-! # Deciders for the side conditions of steps/Buf.lean

`ReadOK`, `BigConvOK` with the map hypothesis `BigRange` of renamed handles stored
into 64-bit elements (by `NativeFacts.range`: every stored bigint in the handle
band is a present handle), `GetSide`, `SetSide` and the element conditions of
`new <TypedArray>(xs)`. -/

section
variable {F : Ffi} (P : JSP F)

def cellFxB : Cell → Bool
  | .num _ => true
  | .big i => bfB P i

def bufByteFxB : Byte → Bool
  | .lit _ => true
  | .part _ c _ => cellFxB P c

/-- `ReadOK`. -/
def readOKB (n : Nat) (k : EltK) (bs : List Byte) : Bool :=
  match readCell k bs with
  | none => true
  | some c => cellB n c && ((wholeCell k (bs.take k.size) k.size).isSome ||
      (allB (bufByteFxB P) (bs.take k.size) && cellFxB P c))

/-- In the renamed handle band. -/
def bandB (i : Int) : Bool :=
  match i with
  | .ofNat m => Nat.ble P.lo m && Nat.blt m P.hi
  | .negSucc _ => false

/-- `BigConvOK` of a stored bigint, and a present handle when it is in the band. -/
def convB (s : St F.S) (k : EltK) : Val → Bool
  | .big i => (bfB P i && (match toCellBig k i with
      | some c => cellFxB P c
      | none => true)) || (bandB P i && P.isHandle s.ffi i)
  | _ => true

/-- `GetSide`: both byte orders of the element are `ReadOK`. -/
def getSideB (s : St F.S) (n : Nat) (k : EltK) (this : Val) (args : List Val) : Bool :=
  bfVB P (arg args 1) && (match viewOf F s this with
    | some (b, off, _) => match bufBytes F s b with
      | some bs => match offsetP (arg args 0) with
        | some pos => readOKB P n k ((bs.drop (off + pos)).take k.size) &&
            readOKB P n k ((bs.drop (off + pos)).take k.size).reverse
        | none => true
      | none => true
    | none => true)

/-- `SetSide` and the handle range of the stored value. -/
def setSideB (s : St F.S) (k : EltK) (args : List Val) : Bool :=
  bfVB P (arg args 2) && convB P s k (arg args 1)

/-- Elements stored by `new <TypedArray>(xs)` (decided on the source run of `elemsOf`). -/
def ctorElemsB (s : St F.S) (S : SSrv) (k : EltK) (v : Val) : Bool :=
  match interpS (elemsOf F s v).run S with
  | some (some vs, _) => allB (convB P s k) vs
  | _ => true

end

section
variable {F : Ffi} {P : JSP F} {K : Ctx}

theorem Kp.cellFx (hK : Kp P K) {c : Cell} (h : cellFxB P c = true) : CellFixed K.lo K.hi c := by
  cases c with
  | num _ => trivial
  | big i => exact hK.bf h

theorem Kp.bufByteFx (hK : Kp P K) {b : Byte} (h : bufByteFxB P b = true) : BufSim.ByteFixed K.lo K.hi b := by
  cases b with
  | lit _ => trivial
  | part _ c _ => exact hK.cellFx h

theorem Kp.readOK (hK : Kp P K) {n : Nat} {k : EltK} {bs : List Byte} (h : readOKB P n k bs = true) :
    ReadOK K.lo K.hi n k bs := by
  intro c hc
  simp only [readOKB, hc, Bool.and_eq_true, Bool.or_eq_true] at h
  refine ⟨cellB_sound h.1, ?_⟩
  rcases h.2 with h2 | ⟨h2, h3⟩
  · exact .inl h2
  · exact .inr ⟨fun b hb => hK.bufByteFx (allB_sound h2 b hb), hK.cellFx h3⟩

theorem bandB_sound {i : Int} (h : bandB P i = true) : (P.lo : Int) ≤ i ∧ i < P.hi := by
  cases i with
  | ofNat m =>
    simp only [bandB, Bool.and_eq_true, Nat.ble_eq, Nat.blt_eq] at h
    simp only [Int.ofNat_eq_natCast]
    omega
  | negSucc _ => simp [bandB] at h

theorem not_band_of_fixed {lo hi : Nat} {i : Int} (h : BigFixed lo hi i) (h1 : (lo : Int) ≤ i) (h2 : i < hi) :
    False := by
  unfold BigFixed at h
  omega

theorem Kp.conv (hK : Kp P K) {s : St F.S} {k : EltK} {v : Val} (h : convB P s k v = true) :
    ∀ i, v = .big i → BigConvOK K k i := by
  rintro i rfl
  simp only [convB, Bool.or_eq_true, Bool.and_eq_true] at h
  rcases h with ⟨h1, h2⟩ | ⟨h1, _⟩
  · refine .inl ⟨hK.bf h1, fun c hc => ?_⟩
    simp only [hc] at h2
    exact hK.cellFx h2
  · have := bandB_sound h1
    unfold BigConvOK
    rw [hK.1, hK.2.1]
    exact .inr this

theorem convB_range {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {s t : St F.S}
    {S : SSrv} {C : CSrv} (hK : Kp P K) (hN : NativeFacts F FR P) (h : Rel F FR M ν K s S t C)
    {k : EltK} {v : Val} (hv : convB P s k v = true) :
    ∀ i, v = .big i → (K.lo : Int) ≤ i → i < K.hi → BigRange k (M.big i) := by
  rintro i rfl hlo hhi
  simp only [convB, Bool.or_eq_true, Bool.and_eq_true] at hv
  rcases hv with ⟨h1, _⟩ | ⟨_, h2⟩
  · exact absurd (hK.bf h1) (fun hf => not_band_of_fixed hf hlo hhi)
  · obtain ⟨r0, r1⟩ := hN.range M _ _ _ h.ffi i h2
    unfold BigRange
    refine ⟨r0, ?_⟩
    cases k <;> simp only <;> omega

theorem Kp.getSide (hK : Kp P K) {s : St F.S} {S : SSrv} {k : EltK} {this : Val} {args : List Val}
    (h : getSideB P s S.tab.length k this args = true) : GetSide F K s S k this args := by
  simp only [getSideB, Bool.and_eq_true] at h
  refine ⟨hK.bfBig h.1, fun b off n bs pos le hv hb hp => ?_⟩
  have h2 := h.2
  simp only [hv, hb, hp, Bool.and_eq_true] at h2
  cases le
  · exact hK.readOK h2.2
  · exact hK.readOK h2.1

theorem Kp.setSide (hK : Kp P K) {s : St F.S} {k : EltK} {args : List Val} (h : setSideB P s k args = true) :
    SetSide K k args := by
  simp only [setSideB, Bool.and_eq_true] at h
  exact ⟨hK.bfBig h.1, hK.conv h.2⟩

theorem setSideB_range {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {s t : St F.S}
    {S : SSrv} {C : CSrv} (hK : Kp P K) (hN : NativeFacts F FR P) (h : Rel F FR M ν K s S t C)
    {k : EltK} {args : List Val} (hv : setSideB P s k args = true) :
    ∀ i, arg args 1 = .big i → (K.lo : Int) ≤ i → i < K.hi → BigRange k (M.big i) := by
  simp only [setSideB, Bool.and_eq_true] at hv
  exact convB_range hK hN h hv.2

theorem Kp.ctorElems (hK : Kp P K) {s : St F.S} {S : SSrv} {k : EltK} {v : Val}
    (h : ctorElemsB P s S k v = true) :
    ∀ vs S1, interpS (elemsOf F s v).run S = some (some vs, S1) → ∀ i, Val.big i ∈ vs → BigConvOK K k i := by
  intro vs S1 hr i hi
  simp only [ctorElemsB, hr] at h
  exact hK.conv (allB_sound h _ hi) i rfl

theorem ctorElemsB_range {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {s t : St F.S}
    {S : SSrv} {C : CSrv} (hK : Kp P K) (hN : NativeFacts F FR P) (h : Rel F FR M ν K s S t C)
    {k : EltK} {v : Val} (hv : ctorElemsB P s S k v = true) :
    ∀ vs S1, interpS (elemsOf F s v).run S = some (some vs, S1) →
      ∀ i, Val.big i ∈ vs → (K.lo : Int) ≤ i → i < K.hi → BigRange k (M.big i) := by
  intro vs S1 hr i hi
  simp only [ctorElemsB, hr] at hv
  exact convB_range hK hN h (allB_sound hv _ hi) i rfl

end
end Host.Ts.Sim.Disp
