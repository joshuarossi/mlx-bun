import host.sim.DecodeAddr
import host.sim.LoopFramesFinal
namespace Host.Ts.Sim
open Host.Ts Host.Ts.Sim.Template

/-! # The decode loop's halts over the frame relation, at a driver's constants

The halts of the decode loop (`final_stepSF`, `exit_stepF`, `finalE_stepF`) start from
`LoopInvF` at `Rel` (no frames beyond framed arrays). Here they start from `LoopInvA` at
`relLW P W` (frames `W`) and the constants `A`, and are one contract: a halting chain under
`relQW` (`HaltSegA`, the laws `haltLaws` keeping the handle band and the `emitted` frame), from the
loop template itself at a cut (`cut_haltA`: EOS at the cut, nothing appended) or from the final
template start with the look-ahead reference (`last_haltA`: the cut's token appended, and the
look-ahead token unless EOS). The obligations on the further invariant are `CutGStepA`,
`LastGStepA`.

The checked halting cases are chains (`ExitCaseA.toSeg`: segment, last step, the framed spread of
`forwarded` (`PieceSim.spreadW`), segment, under the acceptances' simulations under the frames
`AccSimW`). At `addr0` without frames the existing cases and obligations are instances
(`FinalSeg.toA`, `ExitCase.toA`, `FinalCase.toA`, `AccSim.toW`, `haltLaws_addr0`,
`LastGStepA_addr0`). -/

