import host.sim.DecodeAddrHalt
import host.sim.DecodeSeam
namespace Host.Ts.Sim
open Host.Ts Host.Ts.Sim.Template

/-! # The decode route at a driver's constants, under the frame relation

The seam route (`DecodeSeam.lean`) over the invariant `LoopInvA` at the constants `A`, the frames
`W` (the relation family `relLW P W`, `relRelF`) and a valuation family `V`: `DecodeInvA`,
`decode_sourceA`, `decode_source_eosA`. The whole-iteration templates discharge its contracts:

* per iteration, a checked case (`decodeIter_caseA`, `loop_stepA`), the selected one of six at
  prompt length `L` over `valL` (`LoopCasesA`, `loopSelLA`, `decodeIter_selLA`) with the case's
  iteration theorem under the frames from its shift (`iterF_relFA`, `ShiftFWA`);
* at the end, a halting chain (`decodeHalt_lastA`, `decodeHalt_lastEA`, `decodeHalt_cutA`), the
  three final chains by the cache-clear tests (`decodeHalt_last3A`).

`decode_sourceLA` is the decode route after a prompt of length `L` end to end with frames `W`
at the constants `A`, `decode_source_eosLA` its EOS stop. At `addr0` without frames the
invariant is `LoopInvLF` (`DecodeInvA_addr0`), the cases are today's (`LoopCases.toA`,
`loopSelLA_toA`, `LoopCases.OkAt.toA`), and `loop_sourceL_addr`, `loop_source_eosL_addr`
(DecodeAddrCheck.lean) have `loop_sourceL`'s and `loop_source_eosL`'s statements (at today's
`emitted` cell). The valuation `valL` is today's template layout: its discharges assume the
driver's look-ahead variable is `valL`'s (`A.nxt = 17`). -/

/-! ## The route -/

/-- **The decode loop's seam invariant** at the constants `A`, frames `W`, valuations `V`. -/
abbrev DecodeInvA (A : Addr) (Gx : Nat → Map → St LF.S → CSrv → Prop) (W : Nat → Option WFrame) (P : LoadP)
    (Fr : LoopFramesA A) (s0 : St LF.S) (tab0 : List SymE) (fixA : List Nat) (V : LoopVals) (tk : Nat → Nat)
    (toks : List NumV) (E0 : List Val) (B : LoopBase) (ΔJ ΔH ΔN : Nat) : CutInv :=
  fun i t C => LoopInvA A Gx (relLW P W) P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN i t C

