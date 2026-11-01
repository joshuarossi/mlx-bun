import host.route.FinalFramed
import host.sim.world.DecodeSourceFramed
import host.simgraph.mach.Schedule
import host.sim.full.World
import host.sim.full.BridgeFrame
import host.sim.full.BridgeJs
import host.mlx.KernelGpuPrefill
import host.load.RoutePrompt
import host.load.run.tail.World
import host.load.nat.Core
set_option maxRecDepth 1000000
namespace Host.Route
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.FfiAneEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Mlx.SimGraph.Mach (refPrompt prefillHolds_two RefTokens PrefillTyped prefillTyped_of_schedule scheduleTyped
  refPrompt_tokens_total AneNetOk)
open Host.Mlx.SimGraph.Ref (PrefillHolds refPromptModel)
open Host.Ts.Sim (Addr WFrame LoopFramesA LoopBase LoopStartW HaltSegW HaltStopSrc FinalOk ExitOk FinalEOk
  LastGStepW CutGStepW DecodeItersW DecodeInvW valL)
open Host.Ts.Sim.Prefill (RouteGoalW FirstEos NoEos PathW PrefInvsW PrefStepsPW CutStep tokVals loopCutW
  source_tokens_prompt_allW)
open Host.Ts.Sim.Full (FF fullWorldXD fullWorldFb Quiet bridgeOf mlxOf)


variable {C : M1Max.Contract}

/-! # The route's composition with the closures' reading chosen by the run

`RouteArtifactsFramed` fixes the table `kind` naming the compiled closures before the run. A prompt of at most 224 tokens
has one forward reading closures, the first tail, and the table naming the target's handles comes from the relation at its
return. So here the prefill's invariants carry `∃ kind`, and the decode loop, which holds at every table, runs at that one.

* `RouteArtifactsX`, `route_loopX`: `RouteArtifactsFramed`, `route_loopFb_framed` with the decode cut's table existential.
* `routeGoalW_exists`: only one case of a route's goal applies, so its table comes out.
* `route_finalX`: **`∃ kind, RouteOutcomeV … kind …`.** -/

/-- A decode loop's data. -/
structure LoopDataX (A : Addr) where
  Fr : LoopFramesA A
  s0 : St FF.S
  tab0 : List SymE
  Itpl : Iter.TplInputs
  ρ : Nat → F64
  toks : List NumV
  E0 : List Val
  B : LoopBase
  ΔJ : Nat
  ΔH : Nat
  ΔN : Nat

