import host.route.DecodeEosSaved
import host.sim.compose.a4b.FinalEos0
import host.sim.template.SavedBindings
import host.sim.compose.a4b.EosCutFramed
import host.sim.world.DecodeSourceFramed

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false

namespace Host.Route
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Host.Mlx.SimGraph.Mach (AneNetOk)
open Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Compose Host.Ts.Sim.Prefill
open Host.Load.Run.Prompt
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

variable {C : M1Max.Contract}

/-- The actual six-case decode loop followed by the actual final-token EOS exit without a preceding clear.
The starting invariant and its already emitted first token are initialization obligations;
all subsequent execution, EOS exclusion, graph preservation and stopping follow from the proofs. -/
theorem decode_final_eos0 (P : MlxPrefillContract C) (G : Metal.Gpu C) (Pg : KernelGpu.RoutePipelines G)
    (bytes : KernelGpu.SetBytes) (lseSum : Bool)
    (lseNumerator : Inference.Kernels.Attention.SdpaUpdate.Contraction)
    (NE : NeuralEngine) (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey)
    (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (π : List Nat) (T : Nat) (hπ : 1 ≤ π.length) (hlt : ∀ t ∈ π, t < 248320)
    (hT : 3 ≤ T) (hctx : π.length + T ≤ 262144)
    (hNE : NE.Succeeds net)
    (hnet : ∀ tab, AneNetOk net (stageWeights (weights (firstValues P.toMlxContract
      (routeKernel G bytes Pg lseSum lseNumerator).toKernelContract env tab))))
    (b0 : Host.Mlx.FfiAne.St) (q : List Val) (hql : q.length = π.length) (base : LoopBase)
    (hJ : T * DEC.ΔJ + base.D < Sim.bound)
    (hH : (mlxOf DEC.s0.ffi).next + T * DEC.ΔH + base.H +
      (DEC.Pw.E - (mlxOf DEC.s0.ffi).next) < 2 ^ 46)
    (hN : (mlxOf DEC.s0.ffi).nnext + T * DEC.ΔN + base.N +
      (DEC.Pw.NE - (mlxOf DEC.s0.ffi).nnext) < 2 ^ 62)
    (hrem : (T - 2) % 256 ≠ 0) :
    let KR := routeKernel G bytes Pg lseSum lseNumerator
    let tk := machTok P KR NE net env π
    let toks := .ref 2 :: machReads T tk
    let je := entryEnv (_root_.Host.Load.Run.Prompt.P.at0 (π.map natV) (machReads T tk))
    let Inv := DecodeInvW (fullWorldFb b0 15235) addrPrompt
      (machGx P KR NE net env π 15235 DEC.inputs) wideP DEC.Pw (framesP DEC.s0 q)
      DEC.s0 DEC.tab0 terminalFixP (valL (machVal T tk) T tk π.length) tk toks [.num (.ref 1)]
      base DEC.ΔJ DEC.ΔH DEC.ΔN
    ∀ t0 C0, Inv 1 t0 C0 → C0.val (.ref 1) = some (F64.ofNat (tk 1)) → FirstEos tk T T →
      ∃ N tF CF, (∀ n, N ≤ n → runC FF n t0 C0 = some (tF, CF)) ∧
        (∃ v, tF.ctl = .halt (.normal v)) ∧ CSrv.Le C0 CF ∧
        emittedValsW tF je chars!"emitted" CF = some (tokVals tk (T - 1)) ∧
        goalM P KR NE net env π 15235 T tF CF ∧ stopFin je tF := by
  intro KR tk toks je Inv t0 C0 hinv hfirst heos
  have hRT := route_refTokens P G Pg bytes lseSum lseNumerator NE net env leaves typed
    hπ (by omega) hlt hNE hnet
  have hv : ∀ j, tk j ≤ 248319 := machTok_le P KR NE net env π (hRT []) hπ hlt
  have hρ : ∀ j, ∃ n ≤ 2 ^ 20, machVal T tk j = F64.ofNat n := by
    intro j
    by_cases hj : j = 0
    · subst j
      exact ⟨T, by omega, rfl⟩
    · exact ⟨tk j, by have := hv j; omega, by simp only [machVal, ite_eq_right hj]⟩
  have hit := decode_iters_fixed P G Pg bytes lseSum lseNumerator NE net env leaves typed π T hπ hlt (by omega) hctx
    hNE hnet b0 q base hJ hH hN
  let hs := (DEC.finalEos0 b0 15235 q).seg (toks.drop (T - 1))
  have hg : LastGStepW (Wd := fullWorldFb b0 15235) addrPrompt
      (machGx P KR NE net env π 15235 DEC.inputs) DEC.Pw wideP (framesP DEC.s0 q)
      terminalFixP hs (valL (machVal T tk) T tk π.length) tk (goalM P KR NE net env π 15235 T) :=
    lastG_ofM P.toMlxContract KR.toKernelContract env (fullProjFb b0 15235) (DEC.startGM b0 15235)
      (DEC.finalEos0_graph b0 15235 q _) rfl rfl (by omega)
      (fun tab j _ => machTok_def P KR NE net env π (hRT []) hπ tab j)
      (fun j hj => by have := hv (j + 1); omega)
  have hgood := DEC.finalEos0_good b0 15235 q (ρ := machVal T tk) hT hctx (fun j _ => hv j)
    (heos.2.2.2 (T - 1) (by omega) (by omega)) heos.2.2.1 hrem
  have hh : DecodeHaltW Inv (T - 2) hs.case.n
      (FinGoalW je chars!"emitted" [.num (.ref 1)] toks (T - 2)
        (goalM P KR NE net env π 15235 T) (stopFin je)) := by
    exact decodeHalt_lastEW_framed (T := T) (V := valL (machVal T tk) T tk π.length)
      (tk := tk) (toks := toks) (E0 := [.num (.ref 1)]) (B := base)
      (ΔJ := DEC.ΔJ) (ΔH := DEC.ΔH) (ΔN := DEC.ΔN)
      (Fr := framesP DEC.s0 q) (fixA := terminalFixP)
      (DEC.start b0 15235) hs Host.Load.Run.Tpl.DT.noVar17
      (by decide) (by decide) (by decide) (by decide) (fun _ => upd_valL (tk T)) hT
      (by simp only [toks, List.length_cons, machReads, List.length_map, List.length_range]; omega) hgood
      (fun p1 K hfr hlo hhi => by
        have hfr' : K.fr = frA (S := FF.S) addrPrompt DEC.s0 (framesP DEC.s0 q).X p1
            ([.num (.ref 1)] ++ (toks.take (T - 3)).map Val.num) := by
          change K.fr = frA (S := FF.S) addrPrompt DEC.s0 (framesP DEC.s0 q).X p1
            ([.num (.ref 1)] ++ (toks.take (T - 2 - 1)).map Val.num) at hfr
          simpa only [Nat.sub_sub, show 2 + 1 = (3 : Nat) by rfl] using hfr
        exact DEC.finalEos0_entry b0 15235 (q := q) (p1 := p1) (K := K) (toks := toks)
          hρ hT hctx (fun j _ => hv j) hfr' hql hlo hhi)
      (Host.Load.Run.Prompt.saved_emitted (π.map natV) (machReads T tk))
      ((DEC.finalEos0_stopSrc b0 15235 q _).toW (by decide)
        (Host.Load.Run.Prompt.saved_generation (π.map natV) (machReads T tk))) hg
  obtain ⟨N, tF, CF, hrun, hhalt, hle, hgoal⟩ := decode_route_toW (Inv := Inv) (J := T - 2) (by omega)
    (fun i hi hij => hit i hi (by omega) fun j hj hj' => heos.2.2.2 j hj (by omega))
    ⟨hs.case.n, hh⟩ (N0 := 0) (t0 := t0) (C0 := C0) rfl hinv
  have hvals : ∀ j (hj : j < toks.length), C0.val toks[j] = some (F64.ofNat (tk (j + 2))) := by
    obtain ⟨_, _, _, _, _, _, _, _, _, _, _, hvals, _⟩ := hinv
    exact hvals
  have hvs := emitted_toks (m := T - 2) (hle.val hfirst) (fun j hj => hle.val (hvals j hj))
    (by simp only [toks, List.length_cons, machReads, List.length_map, List.length_range]; omega)
  rw [show T - 2 + 1 = T - 1 by omega] at hvs
  exact ⟨N, tF, CF, hrun, hhalt, hle, emittedValsW_of hgoal.1.1 hvs, hgoal.1.2, hgoal.2⟩

end Host.Route
