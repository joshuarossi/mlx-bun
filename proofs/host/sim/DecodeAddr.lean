import host.sim.LoopFramesW
namespace Host.Ts.Sim
open Host.Ts Host.Ts.Sim.Template

/-! # The decode loop over a driver's template constants

The decode invariant and its steps (`LoopFrames.lean`, `LoopFramesW.lean`) name the current
driver's template constants: the output arrays `forwarded` (2673447) and `emitted` (12502), the
template's table reference of the cut's token (79) and its look-ahead variable (17). A
regenerated driver moves them. `Addr` collects them, with the program's cells (`emitted` 2590,
`cache` 2586, `generation` 2589) and the graph side's constants (the template's time and token
variables 9, 14, the pre-loop node bound 20000, the template's node counter 22539, the rope base
5554869888); `addr0` is today's.

Over `A : Addr`: the frames `frA`, `LoopFramesA`, the template start `LoopStartA`, the loop case
`LoopCaseA` (`LoopCase` without its frames-specific shift, at `A`), the restart
`load_restart_dropA` (`load_restart_drop` at `A`'s token reference and look-ahead variable), the
invariant `LoopInvA` and the obligation `LoopGStepA`, the case's iteration theorem `IterFA`, its
shift under the frames `ShiftFWA` and `LoopCase.iterF_relFA` (`iterF_relF`), `KeepsA`, and
`loop_stepA`. At `addr0` each is today's (`frA_addr0`, `LoopFrames.toA`, `LoopStart.toA`,
`LoopCase.toA`, `LoopInvA_addr0`, `LoopGStepA_addr0`, `IterFA_addr0`, `ShiftFWA_addr0`,
definitional). -/

