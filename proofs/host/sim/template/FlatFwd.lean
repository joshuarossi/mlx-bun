import host.route.SetupEntry
import host.sim.dispatch.BridgeTyped
import host.sim.compose.Glue
import host.sim.compose.a4b.SetupChunkStage
import host.sim.template.a4pre_d1_body.SizeAt
import host.sim.full.RunFast
import host.sim.LinGood
import host.sim.full.BridgeJs
import host.sim.dispatch.BridgeSpread
import host.sim.full.ReplayS
import host.sim.template.Ghosts
import host.sim.template.DimVals
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! # A flat D1 forward, for any frames and book

A forward chain with no stage cuts: its glue stretches and size bridges, at the typed acceptance of the
class's chunk, buffer and view addresses (`Fr`), the book the caller's (`Laws`). The chain's generated pieces
compose `toCall`, `size`, `finish` into a `CutStep` from the call to the return, `genFlatFwd.ts`. -/

namespace Host.Load.Run.Tpl.FlatFwd
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Route
open Host.Ts.Sim.Compose Host.Ts.Sim.Prefill Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk Host.Load.Layers

/-! ## Smallness with the row count a singleton

The chunk's length is a variable; a native call's numbers (`n * 5120`) are small only at its value, `1`. -/

/-- What a forward's smallness knows of its valuations: a variable's value, where it has one. -/
abbrev Pin := Nat → Option Nat

/-- Only the row count `r`, one. -/
def Pin.row (r : Nat) : Pin := fun v => bif Nat.beq v r then some 1 else none

/-- POST's rows from the shared cut: the row count, the convolution caches' lengths, the trace dims derived from them. -/
def Pin.post : Pin := fun v => bif Nat.beq v 10 then some 1 else tailVal v

/-- The valuations a smallness reads: bounded, the pinned variables at their values. -/
def VPin (p : Pin) (ν : Nat → F64) : Prop := VBOkF loopVB ν ∧ ∀ v k, p v = some k → ν v = F64.ofNat k

/-- The valuations of a forward: bounded, the row count `r` one. -/
def VP (r : Nat) (ν : Nat → F64) : Prop := VBOkF loopVB ν ∧ ν r = F64.ofNat 1

theorem VP.pin {r : Nat} {ν : Nat → F64} (h : VP r ν) : VPin (Pin.row r) ν := by
  refine ⟨h.1, fun v k hv => ?_⟩
  unfold Pin.row at hv
  cases hb : Nat.beq v r with
  | false => rw [hb] at hv; cases hv
  | true =>
    rw [hb] at hv
    cases hv
    rw [Nat.eq_of_beq_eq_true hb]
    exact h.2

/-- Used only by the interval input, never by the operational server or native state. -/
def singleton (p : Pin) : Nat → SymE := fun v =>
  match p v with
  | some k => .lit (F64.ofNat k)
  | none => .var v

theorem eval_singleton {p : Pin} {ν : Nat → F64} (hν : VPin p ν) (e : SymE) :
    (e.subst (singleton p)).eval ν = e.eval ν := by
  rw [SymE.eval_subst]
  have hv : (fun i => (singleton p i).eval ν) = ν := by
    funext i
    unfold singleton
    cases hi : p i with
    | none => rfl
    | some k => exact (hν.2 i k hi).symm
  rw [hv]

def refSmall (r : Pin) (S : SSrv) (j : Nat) : Bool :=
  match nth? S.tab j with
  | some e => match ivlA loopVB (e.subst (singleton r)) with
    | some (_, h) => decide (h < 2 ^ 31)
    | none => false
  | none => false

theorem refSmall_sound {r : Pin} {ν : Nat → F64} {S : SSrv} {j : Nat}
    (hν : VPin r ν) (h : refSmall r S j = true) : RefSmall ν S j := by
  unfold refSmall at h
  split at h
  · rename_i e he
    split at h
    · rename_i lo hi hb
      obtain ⟨k, -, hk, -, heval⟩ := ivlA_sound hν.1 (e.subst (singleton r)) hb
      rw [eval_singleton hν] at heval
      exact ⟨e, k, he, heval, by have := of_decide_eq_true h; omega⟩
    · cases h
  · cases h

def refGe (r : Pin) (S : SSrv) (c j : Nat) : Bool :=
  match nth? S.tab j with
  | some e => match ivlA loopVB (e.subst (singleton r)) with
    | some (l, h) => decide (c ≤ l ∧ h < 2 ^ 31)
    | none => false
  | none => false

