import host.sim.DecodeAddrSeam
namespace Host.Ts.Sim
open Host.Ts Host.Ts.Sim.Template

/-! # Today's decode route from the route at a driver's constants

`loop_sourceL` (GeneralL.lean) follows from `decode_sourceLA` at `addr0` without frames, with
today's cases (`LoopCases.toA`), acceptances (`AccSim.toWL`) and final cases as halting chains
(`FinalSim.segA`, whose obligation follows from the existing one: `FinalGStepV.toSegA`):
`loop_sourceL_addr` has `loop_sourceL`'s statement at today's `emitted` cell 2590, and with the EOS cases
(`ExitSim.segA`, `FinalESim.segA`, `ExitGStepV.toSegA`, `FinalEGStepV.toSegA`) `loop_source_eosL_addr` has
`loop_source_eosL`'s. -/

section
variable {Gx : Nat → Map → St LF.S → CSrv → Prop} {G : St LF.S → CSrv → Prop} {ok : St LF.S → SSrv → Bool}
  {P : LoadP} {VBOk : (Nat → F64) → Prop} {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat} {D : List Ans}

/-- An acceptance's facts without frames, its framed arrays restated. -/
def AccSim.toWL {framed framed' : List Nat} (S : AccSim P VBOk ok framed) (h : ∀ a, a ∈ framed ↔ a ∈ framed') :
    AccSimW P noFrames VBOk ok framed' :=
  ⟨S.jsP, ⟨S.hj.1, S.hj.2.1, fun a => by rw [S.hj.2.2]; exact h a⟩, S.sim, S.simL, S.ng, S.ngL⟩

/-- Today's final case as a halting chain at `addr0`. -/
noncomputable def FinalSim.segA (F : FinalSim P VBOk ok s0 tab0 2590 D) (S : AccSim P VBOk ok [2673447, 12502])
    (r : List NumV) :
    HaltSegA addr0 noFrames P r s0 (finalStart s0 tab0.length) (tab0 ++ [.var 17])
      [.num (.ref 79), .num (.ref tab0.length)] :=
  F.fc.toA.toSeg (fx := []) (S.toWL fun _ => Iff.rfl) (F.acc.toWL fun _ => Iff.rfl) F.ne2 rfl rfl r

/-- A final case's obligation gives its chain's. -/
theorem FinalGStepV.toSegA (F : FinalSim P VBOk ok s0 tab0 2590 D) (S : AccSim P VBOk ok [2673447, 12502])
    {V : LoopVals} {T : Nat} {tk : Nat → Nat} {toks : List NumV} (hG : FinalGStepV Gx P fixA F.fc V T tk toks G) :
    LastGStepA addr0 Gx P noFrames LoopFrames.empty.toA fixA (F.segA S (toks.drop (T - 1))) V tk G := by
  intro hlen nx M K t C xF hGx hfix h hKfr hlo hhi hrun hgrow hext hν hKlo hKhi _ hend
  obtain ⟨hR, hKp, -⟩ := hend
  have hKfrF : ∀ a, xF.K.fr a ≠ none ↔ a ∈ [2673447, 12502, F.aN] := fun a => by
    exact (hKp.2.2 a).trans (by show a ∈ F.acc.jsP.framed ↔ _; rw [F.acc.hj.2.2])
  have hn : (F.segA S (toks.drop (T - 1))).case.n = F.fc.nA + 1 + 1 + F.fc.nB :=
    ExitCaseA.toSeg_n _ _ _ _ _ _ _
  rw [hn] at hrun
  exact hG hlen nx M K t C xF.M xF.K xF.t xF.C hGx hfix h hKfr hlo hhi hrun hgrow hext hKlo hKhi hKfrF
    (by rw [← hν]; exact hR)

