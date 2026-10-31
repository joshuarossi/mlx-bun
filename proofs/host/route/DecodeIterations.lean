import host.sim.compose.a4b.GraphLoopSupported
import host.route.Final

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false

namespace Host.Route
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Host.Mlx.SimGraph.Mach (AneNetOk)
open Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Ts.Sim.Compose
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

variable {C : M1Max.Contract}

/-- The supported actual decode iterations at the route's own reference and tokens.
Reference recurrence, token definedness and vocabulary bounds follow from the existing platform
and checkpoint contracts. Initialization and the final/EOS executions are separate obligations. -/
theorem decode_iters (P : MlxPrefillContract C) (G : Metal.Gpu C) (Pg : KernelGpu.RoutePipelines G)
    (bytes : KernelGpu.SetBytes) (lseSum : Bool)
    (lseNumerator : Inference.Kernels.Attention.SdpaUpdate.Contraction)
    (NE : NeuralEngine) (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey)
    (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (π : List Nat) (T : Nat) (hπ : 1 ≤ π.length) (hlt : ∀ t ∈ π, t < 248320)
    (hT : 1 ≤ T) (hctx : π.length + T ≤ 262144)
    (hNE : NE.Succeeds net)
    (hnet : ∀ tab, AneNetOk net (stageWeights (weights (firstValues P.toMlxContract
      (routeKernel G bytes Pg lseSum lseNumerator).toKernelContract env tab))))
    (b0 : Host.Mlx.FfiAne.St) (q : List Val) (base : LoopBase)
    (hJ : T * DEC.ΔJ + base.D < Sim.bound)
    (hH : (mlxOf DEC.s0.ffi).next + T * DEC.ΔH + base.H +
      (DEC.Pw.E - (mlxOf DEC.s0.ffi).next) < 2 ^ 46)
    (hN : (mlxOf DEC.s0.ffi).nnext + T * DEC.ΔN + base.N +
      (DEC.Pw.NE - (mlxOf DEC.s0.ffi).nnext) < 2 ^ 62) :
    let KR := routeKernel G bytes Pg lseSum lseNumerator
    let tk := machTok P KR NE net env π
    DecodeItersW (DecodeInvW (fullWorldFb b0 15235) Host.Load.Run.Prompt.addrPrompt
      (machGx P KR NE net env π 15235 DEC.inputs) wideP DEC.Pw (framesP DEC.s0 q)
      DEC.s0 DEC.tab0 fixP (valL (machVal T tk) T tk π.length) tk
      (.ref 2 :: machReads T tk) [.num (.ref 1)] base DEC.ΔJ DEC.ΔH DEC.ΔN) T tk := by
  intro KR tk
  have hRT := route_refTokens P G Pg bytes lseSum lseNumerator NE net env leaves typed
    hπ (by omega) hlt hNE hnet
  have hv : ∀ j, tk j ≤ 248319 := machTok_le P KR NE net env π (hRT []) hπ hlt
  have hρ : ∀ j, ∃ k ≤ 2 ^ 20, machVal T tk j = F64.ofNat k := by
    intro j
    by_cases hj : j = 0
    · subst j
      exact ⟨T, by omega, rfl⟩
    · exact ⟨tk j, by have := hv j; omega, by simp only [machVal, ite_eq_right hj]⟩
  exact DEC.itersMSupported P.toMlxContract KR.toKernelContract env leaves typed
    (Mach.refPrompt P KR NE KR.inPlace net env π) π.length
    (fun tab t ht => Mach.refPrompt_decodes P KR NE KR.inPlace net env π tab t (by omega))
    q hρ hπ hctx (by decide) (by rfl) (by rfl) (by rfl) hJ hH hN
    (by simp only [List.length_cons, machReads, List.length_map, List.length_range]; omega)
    (fun tab j _ => machTok_def P KR NE net env π (hRT []) hπ tab j) (fun j _ => hv j)

end Host.Route