/-- `LoopCutV`: the decode cut holds at some table. -/
structure LoopCutX (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
    (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey) (π : List Nat)
    (T : Nat) (tk : Nat → Nat) (NB : Nat) (Pw Pd : Sim.LoadP) (A : Addr) (W : Nat → Option WFrame) (fixA : List Nat)
    (I : PrefInvsW (fullWorldXD NB).F) extends LoopDataX A where
  nP : Nat
  hpost : tk 1 ≠ 248044 → CutStep (I.ps π.length) (I.dec π.length) nP
  hdec : ∀ t Cs, (I.dec π.length).Inv t Cs → ∃ kind, (decCutFb NB A (machGxV P KR NE net env π kind NB Itpl) W Pd Fr s0 tab0 fixA
    (Sim.valL ρ T tk π.length) tk toks E0 B).Inv t Cs
  e1 : NumV
  hE0 : E0 = [.num e1]
  he1 : ∀ t Cs, (I.dec π.length).Inv t Cs → Cs.val e1 = some (F64.ofNat (tk 1))
  hA : A.nxt = 17
  hfrN : ∀ e ∈ tab0, e.noVar A.nxt = true
  hwe : W A.emit = none
  P1 : tk 1 = 248044 → PathW (fullWorldXD NB) A W Pw fixA (I.ps π.length) []
  s1H : ∀ h, Sim.HaltStopSrc (P1 h).hs
  hG1 : ∀ h, (P1 h).Goal (fun tF CF => ∃ kind, goalMV P KR NE net env π kind NB 1 tF CF)

structure LoopDecX (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
    (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey) (π : List Nat) (kind : Nat → Option Compiled) (T : Nat) (tk : Nat → Nat)
    (je : Host.Ts.Env) (NB : Nat) (Pd : Sim.LoadP) (A : Addr) (W : Nat → Option WFrame) (fixA : List Nat)
    (Lc : LoopDataX A) (b0 : Host.Mlx.FfiAne.St) where
  st : LoopStartW (fullWorldFb b0 NB) A Pd Lc.s0 Lc.tab0
  -- the decode iterations, each with its graph certificate
  hit : DecodeItersW (DecodeInvW (fullWorldFb b0 NB) A (machGxV P KR NE net env π kind NB Lc.Itpl) W Pd Lc.Fr Lc.s0
    Lc.tab0 fixA (valL Lc.ρ T tk π.length) tk Lc.toks Lc.E0 Lc.B Lc.ΔJ Lc.ΔH Lc.ΔN) T tk
  -- the final chains, the EOS exit, the EOS final chains
  F0 : HaltSegW (fullWorldFb b0 NB) A W Pd (Lc.toks.drop (T - 1)) Lc.s0
    ((fullWorldFb b0 NB).finalStartW Lc.s0 Lc.tab0.length) (Lc.tab0 ++ [.var A.nxt])
    [.num (.ref A.tok), .num (.ref Lc.tab0.length)]
  F1 : HaltSegW (fullWorldFb b0 NB) A W Pd (Lc.toks.drop (T - 1)) Lc.s0
    ((fullWorldFb b0 NB).finalStartW Lc.s0 Lc.tab0.length) (Lc.tab0 ++ [.var A.nxt])
    [.num (.ref A.tok), .num (.ref Lc.tab0.length)]
  F2 : HaltSegW (fullWorldFb b0 NB) A W Pd (Lc.toks.drop (T - 1)) Lc.s0
    ((fullWorldFb b0 NB).finalStartW Lc.s0 Lc.tab0.length) (Lc.tab0 ++ [.var A.nxt])
    [.num (.ref A.tok), .num (.ref Lc.tab0.length)]
  c0 : FinalOk false false F0.S0.oracle
  c1 : FinalOk true false F1.S0.oracle
  c2 : FinalOk false true F2.S0.oracle
  hQA : ∀ p1 (K : Sim.Ctx),
    K.fr = Sim.frA A Lc.s0 Lc.Fr.X p1 (Lc.E0 ++ (Lc.toks.take (T - 2 - 1)).map Val.num) →
    K.lo = Pd.lo → K.hi = Pd.E →
    F0.QA (valL Lc.ρ T tk π.length (T - 2) (tk T)) K ∧ F1.QA (valL Lc.ρ T tk π.length (T - 2) (tk T)) K ∧
      F2.QA (valL Lc.ρ T tk π.length (T - 2) (tk T)) K
  X : ∀ k, HaltSegW (fullWorldFb b0 NB) A W Pd (Lc.toks.drop (k - 1)) Lc.s0 Lc.s0 Lc.tab0 []
  cX : ∀ k, ExitOk (X k).S0.oracle
  hQX : ∀ k, 2 ≤ k → k < T → ∀ nx p1 (K : Sim.Ctx), nx ≤ 2 ^ 20 →
    K.fr = Sim.frA A Lc.s0 Lc.Fr.X p1 (Lc.E0 ++ (Lc.toks.take (k - 1 - 1)).map Val.num) →
    K.lo = Pd.lo → K.hi = Pd.E →
    (X k).QA (valL Lc.ρ T tk π.length (k - 1) nx) K
  sX : ∀ k, 2 ≤ k → k < T → HaltStopSrc (X k)
  FE0 : HaltSegW (fullWorldFb b0 NB) A W Pd (Lc.toks.drop (T - 1)) Lc.s0
    ((fullWorldFb b0 NB).finalStartW Lc.s0 Lc.tab0.length) (Lc.tab0 ++ [.var A.nxt]) [.num (.ref A.tok)]
  FE1 : HaltSegW (fullWorldFb b0 NB) A W Pd (Lc.toks.drop (T - 1)) Lc.s0
    ((fullWorldFb b0 NB).finalStartW Lc.s0 Lc.tab0.length) (Lc.tab0 ++ [.var A.nxt]) [.num (.ref A.tok)]
  c0E : FinalEOk false FE0.S0.oracle
  c1E : FinalEOk true FE1.S0.oracle
  hQE : ∀ p1 (K : Sim.Ctx),
    K.fr = Sim.frA A Lc.s0 Lc.Fr.X p1 (Lc.E0 ++ (Lc.toks.take (T - 2 - 1)).map Val.num) →
    K.lo = Pd.lo → K.hi = Pd.E →
    FE0.QA (valL Lc.ρ T tk π.length (T - 2) (tk T)) K ∧ FE1.QA (valL Lc.ρ T tk π.length (T - 2) (tk T)) K
  s0E : HaltStopSrc FE0
  s1E : HaltStopSrc FE1
  hlen : T - 1 ≤ Lc.toks.length
  -- the halts' graph certificates
  hF : NoEos tk T → (T - 2) % 256 ≠ 0 → (T - 1) % 256 ≠ 0 →
    LastGStepW (Wd := fullWorldFb b0 NB) A (machGxV P KR NE net env π kind NB Lc.Itpl) Pd W Lc.Fr fixA
      F0 (valL Lc.ρ T tk π.length) tk
      (goalCV P KR NE net env π kind NB T je)
  hF0 : NoEos tk T → (T - 2) % 256 = 0 →
    LastGStepW (Wd := fullWorldFb b0 NB) A (machGxV P KR NE net env π kind NB Lc.Itpl) Pd W Lc.Fr fixA
      F1 (valL Lc.ρ T tk π.length) tk
      (goalCV P KR NE net env π kind NB T je)
  hF1 : NoEos tk T → (T - 1) % 256 = 0 →
    LastGStepW (Wd := fullWorldFb b0 NB) A (machGxV P KR NE net env π kind NB Lc.Itpl) Pd W Lc.Fr fixA
      F2 (valL Lc.ρ T tk π.length) tk
      (goalCV P KR NE net env π kind NB T je)
  hX : ∀ k, 2 ≤ k → k < T → FirstEos tk T k →
    CutGStepW (Wd := fullWorldFb b0 NB) A (machGxV P KR NE net env π kind NB Lc.Itpl) Pd W Lc.Fr fixA
      (X k) (valL Lc.ρ T tk π.length)
      (goalMV P KR NE net env π kind NB k)
  hFE : FirstEos tk T T → (T - 2) % 256 ≠ 0 →
    LastGStepW (Wd := fullWorldFb b0 NB) A (machGxV P KR NE net env π kind NB Lc.Itpl) Pd W Lc.Fr fixA
      FE0 (valL Lc.ρ T tk π.length) tk
      (goalMV P KR NE net env π kind NB T)
  hFE0 : FirstEos tk T T → (T - 2) % 256 = 0 →
    LastGStepW (Wd := fullWorldFb b0 NB) A (machGxV P KR NE net env π kind NB Lc.Itpl) Pd W Lc.Fr fixA
      FE1 (valL Lc.ρ T tk π.length) tk
      (goalMV P KR NE net env π kind NB T)


/-- `RouteArtifactsFramed` with the closures' table chosen by the run. -/
structure RouteArtifactsX (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine) (net : Host.Mlx.SimGraph.Ref.AneNet)
    (env : FfiEval.Env InKey) (π : List Nat) (T : Nat) (tk : Nat → Nat) (je : Host.Ts.Env) (nm : Host.Ts.Name) where
  NB : Nat
  Pw : Sim.LoadP
  Pd : Sim.LoadP
  A : Addr
  W : Nat → Option WFrame
  fixA : List Nat
  I : PrefInvsW (fullWorldXD NB).F
  SP : PrefStepsPW I
  hcE : A.cE ∈ fixA
  hb : A.emit ∈ fixA
  hgen : A.gen ∈ fixA
  hwc : W A.cE = none
  henv : lookupEnv nm je = some A.cE
  hgenv : lookupEnv chars!"generation" je = some A.gen
  P21 : T = 2 → tk 1 = 248044 → PathW (fullWorldXD NB) A W Pw fixA (I.ps π.length) []
  P22 : T = 2 → tk 1 ≠ 248044 → tk 2 = 248044 → PathW (fullWorldXD NB) A W Pw fixA (I.ps π.length) (tokVals tk 1)
  P20 : T = 2 → tk 1 ≠ 248044 → tk 2 ≠ 248044 → PathW (fullWorldXD NB) A W Pw fixA (I.ps π.length) (tokVals tk 2)
  P11 : T = 1 → tk 1 = 248044 → PathW (fullWorldXD NB) A W Pw fixA (I.ps π.length) []
  P10 : T = 1 → tk 1 ≠ 248044 → PathW (fullWorldXD NB) A W Pw fixA (I.ps π.length) (tokVals tk 1)
  s21 : ∀ h h', HaltStopSrc (P21 h h').hs
  s22 : ∀ h h' h'', HaltStopSrc (P22 h h' h'').hs
  s11 : ∀ h h', HaltStopSrc (P11 h h').hs
  g21 : ∀ h h', (P21 h h').Goal (fun tF CF => ∃ kind, goalMV P KR NE net env π kind NB 1 tF CF)
  g22 : ∀ h h' h'', (P22 h h' h'').Goal (fun tF CF => ∃ kind, goalMV P KR NE net env π kind NB 2 tF CF)
  g20 : ∀ h h' h'', (P20 h h' h'').Goal (fun tF CF => ∃ kind, goalCV P KR NE net env π kind NB T je tF CF)
  g11 : ∀ h h', (P11 h h').Goal (fun tF CF => ∃ kind, goalMV P KR NE net env π kind NB 1 tF CF)
  g10 : ∀ h h', (P10 h h').Goal (fun tF CF => ∃ kind, goalCV P KR NE net env π kind NB T je tF CF)
  loop : 3 ≤ T → LoopCutX P KR NE net env π T tk NB Pw Pd A W fixA I
  dec : ∀ (h3 : 3 ≤ T) (b0 : Host.Mlx.FfiAne.St) (kind : Nat → Option Compiled),
    LoopDecX P KR NE net env π kind T tk je NB Pd A W fixA (loop h3).toLoopDataX b0