/-- **A driver's template constants.** -/
structure Addr where
  /-- The `forwarded` array. -/
  fwd : Nat
  /-- The `emitted` array. -/
  emit : Nat
  /-- The cell of the driver's `emitted` binding. -/
  cE : Nat
  /-- The cell of the driver's `cache` binding. -/
  cache : Nat
  /-- The cell of the driver's `generation` binding. -/
  gen : Nat
  /-- The template's table reference of the cut's token. -/
  tok : Nat
  /-- The template's look-ahead variable. -/
  nxt : Nat
  /-- The template's variable of the cut's absolute time (the graph side). -/
  tvar : Nat
  /-- The template's variable of the cut's token (`A.tok`'s table entry; the graph side). -/
  kvar : Nat
  /-- The graph side: pre-loop native nodes are below `NL`. -/
  NL : Nat
  /-- The graph side: the template start's native node counter. -/
  N0 : Nat
  /-- The graph side: the rope base the template keeps. -/
  rope : Nat
  fwd_emit : fwd ≠ emit

/-- Today's driver. -/
def addr0 : Addr := ⟨2673447, 12502, 2590, 2586, 2589, 79, 17, 9, 14, 20000, 22539, 5554869888, by decide⟩

theorem Addr.beq_ne {a b : Nat} (h : a ≠ b) : Nat.beq a b = false := by
  cases hq : Nat.beq a b
  · rfl
  · exact absurd (Nat.eq_of_beq_eq_true hq) h

/-! ## Frames -/

/-- The loop's context frames at `A`: `forwarded` (target prefix `p1`), `emitted` (`p2`), `X`. -/
def frA {S : Type} (A : Addr) (s0 : St S) (X : Nat → Option (List Val × List Val)) (p1 p2 : List Val) (a : Nat) :
    Option (List Val × List Val) :=
  bif Nat.beq a A.fwd then some (arrOf s0 A.fwd, p1)
  else bif Nat.beq a A.emit then some (arrOf s0 A.emit, p2) else X a

theorem frA_addr0 {S : Type} (s0 : St S) (X : Nat → Option (List Val × List Val)) (p1 p2 : List Val) :
    frA addr0 s0 X p1 p2 = frX s0 X p1 p2 := rfl

/-- The further frames at `A`. -/
structure LoopFramesA (A : Addr) where
  X : Nat → Option (List Val × List Val)
  xs : List Nat
  dom : ∀ a, X a ≠ none ↔ a ∈ xs
  fwd : A.fwd ∉ xs
  emit : A.emit ∉ xs

/-- Today's further frames. -/
def LoopFrames.toA (Fr : LoopFrames) : LoopFramesA addr0 := ⟨Fr.X, Fr.xs, Fr.dom, Fr.fwd, Fr.emit⟩

theorem frA_fwd {S : Type} (A : Addr) (s0 : St S) (X : Nat → Option (List Val × List Val)) (p1 p2 : List Val) :
    frA A s0 X p1 p2 A.fwd = some (arrOf s0 A.fwd, p1) := by
  unfold frA; rw [Nat.beq_refl]; rfl

theorem frA_emit {S : Type} (A : Addr) (s0 : St S) (X : Nat → Option (List Val × List Val)) (p1 p2 : List Val) :
    frA A s0 X p1 p2 A.emit = some (arrOf s0 A.emit, p2) := by
  unfold frA; rw [Addr.beq_ne A.fwd_emit.symm, Nat.beq_refl]; rfl

theorem frA_other {S : Type} (A : Addr) (s0 : St S) (X : Nat → Option (List Val × List Val)) (p1 p2 : List Val)
    {a : Nat} (h1 : a ≠ A.fwd) (h2 : a ≠ A.emit) : frA A s0 X p1 p2 a = X a := by
  unfold frA; rw [Addr.beq_ne h1, Addr.beq_ne h2]; rfl

theorem frA_ne_none {S : Type} (A : Addr) (s0 : St S) (Fr : LoopFramesA A) (p1 p2 : List Val) (a : Nat) :
    frA A s0 Fr.X p1 p2 a ≠ none ↔ a ∈ A.fwd :: A.emit :: Fr.xs := by
  by_cases h1 : a = A.fwd
  · subst h1; rw [frA_fwd]; simp
  · by_cases h2 : a = A.emit
    · subst h2; rw [frA_emit]; simp
    · rw [frA_other A s0 Fr.X p1 p2 h1 h2, Fr.dom]
      simp [h1, h2]

/-! ## The template start and the loop case at `A` -/

/-- Facts about the template start (`LoopStart` at `A`). -/
structure LoopStartA (A : Addr) (P : LoadP) (s0 : St LF.S) (tab0 : List SymE) : Prop where
  tok : s0.ffi.mlx.tokens = [.ref A.tok]
  htok : A.tok < tab0.length
  big : bigsOutB s0.ffi.mlx.next P.E s0.ffi.mlx = true
  free : NoBigSt (fun i => (s0.ffi.mlx.next : Int) ≤ i ∧ i < P.E) s0.trace s0
  lo : P.lo ≤ s0.ffi.mlx.next
  hi : P.E ≤ 2 ^ 56

theorem LoopStart.toA {P : LoadP} {s0 : St LF.S} {tab0 : List SymE} (st : LoopStart P s0 tab0) :
    LoopStartA addr0 P s0 tab0 := ⟨st.tok, st.h79, st.big, st.free, st.lo, st.hi⟩

/-- **A checked loop case at `A`** (`LoopCase` without its shift, which depends on the frames:
`ShiftFWA`). -/
structure LoopCaseA (A : Addr) (ok : St LF.S → SSrv → Bool) (P : LoadP) (s0 : St LF.S) (tab0 : List SymE)
    (fixA : List Nat) where
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
  noVarTab : ∀ e ∈ S1.tab, e.noVar A.nxt = true
  noVarOr : ∀ q ∈ S1.oracle, q.noVar A.nxt = true
  nshift : NShift P tab0.length σ s0.ffi s1.ffi
  num : σ.num A.tok = .ref S1.tab.length
  hE : s1.ffi.mlx.next < P.E
  theta : ∀ j, θ j = loopTheta grow A.nxt j
  fwd : ∃ o, s1.heap.get A.fwd = some (.obj o) ∧ o.kind = .array (arrOf s0 A.fwd ++ xs)
  emit : ∃ o, s1.heap.get A.emit = some (.obj o) ∧ o.kind = .array (arrOf s0 A.emit ++ [.num (.ref A.tok)])
  fix : ∀ a ∈ fixA, σ.a a = a

/-- Today's loop cases. -/
def LoopCase.toA {ok : St LF.S → SSrv → Bool} {P : LoadP} {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat}
    (c : LoopCase ok P s0 tab0 fixA) : LoopCaseA addr0 ok P s0 tab0 fixA where
  S0 := c.S0
  n := c.n
  s1 := c.s1
  S1 := c.S1
  σ := c.σ
  θ := c.θ
  grow := c.grow
  xs := c.xs
  tab := c.tab
  ok0 := c.ok0
  run := c.run
  ctl := c.ctl
  noVarTab := c.noVarTab
  noVarOr := c.noVarOr
  nshift := c.nshift
  num := c.num79
  hE := c.hE
  theta := c.theta
  fwd := c.fwd
  emit := c.emit
  fix := c.fix

/-! ## The restart at `A` -/

/-- **`load_restart_drop` at the token reference `k` and the look-ahead variable `w`.** -/
theorem load_restart_dropA (k w : Nat) {P : LoadP} {r0 : List NumV} {M M1 : Map} {ν : Nat → F64} {K K1 : Ctx}
    {W W0 W1 : Nat → Option WFrame} {kp : Nat → Bool}
    {s0 s1 t t1 : St LF.S} {S0 S1 : SSrv} {C C1 : CSrv} {n : Nat}
    {σ : Map} {θ : Nat → SymE} {v : NumV} {r : List NumV} {x : F64}
    (h : RelF LF (LR P r0) W M ν K s0 S0 t C) (hr0 : r0 = v :: r)
    (hrc : runC LF n t C = some (t1, C1)) (hext : Ext M M1 S0.tab.length)
    (h1 : RelF LF (LR P r0) W1 M1 ν K1 s1 S1 t1 C1)
    (hKD : K1.D = K.D) (hKlo : K1.lo = K.lo) (hKhi : K1.hi = K.hi)
    (htab : ∀ e ∈ S1.tab, e.noVar w = true) (hor : ∀ q ∈ S1.oracle, q.noVar w = true)
    (hshift : ShiftD LF (FSn { P with rest := r0 } S0.tab.length s0.ffi) σ θ kp W0 K1 s0 S0 s1
      ⟨S1.tab ++ [.var w], S1.oracle⟩)
    (hW : ∀ a w, W0 a = some w → W1 a = some w)
    (hσ : σ.num k = .ref S1.tab.length) (htok : s0.ffi.mlx.tokens = [.ref k]) (hk : k < S0.tab.length)
    (hbig : bigsOutB s0.ffi.mlx.next P.E s0.ffi.mlx = true)
    (hfree : NoBigSt (fun i => (s0.ffi.mlx.next : Int) ≤ i ∧ i < P.E) s0.trace s0)
    (hband : ∀ i : Int, (s0.ffi.mlx.next : Int) ≤ i ∧ i < P.E → ¬ BigFixed K.lo K.hi i ∧ 0 ≤ i ∧ i < 2 ^ 56)
    (hx : C.val v = some x) (hE : s1.ffi.mlx.next < P.E) (hD : s1.next - s0.next + K.D < Sim.bound)
    (hroomH : t.ffi.mlx.next + (s1.ffi.mlx.next - s0.ffi.mlx.next) + (P.E - s0.ffi.mlx.next) < 2 ^ 46)
    (hroomN : t.ffi.mlx.nnext + (s1.ffi.mlx.nnext - s0.ffi.mlx.nnext) + (P.NE - s0.ffi.mlx.nnext) < 2 ^ 62) :
    t1.next = t.next + (s1.next - s0.next) ∧
      t1.ffi.mlx.next = t.ffi.mlx.next + (s1.ffi.mlx.next - s0.ffi.mlx.next) ∧
      t1.ffi.mlx.nnext = t.ffi.mlx.nnext + (s1.ffi.mlx.nnext - s0.ffi.mlx.nnext) ∧
      RelF LF (LR P r) W0
        ((((M1.setNum S1.tab.length v).after σ)).rebig s0.ffi.mlx.next P.E t1.ffi.mlx.next)
        (Shift.valuation θ (upd ν w x))
        ⟨dropNext (M1.setNum S1.tab.length v) K1 kp W0 s1, s0.trace, t1.trace, t1.next - s0.next, K.lo, K.hi⟩
        s0 ⟨S0.tab, []⟩ t1 C1 := by
  subst hr0
  have hns : NShift { P with rest := v :: r } S0.tab.length σ s0.ffi s1.ffi := hshift.ffi.2
  have hl := lockstep h.ffi h1.ffi hext rfl hns.mlx.hnext.2 hE hns.mlx.nle
  have hoff : t1.next = t.next + (s1.next - s0.next) := by
    have e1 := h1.offset; rw [hKD] at e1; have := h.offset; have := hshift.grows; omega
  have htk : t1.ffi.mlx.tokens = v :: r := by
    have := h1.ffi.mlx.tokensX
    rw [hns.mlx.tokens] at this
    simpa using this
  have hvx : C1.val v = some x := (runC_le n t C t1 C1 hrc).val hx
  have hw : LoadRw { P with rest := v :: r } (M1.setNum S1.tab.length v) (S1.tab.length + 1)
      (clearTokens s1.ffi) t1.ffi := by
    rw [clearTokens_nil hns.mlx.tokens]
    exact (((loadR_laws _).stable _ _ _ _ _ h1.ffi (Map.setNum_ext M1 S1.tab.length v)).mono
      (Nat.le_succ _)).weak
  have hroom : t1.next - s0.next < Sim.bound := by
    rw [hoff]; have := h.offset; have := hshift.grows; omega
  have hf : FRr { P with rest := v :: r } s0.ffi (M1.setNum S1.tab.length v) (S1.tab.length + 1) s1.ffi t1.ffi := by
    refine ⟨hw, ?_, ?_⟩
    · show t1.ffi.mlx.next + (P.E - s0.ffi.mlx.next) < 2 ^ 46
      rw [hl.1]; omega
    · show t1.ffi.mlx.nnext + (P.NE - s0.ffi.mlx.nnext) < 2 ^ 62
      rw [hl.2]; omega
  have h2 := (h1.extendVar' (loadR_laws _) htab hor hvx).mapFR' (FR' := FRr { P with rest := v :: r } s0.ffi)
    (by simpa using hf)
  have hrel := restartDrop (F := LF) (FR := FRr { P with rest := v :: r } s0.ffi)
    (FS := FSn { P with rest := v :: r } S0.tab.length s0.ffi)
    (fun x y z hxy hyz => by simpa using fsn_compose _ x y z hxy (by simpa using hyz)) h2
    (hshift.withOracle []) hW (fun _ hq => by cases hq) hroom
  rw [hKlo, hKhi] at hrel
  refine ⟨hoff, hl.1, hl.2, ?_⟩
  have hw0 := hrel.ffi.1
  have hz : t1.ffi.mlx.tokens = s0.ffi.mlx.tokens.map ((M1.setNum S1.tab.length v).after σ).nv ++ r := by
    rw [htk, htok]
    simp only [List.map_cons, List.map_nil, List.cons_append, List.nil_append, Map.nv]
    show v :: r = (M1.setNum S1.tab.length v).nv (σ.num k) :: r
    rw [hσ]
    simp [Map.nv, Map.setNum_self]
  have hffi := LoadRw.rebig hw0 hbig (fun t ht => by rw [htok] at ht; simp at ht; subst ht; exact hk) hz
  rw [Map.rebig_eq] at hffi ⊢
  exact hrel.rebig (fun i hi => by simp [hi]) (fun i hi => hband i hi) hfree hffi

/-! ## The invariant at `A` -/

/-- **The loop invariant at iteration `i`** over the driver's constants `A` (`LoopInvF`). -/
def LoopInvA (A : Addr) (Gx : Nat → Map → St LF.S → CSrv → Prop) (R : LoopR) (P : LoadP) (Fr : LoopFramesA A)
    (s0 : St LF.S) (tab0 : List SymE) (fixA : List Nat) (V : LoopVals) (tk : Nat → Nat) (toks : List NumV)
    (E0 : List Val) (B : LoopBase) (ΔJ ΔH ΔN : Nat) (i : Nat) (t : St LF.S) (C : CSrv) : Prop :=
  ∃ M K nx p1, R (toks.drop i) M (V i nx) K s0 ⟨tab0, []⟩ t C ∧
    K.fr = frA A s0 Fr.X p1 (E0 ++ (toks.take (i - 1)).map Val.num) ∧ K.lo = P.lo ∧ K.hi = P.E ∧
    K.base = s0.trace ∧ toks[i - 1]? = some (M.num A.tok) ∧ nx ≤ 2 ^ 20 ∧
    (∀ j (hj : j < toks.length), C.val toks[j] = some (F64.ofNat (tk (j + 2)))) ∧
    K.D ≤ (i - 1) * ΔJ + B.D ∧ t.ffi.mlx.next ≤ s0.ffi.mlx.next + (i - 1) * ΔH + B.H ∧
    t.ffi.mlx.nnext ≤ s0.ffi.mlx.nnext + (i - 1) * ΔN + B.N ∧ (∀ a ∈ fixA, M.a a = a) ∧ Gx i M t C

/-- **At today's constants `LoopInvA` is `LoopInvF`.** -/
theorem LoopInvA_addr0 {Gx : Nat → Map → St LF.S → CSrv → Prop} {R : LoopR} {P : LoadP} {Fr : LoopFrames}
    {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat} {V : LoopVals} {tk : Nat → Nat} {toks : List NumV}
    {E0 : List Val} {B : LoopBase} {ΔJ ΔH ΔN i : Nat} {t : St LF.S} {C : CSrv} :
    LoopInvA addr0 Gx R P Fr.toA s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN i t C ↔
      LoopInvF Gx R P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN i t C := Iff.rfl

section Case
variable {A : Addr} {ok : St LF.S → SSrv → Bool} {P : LoadP} {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat}

/-- `LoopGStepF` at `A`. -/
def LoopGStepA (Gx : Nat → Map → St LF.S → CSrv → Prop) (R : LoopR) (Fr : LoopFramesA A)
    (c : LoopCaseA A ok P s0 tab0 fixA) (V : LoopVals) (toks : List NumV) (i : Nat) : Prop :=
  ∀ (hlen : i < toks.length) (nx : Nat) (M : Map) (K : Ctx) (t : St LF.S) (C : CSrv) (M1 : Map) (t1 : St LF.S)
    (C1 : CSrv), Gx i M t C →
    R (toks.drop i) M (V i nx) K s0 ⟨tab0, []⟩ t C →
    (∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Fr.xs) → K.lo = P.lo → K.hi = P.E →
    runC LF c.n t C = some (t1, C1) → Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx → Ext M M1 c.S0.tab.length →
    R (toks.drop i) M1 (V i nx) K c.s1 c.S1 t1 C1 →
    Gx (i + 1) (((M1.setNum c.S1.tab.length toks[i]).after c.σ).rebig s0.ffi.mlx.next P.E t1.ffi.mlx.next) t1 C1

theorem LoopGStepA_addr0 {Gx : Nat → Map → St LF.S → CSrv → Prop} {R : LoopR} {Fr : LoopFrames}
    (c : LoopCase ok P s0 tab0 fixA) (V : LoopVals) (toks : List NumV) (i : Nat) :
    LoopGStepA Gx R Fr.toA c.toA V toks i ↔ LoopGStepF Gx R Fr c V toks i := Iff.rfl

/-- **A loop case's iteration** at `A` (`LoopCase.IterF`). -/
def LoopCaseA.IterFA (R : LoopR) (Fr : LoopFramesA A) (VBOk : (Nat → F64) → Prop) (c : LoopCaseA A ok P s0 tab0 fixA) :
    Prop :=
  ∀ (r : List NumV) (v : NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (t : St LF.S) (C : CSrv) (x : F64)
    (p1 p2 : List Val), VBOk ν → K.fr = frA A s0 Fr.X p1 p2 → K.lo = P.lo → K.hi = P.E →
    R (v :: r) M ν K s0 c.S0 t C → C.val v = some x →
    c.s1.next - s0.next + K.D < Sim.bound →
    t.ffi.mlx.next + (c.s1.ffi.mlx.next - s0.ffi.mlx.next) + (P.E - s0.ffi.mlx.next) < 2 ^ 46 →
    t.ffi.mlx.nnext + (c.s1.ffi.mlx.nnext - s0.ffi.mlx.nnext) + (P.NE - s0.ffi.mlx.nnext) < 2 ^ 62 →
    ∃ M1 t1 C1, runC LF c.n t C = some (t1, C1) ∧ Ext M M1 c.S0.tab.length ∧
      t1.next = t.next + (c.s1.next - s0.next) ∧
      t1.ffi.mlx.next = t.ffi.mlx.next + (c.s1.ffi.mlx.next - s0.ffi.mlx.next) ∧
      t1.ffi.mlx.nnext = t.ffi.mlx.nnext + (c.s1.ffi.mlx.nnext - s0.ffi.mlx.nnext) ∧
      R r (((M1.setNum c.S1.tab.length v).after c.σ).rebig s0.ffi.mlx.next P.E t1.ffi.mlx.next)
        (Shift.valuation c.θ (upd ν A.nxt x))
        ⟨Shift.framedNext (M1.setNum c.S1.tab.length v) K c.s1, s0.trace, t1.trace, t1.next - s0.next, K.lo, K.hi⟩
        s0 ⟨tab0, []⟩ t1 C1 ∧
      R (v :: r) M1 ν K c.s1 c.S1 t1 C1 ∧ Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx

theorem IterFA_addr0 {R : LoopR} {Fr : LoopFrames} {VBOk : (Nat → F64) → Prop} (c : LoopCase ok P s0 tab0 fixA) :
    c.toA.IterFA R Fr.toA VBOk ↔ c.IterF R Fr VBOk := Iff.rfl

/-- The case's end keeps the further frames (`LoopCase.Keeps`). -/
def LoopCaseA.KeepsA (c : LoopCaseA A ok P s0 tab0 fixA) (Fr : LoopFramesA A) : Prop :=
  ∀ a pre pre', Fr.X a = some (pre, pre') → ∀ o es, c.s1.heap.get a = some (.obj o) → o.kind = .array es →
    es.drop pre.length = []

theorem KeepsA_addr0 {Fr : LoopFrames} (c : LoopCase ok P s0 tab0 fixA) : c.toA.KeepsA Fr.toA ↔ c.Keeps Fr :=
  Iff.rfl

/-- **The case's shift under the frames** at `A` (`LoopCase.ShiftFW`). -/
def LoopCaseA.ShiftFWA (c : LoopCaseA A ok P s0 tab0 fixA) (Fr : LoopFramesA A) (W : Nat → Option WFrame) : Prop :=
  (∀ (p1 p2 : List Val) (K : Ctx), K.fr = frA A s0 Fr.X p1 p2 → K.lo = P.lo → K.hi = P.E →
    ShiftJS LF c.σ c.θ (K.unW W) s0 c.S0 c.s1 ⟨c.S1.tab ++ [.var A.nxt], c.S1.oracle⟩) ∧
  ∀ a w, W a = some w → a ∈ Fr.xs ∧ c.σ.a a = a ∧ Present s0 a ∧ WFix c.σ (Present s0) w

theorem ShiftFWA_addr0 {Fr : LoopFrames} {W : Nat → Option WFrame} (c : LoopCase ok P s0 tab0 fixA) :
    c.toA.ShiftFWA Fr.toA W ↔ c.ShiftFW Fr W := Iff.rfl

/-- **The load world's iteration under the frames `W`** at `A` (`LoopCase.iterF_relF`). -/
theorem LoopCaseA.iterF_relFA {jsP : Disp.JSP LF} {VBOk : (Nat → F64) → Prop} (Fr : LoopFramesA A)
    (W : Nat → Option WFrame) (hsim : ∀ r, Disp.StepSimXVW LF (LR P r) ok (Disp.Kp jsP) W VBOk)
    (hjlo : jsP.lo = P.lo) (hjhi : jsP.hi = P.E) (hjfr : ∀ a, a ∈ jsP.framed ↔ a ∈ A.fwd :: A.emit :: Fr.xs)
    (hng : ∀ (r : List NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (n : Nat) (s t s1 t1 : St LF.S) (S S1 : SSrv)
      (C C1 : CSrv), Disp.Kp jsP K → VBOk ν → RelF LF (LR P r) W M ν K s S t C → ok s S = true →
      runOk LF ok n s S = some (s1, S1) → runC LF n t C = some (t1, C1) → Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx)
    (st : LoopStartA A P s0 tab0) (c : LoopCaseA A ok P s0 tab0 fixA) (hsh : c.ShiftFWA Fr W) :
    c.IterFA (relLW P W) Fr VBOk := by
  intro r v M ν K t C x p1 p2 hν hfr hlo hhi h hx hD hroomH hroomN
  have hK : Disp.Kp jsP K := ⟨hlo.trans hjlo.symm, hhi.trans hjhi.symm, fun a => by
    rw [hjfr, hfr]; exact frA_ne_none A s0 Fr p1 p2 a⟩
  obtain ⟨M1, t1, C1, hrc, he, hx1⟩ := Disp.runOk_simXVW LF (LR P (v :: r)) ok (Disp.Kp jsP) W VBOk
    (hsim (v :: r)) ν K hK hν c.n M s0 c.S0 t C c.s1 c.S1 (Or.inl h) c.ok0 c.run
  have h1 := hx1.rel c.ctl
  have hshift := ShiftD.ofJS (K1 := K) (FS := FSn { P with rest := v :: r } c.S0.tab.length s0.ffi)
    (hsh.1 p1 p2 K hfr hlo hhi) ⟨rfl, by rw [c.tab]; exact c.nshift.withRest _⟩
    (fun a w hw => by
      obtain ⟨hxs, hfix, hp, hwf⟩ := hsh.2 a w hw
      refine ⟨?_, hfix, hp, hwf⟩
      rw [hfr]
      exact (frA_ne_none A s0 Fr p1 p2 a).2 (List.mem_cons_of_mem _ (List.mem_cons_of_mem _ hxs)))
    (fun _ _ => rfl) (fun _ ha hn => absurd hn ha) rfl rfl
  have hband : ∀ j : Int, (s0.ffi.mlx.next : Int) ≤ j ∧ j < P.E → ¬ BigFixed K.lo K.hi j ∧ 0 ≤ j ∧ j < 2 ^ 56 := by
    intro j hj
    have := st.lo; have := st.hi
    rw [hlo, hhi]
    refine ⟨fun hf => ?_, by omega, by omega⟩
    unfold BigFixed at hf
    omega
  obtain ⟨hoff, hH1, hN1, hrel⟩ := load_restart_dropA A.tok A.nxt h rfl hrc he h1 rfl rfl rfl c.noVarTab c.noVarOr
    hshift (fun _ _ hw => hw) c.num st.tok (by rw [c.tab]; exact st.htok) st.big st.free hband hx c.hE hD hroomH
    hroomN
  rw [dropNext_keep h1, c.tab] at hrel
  exact ⟨M1, t1, C1, hrc, he, hoff, hH1, hN1, hrel, h1, hng _ _ _ _ _ _ _ _ _ _ _ _ _ hK hν h c.ok0 c.run hrc⟩

/-- After an iteration the frames are the template's prefixes with the target prefixes of
`forwarded` and `emitted` extended; the further frames are kept (`framedNext_frX`). -/
theorem framedNext_frA {M : Map} {K : Ctx} {Fr : LoopFramesA A} {p1 p2 : List Val}
    (c : LoopCaseA A ok P s0 tab0 fixA) (hfr : K.fr = frA A s0 Fr.X p1 p2) (hk : c.KeepsA Fr) :
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

/-- **One loop iteration preserves the invariant** at `A` (`loop_stepF`). -/
theorem loop_stepA {A : Addr} {Gx : Nat → Map → St LF.S → CSrv → Prop} {R : LoopR} (hR : LoopRel R)
    {ok : St LF.S → SSrv → Bool} {P : LoadP} {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat}
    {VBOk : (Nat → F64) → Prop} (Fr : LoopFramesA A) (st : LoopStartA A P s0 tab0)
    (c : LoopCaseA A ok P s0 tab0 fixA) (hit : c.IterFA R Fr VBOk) (hkeep : c.KeepsA Fr)
    {V : LoopVals} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {B : LoopBase} {ΔJ ΔH ΔN : Nat}
    {i : Nat} {t : St LF.S} {C : CSrv}
    (hinv : LoopInvA A Gx R P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN i t C) (hi1 : 1 ≤ i) (hlen : i < toks.length)
    (hgood : ∀ nx, Good (V i nx) c.S0.oracle)
    (hVB : ∀ nx, nx ≤ 2 ^ 20 → VBOk (V i nx))
    (hnext : ∀ nx, Shift.valuation c.θ (upd (V i nx) A.nxt (F64.ofNat (tk (i + 2)))) = V (i + 1) (tk (i + 2)))
    (htk : tk (i + 2) ≤ 2 ^ 20)
    (hdJ : c.s1.next - s0.next ≤ ΔJ) (hdH : c.s1.ffi.mlx.next - s0.ffi.mlx.next ≤ ΔH)
    (hdN : c.s1.ffi.mlx.nnext - s0.ffi.mlx.nnext ≤ ΔN)
    (hJ : i * ΔJ + B.D < Sim.bound) (hH : s0.ffi.mlx.next + i * ΔH + B.H + (P.E - s0.ffi.mlx.next) < 2 ^ 46)
    (hN : s0.ffi.mlx.nnext + i * ΔN + B.N + (P.NE - s0.ffi.mlx.nnext) < 2 ^ 62)
    (hG : LoopGStepA Gx R Fr c V toks i) :
    ∃ t' C', runC LF c.n t C = some (t', C') ∧ LoopInvA A Gx R P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN (i + 1) t' C' := by
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
    have := interpS_runOk_len c.run; rw [c.tab] at this; have := st.htok; omega
  have hM79 : (M1.setNum c.S1.tab.length toks[i]).num A.tok = M.num A.tok := by
    rw [(Map.setNum_ext M1 c.S1.tab.length toks[i]).num A.tok hlen1]
    exact he.num A.tok (by rw [c.tab]; exact st.htok)
  refine ⟨t1, C1, hrc, (((M1.setNum c.S1.tab.length toks[i]).after c.σ).rebig s0.ffi.mlx.next P.E t1.ffi.mlx.next),
    ⟨Shift.framedNext (M1.setNum c.S1.tab.length toks[i]) K c.s1, s0.trace, t1.trace, t1.next - s0.next, K.lo, K.hi⟩,
    tk (i + 2), p1 ++ (M1.setNum c.S1.tab.length toks[i]).vals c.xs,
    ?_, ?_, hlo, hhi, rfl, ?_, htk, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · rw [hnext nx] at hrel
    exact hrel
  · show Shift.framedNext (M1.setNum c.S1.tab.length toks[i]) K c.s1 = _
    rw [framedNext_frA c hfr hkeep]
    congr 1
    have hnv : (M1.setNum c.S1.tab.length toks[i]).nv (.ref A.tok) = toks[i - 1] := by
      show (M1.setNum c.S1.tab.length toks[i]).num A.tok = _
      rw [hM79]
      have := h79; rw [List.getElem?_eq_getElem (by omega)] at this
      exact (Option.some.inj this).symm
    rw [hnv, show i + 1 - 1 = (i - 1) + 1 by omega, ← take_map_succ toks (i - 1) (by omega), List.append_assoc]
  · show toks[i + 1 - 1]? = some ((((M1.setNum c.S1.tab.length toks[i]).after c.σ).rebig _ _ _).num A.tok)
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
