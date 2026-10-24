import host.sim.steps.All
import host.sim.Run
namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim

/-! # Parameters of the acceptance function and basic deciders

`JSP F` fixes what the checked run's acceptance function `okJS` needs beyond the
source state: the native-call acceptance `okCall` and smallness decider `smallB`
(of `FfiCallSim`), the renamed handle band
`[lo, hi)`, the framed addresses, two predicates on the source native state
that the native relation interprets (`isHandle`: a present native handle,
`isRegion`: a native region the map keeps apart), and the frames beyond framed arrays
the run may use (`wide`, none by default). `Kp P K` ties a run's `Ctx` to the
parameters, `Wp P W` its frames. Deciders are `Bool` functions with soundness lemmas
(`*_sound`); they use structural recursion and `Nat` primitives only. -/

structure JSP (F : Ffi) where
  okCall : F.S → Name → List Arg → Bool
  /-- The smallness decider of native calls (`FfiCallSim`), on the server after decoding. -/
  smallB : SSrv → F.S → Name → List Arg → Bool
  lo : Nat
  hi : Nat
  framed : List Nat
  isHandle : F.S → Int → Bool
  isRegion : F.S → Nat → Bool
  /-- Frames beyond framed arrays, by source address (`Wp`). -/
  wide : List (Nat × WFrame) := []

/-- The run's context agrees with the parameters. -/
def Kp {F : Ffi} (P : JSP F) (K : Ctx) : Prop :=
  K.lo = P.lo ∧ K.hi = P.hi ∧ ∀ a, K.fr a ≠ none ↔ a ∈ P.framed

def memB (a : Nat) : List Nat → Bool
  | [] => false
  | b :: l => Nat.beq a b || memB a l

theorem memB_iff (a : Nat) : ∀ l : List Nat, memB a l = true ↔ a ∈ l
  | [] => by simp [memB]
  | b :: l => by
    simp only [memB, Bool.or_eq_true, memB_iff a l, List.mem_cons]
    constructor
    · rintro (h | h)
      · exact .inl (Nat.eq_of_beq_eq_true h)
      · exact .inr h
    · rintro (h | h)
      · exact .inl (by subst h; exact Nat.beq_refl a)
      · exact .inr h

section
variable {F : Ffi} {P : JSP F} {K : Ctx}

/-- Address `a` is not framed. -/
def frB (P : JSP F) (a : Nat) : Bool := !memB a P.framed

theorem Kp.fr_none (hK : Kp P K) {a : Nat} (h : frB P a = true) : K.fr a = none := by
  have hm : ¬ a ∈ P.framed := by
    intro hm
    have := (memB_iff a P.framed).2 hm
    simp [frB, this] at h
  cases hf : K.fr a with
  | none => rfl
  | some p => exact absurd ((hK.2.2 a).1 (by simp [hf])) hm

theorem Kp.fr_some (hK : Kp P K) {a : Nat} (h : frB P a = false) : K.fr a ≠ none := by
  have hm : memB a P.framed = true := by simpa [frB] using h
  exact (hK.2.2 a).2 ((memB_iff a P.framed).1 hm)

/-- The frame the parameters declare at `a`. -/
def lookupW (a : Nat) : List (Nat × WFrame) → Option WFrame
  | [] => none
  | (b, w) :: l => bif Nat.beq a b then some w else lookupW a l

def wideAt (P : JSP F) (a : Nat) : Option WFrame := lookupW a P.wide

/-- The run's frames are among those the parameters declare. With none declared there are none
(`Wp.noWide`); every `P` admits no frames (`Wp.free`). -/
def Wp (P : JSP F) (W : Nat → Option WFrame) : Prop := ∀ a w, W a = some w → wideAt P a = some w

theorem Wp.free : Wp P noFrames := fun _ _ h => nomatch h

theorem Wp.none_of {W : Nat → Option WFrame} (hW : Wp P W) {a : Nat} (h : wideAt P a = none) : W a = none := by
  cases hw : W a with
  | none => rfl
  | some w => rw [hW a w hw] at h; cases h

theorem Wp.some_of {W : Nat → Option WFrame} (hW : Wp P W) {a : Nat} {w0 : WFrame} (h : wideAt P a = some w0)
    {w : WFrame} (hw : W a = some w) : w = w0 := by
  have := hW a w hw; rw [h] at this; cases this; rfl

/-- No frames are declared. -/
def noWideB (P : JSP F) : Bool := P.wide.isEmpty

