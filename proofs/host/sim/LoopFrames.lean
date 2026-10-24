import host.sim.LoopGen
namespace Host.Ts.Sim
open Host.Ts Host.Ts.Sim.Template

/-! # The loop invariant with counter bases, further frames and any relation family

`LoopInvV` (LoopGen.lean) holds at iteration 1 only of a target whose heap counter equals the
template's (`K.D ≤ 0`) and whose framed set is exactly `forwarded` and `emitted`; a target that
ran a prefill has allocated more and frames the prompt (and ghost slots). `LoopInvF` generalizes
it in three ways, each a special case away from `LoopInvV` (`LoopInvF_empty`, definitional):

* **counter bases** `B : LoopBase`: the heap counter offset within `(i - 1)·ΔJ + B.D`, the
  native counters within `(i - 1)·ΔH + B.H`, `(i - 1)·ΔN + B.N` of the template's;
* **further frames** `Fr : LoopFrames`: the context frames `forwarded` (target prefix `p1`),
  `emitted` (the base prefix and the readbacks) and `Fr.X` at the addresses `Fr.xs` (the framed
  prompt, ghost slots: frames no iteration changes, `Keeps`);
* **the relation family** `R r` (by the remaining readbacks `r`): `Rel LF (LR P r)` (`relRel`),
  or a relation carrying further frames (`RelF … W`), through the interface `LoopRel` and the
  case's iteration theorem `LoopCase.IterF` (`load_step`'s conclusion for `R`).

`loop_stepF`, `loop_all_toF`, `loop_allF` are `loop_stepV` … for `LoopInvF`. For `Rel` the
iteration theorem follows from `load_step` and the case's shift under the frames
(`LoopCase.iterF_rel`, `LoopCase.ShiftF`; the existing cases' shift is `ShiftF` without further
frames, `LoopCase.shiftF_empty`). A relation with frames beyond framed arrays (ghost slots) gives
`IterF` from its own restart theorem. -/

/-! ## Frames, bases, relation families -/

/-- The loop's further frames: at the addresses `xs` (never `forwarded` or `emitted`) the frames
`X` (the prompt `([], π)`, ghost slots), which no iteration changes. -/
structure LoopFrames where
  X : Nat → Option (List Val × List Val)
  xs : List Nat
  dom : ∀ a, X a ≠ none ↔ a ∈ xs
  fwd : 2673447 ∉ xs
  emit : 12502 ∉ xs

/-- No further frames (the existing loop). -/
def LoopFrames.empty : LoopFrames := ⟨fun _ => Option.none, [], by simp, by simp, by simp⟩

/-- The loop's context frames: `forwarded` (target prefix `p1`), `emitted` (`p2`), and `X`. -/
def frX {S : Type} (s0 : St S) (X : Nat → Option (List Val × List Val)) (p1 p2 : List Val) (a : Nat) :
    Option (List Val × List Val) :=
  bif Nat.beq a 2673447 then some (arrOf s0 2673447, p1)
  else bif Nat.beq a 12502 then some (arrOf s0 12502, p2) else X a

theorem frX_empty {S : Type} (s0 : St S) (p1 p2 : List Val) : frX s0 LoopFrames.empty.X p1 p2 = frOf s0 p1 p2 := rfl

theorem frX_ne_none {S : Type} (s0 : St S) (Fr : LoopFrames) (p1 p2 : List Val) (a : Nat) :
    frX s0 Fr.X p1 p2 a ≠ none ↔ a ∈ 2673447 :: 12502 :: Fr.xs := by
  unfold frX
  by_cases h1 : a = 2673447
  · subst h1; simp
  · by_cases h2 : a = 12502
    · subst h2; simp
    · have e1 : Nat.beq a 2673447 = false := by cases h : Nat.beq a 2673447; rfl; exact absurd (Nat.eq_of_beq_eq_true h) h1
      have e2 : Nat.beq a 12502 = false := by cases h : Nat.beq a 12502; rfl; exact absurd (Nat.eq_of_beq_eq_true h) h2
      rw [e1, e2, Bool.cond_false, Bool.cond_false, Fr.dom]
      simp [h1, h2]

