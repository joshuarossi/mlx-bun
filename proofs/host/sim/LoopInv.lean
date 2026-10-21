import host.sim.LoadIter
import host.sim.Cases
import host.sim.template.ShiftJS
import host.sim.extract.Grow
namespace Host.Ts.Sim
open Host.Ts Host.Ts.Sim.Template

/-! # The loop invariant

At the start of iteration `i` the target is related to the template start `s0`
(oracle-free server with the template table `tab0`) at the loop valuation of
iteration `i`, with its remaining readbacks `toks.drop i`. The emitted array's
target prefix is the base prefix `E0` followed by the first `i - 1` readbacks.
`loop_step` advances the invariant by one checked template iteration (`LoopCase`).
The invariant carries a further predicate `Gx` of the iteration start (the graph side),
advanced by each case's `LoopGStep`. -/

/-- Facts about the template start used by every iteration. -/
structure LoopStart (P : LoadP) (s0 : St LF.S) (tab0 : List SymE) : Prop where
  tok : s0.ffi.mlx.tokens = [.ref 79]
  h79 : 79 < tab0.length
  big : bigsOutB s0.ffi.mlx.next P.E s0.ffi.mlx = true
  free : NoBigSt (fun i => (s0.ffi.mlx.next : Int) ≤ i ∧ i < P.E) s0.trace s0
  lo : P.lo ≤ s0.ffi.mlx.next
  hi : P.E ≤ 2 ^ 56

/-- A checked loop case of the template. -/
structure LoopCase (ok : St LF.S → SSrv → Bool) (P : LoadP) (s0 : St LF.S) (tab0 : List SymE) (fixA : List Nat) where
  S0 : SSrv
  n : Nat
  s1 : St LF.S
  S1 : SSrv
  σ : Map
  θ : Nat → SymE
  grow : Bool
  xs : List Val
  tab : S0.tab = tab0
  ok0 : ok s0 S0 = true
  run : runOk LF ok n s0 S0 = some (s1, S1)
  ctl : ∀ v, s1.ctl ≠ .ret v
  noVarTab : ∀ e ∈ S1.tab, e.noVar 17 = true
  noVarOr : ∀ q ∈ S1.oracle, q.noVar 17 = true
  shiftJS : ∀ (p1 p2 : List Val) (K : Ctx), K.fr = frOf s0 p1 p2 → K.lo = P.lo → K.hi = P.E →
    ShiftJS LF σ θ K s0 S0 s1 ⟨S1.tab ++ [.var 17], S1.oracle⟩
  nshift : NShift P tab0.length σ s0.ffi s1.ffi
  num79 : σ.num 79 = .ref S1.tab.length
  hE : s1.ffi.mlx.next < P.E
  theta : ∀ j, θ j = loopTheta grow 17 j
  fwd : ∃ o, s1.heap.get 2673447 = some (.obj o) ∧ o.kind = .array (arrOf s0 2673447 ++ xs)
  emit : ∃ o, s1.heap.get 12502 = some (.obj o) ∧ o.kind = .array (arrOf s0 12502 ++ [.num (.ref 79)])
  fix : ∀ a ∈ fixA, σ.a a = a

/-- The invariant at the start of iteration `i`. `tk j` is the value of the `j`-th token;
`toks[j]` is the target's readback of token `j + 2`. -/
def LoopInv (Gx : Nat → Map → St LF.S → CSrv → Prop) (P : LoadP) (s0 : St LF.S) (tab0 : List SymE) (fixA : List Nat)
    (ρ : Nat → F64) (T : Nat) (tk : Nat → Nat) (toks : List NumV) (E0 : List Val) (ΔJ ΔH ΔN : Nat) (i : Nat) (t : St LF.S) (C : CSrv) : Prop :=
  ∃ M K nx p1, Rel LF (LR P (toks.drop i)) M (loopVal ρ T (i + 2) i (cap i) (tk (i + 1)) (tk i) nx) K s0
      ⟨tab0, []⟩ t C ∧
    K.fr = frOf s0 p1 (E0 ++ (toks.take (i - 1)).map Val.num) ∧ K.lo = P.lo ∧ K.hi = P.E ∧ K.base = s0.trace ∧
    toks[i - 1]? = some (M.num 79) ∧ nx ≤ 2 ^ 20 ∧
    (∀ j (hj : j < toks.length), C.val toks[j] = some (F64.ofNat (tk (j + 2)))) ∧
    K.D ≤ (i - 1) * ΔJ ∧ t.ffi.mlx.next ≤ s0.ffi.mlx.next + (i - 1) * ΔH ∧
    t.ffi.mlx.nnext ≤ s0.ffi.mlx.nnext + (i - 1) * ΔN ∧ (∀ a ∈ fixA, M.a a = a) ∧ Gx i M t C

