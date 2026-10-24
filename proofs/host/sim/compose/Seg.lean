import host.sim.world.Route
import host.sim.compose.Shape
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Prefill

/-! # The halting chains from pieces (gen-plan T8, G7)

A2's world layer takes a halt as a halting chain (`HaltSegW`, a `SegChain` under its laws); the decode
loop's cases are chains of cut steps (`host.sim.compose.Iter`).

* `SPiece`: a segment piece between two template boundaries, at every list of remaining
  readbacks, consuming its oracle `O` from the head of the server's oracle (the rest is left for
  the next piece), so the same piece serves every case whose chain passes through it;
  `SPiece.cons` puts it before a chain.
* **A halting chain** of two or four pieces (`Halt2W`, `Halt4W`) with its end facts (`HaltEndW`) is a
  `HaltSegW` at every list of remaining readbacks (`Halt2W.seg`, `Halt4W.seg`): the exit at an EOS
  read at a loop cut (`rb`, the stop), the final chains from the final template start (`rb`, the
  clear of token `T - 1`, `rb`, the clear of token `T` and the loop's end; the EOS final chains end
  at the stop instead), a short path's halt from its cut. `StopAtW`: the end state's finish reason
  (`HaltStopSrc` of every such chain). -/

section Piece
variable {F : Ffi}

