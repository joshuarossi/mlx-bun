import host.sim.LoopExit
namespace Host.Ts.Sim
open Host.Ts Host.Ts.Sim.Template

/-! # The loop invariant at any loop valuation

`LoopInv` (LoopInv.lean) relates the target at iteration `i` to the template start at the
loop valuation of a prompt of length 1 (offset `i + 2`, capacity `cap i`). Here the same
invariant and its steps for any family of valuations `V i nx` (iteration `i`, look-ahead `nx`):
`LoopInvV`, `LoopGStepV`, `FinalGStepV`, `ExitGStepV`, `FinalEGStepV`, and the steps
`loop_stepV`, `loop_allV`/`loop_all_toV`, `final_stepV`, `exit_stepV`, `finalE_stepV`. The
proofs are the existing ones; the valuation enters only through the template oracles
(`Good (V i nx) …`), the value bounds (`VBOk`), the restart's substitution (`hnext`: it takes
`V i` with the next readback at `v17` to `V (i + 1)`) and the look-ahead update (`hupd`).
The existing statements are the instances at `val1` (`LoopInv_eq`, … in `host.sim.LoopL`). -/

/-- A family of loop valuations: iteration `i`, look-ahead token `nx`. -/
abbrev LoopVals := Nat → Nat → Nat → F64

/-- **The invariant at the start of iteration `i`** at the valuations `V`. -/
def LoopInvV (Gx : Nat → Map → St LF.S → CSrv → Prop) (P : LoadP) (s0 : St LF.S) (tab0 : List SymE)
    (fixA : List Nat) (V : LoopVals) (tk : Nat → Nat) (toks : List NumV) (E0 : List Val) (ΔJ ΔH ΔN : Nat) (i : Nat)
    (t : St LF.S) (C : CSrv) : Prop :=
  ∃ M K nx p1, Rel LF (LR P (toks.drop i)) M (V i nx) K s0 ⟨tab0, []⟩ t C ∧
    K.fr = frOf s0 p1 (E0 ++ (toks.take (i - 1)).map Val.num) ∧ K.lo = P.lo ∧ K.hi = P.E ∧ K.base = s0.trace ∧
    toks[i - 1]? = some (M.num 79) ∧ nx ≤ 2 ^ 20 ∧
    (∀ j (hj : j < toks.length), C.val toks[j] = some (F64.ofNat (tk (j + 2)))) ∧
    K.D ≤ (i - 1) * ΔJ ∧ t.ffi.mlx.next ≤ s0.ffi.mlx.next + (i - 1) * ΔH ∧
    t.ffi.mlx.nnext ≤ s0.ffi.mlx.nnext + (i - 1) * ΔN ∧ (∀ a ∈ fixA, M.a a = a) ∧ Gx i M t C

/-- `LoopGStep` at the valuations `V`. -/
def LoopGStepV (Gx : Nat → Map → St LF.S → CSrv → Prop) {ok : St LF.S → SSrv → Bool} {P : LoadP} {s0 : St LF.S}
    {tab0 : List SymE} {fixA : List Nat} (c : LoopCase ok P s0 tab0 fixA) (V : LoopVals) (toks : List NumV)
    (i : Nat) : Prop :=
  ∀ (hlen : i < toks.length) (nx : Nat) (M : Map) (K : Ctx) (t : St LF.S) (C : CSrv) (M1 : Map) (t1 : St LF.S)
    (C1 : CSrv), Gx i M t C →
    Rel LF (LR P (toks.drop i)) M (V i nx) K s0 ⟨tab0, []⟩ t C →
    (∀ a, K.fr a ≠ none ↔ a ∈ [2673447, 12502]) → K.lo = P.lo → K.hi = P.E → runC LF c.n t C = some (t1, C1) →
    Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx → Ext M M1 c.S0.tab.length →
    Rel LF (LR P (toks.drop i)) M1 (V i nx) K c.s1 c.S1 t1 C1 →
    Gx (i + 1) (((M1.setNum c.S1.tab.length toks[i]).after c.σ).rebig s0.ffi.mlx.next P.E t1.ffi.mlx.next) t1 C1

