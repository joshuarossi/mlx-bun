import host.sim.world.Route
import host.sim.world.DecodeSourceFramed
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

namespace Host.Ts.Sim.Prefill
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The same route goal, using the exact frame contents already retained at each terminal cut. -/

section Route
variable {Wd : World} {A : Addr} {Gx : Nat → Map → St Wd.F.S → CSrv → Prop} {G : St Wd.F.S → CSrv → Prop}
  {GE : Nat → St Wd.F.S → CSrv → Prop} {W : Nat → Option WFrame} {P : Wd.Par} {Fr : LoopFramesA A}
  {s0 : St Wd.F.S} {tab0 : List SymE} {fixA : List Nat} {VBOk : (Nat → F64) → Prop}

/-- **The route of a prompt `π` over the world `Wd` with a budget `T ≥ 3`, every path**
(`RouteGoalW`), exhaustively over the first EOS position among tokens `1 … T`: none (the final
chains), `k = 1` (a path from the prefill's exit, `PathW`), `2 ≤ k < T` (the exit chain at the cut of
iteration `k - 1`; `k = 2` is the decode cut itself), `k = T` (the EOS final chains). Each path's
graph obligations are needed only on that path; the halting chains supply their end states'
finish reason (`HaltStopSrc`); the decode cut's prefix is token 1 (`he1`). -/
theorem source_tokens_prompt_routeW_framed (π : List Nat) {T : Nat} (hπ : 1 ≤ π.length) (hT : 3 ≤ T)
    (hctx : π.length + T ≤ 262144)
    -- the prefill to its exit, POST when token 1 is not EOS
    {I : PrefInvsW Wd.F} (SP : PrefStepsPW I) {nP : Nat}
    {ρ : Nat → F64} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {B : LoopBase} {ΔJ ΔH ΔN : Nat}
    (hpost : tk 1 ≠ 248044 → CutStep (I.ps π.length) (I.dec π.length) nP)
    -- the boot to loadDone and the loadDone cut
    {N0 : Nat} {t0 tL : St Wd.F.S} {C0 CL : CSrv} (hboot : runC Wd.F N0 t0 C0 = some (tL, CL))
    (hld : (I.ld π.length).Inv tL CL)
    -- the decode cut at the regenerated template's constants `A`, its prefix token 1
    (hdec : I.dec π.length = loopCutW Wd A Gx W P Fr s0 tab0 fixA (valL ρ T tk π.length) tk toks E0 B)
    {e1 : NumV} (hE0 : E0 = [.num e1])
    (he1 : ∀ t C, (I.dec π.length).Inv t C → C.val e1 = some (F64.ofNat (tk 1)))
    (hA : A.nxt = 17) (st : LoopStartW Wd A P s0 tab0)
    (hfrN : ∀ e ∈ tab0, e.noVar A.nxt = true) (hcE : A.cE ∈ fixA) (hb : A.emit ∈ fixA) (hgen : A.gen ∈ fixA)
    (hwc : W A.cE = none) (hwe : W A.emit = none)
    {env : Env} {nm : Name} (henv : lookupEnv nm env = some A.cE)
    (hgenv : lookupEnv chars!"generation" env = some A.gen)
    -- the decode iterations (with their graph obligations), however each is proven
    (hit : DecodeItersW (DecodeInvW Wd A Gx W P Fr s0 tab0 fixA (valL ρ T tk π.length) tk toks E0 B ΔJ ΔH ΔN) T tk)
    -- no EOS: the three final chains
    (F0 F1 F2 : HaltSegW Wd A W P (toks.drop (T - 1)) s0 (Wd.finalStartW s0 tab0.length) (tab0 ++ [.var A.nxt])
      [.num (.ref A.tok), .num (.ref tab0.length)])
    (c0 : FinalOk false false F0.S0.oracle) (c1 : FinalOk true false F1.S0.oracle)
    (c2 : FinalOk false true F2.S0.oracle)
    (hQA : ∀ p1 (K : Ctx),
      K.fr = frA A s0 Fr.X p1 (E0 ++ (toks.take (T - 2 - 1)).map Val.num) →
      K.lo = Wd.lo P → K.hi = Wd.E P →
      F0.QA (valL ρ T tk π.length (T - 2) (tk T)) K ∧ F1.QA (valL ρ T tk π.length (T - 2) (tk T)) K ∧
        F2.QA (valL ρ T tk π.length (T - 2) (tk T)) K)
    -- the first EOS at `2 ≤ k < T`: the exit chain at the cut of iteration `k - 1`
    (X : ∀ k, HaltSegW Wd A W P (toks.drop (k - 1)) s0 s0 tab0 []) (cX : ∀ k, ExitOk (X k).S0.oracle)
    (hQX : ∀ k, 2 ≤ k → k < T → ∀ nx p1 (K : Ctx), nx ≤ 2 ^ 20 →
      K.fr = frA A s0 Fr.X p1 (E0 ++ (toks.take (k - 1 - 1)).map Val.num) →
      K.lo = Wd.lo P → K.hi = Wd.E P → (X k).QA (valL ρ T tk π.length (k - 1) nx) K)
    (sX : ∀ k, 2 ≤ k → k < T → HaltStopSrc (X k))
    -- the first EOS at `T`: the two EOS final chains
    (FE0 FE1 : HaltSegW Wd A W P (toks.drop (T - 1)) s0 (Wd.finalStartW s0 tab0.length) (tab0 ++ [.var A.nxt])
      [.num (.ref A.tok)])
    (c0E : FinalEOk false FE0.S0.oracle) (c1E : FinalEOk true FE1.S0.oracle)
    (hQE : ∀ p1 (K : Ctx),
      K.fr = frA A s0 Fr.X p1 (E0 ++ (toks.take (T - 2 - 1)).map Val.num) →
      K.lo = Wd.lo P → K.hi = Wd.E P →
      FE0.QA (valL ρ T tk π.length (T - 2) (tk T)) K ∧ FE1.QA (valL ρ T tk π.length (T - 2) (tk T)) K)
    (s0E : HaltStopSrc FE0) (s1E : HaltStopSrc FE1)
    -- the first EOS at token 1: a path from the prefill's exit (the stage calls before the EOS test,
    -- one dispatched decode step, the halting chain), emitting nothing
    (P1 : tk 1 = 248044 → PathW Wd A W P fixA (I.ps π.length) [])
    (s1H : ∀ h, HaltStopSrc (P1 h).hs)
    -- the readbacks and the bounds
    (hlen : T - 1 ≤ toks.length) (htk : ∀ j, j ≤ T → tk j ≤ 2 ^ 20)
    -- the graph side of the halts, along each path
    (hF : NoEos tk T → (T - 2) % 256 ≠ 0 → (T - 1) % 256 ≠ 0 →
      LastGStepW A Gx P W Fr fixA F0 (valL ρ T tk π.length) tk G)
    (hF0 : NoEos tk T → (T - 2) % 256 = 0 → LastGStepW A Gx P W Fr fixA F1 (valL ρ T tk π.length) tk G)
    (hF1 : NoEos tk T → (T - 1) % 256 = 0 → LastGStepW A Gx P W Fr fixA F2 (valL ρ T tk π.length) tk G)
    (hX : ∀ k, 2 ≤ k → k < T → FirstEos tk T k → CutGStepW A Gx P W Fr fixA (X k) (valL ρ T tk π.length) (GE k))
    (hFE : FirstEos tk T T → (T - 2) % 256 ≠ 0 → LastGStepW A Gx P W Fr fixA FE0 (valL ρ T tk π.length) tk (GE T))
    (hFE0 : FirstEos tk T T → (T - 2) % 256 = 0 → LastGStepW A Gx P W Fr fixA FE1 (valL ρ T tk π.length) tk (GE T))
    (hG1 : ∀ h, (P1 h).Goal (GE 1)) :
    RouteGoalW t0 C0 env nm T tk G GE := by
  classical
  have hL2 : π.length ≤ 262143 := by omega
  have hLT : π.length + T < 2 ^ 29 := by omega
  have hps := prefill_reach_psW SP hπ hL2
  -- the decode cut after POST, with the prefix's and the readbacks' values
  have post : tk 1 ≠ 248044 → ∃ N1 t1 C1, runC Wd.F N1 t0 C0 = some (t1, C1) ∧
      DecodeInvW Wd A Gx W P Fr s0 tab0 fixA (valL ρ T tk π.length) tk toks E0 B ΔJ ΔH ΔN 1 t1 C1 ∧
      C1.val e1 = some (F64.ofNat (tk 1)) ∧ ∀ j (hj : j < toks.length), C1.val toks[j] = some (F64.ofNat (tk (j + 2))) := by
    intro h1
    obtain ⟨t1, C1, hr1, hinv⟩ := (hps.trans (hpost h1)) tL CL hld
    have hv1 := he1 t1 C1 hinv
    rw [hdec] at hinv
    have hinv' := (loopCutW_inv ΔJ ΔH ΔN t1 C1).1 hinv
    have hc := hinv'
    obtain ⟨_, _, _, _, _, _, _, _, _, _, _, hvals, -⟩ := hc
    exact ⟨_, t1, C1, runC_trans hboot hr1, hinv', hv1, hvals⟩
  by_cases hex : ∃ k, 1 ≤ k ∧ k ≤ T ∧ tk k = 248044
  · -- the first EOS
    obtain ⟨k, hk⟩ : ∃ k, FirstEos tk T k := FirstEos.exists_of hex
    obtain ⟨hk1, hkT, heos, hmin⟩ := hk
    refine RouteGoalW.ofFirst ⟨hk1, hkT, heos, hmin⟩ ?_
    by_cases hk1' : k = 1
    · -- token 1: a path from the prefill's exit
      subst hk1'
      obtain ⟨N, tF, CF, hr, hv, hle, hem, hg, hs⟩ := source_haltW hboot hld hps
        ((P1 heos).halt (Fin := stopFin env) hcE hb hwc henv ((s1H heos).toW hgen hgenv) (hG1 heos))
      exact ⟨N, tF, CF, hr, hv, hle, hem, hg, hs⟩
    · -- tokens `2 … T`: POST, then the decode route's EOS stop
      have hk2 : 2 ≤ k := by omega
      obtain ⟨N1, t1, C1, hpre, hinv, hv1, hvals⟩ := post (hmin 1 (Nat.le_refl _) (by omega))
      obtain ⟨N, tF, CF, hrun, hv, hle, ⟨hem, hg⟩, hfin⟩ := decode_source_eosLW_framed (Fin := stopFin env) (G := GE k)
        hA st hfrN hcE hb hwc hwe k hk2 hkT
        (fun i h1 h2 h3 => hit i h1 h3 fun j hj1 hj2 => hmin j hj1 (by omega)) (X k) (cX k) FE0 FE1 c0E c1E
        (fun h => hQX k hk2 h) hQE
        (fun h => (sX k hk2 h).toW hgen hgenv) (fun _ => s0E.toW hgen hgenv) (fun _ => s1E.toW hgen hgenv) henv hT
        hLT hlen htk (fun j h2 h3 => hmin j (by omega) h3) heos
        (fun h => hX k hk2 h ⟨hk1, hkT, heos, hmin⟩)
        (fun h hc => by subst h; exact hFE ⟨hk1, hkT, heos, hmin⟩ hc)
        (fun h hc => by subst h; exact hFE0 ⟨hk1, hkT, heos, hmin⟩ hc) hpre hinv
      rw [hE0] at hem
      have hvs := emitted_toks (m := k - 2) (hle.val hv1) (fun j hj => hle.val (hvals j hj)) (by omega)
      rw [show k - 2 + 1 = k - 1 by omega] at hvs
      exact ⟨N, tF, CF, hrun, hv, (runC_le _ _ _ _ _ hpre).trans hle, emittedValsW_of hem hvs, hg, hfin⟩
  · -- no EOS among tokens `1 … T`: POST, the decode route, the final chains
    have hno : NoEos tk T := fun j h1 h2 he => hex ⟨j, h1, h2, he⟩
    refine RouteGoalW.ofNo hno ?_
    obtain ⟨N1, t1, C1, hpre, hinv, hv1, hvals⟩ := post (hno 1 (Nat.le_refl _) (by omega))
    obtain ⟨N, tF, CF, hrun, hv, hle, hem, hg⟩ := decode_sourceLW_framed hA st hfrN hcE hb hwc hwe
      (fun i h1 h2 => hit i h1 h2 fun j hj1 hj2 => hno j hj1 (by omega))
      F0 F1 F2 c0 c1 c2 hQA henv hT hLT hlen htk (fun j h2 h3 => hno j (by omega) h3) (hF hno) (hF0 hno) (hF1 hno)
      hpre hinv
    rw [hE0] at hem
    have hvs := emitted_toks (m := T - 1) (hle.val hv1) (fun j hj => hle.val (hvals j hj)) hlen
    rw [show T - 1 + 1 = T by omega] at hvs
    exact ⟨N, tF, CF, hrun, hv, (runC_le _ _ _ _ _ hpre).trans hle, emittedValsW_of hem hvs, hg⟩


end Route
end Host.Ts.Sim.Prefill
