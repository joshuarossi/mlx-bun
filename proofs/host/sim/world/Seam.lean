import host.sim.world.Halt
import host.sim.world.Boxes
namespace Host.Ts.Sim
open Host.Ts Host.Ts.Sim.Template

/-! # The decode route over a world, at its seams

`DecodeSeam.lean` and `DecodeAddrSeam.lean` over a world `Wd`:

* the contracts `DecodeIterW`, `DecodeHaltW` and their composition `decode_route_toW`; the goals
  `EmitGoalW` (the `emitted` binding and the graph goal) and `FinGoalW` (with a fact of the halted
  target, for an EOS stop
  `generation.stats.finishReason` `"stop"`);
* the seam invariant `DecodeInvW` (`LoopInvW` under `relW Wd P W`), `decode_sourceW`,
  `decode_source_eosW`; `DecodeItersW`: the iterations a route takes, however each is proven;
* per iteration: `decodeIter_caseW` (a case with its iteration theorem), `decodeIter_seg` (G7: a
  loop case composed of pieces, `LoopSegW`), the six cases as segments (`LoopCasesW`,
  `loopSelLW`, `LoopCasesW.Facts` (each oracle decided by `goodLin` over its class's box,
  `host.sim.world.Boxes`), `OkAt`, `okAt`), the selected one (`decodeIter_selLW`) and all of them
  (`LoopCasesW.iterW`); the iterations as cut-step chains are `decodeIter_piecesW` and, through
  compactions, `decodeIter_piecesCW` (`host.sim.world.IterCut`);
* at the end: `decodeHalt_lastW`, `decodeHalt_last3W` (`FinalOk`), and the EOS halts with their
  chains' end facts (`decodeHalt_cutW` (`ExitOk`), `decodeHalt_lastEW` (`FinalEOk`); at `stopFin`,
  the finish reason);
* `decode_sourceLW`, `decode_source_eosLW`: the decode route after a prompt of length `L`, end to
  end, from its iterations, the EOS stop with the chains' end fact `Fin` (the finish reason at
  `stopFin`). -/

/-! ## The contracts -/

section Contracts
variable {F : Ffi}

/-- A family of cut invariants of the decode loop over `F` (`CutInv`). -/
abbrev CutInvW (F : Ffi) := Nat → St F.S → CSrv → Prop

/-- **The per-iteration contract** over `F` (`DecodeIter`). -/
def DecodeIterW (Inv : CutInvW F) (i n : Nat) : Prop :=
  ∀ t C, Inv i t C → ∃ t' C', runC F n t C = some (t', C') ∧ Inv (i + 1) t' C'

/-- **The halting contract** over `F` (`DecodeHalt`). -/
def DecodeHaltW (Inv : CutInvW F) (J n : Nat) (Goal : St F.S → CSrv → Prop) : Prop :=
  ∀ t C, Inv J t C → ∃ tF CF v, runC F n t C = some (tF, CF) ∧ tF.ctl = .halt (.normal v) ∧
    CSrv.Le C CF ∧ Goal tF CF

/-- **The decode route up to iteration `J` and a halt there** over `F` (`decode_route_to`). -/
theorem decode_route_toW {Inv : CutInvW F} {J : Nat} (hJ1 : 1 ≤ J)
    (hit : ∀ i, 1 ≤ i → i < J → ∃ n, DecodeIterW Inv i n) {Goal : St F.S → CSrv → Prop}
    (hhalt : ∃ n, DecodeHaltW Inv J n Goal)
    {N0 : Nat} {t0 t1 : St F.S} {C0 C1 : CSrv} (hpre : runC F N0 t0 C0 = some (t1, C1)) (h1 : Inv 1 t1 C1) :
    ∃ N tF CF, (∀ m, N ≤ m → runC F m t0 C0 = some (tF, CF)) ∧ (∃ v, tF.ctl = .halt (.normal v)) ∧
      CSrv.Le C1 CF ∧ Goal tF CF := by
  classical
  let len : Nat → Nat := fun i => if h : 1 ≤ i ∧ i < J then Classical.choose (hit i h.1 h.2) else 0
  have hstep : ∀ k t C, Inv k t C → (1 ≤ k ∧ k < J) → ∃ t' C', runC F (len k) t C = some (t', C') ∧
      Inv (k + 1) t' C' := by
    intro k t C hk hkJ
    have e : len k = Classical.choose (hit k hkJ.1 hkJ.2) := dite_eq_left hkJ
    rw [e]
    exact Classical.choose_spec (hit k hkJ.1 hkJ.2) t C hk
  obtain ⟨tJ, CJ, hrJ, hJ⟩ := loop_induct (F := F) Inv (fun i => 1 ≤ i ∧ i < J) len hstep (J - 1) 1 t1 C1 h1
    (fun j hj => ⟨by omega, by omega⟩)
  rw [show 1 + (J - 1) = J by omega] at hJ
  obtain ⟨n, hn⟩ := hhalt
  obtain ⟨tF, CF, v, hrF, hv, hle, hG⟩ := hn tJ CJ hJ
  have hrun := runC_trans hpre (runC_trans hrJ hrF)
  exact ⟨_, tF, CF, fun m hm => runC_halted_le hrun (by rw [hv]; rfl) hm, ⟨v, hv⟩,
    (runC_le _ _ _ _ _ hrJ).trans hle, hG⟩

end Contracts

/-- The goal of a halt: the `emitted` binding holds the cut's prefix and the first `m` readbacks,
and the graph goal `G` holds (`EmitGoal`). -/
def EmitGoalW {S : Type} (env : Env) (nm : Name) (E0 : List Val) (toks : List NumV) (m : Nat)
    (G : St S → CSrv → Prop) (tF : St S) (CF : CSrv) : Prop :=
  (bindingOf tF env nm).bind (elementsW tF) = some (E0 ++ (toks.take m).map Val.num) ∧ G tF CF

/-- The goal of a halt with a fact `Fin` of the halted target (an EOS stop: `stopFin`,
`generation.stats.finishReason` `"stop"`). -/
def FinGoalW {S : Type} (env : Env) (nm : Name) (E0 : List Val) (toks : List NumV) (m : Nat)
    (G : St S → CSrv → Prop) (Fin : St S → Prop) (tF : St S) (CF : CSrv) : Prop :=
  EmitGoalW env nm E0 toks m G tF CF ∧ Fin tF

