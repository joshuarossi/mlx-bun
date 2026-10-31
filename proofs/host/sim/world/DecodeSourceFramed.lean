import host.sim.world.Seam
import host.sim.world.FramedHalt
import host.sim.world.FramedLast

namespace Host.Ts.Sim.Prefill
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

section Halts
variable {Wd : World} {A : Addr} {Gx : Nat → Map → St Wd.F.S → CSrv → Prop} {G : St Wd.F.S → CSrv → Prop}
  {W : Nat → Option WFrame} {P : Wd.Par} {Fr : LoopFramesA A} {s0 : St Wd.F.S} {tab0 : List SymE} {fixA : List Nat}
  {V : LoopVals} {T : Nat} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {B : LoopBase} {ΔJ ΔH ΔN : Nat}
  {env : Env} {nm : Name}

/-- **A halting chain from the final template start discharges the halting contract** at `T - 2`
over `Wd` (`decodeHalt_lastA`). -/
theorem decodeHalt_lastW_framed (st : LoopStartW Wd A P s0 tab0)
    (hs : HaltSegW Wd A W P (toks.drop (T - 1)) s0 (Wd.finalStartW s0 tab0.length) (tab0 ++ [.var A.nxt])
      [.num (.ref A.tok), .num (.ref tab0.length)])
    (hfrN : ∀ e ∈ tab0, e.noVar A.nxt = true) (hcE : A.cE ∈ fixA) (hb : A.emit ∈ fixA)
    (hwc : W A.cE = none) (hwe : W A.emit = none)
    (hupd : ∀ nx, upd (V (T - 2) nx) A.nxt (F64.ofNat (tk T)) = V (T - 2) (tk T)) (hT : 3 ≤ T)
    (hlen : T - 1 ≤ toks.length) (hgood : Good (V (T - 2) (tk T)) hs.S0.oracle)
    (hQA : ∀ p1 (K : Ctx),
      K.fr = frA A s0 Fr.X p1 (E0 ++ (toks.take (T - 2 - 1)).map Val.num) →
      K.lo = Wd.lo P → K.hi = Wd.E P →
      hs.QA (V (T - 2) (tk T)) K)
    (henv : lookupEnv nm env = some A.cE) (hG : LastGStepW A Gx P W Fr fixA hs V tk G) :
    DecodeHaltW (DecodeInvW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN) (T - 2) hs.case.n
      (EmitGoalW env nm E0 toks (T - 1) G) := by
  intro t C hinv
  obtain ⟨tF, CF, v, hr, hv, hem, hle, hg, -⟩ := last_haltW_framed (ks := [A.tok, tab0.length]) st (.inr rfl) hs hfrN hcE
    hb hwc hwe hupd hinv hT hlen hgood hQA henv hG
  refine ⟨tF, CF, v, hr, hv, hle, ?_, hg⟩
  rw [hem, show T - 3 + [A.tok, tab0.length].length = T - 1 by simp; omega]

/-- **A halting chain from the final template start, the look-ahead token EOS**, over `Wd`
(`decodeHalt_lastEA`), with the chain's end fact `Fin` (the finish reason). -/
theorem decodeHalt_lastEW_framed {Fin : St Wd.F.S → Prop} (st : LoopStartW Wd A P s0 tab0)
    (hs : HaltSegW Wd A W P (toks.drop (T - 1)) s0 (Wd.finalStartW s0 tab0.length) (tab0 ++ [.var A.nxt])
      [.num (.ref A.tok)])
    (hfrN : ∀ e ∈ tab0, e.noVar A.nxt = true) (hcE : A.cE ∈ fixA) (hb : A.emit ∈ fixA)
    (hwc : W A.cE = none) (hwe : W A.emit = none)
    (hupd : ∀ nx, upd (V (T - 2) nx) A.nxt (F64.ofNat (tk T)) = V (T - 2) (tk T)) (hT : 3 ≤ T)
    (hlen : T - 1 ≤ toks.length) (hgood : Good (V (T - 2) (tk T)) hs.S0.oracle)
    (hQA : ∀ p1 (K : Ctx),
      K.fr = frA A s0 Fr.X p1 (E0 ++ (toks.take (T - 2 - 1)).map Val.num) →
      K.lo = Wd.lo P → K.hi = Wd.E P →
      hs.QA (V (T - 2) (tk T)) K)
    (henv : lookupEnv nm env = some A.cE) (hfin : HaltFinW hs fixA Fin)
    (hG : LastGStepW A Gx P W Fr fixA hs V tk G) :
    DecodeHaltW (DecodeInvW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN) (T - 2) hs.case.n
      (FinGoalW env nm E0 toks (T - 2) G Fin) := by
  intro t C hinv
  obtain ⟨tF, CF, v, hr, hv, hem, hle, hg, hF⟩ := last_haltW_framed (ks := [A.tok]) st (.inl rfl) hs hfrN hcE hb
    hwc hwe hupd hinv hT hlen hgood hQA henv hG
  refine ⟨tF, CF, v, hr, hv, hle, ⟨?_, hg⟩, hF Fin hfin⟩
  rw [hem, show T - 3 + [A.tok].length = T - 2 by simp; omega]