/-- **At today's constants without frames it is `LoopInvLF`.** -/
theorem DecodeInvA_addr0 {Gx : Nat → Map → St LF.S → CSrv → Prop} {P : LoadP} {Fr : LoopFrames} {s0 : St LF.S}
    {tab0 : List SymE} {fixA : List Nat} {L : Nat} {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat} {toks : List NumV}
    {E0 : List Val} {B : LoopBase} {ΔJ ΔH ΔN : Nat} :
    DecodeInvA addr0 Gx noFrames P Fr.toA s0 tab0 fixA (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN =
      LoopInvLF Gx (relL P) P Fr s0 tab0 fixA L ρ T tk toks E0 B ΔJ ΔH ΔN := rfl

section Route
variable {A : Addr} {Gx : Nat → Map → St LF.S → CSrv → Prop} {W : Nat → Option WFrame} {P : LoadP}
  {Fr : LoopFramesA A} {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat} {V : LoopVals} {T : Nat}
  {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {B : LoopBase} {ΔJ ΔH ΔN : Nat}
  {Goal : St LF.S → CSrv → Prop}

/-- **The decode route** at the constants `A`, frames `W` (`decode_sourceL`). -/
theorem decode_sourceA (hT : 3 ≤ T)
    (hit : ∀ i, 1 ≤ i → i + 2 < T → ∃ n, DecodeIter (DecodeInvA A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN) i n)
    (hfin : ∃ n, DecodeHalt (DecodeInvA A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN) (T - 2) n Goal)
    {N0 : Nat} {t0 t1 : St LF.S} {C0 C1 : CSrv} (hpre : runC LF N0 t0 C0 = some (t1, C1))
    (h1 : DecodeInvA A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN 1 t1 C1) :
    ∃ N tF CF, (∀ m, N ≤ m → runC LF m t0 C0 = some (tF, CF)) ∧ (∃ v, tF.ctl = .halt (.normal v)) ∧
      CSrv.Le C1 CF ∧ Goal tF CF :=
  decode_route_to (by omega) (fun i h1 h2 => hit i h1 (by omega)) hfin hpre h1

/-- **The decode route's EOS stop** at the constants `A`, frames `W` (`decode_source_eosL`). -/
theorem decode_source_eosA (hT : 3 ≤ T) (k : Nat) (hk2 : 2 ≤ k) (hkT : k ≤ T)
    (hit : ∀ i, 1 ≤ i → i + 1 < k → i + 2 < T →
      ∃ n, DecodeIter (DecodeInvA A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN) i n)
    (hX : k < T → ∃ n, DecodeHalt (DecodeInvA A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN) (k - 1) n Goal)
    (hF : k = T → ∃ n, DecodeHalt (DecodeInvA A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN) (T - 2) n Goal)
    {N0 : Nat} {t0 t1 : St LF.S} {C0 C1 : CSrv} (hpre : runC LF N0 t0 C0 = some (t1, C1))
    (h1 : DecodeInvA A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN 1 t1 C1) :
    ∃ N tF CF, (∀ m, N ≤ m → runC LF m t0 C0 = some (tF, CF)) ∧ (∃ v, tF.ctl = .halt (.normal v)) ∧
      CSrv.Le C1 CF ∧ Goal tF CF := by
  by_cases hk : k < T
  · exact decode_route_to (by omega) (fun i h1 h2 => hit i h1 (by omega) (by omega)) (hX hk) hpre h1
  · exact decode_route_to (by omega) (fun i h1 h2 => hit i h1 (by omega) (by omega)) (hF (by omega)) hpre h1

end Route

/-! ## Per iteration -/

section Iter
variable {A : Addr} {Gx : Nat → Map → St LF.S → CSrv → Prop} {ok : St LF.S → SSrv → Bool} {W : Nat → Option WFrame}
  {P : LoadP} {Fr : LoopFramesA A} {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat} {VBOk : (Nat → F64) → Prop}
  {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {B : LoopBase} {ΔJ ΔH ΔN : Nat}

/-- A loop case's counter deltas are within `ΔJ`, `ΔH`, `ΔN`. -/
def LoopCaseA.Within (c : LoopCaseA A ok P s0 tab0 fixA) (ΔJ ΔH ΔN : Nat) : Prop :=
  c.s1.next - s0.next ≤ ΔJ ∧ c.s1.ffi.mlx.next - s0.ffi.mlx.next ≤ ΔH ∧ c.s1.ffi.mlx.nnext - s0.ffi.mlx.nnext ≤ ΔN

/-- **A loop case discharges the per-iteration contract** at iteration `i` (`loop_stepA`). -/
theorem decodeIter_caseA {V : LoopVals} (st : LoopStartA A P s0 tab0) (c : LoopCaseA A ok P s0 tab0 fixA)
    (hit : c.IterFA (relLW P W) Fr VBOk) (hkeep : c.KeepsA Fr) {i : Nat} (hi1 : 1 ≤ i) (hlen : i < toks.length)
    (hgood : ∀ nx, Good (V i nx) c.S0.oracle) (hVB : ∀ nx, nx ≤ 2 ^ 20 → VBOk (V i nx))
    (hnext : ∀ nx, Shift.valuation c.θ (upd (V i nx) A.nxt (F64.ofNat (tk (i + 2)))) = V (i + 1) (tk (i + 2)))
    (htk : tk (i + 2) ≤ 2 ^ 20) (hw : c.Within ΔJ ΔH ΔN)
    (hJ : i * ΔJ + B.D < Sim.bound) (hH : s0.ffi.mlx.next + i * ΔH + B.H + (P.E - s0.ffi.mlx.next) < 2 ^ 46)
    (hN : s0.ffi.mlx.nnext + i * ΔN + B.N + (P.NE - s0.ffi.mlx.nnext) < 2 ^ 62)
    (hG : LoopGStepA Gx (relLW P W) Fr c V toks i) :
    DecodeIter (DecodeInvA A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN) i c.n :=
  fun _ _ hinv => loop_stepA (relRelF P W) Fr st c hit hkeep hinv hi1 hlen hgood hVB hnext htk hw.1 hw.2.1 hw.2.2
    hJ hH hN hG

/-- The six loop cases at the constants `A` (`LoopCases`). -/
structure LoopCasesA (A : Addr) (ok : St LF.S → SSrv → Bool) (P : LoadP) (s0 : St LF.S) (tab0 : List SymE)
    (fixA : List Nat) where
  ord : LoopCaseA A ok P s0 tab0 fixA
  clear : LoopCaseA A ok P s0 tab0 fixA
  grow : LoopCaseA A ok P s0 tab0 fixA
  fill : LoopCaseA A ok P s0 tab0 fixA
  clearFill : LoopCaseA A ok P s0 tab0 fixA
  clearGrow : LoopCaseA A ok P s0 tab0 fixA

/-- Today's six cases. -/
def LoopCases.toA (cs : LoopCases ok P s0 tab0 fixA) : LoopCasesA addr0 ok P s0 tab0 fixA :=
  ⟨cs.ord.toA, cs.clear.toA, cs.grow.toA, cs.fill.toA, cs.clearFill.toA, cs.clearGrow.toA⟩

/-- **The loop case of iteration `i` after a prompt of length `L`** (`loopSelL`). -/
def loopSelLA (cs : LoopCasesA A ok P s0 tab0 fixA) (L i : Nat) : LoopCaseA A ok P s0 tab0 fixA :=
  if i % 256 = 0 then
    (if (L + i + 1) % 256 = 0 then cs.clearGrow else if (L + i + 1) % 256 = 255 then cs.clearFill else cs.clear)
  else if (L + i + 1) % 256 = 0 then cs.grow else if (L + i + 1) % 256 = 255 then cs.fill else cs.ord

theorem loopSelLA_toA (cs : LoopCases ok P s0 tab0 fixA) (L i : Nat) :
    loopSelLA cs.toA L i = (loopSelL cs L i).toA := by
  unfold loopSelLA loopSelL
  by_cases h1 : i % 256 = 0 <;> by_cases h2 : (L + i + 1) % 256 = 0 <;> by_cases h3 : (L + i + 1) % 256 = 255 <;>
    simp [h1, h2, h3, LoopCases.toA]

theorem loopSelLA_cases (cs : LoopCasesA A ok P s0 tab0 fixA) (L i : Nat) :
    (i % 256 = 0 ∧ (L + i + 1) % 256 = 0 ∧ loopSelLA cs L i = cs.clearGrow) ∨
    (i % 256 = 0 ∧ (L + i + 1) % 256 = 255 ∧ loopSelLA cs L i = cs.clearFill) ∨
    (i % 256 = 0 ∧ (L + i + 1) % 256 ≠ 0 ∧ (L + i + 1) % 256 ≠ 255 ∧ loopSelLA cs L i = cs.clear) ∨
    (i % 256 ≠ 0 ∧ (L + i + 1) % 256 = 0 ∧ loopSelLA cs L i = cs.grow) ∨
    (i % 256 ≠ 0 ∧ (L + i + 1) % 256 = 255 ∧ loopSelLA cs L i = cs.fill) ∨
    (i % 256 ≠ 0 ∧ (L + i + 1) % 256 ≠ 0 ∧ (L + i + 1) % 256 ≠ 255 ∧ loopSelLA cs L i = cs.ord) := by
  unfold loopSelLA
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

/-- **The six cases' template facts** (`LoopCases.Facts`). -/
structure LoopCasesA.Facts (cs : LoopCasesA A ok P s0 tab0 fixA) (ΔJ ΔH ΔN : Nat) : Prop where
  cOrd : cs.ord.S0.oracle.all (fun q => ordD.contains q) = true
  cClear : cs.clear.S0.oracle.all (fun q => clearD.contains q) = true
  cGrow : cs.grow.S0.oracle.all (fun q => growD.contains q) = true
  cFill : cs.fill.S0.oracle.all (fun q => fillD.contains q) = true
  cClearFill : cs.clearFill.S0.oracle.all (fun q => clearFillD.contains q) = true
  cClearGrow : cs.clearGrow.S0.oracle.all (fun q => clearGrowD.contains q) = true
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

/-- **What the loop needs of the cases at prompt length `L`** (`LoopCases.OkAt`). -/
structure LoopCasesA.OkAt (cs : LoopCasesA A ok P s0 tab0 fixA) (L ΔJ ΔH ΔN : Nat) : Prop where
  grow : ∀ i, (loopSelLA cs L i).grow = decide ((L + i + 1) % 256 = 0)
  good : ∀ (ρ : Nat → F64) (T : Nat) (tk : Nat → Nat) (i nx : Nat), 1 ≤ i → i + 2 < T → L + T < 2 ^ 29 →
    tk (i + 1) ≠ 248044 → tk (i + 1) < 2 ^ 32 → Good (valL ρ T tk L i nx) (loopSelLA cs L i).S0.oracle
  within : ∀ i, (loopSelLA cs L i).Within ΔJ ΔH ΔN

/-- Today's cases' facts. -/
theorem LoopCases.OkAt.toA {cs : LoopCases ok P s0 tab0 fixA} {L : Nat} (h : cs.OkAt L ΔJ ΔH ΔN) :
    cs.toA.OkAt L ΔJ ΔH ΔN where
  grow i := by rw [loopSelLA_toA]; exact h.grow i
  good ρ T tk i nx h1 h2 h3 h4 h5 := by rw [loopSelLA_toA]; exact h.good ρ T tk i nx h1 h2 h3 h4 h5
  within i := by rw [loopSelLA_toA]; exact h.within i

/-- **The six cases at every prompt length**, from their template facts (`LoopCases.okAt`). -/
theorem LoopCasesA.okAt {cs : LoopCasesA A ok P s0 tab0 fixA} (hf : cs.Facts ΔJ ΔH ΔN) (L : Nat) :
    cs.OkAt L ΔJ ΔH ΔN where
  grow i := by
    rcases loopSelLA_cases cs L i with ⟨_, h, e⟩ | ⟨_, h, e⟩ | ⟨_, h, _, e⟩ | ⟨_, h, e⟩ | ⟨_, h, e⟩ | ⟨_, h, _, e⟩ <;>
      rw [e]
    · rw [hf.gClearGrow]; simp [h]
    · rw [hf.gClearFill]; simp [h]
    · rw [hf.gClear]; simp [h]
    · rw [hf.gGrow]; simp [h]
    · rw [hf.gFill]; simp [h]
    · rw [hf.gOrd]; simp [h]
  good ρ T tk i nx hi1 hT hLT htok ht := by
    rcases loopSelLA_cases cs L i with ⟨h1, h2, e⟩ | ⟨h1, h2, e⟩ | ⟨h1, h2, h3, e⟩ | ⟨h1, h2, e⟩ | ⟨h1, h2, e⟩ |
      ⟨h1, h2, h3, e⟩ <;> rw [e]
    · exact good_of_mem (good_clearGrowL hi1 h1 h2 hT (by omega) (by omega) htok ht) hf.cClearGrow
    · exact good_of_mem (good_clearFillL hi1 h1 h2 hT (by omega) (by omega) htok ht) hf.cClearFill
    · exact good_of_mem (good_clearL hi1 h1 h2 h3 hT (by omega) (by omega) htok ht) hf.cClear
    · exact good_of_mem (good_growL h1 h2 hT (by omega) (by omega) htok ht) hf.cGrow
    · exact good_of_mem (good_fillL h1 h2 hT (by omega) (by omega) htok ht) hf.cFill
    · exact good_of_mem (good_ordL h1 h2 h3 hT (by omega) (by omega) htok ht) hf.cOrd
  within i := by
    rcases loopSelLA_cases cs L i with ⟨_, _, e⟩ | ⟨_, _, e⟩ | ⟨_, _, _, e⟩ | ⟨_, _, e⟩ | ⟨_, _, e⟩ | ⟨_, _, _, e⟩ <;>
      rw [e]
    · exact hf.dClearGrow
    · exact hf.dClearFill
    · exact hf.dClear
    · exact hf.dGrow
    · exact hf.dFill
    · exact hf.dOrd

/-- **The selected case discharges the per-iteration contract** at iteration `i` after a prompt of
length `L` (`decodeIter_case`), under the frames `W`: the loop acceptance's simulation under the
frames `S`, the case's shift under the frames and its keeping the further frames. -/
theorem decodeIter_selLA (hA : A.nxt = 17) (S : AccSimW P W VBOk ok (A.fwd :: A.emit :: Fr.xs))
    (st : LoopStartA A P s0 tab0) (cs : LoopCasesA A ok P s0 tab0 fixA) {L : Nat} (hcs : cs.OkAt L ΔJ ΔH ΔN)
    {ρ : Nat → F64} {T i : Nat} (hi1 : 1 ≤ i) (hiT : i + 2 < T) (hLT : L + T < 2 ^ 29)
    (hlen : T - 2 ≤ toks.length) (htk : ∀ j, j ≤ T → tk j ≤ 2 ^ 20) (notEos : tk (i + 1) ≠ 248044)
    (hsh : (loopSelLA cs L i).ShiftFWA Fr W) (hkeep : (loopSelLA cs L i).KeepsA Fr)
    (hVB : ∀ nx, nx ≤ 2 ^ 20 → VBOk (valL ρ T tk L i nx))
    (hJ : T * ΔJ + B.D < Sim.bound) (hH : s0.ffi.mlx.next + T * ΔH + B.H + (P.E - s0.ffi.mlx.next) < 2 ^ 46)
    (hN : s0.ffi.mlx.nnext + T * ΔN + B.N + (P.NE - s0.ffi.mlx.nnext) < 2 ^ 62)
    (hG : LoopGStepA Gx (relLW P W) Fr (loopSelLA cs L i) (valL ρ T tk L) toks i) :
    DecodeIter (DecodeInvA A Gx W P Fr s0 tab0 fixA (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN) i
      (loopSelLA cs L i).n := by
  have hmul : ∀ D, i * D ≤ T * D := fun D => Nat.mul_le_mul_right D (by omega)
  exact decodeIter_caseA st (loopSelLA cs L i)
    ((loopSelLA cs L i).iterF_relFA Fr W S.sim S.hj.1 S.hj.2.1 S.hj.2.2 S.ng st hsh) hkeep hi1 (by omega)
    (fun nx => hcs.good ρ T tk i nx hi1 hiT hLT notEos (by have := htk (i + 1) (by omega); omega)) hVB
    (fun _ => by
      rw [hA]
      exact next_valL (loopSelLA cs L i).grow (fun j => by rw [(loopSelLA cs L i).theta j, hA]) (by omega)
        (by have := capL_le (L + i + 1); omega) (hcs.grow i))
    (htk (i + 2) (by omega)) (hcs.within i)
    (by have := hmul ΔJ; omega) (by have := hmul ΔH; omega) (by have := hmul ΔN; omega) hG

end Iter

/-! ## The halts -/

section Halts
variable {A : Addr} {Gx : Nat → Map → St LF.S → CSrv → Prop} {G : St LF.S → CSrv → Prop} {W : Nat → Option WFrame}
  {P : LoadP} {Fr : LoopFramesA A} {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat} {V : LoopVals} {T : Nat}
  {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {B : LoopBase} {ΔJ ΔH ΔN : Nat} {env : Env} {nm : Name}

/-- **A halting chain from the final template start discharges the halting contract** at `T - 2`
(`decodeHalt_final`): the `emitted` binding holds the base prefix and the first `T - 1`
readbacks. -/
theorem decodeHalt_lastA (st : LoopStartA A P s0 tab0)
    (hs : HaltSegA A W P (toks.drop (T - 1)) s0 (finalStart s0 tab0.length) (tab0 ++ [.var A.nxt])
      [.num (.ref A.tok), .num (.ref tab0.length)])
    (hfrN : ∀ e ∈ tab0, e.noVar A.nxt = true) (hcE : A.cE ∈ fixA) (hb : A.emit ∈ fixA)
    (hwc : W A.cE = none) (hwe : W A.emit = none)
    (hupd : ∀ nx, upd (V (T - 2) nx) A.nxt (F64.ofNat (tk T)) = V (T - 2) (tk T)) (hT : 3 ≤ T)
    (hlen : T - 1 ≤ toks.length) (hgood : Good (V (T - 2) (tk T)) hs.S0.oracle)
    (hQA : ∀ K : Ctx, (∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Fr.xs) → K.lo = P.lo → K.hi = P.E →
      hs.QA (V (T - 2) (tk T)) K)
    (henv : lookupEnv nm env = some A.cE) (hG : LastGStepA A Gx P W Fr fixA hs V tk G) :
    DecodeHalt (DecodeInvA A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN) (T - 2) hs.case.n
      (EmitGoal env nm E0 toks (T - 1) G) := by
  intro t C hinv
  obtain ⟨tF, CF, v, hr, hv, hem, hle, hg⟩ := last_haltA (ks := [A.tok, tab0.length]) st (.inr rfl) hs hfrN hcE hb
    hwc hwe hupd hinv hT hlen hgood hQA henv hG
  refine ⟨tF, CF, v, hr, hv, hle, ?_, hg⟩
  rw [hem, show T - 3 + [A.tok, tab0.length].length = T - 1 by simp; omega]

/-- **A halting chain from the final template start, the look-ahead token EOS**, discharges the
halting contract at `T - 2` (`decodeHalt_finalE`): the first `T - 2` readbacks. -/
theorem decodeHalt_lastEA (st : LoopStartA A P s0 tab0)
    (hs : HaltSegA A W P (toks.drop (T - 1)) s0 (finalStart s0 tab0.length) (tab0 ++ [.var A.nxt])
      [.num (.ref A.tok)])
    (hfrN : ∀ e ∈ tab0, e.noVar A.nxt = true) (hcE : A.cE ∈ fixA) (hb : A.emit ∈ fixA)
    (hwc : W A.cE = none) (hwe : W A.emit = none)
    (hupd : ∀ nx, upd (V (T - 2) nx) A.nxt (F64.ofNat (tk T)) = V (T - 2) (tk T)) (hT : 3 ≤ T)
    (hlen : T - 1 ≤ toks.length) (hgood : Good (V (T - 2) (tk T)) hs.S0.oracle)
    (hQA : ∀ K : Ctx, (∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Fr.xs) → K.lo = P.lo → K.hi = P.E →
      hs.QA (V (T - 2) (tk T)) K)
    (henv : lookupEnv nm env = some A.cE) (hG : LastGStepA A Gx P W Fr fixA hs V tk G) :
    DecodeHalt (DecodeInvA A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN) (T - 2) hs.case.n
      (EmitGoal env nm E0 toks (T - 2) G) := by
  intro t C hinv
  obtain ⟨tF, CF, v, hr, hv, hem, hle, hg⟩ := last_haltA (ks := [A.tok]) st (.inl rfl) hs hfrN hcE hb
    hwc hwe hupd hinv hT hlen hgood hQA henv hG
  refine ⟨tF, CF, v, hr, hv, hle, ?_, hg⟩
  rw [hem, show T - 3 + [A.tok].length = T - 2 by simp; omega]

/-- **A halting chain at the cut of iteration `J` discharges the halting contract** there
(`decodeHalt_exit`): the first `J - 1` readbacks. -/
theorem decodeHalt_cutA {J : Nat} (hs : HaltSegA A W P (toks.drop J) s0 s0 tab0 []) (hcE : A.cE ∈ fixA)
    (hb : A.emit ∈ fixA) (hwc : W A.cE = none) (hwe : W A.emit = none) (hgood : ∀ nx, Good (V J nx) hs.S0.oracle)
    (hQA : ∀ nx (K : Ctx), nx ≤ 2 ^ 20 → (∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Fr.xs) → K.lo = P.lo →
      K.hi = P.E → hs.QA (V J nx) K)
    (henv : lookupEnv nm env = some A.cE) (hG : CutGStepA A Gx P W Fr fixA hs V G) :
    DecodeHalt (DecodeInvA A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN) J hs.case.n
      (EmitGoal env nm E0 toks (J - 1) G) := by
  intro t C hinv
  obtain ⟨tF, CF, v, hr, hv, hem, hle, hg⟩ := cut_haltA hs hcE hb hwc hwe hinv hgood hQA henv hG
  exact ⟨tF, CF, v, hr, hv, hle, hem, hg⟩

/-- **The three final chains discharge the halting contract** at `T - 2` by the cache-clear tests
of the last two tokens (`decodeHalt_final3`), over `valL`. -/
theorem decodeHalt_last3A (hA : A.nxt = 17) (st : LoopStartA A P s0 tab0) {L : Nat} {ρ : Nat → F64}
    (F0 F1 F2 : HaltSegA A W P (toks.drop (T - 1)) s0 (finalStart s0 tab0.length) (tab0 ++ [.var A.nxt])
      [.num (.ref A.tok), .num (.ref tab0.length)])
    (c0 : F0.S0.oracle.all (fun q => (finalDG false false).contains q) = true)
    (c1 : F1.S0.oracle.all (fun q => (finalDG true false).contains q) = true)
    (c2 : F2.S0.oracle.all (fun q => (finalDG false true).contains q) = true)
    (hfrN : ∀ e ∈ tab0, e.noVar A.nxt = true) (hcE : A.cE ∈ fixA) (hb : A.emit ∈ fixA)
    (hwc : W A.cE = none) (hwe : W A.emit = none) (hT : 3 ≤ T)
    (hLT : L + T < 2 ^ 29) (hlen : T - 1 ≤ toks.length) (htk : ∀ j, j ≤ T → tk j ≤ 2 ^ 20)
    (notEos : ∀ k, 2 ≤ k → k ≤ T → tk k ≠ 248044)
    (hQA : ∀ K : Ctx, (∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Fr.xs) → K.lo = P.lo → K.hi = P.E →
      F0.QA (valL ρ T tk L (T - 2) (tk T)) K ∧ F1.QA (valL ρ T tk L (T - 2) (tk T)) K ∧
        F2.QA (valL ρ T tk L (T - 2) (tk T)) K)
    (henv : lookupEnv nm env = some A.cE)
    (hF : (T - 2) % 256 ≠ 0 → (T - 1) % 256 ≠ 0 → LastGStepA A Gx P W Fr fixA F0 (valL ρ T tk L) tk G)
    (hF0 : (T - 2) % 256 = 0 → LastGStepA A Gx P W Fr fixA F1 (valL ρ T tk L) tk G)
    (hF1 : (T - 1) % 256 = 0 → LastGStepA A Gx P W Fr fixA F2 (valL ρ T tk L) tk G) :
    ∃ n, DecodeHalt (DecodeInvA A Gx W P Fr s0 tab0 fixA (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN) (T - 2) n
      (EmitGoal env nm E0 toks (T - 1) G) := by
  have hupd : ∀ nx, upd (valL ρ T tk L (T - 2) nx) A.nxt (F64.ofNat (tk T)) = valL ρ T tk L (T - 2) (tk T) :=
    fun _ => by rw [hA]; exact upd_valL _
  have hg := good_finalGL (ρ := ρ) (T := T) (tk := tk) (L := L) (i := T - 2) (nx := tk T) (by omega) (by omega)
    (notEos (T - 2 + 1) (by omega) (by omega)) (notEos T (by omega) le_rfl) (by omega)
    (by have := htk (T - 2 + 1) (by omega); omega) (by have := htk T le_rfl; omega)
  by_cases hc0 : (T - 2) % 256 = 0
  · have e0 : decide ((T - 2) % 256 = 0) = true := decide_eq_true hc0
    have e1 : decide ((T - 2 + 1) % 256 = 0) = false := decide_eq_false (by omega)
    rw [e0, e1] at hg
    exact ⟨_, decodeHalt_lastA st F1 hfrN hcE hb hwc hwe hupd hT hlen (good_of_mem hg c1)
      (fun K h1 h2 h3 => (hQA K h1 h2 h3).2.1) henv (hF0 hc0)⟩
  · by_cases hc1 : (T - 1) % 256 = 0
    · have e0 : decide ((T - 2) % 256 = 0) = false := decide_eq_false hc0
      have e1 : decide ((T - 2 + 1) % 256 = 0) = true := decide_eq_true (by omega)
      rw [e0, e1] at hg
      exact ⟨_, decodeHalt_lastA st F2 hfrN hcE hb hwc hwe hupd hT hlen (good_of_mem hg c2)
        (fun K h1 h2 h3 => (hQA K h1 h2 h3).2.2) henv (hF1 hc1)⟩
    · have e0 : decide ((T - 2) % 256 = 0) = false := decide_eq_false hc0
      have e1 : decide ((T - 2 + 1) % 256 = 0) = false := decide_eq_false (by omega)
      rw [e0, e1] at hg
      exact ⟨_, decodeHalt_lastA st F0 hfrN hcE hb hwc hwe hupd hT hlen (good_of_mem hg c0)
        (fun K h1 h2 h3 => (hQA K h1 h2 h3).1) henv (hF hc0 hc1)⟩

end Halts

/-! ## End to end -/

/-- **The decode route after a prompt of length `L`, end to end, at the constants `A` under the
frames `W`** (`loop_sourceL`): the loop acceptance's simulation under the frames, the six cases'
facts at `L` with each selected case's shift under the frames and keeping the further frames, the
three final chains; from any run reaching the decode cut where the seam invariant holds, the
target halts with the `emitted` binding the base prefix and the first `T - 1` readbacks. -/
theorem decode_sourceLA {A : Addr} {Gx : Nat → Map → St LF.S → CSrv → Prop} {G : St LF.S → CSrv → Prop}
    {ok : St LF.S → SSrv → Bool} {W : Nat → Option WFrame} {P : LoadP} {Fr : LoopFramesA A} {s0 : St LF.S}
    {tab0 : List SymE} {fixA : List Nat} {VBOk : (Nat → F64) → Prop} (hA : A.nxt = 17)
    (S : AccSimW P W VBOk ok (A.fwd :: A.emit :: Fr.xs)) (st : LoopStartA A P s0 tab0)
    (hfrN : ∀ e ∈ tab0, e.noVar A.nxt = true) (hcE : A.cE ∈ fixA) (hb : A.emit ∈ fixA)
    (hwc : W A.cE = none) (hwe : W A.emit = none)
    (cs : LoopCasesA A ok P s0 tab0 fixA) {L ΔJ ΔH ΔN : Nat} (hcs : cs.OkAt L ΔJ ΔH ΔN)
    {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {B : LoopBase}
    {env : Env} {nm : Name}
    (hsh : ∀ i, 1 ≤ i → i + 2 < T → (loopSelLA cs L i).ShiftFWA Fr W)
    (hkeep : ∀ i, 1 ≤ i → i + 2 < T → (loopSelLA cs L i).KeepsA Fr)
    (F0 F1 F2 : HaltSegA A W P (toks.drop (T - 1)) s0 (finalStart s0 tab0.length) (tab0 ++ [.var A.nxt])
      [.num (.ref A.tok), .num (.ref tab0.length)])
    (c0 : F0.S0.oracle.all (fun q => (finalDG false false).contains q) = true)
    (c1 : F1.S0.oracle.all (fun q => (finalDG true false).contains q) = true)
    (c2 : F2.S0.oracle.all (fun q => (finalDG false true).contains q) = true)
    (hQA : ∀ K : Ctx, (∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Fr.xs) → K.lo = P.lo → K.hi = P.E →
      F0.QA (valL ρ T tk L (T - 2) (tk T)) K ∧ F1.QA (valL ρ T tk L (T - 2) (tk T)) K ∧
        F2.QA (valL ρ T tk L (T - 2) (tk T)) K)
    (henv : lookupEnv nm env = some A.cE)
    (hT : 3 ≤ T) (hLT : L + T < 2 ^ 29) (hlen : T - 1 ≤ toks.length)
    (htk : ∀ j, j ≤ T → tk j ≤ 2 ^ 20) (notEos : ∀ k, 2 ≤ k → k ≤ T → tk k ≠ 248044)
    (hVB : ∀ i nx, 1 ≤ i → i + 2 ≤ T → nx ≤ 2 ^ 20 → VBOk (valL ρ T tk L i nx))
    (hJ : T * ΔJ + B.D < Sim.bound) (hH : s0.ffi.mlx.next + T * ΔH + B.H + (P.E - s0.ffi.mlx.next) < 2 ^ 46)
    (hN : s0.ffi.mlx.nnext + T * ΔN + B.N + (P.NE - s0.ffi.mlx.nnext) < 2 ^ 62)
    (hG : ∀ i, 1 ≤ i → i + 2 < T → LoopGStepA Gx (relLW P W) Fr (loopSelLA cs L i) (valL ρ T tk L) toks i)
    (hF : (T - 2) % 256 ≠ 0 → (T - 1) % 256 ≠ 0 → LastGStepA A Gx P W Fr fixA F0 (valL ρ T tk L) tk G)
    (hF0 : (T - 2) % 256 = 0 → LastGStepA A Gx P W Fr fixA F1 (valL ρ T tk L) tk G)
    (hF1 : (T - 1) % 256 = 0 → LastGStepA A Gx P W Fr fixA F2 (valL ρ T tk L) tk G)
    {N0 : Nat} {t0 t1 : St LF.S} {C0 C1 : CSrv} (hpre : runC LF N0 t0 C0 = some (t1, C1))
    (h1 : DecodeInvA A Gx W P Fr s0 tab0 fixA (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN 1 t1 C1) :
    ∃ N tF CF, (∀ n, N ≤ n → runC LF n t0 C0 = some (tF, CF)) ∧ (∃ v, tF.ctl = .halt (.normal v)) ∧
      (bindingOf tF env nm).bind (Host.Load.Extract.elements tF) = some (E0 ++ (toks.take (T - 1)).map Val.num) ∧
      CSrv.Le C1 CF ∧ G tF CF := by
  obtain ⟨N, tF, CF, hrun, hv, hle, hem, hg⟩ := decode_sourceA (Goal := EmitGoal env nm E0 toks (T - 1) G) hT
    (fun i hi1 hiT => ⟨_, decodeIter_selLA hA S st cs hcs hi1 hiT hLT (by omega) htk (notEos (i + 1) (by omega)
      (by omega)) (hsh i hi1 hiT) (hkeep i hi1 hiT) (fun nx hnx => hVB i nx hi1 (by omega) hnx) hJ hH hN
      (hG i hi1 hiT)⟩)
    (decodeHalt_last3A hA st F0 F1 F2 c0 c1 c2 hfrN hcE hb hwc hwe hT hLT hlen htk notEos hQA henv hF hF0 hF1)
    hpre h1
  exact ⟨N, tF, CF, hrun, hv, hem, hle, hg⟩

/-- **The decode route's EOS stop after a prompt of length `L`, end to end, at the constants `A`
under the frames `W`** (`loop_source_eosL`): token `k` (`2 ≤ k ≤ T`) is EOS and the tokens before
it are not; the halting chain at the cut of iteration `k - 1` (`k < T`) or an EOS final chain (`k = T`,
by the cache-clear test of the yielded token) halts the target with the `emitted` binding the
base prefix and the first `k - 2` readbacks. -/
theorem decode_source_eosLA {A : Addr} {Gx : Nat → Map → St LF.S → CSrv → Prop} {G : St LF.S → CSrv → Prop}
    {ok : St LF.S → SSrv → Bool} {W : Nat → Option WFrame} {P : LoadP} {Fr : LoopFramesA A} {s0 : St LF.S}
    {tab0 : List SymE} {fixA : List Nat} {VBOk : (Nat → F64) → Prop} (hA : A.nxt = 17)
    (S : AccSimW P W VBOk ok (A.fwd :: A.emit :: Fr.xs)) (st : LoopStartA A P s0 tab0)
    (hfrN : ∀ e ∈ tab0, e.noVar A.nxt = true) (hcE : A.cE ∈ fixA) (hb : A.emit ∈ fixA)
    (hwc : W A.cE = none) (hwe : W A.emit = none)
    (cs : LoopCasesA A ok P s0 tab0 fixA) {L ΔJ ΔH ΔN : Nat} (hcs : cs.OkAt L ΔJ ΔH ΔN)
    {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {B : LoopBase}
    {env : Env} {nm : Name} (k : Nat) (hk2 : 2 ≤ k) (hkT : k ≤ T)
    (hsh : ∀ i, 1 ≤ i → i + 1 < k → i + 2 < T → (loopSelLA cs L i).ShiftFWA Fr W)
    (hkeep : ∀ i, 1 ≤ i → i + 1 < k → i + 2 < T → (loopSelLA cs L i).KeepsA Fr)
    (X : HaltSegA A W P (toks.drop (k - 1)) s0 s0 tab0 [])
    (cX : X.S0.oracle.all (fun q => eosD.contains q) = true)
    (FE0 FE1 : HaltSegA A W P (toks.drop (T - 1)) s0 (finalStart s0 tab0.length) (tab0 ++ [.var A.nxt])
      [.num (.ref A.tok)])
    (c0 : FE0.S0.oracle.all (fun q => (finalEDG false).contains q) = true)
    (c1 : FE1.S0.oracle.all (fun q => (finalEDG true).contains q) = true)
    (hQX : k < T → ∀ nx (K : Ctx), nx ≤ 2 ^ 20 → (∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Fr.xs) →
      K.lo = P.lo → K.hi = P.E → X.QA (valL ρ T tk L (k - 1) nx) K)
    (hQE : ∀ K : Ctx, (∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Fr.xs) → K.lo = P.lo → K.hi = P.E →
      FE0.QA (valL ρ T tk L (T - 2) (tk T)) K ∧ FE1.QA (valL ρ T tk L (T - 2) (tk T)) K)
    (henv : lookupEnv nm env = some A.cE)
    (hT : 3 ≤ T) (hLT : L + T < 2 ^ 29) (hlen : T - 1 ≤ toks.length) (htk : ∀ j, j ≤ T → tk j ≤ 2 ^ 20)
    (notEos : ∀ j, 2 ≤ j → j < k → tk j ≠ 248044) (eos : tk k = 248044)
    (hVB : ∀ i nx, 1 ≤ i → i + 2 ≤ T → nx ≤ 2 ^ 20 → VBOk (valL ρ T tk L i nx))
    (hJ : T * ΔJ + B.D < Sim.bound) (hH : s0.ffi.mlx.next + T * ΔH + B.H + (P.E - s0.ffi.mlx.next) < 2 ^ 46)
    (hN : s0.ffi.mlx.nnext + T * ΔN + B.N + (P.NE - s0.ffi.mlx.nnext) < 2 ^ 62)
    (hG : ∀ i, 1 ≤ i → i + 1 < k → i + 2 < T →
      LoopGStepA Gx (relLW P W) Fr (loopSelLA cs L i) (valL ρ T tk L) toks i)
    (hX : k < T → CutGStepA A Gx P W Fr fixA X (valL ρ T tk L) G)
    (hF : k = T → (T - 2) % 256 ≠ 0 → LastGStepA A Gx P W Fr fixA FE0 (valL ρ T tk L) tk G)
    (hF0 : k = T → (T - 2) % 256 = 0 → LastGStepA A Gx P W Fr fixA FE1 (valL ρ T tk L) tk G)
    {N0 : Nat} {t0 t1 : St LF.S} {C0 C1 : CSrv} (hpre : runC LF N0 t0 C0 = some (t1, C1))
    (h1 : DecodeInvA A Gx W P Fr s0 tab0 fixA (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN 1 t1 C1) :
    ∃ N tF CF, (∀ n, N ≤ n → runC LF n t0 C0 = some (tF, CF)) ∧ (∃ v, tF.ctl = .halt (.normal v)) ∧
      (bindingOf tF env nm).bind (Host.Load.Extract.elements tF) = some (E0 ++ (toks.take (k - 2)).map Val.num) ∧
      CSrv.Le C1 CF ∧ G tF CF := by
  have hupd : ∀ nx, upd (valL ρ T tk L (T - 2) nx) A.nxt (F64.ofNat (tk T)) = valL ρ T tk L (T - 2) (tk T) :=
    fun _ => by rw [hA]; exact upd_valL _
  obtain ⟨N, tF, CF, hrun, hv, hle, hem, hg⟩ := decode_source_eosA (Goal := EmitGoal env nm E0 toks (k - 2) G) hT k
    hk2 hkT
    (fun i hi1 hik hiT => ⟨_, decodeIter_selLA hA S st cs hcs hi1 hiT hLT (by omega) htk
      (notEos (i + 1) (by omega) (by omega)) (hsh i hi1 hik hiT) (hkeep i hi1 hik hiT)
      (fun nx hnx => hVB i nx hi1 (by omega) hnx) hJ hH hN (hG i hi1 hik hiT)⟩)
    (fun hk => by
      have hd := decodeHalt_cutA (tk := tk) (E0 := E0) (B := B) (ΔJ := ΔJ) (ΔH := ΔH) (ΔN := ΔN) (env := env) (nm := nm)
        X hcE hb hwc hwe
        (fun nx => good_of_mem (good_eosL (by omega) (by rw [show k - 1 + 1 = k by omega]; exact eos) (by omega)) cX)
        (hQX hk) henv (hX hk)
      rw [show k - 1 - 1 = k - 2 by omega] at hd
      exact ⟨_, hd⟩)
    (fun hk => by
      subst hk
      have hg := good_finalEGL (ρ := ρ) (T := k) (tk := tk) (L := L) (i := k - 2) (nx := tk k) (by omega) (by omega)
        (notEos (k - 2 + 1) (by omega) (by omega)) eos (by omega) (by have := htk (k - 2 + 1) (by omega); omega)
      by_cases hc0 : (k - 2) % 256 = 0
      · rw [decide_eq_true hc0] at hg
        exact ⟨_, decodeHalt_lastEA st FE1 hfrN hcE hb hwc hwe hupd hT hlen (good_of_mem hg c1)
          (fun K h1 h2 h3 => (hQE K h1 h2 h3).2) henv (hF0 rfl hc0)⟩
      · rw [decide_eq_false hc0] at hg
        exact ⟨_, decodeHalt_lastEA st FE0 hfrN hcE hb hwc hwe hupd hT hlen (good_of_mem hg c0)
          (fun K h1 h2 h3 => (hQE K h1 h2 h3).1) henv (hF rfl hc0)⟩)
    hpre h1
  exact ⟨N, tF, CF, hrun, hv, hem, hle, hg⟩

end Host.Ts.Sim
