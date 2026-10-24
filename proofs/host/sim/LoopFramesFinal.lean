import host.sim.LoopFrames
import host.sim.SegFinal
namespace Host.Ts.Sim
open Host.Ts Host.Ts.Sim.Template

/-! # The final iteration and the EOS exits with further frames and counter bases

`final_stepS` (SegFinal.lean), `exit_stepV`, `finalE_stepV` (LoopGen.lean) start from `LoopInvV`.
Here the same from `LoopInvF` at the load world's relation (`relL P`), with further frames `Fr` and
counter bases: `final_stepSF` (a final case over a chain, `FinalSeg`), `exit_runF`/`exit_stepF`
(EOS at a loop cut), `finalE_stepF` (EOS at the last token). The acceptances frame `forwarded`,
`emitted`, `Fr.xs` (and the spread's new array). The obligations on the further invariant are
`FinalGStepSF`, `ExitGStepF`, `FinalEGStepF`; without further frames they are the existing ones
(`FinalGStepSF_empty`, `ExitGStepF_empty`, `FinalEGStepF_empty`, definitional). -/

/-! ## The final iteration over a chain -/

/-- `FinalGStepS` with the further frames `Fr`. -/
def FinalGStepSF (Gx : Nat → Map → St LF.S → CSrv → Prop) (P : LoadP) (Fr : LoopFrames) (fixA : List Nat)
    {s0 : St LF.S} {tab0 : List SymE} {cE : Nat} {toks : List NumV} {T : Nat}
    (fc : FinalSeg P (toks.drop (T - 1)) s0 tab0 cE) (V : LoopVals) (tk : Nat → Nat) (G : St LF.S → CSrv → Prop) :
    Prop :=
  ∀ (hlen : T - 2 < toks.length) (nx : Nat) (M : Map) (K : Ctx) (t : St LF.S) (C : CSrv) (xF : SegInst LF),
    Gx (T - 2) M t C → (∀ a ∈ fixA, M.a a = a) →
    Rel LF (LR P (toks.drop (T - 2))) M (V (T - 2) nx) K s0 ⟨tab0, []⟩ t C →
    (∀ a, K.fr a ≠ none ↔ a ∈ 2673447 :: 12502 :: Fr.xs) → K.lo = P.lo → K.hi = P.E →
    runC LF fc.case.n t C = some (xF.t, xF.C) → Host.Mlx.Ffi.NGrow t.ffi.mlx xF.t.ffi.mlx →
    Ext (M.setNum tab0.length toks[T - 2]) xF.M (tab0.length + 1) → xF.ν = V (T - 2) (tk T) →
    xF.K.lo = P.lo → xF.K.hi = P.E → xF.K.fr 12502 = K.fr 12502 →
    fc.case.Rend xF fc.case.sF fc.case.SF → G xF.t xF.C

theorem FinalGStepSF_empty {Gx : Nat → Map → St LF.S → CSrv → Prop} {P : LoadP} {fixA : List Nat} {s0 : St LF.S}
    {tab0 : List SymE} {cE : Nat} {toks : List NumV} {T : Nat} (fc : FinalSeg P (toks.drop (T - 1)) s0 tab0 cE)
    (V : LoopVals) (tk : Nat → Nat) (G : St LF.S → CSrv → Prop) :
    FinalGStepSF Gx P LoopFrames.empty fixA fc V tk G ↔ FinalGStepS Gx P fixA fc V tk G := Iff.rfl

/-- **The final iteration over a chain** (`final_stepS`) from `LoopInvF`. -/
theorem final_stepSF {Gx : Nat → Map → St LF.S → CSrv → Prop} {G : St LF.S → CSrv → Prop} {P : LoadP}
    {Fr : LoopFrames} {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat} {cE : Nat}
    {V : LoopVals} {T : Nat} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {B : LoopBase} {ΔJ ΔH ΔN : Nat}
    {t : St LF.S} {C : CSrv} {env : Env} {nm : Name}
    (st : LoopStart P s0 tab0) (fc : FinalSeg P (toks.drop (T - 1)) s0 tab0 cE)
    (hfr17 : ∀ e ∈ tab0, e.noVar 17 = true) (hcE : cE ∈ fixA) (hb : 12502 ∈ fixA)
    (hupd : ∀ nx, upd (V (T - 2) nx) 17 (F64.ofNat (tk T)) = V (T - 2) (tk T))
    (hinv : LoopInvF Gx (relL P) P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN (T - 2) t C) (hT : 3 ≤ T)
    (hlen : T - 1 ≤ toks.length) (hgood : Good (V (T - 2) (tk T)) fc.S0.oracle)
    (hQA : ∀ K : Ctx, (∀ a, K.fr a ≠ none ↔ a ∈ 2673447 :: 12502 :: Fr.xs) → K.lo = P.lo → K.hi = P.E →
      fc.QA (V (T - 2) (tk T)) K)
    (henv : lookupEnv nm env = some cE) (hG : FinalGStepSF Gx P Fr fixA fc V tk G) :
    ∃ tF CF v, runC LF fc.case.n t C = some (tF, CF) ∧ tF.ctl = .halt (.normal v) ∧
      (bindingOf tF env nm).bind (Host.Load.Extract.elements tF) = some (E0 ++ (toks.take (T - 1)).map Val.num) ∧
      CSrv.Le C CF ∧ G tF CF := by
  obtain ⟨M, K, nx, p1, h, hfr, hlo, hhi, hbase, h79, hnx, hvals, hD, hHi, hNi, hfix, hGx⟩ := hinv
  have hT1 : T - 2 + 1 = T - 1 := by omega
  have hi : T - 2 < toks.length := by omega
  have hdrop : toks.drop (T - 2) = toks[T - 2] :: toks.drop (T - 2 + 1) := List.drop_eq_getElem_cons hi
  have hT2 : T - 2 + 2 = T := by omega
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
  rw [hupd] at h2
  have h3 : Rel LF (LR P (toks.drop (T - 2 + 1))) (M.setNum tab0.length toks[T - 2])
      (V (T - 2) (tk T)) K (finalStart s0 tab0.length) fc.S0 t C :=
    h2.srvSwap (by rw [fc.tab]) ⟨fun j e he => h2.srv.num j e (by rw [fc.tab] at he; exact he), hgood⟩
  rw [hT1] at h3
  have hKfr : ∀ a, K.fr a ≠ none ↔ a ∈ 2673447 :: 12502 :: Fr.xs := fun a => by
    rw [hfr]; exact frX_ne_none s0 Fr p1 _ a
  -- the chain
  obtain ⟨x1, hst, hend, ⟨v, hv⟩, -⟩ := seg_halt fc.case (x := ⟨M.setNum tab0.length toks[T - 2], V (T - 2) (tk T), K, t, C⟩)
    ⟨h3, hQA K hKfr hlo hhi⟩
  obtain ⟨hF, -⟩ := fc.rend x1 _ _ hend
  have hS0 : fc.S0.tab.length = tab0.length + 1 := by rw [fc.tab]; simp
  have hext : Ext (M.setNum tab0.length toks[T - 2]) x1.M (tab0.length + 1) := by rw [← hS0]; exact hst.ext
  have hν : x1.ν = V (T - 2) (tk T) := hst.val
  obtain ⟨hklo, hkhi, hk12⟩ := hst.kr
  refine ⟨x1.t, x1.C, v, hst.run, hv, ?_, hst.le, ?_⟩
  · -- the emitted tokens
    have hMa : x1.M.a = M.a := hext.a
    have hfa : x1.M.a cE = cE := by rw [hMa]; exact hfix cE hcE
    have hfb : x1.M.a 12502 = 12502 := by rw [hMa]; exact hfix 12502 hb
    have hk : x1.K.fr 12502 = some (arrOf s0 12502, E0 ++ (toks.take (T - 2 - 1)).map Val.num) := by
      rw [hk12, hfr]; rfl
    obtain ⟨o, hg, hkind⟩ := fc.emitG
    refine (hF.emitted henv fc.cell hfa hfb hk hg hkind).trans ?_
    have hnum : ∀ j, j < tab0.length + 1 → x1.M.num j = (M.setNum tab0.length toks[T - 2]).num j :=
      fun j hj => hext.num j hj
    have hn79 : x1.M.num 79 = toks[T - 3] := by
      rw [hnum 79 (by have := st.h79; omega), (Map.setNum_ext M tab0.length toks[T - 2]).num 79 st.h79]
      have := h79; rw [show T - 2 - 1 = T - 3 by omega, List.getElem?_eq_getElem (by omega)] at this
      exact (Option.some.inj this).symm
    have hnn : x1.M.num tab0.length = toks[T - 2] := by
      rw [hnum tab0.length (by omega), Map.setNum_self]
    show some (E0 ++ (toks.take (T - 2 - 1)).map Val.num ++ [Val.num (x1.M.nv (.ref 79)),
      Val.num (x1.M.nv (.ref tab0.length))]) = _
    simp only [Map.nv, hn79, hnn]
    rw [show T - 2 - 1 = T - 3 by omega, show T - 1 = T - 3 + 1 + 1 by omega,
      ← take_map_succ toks (T - 3 + 1) (by omega), ← take_map_succ toks (T - 3) (by omega)]
    simp only [List.append_assoc, List.singleton_append, show T - 3 + 1 = T - 2 by omega]
  · exact hG hi nx M K t C x1 hGx hfix h hKfr hlo hhi hst.run hst.tr hext hν (hklo.trans hlo) (hkhi.trans hhi)
      hk12 hend

/-! ## The EOS exits -/

/-- **An exit case's run** (`exit_run`) under the loop's frames: the acceptances frame `forwarded`,
`emitted`, `Fr.xs`, and the spread's new array `aN` in the second segment. -/
theorem exit_runF {okA okB : St LF.S → SSrv → Bool} {P : LoadP} {s0 st0 : St LF.S} {tab1 : List SymE}
    {jsPA jsPB : Disp.JSP LF} {VBOk : (Nat → F64) → Prop} {cE aN : Nat} {xs : List Val} {Fr : LoopFrames}
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
    (hjA : jsPA.lo = P.lo ∧ jsPA.hi = P.E ∧ ∀ a, a ∈ jsPA.framed ↔ a ∈ 2673447 :: 12502 :: Fr.xs)
    (hjB : jsPB.lo = P.lo ∧ jsPB.hi = P.E ∧ ∀ a, a ∈ jsPB.framed ↔ a ∈ 2673447 :: 12502 :: (Fr.xs ++ [aN]))
    (ec : ExitCase okA okB s0 st0 tab1 cE aN xs) (haN2 : aN ≠ 12502)
    {r : List NumV} {M : Map} {ν : Nat → F64} {K : Ctx} {t : St LF.S} {C : CSrv} {p1 p2 : List Val}
    (h : Rel LF (LR P r) M ν K st0 ec.S0 t C) (hfr : K.fr = frX s0 Fr.X p1 p2) (hlo : K.lo = P.lo)
    (hhi : K.hi = P.E) (hVB : VBOk ν) :
    ∃ MF KF tF CF v, runC LF ec.n t C = some (tF, CF) ∧ tF.ctl = .halt (.normal v) ∧
      Ext M MF ec.S0.tab.length ∧ KF.lo = P.lo ∧ KF.hi = P.E ∧
      (∀ a, KF.fr a ≠ none ↔ a ∈ 2673447 :: 12502 :: (Fr.xs ++ [aN])) ∧ KF.fr 12502 = some (arrOf s0 12502, p2) ∧
      Rel LF (LR P r) MF ν KF ec.sF ec.SF tF CF ∧ Host.Mlx.Ffi.NGrow t.ffi.mlx tF.ffi.mlx ∧ CSrv.Le C CF := by
  have hKA : Disp.Kp jsPA K := ⟨hlo.trans hjA.1.symm, hhi.trans hjA.2.1.symm, fun a => by
    rw [hjA.2.2, hfr]; exact frX_ne_none s0 Fr p1 _ a⟩
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
  have hfrB : ∀ a, (bif Nat.beq a ec.sA.next then
      some (ec.acc.reverse ++ arrOf s0 2673447, MA.vals ec.acc.reverse ++ p1) else K.fr a) ≠ none ↔
      a ∈ 2673447 :: 12502 :: (Fr.xs ++ [aN]) := by
    intro a
    rw [ec.newA]
    by_cases ha : a = aN
    · subst ha; simp
    · have : Nat.beq a aN = false := by cases hq : Nat.beq a aN; rfl; exact absurd (Nat.eq_of_beq_eq_true hq) ha
      rw [this, Bool.cond_false, hfr, frX_ne_none]
      simp [ha]
  have hKB : Disp.Kp jsPB ⟨fun a => bif Nat.beq a ec.sA.next then
      some (ec.acc.reverse ++ arrOf s0 2673447, MA.vals ec.acc.reverse ++ p1) else K.fr a,
      K.base, K.base', K.D, K.lo, K.hi⟩ :=
    ⟨hlo.trans hjB.1.symm, hhi.trans hjB.2.1.symm, fun a => by rw [hjB.2.2]; exact hfrB a⟩
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
    (heA.trans hgB.ext hlenA).trans heF (Nat.le_trans hlenA hlenB), hlo, hhi, hfrB, ?_, hF,
    hgrow, (runC_le _ _ _ _ _ hrA).trans ((runC_le _ _ _ _ _ hrB).trans (runC_le _ _ _ _ _ hrF))⟩
  show (bif Nat.beq 12502 ec.sA.next then _ else K.fr 12502) = _
  rw [ec.newA]
  have : Nat.beq 12502 aN = false := by
    cases hq : Nat.beq 12502 aN; rfl; exact absurd (Nat.eq_of_beq_eq_true hq).symm haN2
  rw [this, Bool.cond_false, hfr]; rfl

/-- `ExitGStepV` with the further frames `Fr`. -/
def ExitGStepF (Gx : Nat → Map → St LF.S → CSrv → Prop) (P : LoadP) (Fr : LoopFrames) (fixA : List Nat)
    {okA okB : St LF.S → SSrv → Bool} {s0 : St LF.S} {tab0 : List SymE} {cE aN : Nat}
    (ec : ExitCase okA okB s0 s0 tab0 cE aN []) (V : LoopVals) (toks : List NumV) (i : Nat)
    (G : St LF.S → CSrv → Prop) : Prop :=
  ∀ (nx : Nat) (M : Map) (K : Ctx) (t : St LF.S) (C : CSrv) (MF : Map) (KF : Ctx) (tF : St LF.S) (CF : CSrv),
    Gx i M t C → (∀ a ∈ fixA, M.a a = a) →
    Rel LF (LR P (toks.drop i)) M (V i nx) K s0 ⟨tab0, []⟩ t C →
    (∀ a, K.fr a ≠ none ↔ a ∈ 2673447 :: 12502 :: Fr.xs) → K.lo = P.lo → K.hi = P.E →
    runC LF ec.n t C = some (tF, CF) → Host.Mlx.Ffi.NGrow t.ffi.mlx tF.ffi.mlx →
    Ext M MF tab0.length → KF.lo = P.lo → KF.hi = P.E →
    (∀ a, KF.fr a ≠ none ↔ a ∈ 2673447 :: 12502 :: (Fr.xs ++ [aN])) →
    Rel LF (LR P (toks.drop i)) MF (V i nx) KF ec.sF ec.SF tF CF →
    G tF CF

theorem ExitGStepF_empty {Gx : Nat → Map → St LF.S → CSrv → Prop} {P : LoadP} {fixA : List Nat}
    {okA okB : St LF.S → SSrv → Bool} {s0 : St LF.S} {tab0 : List SymE} {cE aN : Nat}
    (ec : ExitCase okA okB s0 s0 tab0 cE aN []) (V : LoopVals) (toks : List NumV) (i : Nat)
    (G : St LF.S → CSrv → Prop) :
    ExitGStepF Gx P LoopFrames.empty fixA ec V toks i G ↔ ExitGStepV Gx P fixA ec V toks i G := Iff.rfl

/-- **EOS at a loop cut** (`exit_stepV`) from `LoopInvF`. -/
theorem exit_stepF {Gx : Nat → Map → St LF.S → CSrv → Prop} {G : St LF.S → CSrv → Prop}
    {okA okB : St LF.S → SSrv → Bool} {P : LoadP} {Fr : LoopFrames} {s0 : St LF.S} {tab0 : List SymE}
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
    (hjA : jsPA.lo = P.lo ∧ jsPA.hi = P.E ∧ ∀ a, a ∈ jsPA.framed ↔ a ∈ 2673447 :: 12502 :: Fr.xs)
    (hjB : jsPB.lo = P.lo ∧ jsPB.hi = P.E ∧ ∀ a, a ∈ jsPB.framed ↔ a ∈ 2673447 :: 12502 :: (Fr.xs ++ [aN]))
    (ec : ExitCase okA okB s0 s0 tab0 cE aN []) (hcE : cE ∈ fixA) (hb : 12502 ∈ fixA) (haN2 : aN ≠ 12502)
    {V : LoopVals} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {B : LoopBase} {ΔJ ΔH ΔN : Nat}
    {i : Nat} {t : St LF.S} {C : CSrv} {env : Env} {nm : Name}
    (hinv : LoopInvF Gx (relL P) P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN i t C)
    (hgood : ∀ nx, Good (V i nx) ec.S0.oracle)
    (hVB : ∀ nx, nx ≤ 2 ^ 20 → VBOk (V i nx))
    (henv : lookupEnv nm env = some cE) (hG : ExitGStepF Gx P Fr fixA ec V toks i G) :
    ∃ tF CF v, runC LF ec.n t C = some (tF, CF) ∧ tF.ctl = .halt (.normal v) ∧
      (bindingOf tF env nm).bind (Host.Load.Extract.elements tF) = some (E0 ++ (toks.take (i - 1)).map Val.num) ∧
      CSrv.Le C CF ∧ G tF CF ∧
      ∃ MF ν KF, Rel LF (LR P (toks.drop i)) MF ν KF ec.sF ec.SF tF CF ∧ ∀ a ∈ fixA, MF.a a = a := by
  obtain ⟨M, K, nx, p1, h, hfr, hlo, hhi, hbase, h79, hnx, hvals, hD, hHi, hNi, hfix, hGx⟩ := hinv
  have h1 := h.srvSwap ec.tab ⟨fun j e he => h.srv.num j e (by rw [ec.tab] at he; exact he), hgood nx⟩
  obtain ⟨MF, KF, tF, CF, v, hrun, hv, hext, hKlo, hKhi, hKfr, hk12, hF, hgrow, hle⟩ :=
    exit_runF hsimA hsimB hngA hngB hsimAL hngAL hjA hjB ec haN2 h1 hfr hlo hhi (hVB nx hnx)
  have hMa : MF.a = M.a := hext.a
  have hfixF : ∀ a ∈ fixA, MF.a a = a := fun a ha => by rw [hMa]; exact hfix a ha
  obtain ⟨o, hg, hkind⟩ := ec.emitG
  have hem := hF.emitted henv ec.cell (hfixF cE hcE) (hfixF 12502 hb) hk12 hg hkind
  refine ⟨tF, CF, v, hrun, hv, ?_, hle, ?_, MF, _, KF, hF, hfixF⟩
  · refine hem.trans ?_; simp [Map.vals]
  · exact hG nx M K t C MF KF tF CF hGx hfix h (fun a => by rw [hfr]; exact frX_ne_none s0 Fr p1 _ a) hlo hhi hrun
      hgrow (by rw [← ec.tab]; exact hext) hKlo hKhi hKfr hF

/-- `FinalEGStepV` with the further frames `Fr`. -/
def FinalEGStepF (Gx : Nat → Map → St LF.S → CSrv → Prop) (P : LoadP) (Fr : LoopFrames) (fixA : List Nat)
    {okA okB : St LF.S → SSrv → Bool} {s0 : St LF.S} {tab0 : List SymE} {cE aN : Nat}
    (ec : ExitCase okA okB s0 (finalStart s0 tab0.length) (tab0 ++ [.var 17]) cE aN [.num (.ref 79)])
    (V : LoopVals) (T : Nat) (tk : Nat → Nat) (toks : List NumV) (G : St LF.S → CSrv → Prop) : Prop :=
  ∀ (hlen : T - 2 < toks.length) (nx : Nat) (M : Map) (K : Ctx) (t : St LF.S) (C : CSrv) (MF : Map) (KF : Ctx)
    (tF : St LF.S) (CF : CSrv), Gx (T - 2) M t C → (∀ a ∈ fixA, M.a a = a) →
    Rel LF (LR P (toks.drop (T - 2))) M (V (T - 2) nx) K s0 ⟨tab0, []⟩ t C →
    (∀ a, K.fr a ≠ none ↔ a ∈ 2673447 :: 12502 :: Fr.xs) → K.lo = P.lo → K.hi = P.E →
    runC LF ec.n t C = some (tF, CF) →
    Host.Mlx.Ffi.NGrow t.ffi.mlx tF.ffi.mlx →
    Ext (M.setNum tab0.length toks[T - 2]) MF (tab0.length + 1) → KF.lo = P.lo → KF.hi = P.E →
    (∀ a, KF.fr a ≠ none ↔ a ∈ 2673447 :: 12502 :: (Fr.xs ++ [aN])) →
    Rel LF (LR P (toks.drop (T - 1))) MF (V (T - 2) (tk T)) KF ec.sF ec.SF tF CF →
    G tF CF

theorem FinalEGStepF_empty {Gx : Nat → Map → St LF.S → CSrv → Prop} {P : LoadP} {fixA : List Nat}
    {okA okB : St LF.S → SSrv → Bool} {s0 : St LF.S} {tab0 : List SymE} {cE aN : Nat}
    (ec : ExitCase okA okB s0 (finalStart s0 tab0.length) (tab0 ++ [.var 17]) cE aN [.num (.ref 79)])
    (V : LoopVals) (T : Nat) (tk : Nat → Nat) (toks : List NumV) (G : St LF.S → CSrv → Prop) :
    FinalEGStepF Gx P LoopFrames.empty fixA ec V T tk toks G ↔ FinalEGStepV Gx P fixA ec V T tk toks G := Iff.rfl

/-- **EOS at the last token** (`finalE_stepV`) from `LoopInvF`. -/
theorem finalE_stepF {Gx : Nat → Map → St LF.S → CSrv → Prop} {G : St LF.S → CSrv → Prop}
    {okA okB : St LF.S → SSrv → Bool} {P : LoadP} {Fr : LoopFrames} {s0 : St LF.S} {tab0 : List SymE}
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
    (hjA : jsPA.lo = P.lo ∧ jsPA.hi = P.E ∧ ∀ a, a ∈ jsPA.framed ↔ a ∈ 2673447 :: 12502 :: Fr.xs)
    (hjB : jsPB.lo = P.lo ∧ jsPB.hi = P.E ∧ ∀ a, a ∈ jsPB.framed ↔ a ∈ 2673447 :: 12502 :: (Fr.xs ++ [aN]))
    (st : LoopStart P s0 tab0)
    (ec : ExitCase okA okB s0 (finalStart s0 tab0.length) (tab0 ++ [.var 17]) cE aN [.num (.ref 79)])
    (hfr17 : ∀ e ∈ tab0, e.noVar 17 = true) (hcE : cE ∈ fixA) (hb : 12502 ∈ fixA) (haN2 : aN ≠ 12502)
    {V : LoopVals} {T : Nat} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {B : LoopBase} {ΔJ ΔH ΔN : Nat}
    {t : St LF.S} {C : CSrv} {env : Env} {nm : Name}
    (hupd : ∀ nx, upd (V (T - 2) nx) 17 (F64.ofNat (tk T)) = V (T - 2) (tk T))
    (hinv : LoopInvF Gx (relL P) P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN (T - 2) t C) (hT : 3 ≤ T)
    (hlen : T - 1 ≤ toks.length)
    (hgood : Good (V (T - 2) (tk T)) ec.S0.oracle) (hVB : VBOk (V (T - 2) (tk T)))
    (henv : lookupEnv nm env = some cE) (hG : FinalEGStepF Gx P Fr fixA ec V T tk toks G) :
    ∃ tF CF v, runC LF ec.n t C = some (tF, CF) ∧ tF.ctl = .halt (.normal v) ∧
      (bindingOf tF env nm).bind (Host.Load.Extract.elements tF) = some (E0 ++ (toks.take (T - 2)).map Val.num) ∧
      CSrv.Le C CF ∧ G tF CF ∧
      ∃ MF ν KF, Rel LF (LR P (toks.drop (T - 1))) MF ν KF ec.sF ec.SF tF CF ∧ ∀ a ∈ fixA, MF.a a = a := by
  obtain ⟨M, K, nx, p1, h, hfr, hlo, hhi, hbase, h79, hnx, hvals, hD, hHi, hNi, hfix, hGx⟩ := hinv
  have hT1 : T - 2 + 1 = T - 1 := by omega
  have hi : T - 2 < toks.length := by omega
  have hdrop : toks.drop (T - 2) = toks[T - 2] :: toks.drop (T - 2 + 1) := List.drop_eq_getElem_cons hi
  have hT2 : T - 2 + 2 = T := by omega
  have hx : C.val toks[T - 2] = some (F64.ofNat (tk T)) := by
    have := hvals (T - 2) hi; rw [hT2] at this; exact this
  have h1 := h.extendVar (loadR_laws _) hfr17 (fun q hq => by cases hq) hx
  have hf : LR P (toks.drop (T - 2 + 1)) (M.setNum tab0.length toks[T - 2]) (tab0.length + 1)
      ({ s0.ffi with mlx := { s0.ffi.mlx with tokens := s0.ffi.mlx.tokens ++ [.ref tab0.length] } }) t.ffi := by
    have := h.ffi
    rw [hdrop] at this
    exact this.addToken
  have h2 := h1.setSrcFfi (FR' := LR P (toks.drop (T - 2 + 1))) _ (by simpa using hf)
  rw [hupd] at h2
  have h3 : Rel LF (LR P (toks.drop (T - 2 + 1))) (M.setNum tab0.length toks[T - 2])
      (V (T - 2) (tk T)) K (finalStart s0 tab0.length) ec.S0 t C :=
    h2.srvSwap (by rw [ec.tab]) ⟨fun j e he => h2.srv.num j e (by rw [ec.tab] at he; exact he), hgood⟩
  obtain ⟨MF, KF, tF, CF, v, hrun, hv, hext, hKlo, hKhi, hKfr, hk12, hF, hgrow, hle⟩ :=
    exit_runF hsimA hsimB hngA hngB hsimAL hngAL hjA hjB ec haN2 h3 hfr hlo hhi hVB
  have hMa : MF.a = M.a := hext.a
  have hfixF : ∀ a ∈ fixA, MF.a a = a := fun a ha => by rw [hMa]; exact hfix a ha
  have hS0 : ec.S0.tab.length = tab0.length + 1 := by rw [ec.tab]; simp
  obtain ⟨o, hg, hkind⟩ := ec.emitG
  have hem := hF.emitted henv ec.cell (hfixF cE hcE) (hfixF 12502 hb) hk12 hg hkind
  rw [hT1] at hF
  refine ⟨tF, CF, v, hrun, hv, ?_, hle, ?_, MF, _, KF, hF, hfixF⟩
  · refine hem.trans ?_
    have hn79 : MF.num 79 = toks[T - 3] := by
      rw [hext.num 79 (by have := st.h79; omega), (Map.setNum_ext M tab0.length toks[T - 2]).num 79 st.h79]
      have := h79; rw [show T - 2 - 1 = T - 3 by omega, List.getElem?_eq_getElem (by omega)] at this
      exact (Option.some.inj this).symm
    show some (E0 ++ (toks.take (T - 2 - 1)).map Val.num ++ [Val.num (MF.nv (.ref 79))]) = _
    simp only [Map.nv, hn79]
    rw [show T - 2 - 1 = T - 3 by omega, show T - 2 = T - 3 + 1 by omega, ← take_map_succ toks (T - 3) (by omega),
      List.append_assoc]
  · exact hG hi nx M K t C MF KF tF CF hGx hfix h (fun a => by rw [hfr]; exact frX_ne_none s0 Fr p1 _ a) hlo hhi
      hrun hgrow (by rw [← hS0]; exact hext) hKlo hKhi hKfr hF

end Host.Ts.Sim
