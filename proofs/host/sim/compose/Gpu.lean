import host.sim.compose.ClassR
import host.sim.compose.RouteStepsR
import host.sim.compose.Loop
set_option maxRecDepth 100000
set_option autoImplicit false
namespace Host.Ts.Sim.Compose.Gpu
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls

/-! # The prompts with no Neural Engine forward: `L ≤ 224`

The schedule below 225 tokens: chunk 2048, no drains, the tail's row class among the 22 GPU bands, the KV branches
ordinary and the post class `other`. `I.clip` is the prefill's invariants with the cuts before the exit empty above
224, and `ClassStepsR.toPrefSteps` the whole of `PrefStepsPW` at it from the classes those prompts reach: every other
class's step starts at an empty cut or cannot apply. `route_of_stepsFramedAt` (`host.sim.compose.MainGpu`) assembles
the route from it.

The decode cases `clearFill` and `clearGrow` are never selected: at `i ≡ 0 (mod 256)` the offset `L + i + 1` is
`≡ L + 1`, which is neither `0` nor `255` for `L ≤ 224`, at every iteration and so every budget
(`clearFill_not`, `clearGrow_not`). `casesOfFour` fills them from `clear` and `grow`. -/

section Sched

theorem chunkC_short {L : Nat} (h : L ≤ 224) : chunkC L = 2048 := by
  rw [← setup_chunk (L := L) (by omega)]
  unfold setupOf
  (repeat' split) <;> first | rfl | omega

theorem drains_short {L : Nat} (h : L ≤ 224) : drains L = 0 := by
  unfold drains
  rw [chunkC_short h]
  exact Nat.div_eq_of_lt (by omega)

theorem tailRows_short {L : Nat} (h : L ≤ 224) : tailRows L = L - 1 := by
  unfold tailRows
  rw [chunkC_short h]
  exact Nat.mod_eq_of_lt (by omega)

theorem kvOf_short {o : Nat} (h1 : 1 ≤ o) (h2 : o ≤ 223) : kvOf o = .ord := by
  unfold kvOf
  rw [Nat.mod_eq_of_lt (by omega : o < 256), if_neg (by omega), if_neg (by omega)]

/-- **The post class** below 225 tokens. -/
theorem other_short {L : Nat} (h1 : 1 ≤ L) (h2 : L ≤ 224) : PostClass.other.Applies L := by
  unfold PostClass.Applies postOf
  rw [Nat.mod_eq_of_lt (by omega : L < 256), if_neg (by omega), if_neg (by omega), if_neg (by omega)]

/-- A tail of at most 223 rows is in one of the 22 GPU bands. -/
theorem rowMem_short {X t : Nat} (h : RowMem X t) (ht : t ≤ 223) : X ∈ List.range 22 := by
  obtain ⟨b, hb, h1, -⟩ := h
  have hX : X < 37 := by
    rw [← rowBands_length]
    exact (List.getElem?_eq_some_iff.mp hb).1
  rw [List.mem_range]
  by_contra hge
  have h22 : 22 ≤ X := by omega
  have hb2 : 224 ≤ b.1 := by
    have key : ∀ X, X < 37 → 22 ≤ X → ∀ c, rowBands[X]? = some c → 224 ≤ c.1 := by
      intro X h1 h2 c hc
      have hall : (rowBands.drop 22).all (fun c => decide (224 ≤ c.1)) = true := by decide
      have hmem : c ∈ rowBands.drop 22 := by
        have hd : (rowBands.drop 22)[X - 22]? = some c := by
          rw [List.getElem?_drop, show 22 + (X - 22) = X by omega]
          exact hc
        exact List.mem_of_getElem? hd
      exact of_decide_eq_true (List.all_eq_true.mp hall c hmem)
    exact key X hX h22 b hb
  omega

end Sched

section Clip
variable {F : Ffi}

/-- The cut `c` with no state in it. -/
def emptyCut (c : ICut F) : ICut F := { c with B := fun _ => False }

theorem CutStep.of_empty {c J : ICut F} {n : Nat} : CutStep (emptyCut c) J n := by
  rintro t C ⟨_, _, _, _, h⟩
  exact h.elim

/-- The cut `c` below 225 tokens, empty above. -/
def clipCut (L : Nat) (c : ICut F) : ICut F := if L ≤ 224 then c else emptyCut c

theorem clipCut_le {L : Nat} {c : ICut F} (h : L ≤ 224) : clipCut L c = c := if_pos h

theorem CutStep.of_clip {L n : Nat} {c J : ICut F} (h : ¬ L ≤ 224) : CutStep (clipCut L c) J n := by
  unfold clipCut
  rw [if_neg h]
  exact CutStep.of_empty

/-- **The prefill's invariants at the prompts with no Neural Engine forward.** The exit and decode cuts stay. -/
def _root_.Host.Ts.Sim.Prefill.PrefInvsW.clip (I : PrefInvsW F) : PrefInvsW F where
  ld L := clipCut L (I.ld L)
  pc0 L := clipCut L (I.pc0 L)
  pc L j := clipCut L (I.pc L j)
  pf L := clipCut L (I.pf L)
  ps := I.ps
  dec := I.dec

theorem clip_ld (I : PrefInvsW F) {L : Nat} (h : L ≤ 224) : I.clip.ld L = I.ld L := clipCut_le h

variable {I : PrefInvsW F}

/-- **The whole prefill chain up to its exit** at the clipped invariants, from the classes those prompts reach. -/
def ClassStepsR.toPrefSteps (S : ClassStepsR I) : PrefStepsPW I.clip where
  nSetup := S.nSetup
  setup c L h1 h2 ha := by
    by_cases hL : L ≤ 224
    · have hm : c ∈ ([.early, .h0] : List SetupClass) := by
        cases c <;> simp only [SetupClass.Applies] at ha <;> first | simp | omega
      exact (S.setup c hm L h1 h2 ha).cast (clipCut_le hL) (clipCut_le hL) rfl
    · exact CutStep.of_clip hL
  nFirst c := match c with
    | .tail X => S.nFirstTail X
    | _ => 0
  firstDrain C L h1 h2 ha := by
    by_cases hL : L ≤ 224
    · have := drains_short hL
      have := ha.2
      omega
    · exact CutStep.of_clip hL
  firstTail X L h1 h2 ha := by
    by_cases hL : L ≤ 224
    · exact (S.firstTail X (rowMem_short ha.2.2 (by omega)) L h1 h2 ha).cast (clipCut_le hL) (clipCut_le hL) rfl
    · exact CutStep.of_clip hL
  nDrain _ := 0
  drain d L j h1 h2 ha := by
    by_cases hL : L ≤ 224
    · obtain ⟨hC, hj, hle, -⟩ := ha
      rw [hC, chunkC_short hL] at hle
      have : 2048 ≤ (j + 1) * 2048 := Nat.le_mul_of_pos_left _ (by omega)
      omega
    · exact CutStep.of_clip hL
  nTail _ := 0
  tail c L h1 h2 ha := by
    by_cases hL : L ≤ 224
    · have := drains_short hL
      have := ha.2.1
      omega
    · exact CutStep.of_clip hL
  nFinal src _ := match src with
    | .first => S.nCold
    | _ => S.nOrd
  final c L h1 h2 ha := by
    by_cases hL : L ≤ 224
    · cases c with
      | cold =>
        have hL1 : L = 1 := ha
        subst hL1
        exact S.finalCold 1 h1 h2 rfl (by simp [pfSrcOf])
      | warm kv =>
        obtain ⟨h2L, hkv⟩ := ha
        have hsrc : pfSrcOf L = .tailed := by
          unfold pfSrcOf
          rw [if_neg (by omega), if_neg (by rw [tailRows_short hL]; omega)]
        rw [kvOf_short (by omega) (by omega)] at hkv
        subst hkv
        rw [hsrc]
        exact (S.finalOrd L h1 h2 ⟨h2L, (kvOf_short (by omega) (by omega)).symm⟩ hsrc).cast (clipCut_le hL) rfl rfl
    · generalize pfSrcOf L = src
      cases src <;> exact CutStep.of_clip hL

end Clip

section Dec

/-- The case `clearFill` is at `L ≡ 254 (mod 256)`, at every iteration. -/
theorem clearFill_not {L i : Nat} (hL : L ≤ 224) : ¬ DecKind.clearFill.Holds L i := by
  simp only [DecKind.Holds]
  omega

/-- The case `clearGrow` is at `L ≡ 255 (mod 256)`, at every iteration. -/
theorem clearGrow_not {L i : Nat} (hL : L ≤ 224) : ¬ DecKind.clearGrow.Holds L i := by
  simp only [DecKind.Holds]
  omega

variable {Wd : World} {A : Addr} {W : Nat → Option WFrame} {P : Wd.Par} {Fr : LoopFramesA A} {s0 : St Wd.F.S}
  {tab0 : List SymE} {fixA : List Nat} {V : LoopVals} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val}
  {B : LoopBase} {ΔJ ΔH ΔN : Nat}