/-- `Rel.setSrcFfi` under frames. -/
theorem RelF.withSrcFfi {F : Ffi} {FR FR' : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {M : Map}
    {ν : Nat → F64} {K : Ctx} {s t : St F.S} {S : SSrv} {C : CSrv} (h : RelF F FR W M ν K s S t C) (x : F.S)
    (hf : FR' M S.tab.length x t.ffi) : RelF F FR' W M ν K (s.setFfi x) S t C :=
  { h with ffi := hf }

/-! ## Halting chains -/

/-- The laws of a halting chain at `A`: the contexts keep the handle band and the `emitted` frame;
the target's native state grows. -/
def haltLaws (A : Addr) : SegLaws LF where
  KR K K' := K'.lo = K.lo ∧ K'.hi = K.hi ∧ K'.fr A.emit = K.fr A.emit
  TR t t' := Host.Mlx.Ffi.NGrow t.ffi.mlx t'.ffi.mlx
  krefl _ := ⟨rfl, rfl, rfl⟩
  ktrans h1 h2 := ⟨h2.1.trans h1.1, h2.2.1.trans h1.2.1, h2.2.2.trans h1.2.2⟩
  trefl _ := Host.Mlx.Ffi.NGrow.refl _
  ttrans h1 h2 := h1.trans h2

theorem haltLaws_addr0 : haltLaws addr0 = finalLaws := rfl

/-- **A halting chain** at `A` under the frames `W`, for the target's remaining readbacks `r`: from
the start `(st0, S0)` (table `tab1`) a halting chain starting under `relQW` with the entry
predicate `QA` and ending under `relQW` (`rend`), where the `emitted` binding (cell `A.cE`) holds
the template's array followed by `xs`. -/
structure HaltSegA (A : Addr) (W : Nat → Option WFrame) (P : LoadP) (r : List NumV) (s0 st0 : St LF.S)
    (tab1 : List SymE) (xs : List Val) where
  S0 : SSrv
  tab : S0.tab = tab1
  QA : (Nat → F64) → Ctx → Prop
  case : SegCase (haltLaws A) (relQW LF (LR P r) W QA) st0 S0 .halt
  QF : (Nat → F64) → Ctx → Prop
  rend : ∀ x s S, case.Rend x s S → relQW LF (LR P r) W QF x s S
  emitG : ∃ o, case.sF.heap.get A.emit = some (.obj o) ∧ o.kind = .array (arrOf s0 A.emit ++ xs)
  cell : case.sF.cell? A.cE = some (some (.obj A.emit))

/-- Today's chain final cases. -/
def FinalSeg.toA {P : LoadP} {r : List NumV} {s0 : St LF.S} {tab0 : List SymE} (fc : FinalSeg P r s0 tab0 2590) :
    HaltSegA addr0 noFrames P r s0 (finalStart s0 tab0.length) (tab0 ++ [.var 17])
      [.num (.ref 79), .num (.ref tab0.length)] :=
  ⟨fc.S0, fc.tab, fc.QA, fc.case, fc.QF, fc.rend, fc.emitG, fc.cell⟩

/-! ## The halts from the invariant -/

section Halt
variable {A : Addr} {Gx : Nat → Map → St LF.S → CSrv → Prop} {G : St LF.S → CSrv → Prop} {P : LoadP}
  {W : Nat → Option WFrame} {Fr : LoopFramesA A} {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat}
  {V : LoopVals} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {B : LoopBase} {ΔJ ΔH ΔN : Nat}

/-- The obligation of a halting chain at a cut (iteration `i`) on the further invariant `Gx`. -/
def CutGStepA (A : Addr) (Gx : Nat → Map → St LF.S → CSrv → Prop) (P : LoadP) (W : Nat → Option WFrame)
    (Fr : LoopFramesA A) (fixA : List Nat) {s0 : St LF.S} {tab0 : List SymE} {toks : List NumV} {i : Nat}
    (hs : HaltSegA A W P (toks.drop i) s0 s0 tab0 []) (V : LoopVals) (G : St LF.S → CSrv → Prop) : Prop :=
  ∀ (nx : Nat) (M : Map) (K : Ctx) (t : St LF.S) (C : CSrv) (xF : SegInst LF),
    Gx i M t C → (∀ a ∈ fixA, M.a a = a) →
    RelF LF (LR P (toks.drop i)) W M (V i nx) K s0 ⟨tab0, []⟩ t C →
    (∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Fr.xs) → K.lo = P.lo → K.hi = P.E →
    runC LF hs.case.n t C = some (xF.t, xF.C) → Host.Mlx.Ffi.NGrow t.ffi.mlx xF.t.ffi.mlx →
    Ext M xF.M tab0.length → xF.ν = V i nx → xF.K.lo = P.lo → xF.K.hi = P.E → xF.K.fr A.emit = K.fr A.emit →
    hs.case.Rend xF hs.case.sF hs.case.SF → G xF.t xF.C

/-- **A halt at the cut of iteration `i`** (`exit_stepF`): the halting chain from the loop template
halts the target with the `emitted` binding the base prefix and the first `i - 1` readbacks. -/
theorem cut_haltA {i : Nat} {t : St LF.S} {C : CSrv} {env : Env} {nm : Name}
    (hs : HaltSegA A W P (toks.drop i) s0 s0 tab0 []) (hcE : A.cE ∈ fixA) (hb : A.emit ∈ fixA)
    (hwc : W A.cE = none) (hwe : W A.emit = none)
    (hinv : LoopInvA A Gx (relLW P W) P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN i t C)
    (hgood : ∀ nx, Good (V i nx) hs.S0.oracle)
    (hQA : ∀ nx (K : Ctx), nx ≤ 2 ^ 20 → (∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Fr.xs) → K.lo = P.lo →
      K.hi = P.E → hs.QA (V i nx) K)
    (henv : lookupEnv nm env = some A.cE) (hG : CutGStepA A Gx P W Fr fixA hs V G) :
    ∃ tF CF v, runC LF hs.case.n t C = some (tF, CF) ∧ tF.ctl = .halt (.normal v) ∧
      (bindingOf tF env nm).bind (Host.Load.Extract.elements tF) = some (E0 ++ (toks.take (i - 1)).map Val.num) ∧
      CSrv.Le C CF ∧ G tF CF := by
  obtain ⟨M, K, nx, p1, h, hfr, hlo, hhi, hbase, htokM, hnx, hvals, hD, hHi, hNi, hfix, hGx⟩ := hinv
  have h1 : RelF LF (LR P (toks.drop i)) W M (V i nx) K s0 hs.S0 t C :=
    h.srvSwap hs.tab ⟨fun j e he => h.srv.num j e (by rw [hs.tab] at he; exact he), hgood nx⟩
  have hKfr : ∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Fr.xs := fun a => by
    rw [hfr]; exact frA_ne_none A s0 Fr p1 _ a
  obtain ⟨x1, hst, hend, ⟨v, hv⟩, -⟩ := seg_halt hs.case (x := ⟨M, V i nx, K, t, C⟩)
    ⟨h1, hQA nx K hnx hKfr hlo hhi⟩
  obtain ⟨hF, -⟩ := hs.rend x1 _ _ hend
  have hext : Ext M x1.M tab0.length := by rw [← hs.tab]; exact hst.ext
  obtain ⟨hklo, hkhi, hke⟩ := hst.kr
  refine ⟨x1.t, x1.C, v, hst.run, hv, ?_, hst.le, ?_⟩
  · have hMa : x1.M.a = M.a := hext.a
    have hk : x1.K.fr A.emit = some (arrOf s0 A.emit, E0 ++ (toks.take (i - 1)).map Val.num) := by
      rw [hke, hfr, frA_emit]
    obtain ⟨o, hg, hkind⟩ := hs.emitG
    refine (hF.emitted henv hs.cell (by rw [hMa]; exact hfix _ hcE) (by rw [hMa]; exact hfix _ hb) hk hg hkind
      hwc hwe).trans ?_
    simp [Map.vals]
  · exact hG nx M K t C x1 hGx hfix h hKfr hlo hhi hst.run hst.tr hext hst.val (hklo.trans hlo) (hkhi.trans hhi)
      hke hend

/-- The obligation of a halting chain from the final template start (the last iteration `T - 2`)
on the further invariant `Gx` (`FinalGStepSF`). -/
def LastGStepA (A : Addr) (Gx : Nat → Map → St LF.S → CSrv → Prop) (P : LoadP) (W : Nat → Option WFrame)
    (Fr : LoopFramesA A) (fixA : List Nat) {s0 : St LF.S} {tab0 : List SymE} {toks : List NumV} {T : Nat}
    {xs : List Val}
    (hs : HaltSegA A W P (toks.drop (T - 1)) s0 (finalStart s0 tab0.length) (tab0 ++ [.var A.nxt]) xs)
    (V : LoopVals) (tk : Nat → Nat) (G : St LF.S → CSrv → Prop) : Prop :=
  ∀ (hlen : T - 2 < toks.length) (nx : Nat) (M : Map) (K : Ctx) (t : St LF.S) (C : CSrv) (xF : SegInst LF),
    Gx (T - 2) M t C → (∀ a ∈ fixA, M.a a = a) →
    RelF LF (LR P (toks.drop (T - 2))) W M (V (T - 2) nx) K s0 ⟨tab0, []⟩ t C →
    (∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Fr.xs) → K.lo = P.lo → K.hi = P.E →
    runC LF hs.case.n t C = some (xF.t, xF.C) → Host.Mlx.Ffi.NGrow t.ffi.mlx xF.t.ffi.mlx →
    Ext (M.setNum tab0.length toks[T - 2]) xF.M (tab0.length + 1) → xF.ν = V (T - 2) (tk T) →
    xF.K.lo = P.lo → xF.K.hi = P.E → xF.K.fr A.emit = K.fr A.emit →
    hs.case.Rend xF hs.case.sF hs.case.SF → G xF.t xF.C

theorem LastGStepA_addr0 {Fr : LoopFrames} {T : Nat} (fc : FinalSeg P (toks.drop (T - 1)) s0 tab0 2590) :
    LastGStepA addr0 Gx P noFrames Fr.toA fixA fc.toA V tk G ↔ FinalGStepSF Gx P Fr fixA fc V tk G := Iff.rfl

/-- **A halt from the final template start** (`final_stepSF`, `finalE_stepF`): the chain appends
the references `ks` to `emitted` (the cut's token, and the look-ahead token unless EOS) and halts
the target with the `emitted` binding the base prefix and the first `T - 3 + ks.length`
readbacks. -/
theorem last_haltA {T : Nat} {t : St LF.S} {C : CSrv} {env : Env} {nm : Name} {ks : List Nat}
    (st : LoopStartA A P s0 tab0) (hks : ks = [A.tok] ∨ ks = [A.tok, tab0.length])
    (hs : HaltSegA A W P (toks.drop (T - 1)) s0 (finalStart s0 tab0.length) (tab0 ++ [.var A.nxt])
      (ks.map fun k => .num (.ref k)))
    (hfrN : ∀ e ∈ tab0, e.noVar A.nxt = true) (hcE : A.cE ∈ fixA) (hb : A.emit ∈ fixA)
    (hwc : W A.cE = none) (hwe : W A.emit = none)
    (hupd : ∀ nx, upd (V (T - 2) nx) A.nxt (F64.ofNat (tk T)) = V (T - 2) (tk T))
    (hinv : LoopInvA A Gx (relLW P W) P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN (T - 2) t C) (hT : 3 ≤ T)
    (hlen : T - 1 ≤ toks.length) (hgood : Good (V (T - 2) (tk T)) hs.S0.oracle)
    (hQA : ∀ K : Ctx, (∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Fr.xs) → K.lo = P.lo → K.hi = P.E →
      hs.QA (V (T - 2) (tk T)) K)
    (henv : lookupEnv nm env = some A.cE) (hG : LastGStepA A Gx P W Fr fixA hs V tk G) :
    ∃ tF CF v, runC LF hs.case.n t C = some (tF, CF) ∧ tF.ctl = .halt (.normal v) ∧
      (bindingOf tF env nm).bind (Host.Load.Extract.elements tF) =
        some (E0 ++ (toks.take (T - 3 + ks.length)).map Val.num) ∧
      CSrv.Le C CF ∧ G tF CF := by
  obtain ⟨M, K, nx, p1, h, hfr, hlo, hhi, hbase, htokM, hnx, hvals, hD, hHi, hNi, hfix, hGx⟩ := hinv
  have hT1 : T - 2 + 1 = T - 1 := by omega
  have hi : T - 2 < toks.length := by omega
  have hdrop : toks.drop (T - 2) = toks[T - 2] :: toks.drop (T - 2 + 1) := List.drop_eq_getElem_cons hi
  have hT2 : T - 2 + 2 = T := by omega
  have hx : C.val toks[T - 2] = some (F64.ofNat (tk T)) := by
    have := hvals (T - 2) hi; rw [hT2] at this; exact this
  -- the look-ahead reference
  have h1 := h.extendVar' (loadR_laws _) hfrN (fun q hq => by cases hq) hx
  have hf : LR P (toks.drop (T - 2 + 1)) (M.setNum tab0.length toks[T - 2]) (tab0.length + 1)
      ({ s0.ffi with mlx := { s0.ffi.mlx with tokens := s0.ffi.mlx.tokens ++ [.ref tab0.length] } }) t.ffi := by
    have := h.ffi
    rw [hdrop] at this
    exact this.addToken
  have h2 := h1.withSrcFfi (FR' := LR P (toks.drop (T - 2 + 1))) _ (by simpa using hf)
  rw [hupd] at h2
  have h3 : RelF LF (LR P (toks.drop (T - 2 + 1))) W (M.setNum tab0.length toks[T - 2])
      (V (T - 2) (tk T)) K (finalStart s0 tab0.length) hs.S0 t C :=
    h2.srvSwap (by rw [hs.tab]) ⟨fun j e he => h2.srv.num j e (by rw [hs.tab] at he; exact he), hgood⟩
  rw [hT1] at h3
  have hKfr : ∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Fr.xs := fun a => by
    rw [hfr]; exact frA_ne_none A s0 Fr p1 _ a
  -- the chain
  obtain ⟨x1, hst, hend, ⟨v, hv⟩, -⟩ :=
    seg_halt hs.case (x := ⟨M.setNum tab0.length toks[T - 2], V (T - 2) (tk T), K, t, C⟩) ⟨h3, hQA K hKfr hlo hhi⟩
  obtain ⟨hF, -⟩ := hs.rend x1 _ _ hend
  have hS0 : hs.S0.tab.length = tab0.length + 1 := by rw [hs.tab]; simp
  have hext : Ext (M.setNum tab0.length toks[T - 2]) x1.M (tab0.length + 1) := by rw [← hS0]; exact hst.ext
  obtain ⟨hklo, hkhi, hke⟩ := hst.kr
  refine ⟨x1.t, x1.C, v, hst.run, hv, ?_, hst.le, ?_⟩
  · -- the emitted tokens
    have hMa : x1.M.a = M.a := hext.a
    have hk : x1.K.fr A.emit = some (arrOf s0 A.emit, E0 ++ (toks.take (T - 2 - 1)).map Val.num) := by
      rw [hke, hfr, frA_emit]
    obtain ⟨o, hg, hkind⟩ := hs.emitG
    refine (hF.emitted henv hs.cell (by rw [hMa]; exact hfix _ hcE) (by rw [hMa]; exact hfix _ hb) hk hg hkind
      hwc hwe).trans ?_
    have hnum : ∀ j, j < tab0.length + 1 → x1.M.num j = (M.setNum tab0.length toks[T - 2]).num j :=
      fun j hj => hext.num j hj
    have hnt : x1.M.num A.tok = toks[T - 3] := by
      rw [hnum A.tok (by have := st.htok; omega), (Map.setNum_ext M tab0.length toks[T - 2]).num A.tok st.htok]
      have := htokM; rw [show T - 2 - 1 = T - 3 by omega, List.getElem?_eq_getElem (by omega)] at this
      exact (Option.some.inj this).symm
    rcases hks with rfl | rfl
    · show some (E0 ++ (toks.take (T - 2 - 1)).map Val.num ++ [Val.num (x1.M.nv (.ref A.tok))]) = _
      simp only [Map.nv, hnt]
      rw [show T - 2 - 1 = T - 3 by omega, show T - 3 + [A.tok].length = T - 3 + 1 by rfl,
        ← take_map_succ toks (T - 3) (by omega), List.append_assoc]
    · have hnn : x1.M.num tab0.length = toks[T - 2] := by
        rw [hnum tab0.length (by omega), Map.setNum_self]
      show some (E0 ++ (toks.take (T - 2 - 1)).map Val.num ++ [Val.num (x1.M.nv (.ref A.tok)),
        Val.num (x1.M.nv (.ref tab0.length))]) = _
      simp only [Map.nv, hnt, hnn]
      rw [show T - 2 - 1 = T - 3 by omega, show T - 3 + [A.tok, tab0.length].length = T - 3 + 1 + 1 by rfl,
        ← take_map_succ toks (T - 3 + 1) (by omega), ← take_map_succ toks (T - 3) (by omega)]
      simp only [List.append_assoc, List.singleton_append, show T - 3 + 1 = T - 2 by omega]
  · exact hG hi nx M K t C x1 hGx hfix h hKfr hlo hhi hst.run hst.tr hext hst.val (hklo.trans hlo) (hkhi.trans hhi)
      hke hend

end Halt

/-! ## The checked halting cases as chains -/

/-- The simulation facts of an acceptance function `ok` under the frames `W` (`AccSim`), framing
the arrays `framed`. -/
structure AccSimW (P : LoadP) (W : Nat → Option WFrame) (VBOk : (Nat → F64) → Prop) (ok : St LF.S → SSrv → Bool)
    (framed : List Nat) where
  jsP : Disp.JSP LF
  hj : jsP.lo = P.lo ∧ jsP.hi = P.E ∧ ∀ a, a ∈ jsP.framed ↔ a ∈ framed
  sim : ∀ r, Disp.StepSimXVW LF (LR P r) ok (Disp.Kp jsP) W VBOk
  simL : ∀ r, Disp.StepSimXLW LF (LR P r) ok (Disp.Kp jsP) W VBOk
  ng : ∀ (r : List NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (n : Nat) (s t s1 t1 : St LF.S) (S S1 : SSrv)
    (C C1 : CSrv), Disp.Kp jsP K → VBOk ν → RelF LF (LR P r) W M ν K s S t C → ok s S = true →
    runOk LF ok n s S = some (s1, S1) → runC LF n t C = some (t1, C1) → Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx
  ngL : ∀ (r : List NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (s t s1 t1 : St LF.S) (S S1 : SSrv) (C C1 : CSrv),
    Disp.Kp jsP K → VBOk ν → RelXF LF (LR P r) W M ν K s S t C → isHalt s.ctl = false → ok s S = true →
    interpS (step LF s).run S = some (s1, S1) → interpC (step LF t).run C = some (t1, C1) →
    Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx

/-- Today's acceptances, without frames. -/
def AccSim.toW {P : LoadP} {VBOk : (Nat → F64) → Prop} {ok : St LF.S → SSrv → Bool} {framed : List Nat}
    (S : AccSim P VBOk ok framed) : AccSimW P noFrames VBOk ok framed :=
  ⟨S.jsP, ⟨S.hj.1, S.hj.2.1, fun a => by rw [S.hj.2.2]⟩, S.sim, S.simL, S.ng, S.ngL⟩

/-- A checked halting case at `A` from `st0` (server table `tab1`), split at the epilogue's spread
of `forwarded` (`ExitCase`, `FinalCase`). -/
structure ExitCaseA (A : Addr) (okA okB : St LF.S → SSrv → Bool) (s0 st0 : St LF.S) (tab1 : List SymE) (aN : Nat)
    (xs : List Val) where
  S0 : SSrv
  tab : S0.tab = tab1
  nA : Nat
  sP : St LF.S
  SP : SSrv
  okA0 : okA st0 S0 = true
  runA : runOk LF okA nA st0 S0 = some (sP, SP)
  okP : okA sP SP = true
  haltP : isHalt sP.ctl = false
  sA : St LF.S
  SA : SSrv
  stepA : interpS (step LF sP).run SP = some (sA, SA)
  acc : List Val
  env : Env
  fs : List Frame
  ctlA : sA.ctl = .ret (.obj A.fwd)
  stackA : sA.stack = .l (.spread acc [] env) :: fs
  roomA : sA.next + margin < Sim.bound
  arrA : Present sA aArrayProto
  newA : sA.next = aN
  sB : St LF.S
  SB : SSrv
  stepB : interpS (step LF sA).run SA = some (sB, SB)
  okB0 : okB sB SB = true
  nB : Nat
  sF : St LF.S
  SF : SSrv
  runB : runOk LF okB nB sB SB = some (sF, SF)
  halt : ∃ v, sF.ctl = .halt (.normal v)
  emitG : ∃ o, sF.heap.get A.emit = some (.obj o) ∧ o.kind = .array (arrOf s0 A.emit ++ xs)
  cell : sF.cell? A.cE = some (some (.obj A.emit))

/-- Today's exit cases. -/
def ExitCase.toA {okA okB : St LF.S → SSrv → Bool} {s0 st0 : St LF.S} {tab1 : List SymE} {aN : Nat} {xs : List Val}
    (ec : ExitCase okA okB s0 st0 tab1 2590 aN xs) : ExitCaseA addr0 okA okB s0 st0 tab1 aN xs :=
  ⟨ec.S0, ec.tab, ec.nA, ec.sP, ec.SP, ec.okA0, ec.runA, ec.okP, ec.haltP, ec.sA, ec.SA, ec.stepA, ec.acc, ec.env,
    ec.fs, ec.ctlA, ec.stackA, ec.roomA, ec.arrA, ec.newA, ec.sB, ec.SB, ec.stepB, ec.okB0, ec.nB, ec.sF, ec.SF,
    ec.runB, ec.halt, ec.emitG, ec.cell⟩

/-- Today's final cases. -/
def FinalCase.toA {okA okB : St LF.S → SSrv → Bool} {s0 : St LF.S} {tab0 : List SymE} {aN : Nat}
    (fc : FinalCase okA okB s0 tab0 2590 aN) :
    ExitCaseA addr0 okA okB s0 (finalStart s0 tab0.length) (tab0 ++ [.var 17]) aN
      [.num (.ref 79), .num (.ref tab0.length)] :=
  ⟨fc.S0, fc.tab, fc.nA, fc.sP, fc.SP, fc.okA0, fc.runA, fc.okP, fc.haltP, fc.sA, fc.SA, fc.stepA, fc.acc, fc.env,
    fc.fs, fc.ctlA, fc.stackA, fc.roomA, fc.arrA, fc.newA, fc.sB, fc.SB, fc.stepB, fc.okB0, fc.nB, fc.sF, fc.SF,
    fc.runB, fc.halt, fc.emitG, fc.cell⟩

/-- An exit case's steps. -/
abbrev ExitCaseA.n {A : Addr} {okA okB : St LF.S → SSrv → Bool} {s0 st0 : St LF.S} {tab1 : List SymE} {aN : Nat}
    {xs : List Val} (ec : ExitCaseA A okA okB s0 st0 tab1 aN xs) : Nat := ec.nA + 1 + 1 + ec.nB

section ToSeg
variable {F : Ffi} {L : SegLaws F} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame}
  {Q Q' : (Nat → F64) → Ctx → Prop} {s s' : St F.S} {S S' : SSrv}

/-- **The framed spread under the frames** (`PieceSim.spread`, `Disp.step_spread_framedW`): the
spread array and the new array carry no frame of `W`. -/
theorem PieceSim.spreadW {b : Nat} {acc : List Val} {env : Env} {fs : List Frame}
    (hc : s.ctl = .ret (.obj b)) (hst : s.stack = .l (.spread acc [] env) :: fs)
    (hn : s.next + margin < Sim.bound) (hp : Present s aArrayProto)
    (hs : interpS (step F s).run S = some (s', S'))
    (hwb : W b = none) (hwn : W s.next = none)
    (hfr : ∀ ν K, Q ν K → ∃ p, K.fr b = some p)
    (hQ : ∀ (M : Map) ν K pre pre', Q ν K → K.fr b = some (pre, pre') →
      Q' ν (Disp.Ctx.frameAt K s.next (acc.reverse ++ pre, M.vals acc.reverse ++ pre')) ∧
        L.KR K (Disp.Ctx.frameAt K s.next (acc.reverse ++ pre, M.vals acc.reverse ++ pre')))
    (hTR : ∀ t t' : St F.S, t'.ffi = t.ffi → L.TR t t') :
    PieceSim L (relQW F FR W Q) (relQW F FR W Q') 1 s S s' S' := by
  refine PieceSim.ofMSim hs fun x hx => ?_
  obtain ⟨h, hq⟩ := hx
  obtain ⟨⟨pre, pre'⟩, hb⟩ := hfr _ _ hq
  have hth : isHalt x.t.ctl = false := by rw [h.ctl, hc]; rfl
  refine ⟨hth, ?_⟩
  have hm := Disp.step_spread_framedW h hc hst hb hn hp hwb hwn
  refine hm.mono fun M' S1 C1 s1 t1 ⟨hg, hr, hffi⟩ => ⟨hg, Disp.Ctx.frameAt x.K s.next (acc.reverse ++ pre,
    x.M.vals acc.reverse ++ pre'), (hQ x.M _ _ _ _ hq hb).2, hTR _ _ hffi, hr, (hQ x.M _ _ _ _ hq hb).1⟩

end ToSeg

section ExitSeg
variable {A : Addr} {P : LoadP} {W : Nat → Option WFrame} {VBOk : (Nat → F64) → Prop}
  {okA okB : St LF.S → SSrv → Bool} {s0 st0 : St LF.S} {tab1 : List SymE} {aN : Nat} {xs : List Val}

/-- The spread's new context: the framed accumulator at the new array. -/
theorem kp_frameAtA {jsA jsB : Disp.JSP LF} {xs' : List Nat}
    (hjA : jsA.lo = P.lo ∧ jsA.hi = P.E ∧ ∀ a, a ∈ jsA.framed ↔ a ∈ xs')
    (hjB : jsB.lo = P.lo ∧ jsB.hi = P.E ∧ ∀ a, a ∈ jsB.framed ↔ a ∈ xs' ++ [aN]) {K : Ctx} (hK : Disp.Kp jsA K)
    (p : List Val × List Val) : Disp.Kp jsB (Disp.Ctx.frameAt K aN p) := by
  obtain ⟨hlo, hhi, hfr⟩ := hK
  refine ⟨hlo.trans (hjA.1.trans hjB.1.symm), hhi.trans (hjA.2.1.trans hjB.2.1.symm), fun a => ?_⟩
  rw [hjB.2.2]
  show (bif Nat.beq a aN then some p else K.fr a) ≠ none ↔ _
  by_cases ha : a = aN
  · subst ha; simp
  · rw [Addr.beq_ne ha, Bool.cond_false, hfr, hjA.2.2]
    simp [ha]

/-- **A checked halting case as a halting chain** under the frames `W`: its first segment, the
step into the spread's state, the framed spread (`forwarded` and the new array carry no frame of
`W`), its second segment. -/
noncomputable def ExitCaseA.toSeg {fx : List Nat} (ec : ExitCaseA A okA okB s0 st0 tab1 aN xs)
    (SA : AccSimW P W VBOk okA (A.fwd :: A.emit :: fx)) (SB : AccSimW P W VBOk okB (A.fwd :: A.emit :: fx ++ [aN]))
    (haN2 : aN ≠ A.emit) (hwf : W A.fwd = none) (hwn : W aN = none) (r : List NumV) :
    HaltSegA A W P r s0 st0 tab1 xs where
  S0 := ec.S0
  tab := ec.tab
  QA ν K := Disp.Kp SA.jsP K ∧ VBOk ν
  QF ν K := Disp.Kp SB.jsP K ∧ VBOk ν
  case :=
    { Rend := relQW LF (LR P r) W fun ν K => Disp.Kp SB.jsP K ∧ VBOk ν
      sF := ec.sF
      SF := ec.SF
      chain :=
        .cons ec.nA (PieceSim.ofRunOkW (SA.sim r) (fun _ _ h => h)
            (fun M ν K n s t s1 t1 S S1 C C1 hq hr hok hrun hrc =>
              SA.ng r M ν K n s t s1 t1 S S1 C C1 hq.1 hq.2 hr hok hrun hrc)
            ec.okA0 ec.runA) (interpS_runOk_len ec.runA) <|
        .cons 1 (PieceSim.ofLastW (SA.simL r) (fun _ _ h => h)
            (fun M ν K s t s1 t1 S S1 C C1 hq hr hh hok hs ht =>
              SA.ngL r M ν K s t s1 t1 S S1 C C1 hq.1 hq.2 hr hh hok hs ht)
            ec.okP ec.haltP ec.stepA) (interpS_len _ _ _ _ ec.stepA) <|
        .cons 0 (PieceSim.relOfXW (fun r env fs he => by rw [ec.stackA] at he; cases he)) (Nat.le_refl _) <|
        .cons 1 (PieceSim.spreadW (Q' := fun ν K => Disp.Kp SB.jsP K ∧ VBOk ν) ec.ctlA ec.stackA ec.roomA ec.arrA
            ec.stepB hwf (by rw [ec.newA]; exact hwn)
            (fun ν K hq => by
              have := (hq.1.2.2 A.fwd).2 (by rw [SA.hj.2.2]; simp)
              exact Option.ne_none_iff_exists'.1 this)
            (fun M ν K pre pre' hq _ => by
              rw [ec.newA]
              refine ⟨⟨kp_frameAtA SA.hj SB.hj hq.1 _, hq.2⟩, rfl, rfl, ?_⟩
              show (bif Nat.beq A.emit aN then _ else K.fr A.emit) = K.fr A.emit
              rw [Addr.beq_ne haN2.symm]; rfl)
            (fun t t' he => by show Host.Mlx.Ffi.NGrow _ _; rw [he]; exact Host.Mlx.Ffi.NGrow.refl _))
          (interpS_len _ _ _ _ ec.stepB) <|
        .cons ec.nB (PieceSim.ofRunOkRelW (SB.sim r) (fun _ _ h => h)
            (fun M ν K n s t s1 t1 S S1 C C1 hq hr hok hrun hrc =>
              SB.ng r M ν K n s t s1 t1 S S1 C C1 hq.1 hq.2 hr hok hrun hrc)
            ec.okB0 ec.runB (fun v hv => by obtain ⟨w, hw⟩ := ec.halt; rw [hw] at hv; cases hv))
          (interpS_runOk_len ec.runB) <|
        .nil _ _ _
      fin := fun x hx => by
        obtain ⟨w, hw⟩ := ec.halt
        exact ⟨x.M.val w, by rw [hx.1.ctl, hw]; rfl⟩ }
  rend _ _ _ h := h
  emitG := ec.emitG
  cell := ec.cell

theorem ExitCaseA.toSeg_n {fx : List Nat} (ec : ExitCaseA A okA okB s0 st0 tab1 aN xs)
    (SA : AccSimW P W VBOk okA (A.fwd :: A.emit :: fx)) (SB : AccSimW P W VBOk okB (A.fwd :: A.emit :: fx ++ [aN]))
    (haN2 : aN ≠ A.emit) (hwf : W A.fwd = none) (hwn : W aN = none) (r : List NumV) :
    (ec.toSeg SA SB haN2 hwf hwn r).case.n = ec.n := by
  show ec.nA + (1 + (0 + (1 + (ec.nB + 0)))) = ec.nA + 1 + 1 + ec.nB
  omega

end ExitSeg

end Host.Ts.Sim
