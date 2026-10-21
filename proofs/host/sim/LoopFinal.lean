import host.sim.LoopInv
import host.sim.FinalExtract
import host.sim.dispatch.SpreadFramed
import host.sim.dispatch.OkLast
namespace Host.Ts.Sim
open Host.Ts Host.Ts.Sim.Template

/-! # The final iteration

The final template case starts from the loop template with its look-ahead token
reference appended (a fresh reference bound to the target's next readback with
template variable `v17`). Its first segment is checked up to the step that returns the
framed `forwarded` array into the epilogue's spread; that step is simulated without
accepting the state it reaches (the acceptance has no case for a framed array returned
into a spread). The spread allocates an array whose prefixes differ between the template
and the target; that step is `step_spread_framed`, which frames the new array for the
checked second segment. The target halts, and its `emitted` binding holds the base
prefix and all readbacks. -/

/-- At a returning state whose top frame is not a statement list, `RelX` is `Rel`. -/
theorem RelX.rel_frame {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
    {s t : St F.S} {S : SSrv} {C : CSrv} (h : RelX F FR M ν K s S t C)
    (hs : ∀ r env fs, s.stack ≠ .s (.block r env) :: fs) : Rel F FR M ν K s S t C := by
  rcases h with h | ⟨_, _, r, env, fs, _, _, hst, _⟩
  · exact h
  · exact absurd hst (hs r env fs)

/-- One simulated source step gives one target step. -/
theorem msim_runC1 {F : Ffi} {P : Map → SSrv → CSrv → St F.S → St F.S → Prop} {S S' : SSrv} {C : CSrv}
    {s s' t : St F.S} (hm : MSim P S C (step F s) (step F t)) (hs : interpS (step F s).run S = some (s', S'))
    (ht : isHalt t.ctl = false) : ∃ M' t' C', runC F 1 t C = some (t', C') ∧ P M' S' C' s' t' := by
  obtain ⟨M', b, C', hb, hp⟩ := hm.run s' S' hs
  refine ⟨M', b, C', ?_, hp⟩
  simp only [runC, runWith_succ, ht, Bool.cond_false, hb, St.rebuild_eq]
  rfl

/-- The final template start: the loop template with its look-ahead token reference. -/
def finalStart (s0 : St LF.S) (n : Nat) : St LF.S :=
  s0.setFfi { s0.ffi with mlx := { s0.ffi.mlx with tokens := s0.ffi.mlx.tokens ++ [.ref n] } }

/-- A checked final case, split at the epilogue's spread of `forwarded`; the second
segment's acceptance frames the spread's new array `aN`. -/
structure FinalCase (okA okB : St LF.S → SSrv → Bool) (s0 : St LF.S) (tab0 : List SymE) (cE aN : Nat) where
  S0 : SSrv
  tab : S0.tab = tab0 ++ [.var 17]
  nA : Nat
  sP : St LF.S
  SP : SSrv
  okA0 : okA (finalStart s0 tab0.length) S0 = true
  runA : runOk LF okA nA (finalStart s0 tab0.length) S0 = some (sP, SP)
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
  emitG : ∃ o, sF.heap.get 12502 = some (.obj o) ∧
    o.kind = .array (arrOf s0 12502 ++ [.num (.ref 79), .num (.ref tab0.length)])
  cell : sF.cell? cE = some (some (.obj 12502))

/-- The obligation of the final case on the loop's further invariant `Gx`: from the start
relation (with the loop's fixed addresses `fixA`), the target run and the relation at the
case's halted end, the goal `G` holds at the target's end. -/
def FinalGStep (Gx : Nat → Map → St LF.S → CSrv → Prop) (P : LoadP) (fixA : List Nat) {okA okB : St LF.S → SSrv → Bool}
    {s0 : St LF.S} {tab0 : List SymE} {cE aN : Nat} (fc : FinalCase okA okB s0 tab0 cE aN) (ρ : Nat → F64) (T : Nat)
    (tk : Nat → Nat) (toks : List NumV) (G : St LF.S → CSrv → Prop) : Prop :=
  ∀ (hlen : T - 2 < toks.length) (nx : Nat) (M : Map) (K : Ctx) (t : St LF.S) (C : CSrv) (MF : Map) (KF : Ctx)
    (tF : St LF.S) (CF : CSrv), Gx (T - 2) M t C → (∀ a ∈ fixA, M.a a = a) →
    Rel LF (LR P (toks.drop (T - 2))) M (loopVal ρ T T (T - 2) (cap (T - 2)) (tk (T - 1)) (tk (T - 2)) nx) K s0
      ⟨tab0, []⟩ t C →
    (∀ a, K.fr a ≠ none ↔ a ∈ [2673447, 12502]) → K.lo = P.lo → K.hi = P.E →
    runC LF (fc.nA + 1 + 1 + fc.nB) t C = some (tF, CF) →
    Host.Mlx.Ffi.NGrow t.ffi.mlx tF.ffi.mlx →
    Ext (M.setNum tab0.length toks[T - 2]) MF (tab0.length + 1) → KF.lo = P.lo → KF.hi = P.E →
    (∀ a, KF.fr a ≠ none ↔ a ∈ [2673447, 12502, aN]) →
    Rel LF (LR P (toks.drop (T - 1))) MF (loopVal ρ T T (T - 2) (cap (T - 2)) (tk (T - 1)) (tk (T - 2)) (tk T)) KF
      fc.sF fc.SF tF CF →
    G tF CF

/-- **The final iteration.** From the loop invariant at iteration `T - 2`, the checked
final case takes the target to a halted state whose `emitted` binding is the base
prefix followed by the first `T - 1` readbacks. -/
theorem final_step {Gx : Nat → Map → St LF.S → CSrv → Prop} {G : St LF.S → CSrv → Prop}
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
    (st : LoopStart P s0 tab0) (fc : FinalCase okA okB s0 tab0 cE aN)
    (hfr17 : ∀ e ∈ tab0, e.noVar 17 = true) (hcE : cE ∈ fixA) (hb : 12502 ∈ fixA)
    (haN1 : aN ≠ 2673447) (haN2 : aN ≠ 12502)
    {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {ΔJ ΔH ΔN : Nat}
    {t : St LF.S} {C : CSrv} {env : Env} {nm : Name}
    (hinv : LoopInv Gx P s0 tab0 fixA ρ T tk toks E0 ΔJ ΔH ΔN (T - 2) t C) (hT : 3 ≤ T) (hlen : T - 1 ≤ toks.length)
    (hgood : Good (loopVal ρ T T (T - 2) (cap (T - 2)) (tk (T - 1)) (tk (T - 2)) (tk T)) fc.S0.oracle)
    (hVB : VBOk (loopVal ρ T T (T - 2) (cap (T - 2)) (tk (T - 1)) (tk (T - 2)) (tk T)))
    (henv : lookupEnv nm env = some cE) (hG : FinalGStep Gx P fixA fc ρ T tk toks G) :
    ∃ tF CF v, runC LF (fc.nA + 1 + 1 + fc.nB) t C = some (tF, CF) ∧ tF.ctl = .halt (.normal v) ∧
      (bindingOf tF env nm).bind (Host.Load.Extract.elements tF) = some (E0 ++ (toks.take (T - 1)).map Val.num) ∧
      CSrv.Le C CF ∧ G tF CF := by
  obtain ⟨M, K, nx, p1, h, hfr, hlo, hhi, hbase, h79, hnx, hvals, hD, hHi, hNi, hfix, hGx⟩ := hinv
  have hT1 : T - 2 + 1 = T - 1 := by omega
  rw [← hT1] at hgood hVB
  have hi : T - 2 < toks.length := by omega
  have hdrop : toks.drop (T - 2) = toks[T - 2] :: toks.drop (T - 2 + 1) := List.drop_eq_getElem_cons hi
  have hT2 : T - 2 + 2 = T := by omega
  rw [hT2] at h
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
      (loopVal ρ T T (T - 2) (cap (T - 2)) (tk (T - 2 + 1)) (tk (T - 2)) (tk T)) K (finalStart s0 tab0.length)
      fc.S0 t C :=
    h2.srvSwap (by rw [fc.tab]) ⟨fun j e he => h2.srv.num j e (by rw [fc.tab] at he; exact he), hgood⟩
  have hKA : Disp.Kp jsPA K := ⟨hlo.trans hjA.1.symm, hhi.trans hjA.2.1.symm, fun a => by
    rw [hfr, hjA.2.2]; exact frOf_ne_none s0 p1 _ a⟩
  -- segment A
  obtain ⟨MP, tP, CP, hrP, heP, hxP⟩ := Disp.runOk_simXV LF _ okA _ VBOk (hsimA _) _ K hKA hVB fc.nA _ _ _ t C
    fc.sP fc.SP (Or.inl h3) fc.okA0 fc.runA
  obtain ⟨MA, tA, CA, htA1, heA1, hxA⟩ := hsimAL _ MP _ K fc.sP fc.SP tP CP fc.sA fc.SA hKA hVB hxP fc.haltP
    fc.okP fc.stepA
  have hA := hxA.rel_frame (fun r env fs he => by rw [fc.stackA] at he; cases he)
  have hrA : runC LF (fc.nA + 1) t C = some (tA, CA) := runC_trans hrP (by
    simp only [runC, runWith_succ, hxP.isHalt, fc.haltP, Bool.cond_false, htA1, St.rebuild_eq]; rfl)
  have hlenA : fc.S0.tab.length ≤ fc.SA.tab.length :=
    Nat.le_trans (interpS_runOk_len fc.runA) (interpS_len _ _ _ _ fc.stepA)
  have heA : Ext (M.setNum tab0.length toks[T - 2]) MA fc.S0.tab.length :=
    heP.trans heA1 (interpS_runOk_len fc.runA)
  -- the spread
  have hk1 : K.fr 2673447 = some (arrOf s0 2673447, p1) := by rw [hfr]; rfl
  have hm := Disp.step_spread_framed hA fc.ctlA fc.stackA hk1 fc.roomA fc.arrA
  have htA : isHalt tA.ctl = false := by rw [hA.isHalt, fc.ctlA]; rfl
  obtain ⟨MB, tB, CB, hrB, hgB, hB, htB⟩ := msim_runC1 hm fc.stepB htA
  -- segment B
  have hKB : Disp.Kp jsPB ⟨fun a => bif Nat.beq a fc.sA.next then
      some (fc.acc.reverse ++ arrOf s0 2673447, MA.vals fc.acc.reverse ++ p1) else K.fr a,
      K.base, K.base', K.D, K.lo, K.hi⟩ := by
    refine ⟨hlo.trans hjB.1.symm, hhi.trans hjB.2.1.symm, fun a => ?_⟩
    rw [hjB.2.2]
    show (bif Nat.beq a fc.sA.next then _ else K.fr a) ≠ none ↔ _
    rw [fc.newA]
    by_cases ha : a = aN
    · subst ha; simp
    · have : Nat.beq a aN = false := by cases hq : Nat.beq a aN; rfl; exact absurd (Nat.eq_of_beq_eq_true hq) ha
      rw [this, Bool.cond_false, hfr, frOf_ne_none]
      simp [ha]
  obtain ⟨MF, tF, CF, hrF, heF, hF⟩ := iter_run (hsimB _) hKB hVB hB fc.okB0 fc.runB
    (fun v hv => by obtain ⟨w, hw⟩ := fc.halt; rw [hw] at hv; cases hv)
  have hgrow : Host.Mlx.Ffi.NGrow t.ffi.mlx tF.ffi.mlx :=
    (((hngA _ _ _ _ _ _ _ _ _ _ _ _ _ hKA hVB h3 fc.okA0 fc.runA hrP).trans
      (hngAL _ _ _ _ _ _ _ _ _ _ _ _ hKA hVB hxP fc.haltP fc.okP fc.stepA htA1)).trans
      (by rw [htB]; exact Host.Mlx.Ffi.NGrow.refl _)).trans
      (hngB _ _ _ _ _ _ _ _ _ _ _ _ _ hKB hVB hB fc.okB0 fc.runB hrF)
  obtain ⟨v, hv⟩ := fc.halt
  have hrun : runC LF (fc.nA + 1 + 1 + fc.nB) t C = some (tF, CF) := by
    rw [show fc.nA + 1 + 1 + fc.nB = (fc.nA + 1) + (1 + fc.nB) by omega]
    exact runC_trans hrA (runC_trans hrB hrF)
  refine ⟨tF, CF, MF.val v, hrun, ?_, ?_, ?_, ?_⟩
  · rw [hF.ctl, hv]; rfl
  · -- the emitted tokens
    have hMa : MF.a = M.a := by rw [heF.a, hgB.ext.a, heA.a]; rfl
    have hfa : MF.a cE = cE := by rw [hMa]; exact hfix cE hcE
    have hfb : MF.a 12502 = 12502 := by rw [hMa]; exact hfix 12502 hb
    have hk : (⟨fun a => bif Nat.beq a fc.sA.next then
        some (fc.acc.reverse ++ arrOf s0 2673447, MA.vals fc.acc.reverse ++ p1) else K.fr a,
        K.base, K.base', K.D, K.lo, K.hi⟩ : Ctx).fr 12502 =
        some (arrOf s0 12502, E0 ++ (toks.take (T - 2 - 1)).map Val.num) := by
      show (bif Nat.beq 12502 fc.sA.next then _ else K.fr 12502) = _
      rw [fc.newA]
      have : Nat.beq 12502 aN = false := by
        cases hq : Nat.beq 12502 aN; rfl; exact absurd (Nat.eq_of_beq_eq_true hq).symm haN2
      rw [this, Bool.cond_false, hfr]; rfl
    obtain ⟨o, hg, hkind⟩ := fc.emitG
    refine (hF.emitted henv fc.cell hfa hfb hk hg hkind).trans ?_
    -- the images of the two appended readbacks
    have hlenB := interpS_len _ _ _ _ fc.stepB
    have hlenF := interpS_runOk_len fc.runB
    have hS0 : fc.S0.tab.length = tab0.length + 1 := by rw [fc.tab]; simp
    have hnum : ∀ j, j < tab0.length + 1 → MF.num j = (M.setNum tab0.length toks[T - 2]).num j := by
      intro j hj
      rw [heF.num j (by omega), hgB.ext.num j (by omega), heA.num j (by omega)]
    have hn79 : MF.num 79 = toks[T - 3] := by
      rw [hnum 79 (by have := st.h79; omega), (Map.setNum_ext M tab0.length toks[T - 2]).num 79 st.h79]
      have := h79; rw [show T - 2 - 1 = T - 3 by omega, List.getElem?_eq_getElem (by omega)] at this
      exact (Option.some.inj this).symm
    have hnn : MF.num tab0.length = toks[T - 2] := by
      rw [hnum tab0.length (by omega), Map.setNum_self]
    show some (E0 ++ (toks.take (T - 2 - 1)).map Val.num ++ [Val.num (MF.nv (.ref 79)), Val.num (MF.nv (.ref tab0.length))]) = _
    simp only [Map.nv, hn79, hnn]
    rw [show T - 2 - 1 = T - 3 by omega, show T - 1 = T - 3 + 1 + 1 by omega, ← take_map_succ toks (T - 3 + 1) (by omega),
      ← take_map_succ toks (T - 3) (by omega)]
    simp only [List.append_assoc, List.singleton_append, show T - 3 + 1 = T - 2 by omega]
  · exact (runC_le _ _ _ _ _ hrA).trans ((runC_le _ _ _ _ _ hrB).trans (runC_le _ _ _ _ _ hrF))
  · -- the further invariant
    have hlenB := interpS_len _ _ _ _ fc.stepB
    have hS0 : fc.S0.tab.length = tab0.length + 1 := by rw [fc.tab]; simp
    have hext : Ext (M.setNum tab0.length toks[T - 2]) MF (tab0.length + 1) := by
      rw [← hS0]; exact (heA.trans hgB.ext hlenA).trans heF (Nat.le_trans hlenA hlenB)
    rw [hT1] at h hF
    exact hG hi nx M K t C MF _ tF CF hGx hfix h (fun a => by rw [hfr]; exact frOf_ne_none s0 p1 _ a) hlo hhi hrun hgrow hext (by exact hlo) (by exact hhi)
      (by exact fun a => by have := hKB.2.2 a; rwa [hjB.2.2] at this) hF

end Host.Ts.Sim
