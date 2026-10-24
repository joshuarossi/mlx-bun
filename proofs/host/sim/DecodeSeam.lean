import host.sim.LoopFramesFinal
import host.sim.GeneralL
namespace Host.Ts.Sim
open Host.Ts Host.Ts.Sim.Template

/-! # The decode loop at its seams

The decode route is stated against two interfaces only (`host-L-design.md`, `seams.md`):

* **from what precedes it**: the invariant at the decode cut `i = 1`, `LoopInvLF … 1`, whose
  parameters are the interface the prefill supplies: the relation family `R` (the load world's
  `Rel`, or a relation with further frames), the further frames `Fr` (the framed prompt, ghost
  slots), the counter bases `B`, the prompt length `L` (offset `L + i + 1`, capacity
  `capL (L + i + 1)`), and on the graph side the further invariant `Gx` (`GxL` with the prompt's
  reference `RefRun`, `RefDecodes`);
* **for each iteration and the end**: the per-iteration contract `DecodeIter` (from the invariant
  at `i`, a run reaching it at `i + 1`) and the halting contract `DecodeHalt` (from the invariant
  at the last iteration or at the EOS cut, a halting run with the goal).

`decode_route_to` composes them; `decode_sourceL`, `decode_source_eosL` are the decode route
after a prompt of length `L`. Their statements mention no template case: the current
whole-iteration templates discharge the contracts (`decodeIter_case`, `decodeHalt_final`,
`decodeHalt_final3`, `decodeHalt_exit`, `decodeHalt_finalE`), and stage contracts
(forward/cache/sample of one iteration) can replace them without changing the route. -/

/-! ## The contracts -/

/-- A family of cut invariants of the decode loop: iteration `i`, target `(t, C)`. -/
abbrev CutInv := Nat → St LF.S → CSrv → Prop

/-- **The per-iteration contract**: from the invariant at iteration `i`, `n` target steps reach the
invariant at `i + 1`. -/
def DecodeIter (Inv : CutInv) (i n : Nat) : Prop :=
  ∀ t C, Inv i t C → ∃ t' C', runC LF n t C = some (t', C') ∧ Inv (i + 1) t' C'

/-- **The halting contract** at iteration `J`: from the invariant there, `n` target steps halt the
target with `Goal`. -/
def DecodeHalt (Inv : CutInv) (J n : Nat) (Goal : St LF.S → CSrv → Prop) : Prop :=
  ∀ t C, Inv J t C → ∃ tF CF v, runC LF n t C = some (tF, CF) ∧ tF.ctl = .halt (.normal v) ∧
    CSrv.Le C CF ∧ Goal tF CF

/-- **The decode route up to iteration `J` and a halt there**: from any run reaching the
iteration-1 invariant, the iterations below `J` and the halting contract at `J` halt the target
with `Goal`. -/
theorem decode_route_to {Inv : CutInv} {J : Nat} (hJ1 : 1 ≤ J)
    (hit : ∀ i, 1 ≤ i → i < J → ∃ n, DecodeIter Inv i n) {Goal : St LF.S → CSrv → Prop}
    (hhalt : ∃ n, DecodeHalt Inv J n Goal)
    {N0 : Nat} {t0 t1 : St LF.S} {C0 C1 : CSrv} (hpre : runC LF N0 t0 C0 = some (t1, C1)) (h1 : Inv 1 t1 C1) :
    ∃ N tF CF, (∀ m, N ≤ m → runC LF m t0 C0 = some (tF, CF)) ∧ (∃ v, tF.ctl = .halt (.normal v)) ∧
      CSrv.Le C1 CF ∧ Goal tF CF := by
  classical
  let len : Nat → Nat := fun i => if h : 1 ≤ i ∧ i < J then Classical.choose (hit i h.1 h.2) else 0
  have hstep : ∀ k t C, Inv k t C → (1 ≤ k ∧ k < J) → ∃ t' C', runC LF (len k) t C = some (t', C') ∧
      Inv (k + 1) t' C' := by
    intro k t C hk hkJ
    have e : len k = Classical.choose (hit k hkJ.1 hkJ.2) := dite_eq_left hkJ
    rw [e]
    exact Classical.choose_spec (hit k hkJ.1 hkJ.2) t C hk
  obtain ⟨tJ, CJ, hrJ, hJ⟩ := loop_induct (F := LF) Inv (fun i => 1 ≤ i ∧ i < J) len hstep (J - 1) 1 t1 C1 h1
    (fun j hj => ⟨by omega, by omega⟩)
  rw [show 1 + (J - 1) = J by omega] at hJ
  obtain ⟨n, hn⟩ := hhalt
  obtain ⟨tF, CF, v, hrF, hv, hle, hG⟩ := hn tJ CJ hJ
  have hrun := runC_trans hpre (runC_trans hrJ hrF)
  exact ⟨_, tF, CF, fun m hm => runC_halted_le hrun (by rw [hv]; rfl) hm, ⟨v, hv⟩,
    (runC_le _ _ _ _ _ hrJ).trans hle, hG⟩