theorem refGe_sound {r : Pin} {ν : Nat → F64} {S : SSrv} {c j : Nat} (hν : VPin r ν) (h : refGe r S c j = true) :
    G.RefGe ν S c j := by
  unfold refGe at h
  split at h
  · rename_i e he
    split at h
    · rename_i l hi hi'
      obtain ⟨k, k1, k2, -, k4⟩ := ivlA_sound hν.1 (e.subst (singleton r)) hi'
      rw [eval_singleton hν] at k4
      have := of_decide_eq_true h
      exact ⟨e, k, he, k4, by omega, by omega⟩
    · cases h
  · cases h

/-- `symShapeSmallB` at the singleton: a convolution's width, a reshape's dimensions. -/
def symSmall (r : Pin) (S : SSrv) (x : NSt) (name : Name) (args : List Arg) : Bool :=
  match Host.Mlx.Ffi.symOf name with
  | some .conv1d => match G.convRef x args with
    | some (j, c0) => refGe r S c0 j
    | none => true
  | some .reshape => (G.reshRefs x args).all (refSmall r S)
  | _ => true

theorem symSmall_sound {r : Pin} {ν : Nat → F64} {S : SSrv} {x : NSt} {name : Name} {args : List Arg}
    (hν : VPin r ν) (h : symSmall r S x name args = true) : G.symShapeSmall ν S x name args := by
  unfold symSmall at h
  unfold G.symShapeSmall
  split
  · rename_i hs
    rw [hs] at h
    intro j c0 hc
    simp only [hc] at h
    exact refGe_sound hν h
  · rename_i hs
    rw [hs] at h
    intro j hj
    exact refSmall_sound hν (List.all_eq_true.mp h j hj)
  · trivial

/-- `cloSmallB` at the singleton: a replayed trace's references. -/
def cloSmallR (r : Pin) (S : SSrv) (x : NSt) (name : Name) (args : List Arg) : Bool :=
  !G.cloSym x name args || ((G.cloRefs x args).all (refSmall r S) && G.cloRunB S x name args)