theorem frX_emit {S : Type} (s0 : St S) (X : Nat → Option (List Val × List Val)) (p1 p2 : List Val) :
    frX s0 X p1 p2 12502 = some (arrOf s0 12502, p2) := rfl

theorem frX_fwd {S : Type} (s0 : St S) (X : Nat → Option (List Val × List Val)) (p1 p2 : List Val) :
    frX s0 X p1 p2 2673447 = some (arrOf s0 2673447, p1) := rfl

/-- The counter bases at iteration 1: the heap counter offset `D`, the target's handle and node
counters `H`, `N` above the template's. -/
structure LoopBase where
  D : Nat
  H : Nat
  N : Nat

/-- A relation family of the loop, by the target's remaining readbacks. -/
abbrev LoopR := List NumV → Map → (Nat → F64) → Ctx → St LF.S → SSrv → St LF.S → CSrv → Prop

/-- What the loop reads of its relation family: the table's numbers, the server swap and the
counter offset. -/
structure LoopRel (R : LoopR) : Prop where
  num : ∀ {r M ν K s S t C}, R r M ν K s S t C → NumOK M ν S C
  swap : ∀ {r M ν K s S S' t C}, R r M ν K s S t C → S'.tab = S.tab → Srv M ν S' C → R r M ν K s S' t C
  offset : ∀ {r M ν K s S t C}, R r M ν K s S t C → t.next = s.next + K.D

/-- The load world's relation family. -/
abbrev relL (P : LoadP) : LoopR := fun r => Rel LF (LR P r)

theorem relRel (P : LoadP) : LoopRel (relL P) where
  num h := h.srv.num
  swap h hS hs := h.srvSwap hS hs
  offset h := h.offset

/-! ## The invariant -/

/-- **The loop invariant at iteration `i`** with the relation family `R`, the further frames `Fr`
and the counter bases `B`. -/
def LoopInvF (Gx : Nat → Map → St LF.S → CSrv → Prop) (R : LoopR) (P : LoadP) (Fr : LoopFrames) (s0 : St LF.S)
    (tab0 : List SymE) (fixA : List Nat) (V : LoopVals) (tk : Nat → Nat) (toks : List NumV) (E0 : List Val)
    (B : LoopBase) (ΔJ ΔH ΔN : Nat) (i : Nat) (t : St LF.S) (C : CSrv) : Prop :=
  ∃ M K nx p1, R (toks.drop i) M (V i nx) K s0 ⟨tab0, []⟩ t C ∧
    K.fr = frX s0 Fr.X p1 (E0 ++ (toks.take (i - 1)).map Val.num) ∧ K.lo = P.lo ∧ K.hi = P.E ∧
    K.base = s0.trace ∧ toks[i - 1]? = some (M.num 79) ∧ nx ≤ 2 ^ 20 ∧
    (∀ j (hj : j < toks.length), C.val toks[j] = some (F64.ofNat (tk (j + 2)))) ∧
    K.D ≤ (i - 1) * ΔJ + B.D ∧ t.ffi.mlx.next ≤ s0.ffi.mlx.next + (i - 1) * ΔH + B.H ∧
    t.ffi.mlx.nnext ≤ s0.ffi.mlx.nnext + (i - 1) * ΔN + B.N ∧ (∀ a ∈ fixA, M.a a = a) ∧ Gx i M t C

/-- **Without further frames, at the load world's relation and zero bases, `LoopInvF` is
`LoopInvV`** (definitionally). -/
theorem LoopInvF_empty {Gx : Nat → Map → St LF.S → CSrv → Prop} {P : LoadP} {s0 : St LF.S} {tab0 : List SymE}
    {fixA : List Nat} {V : LoopVals} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {ΔJ ΔH ΔN i : Nat}
    {t : St LF.S} {C : CSrv} :
    LoopInvF Gx (relL P) P LoopFrames.empty s0 tab0 fixA V tk toks E0 ⟨0, 0, 0⟩ ΔJ ΔH ΔN i t C ↔
      LoopInvV Gx P s0 tab0 fixA V tk toks E0 ΔJ ΔH ΔN i t C := Iff.rfl

/-- `LoopGStepV` with the relation family `R` and the further frames `Fr`. -/
def LoopGStepF (Gx : Nat → Map → St LF.S → CSrv → Prop) (R : LoopR) (Fr : LoopFrames) {ok : St LF.S → SSrv → Bool}
    {P : LoadP} {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat} (c : LoopCase ok P s0 tab0 fixA)
    (V : LoopVals) (toks : List NumV) (i : Nat) : Prop :=
  ∀ (hlen : i < toks.length) (nx : Nat) (M : Map) (K : Ctx) (t : St LF.S) (C : CSrv) (M1 : Map) (t1 : St LF.S)
    (C1 : CSrv), Gx i M t C →
    R (toks.drop i) M (V i nx) K s0 ⟨tab0, []⟩ t C →
    (∀ a, K.fr a ≠ none ↔ a ∈ 2673447 :: 12502 :: Fr.xs) → K.lo = P.lo → K.hi = P.E →
    runC LF c.n t C = some (t1, C1) → Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx → Ext M M1 c.S0.tab.length →
    R (toks.drop i) M1 (V i nx) K c.s1 c.S1 t1 C1 →
    Gx (i + 1) (((M1.setNum c.S1.tab.length toks[i]).after c.σ).rebig s0.ffi.mlx.next P.E t1.ffi.mlx.next) t1 C1

theorem LoopGStepF_empty {Gx : Nat → Map → St LF.S → CSrv → Prop} {ok : St LF.S → SSrv → Bool} {P : LoadP}
    {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat} (c : LoopCase ok P s0 tab0 fixA) (V : LoopVals)
    (toks : List NumV) (i : Nat) :
    LoopGStepF Gx (relL P) LoopFrames.empty c V toks i ↔ LoopGStepV Gx c V toks i := Iff.rfl

/-! ## A case's iteration -/

section Case
variable {ok : St LF.S → SSrv → Bool} {P : LoadP} {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat}

/-- **A loop case's iteration under the relation family `R`** with the further frames `Fr`
(`load_step`'s conclusion): from a target related to the case's start under the loop's frames,
the case's target run, the lockstep counters, the restarted relation at the substituted
valuation (the next readback `v` at `v17`), the relation at the case's end, and the native
growth. -/
def LoopCase.IterF (R : LoopR) (Fr : LoopFrames) (VBOk : (Nat → F64) → Prop) (c : LoopCase ok P s0 tab0 fixA) :
    Prop :=
  ∀ (r : List NumV) (v : NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (t : St LF.S) (C : CSrv) (x : F64)
    (p1 p2 : List Val), VBOk ν → K.fr = frX s0 Fr.X p1 p2 → K.lo = P.lo → K.hi = P.E →
    R (v :: r) M ν K s0 c.S0 t C → C.val v = some x →
    c.s1.next - s0.next + K.D < Sim.bound →
    t.ffi.mlx.next + (c.s1.ffi.mlx.next - s0.ffi.mlx.next) + (P.E - s0.ffi.mlx.next) < 2 ^ 46 →
    t.ffi.mlx.nnext + (c.s1.ffi.mlx.nnext - s0.ffi.mlx.nnext) + (P.NE - s0.ffi.mlx.nnext) < 2 ^ 62 →
    ∃ M1 t1 C1, runC LF c.n t C = some (t1, C1) ∧ Ext M M1 c.S0.tab.length ∧
      t1.next = t.next + (c.s1.next - s0.next) ∧
      t1.ffi.mlx.next = t.ffi.mlx.next + (c.s1.ffi.mlx.next - s0.ffi.mlx.next) ∧
      t1.ffi.mlx.nnext = t.ffi.mlx.nnext + (c.s1.ffi.mlx.nnext - s0.ffi.mlx.nnext) ∧
      R r (((M1.setNum c.S1.tab.length v).after c.σ).rebig s0.ffi.mlx.next P.E t1.ffi.mlx.next)
        (Shift.valuation c.θ (upd ν 17 x))
        ⟨Shift.framedNext (M1.setNum c.S1.tab.length v) K c.s1, s0.trace, t1.trace, t1.next - s0.next, K.lo, K.hi⟩
        s0 ⟨tab0, []⟩ t1 C1 ∧
      R (v :: r) M1 ν K c.s1 c.S1 t1 C1 ∧ Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx

/-- The case's end keeps the further frames: at each, no element appended to an array. -/
def LoopCase.Keeps (c : LoopCase ok P s0 tab0 fixA) (Fr : LoopFrames) : Prop :=
  ∀ a pre pre', Fr.X a = some (pre, pre') → ∀ o es, c.s1.heap.get a = some (.obj o) → o.kind = .array es →
    es.drop pre.length = []

theorem LoopCase.keeps_empty (c : LoopCase ok P s0 tab0 fixA) : c.Keeps LoopFrames.empty :=
  fun _ _ _ h => by cases h

/-- **The case's shift under the frames** (the template fact `ShiftJS` for every context framing
`forwarded`, `emitted` and `Fr`). -/
def LoopCase.ShiftF (c : LoopCase ok P s0 tab0 fixA) (Fr : LoopFrames) : Prop :=
  ∀ (p1 p2 : List Val) (K : Ctx), K.fr = frX s0 Fr.X p1 p2 → K.lo = P.lo → K.hi = P.E →
    ShiftJS LF c.σ c.θ K s0 c.S0 c.s1 ⟨c.S1.tab ++ [.var 17], c.S1.oracle⟩

/-- The existing cases' shift is `ShiftF` without further frames. -/
theorem LoopCase.shiftF_empty (c : LoopCase ok P s0 tab0 fixA) : c.ShiftF LoopFrames.empty :=
  fun p1 p2 K hfr hlo hhi => c.shiftJS p1 p2 K hfr hlo hhi

/-- **The load world's iteration** (`load_step`): with the case's shift under the frames and an
acceptance framing exactly `forwarded`, `emitted` and `Fr`. -/
theorem LoopCase.iterF_rel {jsP : Disp.JSP LF} {VBOk : (Nat → F64) → Prop} (Fr : LoopFrames)
    (hsim : ∀ r, Disp.StepSimXV LF (LR P r) ok (Disp.Kp jsP) VBOk)
    (hjlo : jsP.lo = P.lo) (hjhi : jsP.hi = P.E) (hjfr : ∀ a, a ∈ jsP.framed ↔ a ∈ 2673447 :: 12502 :: Fr.xs)
    (hng : ∀ (r : List NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (n : Nat) (s t s1 t1 : St LF.S) (S S1 : SSrv)
      (C C1 : CSrv), Disp.Kp jsP K → VBOk ν → Rel LF (LR P r) M ν K s S t C → ok s S = true →
      runOk LF ok n s S = some (s1, S1) → runC LF n t C = some (t1, C1) → Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx)
    (st : LoopStart P s0 tab0) (c : LoopCase ok P s0 tab0 fixA) (hsh : c.ShiftF Fr) :
    c.IterF (relL P) Fr VBOk := by
  intro r v M ν K t C x p1 p2 hν hfr hlo hhi h hx hD hroomH hroomN
  have hK : Disp.Kp jsP K := ⟨hlo.trans hjlo.symm, hhi.trans hjhi.symm, fun a => by
    rw [hjfr, hfr]; exact frX_ne_none s0 Fr p1 p2 a⟩
  have hshift := (hsh p1 p2 K hfr hlo hhi).toShift
    (FS := FSn { P with rest := v :: r } c.S0.tab.length s0.ffi) ⟨rfl, by rw [c.tab]; exact c.nshift.withRest _⟩
  have hband : ∀ j : Int, (s0.ffi.mlx.next : Int) ≤ j ∧ j < P.E → ¬ BigFixed K.lo K.hi j ∧ 0 ≤ j ∧ j < 2 ^ 56 := by
    intro j hj
    have := st.lo; have := st.hi
    rw [hlo, hhi]
    refine ⟨fun hf => ?_, by omega, by omega⟩
    unfold BigFixed at hf
    omega
  obtain ⟨M1, t1, C1, hrc, he, hoff, hH1, hN1, hrel, hpre⟩ :=
    load_step (hsim (v :: r)) hK hν h rfl c.ok0 c.run c.ctl c.noVarTab c.noVarOr hshift
      c.num79 st.tok (by rw [c.tab]; exact st.h79) st.big st.free hband hx c.hE hD hroomH hroomN
  refine ⟨M1, t1, C1, hrc, he, hoff, hH1, hN1, ?_, hpre, hng _ _ _ _ _ _ _ _ _ _ _ _ _ hK hν h c.ok0 c.run hrc⟩
  rw [c.tab] at hrel
  exact hrel

/-- After an iteration the frames are the template's prefixes with the target prefixes of
`forwarded` and `emitted` extended; the further frames are kept. -/
theorem framedNext_frX {M : Map} {K : Ctx} {Fr : LoopFrames} {p1 p2 xs : List Val}
    (c : LoopCase ok P s0 tab0 fixA) (hfr : K.fr = frX s0 Fr.X p1 p2) (hk : c.Keeps Fr)
    (hf : ∃ o, c.s1.heap.get 2673447 = some (.obj o) ∧ o.kind = .array (arrOf s0 2673447 ++ xs))
    (he : ∃ o, c.s1.heap.get 12502 = some (.obj o) ∧ o.kind = .array (arrOf s0 12502 ++ [.num (.ref 79)])) :
    Shift.framedNext M K c.s1 = frX s0 Fr.X (p1 ++ M.vals xs) (p2 ++ [.num (M.nv (.ref 79))]) := by
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
    · have e1 : Nat.beq a 2673447 = false := by
        cases h : Nat.beq a 2673447; rfl; exact absurd (Nat.eq_of_beq_eq_true h) ha1
      have e2 : Nat.beq a 12502 = false := by
        cases h : Nat.beq a 12502; rfl; exact absurd (Nat.eq_of_beq_eq_true h) ha2
      have hX : K.fr a = Fr.X a := by rw [hfr]; unfold frX; rw [e1, e2]; rfl
      have hR : frX s0 Fr.X (p1 ++ M.vals xs) (p2 ++ [.num (M.nv (.ref 79))]) a = Fr.X a := by
        unfold frX; rw [e1, e2]; rfl
      rw [hR]
      cases hxa : Fr.X a with
      | none => exact (framedNext_none_iff a).2 (hX.trans hxa)
      | some p =>
        obtain ⟨pre, pre'⟩ := p
        unfold Shift.framedNext
        rw [hX, hxa]
        cases hg : c.s1.heap.get a with
        | none => rfl
        | some h =>
          cases h with
          | cell _ => rfl
          | obj o =>
            cases hok : o.kind with
            | array es =>
              simp only [hok, hk a pre pre' hxa o es hg hok, Map.vals, List.map_nil, List.append_nil]
            | _ => simp only [hok]

end Case

/-! ## The steps -/

/-- **One loop iteration preserves the invariant** (`loop_stepV`) for any relation family with
the case's iteration theorem. -/
theorem loop_stepF {Gx : Nat → Map → St LF.S → CSrv → Prop} {R : LoopR} (hR : LoopRel R)
    {ok : St LF.S → SSrv → Bool} {P : LoadP} {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat}
    {VBOk : (Nat → F64) → Prop} (Fr : LoopFrames) (st : LoopStart P s0 tab0) (c : LoopCase ok P s0 tab0 fixA)
    (hit : c.IterF R Fr VBOk) (hkeep : c.Keeps Fr)
    {V : LoopVals} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {B : LoopBase} {ΔJ ΔH ΔN : Nat}
    {i : Nat} {t : St LF.S} {C : CSrv}
    (hinv : LoopInvF Gx R P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN i t C) (hi1 : 1 ≤ i) (hlen : i < toks.length)
    (hgood : ∀ nx, Good (V i nx) c.S0.oracle)
    (hVB : ∀ nx, nx ≤ 2 ^ 20 → VBOk (V i nx))
    (hnext : ∀ nx, Shift.valuation c.θ (upd (V i nx) 17 (F64.ofNat (tk (i + 2)))) = V (i + 1) (tk (i + 2)))
    (htk : tk (i + 2) ≤ 2 ^ 20)
    (hdJ : c.s1.next - s0.next ≤ ΔJ) (hdH : c.s1.ffi.mlx.next - s0.ffi.mlx.next ≤ ΔH)
    (hdN : c.s1.ffi.mlx.nnext - s0.ffi.mlx.nnext ≤ ΔN)
    (hJ : i * ΔJ + B.D < Sim.bound) (hH : s0.ffi.mlx.next + i * ΔH + B.H + (P.E - s0.ffi.mlx.next) < 2 ^ 46)
    (hN : s0.ffi.mlx.nnext + i * ΔN + B.N + (P.NE - s0.ffi.mlx.nnext) < 2 ^ 62)
    (hG : LoopGStepF Gx R Fr c V toks i) :
    ∃ t' C', runC LF c.n t C = some (t', C') ∧ LoopInvF Gx R P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN (i + 1) t' C' := by
  obtain ⟨M, K, nx, p1, h, hfr, hlo, hhi, hbase, h79, hnx, hvals, hD, hHi, hNi, hfix, hGx⟩ := hinv
  have h1 := hR.swap h c.tab ⟨fun j e he => hR.num h j e (by rw [c.tab] at he; exact he), hgood nx⟩
  have hdrop : toks.drop i = toks[i] :: toks.drop (i + 1) := List.drop_eq_getElem_cons hlen
  rw [hdrop] at h1
  have eJ : (i - 1) * ΔJ + ΔJ = i * ΔJ := by
    obtain ⟨k, rfl⟩ : ∃ k, i = k + 1 := ⟨i - 1, by omega⟩
    simp [Nat.add_mul]
  have eH : (i - 1) * ΔH + ΔH = i * ΔH := by
    obtain ⟨k, rfl⟩ : ∃ k, i = k + 1 := ⟨i - 1, by omega⟩
    simp [Nat.add_mul]
  have eN : (i - 1) * ΔN + ΔN = i * ΔN := by
    obtain ⟨k, rfl⟩ : ∃ k, i = k + 1 := ⟨i - 1, by omega⟩
    simp [Nat.add_mul]
  have hoff0 := hR.offset h
  obtain ⟨M1, t1, C1, hrc, he, hoff, hH1, hN1, hrel, hpre, hng⟩ :=
    hit (toks.drop (i + 1)) toks[i] M (V i nx) K t C (F64.ofNat (tk (i + 2))) p1
      (E0 ++ (toks.take (i - 1)).map Val.num) (hVB nx hnx) hfr hlo hhi h1 (hvals i hlen) (by omega) (by omega)
      (by omega)
  have hlen1 : 79 < c.S1.tab.length := by
    have := interpS_runOk_len c.run; rw [c.tab] at this; have := st.h79; omega
  have hM79 : (M1.setNum c.S1.tab.length toks[i]).num 79 = M.num 79 := by
    rw [(Map.setNum_ext M1 c.S1.tab.length toks[i]).num 79 hlen1]
    exact he.num 79 (by rw [c.tab]; exact st.h79)
  refine ⟨t1, C1, hrc, (((M1.setNum c.S1.tab.length toks[i]).after c.σ).rebig s0.ffi.mlx.next P.E t1.ffi.mlx.next),
    ⟨Shift.framedNext (M1.setNum c.S1.tab.length toks[i]) K c.s1, s0.trace, t1.trace, t1.next - s0.next, K.lo, K.hi⟩,
    tk (i + 2), p1 ++ (M1.setNum c.S1.tab.length toks[i]).vals c.xs,
    ?_, ?_, hlo, hhi, rfl, ?_, htk, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · rw [hnext nx] at hrel
    exact hrel
  · show Shift.framedNext (M1.setNum c.S1.tab.length toks[i]) K c.s1 = _
    rw [framedNext_frX c hfr hkeep c.fwd c.emit]
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
  · show t1.next - s0.next ≤ (i + 1 - 1) * ΔJ + B.D
    rw [hoff, show i + 1 - 1 = i by omega]
    omega
  · rw [hH1, show i + 1 - 1 = i by omega]
    omega
  · rw [hN1, show i + 1 - 1 = i by omega]
    omega
  · intro a ha
    show M1.a (c.σ.a a) = a
    rw [c.fix a ha, he.a, hfix a ha]
  · exact hG hlen nx M K t C M1 t1 C1 hGx h (fun a => by rw [hfr]; exact frX_ne_none s0 Fr p1 _ a) hlo hhi hrc hng
      he (by rw [hdrop]; exact hpre)

/-- **The loop up to iteration `J`** (`loop_all_toV`) for any relation family. -/
theorem loop_all_toF {Gx : Nat → Map → St LF.S → CSrv → Prop} {R : LoopR} (hR : LoopRel R)
    {ok : St LF.S → SSrv → Bool} {P : LoadP} {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat}
    {VBOk : (Nat → F64) → Prop} (Fr : LoopFrames) (st : LoopStart P s0 tab0) (sel : Nat → LoopCase ok P s0 tab0 fixA)
    (hit : ∀ i, (sel i).IterF R Fr VBOk) (hkeep : ∀ i, (sel i).Keeps Fr)
    {V : LoopVals} {T : Nat} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {B : LoopBase} {ΔJ ΔH ΔN : Nat}
    (J : Nat) (hJT : J + 2 ≤ T) (hlen : T - 2 ≤ toks.length)
    (hgood : ∀ i, 1 ≤ i → i < J → ∀ nx, Good (V i nx) (sel i).S0.oracle)
    (hVB : ∀ i, 1 ≤ i → i < J → ∀ nx, nx ≤ 2 ^ 20 → VBOk (V i nx))
    (hnext : ∀ i, 1 ≤ i → i < J → ∀ nx,
      Shift.valuation (sel i).θ (upd (V i nx) 17 (F64.ofNat (tk (i + 2)))) = V (i + 1) (tk (i + 2)))
    (htk : ∀ j, j ≤ T → tk j ≤ 2 ^ 20)
    (hdJ : ∀ i, (sel i).s1.next - s0.next ≤ ΔJ) (hdH : ∀ i, (sel i).s1.ffi.mlx.next - s0.ffi.mlx.next ≤ ΔH)
    (hdN : ∀ i, (sel i).s1.ffi.mlx.nnext - s0.ffi.mlx.nnext ≤ ΔN)
    (hJ : T * ΔJ + B.D < Sim.bound) (hH : s0.ffi.mlx.next + T * ΔH + B.H + (P.E - s0.ffi.mlx.next) < 2 ^ 46)
    (hN : s0.ffi.mlx.nnext + T * ΔN + B.N + (P.NE - s0.ffi.mlx.nnext) < 2 ^ 62)
    (hG : ∀ i, 1 ≤ i → i < J → LoopGStepF Gx R Fr (sel i) V toks i)
    {t : St LF.S} {C : CSrv} (h1 : LoopInvF Gx R P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN 1 t C) (hJ1 : 1 ≤ J) :
    ∃ t' C', runC LF (iterSteps (fun i => (sel i).n) 1 (J - 1)) t C = some (t', C') ∧
      LoopInvF Gx R P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN J t' C' := by
  have := loop_induct (F := LF) (LoopInvF Gx R P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN) (fun i => 1 ≤ i ∧ i < J)
    (fun i => (sel i).n) (fun i t C hinv ⟨hi1, hiJ⟩ => by
      have hmul : ∀ D, i * D ≤ T * D := fun D => Nat.mul_le_mul_right D (by omega)
      exact loop_stepF hR Fr st (sel i) (hit i) (hkeep i) hinv hi1 (by omega) (hgood i hi1 hiJ) (hVB i hi1 hiJ)
        (hnext i hi1 hiJ) (htk (i + 2) (by omega)) (hdJ i) (hdH i) (hdN i)
        (by have := hmul ΔJ; omega) (by have := hmul ΔH; omega) (by have := hmul ΔN; omega) (hG i hi1 hiJ))
    (J - 1) 1 t C h1 (fun j hj => ⟨by omega, by omega⟩)
  rw [show 1 + (J - 1) = J by omega] at this
  exact this

/-- **All loop iterations** (`loop_allV`) for any relation family. -/
theorem loop_allF {Gx : Nat → Map → St LF.S → CSrv → Prop} {R : LoopR} (hR : LoopRel R)
    {ok : St LF.S → SSrv → Bool} {P : LoadP} {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat}
    {VBOk : (Nat → F64) → Prop} (Fr : LoopFrames) (st : LoopStart P s0 tab0) (sel : Nat → LoopCase ok P s0 tab0 fixA)
    (hit : ∀ i, (sel i).IterF R Fr VBOk) (hkeep : ∀ i, (sel i).Keeps Fr)
    {V : LoopVals} {T : Nat} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {B : LoopBase} {ΔJ ΔH ΔN : Nat}
    (hT : 3 ≤ T) (hlen : T - 2 ≤ toks.length)
    (hgood : ∀ i, 1 ≤ i → i + 2 < T → ∀ nx, Good (V i nx) (sel i).S0.oracle)
    (hVB : ∀ i, 1 ≤ i → i + 2 < T → ∀ nx, nx ≤ 2 ^ 20 → VBOk (V i nx))
    (hnext : ∀ i, 1 ≤ i → i + 2 < T → ∀ nx,
      Shift.valuation (sel i).θ (upd (V i nx) 17 (F64.ofNat (tk (i + 2)))) = V (i + 1) (tk (i + 2)))
    (htk : ∀ j, j ≤ T → tk j ≤ 2 ^ 20)
    (hdJ : ∀ i, (sel i).s1.next - s0.next ≤ ΔJ) (hdH : ∀ i, (sel i).s1.ffi.mlx.next - s0.ffi.mlx.next ≤ ΔH)
    (hdN : ∀ i, (sel i).s1.ffi.mlx.nnext - s0.ffi.mlx.nnext ≤ ΔN)
    (hJ : T * ΔJ + B.D < Sim.bound) (hH : s0.ffi.mlx.next + T * ΔH + B.H + (P.E - s0.ffi.mlx.next) < 2 ^ 46)
    (hN : s0.ffi.mlx.nnext + T * ΔN + B.N + (P.NE - s0.ffi.mlx.nnext) < 2 ^ 62)
    (hG : ∀ i, 1 ≤ i → i + 2 < T → LoopGStepF Gx R Fr (sel i) V toks i)
    {t : St LF.S} {C : CSrv} (h1 : LoopInvF Gx R P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN 1 t C) :
    ∃ t' C', runC LF (iterSteps (fun i => (sel i).n) 1 (T - 3)) t C = some (t', C') ∧
      LoopInvF Gx R P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN (T - 2) t' C' := by
  have := loop_all_toF hR Fr st sel hit hkeep (T - 2) (by omega) hlen
    (fun i h1 h2 => hgood i h1 (by omega)) (fun i h1 h2 => hVB i h1 (by omega))
    (fun i h1 h2 => hnext i h1 (by omega)) htk hdJ hdH hdN hJ hH hN (fun i h1 h2 => hG i h1 (by omega)) h1
    (by omega)
  rw [show T - 2 - 1 = T - 3 by omega] at this
  exact this

end Host.Ts.Sim
