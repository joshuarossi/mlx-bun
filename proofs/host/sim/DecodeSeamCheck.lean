import host.sim.DecodeSeam
namespace Host.Ts.Sim
open Host.Ts Host.Ts.Sim.Template

/-! # The seam route reproduces the template route

`loop_sourceL` (GeneralL.lean, the decode route over the whole-iteration templates) follows from
the seam route `decode_sourceL` with the templates' contracts (`decodeIter_case`,
`decodeHalt_final3`), at the load world's relation, without further frames and with zero counter
bases: `loop_sourceL_seam` has `loop_sourceL`'s statement. The final cases enter as chains
(`FinalCase.toSeg`), whose obligation follows from the existing one (`FinalGStepV.toSeg`). -/

section
variable {Gx : Nat → Map → St LF.S → CSrv → Prop} {G : St LF.S → CSrv → Prop} {ok okB : St LF.S → SSrv → Bool}
  {P : LoadP} {VBOk : (Nat → F64) → Prop} {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat} {cE aN : Nat}

/-- A final case's obligation gives its chain's (`FinalCase.toSeg`). -/
theorem FinalGStepV.toSeg (fc : FinalCase ok okB s0 tab0 cE aN) (A : AccSim P VBOk ok [2673447, 12502])
    (Bs : AccSim P VBOk okB [2673447, 12502, aN]) (haN2 : aN ≠ 12502) {V : LoopVals} {T : Nat} {tk : Nat → Nat}
    {toks : List NumV} (hG : FinalGStepV Gx P fixA fc V T tk toks G) :
    FinalGStepSF Gx P LoopFrames.empty fixA (fc.toSeg A Bs haN2 (toks.drop (T - 1))) V tk G := by
  intro hlen nx M K t C xF hGx hfix h hKfr hlo hhi hrun hgrow hext hν hKlo hKhi _ hend
  obtain ⟨hR, hKp, -⟩ := hend
  have hKfrF : ∀ a, xF.K.fr a ≠ none ↔ a ∈ [2673447, 12502, aN] := fun a => by
    rw [hKp.2.2 a, Bs.hj.2.2]
  have hn : (fc.toSeg A Bs haN2 (toks.drop (T - 1))).case.n = fc.nA + 1 + 1 + fc.nB := by
    show fc.nA + (1 + (0 + (1 + (fc.nB + 0)))) = _
    omega
  rw [hn] at hrun
  exact hG hlen nx M K t C xF.M xF.K xF.t xF.C hGx hfix h hKfr hlo hhi hrun hgrow hext hKlo hKhi hKfrF
    (by rw [← hν]; exact hR)

