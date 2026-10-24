import host.sim.world.World
namespace Host.Ts.Sim
open Host.Ts Host.Ts.Sim.Template

/-! # The decode loop over a world, at a driver's constants

`DecodeAddr.lean` over a world `Wd`:

* `LoopStartW` (`LoopStartA`): the template start's facts, the native ones as `Wd.Start`;
* `LoopCaseW`: a loop case's template facts at its end and its restart data (`LoopCaseA` without
  the evidence of its run, so that a case may be one checked run, `LoopRunW`, or a chain of
  pieces, `LoopSegW` in `host.sim.world.LoopSeg`);
* `LoopRW`, `LoopRelW`, `relW`, `relRelW`: the relation families of the loop (`LoopR`, `LoopRel`,
  `relLW`, `relRelF`);
* `LoopInvW`, `LoopGStepW`, `LoopCaseW.IterFW`, `KeepsW`, `ShiftFWW` (`LoopInvA` …
  `ShiftFWA`), `LoopRunW.iterF_relFW` (`iterF_relFA`, from the world's `restart`),
  `framedNext_frW`, `loop_stepW` (`loop_stepA`). -/

section Defs
variable (Wd : World)

/-- **Facts about the template start** at `A` over `Wd` (`LoopStartA`). -/
structure LoopStartW (A : Addr) (P : Wd.Par) (s0 : St Wd.F.S) (tab0 : List SymE) : Prop where
  htok : A.tok < tab0.length
  start : Wd.Start P A.tok s0
  lo : Wd.lo P ≤ (Wd.toMlx s0.ffi).next
  hi : Wd.E P ≤ 2 ^ 56

/-- **A loop case's template facts** at `A` over `Wd`: the case's server, steps, end state, shift
data and end arrays (`LoopCaseA` without the evidence of its run). -/
structure LoopCaseW (A : Addr) (P : Wd.Par) (s0 : St Wd.F.S) (tab0 : List SymE) (fixA : List Nat) where
  S0 : SSrv
  n : Nat
  s1 : St Wd.F.S
  S1 : SSrv
  σ : Map
  θ : Nat → SymE
  grow : Bool
  xs : List Val
  tab : S0.tab = tab0
  tlen : S0.tab.length ≤ S1.tab.length
  noVarTab : ∀ e ∈ S1.tab, e.noVar A.nxt = true
  noVarOr : ∀ q ∈ S1.oracle, q.noVar A.nxt = true
  nshift : Wd.NSh P tab0.length σ s0.ffi s1.ffi
  num : σ.num A.tok = .ref S1.tab.length
  hE : (Wd.toMlx s1.ffi).next < Wd.E P
  theta : ∀ j, θ j = loopTheta grow A.nxt j
  fwd : ∃ o, s1.heap.get A.fwd = some (.obj o) ∧ o.kind = .array (arrOf s0 A.fwd ++ xs)
  emit : ∃ o, s1.heap.get A.emit = some (.obj o) ∧ o.kind = .array (arrOf s0 A.emit ++ [.num (.ref A.tok)])
  fix : ∀ a ∈ fixA, σ.a a = a

/-- **A loop case checked as one run** at `A` over `Wd` (`LoopCaseA`). -/
structure LoopRunW (A : Addr) (ok : St Wd.F.S → SSrv → Bool) (P : Wd.Par) (s0 : St Wd.F.S) (tab0 : List SymE)
    (fixA : List Nat) extends LoopCaseW Wd A P s0 tab0 fixA where
  ok0 : ok s0 S0 = true
  run : runOk Wd.F ok n s0 S0 = some (s1, S1)
  ctl : ∀ v, s1.ctl ≠ .ret v

/-- A relation family of the loop over `Wd`, by the target's remaining readbacks (`LoopR`). -/
abbrev LoopRW := List NumV → Map → (Nat → F64) → Ctx → St Wd.F.S → SSrv → St Wd.F.S → CSrv → Prop

/-- What the loop reads of its relation family (`LoopRel`). -/
structure LoopRelW (R : LoopRW Wd) : Prop where
  num : ∀ {r M ν K s S t C}, R r M ν K s S t C → NumOK M ν S C
  swap : ∀ {r M ν K s S S' t C}, R r M ν K s S t C → S'.tab = S.tab → Srv M ν S' C → R r M ν K s S' t C
  offset : ∀ {r M ν K s S t C}, R r M ν K s S t C → t.next = s.next + K.D

/-- The world's relation family under the frames `W` (`relLW`). -/
abbrev relW (P : Wd.Par) (W : Nat → Option WFrame) : LoopRW Wd := fun r => RelF Wd.F (Wd.R P r) W

theorem relRelW (P : Wd.Par) (W : Nat → Option WFrame) : LoopRelW Wd (relW Wd P W) where
  num h := h.srv.num
  swap h hS hs := h.srvSwap hS hs
  offset h := h.offset

/-- **The loop invariant at iteration `i`** at `A` over `Wd` (`LoopInvA`). -/
def LoopInvW (A : Addr) (Gx : Nat → Map → St Wd.F.S → CSrv → Prop) (R : LoopRW Wd) (P : Wd.Par)
    (Fr : LoopFramesA A) (s0 : St Wd.F.S) (tab0 : List SymE) (fixA : List Nat) (V : LoopVals) (tk : Nat → Nat)
    (toks : List NumV) (E0 : List Val) (B : LoopBase) (ΔJ ΔH ΔN : Nat) (i : Nat) (t : St Wd.F.S) (C : CSrv) : Prop :=
  ∃ M K nx p1, R (toks.drop i) M (V i nx) K s0 ⟨tab0, []⟩ t C ∧
    K.fr = frA A s0 Fr.X p1 (E0 ++ (toks.take (i - 1)).map Val.num) ∧ K.lo = Wd.lo P ∧ K.hi = Wd.E P ∧
    K.base = s0.trace ∧ toks[i - 1]? = some (M.num A.tok) ∧ nx ≤ 2 ^ 20 ∧
    (∀ j (hj : j < toks.length), C.val toks[j] = some (F64.ofNat (tk (j + 2)))) ∧
    K.D ≤ (i - 1) * ΔJ + B.D ∧ (Wd.toMlx t.ffi).next ≤ (Wd.toMlx s0.ffi).next + (i - 1) * ΔH + B.H ∧
    (Wd.toMlx t.ffi).nnext ≤ (Wd.toMlx s0.ffi).nnext + (i - 1) * ΔN + B.N ∧ (∀ a ∈ fixA, M.a a = a) ∧ Gx i M t C

/-- The restart map of a case's end `M1` with the next readback `v` (the map `loop_stepW`
restarts under). -/
abbrev LoopCaseW.rmap {Wd : World} {A : Addr} {P : Wd.Par} {s0 : St Wd.F.S} {tab0 : List SymE} {fixA : List Nat}
    (c : LoopCaseW Wd A P s0 tab0 fixA) (M1 : Map) (v : NumV) (t1 : St Wd.F.S) : Map :=
  ((M1.setNum c.S1.tab.length v).after c.σ).rebig (Wd.toMlx s0.ffi).next (Wd.E P) (Wd.toMlx t1.ffi).next

end Defs

section Case
variable {Wd : World} {A : Addr} {P : Wd.Par} {s0 : St Wd.F.S} {tab0 : List SymE} {fixA : List Nat}

/-- `LoopGStepA` over `Wd`. -/
def LoopGStepW (Gx : Nat → Map → St Wd.F.S → CSrv → Prop) (R : LoopRW Wd) (Fr : LoopFramesA A)
    (c : LoopCaseW Wd A P s0 tab0 fixA) (V : LoopVals) (toks : List NumV) (i : Nat) : Prop :=
  ∀ (hlen : i < toks.length) (nx : Nat) (M : Map) (K : Ctx) (t : St Wd.F.S) (C : CSrv) (M1 : Map) (t1 : St Wd.F.S)
    (C1 : CSrv), Gx i M t C →
    R (toks.drop i) M (V i nx) K s0 ⟨tab0, []⟩ t C →
    (∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Fr.xs) → K.lo = Wd.lo P → K.hi = Wd.E P →
    runC Wd.F c.n t C = some (t1, C1) → Wd.Grows t t1 → Ext M M1 c.S0.tab.length →
    R (toks.drop i) M1 (V i nx) K c.s1 c.S1 t1 C1 →
    Gx (i + 1) (c.rmap M1 toks[i] t1) t1 C1

/-- **A loop case's iteration** over `Wd` (`LoopCaseA.IterFA`). -/
def LoopCaseW.IterFW (R : LoopRW Wd) (Fr : LoopFramesA A) (VBOk : (Nat → F64) → Prop)
    (c : LoopCaseW Wd A P s0 tab0 fixA) : Prop :=
  ∀ (r : List NumV) (v : NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (t : St Wd.F.S) (C : CSrv) (x : F64)
    (p1 p2 : List Val), VBOk ν → K.fr = frA A s0 Fr.X p1 p2 → K.lo = Wd.lo P → K.hi = Wd.E P →
    R (v :: r) M ν K s0 c.S0 t C → C.val v = some x →
    c.s1.next - s0.next + K.D < Sim.bound →
    (Wd.toMlx t.ffi).next + ((Wd.toMlx c.s1.ffi).next - (Wd.toMlx s0.ffi).next) +
      (Wd.E P - (Wd.toMlx s0.ffi).next) < 2 ^ 46 →
    (Wd.toMlx t.ffi).nnext + ((Wd.toMlx c.s1.ffi).nnext - (Wd.toMlx s0.ffi).nnext) +
      (Wd.NE P - (Wd.toMlx s0.ffi).nnext) < 2 ^ 62 →
    ∃ M1 t1 C1, runC Wd.F c.n t C = some (t1, C1) ∧ Ext M M1 c.S0.tab.length ∧
      t1.next = t.next + (c.s1.next - s0.next) ∧
      (Wd.toMlx t1.ffi).next = (Wd.toMlx t.ffi).next + ((Wd.toMlx c.s1.ffi).next - (Wd.toMlx s0.ffi).next) ∧
      (Wd.toMlx t1.ffi).nnext = (Wd.toMlx t.ffi).nnext + ((Wd.toMlx c.s1.ffi).nnext - (Wd.toMlx s0.ffi).nnext) ∧
      R r (c.rmap M1 v t1) (Shift.valuation c.θ (upd ν A.nxt x))
        ⟨Shift.framedNext (M1.setNum c.S1.tab.length v) K c.s1, s0.trace, t1.trace, t1.next - s0.next, K.lo, K.hi⟩
        s0 ⟨tab0, []⟩ t1 C1 ∧
      R (v :: r) M1 ν K c.s1 c.S1 t1 C1 ∧ Wd.Grows t t1

/-- The case's end keeps the further frames (`LoopCaseA.KeepsA`). -/
def LoopCaseW.KeepsW (c : LoopCaseW Wd A P s0 tab0 fixA) (Fr : LoopFramesA A) : Prop :=
  ∀ a pre pre', Fr.X a = some (pre, pre') → ∀ o es, c.s1.heap.get a = some (.obj o) → o.kind = .array es →
    es.drop pre.length = []

/-- **The case's shift under the frames** over `Wd` (`LoopCaseA.ShiftFWA`). -/
def LoopCaseW.ShiftFWW (c : LoopCaseW Wd A P s0 tab0 fixA) (Fr : LoopFramesA A) (W : Nat → Option WFrame) : Prop :=
  (∀ (p1 p2 : List Val) (K : Ctx), K.fr = frA A s0 Fr.X p1 p2 → K.lo = Wd.lo P → K.hi = Wd.E P →
    ShiftJS Wd.F c.σ c.θ (K.unW W) s0 c.S0 c.s1 ⟨c.S1.tab ++ [.var A.nxt], c.S1.oracle⟩) ∧
  ∀ a w, W a = some w → a ∈ Fr.xs ∧ c.σ.a a = a ∧ Present s0 a ∧ WFix c.σ (Present s0) w

/-- The restart's band: the template's fresh handles are renamed, at a context with the world's
band. -/
theorem LoopStartW.band (st : LoopStartW Wd A P s0 tab0) {K : Ctx} (hlo : K.lo = Wd.lo P) (hhi : K.hi = Wd.E P) :
    ∀ j : Int, ((Wd.toMlx s0.ffi).next : Int) ≤ j ∧ j < Wd.E P → ¬ BigFixed K.lo K.hi j ∧ 0 ≤ j ∧ j < 2 ^ 56 := by
  intro j hj
  have := st.lo; have := st.hi
  rw [hlo, hhi]
  refine ⟨fun hf => ?_, by omega, by omega⟩
  unfold BigFixed at hf
  omega

/-- **The restart of a loop case** from a related start to a related end keeping the context
(the world's `restart` at the case's data, under the frames `W` kept). -/
theorem LoopCaseW.restartW (st : LoopStartW Wd A P s0 tab0) (c : LoopCaseW Wd A P s0 tab0 fixA)
    {Fr : LoopFramesA A} {W : Nat → Option WFrame} (hsh : c.ShiftFWW Fr W)
    {r : List NumV} {v : NumV} {M M1 : Map} {ν : Nat → F64} {K : Ctx} {t t1 : St Wd.F.S} {C C1 : CSrv} {x : F64}
    {p1 p2 : List Val} (hfr : K.fr = frA A s0 Fr.X p1 p2) (hlo : K.lo = Wd.lo P) (hhi : K.hi = Wd.E P)
    (h : RelF Wd.F (Wd.R P (v :: r)) W M ν K s0 c.S0 t C) (hrc : runC Wd.F c.n t C = some (t1, C1))
    (he : Ext M M1 c.S0.tab.length) (h1 : RelF Wd.F (Wd.R P (v :: r)) W M1 ν K c.s1 c.S1 t1 C1)
    (hx : C.val v = some x) (hD : c.s1.next - s0.next + K.D < Sim.bound)
    (hroomH : (Wd.toMlx t.ffi).next + ((Wd.toMlx c.s1.ffi).next - (Wd.toMlx s0.ffi).next) +
      (Wd.E P - (Wd.toMlx s0.ffi).next) < 2 ^ 46)
    (hroomN : (Wd.toMlx t.ffi).nnext + ((Wd.toMlx c.s1.ffi).nnext - (Wd.toMlx s0.ffi).nnext) +
      (Wd.NE P - (Wd.toMlx s0.ffi).nnext) < 2 ^ 62) :
    t1.next = t.next + (c.s1.next - s0.next) ∧
      (Wd.toMlx t1.ffi).next = (Wd.toMlx t.ffi).next + ((Wd.toMlx c.s1.ffi).next - (Wd.toMlx s0.ffi).next) ∧
      (Wd.toMlx t1.ffi).nnext = (Wd.toMlx t.ffi).nnext + ((Wd.toMlx c.s1.ffi).nnext - (Wd.toMlx s0.ffi).nnext) ∧
      RelF Wd.F (Wd.R P r) W (c.rmap M1 v t1) (Shift.valuation c.θ (upd ν A.nxt x))
        ⟨Shift.framedNext (M1.setNum c.S1.tab.length v) K c.s1, s0.trace, t1.trace, t1.next - s0.next, K.lo, K.hi⟩
        s0 ⟨tab0, []⟩ t1 C1 := by
  have hshift := ShiftD.ofJS (K1 := K) (FS := fun σ x y => x = s0.ffi ∧ Wd.NSh P c.S0.tab.length σ x y)
    (hsh.1 p1 p2 K hfr hlo hhi) ⟨rfl, by rw [c.tab]; exact c.nshift⟩
    (fun a w hw => by
      obtain ⟨hxs, hfix, hp, hwf⟩ := hsh.2 a w hw
      refine ⟨?_, hfix, hp, hwf⟩
      rw [hfr]
      exact (frA_ne_none A s0 Fr p1 p2 a).2 (List.mem_cons_of_mem _ (List.mem_cons_of_mem _ hxs)))
    (fun _ _ => rfl) (fun _ ha hn => absurd hn ha) rfl rfl
  obtain ⟨hoff, hH1, hN1, hrel⟩ := Wd.restart A.tok A.nxt st.start h rfl hrc he h1 rfl rfl rfl c.noVarTab c.noVarOr
    hshift (fun _ _ hw => hw) c.num (by rw [c.tab]; exact st.htok) (st.band hlo hhi) hx c.hE hD hroomH hroomN
  rw [dropNext_keep h1, c.tab] at hrel
  exact ⟨hoff, hH1, hN1, hrel⟩

/-- **The world's iteration under the frames `W`** for a case checked as one run
(`LoopCaseA.iterF_relFA`). -/
theorem LoopRunW.iterF_relFW {ok : St Wd.F.S → SSrv → Bool} {jsP : Disp.JSP Wd.F} {VBOk : (Nat → F64) → Prop}
    (Fr : LoopFramesA A) (W : Nat → Option WFrame) (hsim : ∀ r, Disp.StepSimXVW Wd.F (Wd.R P r) ok (Disp.Kp jsP) W VBOk)
    (hjlo : jsP.lo = Wd.lo P) (hjhi : jsP.hi = Wd.E P) (hjfr : ∀ a, a ∈ jsP.framed ↔ a ∈ A.fwd :: A.emit :: Fr.xs)
    (hng : ∀ (r : List NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (n : Nat) (s t s1 t1 : St Wd.F.S) (S S1 : SSrv)
      (C C1 : CSrv), Disp.Kp jsP K → VBOk ν → RelF Wd.F (Wd.R P r) W M ν K s S t C → ok s S = true →
      runOk Wd.F ok n s S = some (s1, S1) → runC Wd.F n t C = some (t1, C1) → Wd.Grows t t1)
    (st : LoopStartW Wd A P s0 tab0) (c : LoopRunW Wd A ok P s0 tab0 fixA) (hsh : c.ShiftFWW Fr W) :
    c.IterFW (relW Wd P W) Fr VBOk := by
  intro r v M ν K t C x p1 p2 hν hfr hlo hhi h hx hD hroomH hroomN
  have hK : Disp.Kp jsP K := ⟨hlo.trans hjlo.symm, hhi.trans hjhi.symm, fun a => by
    rw [hjfr, hfr]; exact frA_ne_none A s0 Fr p1 p2 a⟩
  obtain ⟨M1, t1, C1, hrc, he, hx1⟩ := Disp.runOk_simXVW Wd.F (Wd.R P (v :: r)) ok (Disp.Kp jsP) W VBOk
    (hsim (v :: r)) ν K hK hν c.n M s0 c.S0 t C c.s1 c.S1 (Or.inl h) c.ok0 c.run
  have h1 := hx1.rel c.ctl
  obtain ⟨hoff, hH1, hN1, hrel⟩ := c.restartW st hsh hfr hlo hhi h hrc he h1 hx hD hroomH hroomN
  exact ⟨M1, t1, C1, hrc, he, hoff, hH1, hN1, hrel, h1, hng _ _ _ _ _ _ _ _ _ _ _ _ _ hK hν h c.ok0 c.run hrc⟩

/-- After an iteration the frames are the template's prefixes with the target prefixes of
`forwarded` and `emitted` extended; the further frames are kept (`framedNext_frA`). -/
theorem framedNext_frW {M : Map} {K : Ctx} {Fr : LoopFramesA A} {p1 p2 : List Val}
    (c : LoopCaseW Wd A P s0 tab0 fixA) (hfr : K.fr = frA A s0 Fr.X p1 p2) (hk : c.KeepsW Fr) :
    Shift.framedNext M K c.s1 = frA A s0 Fr.X (p1 ++ M.vals c.xs) (p2 ++ [.num (M.nv (.ref A.tok))]) := by
  funext a
  obtain ⟨of, hgf, hkf⟩ := c.fwd
  obtain ⟨oe, hge, hke⟩ := c.emit
  by_cases ha1 : a = A.fwd
  · subst ha1
    rw [framedNext_of (by rw [hfr, frA_fwd]) hgf hkf, frA_fwd]
  · by_cases ha2 : a = A.emit
    · subst ha2
      rw [framedNext_of (by rw [hfr, frA_emit]) hge hke, frA_emit]
      rfl
    · have hX : K.fr a = Fr.X a := by rw [hfr, frA_other A s0 Fr.X p1 p2 ha1 ha2]
      rw [frA_other A s0 Fr.X _ _ ha1 ha2]
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

/-! ## The step -/

/-- **One loop iteration preserves the invariant** over `Wd` (`loop_stepA`). -/
theorem loop_stepW {Wd : World} {A : Addr} {Gx : Nat → Map → St Wd.F.S → CSrv → Prop} {R : LoopRW Wd}
    (hR : LoopRelW Wd R) {P : Wd.Par} {s0 : St Wd.F.S} {tab0 : List SymE} {fixA : List Nat}
    {VBOk : (Nat → F64) → Prop} (Fr : LoopFramesA A) (st : LoopStartW Wd A P s0 tab0)
    (c : LoopCaseW Wd A P s0 tab0 fixA) (hit : c.IterFW R Fr VBOk) (hkeep : c.KeepsW Fr)
    {V : LoopVals} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {B : LoopBase} {ΔJ ΔH ΔN : Nat}
    {i : Nat} {t : St Wd.F.S} {C : CSrv}
    (hinv : LoopInvW Wd A Gx R P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN i t C) (hi1 : 1 ≤ i) (hlen : i < toks.length)
    (hgood : ∀ nx, Good (V i nx) c.S0.oracle)
    (hVB : ∀ nx, nx ≤ 2 ^ 20 → VBOk (V i nx))
    (hnext : ∀ nx, Shift.valuation c.θ (upd (V i nx) A.nxt (F64.ofNat (tk (i + 2)))) = V (i + 1) (tk (i + 2)))
    (htk : tk (i + 2) ≤ 2 ^ 20)
    (hdJ : c.s1.next - s0.next ≤ ΔJ) (hdH : (Wd.toMlx c.s1.ffi).next - (Wd.toMlx s0.ffi).next ≤ ΔH)
    (hdN : (Wd.toMlx c.s1.ffi).nnext - (Wd.toMlx s0.ffi).nnext ≤ ΔN)
    (hJ : i * ΔJ + B.D < Sim.bound)
    (hH : (Wd.toMlx s0.ffi).next + i * ΔH + B.H + (Wd.E P - (Wd.toMlx s0.ffi).next) < 2 ^ 46)
    (hN : (Wd.toMlx s0.ffi).nnext + i * ΔN + B.N + (Wd.NE P - (Wd.toMlx s0.ffi).nnext) < 2 ^ 62)
    (hG : LoopGStepW Gx R Fr c V toks i) :
    ∃ t' C', runC Wd.F c.n t C = some (t', C') ∧
      LoopInvW Wd A Gx R P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN (i + 1) t' C' := by
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
  have hlen1 : A.tok < c.S1.tab.length := by
    have := c.tlen; rw [c.tab] at this; have := st.htok; omega
  have hM79 : (M1.setNum c.S1.tab.length toks[i]).num A.tok = M.num A.tok := by
    rw [(Map.setNum_ext M1 c.S1.tab.length toks[i]).num A.tok hlen1]
    exact he.num A.tok (by rw [c.tab]; exact st.htok)
  refine ⟨t1, C1, hrc, c.rmap M1 toks[i] t1,
    ⟨Shift.framedNext (M1.setNum c.S1.tab.length toks[i]) K c.s1, s0.trace, t1.trace, t1.next - s0.next, K.lo, K.hi⟩,
    tk (i + 2), p1 ++ (M1.setNum c.S1.tab.length toks[i]).vals c.xs,
    ?_, ?_, hlo, hhi, rfl, ?_, htk, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · rw [hnext nx] at hrel
    exact hrel
  · show Shift.framedNext (M1.setNum c.S1.tab.length toks[i]) K c.s1 = _
    rw [framedNext_frW c hfr hkeep]
    congr 1
    have hnv : (M1.setNum c.S1.tab.length toks[i]).nv (.ref A.tok) = toks[i - 1] := by
      show (M1.setNum c.S1.tab.length toks[i]).num A.tok = _
      rw [hM79]
      have := h79; rw [List.getElem?_eq_getElem (by omega)] at this
      exact (Option.some.inj this).symm
    rw [hnv, show i + 1 - 1 = (i - 1) + 1 by omega, ← take_map_succ toks (i - 1) (by omega), List.append_assoc]
  · show toks[i + 1 - 1]? = some ((c.rmap M1 toks[i] t1).num A.tok)
    show _ = some ((M1.setNum c.S1.tab.length toks[i]).nv (c.σ.num A.tok))
    rw [c.num]
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
  · exact hG hlen nx M K t C M1 t1 C1 hGx h (fun a => by rw [hfr]; exact frA_ne_none A s0 Fr p1 _ a) hlo hhi hrc hng
      he (by rw [hdrop]; exact hpre)

end Host.Ts.Sim