/-- **One loop iteration preserves the invariant** at the valuations `V`. -/
theorem loop_stepV {Gx : Nat → Map → St LF.S → CSrv → Prop} {ok : St LF.S → SSrv → Bool} {P : LoadP}
    {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat} {jsP : Disp.JSP LF} {VBOk : (Nat → F64) → Prop}
    (hsim : ∀ r, Disp.StepSimXV LF (LR P r) ok (Disp.Kp jsP) VBOk)
    (hjlo : jsP.lo = P.lo) (hjhi : jsP.hi = P.E) (hjfr : jsP.framed = [2673447, 12502])
    (st : LoopStart P s0 tab0) (c : LoopCase ok P s0 tab0 fixA)
    {V : LoopVals} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {ΔJ ΔH ΔN : Nat}
    {i : Nat} {t : St LF.S} {C : CSrv}
    (hinv : LoopInvV Gx P s0 tab0 fixA V tk toks E0 ΔJ ΔH ΔN i t C) (hi1 : 1 ≤ i) (hlen : i < toks.length)
    (hgood : ∀ nx, Good (V i nx) c.S0.oracle)
    (hVB : ∀ nx, nx ≤ 2 ^ 20 → VBOk (V i nx))
    (hnext : ∀ nx, Shift.valuation c.θ (upd (V i nx) 17 (F64.ofNat (tk (i + 2)))) = V (i + 1) (tk (i + 2)))
    (htk : tk (i + 2) ≤ 2 ^ 20)
    (hdJ : c.s1.next - s0.next ≤ ΔJ) (hdH : c.s1.ffi.mlx.next - s0.ffi.mlx.next ≤ ΔH)
    (hdN : c.s1.ffi.mlx.nnext - s0.ffi.mlx.nnext ≤ ΔN)
    (hJ : i * ΔJ < Sim.bound) (hH : s0.ffi.mlx.next + i * ΔH + (P.E - s0.ffi.mlx.next) < 2 ^ 46)
    (hN : s0.ffi.mlx.nnext + i * ΔN + (P.NE - s0.ffi.mlx.nnext) < 2 ^ 62)
    (hng : ∀ (r : List NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (n : Nat) (s t s1 t1 : St LF.S) (S S1 : SSrv)
      (C C1 : CSrv), Disp.Kp jsP K → VBOk ν → Rel LF (LR P r) M ν K s S t C → ok s S = true →
      runOk LF ok n s S = some (s1, S1) → runC LF n t C = some (t1, C1) → Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx)
    (hG : LoopGStepV Gx c V toks i) :
    ∃ t' C', runC LF c.n t C = some (t', C') ∧ LoopInvV Gx P s0 tab0 fixA V tk toks E0 ΔJ ΔH ΔN (i + 1) t' C' := by
  obtain ⟨M, K, nx, p1, h, hfr, hlo, hhi, hbase, h79, hnx, hvals, hD, hHi, hNi, hfix, hGx⟩ := hinv
  -- the case's server
  have hs : Srv M (V i nx) c.S0 C :=
    ⟨fun j e he => h.srv.num j e (by rw [c.tab] at he; exact he), hgood nx⟩
  have h1 := h.srvSwap c.tab hs
  -- the next readback
  have hdrop : toks.drop i = toks[i] :: toks.drop (i + 1) := List.drop_eq_getElem_cons hlen
  have hK : Disp.Kp jsP K := ⟨hlo.trans hjlo.symm, hhi.trans hjhi.symm, fun a => by
    rw [hfr, hjfr]; exact frOf_ne_none s0 p1 _ a⟩
  have hshift := (c.shiftJS p1 (E0 ++ (toks.take (i - 1)).map Val.num) K hfr hlo hhi).toShift
    (FS := FSn { P with rest := toks.drop i } c.S0.tab.length s0.ffi) ⟨rfl, by rw [c.tab]; exact c.nshift.withRest _⟩
  have hband : ∀ j : Int, (s0.ffi.mlx.next : Int) ≤ j ∧ j < P.E → ¬ BigFixed K.lo K.hi j ∧ 0 ≤ j ∧ j < 2 ^ 56 := by
    intro j hj
    have := st.lo; have := st.hi
    rw [hlo, hhi]
    refine ⟨fun hf => ?_, by omega, by omega⟩
    unfold BigFixed at hf
    omega
  have eJ : (i - 1) * ΔJ + ΔJ = i * ΔJ := by
    obtain ⟨k, rfl⟩ : ∃ k, i = k + 1 := ⟨i - 1, by omega⟩
    simp [Nat.add_mul]
  have eH : (i - 1) * ΔH + ΔH = i * ΔH := by
    obtain ⟨k, rfl⟩ : ∃ k, i = k + 1 := ⟨i - 1, by omega⟩
    simp [Nat.add_mul]
  have eN : (i - 1) * ΔN + ΔN = i * ΔN := by
    obtain ⟨k, rfl⟩ : ∃ k, i = k + 1 := ⟨i - 1, by omega⟩
    simp [Nat.add_mul]
  obtain ⟨M1, t1, C1, hrc, he, hoff, hH1, hN1, hrel, hpre⟩ :=
    load_step (hsim (toks.drop i)) hK (hVB nx hnx) h1 hdrop c.ok0 c.run c.ctl c.noVarTab c.noVarOr hshift
      c.num79 st.tok (by rw [c.tab]; exact st.h79) st.big st.free hband (hvals i hlen) c.hE
      (by have := h.offset; omega) (by omega) (by omega)
  have hlen1 : 79 < c.S1.tab.length := by
    have := interpS_runOk_len c.run; rw [c.tab] at this; have := st.h79; omega
  have hM79 : (M1.setNum c.S1.tab.length toks[i]).num 79 = M.num 79 := by
    rw [(Map.setNum_ext M1 c.S1.tab.length toks[i]).num 79 hlen1]
    exact he.num 79 (by rw [c.tab]; exact st.h79)
  have hx : C.val toks[i] = some (F64.ofNat (tk (i + 2))) := hvals i hlen
  refine ⟨t1, C1, hrc, (((M1.setNum c.S1.tab.length toks[i]).after c.σ).rebig s0.ffi.mlx.next P.E t1.ffi.mlx.next),
    ⟨Shift.framedNext (M1.setNum c.S1.tab.length toks[i]) K c.s1, s0.trace, t1.trace, t1.next - s0.next, K.lo, K.hi⟩,
    tk (i + 2), p1 ++ (M1.setNum c.S1.tab.length toks[i]).vals c.xs,
    ?_, ?_, hlo, hhi, rfl, ?_, htk, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · rw [hnext nx, c.tab] at hrel
    exact hrel
  · show Shift.framedNext (M1.setNum c.S1.tab.length toks[i]) K c.s1 = _
    rw [framedNext_frOf hfr c.fwd c.emit]
    congr 1
    have hnv : (M1.setNum c.S1.tab.length toks[i]).nv (.ref 79) = toks[i - 1] := by
      show (M1.setNum c.S1.tab.length toks[i]).num 79 = _
      rw [hM79]
      have := h79; rw [List.getElem?_eq_getElem (by omega)] at this
      exact (Option.some.inj this).symm
    rw [hnv, show i + 1 - 1 = (i - 1) + 1 by omega, ← take_map_succ toks (i - 1) (by omega), List.append_assoc]
  · show toks[i + 1 - 1]? = some ((((M1.setNum c.S1.tab.length toks[i]).after c.σ).rebig _ _ _).num 79)
    show _ = some ((M1.setNum c.S1.tab.length toks[i]).nv (c.σ.num 79))
    rw [c.num79]
    show _ = some ((M1.setNum c.S1.tab.length toks[i]).num c.S1.tab.length)
    rw [Map.setNum_self, show i + 1 - 1 = i by omega, List.getElem?_eq_getElem hlen]
  · intro j hj
    exact (runC_le c.n t C t1 C1 hrc).val (hvals j hj)
  · show t1.next - s0.next ≤ (i + 1 - 1) * ΔJ
    have := h.offset
    rw [hoff, show i + 1 - 1 = i by omega]
    omega
  · rw [hH1, show i + 1 - 1 = i by omega]
    omega
  · rw [hN1, show i + 1 - 1 = i by omega]
    omega
  · intro a ha
    show M1.a (c.σ.a a) = a
    rw [c.fix a ha, he.a, hfix a ha]
  · exact hG hlen nx M K t C M1 t1 C1 hGx h (fun a => by rw [hfr]; exact frOf_ne_none s0 p1 _ a) hlo hhi hrc
      (hng _ _ _ _ _ _ _ _ _ _ _ _ _ hK (hVB nx hnx) h1 c.ok0 c.run hrc) he (by rw [hdrop]; exact hpre)

/-- **The loop up to iteration `J`** at the valuations `V` (`loop_all_to`). -/
theorem loop_all_toV {Gx : Nat → Map → St LF.S → CSrv → Prop} {ok : St LF.S → SSrv → Bool} {P : LoadP}
    {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat} {jsP : Disp.JSP LF} {VBOk : (Nat → F64) → Prop}
    (hsim : ∀ r, Disp.StepSimXV LF (LR P r) ok (Disp.Kp jsP) VBOk)
    (hjlo : jsP.lo = P.lo) (hjhi : jsP.hi = P.E) (hjfr : jsP.framed = [2673447, 12502])
    (st : LoopStart P s0 tab0) (sel : Nat → LoopCase ok P s0 tab0 fixA)
    {V : LoopVals} {T : Nat} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {ΔJ ΔH ΔN : Nat}
    (J : Nat) (hJT : J + 2 ≤ T) (hlen : T - 2 ≤ toks.length)
    (hgood : ∀ i, 1 ≤ i → i < J → ∀ nx, Good (V i nx) (sel i).S0.oracle)
    (hVB : ∀ i, 1 ≤ i → i < J → ∀ nx, nx ≤ 2 ^ 20 → VBOk (V i nx))
    (hnext : ∀ i, 1 ≤ i → i < J → ∀ nx,
      Shift.valuation (sel i).θ (upd (V i nx) 17 (F64.ofNat (tk (i + 2)))) = V (i + 1) (tk (i + 2)))
    (htk : ∀ j, j ≤ T → tk j ≤ 2 ^ 20)
    (hdJ : ∀ i, (sel i).s1.next - s0.next ≤ ΔJ) (hdH : ∀ i, (sel i).s1.ffi.mlx.next - s0.ffi.mlx.next ≤ ΔH)
    (hdN : ∀ i, (sel i).s1.ffi.mlx.nnext - s0.ffi.mlx.nnext ≤ ΔN)
    (hJ : T * ΔJ < Sim.bound) (hH : s0.ffi.mlx.next + T * ΔH + (P.E - s0.ffi.mlx.next) < 2 ^ 46)
    (hN : s0.ffi.mlx.nnext + T * ΔN + (P.NE - s0.ffi.mlx.nnext) < 2 ^ 62)
    (hng : ∀ (r : List NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (n : Nat) (s t s1 t1 : St LF.S) (S S1 : SSrv)
      (C C1 : CSrv), Disp.Kp jsP K → VBOk ν → Rel LF (LR P r) M ν K s S t C → ok s S = true →
      runOk LF ok n s S = some (s1, S1) → runC LF n t C = some (t1, C1) → Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx)
    (hG : ∀ i, 1 ≤ i → i < J → LoopGStepV Gx (sel i) V toks i)
    {t : St LF.S} {C : CSrv} (h1 : LoopInvV Gx P s0 tab0 fixA V tk toks E0 ΔJ ΔH ΔN 1 t C) (hJ1 : 1 ≤ J) :
    ∃ t' C', runC LF (iterSteps (fun i => (sel i).n) 1 (J - 1)) t C = some (t', C') ∧
      LoopInvV Gx P s0 tab0 fixA V tk toks E0 ΔJ ΔH ΔN J t' C' := by
  have := loop_induct (F := LF) (LoopInvV Gx P s0 tab0 fixA V tk toks E0 ΔJ ΔH ΔN) (fun i => 1 ≤ i ∧ i < J)
    (fun i => (sel i).n) (fun i t C hinv ⟨hi1, hiJ⟩ => by
      have hmul : ∀ D, i * D ≤ T * D := fun D => Nat.mul_le_mul_right D (by omega)
      exact loop_stepV hsim hjlo hjhi hjfr st (sel i) hinv hi1 (by omega) (hgood i hi1 hiJ) (hVB i hi1 hiJ)
        (hnext i hi1 hiJ) (htk (i + 2) (by omega)) (hdJ i) (hdH i) (hdN i)
        (Nat.lt_of_le_of_lt (hmul ΔJ) hJ) (by have := hmul ΔH; omega) (by have := hmul ΔN; omega) hng (hG i hi1 hiJ))
    (J - 1) 1 t C h1 (fun j hj => ⟨by omega, by omega⟩)
  rw [show 1 + (J - 1) = J by omega] at this
  exact this

/-- **All loop iterations** at the valuations `V` (`loop_all`): the invariant at iteration 1
gives the invariant at the final iteration `T - 2`. -/
theorem loop_allV {Gx : Nat → Map → St LF.S → CSrv → Prop} {ok : St LF.S → SSrv → Bool} {P : LoadP}
    {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat} {jsP : Disp.JSP LF} {VBOk : (Nat → F64) → Prop}
    (hsim : ∀ r, Disp.StepSimXV LF (LR P r) ok (Disp.Kp jsP) VBOk)
    (hjlo : jsP.lo = P.lo) (hjhi : jsP.hi = P.E) (hjfr : jsP.framed = [2673447, 12502])
    (st : LoopStart P s0 tab0) (sel : Nat → LoopCase ok P s0 tab0 fixA)
    {V : LoopVals} {T : Nat} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {ΔJ ΔH ΔN : Nat}
    (hT : 3 ≤ T) (hlen : T - 2 ≤ toks.length)
    (hgood : ∀ i, 1 ≤ i → i + 2 < T → ∀ nx, Good (V i nx) (sel i).S0.oracle)
    (hVB : ∀ i, 1 ≤ i → i + 2 < T → ∀ nx, nx ≤ 2 ^ 20 → VBOk (V i nx))
    (hnext : ∀ i, 1 ≤ i → i + 2 < T → ∀ nx,
      Shift.valuation (sel i).θ (upd (V i nx) 17 (F64.ofNat (tk (i + 2)))) = V (i + 1) (tk (i + 2)))
    (htk : ∀ j, j ≤ T → tk j ≤ 2 ^ 20)
    (hdJ : ∀ i, (sel i).s1.next - s0.next ≤ ΔJ) (hdH : ∀ i, (sel i).s1.ffi.mlx.next - s0.ffi.mlx.next ≤ ΔH)
    (hdN : ∀ i, (sel i).s1.ffi.mlx.nnext - s0.ffi.mlx.nnext ≤ ΔN)
    (hJ : T * ΔJ < Sim.bound) (hH : s0.ffi.mlx.next + T * ΔH + (P.E - s0.ffi.mlx.next) < 2 ^ 46)
    (hN : s0.ffi.mlx.nnext + T * ΔN + (P.NE - s0.ffi.mlx.nnext) < 2 ^ 62)
    (hng : ∀ (r : List NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (n : Nat) (s t s1 t1 : St LF.S) (S S1 : SSrv)
      (C C1 : CSrv), Disp.Kp jsP K → VBOk ν → Rel LF (LR P r) M ν K s S t C → ok s S = true →
      runOk LF ok n s S = some (s1, S1) → runC LF n t C = some (t1, C1) → Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx)
    (hG : ∀ i, 1 ≤ i → i + 2 < T → LoopGStepV Gx (sel i) V toks i)
    {t : St LF.S} {C : CSrv} (h1 : LoopInvV Gx P s0 tab0 fixA V tk toks E0 ΔJ ΔH ΔN 1 t C) :
    ∃ t' C', runC LF (iterSteps (fun i => (sel i).n) 1 (T - 3)) t C = some (t', C') ∧
      LoopInvV Gx P s0 tab0 fixA V tk toks E0 ΔJ ΔH ΔN (T - 2) t' C' := by
  have := loop_all_toV hsim hjlo hjhi hjfr st sel (T - 2) (by omega) hlen
    (fun i h1 h2 => hgood i h1 (by omega)) (fun i h1 h2 => hVB i h1 (by omega))
    (fun i h1 h2 => hnext i h1 (by omega)) htk hdJ hdH hdN hJ hH hN hng (fun i h1 h2 => hG i h1 (by omega)) h1
    (by omega)
  rw [show T - 2 - 1 = T - 3 by omega] at this
  exact this

/-! ## The final iteration -/

/-- `FinalGStep` at the valuations `V`. -/
def FinalGStepV (Gx : Nat → Map → St LF.S → CSrv → Prop) (P : LoadP) (fixA : List Nat)
    {okA okB : St LF.S → SSrv → Bool} {s0 : St LF.S} {tab0 : List SymE} {cE aN : Nat}
    (fc : FinalCase okA okB s0 tab0 cE aN) (V : LoopVals) (T : Nat) (tk : Nat → Nat) (toks : List NumV)
    (G : St LF.S → CSrv → Prop) : Prop :=
  ∀ (hlen : T - 2 < toks.length) (nx : Nat) (M : Map) (K : Ctx) (t : St LF.S) (C : CSrv) (MF : Map) (KF : Ctx)
    (tF : St LF.S) (CF : CSrv), Gx (T - 2) M t C → (∀ a ∈ fixA, M.a a = a) →
    Rel LF (LR P (toks.drop (T - 2))) M (V (T - 2) nx) K s0 ⟨tab0, []⟩ t C →
    (∀ a, K.fr a ≠ none ↔ a ∈ [2673447, 12502]) → K.lo = P.lo → K.hi = P.E →
    runC LF (fc.nA + 1 + 1 + fc.nB) t C = some (tF, CF) →
    Host.Mlx.Ffi.NGrow t.ffi.mlx tF.ffi.mlx →
    Ext (M.setNum tab0.length toks[T - 2]) MF (tab0.length + 1) → KF.lo = P.lo → KF.hi = P.E →
    (∀ a, KF.fr a ≠ none ↔ a ∈ [2673447, 12502, aN]) →
    Rel LF (LR P (toks.drop (T - 1))) MF (V (T - 2) (tk T)) KF fc.sF fc.SF tF CF →
    G tF CF

/-- **The final iteration** at the valuations `V` (`final_step`). -/
theorem final_stepV {Gx : Nat → Map → St LF.S → CSrv → Prop} {G : St LF.S → CSrv → Prop}
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
    {V : LoopVals} {T : Nat} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {ΔJ ΔH ΔN : Nat}
    {t : St LF.S} {C : CSrv} {env : Env} {nm : Name}
    (hupd : ∀ nx, upd (V (T - 2) nx) 17 (F64.ofNat (tk T)) = V (T - 2) (tk T))
    (hinv : LoopInvV Gx P s0 tab0 fixA V tk toks E0 ΔJ ΔH ΔN (T - 2) t C) (hT : 3 ≤ T)
    (hlen : T - 1 ≤ toks.length)
    (hgood : Good (V (T - 2) (tk T)) fc.S0.oracle) (hVB : VBOk (V (T - 2) (tk T)))
    (henv : lookupEnv nm env = some cE) (hG : FinalGStepV Gx P fixA fc V T tk toks G) :
    ∃ tF CF v, runC LF (fc.nA + 1 + 1 + fc.nB) t C = some (tF, CF) ∧ tF.ctl = .halt (.normal v) ∧
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
    show some (E0 ++ (toks.take (T - 2 - 1)).map Val.num ++ [Val.num (MF.nv (.ref 79)),
      Val.num (MF.nv (.ref tab0.length))]) = _
    simp only [Map.nv, hn79, hnn]
    rw [show T - 2 - 1 = T - 3 by omega, show T - 1 = T - 3 + 1 + 1 by omega,
      ← take_map_succ toks (T - 3 + 1) (by omega), ← take_map_succ toks (T - 3) (by omega)]
    simp only [List.append_assoc, List.singleton_append, show T - 3 + 1 = T - 2 by omega]
  · exact (runC_le _ _ _ _ _ hrA).trans ((runC_le _ _ _ _ _ hrB).trans (runC_le _ _ _ _ _ hrF))
  · -- the further invariant
    have hlenB := interpS_len _ _ _ _ fc.stepB
    have hS0 : fc.S0.tab.length = tab0.length + 1 := by rw [fc.tab]; simp
    have hext : Ext (M.setNum tab0.length toks[T - 2]) MF (tab0.length + 1) := by
      rw [← hS0]; exact (heA.trans hgB.ext hlenA).trans heF (Nat.le_trans hlenA hlenB)
    rw [hT1] at hF
    exact hG hi nx M K t C MF _ tF CF hGx hfix h (fun a => by rw [hfr]; exact frOf_ne_none s0 p1 _ a) hlo hhi hrun
      hgrow hext (by exact hlo) (by exact hhi)
      (by exact fun a => by have := hKB.2.2 a; rwa [hjB.2.2] at this) hF

/-! ## The EOS exits -/

/-- `ExitGStep` at the valuations `V`. -/
def ExitGStepV (Gx : Nat → Map → St LF.S → CSrv → Prop) (P : LoadP) (fixA : List Nat)
    {okA okB : St LF.S → SSrv → Bool} {s0 : St LF.S} {tab0 : List SymE} {cE aN : Nat}
    (ec : ExitCase okA okB s0 s0 tab0 cE aN []) (V : LoopVals) (toks : List NumV) (i : Nat)
    (G : St LF.S → CSrv → Prop) : Prop :=
  ∀ (nx : Nat) (M : Map) (K : Ctx) (t : St LF.S) (C : CSrv) (MF : Map) (KF : Ctx) (tF : St LF.S) (CF : CSrv),
    Gx i M t C → (∀ a ∈ fixA, M.a a = a) →
    Rel LF (LR P (toks.drop i)) M (V i nx) K s0 ⟨tab0, []⟩ t C →
    (∀ a, K.fr a ≠ none ↔ a ∈ [2673447, 12502]) → K.lo = P.lo → K.hi = P.E →
    runC LF ec.n t C = some (tF, CF) → Host.Mlx.Ffi.NGrow t.ffi.mlx tF.ffi.mlx →
    Ext M MF tab0.length → KF.lo = P.lo → KF.hi = P.E → (∀ a, KF.fr a ≠ none ↔ a ∈ [2673447, 12502, aN]) →
    Rel LF (LR P (toks.drop i)) MF (V i nx) KF ec.sF ec.SF tF CF →
    G tF CF

/-- **EOS at a loop cut** at the valuations `V` (`exit_step`). -/
theorem exit_stepV {Gx : Nat → Map → St LF.S → CSrv → Prop} {G : St LF.S → CSrv → Prop}
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
    {V : LoopVals} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {ΔJ ΔH ΔN : Nat}
    {i : Nat} {t : St LF.S} {C : CSrv} {env : Env} {nm : Name}
    (hinv : LoopInvV Gx P s0 tab0 fixA V tk toks E0 ΔJ ΔH ΔN i t C)
    (hgood : ∀ nx, Good (V i nx) ec.S0.oracle)
    (hVB : ∀ nx, nx ≤ 2 ^ 20 → VBOk (V i nx))
    (henv : lookupEnv nm env = some cE) (hG : ExitGStepV Gx P fixA ec V toks i G) :
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

/-- `FinalEGStep` at the valuations `V`. -/
def FinalEGStepV (Gx : Nat → Map → St LF.S → CSrv → Prop) (P : LoadP) (fixA : List Nat)
    {okA okB : St LF.S → SSrv → Bool} {s0 : St LF.S} {tab0 : List SymE} {cE aN : Nat}
    (ec : ExitCase okA okB s0 (finalStart s0 tab0.length) (tab0 ++ [.var 17]) cE aN [.num (.ref 79)])
    (V : LoopVals) (T : Nat) (tk : Nat → Nat) (toks : List NumV) (G : St LF.S → CSrv → Prop) : Prop :=
  ∀ (hlen : T - 2 < toks.length) (nx : Nat) (M : Map) (K : Ctx) (t : St LF.S) (C : CSrv) (MF : Map) (KF : Ctx)
    (tF : St LF.S) (CF : CSrv), Gx (T - 2) M t C → (∀ a ∈ fixA, M.a a = a) →
    Rel LF (LR P (toks.drop (T - 2))) M (V (T - 2) nx) K s0 ⟨tab0, []⟩ t C →
    (∀ a, K.fr a ≠ none ↔ a ∈ [2673447, 12502]) → K.lo = P.lo → K.hi = P.E →
    runC LF ec.n t C = some (tF, CF) →
    Host.Mlx.Ffi.NGrow t.ffi.mlx tF.ffi.mlx →
    Ext (M.setNum tab0.length toks[T - 2]) MF (tab0.length + 1) → KF.lo = P.lo → KF.hi = P.E →
    (∀ a, KF.fr a ≠ none ↔ a ∈ [2673447, 12502, aN]) →
    Rel LF (LR P (toks.drop (T - 1))) MF (V (T - 2) (tk T)) KF ec.sF ec.SF tF CF →
    G tF CF

/-- **EOS at the last token** at the valuations `V` (`finalE_step`). -/
theorem finalE_stepV {Gx : Nat → Map → St LF.S → CSrv → Prop} {G : St LF.S → CSrv → Prop}
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
    {V : LoopVals} {T : Nat} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {ΔJ ΔH ΔN : Nat}
    {t : St LF.S} {C : CSrv} {env : Env} {nm : Name}
    (hupd : ∀ nx, upd (V (T - 2) nx) 17 (F64.ofNat (tk T)) = V (T - 2) (tk T))
    (hinv : LoopInvV Gx P s0 tab0 fixA V tk toks E0 ΔJ ΔH ΔN (T - 2) t C) (hT : 3 ≤ T)
    (hlen : T - 1 ≤ toks.length)
    (hgood : Good (V (T - 2) (tk T)) ec.S0.oracle) (hVB : VBOk (V (T - 2) (tk T)))
    (henv : lookupEnv nm env = some cE) (hG : FinalEGStepV Gx P fixA ec V T tk toks G) :
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
      (V (T - 2) (tk T)) K (finalStart s0 tab0.length) ec.S0 t C :=
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

end Host.Ts.Sim