/-- **`loop_sourceL` from the seam route.** -/
theorem loop_sourceL_seam {cE : Nat}
    (S : AccSim P VBOk ok [2673447, 12502]) (st : LoopStart P s0 tab0)
    (hfr17 : ∀ e ∈ tab0, e.noVar 17 = true) (hcE : cE ∈ fixA) (hb : 12502 ∈ fixA)
    (cs : LoopCases ok P s0 tab0 fixA) {L ΔJ ΔH ΔN : Nat} (hcs : cs.OkAt L ΔJ ΔH ΔN)
    (F0 : FinalSim P VBOk ok s0 tab0 cE (finalDG false false))
    (F1 : FinalSim P VBOk ok s0 tab0 cE (finalDG true false))
    (F2 : FinalSim P VBOk ok s0 tab0 cE (finalDG false true))
    {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {env : Env} {nm : Name}
    (henv : lookupEnv nm env = some cE)
    (hT : 3 ≤ T) (hLT : L + T < 2 ^ 29) (hlen : T - 1 ≤ toks.length)
    (htk : ∀ j, j ≤ T → tk j ≤ 2 ^ 20) (notEos : ∀ k, 2 ≤ k → k ≤ T → tk k ≠ 248044)
    (hVB : ∀ i nx, 1 ≤ i → i + 2 ≤ T → nx ≤ 2 ^ 20 → VBOk (valL ρ T tk L i nx))
    (hJ : T * ΔJ < Sim.bound) (hH : s0.ffi.mlx.next + T * ΔH + (P.E - s0.ffi.mlx.next) < 2 ^ 46)
    (hN : s0.ffi.mlx.nnext + T * ΔN + (P.NE - s0.ffi.mlx.nnext) < 2 ^ 62)
    (hG : ∀ i, 1 ≤ i → i + 2 < T → LoopGStepL Gx (loopSelL cs L i) L ρ T tk toks i)
    (hF : (T - 2) % 256 ≠ 0 → (T - 1) % 256 ≠ 0 → FinalGStepL Gx P fixA F0.fc L ρ T tk toks G)
    (hF0 : (T - 2) % 256 = 0 → FinalGStepL Gx P fixA F1.fc L ρ T tk toks G)
    (hF1 : (T - 1) % 256 = 0 → FinalGStepL Gx P fixA F2.fc L ρ T tk toks G)
    {N0 : Nat} {t0 t1 : St LF.S} {C0 C1 : CSrv} (hpre : runC LF N0 t0 C0 = some (t1, C1))
    (h1 : LoopInvL Gx P s0 tab0 fixA L ρ T tk toks E0 ΔJ ΔH ΔN 1 t1 C1) :
    ∃ N tF CF, (∀ n, N ≤ n → runC LF n t0 C0 = some (tF, CF)) ∧ (∃ v, tF.ctl = .halt (.normal v)) ∧
      (bindingOf tF env nm).bind (Host.Load.Extract.elements tF) = some (E0 ++ (toks.take (T - 1)).map Val.num) ∧
      CSrv.Le C1 CF ∧ G tF CF := by
  have hjfr : ∀ a, a ∈ S.jsP.framed ↔ a ∈ 2673447 :: 12502 :: LoopFrames.empty.xs := fun a => by
    rw [S.hj.2.2]; rfl
  obtain ⟨N, tF, CF, hrun, hv, hle, hem, hg⟩ := decode_sourceL (Fr := LoopFrames.empty) (B := ⟨0, 0, 0⟩) (R := relL P)
    (Goal := EmitGoal env nm E0 toks (T - 1) G) hT
    (fun i hi1 hiT => ⟨_, decodeIter_case (relRel P) st cs hcs hi1 hiT hLT (by omega) htk
      (notEos (i + 1) (by omega) (by omega))
      ((loopSelL cs L i).iterF_rel LoopFrames.empty S.sim S.hj.1 S.hj.2.1 hjfr S.ng st
        (loopSelL cs L i).shiftF_empty)
      (loopSelL cs L i).keeps_empty (fun nx hnx => hVB i nx hi1 (by omega) hnx) hJ hH hN (hG i hi1 hiT)⟩)
    (decodeHalt_final3 st (F0.fc.toSeg S F0.acc F0.ne2 (toks.drop (T - 1)))
      (F1.fc.toSeg S F1.acc F1.ne2 (toks.drop (T - 1))) (F2.fc.toSeg S F2.acc F2.ne2 (toks.drop (T - 1))) F0.cover F1.cover F2.cover hfr17 hcE hb hT hLT hlen htk
      notEos
      (fun K hK hlo hhi => ⟨⟨⟨hlo.trans S.hj.1.symm, hhi.trans S.hj.2.1.symm, fun a => by rw [hK a, S.hj.2.2]; rfl⟩,
          hVB (T - 2) (tk T) (by omega) (by omega) (htk T le_rfl)⟩,
        ⟨⟨hlo.trans S.hj.1.symm, hhi.trans S.hj.2.1.symm, fun a => by rw [hK a, S.hj.2.2]; rfl⟩,
          hVB (T - 2) (tk T) (by omega) (by omega) (htk T le_rfl)⟩,
        ⟨⟨hlo.trans S.hj.1.symm, hhi.trans S.hj.2.1.symm, fun a => by rw [hK a, S.hj.2.2]; rfl⟩,
          hVB (T - 2) (tk T) (by omega) (by omega) (htk T le_rfl)⟩⟩)
      henv
      (fun h0 h1 => FinalGStepV.toSeg F0.fc S F0.acc F0.ne2 (hF h0 h1))
      (fun h => FinalGStepV.toSeg F1.fc S F1.acc F1.ne2 (hF0 h))
      (fun h => FinalGStepV.toSeg F2.fc S F2.acc F2.ne2 (hF1 h)))
    hpre h1
  exact ⟨N, tF, CF, hrun, hv, hem, hle, hg⟩

end

end Host.Ts.Sim