/-- **The route of a prompt with a budget `T ≥ 3`**, the table chosen at the decode cut. -/
theorem route_loopX {P : MlxPrefillContract C} {KR : RouteKernelContract C} {NE : NeuralEngine}
    {net : Host.Mlx.SimGraph.Ref.AneNet} {env : FfiEval.Env InKey} {π : List Nat} {T : Nat} {tk : Nat → Nat}
    {je : Host.Ts.Env} {nm : Host.Ts.Name} (Ar : RouteArtifactsX P KR NE net env π T tk je nm) (hπ : 1 ≤ π.length)
    (h3 : 3 ≤ T) (hctx : π.length + T ≤ 262144) {N0 : Nat} {t0 tL : St FF.S} {C0 CL : CSrv}
    (hboot : runC FF N0 t0 C0 = some (tL, CL)) (hld : (Ar.I.ld π.length).Inv tL CL)
    (htk : ∀ j, j ≤ T → tk j ≤ 2 ^ 20) :
    RouteGoalW t0 C0 je nm T tk (fun tF CF => ∃ kind, goalCV P KR NE net env π kind Ar.NB T je tF CF)
      (fun k tF CF => ∃ kind, goalMV P KR NE net env π kind Ar.NB k tF CF) := by
  classical
  let Lc := Ar.loop h3
  have hL2 : π.length ≤ 262143 := by omega
  have hLT : π.length + T < 2 ^ 29 := by omega
  have hps := Host.Ts.Sim.Prefill.prefill_reach_psW Ar.SP hπ hL2
  -- the decode cut after POST: a pinned bridge, the seam invariant over its world, the prefix's and readbacks' values
  have post : tk 1 ≠ 248044 → ∃ N1 t1 C1 b0 kind, runC FF N1 t0 C0 = some (t1, C1) ∧
      DecodeInvW (fullWorldFb b0 Ar.NB) Ar.A (machGxV P KR NE net env π kind Ar.NB Lc.Itpl) Ar.W Ar.Pd Lc.Fr Lc.s0 Lc.tab0
        Ar.fixA (valL Lc.ρ T tk π.length) tk Lc.toks Lc.E0 Lc.B Lc.ΔJ Lc.ΔH Lc.ΔN 1 t1 C1 ∧
      C1.val Lc.e1 = some (F64.ofNat (tk 1)) ∧
      ∀ j (hj : j < Lc.toks.length), C1.val Lc.toks[j] = some (F64.ofNat (tk (j + 2))) := by
    intro h1
    obtain ⟨t1, C1, hr1, hinv⟩ := (hps.trans (Lc.hpost h1)) tL CL hld
    have hv1 := Lc.he1 t1 C1 hinv
    obtain ⟨kind, hinv⟩ := Lc.hdec t1 C1 hinv
    obtain ⟨b0, hinv⟩ := decCutFb_inv hinv
    have hinv' := (Host.Ts.Sim.Prefill.loopCutW_inv (Wd := fullWorldFb b0 Ar.NB) Lc.ΔJ Lc.ΔH Lc.ΔN t1 C1).1 hinv
    have hc := hinv'
    obtain ⟨_, _, _, _, _, _, _, _, _, _, _, hvals, -⟩ := hc
    exact ⟨_, t1, C1, b0, kind, Host.Ts.Sim.runC_trans hboot hr1, hinv', hv1, hvals⟩
  by_cases hex : ∃ k, 1 ≤ k ∧ k ≤ T ∧ tk k = 248044
  · -- the first EOS
    obtain ⟨k, hk⟩ : ∃ k, FirstEos tk T k := by
      refine ⟨Nat.find hex, (Nat.find_spec hex).1, (Nat.find_spec hex).2.1, (Nat.find_spec hex).2.2,
        fun j h1 h2 he => Nat.find_min hex h2 ⟨h1, ?_, he⟩⟩
      have := (Nat.find_spec hex).2.1; omega
    obtain ⟨hk1, hkT, heos, hmin⟩ := hk
    refine Host.Ts.Sim.Prefill.RouteGoalW.ofFirst ⟨hk1, hkT, heos, hmin⟩ ?_
    by_cases hk1' : k = 1
    · -- token 1: a path from the prefill's exit
      subst hk1'
      obtain ⟨N, tF, CF, hr, hv, hle, hem, hg, hs⟩ := Host.Ts.Sim.Prefill.source_haltW hboot hld hps
        ((Lc.P1 heos).halt (Fin := Host.Ts.Sim.stopFin je) Ar.hcE Ar.hb Ar.hwc Ar.henv
          ((Lc.s1H heos).toW Ar.hgen Ar.hgenv) (Lc.hG1 heos))
      exact ⟨N, tF, CF, hr, hv, hle, hem, hg, hs⟩
    · -- tokens `2 … T`: POST, then the decode route's EOS stop at the pinned bridge
      have hk2 : 2 ≤ k := by omega
      obtain ⟨N1, t1, C1, b0, kind, hpre, hinv, hv1, hvals⟩ := post (hmin 1 le_rfl (by omega))
      let Ld := Ar.dec h3 b0 kind
      obtain ⟨N, tF, CF, hrun, hv, hle, ⟨hem, hg⟩, hfin⟩ := Host.Ts.Sim.Prefill.decode_source_eosLW_framed (Wd := fullWorldFb b0 Ar.NB)
        (Fin := Host.Ts.Sim.stopFin je) (G := goalMV P KR NE net env π kind Ar.NB k)
        Lc.hA Ld.st Lc.hfrN Ar.hcE Ar.hb Ar.hwc Lc.hwe k hk2 hkT
        (fun i h1 h2 h3' => Ld.hit i h1 h3' fun j hj1 hj2 => hmin j hj1 (by omega)) (Ld.X k) (Ld.cX k) Ld.FE0 Ld.FE1
        Ld.c0E Ld.c1E (fun h => Ld.hQX k hk2 h) Ld.hQE
        (fun h => (Ld.sX k hk2 h).toW Ar.hgen Ar.hgenv) (fun _ => Ld.s0E.toW Ar.hgen Ar.hgenv)
        (fun _ => Ld.s1E.toW Ar.hgen Ar.hgenv) Ar.henv h3 hLT Ld.hlen htk (fun j h2 h3' => hmin j (by omega) h3') heos
        (fun h => Ld.hX k hk2 h ⟨hk1, hkT, heos, hmin⟩)
        (fun h hc => by subst h; exact Ld.hFE ⟨hk1, hkT, heos, hmin⟩ hc)
        (fun h hc => by subst h; exact Ld.hFE0 ⟨hk1, hkT, heos, hmin⟩ hc) hpre hinv
      rw [Lc.hE0] at hem
      have hvs := Host.Ts.Sim.Prefill.emitted_toks (m := k - 2) (hle.val hv1) (fun j hj => hle.val (hvals j hj))
        (by have hl : T - 1 ≤ Lc.toks.length := Ld.hlen; omega)
      rw [show k - 2 + 1 = k - 1 by omega] at hvs
      exact ⟨N, tF, CF, hrun, hv, (Host.Ts.Sim.runC_le _ _ _ _ _ hpre).trans hle,
        Host.Ts.Sim.Prefill.emittedValsW_of hem hvs, ⟨kind, hg⟩, hfin⟩
  · -- no EOS among tokens `1 … T`: POST, the decode route at the pinned bridge, the final chains
    have hno : NoEos tk T := fun j h1 h2 he => hex ⟨j, h1, h2, he⟩
    refine Host.Ts.Sim.Prefill.RouteGoalW.ofNo hno ?_
    obtain ⟨N1, t1, C1, b0, kind, hpre, hinv, hv1, hvals⟩ := post (hno 1 le_rfl (by omega))
    let Ld := Ar.dec h3 b0 kind
    obtain ⟨N, tF, CF, hrun, hv, hle, hem, hg⟩ := Host.Ts.Sim.Prefill.decode_sourceLW_framed (Wd := fullWorldFb b0 Ar.NB) Lc.hA Ld.st
      Lc.hfrN Ar.hcE Ar.hb Ar.hwc
      Lc.hwe (fun i h1 h2 => Ld.hit i h1 h2 fun j hj1 hj2 => hno j hj1 (by omega))
      Ld.F0 Ld.F1 Ld.F2 Ld.c0 Ld.c1 Ld.c2 Ld.hQA Ar.henv h3 hLT Ld.hlen htk (fun j h2 h3' => hno j (by omega) h3')
      (Ld.hF hno) (Ld.hF0 hno) (Ld.hF1 hno) hpre hinv
    rw [Lc.hE0] at hem
    have hvs := Host.Ts.Sim.Prefill.emitted_toks (m := T - 1) (hle.val hv1) (fun j hj => hle.val (hvals j hj)) Ld.hlen
    rw [show T - 1 + 1 = T by omega] at hvs
    exact ⟨N, tF, CF, hrun, hv, (Host.Ts.Sim.runC_le _ _ _ _ _ hpre).trans hle,
      Host.Ts.Sim.Prefill.emittedValsW_of hem hvs, ⟨kind, hg⟩⟩