/-- **A halting chain at the cut of iteration `J` discharges the halting contract** there over
`Wd` (`decodeHalt_cutA`), with the chain's end fact `Fin` (the finish reason). -/
theorem decodeHalt_cutW_framed {J : Nat} {Fin : St Wd.F.S → Prop} (hs : HaltSegW Wd A W P (toks.drop J) s0 s0 tab0 [])
    (hcE : A.cE ∈ fixA)
    (hb : A.emit ∈ fixA) (hwc : W A.cE = none) (hwe : W A.emit = none)
    (hgood : ∀ nx, nx ≤ 2 ^ 20 → Good (V J nx) hs.S0.oracle)
    (hQA : ∀ nx p1 (K : Ctx), nx ≤ 2 ^ 20 →
      K.fr = frA A s0 Fr.X p1 (E0 ++ (toks.take (J - 1)).map Val.num) → K.lo = Wd.lo P →
      K.hi = Wd.E P → hs.QA (V J nx) K)
    (henv : lookupEnv nm env = some A.cE) (hfin : HaltFinW hs fixA Fin)
    (hG : CutGStepW A Gx P W Fr fixA hs V G) :
    DecodeHaltW (DecodeInvW Wd A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN) J hs.case.n
      (FinGoalW env nm E0 toks (J - 1) G Fin) := by
  intro t C hinv
  obtain ⟨tF, CF, v, hr, hv, hem, hle, hg, hF⟩ := cut_haltW_framed hs hcE hb hwc hwe hinv hgood hQA henv hG
  exact ⟨tF, CF, v, hr, hv, hle, ⟨hem, hg⟩, hF Fin hfin⟩

