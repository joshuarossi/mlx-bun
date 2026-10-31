import host.route.DecodeIterationsFixed
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

/-- The actual six-case decode loop followed by the current middle-EOS exit.
The starting invariant and its already emitted first token are initialization obligations;
all subsequent execution, EOS exclusion, graph preservation and stopping follow from the proofs. -/
theorem decode_middle_eos (P : MlxPrefillContract C) (G : Metal.Gpu C) (Pg : KernelGpu.RoutePipelines G)
    (bytes : KernelGpu.SetBytes) (lseSum : Bool)
    (lseNumerator : Inference.Kernels.Attention.SdpaUpdate.Contraction)
    (NE : NeuralEngine) (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey)
    (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (π : List Nat) (T : Nat) (hπ : 1 ≤ π.length) (hlt : ∀ t ∈ π, t < 248320)
    (hT : 1 ≤ T) (hctx : π.length + T ≤ 262144)
    (hNE : NE.Succeeds net)
    (hnet : ∀ tab, AneNetOk net (stageWeights (weights (firstValues P.toMlxContract
      (routeKernel G bytes Pg lseSum lseNumerator).toKernelContract env tab))))
    (b0 : Host.Mlx.FfiAne.St) (q : List Val) (hql : q.length = π.length) (base : LoopBase)
    (hJ : T * DEC.ΔJ + base.D < Sim.bound)
    (hH : (mlxOf DEC.s0.ffi).next + T * DEC.ΔH + base.H +
      (DEC.Pw.E - (mlxOf DEC.s0.ffi).next) < 2 ^ 46)
    (hN : (mlxOf DEC.s0.ffi).nnext + T * DEC.ΔN + base.N +
      (DEC.Pw.NE - (mlxOf DEC.s0.ffi).nnext) < 2 ^ 62)
    (je : Host.Ts.Env) (nm : Host.Ts.Name)
    (henv : lookupEnv nm je = some addrPrompt.cE)
    (hgenv : lookupEnv chars!"generation" je = some addrPrompt.gen)
    (k : Nat) (hk2 : 2 ≤ k) (hkT : k < T) :
    let KR := routeKernel G bytes Pg lseSum lseNumerator
    let tk := machTok P KR NE net env π
    let toks := .ref 2 :: machReads T tk
    let Inv := DecodeInvW (fullWorldFb b0 15235) addrPrompt
      (machGx P KR NE net env π 15235 DEC.inputs) wideP DEC.Pw (framesP DEC.s0 q)
      DEC.s0 DEC.tab0 terminalFixP (valL (machVal T tk) T tk π.length) tk toks [.num (.ref 1)]
      base DEC.ΔJ DEC.ΔH DEC.ΔN
    ∀ t0 C0, Inv 1 t0 C0 → C0.val (.ref 1) = some (F64.ofNat (tk 1)) → FirstEos tk T k →
      ∃ N tF CF, (∀ n, N ≤ n → runC FF n t0 C0 = some (tF, CF)) ∧
        (∃ v, tF.ctl = .halt (.normal v)) ∧ CSrv.Le C0 CF ∧
        emittedValsW tF je nm CF = some (tokVals tk (k - 1)) ∧
        goalM P KR NE net env π 15235 k tF CF ∧ stopFin je tF := by
  intro KR tk toks Inv t0 C0 hinv hfirst heos
  have hRT := route_refTokens P G Pg bytes lseSum lseNumerator NE net env leaves typed
    hπ (by omega) hlt hNE hnet
  have hv : ∀ j, tk j ≤ 248319 := machTok_le P KR NE net env π (hRT []) hπ hlt
  have hρ : ∀ j, ∃ n ≤ 2 ^ 20, machVal T tk j = F64.ofNat n := by
    intro j
    by_cases hj : j = 0
    · subst j
      exact ⟨T, by omega, rfl⟩
    · exact ⟨tk j, by have := hv j; omega, by simp only [machVal, ite_eq_right hj]⟩
  have hit := decode_iters_fixed P G Pg bytes lseSum lseNumerator NE net env leaves typed π T hπ hlt hT hctx
    hNE hnet b0 q base hJ hH hN
  let hs := (DEC.eosCutFramed b0 15235).seg (toks.drop (k - 1))
  have hg : CutGStepW (Wd := fullWorldFb b0 15235) addrPrompt (machGx P KR NE net env π 15235 DEC.inputs) DEC.Pw wideP
      (framesP DEC.s0 q) terminalFixP hs (valL (machVal T tk) T tk π.length)
      (goalM P KR NE net env π 15235 k) :=
    cutG_ofM P.toMlxContract KR.toKernelContract env (fullProjFb b0 15235)
      (ρ := machVal T tk) (T := T) (tk := tk) (toks := toks) (L := π.length) (k := k) (DEC.startGM b0 15235)
      (by omega) (DEC.eosCutFramed_graph b0 15235 _) rfl
      (fun tab j _ => machTok_def P KR NE net env π (hRT []) hπ tab j) (by have := hv k; omega)
  have hh : DecodeHaltW Inv (k - 1) hs.case.n
      (FinGoalW je nm [.num (.ref 1)] toks (k - 2) (goalM P KR NE net env π 15235 k) (stopFin je)) := by
    have hhalt := decodeHalt_cutW_framed (tk := tk) (E0 := [.num (.ref 1)]) (B := base)
      (ΔJ := DEC.ΔJ) (ΔH := DEC.ΔH) (ΔN := DEC.ΔN) hs (by decide) (by decide) (by decide) (by decide)
      (fun nx hnx => good_exitW (DEC.eosCutFramed_exitOk b0 15235) (by omega) (by omega)
        (by rw [show k - 1 + 1 = k by omega]; exact heos.2.2.1) hnx (by omega) (by omega))
      (fun nx p1 K hnx hfr hlo hhi => DEC.eosCutFramed_entry b0 15235 hρ hctx (fun j _ => hv j)
        hfr hql hlo hhi k hk2 hkT nx hnx)
      henv (((DEC.eosCutFramed b0 15235).stop (DEC.eosCutFramed_stop b0 15235) _).toW (by decide) hgenv) hg
    simpa only [show k - 1 - 1 = k - 2 by omega] using hhalt
  obtain ⟨N, tF, CF, hrun, hhalt, hle, hgoal⟩ := decode_route_toW (Inv := Inv) (J := k - 1) (by omega)
    (fun i hi hij => hit i hi (by omega) fun j hj hj' => heos.2.2.2 j hj (by omega))
    ⟨hs.case.n, hh⟩ (N0 := 0) (t0 := t0) (C0 := C0) rfl hinv
  have hvals : ∀ j (hj : j < toks.length), C0.val toks[j] = some (F64.ofNat (tk (j + 2))) := by
    obtain ⟨_, _, _, _, _, _, _, _, _, _, _, hvals, _⟩ := hinv
    exact hvals
  have hvs := emitted_toks (m := k - 2) (hle.val hfirst) (fun j hj => hle.val (hvals j hj))
    (by simp only [toks, List.length_cons, machReads, List.length_map, List.length_range]; omega)
  rw [show k - 2 + 1 = k - 1 by omega] at hvs
  exact ⟨N, tF, CF, hrun, hhalt, hle, emittedValsW_of hgoal.1.1 hvs, hgoal.1.2, hgoal.2⟩

end Host.Route
