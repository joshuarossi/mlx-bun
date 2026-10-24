import host.sim.PrefillDecode
import host.sim.DecodeAddrSeam
namespace Host.Ts.Sim.Prefill
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! # The prefill and the decode route meet at the decode cut, at a driver's constants

`loopCutA` is the decode cut with the seam interface at the constants `A`: frames `W` (the
relation `relLW P W`), further frames `Fr`, counter bases `B`, valuations `V`. Its invariant is
`DecodeInvA … 1` (`loopCutA_inv`), so the route at `A` is a `DecodeRoute` from it
(`decodeRoute_seamA`) and `source_prompt` composes the prefill with it unchanged
(`source_tokens_promptA`). At `addr0` without frames over `valL` it is `loopCutF`
(`loopCutA_addr0`). -/

/-- **The decode cut** `i = 1` at the constants `A`. -/
def loopCutA (A : Addr) (Gx : Nat → Map → St LF.S → CSrv → Prop) (W : Nat → Option WFrame) (P : LoadP)
    (Fr : LoopFramesA A) (s0 : St LF.S) (tab0 : List SymE) (fixA : List Nat) (V : LoopVals) (tk : Nat → Nat)
    (toks : List NumV) (E0 : List Val) (B : LoopBase) : ICut LF where
  s0 := s0
  tab0 := tab0
  R := fun x s S => relLW P W (toks.drop 1) x.M x.ν x.K s S x.t x.C
  B := fun x => ∃ nx p1, x.ν = V 1 nx ∧ x.K.fr = frA A s0 Fr.X p1 E0 ∧ x.K.lo = P.lo ∧ x.K.hi = P.E ∧
    x.K.base = s0.trace ∧ toks[0]? = some (x.M.num A.tok) ∧ nx ≤ 2 ^ 20 ∧
    (∀ j (hj : j < toks.length), x.C.val toks[j] = some (F64.ofNat (tk (j + 2)))) ∧
    x.K.D ≤ B.D ∧ x.t.ffi.mlx.next ≤ s0.ffi.mlx.next + B.H ∧ x.t.ffi.mlx.nnext ≤ s0.ffi.mlx.nnext + B.N ∧
    (∀ a ∈ fixA, x.M.a a = a) ∧ Gx 1 x.M x.t x.C

theorem loopCutA_addr0 {Gx : Nat → Map → St LF.S → CSrv → Prop} {P : LoadP} {Fr : LoopFrames} {s0 : St LF.S}
    {tab0 : List SymE} {fixA : List Nat} {L : Nat} {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat} {toks : List NumV}
    {E0 : List Val} {B : LoopBase} :
    loopCutA addr0 Gx noFrames P Fr.toA s0 tab0 fixA (valL ρ T tk L) tk toks E0 B =
      loopCutF Gx (relL P) P Fr s0 tab0 fixA L ρ T tk toks E0 B := rfl

section
variable {A : Addr} {Gx : Nat → Map → St LF.S → CSrv → Prop} {W : Nat → Option WFrame} {P : LoadP}
  {Fr : LoopFramesA A} {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat} {V : LoopVals} {T : Nat}
  {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {B : LoopBase} {ΔJ ΔH ΔN : Nat}
  {Goal : St LF.S → CSrv → Prop}

/-- **The decode cut's invariant is the seam invariant at iteration 1.** -/
theorem loopCutA_inv (ΔJ ΔH ΔN : Nat) (t : St LF.S) (C : CSrv) :
    (loopCutA A Gx W P Fr s0 tab0 fixA V tk toks E0 B).Inv t C ↔
      DecodeInvA A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN 1 t C := by
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
    · show t'.ffi.mlx.next ≤ s0.ffi.mlx.next + (1 - 1) * ΔH + B.H
      simpa using hH
    · show t'.ffi.mlx.nnext ≤ s0.ffi.mlx.nnext + (1 - 1) * ΔN + B.N
      simpa using hN
  · rintro ⟨M, K, nx, p1, hR, hfr, hlo, hhi, hbase, htok, hnx, hvals, hD, hH, hN, hfix, hG⟩
    refine ⟨⟨M, V 1 nx, K, t, C⟩, rfl, rfl, hR, nx, p1, rfl, ?_, hlo, hhi, hbase, htok, hnx, hvals,
      ?_, ?_, ?_, hfix, hG⟩
    · show K.fr = frA A s0 Fr.X p1 E0
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

/-- **The route at `A` is a decode route** from the decode cut. -/
theorem decodeRoute_seamA (hT : 3 ≤ T)
    (hit : ∀ i, 1 ≤ i → i + 2 < T → ∃ n, DecodeIter (DecodeInvA A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN) i n)
    (hfin : ∃ n, DecodeHalt (DecodeInvA A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN) (T - 2) n Goal)
    (t0 : St LF.S) (C0 : CSrv) :
    DecodeRoute (loopCutA A Gx W P Fr s0 tab0 fixA V tk toks E0 B) t0 C0 (SeamGoal t0 C0 Goal) := by
  intro N t1 C1 hpre h1
  obtain ⟨N', tF, CF, hrun, hv, hle, hG⟩ := decode_sourceA hT hit hfin hpre ((loopCutA_inv ΔJ ΔH ΔN t1 C1).1 h1)
  exact ⟨N', tF, CF, hrun, hv, (runC_le _ _ _ _ _ hpre).trans hle, hG⟩

/-- **The route of a prompt of length `L` through the seams at the constants `A`**
(`source_tokens_promptS`). -/
theorem source_tokens_promptA {I : PrefInvs} (S : PrefSteps I) {L : Nat} (hL1 : 1 ≤ L) (hL2 : L ≤ 262143)
    {N0 : Nat} {t0 tL : St LF.S} {C0 CL : CSrv} (hboot : runC LF N0 t0 C0 = some (tL, CL))
    (hld : (I.ld L).Inv tL CL) (hdec : I.dec L = loopCutA A Gx W P Fr s0 tab0 fixA V tk toks E0 B) (hT : 3 ≤ T)
    (hit : ∀ i, 1 ≤ i → i + 2 < T → ∃ n, DecodeIter (DecodeInvA A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN) i n)
    (hfin : ∃ n, DecodeHalt (DecodeInvA A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN) (T - 2) n Goal) :
    SeamGoal t0 C0 Goal :=
  source_prompt S hL1 hL2 hboot hld (by rw [hdec]; exact decodeRoute_seamA hT hit hfin t0 C0)

end

end Host.Ts.Sim.Prefill