/-- **The three final chains discharge the halting contract** at `T - 2` by the cache-clear tests
of the last two tokens over `Wd` (`decodeHalt_last3A`), over `valL`, each chain's oracle decided
over its class's boxes (`FinalOk`). -/
theorem decodeHalt_last3W_framed (hA : A.nxt = 17) (st : LoopStartW Wd A P s0 tab0) {L : Nat} {ρ : Nat → F64}
    (F0 F1 F2 : HaltSegW Wd A W P (toks.drop (T - 1)) s0 (Wd.finalStartW s0 tab0.length) (tab0 ++ [.var A.nxt])
      [.num (.ref A.tok), .num (.ref tab0.length)])
    (c0 : FinalOk false false F0.S0.oracle) (c1 : FinalOk true false F1.S0.oracle)
    (c2 : FinalOk false true F2.S0.oracle)
    (hfrN : ∀ e ∈ tab0, e.noVar A.nxt = true) (hcE : A.cE ∈ fixA) (hb : A.emit ∈ fixA)
    (hwc : W A.cE = none) (hwe : W A.emit = none) (hT : 3 ≤ T)
    (hLT : L + T < 2 ^ 29) (hlen : T - 1 ≤ toks.length) (htk : ∀ j, j ≤ T → tk j ≤ 2 ^ 20)
    (notEos : ∀ k, 2 ≤ k → k ≤ T → tk k ≠ 248044)
    (hQA : ∀ p1 (K : Ctx),
      K.fr = frA A s0 Fr.X p1 (E0 ++ (toks.take (T - 2 - 1)).map Val.num) →
      K.lo = Wd.lo P → K.hi = Wd.E P →
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
    good_finalW hc (by omega) (by omega) (notEos (T - 2 + 1) (by omega) (by omega)) (notEos T (by omega) (Nat.le_refl _))
      (by omega) (by have := htk (T - 2 + 1) (by omega); omega) (by have := htk T (Nat.le_refl _); omega) h3 h7
  by_cases hc0 : (T - 2) % 256 = 0
  · exact ⟨_, decodeHalt_lastW_framed st F1 hfrN hcE hb hwc hwe hupd hT hlen
      (hg c1 (decide_eq_true hc0) (decide_eq_false (by omega)))
      (fun p1 K h1 h2 h3 => (hQA p1 K h1 h2 h3).2.1) henv (hF0 hc0)⟩
  · by_cases hc1 : (T - 1) % 256 = 0
    · exact ⟨_, decodeHalt_lastW_framed st F2 hfrN hcE hb hwc hwe hupd hT hlen
        (hg c2 (decide_eq_false hc0) (decide_eq_true (by omega)))
        (fun p1 K h1 h2 h3 => (hQA p1 K h1 h2 h3).2.2) henv (hF1 hc1)⟩
    · exact ⟨_, decodeHalt_lastW_framed st F0 hfrN hcE hb hwc hwe hupd hT hlen
        (hg c0 (decide_eq_false hc0) (decide_eq_false (by omega)))
        (fun p1 K h1 h2 h3 => (hQA p1 K h1 h2 h3).1) henv (hF hc0 hc1)⟩

end Halts

/-! ## End to end -/

/-- **The decode route after a prompt of length `L`, end to end, over `Wd`** (`decode_sourceLA`):
the iterations (`hit`: however each is proven, e.g. `LoopCasesW.iterW`), the three final chains
with their oracles decided over their boxes. -/
theorem decode_sourceLW_framed {Wd : World} {A : Addr} {Gx : Nat → Map → St Wd.F.S → CSrv → Prop}
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
    (hQA : ∀ p1 (K : Ctx),
      K.fr = frA A s0 Fr.X p1 (E0 ++ (toks.take (T - 2 - 1)).map Val.num) →
      K.lo = Wd.lo P → K.hi = Wd.E P →
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
    (decodeHalt_last3W_framed hA st F0 F1 F2 c0 c1 c2 hfrN hcE hb hwc hwe hT hLT hlen htk notEos hQA henv hF hF0 hF1)
    hpre h1

/-- **The decode route's EOS stop after a prompt of length `L`, end to end, over `Wd`**
(`decode_source_eosLA`): token `k` (`2 ≤ k ≤ T`) is EOS and the tokens before it are not; the
target halts with the `emitted` binding the base prefix and the first `k - 2` readbacks, and the
halting chains' end fact `Fin` holds (at `stopFin`: `generation.stats.finishReason` is `"stop"`).
The iterations before the stop are `hit`; the chains' oracles are decided over their boxes
(`ExitOk`, `FinalEOk`). -/
theorem decode_source_eosLW_framed {Wd : World} {A : Addr} {Gx : Nat → Map → St Wd.F.S → CSrv → Prop}
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
    (hQX : k < T → ∀ nx p1 (K : Ctx), nx ≤ 2 ^ 20 →
      K.fr = frA A s0 Fr.X p1 (E0 ++ (toks.take (k - 1 - 1)).map Val.num) →
      K.lo = Wd.lo P → K.hi = Wd.E P → X.QA (valL ρ T tk L (k - 1) nx) K)
    (hQE : ∀ p1 (K : Ctx),
      K.fr = frA A s0 Fr.X p1 (E0 ++ (toks.take (T - 2 - 1)).map Val.num) →
      K.lo = Wd.lo P → K.hi = Wd.E P →
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
      have hd := decodeHalt_cutW_framed (tk := tk) (E0 := E0) (B := B) (ΔJ := ΔJ) (ΔH := ΔH) (ΔN := ΔN) (env := env)
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
      · exact ⟨_, decodeHalt_lastEW_framed st FE1 hfrN hcE hb hwc hwe hupd hT hlen (hg c1 (decide_eq_true hc0))
          (fun p1 K h1 h2 h3 => (hQE p1 K h1 h2 h3).2) henv (s1E rfl) (hF0 rfl hc0)⟩
      · exact ⟨_, decodeHalt_lastEW_framed st FE0 hfrN hcE hb hwc hwe hupd hT hlen (hg c0 (decide_eq_false hc0))
          (fun p1 K h1 h2 h3 => (hQE p1 K h1 h2 h3).1) henv (s0E rfl) (hF rfl hc0)⟩)
    hpre h1

end Host.Ts.Sim.Prefill