/-- A case's chain at a selection that never holds: the same end, no obligation. -/
def unselected {Sel Sel' : Nat → Prop} (c : IterCaseW Wd A W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN Sel)
    (h : ∀ i, ¬ Sel' i) : IterCaseW Wd A W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN Sel' :=
  { c with chain := { c.chain with links := fun i _ hs => (h i hs).elim } }

variable {ρ : Nat → F64} {T L : Nat}

/-- **The decode cases at `L ≤ 224`** from the four chains those prompts run. -/
def casesOfFour (hL : L ≤ 224)
    (ord : IterCaseW Wd A W P Fr s0 tab0 fixA (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN (DecSel T L tk .ord))
    (clear : IterCaseW Wd A W P Fr s0 tab0 fixA (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN (DecSel T L tk .clear))
    (grow : IterCaseW Wd A W P Fr s0 tab0 fixA (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN (DecSel T L tk .grow))
    (fill : IterCaseW Wd A W P Fr s0 tab0 fixA (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN (DecSel T L tk .fill))
    (hord : ord.e.grow = false) (hclear : clear.e.grow = false) (hgrow : grow.e.grow = true)
    (hfill : fill.e.grow = false) :
    DecodeCasesW Wd A P W s0 tab0 fixA Fr ρ T tk L toks E0 B ΔJ ΔH ΔN where
  cs
    | .ord => ord
    | .clear => clear
    | .grow => grow
    | .fill => fill
    | .clearFill => unselected clear fun _ hs => clearFill_not hL hs.1.2.2
    | .clearGrow => unselected grow fun _ hs => clearGrow_not hL hs.1.2.2
  gr k := by
    cases k
    · exact hord
    · exact hclear
    · exact hgrow
    · exact hfill
    · exact hclear
    · exact hgrow

end Dec

end Host.Ts.Sim.Compose.Gpu
