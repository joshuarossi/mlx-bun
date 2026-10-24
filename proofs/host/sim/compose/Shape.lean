import host.sim.world.Book
import host.sim.lin.Classes
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

/-! # A prefill class's step from its pieces (gen-plan T8, §1.3)

A prefill step is a chain of pieces between cuts (`host.sim.world.Book`): glue templates
(`CutStep`s), stage calls (`StageCall`: isolate, the stage's run, merge, the conversions being
`CutConv`s whose maps may change: A3's `conv_isolate`, `cut_stage`, `conv_merge` of
`host.sim.conv.World`), and the forward call (`FwdCall`: isolate, the cold or warm prefix, a
conversion into the shared body, the body, merge). The shapes (generation/autoregressive.ts:496-516,
generation/prefill.ts:20-33):

* SETUP (`setup_shape`): glue `g0a`, the `chunkSize` stage, glue `g0b`.
* a drain-kind step (`step_shape`: the first drain, the first tail, a later drain, a later tail):
  `nextPrefillStep`, `g1`, the dispatch (`MlxPhaseDispatch.prompt`), `g2`, the forward, `g3d`,
  `evalCacheState`, `g4` (to the next `nextPrefillStep` call);
* the final step (`final_shape`: from the first call at `L = 1`, after the drains, after the tail):
  `nextPrefillStep`, `g1`, the dispatch, `g2`, the D1 forward, `g3f` (the prefill loop's exit);
* POST (`post_shape`): `g5`, the head, `g6`, the cold sample, `g7`, `asyncEval`, `g8`, then twice a
  decode row (`dec_shape`): the readback, `g9`, the D1 forward, `g10`, the warm sample, `g11`,
  `asyncEval`, `g12`.

A piece is reused over the steps of the rows `uses` of the class table (`host.sim.lin.Table`): it
holds at every step `i` of its rows wherever its oracles are correct at `i` (`PieceOk`, `OblOk`),
and a row's checks give that (`obl_of_row`, `obl_of_row_enum`). `GlueP`, `StageP`, `StageR`, `FwdP`
are a piece's data (lengths, the oracle of a template not yet generated, its checks) with its fact;
`host.sim.compose.Bundle` lists the pieces the classes use. -/

section Calls
variable {F : Ffi}

/-- **A stage call** between the caller's cuts `A` (at the call) and `B` (after the return):
isolate, the stage's `n` target steps from its start cut to its return cut, merge. With A3's
lemmas: `conv_isolate`, `cut_stage` (`n = T.n + 1`), `conv_merge`. -/
def StageCall (A B : ICut F) (n : Nat) : Prop :=
  ∃ call ret : ICut F, CutConv A call ∧ CutStep call ret n ∧ CutConv ret B

theorem StageCall.intro {A B call ret : ICut F} {n : Nat} (hi : CutConv A call) (hs : CutStep call ret n)
    (hm : CutConv ret B) : StageCall A B n := ⟨call, ret, hi, hs, hm⟩

theorem StageCall.step {A B : ICut F} {n : Nat} (h : StageCall A B n) : CutStep A B n := by
  obtain ⟨call, ret, hi, hs, hm⟩ := h
  exact (hs.convL hi).convR hm

/-- **A forward call**: isolate, the prefix of `np` steps (the layers a memo-warmth class runs
before the shared body), a conversion into the shared body's start, the body's `nb` steps, merge. -/
def FwdCall (A B : ICut F) (np nb : Nat) : Prop :=
  ∃ call mid body ret : ICut F,
    CutConv A call ∧ CutStep call mid np ∧ CutConv mid body ∧ CutStep body ret nb ∧ CutConv ret B

theorem FwdCall.intro {A B call mid body ret : ICut F} {np nb : Nat} (hi : CutConv A call) (hp : CutStep call mid np)
    (he : CutConv mid body) (hb : CutStep body ret nb) (hm : CutConv ret B) : FwdCall A B np nb :=
  ⟨call, mid, body, ret, hi, hp, he, hb, hm⟩

/-- A warm forward: no prefix. -/
theorem FwdCall.warm {A B body ret : ICut F} {nb : Nat} (hi : CutConv A body) (hb : CutStep body ret nb)
    (hm : CutConv ret B) : FwdCall A B 0 nb :=
  ⟨body, body, body, ret, hi, CutStep.refl _, CutConv.refl _, hb, hm⟩

theorem FwdCall.step {A B : ICut F} {np nb : Nat} (h : FwdCall A B np nb) : CutStep A B (np + nb) := by
  obtain ⟨call, mid, body, ret, hi, hp, he, hb, hm⟩ := h
  exact ((hp.convL hi).trans (hb.convL he)).convR hm

end Calls

/-! ## The shapes -/

section Shapes
variable {F : Ffi}

/-- The pieces' lengths of SETUP. -/
structure SetupLens where
  g0a : Nat
  chunk : Nat
  g0b : Nat

def SetupLens.total (l : SetupLens) : Nat := l.g0a + l.chunk + l.g0b

/-- **SETUP**: `g0a`, the `chunkSize` stage (the chunk size becomes a table variable at its merge), `g0b`. -/
theorem setup_shape {A c1 c2 B : ICut F} {l : SetupLens} (g0a : CutStep A c1 l.g0a) (chunk : StageCall c1 c2 l.chunk)
    (g0b : CutStep c2 B l.g0b) : CutStep A B l.total :=
  (g0a.trans chunk.step).trans g0b

/-- The pieces' lengths of a drain-kind or final step (`eval`, `g4` unused by the final step). -/
structure StepLens where
  nps : Nat
  g1 : Nat
  disp : Nat
  g2 : Nat
  pre : Nat
  body : Nat
  g3 : Nat
  eval : Nat
  g4 : Nat

def StepLens.total (l : StepLens) : Nat :=
  l.nps + l.g1 + l.disp + l.g2 + (l.pre + l.body) + l.g3 + l.eval + l.g4

def StepLens.final (l : StepLens) : Nat := l.nps + l.g1 + l.disp + l.g2 + (l.pre + l.body) + l.g3

/-- **A drain-kind step** (a whole chunk or a tail): `nextPrefillStep`, `g1`, the dispatch, `g2`,
the forward, `g3d`, `evalCacheState`, `g4` restarting at the next `nextPrefillStep` call. -/
theorem step_shape {A c1 c2 c3 c4 c5 c6 c7 B : ICut F} {l : StepLens} (nps : StageCall A c1 l.nps)
    (g1 : CutStep c1 c2 l.g1) (disp : StageCall c2 c3 l.disp) (g2 : CutStep c3 c4 l.g2)
    (fwd : FwdCall c4 c5 l.pre l.body) (g3 : CutStep c5 c6 l.g3) (eval : StageCall c6 c7 l.eval)
    (g4 : CutStep c7 B l.g4) : CutStep A B l.total :=
  ((((((nps.step.trans g1).trans disp.step).trans g2).trans fwd.step).trans g3).trans eval.step).trans g4

/-- **The final step**: `nextPrefillStep`, `g1`, the dispatch (`decode`), `g2`, the D1 forward, `g3f`
(the prefill loop's exit). -/
theorem final_shape {A c1 c2 c3 c4 c5 B : ICut F} {l : StepLens} (nps : StageCall A c1 l.nps)
    (g1 : CutStep c1 c2 l.g1) (disp : StageCall c2 c3 l.disp) (g2 : CutStep c3 c4 l.g2)
    (fwd : FwdCall c4 c5 l.pre l.body) (g3 : CutStep c5 B l.g3) : CutStep A B l.final :=
  ((((nps.step.trans g1).trans disp.step).trans g2).trans fwd.step).trans g3

/-- The pieces' lengths of a decode row. -/
structure DecLens where
  rb : Nat
  g9 : Nat
  pre : Nat
  body : Nat
  g10 : Nat
  smp : Nat
  g11 : Nat
  async : Nat
  g12 : Nat

def DecLens.total (l : DecLens) : Nat := l.rb + l.g9 + (l.pre + l.body) + l.g10 + l.smp + l.g11 + l.async + l.g12

/-- **A decode row**: the readback, `g9`, the D1 forward, `g10`, the warm sample, `g11`, `asyncEval`, `g12`. -/
theorem dec_shape {A c1 c2 c3 c4 c5 c6 c7 B : ICut F} {l : DecLens} (rb : StageCall A c1 l.rb)
    (g9 : CutStep c1 c2 l.g9) (fwd : FwdCall c2 c3 l.pre l.body) (g10 : CutStep c3 c4 l.g10)
    (smp : StageCall c4 c5 l.smp) (g11 : CutStep c5 c6 l.g11) (async : StageCall c6 c7 l.async)
    (g12 : CutStep c7 B l.g12) : CutStep A B l.total :=
  ((((((rb.step.trans g9).trans fwd.step).trans g10).trans smp.step).trans g11).trans async.step).trans g12

/-- The pieces' lengths of POST's prefix (and of a short path's). -/
structure PreLens where
  g5 : Nat
  head : Nat
  g6 : Nat
  smp : Nat
  g7 : Nat
  async : Nat
  g8 : Nat

def PreLens.total (l : PreLens) : Nat := l.g5 + l.head + l.g6 + l.smp + l.g7 + l.async + l.g8

/-- **POST's prefix** (a short path's prefix): `g5`, the head, `g6`, the cold sample, `g7`,
`asyncEval`, `g8`. -/
theorem pre_shape {A c1 c2 c3 c4 c5 c6 B : ICut F} {l : PreLens} (g5 : CutStep A c1 l.g5)
    (head : StageCall c1 c2 l.head) (g6 : CutStep c2 c3 l.g6) (smp : StageCall c3 c4 l.smp)
    (g7 : CutStep c4 c5 l.g7) (async : StageCall c5 c6 l.async) (g8 : CutStep c6 B l.g8) : CutStep A B l.total :=
  (((((g5.trans head.step).trans g6).trans smp.step).trans g7).trans async.step).trans g8

/-- The pieces' lengths of POST. -/
structure PostLens where
  g5 : Nat
  head : Nat
  g6 : Nat
  smp : Nat
  g7 : Nat
  async : Nat
  g8 : Nat
  d0 : DecLens
  d1 : DecLens

def PostLens.total (l : PostLens) : Nat :=
  l.g5 + l.head + l.g6 + l.smp + l.g7 + l.async + l.g8 + l.d0.total + l.d1.total

/-- **POST**: `g5`, the head, `g6`, the cold sample, `g7`, `asyncEval`, `g8`, the decode rows at
offsets `L` and `L + 1`. -/
theorem post_shape {A c1 c2 c3 c4 c5 c6 c7 c8 B : ICut F} {l : PostLens} (g5 : CutStep A c1 l.g5)
    (head : StageCall c1 c2 l.head) (g6 : CutStep c2 c3 l.g6) (smp : StageCall c3 c4 l.smp)
    (g7 : CutStep c4 c5 l.g7) (async : StageCall c5 c6 l.async) (g8 : CutStep c6 c7 l.g8)
    (d0 : CutStep c7 c8 l.d0.total) (d1 : CutStep c8 B l.d1.total) : CutStep A B l.total :=
  (((((((g5.trans head.step).trans g6).trans smp.step).trans g7).trans async.step).trans g8).trans d0).trans d1

/-! ### The eight class shapes of gen-plan §1.3 at their cuts -/

variable {I : PrefInvsW F} {L j : Nat} {c1 c2 c3 c4 c5 c6 c7 : ICut F} {l : StepLens}

/-- setup c: `ld` to the first call. -/
theorem setup_step {l : SetupLens} (g0a : CutStep (I.ld L) c1 l.g0a) (chunk : StageCall c1 c2 l.chunk)
    (g0b : CutStep c2 (I.pc0 L) l.g0b) : CutStep (I.ld L) (I.pc0 L) l.total := setup_shape g0a chunk g0b

/-- firstDrain C: the first call to the drain cut after one drain. -/
theorem firstDrain_step (nps : StageCall (I.pc0 L) c1 l.nps) (g1 : CutStep c1 c2 l.g1) (disp : StageCall c2 c3 l.disp)
    (g2 : CutStep c3 c4 l.g2) (fwd : FwdCall c4 c5 l.pre l.body) (g3 : CutStep c5 c6 l.g3)
    (eval : StageCall c6 c7 l.eval) (g4 : CutStep c7 (I.pc L 1) l.g4) : CutStep (I.pc0 L) (I.pc L 1) l.total :=
  step_shape nps g1 disp g2 fwd g3 eval g4

/-- firstTail X: the first call to the pre-final cut. -/
theorem firstTail_step (nps : StageCall (I.pc0 L) c1 l.nps) (g1 : CutStep c1 c2 l.g1) (disp : StageCall c2 c3 l.disp)
    (g2 : CutStep c3 c4 l.g2) (fwd : FwdCall c4 c5 l.pre l.body) (g3 : CutStep c5 c6 l.g3)
    (eval : StageCall c6 c7 l.eval) (g4 : CutStep c7 (I.pf L) l.g4) : CutStep (I.pc0 L) (I.pf L) l.total :=
  step_shape nps g1 disp g2 fwd g3 eval g4

/-- drain (C, grow): the drain cut after `j` drains to the one after `j + 1`. -/
theorem drain_step (nps : StageCall (I.pc L j) c1 l.nps) (g1 : CutStep c1 c2 l.g1) (disp : StageCall c2 c3 l.disp)
    (g2 : CutStep c3 c4 l.g2) (fwd : FwdCall c4 c5 l.pre l.body) (g3 : CutStep c5 c6 l.g3)
    (eval : StageCall c6 c7 l.eval) (g4 : CutStep c7 (I.pc L (j + 1)) l.g4) :
    CutStep (I.pc L j) (I.pc L (j + 1)) l.total :=
  step_shape nps g1 disp g2 fwd g3 eval g4

/-- tail (C, X, grow): the drain cut after the drains to the pre-final cut. -/
theorem tail_step (nps : StageCall (I.pc L (drains L)) c1 l.nps) (g1 : CutStep c1 c2 l.g1)
    (disp : StageCall c2 c3 l.disp) (g2 : CutStep c3 c4 l.g2) (fwd : FwdCall c4 c5 l.pre l.body)
    (g3 : CutStep c5 c6 l.g3) (eval : StageCall c6 c7 l.eval) (g4 : CutStep c7 (I.pf L) l.g4) :
    CutStep (I.pc L (drains L)) (I.pf L) l.total :=
  step_shape nps g1 disp g2 fwd g3 eval g4

/-- final-first (`L = 1`): the first call to the loop's exit. -/
theorem finalFirst_step (nps : StageCall (I.pc0 L) c1 l.nps) (g1 : CutStep c1 c2 l.g1) (disp : StageCall c2 c3 l.disp)
    (g2 : CutStep c3 c4 l.g2) (fwd : FwdCall c4 c5 l.pre l.body) (g3 : CutStep c5 (I.ps L) l.g3) :
    CutStep (I.pc0 L) (I.ps L) l.final :=
  final_shape nps g1 disp g2 fwd g3

/-- final: the pre-final cut of its source to the loop's exit. -/
theorem final_step {src : PFSrc} (nps : StageCall (I.pre L src) c1 l.nps) (g1 : CutStep c1 c2 l.g1)
    (disp : StageCall c2 c3 l.disp) (g2 : CutStep c3 c4 l.g2) (fwd : FwdCall c4 c5 l.pre l.body)
    (g3 : CutStep c5 (I.ps L) l.g3) : CutStep (I.pre L src) (I.ps L) l.final :=
  final_shape nps g1 disp g2 fwd g3

/-- post: the loop's exit to the decode cut. -/
theorem post_step {c8 : ICut F} {l : PostLens} (g5 : CutStep (I.ps L) c1 l.g5) (head : StageCall c1 c2 l.head)
    (g6 : CutStep c2 c3 l.g6) (smp : StageCall c3 c4 l.smp) (g7 : CutStep c4 c5 l.g7)
    (async : StageCall c5 c6 l.async) (g8 : CutStep c6 c7 l.g8) (d0 : CutStep c7 c8 l.d0.total)
    (d1 : CutStep c8 (I.dec L) l.d1.total) : CutStep (I.ps L) (I.dec L) l.total :=
  post_shape g5 head g6 smp g7 async g8 d0 d1

end Shapes

/-! ## Pieces over the rows of the class table -/

/-- An oracle obligation: a template reading quantity `q` in variable `v` (`m`), its oracle `O`. -/
structure Obl where
  m : List (Nat × Q)
  O : List Ans

/-- The oracles are correct wherever the variables hold step `i`'s quantities. -/
def OblOk (i : Cls.Inst) : List Obl → Prop
  | [] => True
  | ob :: obs => (∀ ρ, MapOk ρ i ob.m → Good ρ ob.O) ∧ OblOk i obs

theorem obl_of_row {r : Row} {i : Cls.Inst} (hi : InRow r i) {m : List (Nat × Q)} {O : List Ans}
    (h : goodLin r.ps (varsOf r.V m) O = true) : ∀ ρ, MapOk ρ i m → Good ρ O :=
  fun _ hρ => good_of_row h hi hρ

theorem obl_of_row_enum {r : Row} {i : Cls.Inst} (hi : InRow r i) {m : List (Nat × Q)} {O : List Ans}
    (h : goodEnum r.ps (varsOf r.V m) O = true) : ∀ ρ, MapOk ρ i m → Good ρ O :=
  fun _ hρ => good_of_row_enum h hi hρ

/-- The `k`-th entry of a list is in it (a row's membership in a piece's `uses`, by `rfl`). -/
theorem mem_at {α : Type} : ∀ {l : List α} {k : Nat} {a : α}, l[k]? = some a → a ∈ l
  | [], _, _, h => by simp at h
  | b :: l, 0, a, h => by
    simp only [List.getElem?_cons_zero, Option.some.injEq] at h
    subst h; exact List.mem_cons_self
  | b :: l, k + 1, a, h => List.mem_cons_of_mem _ (mem_at (k := k) (by simpa using h))

section Pieces
variable (F : Ffi)

/-- **A piece at the steps of the rows `uses`**: `H (A i) (B i)` (a cut step, a stage call, a forward
call) at every step `i` of the rows wherever its oracles are correct at `i`. -/
def PieceOk (uses : List Row) (obls : List Obl) (H : ICut F → ICut F → Prop) (A B : Cls.Inst → ICut F) : Prop :=
  ∀ r ∈ uses, ∀ i, InRow r i → OblOk i obls → H (A i) (B i)

/-- A glue piece: its length, the oracle of its template and its checks over `uses`, its cut step. -/
structure GlueP (uses : List Row) (m : List (Nat × Q)) (A B : Cls.Inst → ICut F) where
  n : Nat
  O : List Ans
  chk : ∀ r ∈ uses, goodLin r.ps (varsOf r.V m) O = true
  ok : PieceOk F uses [⟨m, O⟩] (fun X Y => CutStep X Y n) A B

/-- A stage call whose stage template's oracle is a parameter (its template not yet generated). -/
structure StageP (uses : List Row) (m : List (Nat × Q)) (A B : Cls.Inst → ICut F) where
  n : Nat
  O : List Ans
  chk : ∀ r ∈ uses, goodLin r.ps (varsOf r.V m) O = true
  ok : PieceOk F uses [⟨m, O⟩] (fun X Y => StageCall X Y n) A B

/-- A stage call whose oracles `obls` are the existing stage templates' (checked per row). -/
structure StageR (uses : List Row) (obls : List Obl) (A B : Cls.Inst → ICut F) where
  n : Nat
  ok : PieceOk F uses obls (fun X Y => StageCall X Y n) A B

/-- A forward call: its prefix and body lengths, the oracle of its templates (a parameter), the
existing stage templates' oracles it bridges (`obls`: the KV append, the down plan). -/
structure FwdP (uses : List Row) (m : List (Nat × Q)) (obls : List Obl) (A B : Cls.Inst → ICut F) where
  np : Nat
  nb : Nat
  O : List Ans
  chk : ∀ r ∈ uses, goodLin r.ps (varsOf r.V m) O = true
  ok : PieceOk F uses (⟨m, O⟩ :: obls) (fun X Y => FwdCall X Y np nb) A B

/-! ### Route pieces

A route piece (POST, a short budget's path prefix) is over route rows (`routeI L T t1 t2`: the
budget and tokens 1, 2 besides the step's quantities) and its oracle is checked per row like a
prefill piece's; it holds at the steps the run admits (`Adm`; the route's `RunAt T tk`: the run's
budget and tokens, the context), since its cuts are the run's. -/

/-- The steps of the run at budget `T` with tokens `tk`: its budget and tokens 1, 2, the context. -/
def RunAt (T : Nat) (tk : Nat → Nat) (i : Cls.Inst) : Prop := i.T = T ∧ i.t1 = tk 1 ∧ i.t2 = tk 2 ∧ i.L + i.T ≤ 262144

/-- `PieceOk` at the admitted steps. -/
def RPieceOk (Adm : Cls.Inst → Prop) (uses : List Row) (obls : List Obl) (H : ICut F → ICut F → Prop) (A B : Cls.Inst → ICut F) : Prop :=
  ∀ r ∈ uses, ∀ i, InRow r i → OblOk i obls → Adm i → H (A i) (B i)

structure RGlue (Adm : Cls.Inst → Prop) (uses : List Row) (m : List (Nat × Q)) (A B : Cls.Inst → ICut F) where
  n : Nat
  O : List Ans
  chk : ∀ r ∈ uses, goodLin r.ps (varsOf r.V m) O = true
  ok : RPieceOk F Adm uses [⟨m, O⟩] (fun X Y => CutStep X Y n) A B

structure RStage (Adm : Cls.Inst → Prop) (uses : List Row) (m : List (Nat × Q)) (A B : Cls.Inst → ICut F) where
  n : Nat
  O : List Ans
  chk : ∀ r ∈ uses, goodLin r.ps (varsOf r.V m) O = true
  ok : RPieceOk F Adm uses [⟨m, O⟩] (fun X Y => StageCall X Y n) A B

structure RFwd (Adm : Cls.Inst → Prop) (uses : List Row) (m : List (Nat × Q)) (obls : List Obl) (A B : Cls.Inst → ICut F) where
  np : Nat
  nb : Nat
  O : List Ans
  chk : ∀ r ∈ uses, goodLin r.ps (varsOf r.V m) O = true
  ok : RPieceOk F Adm uses (⟨m, O⟩ :: obls) (fun X Y => FwdCall X Y np nb) A B

end Pieces

end Host.Ts.Sim.Compose