/-- Only one case of a route's goal applies, so its witness comes out. -/
theorem routeGoalW_exists {F : Host.Ts.Ffi} {t0 : St F.S} {C0 : CSrv} {env : Host.Ts.Env} {nm : Host.Ts.Name} {T : Nat} {tk : Nat → Nat}
    {ι : Type} {G : ι → St F.S → CSrv → Prop} {GE : ι → Nat → St F.S → CSrv → Prop}
    (h : RouteGoalW t0 C0 env nm T tk (fun tF CF => ∃ i, G i tF CF) (fun k tF CF => ∃ i, GE i k tF CF)) :
    ∃ i, RouteGoalW t0 C0 env nm T tk (G i) (GE i) := by
  obtain ⟨N, tF, CF, hr, hv, hle, hno, hfst⟩ := h
  by_cases hex : ∃ k, 1 ≤ k ∧ k ≤ T ∧ tk k = 248044
  · obtain ⟨k, hk⟩ := Host.Ts.Sim.Prefill.FirstEos.exists_of hex
    obtain ⟨hem, ⟨i, hg⟩, hs⟩ := hfst k hk
    refine ⟨i, N, tF, CF, hr, hv, hle, fun hn => absurd hk.2.2.1 (hn k hk.1 hk.2.1), fun k' hk' => ?_⟩
    obtain rfl := hk.unique hk'
    exact ⟨hem, hg, hs⟩
  · have hn : NoEos tk T := fun j h1 h2 he => hex ⟨j, h1, h2, he⟩
    obtain ⟨hem, i, hg⟩ := hno hn
    exact ⟨i, N, tF, CF, hr, hv, hle, fun _ => ⟨hem, hg⟩, fun k ⟨h1, h2, h3, _⟩ => absurd ⟨k, h1, h2, h3⟩ hex⟩