/-! ## The decode route after a prompt of length `L` -/

/-- **The decode loop's seam invariant** after a prompt of length `L`: `LoopInvF` at the loop
valuation `valL` with the interface's relation family `R`, further frames `Fr` and counter bases
`B`. Without further frames, at the load world's relation and zero bases it is `LoopInvL`
(`LoopInvLF_empty`). -/
abbrev LoopInvLF (Gx : Nat → Map → St LF.S → CSrv → Prop) (R : LoopR) (P : LoadP) (Fr : LoopFrames)
    (s0 : St LF.S) (tab0 : List SymE) (fixA : List Nat) (L : Nat) (ρ : Nat → F64) (T : Nat) (tk : Nat → Nat)
    (toks : List NumV) (E0 : List Val) (B : LoopBase) (ΔJ ΔH ΔN : Nat) : CutInv :=
  fun i t C => LoopInvF Gx R P Fr s0 tab0 fixA (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN i t C

theorem LoopInvLF_empty {Gx : Nat → Map → St LF.S → CSrv → Prop} {P : LoadP} {s0 : St LF.S} {tab0 : List SymE}
    {fixA : List Nat} {L : Nat} {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val}
    {ΔJ ΔH ΔN i : Nat} {t : St LF.S} {C : CSrv} :
    LoopInvLF Gx (relL P) P LoopFrames.empty s0 tab0 fixA L ρ T tk toks E0 ⟨0, 0, 0⟩ ΔJ ΔH ΔN i t C ↔
      LoopInvL Gx P s0 tab0 fixA L ρ T tk toks E0 ΔJ ΔH ΔN i t C := Iff.rfl

/-- **The decode route after a prompt of length `L`** at its seams: from any run reaching the
decode cut where the seam invariant holds (the prefill's conclusion), the per-iteration contracts
for the iterations `1 … T - 3` and the halting contract at the final iteration `T - 2` halt the
target with `Goal`. -/
theorem decode_sourceL {Gx : Nat → Map → St LF.S → CSrv → Prop} {R : LoopR} {P : LoadP} {Fr : LoopFrames}
    {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat} {L : Nat} {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat}
    {toks : List NumV} {E0 : List Val} {B : LoopBase} {ΔJ ΔH ΔN : Nat} {Goal : St LF.S → CSrv → Prop}
    (hT : 3 ≤ T)
    (hit : ∀ i, 1 ≤ i → i + 2 < T →
      ∃ n, DecodeIter (LoopInvLF Gx R P Fr s0 tab0 fixA L ρ T tk toks E0 B ΔJ ΔH ΔN) i n)
    (hfin : ∃ n, DecodeHalt (LoopInvLF Gx R P Fr s0 tab0 fixA L ρ T tk toks E0 B ΔJ ΔH ΔN) (T - 2) n Goal)
    {N0 : Nat} {t0 t1 : St LF.S} {C0 C1 : CSrv} (hpre : runC LF N0 t0 C0 = some (t1, C1))
    (h1 : LoopInvLF Gx R P Fr s0 tab0 fixA L ρ T tk toks E0 B ΔJ ΔH ΔN 1 t1 C1) :
    ∃ N tF CF, (∀ m, N ≤ m → runC LF m t0 C0 = some (tF, CF)) ∧ (∃ v, tF.ctl = .halt (.normal v)) ∧
      CSrv.Le C1 CF ∧ Goal tF CF :=
  decode_route_to (by omega) (fun i h1 h2 => hit i h1 (by omega)) hfin hpre h1

/-- **The decode route's EOS stop after a prompt of length `L`** at its seams: token `k`
(`2 ≤ k ≤ T`) stops the route, at the cut of iteration `k - 1` (`k < T`, contract `hX`) or in the
final iteration (`k = T`, contract `hF`); the iterations before it are per-iteration contracts. -/
theorem decode_source_eosL {Gx : Nat → Map → St LF.S → CSrv → Prop} {R : LoopR} {P : LoadP} {Fr : LoopFrames}
    {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat} {L : Nat} {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat}
    {toks : List NumV} {E0 : List Val} {B : LoopBase} {ΔJ ΔH ΔN : Nat} {Goal : St LF.S → CSrv → Prop}
    (hT : 3 ≤ T) (k : Nat) (hk2 : 2 ≤ k) (hkT : k ≤ T)
    (hit : ∀ i, 1 ≤ i → i + 1 < k → i + 2 < T →
      ∃ n, DecodeIter (LoopInvLF Gx R P Fr s0 tab0 fixA L ρ T tk toks E0 B ΔJ ΔH ΔN) i n)
    (hX : k < T → ∃ n, DecodeHalt (LoopInvLF Gx R P Fr s0 tab0 fixA L ρ T tk toks E0 B ΔJ ΔH ΔN) (k - 1) n Goal)
    (hF : k = T → ∃ n, DecodeHalt (LoopInvLF Gx R P Fr s0 tab0 fixA L ρ T tk toks E0 B ΔJ ΔH ΔN) (T - 2) n Goal)
    {N0 : Nat} {t0 t1 : St LF.S} {C0 C1 : CSrv} (hpre : runC LF N0 t0 C0 = some (t1, C1))
    (h1 : LoopInvLF Gx R P Fr s0 tab0 fixA L ρ T tk toks E0 B ΔJ ΔH ΔN 1 t1 C1) :
    ∃ N tF CF, (∀ m, N ≤ m → runC LF m t0 C0 = some (tF, CF)) ∧ (∃ v, tF.ctl = .halt (.normal v)) ∧
      CSrv.Le C1 CF ∧ Goal tF CF := by
  by_cases hk : k < T
  · exact decode_route_to (by omega) (fun i h1 h2 => hit i h1 (by omega) (by omega)) (hX hk) hpre h1
  · have e : k = T := by omega
    exact decode_route_to (by omega) (fun i h1 h2 => hit i h1 (by omega) (by omega)) (hF e) hpre h1

/-! ## The whole-iteration templates discharge the contracts -/

section Templates
variable {Gx : Nat → Map → St LF.S → CSrv → Prop} {ok : St LF.S → SSrv → Bool} {P : LoadP} {Fr : LoopFrames}
  {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat} {VBOk : (Nat → F64) → Prop}
  {L : Nat} {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {B : LoopBase}
  {ΔJ ΔH ΔN : Nat}

/-- **A loop case discharges the per-iteration contract** at iteration `i` (`loop_stepF`): the six
cases' facts at `L` (`LoopCases.OkAt`), the selected case's iteration theorem under the relation
family and frames, its keeping the further frames, and its graph obligation. -/
theorem decodeIter_case {R : LoopR} (hR : LoopRel R) (st : LoopStart P s0 tab0) (cs : LoopCases ok P s0 tab0 fixA)
    (hcs : cs.OkAt L ΔJ ΔH ΔN) {i : Nat} (hi1 : 1 ≤ i) (hiT : i + 2 < T) (hLT : L + T < 2 ^ 29)
    (hlen : T - 2 ≤ toks.length) (htk : ∀ j, j ≤ T → tk j ≤ 2 ^ 20) (notEos : tk (i + 1) ≠ 248044)
    (hit : (loopSelL cs L i).IterF R Fr VBOk) (hkeep : (loopSelL cs L i).Keeps Fr)
    (hVB : ∀ nx, nx ≤ 2 ^ 20 → VBOk (valL ρ T tk L i nx))
    (hJ : T * ΔJ + B.D < Sim.bound) (hH : s0.ffi.mlx.next + T * ΔH + B.H + (P.E - s0.ffi.mlx.next) < 2 ^ 46)
    (hN : s0.ffi.mlx.nnext + T * ΔN + B.N + (P.NE - s0.ffi.mlx.nnext) < 2 ^ 62)
    (hG : LoopGStepF Gx R Fr (loopSelL cs L i) (valL ρ T tk L) toks i) :
    DecodeIter (LoopInvLF Gx R P Fr s0 tab0 fixA L ρ T tk toks E0 B ΔJ ΔH ΔN) i (loopSelL cs L i).n := by
  intro t C hinv
  have hmul : ∀ D, i * D ≤ T * D := fun D => Nat.mul_le_mul_right D (by omega)
  exact loop_stepF hR Fr st (loopSelL cs L i) hit hkeep hinv hi1 (by omega)
    (fun nx => hcs.good ρ T tk i nx hi1 hiT hLT notEos (by have := htk (i + 1) (by omega); omega)) hVB
    (fun _ => next_valL (loopSelL cs L i).grow (loopSelL cs L i).theta (by omega)
      (by have := capL_le (L + i + 1); omega) (hcs.grow i))
    (htk (i + 2) (by omega)) (hcs.within i).1 (hcs.within i).2.1 (hcs.within i).2.2
    (by have := hmul ΔJ; omega) (by have := hmul ΔH; omega) (by have := hmul ΔN; omega) hG

/-- The goal of a final case: the `emitted` binding holds the cut's prefix and the first `T - 1`
readbacks, and the graph goal `G` holds. -/
def EmitGoal (env : Env) (nm : Name) (E0 : List Val) (toks : List NumV) (m : Nat) (G : St LF.S → CSrv → Prop)
    (tF : St LF.S) (CF : CSrv) : Prop :=
  (bindingOf tF env nm).bind (Host.Load.Extract.elements tF) = some (E0 ++ (toks.take m).map Val.num) ∧ G tF CF

/-- **A final case over a chain discharges the halting contract** at `T - 2` (`final_stepSF`). -/
theorem decodeHalt_final {G : St LF.S → CSrv → Prop} {cE : Nat} {env : Env} {nm : Name}
    (st : LoopStart P s0 tab0) (fc : FinalSeg P (toks.drop (T - 1)) s0 tab0 cE)
    (hfr17 : ∀ e ∈ tab0, e.noVar 17 = true) (hcE : cE ∈ fixA) (hb : 12502 ∈ fixA) (hT : 3 ≤ T)
    (hlen : T - 1 ≤ toks.length) (hgood : Good (valL ρ T tk L (T - 2) (tk T)) fc.S0.oracle)
    (hQA : ∀ K : Ctx, (∀ a, K.fr a ≠ none ↔ a ∈ 2673447 :: 12502 :: Fr.xs) → K.lo = P.lo → K.hi = P.E →
      fc.QA (valL ρ T tk L (T - 2) (tk T)) K)
    (henv : lookupEnv nm env = some cE) (hG : FinalGStepSF Gx P Fr fixA fc (valL ρ T tk L) tk G) :
    DecodeHalt (LoopInvLF Gx (relL P) P Fr s0 tab0 fixA L ρ T tk toks E0 B ΔJ ΔH ΔN) (T - 2) fc.case.n
      (EmitGoal env nm E0 toks (T - 1) G) := by
  intro t C hinv
  obtain ⟨tF, CF, v, hr, hv, hem, hle, hg⟩ := final_stepSF st fc hfr17 hcE hb (fun _ => upd_valL _) hinv hT hlen
    hgood hQA henv hG
  exact ⟨tF, CF, v, hr, hv, hle, hem, hg⟩

/-- **The three final cases discharge the halting contract** at `T - 2`, by the cache-clear tests
of the last two tokens (each oracle among `finalDG r3 r7`). -/
theorem decodeHalt_final3 {G : St LF.S → CSrv → Prop} {cE : Nat} {env : Env} {nm : Name}
    (st : LoopStart P s0 tab0) (F0 F1 F2 : FinalSeg P (toks.drop (T - 1)) s0 tab0 cE)
    (c0 : F0.S0.oracle.all (fun q => (finalDG false false).contains q) = true)
    (c1 : F1.S0.oracle.all (fun q => (finalDG true false).contains q) = true)
    (c2 : F2.S0.oracle.all (fun q => (finalDG false true).contains q) = true)
    (hfr17 : ∀ e ∈ tab0, e.noVar 17 = true) (hcE : cE ∈ fixA) (hb : 12502 ∈ fixA) (hT : 3 ≤ T)
    (hLT : L + T < 2 ^ 29) (hlen : T - 1 ≤ toks.length) (htk : ∀ j, j ≤ T → tk j ≤ 2 ^ 20)
    (notEos : ∀ k, 2 ≤ k → k ≤ T → tk k ≠ 248044)
    (hQA : ∀ K : Ctx, (∀ a, K.fr a ≠ none ↔ a ∈ 2673447 :: 12502 :: Fr.xs) → K.lo = P.lo → K.hi = P.E →
      F0.QA (valL ρ T tk L (T - 2) (tk T)) K ∧ F1.QA (valL ρ T tk L (T - 2) (tk T)) K ∧
        F2.QA (valL ρ T tk L (T - 2) (tk T)) K)
    (henv : lookupEnv nm env = some cE)
    (hF : (T - 2) % 256 ≠ 0 → (T - 1) % 256 ≠ 0 → FinalGStepSF Gx P Fr fixA F0 (valL ρ T tk L) tk G)
    (hF0 : (T - 2) % 256 = 0 → FinalGStepSF Gx P Fr fixA F1 (valL ρ T tk L) tk G)
    (hF1 : (T - 1) % 256 = 0 → FinalGStepSF Gx P Fr fixA F2 (valL ρ T tk L) tk G) :
    ∃ n, DecodeHalt (LoopInvLF Gx (relL P) P Fr s0 tab0 fixA L ρ T tk toks E0 B ΔJ ΔH ΔN) (T - 2) n
      (EmitGoal env nm E0 toks (T - 1) G) := by
  have hg := good_finalGL (ρ := ρ) (T := T) (tk := tk) (L := L) (i := T - 2) (nx := tk T) (by omega) (by omega)
    (notEos (T - 2 + 1) (by omega) (by omega)) (notEos T (by omega) le_rfl) (by omega)
    (by have := htk (T - 2 + 1) (by omega); omega) (by have := htk T le_rfl; omega)
  by_cases hc0 : (T - 2) % 256 = 0
  · have e0 : decide ((T - 2) % 256 = 0) = true := decide_eq_true hc0
    have e1 : decide ((T - 2 + 1) % 256 = 0) = false := decide_eq_false (by omega)
    rw [e0, e1] at hg
    exact ⟨_, decodeHalt_final st F1 hfr17 hcE hb hT hlen (good_of_mem hg c1) (fun K h1 h2 h3 => (hQA K h1 h2 h3).2.1) henv
      (hF0 hc0)⟩
  · by_cases hc1 : (T - 1) % 256 = 0
    · have e0 : decide ((T - 2) % 256 = 0) = false := decide_eq_false hc0
      have e1 : decide ((T - 2 + 1) % 256 = 0) = true := decide_eq_true (by omega)
      rw [e0, e1] at hg
      exact ⟨_, decodeHalt_final st F2 hfr17 hcE hb hT hlen (good_of_mem hg c2) (fun K h1 h2 h3 => (hQA K h1 h2 h3).2.2) henv
        (hF1 hc1)⟩
    · have e0 : decide ((T - 2) % 256 = 0) = false := decide_eq_false hc0
      have e1 : decide ((T - 2 + 1) % 256 = 0) = false := decide_eq_false (by omega)
      rw [e0, e1] at hg
      exact ⟨_, decodeHalt_final st F0 hfr17 hcE hb hT hlen (good_of_mem hg c0) (fun K h1 h2 h3 => (hQA K h1 h2 h3).1) henv
        (hF hc0 hc1)⟩

/-- **The EOS exit case discharges the halting contract** at the cut of iteration `J`
(`exit_stepF`): the `emitted` binding holds the cut's prefix and the first `J - 1` readbacks. -/
theorem decodeHalt_exit {G : St LF.S → CSrv → Prop} {okB : St LF.S → SSrv → Bool} {jsPA jsPB : Disp.JSP LF}
    {cE aN : Nat} {env : Env} {nm : Name}
    (hsimB : ∀ r, Disp.StepSimXV LF (LR P r) okB (Disp.Kp jsPB) VBOk)
    (hngB : ∀ (r : List NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (n : Nat) (s t s1 t1 : St LF.S) (S S1 : SSrv)
      (C C1 : CSrv), Disp.Kp jsPB K → VBOk ν → Rel LF (LR P r) M ν K s S t C → okB s S = true →
      runOk LF okB n s S = some (s1, S1) → runC LF n t C = some (t1, C1) → Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx)
    (hsimA : ∀ r, Disp.StepSimXV LF (LR P r) ok (Disp.Kp jsPA) VBOk)
    (hngA : ∀ (r : List NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (n : Nat) (s t s1 t1 : St LF.S) (S S1 : SSrv)
      (C C1 : CSrv), Disp.Kp jsPA K → VBOk ν → Rel LF (LR P r) M ν K s S t C → ok s S = true →
      runOk LF ok n s S = some (s1, S1) → runC LF n t C = some (t1, C1) → Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx)
    (hsimAL : ∀ r, Disp.StepSimXL LF (LR P r) ok (Disp.Kp jsPA) VBOk)
    (hngAL : ∀ (r : List NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (s t s1 t1 : St LF.S) (S S1 : SSrv) (C C1 : CSrv),
      Disp.Kp jsPA K → VBOk ν → RelX LF (LR P r) M ν K s S t C → isHalt s.ctl = false → ok s S = true →
      interpS (step LF s).run S = some (s1, S1) → interpC (step LF t).run C = some (t1, C1) →
      Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx)
    (hjA : jsPA.lo = P.lo ∧ jsPA.hi = P.E ∧ ∀ a, a ∈ jsPA.framed ↔ a ∈ 2673447 :: 12502 :: Fr.xs)
    (hjB : jsPB.lo = P.lo ∧ jsPB.hi = P.E ∧ ∀ a, a ∈ jsPB.framed ↔ a ∈ 2673447 :: 12502 :: (Fr.xs ++ [aN]))
    (ec : ExitCase ok okB s0 s0 tab0 cE aN []) (hcE : cE ∈ fixA) (hb : 12502 ∈ fixA) (haN2 : aN ≠ 12502)
    {J : Nat} (hgood : ∀ nx, Good (valL ρ T tk L J nx) ec.S0.oracle)
    (hVB : ∀ nx, nx ≤ 2 ^ 20 → VBOk (valL ρ T tk L J nx))
    (henv : lookupEnv nm env = some cE) (hG : ExitGStepF Gx P Fr fixA ec (valL ρ T tk L) toks J G) :
    DecodeHalt (LoopInvLF Gx (relL P) P Fr s0 tab0 fixA L ρ T tk toks E0 B ΔJ ΔH ΔN) J ec.n
      (fun tF CF => EmitGoal env nm E0 toks (J - 1) G tF CF ∧
        ∃ MF ν KF, Rel LF (LR P (toks.drop J)) MF ν KF ec.sF ec.SF tF CF ∧ ∀ a ∈ fixA, MF.a a = a) := by
  intro t C hinv
  obtain ⟨tF, CF, v, hr, hv, hem, hle, hg, rest⟩ := exit_stepF hsimA hsimB hngA hngB hsimAL hngAL hjA hjB ec hcE hb
    haN2 hinv hgood hVB henv hG
  exact ⟨tF, CF, v, hr, hv, hle, ⟨hem, hg⟩, rest⟩

/-- **An EOS final case discharges the halting contract** at `T - 2` (`finalE_stepF`): the
`emitted` binding holds the cut's prefix and the first `T - 2` readbacks. -/
theorem decodeHalt_finalE {G : St LF.S → CSrv → Prop} {okB : St LF.S → SSrv → Bool} {jsPA jsPB : Disp.JSP LF}
    {cE aN : Nat} {env : Env} {nm : Name}
    (hsimB : ∀ r, Disp.StepSimXV LF (LR P r) okB (Disp.Kp jsPB) VBOk)
    (hngB : ∀ (r : List NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (n : Nat) (s t s1 t1 : St LF.S) (S S1 : SSrv)
      (C C1 : CSrv), Disp.Kp jsPB K → VBOk ν → Rel LF (LR P r) M ν K s S t C → okB s S = true →
      runOk LF okB n s S = some (s1, S1) → runC LF n t C = some (t1, C1) → Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx)
    (hsimA : ∀ r, Disp.StepSimXV LF (LR P r) ok (Disp.Kp jsPA) VBOk)
    (hngA : ∀ (r : List NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (n : Nat) (s t s1 t1 : St LF.S) (S S1 : SSrv)
      (C C1 : CSrv), Disp.Kp jsPA K → VBOk ν → Rel LF (LR P r) M ν K s S t C → ok s S = true →
      runOk LF ok n s S = some (s1, S1) → runC LF n t C = some (t1, C1) → Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx)
    (hsimAL : ∀ r, Disp.StepSimXL LF (LR P r) ok (Disp.Kp jsPA) VBOk)
    (hngAL : ∀ (r : List NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (s t s1 t1 : St LF.S) (S S1 : SSrv) (C C1 : CSrv),
      Disp.Kp jsPA K → VBOk ν → RelX LF (LR P r) M ν K s S t C → isHalt s.ctl = false → ok s S = true →
      interpS (step LF s).run S = some (s1, S1) → interpC (step LF t).run C = some (t1, C1) →
      Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx)
    (hjA : jsPA.lo = P.lo ∧ jsPA.hi = P.E ∧ ∀ a, a ∈ jsPA.framed ↔ a ∈ 2673447 :: 12502 :: Fr.xs)
    (hjB : jsPB.lo = P.lo ∧ jsPB.hi = P.E ∧ ∀ a, a ∈ jsPB.framed ↔ a ∈ 2673447 :: 12502 :: (Fr.xs ++ [aN]))
    (st : LoopStart P s0 tab0)
    (ec : ExitCase ok okB s0 (finalStart s0 tab0.length) (tab0 ++ [.var 17]) cE aN [.num (.ref 79)])
    (hfr17 : ∀ e ∈ tab0, e.noVar 17 = true) (hcE : cE ∈ fixA) (hb : 12502 ∈ fixA) (haN2 : aN ≠ 12502)
    (hT : 3 ≤ T) (hlen : T - 1 ≤ toks.length)
    (hgood : Good (valL ρ T tk L (T - 2) (tk T)) ec.S0.oracle) (hVB : VBOk (valL ρ T tk L (T - 2) (tk T)))
    (henv : lookupEnv nm env = some cE) (hG : FinalEGStepF Gx P Fr fixA ec (valL ρ T tk L) T tk toks G) :
    DecodeHalt (LoopInvLF Gx (relL P) P Fr s0 tab0 fixA L ρ T tk toks E0 B ΔJ ΔH ΔN) (T - 2) ec.n
      (fun tF CF => EmitGoal env nm E0 toks (T - 2) G tF CF ∧
        ∃ MF ν KF, Rel LF (LR P (toks.drop (T - 1))) MF ν KF ec.sF ec.SF tF CF ∧ ∀ a ∈ fixA, MF.a a = a) := by
  intro t C hinv
  obtain ⟨tF, CF, v, hr, hv, hem, hle, hg, rest⟩ := finalE_stepF hsimA hsimB hngA hngB hsimAL hngAL hjA hjB st ec
    hfr17 hcE hb haN2 (fun _ => upd_valL _) hinv hT hlen hgood hVB henv hG
  exact ⟨tF, CF, v, hr, hv, hle, ⟨hem, hg⟩, rest⟩

end Templates

end Host.Ts.Sim
