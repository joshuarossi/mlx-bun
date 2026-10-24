import host.sim.LoopFinal
namespace Host.Ts.Sim
open Host.Ts Host.Ts.Sim.Template

/-! # The EOS exits of the loop

A halting case of the template (`ExitCase`) runs from a start state `st0` of the
template `s0` to the halt, split at the epilogue's spread of `forwarded` like a final case
(`FinalCase`); at the halt the `emitted` array is the template's followed by `xs`.
`exit_run` simulates it from any related start. Two starts are used:

* `exit_step`: EOS read at the cut of loop iteration `i` (start `s0` itself, nothing
  appended: the EOS token is not yielded);
* `finalE_step`: EOS read in the final iteration (start `finalStart s0 tab0.length` with
  the look-ahead token, the cut's token appended).

Each has an obligation on the loop's further invariant `Gx` (`ExitGStep`, `FinalEGStep`),
and the conclusions expose the end relation with the loop's fixed addresses, from which
the halt's read-only projections transfer to the target. -/

/-- A checked halting case from `st0` (server table `tab1`), split at the epilogue's spread
of `forwarded`; the second segment's acceptance frames the spread's new array `aN`. -/
structure ExitCase (okA okB : St LF.S → SSrv → Bool) (s0 st0 : St LF.S) (tab1 : List SymE) (cE aN : Nat)
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
  ctlA : sA.ctl = .ret (.obj 2673447)
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
  emitG : ∃ o, sF.heap.get 12502 = some (.obj o) ∧ o.kind = .array (arrOf s0 12502 ++ xs)
  cell : sF.cell? cE = some (some (.obj 12502))

/-- The steps of an exit case. -/
abbrev ExitCase.n {okA okB : St LF.S → SSrv → Bool} {s0 st0 : St LF.S} {tab1 : List SymE} {cE aN : Nat}
    {xs : List Val} (ec : ExitCase okA okB s0 st0 tab1 cE aN xs) : Nat := ec.nA + 1 + 1 + ec.nB

/-- **An exit case's run.** From a start related to `st0` (the framed `forwarded` and `emitted`
prefixes of `s0`), the target halts after the case's steps, related to the case's halt with
the spread's new array framed; the map extends the start's. -/
theorem exit_run {okA okB : St LF.S → SSrv → Bool} {P : LoadP} {s0 st0 : St LF.S} {tab1 : List SymE}
    {jsPA jsPB : Disp.JSP LF} {VBOk : (Nat → F64) → Prop} {cE aN : Nat} {xs : List Val}
    (hsimA : ∀ r, Disp.StepSimXV LF (LR P r) okA (Disp.Kp jsPA) VBOk)
    (hsimB : ∀ r, Disp.StepSimXV LF (LR P r) okB (Disp.Kp jsPB) VBOk)
    (hngA : ∀ (r : List NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (n : Nat) (s t s1 t1 : St LF.S) (S S1 : SSrv)
      (C C1 : CSrv), Disp.Kp jsPA K → VBOk ν → Rel LF (LR P r) M ν K s S t C → okA s S = true →
      runOk LF okA n s S = some (s1, S1) → runC LF n t C = some (t1, C1) → Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx)
    (hngB : ∀ (r : List NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (n : Nat) (s t s1 t1 : St LF.S) (S S1 : SSrv)
      (C C1 : CSrv), Disp.Kp jsPB K → VBOk ν → Rel LF (LR P r) M ν K s S t C → okB s S = true →
      runOk LF okB n s S = some (s1, S1) → runC LF n t C = some (t1, C1) → Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx)
    (hsimAL : ∀ r, Disp.StepSimXL LF (LR P r) okA (Disp.Kp jsPA) VBOk)
    (hngAL : ∀ (r : List NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (s t s1 t1 : St LF.S) (S S1 : SSrv) (C C1 : CSrv),
      Disp.Kp jsPA K → VBOk ν → RelX LF (LR P r) M ν K s S t C → isHalt s.ctl = false → okA s S = true →
      interpS (step LF s).run S = some (s1, S1) → interpC (step LF t).run C = some (t1, C1) →
      Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx)
    (hjA : jsPA.lo = P.lo ∧ jsPA.hi = P.E ∧ jsPA.framed = [2673447, 12502])
    (hjB : jsPB.lo = P.lo ∧ jsPB.hi = P.E ∧ jsPB.framed = [2673447, 12502, aN])
    (ec : ExitCase okA okB s0 st0 tab1 cE aN xs) (haN2 : aN ≠ 12502)
    {r : List NumV} {M : Map} {ν : Nat → F64} {K : Ctx} {t : St LF.S} {C : CSrv} {p1 p2 : List Val}
    (h : Rel LF (LR P r) M ν K st0 ec.S0 t C) (hfr : K.fr = frOf s0 p1 p2) (hlo : K.lo = P.lo)
    (hhi : K.hi = P.E) (hVB : VBOk ν) :
    ∃ MF KF tF CF v, runC LF ec.n t C = some (tF, CF) ∧ tF.ctl = .halt (.normal v) ∧
      Ext M MF ec.S0.tab.length ∧ KF.lo = P.lo ∧ KF.hi = P.E ∧
      (∀ a, KF.fr a ≠ none ↔ a ∈ [2673447, 12502, aN]) ∧ KF.fr 12502 = some (arrOf s0 12502, p2) ∧
      Rel LF (LR P r) MF ν KF ec.sF ec.SF tF CF ∧ Host.Mlx.Ffi.NGrow t.ffi.mlx tF.ffi.mlx ∧ CSrv.Le C CF := by
  have hKA : Disp.Kp jsPA K := ⟨hlo.trans hjA.1.symm, hhi.trans hjA.2.1.symm, fun a => by
    rw [hfr, hjA.2.2]; exact frOf_ne_none s0 p1 _ a⟩
  -- segment A
  obtain ⟨MP, tP, CP, hrP, heP, hxP⟩ := Disp.runOk_simXV LF _ okA _ VBOk (hsimA _) _ K hKA hVB ec.nA _ _ _ t C
    ec.sP ec.SP (Or.inl h) ec.okA0 ec.runA
  obtain ⟨MA, tA, CA, htA1, heA1, hxA⟩ := hsimAL _ MP _ K ec.sP ec.SP tP CP ec.sA ec.SA hKA hVB hxP ec.haltP
    ec.okP ec.stepA
  have hA := hxA.rel_frame (fun r env fs he => by rw [ec.stackA] at he; cases he)
  have hrA : runC LF (ec.nA + 1) t C = some (tA, CA) := runC_trans hrP (by
    simp only [runC, runWith_succ, hxP.isHalt, ec.haltP, Bool.cond_false, htA1, St.rebuild_eq]; rfl)
  have hlenA : ec.S0.tab.length ≤ ec.SA.tab.length :=
    Nat.le_trans (interpS_runOk_len ec.runA) (interpS_len _ _ _ _ ec.stepA)
  have heA : Ext M MA ec.S0.tab.length := heP.trans heA1 (interpS_runOk_len ec.runA)
  -- the spread
  have hk1 : K.fr 2673447 = some (arrOf s0 2673447, p1) := by rw [hfr]; rfl
  have hm := Disp.step_spread_framed hA ec.ctlA ec.stackA hk1 ec.roomA ec.arrA
  have htA : isHalt tA.ctl = false := by rw [hA.isHalt, ec.ctlA]; rfl
  obtain ⟨MB, tB, CB, hrB, hgB, hB, htB⟩ := msim_runC1 hm ec.stepB htA
  -- segment B
  have hKB : Disp.Kp jsPB ⟨fun a => bif Nat.beq a ec.sA.next then
      some (ec.acc.reverse ++ arrOf s0 2673447, MA.vals ec.acc.reverse ++ p1) else K.fr a,
      K.base, K.base', K.D, K.lo, K.hi⟩ := by
    refine ⟨hlo.trans hjB.1.symm, hhi.trans hjB.2.1.symm, fun a => ?_⟩
    rw [hjB.2.2]
    show (bif Nat.beq a ec.sA.next then _ else K.fr a) ≠ none ↔ _
    rw [ec.newA]
    by_cases ha : a = aN
    · subst ha; simp
    · have : Nat.beq a aN = false := by cases hq : Nat.beq a aN; rfl; exact absurd (Nat.eq_of_beq_eq_true hq) ha
      rw [this, Bool.cond_false, hfr, frOf_ne_none]
      simp [ha]
  obtain ⟨MF, tF, CF, hrF, heF, hF⟩ := iter_run (hsimB _) hKB hVB hB ec.okB0 ec.runB
    (fun v hv => by obtain ⟨w, hw⟩ := ec.halt; rw [hw] at hv; cases hv)
  have hgrow : Host.Mlx.Ffi.NGrow t.ffi.mlx tF.ffi.mlx :=
    (((hngA _ _ _ _ _ _ _ _ _ _ _ _ _ hKA hVB h ec.okA0 ec.runA hrP).trans
      (hngAL _ _ _ _ _ _ _ _ _ _ _ _ hKA hVB hxP ec.haltP ec.okP ec.stepA htA1)).trans
      (by rw [htB]; exact Host.Mlx.Ffi.NGrow.refl _)).trans
      (hngB _ _ _ _ _ _ _ _ _ _ _ _ _ hKB hVB hB ec.okB0 ec.runB hrF)
  obtain ⟨v, hv⟩ := ec.halt
  have hrun : runC LF ec.n t C = some (tF, CF) := by
    show runC LF (ec.nA + 1 + 1 + ec.nB) t C = _
    rw [show ec.nA + 1 + 1 + ec.nB = (ec.nA + 1) + (1 + ec.nB) by omega]
    exact runC_trans hrA (runC_trans hrB hrF)
  have hlenB := interpS_len _ _ _ _ ec.stepB
  refine ⟨MF, ⟨fun a => bif Nat.beq a ec.sA.next then
      some (ec.acc.reverse ++ arrOf s0 2673447, MA.vals ec.acc.reverse ++ p1) else K.fr a,
      K.base, K.base', K.D, K.lo, K.hi⟩, tF, CF, MF.val v, hrun, by rw [hF.ctl, hv]; rfl,
    (heA.trans hgB.ext hlenA).trans heF (Nat.le_trans hlenA hlenB), hlo, hhi,
    fun a => by have := hKB.2.2 a; rwa [hjB.2.2] at this, ?_, hF,
    hgrow, (runC_le _ _ _ _ _ hrA).trans ((runC_le _ _ _ _ _ hrB).trans (runC_le _ _ _ _ _ hrF))⟩
  show (bif Nat.beq 12502 ec.sA.next then _ else K.fr 12502) = _
  rw [ec.newA]
  have : Nat.beq 12502 aN = false := by
    cases hq : Nat.beq 12502 aN; rfl; exact absurd (Nat.eq_of_beq_eq_true hq).symm haN2
  rw [this, Bool.cond_false, hfr]; rfl

/-! ## EOS at a loop cut -/

/-- The obligation of the exit case at iteration `i` on the further invariant `Gx`: from the
start relation (with the loop's fixed addresses), the target run and the relation at the
case's halted end, the goal `G` holds at the target's end. -/
def ExitGStep (Gx : Nat → Map → St LF.S → CSrv → Prop) (P : LoadP) (fixA : List Nat)
    {okA okB : St LF.S → SSrv → Bool} {s0 : St LF.S} {tab0 : List SymE} {cE aN : Nat}
    (ec : ExitCase okA okB s0 s0 tab0 cE aN []) (ρ : Nat → F64) (T : Nat) (tk : Nat → Nat) (toks : List NumV)
    (i : Nat) (G : St LF.S → CSrv → Prop) : Prop :=
  ∀ (nx : Nat) (M : Map) (K : Ctx) (t : St LF.S) (C : CSrv) (MF : Map) (KF : Ctx) (tF : St LF.S) (CF : CSrv),
    Gx i M t C → (∀ a ∈ fixA, M.a a = a) →
    Rel LF (LR P (toks.drop i)) M (loopVal ρ T (i + 2) i (cap i) (tk (i + 1)) (tk i) nx) K s0 ⟨tab0, []⟩ t C →
    (∀ a, K.fr a ≠ none ↔ a ∈ [2673447, 12502]) → K.lo = P.lo → K.hi = P.E →
    runC LF ec.n t C = some (tF, CF) → Host.Mlx.Ffi.NGrow t.ffi.mlx tF.ffi.mlx →
    Ext M MF tab0.length → KF.lo = P.lo → KF.hi = P.E → (∀ a, KF.fr a ≠ none ↔ a ∈ [2673447, 12502, aN]) →
    Rel LF (LR P (toks.drop i)) MF (loopVal ρ T (i + 2) i (cap i) (tk (i + 1)) (tk i) nx) KF ec.sF ec.SF tF CF →
    G tF CF

/-- **EOS at a loop cut.** From the loop invariant at iteration `i`, the checked exit case
takes the target to a halted state whose `emitted` binding is the base prefix followed by the
first `i - 1` readbacks (the cut's token, EOS, is not yielded), related to the case's halt with
the loop's fixed addresses kept. -/
theorem exit_step {Gx : Nat → Map → St LF.S → CSrv → Prop} {G : St LF.S → CSrv → Prop}
    {okA okB : St LF.S → SSrv → Bool} {P : LoadP} {s0 : St LF.S} {tab0 : List SymE}
    {fixA : List Nat} {jsPA jsPB : Disp.JSP LF} {VBOk : (Nat → F64) → Prop} {cE aN : Nat}
    (hsimA : ∀ r, Disp.StepSimXV LF (LR P r) okA (Disp.Kp jsPA) VBOk)
    (hsimB : ∀ r, Disp.StepSimXV LF (LR P r) okB (Disp.Kp jsPB) VBOk)
    (hngA : ∀ (r : List NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (n : Nat) (s t s1 t1 : St LF.S) (S S1 : SSrv)
      (C C1 : CSrv), Disp.Kp jsPA K → VBOk ν → Rel LF (LR P r) M ν K s S t C → okA s S = true →
      runOk LF okA n s S = some (s1, S1) → runC LF n t C = some (t1, C1) → Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx)
    (hngB : ∀ (r : List NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (n : Nat) (s t s1 t1 : St LF.S) (S S1 : SSrv)
      (C C1 : CSrv), Disp.Kp jsPB K → VBOk ν → Rel LF (LR P r) M ν K s S t C → okB s S = true →
      runOk LF okB n s S = some (s1, S1) → runC LF n t C = some (t1, C1) → Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx)
    (hsimAL : ∀ r, Disp.StepSimXL LF (LR P r) okA (Disp.Kp jsPA) VBOk)
    (hngAL : ∀ (r : List NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (s t s1 t1 : St LF.S) (S S1 : SSrv) (C C1 : CSrv),
      Disp.Kp jsPA K → VBOk ν → RelX LF (LR P r) M ν K s S t C → isHalt s.ctl = false → okA s S = true →
      interpS (step LF s).run S = some (s1, S1) → interpC (step LF t).run C = some (t1, C1) →
      Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx)
    (hjA : jsPA.lo = P.lo ∧ jsPA.hi = P.E ∧ jsPA.framed = [2673447, 12502])
    (hjB : jsPB.lo = P.lo ∧ jsPB.hi = P.E ∧ jsPB.framed = [2673447, 12502, aN])
    (ec : ExitCase okA okB s0 s0 tab0 cE aN []) (hcE : cE ∈ fixA) (hb : 12502 ∈ fixA) (haN2 : aN ≠ 12502)
    {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {ΔJ ΔH ΔN : Nat}
    {i : Nat} {t : St LF.S} {C : CSrv} {env : Env} {nm : Name}
    (hinv : LoopInv Gx P s0 tab0 fixA ρ T tk toks E0 ΔJ ΔH ΔN i t C)
    (hgood : ∀ nx, Good (loopVal ρ T (i + 2) i (cap i) (tk (i + 1)) (tk i) nx) ec.S0.oracle)
    (hVB : ∀ nx, nx ≤ 2 ^ 20 → VBOk (loopVal ρ T (i + 2) i (cap i) (tk (i + 1)) (tk i) nx))
    (henv : lookupEnv nm env = some cE) (hG : ExitGStep Gx P fixA ec ρ T tk toks i G) :
    ∃ tF CF v, runC LF ec.n t C = some (tF, CF) ∧ tF.ctl = .halt (.normal v) ∧
      (bindingOf tF env nm).bind (Host.Load.Extract.elements tF) = some (E0 ++ (toks.take (i - 1)).map Val.num) ∧
      CSrv.Le C CF ∧ G tF CF ∧
      ∃ MF ν KF, Rel LF (LR P (toks.drop i)) MF ν KF ec.sF ec.SF tF CF ∧ ∀ a ∈ fixA, MF.a a = a := by
  obtain ⟨M, K, nx, p1, h, hfr, hlo, hhi, hbase, h79, hnx, hvals, hD, hHi, hNi, hfix, hGx⟩ := hinv
  have h1 := h.srvSwap ec.tab ⟨fun j e he => h.srv.num j e (by rw [ec.tab] at he; exact he), hgood nx⟩
  obtain ⟨MF, KF, tF, CF, v, hrun, hv, hext, hKlo, hKhi, hKfr, hk12, hF, hgrow, hle⟩ :=
    exit_run hsimA hsimB hngA hngB hsimAL hngAL hjA hjB ec haN2 h1 hfr hlo hhi (hVB nx hnx)
  have hMa : MF.a = M.a := hext.a
  have hfixF : ∀ a ∈ fixA, MF.a a = a := fun a ha => by rw [hMa]; exact hfix a ha
  obtain ⟨o, hg, hkind⟩ := ec.emitG
  have hem := hF.emitted henv ec.cell (hfixF cE hcE) (hfixF 12502 hb) hk12 hg hkind
  refine ⟨tF, CF, v, hrun, hv, ?_, hle, ?_, MF, _, KF, hF, hfixF⟩
  · refine hem.trans ?_; simp [Map.vals]
  · exact hG nx M K t C MF KF tF CF hGx hfix h (fun a => by rw [hfr]; exact frOf_ne_none s0 p1 _ a) hlo hhi hrun
      hgrow (by rw [← ec.tab]; exact hext) hKlo hKhi hKfr hF

/-! ## EOS at the final iteration's look-ahead token -/

/-- The obligation of an EOS final case on the loop's further invariant `Gx` (as
`FinalGStep`). -/
def FinalEGStep (Gx : Nat → Map → St LF.S → CSrv → Prop) (P : LoadP) (fixA : List Nat)
    {okA okB : St LF.S → SSrv → Bool} {s0 : St LF.S} {tab0 : List SymE} {cE aN : Nat}
    (ec : ExitCase okA okB s0 (finalStart s0 tab0.length) (tab0 ++ [.var 17]) cE aN [.num (.ref 79)])
    (ρ : Nat → F64) (T : Nat) (tk : Nat → Nat) (toks : List NumV) (G : St LF.S → CSrv → Prop) : Prop :=
  ∀ (hlen : T - 2 < toks.length) (nx : Nat) (M : Map) (K : Ctx) (t : St LF.S) (C : CSrv) (MF : Map) (KF : Ctx)
    (tF : St LF.S) (CF : CSrv), Gx (T - 2) M t C → (∀ a ∈ fixA, M.a a = a) →
    Rel LF (LR P (toks.drop (T - 2))) M (loopVal ρ T T (T - 2) (cap (T - 2)) (tk (T - 1)) (tk (T - 2)) nx) K s0
      ⟨tab0, []⟩ t C →
    (∀ a, K.fr a ≠ none ↔ a ∈ [2673447, 12502]) → K.lo = P.lo → K.hi = P.E →
    runC LF ec.n t C = some (tF, CF) →
    Host.Mlx.Ffi.NGrow t.ffi.mlx tF.ffi.mlx →
    Ext (M.setNum tab0.length toks[T - 2]) MF (tab0.length + 1) → KF.lo = P.lo → KF.hi = P.E →
    (∀ a, KF.fr a ≠ none ↔ a ∈ [2673447, 12502, aN]) →
    Rel LF (LR P (toks.drop (T - 1))) MF (loopVal ρ T T (T - 2) (cap (T - 2)) (tk (T - 1)) (tk (T - 2)) (tk T)) KF
      ec.sF ec.SF tF CF →
    G tF CF

/-- **EOS at the last token.** From the loop invariant at iteration `T - 2`, the checked EOS
final case takes the target to a halted state whose `emitted` binding is the base prefix
followed by the first `T - 2` readbacks (the cut's token is yielded, the look-ahead EOS is
not), related to the case's halt with the loop's fixed addresses kept. -/
theorem finalE_step {Gx : Nat → Map → St LF.S → CSrv → Prop} {G : St LF.S → CSrv → Prop}
    {okA okB : St LF.S → SSrv → Bool} {P : LoadP} {s0 : St LF.S} {tab0 : List SymE}
    {fixA : List Nat} {jsPA jsPB : Disp.JSP LF} {VBOk : (Nat → F64) → Prop} {cE aN : Nat}
    (hsimA : ∀ r, Disp.StepSimXV LF (LR P r) okA (Disp.Kp jsPA) VBOk)
    (hsimB : ∀ r, Disp.StepSimXV LF (LR P r) okB (Disp.Kp jsPB) VBOk)
    (hngA : ∀ (r : List NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (n : Nat) (s t s1 t1 : St LF.S) (S S1 : SSrv)
      (C C1 : CSrv), Disp.Kp jsPA K → VBOk ν → Rel LF (LR P r) M ν K s S t C → okA s S = true →
      runOk LF okA n s S = some (s1, S1) → runC LF n t C = some (t1, C1) → Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx)
    (hngB : ∀ (r : List NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (n : Nat) (s t s1 t1 : St LF.S) (S S1 : SSrv)
      (C C1 : CSrv), Disp.Kp jsPB K → VBOk ν → Rel LF (LR P r) M ν K s S t C → okB s S = true →
      runOk LF okB n s S = some (s1, S1) → runC LF n t C = some (t1, C1) → Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx)
    (hsimAL : ∀ r, Disp.StepSimXL LF (LR P r) okA (Disp.Kp jsPA) VBOk)
    (hngAL : ∀ (r : List NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (s t s1 t1 : St LF.S) (S S1 : SSrv) (C C1 : CSrv),
      Disp.Kp jsPA K → VBOk ν → RelX LF (LR P r) M ν K s S t C → isHalt s.ctl = false → okA s S = true →
      interpS (step LF s).run S = some (s1, S1) → interpC (step LF t).run C = some (t1, C1) →
      Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx)
    (hjA : jsPA.lo = P.lo ∧ jsPA.hi = P.E ∧ jsPA.framed = [2673447, 12502])
    (hjB : jsPB.lo = P.lo ∧ jsPB.hi = P.E ∧ jsPB.framed = [2673447, 12502, aN])
    (st : LoopStart P s0 tab0)
    (ec : ExitCase okA okB s0 (finalStart s0 tab0.length) (tab0 ++ [.var 17]) cE aN [.num (.ref 79)])
    (hfr17 : ∀ e ∈ tab0, e.noVar 17 = true) (hcE : cE ∈ fixA) (hb : 12502 ∈ fixA) (haN2 : aN ≠ 12502)
    {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {ΔJ ΔH ΔN : Nat}
    {t : St LF.S} {C : CSrv} {env : Env} {nm : Name}
    (hinv : LoopInv Gx P s0 tab0 fixA ρ T tk toks E0 ΔJ ΔH ΔN (T - 2) t C) (hT : 3 ≤ T) (hlen : T - 1 ≤ toks.length)
    (hgood : Good (loopVal ρ T T (T - 2) (cap (T - 2)) (tk (T - 1)) (tk (T - 2)) (tk T)) ec.S0.oracle)
    (hVB : VBOk (loopVal ρ T T (T - 2) (cap (T - 2)) (tk (T - 1)) (tk (T - 2)) (tk T)))
    (henv : lookupEnv nm env = some cE) (hG : FinalEGStep Gx P fixA ec ρ T tk toks G) :
    ∃ tF CF v, runC LF ec.n t C = some (tF, CF) ∧ tF.ctl = .halt (.normal v) ∧
      (bindingOf tF env nm).bind (Host.Load.Extract.elements tF) = some (E0 ++ (toks.take (T - 2)).map Val.num) ∧
      CSrv.Le C CF ∧ G tF CF ∧
      ∃ MF ν KF, Rel LF (LR P (toks.drop (T - 1))) MF ν KF ec.sF ec.SF tF CF ∧ ∀ a ∈ fixA, MF.a a = a := by
  obtain ⟨M, K, nx, p1, h, hfr, hlo, hhi, hbase, h79, hnx, hvals, hD, hHi, hNi, hfix, hGx⟩ := hinv
  have hT1 : T - 2 + 1 = T - 1 := by omega
  have hi : T - 2 < toks.length := by omega
  have hdrop : toks.drop (T - 2) = toks[T - 2] :: toks.drop (T - 2 + 1) := List.drop_eq_getElem_cons hi
  have hT2 : T - 2 + 2 = T := by omega
  rw [hT2, hT1] at h
  have hx : C.val toks[T - 2] = some (F64.ofNat (tk T)) := by
    have := hvals (T - 2) hi; rw [hT2] at this; exact this
  -- the look-ahead reference
  have h1 := h.extendVar (loadR_laws _) hfr17 (fun q hq => by cases hq) hx
  have hf : LR P (toks.drop (T - 2 + 1)) (M.setNum tab0.length toks[T - 2]) (tab0.length + 1)
      ({ s0.ffi with mlx := { s0.ffi.mlx with tokens := s0.ffi.mlx.tokens ++ [.ref tab0.length] } }) t.ffi := by
    have := h.ffi
    rw [hdrop] at this
    exact this.addToken
  have h2 := h1.setSrcFfi (FR' := LR P (toks.drop (T - 2 + 1))) _ (by simpa using hf)
  rw [upd_loopVal] at h2
  have h3 : Rel LF (LR P (toks.drop (T - 2 + 1))) (M.setNum tab0.length toks[T - 2])
      (loopVal ρ T T (T - 2) (cap (T - 2)) (tk (T - 1)) (tk (T - 2)) (tk T)) K (finalStart s0 tab0.length)
      ec.S0 t C :=
    h2.srvSwap (by rw [ec.tab]) ⟨fun j e he => h2.srv.num j e (by rw [ec.tab] at he; exact he), hgood⟩
  obtain ⟨MF, KF, tF, CF, v, hrun, hv, hext, hKlo, hKhi, hKfr, hk12, hF, hgrow, hle⟩ :=
    exit_run hsimA hsimB hngA hngB hsimAL hngAL hjA hjB ec haN2 h3 hfr hlo hhi hVB
  have hMa : MF.a = M.a := hext.a
  have hfixF : ∀ a ∈ fixA, MF.a a = a := fun a ha => by rw [hMa]; exact hfix a ha
  have hS0 : ec.S0.tab.length = tab0.length + 1 := by rw [ec.tab]; simp
  obtain ⟨o, hg, hkind⟩ := ec.emitG
  have hem := hF.emitted henv ec.cell (hfixF cE hcE) (hfixF 12502 hb) hk12 hg hkind
  rw [hT1] at hF
  refine ⟨tF, CF, v, hrun, hv, ?_, hle, ?_, MF, _, KF, hF, hfixF⟩
  · refine hem.trans ?_
    -- the image of the cut's token
    have hn79 : MF.num 79 = toks[T - 3] := by
      rw [hext.num 79 (by have := st.h79; omega), (Map.setNum_ext M tab0.length toks[T - 2]).num 79 st.h79]
      have := h79; rw [show T - 2 - 1 = T - 3 by omega, List.getElem?_eq_getElem (by omega)] at this
      exact (Option.some.inj this).symm
    show some (E0 ++ (toks.take (T - 2 - 1)).map Val.num ++ [Val.num (MF.nv (.ref 79))]) = _
    simp only [Map.nv, hn79]
    rw [show T - 2 - 1 = T - 3 by omega, show T - 2 = T - 3 + 1 by omega, ← take_map_succ toks (T - 3) (by omega),
      List.append_assoc]
  · exact hG hi nx M K t C MF KF tF CF hGx hfix h (fun a => by rw [hfr]; exact frOf_ne_none s0 p1 _ a) hlo hhi
      hrun hgrow (by rw [← hS0]; exact hext) hKlo hKhi hKfr hF

/-! ## The loop up to a given iteration -/

/-- **The loop up to iteration `J`.** With a checked case for every iteration `i < J` whose
oracle holds there, the invariant at iteration 1 gives the invariant at iteration `J`
(`J ≤ T - 2`) after those iterations' target steps (`loop_all` is the case `J = T - 2`). -/
theorem loop_all_to {Gx : Nat → Map → St LF.S → CSrv → Prop} {ok : St LF.S → SSrv → Bool} {P : LoadP} {s0 : St LF.S}
    {tab0 : List SymE} {fixA : List Nat} {jsP : Disp.JSP LF} {VBOk : (Nat → F64) → Prop}
    (hsim : ∀ r, Disp.StepSimXV LF (LR P r) ok (Disp.Kp jsP) VBOk)
    (hjlo : jsP.lo = P.lo) (hjhi : jsP.hi = P.E) (hjfr : jsP.framed = [2673447, 12502])
    (st : LoopStart P s0 tab0) (sel : Nat → LoopCase ok P s0 tab0 fixA)
    {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {ΔJ ΔH ΔN : Nat}
    (J : Nat) (hJT : J + 2 ≤ T) (hlen : T - 2 ≤ toks.length)
    (hgood : ∀ i, 1 ≤ i → i < J → ∀ nx, Good (loopVal ρ T (i + 2) i (cap i) (tk (i + 1)) (tk i) nx) (sel i).S0.oracle)
    (hVB : ∀ i, 1 ≤ i → i < J → ∀ nx, nx ≤ 2 ^ 20 → VBOk (loopVal ρ T (i + 2) i (cap i) (tk (i + 1)) (tk i) nx))
    (hgrow : ∀ i, (sel i).grow = decide (i % 256 = 254)) (hTb : T + 3 < 2 ^ 30) (hcap : ∀ i, i < T → cap i < 2 ^ 30)
    (htk : ∀ j, j ≤ T → tk j ≤ 2 ^ 20)
    (hdJ : ∀ i, (sel i).s1.next - s0.next ≤ ΔJ) (hdH : ∀ i, (sel i).s1.ffi.mlx.next - s0.ffi.mlx.next ≤ ΔH)
    (hdN : ∀ i, (sel i).s1.ffi.mlx.nnext - s0.ffi.mlx.nnext ≤ ΔN)
    (hJ : T * ΔJ < Sim.bound) (hH : s0.ffi.mlx.next + T * ΔH + (P.E - s0.ffi.mlx.next) < 2 ^ 46)
    (hN : s0.ffi.mlx.nnext + T * ΔN + (P.NE - s0.ffi.mlx.nnext) < 2 ^ 62)
    (hng : ∀ (r : List NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (n : Nat) (s t s1 t1 : St LF.S) (S S1 : SSrv)
      (C C1 : CSrv), Disp.Kp jsP K → VBOk ν → Rel LF (LR P r) M ν K s S t C → ok s S = true →
      runOk LF ok n s S = some (s1, S1) → runC LF n t C = some (t1, C1) → Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx)
    (hG : ∀ i, 1 ≤ i → i < J → LoopGStep Gx (sel i) ρ T tk toks i)
    {t : St LF.S} {C : CSrv} (h1 : LoopInv Gx P s0 tab0 fixA ρ T tk toks E0 ΔJ ΔH ΔN 1 t C) (hJ1 : 1 ≤ J) :
    ∃ t' C', runC LF (iterSteps (fun i => (sel i).n) 1 (J - 1)) t C = some (t', C') ∧
      LoopInv Gx P s0 tab0 fixA ρ T tk toks E0 ΔJ ΔH ΔN J t' C' := by
  have := loop_induct (F := LF) (LoopInv Gx P s0 tab0 fixA ρ T tk toks E0 ΔJ ΔH ΔN) (fun i => 1 ≤ i ∧ i < J)
    (fun i => (sel i).n) (fun i t C hinv ⟨hi1, hiJ⟩ => by
      have hmul : ∀ D, i * D ≤ T * D := fun D => Nat.mul_le_mul_right D (by omega)
      exact loop_step hsim hjlo hjhi hjfr st (sel i) hinv hi1 (by omega) (hgood i hi1 hiJ) (hVB i hi1 hiJ)
        (hgrow i) (by omega) (hcap i (by omega)) (htk (i + 2) (by omega)) (hdJ i) (hdH i) (hdN i)
        (Nat.lt_of_le_of_lt (hmul ΔJ) hJ) (by have := hmul ΔH; omega) (by have := hmul ΔN; omega) hng (hG i hi1 hiJ))
    (J - 1) 1 t C h1 (fun j hj => ⟨by omega, by omega⟩)
  rw [show 1 + (J - 1) = J by omega] at this
  exact this

end Host.Ts.Sim
