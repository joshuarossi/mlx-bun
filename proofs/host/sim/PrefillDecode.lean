import host.sim.Prefill
import host.sim.DecodeSeam
namespace Host.Ts.Sim.Prefill
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! # The prefill and the decode route meet at the decode cut

`loopCutF` is the decode cut with the decode loop's seam interface: the relation family `R`, the
further frames `Fr` (the framed prompt and ghost slots, beside `forwarded` and `emitted`) and the
counter bases `B` (`loopCut` is the case of `Rel`, no further frames, zero bases). Its invariant is
the seam invariant at iteration 1 (`loopCutF_inv`), so the seam route is a `DecodeRoute` from it
(`decodeRoute_seam`), and `source_prompt` composes the prefill with it unchanged
(`source_tokens_promptS`). -/

/-- **The decode cut** `i = 1` with the seam interface. -/
def loopCutF (Gx : Nat → Map → St LF.S → CSrv → Prop) (R : LoopR) (P : LoadP) (Fr : LoopFrames) (s0 : St LF.S)
    (tab0 : List SymE) (fixA : List Nat) (L : Nat) (ρ : Nat → F64) (T : Nat) (tk : Nat → Nat) (toks : List NumV)
    (E0 : List Val) (B : LoopBase) : ICut LF where
  s0 := s0
  tab0 := tab0
  R := fun x s S => R (toks.drop 1) x.M x.ν x.K s S x.t x.C
  B := fun x => ∃ nx p1, x.ν = valL ρ T tk L 1 nx ∧ x.K.fr = frX s0 Fr.X p1 E0 ∧ x.K.lo = P.lo ∧ x.K.hi = P.E ∧
    x.K.base = s0.trace ∧ toks[0]? = some (x.M.num 79) ∧ nx ≤ 2 ^ 20 ∧
    (∀ j (hj : j < toks.length), x.C.val toks[j] = some (F64.ofNat (tk (j + 2)))) ∧
    x.K.D ≤ B.D ∧ x.t.ffi.mlx.next ≤ s0.ffi.mlx.next + B.H ∧ x.t.ffi.mlx.nnext ≤ s0.ffi.mlx.nnext + B.N ∧
    (∀ a ∈ fixA, x.M.a a = a) ∧ Gx 1 x.M x.t x.C

/-- **The decode cut's invariant is the seam invariant at iteration 1.** -/
theorem loopCutF_inv {Gx : Nat → Map → St LF.S → CSrv → Prop} {R : LoopR} {P : LoadP} {Fr : LoopFrames}
    {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat} {L : Nat} {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat}
    {toks : List NumV} {E0 : List Val} {B : LoopBase} (ΔJ ΔH ΔN : Nat) (t : St LF.S) (C : CSrv) :
    (loopCutF Gx R P Fr s0 tab0 fixA L ρ T tk toks E0 B).Inv t C ↔
      LoopInvLF Gx R P Fr s0 tab0 fixA L ρ T tk toks E0 B ΔJ ΔH ΔN 1 t C := by
  have e1 : E0 ++ (toks.take (1 - 1)).map Val.num = E0 := by simp
  constructor
  · rintro ⟨⟨M, ν, K, t', C'⟩, ht, hC, hR, nx, p1, hν, hfr, hlo, hhi, hbase, h79, hnx, hvals, hD, hH, hN, hfix, hG⟩
    change t' = t at ht
    change C' = C at hC
    change ν = valL ρ T tk L 1 nx at hν
    subst ht hC hν
    refine ⟨M, K, nx, p1, hR, by rw [e1]; exact hfr, hlo, hhi, hbase, h79, hnx, hvals, ?_, ?_, ?_, hfix, hG⟩
    · show K.D ≤ (1 - 1) * ΔJ + B.D
      simpa using hD
    · show t'.ffi.mlx.next ≤ s0.ffi.mlx.next + (1 - 1) * ΔH + B.H
      simpa using hH
    · show t'.ffi.mlx.nnext ≤ s0.ffi.mlx.nnext + (1 - 1) * ΔN + B.N
      simpa using hN
  · rintro ⟨M, K, nx, p1, hR, hfr, hlo, hhi, hbase, h79, hnx, hvals, hD, hH, hN, hfix, hG⟩
    refine ⟨⟨M, valL ρ T tk L 1 nx, K, t, C⟩, rfl, rfl, hR, nx, p1, rfl, ?_, hlo, hhi, hbase, h79, hnx, hvals,
      ?_, ?_, ?_, hfix, hG⟩
    · show K.fr = frX s0 Fr.X p1 E0
      rw [hfr, e1]
    · show K.D ≤ B.D
      have : K.D ≤ (1 - 1) * ΔJ + B.D := hD
      simpa using this
    · show t.ffi.mlx.next ≤ s0.ffi.mlx.next + B.H
      have : t.ffi.mlx.next ≤ s0.ffi.mlx.next + (1 - 1) * ΔH + B.H := hH
      simpa using this
    · show t.ffi.mlx.nnext ≤ s0.ffi.mlx.nnext + B.N
      have : t.ffi.mlx.nnext ≤ s0.ffi.mlx.nnext + (1 - 1) * ΔN + B.N := hN
      simpa using this