theorem Wp.noWide {W : Nat → Option WFrame} (hW : Wp P W) (h : noWideB P = true) : ∀ a, W a = none := by
  intro a
  apply hW.none_of
  have : P.wide = [] := by
    unfold noWideB at h
    cases hl : P.wide with
    | nil => rfl
    | cons _ _ => rw [hl] at h; cases h
  show lookupW a P.wide = none
  rw [this]; rfl

/-- At `a` no frame is declared, or `a` is unframed. -/
def nwB (P : JSP F) (a : Nat) : Bool := (wideAt P a).isNone || frB P a

theorem Kp.nw {W : Nat → Option WFrame} (hK : Kp P K) (hW : Wp P W) {a : Nat} (h : nwB P a = true) :
    W a = none ∨ K.fr a = none := by
  simp only [nwB, Bool.or_eq_true, Option.isNone_iff_eq_none] at h
  rcases h with h | h
  · exact .inl (hW.none_of h)
  · exact .inr (hK.fr_none h)

/-- Kinds no frame admits (`¬ Wideable`). -/
def wideableB : Kind → Bool
  | .ordinary | .map _ | .box _ => true
  | _ => false

theorem wideableB_sound {k : Kind} (h : wideableB k = false) : ¬ Wideable k := by
  cases k <;> simp_all [wideableB, Wideable]

/-- `NoW`: `nwB`, or an object of a kind no frame admits. -/
def nwoB {S' : Type} (P : JSP F) (s : St S') (a : Nat) : Bool :=
  nwB P a || match s.obj? a with
    | some o => !wideableB o.kind
    | none => false