/-- The obligation of loop case `c` at iteration `i` on the further invariant `Gx`: from the
start relation, the target run and the relation at the case's end (before the restart), `Gx`
holds at the next iteration's start under the restart map. -/
def LoopGStep (Gx : Nat → Map → St LF.S → CSrv → Prop) {ok : St LF.S → SSrv → Bool} {P : LoadP} {s0 : St LF.S}
    {tab0 : List SymE} {fixA : List Nat} (c : LoopCase ok P s0 tab0 fixA) (ρ : Nat → F64) (T : Nat) (tk : Nat → Nat)
    (toks : List NumV) (i : Nat) : Prop :=
  ∀ (hlen : i < toks.length) (nx : Nat) (M : Map) (K : Ctx) (t : St LF.S) (C : CSrv) (M1 : Map) (t1 : St LF.S)
    (C1 : CSrv), Gx i M t C →
    Rel LF (LR P (toks.drop i)) M (loopVal ρ T (i + 2) i (cap i) (tk (i + 1)) (tk i) nx) K s0 ⟨tab0, []⟩ t C →
    (∀ a, K.fr a ≠ none ↔ a ∈ [2673447, 12502]) → K.lo = P.lo → K.hi = P.E → runC LF c.n t C = some (t1, C1) →
    Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx → Ext M M1 c.S0.tab.length →
    Rel LF (LR P (toks.drop i)) M1 (loopVal ρ T (i + 2) i (cap i) (tk (i + 1)) (tk i) nx) K c.s1 c.S1 t1 C1 →
    Gx (i + 1) (((M1.setNum c.S1.tab.length toks[i]).after c.σ).rebig s0.ffi.mlx.next P.E t1.ffi.mlx.next) t1 C1

theorem frOf_ne_none (s0 : St LF.S) (p1 p2 : List Val) (a : Nat) :
    frOf s0 p1 p2 a ≠ none ↔ a ∈ [2673447, 12502] := by
  unfold frOf
  constructor
  · intro h
    cases h1 : Nat.beq a 2673447
    · cases h2 : Nat.beq a 12502
      · simp [h1, h2] at h
      · simp [Nat.eq_of_beq_eq_true h2]
    · simp [Nat.eq_of_beq_eq_true h1]
  · intro h
    simp only [List.mem_cons, List.not_mem_nil, or_false] at h
    rcases h with rfl | rfl <;> simp

/-- After an iteration the framed prefixes are the template's arrays and the target
prefixes extended by the images of the appended elements. -/
theorem framedNext_frOf {M : Map} {K : Ctx} {s0 s1 : St LF.S} {p1 p2 xs : List Val}
    (hfr : K.fr = frOf s0 p1 p2)
    (hf : ∃ o, s1.heap.get 2673447 = some (.obj o) ∧ o.kind = .array (arrOf s0 2673447 ++ xs))
    (he : ∃ o, s1.heap.get 12502 = some (.obj o) ∧ o.kind = .array (arrOf s0 12502 ++ [.num (.ref 79)])) :
    Shift.framedNext M K s1 = frOf s0 (p1 ++ M.vals xs) (p2 ++ [.num (M.nv (.ref 79))]) := by
  funext a
  obtain ⟨of, hgf, hkf⟩ := hf
  obtain ⟨oe, hge, hke⟩ := he
  by_cases ha1 : a = 2673447
  · subst ha1
    rw [framedNext_of (by rw [hfr]; rfl) hgf hkf]
    rfl
  · by_cases ha2 : a = 12502
    · subst ha2
      rw [framedNext_of (by rw [hfr]; rfl) hge hke]
      rfl
    · have hn : K.fr a = none := by
        rw [hfr]; unfold frOf
        simp [ha1, ha2]
      have : Shift.framedNext M K s1 a = none := (framedNext_none_iff a).2 hn
      rw [this]
      unfold frOf
      simp [ha1, ha2]


theorem take_map_succ (l : List NumV) (n : Nat) (h : n < l.length) :
    (l.take n).map Val.num ++ [Val.num l[n]] = (l.take (n + 1)).map Val.num := by
  rw [List.take_succ, List.getElem?_eq_getElem h]
  simp only [Option.toList_some, List.map_append, List.map_cons, List.map_nil]