/-- **`loop_sourceL` from the route at today's constants.** -/
theorem loop_sourceL_addr
    (S : AccSim P VBOk ok [2673447, 12502]) (st : LoopStart P s0 tab0)
    (hfr17 : ∀ e ∈ tab0, e.noVar 17 = true) (hcE : 2590 ∈ fixA) (hb : 12502 ∈ fixA)
    (cs : LoopCases ok P s0 tab0 fixA) {L ΔJ ΔH ΔN : Nat} (hcs : cs.OkAt L ΔJ ΔH ΔN)
    (F0 : FinalSim P VBOk ok s0 tab0 2590 (finalDG false false))
    (F1 : FinalSim P VBOk ok s0 tab0 2590 (finalDG true false))
    (F2 : FinalSim P VBOk ok s0 tab0 2590 (finalDG false true))
    {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {env : Env} {nm : Name}
    (henv : lookupEnv nm env = some 2590)
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
  have hsel : ∀ i, loopSelLA cs.toA L i = (loopSelL cs L i).toA := loopSelLA_toA cs L
  have hqa : ∀ K : Ctx, (∀ a, K.fr a ≠ none ↔ a ∈ addr0.fwd :: addr0.emit :: LoopFrames.empty.toA.xs) →
      K.lo = P.lo → K.hi = P.E → Disp.Kp S.jsP K ∧ VBOk (valL ρ T tk L (T - 2) (tk T)) := fun K hK hlo hhi =>
    ⟨⟨hlo.trans S.hj.1.symm, hhi.trans S.hj.2.1.symm, fun a => by rw [hK a, S.hj.2.2]; rfl⟩,
      hVB (T - 2) (tk T) (by omega) (by omega) (htk T le_rfl)⟩
  exact decode_sourceLA (A := addr0) (W := noFrames) (Fr := LoopFrames.empty.toA) (B := ⟨0, 0, 0⟩) rfl
    (S.toWL fun _ => Iff.rfl) st.toA hfr17 hcE hb rfl rfl cs.toA hcs.toA
    (fun i _ _ => by
      rw [hsel]
      exact (ShiftFWA_addr0 _).2 ((loopSelL cs L i).shiftFW_free (loopSelL cs L i).shiftF_empty))
    (fun i _ _ => by rw [hsel]; exact (KeepsA_addr0 _).2 (loopSelL cs L i).keeps_empty)
    (F0.segA S _) (F1.segA S _) (F2.segA S _) F0.cover F1.cover F2.cover
    (fun K hK hlo hhi => ⟨hqa K hK hlo hhi, hqa K hK hlo hhi, hqa K hK hlo hhi⟩)
    henv hT hLT hlen htk notEos hVB (by simpa using hJ) (by simpa using hH) (by simpa using hN)
    (fun i h1 h2 => by rw [hsel]; exact hG i h1 h2)
    (fun h0 h1 => FinalGStepV.toSegA F0 S (hF h0 h1)) (fun h => FinalGStepV.toSegA F1 S (hF0 h))
    (fun h => FinalGStepV.toSegA F2 S (hF1 h)) hpre h1


/-! ## The EOS stop -/

/-- Today's EOS exit case as a halting chain at `addr0`. -/
noncomputable def ExitSim.segA (X : ExitSim P VBOk ok s0 tab0 2590) (S : AccSim P VBOk ok [2673447, 12502])
    (r : List NumV) : HaltSegA addr0 noFrames P r s0 s0 tab0 [] :=
  X.ec.toA.toSeg (fx := []) (S.toWL fun _ => Iff.rfl) (X.acc.toWL fun _ => Iff.rfl) X.ne2 rfl rfl r

/-- Today's EOS final case as a halting chain at `addr0`. -/
noncomputable def FinalESim.segA (F : FinalESim P VBOk ok s0 tab0 2590 D) (S : AccSim P VBOk ok [2673447, 12502])
    (r : List NumV) :
    HaltSegA addr0 noFrames P r s0 (finalStart s0 tab0.length) (tab0 ++ [.var 17]) [.num (.ref 79)] :=
  F.ec.toA.toSeg (fx := []) (S.toWL fun _ => Iff.rfl) (F.acc.toWL fun _ => Iff.rfl) F.ne2 rfl rfl r

/-- The EOS goal: `G`, and the end related, with the loop's fixed addresses kept, to a case halt
satisfying `Q`. -/
def EosGoal (P : LoadP) (fixA : List Nat) (toks : List NumV) (Q : St LF.S → Prop) (G : St LF.S → CSrv → Prop)
    (tF : St LF.S) (CF : CSrv) : Prop :=
  G tF CF ∧ ∃ i MF ν KF s S, Q s ∧ Rel LF (LR P (toks.drop i)) MF ν KF s S tF CF ∧ ∀ a ∈ fixA, MF.a a = a

/-- An exit case's obligation gives its chain's, with the end relation. -/
theorem ExitGStepV.toSegA (X : ExitSim P VBOk ok s0 tab0 2590) (S : AccSim P VBOk ok [2673447, 12502])
    {V : LoopVals} {toks : List NumV} {i : Nat} {Q : St LF.S → Prop} (hQ : Q X.ec.sF)
    (hG : ExitGStepV Gx P fixA X.ec V toks i G) :
    CutGStepA addr0 Gx P noFrames LoopFrames.empty.toA fixA (X.segA S (toks.drop i)) V (EosGoal P fixA toks Q G) := by
  intro nx M K t C xF hGx hfix h hKfr hlo hhi hrun hgrow hext hν hKlo hKhi _ hend
  obtain ⟨hR, hKp, -⟩ := hend
  have hKfrF : ∀ a, xF.K.fr a ≠ none ↔ a ∈ [2673447, 12502, X.aN] := fun a => by
    exact (hKp.2.2 a).trans (by show a ∈ X.acc.jsP.framed ↔ _; rw [X.acc.hj.2.2])
  have hn : (X.segA S (toks.drop i)).case.n = X.ec.nA + 1 + 1 + X.ec.nB := ExitCaseA.toSeg_n _ _ _ _ _ _ _
  rw [hn] at hrun
  rw [hν] at hR
  exact ⟨hG nx M K t C xF.M xF.K xF.t xF.C hGx hfix h hKfr hlo hhi hrun hgrow hext hKlo hKhi hKfrF hR,
    i, xF.M, _, xF.K, _, _, hQ, hR, fun a ha => by rw [hext.a]; exact hfix a ha⟩

/-- An EOS final case's obligation gives its chain's, with the end relation. -/
theorem FinalEGStepV.toSegA (F : FinalESim P VBOk ok s0 tab0 2590 D) (S : AccSim P VBOk ok [2673447, 12502])
    {V : LoopVals} {T : Nat} {tk : Nat → Nat} {toks : List NumV} {Q : St LF.S → Prop} (hQ : Q F.ec.sF)
    (hG : FinalEGStepV Gx P fixA F.ec V T tk toks G) :
    LastGStepA addr0 Gx P noFrames LoopFrames.empty.toA fixA (F.segA S (toks.drop (T - 1))) V tk
      (EosGoal P fixA toks Q G) := by
  intro hlen nx M K t C xF hGx hfix h hKfr hlo hhi hrun hgrow hext hν hKlo hKhi _ hend
  obtain ⟨hR, hKp, -⟩ := hend
  have hKfrF : ∀ a, xF.K.fr a ≠ none ↔ a ∈ [2673447, 12502, F.aN] := fun a => by
    exact (hKp.2.2 a).trans (by show a ∈ F.acc.jsP.framed ↔ _; rw [F.acc.hj.2.2])
  have hn : (F.segA S (toks.drop (T - 1))).case.n = F.ec.nA + 1 + 1 + F.ec.nB := ExitCaseA.toSeg_n _ _ _ _ _ _ _
  rw [hn] at hrun
  rw [hν] at hR
  exact ⟨hG hlen nx M K t C xF.M xF.K xF.t xF.C hGx hfix h hKfr hlo hhi hrun hgrow hext hKlo hKhi hKfrF hR,
    T - 1, xF.M, _, xF.K, _, _, hQ, hR, fun a ha => by rw [hext.a]; exact hfix a ha⟩

/-- **`loop_source_eosL` from the route at today's constants.** -/
theorem loop_source_eosL_addr
    (S : AccSim P VBOk ok [2673447, 12502]) (st : LoopStart P s0 tab0)
    (hfr17 : ∀ e ∈ tab0, e.noVar 17 = true) (hcE : 2590 ∈ fixA) (hb : 12502 ∈ fixA)
    (cs : LoopCases ok P s0 tab0 fixA) {L ΔJ ΔH ΔN : Nat} (hcs : cs.OkAt L ΔJ ΔH ΔN)
    (X : ExitSim P VBOk ok s0 tab0 2590)
    (FE0 : FinalESim P VBOk ok s0 tab0 2590 (finalEDG false))
    (FE1 : FinalESim P VBOk ok s0 tab0 2590 (finalEDG true))
    {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {env : Env} {nm : Name}
    (henv : lookupEnv nm env = some 2590)
    (hT : 3 ≤ T) (hLT : L + T < 2 ^ 29) (hlen : T - 1 ≤ toks.length)
    (htk : ∀ j, j ≤ T → tk j ≤ 2 ^ 20)
    (k : Nat) (hk2 : 2 ≤ k) (hkT : k ≤ T) (notEos : ∀ j, 2 ≤ j → j < k → tk j ≠ 248044) (eos : tk k = 248044)
    (hVB : ∀ i nx, 1 ≤ i → i + 2 ≤ T → nx ≤ 2 ^ 20 → VBOk (valL ρ T tk L i nx))
    (hJ : T * ΔJ < Sim.bound) (hH : s0.ffi.mlx.next + T * ΔH + (P.E - s0.ffi.mlx.next) < 2 ^ 46)
    (hN : s0.ffi.mlx.nnext + T * ΔN + (P.NE - s0.ffi.mlx.nnext) < 2 ^ 62)
    (hG : ∀ i, 1 ≤ i → i + 1 < k → i + 2 < T → LoopGStepL Gx (loopSelL cs L i) L ρ T tk toks i)
    (hX : k < T → ExitGStepL Gx P fixA X.ec L ρ T tk toks (k - 1) G)
    (hF : k = T → (T - 2) % 256 ≠ 0 → FinalEGStepL Gx P fixA FE0.ec L ρ T tk toks G)
    (hF0 : k = T → (T - 2) % 256 = 0 → FinalEGStepL Gx P fixA FE1.ec L ρ T tk toks G)
    (Q : St LF.S → Prop) (hQX : Q X.ec.sF) (hQ0 : Q FE0.ec.sF) (hQ1 : Q FE1.ec.sF)
    {N0 : Nat} {t0 t1 : St LF.S} {C0 C1 : CSrv} (hpre : runC LF N0 t0 C0 = some (t1, C1))
    (h1 : LoopInvL Gx P s0 tab0 fixA L ρ T tk toks E0 ΔJ ΔH ΔN 1 t1 C1) :
    ∃ N tF CF, (∀ n, N ≤ n → runC LF n t0 C0 = some (tF, CF)) ∧ (∃ v, tF.ctl = .halt (.normal v)) ∧
      (bindingOf tF env nm).bind (Host.Load.Extract.elements tF) = some (E0 ++ (toks.take (k - 2)).map Val.num) ∧
      CSrv.Le C1 CF ∧ G tF CF ∧
      ∃ i MF ν KF s S, Q s ∧ Rel LF (LR P (toks.drop i)) MF ν KF s S tF CF ∧ ∀ a ∈ fixA, MF.a a = a := by
  have hsel : ∀ i, loopSelLA cs.toA L i = (loopSelL cs L i).toA := loopSelLA_toA cs L
  have hkp : ∀ K : Ctx, (∀ a, K.fr a ≠ none ↔ a ∈ addr0.fwd :: addr0.emit :: LoopFrames.empty.toA.xs) →
      K.lo = P.lo → K.hi = P.E → Disp.Kp S.jsP K := fun K hK hlo hhi =>
    ⟨hlo.trans S.hj.1.symm, hhi.trans S.hj.2.1.symm, fun a => by rw [hK a, S.hj.2.2]; rfl⟩
  obtain ⟨N, tF, CF, hrun, hv, hem, hle, hg, rest⟩ := decode_source_eosLA (A := addr0) (W := noFrames)
    (Fr := LoopFrames.empty.toA) (B := ⟨0, 0, 0⟩) (G := EosGoal P fixA toks Q G) rfl
    (S.toWL fun _ => Iff.rfl) st.toA hfr17 hcE hb rfl rfl cs.toA hcs.toA k hk2 hkT
    (fun i _ _ _ => by
      rw [hsel]
      exact (ShiftFWA_addr0 _).2 ((loopSelL cs L i).shiftFW_free (loopSelL cs L i).shiftF_empty))
    (fun i _ _ _ => by rw [hsel]; exact (KeepsA_addr0 _).2 (loopSelL cs L i).keeps_empty)
    (X.segA S _) X.cover (FE0.segA S _) (FE1.segA S _) FE0.cover FE1.cover
    (fun hk nx K hnx hK hlo hhi => ⟨hkp K hK hlo hhi, hVB (k - 1) nx (by omega) (by omega) hnx⟩)
    (fun K hK hlo hhi => ⟨⟨hkp K hK hlo hhi, hVB (T - 2) (tk T) (by omega) (by omega) (htk T le_rfl)⟩,
      ⟨hkp K hK hlo hhi, hVB (T - 2) (tk T) (by omega) (by omega) (htk T le_rfl)⟩⟩)
    henv hT hLT hlen htk notEos eos hVB (by simpa using hJ) (by simpa using hH) (by simpa using hN)
    (fun i h1 h2 h3 => by rw [hsel]; exact hG i h1 h2 h3)
    (fun h => ExitGStepV.toSegA X S hQX (hX h)) (fun h h0 => FinalEGStepV.toSegA FE0 S hQ0 (hF h h0))
    (fun h h0 => FinalEGStepV.toSegA FE1 S hQ1 (hF0 h h0)) hpre h1
  exact ⟨N, tF, CF, hrun, hv, hem, hle, hg, rest⟩

end

end Host.Ts.Sim