theorem Kp.noW {S' : Type} {s : St S'} {W : Nat → Option WFrame} (hK : Kp P K) (hW : Wp P W) {a : Nat}
    (h : nwoB P s a = true) : NoW K W s a := by
  simp only [nwoB, Bool.or_eq_true] at h
  rcases h with h | h
  · exact .of_or (hK.nw hW h)
  · cases ho : s.obj? a with
    | none => rw [ho] at h; cases h
    | some o =>
      rw [ho] at h
      simp only [Bool.not_eq_true'] at h
      exact .of_kind ho (wideableB_sound h)

/-- `2 ^ 56` as a literal. -/
def two56 : Nat := 72057594037927936

theorem two56_eq : two56 = 2 ^ 56 := by decide

def bigFixedB (lo hi : Nat) : Int → Bool
  | .ofNat n => Nat.blt n lo || (Nat.ble hi n && Nat.blt n two56)
  | .negSucc _ => true

theorem bigFixedB_sound {lo hi : Nat} {i : Int} (h : bigFixedB lo hi i = true) : BigFixed lo hi i := by
  unfold BigFixed
  cases i with
  | ofNat n =>
    simp only [bigFixedB, Bool.or_eq_true, Bool.and_eq_true, Nat.blt_eq, Nat.ble_eq, two56_eq] at h
    simp only [Int.ofNat_eq_natCast]
    rcases h with h | ⟨h1, h2⟩
    · exact .inr (.inl ⟨by omega, by omega⟩)
    · exact .inr (.inr ⟨by omega, by omega⟩)
  | negSucc n => exact .inl (Int.negSucc_lt_zero n)

/-- A bigint the map fixes, under the parameters. -/
def bfB (P : JSP F) (i : Int) : Bool := bigFixedB P.lo P.hi i

theorem Kp.bf (hK : Kp P K) {i : Int} (h : bfB P i = true) : BigFixed K.lo K.hi i := by
  rw [hK.1, hK.2.1]; exact bigFixedB_sound h

/-- `BigFixedV`. -/
def bfVB (P : JSP F) : Val → Bool
  | .big i => bfB P i
  | _ => true

theorem Kp.bfV (hK : Kp P K) {v : Val} (h : bfVB P v = true) : BigFixedV K v := by
  cases v <;> simp only [BigFixedV] <;> first | trivial | exact hK.bf h

theorem Kp.bfBig (hK : Kp P K) {v : Val} (h : bfVB P v = true) : ∀ i, v = .big i → BigFixed K.lo K.hi i := by
  rintro i rfl; exact hK.bf h

/-- `NumLitV`. -/
def litVB : Val → Bool
  | .num (.ref _) => false
  | _ => true

theorem litVB_sound {v : Val} (h : litVB v = true) : NumLitV v := by
  rcases v with _ | _ | _ | ⟨_ | _⟩ | _ | _ | _ | _ | _ <;> simp_all [litVB, NumLitV]

/-- Presence of a heap address. -/
def presB {S' : Type} (s : St S') (a : Nat) : Bool := (s.heap.get a).isSome

theorem presB_sound {S' : Type} {s : St S'} {a : Nat} (h : presB s a = true) : Present s a := h

/-- Every intrinsic address `1 … aFirst - 1` is present. -/
def intrB {S' : Type} (s : St S') : Nat → Bool
  | 0 => true
  | k + 1 => presB s (k + 1) && intrB s k

theorem intrB_sound {S' : Type} {s : St S'} : ∀ {m : Nat}, intrB s m = true → ∀ a, 0 < a → a ≤ m → Present s a
  | 0, _, a, h0, hm => absurd hm (by omega)
  | m + 1, h, a, h0, hm => by
    simp only [intrB, Bool.and_eq_true] at h
    rcases Nat.lt_or_ge a (m + 1) with hl | hl
    · exact intrB_sound h.2 a h0 (by omega)
    · have : a = m + 1 := by omega
      subst this; exact h.1

theorem intrB_aFirst {S' : Type} {s : St S'} (h : intrB s 39 = true) : ∀ a, 0 < a → a < aFirst → Present s a :=
  fun a h0 h1 => intrB_sound h a h0 (by simp [aFirst] at h1; omega)

/-- Supports of number references, cells, bytes and native call data (any address set). -/
def nvB (n : Nat) : NumV → Bool
  | .lit _ => true
  | .ref i => Nat.blt i n

theorem nvB_sound {A : Nat → Prop} {n : Nat} {x : NumV} (h : nvB n x = true) : Supp.nv A n x := by
  cases x <;> simp_all [nvB, Supp.nv]

def cellB (n : Nat) : Cell → Bool
  | .num x => nvB n x
  | .big _ => true

theorem cellB_sound {A : Nat → Prop} {n : Nat} {c : Cell} (h : cellB n c = true) : Supp.cell A n c := by
  cases c with
  | num x => exact nvB_sound (A := A) h
  | big _ => trivial

def byteB (n : Nat) : Byte → Bool
  | .lit _ => true
  | .part _ c _ => cellB n c

def bytesB (n : Nat) : List Byte → Bool
  | [] => true
  | b :: bs => byteB n b && bytesB n bs

theorem bytesB_sound {A : Nat → Prop} {n : Nat} : ∀ {bs : List Byte}, bytesB n bs = true → Supp.bytes A n bs
  | [], _ => fun _ hb => nomatch hb
  | b :: bs, h => by
    simp only [bytesB, Bool.and_eq_true] at h
    intro x hx
    rcases List.mem_cons.1 hx with rfl | hx
    · cases x with
      | lit _ => trivial
      | part _ c _ => exact cellB_sound h.1
    · exact bytesB_sound h.2 x hx

/-- `2 ^ 20` as a literal. -/
def two20 : Nat := 1048576

theorem le20 {m : Nat} (h : Nat.ble m two20 = true) : m ≤ 2 ^ 20 := by
  have := Nat.le_of_ble_eq_true h; simpa [two20] using this

/-- The room the allocation margin needs below the counter bound. -/
def nextMax : Nat := 2305843008139952128

theorem next_ok {s : St F.S} (h : Nat.blt s.next nextMax = true) : s.next + margin < Sim.bound := by
  have : s.next < nextMax := by simpa [Nat.blt_eq] using h
  simp only [nextMax] at this
  simp only [margin, Sim.bound]
  omega

end

/-! ## Facts of the map only the native relation knows

`NativeFacts` collects what the step lemmas assume of the map beyond `Rel`, stated
for source values that satisfy the native predicates of `P` on the source native
state `x` (the native relation `FR M n x y` will prove them). -/

structure NativeFacts (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (P : JSP F) : Prop where
  /-- Bigint images keep zeroness (`done` values of iterator results). -/
  zero : ∀ M n x y, FR M n x y → ∀ i, (M.big i == 0) = (i == 0)
  /-- A present handle's image differs from the images of other present handles and of the
  fixed bigints below the band (negative or in `[0, lo)`; not those in `[hi, 2 ^ 56)`, which the
  target's growing handle counter eventually reaches). -/
  inj : ∀ M n x y, FR M n x y → ∀ i j : Int, P.isHandle x i = true →
    ((j < 0 ∨ (0 ≤ j ∧ j < (P.lo : Int))) ∨ P.isHandle x j = true) → M.big i = M.big j → i = j
  /-- Accepted native regions have distinct images. -/
  region : ∀ M n x y, FR M n x y → ∀ r r', P.isRegion x r = true → P.isRegion x r' = true →
    M.region r = M.region r' → r = r'
  /-- Present handles have images in the range of 64-bit elements. -/
  range : ∀ M n x y, FR M n x y → ∀ i, P.isHandle x i = true → 0 ≤ M.big i ∧ M.big i < 2 ^ 63
  /-- Host memory regions (`4 h + 3`, below the `JSCallback` regions) are fixed. -/
  host : ∀ M n x y, FR M n x y → ∀ r, r % 4 = 3 → r < cbBase → M.region r = r
  /-- `JSCallback` regions follow their objects. -/
  cb : ∀ M n x y, FR M n x y → ∀ f, cbBase ≤ f → M.region f = cbBase + M.a (f - cbBase)

/-! ## Steps that read no frame below the source's own

Under a target-only stack base (`RelB … stk`, caller frames the source does not hold) a step is
simulated when it reads none of the frames below the source's: `localB s`. No return or
abrupt completion reaches an empty source stack (that step would run a job or halt on the source
and return into the caller's frames on the target), a function boundary is among the frames (the
scans `nearestGen`, `ctorTop`, `fnTop` stop there), and a `using` declaration has a scope frame
below it (`addUsing`). `splitSusp`, which stops only at suspension boundaries, needs no condition:
a source that finds none fails. A stage template runs from its call state (empty stack, a call
control) to its return state (empty stack, a return or abrupt control); every state between has
its callee's boundary among its frames. -/

/-- The source step reads no frame below the source's own. -/
def localB {S' : Type} (s : St S') : Bool :=
  (match s.stack with
    | [] => match s.ctl with
      | .ret _ => false
      | .abr _ => false
      | _ => true
    | fs => fnB fs) &&
  (match s.stack with
    | .s (.decl k _ _ _) :: fs => !isUsing k || StmtSim.scopeB fs
    | _ => true)

theorem localB_nil_ret {S' : Type} {s : St S'} (h : localB s = true) (hs : s.stack = []) {v : Val}
    (hc : s.ctl = .ret v) : False := by
  simp [localB, hs, hc] at h

theorem localB_nil_abr {S' : Type} {s : St S'} (h : localB s = true) (hs : s.stack = []) {a : Abrupt}
    (hc : s.ctl = .abr a) : False := by
  simp [localB, hs, hc] at h

/-- Below a top frame that is no function boundary there is one. -/
theorem localB_tail {S' : Type} {s : St S'} (h : localB s = true) {f : Frame} {fs : List Frame}
    (hs : s.stack = f :: fs) (hf : isFnF f = false) : fnB fs = true := by
  simp only [localB, hs, Bool.and_eq_true] at h
  have := h.1
  simpa [fnB, List.any_cons, hf] using this

theorem localB_ne {S' : Type} {s : St S'} (h : localB s = true) {f : Frame} {fs : List Frame}
    (hs : s.stack = f :: fs) (hf : isFnF f = false) : fs ≠ [] := by
  have := localB_tail h hs hf
  intro he; subst he; simp [fnB] at this

/-- A `using` declaration has a scope frame below it. -/
theorem localB_using {S' : Type} {s : St S'} (h : localB s = true) {k : DeclKind} {p : Pat}
    {rest : List (Pat × Option Expr)} {env : Env} {fs : List Frame} (hs : s.stack = .s (.decl k p rest env) :: fs)
    (hk : isUsing k = true) : StmtSim.scopeB fs = true := by
  simp only [localB, hs, Bool.and_eq_true] at h
  simpa [hk] using h.2

/-! ## The postcondition of the dispatcher -/

/-- A step lemma's postcondition with `RelXF` for the resulting states. -/
def PX (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (W : Nat → Option WFrame) (stk : List Frame) (M : Map)
    (ν : Nat → F64) (K : Ctx) (S : SSrv) (C : CSrv) : Map → SSrv → CSrv → St F.S → St F.S → Prop :=
  fun M' S' C' s1 t1 => Grow M ν S C M' S' C' ∧ RelXB F FR W stk M' ν K s1 S' t1 C'

theorem MSim.toX {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
    {S : SSrv} {C : CSrv} {m m' : Host.Ts.M (St F.S)} (h : MSim (StepPostB F FR W stk M ν K S C) S C m m') :
    MSim (PX F FR W stk M ν K S C) S C m m' :=
  MSim.mono h fun _ _ _ _ _ hp => ⟨hp.1, .inl hp.2⟩

theorem MSim.toXD {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
    {S : SSrv} {C : CSrv} {m m' : Host.Ts.M (St F.S)}
    (h : MSim (fun M' S' C' s1 t1 => Grow M ν S C M' S' C' ∧ RelDB F FR W stk M' ν K s1 S' t1 C') S C m m') :
    MSim (PX F FR W stk M ν K S C) S C m m' :=
  MSim.mono h fun _ _ _ _ _ hp => ⟨hp.1, .inr hp.2⟩

end Host.Ts.Sim.Disp