/-! ## The route -/

/-- **The decode loop's seam invariant** at the constants `A` over `Wd` (`DecodeInvA`). -/
abbrev DecodeInvW (Wd : World) (A : Addr) (Gx : Nat → Map → St Wd.F.S → CSrv → Prop) (W : Nat → Option WFrame)
    (P : Wd.Par) (Fr : LoopFramesA A) (s0 : St Wd.F.S) (tab0 : List SymE) (fixA : List Nat) (V : LoopVals)
    (tk : Nat → Nat) (toks : List NumV) (E0 : List Val) (B : LoopBase) (ΔJ ΔH ΔN : Nat) : CutInvW Wd.F :=
  fun i t C => LoopInvW Wd A Gx (relW Wd P W) P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN i t C

section Route
variable {Wd : World} {A : Addr} {Gx : Nat → Map → St Wd.F.S → CSrv → Prop} {W : Nat → Option WFrame}
  {P : Wd.Par} {Fr : LoopFramesA A} {s0 : St Wd.F.S} {tab0 : List SymE} {fixA : List Nat} {V : LoopVals} {T : Nat}
  {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {B : LoopBase} {ΔJ ΔH ΔN : Nat}
  {Goal : St Wd.F.S → CSrv → Prop}

/-- **The decode route** over `Wd` (`decode_sourceA`). -/
theorem decode_sourceW (hT : 3 ≤ T)
    (hit : ∀ i, 1 ≤ i → i + 2 < T → ∃ n, DecodeIterW (DecodeInvW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN) i n)
    (hfin : ∃ n, DecodeHaltW (DecodeInvW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN) (T - 2) n Goal)
    {N0 : Nat} {t0 t1 : St Wd.F.S} {C0 C1 : CSrv} (hpre : runC Wd.F N0 t0 C0 = some (t1, C1))
    (h1 : DecodeInvW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN 1 t1 C1) :
    ∃ N tF CF, (∀ m, N ≤ m → runC Wd.F m t0 C0 = some (tF, CF)) ∧ (∃ v, tF.ctl = .halt (.normal v)) ∧
      CSrv.Le C1 CF ∧ Goal tF CF :=
  decode_route_toW (by omega) (fun i h1 h2 => hit i h1 (by omega)) hfin hpre h1

/-- **The decode route's EOS stop** over `Wd` (`decode_source_eosA`). -/
theorem decode_source_eosW (hT : 3 ≤ T) (k : Nat) (hk2 : 2 ≤ k) (hkT : k ≤ T)
    (hit : ∀ i, 1 ≤ i → i + 1 < k → i + 2 < T →
      ∃ n, DecodeIterW (DecodeInvW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN) i n)
    (hX : k < T → ∃ n, DecodeHaltW (DecodeInvW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN) (k - 1) n Goal)
    (hF : k = T → ∃ n, DecodeHaltW (DecodeInvW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN) (T - 2) n Goal)
    {N0 : Nat} {t0 t1 : St Wd.F.S} {C0 C1 : CSrv} (hpre : runC Wd.F N0 t0 C0 = some (t1, C1))
    (h1 : DecodeInvW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN 1 t1 C1) :
    ∃ N tF CF, (∀ m, N ≤ m → runC Wd.F m t0 C0 = some (tF, CF)) ∧ (∃ v, tF.ctl = .halt (.normal v)) ∧
      CSrv.Le C1 CF ∧ Goal tF CF := by
  by_cases hk : k < T
  · exact decode_route_toW (by omega) (fun i h1 h2 => hit i h1 (by omega) (by omega)) (hX hk) hpre h1
  · exact decode_route_toW (by omega) (fun i h1 h2 => hit i h1 (by omega) (by omega)) (hF (by omega)) hpre h1

end Route

/-- **The decode iterations a route takes**: every iteration `i` before the final one (`i + 2 < T`)
whose tokens `1 … i + 1` are not EOS discharges the per-iteration contract, in some number of
target steps — however it is proven: a loop case of one run (`decodeIter_caseW`), of pieces
(`decodeIter_seg`, selected among six: `LoopCasesW.iterW`), a chain of cut steps with stage calls
(`decodeIter_piecesW`), through compactions (`decodeIter_piecesCW`). -/
def DecodeItersW {F : Ffi} (Inv : CutInvW F) (T : Nat) (tk : Nat → Nat) : Prop :=
  ∀ i, 1 ≤ i → i + 2 < T → (∀ j, 1 ≤ j → j ≤ i + 1 → tk j ≠ 248044) → ∃ n, DecodeIterW Inv i n

/-! ## Per iteration -/

section Iter
variable {Wd : World} {A : Addr} {Gx : Nat → Map → St Wd.F.S → CSrv → Prop} {W : Nat → Option WFrame}
  {P : Wd.Par} {Fr : LoopFramesA A} {s0 : St Wd.F.S} {tab0 : List SymE} {fixA : List Nat} {VBOk : (Nat → F64) → Prop}
  {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {B : LoopBase} {ΔJ ΔH ΔN : Nat}

/-- A loop case's counter deltas are within `ΔJ`, `ΔH`, `ΔN` (`LoopCaseA.Within`). -/
def LoopCaseW.Within (c : LoopCaseW Wd A P s0 tab0 fixA) (ΔJ ΔH ΔN : Nat) : Prop :=
  c.s1.next - s0.next ≤ ΔJ ∧ (Wd.toMlx c.s1.ffi).next - (Wd.toMlx s0.ffi).next ≤ ΔH ∧
    (Wd.toMlx c.s1.ffi).nnext - (Wd.toMlx s0.ffi).nnext ≤ ΔN

/-- **A loop case discharges the per-iteration contract** over `Wd` (`decodeIter_caseA`). -/
theorem decodeIter_caseW {V : LoopVals} (st : LoopStartW Wd A P s0 tab0) (c : LoopCaseW Wd A P s0 tab0 fixA)
    (hit : c.IterFW (relW Wd P W) Fr VBOk) (hkeep : c.KeepsW Fr) {i : Nat} (hi1 : 1 ≤ i) (hlen : i < toks.length)
    (hgood : ∀ nx, Good (V i nx) c.S0.oracle) (hVB : ∀ nx, nx ≤ 2 ^ 20 → VBOk (V i nx))
    (hnext : ∀ nx, Shift.valuation c.θ (upd (V i nx) A.nxt (F64.ofNat (tk (i + 2)))) = V (i + 1) (tk (i + 2)))
    (htk : tk (i + 2) ≤ 2 ^ 20) (hw : c.Within ΔJ ΔH ΔN)
    (hJ : i * ΔJ + B.D < Sim.bound)
    (hH : (Wd.toMlx s0.ffi).next + i * ΔH + B.H + (Wd.E P - (Wd.toMlx s0.ffi).next) < 2 ^ 46)
    (hN : (Wd.toMlx s0.ffi).nnext + i * ΔN + B.N + (Wd.NE P - (Wd.toMlx s0.ffi).nnext) < 2 ^ 62)
    (hG : LoopGStepW Gx (relW Wd P W) Fr c V toks i) :
    DecodeIterW (DecodeInvW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN) i c.n :=
  fun _ _ hinv => loop_stepW (relRelW Wd P W) Fr st c hit hkeep hinv hi1 hlen hgood hVB hnext htk hw.1 hw.2.1
    hw.2.2 hJ hH hN hG

/-- **A loop case composed of pieces discharges the per-iteration contract** (G7): its chain from
the decode cut's template, the world's restart into it (`LoopSegW.iterF`), the invariant's
bookkeeping (`loop_stepW`). -/
theorem decodeIter_seg {V : LoopVals} (st : LoopStartW Wd A P s0 tab0) (c : LoopSegW Wd A P W s0 tab0 fixA)
    (hQ : c.Entry Fr VBOk) (hsh : c.ShiftFWW Fr W) (hkeep : c.KeepsW Fr) {i : Nat} (hi1 : 1 ≤ i)
    (hlen : i < toks.length) (hgood : ∀ nx, Good (V i nx) c.S0.oracle) (hVB : ∀ nx, nx ≤ 2 ^ 20 → VBOk (V i nx))
    (hnext : ∀ nx, Shift.valuation c.θ (upd (V i nx) A.nxt (F64.ofNat (tk (i + 2)))) = V (i + 1) (tk (i + 2)))
    (htk : tk (i + 2) ≤ 2 ^ 20) (hw : c.Within ΔJ ΔH ΔN)
    (hJ : i * ΔJ + B.D < Sim.bound)
    (hH : (Wd.toMlx s0.ffi).next + i * ΔH + B.H + (Wd.E P - (Wd.toMlx s0.ffi).next) < 2 ^ 46)
    (hN : (Wd.toMlx s0.ffi).nnext + i * ΔN + B.N + (Wd.NE P - (Wd.toMlx s0.ffi).nnext) < 2 ^ 62)
    (hG : LoopGStepW Gx (relW Wd P W) Fr c.toLoopCaseW V toks i) :
    DecodeIterW (DecodeInvW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN) i c.n :=
  decodeIter_caseW st c.toLoopCaseW (c.iterF st hQ hsh) hkeep hi1 hlen hgood hVB hnext htk hw hJ hH hN hG

/-- **The six loop cases** at `A` over `Wd`, each composed of pieces (`LoopCasesA` recast as
segments). -/
structure LoopCasesW (Wd : World) (A : Addr) (P : Wd.Par) (W : Nat → Option WFrame) (s0 : St Wd.F.S)
    (tab0 : List SymE) (fixA : List Nat) where
  ord : LoopSegW Wd A P W s0 tab0 fixA
  clear : LoopSegW Wd A P W s0 tab0 fixA
  grow : LoopSegW Wd A P W s0 tab0 fixA
  fill : LoopSegW Wd A P W s0 tab0 fixA
  clearFill : LoopSegW Wd A P W s0 tab0 fixA
  clearGrow : LoopSegW Wd A P W s0 tab0 fixA

/-- **The loop case of iteration `i` after a prompt of length `L`** (`loopSelLA`). -/
def loopSelLW (cs : LoopCasesW Wd A P W s0 tab0 fixA) (L i : Nat) : LoopSegW Wd A P W s0 tab0 fixA :=
  if i % 256 = 0 then
    (if (L + i + 1) % 256 = 0 then cs.clearGrow else if (L + i + 1) % 256 = 255 then cs.clearFill else cs.clear)
  else if (L + i + 1) % 256 = 0 then cs.grow else if (L + i + 1) % 256 = 255 then cs.fill else cs.ord

theorem loopSelLW_cases (cs : LoopCasesW Wd A P W s0 tab0 fixA) (L i : Nat) :
    (i % 256 = 0 ∧ (L + i + 1) % 256 = 0 ∧ loopSelLW cs L i = cs.clearGrow) ∨
    (i % 256 = 0 ∧ (L + i + 1) % 256 = 255 ∧ loopSelLW cs L i = cs.clearFill) ∨
    (i % 256 = 0 ∧ (L + i + 1) % 256 ≠ 0 ∧ (L + i + 1) % 256 ≠ 255 ∧ loopSelLW cs L i = cs.clear) ∨
    (i % 256 ≠ 0 ∧ (L + i + 1) % 256 = 0 ∧ loopSelLW cs L i = cs.grow) ∨
    (i % 256 ≠ 0 ∧ (L + i + 1) % 256 = 255 ∧ loopSelLW cs L i = cs.fill) ∨
    (i % 256 ≠ 0 ∧ (L + i + 1) % 256 ≠ 0 ∧ (L + i + 1) % 256 ≠ 255 ∧ loopSelLW cs L i = cs.ord) := by
  unfold loopSelLW
  by_cases hc : i % 256 = 0
  · by_cases h0 : (L + i + 1) % 256 = 0
    · exact .inl ⟨hc, h0, by simp [hc, h0]⟩
    · by_cases h1 : (L + i + 1) % 256 = 255
      · exact .inr (.inl ⟨hc, h1, by simp [hc, h1]⟩)
      · exact .inr (.inr (.inl ⟨hc, h0, h1, by simp [hc, h0, h1]⟩))
  · by_cases h0 : (L + i + 1) % 256 = 0
    · exact .inr (.inr (.inr (.inl ⟨hc, h0, by simp [hc, h0]⟩)))
    · by_cases h1 : (L + i + 1) % 256 = 255
      · exact .inr (.inr (.inr (.inr (.inl ⟨hc, h1, by simp [hc, h1]⟩))))
      · exact .inr (.inr (.inr (.inr (.inr ⟨hc, h0, h1, by simp [hc, h0, h1]⟩))))

/-- **The six cases' template facts** (`LoopCasesA.Facts`): each case's oracle (the oracle of its
chain's start, which the pieces' checks consume) decided by `goodLin` over its class's box (the
old containment in the class's answers implies it: `goodLin_sub Lin.ordL_check`, …), the growth
flag of its KV decode stage instance, its counter deltas. -/
structure LoopCasesW.Facts (cs : LoopCasesW Wd A P W s0 tab0 fixA) (ΔJ ΔH ΔN : Nat) : Prop where
  cOrd : Lin.goodLin Lin.ordLB Lin.ordLV cs.ord.S0.oracle = true
  cClear : Lin.goodLin Lin.clearLB Lin.clearLV cs.clear.S0.oracle = true
  cGrow : Lin.goodLin Lin.growLB Lin.growLV cs.grow.S0.oracle = true
  cFill : Lin.goodLin Lin.fillLB Lin.fillLV cs.fill.S0.oracle = true
  cClearFill : Lin.goodLin Lin.clearFillLB Lin.clearFillLV cs.clearFill.S0.oracle = true
  cClearGrow : Lin.goodLin Lin.clearGrowLB Lin.clearGrowLV cs.clearGrow.S0.oracle = true
  gOrd : cs.ord.grow = false
  gClear : cs.clear.grow = false
  gGrow : cs.grow.grow = true
  gFill : cs.fill.grow = false
  gClearFill : cs.clearFill.grow = false
  gClearGrow : cs.clearGrow.grow = true
  dOrd : cs.ord.Within ΔJ ΔH ΔN
  dClear : cs.clear.Within ΔJ ΔH ΔN
  dGrow : cs.grow.Within ΔJ ΔH ΔN
  dFill : cs.fill.Within ΔJ ΔH ΔN
  dClearFill : cs.clearFill.Within ΔJ ΔH ΔN
  dClearGrow : cs.clearGrow.Within ΔJ ΔH ΔN

/-- **What the loop needs of the cases at prompt length `L`** (`LoopCasesA.OkAt`). -/
structure LoopCasesW.OkAt (cs : LoopCasesW Wd A P W s0 tab0 fixA) (L ΔJ ΔH ΔN : Nat) : Prop where
  grow : ∀ i, (loopSelLW cs L i).grow = decide ((L + i + 1) % 256 = 0)
  good : ∀ (ρ : Nat → F64) (T : Nat) (tk : Nat → Nat) (i nx : Nat), 1 ≤ i → i + 2 < T → L + T < 2 ^ 29 →
    tk (i + 1) ≠ 248044 → tk (i + 1) < 2 ^ 32 → Good (valL ρ T tk L i nx) (loopSelLW cs L i).S0.oracle
  within : ∀ i, (loopSelLW cs L i).Within ΔJ ΔH ΔN

/-- **The six cases at every prompt length**, from their template facts (`LoopCasesA.okAt`). -/
theorem LoopCasesW.okAt {cs : LoopCasesW Wd A P W s0 tab0 fixA} (hf : cs.Facts ΔJ ΔH ΔN) (L : Nat) :
    cs.OkAt L ΔJ ΔH ΔN where
  grow i := by
    rcases loopSelLW_cases cs L i with ⟨_, h, e⟩ | ⟨_, h, e⟩ | ⟨_, h, _, e⟩ | ⟨_, h, e⟩ | ⟨_, h, e⟩ | ⟨_, h, _, e⟩ <;>
      rw [e]
    · rw [hf.gClearGrow]; simp [h]
    · rw [hf.gClearFill]; simp [h]
    · rw [hf.gClear]; simp [h]
    · rw [hf.gGrow]; simp [h]
    · rw [hf.gFill]; simp [h]
    · rw [hf.gOrd]; simp [h]
  good ρ T tk i nx hi1 hT hLT htok ht := by
    rcases loopSelLW_cases cs L i with ⟨h1, h2, e⟩ | ⟨h1, h2, e⟩ | ⟨h1, h2, h3, e⟩ | ⟨h1, h2, e⟩ | ⟨h1, h2, e⟩ |
      ⟨h1, h2, h3, e⟩ <;> rw [e]
    · exact good_clearGrowW hf.cClearGrow hi1 h1 h2 hT (by omega) (by omega) htok ht
    · exact good_clearFillW hf.cClearFill hi1 h1 h2 hT (by omega) (by omega) htok ht
    · exact good_clearW hf.cClear hi1 h1 h2 h3 hT (by omega) (by omega) htok ht
    · exact good_growW hf.cGrow h1 h2 hT (by omega) (by omega) htok ht
    · exact good_fillW hf.cFill h1 h2 hT (by omega) (by omega) htok ht
    · exact good_ordW hf.cOrd h1 h2 h3 hT (by omega) (by omega) htok ht
  within i := by
    rcases loopSelLW_cases cs L i with ⟨_, _, e⟩ | ⟨_, _, e⟩ | ⟨_, _, _, e⟩ | ⟨_, _, e⟩ | ⟨_, _, e⟩ | ⟨_, _, _, e⟩ <;>
      rw [e]
    · exact hf.dClearGrow
    · exact hf.dClearFill
    · exact hf.dClear
    · exact hf.dGrow
    · exact hf.dFill
    · exact hf.dOrd

/-- **The selected case discharges the per-iteration contract** at iteration `i` after a prompt of
length `L` (`decodeIter_selLA`), over `Wd`: the selected segment's entry, shift under the frames
and keeping of the further frames. -/
theorem decodeIter_selLW (hA : A.nxt = 17) (st : LoopStartW Wd A P s0 tab0) (cs : LoopCasesW Wd A P W s0 tab0 fixA)
    {L : Nat} (hcs : cs.OkAt L ΔJ ΔH ΔN) {ρ : Nat → F64} {T i : Nat} (hi1 : 1 ≤ i) (hiT : i + 2 < T)
    (hLT : L + T < 2 ^ 29) (hlen : T - 2 ≤ toks.length) (htk : ∀ j, j ≤ T → tk j ≤ 2 ^ 20)
    (notEos : tk (i + 1) ≠ 248044) (hQ : (loopSelLW cs L i).Entry Fr VBOk)
    (hsh : (loopSelLW cs L i).ShiftFWW Fr W) (hkeep : (loopSelLW cs L i).KeepsW Fr)
    (hVB : ∀ nx, nx ≤ 2 ^ 20 → VBOk (valL ρ T tk L i nx))
    (hJ : T * ΔJ + B.D < Sim.bound)
    (hH : (Wd.toMlx s0.ffi).next + T * ΔH + B.H + (Wd.E P - (Wd.toMlx s0.ffi).next) < 2 ^ 46)
    (hN : (Wd.toMlx s0.ffi).nnext + T * ΔN + B.N + (Wd.NE P - (Wd.toMlx s0.ffi).nnext) < 2 ^ 62)
    (hG : LoopGStepW Gx (relW Wd P W) Fr (loopSelLW cs L i).toLoopCaseW (valL ρ T tk L) toks i) :
    DecodeIterW (DecodeInvW Wd A Gx W P Fr s0 tab0 fixA (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN) i
      (loopSelLW cs L i).n := by
  have hmul : ∀ D, i * D ≤ T * D := fun D => Nat.mul_le_mul_right D (by omega)
  exact decodeIter_seg st (loopSelLW cs L i) hQ hsh hkeep hi1 (by omega)
    (fun nx => hcs.good ρ T tk i nx hi1 hiT hLT notEos (by have := htk (i + 1) (by omega); omega)) hVB
    (fun _ => by
      rw [hA]
      exact next_valL (loopSelLW cs L i).grow (fun j => by rw [(loopSelLW cs L i).theta j, hA]) (by omega)
        (by have := capL_le (L + i + 1); omega) (hcs.grow i))
    (htk (i + 2) (by omega)) (hcs.within i)
    (by have := hmul ΔJ; omega) (by have := hmul ΔH; omega) (by have := hmul ΔN; omega) hG

/-- **The six cases composed of pieces give the route's iterations** at a prompt of length `L`
(the `LoopSegW` path of `DecodeItersW`): each selected case's entry, shift under the frames, kept
frames and graph obligation. -/
theorem LoopCasesW.iterW (hA : A.nxt = 17) (st : LoopStartW Wd A P s0 tab0) (cs : LoopCasesW Wd A P W s0 tab0 fixA)
    {L : Nat} (hcs : cs.OkAt L ΔJ ΔH ΔN) {ρ : Nat → F64} {T : Nat} (hLT : L + T < 2 ^ 29)
    (hlen : T - 2 ≤ toks.length) (htk : ∀ j, j ≤ T → tk j ≤ 2 ^ 20)
    (hQ : ∀ i, 1 ≤ i → i + 2 < T → (loopSelLW cs L i).Entry Fr VBOk)
    (hsh : ∀ i, 1 ≤ i → i + 2 < T → (loopSelLW cs L i).ShiftFWW Fr W)
    (hkeep : ∀ i, 1 ≤ i → i + 2 < T → (loopSelLW cs L i).KeepsW Fr)
    (hVB : ∀ i nx, 1 ≤ i → i + 2 ≤ T → nx ≤ 2 ^ 20 → VBOk (valL ρ T tk L i nx))
    (hJ : T * ΔJ + B.D < Sim.bound)
    (hH : (Wd.toMlx s0.ffi).next + T * ΔH + B.H + (Wd.E P - (Wd.toMlx s0.ffi).next) < 2 ^ 46)
    (hN : (Wd.toMlx s0.ffi).nnext + T * ΔN + B.N + (Wd.NE P - (Wd.toMlx s0.ffi).nnext) < 2 ^ 62)
    (hG : ∀ i, 1 ≤ i → i + 2 < T → (∀ j, 1 ≤ j → j ≤ i + 1 → tk j ≠ 248044) →
      LoopGStepW Gx (relW Wd P W) Fr (loopSelLW cs L i).toLoopCaseW (valL ρ T tk L) toks i) :
    DecodeItersW (DecodeInvW Wd A Gx W P Fr s0 tab0 fixA (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN) T tk :=
  fun i hi1 hiT hne => ⟨_, decodeIter_selLW hA st cs hcs hi1 hiT hLT hlen htk (hne (i + 1) (by omega) le_rfl)
    (hQ i hi1 hiT) (hsh i hi1 hiT) (hkeep i hi1 hiT) (fun nx hnx => hVB i nx hi1 (by omega) hnx) hJ hH hN
    (hG i hi1 hiT hne)⟩

end Iter

/-! ## The halts -/

section Halts
variable {Wd : World} {A : Addr} {Gx : Nat → Map → St Wd.F.S → CSrv → Prop} {G : St Wd.F.S → CSrv → Prop}
  {W : Nat → Option WFrame} {P : Wd.Par} {Fr : LoopFramesA A} {s0 : St Wd.F.S} {tab0 : List SymE} {fixA : List Nat}
  {V : LoopVals} {T : Nat} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {B : LoopBase} {ΔJ ΔH ΔN : Nat}
  {env : Env} {nm : Name}

/-- **A halting chain from the final template start discharges the halting contract** at `T - 2`
over `Wd` (`decodeHalt_lastA`). -/
theorem decodeHalt_lastW (st : LoopStartW Wd A P s0 tab0)
    (hs : HaltSegW Wd A W P (toks.drop (T - 1)) s0 (Wd.finalStartW s0 tab0.length) (tab0 ++ [.var A.nxt])
      [.num (.ref A.tok), .num (.ref tab0.length)])
    (hfrN : ∀ e ∈ tab0, e.noVar A.nxt = true) (hcE : A.cE ∈ fixA) (hb : A.emit ∈ fixA)
    (hwc : W A.cE = none) (hwe : W A.emit = none)
    (hupd : ∀ nx, upd (V (T - 2) nx) A.nxt (F64.ofNat (tk T)) = V (T - 2) (tk T)) (hT : 3 ≤ T)
    (hlen : T - 1 ≤ toks.length) (hgood : Good (V (T - 2) (tk T)) hs.S0.oracle)
    (hQA : ∀ K : Ctx, (∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Fr.xs) → K.lo = Wd.lo P → K.hi = Wd.E P →
      hs.QA (V (T - 2) (tk T)) K)
    (henv : lookupEnv nm env = some A.cE) (hG : LastGStepW A Gx P W Fr fixA hs V tk G) :
    DecodeHaltW (DecodeInvW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN) (T - 2) hs.case.n
      (EmitGoalW env nm E0 toks (T - 1) G) := by
  intro t C hinv
  obtain ⟨tF, CF, v, hr, hv, hem, hle, hg, -⟩ := last_haltW (ks := [A.tok, tab0.length]) st (.inr rfl) hs hfrN hcE
    hb hwc hwe hupd hinv hT hlen hgood hQA henv hG
  refine ⟨tF, CF, v, hr, hv, hle, ?_, hg⟩
  rw [hem, show T - 3 + [A.tok, tab0.length].length = T - 1 by simp; omega]

/-- **A halting chain from the final template start, the look-ahead token EOS**, over `Wd`
(`decodeHalt_lastEA`), with the chain's end fact `Fin` (the finish reason). -/
theorem decodeHalt_lastEW {Fin : St Wd.F.S → Prop} (st : LoopStartW Wd A P s0 tab0)
    (hs : HaltSegW Wd A W P (toks.drop (T - 1)) s0 (Wd.finalStartW s0 tab0.length) (tab0 ++ [.var A.nxt])
      [.num (.ref A.tok)])
    (hfrN : ∀ e ∈ tab0, e.noVar A.nxt = true) (hcE : A.cE ∈ fixA) (hb : A.emit ∈ fixA)
    (hwc : W A.cE = none) (hwe : W A.emit = none)
    (hupd : ∀ nx, upd (V (T - 2) nx) A.nxt (F64.ofNat (tk T)) = V (T - 2) (tk T)) (hT : 3 ≤ T)
    (hlen : T - 1 ≤ toks.length) (hgood : Good (V (T - 2) (tk T)) hs.S0.oracle)
    (hQA : ∀ K : Ctx, (∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Fr.xs) → K.lo = Wd.lo P → K.hi = Wd.E P →
      hs.QA (V (T - 2) (tk T)) K)
    (henv : lookupEnv nm env = some A.cE) (hfin : HaltFinW hs fixA Fin)
    (hG : LastGStepW A Gx P W Fr fixA hs V tk G) :
    DecodeHaltW (DecodeInvW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN) (T - 2) hs.case.n
      (FinGoalW env nm E0 toks (T - 2) G Fin) := by
  intro t C hinv
  obtain ⟨tF, CF, v, hr, hv, hem, hle, hg, hF⟩ := last_haltW (ks := [A.tok]) st (.inl rfl) hs hfrN hcE hb
    hwc hwe hupd hinv hT hlen hgood hQA henv hG
  refine ⟨tF, CF, v, hr, hv, hle, ⟨?_, hg⟩, hF Fin hfin⟩
  rw [hem, show T - 3 + [A.tok].length = T - 2 by simp; omega]

/-- **A halting chain at the cut of iteration `J` discharges the halting contract** there over
`Wd` (`decodeHalt_cutA`), with the chain's end fact `Fin` (the finish reason). -/
theorem decodeHalt_cutW {J : Nat} {Fin : St Wd.F.S → Prop} (hs : HaltSegW Wd A W P (toks.drop J) s0 s0 tab0 [])
    (hcE : A.cE ∈ fixA)
    (hb : A.emit ∈ fixA) (hwc : W A.cE = none) (hwe : W A.emit = none)
    (hgood : ∀ nx, nx ≤ 2 ^ 20 → Good (V J nx) hs.S0.oracle)
    (hQA : ∀ nx (K : Ctx), nx ≤ 2 ^ 20 → (∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Fr.xs) → K.lo = Wd.lo P →
      K.hi = Wd.E P → hs.QA (V J nx) K)
    (henv : lookupEnv nm env = some A.cE) (hfin : HaltFinW hs fixA Fin)
    (hG : CutGStepW A Gx P W Fr fixA hs V G) :
    DecodeHaltW (DecodeInvW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN) J hs.case.n
      (FinGoalW env nm E0 toks (J - 1) G Fin) := by
  intro t C hinv
  obtain ⟨tF, CF, v, hr, hv, hem, hle, hg, hF⟩ := cut_haltW hs hcE hb hwc hwe hinv hgood hQA henv hG
  exact ⟨tF, CF, v, hr, hv, hle, ⟨hem, hg⟩, hF Fin hfin⟩

/-- **The three final chains discharge the halting contract** at `T - 2` by the cache-clear tests
of the last two tokens over `Wd` (`decodeHalt_last3A`), over `valL`, each chain's oracle decided
over its class's boxes (`FinalOk`). -/
theorem decodeHalt_last3W (hA : A.nxt = 17) (st : LoopStartW Wd A P s0 tab0) {L : Nat} {ρ : Nat → F64}
    (F0 F1 F2 : HaltSegW Wd A W P (toks.drop (T - 1)) s0 (Wd.finalStartW s0 tab0.length) (tab0 ++ [.var A.nxt])
      [.num (.ref A.tok), .num (.ref tab0.length)])
    (c0 : FinalOk false false F0.S0.oracle) (c1 : FinalOk true false F1.S0.oracle)
    (c2 : FinalOk false true F2.S0.oracle)
    (hfrN : ∀ e ∈ tab0, e.noVar A.nxt = true) (hcE : A.cE ∈ fixA) (hb : A.emit ∈ fixA)
    (hwc : W A.cE = none) (hwe : W A.emit = none) (hT : 3 ≤ T)
    (hLT : L + T < 2 ^ 29) (hlen : T - 1 ≤ toks.length) (htk : ∀ j, j ≤ T → tk j ≤ 2 ^ 20)
    (notEos : ∀ k, 2 ≤ k → k ≤ T → tk k ≠ 248044)
    (hQA : ∀ K : Ctx, (∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Fr.xs) → K.lo = Wd.lo P → K.hi = Wd.E P →
      F0.QA (valL ρ T tk L (T - 2) (tk T)) K ∧ F1.QA (valL ρ T tk L (T - 2) (tk T)) K ∧
        F2.QA (valL ρ T tk L (T - 2) (tk T)) K)
    (henv : lookupEnv nm env = some A.cE)
    (hF : (T - 2) % 256 ≠ 0 → (T - 1) % 256 ≠ 0 → LastGStepW A Gx P W Fr fixA F0 (valL ρ T tk L) tk G)
    (hF0 : (T - 2) % 256 = 0 → LastGStepW A Gx P W Fr fixA F1 (valL ρ T tk L) tk G)
    (hF1 : (T - 1) % 256 = 0 → LastGStepW A Gx P W Fr fixA F2 (valL ρ T tk L) tk G) :
    ∃ n, DecodeHaltW (DecodeInvW Wd A Gx W P Fr s0 tab0 fixA (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN) (T - 2) n
      (EmitGoalW env nm E0 toks (T - 1) G) := by
  have hupd : ∀ nx, upd (valL ρ T tk L (T - 2) nx) A.nxt (F64.ofNat (tk T)) = valL ρ T tk L (T - 2) (tk T) :=
    fun _ => by rw [hA]; exact upd_valL _
  have hg : ∀ {r3 r7 : Bool} {o : List Ans}, FinalOk r3 r7 o → decide ((T - 2) % 256 = 0) = r3 →
      decide ((T - 2 + 1) % 256 = 0) = r7 → Good (valL ρ T tk L (T - 2) (tk T)) o := fun hc h3 h7 =>
    good_finalW hc (by omega) (by omega) (notEos (T - 2 + 1) (by omega) (by omega)) (notEos T (by omega) le_rfl)
      (by omega) (by have := htk (T - 2 + 1) (by omega); omega) (by have := htk T le_rfl; omega) h3 h7
  by_cases hc0 : (T - 2) % 256 = 0
  · exact ⟨_, decodeHalt_lastW st F1 hfrN hcE hb hwc hwe hupd hT hlen
      (hg c1 (decide_eq_true hc0) (decide_eq_false (by omega)))
      (fun K h1 h2 h3 => (hQA K h1 h2 h3).2.1) henv (hF0 hc0)⟩
  · by_cases hc1 : (T - 1) % 256 = 0
    · exact ⟨_, decodeHalt_lastW st F2 hfrN hcE hb hwc hwe hupd hT hlen
        (hg c2 (decide_eq_false hc0) (decide_eq_true (by omega)))
        (fun K h1 h2 h3 => (hQA K h1 h2 h3).2.2) henv (hF1 hc1)⟩
    · exact ⟨_, decodeHalt_lastW st F0 hfrN hcE hb hwc hwe hupd hT hlen
        (hg c0 (decide_eq_false hc0) (decide_eq_false (by omega)))
        (fun K h1 h2 h3 => (hQA K h1 h2 h3).1) henv (hF hc0 hc1)⟩

end Halts

/-! ## End to end -/

/-- **The decode route after a prompt of length `L`, end to end, over `Wd`** (`decode_sourceLA`):
the iterations (`hit`: however each is proven, e.g. `LoopCasesW.iterW`), the three final chains
with their oracles decided over their boxes. -/
theorem decode_sourceLW {Wd : World} {A : Addr} {Gx : Nat → Map → St Wd.F.S → CSrv → Prop}
    {G : St Wd.F.S → CSrv → Prop} {W : Nat → Option WFrame} {P : Wd.Par} {Fr : LoopFramesA A} {s0 : St Wd.F.S}
    {tab0 : List SymE} {fixA : List Nat} (hA : A.nxt = 17) (st : LoopStartW Wd A P s0 tab0)
    (hfrN : ∀ e ∈ tab0, e.noVar A.nxt = true) (hcE : A.cE ∈ fixA) (hb : A.emit ∈ fixA)
    (hwc : W A.cE = none) (hwe : W A.emit = none) {L ΔJ ΔH ΔN : Nat}
    {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {B : LoopBase}
    {env : Env} {nm : Name}
    (hit : ∀ i, 1 ≤ i → i + 2 < T →
      ∃ n, DecodeIterW (DecodeInvW Wd A Gx W P Fr s0 tab0 fixA (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN) i n)
    (F0 F1 F2 : HaltSegW Wd A W P (toks.drop (T - 1)) s0 (Wd.finalStartW s0 tab0.length) (tab0 ++ [.var A.nxt])
      [.num (.ref A.tok), .num (.ref tab0.length)])
    (c0 : FinalOk false false F0.S0.oracle) (c1 : FinalOk true false F1.S0.oracle)
    (c2 : FinalOk false true F2.S0.oracle)
    (hQA : ∀ K : Ctx, (∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Fr.xs) → K.lo = Wd.lo P → K.hi = Wd.E P →
      F0.QA (valL ρ T tk L (T - 2) (tk T)) K ∧ F1.QA (valL ρ T tk L (T - 2) (tk T)) K ∧
        F2.QA (valL ρ T tk L (T - 2) (tk T)) K)
    (henv : lookupEnv nm env = some A.cE)
    (hT : 3 ≤ T) (hLT : L + T < 2 ^ 29) (hlen : T - 1 ≤ toks.length)
    (htk : ∀ j, j ≤ T → tk j ≤ 2 ^ 20) (notEos : ∀ k, 2 ≤ k → k ≤ T → tk k ≠ 248044)
    (hF : (T - 2) % 256 ≠ 0 → (T - 1) % 256 ≠ 0 → LastGStepW A Gx P W Fr fixA F0 (valL ρ T tk L) tk G)
    (hF0 : (T - 2) % 256 = 0 → LastGStepW A Gx P W Fr fixA F1 (valL ρ T tk L) tk G)
    (hF1 : (T - 1) % 256 = 0 → LastGStepW A Gx P W Fr fixA F2 (valL ρ T tk L) tk G)
    {N0 : Nat} {t0 t1 : St Wd.F.S} {C0 C1 : CSrv} (hpre : runC Wd.F N0 t0 C0 = some (t1, C1))
    (h1 : DecodeInvW Wd A Gx W P Fr s0 tab0 fixA (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN 1 t1 C1) :
    ∃ N tF CF, (∀ n, N ≤ n → runC Wd.F n t0 C0 = some (tF, CF)) ∧ (∃ v, tF.ctl = .halt (.normal v)) ∧
      CSrv.Le C1 CF ∧ EmitGoalW env nm E0 toks (T - 1) G tF CF :=
  decode_sourceW hT hit
    (decodeHalt_last3W hA st F0 F1 F2 c0 c1 c2 hfrN hcE hb hwc hwe hT hLT hlen htk notEos hQA henv hF hF0 hF1)
    hpre h1

/-- **The decode route's EOS stop after a prompt of length `L`, end to end, over `Wd`**
(`decode_source_eosLA`): token `k` (`2 ≤ k ≤ T`) is EOS and the tokens before it are not; the
target halts with the `emitted` binding the base prefix and the first `k - 2` readbacks, and the
halting chains' end fact `Fin` holds (at `stopFin`: `generation.stats.finishReason` is `"stop"`).
The iterations before the stop are `hit`; the chains' oracles are decided over their boxes
(`ExitOk`, `FinalEOk`). -/
theorem decode_source_eosLW {Wd : World} {A : Addr} {Gx : Nat → Map → St Wd.F.S → CSrv → Prop}
    {G : St Wd.F.S → CSrv → Prop} {W : Nat → Option WFrame} {P : Wd.Par} {Fr : LoopFramesA A} {s0 : St Wd.F.S}
    {tab0 : List SymE} {fixA : List Nat} (hA : A.nxt = 17) (st : LoopStartW Wd A P s0 tab0)
    (hfrN : ∀ e ∈ tab0, e.noVar A.nxt = true) (hcE : A.cE ∈ fixA) (hb : A.emit ∈ fixA)
    (hwc : W A.cE = none) (hwe : W A.emit = none) {L ΔJ ΔH ΔN : Nat}
    {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {B : LoopBase}
    {env : Env} {nm : Name} {Fin : St Wd.F.S → Prop} (k : Nat) (hk2 : 2 ≤ k) (hkT : k ≤ T)
    (hit : ∀ i, 1 ≤ i → i + 1 < k → i + 2 < T →
      ∃ n, DecodeIterW (DecodeInvW Wd A Gx W P Fr s0 tab0 fixA (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN) i n)
    (X : HaltSegW Wd A W P (toks.drop (k - 1)) s0 s0 tab0 []) (cX : ExitOk X.S0.oracle)
    (FE0 FE1 : HaltSegW Wd A W P (toks.drop (T - 1)) s0 (Wd.finalStartW s0 tab0.length) (tab0 ++ [.var A.nxt])
      [.num (.ref A.tok)])
    (c0 : FinalEOk false FE0.S0.oracle) (c1 : FinalEOk true FE1.S0.oracle)
    (hQX : k < T → ∀ nx (K : Ctx), nx ≤ 2 ^ 20 → (∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Fr.xs) →
      K.lo = Wd.lo P → K.hi = Wd.E P → X.QA (valL ρ T tk L (k - 1) nx) K)
    (hQE : ∀ K : Ctx, (∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Fr.xs) → K.lo = Wd.lo P → K.hi = Wd.E P →
      FE0.QA (valL ρ T tk L (T - 2) (tk T)) K ∧ FE1.QA (valL ρ T tk L (T - 2) (tk T)) K)
    (sX : k < T → HaltFinW X fixA Fin) (s0E : k = T → HaltFinW FE0 fixA Fin)
    (s1E : k = T → HaltFinW FE1 fixA Fin)
    (henv : lookupEnv nm env = some A.cE)
    (hT : 3 ≤ T) (hLT : L + T < 2 ^ 29) (hlen : T - 1 ≤ toks.length) (htk : ∀ j, j ≤ T → tk j ≤ 2 ^ 20)
    (notEos : ∀ j, 2 ≤ j → j < k → tk j ≠ 248044) (eos : tk k = 248044)
    (hX : k < T → CutGStepW A Gx P W Fr fixA X (valL ρ T tk L) G)
    (hF : k = T → (T - 2) % 256 ≠ 0 → LastGStepW A Gx P W Fr fixA FE0 (valL ρ T tk L) tk G)
    (hF0 : k = T → (T - 2) % 256 = 0 → LastGStepW A Gx P W Fr fixA FE1 (valL ρ T tk L) tk G)
    {N0 : Nat} {t0 t1 : St Wd.F.S} {C0 C1 : CSrv} (hpre : runC Wd.F N0 t0 C0 = some (t1, C1))
    (h1 : DecodeInvW Wd A Gx W P Fr s0 tab0 fixA (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN 1 t1 C1) :
    ∃ N tF CF, (∀ n, N ≤ n → runC Wd.F n t0 C0 = some (tF, CF)) ∧ (∃ v, tF.ctl = .halt (.normal v)) ∧
      CSrv.Le C1 CF ∧ FinGoalW env nm E0 toks (k - 2) G Fin tF CF := by
  have hupd : ∀ nx, upd (valL ρ T tk L (T - 2) nx) A.nxt (F64.ofNat (tk T)) = valL ρ T tk L (T - 2) (tk T) :=
    fun _ => by rw [hA]; exact upd_valL _
  exact decode_source_eosW hT k hk2 hkT hit
    (fun hk => by
      have hd := decodeHalt_cutW (tk := tk) (E0 := E0) (B := B) (ΔJ := ΔJ) (ΔH := ΔH) (ΔN := ΔN) (env := env)
        (nm := nm) X hcE hb hwc hwe
        (fun nx hnx => good_exitW cX (by omega) (by omega) (by rw [show k - 1 + 1 = k by omega]; exact eos) hnx
          (by omega) (by omega))
        (hQX hk) henv (sX hk) (hX hk)
      rw [show k - 1 - 1 = k - 2 by omega] at hd
      exact ⟨_, hd⟩)
    (fun hk => by
      subst hk
      have hg : ∀ {r3 : Bool} {o : List Ans}, FinalEOk r3 o → decide ((k - 2) % 256 = 0) = r3 →
          Good (valL ρ k tk L (k - 2) (tk k)) o := fun hc h3 =>
        good_finalEW hc (by omega) (by omega) (notEos (k - 2 + 1) (by omega) (by omega)) eos (by omega)
          (by have := htk (k - 2 + 1) (by omega); omega) h3
      by_cases hc0 : (k - 2) % 256 = 0
      · exact ⟨_, decodeHalt_lastEW st FE1 hfrN hcE hb hwc hwe hupd hT hlen (hg c1 (decide_eq_true hc0))
          (fun K h1 h2 h3 => (hQE K h1 h2 h3).2) henv (s1E rfl) (hF0 rfl hc0)⟩
      · exact ⟨_, decodeHalt_lastEW st FE0 hfrN hcE hb hwc hwe hupd hT hlen (hg c0 (decide_eq_false hc0))
          (fun K h1 h2 h3 => (hQE K h1 h2 h3).1) henv (s0E rfl) (hF rfl hc0)⟩)
    hpre h1

end Host.Ts.Sim
