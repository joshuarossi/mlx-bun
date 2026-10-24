import host.sim.world.Seam
import host.sim.world.Book
namespace Host.Ts.Sim.Prefill
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! # The route over a world

The prefill (`host.sim.world.Book`) and the decode route (`host.sim.world.Seam`) meet at the decode
cut (`PrefillDecodeA.lean` over a world `Wd`):

* `decCutW … i`: the decode cut at iteration `i` as an invariant cut; its invariant is the seam
  invariant (`decCutW_inv`), so a decode iteration composed of cut steps (pieces between cuts,
  0-step conversions at the stage calls inside the iteration, the last piece restarting into the
  decode cut) discharges the per-iteration contract (`decodeIter_cuts`), and every per-iteration
  contract (a loop case of one run or of pieces, `decodeIter_seg`) is such a cut step
  (`cutStep_of_iter`); `decodeHalt_cuts` for a halt;
* `loopCutW`: the decode cut `i = 1` (`loopCutA`), `loopCutW_inv`, `SeamGoalW`,
  `decodeRoute_seamW`, `source_tokens_promptAW` (`source_tokens_promptA`), `source_tokens_prompt_eosAW`
  (its EOS stop: the contracts before the stop and the halting contract at it).

The decode cut sits wherever the regenerated decode template starts (G16: at the readback stage
call). Its constants are the parameter `A : Addr` (the regenerated template's `addrFull`), and the
start facts the route needs of it are the hypothesis `st : LoopStartW Wd A P s0 tab0`.

The route's top theorems, at every budget and first EOS position, are in `host.sim.world.Route`. -/

section Cuts
variable (Wd : World) (A : Addr) (Gx : Nat → Map → St Wd.F.S → CSrv → Prop) (W : Nat → Option WFrame) (P : Wd.Par)
  (Fr : LoopFramesA A) (s0 : St Wd.F.S) (tab0 : List SymE) (fixA : List Nat) (V : LoopVals) (tk : Nat → Nat)
  (toks : List NumV) (E0 : List Val) (B : LoopBase) (ΔJ ΔH ΔN : Nat)

/-- **The decode cut at iteration `i`** over `Wd` as an invariant cut. -/
def decCutW (i : Nat) : ICut Wd.F where
  s0 := s0
  tab0 := tab0
  R := fun x s S => relW Wd P W (toks.drop i) x.M x.ν x.K s S x.t x.C
  B := fun x => ∃ nx p1, x.ν = V i nx ∧ x.K.fr = frA A s0 Fr.X p1 (E0 ++ (toks.take (i - 1)).map Val.num) ∧
    x.K.lo = Wd.lo P ∧ x.K.hi = Wd.E P ∧ x.K.base = s0.trace ∧ toks[i - 1]? = some (x.M.num A.tok) ∧ nx ≤ 2 ^ 20 ∧
    (∀ j (hj : j < toks.length), x.C.val toks[j] = some (F64.ofNat (tk (j + 2)))) ∧
    x.K.D ≤ (i - 1) * ΔJ + B.D ∧ (Wd.toMlx x.t.ffi).next ≤ (Wd.toMlx s0.ffi).next + (i - 1) * ΔH + B.H ∧
    (Wd.toMlx x.t.ffi).nnext ≤ (Wd.toMlx s0.ffi).nnext + (i - 1) * ΔN + B.N ∧ (∀ a ∈ fixA, x.M.a a = a) ∧
    Gx i x.M x.t x.C

/-- **The decode cut `i = 1`** over `Wd` (`loopCutA`). -/
def loopCutW : ICut Wd.F where
  s0 := s0
  tab0 := tab0
  R := fun x s S => relW Wd P W (toks.drop 1) x.M x.ν x.K s S x.t x.C
  B := fun x => ∃ nx p1, x.ν = V 1 nx ∧ x.K.fr = frA A s0 Fr.X p1 E0 ∧ x.K.lo = Wd.lo P ∧ x.K.hi = Wd.E P ∧
    x.K.base = s0.trace ∧ toks[0]? = some (x.M.num A.tok) ∧ nx ≤ 2 ^ 20 ∧
    (∀ j (hj : j < toks.length), x.C.val toks[j] = some (F64.ofNat (tk (j + 2)))) ∧
    x.K.D ≤ B.D ∧ (Wd.toMlx x.t.ffi).next ≤ (Wd.toMlx s0.ffi).next + B.H ∧
    (Wd.toMlx x.t.ffi).nnext ≤ (Wd.toMlx s0.ffi).nnext + B.N ∧ (∀ a ∈ fixA, x.M.a a = a) ∧ Gx 1 x.M x.t x.C

end Cuts

section Inv
variable {Wd : World} {A : Addr} {Gx : Nat → Map → St Wd.F.S → CSrv → Prop} {W : Nat → Option WFrame} {P : Wd.Par}
  {Fr : LoopFramesA A} {s0 : St Wd.F.S} {tab0 : List SymE} {fixA : List Nat} {V : LoopVals} {tk : Nat → Nat}
  {toks : List NumV} {E0 : List Val} {B : LoopBase} {ΔJ ΔH ΔN : Nat}

/-- **The decode cut's invariant at iteration `i` is the seam invariant.** -/
theorem decCutW_inv (i : Nat) (t : St Wd.F.S) (C : CSrv) :
    (decCutW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN i).Inv t C ↔
      DecodeInvW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN i t C := by
  constructor
  · rintro ⟨⟨M, ν, K, t', C'⟩, ht, hC, hR, nx, p1, hν, hfr, hlo, hhi, hbase, htok, hnx, hvals, hD, hH, hN, hfix, hG⟩
    change t' = t at ht
    change C' = C at hC
    change ν = V i nx at hν
    subst ht hC hν
    exact ⟨M, K, nx, p1, hR, hfr, hlo, hhi, hbase, htok, hnx, hvals, hD, hH, hN, hfix, hG⟩
  · rintro ⟨M, K, nx, p1, hR, hfr, hlo, hhi, hbase, htok, hnx, hvals, hD, hH, hN, hfix, hG⟩
    exact ⟨⟨M, V i nx, K, t, C⟩, rfl, rfl, hR, nx, p1, rfl, hfr, hlo, hhi, hbase, htok, hnx, hvals, hD, hH, hN, hfix, hG⟩

/-- **A decode iteration composed of cut steps discharges the per-iteration contract** (G7): from
the decode cut at `i` to the decode cut at `i + 1`, through any cuts (the pieces' cut steps,
`XCase.step`, `book_stepW`, and conversions, `CutConv.step`). -/
theorem decodeIter_cuts {i n : Nat}
    (h : CutStep (decCutW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN i)
      (decCutW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN (i + 1)) n) :
    DecodeIterW (DecodeInvW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN) i n := by
  intro t C hinv
  obtain ⟨t', C', hr, h'⟩ := h t C ((decCutW_inv i t C).2 hinv)
  exact ⟨t', C', hr, (decCutW_inv (i + 1) t' C').1 h'⟩

/-- **A per-iteration contract is a cut step between the decode cuts**, so a loop case (one run, a
segment of pieces: `decodeIter_seg`) composes with conversions and other cut steps. -/
theorem cutStep_of_iter {i n : Nat}
    (h : DecodeIterW (DecodeInvW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN) i n) :
    CutStep (decCutW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN i)
      (decCutW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN (i + 1)) n := by
  intro t C hinv
  obtain ⟨t', C', hr, h'⟩ := h t C ((decCutW_inv i t C).1 hinv)
  exact ⟨t', C', hr, (decCutW_inv (i + 1) t' C').2 h'⟩

/-- **A halt from the decode cut composed of cut steps** discharges the halting contract: cut steps
from the decode cut at `J` to a halting cut whose invariant gives the halt and the goal. -/
theorem decodeHalt_cuts {J n m : Nat} {Ih : ICut Wd.F} {Goal : St Wd.F.S → CSrv → Prop}
    (h : CutStep (decCutW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN J) Ih n)
    (hh : DecodeHaltW (fun _ => Ih.Inv) 0 m Goal) :
    DecodeHaltW (DecodeInvW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN) J (n + m) Goal := by
  intro t C hinv
  obtain ⟨t1, C1, hr1, h1⟩ := h t C ((decCutW_inv J t C).2 hinv)
  obtain ⟨tF, CF, v, hr2, hv, hle, hG⟩ := hh t1 C1 h1
  exact ⟨tF, CF, v, runC_trans hr1 hr2, hv, (runC_le _ _ _ _ _ hr1).trans hle, hG⟩

/-- **The decode cut's invariant is the seam invariant at iteration 1** (`loopCutA_inv`). -/
theorem loopCutW_inv (ΔJ ΔH ΔN : Nat) (t : St Wd.F.S) (C : CSrv) :
    (loopCutW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B).Inv t C ↔
      DecodeInvW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN 1 t C := by
  have e1 : E0 ++ (toks.take (1 - 1)).map Val.num = E0 := by simp
  constructor
  · rintro ⟨⟨M, ν, K, t', C'⟩, ht, hC, hR, nx, p1, hν, hfr, hlo, hhi, hbase, htok, hnx, hvals, hD, hH, hN, hfix, hG⟩
    change t' = t at ht
    change C' = C at hC
    change ν = V 1 nx at hν
    subst ht hC hν
    refine ⟨M, K, nx, p1, hR, by rw [e1]; exact hfr, hlo, hhi, hbase, htok, hnx, hvals, ?_, ?_, ?_, hfix, hG⟩
    · show K.D ≤ (1 - 1) * ΔJ + B.D
      simpa using hD
    · show (Wd.toMlx t'.ffi).next ≤ (Wd.toMlx s0.ffi).next + (1 - 1) * ΔH + B.H
      simpa using hH
    · show (Wd.toMlx t'.ffi).nnext ≤ (Wd.toMlx s0.ffi).nnext + (1 - 1) * ΔN + B.N
      simpa using hN
  · rintro ⟨M, K, nx, p1, hR, hfr, hlo, hhi, hbase, htok, hnx, hvals, hD, hH, hN, hfix, hG⟩
    refine ⟨⟨M, V 1 nx, K, t, C⟩, rfl, rfl, hR, nx, p1, rfl, ?_, hlo, hhi, hbase, htok, hnx, hvals,
      ?_, ?_, ?_, hfix, hG⟩
    · show K.fr = frA A s0 Fr.X p1 E0
      rw [hfr, e1]
    · show K.D ≤ B.D
      have : K.D ≤ (1 - 1) * ΔJ + B.D := hD
      simpa using this
    · show (Wd.toMlx t.ffi).next ≤ (Wd.toMlx s0.ffi).next + B.H
      have : (Wd.toMlx t.ffi).next ≤ (Wd.toMlx s0.ffi).next + (1 - 1) * ΔH + B.H := hH
      simpa using this
    · show (Wd.toMlx t.ffi).nnext ≤ (Wd.toMlx s0.ffi).nnext + B.N
      have : (Wd.toMlx t.ffi).nnext ≤ (Wd.toMlx s0.ffi).nnext + (1 - 1) * ΔN + B.N := hN
      simpa using this

end Inv

/-- The seam route's goal from `(t0, C0)` over `F` (`SeamGoal`). -/
def SeamGoalW {F : Ffi} (t0 : St F.S) (C0 : CSrv) (Goal : St F.S → CSrv → Prop) : Prop :=
  ∃ N tF CF, (∀ m, N ≤ m → runC F m t0 C0 = some (tF, CF)) ∧ (∃ v, tF.ctl = .halt (.normal v)) ∧
    CSrv.Le C0 CF ∧ Goal tF CF

section Route
variable {Wd : World} {A : Addr} {Gx : Nat → Map → St Wd.F.S → CSrv → Prop} {W : Nat → Option WFrame} {P : Wd.Par}
  {Fr : LoopFramesA A} {s0 : St Wd.F.S} {tab0 : List SymE} {fixA : List Nat} {V : LoopVals} {T : Nat}
  {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {B : LoopBase} {ΔJ ΔH ΔN : Nat}
  {Goal : St Wd.F.S → CSrv → Prop}

/-- **The route at `A` is a decode route** from the decode cut over `Wd` (`decodeRoute_seamA`). -/
theorem decodeRoute_seamW (hT : 3 ≤ T)
    (hit : ∀ i, 1 ≤ i → i + 2 < T → ∃ n, DecodeIterW (DecodeInvW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN) i n)
    (hfin : ∃ n, DecodeHaltW (DecodeInvW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN) (T - 2) n Goal)
    (t0 : St Wd.F.S) (C0 : CSrv) :
    DecodeRouteW (loopCutW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B) t0 C0 (SeamGoalW t0 C0 Goal) := by
  intro N t1 C1 hpre h1
  obtain ⟨N', tF, CF, hrun, hv, hle, hG⟩ := decode_sourceW hT hit hfin hpre ((loopCutW_inv ΔJ ΔH ΔN t1 C1).1 h1)
  exact ⟨N', tF, CF, hrun, hv, (runC_le _ _ _ _ _ hpre).trans hle, hG⟩

/-- **The route of a prompt of length `L` through the seams** over `Wd` (`source_tokens_promptA`). -/
theorem source_tokens_promptAW {I : PrefInvsW Wd.F} (S : PrefStepsW I) {L : Nat} (hL1 : 1 ≤ L) (hL2 : L ≤ 262143)
    {N0 : Nat} {t0 tL : St Wd.F.S} {C0 CL : CSrv} (hboot : runC Wd.F N0 t0 C0 = some (tL, CL))
    (hld : (I.ld L).Inv tL CL) (hdec : I.dec L = loopCutW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B) (hT : 3 ≤ T)
    (hit : ∀ i, 1 ≤ i → i + 2 < T → ∃ n, DecodeIterW (DecodeInvW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN) i n)
    (hfin : ∃ n, DecodeHaltW (DecodeInvW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN) (T - 2) n Goal) :
    SeamGoalW t0 C0 Goal :=
  source_promptW S hL1 hL2 hboot hld (by rw [hdec]; exact decodeRoute_seamW hT hit hfin t0 C0)

/-- The EOS stop through the seams over `Wd`: the iterations before the stop and the halting contract at
the stop's cut (`k < T`) or the final iteration (`k = T`). -/
theorem source_tokens_prompt_eosAW {I : PrefInvsW Wd.F} (S : PrefStepsW I) {L : Nat} (hL1 : 1 ≤ L)
    (hL2 : L ≤ 262143) {N0 : Nat} {t0 tL : St Wd.F.S} {C0 CL : CSrv} (hboot : runC Wd.F N0 t0 C0 = some (tL, CL))
    (hld : (I.ld L).Inv tL CL) (hdec : I.dec L = loopCutW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B) (hT : 3 ≤ T)
    (k : Nat) (hk2 : 2 ≤ k) (hkT : k ≤ T)
    (hit : ∀ i, 1 ≤ i → i + 1 < k → i + 2 < T →
      ∃ n, DecodeIterW (DecodeInvW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN) i n)
    (hX : k < T → ∃ n, DecodeHaltW (DecodeInvW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN) (k - 1) n Goal)
    (hF : k = T → ∃ n, DecodeHaltW (DecodeInvW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN) (T - 2) n Goal) :
    SeamGoalW t0 C0 Goal := by
  refine source_promptW S hL1 hL2 hboot hld ?_
  rw [hdec]
  intro N t1 C1 hpre h1
  obtain ⟨N', tF, CF, hrun, hv, hle, hG⟩ :=
    decode_source_eosW hT k hk2 hkT hit hX hF hpre ((loopCutW_inv ΔJ ΔH ΔN t1 C1).1 h1)
  exact ⟨N', tF, CF, hrun, hv, (runC_le _ _ _ _ _ hpre).trans hle, hG⟩

end Route

end Host.Ts.Sim.Prefill