/-- **One loop iteration preserves the invariant.** -/
theorem loop_step {Gx : Nat → Map → St LF.S → CSrv → Prop} {ok : St LF.S → SSrv → Bool} {P : LoadP} {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat}
    {jsP : Disp.JSP LF} {VBOk : (Nat → F64) → Prop}
    (hsim : ∀ r, Disp.StepSimXV LF (LR P r) ok (Disp.Kp jsP) VBOk)
    (hjlo : jsP.lo = P.lo) (hjhi : jsP.hi = P.E) (hjfr : jsP.framed = [2673447, 12502])
    (st : LoopStart P s0 tab0) (c : LoopCase ok P s0 tab0 fixA)
    {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {ΔJ ΔH ΔN : Nat}
    {i : Nat} {t : St LF.S} {C : CSrv}
    (hinv : LoopInv Gx P s0 tab0 fixA ρ T tk toks E0 ΔJ ΔH ΔN i t C) (hi1 : 1 ≤ i) (hlen : i < toks.length)
    (hgood : ∀ nx, Good (loopVal ρ T (i + 2) i (cap i) (tk (i + 1)) (tk i) nx) c.S0.oracle)
    (hVB : ∀ nx, nx ≤ 2 ^ 20 → VBOk (loopVal ρ T (i + 2) i (cap i) (tk (i + 1)) (tk i) nx))
    (hgrow : c.grow = decide (i % 256 = 254)) (hib : i + 3 < 2 ^ 30) (hcb : cap i < 2 ^ 30)
    (htk : tk (i + 2) ≤ 2 ^ 20)
    (hdJ : c.s1.next - s0.next ≤ ΔJ) (hdH : c.s1.ffi.mlx.next - s0.ffi.mlx.next ≤ ΔH)
    (hdN : c.s1.ffi.mlx.nnext - s0.ffi.mlx.nnext ≤ ΔN)
    (hJ : i * ΔJ < Sim.bound) (hH : s0.ffi.mlx.next + i * ΔH + (P.E - s0.ffi.mlx.next) < 2 ^ 46)
    (hN : s0.ffi.mlx.nnext + i * ΔN + (P.NE - s0.ffi.mlx.nnext) < 2 ^ 62)
    (hng : ∀ (r : List NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (n : Nat) (s t s1 t1 : St LF.S) (S S1 : SSrv)
      (C C1 : CSrv), Disp.Kp jsP K → VBOk ν → Rel LF (LR P r) M ν K s S t C → ok s S = true →
      runOk LF ok n s S = some (s1, S1) → runC LF n t C = some (t1, C1) → Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx)
    (hG : LoopGStep Gx c ρ T tk toks i) :
    ∃ t' C', runC LF c.n t C = some (t', C') ∧ LoopInv Gx P s0 tab0 fixA ρ T tk toks E0 ΔJ ΔH ΔN (i + 1) t' C' := by
  obtain ⟨M, K, nx, p1, h, hfr, hlo, hhi, hbase, h79, hnx, hvals, hD, hHi, hNi, hfix, hGx⟩ := hinv
  -- the case's server
  have hs : Srv M (loopVal ρ T (i + 2) i (cap i) (tk (i + 1)) (tk i) nx) c.S0 C :=
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
  have hval := next_loopVal (rest := ρ) (T := T) (tok := tk (i + 1)) (ptok := tk i) (next := nx)
    (x := tk (i + 2)) c.grow c.theta hib hcb hgrow
  refine ⟨t1, C1, hrc, (((M1.setNum c.S1.tab.length toks[i]).after c.σ).rebig s0.ffi.mlx.next P.E t1.ffi.mlx.next),
    ⟨Shift.framedNext (M1.setNum c.S1.tab.length toks[i]) K c.s1, s0.trace, t1.trace, t1.next - s0.next, K.lo, K.hi⟩,
    tk (i + 2), p1 ++ (M1.setNum c.S1.tab.length toks[i]).vals c.xs,
    ?_, ?_, hlo, hhi, rfl, ?_, htk, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · have e : Shift.valuation c.θ (upd (loopVal ρ T (i + 2) i (cap i) (tk (i + 1)) (tk i) nx) 17
        (F64.ofNat (tk (i + 2)))) = loopVal ρ T (i + 1 + 2) (i + 1) (cap (i + 1)) (tk (i + 1 + 1)) (tk (i + 1))
        (tk (i + 2)) := hval
    rw [e, c.tab] at hrel
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

/-- **All loop iterations.** With a checked case for every iteration (`sel i`) whose
oracle holds there, the invariant at iteration 1 gives the invariant at iteration
`T - 2` (the final iteration) after the iterations' target steps. -/
theorem loop_all {Gx : Nat → Map → St LF.S → CSrv → Prop} {ok : St LF.S → SSrv → Bool} {P : LoadP} {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat}
    {jsP : Disp.JSP LF} {VBOk : (Nat → F64) → Prop}
    (hsim : ∀ r, Disp.StepSimXV LF (LR P r) ok (Disp.Kp jsP) VBOk)
    (hjlo : jsP.lo = P.lo) (hjhi : jsP.hi = P.E) (hjfr : jsP.framed = [2673447, 12502])
    (st : LoopStart P s0 tab0) (sel : Nat → LoopCase ok P s0 tab0 fixA)
    {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {ΔJ ΔH ΔN : Nat}
    (hT : 3 ≤ T) (hlen : T - 2 ≤ toks.length)
    (hgood : ∀ i, 1 ≤ i → i + 2 < T → ∀ nx, Good (loopVal ρ T (i + 2) i (cap i) (tk (i + 1)) (tk i) nx) (sel i).S0.oracle)
    (hVB : ∀ i, 1 ≤ i → i + 2 < T → ∀ nx, nx ≤ 2 ^ 20 → VBOk (loopVal ρ T (i + 2) i (cap i) (tk (i + 1)) (tk i) nx))
    (hgrow : ∀ i, (sel i).grow = decide (i % 256 = 254)) (hTb : T + 3 < 2 ^ 30) (hcap : ∀ i, i < T → cap i < 2 ^ 30)
    (htk : ∀ j, j ≤ T → tk j ≤ 2 ^ 20)
    (hdJ : ∀ i, (sel i).s1.next - s0.next ≤ ΔJ) (hdH : ∀ i, (sel i).s1.ffi.mlx.next - s0.ffi.mlx.next ≤ ΔH)
    (hdN : ∀ i, (sel i).s1.ffi.mlx.nnext - s0.ffi.mlx.nnext ≤ ΔN)
    (hJ : T * ΔJ < Sim.bound) (hH : s0.ffi.mlx.next + T * ΔH + (P.E - s0.ffi.mlx.next) < 2 ^ 46)
    (hN : s0.ffi.mlx.nnext + T * ΔN + (P.NE - s0.ffi.mlx.nnext) < 2 ^ 62)
    (hng : ∀ (r : List NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (n : Nat) (s t s1 t1 : St LF.S) (S S1 : SSrv)
      (C C1 : CSrv), Disp.Kp jsP K → VBOk ν → Rel LF (LR P r) M ν K s S t C → ok s S = true →
      runOk LF ok n s S = some (s1, S1) → runC LF n t C = some (t1, C1) → Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx)
    (hG : ∀ i, 1 ≤ i → i + 2 < T → LoopGStep Gx (sel i) ρ T tk toks i)
    {t : St LF.S} {C : CSrv} (h1 : LoopInv Gx P s0 tab0 fixA ρ T tk toks E0 ΔJ ΔH ΔN 1 t C) :
    ∃ t' C', runC LF (iterSteps (fun i => (sel i).n) 1 (T - 3)) t C = some (t', C') ∧
      LoopInv Gx P s0 tab0 fixA ρ T tk toks E0 ΔJ ΔH ΔN (T - 2) t' C' := by
  have := loop_induct (F := LF) (LoopInv Gx P s0 tab0 fixA ρ T tk toks E0 ΔJ ΔH ΔN) (fun i => 1 ≤ i ∧ i + 2 < T)
    (fun i => (sel i).n) (fun i t C hinv ⟨hi1, hiT⟩ => by
      have hmul : ∀ D, i * D ≤ T * D := fun D => Nat.mul_le_mul_right D (by omega)
      exact loop_step hsim hjlo hjhi hjfr st (sel i) hinv hi1 (by omega) (hgood i hi1 hiT) (hVB i hi1 hiT)
        (hgrow i) (by omega) (hcap i (by omega)) (htk (i + 2) (by omega)) (hdJ i) (hdH i) (hdN i)
        (Nat.lt_of_le_of_lt (hmul ΔJ) hJ) (by have := hmul ΔH; omega) (by have := hmul ΔN; omega) hng (hG i hi1 hiT))
    (T - 3) 1 t C h1 (fun j hj => ⟨by omega, by omega⟩)
  rw [show 1 + (T - 3) = T - 2 by omega] at this
  exact this

end Host.Ts.Sim
