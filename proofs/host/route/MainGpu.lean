import host.route.Gpu
import host.route.Main
set_option maxRecDepth 1000000
namespace Host.Route
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Ts.Sim.Full (fullWorld mlxOf)
open Host.Load.Run.Prompt (ldStT aneNetLd_ok)

/-! # The route of a prompt with no Neural Engine forward, from the boot

`route_main_gpu`: `route_main` for prompts of at most 224 tokens, from `RouteGenGpu`. The bound is the schedule's: at
225 tokens the first step is a 224-row Neural Engine bucket (`first_tail_x22`, `rowBands`), and at most 224 tokens every
forward is on the GPU (`rowMem_short`, `host.sim.compose.Gpu`). The boot still loads the Neural Engine programs, so
`NE` and its success stay premises. -/

variable {C : M1Max.Contract}

/-- **The route of a prompt of at most 224 tokens, at the machine reference, every budget and first EOS position.**
It holds for every initial content `init` of the surfaces. -/
theorem route_main_gpu (P : MlxPrefillContract C) (G : Metal.Gpu C) (Pg : KernelGpu.RoutePipelines G)
    (B : KernelGpu.SetBytes) (lseSum : Bool) (lseNumerator : Inference.Kernels.Attention.SdpaUpdate.Contraction)
    (NE : NeuralEngine) (env : FfiEval.Env InKey) (leaves : Leaves code env.weights)
    (typed : TypedCheckpoint env.weights)
    (π : List Nat) (T : Nat) (hπ : 1 ≤ π.length) (hL : π.length ≤ 224) (hlt : ∀ t ∈ π, t < 248320) (hT : 1 ≤ T)
    (hctx : π.length + T ≤ 262144)
    (init : Nat → Surface)
    (hNE : NE.Succeeds (netLd P (routeKernel G B Pg lseSum lseNumerator) env init))
    (Gn : RouteGenGpu P (routeKernel G B Pg lseSum lseNumerator) NE
      (netLd P (routeKernel G B Pg lseSum lseNumerator) env init) env π T
      (tokLd P G Pg B lseSum lseNumerator NE env π init)
      (entryEnv (bootedSt π T (tokLd P G Pg B lseSum lseNumerator NE env π init))) chars!"emitted" (ldStT [] [])) :
    RouteOutcomeV P (routeKernel G B Pg lseSum lseNumerator) NE
      (netLd P (routeKernel G B Pg lseSum lseNumerator) env init) env leaves typed π Gn.kind T
      (bootedSt π T (tokLd P G Pg B lseSum lseNumerator NE env π init)) Gn.NB :=
  have hnet := aneNetLd_ok P.toMlxContract (routeKernel G B Pg lseSum lseNumerator).toKernelContract env
    (contentsLd P (routeKernel G B Pg lseSum lseNumerator) env) init
  have hRT := route_refTokens P G Pg B lseSum lseNumerator NE _ env leaves typed hπ (by omega) hlt hNE hnet
  route_gen_gpu P G Pg B lseSum lseNumerator NE env leaves typed π T hπ hL hlt hT hctx _ hNE hnet
    _ (bootedSt_boot π T _) Gn
    ⟨_, _, _, bootedSt_run π T _ Gn.NB,
      cutConv_inv Gn.hI (LoadedCut.ldPromptCut_inv Gn.NB Gn.Pw Gn.hPw Gn.W Gn.hW π hlt T _ (by omega)
        fun j => Nat.le_trans (machTok_le P _ NE _ env π (hRT []) hπ hlt j) (by decide))⟩

end Host.Route
