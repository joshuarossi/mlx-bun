import host.sim.compose.Shape
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

/-! # The checked steps of the prefill chain from its classes' steps

`PrefStepsPW` (`host.sim.world.Book`, the chain up to the prefill loop's exit `ps`; POST is a route
piece, `host.sim.compose.RouteBundle`) asks a cut step for every class at every length of the range
`1 ≤ L ≤ 262143` (`|π| + T ≤ 262144`, `T ≥ 1`) where the class applies. `ClassSteps I` is the classes'
steps (`SetupS` … `FinalS`, one per class of `PrefillSched`'s lists, with its step count);
`ClassSteps.toPrefSteps` is that `PrefStepsPW`, and `ClassSteps.reach` the prefill from the loadDone
cut to the exit cut at every `L` of the range. `RouteS`: a route position's step from the exit cut
(POST, a short path's prefix) at the run's budget and tokens.

`*S_of_rows`: a class's step from its rows: the class's cover (`<class>.cover`,
`host.sim.lin.Cover`, `host.sim.lin.CoverR`) gives the row of each step, and each row's pieces the
step there. -/

section
variable {F : Ffi} (I : PrefInvsW F)

/-! ## A class's step -/

def SetupS (c : SetupClass) (n : Nat) : Prop :=
  ∀ L, 1 ≤ L → L ≤ 262143 → c.Applies L → CutStep (I.ld L) (I.pc0 L) n

def FirstDrainS (C n : Nat) : Prop :=
  ∀ L, 1 ≤ L → L ≤ 262143 → (FirstClass.drain C).Applies L → CutStep (I.pc0 L) (I.pc L 1) n

def FirstTailS (X n : Nat) : Prop :=
  ∀ L, 1 ≤ L → L ≤ 262143 → (FirstClass.tail X).Applies L → CutStep (I.pc0 L) (I.pf L) n

def DrainS (d : DrainClass) (n : Nat) : Prop :=
  ∀ L j, 1 ≤ L → L ≤ 262143 → d.Applies L j → CutStep (I.pc L j) (I.pc L (j + 1)) n

def TailS (c : TailClass) (n : Nat) : Prop :=
  ∀ L, 1 ≤ L → L ≤ 262143 → c.Applies L → CutStep (I.pc L (drains L)) (I.pf L) n

def FinalS (src : PFSrc) (c : FinalClass) (n : Nat) : Prop :=
  ∀ L, 1 ≤ L → L ≤ 262143 → c.Applies L → pfSrcOf L = src → CutStep (I.pre L src) (I.ps L) n

/-- A route position `k` of the run at budget `T` with tokens `tk` (POST to the decode cut, a short
budget's path prefix to its cut): from the exit cut to `cut` of the step at every length of the post
class where `k`'s facts hold. -/
def RouteS (T : Nat) (tk : Nat → Nat) (k : RouteKind) (cut : Cls.Inst → ICut F) (c : PostClass) (n : Nat) : Prop :=
  ∀ L, 1 ≤ L → L ≤ 262143 → k.Holds L T (tk 1) (tk 2) → c.Applies L →
    CutStep (I.ps L) (cut (routeI L T (tk 1) (tk 2))) n

variable {I}

/-! ## From the rows -/

theorem setupS_of_rows {c : SetupClass} {rows : List Row} {n : Nat} (hcov : SetupP c rows)
    (h : ∀ r ∈ rows, ∀ L, 1 ≤ L → L ≤ 262143 → c.Applies L → InRow r (setupI L) → CutStep (I.ld L) (I.pc0 L) n) :
    SetupS I c n := fun L h1 h2 ha => let ⟨r, hr, hi⟩ := hcov L h1 h2 ha; h r hr L h1 h2 ha hi

theorem firstDrainS_of_rows {C : Nat} {rows : List Row} {n : Nat} (hcov : FirstP (.drain C) rows)
    (h : ∀ r ∈ rows, ∀ L, 1 ≤ L → L ≤ 262143 → (FirstClass.drain C).Applies L → InRow r (firstI L) →
      CutStep (I.pc0 L) (I.pc L 1) n) : FirstDrainS I C n :=
  fun L h1 h2 ha => let ⟨r, hr, hi⟩ := hcov L h1 h2 ha; h r hr L h1 h2 ha hi

theorem firstTailS_of_rows {X : Nat} {rows : List Row} {n : Nat} (hcov : FirstP (.tail X) rows)
    (h : ∀ r ∈ rows, ∀ L, 1 ≤ L → L ≤ 262143 → (FirstClass.tail X).Applies L → InRow r (firstI L) →
      CutStep (I.pc0 L) (I.pf L) n) : FirstTailS I X n :=
  fun L h1 h2 ha => let ⟨r, hr, hi⟩ := hcov L h1 h2 ha; h r hr L h1 h2 ha hi

theorem drainS_of_rows {d : DrainClass} {rows : List Row} {n : Nat} (hcov : DrainP d rows)
    (h : ∀ r ∈ rows, ∀ L j, 1 ≤ L → L ≤ 262143 → d.Applies L j → InRow r (drainI L j) →
      CutStep (I.pc L j) (I.pc L (j + 1)) n) : DrainS I d n :=
  fun L j h1 h2 ha => let ⟨r, hr, hi⟩ := hcov L j h1 h2 ha; h r hr L j h1 h2 ha hi

theorem tailS_of_rows {c : TailClass} {rows : List Row} {n : Nat} (hcov : TailP c rows)
    (h : ∀ r ∈ rows, ∀ L, 1 ≤ L → L ≤ 262143 → c.Applies L → InRow r (tailI L) →
      CutStep (I.pc L (drains L)) (I.pf L) n) : TailS I c n :=
  fun L h1 h2 ha => let ⟨r, hr, hi⟩ := hcov L h1 h2 ha; h r hr L h1 h2 ha hi

theorem finalS_of_rows {src : PFSrc} {c : FinalClass} {rows : List Row} {n : Nat} (hcov : FinalP c rows)
    (h : ∀ r ∈ rows, ∀ L, 1 ≤ L → L ≤ 262143 → c.Applies L → pfSrcOf L = src → InRow r (finalI L) →
      CutStep (I.pre L src) (I.ps L) n) : FinalS I src c n :=
  fun L h1 h2 ha hs => let ⟨r, hr, hi⟩ := hcov L h1 h2 ha; h r hr L h1 h2 ha hs hi

theorem routeS_of_rows {T : Nat} {tk : Nat → Nat} {k : RouteKind} {cut : Cls.Inst → ICut F} {c : PostClass}
    {rows : List Row} {n : Nat} (hcov : RouteP k c rows)
    (h : ∀ r ∈ rows, ∀ L, 1 ≤ L → L ≤ 262143 → k.Holds L T (tk 1) (tk 2) → c.Applies L →
      InRow r (routeI L T (tk 1) (tk 2)) → RunAt T tk (routeI L T (tk 1) (tk 2)) →
      CutStep (I.ps L) (cut (routeI L T (tk 1) (tk 2))) n) :
    RouteS I T tk k cut c n := fun L h1 h2 hq ha =>
  let ⟨r, hr, hi⟩ := hcov L T (tk 1) (tk 2) h1 h2 hq ha
  h r hr L h1 h2 hq ha hi ⟨rfl, rfl, rfl, RouteKind.ctx hq⟩

/-- The cold class only follows the first call. -/
theorem FinalS.cold_of_ne {src : PFSrc} (hs : src ≠ .first) (n : Nat) : FinalS I src .cold n := by
  intro L _ _ ha he
  simp only [FinalClass.Applies] at ha
  subst ha
  exact absurd (he.symm.trans (by simp [pfSrcOf])) hs

/-- A warm class never follows the first call. -/
theorem FinalS.warm_first (kv : KvBranch) (n : Nat) : FinalS I .first (.warm kv) n := by
  intro L _ _ ha he
  obtain ⟨hL, -⟩ := ha
  unfold pfSrcOf at he
  split at he
  · omega
  · split at he <;> cases he

/-! ## All classes -/

/-- A class's count in a table of counts (`0` off the table). -/
def countOf {α : Type} [DecidableEq α] : List (α × Nat) → α → Nat
  | [], _ => 0
  | (a, n) :: t, c => if a = c then n else countOf t c

theorem all_cons' {α : Type} {P : α → Prop} {a : α} {l : List α} (h : P a) (t : ∀ x ∈ l, P x) : ∀ x ∈ a :: l, P x :=
  List.forall_mem_cons.2 ⟨h, t⟩

theorem all_nil' {α : Type} {P : α → Prop} : ∀ x ∈ ([] : List α), P x := fun _ h => nomatch h

variable (I)

/-- **The classes' steps**: one per class of `PrefillSched`'s lists, at every length of the range. -/
structure ClassSteps where
  nSetup : SetupClass → Nat
  setup : ∀ c ∈ setupClasses, SetupS I c (nSetup c)
  nFirstDrain : Nat → Nat
  firstDrain : ∀ C ∈ chunkSizes, FirstDrainS I C (nFirstDrain C)
  nFirstTail : Nat → Nat
  firstTail : ∀ X ∈ List.range 37, FirstTailS I X (nFirstTail X)
  nDrain : DrainClass → Nat
  drain : ∀ d ∈ drainClasses, DrainS I d (nDrain d)
  nTail : TailClass → Nat
  tail : ∀ c ∈ tailClasses, TailS I c (nTail c)
  nFinal : PFSrc → FinalClass → Nat
  final : ∀ c ∈ finalClasses, ∀ src, FinalS I src c (nFinal src c)

variable {I}

theorem firstTail_mem {X L : Nat} (ha : (FirstClass.tail X).Applies L) : X ∈ List.range 37 := by
  obtain ⟨-, -, b, hb, -, -⟩ := ha
  rw [List.mem_range, ← rowBands_length]
  exact (List.getElem?_eq_some_iff.mp hb).1

/-- **The `PrefStepsPW` of the classes' steps.** -/
def ClassSteps.toPrefSteps (S : ClassSteps I) : PrefStepsPW I where
  nSetup := S.nSetup
  setup c L h1 h2 ha := by
    have hc := setup_cover h1 (by omega)
    exact S.setup c (by rw [hc.2.2 c ha]; exact hc.1) L h1 h2 ha
  nFirst c := match c with
    | .drain C => S.nFirstDrain C
    | .tail X => S.nFirstTail X
    | .final => 0
  firstDrain C L h1 h2 ha := S.firstDrain C (by rw [ha.1]; exact chunkC_mem (by omega)) L h1 h2 ha
  firstTail X L h1 h2 ha := S.firstTail X (firstTail_mem ha) L h1 h2 ha
  nDrain := S.nDrain
  drain d L j h1 h2 ha := by
    have hC := ha.1
    have hj := ha.2.1
    have hle := ha.2.2.1
    have h64 := chunkC_range (L := L) (by omega)
    have hk : j + 1 ≤ drains L := by
      unfold drains
      rw [← hC]
      exact (Nat.le_div_iff_mul_le (by rw [hC]; omega)).mpr hle
    have hc := drain_cover (L := L) (by omega) hj hk
    exact S.drain d (by rw [hc.2.2 d ha]; exact hc.1) L j h1 h2 ha
  nTail := S.nTail
  tail c L h1 h2 ha := by
    have hc := tail_cover (L := L) (by omega) ha.2.1 ha.2.2.1
    exact S.tail c (by rw [hc.2.2 c ha]; exact hc.1) L h1 h2 ha
  nFinal := S.nFinal
  final c L h1 h2 ha := by
    have hc := final_cover (L := L) h1
    exact S.final c (by rw [hc.2.2 c ha]; exact hc.1) (pfSrcOf L) L h1 h2 ha rfl

/-- **The prefill from the loadDone cut to its exit cut**, at every length of the range, from the
classes' steps. -/
theorem ClassSteps.reach (S : ClassSteps I) {L : Nat} (h1 : 1 ≤ L) (h2 : L ≤ 262143) :
    CutStep (I.ld L) (I.ps L) (S.toPrefSteps.n L) :=
  prefill_reach_psW S.toPrefSteps h1 h2

end

end Host.Ts.Sim.Compose