/-- **A segment piece** under the laws `L` and the native relations `FR r` (by the remaining
readbacks `r`) with frames `W`: from `(s, tab)` under the entry predicate `Q` to `(s', tab')` under
`Q'` in `n` target steps, consuming its oracle `O` from the head of the server's oracle. -/
structure SPiece (L : SegLaws F) (FR : List NumV → Map → Nat → F.S → F.S → Prop) (W : Nat → Option WFrame)
    (s : St F.S) (tab : List SymE) (Q : (Nat → F64) → Ctx → Prop) (s' : St F.S) (tab' : List SymE)
    (Q' : (Nat → F64) → Ctx → Prop) where
  n : Nat
  O : List Ans
  len : tab.length ≤ tab'.length
  sim : ∀ r rest, PieceSim L (relQW F (FR r) W Q) (relQW F (FR r) W Q') n s ⟨tab, O ++ rest⟩ s' ⟨tab', rest⟩

/-- A piece before a chain. -/
def SPiece.cons {L : SegLaws F} {FR : List NumV → Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame}
    {s : St F.S} {tab : List SymE} {Q : (Nat → F64) → Ctx → Prop} {s' : St F.S} {tab' : List SymE}
    {Q' : (Nat → F64) → Ctx → Prop} (p : SPiece L FR W s tab Q s' tab' Q') (r : List NumV) {rest : List Ans}
    {R'' : SRel F} {s'' : St F.S} {S'' : SSrv} (c : SegChain L (relQW F (FR r) W Q') s' ⟨tab', rest⟩ R'' s'' S'') :
    SegChain L (relQW F (FR r) W Q) s ⟨tab, p.O ++ rest⟩ R'' s'' S'' :=
  .cons p.n (p.sim r rest) p.len c

end Piece

/-! ## Halting chains -/

section Halt
variable {Wd : World} {A : Addr} {P : Wd.Par} {W : Nat → Option WFrame}

variable (Wd A P W) in
/-- **A halting chain's end facts** at `(sF, SF)` under the predicate `QE`: the halt, the `emitted`
array (the template's `s0`'s with `xs` appended) and its binding's cell. -/
structure HaltEndW (s0 : St Wd.F.S) (xs : List Val) (sF : St Wd.F.S) (SF : SSrv) (QE : (Nat → F64) → Ctx → Prop) :
    Prop where
  halt : ∀ r x, relQW Wd.F (Wd.R P r) W QE x sF SF → ∃ v, x.t.ctl = .halt (.normal v)
  emitG : ∃ o, sF.heap.get A.emit = some (.obj o) ∧ o.kind = .array (arrOf s0 A.emit ++ xs)
  cell : sF.cell? A.cE = some (some (.obj A.emit))

/-- **A halting chain from a chain of pieces** and its end facts. -/
def haltSegOf {s0 st0 : St Wd.F.S} {tab1 : List SymE} {xs : List Val} (r : List NumV) {O : List Ans}
    {QA QE : (Nat → F64) → Ctx → Prop} {sF : St Wd.F.S} {SF : SSrv}
    (ch : SegChain (haltLawsW Wd A) (relQW Wd.F (Wd.R P r) W QA) st0 ⟨tab1, O⟩ (relQW Wd.F (Wd.R P r) W QE) sF SF)
    (e : HaltEndW Wd A P W s0 xs sF SF QE) : HaltSegW Wd A W P r s0 st0 tab1 xs where
  S0 := ⟨tab1, O⟩
  tab := rfl
  QA := QA
  case := ⟨relQW Wd.F (Wd.R P r) W QE, sF, SF, ch, fun x hx => e.halt r x hx⟩
  QF := QE
  rend := fun _ _ _ h => h
  emitG := e.emitG
  cell := e.cell

/-- The finish reason at a halting chain's end state `sF` (`HaltStopSrc`'s facts). -/
def StopAtW (W : Nat → Option WFrame) (A : Addr) (sF : St Wd.F.S) : Prop :=
  W A.gen = none ∧ ∃ g w, sF.cell? A.gen = some (some (.obj g)) ∧ W g = none ∧
    ownW sF (.obj g) chars!"stats" = some (.obj w) ∧ W w = none ∧
    ownW sF (.obj w) chars!"finishReason" = some (.str chars!"stop")

variable (Wd A P W) in
/-- **A halting chain of two pieces** (an EOS read at a cut and the stop; a short path's halt): from
`(st0, tab1)` under `QA`, `p1`, `p2`, its end facts. -/
structure Halt2W (s0 st0 : St Wd.F.S) (tab1 : List SymE) (xs : List Val) where
  QA : (Nat → F64) → Ctx → Prop
  s1 : St Wd.F.S
  t1 : List SymE
  Q1 : (Nat → F64) → Ctx → Prop
  sE : St Wd.F.S
  tE : List SymE
  QE : (Nat → F64) → Ctx → Prop
  p1 : SPiece (haltLawsW Wd A) (Wd.R P) W st0 tab1 QA s1 t1 Q1
  p2 : SPiece (haltLawsW Wd A) (Wd.R P) W s1 t1 Q1 sE tE QE
  fin : HaltEndW Wd A P W s0 xs sE ⟨tE, []⟩ QE

/-- The chain's oracle. -/
def Halt2W.O {s0 st0 : St Wd.F.S} {tab1 : List SymE} {xs : List Val} (h : Halt2W Wd A P W s0 st0 tab1 xs) : List Ans :=
  h.p1.O ++ (h.p2.O ++ [])

/-- **The two-piece halting chain** at the remaining readbacks `r`. -/
def Halt2W.seg {s0 st0 : St Wd.F.S} {tab1 : List SymE} {xs : List Val} (h : Halt2W Wd A P W s0 st0 tab1 xs)
    (r : List NumV) : HaltSegW Wd A W P r s0 st0 tab1 xs :=
  haltSegOf r (O := h.O) (h.p1.cons r (h.p2.cons r (.nil _ _ _))) h.fin

variable (Wd A P W) in
/-- **A halting chain of four pieces** (a final chain: `rb`, the clear of token `T - 1`, `rb`, the
clear of token `T` and the loop's end, or the stop for the EOS final chains). -/
structure Halt4W (s0 st0 : St Wd.F.S) (tab1 : List SymE) (xs : List Val) where
  QA : (Nat → F64) → Ctx → Prop
  s1 : St Wd.F.S
  t1 : List SymE
  Q1 : (Nat → F64) → Ctx → Prop
  s2 : St Wd.F.S
  t2 : List SymE
  Q2 : (Nat → F64) → Ctx → Prop
  s3 : St Wd.F.S
  t3 : List SymE
  Q3 : (Nat → F64) → Ctx → Prop
  sE : St Wd.F.S
  tE : List SymE
  QE : (Nat → F64) → Ctx → Prop
  p1 : SPiece (haltLawsW Wd A) (Wd.R P) W st0 tab1 QA s1 t1 Q1
  p2 : SPiece (haltLawsW Wd A) (Wd.R P) W s1 t1 Q1 s2 t2 Q2
  p3 : SPiece (haltLawsW Wd A) (Wd.R P) W s2 t2 Q2 s3 t3 Q3
  p4 : SPiece (haltLawsW Wd A) (Wd.R P) W s3 t3 Q3 sE tE QE
  fin : HaltEndW Wd A P W s0 xs sE ⟨tE, []⟩ QE

def Halt4W.O {s0 st0 : St Wd.F.S} {tab1 : List SymE} {xs : List Val} (h : Halt4W Wd A P W s0 st0 tab1 xs) : List Ans :=
  h.p1.O ++ (h.p2.O ++ (h.p3.O ++ (h.p4.O ++ [])))

/-- **The four-piece halting chain** at the remaining readbacks `r`. -/
def Halt4W.seg {s0 st0 : St Wd.F.S} {tab1 : List SymE} {xs : List Val} (h : Halt4W Wd A P W s0 st0 tab1 xs)
    (r : List NumV) : HaltSegW Wd A W P r s0 st0 tab1 xs :=
  haltSegOf r (O := h.O) (h.p1.cons r (h.p2.cons r (h.p3.cons r (h.p4.cons r (.nil _ _ _))))) h.fin

theorem Halt2W.stop {s0 st0 : St Wd.F.S} {tab1 : List SymE} {xs : List Val} (h : Halt2W Wd A P W s0 st0 tab1 xs)
    (hs : StopAtW W A h.sE) (r : List NumV) : HaltStopSrc (h.seg r) := hs

theorem Halt4W.stop {s0 st0 : St Wd.F.S} {tab1 : List SymE} {xs : List Val} (h : Halt4W Wd A P W s0 st0 tab1 xs)
    (hs : StopAtW W A h.sE) (r : List NumV) : HaltStopSrc (h.seg r) := hs

end Halt

end Host.Ts.Sim.Compose
