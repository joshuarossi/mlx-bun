import host.route.DecodeIterationsFixed
import host.sim.compose.a4b.GraphPiecesFixed
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

/-- From the actual initialized decode cut, all supported iterations and the selected budget exit
halt with the reference tokens and cache values. Initialization remains an explicit obligation. -/
theorem decode_budget_saved (P : MlxPrefillContract C) (G : Metal.Gpu C) (Pg : KernelGpu.RoutePipelines G)
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
      (DEC.Pw.NE - (mlxOf DEC.s0.ffi).nnext) < 2 ^ 62) :
    let KR := routeKernel G bytes Pg lseSum lseNumerator
    let tk := machTok P KR NE net env π
    let toks := .ref 2 :: machReads T tk
    let je := entryEnv (_root_.Host.Load.Run.Prompt.P.at0 (π.map natV) (machReads T tk))
    let Inv := DecodeInvW (fullWorldFb b0 15235) addrPrompt
      (machGx P KR NE net env π 15235 DEC.inputs) wideP DEC.Pw (framesP DEC.s0 q)
      DEC.s0 DEC.tab0 terminalFixP (valL (machVal T tk) T tk π.length) tk toks [.num (.ref 1)]
      base DEC.ΔJ DEC.ΔH DEC.ΔN
    ∀ t0 C0, Inv 1 t0 C0 → C0.val (.ref 1) = some (F64.ofNat (tk 1)) → NoEos tk T →
      ∃ N tF CF, (∀ n, N ≤ n → runC FF n t0 C0 = some (tF, CF)) ∧
        (∃ v, tF.ctl = .halt (.normal v)) ∧ CSrv.Le C0 CF ∧
        emittedValsW tF je chars!"emitted" CF = some (tokVals tk T) ∧
        goalC P KR NE net env π 15235 T je tF CF := by
  intro KR tk toks je Inv t0 C0 hinv hfirst hno
  have hRT := route_refTokens P G Pg bytes lseSum lseNumerator NE net env leaves typed
    hπ (by omega) hlt hNE hnet
  have hv : ∀ j, tk j ≤ 248319 := machTok_le P KR NE net env π (hRT []) hπ hlt
  have hρ : ∀ j, ∃ n ≤ 2 ^ 20, machVal T tk j = F64.ofNat n := by
    intro j
    by_cases hj : j = 0
    · subst j
      exact ⟨T, by omega, rfl⟩
    · exact ⟨tk j, by have := hv j; omega, by simp only [machVal, ite_eq_right hj]⟩
  let D := DEC.piecesFramedFixed (b0 := b0) (NB := 15235) (ρ := machVal T tk) (toks := toks)
    q hql hρ hπ hT hctx (fun j _ => hv j) le_rfl le_rfl le_rfl hJ hH hN
  let Dg := DEC.graphPiecesFramedFixed P KR env π (b0 := b0) (NB := 15235)
    q hql hρ hπ hT hctx (fun j _ => hv j) le_rfl le_rfl le_rfl le_rfl hJ hH hN
  have hit := decode_iters_fixed P G Pg bytes lseSum lseNumerator NE net env leaves typed π T hπ hlt (by omega) hctx
    hNE hnet b0 q base hJ hH hN
  obtain ⟨N, tF, CF, hrun, hhalt, hle, hem, hg⟩ := decode_sourceLW_framed
    (Wd := fullWorldFb b0 15235) (G := goalC P KR NE net env π 15235 T je)
    rfl (DEC.start b0 15235) Host.Load.Run.Tpl.DT.noVar17
    (by decide) (by decide) (by decide) (by decide)
    (fun i hi hij => hit i hi hij fun j hj hj' => hno j hj (by omega))
    (D.f0.seg _) (D.f1.seg _) (D.f2.seg _) D.c0 D.c1 D.c2 D.qF
    (Host.Load.Run.Prompt.saved_emitted (π.map natV) (machReads T tk)) hT (by omega)
    (by simp only [toks, List.length_cons, machReads, List.length_map, List.length_range]; omega)
    (fun j _ => Nat.le_trans (hv j) (by decide)) (fun j hj hj' => hno j (by omega) hj')
    (fun _ _ => lastGC_ofM P KR NE net env π Dg.st Dg.f0 Dg.c0.cache rfl rfl (by omega)
      (fun tab j _ => machTok_def P KR NE net env π (hRT []) hπ tab j)
      (fun j hj => by change tk (j + 1) < 2 ^ 31; have := hv (j + 1); omega))
    (fun _ => lastGC_ofM P KR NE net env π Dg.st Dg.f1 Dg.c1.cache rfl rfl (by omega)
      (fun tab j _ => machTok_def P KR NE net env π (hRT []) hπ tab j)
      (fun j hj => by change tk (j + 1) < 2 ^ 31; have := hv (j + 1); omega))
    (fun _ => lastGC_ofM P KR NE net env π Dg.st Dg.f2 Dg.c2.cache rfl rfl (by omega)
      (fun tab j _ => machTok_def P KR NE net env π (hRT []) hπ tab j)
      (fun j hj => by change tk (j + 1) < 2 ^ 31; have := hv (j + 1); omega))
    (N0 := 0) (t0 := t0) (C0 := C0) rfl hinv
  have hvals : ∀ j (hj : j < toks.length), C0.val toks[j] = some (F64.ofNat (tk (j + 2))) := by
    obtain ⟨_, _, _, _, _, _, _, _, _, _, _, hvals, _⟩ := hinv
    exact hvals
  have hvs := emitted_toks (m := T - 1) (hle.val hfirst) (fun j hj => hle.val (hvals j hj))
    (by simp only [toks, List.length_cons, machReads, List.length_map, List.length_range]; omega)
  rw [show T - 1 + 1 = T by omega] at hvs
  exact ⟨N, tF, CF, hrun, hhalt, hle, emittedValsW_of hem hvs, hg⟩

end Host.Route
