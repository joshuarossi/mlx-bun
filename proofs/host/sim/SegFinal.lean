import host.sim.Seg
import host.sim.GeneralL
namespace Host.Ts.Sim
open Host.Ts Host.Ts.Sim.Template

/-! # The final iteration over a chain

The regenerated decode epilogue reads the framed prompt (`promptTokens.length`, B-len) and
spreads it (`[...promptTokens, ...forwarded]`, B-spread) besides the spread of `forwarded`, so a
final case is a chain of checked segments and bridges (`FinalSeg`: a halting `SegCase` from the
final template start under the laws `finalLaws`, which keep the handle band and the `emitted`
frame and grow the target's native state). `final_stepS` is `final_stepV` for it, with the
obligation `FinalGStepS` on the loop's further invariant. `FinalCase.toSeg`: the existing final
cases (one spread between two segments) are instances. -/

/-- The laws of a final chain: the contexts keep the handle band and the `emitted` frame; the
target's native state grows. -/
def finalLaws : SegLaws LF where
  KR K K' := K'.lo = K.lo ∧ K'.hi = K.hi ∧ K'.fr 12502 = K.fr 12502
  TR t t' := Host.Mlx.Ffi.NGrow t.ffi.mlx t'.ffi.mlx
  krefl _ := ⟨rfl, rfl, rfl⟩
  ktrans h1 h2 := ⟨h2.1.trans h1.1, h2.2.1.trans h1.2.1, h2.2.2.trans h1.2.2⟩
  trefl _ := Host.Mlx.Ffi.NGrow.refl _
  ttrans h1 h2 := h1.trans h2

/-- **A final case over a chain**, for the target's remaining readbacks `r`: from the final template
start (the loop template with its look-ahead reference, table `tab0 ++ [var 17]`) a halting chain
starting under `Rel` with the entry predicate `QA` and ending under `Rel` (`rend`), where the
`emitted` binding (cell `cE`) holds the template's array followed by the cut's and the look-ahead
references. -/
structure FinalSeg (P : LoadP) (r : List NumV) (s0 : St LF.S) (tab0 : List SymE) (cE : Nat) where
  S0 : SSrv
  tab : S0.tab = tab0 ++ [.var 17]
  QA : (Nat → F64) → Ctx → Prop
  case : SegCase finalLaws (relQ LF (LR P r) QA) (finalStart s0 tab0.length) S0 .halt
  QF : (Nat → F64) → Ctx → Prop
  rend : ∀ x s S, case.Rend x s S → relQ LF (LR P r) QF x s S
  emitG : ∃ o, case.sF.heap.get 12502 = some (.obj o) ∧
    o.kind = .array (arrOf s0 12502 ++ [.num (.ref 79), .num (.ref tab0.length)])
  cell : case.sF.cell? cE = some (some (.obj 12502))

/-- The obligation of a chain final case on the loop's further invariant `Gx`: from the start
relation, the run, and the end pair (the chain's end relation), `G` holds at the target's end. -/
def FinalGStepS (Gx : Nat → Map → St LF.S → CSrv → Prop) (P : LoadP) (fixA : List Nat) {s0 : St LF.S}
    {tab0 : List SymE} {cE : Nat} {toks : List NumV} {T : Nat} (fc : FinalSeg P (toks.drop (T - 1)) s0 tab0 cE)
    (V : LoopVals) (tk : Nat → Nat) (G : St LF.S → CSrv → Prop) : Prop :=
  ∀ (hlen : T - 2 < toks.length) (nx : Nat) (M : Map) (K : Ctx) (t : St LF.S) (C : CSrv) (xF : SegInst LF),
    Gx (T - 2) M t C → (∀ a ∈ fixA, M.a a = a) →
    Rel LF (LR P (toks.drop (T - 2))) M (V (T - 2) nx) K s0 ⟨tab0, []⟩ t C →
    (∀ a, K.fr a ≠ none ↔ a ∈ [2673447, 12502]) → K.lo = P.lo → K.hi = P.E →
    runC LF fc.case.n t C = some (xF.t, xF.C) → Host.Mlx.Ffi.NGrow t.ffi.mlx xF.t.ffi.mlx →
    Ext (M.setNum tab0.length toks[T - 2]) xF.M (tab0.length + 1) → xF.ν = V (T - 2) (tk T) →
    xF.K.lo = P.lo → xF.K.hi = P.E → xF.K.fr 12502 = K.fr 12502 →
    fc.case.Rend xF fc.case.sF fc.case.SF → G xF.t xF.C

/-- **The final iteration over a chain** at the valuations `V` (`final_stepV`): from the loop
invariant at iteration `T - 2`, the chain final case halts the target with the `emitted` binding
the base prefix followed by the first `T - 1` readbacks. -/
theorem final_stepS {Gx : Nat → Map → St LF.S → CSrv → Prop} {G : St LF.S → CSrv → Prop} {P : LoadP}
    {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat} {cE : Nat}
    {V : LoopVals} {T : Nat} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {ΔJ ΔH ΔN : Nat}
    {t : St LF.S} {C : CSrv} {env : Env} {nm : Name}
    (st : LoopStart P s0 tab0) (fc : FinalSeg P (toks.drop (T - 1)) s0 tab0 cE)
    (hfr17 : ∀ e ∈ tab0, e.noVar 17 = true) (hcE : cE ∈ fixA) (hb : 12502 ∈ fixA)
    (hupd : ∀ nx, upd (V (T - 2) nx) 17 (F64.ofNat (tk T)) = V (T - 2) (tk T))
    (hinv : LoopInvV Gx P s0 tab0 fixA V tk toks E0 ΔJ ΔH ΔN (T - 2) t C) (hT : 3 ≤ T)
    (hlen : T - 1 ≤ toks.length) (hgood : Good (V (T - 2) (tk T)) fc.S0.oracle)
    (hQA : ∀ K : Ctx, (∀ a, K.fr a ≠ none ↔ a ∈ [2673447, 12502]) → K.lo = P.lo → K.hi = P.E →
      fc.QA (V (T - 2) (tk T)) K)
    (henv : lookupEnv nm env = some cE) (hG : FinalGStepS Gx P fixA fc V tk G) :
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
  have hKfr : ∀ a, K.fr a ≠ none ↔ a ∈ [2673447, 12502] := fun a => by rw [hfr]; exact frOf_ne_none s0 p1 _ a
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

/-! ## The existing final cases are chain final cases -/

section ToSeg
variable {okA okB : St LF.S → SSrv → Bool} {P : LoadP} {VBOk : (Nat → F64) → Prop} {s0 : St LF.S}
  {tab0 : List SymE} {cE aN : Nat}

/-- The spread's new context: the framed accumulator at the new array. -/
theorem kp_frameAt {jsA jsB : Disp.JSP LF} (hjA : jsA.lo = P.lo ∧ jsA.hi = P.E ∧ jsA.framed = [2673447, 12502])
    (hjB : jsB.lo = P.lo ∧ jsB.hi = P.E ∧ jsB.framed = [2673447, 12502, aN]) {K : Ctx} (hK : Disp.Kp jsA K)
    (p : List Val × List Val) : Disp.Kp jsB (Disp.Ctx.frameAt K aN p) := by
  obtain ⟨hlo, hhi, hfr⟩ := hK
  refine ⟨hlo.trans (hjA.1.trans hjB.1.symm), hhi.trans (hjA.2.1.trans hjB.2.1.symm), fun a => ?_⟩
  rw [hjB.2.2]
  show (bif Nat.beq a aN then some p else K.fr a) ≠ none ↔ _
  by_cases ha : a = aN
  · subst ha; simp
  · have : Nat.beq a aN = false := by cases hq : Nat.beq a aN; rfl; exact absurd (Nat.eq_of_beq_eq_true hq) ha
    rw [this, Bool.cond_false, hfr, hjA.2.2]
    simp [ha]

/-- **A final case as a chain final case**: its first segment, the step into the spread's state,
the framed spread, its second segment. -/
noncomputable def FinalCase.toSeg (fc : FinalCase okA okB s0 tab0 cE aN) (A : AccSim P VBOk okA [2673447, 12502])
    (B : AccSim P VBOk okB [2673447, 12502, aN]) (haN2 : aN ≠ 12502) (r : List NumV) : FinalSeg P r s0 tab0 cE where
  S0 := fc.S0
  tab := fc.tab
  QA ν K := Disp.Kp A.jsP K ∧ VBOk ν
  QF ν K := Disp.Kp B.jsP K ∧ VBOk ν
  case :=
    { Rend := relQ LF (LR P r) fun ν K => Disp.Kp B.jsP K ∧ VBOk ν
      sF := fc.sF
      SF := fc.SF
      chain :=
        .cons fc.nA (PieceSim.ofRunOk (A.sim r) (fun _ _ h => h)
            (fun M ν K n s t s1 t1 S S1 C C1 hq hr hok hrun hrc => A.ng r M ν K n s t s1 t1 S S1 C C1 hq.1 hq.2 hr hok hrun hrc)
            fc.okA0 fc.runA) (interpS_runOk_len fc.runA) <|
        .cons 1 (PieceSim.ofLast (A.simL r) (fun _ _ h => h)
            (fun M ν K s t s1 t1 S S1 C C1 hq hr hh hok hs ht => A.ngL r M ν K s t s1 t1 S S1 C C1 hq.1 hq.2 hr hh hok hs ht)
            fc.okP fc.haltP fc.stepA) (interpS_len _ _ _ _ fc.stepA) <|
        .cons 0 (PieceSim.relOfX (fun r env fs he => by rw [fc.stackA] at he; cases he)) (Nat.le_refl _) <|
        .cons 1 (PieceSim.spread (Q' := fun ν K => Disp.Kp B.jsP K ∧ VBOk ν) fc.ctlA fc.stackA fc.roomA fc.arrA fc.stepB
            (fun ν K hq => by
              have := (hq.1.2.2 2673447).2 (by rw [A.hj.2.2]; simp)
              exact Option.ne_none_iff_exists'.1 this)
            (fun M ν K pre pre' hq _ => by
              rw [fc.newA]
              refine ⟨⟨kp_frameAt A.hj B.hj hq.1 _, hq.2⟩, rfl, rfl, ?_⟩
              show (bif Nat.beq 12502 aN then _ else K.fr 12502) = K.fr 12502
              have : Nat.beq 12502 aN = false := by
                cases hq : Nat.beq 12502 aN; rfl; exact absurd (Nat.eq_of_beq_eq_true hq).symm haN2
              rw [this]; rfl)
            (fun t t' he => by show Host.Mlx.Ffi.NGrow _ _; rw [he]; exact Host.Mlx.Ffi.NGrow.refl _))
          (interpS_len _ _ _ _ fc.stepB) <|
        .cons fc.nB (PieceSim.ofRunOkRel (B.sim r) (fun _ _ h => h)
            (fun M ν K n s t s1 t1 S S1 C C1 hq hr hok hrun hrc => B.ng r M ν K n s t s1 t1 S S1 C C1 hq.1 hq.2 hr hok hrun hrc)
            fc.okB0 fc.runB (fun v hv => by obtain ⟨w, hw⟩ := fc.halt; rw [hw] at hv; cases hv))
          (interpS_runOk_len fc.runB) <|
        .nil _ _ _
      fin := fun x hx => by
        obtain ⟨w, hw⟩ := fc.halt
        exact ⟨x.M.val w, by rw [hx.1.ctl, hw]; rfl⟩ }
  rend _ _ _ h := h
  emitG := fc.emitG
  cell := fc.cell

end ToSeg

end Host.Ts.Sim