/-- The seam route's goal from `(t0, C0)`. -/
def SeamGoal (t0 : St LF.S) (C0 : CSrv) (Goal : St LF.S → CSrv → Prop) : Prop :=
  ∃ N tF CF, (∀ m, N ≤ m → runC LF m t0 C0 = some (tF, CF)) ∧ (∃ v, tF.ctl = .halt (.normal v)) ∧
    CSrv.Le C0 CF ∧ Goal tF CF

/-- **The seam route is a decode route** from the decode cut: the per-iteration and halting
contracts give the goal from every run reaching the cut's invariant. -/
theorem decodeRoute_seam {Gx : Nat → Map → St LF.S → CSrv → Prop} {R : LoopR} {P : LoadP} {Fr : LoopFrames}
    {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat} {L : Nat} {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat}
    {toks : List NumV} {E0 : List Val} {B : LoopBase} {ΔJ ΔH ΔN : Nat} {Goal : St LF.S → CSrv → Prop}
    (hT : 3 ≤ T)
    (hit : ∀ i, 1 ≤ i → i + 2 < T →
      ∃ n, DecodeIter (LoopInvLF Gx R P Fr s0 tab0 fixA L ρ T tk toks E0 B ΔJ ΔH ΔN) i n)
    (hfin : ∃ n, DecodeHalt (LoopInvLF Gx R P Fr s0 tab0 fixA L ρ T tk toks E0 B ΔJ ΔH ΔN) (T - 2) n Goal)
    (t0 : St LF.S) (C0 : CSrv) :
    DecodeRoute (loopCutF Gx R P Fr s0 tab0 fixA L ρ T tk toks E0 B) t0 C0 (SeamGoal t0 C0 Goal) := by
  intro N t1 C1 hpre h1
  obtain ⟨N', tF, CF, hrun, hv, hle, hG⟩ :=
    decode_sourceL hT hit hfin hpre ((loopCutF_inv ΔJ ΔH ΔN t1 C1).1 h1)
  exact ⟨N', tF, CF, hrun, hv, (runC_le _ _ _ _ _ hpre).trans hle, hG⟩

/-- **The route of a prompt of length `L` through the seams**: the boot run to loadDone, the
prefill's checked steps to the decode cut (`prefill_reach`), and the decode route's contracts
(`source_prompt` with `decodeRoute_seam`). -/
theorem source_tokens_promptS {I : PrefInvs} (S : PrefSteps I) {L : Nat} (hL1 : 1 ≤ L) (hL2 : L ≤ 262143)
    {N0 : Nat} {t0 tL : St LF.S} {C0 CL : CSrv} (hboot : runC LF N0 t0 C0 = some (tL, CL))
    (hld : (I.ld L).Inv tL CL)
    {Gx : Nat → Map → St LF.S → CSrv → Prop} {R : LoopR} {P : LoadP} {Fr : LoopFrames}
    {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat} {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat}
    {toks : List NumV} {E0 : List Val} {B : LoopBase} {ΔJ ΔH ΔN : Nat} {Goal : St LF.S → CSrv → Prop}
    (hdec : I.dec L = loopCutF Gx R P Fr s0 tab0 fixA L ρ T tk toks E0 B) (hT : 3 ≤ T)
    (hit : ∀ i, 1 ≤ i → i + 2 < T →
      ∃ n, DecodeIter (LoopInvLF Gx R P Fr s0 tab0 fixA L ρ T tk toks E0 B ΔJ ΔH ΔN) i n)
    (hfin : ∃ n, DecodeHalt (LoopInvLF Gx R P Fr s0 tab0 fixA L ρ T tk toks E0 B ΔJ ΔH ΔN) (T - 2) n Goal) :
    SeamGoal t0 C0 Goal :=
  source_prompt S hL1 hL2 hboot hld (by rw [hdec]; exact decodeRoute_seam hT hit hfin t0 C0)

end Host.Ts.Sim.Prefill