/-- **The route of a prompt, at the machine reference, every budget and first EOS position**, the closures' table chosen
by the run. -/
theorem route_finalX (P : MlxPrefillContract C) (G : Metal.Gpu C) (Pg : KernelGpu.RoutePipelines G)
    (B : KernelGpu.SetBytes) (lseSum : Bool) (lseNumerator : Inference.Kernels.Attention.SdpaUpdate.Contraction)
    (NE : NeuralEngine) (env : FfiEval.Env InKey) (leaves : Leaves code env.weights)
    (typed : TypedCheckpoint env.weights)
    (π : List Nat) (T : Nat) (hπ : 1 ≤ π.length) (hlt : ∀ t ∈ π, t < 248320) (hT : 1 ≤ T)
    (hctx : π.length + T ≤ 262144)
    (net : Host.Mlx.SimGraph.Ref.AneNet)
    (hNE : NE.Succeeds net)
    (hnet : ∀ tab, AneNetOk net (stageWeights (weights (firstValues P.toMlxContract
      (routeKernel G B Pg lseSum lseNumerator).toKernelContract env tab))))
    (s : St LSt)
    (hs : bootL (RoutePrompt.cx π) (routeWorld T (machTok P (routeKernel G B Pg lseSum lseNumerator) NE net env π))
      2000 = some s)
    (Ar : RouteArtifactsX P (routeKernel G B Pg lseSum lseNumerator) NE net env π T
      (machTok P (routeKernel G B Pg lseSum lseNumerator) NE net env π) (entryEnv s) chars!"emitted")
    (hboot : ∃ N0 tL CL, runC (fullWorldXD Ar.NB).F N0 (bootStart s)
      (routeServer T (machTok P (routeKernel G B Pg lseSum lseNumerator) NE net env π)) = some (tL, CL) ∧
      (Ar.I.ld π.length).Inv tL CL) :
    ∃ kind, RouteOutcomeV P (routeKernel G B Pg lseSum lseNumerator) NE net env leaves typed π kind T s Ar.NB := by
  obtain ⟨N0, tL, CL, hrun, hld⟩ := hboot
  have hRT := route_refTokens P G Pg B lseSum lseNumerator NE net env leaves typed hπ (by omega) hlt hNE hnet
  have hdef := fun tab j (_ : j < T) => machTok_def P (routeKernel G B Pg lseSum lseNumerator) NE net env π (hRT []) hπ tab j
  have htkb : ∀ j, j ≤ T → machTok P (routeKernel G B Pg lseSum lseNumerator) NE net env π j ≤ 2 ^ 20 := fun j _ =>
    Nat.le_trans (machTok_le P _ NE net env π (hRT []) hπ hlt j) (by decide)
  have hm : RouteGoalW (bootStart s) (routeServer T (machTok P (routeKernel G B Pg lseSum lseNumerator) NE net env π))
      (entryEnv s) chars!"emitted" T (machTok P (routeKernel G B Pg lseSum lseNumerator) NE net env π)
      (fun tF CF => ∃ kind, goalCV P (routeKernel G B Pg lseSum lseNumerator) NE net env π kind Ar.NB T (entryEnv s) tF CF)
      (fun k tF CF => ∃ kind, goalMV P (routeKernel G B Pg lseSum lseNumerator) NE net env π kind Ar.NB k tF CF) := by
    refine source_tokens_prompt_allW (Wd := fullWorldXD Ar.NB) (A := Ar.A) (W := Ar.W) (P := Ar.Pw) (fixA := Ar.fixA)
      π hπ hT hctx Ar.SP hrun hld Ar.hcE Ar.hb Ar.hgen Ar.hwc Ar.henv Ar.hgenv
      (fun h3 => ?_) Ar.P21 Ar.P22 Ar.P20 Ar.P11 Ar.P10 Ar.s21 Ar.s22 Ar.s11 Ar.g21 Ar.g22 Ar.g20 Ar.g11 Ar.g10
    exact route_loopX Ar hπ h3 hctx hrun hld htkb
  obtain ⟨kind, hm⟩ := routeGoalW_exists hm
  refine ⟨kind, ?_⟩
  unfold RouteOutcomeV
  refine ⟨hm, hRT, fun hL parameters => ?_⟩
  have h := prefillHolds_short P (routeKernel G B Pg lseSum lseNumerator) NE net env leaves typed parameters hπ hL hlt
  have hm' := hm.mono (G' := goalMV P (routeKernel G B Pg lseSum lseNumerator) NE net env π kind Ar.NB T)
    (GE' := fun k => goalMV P (routeKernel G B Pg lseSum lseNumerator) NE net env π kind Ar.NB k) (fun _ _ hg => hg.1)
    (fun _ _ _ _ hg => hg)
  exact ⟨h, route_model_of_machV P _ NE _ net env (routeVs P _ env kind) leaves typed parameters (Wd := fullWorldXD Ar.NB) h hlt hπ hdef hm'⟩

end Host.Route