theorem cloSmallR_sound {r : Pin} {ν : Nat → F64} {S : SSrv} {x : NSt} {name : Name} {args : List Arg}
    (hν : VPin r ν) (h : cloSmallR r S x name args = true) : G.cloSmall ν S x name args := by
  intro hc
  unfold cloSmallR at h
  rw [hc] at h
  simp only [Bool.not_true, Bool.false_or, Bool.and_eq_true] at h
  refine ⟨fun j hj => refSmall_sound hν (List.all_eq_true.mp h.1 j hj), fun r' S' hr' => ?_⟩
  have h2 := h.2
  unfold G.cloRunB at h2
  rw [hr'] at h2
  cases r'
  · cases h2
  · rfl

def smallFX (r : Pin) (S : SSrv) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  ((smallRefs (toLoad x).mlx name args).all (refSmall r S) && (G.smallRefsX (toLoad x).mlx name args).all (refSmall r S)) &&
    (!isSymShape name || symRunOk S x name args)

theorem smallFX_sound {r : Pin} {ν : Nat → F64} {S : SSrv} {x : FF.S} {name : Name} {args : List Arg}
    (hν : VPin r ν) (h : smallFX r S x name args = true) : Full.smallFX ν S x name args := by
  simp only [smallFX, Bool.and_eq_true, Bool.or_eq_true, Bool.not_eq_true'] at h
  refine ⟨⟨fun j hj => refSmall_sound hν (List.all_eq_true.mp h.1.1 j hj),
    fun j hj => refSmall_sound hν (List.all_eq_true.mp h.1.2 j hj)⟩, fun hs => ?_⟩
  rcases h.2 with h2 | h2
  · rw [hs] at h2; cases h2
  · exact symRunOk_sound h2

def smallFS (r : Pin) (S : SSrv) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  bif G.symPath (mlxOf x) name args then symSmall r S (mlxOf x) name args
  else smallFX r S x name args && cloSmallR r S (mlxOf x) name args

theorem smallFS_sound {r : Pin} {ν : Nat → F64} {S : SSrv} {x : FF.S} {name : Name} {args : List Arg}
    (hν : VPin r ν) (h : smallFS r S x name args = true) : Full.smallFS ν S x name args := by
  unfold smallFS at h
  constructor
  · intro hp; rw [hp, Bool.cond_true] at h; exact symSmall_sound hν h
  · intro hp; rw [hp, Bool.cond_false, Bool.and_eq_true] at h
    exact ⟨smallFX_sound hν h.1, cloSmallR_sound hν h.2⟩

/-- `cloSmallS` at the singleton: an apply whose trace lookup asks the server. -/
def cloSmallSR (r : Pin) (S : SSrv) (x : NSt) (name : Name) (args : List Arg) : Bool :=
  !G.cloServer x name args || ((G.cloRefsS x args).all (refSmall r S) && G.cloFoundS S x args && G.cloRunB S x name args)

theorem cloSmallSR_sound {r : Pin} {ν : Nat → F64} {S : SSrv} {x : NSt} {name : Name} {args : List Arg}
    (hν : VPin r ν) (h : cloSmallSR r S x name args = true) : G.cloSmallS ν S x name args := by
  intro hc
  unfold cloSmallSR at h
  rw [hc] at h
  simp only [Bool.not_true, Bool.false_or, Bool.and_eq_true] at h
  refine ⟨fun j hj => refSmall_sound hν (List.all_eq_true.mp h.1.1 j hj), h.1.2, fun r' S' hr' => ?_⟩
  have h2 := h.2
  unfold G.cloRunB at h2
  rw [hr'] at h2
  cases r'
  · cases h2
  · rfl

def smallFX2O (r : Pin) (S : SSrv) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  bif (bridgeOf x).active then smallFX r S x name args && (!isSymShape name || aneRunOk S x name args) &&
    cloSmallR r S (mlxOf x) name args
  else smallFS r S x name args

@[irreducible] def smallFX2 (r : Pin) (S : SSrv) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  smallFX2O r S x name args && cloSmallSR r S (mlxOf x) name args

theorem smallFX2O_sound {r : Pin} {ν : Nat → F64} {S : SSrv} {x : FF.S} {name : Name} {args : List Arg}
    (hν : VPin r ν) (h : smallFX2O r S x name args = true) : Full.smallFX2 ν S x name args := by
  unfold smallFX2O at h
  constructor
  · intro ha; rw [ha, Bool.cond_false] at h; exact smallFS_sound hν h
  · intro ha
    rw [ha, Bool.cond_true, Bool.and_eq_true, Bool.and_eq_true] at h
    refine ⟨smallFX_sound hν h.1.1, fun hs => ?_, cloSmallR_sound hν h.2⟩
    have := h.1.2
    rw [hs] at this
    simpa using this

theorem smallFX2_sound {r : Pin} {ν : Nat → F64} {S : SSrv} {x : FF.S} {name : Name} {args : List Arg}
    (hν : VPin r ν) (h : smallFX2 r S x name args = true) : Full.smallFXS ν S x name args := by
  unfold smallFX2 at h
  rw [Bool.and_eq_true] at h
  exact ⟨smallFX2O_sound hν h.1, cloSmallSR_sound hν h.2⟩

/-- The accepted calls don't read the readbacks. -/
theorem okCallSV_rest (P : LoadP) (r : List NumV) : okCallSV { P with rest := r } = okCallSV P := by
  funext x name args
  unfold okCallSV
  rw [clApplyS_rest]

theorem okCallFXS_rest (P : LoadP) (r : List NumV) : okCallFXS { P with rest := r } = okCallFXS P := by
  funext x name args
  unfold okCallFXS
  rw [callRaiseRest]
  change (okCallFXD P x name args || (decide (P.NL = P.N0) &&
    okCallSV { P.raise (mlxOf x).nnext with rest := r } x name args)) = _
  rw [okCallSV_rest]

/-! ### Over the fast table -/

def refSmallF (r : Pin) (c : FSrv) (j : Nat) : Bool :=
  match c.val (.ref j) with
  | some e => match ivlA loopVB (e.subst (singleton r)) with
    | some (_, h) => decide (h < 2 ^ 31)
    | none => false
  | none => false

theorem refSmallF_eq (r : Pin) {c : FSrv} (h : c.Wf) : refSmallF r c = refSmall r c.toS := by
  funext j
  unfold refSmallF refSmall
  rw [FSrv.val_eq h]
  rfl

def refGeF (r : Pin) (c : FSrv) (c0 j : Nat) : Bool :=
  match c.val (.ref j) with
  | some e => match ivlA loopVB (e.subst (singleton r)) with
    | some (l, h) => decide (c0 ≤ l ∧ h < 2 ^ 31)
    | none => false
  | none => false

theorem refGeF_eq (r : Pin) {c : FSrv} (h : c.Wf) (c0 j : Nat) : refGeF r c c0 j = refGe r c.toS c0 j := by
  unfold refGeF refGe
  rw [FSrv.val_eq h]
  rfl

def symSmallF (r : Pin) (c : FSrv) (x : NSt) (name : Name) (args : List Arg) : Bool :=
  match Host.Mlx.Ffi.symOf name with
  | some .conv1d => match G.convRef x args with
    | some (j, c0) => refGeF r c c0 j
    | none => true
  | some .reshape => (G.reshRefs x args).all (refSmallF r c)
  | _ => true

set_option maxRecDepth 1000000 in
theorem symSmallF_eq (r : Pin) {c : FSrv} (h : c.Wf) (x : NSt) (name : Name) (args : List Arg) :
    symSmallF r c x name args = symSmall r c.toS x name args := by
  unfold symSmallF symSmall
  simp only [refGeF_eq r h, refSmallF_eq r h]

noncomputable def cloSmallRF (r : Pin) (c : FSrv) (x : NSt) (name : Name) (args : List Arg) : Bool :=
  !G.cloSym x name args || ((G.cloRefs x args).all (refSmallF r c) && cloRunF c x name args)

theorem cloSmallRF_eq (r : Pin) {c : FSrv} (h : c.Wf) (x : NSt) (name : Name) (args : List Arg) :
    cloSmallRF r c x name args = cloSmallR r c.toS x name args := by
  unfold cloSmallRF cloSmallR
  rw [refSmallF_eq r h, cloRunF_eq h]

noncomputable def smallFXF (r : Pin) (c : FSrv) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  ((smallRefs (toLoad x).mlx name args).all (refSmallF r c) && (G.smallRefsX (toLoad x).mlx name args).all (refSmallF r c)) &&
    (!isSymShape name || symRunF c x name args)

theorem smallFXF_eq (r : Pin) {c : FSrv} (h : c.Wf) (x : FF.S) (name : Name) (args : List Arg) :
    smallFXF r c x name args = smallFX r c.toS x name args := by
  unfold smallFXF smallFX
  rw [refSmallF_eq r h, symRunF_eq h]

noncomputable def smallFSF (r : Pin) (c : FSrv) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  bif G.symPath (mlxOf x) name args then symSmallF r c (mlxOf x) name args
  else smallFXF r c x name args && cloSmallRF r c (mlxOf x) name args

theorem smallFSF_eq (r : Pin) {c : FSrv} (h : c.Wf) (x : FF.S) (name : Name) (args : List Arg) :
    smallFSF r c x name args = smallFS r c.toS x name args := by
  unfold smallFSF smallFS
  rw [symSmallF_eq r h, smallFXF_eq r h, cloSmallRF_eq r h]

/-- `cloFoundS` over the fast table. -/
noncomputable def cloFoundF (c : FSrv) (x : NSt) (args : List Arg) : Bool :=
  match G.cloParts x args with
  | some (xs, ts) => match interpF (Host.Mlx.Ffi.findTrace x false xs ts).run c with
    | some (some _, _) => true
    | _ => false
  | none => false

theorem cloFoundF_eq {c : FSrv} (h : c.Wf) (x : NSt) (args : List Arg) :
    cloFoundF c x args = G.cloFoundS c.toS x args := by
  unfold cloFoundF G.cloFoundS
  cases G.cloParts x args with
  | none => rfl
  | some p =>
    obtain ⟨xs, ts⟩ := p
    dsimp only
    rw [← (interpF_eq (Host.Mlx.Ffi.findTrace x false xs ts).run c h).1]
    cases interpF (Host.Mlx.Ffi.findTrace x false xs ts).run c with
    | none => rfl
    | some p =>
      obtain ⟨o, c1⟩ := p
      cases o <;> rfl

noncomputable def cloSmallSRF (r : Pin) (c : FSrv) (x : NSt) (name : Name) (args : List Arg) : Bool :=
  !G.cloServer x name args || ((G.cloRefsS x args).all (refSmallF r c) && cloFoundF c x args && cloRunF c x name args)

theorem cloSmallSRF_eq (r : Pin) {c : FSrv} (h : c.Wf) (x : NSt) (name : Name) (args : List Arg) :
    cloSmallSRF r c x name args = cloSmallSR r c.toS x name args := by
  unfold cloSmallSRF cloSmallSR
  rw [refSmallF_eq r h, cloFoundF_eq h, cloRunF_eq h]

noncomputable def smallFX2F (r : Pin) (c : FSrv) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  (bif (bridgeOf x).active then smallFXF r c x name args && (!isSymShape name || aneRunF c x name args) &&
    cloSmallRF r c (mlxOf x) name args
  else smallFSF r c x name args) && cloSmallSRF r c (mlxOf x) name args

theorem smallFX2F_eq (r : Pin) {c : FSrv} (h : c.Wf) (x : FF.S) (name : Name) (args : List Arg) :
    smallFX2F r c x name args = smallFX2 r c.toS x name args := by
  unfold smallFX2F smallFX2 smallFX2O
  rw [smallFXF_eq r h, aneRunF_eq h, cloSmallRF_eq r h, smallFSF_eq r h, cloSmallSRF_eq r h]

/-- A class's row count variable, its chunk array, its buffer and its view. -/
structure Fr where
  row : Nat
  chunk : Nat
  buffer : Nat
  view : Nat
  /-- The memo's ghost keys, and the cells this forward frames as ghosts. -/
  memo : List Nat
  ghosts : List Nat
  hvb : Nat.beq view buffer = false
  hbv : Nat.beq buffer view = false

namespace Fr
variable (f : Fr)

def typedW (bytes : List Byte) : Nat → Option WFrame :=
  Disp.wAt (Disp.wAt (wideOf f.memo f.ghosts) f.buffer (.buf bytes)) f.view (.typed .i32 f.buffer 0 1)

abbrev typedJ (bytes : List Byte) : Disp.JSP FF :=
  { fullJSPPXS setupP ([2665, f.chunk, f.buffer, f.view] ++ f.ghosts)
      ((f.buffer, .buf bytes) :: (f.view, .typed .i32 f.buffer 0 1) :: wideListOf f.memo f.ghosts) with
    okCall := okCallFXS setupP, smallB := smallFX2 (Pin.row f.row) }

noncomputable def typedOk (bytes : List Byte) : St FF.S → SSrv → Bool :=
  Disp.okJSJ (f.typedJ bytes) (okBackFXS setupP) 4096

/-- `typedOk` over the fast table. -/
noncomputable def typedOkN (bytes : List Byte) : St FF.S → FSrv → Bool :=
  Disp.okJSJN (f.typedJ bytes) (okBackFXS setupP) 4096 (smallFX2F (Pin.row f.row))

theorem typedOkN_ok (bytes : List Byte) (s : St FF.S) (c : FSrv) (h : c.Wf) :
    f.typedOkN bytes s c = f.typedOk bytes s c.toS :=
  Disp.okJSJN_eq (f.typedJ bytes) (okBackFXS setupP) 4096 (fun _ x name args hw => smallFX2F_eq (Pin.row f.row) hw x name args) s h

theorem typed_wp (bytes : List Byte) : Disp.Wp (f.typedJ bytes) (f.typedW bytes) := by
  intro a w hw
  change Disp.lookupW a ((f.buffer, .buf bytes) :: (f.view, .typed .i32 f.buffer 0 1) :: wideListOf f.memo f.ghosts) = some w
  have e1 := f.hvb
  have e2 := f.hbv
  by_cases hv : a = f.view
  · subst hv
    simpa only [typedW, Disp.wAt, Disp.lookupW, e1, Nat.beq_refl, Bool.cond_true, Bool.cond_false] using hw
  · have ev := Template.beq_false hv
    by_cases hb : a = f.buffer
    · subst hb
      simpa only [typedW, Disp.wAt, Disp.lookupW, e2, Nat.beq_refl, Bool.cond_true, Bool.cond_false] using hw
    · have eb := Template.beq_false hb
      simpa only [typedW, Disp.wAt, ev, eb, Bool.cond_false, wideOf, Disp.lookupW] using hw

end Fr

abbrev Native (NB T : Nat) (tk : Nat → Nat) (y0 : Host.Mlx.Ffi.St) :=
  Disp.FRJ (FRQ (FullRXD { setupP with rest := machReads T tk } NB)
    (fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)))

/-- What the caller's book gives and keeps across the forward. `box`: the valuation lies in the class the
chain's oracle was checked over. -/
structure Laws (f : Fr) (bytes : List Byte) (ps : List Lin.Prm) (V : List (Nat × Lin.Aff)) (Book : SegInst FF → Prop) : Prop where
  context : ∀ x, Book x → Disp.KpJ (f.typedJ bytes) 4096 x.K
  valuation : ∀ x, Book x → VP f.row x.ν
  box : ∀ x, Book x → ∃ v, Lin.InBox ps 0 v ∧ Lin.VarsOk x.ν v V
  ext : ∀ {x : SegInst FF} {M' : Map} {t' : St FF.S} {C' : CSrv} {n : Nat}, Book x → Ext x.M M' n →
    Book ⟨M', x.ν, x.K, t', C'⟩
  restart : ∀ {x : SegInst FF} {M' : Map} {t' : St FF.S} {C' : CSrv} {n : Nat} {e : Event} {base : List Event}
    {FR : Map → Nat → FF.S → FF.S → Prop} {W : Nat → Option WFrame} {s : St FF.S} {S : SSrv},
    Book x → Ext x.M M' n → RelB FF FR W [] x.M x.ν x.K s S x.t x.C → t'.trace = e :: x.t.trace →
    Book ⟨M', x.ν, ⟨x.K.fr, base, t'.trace, x.K.D, x.K.lo, x.K.hi⟩, t', C'⟩

/-- A chain's answers are a suffix of the checked oracle. -/
theorem goodLin_drop {ps : List Lin.Prm} {V : List (Nat × Lin.Aff)} {O : List Ans} (h : Lin.goodLin ps V O = true) (m : Nat) :
    Lin.goodLin ps V (O.drop m) = true := by
  unfold Lin.goodLin at h ⊢
  rw [List.all_eq_true] at h ⊢
  exact fun q hq => h q (List.mem_of_mem_drop hq)

/-- A cut of the forward: related at the class's frames, the book, and the bookkeeping every forward keeps. -/
noncomputable def cut (f : Fr) (NB T : Nat) (tk : Nat → Nat) (bytes : List Byte) (Book : SegInst FF → Prop)
    (M0 : Map) (y0 : Host.Mlx.Ffi.St) (s : St FF.S) (S : SSrv) : ICut FF where
  s0 := s
  tab0 := S.tab
  R := fun x s S => RelB FF (Native NB T tk y0) (f.typedW bytes) [] x.M x.ν x.K s S x.t x.C ∧ Book x
  B := fun x => AneFresh x.t ∧ fixedCells x ∧ Ext M0 x.M 20

theorem simulation (f : Fr) (NB T : Nat) (tk : Nat → Nat) (bytes : List Byte) (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF (Native NB T tk y0) (f.typedOk bytes)
      (Disp.KpJ (f.typedJ bytes) 4096) (f.typedW bytes) [] (VP f.row) := by
  let P : LoadP := { setupP with rest := machReads T tk }
  have hj : (f.typedJ bytes).okCall = okCallFXS P := (okCallFXS_rest setupP (machReads T tk)).symm
  have hC : FfiCallSim FF (FullRXD P NB) (f.typedJ bytes).okCall Full.smallFXS := by
    rw [hj]; exact fullCallSimXS P NB
  have hQ := fullTargetPres (FR := FullRXD P NB) fullRXD_ninv y0
  have hs := Disp.stepSimXLBJS (D0 := 4096) (stk := [])
    ((fullFfiSimXD P NB).liftQ fullLawful hQ)
    (backSimS_liftQ (fullBackSimXDS P NB) fullLawful hQ) (hC.liftQ fullLawful hQ)
    (VBOk := VP f.row) (fun _ _ _ _ _ hν hb => smallFX2_sound hν.pin hb)
    (fun _ _ _ _ hν hb => smallBackFB_sound hν.1 hb)
    (fullRXD_laws P NB).liftQ fullLawful (fullNativeFactsXD P NB (f.typedJ bytes) rfl rfl rfl).liftQ (f.typed_wp bytes)
  simpa only [P, backRest, Fr.typedOk] using hs

private theorem fresh {NB T : Nat} {tk : Nat → Nat} {y0 : Host.Mlx.Ffi.St}
    {W : Nat → Option WFrame} {M M' : Map} {ν : Nat → F64} {K K' : Host.Ts.Sim.Ctx}
    {sa sb t t' : St FF.S} {Sa Sb : SSrv} {C C' : CSrv}
    (hr : RelB FF (Native NB T tk y0) W [] M ν K sa Sa t C)
    (hr' : RelB FF (Native NB T tk y0) W [] M' ν K' sb Sb t' C')
    (hi : (bridgeOf sa.ffi).active = false) (he : bridgeOf sb.ffi = bridgeOf sa.ffi)
    (hf : AneFresh t) : AneFresh t' := by
  obtain ⟨_, _, r0⟩ := hr.ffi.1.1
  obtain ⟨_, _, r1⟩ := hr'.ffi.1.1
  have hi' : (bridgeOf sb.ffi).active = false :=
    (congrArg (fun b : Host.Mlx.FfiAne.St => b.active) he).trans hi
  have hb : bridgeOf t'.ffi = bridgeOf t.ffi :=
    (r1.toR hi').bridge.1.trans (he.trans (r0.toR hi).bridge.1.symm)
  intro Cx Pc Kc weights kind NE IP G init
  rw [hb]
  exact hf Cx Pc Kc weights kind NE IP G init

private theorem fixed {M M' : Map} {ν : Nat → F64} {K K' : Host.Ts.Sim.Ctx}
    {t t' : St FF.S} {C C' : CSrv} {n : Nat}
    (h : fixedCells (⟨M, ν, K, t, C⟩ : SegInst FF)) (he : Ext M M' n) :
    fixedCells (⟨M', ν, K', t', C'⟩ : SegInst FF) := by
  constructor
  · change M'.a 2586 = 2586
    rw [he.a]
    exact h.1
  · change M'.a 2589 = 2589
    rw [he.a]
    exact h.2

section
variable {f : Fr} {NB T n : Nat} {tk : Nat → Nat} {bytes : List Byte} {ps : List Lin.Prm} {V : List (Nat × Lin.Aff)}
  {Book : SegInst FF → Prop} {M0 : Map} {y0 : Host.Mlx.Ffi.St}

theorem toCall (L : Laws f bytes ps V Book) {sa sb sc : St FF.S} {Sa Sb Sc : SSrv}
    (ha : (fun bs : List Byte => f.typedOk bs sa Sa) = fun _ => true)
    (hrun : ∀ bs, runOk FF (f.typedOk bs) n sa Sa = some (sb, Sb))
    (hb : (fun bs : List Byte => f.typedOk bs sb Sb) = fun _ => true)
    (hh : isHalt sb.ctl = false) (hs : interpS (step FF sb).run Sb = some (sc, Sc))
    (htop : noRetBlock sc = true)
    (hgood : Lin.goodLin ps V Sa.oracle = true)
    (hi : (bridgeOf sa.ffi).active = false) (hbr : bridgeOf sc.ffi = bridgeOf sa.ffi)
    (h20 : 20 ≤ Sa.tab.length) :
    CutStep (cut f NB T tk bytes Book M0 y0 sa Sa) (cut f NB T tk bytes Book M0 y0 sc Sc) (n + 1) := by
  apply cut_glueCall (simulation f NB T tk bytes y0)
    (congrFun ha _) (hrun _) (congrFun hb _) hh hs htop
  · intro x hbook _
    exact ⟨L.context x hbook, L.valuation x hbook⟩
  · intro x hbook _
    obtain ⟨v, hv, hρ⟩ := L.box x hbook
    exact Lin.goodLin_sound hgood hv hρ
  · intro x M' t' C' hbook hB hr he _ hrel
    refine ⟨⟨hrel.withOracle (fun _ h => nomatch h), L.ext hbook he⟩,
      fresh hr hrel hi hbr hB.1, fixed hB.2.1 he, hB.2.2.trans (he.mono h20) (Nat.le_refl _)⟩

theorem finish (L : Laws f bytes ps V Book) {sa sb : St FF.S} {Sa Sb : SSrv}
    (ha : (fun bs : List Byte => f.typedOk bs sa Sa) = fun _ => true)
    (hrun : ∀ bs, runOk FF (f.typedOk bs) n sa Sa = some (sb, Sb))
    (htop : noRetBlock sb = true)
    (hgood : Lin.goodLin ps V Sa.oracle = true)
    (hi : (bridgeOf sa.ffi).active = false) (hbr : bridgeOf sb.ffi = bridgeOf sa.ffi)
    (h20 : 20 ≤ Sa.tab.length) :
    CutStep (cut f NB T tk bytes Book M0 y0 sa Sa) (cut f NB T tk bytes Book M0 y0 sb Sb) n := by
  apply cut_glue (simulation f NB T tk bytes y0) (congrFun ha _) (hrun _) htop
  · intro x hbook _
    exact ⟨L.context x hbook, L.valuation x hbook⟩
  · intro x hbook _
    obtain ⟨v, hv, hρ⟩ := L.box x hbook
    exact Lin.goodLin_sound hgood hv hρ
  · intro x M' t' C' hbook hB hr he _ hrel
    refine ⟨⟨hrel.withOracle (fun _ h => nomatch h), L.ext hbook he⟩,
      fresh hr hrel hi hbr hB.1, fixed hB.2.1 he, hB.2.2.trans (he.mono h20) (Nat.le_refl _)⟩

theorem size (L : Laws f bytes ps V Book) {sa sb : St FF.S} {Sa Sb Sdec : SSrv}
    {fsym ta nf : Nat} {name rt : Name} {tys args : List Val} {asR : List Arg}
    (hparts : Disp.sizeParts sa = some (fsym, ta, nf, name, rt, tys, args))
    (hargs : Disp.sizeArgsOk sa = true)
    (hsym : Host.Mlx.Ffi.symOf name = some .arraySize) (hm : Host.Load.isMlx name = true)
    (hpay : nameEq name Host.Mlx.FfiAne.payloadName = false)
    (hta : ta ∉ [2665, f.chunk, f.buffer, f.view] ++ f.ghosts)
    (hdec : interpS (decodeArgs FF sa tys args).run Sa = some (some asR, Sdec))
    (hpre : sizePreB loopVB Sdec sa.ffi asR = true)
    (hsize : interpS (Disp.sizeS FF sa).run Sa = some (sb, Sb))
    (hgood : Lin.goodLin ps V Sa.oracle = true)
    (hi : (bridgeOf sa.ffi).active = false) (hbr : bridgeOf sb.ffi = bridgeOf sa.ffi)
    (h20 : 20 ≤ Sa.tab.length) :
    CutStep (cut f NB T tk bytes Book M0 y0 sa Sa) (cut f NB T tk bytes Book M0 y0 sb Sb) 3 := by
  rintro t C ⟨x, rfl, rfl, ⟨hr, hbook⟩, hf, hfixed, he0⟩
  have hctx := L.context x hbook
  have hval := L.valuation x hbook
  obtain ⟨v, hv, hρ⟩ := L.box x hbook
  have hg := Lin.goodLin_sound hgood hv hρ
  have hr0 := hr.withOracle hg
  have hfr : x.K.fr ta = none := by
    by_contra h
    exact hta ((hctx.1.2.2 ta).mp h)
  have hpre0 : ∀ ars S1, interpS (decodeArgs FF sa tys args).run Sa = some (some ars, S1) →
      D1BodySize.Pre x.ν S1 sa.ffi ars := by
    intro ars S1 hd
    exact ⟨sizePre_of hdec hpre hval.1 ars S1 hd, hi⟩
  obtain ⟨M', t', C', _, ⟨⟨gg, hrel, ars, ret, ars', ret', w, hs, ht, hw, hw'⟩, hrun⟩⟩ :=
    (D1BodySize.growAt y0 hr0 hparts hargs hsym hm hpay hfr hpre0).run sb Sb hsize
  let K' : Host.Ts.Sim.Ctx := ⟨x.K.fr, sb.trace, t'.trace, x.K.D, x.K.lo, x.K.hi⟩
  have hb' : Book ⟨M', x.ν, K', t', C'⟩ := L.restart hbook gg.ext hr0 ht
  exact ⟨t', C', hrun, ⟨M', x.ν, K', t', C'⟩, rfl, rfl,
    ⟨hrel.withOracle (fun _ h => nomatch h), hb'⟩,
    fresh hr hrel hi hbr hf, fixed hfixed gg.ext, he0.trans (gg.ext.mono h20) (Nat.le_refl _)⟩

end

end Host.Load.Run.Tpl.FlatFwd
